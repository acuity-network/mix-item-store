pragma solidity ^0.4.11;

import "./blobstore_interface.sol";
import "./blobstore_registry.sol";


/**
 * @title BlobStoreIpfsSha256
 * @author Jonathan Brown <jbrown@link-blockchain.org>
 * @dev BlobStore implementation where each blob revision is a SHA256 IPFS hash.
 */
contract BlobStoreIpfsSha256 is BlobStoreInterface {

    enum State { Unused, Exists, Retracted }

    byte constant UPDATABLE = 0x01;           // True if the blob is updatable. After creation can only be disabled.
    byte constant ENFORCE_REVISIONS = 0x02;   // True if the blob is enforcing revisions. After creation can only be enabled.
    byte constant RETRACTABLE = 0x04;         // True if the blob can be retracted. After creation can only be disabled.
    byte constant TRANSFERABLE = 0x08;        // True if the blob be transfered to another user or disowned. After creation can only be disabled.
    byte constant ANONYMOUS = 0x10;           // True if the blob should not have an owner.

    /**
     * @dev Single slot structure of blob info.
     */
    struct BlobInfo {
        State state;            // Unused, exists or retracted.
        byte flags;             // Packed blob settings.
        uint32 revisionCount;   // Number of revisions including revision 0.
        address owner;          // Who owns this blob.
    }

    /**
     * @dev Mapping of blobId to blob info.
     */
    mapping (bytes20 => BlobInfo) blobInfo;

    /**
     * @dev Mapping of blobId to mapping of revision number to IPFS hash.
     */
    mapping (bytes20 => mapping (uint => bytes32)) blobRevisionIpfsHashes;

    /**
     * @dev Mapping of blobId to mapping of transfer recipient addresses to enabled.
     */
    mapping (bytes20 => mapping (address => bool)) enabledTransfers;

    /**
     * @dev Id of this instance of BlobStore. Unique across all blockchains.
     */
    bytes12 contractId;

    /**
     * @dev A blob revision has been published.
     * @param blobId Id of the blob.
     * @param revisionId Id of the revision (the highest at time of logging).
     * @param ipfsHash Hash of the IPFS object where the blob revision is stored.
     */
    event Publish(bytes20 indexed blobId, uint revisionId, bytes32 ipfsHash);

    /**
     * @dev Revert if the blob has not been used before or it has been retracted.
     * @param blobId Id of the blob.
     */
    modifier exists(bytes20 blobId) {
        require (blobInfo[blobId].state == State.Exists);
        _;
    }

    /**
     * @dev Revert if the owner of the blob is not the message sender.
     * @param blobId Id of the blob.
     */
    modifier isOwner(bytes20 blobId) {
        require (blobInfo[blobId].owner == msg.sender);
        _;
    }

    /**
     * @dev Revert if the blob is not updatable.
     * @param blobId Id of the blob.
     */
    modifier isUpdatable(bytes20 blobId) {
        require (blobInfo[blobId].flags & UPDATABLE != 0);
        _;
    }

    /**
     * @dev Revert if the blob is not enforcing revisions.
     * @param blobId Id of the blob.
     */
    modifier isNotEnforceRevisions(bytes20 blobId) {
        require (blobInfo[blobId].flags & ENFORCE_REVISIONS == 0);
        _;
    }

    /**
     * @dev Revert if the blob is not retractable.
     * @param blobId Id of the blob.
     */
    modifier isRetractable(bytes20 blobId) {
        require (blobInfo[blobId].flags & RETRACTABLE != 0);
        _;
    }

    /**
     * @dev Revert if the blob is not transferable.
     * @param blobId Id of the blob.
     */
    modifier isTransferable(bytes20 blobId) {
        require (blobInfo[blobId].flags & TRANSFERABLE != 0);
        _;
    }

    /**
     * @dev Revert if the blob is not transferable to a specific user.
     * @param blobId Id of the blob.
     * @param recipient Address of the user.
     */
    modifier isTransferEnabled(bytes20 blobId, address recipient) {
        require (enabledTransfers[blobId][recipient]);
        _;
    }

    /**
     * @dev Revert if the blob only has one revision.
     * @param blobId Id of the blob.
     */
    modifier hasAdditionalRevisions(bytes20 blobId) {
        require (blobInfo[blobId].revisionCount > 1);
        _;
    }

    /**
     * @dev Revert if a specific blob revision does not exist.
     * @param blobId Id of the blob.
     * @param revisionId Id of the revision.
     */
    modifier revisionExists(bytes20 blobId, uint revisionId) {
        require (revisionId < blobInfo[blobId].revisionCount);
        _;
    }

    /**
     * @dev Constructor.
     * @param registry Address of BlobStoreRegistry contract to register with.
     */
    function BlobStoreIpfsSha256(BlobStoreRegistry registry) {
        // Create id for this contract.
        contractId = bytes12(keccak256(this, block.blockhash(block.number - 1)));
        // Register this contract.
        registry.register(contractId);
    }

    /**
     * @dev Creates a new blob. It is guaranteed that different users will never receive the same blobId, even before consensus has been reached. This prevents blobId sniping.
     * @param flags Packed blob settings.
     * @param ipfsHash Hash of the IPFS object where the blob revision is stored.
     * @param nonce Unique value that this user has never used before to create a new blob.
     * @return blobId Id of the blob.
     */
    function create(byte flags, bytes32 ipfsHash, bytes32 nonce) external returns (bytes20 blobId) {
        // Generate the blobId.
        blobId = bytes20(keccak256(msg.sender, nonce));
        // Make sure this blobId has not been used before.
        require (blobInfo[blobId].state == State.Unused);
        // Store blob info in state.
        blobInfo[blobId] = BlobInfo({
            state: State.Exists,
            flags: flags,
            revisionCount: 1,
            owner: (flags & ANONYMOUS == 0) ? msg.sender : 0,
        });
        // Store the IPFS hash.
        blobRevisionIpfsHashes[blobId][0] = ipfsHash;
        // Log the first revision.
        Publish(blobId, 0, ipfsHash);
    }

    /**
     * @dev Create a new blob revision.
     * @param blobId Id of the blob.
     * @param ipfsHash Hash of the IPFS object where the blob revision is stored.
     * @return revisionId The new revisionId.
     */
    function createNewRevision(bytes20 blobId, bytes32 ipfsHash) external isOwner(blobId) isUpdatable(blobId) returns (uint revisionId) {
        // Increment the number of revisions.
        revisionId = blobInfo[blobId].revisionCount++;
        // Store the IPFS hash.
        blobRevisionIpfsHashes[blobId][revisionId] = ipfsHash;
        // Log the revision.
        Publish(blobId, revisionId, ipfsHash);
    }

    /**
     * @dev Update a blob's latest revision.
     * @param blobId Id of the blob.
     * @param ipfsHash Hash of the IPFS object where the blob revision is stored.
     */
    function updateLatestRevision(bytes20 blobId, bytes32 ipfsHash) external isOwner(blobId) isUpdatable(blobId) isNotEnforceRevisions(blobId) {
        uint revisionId = blobInfo[blobId].revisionCount - 1;
        // Update the IPFS hash.
        blobRevisionIpfsHashes[blobId][revisionId] = ipfsHash;
        // Log the revision.
        Publish(blobId, revisionId, ipfsHash);
    }

    /**
     * @dev Retract a blob's latest revision. Revision 0 cannot be retracted.
     * @param blobId Id of the blob.
     */
    function retractLatestRevision(bytes20 blobId) external isOwner(blobId) isUpdatable(blobId) isNotEnforceRevisions(blobId) hasAdditionalRevisions(blobId) {
        // Decrement the number of revisions.
        uint revisionId = --blobInfo[blobId].revisionCount;
        // Delete the IPFS hash.
        delete blobRevisionIpfsHashes[blobId][revisionId];
        // Log the revision retraction.
        RetractRevision(blobId, revisionId);
    }

    /**
     * @dev Delete all a blob's revisions and replace it with a new blob.
     * @param blobId Id of the blob.
     * @param ipfsHash Hash of the IPFS object where the blob revision is stored.
     */
    function restart(bytes20 blobId, bytes32 ipfsHash) external isOwner(blobId) isUpdatable(blobId) isNotEnforceRevisions(blobId) {
        // Delete all the IPFS hashes except the first one.
        for (uint i = 1; i < blobInfo[blobId].revisionCount; i++) {
            delete blobRevisionIpfsHashes[blobId][i];
        }
        // Update the blob state info.
        blobInfo[blobId].revisionCount = 1;
        // Update the first IPFS hash.
        blobRevisionIpfsHashes[blobId][0] = ipfsHash;
        // Log the revision.
        Publish(blobId, 0, ipfsHash);
    }

    /**
     * @dev Retract a blob.
     * @param blobId Id of the blob. This blobId can never be used again.
     */
    function retract(bytes20 blobId) external isOwner(blobId) isRetractable(blobId) {
        // Delete all the IPFS hashes.
        for (uint i = 0; i < blobInfo[blobId].revisionCount; i++) {
            delete blobRevisionIpfsHashes[blobId][i];
        }
        // Mark this blob as retracted.
        blobInfo[blobId] = BlobInfo({
            state: State.Retracted,
            flags: 0,
            revisionCount: 0,
            owner: 0,
        });
        // Log the blob retraction.
        Retract(blobId);
    }

    /**
     * @dev Enable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferEnable(bytes20 blobId) external isTransferable(blobId) {
        // Record in state that the current user will accept this blob.
        enabledTransfers[blobId][msg.sender] = true;
    }

    /**
     * @dev Disable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferDisable(bytes20 blobId) external isTransferEnabled(blobId, msg.sender) {
        // Record in state that the current user will not accept this blob.
        enabledTransfers[blobId][msg.sender] = false;
    }

    /**
     * @dev Transfer a blob to a new user.
     * @param blobId Id of the blob.
     * @param recipient Address of the user to transfer to blob to.
     */
    function transfer(bytes20 blobId, address recipient) external isOwner(blobId) isTransferable(blobId) isTransferEnabled(blobId, recipient) {
        // Update ownership of the blob.
        blobInfo[blobId].owner = recipient;
        // Disable this transfer in future and free up the slot.
        enabledTransfers[blobId][recipient] = false;
        // Log the transfer.
        Transfer(blobId, recipient);
    }

    /**
     * @dev Disown a blob.
     * @param blobId Id of the blob.
     */
    function disown(bytes20 blobId) external isOwner(blobId) isTransferable(blobId) {
        // Remove the owner from the blob's state.
        delete blobInfo[blobId].owner;
        // Log that the blob has been disowned.
        Disown(blobId);
    }

    /**
     * @dev Set a blob as not updatable.
     * @param blobId Id of the blob.
     */
    function setNotUpdatable(bytes20 blobId) external isOwner(blobId) {
        // Record in state that the blob is not updatable.
        blobInfo[blobId].flags &= ~UPDATABLE;
        // Log that the blob is not updatable.
        SetNotUpdatable(blobId);
    }

    /**
     * @dev Set a blob to enforce revisions.
     * @param blobId Id of the blob.
     */
    function setEnforceRevisions(bytes20 blobId) external isOwner(blobId) {
        // Record in state that all changes to this blob must be new revisions.
        blobInfo[blobId].flags |= ENFORCE_REVISIONS;
        // Log that the blob now enforces new revisions.
        SetEnforceRevisions(blobId);
    }

    /**
     * @dev Set a blob to not be retractable.
     * @param blobId Id of the blob.
     */
    function setNotRetractable(bytes20 blobId) external isOwner(blobId) {
        // Record in state that the blob is not retractable.
        blobInfo[blobId].flags &= ~RETRACTABLE;
        // Log that the blob is not retractable.
        SetNotRetractable(blobId);
    }

    /**
     * @dev Set a blob to not be transferable.
     * @param blobId Id of the blob.
     */
    function setNotTransferable(bytes20 blobId) external isOwner(blobId) {
        // Record in state that the blob is not transferable.
        blobInfo[blobId].flags &= ~TRANSFERABLE;
        // Log that the blob is not transferable.
        SetNotTransferable(blobId);
    }

    /**
     * @dev Get the id for this BlobStore contract.
     * @return Id of the contract.
     */
    function getContractId() external constant returns (bytes12) {
        return contractId;
    }

    /**
     * @dev Check if a blob exists.
     * @param blobId Id of the blob.
     * @return exists True if the blob exists.
     */
    function getExists(bytes20 blobId) external constant returns (bool exists) {
        exists = blobInfo[blobId].state == State.Exists;
    }

    /**
     * @dev Get the IPFS hashes for all of a blob's revisions.
     * @param blobId Id of the blob.
     * @return ipfsHashes Revision IPFS hashes.
     */
    function _getAllRevisionIpfsHashes(bytes20 blobId) internal returns (bytes32[] ipfsHashes) {
        uint revisionCount = blobInfo[blobId].revisionCount;
        ipfsHashes = new bytes32[](revisionCount);
        for (uint revisionId = 0; revisionId < revisionCount; revisionId++) {
            ipfsHashes[revisionId] = blobRevisionIpfsHashes[blobId][revisionId];
        }
    }

    /**
     * @dev Get info about a blob.
     * @param blobId Id of the blob.
     * @return flags Packed blob settings.
     * @return owner Owner of the blob.
     * @return revisionCount How many revisions the blob has.
     * @return ipfsHashes IPFS hash of each revision.
     */
    function getInfo(bytes20 blobId) external constant exists(blobId) returns (byte flags, address owner, uint revisionCount, bytes32[] ipfsHashes) {
        BlobInfo info = blobInfo[blobId];
        flags = info.flags;
        owner = info.owner;
        revisionCount = info.revisionCount;
        ipfsHashes = _getAllRevisionIpfsHashes(blobId);
    }

    /**
     * @dev Get all a blob's flags.
     * @param blobId Id of the blob.
     * @return flags Packed blob settings.
     */
    function getFlags(bytes20 blobId) external constant exists(blobId) returns (byte flags) {
        flags = blobInfo[blobId].flags;
    }

    /**
     * @dev Determine if a blob is updatable.
     * @param blobId Id of the blob.
     * @return updatable True if the blob is updatable.
     */
    function getUpdatable(bytes20 blobId) external constant exists(blobId) returns (bool updatable) {
        updatable = blobInfo[blobId].flags & UPDATABLE != 0;
    }

    /**
     * @dev Determine if a blob enforces revisions.
     * @param blobId Id of the blob.
     * @return enforceRevisions True if the blob enforces revisions.
     */
    function getEnforceRevisions(bytes20 blobId) external constant exists(blobId) returns (bool enforceRevisions) {
        enforceRevisions = blobInfo[blobId].flags & ENFORCE_REVISIONS != 0;
    }

    /**
     * @dev Determine if a blob is retractable.
     * @param blobId Id of the blob.
     * @return retractable True if the blob is blob retractable.
     */
    function getRetractable(bytes20 blobId) external constant exists(blobId) returns (bool retractable) {
        retractable = blobInfo[blobId].flags & RETRACTABLE != 0;
    }

    /**
     * @dev Determine if a blob is transferable.
     * @param blobId Id of the blob.
     * @return transferable True if the blob is transferable.
     */
    function getTransferable(bytes20 blobId) external constant exists(blobId) returns (bool transferable) {
        transferable = blobInfo[blobId].flags & TRANSFERABLE != 0;
    }

    /**
     * @dev Get the owner of a blob.
     * @param blobId Id of the blob.
     * @return owner Owner of the blob.
     */
    function getOwner(bytes20 blobId) external constant exists(blobId) returns (address owner) {
        owner = blobInfo[blobId].owner;
    }

    /**
     * @dev Get the number of revisions a blob has.
     * @param blobId Id of the blob.
     * @return revisionCount How many revisions the blob has.
     */
    function getRevisionCount(bytes20 blobId) external constant exists(blobId) returns (uint revisionCount) {
        revisionCount = blobInfo[blobId].revisionCount;
    }

   /**
     * @dev Get the IPFS hash for a specific blob revision.
     * @param blobId Id of the blob.
     * @param revisionId Id of the revision.
     * @return ipfsHash IPFS hash of the specified revision.
     */
    function getRevisionIpfsHash(bytes20 blobId, uint revisionId) external constant revisionExists(blobId, revisionId) returns (bytes32 ipfsHash) {
        ipfsHash = blobRevisionIpfsHashes[blobId][revisionId];
    }

    /**
     * @dev Get the IPFS hashes for all of a blob's revisions.
     * @param blobId Id of the blob.
     * @return ipfsHashes IPFS hashes of all revisions of the blob.
     */
    function getAllRevisionIpfsHashes(bytes20 blobId) external constant returns (bytes32[] ipfsHashes) {
        ipfsHashes = _getAllRevisionIpfsHashes(blobId);
    }

}
