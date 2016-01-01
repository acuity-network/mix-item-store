/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    event logBlob(bytes32 indexed id, bytes blob) anonymous;

    /**
     * @dev Stores a blob in the transaction log.
     * @param blob Blob that should be stored.
     * @return id 26 bytes hash of blob, 6 bytes block number.
     */
    function storeBlob(bytes blob) external returns (bytes32 id) {
        // Calculate the hash and zero out the last six bytes.
        // Casting to bytes32 before the ~ saves 8 gas.
        id = sha3(blob) & ~bytes32((2 ** 48) - 1);
        // Store the blob in a log in the current block.
        logBlob(id, blob);
        // Populate the last six bytes with the current block number.
        id |= bytes32(block.number);
    }

}
