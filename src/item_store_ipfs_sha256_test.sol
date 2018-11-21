pragma solidity ^0.5.0;

import "ds-test/test.sol";

import "./item_store_registry.sol";
import "./item_store_constants.sol";
import "./item_store_ipfs_sha256.sol";
import "./item_store_ipfs_sha256_proxy.sol";


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
        itemStore.getNewItemId(hex"2345");
    }

    function testFailCreateSameItemId() public {
        itemStore.create(hex"1234", hex"1234");
        itemStore.getNewItemId(hex"1234");
    }

    function testGetNewItemId() public {
        assertEq((itemStore.getNewItemId(hex"1234") & CONTRACT_ID_MASK) << 192, itemStore.getContractId());
        assertEq(itemStore.getNewItemId(hex"1234"), itemStore.getNewItemId(hex"1234"));
        assertTrue(itemStore.getNewItemId(hex"1234") != itemStore.getNewItemId(hex"2345"));
        assertTrue(itemStore.getNewItemId(hex"1234") != itemStoreProxy.getNewItemId(hex"1234"));
    }

    function testCreate() public {
        bytes32 itemId0 = itemStore.create(hex"0000", hex"1234");
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), address(this));
        assertEq(itemStore.getChildCount(itemId0), 0);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), 0);
        assertEq(itemStore.getParentCount(itemId0), 0);
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
        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getRevisionCount(itemId1), 1);

        bytes32 itemId2 = itemStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(hex"0002"), hex"2345");
        assertTrue(itemStore.getInUse(itemId2));
        assertEq(itemStore.getFlags(itemId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId2), address(0));
        assertEq(itemStore.getChildCount(itemId2), 0);
        assertEq(itemStore.getRevisionCount(itemId2), 1);
        assertTrue(itemStore.getUpdatable(itemId2));
        assertTrue(itemStore.getEnforceRevisions(itemId2));
        assertTrue(itemStore.getRetractable(itemId2));
        assertTrue(itemStore.getTransferable(itemId2));
        assertEq(itemStore.getRevisionIpfsHash(itemId2, 0), hex"2345");
        assertEq(itemStore.getRevisionTimestamp(itemId2, 0), 0);
        assertEq(itemStore.getParentCount(itemId2), 0);
        assertEq(itemStore.getRevisionCount(itemId2), 1);

        assertTrue(itemId0 != itemId1);
        assertTrue(itemId0 != itemId2);
        assertTrue(itemId1 != itemId2);
    }

    function testControlCreateWithParentSameItemId() public {
        itemStore.create(hex"0000", hex"1234");
        bytes32 parent = itemStore.create(hex"0001", hex"1234");
        itemStore.createWithParent(hex"0002", hex"1234", parent);
    }

    function testFailCreateWithParentSameItemId() public {
        itemStore.create(hex"0000", hex"1234");
        bytes32 parent = itemStore.create(hex"0001", hex"1234");
        itemStore.createWithParent(hex"0000", hex"1234", parent);
    }

    function testControlCreateWithParentParentSameItemId() public {
        bytes32 parent = itemStore.create(hex"0000", hex"1234");
        itemStore.createWithParent(hex"0001", hex"1234", parent);
    }

    function testFailCreateWithParentParentSameItemId() public {
        itemStore.createWithParent(hex"0001", hex"1234", hex"27f0627239c077bd4a85416f92f30529ad279852466bfc94c449a2ef0a72f358");
    }

    function testControlCreateWithParentParentNotInUse() public {
        bytes32 parent = itemStore.create(hex"0000", hex"1234");
        itemStore.createWithParent(hex"0001", hex"1234", parent);
    }

    function testFailCreateWithParentParentNotInUse() public {
        itemStore.createWithParent(hex"0001", hex"1234", itemStore.getContractId());
    }

    function testCreateWithParent() public {
        bytes32 itemId0 = itemStore.create(hex"0000", hex"1234");
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), address(this));
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), 0);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 0);

        bytes32 itemId1 = itemStore.createWithParent(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(hex"0001"), hex"1234", itemId0);
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
        assertEq(itemStore.getParentCount(itemId1), 1);
        assertEq(itemStore.getParentId(itemId1, 0), itemId0);
        assertEq(itemStore.getChildCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId0), 1);
        assertEq(itemStore.getChildId(itemId0, 0), itemId1);

        bytes32 itemId2 = itemStore.createWithParent(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(hex"0002"), hex"2345", itemId0);
        assertTrue(itemStore.getInUse(itemId2));
        assertEq(itemStore.getFlags(itemId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId2), address(0));
        assertEq(itemStore.getChildCount(itemId2), 0);
        assertEq(itemStore.getRevisionCount(itemId2), 1);
        assertTrue(itemStore.getUpdatable(itemId2));
        assertTrue(itemStore.getEnforceRevisions(itemId2));
        assertTrue(itemStore.getRetractable(itemId2));
        assertTrue(itemStore.getTransferable(itemId2));
        assertEq(itemStore.getRevisionIpfsHash(itemId2, 0), hex"2345");
        assertEq(itemStore.getRevisionTimestamp(itemId2, 0), 0);
        assertEq(itemStore.getParentCount(itemId2), 1);
        assertEq(itemStore.getParentId(itemId2, 0), itemId0);
        assertEq(itemStore.getChildCount(itemId2), 0);
        assertEq(itemStore.getChildCount(itemId0), 2);
        assertEq(itemStore.getChildId(itemId0, 1), itemId2);

        assertTrue(itemId0 != itemId1);
        assertTrue(itemId0 != itemId2);
        assertTrue(itemId1 != itemId2);
    }

    function testControlCreateWithParentForeignNotInUse() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32 parent = itemStore2.create(hex"0000", hex"1234");
        itemStore.createWithParent(hex"0001", hex"1234", parent);
    }

    function testFailCreateWithParentForeignNotInUse() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        itemStore.createWithParent(hex"0000", hex"1234", itemStore2.getContractId());
    }

    function testCreateWithParentForeign() public {
        bytes32 itemId0 = itemStore.create(hex"0000", hex"1234");
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), address(this));
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), 0);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 0);

        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32 itemId1 = itemStore2.createWithParent(hex"0000", hex"1234", itemId0);
        assertTrue(itemStore2.getInUse(itemId1));
        assertEq(itemStore2.getFlags(itemId1), 0);
        assertEq(itemStore2.getOwner(itemId1), address(this));
        assertEq(itemStore2.getRevisionCount(itemId1), 1);
        assertTrue(!itemStore2.getUpdatable(itemId1));
        assertTrue(!itemStore2.getEnforceRevisions(itemId1));
        assertTrue(!itemStore2.getRetractable(itemId1));
        assertTrue(!itemStore2.getTransferable(itemId1));
        assertEq(itemStore2.getRevisionIpfsHash(itemId1, 0), hex"1234");
        assertEq(itemStore2.getRevisionTimestamp(itemId1, 0), 0);
        assertEq(itemStore2.getParentCount(itemId1), 1);
        assertEq(itemStore2.getParentId(itemId1, 0), itemId0);
        assertEq(itemStore2.getChildCount(itemId1), 0);

        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 1);
        assertEq(itemStore.getChildId(itemId0, 0), itemId1);
    }

    function testControlCreateWithParentsSameItemId() public {
        itemStore.create(hex"0000", hex"1234");
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(hex"0001", hex"1234");
        parents[1] = itemStore.create(hex"0002", hex"1234");
        itemStore.createWithParents(hex"0003", hex"1234", parents);
    }

    function testFailCreateWithParentsSameItemId() public {
        itemStore.create(hex"0000", hex"1234");
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(hex"0001", hex"1234");
        parents[1] = itemStore.create(hex"0002", hex"1234");
        itemStore.createWithParents(hex"0000", hex"1234", parents);
    }

    function testControlCreateWithParentsParentSameItemId() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(hex"0000", hex"1234");
        parents[1] = itemStore.create(hex"0001", hex"1234");
        itemStore.createWithParents(hex"0002", hex"1234", parents);
    }

    function testFailCreateWithParentsParentSameItemId0() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = hex"27f0627239c077bd4a85416f92f30529ad279852466bfc94c449a2ef0a72f358";
        parents[1] = itemStore.create(hex"0002", hex"1234");
        itemStore.createWithParents(hex"0001", hex"1234", parents);
    }

    function testFailCreateWithParentsParentSameItemId1() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(hex"0002", hex"1234");
        parents[1] = hex"27f0627239c077bd4a85416f92f30529ad279852466bfc94c449a2ef0a72f358";
        itemStore.createWithParents(hex"0001", hex"1234", parents);
    }

    function testControlCreateWithParentsParentNotInUse() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(hex"0000", hex"1234");
        parents[1] = itemStore.create(hex"0001", hex"1234");
        itemStore.createWithParents(hex"0002", hex"1234", parents);
    }

    function testFailCreateWithParentsParentNotInUse0() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.getContractId();
        parents[1] = itemStore.create(hex"0001", hex"1234");
        itemStore.createWithParents(hex"0002", hex"1234", parents);
    }

    function testFailCreateWithParentsParentNotInUse1() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(hex"0000", hex"1234");
        parents[1] = itemStore.getContractId();
        itemStore.createWithParents(hex"0002", hex"1234", parents);
    }

    function testCreateWithParents() public {
        bytes32 itemId0 = itemStore.create(hex"0000", hex"1234");
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), address(this));
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), 0);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 0);

        bytes32 itemId1 = itemStore.create(hex"0001", hex"1234");
        assertTrue(itemStore.getInUse(itemId1));
        assertEq(itemStore.getFlags(itemId1), 0);
        assertEq(itemStore.getOwner(itemId1), address(this));
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assertTrue(!itemStore.getUpdatable(itemId1));
        assertTrue(!itemStore.getEnforceRevisions(itemId1));
        assertTrue(!itemStore.getRetractable(itemId1));
        assertTrue(!itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId1, 0), 0);
        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId1), 0);

        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemId0;
        parents[1] = itemId1;
        bytes32 itemId2 = itemStore.createWithParents(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(hex"0001"), hex"1234", parents);
        assertTrue(itemStore.getInUse(itemId2));
        assertEq(itemStore.getFlags(itemId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId2), address(0));
        assertEq(itemStore.getRevisionCount(itemId2), 1);
        assertTrue(itemStore.getUpdatable(itemId2));
        assertTrue(itemStore.getEnforceRevisions(itemId2));
        assertTrue(itemStore.getRetractable(itemId2));
        assertTrue(itemStore.getTransferable(itemId2));
        assertEq(itemStore.getRevisionIpfsHash(itemId2, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId2, 0), 0);
        assertEq(itemStore.getParentCount(itemId2), 2);
        assertEq(itemStore.getParentId(itemId2, 0), itemId0);
        assertEq(itemStore.getParentId(itemId2, 1), itemId1);
        assertEq(itemStore.getChildCount(itemId0), 1);
        assertEq(itemStore.getChildCount(itemId1), 1);
        assertEq(itemStore.getChildCount(itemId2), 0);
        assertEq(itemStore.getChildId(itemId0, 0), itemId2);
        assertEq(itemStore.getChildId(itemId1, 0), itemId2);

        bytes32 itemId3 = itemStore.createWithParents(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(hex"0002"), hex"2345", parents);
        assertTrue(itemStore.getInUse(itemId3));
        assertEq(itemStore.getFlags(itemId3), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId3), address(0));
        assertEq(itemStore.getChildCount(itemId3), 0);
        assertEq(itemStore.getRevisionCount(itemId3), 1);
        assertTrue(itemStore.getUpdatable(itemId3));
        assertTrue(itemStore.getEnforceRevisions(itemId3));
        assertTrue(itemStore.getRetractable(itemId3));
        assertTrue(itemStore.getTransferable(itemId3));
        assertEq(itemStore.getRevisionIpfsHash(itemId3, 0), hex"2345");
        assertEq(itemStore.getRevisionTimestamp(itemId3, 0), 0);
        assertEq(itemStore.getParentCount(itemId3), 2);
        assertEq(itemStore.getParentId(itemId3, 0), itemId0);
        assertEq(itemStore.getParentId(itemId3, 1), itemId1);
        assertEq(itemStore.getChildCount(itemId0), 2);
        assertEq(itemStore.getChildCount(itemId1), 2);
        assertEq(itemStore.getChildCount(itemId2), 0);
        assertEq(itemStore.getChildCount(itemId3), 0);
        assertEq(itemStore.getChildId(itemId0, 0), itemId2);
        assertEq(itemStore.getChildId(itemId1, 0), itemId2);
        assertEq(itemStore.getChildId(itemId0, 1), itemId3);
        assertEq(itemStore.getChildId(itemId1, 1), itemId3);

        assertTrue(itemId0 != itemId1);
        assertTrue(itemId0 != itemId2);
        assertTrue(itemId0 != itemId3);
        assertTrue(itemId1 != itemId2);
        assertTrue(itemId1 != itemId3);
        assertTrue(itemId2 != itemId3);
    }

    function testControlCreateWithParentsForeignNotInUse() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore2.create(hex"0000", hex"1234");
        parents[1] = itemStore2.create(hex"0001", hex"1234");
        itemStore.createWithParents(hex"0002", hex"1234", parents);
    }

    function testFailCreateWithParentsForeignNotInUse0() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore2.getContractId();
        parents[1] = itemStore2.create(hex"0001", hex"1234");
        itemStore.createWithParents(hex"0002", hex"1234", parents);
    }

    function testFailCreateWithParentsForeignNotInUse1() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore2.create(hex"0000", hex"1234");
        parents[1] = itemStore2.getContractId();
        itemStore.createWithParents(hex"0002", hex"1234", parents);
    }

    function testCreateWithParentsForeign0() public {
        bytes32 itemId0 = itemStore.create(hex"0000", hex"1234");
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), address(this));
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), 0);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 0);

        bytes32 itemId1 = itemStore.create(hex"0001", hex"1234");
        assertTrue(itemStore.getInUse(itemId1));
        assertEq(itemStore.getFlags(itemId1), 0);
        assertEq(itemStore.getOwner(itemId1), address(this));
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assertTrue(!itemStore.getUpdatable(itemId1));
        assertTrue(!itemStore.getEnforceRevisions(itemId1));
        assertTrue(!itemStore.getRetractable(itemId1));
        assertTrue(!itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId1, 0), 0);
        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId1), 0);

        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemId0;
        parents[1] = itemId1;
        bytes32 itemId2 = itemStore2.createWithParents(hex"0000", hex"1234", parents);
        assertTrue(itemStore2.getInUse(itemId2));
        assertEq(itemStore2.getFlags(itemId2), 0);
        assertEq(itemStore2.getOwner(itemId2), address(this));
        assertEq(itemStore2.getRevisionCount(itemId2), 1);
        assertTrue(!itemStore2.getUpdatable(itemId2));
        assertTrue(!itemStore2.getEnforceRevisions(itemId2));
        assertTrue(!itemStore2.getRetractable(itemId2));
        assertTrue(!itemStore2.getTransferable(itemId2));
        assertEq(itemStore2.getRevisionIpfsHash(itemId2, 0), hex"1234");
        assertEq(itemStore2.getRevisionTimestamp(itemId2, 0), 0);
        assertEq(itemStore2.getParentCount(itemId2), 2);
        assertEq(itemStore2.getParentId(itemId2, 0), itemId0);
        assertEq(itemStore2.getParentId(itemId2, 1), itemId1);
        assertEq(itemStore2.getChildCount(itemId2), 0);

        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 1);
        assertEq(itemStore.getChildId(itemId0, 0), itemId2);

        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId1), 1);
        assertEq(itemStore.getChildId(itemId1, 0), itemId2);
    }

    function testCreateWithParentsForeign1() public {
        bytes32 itemId0 = itemStore.create(hex"0000", hex"1234");
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), address(this));
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), 0);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 0);

        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32 itemId1 = itemStore2.create(hex"0001", hex"1234");
        assertTrue(itemStore2.getInUse(itemId1));
        assertEq(itemStore2.getFlags(itemId1), 0);
        assertEq(itemStore2.getOwner(itemId1), address(this));
        assertEq(itemStore2.getRevisionCount(itemId1), 1);
        assertTrue(!itemStore2.getUpdatable(itemId1));
        assertTrue(!itemStore2.getEnforceRevisions(itemId1));
        assertTrue(!itemStore2.getRetractable(itemId1));
        assertTrue(!itemStore2.getTransferable(itemId1));
        assertEq(itemStore2.getRevisionIpfsHash(itemId1, 0), hex"1234");
        assertEq(itemStore2.getRevisionTimestamp(itemId1, 0), 0);
        assertEq(itemStore2.getParentCount(itemId1), 0);
        assertEq(itemStore2.getChildCount(itemId1), 0);

        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemId0;
        parents[1] = itemId1;
        bytes32 itemId2 = itemStore2.createWithParents(hex"0000", hex"1234", parents);
        assertTrue(itemStore2.getInUse(itemId2));
        assertEq(itemStore2.getFlags(itemId2), 0);
        assertEq(itemStore2.getOwner(itemId2), address(this));
        assertEq(itemStore2.getRevisionCount(itemId2), 1);
        assertTrue(!itemStore2.getUpdatable(itemId2));
        assertTrue(!itemStore2.getEnforceRevisions(itemId2));
        assertTrue(!itemStore2.getRetractable(itemId2));
        assertTrue(!itemStore2.getTransferable(itemId2));
        assertEq(itemStore2.getRevisionIpfsHash(itemId2, 0), hex"1234");
        assertEq(itemStore2.getRevisionTimestamp(itemId2, 0), 0);
        assertEq(itemStore2.getParentCount(itemId2), 2);
        assertEq(itemStore2.getParentId(itemId2, 0), itemId0);
        assertEq(itemStore2.getParentId(itemId2, 1), itemId1);
        assertEq(itemStore2.getChildCount(itemId2), 0);

        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 1);
        assertEq(itemStore.getChildId(itemId0, 0), itemId2);

        assertEq(itemStore2.getParentCount(itemId1), 0);
        assertEq(itemStore2.getChildCount(itemId1), 1);
        assertEq(itemStore2.getChildId(itemId1, 0), itemId2);
    }

    function testCreateWithParentsForeign2() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32 itemId0 = itemStore2.create(hex"0001", hex"1234");
        assertTrue(itemStore2.getInUse(itemId0));
        assertEq(itemStore2.getFlags(itemId0), 0);
        assertEq(itemStore2.getOwner(itemId0), address(this));
        assertEq(itemStore2.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore2.getUpdatable(itemId0));
        assertTrue(!itemStore2.getEnforceRevisions(itemId0));
        assertTrue(!itemStore2.getRetractable(itemId0));
        assertTrue(!itemStore2.getTransferable(itemId0));
        assertEq(itemStore2.getRevisionIpfsHash(itemId0, 0), hex"1234");
        assertEq(itemStore2.getRevisionTimestamp(itemId0, 0), 0);
        assertEq(itemStore2.getParentCount(itemId0), 0);
        assertEq(itemStore2.getChildCount(itemId0), 0);

        bytes32 itemId1 = itemStore.create(hex"0001", hex"1234");
        assertTrue(itemStore.getInUse(itemId1));
        assertEq(itemStore.getFlags(itemId1), 0);
        assertEq(itemStore.getOwner(itemId1), address(this));
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assertTrue(!itemStore.getUpdatable(itemId1));
        assertTrue(!itemStore.getEnforceRevisions(itemId1));
        assertTrue(!itemStore.getRetractable(itemId1));
        assertTrue(!itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), hex"1234");
        assertEq(itemStore.getRevisionTimestamp(itemId1, 0), 0);
        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId1), 0);

        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemId0;
        parents[1] = itemId1;
        bytes32 itemId2 = itemStore2.createWithParents(hex"0000", hex"1234", parents);
        assertTrue(itemStore2.getInUse(itemId2));
        assertEq(itemStore2.getFlags(itemId2), 0);
        assertEq(itemStore2.getOwner(itemId2), address(this));
        assertEq(itemStore2.getRevisionCount(itemId2), 1);
        assertTrue(!itemStore2.getUpdatable(itemId2));
        assertTrue(!itemStore2.getEnforceRevisions(itemId2));
        assertTrue(!itemStore2.getRetractable(itemId2));
        assertTrue(!itemStore2.getTransferable(itemId2));
        assertEq(itemStore2.getRevisionIpfsHash(itemId2, 0), hex"1234");
        assertEq(itemStore2.getRevisionTimestamp(itemId2, 0), 0);
        assertEq(itemStore2.getParentCount(itemId2), 2);
        assertEq(itemStore2.getParentId(itemId2, 0), itemId0);
        assertEq(itemStore2.getParentId(itemId2, 1), itemId1);
        assertEq(itemStore2.getChildCount(itemId2), 0);

        assertEq(itemStore2.getParentCount(itemId0), 0);
        assertEq(itemStore2.getChildCount(itemId0), 1);
        assertEq(itemStore2.getChildId(itemId0, 0), itemId2);

        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId1), 1);
        assertEq(itemStore.getChildId(itemId1, 0), itemId2);
    }

    function testFailAddForeignChildNotInUse() public {
        bytes32 itemId0 = itemStore.create(hex"0000", hex"1234");
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        itemStore.addForeignChild(itemId0, itemStore2.getContractId());
    }

    function testFailAddForeignChildNotChild() public {
        bytes32 itemId0 = itemStore.create(hex"0000", hex"1234");
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32 itemId1 = itemStore2.create(hex"0000", hex"1234");
        itemStore.addForeignChild(itemId0, itemId1);
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
        bytes32 itemId = itemStore.create(UPDATABLE, 0);
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

}
