pragma solidity ^0.6.6;


/**
 * @title MixItemStoreShortId
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Maintains a bidirectional mapping between 32 byte itemIds and 4 byte shortIds.
 */
contract MixItemStoreShortId {

    /**
     * @dev Mapping of itemId to shortId.
     */
    mapping (bytes32 => bytes4) itemIdShortId;

    /**
     * @dev Mapping of shortId to itemId.
     */
    mapping (bytes4 => bytes32) shortIdItemId;

    /**
     * @dev A new shortId has been created.
     * @param itemId itemId of the item.
     * @param shortId shortId of the item
     */
    event CreateShortId(bytes32 indexed itemId, bytes32 indexed shortId);

    /**
     * @dev Revert if the itemId already has a shortId.
     * @param itemId itemId of the item.
     */
    modifier noShortId(bytes32 itemId) {
        require (itemIdShortId[itemId] == 0, "itemId already has a shortId.");
        _;
    }

    /**
     * @dev Create a 4 byte shortId for a 32 byte itemId.
     * @param itemId itemId of the item.
     * @return shortId New 4 byte shortId.
     */
    function createShortId(bytes32 itemId) external noShortId(itemId) returns (bytes4 shortId) {
        // Find a shortId that hasn't been used before.
        bytes32 hash = keccak256(abi.encodePacked(itemId));
        shortId = bytes4(hash);
        while (shortIdItemId[shortId] != 0) {
            hash = keccak256(abi.encodePacked(hash));
            shortId = bytes4(hash);
        }
        // Store the mappings.
        itemIdShortId[itemId] = shortId;
        shortIdItemId[shortId] = itemId;
        // Log the event.
        emit CreateShortId(itemId, shortId);
    }

    /**
     * @dev Get itemId for shortId.
     * @param shortId to get the itemId for.
     * @return The itemId.
     */
    function getItemId(bytes4 shortId) external view returns (bytes32) {
        return shortIdItemId[shortId];
    }

    /**
     * @dev Get shortId for itemId.
     * @param itemId to get the shortId for.
     * @return The shortId.
     */
    function getShortId(bytes32 itemId) external view returns (bytes4) {
        return itemIdShortId[itemId];
    }

}
