/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    struct BlobInfo {
        uint96 blockNumber;
        address owner;
    }

    mapping (bytes32 => BlobInfo) blobInfo;
    mapping (bytes32 => uint256[]) revisionBlockNumbers;

    event logBlob(bytes32 indexed hash, uint256 indexed revisionId, bytes blob) anonymous;
    event logRetraction(bytes32 indexed hash) anonymous;

    modifier isOwner(bytes32 hash) {
        if (blobInfo[hash].owner != msg.sender) {
            throw;
        }
        _
    }

    /**
     * @dev Stores a blob in the transaction log. It is guaranteed that each user will get a different hash when storing the same blob.
     * @param blob Blob that should be stored.
     * @return hash Hash of sender and blob.
     */
    function storeBlob(bytes blob, bool revisionable) external returns (bytes32 hash) {
        // Calculate the hash.
        hash = sha3(msg.sender, blob);
        // Store block number and owner in state.
        blobInfo[hash] = BlobInfo({
            blockNumber: uint96(block.number),
            owner: revisionable ? msg.sender : 0,
        });
        // Store the blob in a log in the current block.
        logBlob(hash, 0, blob);
    }

    function updateBlob(bytes32 hash, bytes blob) isOwner(hash) external {
        revisionBlockNumbers[hash].push(block.number);
        // Store the new blob in a log in the current block.
        logBlob(hash, revisionBlockNumbers[hash].length, blob);
    }

    function retractBlob(bytes32 hash) isOwner(hash) external {
        // Get a refund for the storage slots.
        delete blobInfo[hash];
        delete revisionBlockNumbers[hash];
        // Log the retraction.
        logRetraction(hash);
    }

    function getBlobInfo(bytes32 hash) constant external returns (address owner, uint256 revisions, uint256 blockNumber) {
        owner = blobInfo[hash].owner;
        revisions = revisionBlockNumbers[hash].length;
        if (revisions == 0) {
            blockNumber = blobInfo[hash].blockNumber;
        }
        else {
            blockNumber = revisionBlockNumbers[hash][revisions - 1];
        }
    }

    function getRevisionBlockNumber(bytes32 hash, uint256 revisionId) constant external returns (uint256 blockNumber) {
        if (revisionId == 0) {
            blockNumber = blobInfo[hash].blockNumber;
        }
        else {
            blockNumber = revisionBlockNumbers[hash][revisionId - 1];
        }
    }

    function() {
        throw;      // Do not maintain an ether balance.
    }

}
