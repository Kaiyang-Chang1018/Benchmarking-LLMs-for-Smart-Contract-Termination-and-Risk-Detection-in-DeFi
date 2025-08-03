// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.20;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the Merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates Merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     *@dev The multiproof provided is not valid.
     */
    error MerkleProofInvalidMultiproof();

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proofLen != totalHashes + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            if (proofPos != proofLen) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Sorts the pair (a, b) and hashes the result.
     */
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts-v5/access/Ownable2Step.sol";
import {MerkleProof} from "@openzeppelin/contracts-v5/utils/cryptography/MerkleProof.sol";

import {ILock} from "./interfaces/ILock.sol";
import {ICumulativeMerkleDrop} from "./interfaces/ICumulativeMerkleDrop.sol";

/// Contract which manages initial distribution of the SWELL token via merkle drop claim process.
contract CumulativeMerkleDrop is Ownable2Step, ICumulativeMerkleDrop {
    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/
    
    uint8 private constant OPEN = 1;
    uint8 private constant NOT_OPEN = 2;
    
    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc ICumulativeMerkleDrop
    IERC20 public immutable token;

    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc ICumulativeMerkleDrop
    uint8 public claimIsOpen;

    /// @inheritdoc ICumulativeMerkleDrop
    ILock public stakingContract;

    /// @inheritdoc ICumulativeMerkleDrop
    bytes32 public merkleRoot;

    /// @inheritdoc ICumulativeMerkleDrop
    mapping(address => uint256) public cumulativeClaimed;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner, address _token) Ownable(_owner) {
        if (_token == address(0)) revert ADDRESS_NULL();

        claimIsOpen = NOT_OPEN;
        token = IERC20(_token);
    }

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyClaimOpen() {
        if (claimIsOpen != OPEN) revert CLAIM_CLOSED();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                SETTERS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc ICumulativeMerkleDrop
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        if (_merkleRoot == merkleRoot) revert SAME_MERKLE_ROOT();
        emit MerkleRootUpdated(merkleRoot, _merkleRoot);
        merkleRoot = _merkleRoot;
    }

    /// @inheritdoc ICumulativeMerkleDrop
    function setStakingContract(address _stakingContract) external onlyOwner {
        if (_stakingContract == address(0)) revert ADDRESS_NULL();
        address oldStakingContract = address(stakingContract);
        
        if (_stakingContract == oldStakingContract) revert SAME_STAKING_CONTRACT();
        if (ILock(_stakingContract).token() != token) revert STAKING_TOKEN_MISMATCH();
        emit StakingContractUpdated(oldStakingContract, _stakingContract);
        stakingContract = ILock(_stakingContract);
        token.approve(address(_stakingContract), type(uint256).max);

        if (oldStakingContract != address(0)) {
            token.approve(oldStakingContract, 0);
        }
    }

    /// @inheritdoc ICumulativeMerkleDrop
    function clearStakingContract() external onlyOwner {
        address oldStakingContract = address(stakingContract);
        if (oldStakingContract == address(0)) revert SAME_STAKING_CONTRACT();
        emit StakingContractCleared();
        stakingContract = ILock(address(0));
        token.approve(oldStakingContract, 0);
    }

    /// @inheritdoc ICumulativeMerkleDrop
    function setClaimStatus(uint8 status) external onlyOwner {
        if (status != OPEN && status != NOT_OPEN) revert INVALID_STATUS();
        emit ClaimStatusUpdated(claimIsOpen, status);
        claimIsOpen = status;
    }

    /*//////////////////////////////////////////////////////////////
                             MAIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc ICumulativeMerkleDrop
    function claimAndLock(uint256 cumulativeAmount, uint256 amountToLock, bytes32[] calldata merkleProof)
        external
        onlyClaimOpen
    {
        // Verify the merkle proof
        if (!verifyProof(merkleProof, cumulativeAmount, msg.sender)) revert INVALID_PROOF();

        // Mark it claimed
        uint256 preclaimed = cumulativeClaimed[msg.sender];
        if (preclaimed >= cumulativeAmount) revert NOTHING_TO_CLAIM();
        cumulativeClaimed[msg.sender] = cumulativeAmount;

        // Send the token
        uint256 amount = cumulativeAmount - preclaimed;
        if (amountToLock > 0) {
            if (amountToLock > amount) revert AMOUNT_TO_LOCK_GT_AMOUNT_CLAIMED();
            // Ensure the staking contract is set before locking
            if (address(stakingContract) == address(0)) revert STAKING_NOT_AVAILABLE();
            stakingContract.lock(msg.sender, amountToLock);
        }

        if (amount != amountToLock) token.transfer(msg.sender, amount - amountToLock);

        emit Claimed(msg.sender, amount, amountToLock);
    }

    /*//////////////////////////////////////////////////////////////
                                 VIEWS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc ICumulativeMerkleDrop
    function verifyProof(bytes32[] calldata proof, uint256 amount, address addr) public view returns (bool) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, amount))));
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ILock} from "./ILock.sol";

