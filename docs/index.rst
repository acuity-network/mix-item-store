.. BlobStore documentation master file, created by
   sphinx-quickstart on Sat Oct  1 13:28:21 2016.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

BlobStore
=========

BlobStore is a smart contract for Ethereum blockchains that permanently stores blobs of data. It will be the principle contract of the Link Blockchain.

Useful links
------------

* `Source code <https://github.com/link-blockchain/blobstore>`_

* `Issue tracker <https://github.com/link-blockchain/blobstore/issues>`_

* `Solidity API <http://solidity-apis.link-blockchain.org/docs/BlobStore/>`_

* `Node.js NPM <https://www.npmjs.com/package/blobstore-ethereum>`_

* `Link Blockchain blog <https://blog.link-blockchain.org/>`_

* `Gitter channel <https://gitter.im/link-blockchain/blobstore>`_

It has the following properties:

* Immutable
    While a blob can be "retracted", it can never really be deleted because the transaction that created it will be archived for eternity on full nodes.
    
* Revisioned
   BlobStore has a rudimentary revisioning system built-in where a blob can have multiple revisions, e.g. for editing posts. More sophisticated revisioning systems can be built on top of BlobStore where each blob is a revision.

* Ownership
   Each blob can have an owner. Only the owner can modify a blob, change blob settings, or transfer ownership to another address.
   
* Configurable
   Each blob has the following flags that can be set:

   * Updatable
      The contents of the blob can be changed. Once disabled it cannot be re-enabled.
   * Enfore Revisions
      When updating the blob a new revision must be created. It is not possible to retract revisions. Once enabled, this flag cannot be disabled.
   * Retractable
      The blob in its entirety can be retracted. This is unaffected by Enforce Revisions. The blobId of a retracted blob can never be used again. Once disabled it cannot be re-enabled.
   * Transferable
      The blob can be transfered to another user (if they accept it), or disowned completely. Once disabled it cannot be re-enabled. At creation time blobs can also be flaged as anonymous to not have an owner associated. An alternative to transferable blobs is to use a proxy account with transferable ownership as the blob owner.

* Light client support
   Blobs are stored in Ethereum log storage so can be retreived by light clients.
   
* Scalable
   Currently every Ethereum full node processes every transaction, limiting the scalability of BlobStore. However, in future Ethereum blockchains will become "sharded", effectively providing unlimited scalability.
   
* Low latency
   Searching Ethereum logs is not normally instantaneous because they are not fully indexed like state entries. However, BlobStore stores in state the block number that each log is stored in. This allows for instantaneous retrival.
   
   Geth does not currently support reading logs from unconfirmed transactions, so may not be suitable at the moment for many use cases. However, Parity does have this feature. This is why Parity is the recommended client when using BlobStore.

* Expensive
   While cheaper than contract state, BlobStore is still considerably more expensive than other decentralized storage systems. This is because it is fully immutable. BlobStore is not cost effective for very large blobs of data or for a large number of blobs that are of low value. As Ethereum blockchains become more scalable BlobStore will become better value.

* Anti-spam
   Because each blob that is stored in the system must paid for spam is not profitable.

* Upgradability
    BlobStore is an upgradable system. Due to a security vulnerability, new features, or performance improvements a new BlobStore contract may be deployed.

* Unit Tests
   BlobStore has tests written in Solidity using the Dapple framework.

* JavaScript library
   BlobStore has a simple library to ease the process of reading and writing blobs.

* Multiple blockchains
   BlobStore is currently deployed on Ethereum, Ethereum Classic, Expanse and Link.

.. toctree::
   :maxdepth: 2

   blobid.rst
   deployments.rst
   example.rst
   faq.rst


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

