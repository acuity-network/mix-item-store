pragma solidity ^0.4.0;

import "dapple/test.sol";
import "blobstore.sol";

/**
 * @title BlobStoreTest
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStoreTest is Test {

    BlobStoreRegistry blobStoreRegistry;
    BlobStore blobStore;

    function setUp() {
        blobStoreRegistry = new BlobStoreRegistry();
        blobStore = new BlobStore(blobStoreRegistry);
    }

    function testBlobCreate() {
        bytes32 id = blobStore.create(hex"001122FF", 0x1234, true, true, true, true, true);
        assertEq12(bytes12(id), blobStore.getContractId());
    }

}
