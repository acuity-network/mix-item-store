import "blobstore.sol";

/**
 * @title BlobLog
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobLog is BlobStore {

    mapping (bytes32 => uint) hashBlockNumber;

    event logBlob(bytes32 indexed hash, bytes blob) anonymous;

    /**
     * @dev Stores a blob in the transaction log. No deduplication is performed
     * in-contract as a copy of the blob in an older block log may not be as
     * readily available due to pruning.
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
     * @dev Checks if a blob has been stored before.
     * @param hash Hash of the blob that is being checked for.
     * @return hash sha3 of the blob.
     */
    function blobExists(bytes32 hash) constant returns (bool exists) {
        exists = hashBlockNumber[hash] > 0;
    }

    /**
     * @dev Gets the block number a blob was logged in.
     * @param hash Hash of the blob to search for.
     * @return blockNumber Block number that the blob was logged in.
     */
    function getBlobBlockNumber(bytes32 hash) constant returns (uint blockNumber) {
        blockNumber = hashBlockNumber[hash];
    }

}
