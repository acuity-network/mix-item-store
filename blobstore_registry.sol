pragma solidity ^0.4.11;

import "./blobstore_interface.sol";


/**
 * @title BlobStoreRegistry
 * @author Jonathan Brown <jbrown@link-blockchain.org>
 * @dev Contract that every BlobStore implementation must register with.
 */
contract BlobStoreRegistry {

    /**
     * @dev Mapping of contract id to contract addresses.
     */
    mapping (bytes12 => BlobStoreInterface) contracts;

    /**
     * @dev A BlobStore contract has been registered.
     * @param contractId Id of the contract.
     * @param contractAddress Address of the contract.
     */
    event Register(bytes12 indexed contractId, BlobStoreInterface indexed contractAddress);

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
     * @dev Register the calling BlobStore contract.
     * @param contractId Id of the BlobStore contract.
     */
    function register(bytes12 contractId) external isNotRegistered(contractId) {
        // Record the calling contract address.
        contracts[contractId] = BlobStoreInterface(msg.sender);
        // Log the registration.
        Register(contractId, BlobStoreInterface(msg.sender));
    }

    /**
     * @dev Get a BlobStore contract.
     * @param contractId Id of the contract.
     * @return blobStore The BlobStore contract.
     */
    function getBlobStore(bytes12 contractId) external constant isRegistered(contractId) returns (BlobStoreInterface blobStore) {
        blobStore = contracts[contractId];
    }

}
