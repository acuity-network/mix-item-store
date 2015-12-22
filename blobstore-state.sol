import "blobstore.sol";

/**
 * @title BlobState
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobState is BlobStore {

    mapping (bytes32 => bytes) hashBlob;
    
    /**
     * @dev Stores a blob in the contract state.
     * @param blob Blob that should be stored.
     * @return hash sha3 of the blob.
     */
    function storeBlob(bytes blob) returns (bytes32 hash) {
        // Calculate the hash.
        hash = sha3(blob);
        // Have we already stored this blob before?
        if (hashBlob[hash].length == 0) {
            // Transfer the blob to contract state. Expensive!
            hashBlob[hash] = blob;
        }
    }
    
    /**
     * @dev Checks if a blob has been stored before.
     * @param hash Hash of the blob that is being checked for.
     * @return hash sha3 of the blob.
     */
    function blobExists(bytes32 hash) constant returns (bool exists) {
        exists = hashBlob[hash].length > 0;
    }

    /**
     * @dev Gets a blob.
     * @param hash Hash of the blob to get.
     * @return blob The blob.
     */
    function getBlob(bytes32 hash) constant returns (bytes blob) {
        blob = hashBlob[hash];
    }

}
