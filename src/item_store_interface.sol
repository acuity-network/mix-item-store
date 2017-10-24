pragma solidity ^0.4.18;


/**
 * @title ItemStoreInterface
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev ItemStore implementation interface.
 */
interface ItemStoreInterface {

    /**
     * @dev A child item has been attached to this item.
     * @param parent itemId of the parent.
     * @param child itemId of the new child.
     */
    event AddChild(bytes32 indexed parent, bytes32 child);

    /**
     * @dev A revision has been retracted.
     * @param itemId Id of the item.
     * @param revisionId Id of the revision.
     */
    event RetractRevision(bytes32 indexed itemId, uint revisionId);

    /**
     * @dev An entire item has been retracted. This cannot be undone.
     * @param itemId Id of the item.
     */
    event Retract(bytes32 indexed itemId);

    /**
     * @dev An item has been transfered to a new owner.
     * @param itemId Id of the item.
     * @param recipient The address that now owns the item.
     */
    event Transfer(bytes32 indexed itemId, address recipient);

    /**
     * @dev An item has been disowned. This cannot be undone.
     * @param itemId Id of the item.
     */
    event Disown(bytes32 indexed itemId);

    /**
     * @dev An item has been set as not updatable. This cannot be undone.
     * @param itemId Id of the item.
     */
    event SetNotUpdatable(bytes32 indexed itemId);

    /**
     * @dev An item has been set as enforcing revisions. This cannot be undone.
     * @param itemId Id of the item.
     */
    event SetEnforceRevisions(bytes32 indexed itemId);

    /**
     * @dev An item has been set as not retractable. This cannot be undone.
     * @param itemId Id of the item.
     */
    event SetNotRetractable(bytes32 indexed itemId);

    /**
     * @dev An item has been set as not transferable. This cannot be undone.
     * @param itemId Id of the item.
     */
    event SetNotTransferable(bytes32 indexed itemId);

    /**
     * @dev Add a child from another item store contract.
     * @param itemId itemId of parent.
     * @param child itemId of child.
     */
    function addForeignChild(bytes32 itemId, bytes32 child) external;

    /**
     * @dev Retract an item's latest revision. Revision 0 cannot be retracted.
     * @param itemId Id of the item.
     */
    function retractLatestRevision(bytes32 itemId) external;

    /**
     * @dev Retract an item.
     * @param itemId Id of the item. This itemId can never be used again.
     */
    function retract(bytes32 itemId) external;

    /**
     * @dev Enable transfer of an item to the current user.
     * @param itemId Id of the item.
     */
    function transferEnable(bytes32 itemId) external;

    /**
     * @dev Disable transfer of an item to the current user.
     * @param itemId Id of the item.
     */
    function transferDisable(bytes32 itemId) external;

    /**
     * @dev Transfer an item to a new user.
     * @param itemId Id of the item.
     * @param recipient Address of the user to transfer to item to.
     */
    function transfer(bytes32 itemId, address recipient) external;

    /**
     * @dev Disown an item.
     * @param itemId Id of the item.
     */
    function disown(bytes32 itemId) external;

    /**
     * @dev Set an item as not updatable.
     * @param itemId Id of the item.
     */
    function setNotUpdatable(bytes32 itemId) external;

    /**
     * @dev Set an item to enforce revisions.
     * @param itemId Id of the item.
     */
    function setEnforceRevisions(bytes32 itemId) external;

    /**
     * @dev Set an item to not be retractable.
     * @param itemId Id of the item.
     */
    function setNotRetractable(bytes32 itemId) external;

    /**
     * @dev Set an item to not be transferable.
     * @param itemId Id of the item.
     */
    function setNotTransferable(bytes32 itemId) external;

    /**
     * @dev Get the id for this ItemStore contract.
     * @return Id of the contract.
     */
    function getContractId() external view returns (bytes32);

    /**
     * @dev Check if an itemId is in use.
     * @param itemId Id of the item.
     * @return True if the itemId is in use.
     */
    function getInUse(bytes32 itemId) public view returns (bool);

    /**
     * @dev Determine if an item is updatable.
     * @param itemId Id of the item.
     * @return True if the item is updatable.
     */
    function getUpdatable(bytes32 itemId) external view returns (bool);

    /**
     * @dev Determine if an item enforces revisions.
     * @param itemId Id of the item.
     * @return True if the item enforces revisions.
     */
    function getEnforceRevisions(bytes32 itemId) external view returns (bool);

    /**
     * @dev Determine if an item is retractable.
     * @param itemId Id of the item.
     * @return retractable True if the item is item retractable.
     */
    function getRetractable(bytes32 itemId) external view returns (bool);

    /**
     * @dev Determine if an item is transferable.
     * @param itemId Id of the item.
     * @return True if the item is transferable.
     */
    function getTransferable(bytes32 itemId) external view returns (bool);

    /**
     * @dev Get all an items parent.
     * @return itemId of parent.
     */
    function getParent(bytes32 itemId) external view returns (bytes32);

    /**
     * @dev Get the owner of an item.
     * @param itemId Id of the item.
     * @return Owner of the item.
     */
    function getOwner(bytes32 itemId) external view returns (address);

    /**
     * @dev Get the number of revisions an item has.
     * @param itemId Id of the item.
     * @return How many revisions the item has.
     */
    function getRevisionCount(bytes32 itemId) external view returns (uint);

}
