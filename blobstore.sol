/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    event logBlob(bytes32 indexed hash, bytes blob) anonymous;

    /**
     * @dev Stores a blob in the transaction log.
     * @param blob Blob that should be stored.
     * @return hash Hash of the blob.
     */
    function storeBlob(bytes blob) external returns (bytes32 hash) {
        // Calculate the hash.
        hash = sha3(blob);
        // Store the blob in a log in the current block.
        logBlob(hash, blob);
    }

}
