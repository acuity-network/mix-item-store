/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    struct BlobInfo {               // Single slot.
        bool immutable;             // Any update to this blob will be a new revision. Cannot be retracted.
        bool updatable;             // Is it possible to update this blob?
        uint32 blockNumber;         // Which block has revision 0 of this blob.
        uint32 numRevisions;        // Number of additional revisions.
        address owner;              // Who created this blob. Owner can always disown.
    }

    mapping (bytes32 => BlobInfo) idBlobInfo;
    mapping (bytes32 => mapping (uint => uint32)) idRevisionIdBlockNumber;  // Not packed - need better compiler / evm.

    event logBlob(bytes32 indexed id, bytes blob);
    event logBlobRevision(bytes32 indexed id, uint indexed revisionId, bytes blob);
    event logBlobRetract(bytes32 indexed id);
    event logSetImmutable(bytes32 indexed id);
    event logSetNotUpdatable(bytes32 indexed id);
    event logDisown(bytes32 indexed id);

    // Create a 96-bit id for this contract. This needs to be unique across all blockchains.
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

    modifier isNotImmutable(bytes32 id) {
        if (idBlobInfo[id].immutable) {
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

    /**
     * @dev Stores a blob in the transaction log. It is guaranteed that each user will get a different id from the same nonce.
     * @param blob Blob that should be stored.
     * @return hash Hash of sender and blob.
     */
    function store(bytes blob, bytes32 nonce, bool immutable, bool updatable, bool anon) noValue external returns (bytes32 id) {
        // Determine the id.
        id = contractId | (sha3(contractId, msg.sender, nonce) & (2 ** 160 - 1));
        // Make sure this id has not been used before.
        if (idBlobInfo[id].blockNumber != 0) {
            throw;
        }
        // Store blob info in state.
        idBlobInfo[id] = BlobInfo({
            immutable: immutable,
            updatable: updatable,
            numRevisions: 0,
            blockNumber: uint32(block.number),
            owner: anon ? 0 : msg.sender,
        });
        // Store the blob in a log in the current block.
        logBlob(id, blob);
    }

    function update(bytes32 id, bytes blob, bool newRevision) noValue isOwner(id) isUpdatable(id) external returns (uint revisionId) {
        BlobInfo blobInfo = idBlobInfo[id];
        if (newRevision || blobInfo.immutable) {
            idRevisionIdBlockNumber[id][++blobInfo.numRevisions] = uint32(block.number);
        }
        else {
            if (blobInfo.numRevisions == 0) {
                blobInfo.blockNumber = uint32(block.number);
            }
            else {
                idRevisionIdBlockNumber[id][blobInfo.numRevisions] = uint32(block.number);
            }
        }
        revisionId = blobInfo.numRevisions;
        // Store the new blob in a log in the current block.
        logBlobRevision(id, revisionId, blob);
    }

    function retract(bytes32 id) noValue isOwner(id) isNotImmutable(id) external {
        // Delete the revision block numbers.
        uint numRevisions = idBlobInfo[id].numRevisions;
        for (uint i = 1; i <= numRevisions; i++) {
            delete idRevisionIdBlockNumber[id][i];
        }
        // Mark this blob as retracted.
        idBlobInfo[id] = BlobInfo({
            immutable: true,
            updatable: false,
            numRevisions: 0,
            blockNumber: uint32(-1),
            owner: 0,
        });
        // Log that the blob has been retracted.
        logBlobRetract(id);
    }

    function setImmutable(bytes32 id) noValue isOwner(id) {
        // Record in state that the blob is immutable.
        idBlobInfo[id].immutable = true;
        // Log that the blob is immutable.
        logSetImmutable(id);
    }

    function setNotUpdatable(bytes32 id) noValue isOwner(id) {
        // Record in state that the blob is not updatable.
        idBlobInfo[id].updatable = false;
        // Log that the blob is not updatable.
        logSetNotUpdatable(id);
    }

    function lock(bytes32 id) noValue isOwner(id) external {
        // Set the blob as immutable.
        setImmutable(id);
        // Set the blob as not updatable.
        setNotUpdatable(id);
    }

    function disown(bytes32 id) noValue isOwner(id) external {
        // Remove the owner from the blob's state.
        delete idBlobInfo[id].owner;
        // Log as blob as disowned.
        logDisown(id);
    }

    function getBlobInfo(bytes32 id) noValue constant external returns (address owner, bool immutable, bool updatable, uint numRevisions, uint latestBlockNumber) {
        owner = idBlobInfo[id].owner;
        immutable = idBlobInfo[id].immutable;
        updatable = idBlobInfo[id].updatable;
        numRevisions = idBlobInfo[id].numRevisions;
        latestBlockNumber = getRevisionBlockNumber(id, numRevisions);
    }

    function getOwner(bytes32 id) noValue constant external returns (address owner) {
        owner = idBlobInfo[id].owner;
    }

    function getImmutable(bytes32 id) noValue constant external returns (bool immutable) {
        immutable = idBlobInfo[id].immutable;
    }

    function getUpdateable(bytes32 id) noValue constant external returns (bool updatable) {
        updatable = idBlobInfo[id].updatable;
    }

    function numRevisions(bytes32 id) noValue constant external returns (uint32 numRevisions) {
        numRevisions = idBlobInfo[id].numRevisions;
    }

    function getRevisionBlockNumber(bytes32 id, uint revisionId) noValue constant returns (uint blockNumber) {
        if (revisionId == 0) {
            blockNumber = idBlobInfo[id].blockNumber;
        }
        else {
            blockNumber = idRevisionIdBlockNumber[id][revisionId];
        }
    }

    function() {
        throw;      // Do not maintain a balance.
    }

}
