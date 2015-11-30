var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));
var blobstoreAbi = require('./blobstore.abi.json');
var blobstoreContract = web3.eth.contract(blobstoreAbi);
var blobstoreAddress = '0x3c531591cb807e01404574076f429d205f5ee981';
var blobstore = blobstoreContract.at(blobstoreAddress);

// https://github.com/bluedroplet/blobstore-ethereum/blob/c65287e0ff249fec047834e7895cb46c0e090228/blobstore.sol
// Solidity version: 0.1.7-f86451cd/.-Emscripten/clang/int linked to libethereum-1.1.0-35b67881/.-Emscripten/clang/int

var getBlobHash = function(blob) {
  return '0x' + web3.sha3(blob.toString('ascii'));
}

var getBlobBlock = function(hash) {
  // Determine the block that includes the transaction for this blob.
  return blobstore.getBlobBlock(hash, {}, 'latest').toFixed();
}

var storeBlob = function(blob) {
  // Determine hash of blob.
  var hash = getBlobHash(blob);
  // Check if this blob is in a block yet.
  if (getBlobBlock(hash) == 0) {
    // Calculate maximum transaction gas.
    var gas = 44800 + 78 * blob.length;
    // Broadcast the transaction. If this blob is already in a pending
    // transaction, or has just been mined, this will be handled by the
    // contract.
    blobstore.storeBlob('0x' + blob.toString('hex'), {gas: gas});
  }
  return hash;
}

var getBlob = function(hash, callback) {
  var blobBlock = getBlobBlock(hash);
  if (blobBlock == 0) {
    // The blob isn't in a block yet. See if it is in a pending transaction.
    var txids = web3.eth.getBlock('pending').transactions;
    for (var i in txids) {
      var tx = web3.eth.getTransaction(txids[i]);
      if (tx.to != blobstoreAddress) {
        continue;
      }
      // Extract the blob from the transaction.
      var length = parseInt(tx.input.substr(74, 64), 16);
      var blob = new Buffer(tx.input.substr(138, length * 2), 'hex');
      // Does it have the correct hash?
      if (getBlobHash(blob) == hash) {
        callback(null, blob);
        break;
      }
    }
  }
  else {
    // Start searching for the log at least an hour in the past in case of block
    // re-arrangement.
    var fromBlock = Math.min(blobBlock, web3.eth.blockNumber - 200);
    var filter = web3.eth.filter({fromBlock: fromBlock, toBlock: 'latest', address: blobstoreAddress, topics: [hash]});
    filter.get(function(error, result) {
      if (result != 0) {
        var length = parseInt(result[0].data.substr(66, 64), 16);
        callback(null, new Buffer(result[0].data.substr(130, length * 2), 'hex'));
      }
      else {
        callback('error');
      }
    });
  }
}

module.exports = {
  storeBlob: storeBlob,
  getBlobBlock: getBlobBlock,
  getBlob: getBlob
};
