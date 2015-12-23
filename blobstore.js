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
var blobStoreAddress = '0x3ed94117c369f92f2aa8500da996f1ae4f6460fd';
var blobStore = blobStoreContract.at(blobStoreAddress);

// solc version: 0.2.0-0/Release-Linux/g++/int linked to libethereum-1.1.0-0/Release-Linux/g++/int

getBlobHash = function(blob) {
  return '0x' + web3.sha3(blob.toString('hex'), {encoding: 'hex'});
}

function getBlobTx(blob) {
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

var getBlob = function(hash, callback) {
  web3.eth.filter({fromBlock: 736860, toBlock: 'latest', address: blobStoreAddress, topics: [hash]}).get(function(error, result) {
    if (error) { callback(error); return; }
    if (result.length != 0) {
      var length = parseInt(result[0].data.substr(66, 64), 16);
      callback(null, new Buffer(result[0].data.substr(130, length * 2), 'hex'));
    }
    else {
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
        callback("Blob not found.");
      });
    }
  });
}

module.exports = {
  getBlobHash: getBlobHash,
  getGas: getGas,
  storeBlob: storeBlob,
  getBlob: getBlob
};
