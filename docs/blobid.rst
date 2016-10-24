######
blobId
######

Each blob has a 20 byte blobId that is unique to the contract that generated it. The blobId can be further classified to indicate which contract and blockchain the blob is on.

Off-chain
=========
For each blockchain there is considered to be an ordered list of BlobStore contracts. For example, the first contract would be #0. The next one would be #1. This list is maintained by convention. 20 byte blobIds can be prefixed with a single byte to indicate which contract the blob is in. BlobStore itself has no means of specifiying which blockchain a blob is on. This is either to be assumed or to be specified by some other method, e.g. a URI.

Client software should have a hard coded whitelist of BlobStore contracts that its knows how to read from.

On-chain
========
New BlobStore contracts register with the BlobStore registration contract. When a blobId is stored in a smart contract, it must be stored with the 12 byte BlobStore contractId. This way the smart contract can look up the address of any BlobStore contract in the registration contract. This is essential to future-proof smart contracts that need to communicate with BlobStore contracts.
