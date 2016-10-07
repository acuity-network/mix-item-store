pragma solidity ^0.4.0;

/**
 * @title AbstractBlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract AbstractBlobStore {

    /**
     * @dev Enable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferEnable(bytes32 blobId) external;

    /**
     * @dev Disable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferDisable(bytes32 blobId) external;

    /**
     * @dev Get the id for this BlobStore contract.
     * @return Id of the contract.
     */
    function getContractId() constant external returns (bytes12 contractId);

    /**
     * @dev Check if a blob exists.
     * @param blobId Id of the blob.
     * @return exists True if the blob exists.
     */
    function getExists(bytes32 blobId) constant external returns (bool exists);

    /**
     * @dev Get the owner of a blob.
     * @param blobId Id of the blob.
     * @return owner Owner of the blob.
     */
    function getOwner(bytes32 blobId) constant external returns (address owner);

    /**
     * @dev Get the number of revisions a blob has.
     * @param blobId Id of the blob.
     * @return revisionCount How many revisions the blob has.
     */
    function getRevisionCount(bytes32 blobId) constant external returns (uint revisionCount);

    /**
     * @dev Determine if a blob is updatable.
     * @param blobId Id of the blob.
     * @return updatable True if the blob is updatable.
     */
    function getUpdatable(bytes32 blobId) constant external returns (bool updatable);

    /**
     * @dev Determine if a blob enforces revisions.
     * @param blobId Id of the blob.
     * @return enforceRevisions True if the blob enforces revisions.
     */
    function getEnforceRevisions(bytes32 blobId) constant external returns (bool enforceRevisions);

    /**
     * @dev Determine if a blob is retractable.
     * @param blobId Id of the blob.
     * @return retractable True if the blob is blob retractable.
     */
    function getRetractable(bytes32 blobId) constant external returns (bool retractable);

    /**
     * @dev Determine if a blob is transferable.
     * @param blobId Id of the blob.
     * @return transferable True if the blob is transferable.
     */
    function getTransferable(bytes32 blobId) constant external returns (bool transferable);

}
