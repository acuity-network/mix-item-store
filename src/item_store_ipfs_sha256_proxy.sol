pragma solidity ^0.4.14;

import "./itemstore_interface.sol";
import "./itemstore_ipfs_sha256.sol";


/**
 * @title ItemStoreIpfsSha256Proxy
 * @author Jonathan Brown <jbrown@link-blockchain.org>
 * @dev Proxy contract for accessing a ItemStoreIpfsSha256Proxy contract from a different address for testing purposes.
 */
contract ItemStoreIpfsSha256Proxy is ItemStoreInterface {

    ItemStoreIpfsSha256 itemStore;

    /**
     * @dev Constructor.
     * @param _itemStore Real ItemStore contract to proxy to.
     */
    function ItemStoreIpfsSha256Proxy(ItemStoreIpfsSha256 _itemStore) {
        itemStore = _itemStore;
    }

    /**
     * @dev Create a new item revision.
     * @param itemId Id of the item.
     * @param ipfsHash Hash of the IPFS object where the item revision is stored.
     * @return revisionId The new revisionId.
     */
    function createNewRevision(bytes20 itemId, bytes32 ipfsHash) external returns (uint revisionId) {
        revisionId = itemStore.createNewRevision(itemId, ipfsHash);
    }

    /**
     * @dev Update an item's latest revision.
     * @param itemId Id of the item.
     * @param ipfsHash Hash of the IPFS object where the item revision is stored.
     */
    function updateLatestRevision(bytes20 itemId, bytes32 ipfsHash) external {
        itemStore.updateLatestRevision(itemId, ipfsHash);
    }

    /**
     * @dev Retract an item's latest revision. Revision 0 cannot be retracted.
     * @param itemId Id of the item.
     */
    function retractLatestRevision(bytes20 itemId) external {
        itemStore.retractLatestRevision(itemId);
    }

    /**
     * @dev Delete all an item's revisions and replace it with a new item.
     * @param itemId Id of the item.
     * @param ipfsHash Hash of the IPFS object where the item revision is stored.
     */
    function restart(bytes20 itemId, bytes32 ipfsHash) external {
        itemStore.restart(itemId, ipfsHash);
    }

    /**
     * @dev Retract an item.
     * @param itemId Id of the item. This itemId can never be used again.
     */
    function retract(bytes20 itemId) external {
        itemStore.retract(itemId);
    }

    /**
     * @dev Transfer an item to a new user.
     * @param itemId Id of the item.
     * @param recipient Address of the user to transfer to item to.
     */
    function transfer(bytes20 itemId, address recipient) external {
        itemStore.transfer(itemId, recipient);
    }

    /**
     * @dev Disown an item.
     * @param itemId Id of the item.
     */
    function disown(bytes20 itemId) external {
        itemStore.disown(itemId);
    }

    /**
     * @dev Set an item to enforce revisions.
     * @param itemId Id of the item.
     */
    function setEnforceRevisions(bytes20 itemId) external {
        itemStore.setEnforceRevisions(itemId);
    }

    /**
     * @dev Set an item to not be retractable.
     * @param itemId Id of the item.
     */
    function setNotRetractable(bytes20 itemId) external {
        itemStore.setNotRetractable(itemId);
    }

    /**
     * @dev Set an item to not be transferable.
     * @param itemId Id of the item.
     */
    function setNotTransferable(bytes20 itemId) external {
        itemStore.setNotTransferable(itemId);
    }

    /**
     * @dev Enable transfer of an item to the current user.
     * @param itemId Id of the item.
     */
    function transferEnable(bytes20 itemId) external {
        itemStore.transferEnable(itemId);
    }

    /**
     * @dev Disable transfer of an item to the current user.
     * @param itemId Id of the item.
     */
    function transferDisable(bytes20 itemId) external {
        itemStore.transferDisable(itemId);
    }

    /**
     * @dev Set an item as not updatable.
     * @param itemId Id of the item.
     */
    function setNotUpdatable(bytes20 itemId) external {
        itemStore.setNotUpdatable(itemId);
    }




    /**
     * @dev Get the id for this ItemStore contract.
     * @return Id of the contract.
     */
    function getContractId() external constant returns (bytes12 contractId) {
        contractId = itemStore.getContractId();
    }

    /**
     * @dev Check if an item exists.
     * @param itemId Id of the item.
     * @return exists True if the item exists.
     */
    function getExists(bytes20 itemId) external constant returns (bool exists) {
        exists = itemStore.getExists(itemId);
    }

    /**
     * @dev Determine if an item is updatable.
     * @param itemId Id of the item.
     * @return updatable True if the item is updatable.
     */
    function getUpdatable(bytes20 itemId) external constant returns (bool updatable) {
        updatable = itemStore.getUpdatable(itemId);
    }

    /**
     * @dev Determine if an item enforces revisions.
     * @param itemId Id of the item.
     * @return enforceRevisions True if the item enforces revisions.
     */
    function getEnforceRevisions(bytes20 itemId) external constant returns (bool enforceRevisions) {
        enforceRevisions = itemStore.getEnforceRevisions(itemId);
    }

    /**
     * @dev Determine if an item is retractable.
     * @param itemId Id of the item.
     * @return retractable True if the item is item retractable.
     */
    function getRetractable(bytes20 itemId) external constant returns (bool retractable) {
        retractable = itemStore.getRetractable(itemId);
    }

    /**
     * @dev Determine if an item is transferable.
     * @param itemId Id of the item.
     * @return transferable True if the item is transferable.
     */
    function getTransferable(bytes20 itemId) external constant returns (bool transferable) {
        transferable = itemStore.getTransferable(itemId);
    }

    /**
     * @dev Get the owner of an item.
     * @param itemId Id of the item.
     * @return owner Owner of the item.
     */
    function getOwner(bytes20 itemId) external constant returns (address owner) {
        owner = itemStore.getOwner(itemId);
    }

    /**
     * @dev Get the number of revisions an item has.
     * @param itemId Id of the item.
     * @return revisionCount How many revisions the item has.
     */
    function getRevisionCount(bytes20 itemId) external constant returns (uint revisionCount) {
        revisionCount = itemStore.getRevisionCount(itemId);
    }

}
