pragma solidity ^0.4.11;

import "ds-test/test.sol";

import "./blobstore_ipfs_sha256.sol";
import "./blobstore_ipfs_sha256_proxy.sol";


/**
 * @title BlobStoreTest
 * @author Jonathan Brown <jbrown@link-blockchain.org>
 */
contract BlobStoreTest is DSTest {

    byte constant UPDATABLE = 0x01;           // True if the blob is updatable. After creation can only be disabled.
    byte constant ENFORCE_REVISIONS = 0x02;   // True if the blob is enforcing revisions. After creation can only be enabled.
    byte constant RETRACTABLE = 0x04;         // True if the blob can be retracted. After creation can only be disabled.
    byte constant TRANSFERABLE = 0x08;        // True if the blob be transfered to another user or disowned. After creation can only be disabled.
    byte constant ANONYMOUS = 0x10;           // True if the blob should not have an owner.

    BlobStoreRegistry blobStoreRegistry;
    BlobStoreIpfsSha256 blobStore;
    BlobStoreIpfsSha256Proxy blobStoreProxy;

    function setUp() {
        blobStoreRegistry = new BlobStoreRegistry();
        blobStore = new BlobStoreIpfsSha256(blobStoreRegistry);
        blobStoreProxy = new BlobStoreIpfsSha256Proxy(blobStore);
    }

    function testControlCreateSameIpfsHashAndNonce() {
        blobStore.create(0, 0x1234, 0);
        blobStore.create(0, 0x1234, 1);
        blobStore.create(0, 0x2345, 0);
    }

    function testFailCreateSameIpfsHashAndNonce() {
        blobStore.create(0, 0x1234, 0);
        blobStore.create(0, 0x1234, 0);
    }

    function testCreate() {
        bytes20 blobId0 = blobStore.create(0, 0x1234, 0);
        assert(blobStore.getExists(blobId0));
        assertEq(blobStore.getFlags(blobId0), 0);
        assertEq(blobStore.getOwner(blobId0), this);
        assertEq(blobStore.getRevisionCount(blobId0), 1);
        assert(!blobStore.getUpdatable(blobId0));
        assert(!blobStore.getEnforceRevisions(blobId0));
        assert(!blobStore.getRetractable(blobId0));
        assert(!blobStore.getTransferable(blobId0));
        assertEq(blobStore.getRevisionIpfsHash(blobId0, 0), 0x1234);

        bytes20 blobId1 = blobStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS, 0x1234, 1);
        assert(blobStore.getExists(blobId1));
        assertEq(blobStore.getFlags(blobId1), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS);
        assertEq(blobStore.getOwner(blobId1), 0);
        assertEq(blobStore.getRevisionCount(blobId1), 1);
        assert(blobStore.getUpdatable(blobId1));
        assert(blobStore.getEnforceRevisions(blobId1));
        assert(blobStore.getRetractable(blobId1));
        assert(blobStore.getTransferable(blobId1));
        assertEq(blobStore.getRevisionIpfsHash(blobId1, 0), 0x1234);

        bytes20 blobId2 = blobStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS, 0x2345, 0);
        assert(blobStore.getExists(blobId2));
        assertEq(blobStore.getFlags(blobId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS);
        assertEq(blobStore.getOwner(blobId2), 0);
        assertEq(blobStore.getRevisionCount(blobId2), 1);
        assert(blobStore.getUpdatable(blobId2));
        assert(blobStore.getEnforceRevisions(blobId2));
        assert(blobStore.getRetractable(blobId2));
        assert(blobStore.getTransferable(blobId2));
        assertEq(blobStore.getRevisionIpfsHash(blobId2, 0), 0x2345);

        assert(blobId0 != blobId1);
        assert(blobId0 != blobId2);
        assert(blobId1 != blobId2);
    }

    function testControlCreateNewRevisionNotOwner() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
    }

    function testFailCreateNewRevisionNotOwner() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStoreProxy.createNewRevision(blobId, 0x2345);
    }

    function testControlCreateNewRevisionNotUpdatable() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
    }

    function testFailCreateNewRevisionNotUpdatable() {
        bytes20 blobId = blobStore.create(0, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
    }

    function testCreateNewRevision() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        uint revisionId = blobStore.createNewRevision(blobId, 0x2345);
        assertEq(revisionId, 1);
        assertEq(blobStore.getRevisionCount(blobId), 2);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x1234);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 1), 0x2345);
    }

    function testControlUpdateLatestRevisionNotOwner() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.updateLatestRevision(blobId, 0x2345);
    }

    function testFailUpdateLatestRevisionNotOwner() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStoreProxy.updateLatestRevision(blobId, 0x2345);
    }

    function testControlUpdateLatestRevisionNotUpdatable() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.updateLatestRevision(blobId, 0x2345);
    }

    function testFailUpdateLatestRevisionNotUpdatable() {
        bytes20 blobId = blobStore.create(0, 0x1234, 0);
        blobStore.updateLatestRevision(blobId, 0x2345);
    }

    function testControlUpdateLatestRevisionEnforceRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.updateLatestRevision(blobId, 0x2345);
    }

    function testFailUpdateLatestRevisionEnforceRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE | ENFORCE_REVISIONS, 0x1234, 0);
        blobStore.updateLatestRevision(blobId, 0x2345);
    }

    function testUpdateLatestRevision() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        assertEq(blobStore.getRevisionCount(blobId), 1);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x1234);
        blobStore.updateLatestRevision(blobId, 0x2345);
        assertEq(blobStore.getRevisionCount(blobId), 1);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x2345);
    }

    function testControlRetractLatestRevisionNotOwner() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
        blobStore.retractLatestRevision(blobId);
    }

    function testFailRetractLatestRevisionNotOwner() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
        blobStoreProxy.retractLatestRevision(blobId);
    }

    function testControlRetractLatestRevisionNotUpdatable() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
        blobStore.retractLatestRevision(blobId);
    }

    function testFailRetractLatestRevisionNotUpdatable() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
        blobStore.setNotUpdatable(blobId);
        blobStore.retractLatestRevision(blobId);
    }

    function testControlRetractLatestRevisionEnforceRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
        blobStore.retractLatestRevision(blobId);
    }

    function testFailRetractLatestRevisionEnforceRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE | ENFORCE_REVISIONS, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
        blobStore.retractLatestRevision(blobId);
    }

    function testControlRetractLatestRevisionDoesntHaveAdditionalRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
        blobStore.retractLatestRevision(blobId);
    }

    function testFailRetractLatestRevisionDoesntHaveAdditionalRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.retractLatestRevision(blobId);
    }

    function testRetractLatestRevision() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
        blobStore.createNewRevision(blobId, 0x3456);
        assertEq(blobStore.getRevisionCount(blobId), 3);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x1234);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 1), 0x2345);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 2), 0x3456);
        blobStore.retractLatestRevision(blobId);
        assertEq(blobStore.getRevisionCount(blobId), 2);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x1234);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 1), 0x2345);
        blobStore.retractLatestRevision(blobId);
        assertEq(blobStore.getRevisionCount(blobId), 1);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x1234);
    }

    function testControlRestartNotOwner() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.restart(blobId, 0x2345);
    }

    function testFailRestartNotOwner() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStoreProxy.restart(blobId, 0x2345);
    }

    function testControlRestartNotUpdatable() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.restart(blobId, 0x2345);
    }

    function testFailRestartNotUpdatable() {
        bytes20 blobId = blobStore.create(0, 0x1234, 0);
        blobStore.restart(blobId, 0x2345);
    }

    function testControlRestartEnforceRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.restart(blobId, 0x2345);
    }

    function testFailRestartEnforceRevisions() {
        bytes20 blobId = blobStore.create(UPDATABLE | ENFORCE_REVISIONS, 0x1234, 0);
        blobStore.restart(blobId, 0x2345);
    }

    function testRestart() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.createNewRevision(blobId, 0x2345);
        blobStore.createNewRevision(blobId, 0x3456);
        assertEq(blobStore.getRevisionCount(blobId), 3);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x1234);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 1), 0x2345);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 2), 0x3456);
        blobStore.restart(blobId, 0x4567);
        assertEq(blobStore.getRevisionCount(blobId), 1);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x4567);
    }

    function testControlRetractNotOwner() {
        bytes20 blobId = blobStore.create(RETRACTABLE, 0x1234, 0);
        blobStore.retract(blobId);
    }

    function testFailRetractNotOwner() {
        bytes20 blobId = blobStore.create(RETRACTABLE, 0x1234, 0);
        blobStoreProxy.retract(blobId);
    }

    function testControlRetractNotRetractable() {
        bytes20 blobId = blobStore.create(RETRACTABLE, 0x1234, 0);
        blobStore.retract(blobId);
    }

    function testFailRetractNotRetractable() {
        bytes20 blobId = blobStore.create(0, 0x1234, 0);
        blobStore.retract(blobId);
    }

    function testRetract() {
        bytes20 blobId = blobStore.create(RETRACTABLE, 0x1234, 0);
        assertEq(blobStore.getRevisionCount(blobId), 1);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x1234);
        blobStore.retract(blobId);
        assert(!blobStore.getExists(blobId));
    }

    function testControlTransferEnableNotTransferable() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStoreProxy.transferEnable(blobId);
    }

    function testFailTransferEnableNotTransferable() {
        bytes20 blobId = blobStore.create(0, 0x1234, 0);
        blobStoreProxy.transferEnable(blobId);
    }

    function testControlTransferDisableNotEnabled() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStoreProxy.transferEnable(blobId);
        blobStoreProxy.transferDisable(blobId);
    }

    function testFailTransferDisableNotEnabled() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStoreProxy.transferDisable(blobId);
    }

    function testControlTransferNotTransferable() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStoreProxy.transferEnable(blobId);
        blobStore.transfer(blobId, blobStoreProxy);
    }

    function testFailTransferNotTransferable() {
        bytes20 blobId = blobStore.create(0, 0x1234, 0);
        blobStoreProxy.transferEnable(blobId);
        blobStore.transfer(blobId, blobStoreProxy);
    }

    function testControlTransferNotEnabled() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStoreProxy.transferEnable(blobId);
        blobStore.transfer(blobId, blobStoreProxy);
    }

    function testFailTransferNotEnabled() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStore.transfer(blobId, blobStoreProxy);
    }

    function testControlTransferDisabled() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStoreProxy.transferEnable(blobId);
        blobStore.transfer(blobId, blobStoreProxy);
    }

    function testFailTransferDisabled() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStoreProxy.transferEnable(blobId);
        blobStoreProxy.transferDisable(blobId);
        blobStore.transfer(blobId, blobStoreProxy);
    }

    function testTransfer() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        assertEq(blobStore.getOwner(blobId), this);
        assertEq(blobStore.getRevisionCount(blobId), 1);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x1234);
        blobStoreProxy.transferEnable(blobId);
        blobStore.transfer(blobId, blobStoreProxy);
        assertEq(blobStore.getOwner(blobId), blobStoreProxy);
        assertEq(blobStore.getRevisionCount(blobId), 1);
        assertEq(blobStore.getRevisionIpfsHash(blobId, 0), 0x1234);
    }

    function testControlDisownNotOwner() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStore.disown(blobId);
    }

    function testFailDisownNotOwner() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStoreProxy.disown(blobId);
    }

    function testControlDisownNotTransferable() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStore.disown(blobId);
    }

    function testFailDisownNotTransferable() {
        bytes20 blobId = blobStore.create(0, 0x1234, 0);
        blobStore.disown(blobId);
    }

    function testDisown() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        assertEq(blobStore.getOwner(blobId), this);
        blobStore.disown(blobId);
        assertEq(blobStore.getOwner(blobId), 0);
    }

    function testControlSetNotUpdatableNotOwner() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStore.setNotUpdatable(blobId);
    }

    function testFailSetNotUpdatableNotOwner() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        blobStoreProxy.setNotUpdatable(blobId);
    }

    function testSetNotUpdatable() {
        bytes20 blobId = blobStore.create(UPDATABLE, 0x1234, 0);
        assert(blobStore.getUpdatable(blobId));
        blobStore.setNotUpdatable(blobId);
        assert(!blobStore.getUpdatable(blobId));
    }

    function testControlSetEnforceRevisionsNotOwner() {
        bytes20 blobId = blobStore.create(0, 0x1234, 0);
        blobStore.setEnforceRevisions(blobId);
    }

    function testFailSetEnforceRevisionsNotOwner() {
        bytes20 blobId = blobStore.create(0, 0x1234, 0);
        blobStoreProxy.setEnforceRevisions(blobId);
    }

    function testSetEnforceRevisions() {
        bytes20 blobId = blobStore.create(0, 0x1234, 0);
        assert(!blobStore.getEnforceRevisions(blobId));
        blobStore.setEnforceRevisions(blobId);
        assert(blobStore.getEnforceRevisions(blobId));
    }

    function testControlSetNotRetractableNotOwner() {
        bytes20 blobId = blobStore.create(RETRACTABLE, 0x1234, 0);
        blobStore.setNotRetractable(blobId);
    }

    function testFailSetNotRetractableNotOwner() {
        bytes20 blobId = blobStore.create(RETRACTABLE, 0x1234, 0);
        blobStoreProxy.setNotRetractable(blobId);
    }

    function testSetNotRetractable() {
        bytes20 blobId = blobStore.create(RETRACTABLE, 0x1234, 0);
        assert(blobStore.getRetractable(blobId));
        blobStore.setNotRetractable(blobId);
        assert(!blobStore.getRetractable(blobId));
    }

    function testControlSetNotTransferableNotOwner() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStore.setNotTransferable(blobId);
    }

    function testFailSetNotTransferableNotOwner() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        blobStoreProxy.setNotTransferable(blobId);
    }

    function testSetNotTransferable() {
        bytes20 blobId = blobStore.create(TRANSFERABLE, 0x1234, 0);
        assert(blobStore.getTransferable(blobId));
        blobStore.setNotTransferable(blobId);
        assert(!blobStore.getTransferable(blobId));
    }

}
