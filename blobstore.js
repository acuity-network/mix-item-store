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
var blobStoreAddress = '0x3f40845b2c436bd2d367fc4a50638981dec61b0b';
var blobStore = blobStoreContract.at(blobStoreAddress);

// solc version: 0.4.2+commit.af6afb04.Linux.g++

var createAssisted = function(contents, flags, callback) {
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
  // Remove the padding from blobId.
  blobId = blobId.substr(0, 42);
  // Calculate maximum transaction gas.
  web3.eth.estimateGas(tx, 'pending', function(error, gas) {
    if (error) { callback(error); return; }
    tx.gas = gas;
    tx.gasPrice = 20000000000;
    // Broadcast the transaction.
    web3.eth.sendTransaction(tx, function(error, result) {
      console.log(result);
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
    web3.eth.filter({fromBlock: fromBlock, toBlock: toBlock, address: blobStoreAddress, topics: ["0xfd5eeef8919c5473de9558a49bf3a5b19bcf59ec0d36e420586d7c3bbaf17d01", blobId + "000000000000000000000000", "0x" + revisionIdBuf.toString('hex')]}).get(function(error, result) {
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



var contents = new Buffer("Hello Parity this is an updatable blob2.");



/*
var blobId = createAssisted(contents, {updatable: true}, function(error, blobId) {
  if (error) {
    console.log(error);
    return;
  }
  
  console.log(blobId);
  

  getContents(blobId, 0, function(error, result) {
    if (error) {
      console.log(error.toString());
    }
    else {
      console.log(result.toString());
    }
  });
});

*/


var blobId = "0x3ac0a6b049e311a71ed8448c5a7627affa4b339d";


getContents(blobId, 1, function(error, result) {
  if (error) {
    console.log(error.toString());
  }
  else {
    console.log(result.toString());
  }
});






blobStore.getRevisionCount(blobId, 'pending', function(error, result){
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
