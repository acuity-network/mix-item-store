pragma solidity ^0.4.2;


/**
 * @title BlobStoreFlags
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStoreFlags {

    bytes4 constant FLAG_UPDATABLE = 0x01;           // True if the blob is updatable. After creation can only be disabled.
    bytes4 constant FLAG_ENFORCE_REVISIONS = 0x02;   // True if the blob is enforcing revisions. After creation can only be enabled.
    bytes4 constant FLAG_RETRACTABLE = 0x04;         // True if the blob can be retracted. After creation can only be disabled.
    bytes4 constant FLAG_TRANSFERABLE = 0x08;        // True if the blob be transfered to another user or disowned. After creation can only be disabled.
    bytes4 constant FLAG_ANONYMOUS = 0x10;           // True if the blob should not have an owner.

}
