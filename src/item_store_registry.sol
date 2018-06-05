pragma solidity ^0.4.24;

import "./item_store_interface.sol";


/**
 * @title ItemStoreRegistry
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Contract that every ItemStore implementation must register with.
 */
contract ItemStoreRegistry {

    /**
     * @dev Mapping of contractIds to contract addresses.
     */
    mapping (bytes32 => ItemStoreInterface) contracts;

    /**
     * @dev A ItemStore contract has been registered.
     * @param contractId Id of the contract.
     * @param contractAddress Address of the contract.
     */
    event Register(bytes8 indexed contractId, ItemStoreInterface indexed contractAddress);

    /**
     * @dev Register the calling ItemStore contract.
     * @return contractId Id of the ItemStore contract.
     */
    function register() external returns (bytes32 contractId) {
        // Create contractId.
        contractId = keccak256(abi.encodePacked(msg.sender)) & bytes32(uint64(-1));
        // Make sure this contractId has not been used before (highly unlikely).
        require (contracts[contractId] == ItemStoreInterface(0));
        // Record the calling contract address.
        contracts[contractId] = ItemStoreInterface(msg.sender);
        // Log the registration.
        emit Register(bytes8(contractId << 192), ItemStoreInterface(msg.sender));
    }

    /**
     * @dev Lookup the itemStore contract for an item.
     * @param itemId itemId of the item to determine the itemStore contract of.
     * @return itemStore itemStore contract of the item.
     */
    function getItemStore(bytes32 itemId) external view returns (ItemStoreInterface itemStore) {
        itemStore = contracts[itemId & bytes32(uint64(-1))];
        require (address(itemStore) != 0);
    }

}
