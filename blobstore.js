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
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8645"));
  web3.eth.defaultAccount = '0x9a2b39c4512177403650227863b8768e378bc7b1';
}

var blobStoreAbi = require('./blobstore.abi.json');
var blobStoreContract = web3.eth.contract(blobStoreAbi);
var blobStoreAddress = '0xd0ba092adb5c791cbdf204203c65dfbe809d2eb1';
var blobStore = blobStoreContract.at(blobStoreAddress);

// solc version: 0.4.2+commit.af6afb04.Linux.g++

var createAssisted = function(contents, flags, callback) {
  // Combine the flags into a byte.
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
  var flagsBuf = new Buffer(1);
  flagsBuf.writeUInt8(flagsBinary, 0);
  // Keep hashing until we find a unique blobId.
  var nonce = web3.sha3(contents.toString('hex'), {encoding: 'hex'});
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.create.getData('0x' + contents.toString('hex'), nonce, "0x" + flagsBuf.toString('hex'))
  }
  var blobId = web3.eth.call(tx, 'pending');
  while (blobId == "0x") {
    nonce = web3.sha3(nonce);
    // Create transaction object.
    tx = {
      to: blobStoreAddress,
      data: blobStore.create.getData("0x" + contents.toString('hex'), nonce, "0x" + flagsBuf.toString('hex'))
    }
    blobId = web3.eth.call(tx, 'pending');
  }
  // Calculate maximum transaction gas.
  web3.eth.estimateGas(tx, 'pending', function(error, gas) {
    if (error) { callback(error); return; }
    tx.gas = gas;
    // Broadcast the transaction.
    web3.eth.sendTransaction(tx, function(error, result) {
      if (error) { callback(error); return; }
      callback(null, blobId);
    });
  });
  return blobId;
}

var createNewRevisionAssisted = function(blobId, blob, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.createNewRevision.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Calculate maximum transaction gas.
  web3.eth.estimateGas(tx, 'pending', function(error, gas) {
    if (error) { callback(error); return; }
    tx.gas = gas;
    // Broadcast the transaction.
    web3.eth.sendTransaction(tx, function(error, result) {
      if (error) { callback(error); return; }
      callback(null, blobId);
    });
  });
}

var updateLatestRevisionAssisted = function(blobId, blob, callback) {
  // Create transaction object.
  var tx = {
    to: blobStoreAddress,
    data: blobStore.updateLatestRevision.getData(blobId, '0x' + contents.toString('hex'))
  }
  // Calculate maximum transaction gas.
  web3.eth.estimateGas(tx, 'pending', function(error, gas) {
    if (error) { callback(error); return; }
    tx.gas = gas;
    // Broadcast the transaction.
    web3.eth.sendTransaction(tx, function(error, result) {
      if (error) { callback(error); return; }
      callback(null, blobId);
    });
  });
}

var getContents = function(blobId, revisionId, callback) {
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
    web3.eth.filter({fromBlock: fromBlock, toBlock: toBlock, address: blobStoreAddress, topics: ["0x1b3165ae125b4fcd8ba9516c3c62690139492d91cc45b85e07613b95d47ce863", blobId, "0x" + revisionIdBuf.toString('hex')]}).get(function(error, result) {
      if (error) { callback(error); return; }
      for (var i = 0; i < result.length; i++) {
        var length = parseInt(result[i].data.substr(66, 64), 16);
        callback(null, new Buffer(result[i].data.substr(130, length * 2), 'hex'));
      }
    });
  });
}

module.exports = blobStore;
module.exports.createAssisted = createAssisted;
module.exports.createNewRevisionAssisted = createNewRevisionAssisted;
module.exports.updateLatestRevisionAssisted = updateLatestRevisionAssisted;
module.exports.getContents = getContents;


/*
var contents = new Buffer("Hello Parity this is an updatable blob.");
var blobId = createAssisted(contents, {updatable: true}, function(error, result) {
  if (error) {
    console.log(error);
    return;
  }
  getContents(result, 0, function(error, result) {
    if (error) {
      console.log(error.toString());
    }
    else {
      console.log(result.toString());
    }
  });
});


console.log(blobId);
*/


var blobId = "0x2b63df6cf0f80cbad2af59c9ff02bf6c52957a18c6d26ff0e2455a98cf7f4c3c";


getContents(blobId, 1, function(error, result) {
  if (error) {
    console.log(error.toString());
  }
  else {
    console.log(result.toString());
  }
});




blobStore.getInfo(blobId, 'pending', function(error, result){
  if (error) {
    console.log(error.toString());
  }
  else {
    console.log(result.toString());
  }
});

/*
var contents = new Buffer("This blob has a new revision.");
blobStore.createNewRevisionAssisted(blobId, contents, function(error, result) {
  if (error) {
    console.log(error.toString());
  }
  else {
    console.log(result.toString());
  }
});

*/


