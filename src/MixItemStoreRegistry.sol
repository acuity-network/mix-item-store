pragma solidity ^0.6.6;

import "./MixItemStoreConstants.sol";
import "./MixItemStoreInterface.sol";


/**
 * @title MixItemStoreRegistry
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Maintains a registry of MixItemStoreInterface contracts.
 */
contract MixItemStoreRegistry is MixItemStoreConstants {

    /**
     * @dev Mapping of contractIds to contract addresses.
     */
    mapping (bytes32 => MixItemStoreInterface) contracts;

    /**
     * @dev A MixItemStoreInterface contract has been registered.
     * @param contractId Id of the contract.
     * @param contractAddress Address of the contract.
     */
    event Register(bytes8 indexed contractId, MixItemStoreInterface indexed contractAddress);

    /**
     * @dev Register the calling MixItemStoreInterface contract.
     * @return contractId Id of the MixItemStoreInterface contract.
     */
    function register() external returns (bytes32 contractId) {
        // Create contractId.
        contractId = keccak256(abi.encodePacked(msg.sender)) & CONTRACT_ID_MASK;
        // Make sure this contractId has not been used before (highly unlikely).
        require (contracts[contractId] == MixItemStoreInterface(0), "contractId already exists.");
        // Record the calling contract address.
        contracts[contractId] = MixItemStoreInterface(msg.sender);
        // Log the registration.
        emit Register(bytes8(contractId << 192), MixItemStoreInterface(msg.sender));
    }

    /**
     * @dev Lookup the itemStore contract for an item.
     * @param itemId itemId of the item to determine the itemStore contract of.
     * @return itemStore itemStore contract of the item.
     */
    function getItemStore(bytes32 itemId) external view returns (MixItemStoreInterface itemStore) {
        itemStore = contracts[itemId & CONTRACT_ID_MASK];
        require (address(itemStore) != address(0), "itemId does not have an itemStore contract.");
    }

}
