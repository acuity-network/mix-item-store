.. _deployments:

###########
Deployments
###########

BlobStore can be deployed on any Ethereum blockchain. Each blockchain needs a single BlobStoreRegistry to be deployed. This is so that when later versions of BlobStore are deployed they can register with it.

On each blockchain, each BlobStore contract has a serial number that is used outside the blockchain to identify which contract a blob is stored on. This page is the authority on which contracts have which serial numbers on which blockchains.

Each BlobStore contract also has a contractId that is used within contracts.

See :ref:`blobid` for more information.

All current deployments are of BlobStore `1.0 <https://github.com/link-blockchain/blobstore/tree/1.0>`_ compiled with Solidity 4.4 with optimization enabled.

Ethereum
========

BlobStoreRegistry contract address: ``0x71E080a2e36753f880c060Ee38139A799C6366a5`` `✔ <https://etherscan.io/address/0x71e080a2e36753f880c060ee38139a799c6366a5#code>`_

Ethereum BlobStore #0
`````````````````````

contract address: ``0xe70e90fdD2B9d3e27BDd56ef249EE1D408F40BE2`` `✔ <https://etherscan.io/address/0xe70e90fdd2b9d3e27bdd56ef249ee1d408f40be2#code>`_

BlobStore contractId: ``0x74e36b12cf45d88ddf28403e``

Ethereum Classic
================

BlobStoreRegistry contract address: ``0xb2a3a31c5425cab2a592b22ba6eab4dd24885a18``

Ethereum Classic BlobStore #0
`````````````````````````````

contract address: ``0x142c02617643b4fd6d50179580169bdef391353a``

BlobStore contractId: ``0xc23a81a289591896339e1411``

Expanse
=======

BlobStoreRegistry contract address: ``0x4d7bec7eafc33915f7ac4c3375762c58643eee5b``

Expanse BlobStore #0
````````````````````

contract address: ``0xd09bc8e21b6ef637f40522918f88064f783d3002``

BlobStore contractId: ``0xe65c702e1e4d84fcc7e1cbb8``
