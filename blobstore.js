"use strict";

var Web3 = require('web3');
var web3;

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
var blobStoreAddress = '0xe70e90fdD2B9d3e27BDd56ef249EE1D408F40BE2';
var blobStore = blobStoreContract.at(blobStoreAddress);

module.exports.contract = blobStore;

function sendTransaction(tx, callback) {
  web3.eth.estimateGas(tx, 'pending', function(error, gas) {
    if (error) { callback(error); return; }
    tx.gas = gas;
    // Broadcast the transaction.
    web3.eth.sendTransaction(tx, function(error, result) {
      if (error) { callback(error); return; }
      callback(null, result);
    });
  });
}

module.exports.create = function(contents, flags, callback) {
  // Combine the flags into 4 bytes.
  var flagsBinary = 0;
  if (flags.updatable) {
    flagsBinary |= 0x01;
  }
  if (flags.enforceRevisions) {
    flagsBinary |= 0x02;
  }
  if (flags.retractable) {
    flagsBinary |= 0x04;
  }
  if (flags.transferable) {
    flagsBinary |= 0x08;
  }
  if (flags.anonymous) {
    flagsBinary |= 0x10;
  }
  var flagsBuf = new Buffer(4);
  flagsBuf.writeUInt8(flagsBinary, 3);

  // Keep hashing until we find a unique blobId.
  var nonce = web3.sha3(contents.toString('hex'), {encoding: 'hex'});
  var flagsNonce = "0x" + flagsBuf.toString('hex') + nonce.substr(2, 56);
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.createWithNonce.getData(flagsNonce, '0x' + contents.toString('hex'))
  }
  var blobId = web3.eth.call(tx, 'pending');
  while (blobId == "0x") {
    nonce = web3.sha3(nonce);
    flagsNonce = "0x" + flagsBuf.toString('hex') + nonce.substr(2, 56);
    // Create transaction object.
    tx = {
      to: blobStoreAddress,
      data: blobStore.createWithNonce.getData(flagsNonce, '0x' + contents.toString('hex'))
    }
    blobId = web3.eth.call(tx, 'pending');
  }
  sendTransaction(tx, callback);
  // Remove the padding from blobId.
  return blobId.substr(0, 42);
}

module.exports.createNewRevision = function(blobId, blob, callback) {
  // Create the transaction.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.createNewRevision.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Send it.
  sendTransaction(tx, callback);
}

module.exports.updateLatestRevision = function(blobId, blob, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.updateLatestRevision.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.retractLatestRevision = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.retractLatestRevision.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.restart = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.restart.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.retract = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.retract.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.transferEnable = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.transferEnable.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.transferDisable = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.transferDisable.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.transfer = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.transfer.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.disown = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.disown.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.setNotUpdatable = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.setNotUpdatable.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.setEnforceRevisions = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.setEnforceRevisions.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.setNotRetractable = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.setNotRetractable.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.setNotTransferable = function(blobId, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.setNotTransferable.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Create the transaction.
  sendTransaction(tx, callback);
}

module.exports.getContractId = module.exports.contract.getContractId;
module.exports.getExists = module.exports.contract.getExists;
module.exports.getInfo = module.exports.contract.getInfo;
module.exports.getFlags = module.exports.contract.getFlags;
module.exports.getUpdatable = module.exports.contract.getUpdatable;
module.exports.getEnforceRevisions = module.exports.contract.getEnforceRevisions;
module.exports.getRetractable = module.exports.contract.getRetractable;
module.exports.getTransferable = module.exports.contract.getTransferable;
module.exports.getOwner = module.exports.contract.getOwner;
module.exports.getRevisionCount = module.exports.contract.getRevisionCount;
module.exports.getRevisionBlockNumber = module.exports.contract.getRevisionBlockNumber;
module.exports.getAllRevisionBlockNumbers = module.exports.contract.getAllRevisionBlockNumbers;

module.exports.getContents = function(blobId, revisionId, callback) {
  // Get the block number.
  blobStore.getRevisionBlockNumber(blobId, revisionId, 'pending', function(error, blockNumber) {
    if (error) { callback(error); return; }
    if (blockNumber == 0) {
      callback("Error: blob revision not found.");
      return;
    }
    var fromBlock, toBlock;
    if (web3.eth.blockNumber - blockNumber < 20) {
      fromBlock = web3.eth.blockNumber - 20;
      toBlock = 'pending';
    }
    else {
      fromBlock = toBlock = blockNumber;
    }
    var revisionIdBuf = new Buffer(32);
    revisionIdBuf.fill(0);
    revisionIdBuf.writeUInt32BE(revisionId, 28);
    // Search the logs.
    web3.eth.filter({fromBlock: fromBlock, toBlock: toBlock, address: blobStoreAddress, topics: ["0xfd5eeef8919c5473de9558a49bf3a5b19bcf59ec0d36e420586d7c3bbaf17d01", blobId + "000000000000000000000000", "0x" + revisionIdBuf.toString('hex')]}).get(function(error, result) {
      if (error) { callback(error); return; }
      for (var i = 0; i < result.length; i++) {
        var length = parseInt(result[i].data.substr(66, 64), 16);
        callback(null, new Buffer(result[i].data.substr(130, length * 2), 'hex'));
      }
    });
  });
}
