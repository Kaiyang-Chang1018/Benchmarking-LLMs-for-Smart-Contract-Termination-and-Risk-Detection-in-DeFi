// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

// Migrator is a contract for migrating VXV and SBIO tokens to VAIX.
//
// VXV tokens migrate 1:1 for VAIX.
//
// SBIO tokens migrate with an optional lock period that increases receipt amount.
contract Migrator {
    // The VAIX that is locked as part of an SBIO migration.
    struct LockedMigration {
        uint256 receiptAmount; // how much VAIX will be received
        uint32 lockedAt; // block.timestamp of the migration call
        uint32 unlockAfter; // will be 0 when the lock duration is None (immediate)
        uint32 claimedAt; // will be 0 until it is claimed after unlocking
    }

    enum LockDuration {
        None, // migrate 3:1 for VAIX, immediately
        OneMonth, // migrate 2:1 for VAIX, locked for 30 days
        ThreeMonths // migrate 1:1 for VAIX, locked for 90 days
    }

    IERC20 public immutable VAIX;
    IERC20 public immutable VXV;
    IERC20 public immutable SBIO;
    address public immutable treasury;
    mapping(address => LockedMigration[]) public locks;
    bytes32 public immutable whitelistRoot;
    uint32 public immutable migrationClosesAfter;
    uint256 public immutable sbioMigrationCap;
    uint256 public sbioMigrationTotal;

    error WhitelistNotVerified();
    error MigrationWindowOpen();
    error MigrationWindowClosed();
    error MigrationCapExceeded();

    // When a user has migrated tokens (VXV or SBIO) for VAIX tokens.
    event Migrated(
        address indexed user,
        address indexed depositToken, // VXV or SBIO
        uint256 depositAmount,
        uint256 receiptAmount,
        LockDuration lockDuration
    );

    // When a user claims VAIX tokens that were previously locked.
    event Claimed(address indexed user, uint256 receiptAmount);

    // When the treasury receives VAIX because an SBIO holder opted for a shorter migration lock.
    // e.g. when they opt for no lock then 2/3 of the VAIX is sent to the treasury instead.
    event TreasuryReceipt(address indexed user, uint256 treasuryReceiptAmount);

    constructor(
        address treasuryAddress,
        address vaixAddress,
        address vxvAddress,
        address sbioAddress,
        bytes32 sbioWhitelistRoot,
        uint256 _sbioMigrationCap,
        uint32 _migrationClosesAfter
    ) {
        treasury = treasuryAddress;
        VAIX = IERC20(vaixAddress);
        VXV = IERC20(vxvAddress);
        SBIO = IERC20(sbioAddress);
        sbioMigrationCap = _sbioMigrationCap;
        sbioMigrationTotal = 0;
        whitelistRoot = sbioWhitelistRoot;
        migrationClosesAfter = _migrationClosesAfter;
    }

    // Returns the maximum VAIX required to perform all migrations.
    function maximumMigrationSupply() external view returns (uint256) {
        return VXV.totalSupply() + sbioMigrationCap;
    }

    // Migrate VXV tokens to VAIX.
    function migrateFromVXV(uint256 amount) external {
        if (block.timestamp > migrationClosesAfter) {
            revert MigrationWindowClosed();
        }
        VXV.transferFrom(msg.sender, address(this), amount);
        VAIX.transfer(msg.sender, amount);
        emit Migrated(
            msg.sender,
            address(VXV),
            amount,
            amount,
            LockDuration.None
        );
    }

    // Migrate SBIO tokens to VAIX.
    // The receipt amount is determined by the lock duration.
    // When `LockDuration.None` then SBIO migrates 3:1 for VAIX immediately.
    // When `LockDuration.OneMonth` then SBIO migrates 2:1 for VAIX after 30 days.
    // When `LockDuration.ThreeMonths` then SBIO migrates 1:1 for VAIX after 90 days.
    // The remainder from accelerating the migration is sent to the treasury.
    //
    // After the lock period, a user will have a `.claimableBalanceOf` and can `.claim` their VAIX.
    function migrateFromSBIO(
        uint256 amount,
        LockDuration lockDuration,
        bytes32[] calldata whitelistProof
    ) external {
        if (block.timestamp > migrationClosesAfter) {
            revert MigrationWindowClosed();
        }
        bytes32 whitelistLeaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender)))
        );
        if (
            !MerkleProof.verifyCalldata(
                whitelistProof,
                whitelistRoot,
                whitelistLeaf
            )
        ) {
            revert WhitelistNotVerified();
        }
        sbioMigrationTotal += amount;
        if (sbioMigrationTotal > sbioMigrationCap) {
            revert MigrationCapExceeded();
        }
        SBIO.transferFrom(msg.sender, address(this), amount);
        LockedMigration memory lock = _makeSBIOLock(amount, lockDuration);
        locks[msg.sender].push(lock);
        emit Migrated(
            msg.sender,
            address(SBIO),
            amount,
            lock.receiptAmount,
            lockDuration
        );
        uint256 remainder = amount - lock.receiptAmount;
        if (remainder > 0) {
            VAIX.transfer(treasury, remainder);
            emit TreasuryReceipt(msg.sender, remainder);
        }
        _claimUnlockedMigrations(msg.sender);
    }

    // Returns all locks for a `user`.
    function locksOf(
        address user
    ) external view returns (LockedMigration[] memory) {
        return locks[user];
    }

    // Claim unlocked VAIX tokens.
    // See `.claimableBalanceOf()` to determine the VAIX that will be claimed.
    // Note: this will claim VAIX tokens across any expired locks for the `msg.sender`.
    function claim() external {
        _claimUnlockedMigrations(msg.sender);
    }

    // Returns the VAIX that a `user` can `.claim()` now.
    function claimableBalanceOf(
        address user
    ) external view returns (uint256 balance) {
        balance = 0;
        if (block.timestamp > migrationClosesAfter) {
            return 0;
        }
        LockedMigration[] storage userLocks = locks[user];
        for (uint256 i = 0; i < userLocks.length; i++) {
            LockedMigration storage lock = userLocks[i];
            if (lock.unlockAfter < block.timestamp && lock.claimedAt == 0) {
                balance += lock.receiptAmount;
            }
        }
    }

    function withdrawAfterClosing() external {
        if (block.timestamp <= migrationClosesAfter) {
            revert MigrationWindowOpen();
        }
        VAIX.transfer(treasury, VAIX.balanceOf(address(this)));
        SBIO.transfer(treasury, SBIO.balanceOf(address(this)));
    }

    function isMigrationClosed() external view returns (bool) {
        return block.timestamp > migrationClosesAfter;
    }

    function _claimUnlockedMigrations(address user) internal {
        if (block.timestamp > migrationClosesAfter) {
            revert MigrationWindowClosed();
        }
        LockedMigration[] storage userLocks = locks[user];
        for (uint256 i = 0; i < userLocks.length; i++) {
            LockedMigration storage lock = userLocks[i];
            if (lock.unlockAfter < block.timestamp && lock.claimedAt == 0) {
                lock.claimedAt = uint32(block.timestamp);
                VAIX.transfer(user, lock.receiptAmount);
                emit Claimed(user, lock.receiptAmount);
            }
        }
    }

    function _makeSBIOLock(
        uint256 amount,
        LockDuration duration
    ) private view returns (LockedMigration memory) {
        LockedMigration memory lock;
        lock.lockedAt = uint32(block.timestamp);
        lock.claimedAt = 0;
        if (duration == LockDuration.ThreeMonths) {
            lock.unlockAfter = uint32(block.timestamp) + 90 days;
            lock.receiptAmount = amount;
        } else if (duration == LockDuration.OneMonth) {
            lock.unlockAfter = uint32(block.timestamp) + 30 days;
            lock.receiptAmount = amount / 2;
        } else {
            // LockDuration.None
            lock.unlockAfter = 0;
            lock.receiptAmount = amount / 3;
        }
        return lock;
    }
}