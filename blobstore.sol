/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    mapping (bytes32 => uint) public blobBlockNumber;

    event logBlob(bytes32 indexed hash, bytes blob) anonymous;

    /**
     * @dev Stores a blob in the transaction log.
     * @param blob Blob that should be stored.
     * @return hash sha3 of the blob.
     */
    function storeBlob(bytes blob) returns (bytes32 hash) {
        hash = sha3(blob);
        blobBlockNumber[hash] = block.number;
        logBlob(hash, blob);
    }

}
