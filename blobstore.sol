/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    struct BlobInfo {               // Single slot.
        bool updatable;             // Can the blob be updated? Can be disabled.
        bool enforceRevisions;      // When updating, always make a new revision. Can be enabled.
        bool retractable;           // Can the blob be retracted? Can be disabled.
        bool disownable;            // Can the blob be disowned? Can be disabled.
        uint32 blockNumber;         // Which block has revision 0 of this blob.
        uint32 numRevisions;        // Number of additional revisions.
        address owner;              // Who created this blob. Non-transferable.
    }

    mapping (bytes32 => BlobInfo) idBlobInfo;
    mapping (bytes32 => mapping (uint => bytes32)) idPackedRevisionBlockNumbers;

    event logBlob(bytes32 indexed id, uint indexed revisionId, bytes blob);     // Greatest revisionId for the blob at time of logging.
    event logRetractRevision(bytes32 indexed id, uint indexed revisionId);
    event logRetract(bytes32 indexed id);
    event logDisown(bytes32 indexed id);
    event logSetNotUpdatable(bytes32 indexed id);
    event logSetEnforceRevisions(bytes32 indexed id);
    event logSetNotRetractable(bytes32 indexed id);
    event logSetNotDisownable(bytes32 indexed id);

    // Create a 96-bit id for this contract. This is unique across all blockchains.
    // Wait a few minutes after deploying for this id to settle.
    bytes12 constant contractId = bytes12(sha3(this, block.blockhash(block.number - 1)));

    /**
     * @dev Throw if the current message is sending a payment.
     */
    modifier noValue() {
        if (msg.value > 0) {
            throw;      // Do not maintain a balance.
        }
        _
    }

    /**
     * @dev Throw if the blob has not been used before or it has been retracted.
     * @param id Id of the blob.
     */
    modifier exists(bytes32 id) {
        if (idBlobInfo[id].blockNumber == 0 || idBlobInfo[id].blockNumber == uint32(-1)) {
            throw;
        }
        _
    }

    /**
     * @dev Throw if the owner of the blob is not the message sender.
     * @param id Id of the blob.
     */
    modifier isOwner(bytes32 id) {
        if (idBlobInfo[id].owner != msg.sender) {
            throw;
        }
        _
    }

    /**
     * @dev Throw if the blob is not updatable.
     * @param id Id of the blob.
     */
    modifier isUpdatable(bytes32 id) {
        if (!idBlobInfo[id].updatable) {
            throw;
        }
        _
    }

    /**
     * @dev Throw if the blob is not enforcing revisions.
     * @param id Id of the blob.
     */
    modifier isNotEnforceRevisions(bytes32 id) {
        if (idBlobInfo[id].enforceRevisions) {
            throw;
        }
        _
    }

    /**
     * @dev Throw is the blob is not retractable.
     * @param id Id of the blob.
     */
    modifier isRetractable(bytes32 id) {
        if (!idBlobInfo[id].retractable) {
            throw;
        }
        _
    }

    /**
     * @dev Throw if the blob is not disownable.
     * @param id Id of the blob.
     */
    modifier isDisownable(bytes32 id) {
        if (!idBlobInfo[id].disownable) {
            throw;
        }
        _
    }

    /**
     * @dev Throw if the blob does not have revisions.
     * @param id Id of the blob.
     */
    modifier hasRevisions(bytes32 id) {
        if (idBlobInfo[id].numRevisions == 0) {
            throw;
        }
        _
    }

    /**
     * @dev Throw if a specific blob revision does not exist.
     * @param id Id of the blob.
     * @param revisionId Id of the revision.
     */
    modifier revisionExists(bytes32 id, uint revisionId) {
        if (revisionId > idBlobInfo[id].numRevisions) {
            throw;
        }
        _
    }

    /**
     * @dev Stores new blob in the transaction log. It is guaranteed that each user will get a different id from the same nonce.
     * @param blob Blob that should be stored.
     * @param nonce Any value that the user has not used previously to create a blob.
     * @param updatable Should the blob be updatable?
     * @param enforceRevisions Should the blob enforce revisions when updating?
     * @param retractable Should the blob be retractable?
     * @param disownable Should the blob be disownable?
     * @param anon Should the blob be anonymous?
     * @return id Id of the blob.
     */
    function create(bytes blob, bytes32 nonce, bool updatable, bool enforceRevisions, bool retractable, bool disownable, bool anon) noValue external returns (bytes32 id) {
        // Determine the id.
        id = contractId | (sha3(msg.sender, nonce) & (2 ** 160 - 1));
        // Make sure this id has not been used before.
        if (idBlobInfo[id].blockNumber != 0) {
            throw;
        }
        // Store blob info in state.
        idBlobInfo[id] = BlobInfo({
            updatable: updatable,
            enforceRevisions: enforceRevisions,
            retractable: retractable,
            disownable: disownable,
            numRevisions: 0,
            blockNumber: uint32(block.number),
            owner: anon ? 0 : msg.sender,
        });
        // Store the blob in a log in the current block.
        logBlob(id, 0, blob);
    }

    /**
     * @dev Store a blob revision block number in a packed slot.
     * @param id Id of the blob.
     * @param offset The offset of the block number should be retreived.
     */
    function setPackedRevisionBlockNumber(bytes32 id, uint offset) internal {
        // Get the slot.
        bytes32 slot = idPackedRevisionBlockNumbers[id][offset / 8];
        // Wipe the previous block number.
        slot &= ~bytes32(uint32(-1) * 2 ** ((offset % 8) * 32));
        // Insert the current block number.
        slot |= bytes32(uint32(block.number) * 2 ** ((offset % 8) * 32));
        // Store the slot.
        idPackedRevisionBlockNumbers[id][offset / 8] = slot;
    }

    /**
     * @dev Create a new blob revision.
     * @param id Id of the blob.
     * @param blob Blob that should be stored as the new revision.
     * @return revisionId The new revisionId.
     */
    function createRevision(bytes32 id, bytes blob) noValue isOwner(id) isUpdatable(id) external returns (uint revisionId) {
        // Increment the number of revisions.
        revisionId = ++idBlobInfo[id].numRevisions;
        // Store the block number.
        setPackedRevisionBlockNumber(id, revisionId - 1);
        // Store the new blob in a log in the current block.
        logBlob(id, revisionId, blob);
    }

    /**
     * @dev Update a blob's latest revsion.
     * @param id Id of the blob.
     * @param blob Blob that should be stored as the latest revision.
     */
    function updateLatestRevision(bytes32 id,  bytes blob) noValue isOwner(id) isUpdatable(id) isNotEnforceRevisions(id) external {
        if (idBlobInfo[id].numRevisions == 0) {
            idBlobInfo[id].blockNumber = uint32(block.number);
        }
        else {
            setPackedRevisionBlockNumber(id, idBlobInfo[id].numRevisions - 1);
        }
        // Store the new blob in a log in the current block.
        logBlob(id, idBlobInfo[id].numRevisions, blob);
    }

    /**
     * @dev Retract a blob's latest revision.
     * @param id Id of the blob.
     */
    function retractLatestRevision(bytes32 id) noValue isOwner(id) isUpdatable(id) isNotEnforceRevisions(id) hasRevisions(id) external {
        logRetractRevision(id, idBlobInfo[id].numRevisions--);
    }

    /**
     * @dev Delete all of a blob's packed revision block numbers.
     * @param id Id of the blob.
     */
    function deleteAllRevisionBlockNumbers(bytes32 id) internal {
        uint numSlots = (idBlobInfo[id].numRevisions + 7) / 8;
        for (uint i = 0; i < numSlots; i++) {
            delete idPackedRevisionBlockNumbers[id][i];
        }
    }

    /**
     * @dev Delete all a blob's revisions and replace it with a new blob.
     * @param id Id of the blob.
     * @param blob Blob that should be stored.
     */
    function restart(bytes32 id, bytes blob) noValue isOwner(id) isUpdatable(id) isNotEnforceRevisions(id) external {
        // Try to get some gas refunds.
        deleteAllRevisionBlockNumbers(id);
        // Update the blob state info.
        idBlobInfo[id].blockNumber = uint32(block.number);
        idBlobInfo[id].numRevisions = 0;
        // Store the blob in a log in the current block.
        logBlob(id, 0, blob);
    }

    /**
     * @dev Retract a blob.
     * @param id Id of the blob.
     */
    function retract(bytes32 id) noValue isOwner(id) isRetractable(id) external {
        // Delete the packed revision block numbers.
        deleteAllRevisionBlockNumbers(id);
        // Mark this blob as retracted.
        idBlobInfo[id] = BlobInfo({
            updatable: false,
            enforceRevisions: false,
            retractable: false,
            disownable: false,
            numRevisions: 0,
            blockNumber: uint32(-1),
            owner: 0,
        });
        // Log that the blob has been retracted.
        logRetract(id);
    }

    /**
     * @dev Disown a blob.
     * @param id Id of the blob.
     */
    function disown(bytes32 id) noValue isOwner(id) isDisownable(id) external {
        // Remove the owner from the blob's state.
        delete idBlobInfo[id].owner;
        // Log as blob as disowned.
        logDisown(id);
    }

    /**
     * @dev Set a blob as not updatable.
     * @param id Id of the blob.
     */
    function setNotUpdatable(bytes32 id) noValue isOwner(id) external {
        // Record in state that the blob is not updatable.
        idBlobInfo[id].updatable = false;
        // Log that the blob is not updatable.
        logSetNotUpdatable(id);
    }

    /**
     * @dev Set a blob to enforce revisions.
     * @param id Id of the blob.
     */
    function setEnforceRevisions(bytes32 id) noValue isOwner(id) external {
        // Record in state that all changes to this blob must be new revisions.
        idBlobInfo[id].enforceRevisions = true;
        // Log that the blob now forces new revisions.
        logSetEnforceRevisions(id);
    }

    /**
     * @dev Set a blob to not be retractable.
     * @param id Id of the blob.
     */
    function setNotRetractable(bytes32 id) noValue isOwner(id) external {
        // Record in state that the blob is not retractable.
        idBlobInfo[id].retractable = false;
        // Log that the blob is not retractable.
        logSetNotRetractable(id);
    }

    /**
     * @dev Set a blob to not be disownable.
     * @param id Id of the blob.
     */
    function setNotDisownable(bytes32 id) noValue isOwner(id) external {
        // Record in state that the blob is not disownable.
        idBlobInfo[id].disownable = false;
        // Log that the blob is not disownable.
        logSetNotDisownable(id);
    }

    function getContractId() noValue constant external returns (bytes12 _contractId) {
        _contractId = contractId;
    }

    /**
     * @dev Get info about a blob.
     * @param id Id of the blob.
     * @return owner Owner of the blob.
     * @return updatable Is the blob updatable?
     * @return enforceRevisions Does the blob enforce revisions?
     * @return retractable Is the blob retractable?
     * @return disownable Is the blob disownable?
     * @return numRevisions How many revisions the blob has.
     * @return latestBlockNumber The block number of the latest revision.
     */
    function getInfo(bytes32 id) noValue exists(id) constant external returns (address owner, bool updatable, bool enforceRevisions, bool retractable, bool disownable, uint numRevisions, uint latestBlockNumber) {
        owner = idBlobInfo[id].owner;
        updatable = idBlobInfo[id].updatable;
        enforceRevisions = idBlobInfo[id].enforceRevisions;
        retractable = idBlobInfo[id].retractable;
        disownable = idBlobInfo[id].disownable;
        numRevisions = idBlobInfo[id].numRevisions;
        latestBlockNumber = getRevisionBlockNumber(id, numRevisions);
    }

    /**
     * @dev Get the owner of a blob.
     * @param id Id of the blob.
     * @return owner Owner of the blob.
     */
    function getOwner(bytes32 id) noValue exists(id) constant external returns (address owner) {
        owner = idBlobInfo[id].owner;
    }

    /**
     * @dev Is a blob updatable?
     * @param id Id of the blob.
     * @return updatable Is the blob updatable?
     */
    function getUpdatable(bytes32 id) noValue exists(id) constant external returns (bool updatable) {
        updatable = idBlobInfo[id].updatable;
    }

    /**
     * @dev Does a blob enforce revisions?
     * @param id Id of the blob.
     * @return enforceRevisions Does the blob enforce revisions?
     */
    function getEnforceRevisions(bytes32 id) noValue exists(id) constant external returns (bool enforceRevisions) {
        enforceRevisions = idBlobInfo[id].enforceRevisions;
    }

    /**
     * @dev Is a blob retractable?
     * @param id Id of the blob.
     * @return retractable Is the blob retractable?
     */
    function getRetractable(bytes32 id) noValue exists(id) constant external returns (bool retractable) {
        retractable = idBlobInfo[id].retractable;
    }

    /**
     * @dev Is a blob disownable.
     * @param id Id of the blob.
     * @return disownable Is the blob disownable?
     */
    function getDisownable(bytes32 id) noValue exists(id) constant external returns (bool disownable) {
        disownable = idBlobInfo[id].disownable;
    }

    /**
     * @dev Get the number of revisions a blob has.
     * @param id Id of the blob.
     * @return numRevisions How many revisions the blob has.
     */
    function getNumRevisions(bytes32 id) noValue exists(id) constant external returns (uint numRevisions) {
        numRevisions = idBlobInfo[id].numRevisions;
    }

    /**
     * @dev Get the block number for a specific blob revision.
     * @param id Id of the blob.
     * @param revisionId Id of the revision.
     * @return blockNumber Block number of the specified revision.
     */
    function getRevisionBlockNumber(bytes32 id, uint revisionId) noValue exists(id) revisionExists(id, revisionId) constant returns (uint blockNumber) {
        if (revisionId == 0) {
            blockNumber = idBlobInfo[id].blockNumber;
        }
        else {
            bytes32 slot = idPackedRevisionBlockNumbers[id][(revisionId - 1) / 8];
            blockNumber = uint32(uint256(slot) / 2 ** (((revisionId - 1) % 8) * 32));
        }
    }

    /**
     * @dev Default function.
     */
    function() {
        throw;      // Do not maintain a balance.
    }

}
