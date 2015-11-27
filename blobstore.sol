/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    mapping (bytes32 => uint) blobBlock;

    event logBlob(bytes32 indexed hash, bytes blob) anonymous;

    function getBlobBlock(bytes32 hash) constant returns (uint) {
        return blobBlock[hash];
    }

    function storeBlob(bytes blob) returns (bytes32 hash) {
        hash = sha3(blob);
        if (blobBlock[hash] != 0) {
            logBlob(hash, blob);
            blobBlock[hash] = block.number;
        }
    }

}
