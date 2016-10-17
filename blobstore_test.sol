pragma solidity ^0.4.2;

import "dapple/test.sol";
import "blobstore.sol";


/**
 * @title BlobStoreTest
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStoreTest is Test {

    BlobStoreRegistry blobStoreRegistry;
    BlobStore blobStore;

    function setUp() {
        blobStoreRegistry = new BlobStoreRegistry();
        blobStore = new BlobStore(blobStoreRegistry);
    }

    function testThrowRegisterContractAgain() {
        blobStoreRegistry.register(blobStore.getContractId());
    }

    function testThrowBlobStoreNotRegistered() {
        blobStoreRegistry.getBlobStore(0);
    }

    function testBlobStoreRegistered() {
        assertEq(blobStoreRegistry.getBlobStore(blobStore.getContractId()), blobStore);
    }

    function testThrowCreateExistingNonce() {
        blobStore.create(hex"00", 0, 0);
        blobStore.create(hex"00", 0, 0);
    }

    function testCreate() {
        bytes32 blobId0 = blobStore.create(hex"00", 0, 0);
        assertEq12(blobStore.getContractId(), bytes12(blobId0));
        assertTrue(blobStore.getExists(blobId0));
        assertEq(blobStore.getOwner(blobId0), this);
        assertEq(blobStore.getRevisionCount(blobId0), 1);
        assertFalse(blobStore.getUpdatable(blobId0));
        assertFalse(blobStore.getEnforceRevisions(blobId0));
        assertFalse(blobStore.getRetractable(blobId0));
        assertFalse(blobStore.getTransferable(blobId0));

        bytes32 blobId1 = blobStore.create(hex"00", 1, 0x1f);
        assertEq12(blobStore.getContractId(), bytes12(blobId1));
        assertTrue(blobStore.getExists(blobId1));
        assertEq(blobStore.getOwner(blobId1), 0);
        assertEq(blobStore.getRevisionCount(blobId1), 1);
        assertTrue(blobStore.getUpdatable(blobId1));
        assertTrue(blobStore.getEnforceRevisions(blobId1));
        assertTrue(blobStore.getRetractable(blobId1));
        assertTrue(blobStore.getTransferable(blobId1));

        assertFalse(blobId0 == blobId1);
    }

    function testThrowsCreateNewRevisionNotUpdatable() {
        bytes32 blobId = blobStore.create(hex"00", 0, 0);
        blobStore.createNewRevision(blobId, hex"00");
    }

    function testCreateNewRevision() {
        bytes32 blobId = blobStore.create(hex"00", 0, 0x1);
        uint revisionId = blobStore.createNewRevision(blobId, hex"00");
        assertEq(revisionId, 1);
        assertEq(blobStore.getRevisionCount(blobId), 2);
    }

}
