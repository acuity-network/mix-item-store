pragma solidity ^0.4.4;

import "./blobstore.sol";


/**
 * @title BlobStoreProxy
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 * @dev Proxy contract for accessing a BlobStore contract from a different address for testing purposes.
 */
contract BlobStoreProxy is AbstractBlobStore {

    BlobStore blobStore;

    /**
     * @dev Constructor.
     * @param _blobStore Real BlobStore contract to proxy to.
     */
    function BlobStoreProxy(BlobStore _blobStore) {
        blobStore = _blobStore;
    }

    /**
     * @dev Creates a new blob. It is guaranteed that different users will never receive the same blobId, even before consensus has been reached. This prevents blobId sniping. Consider createWithNonce() if not calling from another contract.
     * @param flags Packed blob settings.
     * @param contents Contents of the blob to be stored.
     * @return blobId Id of the blob.
     */
    function create(bytes4 flags, bytes contents) external returns (bytes20 blobId) {
        blobId = blobStore.create(flags, contents);
    }

    /**
     * @dev Creates a new blob using provided nonce. It is guaranteed that different users will never receive the same blobId, even before consensus has been reached. This prevents blobId sniping. This method is cheaper than create(), especially if multiple blobs from the same account end up in the same block. However, it is not suitable for calling from other contracts because it will throw if a unique nonce is not provided.
     * @param flagsNonce First 4 bytes: Packed blob settings. The parameter as a whole must never have been passed to this function from the same account, or it will throw.
     * @param contents Contents of the blob to be stored.
     * @return blobId Id of the blob.
     */
    function createWithNonce(bytes32 flagsNonce, bytes contents) external returns (bytes20 blobId) {
        blobId = blobStore.createWithNonce(flagsNonce, contents);
    }

    /**
     * @dev Create a new blob revision.
     * @param blobId Id of the blob.
     * @param contents Contents of the new revision.
     * @return revisionId The new revisionId.
     */
    function createNewRevision(bytes20 blobId, bytes contents) external returns (uint revisionId) {
        revisionId = blobStore.createNewRevision(blobId, contents);
    }

    /**
     * @dev Update a blob's latest revision.
     * @param blobId Id of the blob.
     * @param contents Contents that should replace the latest revision.
     */
    function updateLatestRevision(bytes20 blobId, bytes contents) external {
        blobStore.updateLatestRevision(blobId, contents);
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
     * @param contents Contents that should be stored.
     */
    function restart(bytes20 blobId, bytes contents) external {
        blobStore.restart(blobId, contents);
    }

    /**
     * @dev Retract a blob.
     * @param blobId Id of the blob. This blobId can never be used again.
     */
    function retract(bytes20 blobId) external {
        blobStore.retract(blobId);
    }

    /**
     * @dev Enable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferEnable(bytes20 blobId) external {
        blobStore.transferEnable(blobId);
    }

    /**
     * @dev Disable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferDisable(bytes20 blobId) external {
        blobStore.transferDisable(blobId);
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
     * @dev Set a blob as not updatable.
     * @param blobId Id of the blob.
     */
    function setNotUpdatable(bytes20 blobId) external {
        blobStore.setNotUpdatable(blobId);
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
     * @dev Get the id for this BlobStore contract.
     * @return Id of the contract.
     */
    function getContractId() external constant returns (bytes12) {
        return blobStore.getContractId();
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
     * @dev Get info about a blob.
     * @param blobId Id of the blob.
     * @return flags Packed blob settings.
     * @return owner Owner of the blob.
     * @return revisionCount How many revisions the blob has.
     * @return blockNumbers The block numbers of the revisions.
     */
    function getInfo(bytes20 blobId) external constant returns (bytes4 flags, address owner, uint revisionCount, uint[] blockNumbers) {
//        (flags, owner, revisionCount, blockNumbers) = blobStore.getInfo(blobId);
    }

    /**
     * @dev Get all a blob's flags.
     * @param blobId Id of the blob.
     * @return flags Packed blob settings.
     */
    function getFlags(bytes20 blobId) external constant returns (bytes4 flags) {
        flags = blobStore.getFlags(blobId);
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

    /**
     * @dev Get the block numbers for all of a blob's revisions.
     * @param blobId Id of the blob.
     * @return blockNumbers Revision block numbers.
     */
    function getAllRevisionBlockNumbers(bytes20 blobId) external constant returns (uint[] blockNumbers) {
//        blockNumbers = blobStore.getAllRevisionBlockNumbers(blobId);
    }

}
