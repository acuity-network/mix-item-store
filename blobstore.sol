/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    event logBlob(bytes32 indexed id, bytes blob) anonymous;

    /**
     * @dev Stores a blob in the transaction log.
     * @param blob Blob that should be stored.
     * @return id 6 bytes block number, 26 bytes hash of blob.
     */
    function storeBlob(bytes blob) external returns (bytes32 id) {
        // Calculate the hash and zero out the first six bytes.
        id = sha3(blob) & (2**208 - 1);
        // Store the blob in a log in the current block.
        logBlob(id, blob);
        // Populate the first six bytes with the current block number.
        id = bytes32(block.number * (2**208)) | id;
    }

}
