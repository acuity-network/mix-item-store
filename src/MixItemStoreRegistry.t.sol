pragma solidity ^0.6.6;

import "ds-test/test.sol";

import "./MixItemStoreRegistry.sol";
import "./MixItemStoreIpfsSha256.sol";


contract MixItemStoreRegistryTest is DSTest {

    MixItemStoreRegistry mixItemStoreRegistry;
    MixItemStoreIpfsSha256 mixItemStoreIpfsSha256;

    function setUp() public {
        mixItemStoreRegistry = new MixItemStoreRegistry();
        mixItemStoreIpfsSha256 = new MixItemStoreIpfsSha256(mixItemStoreRegistry);
    }

    function testControlRegisterContractIdAgain() public {
        mixItemStoreRegistry.register();
    }

    function testFailRegisterContractIdAgain() public {
        mixItemStoreRegistry.register();
        mixItemStoreRegistry.register();
    }

    function testControlMixItemStoreNotRegistered() public view {
        mixItemStoreRegistry.getItemStore(bytes32(mixItemStoreIpfsSha256.getContractId()) >> 192);
    }

    function testFailMixItemStoreNotRegistered() public view {
        mixItemStoreRegistry.getItemStore(0);
    }

    function testGetItemStore() public {
        assertEq(address(mixItemStoreRegistry.getItemStore(bytes32(mixItemStoreIpfsSha256.getContractId()) >> 192)), address(mixItemStoreIpfsSha256));
    }

}
