pragma solidity ^0.4.11;

import "./blobstore_ipfs_sha256.sol";


/**
 * @title BlobStoreProxy
 * @author Jonathan Brown <jbrown@link-blockchain.org>
 * @dev Proxy contract for accessing a BlobStore contract from a different address for testing purposes.
 */
contract BlobStoreIpfsSha256Proxy is BlobStoreInterface {

    BlobStoreIpfsSha256 blobStore;

    /**
     * @dev Constructor.
     * @param _blobStore Real BlobStore contract to proxy to.
     */
    function BlobStoreIpfsSha256Proxy(BlobStoreIpfsSha256 _blobStore) {
        blobStore = _blobStore;
    }

    /**
     * @dev Create a new blob revision.
     * @param blobId Id of the blob.
     * @param ipfsHash Hash of the IPFS object where the blob revision is stored.
     * @return revisionId The new revisionId.
     */
    function createNewRevision(bytes20 blobId, bytes32 ipfsHash) external returns (uint revisionId) {
        revisionId = blobStore.createNewRevision(blobId, ipfsHash);
    }

    /**
     * @dev Update a blob's latest revision.
     * @param blobId Id of the blob.
     * @param ipfsHash Hash of the IPFS object where the blob revision is stored.
     */
    function updateLatestRevision(bytes20 blobId, bytes32 ipfsHash) external {
        blobStore.updateLatestRevision(blobId, ipfsHash);
    }

    /**
     * @dev Retract a blob's latest revision. Revision 0 cannot be retracted.
     * @param blobId Id of the blob.
     */
    function retractLatestRevision(bytes20 blobId) external {
        blobStore.retractLatestRevision(blobId);
    }

    /**
     * @dev Delete all a blob's revisions and replace it with a new blob.
     * @param blobId Id of the blob.
     * @param ipfsHash Hash of the IPFS object where the blob revision is stored.
     */
    function restart(bytes20 blobId, bytes32 ipfsHash) external {
        blobStore.restart(blobId, ipfsHash);
    }

    /**
     * @dev Retract a blob.
     * @param blobId Id of the blob. This blobId can never be used again.
     */
    function retract(bytes20 blobId) external {
        blobStore.retract(blobId);
    }

    /**
     * @dev Transfer a blob to a new user.
     * @param blobId Id of the blob.
     * @param recipient Address of the user to transfer to blob to.
     */
    function transfer(bytes20 blobId, address recipient) external {
        blobStore.transfer(blobId, recipient);
    }

    /**
     * @dev Disown a blob.
     * @param blobId Id of the blob.
     */
    function disown(bytes20 blobId) external {
        blobStore.disown(blobId);
    }

    /**
     * @dev Set a blob to enforce revisions.
     * @param blobId Id of the blob.
     */
    function setEnforceRevisions(bytes20 blobId) external {
        blobStore.setEnforceRevisions(blobId);
    }

    /**
     * @dev Set a blob to not be retractable.
     * @param blobId Id of the blob.
     */
    function setNotRetractable(bytes20 blobId) external {
        blobStore.setNotRetractable(blobId);
    }

    /**
     * @dev Set a blob to not be transferable.
     * @param blobId Id of the blob.
     */
    function setNotTransferable(bytes20 blobId) external {
        blobStore.setNotTransferable(blobId);
    }

    /**
     * @dev Enable transfer of a blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferEnable(bytes20 blobId) external {
        blobStore.transferEnable(blobId);
    }

    /**
     * @dev Disable transfer of a blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferDisable(bytes20 blobId) external {
        blobStore.transferDisable(blobId);
    }

    /**
     * @dev Set a blob as not updatable.
     * @param blobId Id of the blob.
     */
    function setNotUpdatable(bytes20 blobId) external {
        blobStore.setNotUpdatable(blobId);
    }




    /**
     * @dev Get the id for this BlobStore contract.
     * @return Id of the contract.
     */
    function getContractId() external constant returns (bytes12 contractId) {
        contractId = blobStore.getContractId();
    }

    /**
     * @dev Check if a blob exists.
     * @param blobId Id of the blob.
     * @return exists True if the blob exists.
     */
    function getExists(bytes20 blobId) external constant returns (bool exists) {
        exists = blobStore.getExists(blobId);
    }

    /**
     * @dev Determine if a blob is updatable.
     * @param blobId Id of the blob.
     * @return updatable True if the blob is updatable.
     */
    function getUpdatable(bytes20 blobId) external constant returns (bool updatable) {
        updatable = blobStore.getUpdatable(blobId);
    }

    /**
     * @dev Determine if a blob enforces revisions.
     * @param blobId Id of the blob.
     * @return enforceRevisions True if the blob enforces revisions.
     */
    function getEnforceRevisions(bytes20 blobId) external constant returns (bool enforceRevisions) {
        enforceRevisions = blobStore.getEnforceRevisions(blobId);
    }

    /**
     * @dev Determine if a blob is retractable.
     * @param blobId Id of the blob.
     * @return retractable True if the blob is blob retractable.
     */
    function getRetractable(bytes20 blobId) external constant returns (bool retractable) {
        retractable = blobStore.getRetractable(blobId);
    }

    /**
     * @dev Determine if a blob is transferable.
     * @param blobId Id of the blob.
     * @return transferable True if the blob is transferable.
     */
    function getTransferable(bytes20 blobId) external constant returns (bool transferable) {
        transferable = blobStore.getTransferable(blobId);
    }

    /**
     * @dev Get the owner of a blob.
     * @param blobId Id of the blob.
     * @return owner Owner of the blob.
     */
    function getOwner(bytes20 blobId) external constant returns (address owner) {
        owner = blobStore.getOwner(blobId);
    }

    /**
     * @dev Get the number of revisions a blob has.
     * @param blobId Id of the blob.
     * @return revisionCount How many revisions the blob has.
     */
    function getRevisionCount(bytes20 blobId) external constant returns (uint revisionCount) {
        revisionCount = blobStore.getRevisionCount(blobId);
    }

}
