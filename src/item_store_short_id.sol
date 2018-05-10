pragma solidity ^0.4.23;

/**
 * @title ItemStoreShortId
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Maintain bidirectional mapping between 32 byte itemIds and 4 byte shortIds.
 */
contract ItemStoreShortId {

    /**
     * @dev Mapping of itemId to shortId.
     */
    mapping (bytes32 => bytes4) itemIdShortId;

    /**
     * @dev Mapping of shortId to itemId.
     */
    mapping (bytes4 => bytes32) shortIdItemId;

    /**
     * @dev
     * @param itemId itemId of the item.
     * @param nonce Extra parameter to change the shortId if it is already taken.
     * @return shortId
     */
    function createShortId(bytes32 itemId, bytes32 nonce) external returns (bytes4 shortId) {
        // Caluculate the shortId.
        shortId = bytes4(keccak256(itemId, nonce));
        // Make sure it hasn't been used before.
        assert(shortIdItemId[shortId] == 0);
        // Store the mappings.
        itemIdShortId[itemId] = shortId;
        shortIdItemId[shortId] = itemId;
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
