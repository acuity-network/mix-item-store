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
var blobStoreAddress = '0x6feab968708c8c3de09229ca80d251481d03c0ef';
var blobStore = blobStoreContract.at(blobStoreAddress);

// solc version: 0.2.0-0/Release-Linux/g++/int linked to libethereum-1.1.1-0/Release-Linux/g++/int

var getBlobHash = function(blob) {
  // Calculate the hash and zero-out the last six bytes.
  return '0x' + web3.sha3(blob.toString('hex'), {encoding: 'hex'}).substr(0, 52) + '000000000000';
}

function getBlobTx(blob) {
  return {
    to: blobStoreAddress,
    data: blobStore.storeBlob.getData('0x' + blob.toString('hex'))
  };
}

var getGas = function(blob, callback) {
  // Calculate maximum transaction gas.
  web3.eth.estimateGas(getBlobTx(blob), 'pending', callback);
}

var storeBlob = function(blob, callback) {
  // Determine hash of blob.
  var hash = getBlobHash(blob);
  // Create transaction object.
  var tx = getBlobTx(blob);
  // Calculate maximum transaction gas.
  web3.eth.estimateGas(tx, 'pending', function(error, gas) {
    if (error) { callback(error); return; }
    tx.gas = gas;
    // Broadcast the transaction.
    web3.eth.sendTransaction(tx, function(error, result) {
      if (error) {
        callback("Blob failed to broadcast.");
      }
      else {
        callback(null, hash);
      }
    });
  });
  return hash;
}

var getBlob = function(id, callback) {
  // Break up the blob id into block number and hash.
  var blockNumber = parseInt(id.substr(54, 12), 16);
  var hash = '0x' + id.substr(2, 52) + '000000000000';
  if (blockNumber == 0 || blockNumber > web3.eth.blockNumber) {
    // We don't know which block the blob is in, or it isn't in a block yet. See
    // if it is in a pending transaction. This will only work if the blob was
    // stored directly by a transaction.
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
    });
  }
  var fromBlock, toBlock;
  // If we don't know the block number, search the whole log index.
  if (blockNumber == 0) {
    fromBlock = 782352;
    toBlock = 'latest';
  }
  // If the blob is in a block that occured within the past hour, search from an
  // hour ago until the latest block in case there has been a re-arragement
  // since we got the block number (very conservative).
  else if (blockNumber > web3.eth.blockNumber - 200) {
    fromBlock = web3.eth.blockNumber - 200;
    toBlock = 'latest';
  }
  else {
    // We know exactly which block the blob is in.
    fromBlock = toBlock = blockNumber;
  }
  // Perform the search.
  web3.eth.filter({fromBlock: fromBlock, toBlock: toBlock, address: blobStoreAddress, topics: [hash]}).get(function(error, result) {
    if (error) { callback(error); return; }
    if (result.length != 0) {
      var length = parseInt(result[0].data.substr(66, 64), 16);
      callback(null, new Buffer(result[0].data.substr(130, length * 2), 'hex'));
    }
  });
}

module.exports = {
  getBlobHash: getBlobHash,
  getGas: getGas,
  storeBlob: storeBlob,
  getBlob: getBlob
};
