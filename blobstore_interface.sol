pragma solidity ^0.4.11;


/**
 * @title BlobStoreInterface
 * @author Jonathan Brown <jbrown@link-blockchain.org>
 */
interface BlobStoreInterface {

    /**
     * @dev A revision has been retracted.
     * @param blobId Id of the blob.
     * @param revisionId Id of the revision.
     */
    event RetractRevision(bytes20 indexed blobId, uint revisionId);

    /**
     * @dev An entire blob has been retracted. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event Retract(bytes20 indexed blobId);

    /**
     * @dev A blob has been transfered to a new owner.
     * @param blobId Id of the blob.
     * @param recipient The address that now owns the blob.
     */
    event Transfer(bytes20 indexed blobId, address recipient);

    /**
     * @dev A blob has been disowned. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event Disown(bytes20 indexed blobId);

    /**
     * @dev A blob has been set as not updatable. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event SetNotUpdatable(bytes20 indexed blobId);

    /**
     * @dev A blob has been set as enforcing revisions. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event SetEnforceRevisions(bytes20 indexed blobId);

    /**
     * @dev A blob has been set as not retractable. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event SetNotRetractable(bytes20 indexed blobId);

    /**
     * @dev A blob has been set as not transferable. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event SetNotTransferable(bytes20 indexed blobId);

    /**
     * @dev Retract a blob's latest revision. Revision 0 cannot be retracted.
     * @param blobId Id of the blob.
     */
    function retractLatestRevision(bytes20 blobId) external;

    /**
     * @dev Retract a blob.
     * @param blobId Id of the blob. This blobId can never be used again.
     */
    function retract(bytes20 blobId) external;

    /**
     * @dev Enable transfer of a blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferEnable(bytes20 blobId) external;

    /**
     * @dev Disable transfer of a blob to the current user.
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
    function getContractId() external constant returns (bytes12 contractId);

    /**
     * @dev Check if a blob exists.
     * @param blobId Id of the blob.
     * @return exists True if the blob exists.
     */
    function getExists(bytes20 blobId) external constant returns (bool exists);

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

}
