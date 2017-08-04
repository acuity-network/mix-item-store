pragma solidity ^0.4.14;


/**
 * @title ItemStoreInterface
 * @author Jonathan Brown <jbrown@link-blockchain.org>
 * @dev ItemStore implementation interface.
 */
interface ItemStoreInterface {

    /**
     * @dev A revision has been retracted.
     * @param itemId Id of the item.
     * @param revisionId Id of the revision.
     */
    event RetractRevision(bytes20 indexed itemId, uint revisionId);

    /**
     * @dev An entire item has been retracted. This cannot be undone.
     * @param itemId Id of the item.
     */
    event Retract(bytes20 indexed itemId);

    /**
     * @dev An item has been transfered to a new owner.
     * @param itemId Id of the item.
     * @param recipient The address that now owns the item.
     */
    event Transfer(bytes20 indexed itemId, address recipient);

    /**
     * @dev An item has been disowned. This cannot be undone.
     * @param itemId Id of the item.
     */
    event Disown(bytes20 indexed itemId);

    /**
     * @dev An item has been set as not updatable. This cannot be undone.
     * @param itemId Id of the item.
     */
    event SetNotUpdatable(bytes20 indexed itemId);

    /**
     * @dev An item has been set as enforcing revisions. This cannot be undone.
     * @param itemId Id of the item.
     */
    event SetEnforceRevisions(bytes20 indexed itemId);

    /**
     * @dev An item has been set as not retractable. This cannot be undone.
     * @param itemId Id of the item.
     */
    event SetNotRetractable(bytes20 indexed itemId);

    /**
     * @dev An item has been set as not transferable. This cannot be undone.
     * @param itemId Id of the item.
     */
    event SetNotTransferable(bytes20 indexed itemId);

    /**
     * @dev Retract an item's latest revision. Revision 0 cannot be retracted.
     * @param itemId Id of the item.
     */
    function retractLatestRevision(bytes20 itemId) external;

    /**
     * @dev Retract an item.
     * @param itemId Id of the item. This itemId can never be used again.
     */
    function retract(bytes20 itemId) external;

    /**
     * @dev Enable transfer of an item to the current user.
     * @param itemId Id of the item.
     */
    function transferEnable(bytes20 itemId) external;

    /**
     * @dev Disable transfer of an item to the current user.
     * @param itemId Id of the item.
     */
    function transferDisable(bytes20 itemId) external;

    /**
     * @dev Transfer an item to a new user.
     * @param itemId Id of the item.
     * @param recipient Address of the user to transfer to item to.
     */
    function transfer(bytes20 itemId, address recipient) external;

    /**
     * @dev Disown an item.
     * @param itemId Id of the item.
     */
    function disown(bytes20 itemId) external;

    /**
     * @dev Set an item as not updatable.
     * @param itemId Id of the item.
     */
    function setNotUpdatable(bytes20 itemId) external;

    /**
     * @dev Set an item to enforce revisions.
     * @param itemId Id of the item.
     */
    function setEnforceRevisions(bytes20 itemId) external;

    /**
     * @dev Set an item to not be retractable.
     * @param itemId Id of the item.
     */
    function setNotRetractable(bytes20 itemId) external;

    /**
     * @dev Set an item to not be transferable.
     * @param itemId Id of the item.
     */
    function setNotTransferable(bytes20 itemId) external;

    /**
     * @dev Get the id for this ItemStore contract.
     * @return Id of the contract.
     */
    function getContractId() external constant returns (bytes12 contractId);

    /**
     * @dev Check if an item exists.
     * @param itemId Id of the item.
     * @return exists True if the item exists.
     */
    function getExists(bytes20 itemId) external constant returns (bool exists);

    /**
     * @dev Determine if an item is updatable.
     * @param itemId Id of the item.
     * @return updatable True if the item is updatable.
     */
    function getUpdatable(bytes20 itemId) external constant returns (bool updatable);

    /**
     * @dev Determine if an item enforces revisions.
     * @param itemId Id of the item.
     * @return enforceRevisions True if the item enforces revisions.
     */
    function getEnforceRevisions(bytes20 itemId) external constant returns (bool enforceRevisions);

    /**
     * @dev Determine if an item is retractable.
     * @param itemId Id of the item.
     * @return retractable True if the item is item retractable.
     */
    function getRetractable(bytes20 itemId) external constant returns (bool retractable);

    /**
     * @dev Determine if an item is transferable.
     * @param itemId Id of the item.
     * @return transferable True if the item is transferable.
     */
    function getTransferable(bytes20 itemId) external constant returns (bool transferable);

    /**
     * @dev Get the owner of an item.
     * @param itemId Id of the item.
     * @return owner Owner of the item.
     */
    function getOwner(bytes20 itemId) external constant returns (address owner);

    /**
     * @dev Get the number of revisions an item has.
     * @param itemId Id of the item.
     * @return revisionCount How many revisions the item has.
     */
    function getRevisionCount(bytes20 itemId) external constant returns (uint revisionCount);

}