interface ICumulativeMerkleDrop {
    /// @notice error emitted when address is null.
    error ADDRESS_NULL();

    /// @notice error emitted when claim is closed.
    error CLAIM_CLOSED();

    /// @notice error emitted when amount to lock is greater than claimable amount.
    error AMOUNT_TO_LOCK_GT_AMOUNT_CLAIMED();

    /// @notice error emitted when submited proof is invalid.
    error INVALID_PROOF();

    /// @notice error emitted when claim status is invalid.
    error INVALID_STATUS();

    /// @notice error emitted when nothing to claim.
    error NOTHING_TO_CLAIM();

    /// @notice error emitted when an admin tries to update the merkle root with the same value.
    error SAME_MERKLE_ROOT();

    /// @notice error emitted when an admin tries to update the staking contract to the same address.
    error SAME_STAKING_CONTRACT();

    /// @notice error emitted when the provided staking contract token address does not match the drop token address.
    error STAKING_TOKEN_MISMATCH();

    /// @notice error emitted when staking is set to the zero address and the user attempts to lock funds.
    error STAKING_NOT_AVAILABLE();

    /// @notice event emitted when claim is made.
    /// @param account The account that made the claim.
    /// @param amount The amount of token claimed.
    /// @param amountToLock The amount of token locked.
    event Claimed(address indexed account, uint256 amount, uint256 amountToLock);

    /// @notice event emitted when claim status is updated.
    /// @param oldStatus The old status of the claim.
    /// @param newStatus The new status of the claim.
    event ClaimStatusUpdated(uint8 oldStatus, uint8 newStatus);

    /// @notice event emitted when Merkle root is updated.
    /// @param oldMerkleRoot The old Merkle root.
    /// @param newMerkleRoot The new Merkle root.
    event MerkleRootUpdated(bytes32 oldMerkleRoot, bytes32 newMerkleRoot);

    /// @notice event emitted when stakingContract contract is updated.
    /// @param oldStakingContract The old stakingContract contract address.
    /// @param newStakingContract The new stakingContract contract address.
    event StakingContractUpdated(address oldStakingContract, address newStakingContract);

    /// @notice event emitted when stakingContract contract is cleared.
    event StakingContractCleared();

    /// @notice Claim and lock token.
    /// @param cumulativeAmount The cumulative amount of token claimed.
    /// @param amountToLock The amount of token to lock.
    /// @param merkleProof The merkle proof.
    /// @notice It is only possible to lock if there is a staking contract set.
    function claimAndLock(uint256 cumulativeAmount, uint256 amountToLock, bytes32[] memory merkleProof) external;

    /// @notice Get the status of the claim.
    /// @return The status of the claim, 1 for open, 2 for closed.
    function claimIsOpen() external view returns (uint8);

    /// @notice Get the cumulative claimed amount of an account.
    /// @return The cumulative claimed amount of an account.
    function cumulativeClaimed(address) external view returns (uint256);

    /// @notice Get the current Merkle root.
    /// @return The current Merkle root.
    function merkleRoot() external view returns (bytes32);

    /// @notice Set the status of the claim.
    /// @param status The status of the claim, 1 for open, 2 for closed.
    function setClaimStatus(uint8 status) external;

    /// @notice Set the Merkle root.
    /// @param _merkleRoot The new Merkle root.
    function setMerkleRoot(bytes32 _merkleRoot) external;

    /// @notice Set the staking contract address.
    /// @param _stakingContract The staking contract address.
    function setStakingContract(address _stakingContract) external;

    /// @notice Clear the staking contract address.
    /// @notice After calling, it is not possible to lock funds until a new staking contract is set.
    function clearStakingContract() external;

    /// @notice Get the staking contract address.
    /// @return The staking contract address.
    function stakingContract() external view returns (ILock);

    /// @notice Get the token address.
    /// @return The token address.
    function token() external view returns (IERC20);

    /// @notice Verify the merkle proof.
    /// @param proof The merkle proof.
    /// @param amount The amount of token claimed.
    /// @param addr The address of the claimer.
    /// @return True if the proof is valid, false otherwise.
    function verifyProof(bytes32[] memory proof, uint256 amount, address addr) external view returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILock {
    /// @notice locks the token in the staking contract.
    /// @param _account The account address to lock for.
    /// @param _amount The amount of token to lock.
    function lock(address _account, uint256 _amount) external;


    /// @notice Get the staking token address.
    /// @return The staking token address.
    function token() external view returns (IERC20);
}