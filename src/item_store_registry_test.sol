pragma solidity ^0.4.17;

import "ds-test/test.sol";

import "./item_store_registry.sol";
import "./item_store_ipfs_sha256.sol";


/**
 * @title ItemStoreRegistryTest
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for ItemStoreRegistry.
 */
contract ItemStoreRegistryTest is DSTest {

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;

    function setUp() {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
    }

    function testControlRegisterContractAgain() {
        itemStoreRegistry.register(~itemStore.getContractId());
    }

    function testFailRegisterContractAgain() {
        itemStoreRegistry.register(itemStore.getContractId());
    }

    function testControlItemStoreNotRegistered() {
        itemStoreRegistry.getItemStore(itemStore.getContractId());
    }

    function testFailItemStoreNotRegistered() {
        itemStoreRegistry.getItemStore(0);
    }

    function testGetItemStore() {
        assertEq(itemStoreRegistry.getItemStore(itemStore.getContractId()), itemStore);
    }

}
