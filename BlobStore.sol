pragma solidity ^0.4.0;

import "AbstractBlobStore.sol";
import "BlobStoreRegistry.sol";

/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore is AbstractBlobStore {

    struct BlobInfo {               // Single slot.
        bool updatable;             // True if the blob is updatable. After creation can only be disabled.
        bool enforceRevisions;      // True if the blob is enforcing revisions. After creation can only be enabled.
        bool retractable;           // True if the blob can be retracted. After creation can only be disabled.
        bool transferable;          // True if the blob be transfered to another user or disowned. After creation can only be disabled.
        uint32 revisionCount;       // Number of revisions including revision 0.
        uint32 blockNumber;         // Block number which contains revision 0.
        address owner;              // Who owns this blob.
    }

    mapping (bytes32 => BlobInfo) blobInfo;
    mapping (bytes32 => mapping (uint => bytes32)) packedBlockNumbers;
    mapping (bytes32 => mapping (address => bool)) enabledTransfers;

    bytes12 contractId;

    /**
     * @dev A blob revision has been published.
     * @param id Id of the blob.
     * @param revisionId Id of the revision (the highest at time of logging).
     * @param blob Contents of the blob.
     */
    event logBlob(bytes32 indexed id, uint indexed revisionId, bytes blob);

    /**
     * @dev A revision has been retracted.
     * @param id Id of the blob.
     * @param revisionId Id of the revision.
     */
    event logRetractRevision(bytes32 indexed id, uint revisionId);

    /**
     * @dev An entire blob has been retracted. This cannot be undone.
     * @param id Id of the blob.
     */
    event logRetract(bytes32 indexed id);

    /**
     * @dev A blob has been transfered to a new address.
     * @param id Id of the blob.
     * @param recipient The address that now owns the blob.
     */
    event logTransfer(bytes32 indexed id, address recipient);

    /**
     * @dev A blob has been disowned. This cannot be undone.
     * @param id Id of the blob.
     */
    event logDisown(bytes32 indexed id);

    /**
     * @dev A blob has been set as not updatable. This cannot be undone.
     * @param id Id of the blob.
     */
    event logSetNotUpdatable(bytes32 indexed id);

    /**
     * @dev A blob has been set as enforcing revisions. This cannot be undone.
     * @param id Id of the blob.
     */
    event logSetEnforceRevisions(bytes32 indexed id);

    /**
     * @dev A blob has been set as not retractable. This cannot be undone.
     * @param id Id of the blob.
     */
    event logSetNotRetractable(bytes32 indexed id);

    /**
     * @dev A blob has been set as not transferable. This cannot be undone.
     * @param id Id of the blob.
     */
    event logSetNotTransferable(bytes32 indexed id);

    /**
     * @dev Throw if the blob has not been used before or it has been retracted.
     * @param id Id of the blob.
     */
    modifier exists(bytes32 id) {
        BlobInfo info = blobInfo[id];
        if (info.blockNumber == 0 || info.blockNumber == uint32(-1)) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the owner of the blob is not the message sender.
     * @param id Id of the blob.
     */
    modifier isOwner(bytes32 id) {
        if (blobInfo[id].owner != msg.sender) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob is not updatable.
     * @param id Id of the blob.
     */
    modifier isUpdatable(bytes32 id) {
        if (!blobInfo[id].updatable) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob is not enforcing revisions.
     * @param id Id of the blob.
     */
    modifier isNotEnforceRevisions(bytes32 id) {
        if (blobInfo[id].enforceRevisions) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw is the blob is not retractable.
     * @param id Id of the blob.
     */
    modifier isRetractable(bytes32 id) {
        if (!blobInfo[id].retractable) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob is not transferable.
     * @param id Id of the blob.
     */
    modifier isTransferable(bytes32 id) {
        if (!blobInfo[id].transferable) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob is not transferable to a specific user.
     * @param id Id of the blob.
     * @param recipient Address of the user.
     */
    modifier isTransferEnabled(bytes32 id, address recipient) {
        if (!enabledTransfers[id][recipient]) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob only has one revision.
     * @param id Id of the blob.
     */
    modifier hasAdditionalRevisions(bytes32 id) {
        if (blobInfo[id].revisionCount == 1) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if a specific blob revision does not exist.
     * @param id Id of the blob.
     * @param revisionId Id of the revision.
     */
    modifier revisionExists(bytes32 id, uint revisionId) {
        if (revisionId >= blobInfo[id].revisionCount) {
            throw;
        }
        _;
    }

    /**
     * @dev Constructor.
     * @param registry Address of BlobStoreRegistry contract to register with.
     */
    function BlobStore(BlobStoreRegistry registry) {
        // Create a 96-bit id for this contract. This is unique across all blockchains.
        // Wait a few minutes after deploying for this id to settle.
        contractId = bytes12(sha3(this, block.blockhash(block.number - 1)));
        // Register this contract.
        registry.register(contractId);
    }

    /**
     * @dev Stores new blob in the transaction log. It is guaranteed that each user will get a different id from the same nonce.
     * @param blob Blob that should be stored.
     * @param nonce Any value that the user has not used previously to create a blob.
     * @param updatable True if the blob should be updatable.
     * @param enforceRevisions True if the blob should enforce revisions.
     * @param retractable True if the blob should be retractable.
     * @param transferable True if the blob should be transferable.
     * @param anon True if the blob should be anonymous.
     * @return id Id of the blob.
     */
    function create(bytes blob, bytes32 nonce, bool updatable, bool enforceRevisions, bool retractable, bool transferable, bool anon) external returns (bytes32 id) {
        // Determine the id.
        id = contractId | (sha3(msg.sender, nonce) & (2 ** 160 - 1));
        // Make sure this id has not been used before.
        if (blobInfo[id].blockNumber != 0) {
            throw;
        }
        // Store blob info in state.
        blobInfo[id] = BlobInfo({
            updatable: updatable,
            enforceRevisions: enforceRevisions,
            retractable: retractable,
            transferable: transferable,
            revisionCount: 1,
            blockNumber: uint32(block.number),
            owner: anon ? 0 : msg.sender,
        });
        // Store the blob in a log in the current block.
        logBlob(id, 0, blob);
    }

    /**
     * @dev Store a blob revision block number in a packed slot.
     * @param id Id of the blob.
     * @param offset The offset of the block number should be retreived.
     */
    function _setPackedBlockNumber(bytes32 id, uint offset) internal {
        // Get the slot.
        bytes32 slot = packedBlockNumbers[id][offset / 8];
        // Wipe the previous block number.
        slot &= ~bytes32(uint32(-1) * 2 ** ((offset % 8) * 32));
        // Insert the current block number.
        slot |= bytes32(uint32(block.number) * 2 ** ((offset % 8) * 32));
        // Store the slot.
        packedBlockNumbers[id][offset / 8] = slot;
    }

    /**
     * @dev Create a new blob revision.
     * @param id Id of the blob.
     * @param blob Blob that should be stored as the new revision. Typically a VCDIFF of an earlier revision.
     * @return revisionId The new revisionId.
     */
    function createNewRevision(bytes32 id, bytes blob) isOwner(id) isUpdatable(id) external returns (uint revisionId) {
        // Increment the number of revisions.
        revisionId = blobInfo[id].revisionCount++;
        // Store the block number.
        _setPackedBlockNumber(id, revisionId - 1);
        // Store the new blob in a log in the current block.
        logBlob(id, revisionId, blob);
    }

    /**
     * @dev Update a blob's latest revision.
     * @param id Id of the blob.
     * @param blob Blob that should replace the latest revision. Typically a VCDIFF if there is an earlier revision.
     */
    function updateLatestRevision(bytes32 id, bytes blob) isOwner(id) isUpdatable(id) isNotEnforceRevisions(id) external {
        BlobInfo info = blobInfo[id];
        uint revisionId = info.revisionCount - 1;
        // Update the block number.
        if (revisionId == 0) {
            info.blockNumber = uint32(block.number);
        }
        else {
            _setPackedBlockNumber(id, revisionId - 1);
        }
        // Store the new blob in a log in the current block.
        logBlob(id, revisionId, blob);
    }

    /**
     * @dev Retract a blob's latest revision. Revision 0 cannot be retracted.
     * @param id Id of the blob.
     */
    function retractLatestRevision(bytes32 id) isOwner(id) isUpdatable(id) isNotEnforceRevisions(id) hasAdditionalRevisions(id) external {
        uint revisionId = --blobInfo[id].revisionCount;
        // Delete the slot if it is no longer required.
        if (revisionId % 8 == 1) {
            delete packedBlockNumbers[id][revisionId / 8];
        }
        // Log the retraction.
        logRetractRevision(id, revisionId);
    }

    /**
     * @dev Delete all of a blob's packed revision block numbers.
     * @param id Id of the blob.
     */
    function _deleteAllPackedRevisionBlockNumbers(bytes32 id) internal {
        // Determine how many slots should be deleted.
        // Block number of the first revision is stored in the blob info, so the first slot only needs to be deleted of there are at least 2 revisions.
        uint slotCount = (blobInfo[id].revisionCount + 6) / 8;
        // Delete the slots.
        for (uint i = 0; i < slotCount; i++) {
            delete packedBlockNumbers[id][i];
        }
    }

    /**
     * @dev Delete all a blob's revisions and replace it with a new blob.
     * @param id Id of the blob.
     * @param blob Blob that should be stored.
     */
    function restart(bytes32 id, bytes blob) isOwner(id) isUpdatable(id) isNotEnforceRevisions(id) external {
        // Delete the packed revision block numbers.
        _deleteAllPackedRevisionBlockNumbers(id);
        // Update the blob state info.
        BlobInfo info = blobInfo[id];
        info.revisionCount = 1;
        info.blockNumber = uint32(block.number);
        // Store the blob in a log in the current block.
        logBlob(id, 0, blob);
    }

    /**
     * @dev Retract a blob.
     * @param id Id of the blob. This id can never be used again.
     */
    function retract(bytes32 id) isOwner(id) isRetractable(id) external {
        // Delete the packed revision block numbers.
        _deleteAllPackedRevisionBlockNumbers(id);
        // Mark this blob as retracted.
        blobInfo[id] = BlobInfo({
            updatable: false,
            enforceRevisions: false,
            retractable: false,
            transferable: false,
            revisionCount: 0,
            blockNumber: uint32(-1),
            owner: 0,
        });
        // Log that the blob has been retracted.
        logRetract(id);
    }

    /**
     * @dev Enable transfer of the blob to the current user.
     * @param id Id of the blob.
     */
    function transferEnable(bytes32 id) isTransferable(id) external {
        // Record in state that the current user will accept this blob.
        enabledTransfers[id][msg.sender] = true;
    }

    /**
     * @dev Disable transfer of the blob to the current user.
     * @param id Id of the blob.
     */
    function transferDisable(bytes32 id) isTransferEnabled(id, msg.sender) external {
        // Record in state that the current user will not accept this blob.
        enabledTransfers[id][msg.sender] = false;
    }

    /**
     * @dev Transfer a blob to a new user.
     * @param id Id of the blob.
     * @param recipient Address of the user to transfer to blob to.
     */
    function transfer(bytes32 id, address recipient) isOwner(id) isTransferable(id) isTransferEnabled(id, recipient) external {
        // Update ownership of the blob.
        blobInfo[id].owner = recipient;
        // Disable this transfer in future and free up the slot.
        enabledTransfers[id][recipient] = false;
        // Log the transfer.
        logTransfer(id, recipient);
    }

    /**
     * @dev Disown a blob.
     * @param id Id of the blob.
     */
    function disown(bytes32 id) isOwner(id) isTransferable(id) external {
        // Remove the owner from the blob's state.
        delete blobInfo[id].owner;
        // Log as blob as disowned.
        logDisown(id);
    }

    /**
     * @dev Set a blob as not updatable.
     * @param id Id of the blob.
     */
    function setNotUpdatable(bytes32 id) isOwner(id) external {
        // Record in state that the blob is not updatable.
        blobInfo[id].updatable = false;
        // Log that the blob is not updatable.
        logSetNotUpdatable(id);
    }

    /**
     * @dev Set a blob to enforce revisions.
     * @param id Id of the blob.
     */
    function setEnforceRevisions(bytes32 id) isOwner(id) external {
        // Record in state that all changes to this blob must be new revisions.
        blobInfo[id].enforceRevisions = true;
        // Log that the blob now forces new revisions.
        logSetEnforceRevisions(id);
    }

    /**
     * @dev Set a blob to not be retractable.
     * @param id Id of the blob.
     */
    function setNotRetractable(bytes32 id) isOwner(id) external {
        // Record in state that the blob is not retractable.
        blobInfo[id].retractable = false;
        // Log that the blob is not retractable.
        logSetNotRetractable(id);
    }

    /**
     * @dev Set a blob to not be transferable.
     * @param id Id of the blob.
     */
    function setNotTransferable(bytes32 id) isOwner(id) external {
        // Record in state that the blob is not transferable.
        blobInfo[id].transferable = false;
        // Log that the blob is not transferable.
        logSetNotTransferable(id);
    }

    /**
     * @dev Get the id for this BlobStore contract.
     * @return Id of the contract.
     */
    function getContractId() constant external returns (bytes12) {
        return contractId;
    }

    /**
     * @dev Check if a blob exists.
     * @param id Id of the blob.
     * @return exists True if the blob exists.
     */
    function getExists(bytes32 id) constant external returns (bool exists) {
        BlobInfo info = blobInfo[id];
        exists = info.blockNumber != 0 && info.blockNumber != uint32(-1);
    }

    /**
     * @dev Get the block number for a specific blob revision.
     * @param id Id of the blob.
     * @param revisionId Id of the revision.
     * @return blockNumber Block number of the specified revision.
     */
    function _getRevisionBlockNumber(bytes32 id, uint revisionId) internal returns (uint blockNumber) {
        if (revisionId == 0) {
            blockNumber = blobInfo[id].blockNumber;
        }
        else {
            bytes32 slot = packedBlockNumbers[id][(revisionId - 1) / 8];
            blockNumber = uint32(uint256(slot) / 2 ** (((revisionId - 1) % 8) * 32));
        }
    }

    /**
     * @dev Get the block numbers for all of a blob's revisions.
     * @param id Id of the blob.
     * @return blockNumbers Revision block numbers.
     */
    function _getAllRevisionBlockNumbers(bytes32 id) internal returns (uint[] blockNumbers) {
        uint revisionCount = blobInfo[id].revisionCount;
        blockNumbers = new uint[](revisionCount);
        for (uint revisionId = 0; revisionId < revisionCount; revisionId++) {
            blockNumbers[revisionId] = _getRevisionBlockNumber(id, revisionId);
        }
    }

    /**
     * @dev Get info about a blob.
     * @param id Id of the blob.
     * @return owner Owner of the blob.
     * @return revisionCount How many revisions the blob has.
     * @return blockNumbers The block numbers of the revisions.
     * @return updatable Is the blob updatable?
     * @return enforceRevisions Does the blob enforce revisions?
     * @return retractable Is the blob retractable?
     * @return transferable Is the blob transferable?
     */
    function getInfo(bytes32 id) exists(id) constant external returns (address owner, uint revisionCount, uint[] blockNumbers, bool updatable, bool enforceRevisions, bool retractable, bool transferable) {
        BlobInfo info = blobInfo[id];
        owner = info.owner;
        revisionCount = info.revisionCount;
        blockNumbers = _getAllRevisionBlockNumbers(id);
        updatable = info.updatable;
        enforceRevisions = info.enforceRevisions;
        retractable = info.retractable;
        transferable = info.transferable;
    }

    /**
     * @dev Get the owner of a blob.
     * @param id Id of the blob.
     * @return owner Owner of the blob.
     */
    function getOwner(bytes32 id) exists(id) constant external returns (address owner) {
        owner = blobInfo[id].owner;
    }

    /**
     * @dev Get the number of revisions a blob has.
     * @param id Id of the blob.
     * @return revisionCount How many revisions the blob has.
     */
    function getRevisionCount(bytes32 id) exists(id) constant external returns (uint revisionCount) {
        revisionCount = blobInfo[id].revisionCount;
    }

    /**
     * @dev Get the block number for a specific blob revision.
     * @param id Id of the blob.
     * @param revisionId Id of the revision.
     * @return blockNumber Block number of the specified revision.
     */
    function getRevisionBlockNumber(bytes32 id, uint revisionId) constant external returns (uint blockNumber) {
        blockNumber = _getRevisionBlockNumber(id, revisionId);
    }

    /**
     * @dev Get the block numbers for all of a blob's revisions.
     * @param id Id of the blob.
     * @return blockNumbers Revision block numbers.
     */
    function getAllRevisionBlockNumbers(bytes32 id) exists(id) constant external returns (uint[] blockNumbers) {
        blockNumbers = _getAllRevisionBlockNumbers(id);
    }

    /**
     * @dev Determine if a blob is updatable.
     * @param id Id of the blob.
     * @return updatable True if the blob is updatable.
     */
    function getUpdatable(bytes32 id) exists(id) constant external returns (bool updatable) {
        updatable = blobInfo[id].updatable;
    }

    /**
     * @dev Determine if a blob enforces revisions.
     * @param id Id of the blob.
     * @return enforceRevisions True if the blob enforces revisions.
     */
    function getEnforceRevisions(bytes32 id) exists(id) constant external returns (bool enforceRevisions) {
        enforceRevisions = blobInfo[id].enforceRevisions;
    }

    /**
     * @dev Determine if a blob is retractable.
     * @param id Id of the blob.
     * @return retractable True if the blob is blob retractable.
     */
    function getRetractable(bytes32 id) exists(id) constant external returns (bool retractable) {
        retractable = blobInfo[id].retractable;
    }

    /**
     * @dev Determine if a blob is transferable.
     * @param id Id of the blob.
     * @return transferable True if the blob is transferable.
     */
    function getTransferable(bytes32 id) exists(id) constant external returns (bool transferable) {
        transferable = blobInfo[id].transferable;
    }

}
