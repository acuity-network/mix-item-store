.. _example:

#######
Example
#######

Adding BlobStore to your Node.js project::

    npm install blobstore-ethereum --save

Accessing the library from JavaScript::

    var blobStore = require('blobstore-ethereum');
    
Retreiving a blob::

    var blobId = "0x0598888a30f36c84fe78b45247184a25309520ba";
    var revisionId = 0;

    blobStore.getContents(blobId, revisionId, function(error, result) {
        if (!error) {
            console.log(result.toString());
        }
        else {
            console.error(error);
        }
    });

Creating a blob::

    var contents = Buffer.from("This is a new test blob.");

    var blobId = blobStore.create(contents, {updatable: true, enforceRevisions: true, retractable: true, transferable: false}, function(error, result) {
        if (!error) {
            console.log(result.toString());
        }
        else {
            console.error(error);
        }
    });
    console.log(blobId);

Creating a new revision::

    var blobId = "0x402c1394b6808fa24ec40e4a8029b98e1923f057";
    var contents = Buffer.from("This is the new contents of my blob.");

    blobStore.createNewRevision(blobId, contents, function(error, result) {
        if (!error) {
            console.log(result);
        }
        else {
            console.error(error);
        }
    });

Retracting a blob::

    var blobId = "0x402c1394b6808fa24ec40e4a8029b98e1923f057";

    blobStore.retract(blobId, function(error, result) {
        if (!error) {
            console.log(result);
        }
        else {
            console.error(error);
        }
    });
