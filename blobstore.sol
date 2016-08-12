/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    struct BlobInfo {               // Single slot.
        bool updatable;             // Can the blob be updated? Cannot be enabled after creation.
        bool forceNewRevisions;     // When updating always make a new revision. Cannot be disabled after creation.
        bool retractable;           // Can the blob be retracted? Cannot be enabled after creation.
        bool disownable;            // Can the blob be disowned? Cannot be enabled after creation.
        uint32 blockNumber;         // Which block has revision 0 of this blob.
        uint32 numRevisions;        // Number of additional revisions.
        address owner;              // Who created this blob.
    }

    mapping (bytes32 => BlobInfo) idBlobInfo;
    mapping (bytes32 => mapping (uint => bytes32)) idPackedRevisionBlockNumbers;

    event logBlob(bytes32 indexed id, uint indexed revisionId, bytes blob);
    event logRetract(bytes32 indexed id);
    event logDisown(bytes32 indexed id);
    event logSetNotUpdatable(bytes32 indexed id);
    event logSetForceNewRevisions(bytes32 indexed id);
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

    function setPackedRevisionBlockNumber(bytes32 id, uint revisionId) {
        bytes32 slot = idPackedRevisionBlockNumbers[id][(revisionId - 1) / 8];
        uint multiplier = 2 ** (((revisionId - 1) % 8) * 32);
        slot &= ~bytes32(uint32(-1) * multiplier);
        slot |= bytes32(uint32(block.number) * multiplier);
        idPackedRevisionBlockNumbers[id][(revisionId - 1) / 8] = slot;
    }

    function getPackedRevisionBlockNumber(bytes32 id, uint revisionId) returns (uint blockNumber) {
        bytes32 slot = idPackedRevisionBlockNumbers[id][(revisionId - 1) / 8];
        uint offset = ((revisionId - 1) % 8) * 32;
        blockNumber = uint32(uint256(slot) / 2 ** offset);
    }

    /**
     * @dev Stores a blob in the transaction log. It is guaranteed that each user will get a different id from the same nonce.
     * @param blob Blob that should be stored.
     * @return hash Hash of sender and blob.
     */
    function store(bytes blob, bytes32 nonce, bool updatable, bool forceNewRevisions, bool retractable, bool disownable, bool anon) noValue external returns (bytes32 id) {
        // Determine the id.
        id = contractId | (sha3(msg.sender, nonce) & (2 ** 160 - 1));
        // Make sure this id has not been used before.
        if (idBlobInfo[id].blockNumber != 0) {
            throw;
        }
        // Store blob info in state.
        idBlobInfo[id] = BlobInfo({
            updatable: updatable,
            forceNewRevisions: forceNewRevisions,
            retractable: retractable,
            disownable: disownable,
            numRevisions: 0,
            blockNumber: uint32(block.number),
            owner: anon ? 0 : msg.sender,
        });
        // Store the blob in a log in the current block.
        logBlob(id, 0, blob);
    }

    function update(bytes32 id, bytes blob, bool newRevision) noValue isOwner(id) isUpdatable(id) external returns (uint revisionId) {
        BlobInfo blobInfo = idBlobInfo[id];
        if (newRevision || blobInfo.forceNewRevisions) {
            setPackedRevisionBlockNumber(id, ++blobInfo.numRevisions);
        }
        else {
            if (blobInfo.numRevisions == 0) {
                blobInfo.blockNumber = uint32(block.number);
            }
            else {
                setPackedRevisionBlockNumber(id, blobInfo.numRevisions);
            }
        }
        revisionId = blobInfo.numRevisions;
        // Store the new blob in a log in the current block.
        logBlob(id, revisionId, blob);
    }

    function retract(bytes32 id) noValue isOwner(id) isRetractable(id) external {
        // Delete the packed revision block numbers.
        uint numSlots = (idBlobInfo[id].numRevisions + 7) / 8;
        for (uint i = 0; i < numSlots; i++) {
            delete idPackedRevisionBlockNumbers[id][i];
        }
        // Mark this blob as retracted.
        idBlobInfo[id] = BlobInfo({
            updatable: false,
            forceNewRevisions: false,
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

    function setNotUpdatable(bytes32 id) noValue isOwner(id) {
        // Record in state that the blob is not updatable.
        idBlobInfo[id].updatable = false;
        // Log that the blob is not updatable.
        logSetNotUpdatable(id);
    }

    function setForceNewTransactions(bytes32 id) noValue isOwner(id) {
        // Record in state that all changes to this blob must be new revisions.
        idBlobInfo[id].forceNewRevisions = true;
        // Log that the blob now forces new revisions.
        logSetForceNewRevisions(id);
    }

    function setNotRetractable(bytes32 id) noValue isOwner(id) {
        // Record in state that the blob is not retractable.
        idBlobInfo[id].retractable = false;
        // Log that the blob is not retractable.
        logSetNotRetractable(id);
    }

    function setNotDisownable(bytes32 id) noValue isOwner(id) {
        // Record in state that the blob is not disownable.
        idBlobInfo[id].disownable = false;
        // Log that the blob is not disownable.
        logSetNotDisownable(id);
    }

    function getInfo(bytes32 id) noValue constant external returns (address owner, bool updatable, bool forceNewRevisions, bool retractable, bool disownable, uint numRevisions, uint latestBlockNumber) {
        owner = idBlobInfo[id].owner;
        updatable = idBlobInfo[id].updatable;
        forceNewRevisions = idBlobInfo[id].forceNewRevisions;
        retractable = idBlobInfo[id].retractable;
        disownable = idBlobInfo[id].disownable;
        numRevisions = idBlobInfo[id].numRevisions;
        latestBlockNumber = getRevisionBlockNumber(id, numRevisions);
    }

    function getOwner(bytes32 id) noValue constant external returns (address owner) {
        owner = idBlobInfo[id].owner;
    }

    function getUpdatable(bytes32 id) noValue constant external returns (bool updatable) {
        updatable = idBlobInfo[id].updatable;
    }

    function getForceNewRevisions(bytes32 id) noValue constant external returns (bool forceNewRevisions) {
        forceNewRevisions = idBlobInfo[id].forceNewRevisions;
    }

    function getRetractable(bytes32 id) noValue constant external returns (bool retractable) {
        retractable = idBlobInfo[id].retractable;
    }

    function getDisownable(bytes32 id) noValue constant external returns (bool disownable) {
        disownable = idBlobInfo[id].disownable;
    }

    function numRevisions(bytes32 id) noValue constant external returns (uint32 numRevisions) {
        numRevisions = idBlobInfo[id].numRevisions;
    }

    function getRevisionBlockNumber(bytes32 id, uint revisionId) noValue constant returns (uint blockNumber) {
        if (revisionId == 0) {
            blockNumber = idBlobInfo[id].blockNumber;
        }
        else {
            blockNumber = getPackedRevisionBlockNumber(id, revisionId);
        }
    }

    function() {
        throw;      // Do not maintain a balance.
    }

}
