pragma solidity ^0.6.6;

import "ds-test/test.sol";

import "./MixItemStoreRegistry.sol";
import "./MixItemStoreConstants.sol";
import "./MixItemStoreIpfsSha256.sol";
import "./MixItemStoreIpfsSha256Proxy.sol";


contract MixItemStoreIpfsSha256Test is DSTest, MixItemStoreConstants {

    MixItemStoreRegistry mixItemStoreRegistry;
    MixItemStoreIpfsSha256 mixItemStoreIpfsSha256;
    MixItemStoreIpfsSha256Proxy mixItemStoreIpfsSha256Proxy;

    function setUp() public {
        mixItemStoreRegistry = new MixItemStoreRegistry();
        mixItemStoreIpfsSha256 = new MixItemStoreIpfsSha256(mixItemStoreRegistry);
        mixItemStoreIpfsSha256Proxy = new MixItemStoreIpfsSha256Proxy(mixItemStoreIpfsSha256);
    }

    function testControlCreateSameItemId() public {
        mixItemStoreIpfsSha256.create(hex"1234", hex"1234");
        mixItemStoreIpfsSha256.getNewItemId(address(this), hex"2345");
    }

    function testFailCreateSameItemId() public {
        mixItemStoreIpfsSha256.create(hex"1234", hex"1234");
        mixItemStoreIpfsSha256.getNewItemId(address(this), hex"1234");
    }

    function testGetNewItemId() public {
        assertEq((mixItemStoreIpfsSha256.getNewItemId(address(this), hex"1234") & CONTRACT_ID_MASK) << 192, mixItemStoreIpfsSha256.getContractId());
        assertEq(mixItemStoreIpfsSha256.getNewItemId(address(this), hex"1234"), mixItemStoreIpfsSha256.getNewItemId(address(this), hex"1234"));
        assertTrue(mixItemStoreIpfsSha256.getNewItemId(address(this), hex"1234") != mixItemStoreIpfsSha256.getNewItemId(address(this), hex"2345"));
        assertTrue(mixItemStoreIpfsSha256.getNewItemId(address(this), hex"1234") != mixItemStoreIpfsSha256.getNewItemId(address(0), hex"1234"));
    }

    function testCreate() public {
        bytes32 itemId0 = mixItemStoreIpfsSha256.create(hex"0000", hex"1234");
        assertTrue(mixItemStoreIpfsSha256.getInUse(itemId0));
        assertEq(mixItemStoreIpfsSha256.getFlags(itemId0), 0);
        assertEq(mixItemStoreIpfsSha256.getOwner(itemId0), address(this));
        assertTrue(!mixItemStoreIpfsSha256.getUpdatable(itemId0));
        assertTrue(!mixItemStoreIpfsSha256.getEnforceRevisions(itemId0));
        assertTrue(!mixItemStoreIpfsSha256.getRetractable(itemId0));
        assertTrue(!mixItemStoreIpfsSha256.getTransferable(itemId0));
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId0, 0), hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId0, 0), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId0), 1);

        bytes32 itemId1 = mixItemStoreIpfsSha256.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(hex"0001"), hex"1234");
        assertTrue(mixItemStoreIpfsSha256.getInUse(itemId1));
        assertEq(mixItemStoreIpfsSha256.getFlags(itemId1), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(mixItemStoreIpfsSha256.getOwner(itemId1), address(0));
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId1), 1);
        assertTrue(mixItemStoreIpfsSha256.getUpdatable(itemId1));
        assertTrue(mixItemStoreIpfsSha256.getEnforceRevisions(itemId1));
        assertTrue(mixItemStoreIpfsSha256.getRetractable(itemId1));
        assertTrue(mixItemStoreIpfsSha256.getTransferable(itemId1));
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId1, 0), hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId1, 0), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId1), 1);

        bytes32 itemId2 = mixItemStoreIpfsSha256.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(hex"0002"), hex"2345");
        assertTrue(mixItemStoreIpfsSha256.getInUse(itemId2));
        assertEq(mixItemStoreIpfsSha256.getFlags(itemId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(mixItemStoreIpfsSha256.getOwner(itemId2), address(0));
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId2), 1);
        assertTrue(mixItemStoreIpfsSha256.getUpdatable(itemId2));
        assertTrue(mixItemStoreIpfsSha256.getEnforceRevisions(itemId2));
        assertTrue(mixItemStoreIpfsSha256.getRetractable(itemId2));
        assertTrue(mixItemStoreIpfsSha256.getTransferable(itemId2));
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId2, 0), hex"2345");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId2, 0), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId2), 1);

        assertTrue(itemId0 != itemId1);
        assertTrue(itemId0 != itemId2);
        assertTrue(itemId1 != itemId2);
    }

    function testControlCreateNewRevisionNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
    }

    function testFailCreateNewRevisionNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.createNewRevision(itemId, hex"2345");
    }

    function testControlCreateNewRevisionNotUpdatable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
    }

    function testFailCreateNewRevisionNotUpdatable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(0, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
    }

    function testCreateNewRevision() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"00");
        uint revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"01");
        assertEq(revisionId, 1);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"02");
        assertEq(revisionId, 2);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"03");
        assertEq(revisionId, 3);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"04");
        assertEq(revisionId, 4);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"05");
        assertEq(revisionId, 5);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"06");
        assertEq(revisionId, 6);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"07");
        assertEq(revisionId, 7);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"08");
        assertEq(revisionId, 8);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"09");
        assertEq(revisionId, 9);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"10");
        assertEq(revisionId, 10);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"11");
        assertEq(revisionId, 11);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"12");
        assertEq(revisionId, 12);
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, hex"13");
        assertEq(revisionId, 13);
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 14);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"00");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 1), hex"01");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 2), hex"02");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 3), hex"03");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 4), hex"04");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 5), hex"05");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 6), hex"06");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 7), hex"07");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 8), hex"08");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 9), hex"09");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 10), hex"10");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 11), hex"11");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 12), hex"12");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 13), hex"13");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 1), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 2), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 3), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 4), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 5), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 6), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 7), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 8), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 9), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 10), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 11), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 12), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 13), 0);
    }

    function testControlUpdateLatestRevisionNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.updateLatestRevision(itemId, hex"2345");
    }

    function testFailUpdateLatestRevisionNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.updateLatestRevision(itemId, hex"2345");
    }

    function testControlUpdateLatestRevisionNotUpdatable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.updateLatestRevision(itemId, hex"2345");
    }

    function testFailUpdateLatestRevisionNotUpdatable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(0, hex"1234");
        mixItemStoreIpfsSha256.updateLatestRevision(itemId, hex"2345");
    }

    function testControlUpdateLatestRevisionEnforceRevisions() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.updateLatestRevision(itemId, hex"2345");
    }

    function testFailUpdateLatestRevisionEnforceRevisions() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE | ENFORCE_REVISIONS, hex"1234");
        mixItemStoreIpfsSha256.updateLatestRevision(itemId, hex"2345");
    }

    function testUpdateLatestRevision() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 1);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
        mixItemStoreIpfsSha256.updateLatestRevision(itemId, hex"2345");
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 1);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"2345");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
    }

    function testControlRetractLatestRevisionNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
        mixItemStoreIpfsSha256.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
        mixItemStoreIpfsSha256Proxy.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionNotUpdatable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
        mixItemStoreIpfsSha256.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionNotUpdatable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
        mixItemStoreIpfsSha256.setNotUpdatable(itemId);
        mixItemStoreIpfsSha256.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionEnforceRevisions() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
        mixItemStoreIpfsSha256.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionEnforceRevisions() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE | ENFORCE_REVISIONS, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
        mixItemStoreIpfsSha256.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionDoesntHaveAdditionalRevisions() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
        mixItemStoreIpfsSha256.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionDoesntHaveAdditionalRevisions() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.retractLatestRevision(itemId);
    }

    function testRetractLatestRevision() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"3456");
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 3);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 1), hex"2345");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 2), hex"3456");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 1), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 2), 0);
        mixItemStoreIpfsSha256.retractLatestRevision(itemId);
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 2);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 1), hex"2345");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 1), 0);
        mixItemStoreIpfsSha256.retractLatestRevision(itemId);
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 1);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
    }

    function testControlRestartNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.restart(itemId, hex"2345");
    }

    function testFailRestartNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.restart(itemId, hex"2345");
    }

    function testControlRestartNotUpdatable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.restart(itemId, hex"2345");
    }

    function testFailRestartNotUpdatable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(0, hex"1234");
        mixItemStoreIpfsSha256.restart(itemId, hex"2345");
    }

    function testControlRestartEnforceRevisions() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.restart(itemId, hex"2345");
    }

    function testFailRestartEnforceRevisions() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE | ENFORCE_REVISIONS, hex"1234");
        mixItemStoreIpfsSha256.restart(itemId, hex"2345");
    }

    function testRestart() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"2345");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"3456");
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 3);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 1), hex"2345");
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 2), hex"3456");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 1), 0);
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 2), 0);
        mixItemStoreIpfsSha256.restart(itemId, hex"4567");
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 1);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"4567");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
    }

    function testControlRetractNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(RETRACTABLE, hex"1234");
        mixItemStoreIpfsSha256.retract(itemId);
    }

    function testFailRetractNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(RETRACTABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.retract(itemId);
    }

    function testControlRetractNotRetractable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(RETRACTABLE, hex"1234");
        mixItemStoreIpfsSha256.retract(itemId);
    }

    function testFailRetractNotRetractable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(0, hex"1234");
        mixItemStoreIpfsSha256.retract(itemId);
    }

    function testRetract() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(RETRACTABLE, hex"1234");
        assertTrue(mixItemStoreIpfsSha256.getInUse(itemId));
        assertEq(mixItemStoreIpfsSha256.getOwner(itemId), address(this));
        assertTrue(!mixItemStoreIpfsSha256.getUpdatable(itemId));
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 1);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
        mixItemStoreIpfsSha256.retract(itemId);
        assertTrue(mixItemStoreIpfsSha256.getInUse(itemId));
        assertEq(mixItemStoreIpfsSha256.getOwner(itemId), address(0));
        assertTrue(!mixItemStoreIpfsSha256.getUpdatable(itemId));
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 0);
    }

    function testControlTransferEnableNotTransferable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.transferEnable(itemId);
    }

    function testFailTransferEnableNotTransferable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(0, hex"1234");
        mixItemStoreIpfsSha256Proxy.transferEnable(itemId);
    }

    function testControlTransferDisableNotEnabled() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.transferEnable(itemId);
        mixItemStoreIpfsSha256Proxy.transferDisable(itemId);
    }

    function testFailTransferDisableNotEnabled() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.transferDisable(itemId);
    }

    function testControlTransferNotTransferable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.transferEnable(itemId);
        mixItemStoreIpfsSha256.transfer(itemId, address(mixItemStoreIpfsSha256Proxy));
    }

    function testFailTransferNotTransferable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(0, hex"1234");
        mixItemStoreIpfsSha256Proxy.transferEnable(itemId);
        mixItemStoreIpfsSha256.transfer(itemId, address(mixItemStoreIpfsSha256Proxy));
    }

    function testControlTransferNotEnabled() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.transferEnable(itemId);
        mixItemStoreIpfsSha256.transfer(itemId, address(mixItemStoreIpfsSha256Proxy));
    }

    function testFailTransferNotEnabled() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256.transfer(itemId, address(mixItemStoreIpfsSha256Proxy));
    }

    function testControlTransferDisabled() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.transferEnable(itemId);
        mixItemStoreIpfsSha256.transfer(itemId, address(mixItemStoreIpfsSha256Proxy));
    }

    function testFailTransferDisabled() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.transferEnable(itemId);
        mixItemStoreIpfsSha256Proxy.transferDisable(itemId);
        mixItemStoreIpfsSha256.transfer(itemId, address(mixItemStoreIpfsSha256Proxy));
    }

    function testTransfer() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        assertEq(mixItemStoreIpfsSha256.getOwner(itemId), address(this));
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 1);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
        mixItemStoreIpfsSha256Proxy.transferEnable(itemId);
        mixItemStoreIpfsSha256.transfer(itemId, address(mixItemStoreIpfsSha256Proxy));
        assertEq(mixItemStoreIpfsSha256.getOwner(itemId), address(mixItemStoreIpfsSha256Proxy));
        assertEq(mixItemStoreIpfsSha256.getRevisionCount(itemId), 1);
        assertEq(mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, 0), hex"1234");
        assertEq(mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, 0), 0);
    }

    function testControlDisownNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256.disown(itemId);
    }

    function testFailDisownNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.disown(itemId);
    }

    function testControlDisownNotTransferable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256.disown(itemId);
    }

    function testFailDisownNotTransferable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(0, hex"1234");
        mixItemStoreIpfsSha256.disown(itemId);
    }

    function testDisown() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        assertEq(mixItemStoreIpfsSha256.getOwner(itemId), address(this));
        mixItemStoreIpfsSha256.disown(itemId);
        assertEq(mixItemStoreIpfsSha256.getOwner(itemId), address(0));
    }

    function testControlSetNotUpdatableNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256.setNotUpdatable(itemId);
    }

    function testFailSetNotUpdatableNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.setNotUpdatable(itemId);
    }

    function testSetNotUpdatable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"1234");
        assertTrue(mixItemStoreIpfsSha256.getUpdatable(itemId));
        mixItemStoreIpfsSha256.setNotUpdatable(itemId);
        assertTrue(!mixItemStoreIpfsSha256.getUpdatable(itemId));
    }

    function testControlSetEnforceRevisionsNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(0, hex"1234");
        mixItemStoreIpfsSha256.setEnforceRevisions(itemId);
    }

    function testFailSetEnforceRevisionsNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(0, hex"1234");
        mixItemStoreIpfsSha256Proxy.setEnforceRevisions(itemId);
    }

    function testSetEnforceRevisions() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(0, hex"1234");
        assertTrue(!mixItemStoreIpfsSha256.getEnforceRevisions(itemId));
        mixItemStoreIpfsSha256.setEnforceRevisions(itemId);
        assertTrue(mixItemStoreIpfsSha256.getEnforceRevisions(itemId));
    }

    function testControlSetNotRetractableNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(RETRACTABLE, hex"1234");
        mixItemStoreIpfsSha256.setNotRetractable(itemId);
    }

    function testFailSetNotRetractableNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(RETRACTABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.setNotRetractable(itemId);
    }

    function testSetNotRetractable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(RETRACTABLE, hex"1234");
        assertTrue(mixItemStoreIpfsSha256.getRetractable(itemId));
        mixItemStoreIpfsSha256.setNotRetractable(itemId);
        assertTrue(!mixItemStoreIpfsSha256.getRetractable(itemId));
    }

    function testControlSetNotTransferableNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256.setNotTransferable(itemId);
    }

    function testFailSetNotTransferableNotOwner() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        mixItemStoreIpfsSha256Proxy.setNotTransferable(itemId);
    }

    function testSetNotTransferable() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(TRANSFERABLE, hex"1234");
        assertTrue(mixItemStoreIpfsSha256.getTransferable(itemId));
        mixItemStoreIpfsSha256.setNotTransferable(itemId);
        assertTrue(!mixItemStoreIpfsSha256.getTransferable(itemId));
    }

    function testGetAbiVersion() public {
        assertEq(mixItemStoreIpfsSha256.getAbiVersion(), 0);
    }

    function testMultipleGetters() public {
        bytes32 itemId = mixItemStoreIpfsSha256.create(UPDATABLE, hex"00");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"01");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"02");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"03");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"04");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"05");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"06");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"07");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"08");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"09");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"10");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"11");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"12");
        mixItemStoreIpfsSha256.createNewRevision(itemId, hex"13");

        (byte flags, address owner, uint[] memory timestamps, bytes32[] memory ipfsHashes) = mixItemStoreIpfsSha256.getItem(itemId);

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

        timestamps = mixItemStoreIpfsSha256.getAllRevisionTimestamps(itemId);

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

        ipfsHashes = mixItemStoreIpfsSha256.getAllRevisionIpfsHashes(itemId);

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
