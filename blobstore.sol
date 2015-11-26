/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore {

    mapping (bytes32 => bool) stored;

    event logBlob(bytes32 indexed hash, bytes blob) anonymous;

    function isStored(bytes32 hash) constant returns (bool) {
        return stored[hash];
    }

    function storeBlob(bytes blob) returns (bytes32 hash) {
        hash = sha3(blob);
        if (!isStored(hash)) {
            logBlob(hash, blob);
            stored[hash] = true;
        }
    }

}
