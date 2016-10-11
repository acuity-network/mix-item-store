pragma solidity ^0.4.0;

import "abstract_blobstore.sol";

/**
 * @title BlobStoreRegistry
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStoreRegistry {

    /**
     * @dev Mapping of contract id to contract addresses.
     */
    mapping (bytes12 => address) contractAddresses;

    /**
     * @dev An AbstractBlobStore contract has been registered.
     * @param contractId Id of the contract.
     * @param contractAddress Address of the contract.
     */
    event logRegistration(bytes12 indexed contractId, address indexed contractAddress);

    /**
     * @dev Throw if contract is registered.
     * @param contractId Id of the contract.
     */
    modifier isNotRegistered(bytes12 contractId) {
        if (contractAddresses[contractId] != 0) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if contract is not registered.
     * @param contractId Id of the contract.
     */
    modifier isRegistered(bytes12 contractId) {
        if (contractAddresses[contractId] == 0) {
            throw;
        }
        _;
    }

    /**
     * @dev Register the calling BlobStore contract.
     * @param contractId Id of the BlobStore contract.
     */
    function register(bytes12 contractId) isNotRegistered(contractId) external {
        // Record the calling contract address.
        contractAddresses[contractId] = msg.sender;
        // Log the registration.
        logRegistration(contractId, msg.sender);
    }

    /**
     * @dev Get an AbstractBlobStore contract.
     * @param contractId Id of the contract.
     * @return blobStore The AbstractBlobStore contract.
     */
    function getBlobStore(bytes12 contractId) isRegistered(contractId) constant external returns (AbstractBlobStore blobStore) {
        blobStore = AbstractBlobStore(contractAddresses[contractId]);
    }

}
