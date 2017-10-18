pragma solidity ^0.4.17;

import "ds-test/test.sol";

import "./item_store_registry.sol";
import "./item_store_ipfs_sha256.sol";
import "./item_store_ipfs_sha256_proxy.sol";


/**
 * @title ItemStoreIpfsSha256Test
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for ItemStoreIpfsSha256.
 */
contract ItemStoreIpfsSha256Test is DSTest {

    byte constant UPDATABLE = 0x01;           // True if the item is updatable. After creation can only be disabled.
    byte constant ENFORCE_REVISIONS = 0x02;   // True if the item is enforcing revisions. After creation can only be enabled.
    byte constant RETRACTABLE = 0x04;         // True if the item can be retracted. After creation can only be disabled.
    byte constant TRANSFERABLE = 0x08;        // True if the item be transfered to another user or disowned. After creation can only be disabled.
    byte constant ANONYMOUS = 0x10;           // True if the item should not have an owner.

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;
    ItemStoreIpfsSha256Proxy itemStoreProxy;

    function setUp() {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
        itemStoreProxy = new ItemStoreIpfsSha256Proxy(itemStore);
    }

    function testControlCreateSameNonce() {
        itemStore.create(0, 0x1234, 0);
        itemStore.create(0, 0x1234, 1);
    }

    function testFailCreateSameNonce() {
        itemStore.create(0, 0x1234, 0);
        itemStore.create(0, 0x1234, 0);
    }

    function testCreate() {
        bytes20 itemId0 = itemStore.create(0, 0x1234, 0);
        assert(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), this);
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assert(!itemStore.getUpdatable(itemId0));
        assert(!itemStore.getEnforceRevisions(itemId0));
        assert(!itemStore.getRetractable(itemId0));
        assert(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), block.timestamp);

        bytes20 itemId1 = itemStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS, 0x1234, 1);
        assert(itemStore.getInUse(itemId1));
        assertEq(itemStore.getFlags(itemId1), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS);
        assertEq(itemStore.getOwner(itemId1), 0);
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assert(itemStore.getUpdatable(itemId1));
        assert(itemStore.getEnforceRevisions(itemId1));
        assert(itemStore.getRetractable(itemId1));
        assert(itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId1, 0), block.timestamp);

        bytes20 itemId2 = itemStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS, 0x2345, 2);
        assert(itemStore.getInUse(itemId2));
        assertEq(itemStore.getFlags(itemId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS);
        assertEq(itemStore.getOwner(itemId2), 0);
        assertEq(itemStore.getRevisionCount(itemId2), 1);
        assert(itemStore.getUpdatable(itemId2));
        assert(itemStore.getEnforceRevisions(itemId2));
        assert(itemStore.getRetractable(itemId2));
        assert(itemStore.getTransferable(itemId2));
        assertEq(itemStore.getRevisionIpfsHash(itemId2, 0), 0x2345);
        assertEq(itemStore.getRevisionTimestamp(itemId2, 0), block.timestamp);

        assert(itemId0 != itemId1);
        assert(itemId0 != itemId2);
        assert(itemId1 != itemId2);
    }

    function testControlCreateNewRevisionNotOwner() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
    }

    function testFailCreateNewRevisionNotOwner() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStoreProxy.createNewRevision(itemId, 0x2345);
    }

    function testControlCreateNewRevisionNotUpdatable() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
    }

    function testFailCreateNewRevisionNotUpdatable() {
        bytes20 itemId = itemStore.create(0, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
    }

    function testCreateNewRevision() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0, 0);
        uint revisionId = itemStore.createNewRevision(itemId, 1);
        assertEq(revisionId, 1);
        revisionId = itemStore.createNewRevision(itemId, 2);
        assertEq(revisionId, 2);
        revisionId = itemStore.createNewRevision(itemId, 3);
        assertEq(revisionId, 3);
        revisionId = itemStore.createNewRevision(itemId, 4);
        assertEq(revisionId, 4);
        revisionId = itemStore.createNewRevision(itemId, 5);
        assertEq(revisionId, 5);
        revisionId = itemStore.createNewRevision(itemId, 6);
        assertEq(revisionId, 6);
        revisionId = itemStore.createNewRevision(itemId, 7);
        assertEq(revisionId, 7);
        revisionId = itemStore.createNewRevision(itemId, 8);
        assertEq(revisionId, 8);
        revisionId = itemStore.createNewRevision(itemId, 9);
        assertEq(revisionId, 9);
        revisionId = itemStore.createNewRevision(itemId, 10);
        assertEq(revisionId, 10);
        revisionId = itemStore.createNewRevision(itemId, 11);
        assertEq(revisionId, 11);
        revisionId = itemStore.createNewRevision(itemId, 12);
        assertEq(revisionId, 12);
        revisionId = itemStore.createNewRevision(itemId, 13);
        assertEq(revisionId, 13);
        assertEq(itemStore.getRevisionCount(itemId), 14);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 2), 2);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 3), 3);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 4), 4);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 5), 5);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 6), 6);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 7), 7);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 8), 8);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 9), 9);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 10), 10);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 11), 11);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 12), 12);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 13), 13);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 2), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 3), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 4), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 5), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 6), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 7), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 8), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 9), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 10), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 11), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 12), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 13), block.timestamp);
    }

    function testControlUpdateLatestRevisionNotOwner() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.updateLatestRevision(itemId, 0x2345);
    }

    function testFailUpdateLatestRevisionNotOwner() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStoreProxy.updateLatestRevision(itemId, 0x2345);
    }

    function testControlUpdateLatestRevisionNotUpdatable() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.updateLatestRevision(itemId, 0x2345);
    }

    function testFailUpdateLatestRevisionNotUpdatable() {
        bytes20 itemId = itemStore.create(0, 0x1234, 0);
        itemStore.updateLatestRevision(itemId, 0x2345);
    }

    function testControlUpdateLatestRevisionEnforceRevisions() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.updateLatestRevision(itemId, 0x2345);
    }

    function testFailUpdateLatestRevisionEnforceRevisions() {
        bytes20 itemId = itemStore.create(UPDATABLE | ENFORCE_REVISIONS, 0x1234, 0);
        itemStore.updateLatestRevision(itemId, 0x2345);
    }

    function testUpdateLatestRevision() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        itemStore.updateLatestRevision(itemId, 0x2345);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x2345);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
    }

    function testControlRetractLatestRevisionNotOwner() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionNotOwner() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStoreProxy.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionNotUpdatable() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionNotUpdatable() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.setNotUpdatable(itemId);
        itemStore.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionEnforceRevisions() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionEnforceRevisions() {
        bytes20 itemId = itemStore.create(UPDATABLE | ENFORCE_REVISIONS, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionDoesntHaveAdditionalRevisions() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionDoesntHaveAdditionalRevisions() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.retractLatestRevision(itemId);
    }

    function testRetractLatestRevision() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.createNewRevision(itemId, 0x3456);
        assertEq(itemStore.getRevisionCount(itemId), 3);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), 0x2345);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 2), 0x3456);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 2), block.timestamp);
        itemStore.retractLatestRevision(itemId);
        assertEq(itemStore.getRevisionCount(itemId), 2);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), 0x2345);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), block.timestamp);
        itemStore.retractLatestRevision(itemId);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
    }

    function testControlRestartNotOwner() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.restart(itemId, 0x2345);
    }

    function testFailRestartNotOwner() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStoreProxy.restart(itemId, 0x2345);
    }

    function testControlRestartNotUpdatable() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.restart(itemId, 0x2345);
    }

    function testFailRestartNotUpdatable() {
        bytes20 itemId = itemStore.create(0, 0x1234, 0);
        itemStore.restart(itemId, 0x2345);
    }

    function testControlRestartEnforceRevisions() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.restart(itemId, 0x2345);
    }

    function testFailRestartEnforceRevisions() {
        bytes20 itemId = itemStore.create(UPDATABLE | ENFORCE_REVISIONS, 0x1234, 0);
        itemStore.restart(itemId, 0x2345);
    }

    function testRestart() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.createNewRevision(itemId, 0x3456);
        assertEq(itemStore.getRevisionCount(itemId), 3);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), 0x2345);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 2), 0x3456);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 2), block.timestamp);
        itemStore.restart(itemId, 0x4567);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x4567);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
    }

    function testControlRetractNotOwner() {
        bytes20 itemId = itemStore.create(RETRACTABLE, 0x1234, 0);
        itemStore.retract(itemId);
    }

    function testFailRetractNotOwner() {
        bytes20 itemId = itemStore.create(RETRACTABLE, 0x1234, 0);
        itemStoreProxy.retract(itemId);
    }

    function testControlRetractNotRetractable() {
        bytes20 itemId = itemStore.create(RETRACTABLE, 0x1234, 0);
        itemStore.retract(itemId);
    }

    function testFailRetractNotRetractable() {
        bytes20 itemId = itemStore.create(0, 0x1234, 0);
        itemStore.retract(itemId);
    }

    function testRetract() {
        bytes20 itemId = itemStore.create(RETRACTABLE, 0x1234, 0);
        assert(itemStore.getInUse(itemId));
        assertEq(itemStore.getOwner(itemId), this);
        assert(!itemStore.getUpdatable(itemId));
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        itemStore.retract(itemId);
        assert(itemStore.getInUse(itemId));
        assertEq(itemStore.getOwner(itemId), 0);
        assert(!itemStore.getUpdatable(itemId));
        assertEq(itemStore.getRevisionCount(itemId), 0);
    }

    function testControlTransferEnableNotTransferable() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStoreProxy.transferEnable(itemId);
    }

    function testFailTransferEnableNotTransferable() {
        bytes20 itemId = itemStore.create(0, 0x1234, 0);
        itemStoreProxy.transferEnable(itemId);
    }

    function testControlTransferDisableNotEnabled() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStoreProxy.transferEnable(itemId);
        itemStoreProxy.transferDisable(itemId);
    }

    function testFailTransferDisableNotEnabled() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStoreProxy.transferDisable(itemId);
    }

    function testControlTransferNotTransferable() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testFailTransferNotTransferable() {
        bytes20 itemId = itemStore.create(0, 0x1234, 0);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testControlTransferNotEnabled() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testFailTransferNotEnabled() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testControlTransferDisabled() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testFailTransferDisabled() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStoreProxy.transferEnable(itemId);
        itemStoreProxy.transferDisable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testTransfer() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        assertEq(itemStore.getOwner(itemId), this);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
        assertEq(itemStore.getOwner(itemId), itemStoreProxy);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
    }

    function testControlDisownNotOwner() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStore.disown(itemId);
    }

    function testFailDisownNotOwner() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStoreProxy.disown(itemId);
    }

    function testControlDisownNotTransferable() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStore.disown(itemId);
    }

    function testFailDisownNotTransferable() {
        bytes20 itemId = itemStore.create(0, 0x1234, 0);
        itemStore.disown(itemId);
    }

    function testDisown() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        assertEq(itemStore.getOwner(itemId), this);
        itemStore.disown(itemId);
        assertEq(itemStore.getOwner(itemId), 0);
    }

    function testControlSetNotUpdatableNotOwner() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStore.setNotUpdatable(itemId);
    }

    function testFailSetNotUpdatableNotOwner() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        itemStoreProxy.setNotUpdatable(itemId);
    }

    function testSetNotUpdatable() {
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        assert(itemStore.getUpdatable(itemId));
        itemStore.setNotUpdatable(itemId);
        assert(!itemStore.getUpdatable(itemId));
    }

    function testControlSetEnforceRevisionsNotOwner() {
        bytes20 itemId = itemStore.create(0, 0x1234, 0);
        itemStore.setEnforceRevisions(itemId);
    }

    function testFailSetEnforceRevisionsNotOwner() {
        bytes20 itemId = itemStore.create(0, 0x1234, 0);
        itemStoreProxy.setEnforceRevisions(itemId);
    }

    function testSetEnforceRevisions() {
        bytes20 itemId = itemStore.create(0, 0x1234, 0);
        assert(!itemStore.getEnforceRevisions(itemId));
        itemStore.setEnforceRevisions(itemId);
        assert(itemStore.getEnforceRevisions(itemId));
    }

    function testControlSetNotRetractableNotOwner() {
        bytes20 itemId = itemStore.create(RETRACTABLE, 0x1234, 0);
        itemStore.setNotRetractable(itemId);
    }

    function testFailSetNotRetractableNotOwner() {
        bytes20 itemId = itemStore.create(RETRACTABLE, 0x1234, 0);
        itemStoreProxy.setNotRetractable(itemId);
    }

    function testSetNotRetractable() {
        bytes20 itemId = itemStore.create(RETRACTABLE, 0x1234, 0);
        assert(itemStore.getRetractable(itemId));
        itemStore.setNotRetractable(itemId);
        assert(!itemStore.getRetractable(itemId));
    }

    function testControlSetNotTransferableNotOwner() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStore.setNotTransferable(itemId);
    }

    function testFailSetNotTransferableNotOwner() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        itemStoreProxy.setNotTransferable(itemId);
    }

    function testSetNotTransferable() {
        bytes20 itemId = itemStore.create(TRANSFERABLE, 0x1234, 0);
        assert(itemStore.getTransferable(itemId));
        itemStore.setNotTransferable(itemId);
        assert(!itemStore.getTransferable(itemId));
    }

}