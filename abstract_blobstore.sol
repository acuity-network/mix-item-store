pragma solidity ^0.4.2;


/**
 * @title AbstractBlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 * @dev Contracts must be able to interact with blobs regardless of which BlobStore contract they are stored in, so it is necessary for there to be an abstract contract that defines an interface for BlobStore contracts.
 */
contract AbstractBlobStore {

    /**
     * @dev Creates a new blob. It is guaranteed that different users will never receive the same blobId.
     * @param flagsNonce First 4 bytes packed blob settings. The whole parameter needs to not have been passed previously by this user.
     * @param contents Contents of the blob to be stored.
     * @return blobId Id of the blob.
     */
    function create(bytes32 flagsNonce, bytes contents) external returns (bytes20 blobId);

    /**
     * @dev Create a new blob revision.
     * @param blobId Id of the blob.
     * @param contents Contents of the new revision.
     * @return revisionId The new revisionId.
     */
    function createNewRevision(bytes20 blobId, bytes contents) external returns (uint revisionId);

    /**
     * @dev Update a blob's latest revision.
     * @param blobId Id of the blob.
     * @param contents Contents that should replace the latest revision.
     */
    function updateLatestRevision(bytes20 blobId, bytes contents) external;

    /**
     * @dev Retract a blob's latest revision. Revision 0 cannot be retracted.
     * @param blobId Id of the blob.
     */
    function retractLatestRevision(bytes20 blobId) external;

    /**
     * @dev Delete all a blob's revisions and replace it with a new blob.
     * @param blobId Id of the blob.
     * @param contents Contents that should be stored.
     */
    function restart(bytes20 blobId, bytes contents) external;

    /**
     * @dev Retract a blob.
     * @param blobId Id of the blob. This blobId can never be used again.
     */
    function retract(bytes20 blobId) external;

    /**
     * @dev Enable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferEnable(bytes20 blobId) external;

    /**
     * @dev Disable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferDisable(bytes20 blobId) external;

    /**
     * @dev Transfer a blob to a new user.
     * @param blobId Id of the blob.
     * @param recipient Address of the user to transfer to blob to.
     */
    function transfer(bytes20 blobId, address recipient) external;

    /**
     * @dev Disown a blob.
     * @param blobId Id of the blob.
     */
    function disown(bytes20 blobId) external;

    /**
     * @dev Set a blob as not updatable.
     * @param blobId Id of the blob.
     */
    function setNotUpdatable(bytes20 blobId) external;

    /**
     * @dev Set a blob to enforce revisions.
     * @param blobId Id of the blob.
     */
    function setEnforceRevisions(bytes20 blobId) external;

    /**
     * @dev Set a blob to not be retractable.
     * @param blobId Id of the blob.
     */
    function setNotRetractable(bytes20 blobId) external;

    /**
     * @dev Set a blob to not be transferable.
     * @param blobId Id of the blob.
     */
    function setNotTransferable(bytes20 blobId) external;

    /**
     * @dev Get the id for this BlobStore contract.
     * @return Id of the contract.
     */
    function getContractId() external constant returns (bytes12);

    /**
     * @dev Check if a blob exists.
     * @param blobId Id of the blob.
     * @return exists True if the blob exists.
     */
    function getExists(bytes20 blobId) external constant returns (bool exists);

    /**
     * @dev Get info about a blob.
     * @param blobId Id of the blob.
     * @return flags Packed blob settings.
     * @return owner Owner of the blob.
     * @return revisionCount How many revisions the blob has.
     * @return blockNumbers The block numbers of the revisions.
     */
    function getInfo(bytes20 blobId) external constant returns (bytes4 flags, address owner, uint revisionCount, uint[] blockNumbers);

    /**
     * @dev Get all a blob's flags.
     * @param blobId Id of the blob.
     * @return flags Packed blob settings.
     */
    function getFlags(bytes20 blobId) external constant returns (bytes4 flags);

    /**
     * @dev Determine if a blob is updatable.
     * @param blobId Id of the blob.
     * @return updatable True if the blob is updatable.
     */
    function getUpdatable(bytes20 blobId) external constant returns (bool updatable);

    /**
     * @dev Determine if a blob enforces revisions.
     * @param blobId Id of the blob.
     * @return enforceRevisions True if the blob enforces revisions.
     */
    function getEnforceRevisions(bytes20 blobId) external constant returns (bool enforceRevisions);

    /**
     * @dev Determine if a blob is retractable.
     * @param blobId Id of the blob.
     * @return retractable True if the blob is blob retractable.
     */
    function getRetractable(bytes20 blobId) external constant returns (bool retractable);

    /**
     * @dev Determine if a blob is transferable.
     * @param blobId Id of the blob.
     * @return transferable True if the blob is transferable.
     */
    function getTransferable(bytes20 blobId) external constant returns (bool transferable);

    /**
     * @dev Get the owner of a blob.
     * @param blobId Id of the blob.
     * @return owner Owner of the blob.
     */
    function getOwner(bytes20 blobId) external constant returns (address owner);

    /**
     * @dev Get the number of revisions a blob has.
     * @param blobId Id of the blob.
     * @return revisionCount How many revisions the blob has.
     */
    function getRevisionCount(bytes20 blobId) external constant returns (uint revisionCount);

    /**
     * @dev Get the block numbers for all of a blob's revisions.
     * @param blobId Id of the blob.
     * @return blockNumbers Revision block numbers.
     */
    function getAllRevisionBlockNumbers(bytes20 blobId) external constant returns (uint[] blockNumbers);

}
