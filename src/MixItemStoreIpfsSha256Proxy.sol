pragma solidity ^0.6.6;

import "./MixItemStoreInterface.sol";
import "./MixItemStoreIpfsSha256.sol";


contract MixItemStoreIpfsSha256Proxy is MixItemStoreInterface {

    MixItemStoreIpfsSha256 mixItemStoreIpfsSha256;

    constructor (MixItemStoreIpfsSha256 _mixItemStore) public {
        mixItemStoreIpfsSha256 = _mixItemStore;
    }

    function getNewItemId(address owner, bytes32 nonce) override public view returns (bytes32 itemId) {
        itemId = mixItemStoreIpfsSha256.getNewItemId(owner, nonce);
    }

    function create(bytes32 flagsNonce, bytes32 ipfsHash) external returns (bytes32 itemId) {
        itemId = mixItemStoreIpfsSha256.create(flagsNonce, ipfsHash);
    }

    function createNewRevision(bytes32 itemId, bytes32 ipfsHash) external returns (uint revisionId) {
        revisionId = mixItemStoreIpfsSha256.createNewRevision(itemId, ipfsHash);
    }

    function updateLatestRevision(bytes32 itemId, bytes32 ipfsHash) external {
        mixItemStoreIpfsSha256.updateLatestRevision(itemId, ipfsHash);
    }

    function retractLatestRevision(bytes32 itemId) override external {
        mixItemStoreIpfsSha256.retractLatestRevision(itemId);
    }

    function restart(bytes32 itemId, bytes32 ipfsHash) external {
        mixItemStoreIpfsSha256.restart(itemId, ipfsHash);
    }

    function retract(bytes32 itemId) override external {
        mixItemStoreIpfsSha256.retract(itemId);
    }

    function transfer(bytes32 itemId, address recipient) override external {
        mixItemStoreIpfsSha256.transfer(itemId, recipient);
    }

    function disown(bytes32 itemId) override external {
        mixItemStoreIpfsSha256.disown(itemId);
    }

    function setEnforceRevisions(bytes32 itemId) override external {
        mixItemStoreIpfsSha256.setEnforceRevisions(itemId);
    }

    function setNotRetractable(bytes32 itemId) override external {
        mixItemStoreIpfsSha256.setNotRetractable(itemId);
    }

    function setNotTransferable(bytes32 itemId) override external {
        mixItemStoreIpfsSha256.setNotTransferable(itemId);
    }

    function transferEnable(bytes32 itemId) override external {
        mixItemStoreIpfsSha256.transferEnable(itemId);
    }

    function transferDisable(bytes32 itemId) override external {
        mixItemStoreIpfsSha256.transferDisable(itemId);
    }

    function setNotUpdatable(bytes32 itemId) override external {
        mixItemStoreIpfsSha256.setNotUpdatable(itemId);
    }

    function getAbiVersion() override external view returns (uint) {
        return mixItemStoreIpfsSha256.getAbiVersion();
    }

    function getContractId() override external view returns (bytes8) {
        return mixItemStoreIpfsSha256.getContractId();
    }

    function getInUse(bytes32 itemId) override public view returns (bool) {
        return mixItemStoreIpfsSha256.getInUse(itemId);
    }

    function getItem(bytes32 itemId) external view returns (byte flags, address owner, uint[] memory timestamps, bytes32[] memory ipfsHashes) {
        (flags, owner, timestamps, ipfsHashes) = mixItemStoreIpfsSha256.getItem(itemId);
    }

    function getFlags(bytes32 itemId) override external view returns (byte) {
        return mixItemStoreIpfsSha256.getFlags(itemId);
    }

    function getUpdatable(bytes32 itemId) override external view returns (bool) {
        return mixItemStoreIpfsSha256.getUpdatable(itemId);
    }

    function getEnforceRevisions(bytes32 itemId) override external view returns (bool) {
        return mixItemStoreIpfsSha256.getEnforceRevisions(itemId);
    }

    function getRetractable(bytes32 itemId) override external view returns (bool) {
        return mixItemStoreIpfsSha256.getRetractable(itemId);
    }

    function getTransferable(bytes32 itemId) override external view returns (bool) {
        return mixItemStoreIpfsSha256.getTransferable(itemId);
    }

    function getOwner(bytes32 itemId) override external view returns (address) {
        return mixItemStoreIpfsSha256.getOwner(itemId);
    }

    function getRevisionCount(bytes32 itemId) override external view returns (uint) {
        return mixItemStoreIpfsSha256.getRevisionCount(itemId);
    }

    function getRevisionTimestamp(bytes32 itemId, uint revisionId) override external view returns (uint) {
        return mixItemStoreIpfsSha256.getRevisionTimestamp(itemId, revisionId);
    }

    function getAllRevisionTimestamps(bytes32 itemId) override external view returns (uint[] memory) {
        return mixItemStoreIpfsSha256.getAllRevisionTimestamps(itemId);
    }

    function getRevisionIpfsHash(bytes32 itemId, uint revisionId) external view returns (bytes32) {
        return mixItemStoreIpfsSha256.getRevisionIpfsHash(itemId, revisionId);
    }

    function getAllRevisionIpfsHashes(bytes32 itemId) external view returns (bytes32[] memory) {
        return mixItemStoreIpfsSha256.getAllRevisionIpfsHashes(itemId);
    }

}
