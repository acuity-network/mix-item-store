/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    struct BlobInfo {               // Single slot.
        bool updatable;             // Can the blob be updated? Cannot be enabled after creation.
        bool enforceRevisions;      // When updating always make a new revision. Cannot be disabled after creation.
        bool retractable;           // Can the blob be retracted? Cannot be enabled after creation.
        bool disownable;            // Can the blob be disowned? Cannot be enabled after creation.
        uint32 blockNumber;         // Which block has revision 0 of this blob.
        uint32 numRevisions;        // Number of additional revisions.
        address owner;              // Who created this blob.
    }

    mapping (bytes32 => BlobInfo) idBlobInfo;
    mapping (bytes32 => mapping (uint => bytes32)) idPackedRevisionBlockNumbers;

    event logBlob(bytes32 indexed id, uint indexed revisionId, bytes blob);     // Greatest revision for the blob at time of logging.
    event logRetractRevision(bytes32 indexed id, uint indexed revisionId);
    event logRetract(bytes32 indexed id);
    event logDisown(bytes32 indexed id);
    event logSetNotUpdatable(bytes32 indexed id);
    event logSetEnforceRevisions(bytes32 indexed id);
    event logSetNotRetractable(bytes32 indexed id);
    event logSetNotDisownable(bytes32 indexed id);

    // Create a 96-bit id for this contract. This is unique across all blockchains.
    // Wait a few minutes after deploying for this id to settle.
    bytes12 constant public contractId = bytes12(sha3(this, block.blockhash(block.number - 1)));

    modifier noValue() {
        if (msg.value > 0) {
            throw;      // Do not maintain a balance.
        }
        _
    }

    modifier exists(bytes32 id) {
        if (idBlobInfo[id].blockNumber == 0 || idBlobInfo[id].blockNumber == uint32(-1)) {
            throw;
        }
        _
    }

    modifier isOwner(bytes32 id) {
        if (idBlobInfo[id].owner != msg.sender) {
            throw;
        }
        _
    }

    modifier isUpdatable(bytes32 id) {
        if (!idBlobInfo[id].updatable) {
            throw;
        }
        _
    }

    modifier isNotEnforceRevisions(bytes32 id) {
        if (idBlobInfo[id].enforceRevisions) {
            throw;
        }
        _
    }

    modifier isRetractable(bytes32 id) {
        if (!idBlobInfo[id].retractable) {
            throw;
        }
        _
    }

    modifier isDisownable(bytes32 id) {
        if (!idBlobInfo[id].disownable) {
            throw;
        }
        _
    }

    modifier hasRevisions(bytes32 id) {
        if (idBlobInfo[id].numRevisions == 0) {
            throw;
        }
        _
    }

    modifier revisionExists(bytes32 id, uint revisionId) {
        if (revisionId > idBlobInfo[id].numRevisions) {
            throw;
        }
        _
    }

    /**
     * @dev Stores a blob in the transaction log. It is guaranteed that each user will get a different id from the same nonce.
     * @param blob Blob that should be stored.
     * @return hash Hash of sender and blob.
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

    function createRevision(bytes32 id, bytes blob) noValue isOwner(id) isUpdatable(id) external returns (uint revisionId) {
        // Increment the number of revisions.
        revisionId = ++idBlobInfo[id].numRevisions;
        // Store the block number.
        setPackedRevisionBlockNumber(id, revisionId - 1);
        // Store the new blob in a log in the current block.
        logBlob(id, revisionId, blob);
    }

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

    function retractLatestRevision(bytes32 id) noValue isOwner(id) isUpdatable(id) isNotEnforceRevisions(id) hasRevisions(id) external {
        logRetractRevision(id, idBlobInfo[id].numRevisions--);
    }

    function deleteAllRevisionBlockNumbers(bytes32 id) internal {
        uint numSlots = (idBlobInfo[id].numRevisions + 7) / 8;
        for (uint i = 0; i < numSlots; i++) {
            delete idPackedRevisionBlockNumbers[id][i];
        }
    }

    function restart(bytes32 id, bytes blob) noValue isOwner(id) isUpdatable(id) isNotEnforceRevisions(id) external {
        // Try to get some gas refunds.
        deleteAllRevisionBlockNumbers(id);
        // Update the blob state info.
        idBlobInfo[id].blockNumber = uint32(block.number);
        idBlobInfo[id].numRevisions = 0;
        // Store the blob in a log in the current block.
        logBlob(id, 0, blob);
    }

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

    function disown(bytes32 id) noValue isOwner(id) isDisownable(id) external {
        // Remove the owner from the blob's state.
        delete idBlobInfo[id].owner;
        // Log as blob as disowned.
        logDisown(id);
    }

    function setNotUpdatable(bytes32 id) noValue isOwner(id) external {
        // Record in state that the blob is not updatable.
        idBlobInfo[id].updatable = false;
        // Log that the blob is not updatable.
        logSetNotUpdatable(id);
    }

    function setEnforceRevisions(bytes32 id) noValue isOwner(id) external {
        // Record in state that all changes to this blob must be new revisions.
        idBlobInfo[id].enforceRevisions = true;
        // Log that the blob now forces new revisions.
        logSetEnforceRevisions(id);
    }

    function setNotRetractable(bytes32 id) noValue isOwner(id) external {
        // Record in state that the blob is not retractable.
        idBlobInfo[id].retractable = false;
        // Log that the blob is not retractable.
        logSetNotRetractable(id);
    }

    function setNotDisownable(bytes32 id) noValue isOwner(id) external {
        // Record in state that the blob is not disownable.
        idBlobInfo[id].disownable = false;
        // Log that the blob is not disownable.
        logSetNotDisownable(id);
    }

    function getInfo(bytes32 id) noValue exists(id) constant external returns (address owner, bool updatable, bool enforceRevisions, bool retractable, bool disownable, uint numRevisions, uint latestBlockNumber) {
        owner = idBlobInfo[id].owner;
        updatable = idBlobInfo[id].updatable;
        enforceRevisions = idBlobInfo[id].enforceRevisions;
        retractable = idBlobInfo[id].retractable;
        disownable = idBlobInfo[id].disownable;
        numRevisions = idBlobInfo[id].numRevisions;
        latestBlockNumber = getRevisionBlockNumber(id, numRevisions);
    }

    function getOwner(bytes32 id) noValue exists(id) constant external returns (address owner) {
        owner = idBlobInfo[id].owner;
    }

    function getUpdatable(bytes32 id) noValue exists(id) constant external returns (bool updatable) {
        updatable = idBlobInfo[id].updatable;
    }

    function getEnforceRevisions(bytes32 id) noValue exists(id) constant external returns (bool enforceRevisions) {
        enforceRevisions = idBlobInfo[id].enforceRevisions;
    }

    function getRetractable(bytes32 id) noValue exists(id) constant external returns (bool retractable) {
        retractable = idBlobInfo[id].retractable;
    }

    function getDisownable(bytes32 id) noValue exists(id) constant external returns (bool disownable) {
        disownable = idBlobInfo[id].disownable;
    }

    function getNumRevisions(bytes32 id) noValue exists(id) constant external returns (uint numRevisions) {
        numRevisions = idBlobInfo[id].numRevisions;
    }

    function getRevisionBlockNumber(bytes32 id, uint revisionId) noValue exists(id) revisionExists(id, revisionId) constant returns (uint blockNumber) {
        if (revisionId == 0) {
            blockNumber = idBlobInfo[id].blockNumber;
        }
        else {
            bytes32 slot = idPackedRevisionBlockNumbers[id][(revisionId - 1) / 8];
            blockNumber = uint32(uint256(slot) / 2 ** (((revisionId - 1) % 8) * 32));
        }
    }

    function() {
        throw;      // Do not maintain a balance.
    }

}
