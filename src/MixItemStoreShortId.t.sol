pragma solidity ^0.6.6;

import "ds-test/test.sol";

import "./MixItemStoreShortId.sol";


contract MixItemStoreShortIdTest is DSTest {

    MixItemStoreShortId mixItemStoreShortId;

    function setUp() public {
        mixItemStoreShortId = new MixItemStoreShortId();
    }

    function testControlCreateShortIdAlreadyExists() public {
        mixItemStoreShortId.createShortId(hex"1234");
        mixItemStoreShortId.createShortId(hex"2345");
    }

    function testFailCreateShortIdAlreadyExists() public {
        mixItemStoreShortId.createShortId(hex"1234");
        mixItemStoreShortId.createShortId(hex"1234");
    }

    function testCreateShortId() public {
        bytes32 itemId0 = hex"1234";
        bytes32 itemId1 = hex"2345";
        bytes32 itemId2 = hex"3456";
        bytes32 itemId3 = hex"4567";

        bytes4 shortId0 = mixItemStoreShortId.createShortId(itemId0);
        bytes4 shortId1 = mixItemStoreShortId.createShortId(itemId1);
        bytes4 shortId2 = mixItemStoreShortId.createShortId(itemId2);
        bytes4 shortId3 = mixItemStoreShortId.createShortId(itemId3);

        assertTrue(shortId0 != shortId1);
        assertTrue(shortId0 != shortId2);
        assertTrue(shortId0 != shortId3);

        assertTrue(shortId1 != shortId2);
        assertTrue(shortId1 != shortId3);

        assertTrue(shortId2 != shortId3);

        assertEq(mixItemStoreShortId.getItemId(shortId0), itemId0);
        assertEq(mixItemStoreShortId.getShortId(itemId0), shortId0);

        assertEq(mixItemStoreShortId.getItemId(shortId1), itemId1);
        assertEq(mixItemStoreShortId.getShortId(itemId1), shortId1);

        assertEq(mixItemStoreShortId.getItemId(shortId2), itemId2);
        assertEq(mixItemStoreShortId.getShortId(itemId2), shortId2);

        assertEq(mixItemStoreShortId.getItemId(shortId3), itemId3);
        assertEq(mixItemStoreShortId.getShortId(itemId3), shortId3);
    }

}
