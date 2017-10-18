pragma solidity ^0.4.17;

import "./item_store_interface.sol";


/**
 * @title ItemStoreRegistry
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Contract that every ItemStore implementation must register with.
 */
contract ItemStoreRegistry {

    /**
     * @dev Mapping of contract id to contract addresses.
     */
    mapping (bytes12 => ItemStoreInterface) contracts;

    /**
     * @dev A ItemStore contract has been registered.
     * @param contractId Id of the contract.
     * @param contractAddress Address of the contract.
     */
    event Register(bytes12 indexed contractId, ItemStoreInterface indexed contractAddress);

    /**
     * @dev Throw if contract is registered.
     * @param contractId Id of the contract.
     */
    modifier isNotRegistered(bytes12 contractId) {
        require (address(contracts[contractId]) == 0);
        _;
    }

    /**
     * @dev Throw if contract is not registered.
     * @param contractId Id of the contract.
     */
    modifier isRegistered(bytes12 contractId) {
        require (address(contracts[contractId]) != 0);
        _;
    }

    /**
     * @dev Register the calling ItemStore contract.
     * @param contractId Id of the ItemStore contract.
     */
    function register(bytes12 contractId) external isNotRegistered(contractId) {
        // Record the calling contract address.
        contracts[contractId] = ItemStoreInterface(msg.sender);
        // Log the registration.
        Register(contractId, ItemStoreInterface(msg.sender));
    }

    /**
     * @dev Get a ItemStore contract.
     * @param contractId Id of the contract.
     * @return The ItemStore contract.
     */
    function getItemStore(bytes12 contractId) external view isRegistered(contractId) returns (ItemStoreInterface) {
        return contracts[contractId];
    }

}
