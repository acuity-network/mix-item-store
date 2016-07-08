/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    mapping (bytes32 => bytes32) blobInfo;      // Block number and user.

    event logBlob(bytes32 indexed hash, bytes blob) anonymous;
    event logRetraction(bytes32 indexed hash) anonymous;

    modifier isOwner(bytes32 hash) {
        if (address(blobInfo[hash] & (2**160)) == msg.sender) {
            throw;
        }
        _
    }

    /**
     * @dev Stores a blob in the transaction log. It is guaranteed that each user will get a different hash when storing the same blob.
     * @param blob Blob that should be stored.
     * @return hash Hash of sender and blob.
     */
    function storeBlob(bytes blob) external returns (bytes32 hash) {
        // Calculate the hash.
        hash = sha3(msg.sender, blob);
        // Store the blob owner and block number in state.
        blobInfo[hash] = bytes32(block.number * (2**208)) | bytes32(msg.sender);
        // Store the blob in a log in the current block.
        logBlob(hash, blob);
    }

    function updateBlob(bytes32 hash, bytes blob) isOwner(hash) external {
        // Update block number in state.
        blobInfo[hash] = bytes32(block.number * (2**208)) | bytes32(msg.sender);
        // Store the new blob in a log in the current block.
        logBlob(hash, blob);
    }

    function retractBlob(bytes32 hash) isOwner(hash) external {
        // Get a refund for the storage slot.
        delete blobInfo[hash];
        // Log the retraction.
        logRetraction(hash);
    }

    function getBlobInfo(bytes32 hash) constant external returns (address owner, uint256 blockNumber) {
        owner = address(blobInfo[hash] & ((2**208) - 1));
        blockNumber = uint256(blobInfo[hash]) / (2**208);
    }

    function() {
        throw;      // Do not maintain an ether balance.
    }

}
