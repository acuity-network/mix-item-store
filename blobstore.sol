/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    mapping (bytes32 => uint) blobBlock;

    event logBlob(bytes32 indexed hash, bytes blob) anonymous;

    /**
     * @dev Gets the block that a blob is logged in.
     * @param hash sha3 of the blob.
     * @return Block number.
     */
    function getBlobBlock(bytes32 hash) constant returns (uint) {
        return blobBlock[hash];
    }

    /**
     * @dev Stores a blob in the transaction log.
     * @param blob Blob that should be stored.
     * @return hash sha3 of the blob.
     */
    function storeBlob(bytes blob) returns (bytes32 hash) {
        hash = sha3(blob);
        if (blobBlock[hash] == 0) {
            logBlob(hash, blob);
            blobBlock[hash] = block.number;
        }
    }

}
