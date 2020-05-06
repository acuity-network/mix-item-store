pragma solidity ^0.6.6;


/**
 * @title MixItemStoreConstants
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Provides constants for item store.
 */
contract MixItemStoreConstants {

    byte constant UPDATABLE         = hex"01";  // True if the item is updatable. After creation can only be disabled.
    byte constant ENFORCE_REVISIONS = hex"02";  // True if the item is enforcing revisions. After creation can only be enabled.
    byte constant RETRACTABLE       = hex"04";  // True if the item can be retracted. After creation can only be disabled.
    byte constant TRANSFERABLE      = hex"08";  // True if the item can be transferred to another user or disowned. After creation can only be disabled.
    byte constant DISOWN            = hex"10";  // True if the item should not have an owner at creation.

    bytes32 constant ITEM_ID_MASK       = hex"ffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000";
    bytes32 constant CONTRACT_ID_MASK   = hex"000000000000000000000000000000000000000000000000ffffffffffffffff";

    uint constant ABI_VERSION = 0;
}
