pragma solidity ^0.6.6;

import "./MixItemStoreInterface.sol";
import "./MixItemStoreConstants.sol";
import "./MixItemStoreRegistry.sol";


/**
 * @title MixItemStoreIpfsSha256
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev MixItemStoreInterface implementation where each item revision is a SHA256 IPFS hash.
 */
contract MixItemStoreIpfsSha256 is MixItemStoreInterface, MixItemStoreConstants {

    /**
     * @dev Single slot structure of item state.
     */
    struct ItemState {
        bool inUse;             // Has this itemId ever been used.
        byte flags;             // Packed item settings.
        uint32 revisionCount;   // Number of revisions including revision 0.
        uint32 timestamp;       // Timestamp of revision 0.
        address owner;          // Who owns this item.
    }

    /**
     * @dev Mapping of itemId to item state.
     */
    mapping (bytes32 => ItemState) itemState;

    /**
     * @dev Mapping of itemId to mapping of packed slots of eight 32-bit timestamps.
     */
    mapping (bytes32 => mapping (uint => bytes32)) itemPackedTimestamps;

    /**
     * @dev Mapping of itemId to mapping of revision number to IPFS hash.
     */
    mapping (bytes32 => mapping (uint => bytes32)) itemRevisionIpfsHashes;

    /**
     * @dev Mapping of itemId to mapping of transfer recipient addresses to enabled.
     */
    mapping (bytes32 => mapping (address => bool)) itemTransferEnabled;

    /**
     * @dev MixItemStoreRegistry contract.
     */
    MixItemStoreRegistry public itemStoreRegistry;

    /**
     * @dev Id of this instance of MixItemStoreInterface. Stored as bytes32 instead of bytes8 to reduce gas usage.
     */
    bytes32 contractId;

    /**
     * @dev Revert if the itemId is not in use.
     * @param itemId itemId of the item.
     */
    modifier inUse(bytes32 itemId) {
        require (itemState[itemId].inUse, "Item not in use.");
        _;
    }

    /**
     * @dev Revert if the owner of the item is not the message sender.
     * @param itemId itemId of the item.
     */
    modifier isOwner(bytes32 itemId) {
        require (itemState[itemId].owner == msg.sender, "Sender is not owner of item.");
        _;
    }

    /**
     * @dev Revert if the item is not updatable.
     * @param itemId itemId of the item.
     */
    modifier isUpdatable(bytes32 itemId) {
        require (itemState[itemId].flags & UPDATABLE != 0, "Item is not updatable.");
        _;
    }

    /**
     * @dev Revert if the item is not enforcing revisions.
     * @param itemId itemId of the item.
     */
    modifier isNotEnforceRevisions(bytes32 itemId) {
        require (itemState[itemId].flags & ENFORCE_REVISIONS == 0, "Item is enforcing revisions.");
        _;
    }

    /**
     * @dev Revert if the item is not retractable.
     * @param itemId itemId of the item.
     */
    modifier isRetractable(bytes32 itemId) {
        require (itemState[itemId].flags & RETRACTABLE != 0, "Item is not retractable.");
        _;
    }

    /**
     * @dev Revert if the item is not transferable.
     * @param itemId itemId of the item.
     */
    modifier isTransferable(bytes32 itemId) {
        require (itemState[itemId].flags & TRANSFERABLE != 0, "Item is not transferable.");
        _;
    }

    /**
     * @dev Revert if the item is not transferable to a specific user.
     * @param itemId itemId of the item.
     * @param recipient Address of the user.
     */
    modifier isTransferEnabled(bytes32 itemId, address recipient) {
        require (itemTransferEnabled[itemId][recipient], "Item transfer to recipient not enabled.");
        _;
    }

    /**
     * @dev Revert if the item only has one revision.
     * @param itemId itemId of the item.
     */
    modifier hasAdditionalRevisions(bytes32 itemId) {
        require (itemState[itemId].revisionCount > 1, "Item only has 1 revision.");
        _;
    }

    /**
     * @dev Revert if a specific item revision does not exist.
     * @param itemId itemId of the item.
     * @param revisionId Id of the revision.
     */
    modifier revisionExists(bytes32 itemId, uint revisionId) {
        require (revisionId < itemState[itemId].revisionCount, "Revision does not exist.");
        _;
    }

    /**
     * @param _itemStoreRegistry Address of the MixItemStoreRegistry contract.
     */
    constructor(MixItemStoreRegistry _itemStoreRegistry) public {
        // Store the address of the MixItemStoreRegistry contract.
        itemStoreRegistry = _itemStoreRegistry;
        // Register this contract.
        contractId = itemStoreRegistry.register();
    }

    /**
     * @dev Generates an itemId from owner and nonce and checks that it is unused.
     * @param owner Address that will own the item.
     * @param nonce Nonce that this owner has never used before.
     * @return itemId itemId of the item with this owner and nonce.
     */
    function getNewItemId(address owner, bytes32 nonce) override public view returns (bytes32 itemId) {
        // Combine contractId with hash of sender and nonce.
        itemId = (keccak256(abi.encodePacked(address(this), owner, nonce)) & ITEM_ID_MASK) | contractId;
        // Make sure this itemId has not been used before.
        require (!itemState[itemId].inUse, "itemId already in use.");
    }

    /**
     * @dev Creates an item with no parents. It is guaranteed that different users will never receive the same itemId, even before consensus has been reached. This prevents itemId sniping.
     * @param flagsNonce Nonce that this address has never passed before; first byte is creation flags.
     * @param ipfsHash Hash of the IPFS object where revision 0 is stored.
     * @return itemId itemId of the new item.
     */
    function create(bytes32 flagsNonce, bytes32 ipfsHash) external returns (bytes32 itemId) {
        // Determine the itemId.
        itemId = getNewItemId(msg.sender, flagsNonce);
        // Extract the flags.
        byte flags = byte(flagsNonce);
        // Determine the owner.
        address owner = (flags & DISOWN == 0) ? msg.sender : address(0);
        // Store item state.
        ItemState storage state = itemState[itemId];
        state.inUse = true;
        state.flags = flags;
        state.revisionCount = 1;
        state.timestamp = uint32(block.timestamp);
        state.owner = owner;
        // Store the IPFS hash.
        itemRevisionIpfsHashes[itemId][0] = ipfsHash;
        // Log item creation.
        emit Create(itemId, owner, flags);
        // Log the first revision.
        emit PublishRevision(itemId, owner, 0);
    }

    /**
     * @dev Store an item revision timestamp in a packed slot.
     * @param itemId itemId of the item.
     * @param offset The offset of the timestamp that should be stored.
     */
    function _setPackedTimestamp(bytes32 itemId, uint offset) internal {
        // Get the slot.
        bytes32 slot = itemPackedTimestamps[itemId][offset / 8];
        // Calculate the shift.
        uint shift = (offset % 8) * 32;
        // Wipe the previous timestamp.
        slot &= ~(bytes32(uint256(uint32(-1))) << shift);
        // Insert the current timestamp.
        slot |= bytes32(uint256(uint32(block.timestamp))) << shift;
        // Store the slot.
        itemPackedTimestamps[itemId][offset / 8] = slot;
    }

    /**
     * @dev Create a new item revision.
     * @param itemId itemId of the item.
     * @param ipfsHash Hash of the IPFS object where the item revision is stored.
     * @return revisionId The revisionId of the new revision.
     */
    function createNewRevision(bytes32 itemId, bytes32 ipfsHash) external isOwner(itemId) isUpdatable(itemId) returns (uint revisionId) {
        // Get item state.
        ItemState storage state = itemState[itemId];
        // Increment the number of revisions.
        revisionId = state.revisionCount++;
        // Store the IPFS hash.
        itemRevisionIpfsHashes[itemId][revisionId] = ipfsHash;
        // Store the timestamp.
        _setPackedTimestamp(itemId, revisionId - 1);
        // Log the revision.
        emit PublishRevision(itemId, state.owner, revisionId);
    }

    /**
     * @dev Update an item's latest revision.
     * @param itemId itemId of the item.
     * @param ipfsHash Hash of the IPFS object where the item revision is stored.
     */
    function updateLatestRevision(bytes32 itemId, bytes32 ipfsHash) external isOwner(itemId) isUpdatable(itemId) isNotEnforceRevisions(itemId) {
        // Get item state.
        ItemState storage state = itemState[itemId];
        // Determine the revisionId.
        uint revisionId = state.revisionCount - 1;
        // Update the IPFS hash.
        itemRevisionIpfsHashes[itemId][revisionId] = ipfsHash;
        // Update the timestamp.
        if (revisionId == 0) {
            state.timestamp = uint32(block.timestamp);
        }
        else {
            _setPackedTimestamp(itemId, revisionId - 1);
        }
        // Log the revision.
        emit PublishRevision(itemId, state.owner, revisionId);
    }

    /**
     * @dev Retract an item's latest revision. Revision 0 cannot be retracted.
     * @param itemId itemId of the item.
     */
    function retractLatestRevision(bytes32 itemId) override external isOwner(itemId) isUpdatable(itemId) isNotEnforceRevisions(itemId) hasAdditionalRevisions(itemId) {
        // Get item state.
        ItemState storage state = itemState[itemId];
        // Decrement the number of revisions.
        uint revisionId = --state.revisionCount;
        // Delete the IPFS hash.
        delete itemRevisionIpfsHashes[itemId][revisionId];
        // Delete the packed timestamp slot if it is no longer required.
        if (revisionId % 8 == 1) {
            delete itemPackedTimestamps[itemId][revisionId / 8];
        }
        // Log the revision retraction.
        emit RetractRevision(itemId, state.owner, revisionId);
    }

    /**
     * @dev Delete all of an item's packed revision timestamps.
     * @param itemId itemId of the item.
     */
    function _deleteAllPackedRevisionTimestamps(bytes32 itemId) internal {
        // Determine how many slots should be deleted.
        // Timestamp of the first revision is stored in the item state, so the first slot only needs to be deleted if there are at least 2 revisions.
        uint slotCount = (itemState[itemId].revisionCount + 6) / 8;
        // Delete the slots.
        for (uint i = 0; i < slotCount; i++) {
            delete itemPackedTimestamps[itemId][i];
        }
    }

    /**
     * @dev Delete all an item's revisions and replace it with a new item.
     * @param itemId itemId of the item.
     * @param ipfsHash Hash of the IPFS object where the item revision is stored.
     */
    function restart(bytes32 itemId, bytes32 ipfsHash) external isOwner(itemId) isUpdatable(itemId) isNotEnforceRevisions(itemId) {
        // Get item state and IPFS hashes.
        ItemState storage state = itemState[itemId];
        mapping (uint => bytes32) storage ipfsHashes = itemRevisionIpfsHashes[itemId];
        // Log and delete all the IPFS hashes except the first one.
        for (uint revisionId = state.revisionCount - 1; revisionId > 0; revisionId--) {
            delete ipfsHashes[revisionId];
            emit RetractRevision(itemId, state.owner, revisionId);
        }
        // Delete all the packed revision timestamps.
        _deleteAllPackedRevisionTimestamps(itemId);
        // Update the item state.
        state.revisionCount = 1;
        state.timestamp = uint32(block.timestamp);
        // Update the first IPFS hash.
        ipfsHashes[0] = ipfsHash;
        // Log the revision.
        emit PublishRevision(itemId, state.owner, 0);
    }

    /**
     * @dev Retract an item.
     * @param itemId itemId of the item. This itemId can never be used again.
     */
    function retract(bytes32 itemId) override external isOwner(itemId) isRetractable(itemId) {
        // Get item state and IPFS hashes.
        ItemState storage state = itemState[itemId];
        mapping (uint => bytes32) storage ipfsHashes = itemRevisionIpfsHashes[itemId];
        // Log and delete all the IPFS hashes.
        for (uint revisionId = state.revisionCount - 1; revisionId < state.revisionCount; revisionId--) {
            delete ipfsHashes[revisionId];
            emit RetractRevision(itemId, state.owner, revisionId);
        }
        // Delete all the packed revision timestamps.
        _deleteAllPackedRevisionTimestamps(itemId);
        // Mark this item as retracted.
        state.inUse = true;
        state.flags = 0;
        state.revisionCount = 0;
        state.timestamp = 0;
        state.owner = address(0);
        // Log the item retraction.
        emit Retract(itemId, state.owner);
    }

    /**
     * @dev Enable transfer of an item to the current user.
     * @param itemId itemId of the item.
     */
    function transferEnable(bytes32 itemId) override external isTransferable(itemId) {
        // Record in state that the current user will accept this item.
        itemTransferEnabled[itemId][msg.sender] = true;
        // Log that transfer to this user is enabled.
        emit EnableTransfer(itemId, itemState[itemId].owner, msg.sender);
    }

    /**
     * @dev Disable transfer of an item to the current user.
     * @param itemId itemId of the item.
     */
    function transferDisable(bytes32 itemId) override external isTransferEnabled(itemId, msg.sender) {
        // Record in state that the current user will not accept this item.
        itemTransferEnabled[itemId][msg.sender] = false;
        // Log that transfer to this user is disabled.
        emit DisableTransfer(itemId, itemState[itemId].owner, msg.sender);
    }

    /**
     * @dev Transfer an item to a new user.
     * @param itemId itemId of the item.
     * @param recipient Address of the user to transfer to item to.
     */
    function transfer(bytes32 itemId, address recipient) override external isOwner(itemId) isTransferable(itemId) isTransferEnabled(itemId, recipient) {
        // Get item state.
        ItemState storage state = itemState[itemId];
        // Log the transfer.
        emit Transfer(itemId, state.owner, recipient);
        // Update ownership of the item.
        state.owner = recipient;
        // Disable this transfer in future and free up the slot.
        itemTransferEnabled[itemId][recipient] = false;
    }

    /**
     * @dev Disown an item.
     * @param itemId itemId of the item.
     */
    function disown(bytes32 itemId) override external isOwner(itemId) isTransferable(itemId) {
        // Get item state.
        ItemState storage state = itemState[itemId];
        // Log that the item has been disowned.
        emit Disown(itemId, state.owner);
        // Remove the owner from the item's state.
        delete state.owner;
    }

    /**
     * @dev Set an item as not updatable.
     * @param itemId itemId of the item.
     */
    function setNotUpdatable(bytes32 itemId) override external isOwner(itemId) {
        // Get item state.
        ItemState storage state = itemState[itemId];
        // Record in state that the item is not updatable.
        state.flags &= ~UPDATABLE;
        // Log that the item is not updatable.
        emit SetNotUpdatable(itemId, state.owner);
    }

    /**
     * @dev Set an item to enforce revisions.
     * @param itemId itemId of the item.
     */
    function setEnforceRevisions(bytes32 itemId) override external isOwner(itemId) {
        // Get item state.
        ItemState storage state = itemState[itemId];
        // Record in state that all changes to this item must be new revisions.
        state.flags |= ENFORCE_REVISIONS;
        // Log that the item now enforces new revisions.
        emit SetEnforceRevisions(itemId, state.owner);
    }

    /**
     * @dev Set an item to not be retractable.
     * @param itemId itemId of the item.
     */
    function setNotRetractable(bytes32 itemId) override external isOwner(itemId) {
        // Get item state.
        ItemState storage state = itemState[itemId];
        // Record in state that the item is not retractable.
        state.flags &= ~RETRACTABLE;
        // Log that the item is not retractable.
        emit SetNotRetractable(itemId, state.owner);
    }

    /**
     * @dev Set an item to not be transferable.
     * @param itemId itemId of the item.
     */
    function setNotTransferable(bytes32 itemId) override external isOwner(itemId) {
        // Get item state.
        ItemState storage state = itemState[itemId];
        // Record in state that the item is not transferable.
        state.flags &= ~TRANSFERABLE;
        // Log that the item is not transferable.
        emit SetNotTransferable(itemId, state.owner);
    }

    /**
     * @dev Get the ABI version for this contract.
     * @return ABI version.
     */
    function getAbiVersion() override external view returns (uint) {
        return ABI_VERSION;
    }

    /**
     * @dev Get the id for this contract.
     * @return Id of the contract.
     */
    function getContractId() override external view returns (bytes8) {
        return bytes8(contractId << 192);
    }

    /**
     * @dev Check if an itemId is in use.
     * @param itemId itemId of the item.
     * @return True if the itemId is in use.
     */
    function getInUse(bytes32 itemId) override external view returns (bool) {
        return itemState[itemId].inUse;
    }

    /**
     * @dev Get the IPFS hashes for all of an item's revisions.
     * @param itemId itemId of the item.
     * @return ipfsHashes Revision IPFS hashes.
     */
    function _getAllRevisionIpfsHashes(bytes32 itemId) internal view returns (bytes32[] memory ipfsHashes) {
        uint revisionCount = itemState[itemId].revisionCount;
        ipfsHashes = new bytes32[](revisionCount);
        for (uint revisionId = 0; revisionId < revisionCount; revisionId++) {
            ipfsHashes[revisionId] = itemRevisionIpfsHashes[itemId][revisionId];
        }
    }

    /**
     * @dev Get the timestamp for a specific item revision.
     * @param itemId itemId of the item.
     * @param revisionId Id of the revision.
     * @return timestamp Timestamp of the specified revision or 0 for unconfirmed.
     */
    function _getRevisionTimestamp(bytes32 itemId, uint revisionId) internal view returns (uint timestamp) {
        if (revisionId == 0) {
            timestamp = itemState[itemId].timestamp;
        }
        else {
            uint offset = revisionId - 1;
            timestamp = uint32(uint256(itemPackedTimestamps[itemId][offset / 8] >> ((offset % 8) * 32)));
        }
        // Check if the revision has been confirmed yet.
        if (timestamp == block.timestamp) {
            timestamp = 0;
        }
    }

    /**
     * @dev Get the timestamps for all of an item's revisions.
     * @param itemId itemId of the item.
     * @return timestamps Revision timestamps.
     */
    function _getAllRevisionTimestamps(bytes32 itemId) internal view returns (uint[] memory timestamps) {
        uint count = itemState[itemId].revisionCount;
        timestamps = new uint[](count);
        for (uint revisionId = 0; revisionId < count; revisionId++) {
            timestamps[revisionId] = _getRevisionTimestamp(itemId, revisionId);
        }
    }

    /**
     * @dev Get an item.
     * @param itemId itemId of the item.
     * @return flags Packed item settings.
     * @return owner Owner of the item.
     * @return timestamps Timestamp of each revision.
     * @return ipfsHashes IPFS hash of each revision.
     */
    function getItem(bytes32 itemId) external view inUse(itemId) returns (byte flags, address owner, uint[] memory timestamps, bytes32[] memory ipfsHashes) {
        ItemState storage state = itemState[itemId];
        flags = state.flags;
        owner = state.owner;
        ipfsHashes = _getAllRevisionIpfsHashes(itemId);
        timestamps = _getAllRevisionTimestamps(itemId);
    }

    /**
     * @dev Get an item's flags.
     * @param itemId itemId of the item.
     * @return Packed item settings.
     */
    function getFlags(bytes32 itemId) override external view inUse(itemId) returns (byte) {
        return itemState[itemId].flags;
    }

    /**
     * @dev Determine if an item is updatable.
     * @param itemId itemId of the item.
     * @return True if the item is updatable.
     */
    function getUpdatable(bytes32 itemId) override external view inUse(itemId) returns (bool) {
        return itemState[itemId].flags & UPDATABLE != 0;
    }

    /**
     * @dev Determine if an item enforces revisions.
     * @param itemId itemId of the item.
     * @return True if the item enforces revisions.
     */
    function getEnforceRevisions(bytes32 itemId) override external view inUse(itemId) returns (bool) {
        return itemState[itemId].flags & ENFORCE_REVISIONS != 0;
    }

    /**
     * @dev Determine if an item is retractable.
     * @param itemId itemId of the item.
     * @return True if the item is item retractable.
     */
    function getRetractable(bytes32 itemId) override external view inUse(itemId) returns (bool) {
        return itemState[itemId].flags & RETRACTABLE != 0;
    }

    /**
     * @dev Determine if an item is transferable.
     * @param itemId itemId of the item.
     * @return True if the item is transferable.
     */
    function getTransferable(bytes32 itemId) override external view inUse(itemId) returns (bool) {
        return itemState[itemId].flags & TRANSFERABLE != 0;
    }

    /**
     * @dev Get the owner of an item.
     * @param itemId itemId of the item.
     * @return Owner of the item.
     */
    function getOwner(bytes32 itemId) override external view inUse(itemId) returns (address) {
        return itemState[itemId].owner;
    }

    /**
     * @dev Get the number of revisions an item has.
     * @param itemId itemId of the item.
     * @return How many revisions the item has.
     */
    function getRevisionCount(bytes32 itemId) override external view inUse(itemId) returns (uint) {
        return itemState[itemId].revisionCount;
    }

    /**
     * @dev Get the timestamp for a specific item revision.
     * @param itemId itemId of the item.
     * @param revisionId Id of the revision.
     * @return Timestamp of the specified revision.
     */
    function getRevisionTimestamp(bytes32 itemId, uint revisionId) override external view revisionExists(itemId, revisionId) returns (uint) {
        return _getRevisionTimestamp(itemId, revisionId);
    }

    /**
     * @dev Get the timestamps for all of an item's revisions.
     * @param itemId itemId of the item.
     * @return Timestamps of all revisions of the item.
     */
    function getAllRevisionTimestamps(bytes32 itemId) override external view inUse(itemId) returns (uint[] memory) {
        return _getAllRevisionTimestamps(itemId);
    }

    /**
     * @dev Get the IPFS hash for a specific item revision.
     * @param itemId itemId of the item.
     * @param revisionId Id of the revision.
     * @return IPFS hash of the specified revision.
     */
    function getRevisionIpfsHash(bytes32 itemId, uint revisionId) external view revisionExists(itemId, revisionId) returns (bytes32) {
        return itemRevisionIpfsHashes[itemId][revisionId];
    }

    /**
     * @dev Get the IPFS hashes for all of an item's revisions.
     * @param itemId itemId of the item.
     * @return IPFS hashes of all revisions of the item.
     */
    function getAllRevisionIpfsHashes(bytes32 itemId) external view inUse(itemId) returns (bytes32[] memory) {
        return _getAllRevisionIpfsHashes(itemId);
    }

}
