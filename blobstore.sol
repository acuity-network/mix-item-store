/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    event logBlob(bytes32 indexed id, bytes blob) anonymous;

    /**
     * @dev Stores a blob in the transaction log.
     * @param blob Blob that should be stored.
     * @return id Hash of blob.
     */
    function storeBlob(bytes blob) external returns (bytes32 id) {
        // Calculate the hash.
        id = sha3(blob);
        // Store the blob in a log in the current block.
        logBlob(id, blob);
    }

}
