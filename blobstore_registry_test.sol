pragma solidity ^0.4.11;

import "ds-test/test.sol";

import "./blobstore_ipfs_sha256.sol";


/**
 * @title BlobStoreTest
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStoreRegistryTest is DSTest {

    BlobStoreRegistry blobStoreRegistry;
    BlobStoreIpfsSha256 blobStore;
 
    function setUp() {
        blobStoreRegistry = new BlobStoreRegistry();
        blobStore = new BlobStoreIpfsSha256(blobStoreRegistry);
    }

    function testControlRegisterContractAgain() {
        blobStoreRegistry.register(~blobStore.getContractId());
    }

    function testFailRegisterContractAgain() {
        blobStoreRegistry.register(blobStore.getContractId());
    }

    function testControlBlobStoreNotRegistered() {
        blobStoreRegistry.getBlobStore(blobStore.getContractId());
    }

    function testFailBlobStoreNotRegistered() {
        blobStoreRegistry.getBlobStore(0);
    }

    function testGetBlobStore() {
        assertEq(blobStoreRegistry.getBlobStore(blobStore.getContractId()), blobStore);
    }

    function testGetBlobStoreFromFullBlobId() {
        assertEq(blobStoreRegistry.getBlobStoreFromFullBlobId(bytes32(blobStore.getContractId())), blobStore);
    }

}
