pragma solidity ^0.5.10;

import "ds-test/test.sol";

import "./ItemStoreRegistry.sol";
import "./ItemStoreIpfsSha256.sol";


/**
 * @title ItemStoreRegistryTest
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for ItemStoreRegistry.
 */
contract ItemStoreRegistryTest is DSTest {

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
    }

    function testControlRegisterContractIdAgain() public {
        itemStoreRegistry.register();
    }

    function testFailRegisterContractIdAgain() public {
        itemStoreRegistry.register();
        itemStoreRegistry.register();
    }

    function testControlItemStoreNotRegistered() public view {
        itemStoreRegistry.getItemStore(bytes32(itemStore.getContractId()) >> 192);
    }

    function testFailItemStoreNotRegistered() public view {
        itemStoreRegistry.getItemStore(0);
    }

    function testGetItemStore() public {
        assertEq(address(itemStoreRegistry.getItemStore(bytes32(itemStore.getContractId()) >> 192)), address(itemStore));
    }

}
