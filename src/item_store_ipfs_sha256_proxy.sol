pragma solidity ^0.5.0;

import "./item_store_interface.sol";
import "./item_store_ipfs_sha256.sol";


/**
 * @title ItemStoreIpfsSha256Proxy
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Proxy contract for accessing a ItemStoreIpfsSha256 contract from a different address for testing purposes.
 */
contract ItemStoreIpfsSha256Proxy is ItemStoreInterface {

    ItemStoreIpfsSha256 itemStore;

    /**
     * @param _itemStore Real ItemStore contract to proxy to.
     */
    constructor (ItemStoreIpfsSha256 _itemStore) public {
        itemStore = _itemStore;
    }

    function getNewItemId(bytes32 nonce) public view returns (bytes32 itemId) {
        itemId = itemStore.getNewItemId(nonce);
    }

    function create(bytes32 flagsNonce, bytes32 ipfsHash) external returns (bytes32 itemId) {
        itemId = itemStore.create(flagsNonce, ipfsHash);
    }

    function createWithParent(bytes32 flagsNonce, bytes32 ipfsHash, bytes32 parentId) external returns (bytes32 itemId) {
        itemId = itemStore.createWithParent(flagsNonce, ipfsHash, parentId);
    }

    function createWithParents(bytes32 flagsNonce, bytes32 ipfsHash, bytes32[] calldata parentIds) external returns (bytes32 itemId) {
        itemId = itemStore.createWithParents(flagsNonce, ipfsHash, parentIds);
    }

    function addForeignChild(bytes32 itemId, bytes32 child) external {
        itemStore.addForeignChild(itemId, child);
    }

    function createNewRevision(bytes32 itemId, bytes32 ipfsHash) external returns (uint revisionId) {
        revisionId = itemStore.createNewRevision(itemId, ipfsHash);
    }

    function updateLatestRevision(bytes32 itemId, bytes32 ipfsHash) external {
        itemStore.updateLatestRevision(itemId, ipfsHash);
    }

    function retractLatestRevision(bytes32 itemId) external {
        itemStore.retractLatestRevision(itemId);
    }

    function restart(bytes32 itemId, bytes32 ipfsHash) external {
        itemStore.restart(itemId, ipfsHash);
    }

    function retract(bytes32 itemId) external {
        itemStore.retract(itemId);
    }

    function transfer(bytes32 itemId, address recipient) external {
        itemStore.transfer(itemId, recipient);
    }

    function disown(bytes32 itemId) external {
        itemStore.disown(itemId);
    }

    function setEnforceRevisions(bytes32 itemId) external {
        itemStore.setEnforceRevisions(itemId);
    }

    function setNotRetractable(bytes32 itemId) external {
        itemStore.setNotRetractable(itemId);
    }

    function setNotTransferable(bytes32 itemId) external {
        itemStore.setNotTransferable(itemId);
    }

    function transferEnable(bytes32 itemId) external {
        itemStore.transferEnable(itemId);
    }

    function transferDisable(bytes32 itemId) external {
        itemStore.transferDisable(itemId);
    }

    function setNotUpdatable(bytes32 itemId) external {
        itemStore.setNotUpdatable(itemId);
    }

    function getAbiVersion() external view returns (uint) {
        return itemStore.getAbiVersion();
    }

    function getContractId() external view returns (bytes8) {
        return itemStore.getContractId();
    }

    function getInUse(bytes32 itemId) public view returns (bool) {
        return itemStore.getInUse(itemId);
    }

    function getUpdatable(bytes32 itemId) external view returns (bool) {
        return itemStore.getUpdatable(itemId);
    }

    function getEnforceRevisions(bytes32 itemId) external view returns (bool) {
        return itemStore.getEnforceRevisions(itemId);
    }

    function getRetractable(bytes32 itemId) external view returns (bool) {
        return itemStore.getRetractable(itemId);
    }

    function getTransferable(bytes32 itemId) external view returns (bool) {
        return itemStore.getTransferable(itemId);
    }

    function getOwner(bytes32 itemId) external view returns (address) {
        return itemStore.getOwner(itemId);
    }

    function getRevisionCount(bytes32 itemId) external view returns (uint) {
        return itemStore.getRevisionCount(itemId);
    }

    function getParentCount(bytes32 itemId) external view returns (uint) {
        return itemStore.getParentCount(itemId);
    }

    function getParentId(bytes32 itemId, uint i) external view returns (bytes32) {
        return itemStore.getParentId(itemId, i);
    }

    function getChildCount(bytes32 itemId) external view returns (uint) {
        return itemStore.getChildCount(itemId);
    }

    function getChildId(bytes32 itemId, uint i) external view returns (bytes32) {
        return itemStore.getChildId(itemId, i);
    }

}
