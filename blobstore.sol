/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    event logBlob(bytes32 indexed hash, bytes blob) anonymous;

    /**
     * @dev Stores a blob in the transaction log. It is guaranteed that each user will get a different hash when storing the same blob.
     * @param blob Blob that should be stored.
     * @return hash Hash of sender and blob.
     */
    function storeBlob(bytes blob) external returns (bytes32 hash) {
        // Calculate the hash.
        hash = sha3(msg.sender, blob);
        // Store the blob in a log in the current block.
        logBlob(hash, blob);
    }

    function() {
        throw;      // Do not maintain an ether balance.
    }

}
