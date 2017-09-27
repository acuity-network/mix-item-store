pragma solidity ^0.4.17;

import "ds-test/test.sol";

import "./item_store_registry.sol";
import "./item_store_ipfs_sha256.sol";
import "./item_store_ipfs_sha256_proxy.sol";


/**
 * @title ItemStoreIpfsSha256Test
 * @author Jonathan Brown <jbrown@link-blockchain.org>
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
        assert(itemStore.getExists(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), this);
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assert(!itemStore.getUpdatable(itemId0));
        assert(!itemStore.getEnforceRevisions(itemId0));
        assert(!itemStore.getRetractable(itemId0));
        assert(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), 0x1234);

        bytes20 itemId1 = itemStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS, 0x1234, 1);
        assert(itemStore.getExists(itemId1));
        assertEq(itemStore.getFlags(itemId1), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS);
        assertEq(itemStore.getOwner(itemId1), 0);
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assert(itemStore.getUpdatable(itemId1));
        assert(itemStore.getEnforceRevisions(itemId1));
        assert(itemStore.getRetractable(itemId1));
        assert(itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), 0x1234);

        bytes20 itemId2 = itemStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS, 0x2345, 2);
        assert(itemStore.getExists(itemId2));
        assertEq(itemStore.getFlags(itemId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | ANONYMOUS);
        assertEq(itemStore.getOwner(itemId2), 0);
        assertEq(itemStore.getRevisionCount(itemId2), 1);
        assert(itemStore.getUpdatable(itemId2));
        assert(itemStore.getEnforceRevisions(itemId2));
        assert(itemStore.getRetractable(itemId2));
        assert(itemStore.getTransferable(itemId2));
        assertEq(itemStore.getRevisionIpfsHash(itemId2, 0), 0x2345);

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
        bytes20 itemId = itemStore.create(UPDATABLE, 0x1234, 0);
        uint revisionId = itemStore.createNewRevision(itemId, 0x2345);
        assertEq(revisionId, 1);
        assertEq(itemStore.getRevisionCount(itemId), 2);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), 0x2345);
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
        itemStore.updateLatestRevision(itemId, 0x2345);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x2345);
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
        itemStore.retractLatestRevision(itemId);
        assertEq(itemStore.getRevisionCount(itemId), 2);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), 0x2345);
        itemStore.retractLatestRevision(itemId);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
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
        itemStore.restart(itemId, 0x4567);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x4567);
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
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        itemStore.retract(itemId);
        assert(!itemStore.getExists(itemId));
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
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
        assertEq(itemStore.getOwner(itemId), itemStoreProxy);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
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
