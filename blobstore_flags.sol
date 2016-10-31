pragma solidity ^0.4.3;


/**
 * @title BlobStoreFlags
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStoreFlags {

    bytes4 constant UPDATABLE = 0x01;           // True if the blob is updatable. After creation can only be disabled.
    bytes4 constant ENFORCE_REVISIONS = 0x02;   // True if the blob is enforcing revisions. After creation can only be enabled.
    bytes4 constant RETRACTABLE = 0x04;         // True if the blob can be retracted. After creation can only be disabled.
    bytes4 constant TRANSFERABLE = 0x08;        // True if the blob be transfered to another user or disowned. After creation can only be disabled.
    bytes4 constant ANONYMOUS = 0x10;           // True if the blob should not have an owner.

}
