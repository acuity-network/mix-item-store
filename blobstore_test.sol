pragma solidity ^0.4.4;

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

    function testCreate() {
        bytes20 blobId0 = blobStore.create(0, hex"00");
        assertTrue(blobStore.getExists(blobId0));
        assertEq(blobStore.getOwner(blobId0), this);
        assertEq(blobStore.getRevisionCount(blobId0), 1);
        assertFalse(blobStore.getUpdatable(blobId0));
        assertFalse(blobStore.getEnforceRevisions(blobId0));
        assertFalse(blobStore.getRetractable(blobId0));
        assertFalse(blobStore.getTransferable(blobId0));

        bytes20 blobId1 = blobStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS, hex"00");
        assertTrue(blobStore.getExists(blobId1));
        assertEq(blobStore.getOwner(blobId1), 0);
        assertEq(blobStore.getRevisionCount(blobId1), 1);
        assertTrue(blobStore.getUpdatable(blobId1));
        assertTrue(blobStore.getEnforceRevisions(blobId1));
        assertTrue(blobStore.getRetractable(blobId1));
        assertTrue(blobStore.getTransferable(blobId1));

        assertFalse(blobId0 == blobId1);
    }

    function testThrowCreateWithNonceExistingNonce() {
        blobStore.createWithNonce(0, hex"00");
        blobStore.createWithNonce(0, hex"00");
    }

    function testCreateWithNonce() {
        bytes20 blobId0 = blobStore.createWithNonce(0, hex"00");
        assertTrue(blobStore.getExists(blobId0));
        assertEq(blobStore.getOwner(blobId0), this);
        assertEq(blobStore.getRevisionCount(blobId0), 1);
        assertFalse(blobStore.getUpdatable(blobId0));
        assertFalse(blobStore.getEnforceRevisions(blobId0));
        assertFalse(blobStore.getRetractable(blobId0));
        assertFalse(blobStore.getTransferable(blobId0));

        bytes20 blobId1 = blobStore.createWithNonce(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS, hex"00");
        assertTrue(blobStore.getExists(blobId1));
        assertEq(blobStore.getOwner(blobId1), 0);
        assertEq(blobStore.getRevisionCount(blobId1), 1);
        assertTrue(blobStore.getUpdatable(blobId1));
        assertTrue(blobStore.getEnforceRevisions(blobId1));
        assertTrue(blobStore.getRetractable(blobId1));
        assertTrue(blobStore.getTransferable(blobId1));

        assertFalse(blobId0 == blobId1);
    }

    function testThrowCreateWithNonceRetracted() {
        bytes20 blobId = blobStore.createWithNonce(RETRACTABLE, hex"00");
        blobStore.retract(blobId);
        blobStore.createWithNonce(RETRACTABLE, hex"00");
    }

    function testThrowsCreateNewRevisionNotUpdatable() {
        bytes20 blobId = blobStore.create(0, hex"00");
        blobStore.createNewRevision(blobId, hex"00");
    }

    function testCreateNewRevision() {
        bytes20 blobId = blobStore.create(UPDATABLE, hex"00");
        uint revisionId = blobStore.createNewRevision(blobId, hex"00");
        assertEq(revisionId, 1);
        assertEq(blobStore.getRevisionCount(blobId), 2);
    }

    function testThrowsUpdateLatestRevisionNotUpdatable() {
        bytes20 blobId = blobStore.create(0, hex"00");
        blobStore.updateLatestRevision(blobId, hex"00");
    }

    function testThrowsUpdateLatestRevisionEnforceRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE | ENFORCE_REVISIONS, hex"00");
        blobStore.updateLatestRevision(blobId, hex"00");
    }

    function testUpdateLatestRevision() {
        bytes20 blobId = blobStore.create(UPDATABLE, hex"00");
        blobStore.updateLatestRevision(blobId, hex"00");
        assertEq(blobStore.getRevisionCount(blobId), 1);
    }

    function testThrowsRetractLatestRevisionNotUpdatable() {
        bytes20 blobId = blobStore.create(UPDATABLE, hex"00");
        blobStore.createNewRevision(blobId, hex"00");
        blobStore.setNotUpdatable(blobId);
        blobStore.retractLatestRevision(blobId);
    }

    function testThrowsRetractLatestRevisionEnforceRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE | ENFORCE_REVISIONS, hex"00");
        blobStore.createNewRevision(blobId, hex"00");
        blobStore.retractLatestRevision(blobId);
    }

    function testThrowsRetractLatestRevisionDoesntHaveAdditionalRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE, hex"00");
        blobStore.retractLatestRevision(blobId);
    }

    function testRetractLatestRevision() {
        bytes20 blobId = blobStore.create(UPDATABLE, hex"00");
        blobStore.createNewRevision(blobId, hex"00");
        blobStore.createNewRevision(blobId, hex"00");
        assertEq(blobStore.getRevisionCount(blobId), 3);
        blobStore.retractLatestRevision(blobId);
        assertEq(blobStore.getRevisionCount(blobId), 2);
    }

    function testThrowsRestartNotUpdatable() {
        bytes20 blobId = blobStore.create(0, hex"00");
        blobStore.restart(blobId, hex"00");
    }

    function testThrowsRestartEnforceRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE | ENFORCE_REVISIONS, hex"00");
        blobStore.restart(blobId, hex"00");
    }

    function testRestart() {
        bytes20 blobId = blobStore.create(UPDATABLE, hex"00");
        blobStore.createNewRevision(blobId, hex"00");
        blobStore.createNewRevision(blobId, hex"00");
        assertEq(blobStore.getRevisionCount(blobId), 3);
        blobStore.restart(blobId, hex"00");
        assertEq(blobStore.getRevisionCount(blobId), 1);
    }

    function testThrowsRetractNotRetractable() {
        bytes20 blobId = blobStore.create(0, hex"00");
        blobStore.retract(blobId);
    }

    function testRetract() {
        bytes20 blobId = blobStore.create(RETRACTABLE, hex"00");
        blobStore.retract(blobId);
        assertEq(blobStore.getExists(blobId), false);
    }

    function testThrowsDisownNotTransferable() {
        bytes20 blobId = blobStore.create(0, hex"00");
        blobStore.disown(blobId);
    }

    function testDisown() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, hex"00");
        assertEq(blobStore.getOwner(blobId), this);
        blobStore.disown(blobId);
        assertEq(blobStore.getOwner(blobId), 0);
    }

    function testSetNotUpdatable() {
        bytes20 blobId = blobStore.create(UPDATABLE, hex"00");
        assertTrue(blobStore.getUpdatable(blobId));
        blobStore.setNotUpdatable(blobId);
        assertEq(blobStore.getUpdatable(blobId), false);
    }

    function testSetEnforceRevisions() {
        bytes20 blobId = blobStore.create(0, hex"00");
        assertEq(blobStore.getEnforceRevisions(blobId), false);
        blobStore.setEnforceRevisions(blobId);
        assertTrue(blobStore.getEnforceRevisions(blobId));
    }

    function testSetNotRetractable() {
        bytes20 blobId = blobStore.create(RETRACTABLE, hex"00");
        assertTrue(blobStore.getRetractable(blobId));
        blobStore.setNotRetractable(blobId);
        assertEq(blobStore.getRetractable(blobId), false);
    }

    function testSetNotTransferable() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, hex"00");
        assertTrue(blobStore.getTransferable(blobId));
        blobStore.setNotTransferable(blobId);
        assertEq(blobStore.getTransferable(blobId), false);
    }

}
