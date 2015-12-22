
var blobStateAbi = require('./blobstore-state.abi.json');
var blobStateContract = web3.eth.contract(blobStateAbi);
var blobStateAddress = '0x67f4bd6ca9cff2d7358ffd2d9bf4553b522b9e88';
var blobState = blobStateContract.at(blobStateAddress);

// solc version: 0.2.0-0/Release-Linux/g++/int linked to libethereum-1.1.0-0/Release-Linux/g++/int

function tx(blob) {
  return {
    to: blobStateAddress,
    data: blobState.storeBlob.getData('0x' + blob.toString('hex'))
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
      // Check that the blob is pending.
      blobExists(hash, function(error, exists) {
        if (!exists) {
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

var blobExists = function(hash, callback) {
  blobState.blobExists(hash, {}, 'pending', callback);
}

var getBlob = function(hash, callback) {
  blobState.getBlob(hash, {}, 'pending', function(error, blob) {
    if (!blob) {
      callback("Blob not found.");
    }
    else {
      callback(null, new Buffer(blob.substr(2), 'hex'));
    }
  });
}

module.exports = {
  getGas: getGas,
  storeBlob: storeBlob,
  blobExists: blobExists,
  getBlob: getBlob
};
