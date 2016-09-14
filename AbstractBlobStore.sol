pragma solidity ^0.4.0;

/**
 * @title AbstractBlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract AbstractBlobStore {

    /**
     * @dev Stores new blob in the transaction log. It is guaranteed that each user will get a different id from the same nonce.
     * @param blob Blob that should be stored.
     * @param nonce Any value that the user has not used previously to create a blob.
     * @param updatable True if the blob should be updatable.
     * @param enforceRevisions True if the blob should enforce revisions.
     * @param retractable True if the blob should be retractable.
     * @param transferable True if the blob should be transferable.
     * @param anon True if the blob should be anonymous.
     * @return id Id of the blob.
     */
    function create(bytes blob, bytes32 nonce, bool updatable, bool enforceRevisions, bool retractable, bool transferable, bool anon) external returns (bytes32 id);

    /**
     * @dev Create a new blob revision.
     * @param id Id of the blob.
     * @param blob Blob that should be stored as the new revision. Typically a VCDIFF of an earlier revision.
     * @return revisionId The new revisionId.
     */
    function createNewRevision(bytes32 id, bytes blob) external returns (uint revisionId);

    /**
     * @dev Update a blob's latest revision.
     * @param id Id of the blob.
     * @param blob Blob that should replace the latest revision. Typically a VCDIFF if there is an earlier revision.
     */
    function updateLatestRevision(bytes32 id, bytes blob) external;

    /**
     * @dev Retract a blob's latest revision. Revision 0 cannot be retracted.
     * @param id Id of the blob.
     */
    function retractLatestRevision(bytes32 id) external;

    /**
     * @dev Delete all a blob's revisions and replace it with a new blob.
     * @param id Id of the blob.
     * @param blob Blob that should be stored.
     */
    function restart(bytes32 id, bytes blob) external;

    /**
     * @dev Retract a blob.
     * @param id Id of the blob. This id can never be used again.
     */
    function retract(bytes32 id) external;

    /**
     * @dev Enable transfer of the blob to the current user.
     * @param id Id of the blob.
     */
    function transferEnable(bytes32 id) external;

    /**
     * @dev Disable transfer of the blob to the current user.
     * @param id Id of the blob.
     */
    function transferDisable(bytes32 id) external;

    /**
     * @dev Transfer a blob to a new user.
     * @param id Id of the blob.
     * @param recipient Address of the user to transfer to blob to.
     */
    function transfer(bytes32 id, address recipient) external;

    /**
     * @dev Disown a blob.
     * @param id Id of the blob.
     */
    function disown(bytes32 id) external;

    /**
     * @dev Set a blob as not updatable.
     * @param id Id of the blob.
     */
    function setNotUpdatable(bytes32 id) external;

    /**
     * @dev Set a blob to enforce revisions.
     * @param id Id of the blob.
     */
    function setEnforceRevisions(bytes32 id) external;

    /**
     * @dev Set a blob to not be retractable.
     * @param id Id of the blob.
     */
    function setNotRetractable(bytes32 id) external;

    /**
     * @dev Set a blob to not be transferable.
     * @param id Id of the blob.
     */
    function setNotTransferable(bytes32 id) external;

    /**
     * @dev Get the id for this BlobStore contract.
     * @return Id of the contract.
     */
    function getContractId() constant external returns (bytes12);

    /**
     * @dev Get info about a blob.
     * @param id Id of the blob.
     * @return owner Owner of the blob.
     * @return revisionCount How many revisions the blob has.
     * @return blockNumbers The block numbers of the revisions.
     * @return updatable Is the blob updatable?
     * @return enforceRevisions Does the blob enforce revisions?
     * @return retractable Is the blob retractable?
     * @return transferable Is the blob transferable?
     */
    function getInfo(bytes32 id) constant external returns (address owner, uint revisionCount, uint[] blockNumbers, bool updatable, bool enforceRevisions, bool retractable, bool transferable);

    /**
     * @dev Get the owner of a blob.
     * @param id Id of the blob.
     * @return owner Owner of the blob.
     */
    function getOwner(bytes32 id) constant external returns (address owner);

    /**
     * @dev Get the number of revisions a blob has.
     * @param id Id of the blob.
     * @return revisionCount How many revisions the blob has.
     */
    function getRevisionCount(bytes32 id) constant external returns (uint revisionCount);

    /**
     * @dev Get the block number for a specific blob revision.
     * @param id Id of the blob.
     * @param revisionId Id of the revision.
     * @return blockNumber Block number of the specified revision.
     */
    function getRevisionBlockNumber(bytes32 id, uint revisionId) constant external returns (uint blockNumber);

    /**
     * @dev Get the block numbers for all of a blob's revisions.
     * @param id Id of the blob.
     * @return blockNumbers Revision block numbers.
     */
    function getAllRevisionBlockNumbers(bytes32 id) constant external returns (uint[] blockNumbers);

    /**
     * @dev Determine if a blob is updatable.
     * @param id Id of the blob.
     * @return updatable True if the blob is updatable.
     */
    function getUpdatable(bytes32 id) constant external returns (bool updatable);

    /**
     * @dev Determine if a blob enforces revisions.
     * @param id Id of the blob.
     * @return enforceRevisions True if the blob enforces revisions.
     */
    function getEnforceRevisions(bytes32 id) constant external returns (bool enforceRevisions);

    /**
     * @dev Determine if a blob is retractable.
     * @param id Id of the blob.
     * @return retractable True if the blob is blob retractable.
     */
    function getRetractable(bytes32 id) constant external returns (bool retractable);

    /**
     * @dev Determine if a blob is transferable.
     * @param id Id of the blob.
     * @return transferable True if the blob is transferable.
     */
    function getTransferable(bytes32 id) constant external returns (bool transferable);

}
