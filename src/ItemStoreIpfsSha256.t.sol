pragma solidity ^0.5.10;

import "ds-test/test.sol";

import "./ItemStoreRegistry.sol";
import "./ItemStoreConstants.sol";
import "./ItemStoreIpfsSha256.sol";
import "./ItemStoreIpfsSha256Proxy.sol";


/**
 * @title ItemStoreIpfsSha256Test
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for ItemStoreIpfsSha256.
 */
contract ItemStoreIpfsSha256Test is DSTest, ItemStoreConstants {

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;
    ItemStoreIpfsSha256Proxy itemStoreProxy;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
        itemStoreProxy = new ItemStoreIpfsSha256Proxy(itemStore);
    }

    function testControlCreateSameItemId() public {
        itemStore.create(hex"1234", hex"1234");
        itemStore.getNewItemId(address(this), hex"2345");
    }

    function testFailCreateSameItemId() public {
        itemStore.create(hex"1234", hex"1234");
        itemStore.getNewItemId(address(this), hex"1234");
    }

    function testGetNewItemId() public {
        assertEq((itemStore.getNewItemId(address(this), hex"1234") & CONTRACT_ID_MASK) << 192, itemStore.getContractId());
        assertEq(itemStore.getNewItemId(address(this), hex"1234"), itemStore.getNewItemId(address(this), hex"1234"));
        assertTrue(itemStore.getNewItemId(address(this), hex"1234") != itemStore.getNewItemId(address(this), hex"2345"));
        assertTrue(itemStore.getNewItemId(address(this), hex"1234") != itemStore.getNewItemId(address(0), hex"1234"));
    }

    function testCreate() public {
        bytes32 itemId0 = itemStore.create(hex"0000", hex"1234");
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), address(this));
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), 0);
        assertEq(itemStore.getRevisionCount(itemId0), 1);

        bytes32 itemId1 = itemStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(hex"0001"), hex"1234");
        assertTrue(itemStore.getInUse(itemId1));
        assertEq(itemStore.getFlags(itemId1), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId1), address(0));
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assertTrue(itemStore.getUpdatable(itemId1));
        assertTrue(itemStore.getEnforceRevisions(itemId1));
        assertTrue(itemStore.getRetractable(itemId1));
        assertTrue(itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId1, 0), 0);
        assertEq(itemStore.getRevisionCount(itemId1), 1);

        bytes32 itemId2 = itemStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(hex"0002"), hex"2345");
        assertTrue(itemStore.getInUse(itemId2));
        assertEq(itemStore.getFlags(itemId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId2), address(0));
        assertEq(itemStore.getRevisionCount(itemId2), 1);
        assertTrue(itemStore.getUpdatable(itemId2));
        assertTrue(itemStore.getEnforceRevisions(itemId2));
        assertTrue(itemStore.getRetractable(itemId2));
        assertTrue(itemStore.getTransferable(itemId2));
        assertEq(itemStore.getRevisionIpfsHash(itemId2, 0), hex"2345");
        assertEq(itemStore.getRevisionTimestamp(itemId2, 0), 0);
        assertEq(itemStore.getRevisionCount(itemId2), 1);

        assertTrue(itemId0 != itemId1);
        assertTrue(itemId0 != itemId2);
        assertTrue(itemId1 != itemId2);
    }

    function testControlCreateNewRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
    }

    function testFailCreateNewRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStoreProxy.createNewRevision(itemId, hex"2345");
    }

    function testControlCreateNewRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
    }

    function testFailCreateNewRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(0, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
    }

    function testCreateNewRevision() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"00");
        uint revisionId = itemStore.createNewRevision(itemId, hex"01");
        assertEq(revisionId, 1);
        revisionId = itemStore.createNewRevision(itemId, hex"02");
        assertEq(revisionId, 2);
        revisionId = itemStore.createNewRevision(itemId, hex"03");
        assertEq(revisionId, 3);
        revisionId = itemStore.createNewRevision(itemId, hex"04");
        assertEq(revisionId, 4);
        revisionId = itemStore.createNewRevision(itemId, hex"05");
        assertEq(revisionId, 5);
        revisionId = itemStore.createNewRevision(itemId, hex"06");
        assertEq(revisionId, 6);
        revisionId = itemStore.createNewRevision(itemId, hex"07");
        assertEq(revisionId, 7);
        revisionId = itemStore.createNewRevision(itemId, hex"08");
        assertEq(revisionId, 8);
        revisionId = itemStore.createNewRevision(itemId, hex"09");
        assertEq(revisionId, 9);
        revisionId = itemStore.createNewRevision(itemId, hex"10");
        assertEq(revisionId, 10);
        revisionId = itemStore.createNewRevision(itemId, hex"11");
        assertEq(revisionId, 11);
        revisionId = itemStore.createNewRevision(itemId, hex"12");
        assertEq(revisionId, 12);
        revisionId = itemStore.createNewRevision(itemId, hex"13");
        assertEq(revisionId, 13);
        assertEq(itemStore.getRevisionCount(itemId), 14);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"00");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), hex"01");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 2), hex"02");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 3), hex"03");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 4), hex"04");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 5), hex"05");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 6), hex"06");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 7), hex"07");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 8), hex"08");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 9), hex"09");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 10), hex"10");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 11), hex"11");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 12), hex"12");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 13), hex"13");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 2), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 3), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 4), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 5), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 6), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 7), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 8), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 9), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 10), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 11), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 12), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 13), 0);
    }

    function testControlUpdateLatestRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.updateLatestRevision(itemId, hex"2345");
    }

    function testFailUpdateLatestRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStoreProxy.updateLatestRevision(itemId, hex"2345");
    }

    function testControlUpdateLatestRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.updateLatestRevision(itemId, hex"2345");
    }

    function testFailUpdateLatestRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(0, hex"1234");
        itemStore.updateLatestRevision(itemId, hex"2345");
    }

    function testControlUpdateLatestRevisionEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.updateLatestRevision(itemId, hex"2345");
    }

    function testFailUpdateLatestRevisionEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE | ENFORCE_REVISIONS, hex"1234");
        itemStore.updateLatestRevision(itemId, hex"2345");
    }

    function testUpdateLatestRevision() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
        itemStore.updateLatestRevision(itemId, hex"2345");
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"2345");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
    }

    function testControlRetractLatestRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
        itemStoreProxy.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
        itemStore.setNotUpdatable(itemId);
        itemStore.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE | ENFORCE_REVISIONS, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
        itemStore.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionDoesntHaveAdditionalRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionDoesntHaveAdditionalRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.retractLatestRevision(itemId);
    }

    function testRetractLatestRevision() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
        itemStore.createNewRevision(itemId, hex"3456");
        assertEq(itemStore.getRevisionCount(itemId), 3);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), hex"2345");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 2), hex"3456");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 2), 0);
        itemStore.retractLatestRevision(itemId);
        assertEq(itemStore.getRevisionCount(itemId), 2);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), hex"2345");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), 0);
        itemStore.retractLatestRevision(itemId);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
    }

    function testControlRestartNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.restart(itemId, hex"2345");
    }

    function testFailRestartNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStoreProxy.restart(itemId, hex"2345");
    }

    function testControlRestartNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.restart(itemId, hex"2345");
    }

    function testFailRestartNotUpdatable() public {
        bytes32 itemId = itemStore.create(0, hex"1234");
        itemStore.restart(itemId, hex"2345");
    }

    function testControlRestartEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.restart(itemId, hex"2345");
    }

    function testFailRestartEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE | ENFORCE_REVISIONS, hex"1234");
        itemStore.restart(itemId, hex"2345");
    }

    function testRestart() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.createNewRevision(itemId, hex"2345");
        itemStore.createNewRevision(itemId, hex"3456");
        assertEq(itemStore.getRevisionCount(itemId), 3);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), hex"2345");
        assertEq(itemStore.getRevisionIpfsHash(itemId, 2), hex"3456");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), 0);
        assertEq(itemStore.getRevisionTimestamp(itemId, 2), 0);
        itemStore.restart(itemId, hex"4567");
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"4567");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
    }

    function testControlRetractNotOwner() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, hex"1234");
        itemStore.retract(itemId);
    }

    function testFailRetractNotOwner() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, hex"1234");
        itemStoreProxy.retract(itemId);
    }

    function testControlRetractNotRetractable() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, hex"1234");
        itemStore.retract(itemId);
    }

    function testFailRetractNotRetractable() public {
        bytes32 itemId = itemStore.create(0, hex"1234");
        itemStore.retract(itemId);
    }

    function testRetract() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, hex"1234");
        assertTrue(itemStore.getInUse(itemId));
        assertEq(itemStore.getOwner(itemId), address(this));
        assertTrue(!itemStore.getUpdatable(itemId));
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
        itemStore.retract(itemId);
        assertTrue(itemStore.getInUse(itemId));
        assertEq(itemStore.getOwner(itemId), address(0));
        assertTrue(!itemStore.getUpdatable(itemId));
        assertEq(itemStore.getRevisionCount(itemId), 0);
    }

    function testControlTransferEnableNotTransferable() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStoreProxy.transferEnable(itemId);
    }

    function testFailTransferEnableNotTransferable() public {
        bytes32 itemId = itemStore.create(0, hex"1234");
        itemStoreProxy.transferEnable(itemId);
    }

    function testControlTransferDisableNotEnabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStoreProxy.transferEnable(itemId);
        itemStoreProxy.transferDisable(itemId);
    }

    function testFailTransferDisableNotEnabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStoreProxy.transferDisable(itemId);
    }

    function testControlTransferNotTransferable() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, address(itemStoreProxy));
    }

    function testFailTransferNotTransferable() public {
        bytes32 itemId = itemStore.create(0, hex"1234");
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, address(itemStoreProxy));
    }

    function testControlTransferNotEnabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, address(itemStoreProxy));
    }

    function testFailTransferNotEnabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStore.transfer(itemId, address(itemStoreProxy));
    }

    function testControlTransferDisabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, address(itemStoreProxy));
    }

    function testFailTransferDisabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStoreProxy.transferEnable(itemId);
        itemStoreProxy.transferDisable(itemId);
        itemStore.transfer(itemId, address(itemStoreProxy));
    }

    function testTransfer() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        assertEq(itemStore.getOwner(itemId), address(this));
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, address(itemStoreProxy));
        assertEq(itemStore.getOwner(itemId), address(itemStoreProxy));
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), 0);
    }

    function testControlDisownNotOwner() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStore.disown(itemId);
    }

    function testFailDisownNotOwner() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStoreProxy.disown(itemId);
    }

    function testControlDisownNotTransferable() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStore.disown(itemId);
    }

    function testFailDisownNotTransferable() public {
        bytes32 itemId = itemStore.create(0, hex"1234");
        itemStore.disown(itemId);
    }

    function testDisown() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        assertEq(itemStore.getOwner(itemId), address(this));
        itemStore.disown(itemId);
        assertEq(itemStore.getOwner(itemId), address(0));
    }

    function testControlSetNotUpdatableNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStore.setNotUpdatable(itemId);
    }

    function testFailSetNotUpdatableNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        itemStoreProxy.setNotUpdatable(itemId);
    }

    function testSetNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"1234");
        assertTrue(itemStore.getUpdatable(itemId));
        itemStore.setNotUpdatable(itemId);
        assertTrue(!itemStore.getUpdatable(itemId));
    }

    function testControlSetEnforceRevisionsNotOwner() public {
        bytes32 itemId = itemStore.create(0, hex"1234");
        itemStore.setEnforceRevisions(itemId);
    }

    function testFailSetEnforceRevisionsNotOwner() public {
        bytes32 itemId = itemStore.create(0, hex"1234");
        itemStoreProxy.setEnforceRevisions(itemId);
    }

    function testSetEnforceRevisions() public {
        bytes32 itemId = itemStore.create(0, hex"1234");
        assertTrue(!itemStore.getEnforceRevisions(itemId));
        itemStore.setEnforceRevisions(itemId);
        assertTrue(itemStore.getEnforceRevisions(itemId));
    }

    function testControlSetNotRetractableNotOwner() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, hex"1234");
        itemStore.setNotRetractable(itemId);
    }

    function testFailSetNotRetractableNotOwner() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, hex"1234");
        itemStoreProxy.setNotRetractable(itemId);
    }

    function testSetNotRetractable() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, hex"1234");
        assertTrue(itemStore.getRetractable(itemId));
        itemStore.setNotRetractable(itemId);
        assertTrue(!itemStore.getRetractable(itemId));
    }

    function testControlSetNotTransferableNotOwner() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStore.setNotTransferable(itemId);
    }

    function testFailSetNotTransferableNotOwner() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        itemStoreProxy.setNotTransferable(itemId);
    }

    function testSetNotTransferable() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, hex"1234");
        assertTrue(itemStore.getTransferable(itemId));
        itemStore.setNotTransferable(itemId);
        assertTrue(!itemStore.getTransferable(itemId));
    }

    function testGetAbiVersion() public {
        assertEq(itemStore.getAbiVersion(), 0);
    }

    function testMultipleGetters() public {
        bytes32 itemId = itemStore.create(UPDATABLE, hex"00");
        itemStore.createNewRevision(itemId, hex"01");
        itemStore.createNewRevision(itemId, hex"02");
        itemStore.createNewRevision(itemId, hex"03");
        itemStore.createNewRevision(itemId, hex"04");
        itemStore.createNewRevision(itemId, hex"05");
        itemStore.createNewRevision(itemId, hex"06");
        itemStore.createNewRevision(itemId, hex"07");
        itemStore.createNewRevision(itemId, hex"08");
        itemStore.createNewRevision(itemId, hex"09");
        itemStore.createNewRevision(itemId, hex"10");
        itemStore.createNewRevision(itemId, hex"11");
        itemStore.createNewRevision(itemId, hex"12");
        itemStore.createNewRevision(itemId, hex"13");

        (byte flags, address owner, uint[] memory timestamps, bytes32[] memory ipfsHashes) = itemStore.getItem(itemId);

        assertEq(flags, UPDATABLE);
        assertEq(owner, address(this));

        assertEq(timestamps.length, 14);
        assertEq(timestamps[0], 0);
        assertEq(timestamps[1], 0);
        assertEq(timestamps[2], 0);
        assertEq(timestamps[3], 0);
        assertEq(timestamps[4], 0);
        assertEq(timestamps[5], 0);
        assertEq(timestamps[6], 0);
        assertEq(timestamps[7], 0);
        assertEq(timestamps[8], 0);
        assertEq(timestamps[9], 0);
        assertEq(timestamps[10], 0);
        assertEq(timestamps[11], 0);
        assertEq(timestamps[12], 0);
        assertEq(timestamps[13], 0);

        assertEq(ipfsHashes.length, 14);
        assertEq(ipfsHashes[0], hex"00");
        assertEq(ipfsHashes[1], hex"01");
        assertEq(ipfsHashes[2], hex"02");
        assertEq(ipfsHashes[3], hex"03");
        assertEq(ipfsHashes[4], hex"04");
        assertEq(ipfsHashes[5], hex"05");
        assertEq(ipfsHashes[6], hex"06");
        assertEq(ipfsHashes[7], hex"07");
        assertEq(ipfsHashes[8], hex"08");
        assertEq(ipfsHashes[9], hex"09");
        assertEq(ipfsHashes[10], hex"10");
        assertEq(ipfsHashes[11], hex"11");
        assertEq(ipfsHashes[12], hex"12");
        assertEq(ipfsHashes[13], hex"13");

        timestamps = itemStore.getAllRevisionTimestamps(itemId);

        assertEq(timestamps.length, 14);
        assertEq(timestamps[0], 0);
        assertEq(timestamps[1], 0);
        assertEq(timestamps[2], 0);
        assertEq(timestamps[3], 0);
        assertEq(timestamps[4], 0);
        assertEq(timestamps[5], 0);
        assertEq(timestamps[6], 0);
        assertEq(timestamps[7], 0);
        assertEq(timestamps[8], 0);
        assertEq(timestamps[9], 0);
        assertEq(timestamps[10], 0);
        assertEq(timestamps[11], 0);
        assertEq(timestamps[12], 0);
        assertEq(timestamps[13], 0);

        ipfsHashes = itemStore.getAllRevisionIpfsHashes(itemId);

        assertEq(ipfsHashes.length, 14);
        assertEq(ipfsHashes[0], hex"00");
        assertEq(ipfsHashes[1], hex"01");
        assertEq(ipfsHashes[2], hex"02");
        assertEq(ipfsHashes[3], hex"03");
        assertEq(ipfsHashes[4], hex"04");
        assertEq(ipfsHashes[5], hex"05");
        assertEq(ipfsHashes[6], hex"06");
        assertEq(ipfsHashes[7], hex"07");
        assertEq(ipfsHashes[8], hex"08");
        assertEq(ipfsHashes[9], hex"09");
        assertEq(ipfsHashes[10], hex"10");
        assertEq(ipfsHashes[11], hex"11");
        assertEq(ipfsHashes[12], hex"12");
        assertEq(ipfsHashes[13], hex"13");
    }

}
