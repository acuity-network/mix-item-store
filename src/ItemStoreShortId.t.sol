pragma solidity ^0.5.9;

import "ds-test/test.sol";

import "./ItemStoreShortId.sol";


/**
 * @title ItemStoreShortIdTest
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for ItemStoreShortId.
 */
contract ItemStoreShortIdTest is DSTest {

    ItemStoreShortId itemStoreShortId;

    function setUp() public {
        itemStoreShortId = new ItemStoreShortId();
    }

    function testControlCreateShortIdAlreadyExists() public {
        itemStoreShortId.createShortId(hex"1234");
        itemStoreShortId.createShortId(hex"2345");
    }

    function testFailCreateShortIdAlreadyExists() public {
        itemStoreShortId.createShortId(hex"1234");
        itemStoreShortId.createShortId(hex"1234");
    }

    function testCreateShortId() public {
        bytes32 itemId0 = hex"1234";
        bytes32 itemId1 = hex"2345";
        bytes32 itemId2 = hex"3456";
        bytes32 itemId3 = hex"4567";

        bytes4 shortId0 = itemStoreShortId.createShortId(itemId0);
        bytes4 shortId1 = itemStoreShortId.createShortId(itemId1);
        bytes4 shortId2 = itemStoreShortId.createShortId(itemId2);
        bytes4 shortId3 = itemStoreShortId.createShortId(itemId3);

        assertTrue(shortId0 != shortId1);
        assertTrue(shortId0 != shortId2);
        assertTrue(shortId0 != shortId3);

        assertTrue(shortId1 != shortId2);
        assertTrue(shortId1 != shortId3);

        assertTrue(shortId2 != shortId3);

        assertEq(itemStoreShortId.getItemId(shortId0), itemId0);
        assertEq(itemStoreShortId.getShortId(itemId0), shortId0);

        assertEq(itemStoreShortId.getItemId(shortId1), itemId1);
        assertEq(itemStoreShortId.getShortId(itemId1), shortId1);

        assertEq(itemStoreShortId.getItemId(shortId2), itemId2);
        assertEq(itemStoreShortId.getShortId(itemId2), shortId2);

        assertEq(itemStoreShortId.getItemId(shortId3), itemId3);
        assertEq(itemStoreShortId.getShortId(itemId3), shortId3);
    }

}
