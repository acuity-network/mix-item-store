pragma solidity ^0.4.2;

import "dapple/test.sol";
import "blobstore.sol";
import "blobstore_flags.sol";


/**
 * @title BlobStoreTest
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStoreTest is Test, BlobStoreFlags {

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
        blobStore.create(0, hex"00");
        blobStore.create(0, hex"00");
    }

    function testCreate() {
        bytes20 blobId0 = blobStore.create(0, hex"00");
        assertTrue(blobStore.getExists(blobId0));
        assertEq(blobStore.getOwner(blobId0), this);
        assertEq(blobStore.getRevisionCount(blobId0), 1);
        assertFalse(blobStore.getUpdatable(blobId0));
        assertFalse(blobStore.getEnforceRevisions(blobId0));
        assertFalse(blobStore.getRetractable(blobId0));
        assertFalse(blobStore.getTransferable(blobId0));

        bytes20 blobId1 = blobStore.create(FLAG_UPDATABLE | FLAG_ENFORCE_REVISIONS | FLAG_RETRACTABLE | FLAG_TRANSFERABLE | FLAG_ANONYMOUS, hex"00");
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
        bytes20 blobId = blobStore.create(0, hex"00");
        blobStore.createNewRevision(blobId, hex"00");
    }

    function testCreateNewRevision() {
        bytes20 blobId = blobStore.create(FLAG_UPDATABLE, hex"00");
        uint revisionId = blobStore.createNewRevision(blobId, hex"00");
        assertEq(revisionId, 1);
        assertEq(blobStore.getRevisionCount(blobId), 2);
    }

    function testThrowsUpdateLatestRevisionNotUpdatable() {
        bytes20 blobId = blobStore.create(0, hex"00");
        blobStore.updateLatestRevision(blobId, hex"00");
    }

    function testThrowsUpdateLatestRevisionEnforceRevisions() {
        bytes20 blobId = blobStore.create(FLAG_UPDATABLE | FLAG_ENFORCE_REVISIONS, hex"00");
        blobStore.updateLatestRevision(blobId, hex"00");
    }

    function testUpdateLatestRevision() {
        bytes20 blobId = blobStore.create(FLAG_UPDATABLE, hex"00");
        blobStore.updateLatestRevision(blobId, hex"00");
        assertEq(blobStore.getRevisionCount(blobId), 1);
    }

}
