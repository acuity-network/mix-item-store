/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    /**
     * @dev Stores a blob.
     * @param blob Blob that should be stored.
     * @return hash sha3 of the blob.
     */
    function storeBlob(bytes blob) returns (bytes32 hash);
    
    /**
     * @dev Checks if a blob has been stored before.
     * @param hash Hash of the blob that is being checked for.
     * @return hash sha3 of the blob.
     */
    function blobExists(bytes32 hash) constant returns (bool exists);

}
