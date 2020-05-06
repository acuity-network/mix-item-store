pragma solidity ^0.6.6;


/**
 * @title MixItemStoreInterface
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Implementation interface for item store contracts.
 */
interface MixItemStoreInterface {

    /**
     * @dev A new item has been created.
     * @param itemId itemId of the item.
     * @param owner Address of the item owner.
     */
    event Create(bytes32 indexed itemId, address indexed owner, byte flags);

    /**
     * @dev An entire item has been retracted. This cannot be undone.
     * @param itemId itemId of the item.
     */
    event Retract(bytes32 indexed itemId, address indexed owner);

    /**
     * @dev An item revision has been published.
     * @param itemId itemId of the item.
     * @param revisionId Id of the revision (highest at time of logging).
     */
    event PublishRevision(bytes32 indexed itemId, address indexed owner, uint revisionId);

    /**
     * @dev An item revision has been retracted.
     * @param itemId itemId of the item.
     * @param revisionId Id of the revision (highest at time of logging).
     */
    event RetractRevision(bytes32 indexed itemId, address indexed owner, uint revisionId);

    /**
     * @dev Transfering ownership of an item to a specific account has been enabled.
     * @param itemId itemId of the item.
     * @param recipient The account that the item can be transferred to.
     */
    event EnableTransfer(bytes32 indexed itemId, address indexed owner, address indexed recipient);

    /**
     * @dev Transfering ownership of an item to a specific account has been disabled.
     * @param itemId itemId of the item.
     * @param recipient The account that the item cannot be transferred to.
     */
    event DisableTransfer(bytes32 indexed itemId, address indexed owner, address indexed recipient);

    /**
     * @dev An item has been transferred to a new owner.
     * @param itemId itemId of the item.
     * @param recipient The account that now owns the item.
     */
    event Transfer(bytes32 indexed itemId, address indexed owner, address indexed recipient);

    /**
     * @dev An item has been disowned. This cannot be undone.
     * @param itemId itemId of the item.
     */
    event Disown(bytes32 indexed itemId, address indexed owner);

    /**
     * @dev An item has been set as not updatable. This cannot be undone.
     * @param itemId itemId of the item.
     */
    event SetNotUpdatable(bytes32 indexed itemId, address indexed owner);

    /**
     * @dev An item has been set as enforcing revisions. This cannot be undone.
     * @param itemId itemId of the item.
     */
    event SetEnforceRevisions(bytes32 indexed itemId, address indexed owner);

    /**
     * @dev An item has been set as not retractable. This cannot be undone.
     * @param itemId itemId of the item.
     */
    event SetNotRetractable(bytes32 indexed itemId, address indexed owner);

    /**
     * @dev An item has been set as not transferable. This cannot be undone.
     * @param itemId itemId of the item.
     */
    event SetNotTransferable(bytes32 indexed itemId, address indexed owner);

    /**
     * @dev Generates an itemId from owner and nonce and checks that it is unused.
     * @param owner Address that will own the item.
     * @param nonce Nonce that this owner has never used before.
     * @return itemId itemId of the item with this owner and nonce.
     */
    function getNewItemId(address owner, bytes32 nonce) external view returns (bytes32 itemId);

    /**
     * @dev Retract an item's latest revision. Revision 0 cannot be retracted.
     * @param itemId itemId of the item.
     */
    function retractLatestRevision(bytes32 itemId) external;

    /**
     * @dev Retract an item.
     * @param itemId itemId of the item. This itemId can never be used again.
     */
    function retract(bytes32 itemId) external;

    /**
     * @dev Enable transfer of the item to the current user.
     * @param itemId itemId of the item.
     */
    function transferEnable(bytes32 itemId) external;

    /**
     * @dev Disable transfer of the item to the current user.
     * @param itemId itemId of the item.
     */
    function transferDisable(bytes32 itemId) external;

    /**
     * @dev Transfer an item to a new user.
     * @param itemId itemId of the item.
     * @param recipient Address of the user to transfer to item to.
     */
    function transfer(bytes32 itemId, address recipient) external;

    /**
     * @dev Disown an item.
     * @param itemId itemId of the item.
     */
    function disown(bytes32 itemId) external;

    /**
     * @dev Set an item as not updatable.
     * @param itemId itemId of the item.
     */
    function setNotUpdatable(bytes32 itemId) external;

    /**
     * @dev Set an item to enforce revisions.
     * @param itemId itemId of the item.
     */
    function setEnforceRevisions(bytes32 itemId) external;

    /**
     * @dev Set an item to not be retractable.
     * @param itemId itemId of the item.
     */
    function setNotRetractable(bytes32 itemId) external;

    /**
     * @dev Set an item to not be transferable.
     * @param itemId itemId of the item.
     */
    function setNotTransferable(bytes32 itemId) external;

    /**
     * @dev Get the ABI version for this contract.
     * @return ABI version.
     */
    function getAbiVersion() external view returns (uint);

    /**
     * @dev Get the id for this contract.
     * @return Id of the contract.
     */
    function getContractId() external view returns (bytes8);

    /**
     * @dev Check if an itemId is in use.
     * @param itemId itemId of the item.
     * @return True if the itemId is in use.
     */
    function getInUse(bytes32 itemId) external view returns (bool);

    /**
     * @dev Get an item's flags.
     * @param itemId itemId of the item.
     * @return Packed item settings.
     */
    function getFlags(bytes32 itemId) external view returns (byte);

    /**
     * @dev Determine if an item is updatable.
     * @param itemId itemId of the item.
     * @return True if the item is updatable.
     */
    function getUpdatable(bytes32 itemId) external view returns (bool);

    /**
     * @dev Determine if an item enforces revisions.
     * @param itemId itemId of the item.
     * @return True if the item enforces revisions.
     */
    function getEnforceRevisions(bytes32 itemId) external view returns (bool);

    /**
     * @dev Determine if an item is retractable.
     * @param itemId itemId of the item.
     * @return retractable True if the item is item retractable.
     */
    function getRetractable(bytes32 itemId) external view returns (bool);

    /**
     * @dev Determine if an item is transferable.
     * @param itemId itemId of the item.
     * @return True if the item is transferable.
     */
    function getTransferable(bytes32 itemId) external view returns (bool);

    /**
     * @dev Get the owner of an item.
     * @param itemId itemId of the item.
     * @return Owner of the item.
     */
    function getOwner(bytes32 itemId) external view returns (address);

    /**
     * @dev Get the number of revisions an item has.
     * @param itemId itemId of the item.
     * @return How many revisions the item has.
     */
    function getRevisionCount(bytes32 itemId) external view returns (uint);

    /**
     * @dev Get the timestamp for a specific item revision.
     * @param itemId itemId of the item.
     * @param revisionId Id of the revision.
     * @return Timestamp of the specified revision.
     */
    function getRevisionTimestamp(bytes32 itemId, uint revisionId) external view returns (uint);

    /**
     * @dev Get the timestamps for all of an item's revisions.
     * @param itemId itemId of the item.
     * @return Timestamps of all revisions of the item.
     */
    function getAllRevisionTimestamps(bytes32 itemId) external view returns (uint[] memory);

}
