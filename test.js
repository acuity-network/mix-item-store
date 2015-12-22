var fs = require('fs');

var blobStore = require('./blobstore');

/*
var hash = blobStore.log.storeBlob(new Buffer("hello"), function(error, result) {

  if (error) { console.log(error); return; }
  blobStore.log.getBlob(hash, function(error, result) {
    if (error) {
      console.log(error);
    }
    else {
      console.log(result.toString());
    }
  });
});
*/


//var hash = getBlobHash(new Buffer("new test2 1236"));
var hash = "0x2d71370ced7c2bdeba90a9d8a2552c5fe14df8277dcbf2f4e2718ae38066937f";
blobStore.log.getBlob(hash, function(error, result) {
  if (error) {
    console.log(error);
  }
  else {
    console.log(result.toString());
  }
});


/*
fs.readFile('test.txt', function (err, data) {
  if (err) throw err;

  var hash = blobStore.state.storeBlob(data, function(error, result) {
    console.log(hash);

    if (error) { console.log(error); return; }
    blobStore.state.getBlob(hash, function(error, result) {
      if (error) {
        console.log(error);
      }
      else {
        console.log(result.toString());
      }
    });
  });
});
*/

