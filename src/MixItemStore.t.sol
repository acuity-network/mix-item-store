pragma solidity ^0.4.17;

import "ds-test/test.sol";

import "./MixItemStore.sol";

contract MixItemStoreTest is DSTest {
    MixItemStore store;

    function setUp() {
        store = new MixItemStore();
    }

    function testFail_basic_sanity() {
        assertTrue(false);
    }

    function test_basic_sanity() {
        assertTrue(true);
    }
}
