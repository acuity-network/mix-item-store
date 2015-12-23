/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    mapping (bytes32 => uint) hashBlockNumber;

    event logBlob(bytes32 indexed hash, bytes blob) anonymous;

    /**
     * @dev Stores a blob in the transaction log.
     * @param blob Blob that should be stored.
     * @return hash sha3 of the blob.
     */
    function storeBlob(bytes blob) returns (bytes32 hash) {
        // Calculate the hash. 
        hash = sha3(blob);
        // Associate the current block number with the hash.
        hashBlockNumber[hash] = block.number;
        // Store the blob in a log in the current block.
        logBlob(hash, blob);
    }
    
    /**
     * @dev Gets the block number a blob was logged in.
     * @param hash Hash of the blob to search for.
     * @return blockNumber Block number that the blob was logged in or zero if
     * not logged at all.
     */
    function getBlobBlockNumber(bytes32 hash) constant returns (uint blockNumber) {
        blockNumber = hashBlockNumber[hash];
    }

}
