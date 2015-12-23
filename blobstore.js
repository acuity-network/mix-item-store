var Web3 = require('web3');

// @see https://gist.github.com/frozeman/fbc7465d0b0e6c1c4c23
if (typeof web3 !== 'undefined') {
  var defaultAccount = web3.eth.defaultAccount;
  web3 = new Web3(web3.currentProvider);
  web3.eth.defaultAccount = defaultAccount;
}
else {
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  web3.eth.defaultAccount = web3.eth.accounts[0];
}

var blobStoreAbi = require('./blobstore.abi.json');
var blobStoreContract = web3.eth.contract(blobStoreAbi);
var blobStoreAddress = '0x4544da6c0e65c0eb73646f4e55be848d3d02e0fd';
var blobStore = blobStoreContract.at(blobStoreAddress);

// solc version: 0.2.0-0/Release-Linux/g++/int linked to libethereum-1.1.0-0/Release-Linux/g++/int

getBlobHash = function(blob) {
  return '0x' + web3.sha3(blob.toString('hex'), {encoding: 'hex'});
}

var getBlobBlockNumber = function(hash, block, callback) {
  // Determine the block that includes the transaction for this blob.
  blobStore.getBlobBlockNumber(hash, {}, block, function(error, result) {
    if (error) {
      callback(error);
    }
    else {
      callback(null, result.toNumber());
    }
  });
}

function tx(blob) {
  return {
    to: blobStoreAddress,
    data: blobStore.storeBlob.getData('0x' + blob.toString('hex'))
  };
}

var getGas = function(blob, callback) {
  // Calculate maximum transaction gas.
  web3.eth.estimateGas(tx(blob), 'pending', callback);
}

var storeBlob = function(blob, callback) {
  // Determine hash of blob.
  var hash = getBlobHash(blob);
  // Create transaction object.
  var tx = tx(blob);
  // Calculate maximum transaction gas.
  web3.eth.estimateGas(tx, 'pending', function(error, gas) {
    if (error) { callback(error); return; }
    tx.gas = gas;
    // Broadcast the transaction.
    web3.eth.sendTransaction(tx, function(error, result) {
      if (error) { callback(error); return; }
      // Check that the transaction has been broadcast.
      getBlobBlockNumber(hash, 'pending', function(error, blockNumber) {
        // Make sure we are not looking at a really old copy that could get
        // pruned.
        if (blockNumber < web3.eth.blockNumber - 100) {
          callback("Blob failed to broadcast.");
        }
        else {
          callback(null, hash);
        }
      });
    });
  });
  return hash;
}

function getBlobFromBlock(blobBlock, hash, callback) {
  // If the blob is in a block that occured within the past hour, search from an
  // hour ago until the latest block in case there has been a re-arragement
  // since we got the block number (very conservative).
  var fromBlock, toBlock;
  if (blobBlock > web3.eth.blockNumber - 200) {
    fromBlock = web3.eth.blockNumber - 200;
    toBlock = 'latest';
  }
  else {
    fromBlock = toBlock = blobBlock;
  }
  web3.eth.filter({fromBlock: fromBlock, toBlock: toBlock, address: blobStoreAddress, topics: [hash]}).get(function(error, result) {
    if (error) { callback(error); return; }
    if (result.length != 0) {
      var length = parseInt(result[0].data.substr(66, 64), 16);
      callback(null, new Buffer(result[0].data.substr(130, length * 2), 'hex'));
    }
    else {
      // There has just been a re-arrangement and the trasaction is now back to
      // pending. Let's try again from the start.
      getBlob(hash, callback);
    }
  });
}

var getBlob = function(hash, callback) {
  getBlobBlockNumber(hash, 'latest', function(error, blockNumber) {
    if (error) { callback(error); return; }
    if (blockNumber == 0) {
      // The blob isn't in a block yet. See if it is in a pending transaction.
      // This will only work if the blob was stored directly by a transaction.
      web3.eth.getBlock('pending', true, function(error, result) {
        if (error) { callback(error); return; }
        for (var i in result.transactions) {
          var tx = result.transactions[i];
          if (tx.to != blobStoreAddress) {
            continue;
          }
          // Extract the blob from the transaction.
          var length = parseInt(tx.input.substr(74, 64), 16);
          var blob = new Buffer(tx.input.substr(138, length * 2), 'hex');
          // Does it have the correct hash?
          if (getBlobHash(blob) == hash) {
            callback(null, blob);
            return;
          }
        }
        // We didn't find the blob. Check in the blocks one more time in case it
        // just got mined and we missed it.
        getBlobBlockNumber(hash, 'latest', function(error, blockNumber) {
          if (error) { callback(error); return; }
          if (blockNumber == 0) {
            // We didn't find it. Report the Error.
            callback("Blob not found.");
          }
          else {
            getBlobFromBlock(blockNumber, hash, callback);
          }
        });
      });
    }
    else {
      getBlobFromBlock(blockNumber, hash, callback);
    }
  });
}

module.exports = {
  address: blobStoreAddress,
  getBlobHash: getBlobHash,
  getBlobBlockNumber: getBlobBlockNumber,
  getGas: getGas,
  storeBlob: storeBlob
};
