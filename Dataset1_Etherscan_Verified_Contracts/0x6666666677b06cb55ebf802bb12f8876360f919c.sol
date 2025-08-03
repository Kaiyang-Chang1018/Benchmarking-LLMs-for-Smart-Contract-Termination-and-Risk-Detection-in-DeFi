// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/Hashes.sol)

pragma solidity ^0.8.20;

/**
 * @dev Library of standard hash functions.
 *
 * _Available since v5.1._
 */
library Hashes {
    /**
     * @dev Commutative Keccak256 hash of a sorted pair of bytes32. Frequently used when working with merkle proofs.
     *
     * NOTE: Equivalent to the `standardNodeHash` in our https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
     */
    function commutativeKeccak256(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? _efficientKeccak256(a, b) : _efficientKeccak256(b, a);
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
    function _efficientKeccak256(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly ("memory-safe") {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/MerkleProof.sol)
// This file was procedurally generated from scripts/generate/templates/MerkleProof.js.

pragma solidity ^0.8.20;

import {Hashes} from "./Hashes.sol";

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
 *
 * IMPORTANT: Consider memory side-effects when using custom hashing functions
 * that access memory in an unsafe way.
 *
 * NOTE: This library supports proof verification for merkle trees built using
 * custom _commutative_ hashing functions (i.e. `H(a, b) == H(b, a)`). Proving
 * leaf inclusion in trees built using non-commutative hashing functions requires
 * additional logic that is not supported by this library.
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
     *
     * This version handles proofs in memory with the default hashing function.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leaves & pre-images are assumed to be sorted.
     *
     * This version handles proofs in memory with the default hashing function.
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = Hashes.commutativeKeccak256(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     *
     * This version handles proofs in memory with a custom hashing function.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bool) {
        return processProof(proof, leaf, hasher) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leaves & pre-images are assumed to be sorted.
     *
     * This version handles proofs in memory with a custom hashing function.
     */
    function processProof(
        bytes32[] memory proof,
        bytes32 leaf,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = hasher(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     *
     * This version handles proofs in calldata with the default hashing function.
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leaves & pre-images are assumed to be sorted.
     *
     * This version handles proofs in calldata with the default hashing function.
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = Hashes.commutativeKeccak256(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     *
     * This version handles proofs in calldata with a custom hashing function.
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bool) {
        return processProofCalldata(proof, leaf, hasher) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leaves & pre-images are assumed to be sorted.
     *
     * This version handles proofs in calldata with a custom hashing function.
     */
    function processProofCalldata(
        bytes32[] calldata proof,
        bytes32 leaf,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = hasher(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * This version handles multiproofs in memory with the default hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * NOTE: Consider the case where `root == proof[0] && leaves.length == 0` as it will return `true`.
     * The `leaves` must be validated independently. See {processMultiProof}.
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
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * This version handles multiproofs in memory with the default hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * NOTE: The _empty set_ (i.e. the case where `proof.length == 1 && leaves.length == 0`) is considered a no-op,
     * and therefore a valid multiproof (i.e. it returns `proof[0]`). Consider disallowing this case if you're not
     * validating the leaves elsewhere.
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
        uint256 proofFlagsLen = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proof.length != proofFlagsLen + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](proofFlagsLen);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < proofFlagsLen; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = Hashes.commutativeKeccak256(a, b);
        }

        if (proofFlagsLen > 0) {
            if (proofPos != proof.length) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[proofFlagsLen - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * This version handles multiproofs in memory with a custom hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * NOTE: Consider the case where `root == proof[0] && leaves.length == 0` as it will return `true`.
     * The `leaves` must be validated independently. See {processMultiProof}.
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bool) {
        return processMultiProof(proof, proofFlags, leaves, hasher) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * This version handles multiproofs in memory with a custom hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * NOTE: The _empty set_ (i.e. the case where `proof.length == 1 && leaves.length == 0`) is considered a no-op,
     * and therefore a valid multiproof (i.e. it returns `proof[0]`). Consider disallowing this case if you're not
     * validating the leaves elsewhere.
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofFlagsLen = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proof.length != proofFlagsLen + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](proofFlagsLen);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < proofFlagsLen; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = hasher(a, b);
        }

        if (proofFlagsLen > 0) {
            if (proofPos != proof.length) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[proofFlagsLen - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * This version handles multiproofs in calldata with the default hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * NOTE: Consider the case where `root == proof[0] && leaves.length == 0` as it will return `true`.
     * The `leaves` must be validated independently. See {processMultiProofCalldata}.
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
     * This version handles multiproofs in calldata with the default hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * NOTE: The _empty set_ (i.e. the case where `proof.length == 1 && leaves.length == 0`) is considered a no-op,
     * and therefore a valid multiproof (i.e. it returns `proof[0]`). Consider disallowing this case if you're not
     * validating the leaves elsewhere.
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
        uint256 proofFlagsLen = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proof.length != proofFlagsLen + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](proofFlagsLen);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < proofFlagsLen; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = Hashes.commutativeKeccak256(a, b);
        }

        if (proofFlagsLen > 0) {
            if (proofPos != proof.length) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[proofFlagsLen - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * This version handles multiproofs in calldata with a custom hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * NOTE: Consider the case where `root == proof[0] && leaves.length == 0` as it will return `true`.
     * The `leaves` must be validated independently. See {processMultiProofCalldata}.
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves, hasher) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * This version handles multiproofs in calldata with a custom hashing function.
     *
     * CAUTION: Not all Merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * NOTE: The _empty set_ (i.e. the case where `proof.length == 1 && leaves.length == 0`) is considered a no-op,
     * and therefore a valid multiproof (i.e. it returns `proof[0]`). Consider disallowing this case if you're not
     * validating the leaves elsewhere.
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves,
        function(bytes32, bytes32) view returns (bytes32) hasher
    ) internal view returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the Merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofFlagsLen = proofFlags.length;

        // Check proof validity.
        if (leavesLen + proof.length != proofFlagsLen + 1) {
            revert MerkleProofInvalidMultiproof();
        }

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](proofFlagsLen);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < proofFlagsLen; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = hasher(a, b);
        }

        if (proofFlagsLen > 0) {
            if (proofPos != proof.length) {
                revert MerkleProofInvalidMultiproof();
            }
            unchecked {
                return hashes[proofFlagsLen - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { VestManagerBase } from "./VestManagerBase.sol";

interface IGovToken is IERC20 {
    function INITIAL_SUPPLY() external view returns (uint256);
}

contract VestManager is VestManagerBase {
    uint256 constant PRECISION = 1e18;
    address immutable public prisma;
    address immutable public yprisma;
    address immutable public cvxprisma;
    uint256 public immutable INITIAL_SUPPLY;
    address public immutable BURN_ADDRESS;
    
    bool public initialized;
    uint256 public redemptionRatio;
    mapping(AllocationType => uint256) public allocationByType;
    mapping(AllocationType => uint256) public durationByType;
    mapping(AllocationType => bytes32) public merkleRootByType;
    mapping(address account => mapping(AllocationType => bool hasClaimed)) public hasClaimed; // used for airdrops only

    enum AllocationType {
        PERMA_STAKE,
        LICENSING,
        TREASURY,
        REDEMPTIONS,
        AIRDROP_TEAM,
        AIRDROP_VICTIMS,
        AIRDROP_LOCK_PENALTY
    }

    event TokenRedeemed(address indexed token, address indexed redeemer, address indexed recipient, uint256 amount);
    event MerkleRootSet(AllocationType indexed allocationType, bytes32 root);
    event AirdropClaimed(AllocationType indexed allocationType, address indexed account, address indexed recipient, uint256 amount);
    event InitializationParamsSet();

    constructor(
        address _core,
        address _token,
        address _burnAddress,
        address[3] memory _redemptionTokens // PRISMA, yPRISMA, cvxPRISMA
    ) VestManagerBase(_core, _token) {
        INITIAL_SUPPLY = IGovToken(_token).INITIAL_SUPPLY();
        require(IERC20(_token).balanceOf(address(this)) == INITIAL_SUPPLY, "VestManager not funded");
        BURN_ADDRESS = _burnAddress;
        prisma = _redemptionTokens[0];
        yprisma = _redemptionTokens[1];
        cvxprisma = _redemptionTokens[2];
    }

    /**
        @notice Set the initialization parameters for the vesting contract
        @dev All values must be set in the same order as the AllocationType enum
        @param _maxRedeemable   Maximum amount of PRISMA/yPRISMA/cvxPRISMA that can be redeemed
        @param _merkleRoots     Merkle roots for the airdrop allocations
        @param _nonUserTargets  Addresses to receive the non-user allocations
        @param _vestDurations  Durations of the vesting periods for each type
        @param _allocPercentages Percentages of the initial supply allocated to each type,  
            the first two values being perma-stakers, followed by all other allocation types in order of 
            AllocationType enum.
    */
    function setInitializationParams(
        uint256 _maxRedeemable,
        bytes32[3] memory _merkleRoots,
        address[4] memory _nonUserTargets,
        uint256[8] memory _vestDurations,
        uint256[8] memory _allocPercentages
    ) external onlyOwner {
        require(!initialized, "params already set");
        initialized = true;

        uint256 totalPctAllocated;
        uint256 airdropIndex;
        require(_vestDurations[0] == _vestDurations[1], "perma-staker durations must match");
        for (uint256 i = 0; i < _allocPercentages.length; i++) {
            AllocationType allocType = i == 0 ? AllocationType(i) : AllocationType(i-1); // First two are same type
            require(_vestDurations[i] > 0 && _vestDurations[i] <= type(uint32).max, "invalid duration");
            durationByType[allocType] = uint32(_vestDurations[i]);
            totalPctAllocated += _allocPercentages[i];
            uint256 allocation = _allocPercentages[i] * INITIAL_SUPPLY / PRECISION;
            allocationByType[allocType] += allocation;
            
            if (i < _nonUserTargets.length) { 
                _createVest(
                    _nonUserTargets[i], 
                    uint32(_vestDurations[i]), 
                    uint112(allocation)
                );
                continue;
            }
            if (
                allocType == AllocationType.AIRDROP_TEAM ||
                allocType == AllocationType.AIRDROP_VICTIMS ||
                allocType == AllocationType.AIRDROP_LOCK_PENALTY
            ) {
                // Set merkle roots for airdrop allocations
                merkleRootByType[allocType] = _merkleRoots[airdropIndex];
                emit MerkleRootSet(allocType, _merkleRoots[airdropIndex++]);
            }
        }

        // Set the redemption ratio to be used for all PRISMA/yPRISMA/cvxPRISMA redemptions
        uint256 _redemptionRatio = (
            allocationByType[AllocationType.REDEMPTIONS] * 1e18 / _maxRedeemable
        );
        redemptionRatio = _redemptionRatio;
        require(_redemptionRatio != 0, "ratio is 0");
        require(totalPctAllocated == PRECISION, "Total not 100%");
        emit InitializationParamsSet();
    }

    /**
        @notice Set the merkle root for the lock penalty airdrop
        @dev This root must be set later after lock penalty data is finalized
        @param _root Merkle root for the lock penalty airdrop
        @param _allocation Allocation for the lock penalty airdrop
    */
    function setLockPenaltyMerkleRoot(bytes32 _root, uint256 _allocation) external onlyOwner {
        require(initialized, "init params not set");
        require(merkleRootByType[AllocationType.AIRDROP_LOCK_PENALTY] == bytes32(0), "root already set");
        merkleRootByType[AllocationType.AIRDROP_LOCK_PENALTY] = _root;
        emit MerkleRootSet(AllocationType.AIRDROP_LOCK_PENALTY, _root);
        allocationByType[AllocationType.AIRDROP_LOCK_PENALTY] = _allocation;
    }

    function merkleClaim(
        address _account,
        address _recipient,
        uint256 _amount,
        AllocationType _type,
        bytes32[] calldata _proof,
        uint256 _index
    ) external callerOrDelegated(_account) {
        require(
            _type == AllocationType.AIRDROP_TEAM || 
            _type == AllocationType.AIRDROP_LOCK_PENALTY || 
            _type == AllocationType.AIRDROP_VICTIMS, 
            "invalid type"
        );

        bytes32 _root = merkleRootByType[_type];
        require(_root != bytes32(0), "root not set");

        require(!hasClaimed[_account][_type], "already claimed");
        bytes32 node = keccak256(abi.encodePacked(_account, _index, _amount));
        require(MerkleProof.verifyCalldata(
            _proof, 
            _root, 
            node
        ), "invalid proof");

        _createVest(
            _recipient,
            uint32(durationByType[_type]),
            uint112(_amount)
        );
        hasClaimed[_account][_type] = true;
        emit AirdropClaimed(_type, _account, _recipient, _amount);
    }

    /**
        @notice Redeem PRISMA tokens for RSUP tokens
        @param _token    Token to redeem (PRISMA, yPRISMA or cvxPRISMA)
        @param _recipient Address to receive the RSUP tokens
        @param _amount   Amount of tokens to redeem
        @dev This function allows users to convert their PRISMA tokens to RSUP tokens
             at the redemption ratio. The input tokens are burned in the process.
    */
    function redeem(address _token, address _recipient, uint256 _amount) external {
        require(
            _token == address(prisma) || 
            _token == address(yprisma) || 
            _token == address(cvxprisma), 
            "invalid token"
        );
        require(_amount > 0, "amount too low");
        uint256 _ratio = redemptionRatio;
        require(_ratio != 0, "ratio not set");
        IERC20(_token).transferFrom(msg.sender, BURN_ADDRESS, _amount);
        _createVest(
            _recipient,
            uint32(durationByType[AllocationType.REDEMPTIONS]),
            uint112(_amount * _ratio / 1e18)
        );
        emit TokenRedeemed(_token, msg.sender, _recipient, _amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { DelegatedOps } from '../../dependencies/DelegatedOps.sol';
import { CoreOwnable } from '../../dependencies/CoreOwnable.sol';
import { IVestClaimCallback } from 'src/interfaces/IVestClaimCallback.sol';

contract VestManagerBase is CoreOwnable, DelegatedOps {
    uint256 public immutable VEST_GLOBAL_START_TIME;
    IERC20 public immutable token;

    mapping(address => Vest[]) public userVests;
    mapping(address => ClaimSettings) public claimSettings;

    struct Vest {
        uint32 duration; // max of ~56k days
        uint112 amount;
        uint112 claimed;
    }

    struct ClaimSettings {
        bool allowPermissionlessClaims;
        address recipient;
    }

    event VestCreated(address indexed account, uint256 indexed duration, uint256 amount);
    event Claimed(address indexed account, uint256 amount);
    event ClaimSettingsSet(address indexed account, bool indexed allowPermissionlessClaims, address indexed recipient);

    constructor(address _core, address _token) CoreOwnable(_core) {
        token = IERC20(_token);
        VEST_GLOBAL_START_TIME = block.timestamp;
    }

    /// @notice Creates or adds to a vesting instance for an account
    /// @param _account The address to create the vest for
    /// @param _duration The duration of the vesting period in seconds
    /// @param _amount The amount of tokens to vest
    /// @return The total number of vesting instances for the account
    function _createVest(
        address _account,
        uint32 _duration,
        uint112 _amount
    ) internal returns (uint256) {
        require(_account != address(0), "zero address");
        require(_amount > 0, "Amount must be greater than zero");

        uint256 length = numAccountVests(_account);

        // If a vest with matching duration already exists, simply add to its amount
        for (uint256 i = 0; i < length; i++) {
            if (userVests[_account][i].duration == _duration) {
                userVests[_account][i].amount += _amount;
                return length;
            }
        }

        // If the duration does not exist, create a new vest
        userVests[_account].push(Vest(
            _duration,
            _amount,
            0
        ));

        emit VestCreated(_account, _duration, _amount);
        return length + 1;
    }

    function numAccountVests(address _account) public view returns (uint256) {
        return userVests[_account].length;
    }

    /**
     * @notice Claims all available vested tokens for an account
     * @param _account Address to claim tokens for
     * @return _claimed Total amount of tokens claimed
     * @dev Any caller can claim on behalf of an account, unless explicitly blocked via account's claimSettings
     */
    function claim(address _account) external returns (uint256 _claimed) {
        address recipient = _enforceClaimSettings(_account);
        _claimed = _claim(_account);
        if (_claimed > 0) {
            token.transfer(recipient, _claimed);
            emit Claimed(_account, _claimed);
        }
    }

    /**
     * @notice Claims all available vested tokens for an account, and calls a callback to handle the tokens
     * @dev Important: the claimed tokens are transferred to the callback contract for handling, not the recipient
     * @dev Restricted to the account or a delegated caller
     * @param _account Address to claim tokens for
     * @param _callback Address of the callback contract to use
     * @return _claimed Total amount of tokens claimed
     */
    function claimWithCallback(
        address _account, 
        address _callback
    ) external callerOrDelegated(_account) returns (uint256 _claimed) {
        address recipient = _enforceClaimSettings(_account);
        _claimed = _claim(_account);
        if (_claimed > 0) {
            token.transfer(_callback, _claimed);
            require(IVestClaimCallback(_callback).onClaim(_account, recipient, _claimed), "callback failed");
            emit Claimed(_account, _claimed);
        }
    }

    function _claim(address _account) internal returns (uint256 _claimed) {
        Vest[] storage vests = userVests[_account];
        uint256 length = vests.length;
        require(length > 0, "No vests to claim");

        for (uint256 i = 0; i < length; i++) {
            uint112 claimable = _claimableAmount(vests[i]);
            if (claimable > 0) {
                vests[i].claimed += claimable;
                _claimed += claimable;
            }
        }
    }

    function _enforceClaimSettings(address _account) internal view returns (address) {
        ClaimSettings memory settings = claimSettings[_account];
        if (!settings.allowPermissionlessClaims) {
            require(msg.sender == _account, "!authorized");
        }
        return settings.recipient != address(0) ? settings.recipient : _account;
    }

    /**
     * @notice Get aggregated vesting data for an account. Includes all vests for the account.
     * @param _account Address of the account to query
     * @return _totalAmount Total amount of tokens in all vests for the account
     * @return _totalClaimable Amount of tokens that can be claimed by the account
     * @return _totalClaimed Amount of tokens already claimed by the account
     * @dev Iterates through all vests for the account to calculate totals
     */
    function getAggregateVestData(address _account) external view returns (
        uint256 _totalAmount,
        uint256 _totalClaimable,
        uint256 _totalClaimed
    ) {
        uint256 length = numAccountVests(_account);
        for (uint256 i = 0; i < length; i++) {
            (uint256 _total, uint256 _claimable, uint256 _claimed,) = _vestData(userVests[_account][i]);
            _totalAmount += _total;
            _totalClaimable += _claimable;
            _totalClaimed += _claimed;
        }
    }

    /**
     * @notice Get single vest data for an account
     * @param _account Address of the account to query
     * @param index Index of the vest to query
     * @return _total Total amount of tokens in the vest
     * @return _claimable Amount of tokens that can be claimed for the vest
     * @return _claimed Amount of tokens already claimed for the vest
     * @return _timeRemaining Time remaining until vesting is complete
     */
    function getSingleVestData(address _account, uint256 index) external view returns (
        uint256 _total,
        uint256 _claimable,
        uint256 _claimed,
        uint256 _timeRemaining
    ) {
        return _vestData(userVests[_account][index]);
    }

    function _vestData(Vest memory vest) internal view returns (
        uint256 _total,
        uint256 _claimable,
        uint256 _claimed,
        uint256 _timeRemaining
    ){
        uint256 vested = _vestedAmount(vest);
        _total = vest.amount;
        _claimable = vested - vest.claimed;
        _claimed = vest.claimed;
        uint256 elapsed = block.timestamp - VEST_GLOBAL_START_TIME;
        _timeRemaining = elapsed > vest.duration ? 0 : vest.duration - elapsed;
    }

    function _claimableAmount(Vest storage vest) internal view returns (uint112) {
        return uint112(_vestedAmount(vest) - vest.claimed);
    }

    function _vestedAmount(Vest memory vest) internal view returns (uint256) {
        if (block.timestamp < VEST_GLOBAL_START_TIME) {
            return 0;
        } else if (block.timestamp >= VEST_GLOBAL_START_TIME + vest.duration) {
            return vest.amount;
        } else {
            return (vest.amount * (block.timestamp - VEST_GLOBAL_START_TIME)) / vest.duration;
        }
    }

    function setClaimSettings( 
        bool _allowPermissionlessClaims, 
        address _recipient
    ) external {
        claimSettings[msg.sender] = ClaimSettings(_allowPermissionlessClaims, _recipient);
        emit ClaimSettingsSet(msg.sender, _allowPermissionlessClaims, _recipient);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ICore} from "../interfaces/ICore.sol";

/**
    @title Core Ownable
    @author Prisma Finance (with edits by Resupply Finance)
    @notice Contracts inheriting `CoreOwnable` have the same owner as `Core`.
            The ownership cannot be independently modified or renounced.
 */
contract CoreOwnable {
    ICore public immutable core;

    constructor(address _core) {
        core = ICore(_core);
    }

    modifier onlyOwner() {
        require(msg.sender == address(core), "!core");
        _;
    }

    function owner() public view returns (address) {
        return address(core);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
    @title Delegated Operations
    @author Prisma Finance (with edits by Resupply Finance)
    @notice Allows delegation to specific contract functionality. Useful for creating
            wrapper contracts to bundle multiple interactions into a single call.
 */
contract DelegatedOps {
    event DelegateApprovalSet(address indexed account, address indexed delegate, bool isApproved);

    mapping(address owner => mapping(address caller => bool isApproved)) public isApprovedDelegate;

    modifier callerOrDelegated(address _account) {
        require(msg.sender == _account || isApprovedDelegate[_account][msg.sender], "!CallerOrDelegated");
        _;
    }

    function setDelegateApproval(address _delegate, bool _isApproved) external {
        isApprovedDelegate[msg.sender][_delegate] = _isApproved;
        emit DelegateApprovalSet(msg.sender, _delegate, _isApproved);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IAuthHook {
    function preHook(address operator, address target, bytes calldata data) external returns (bool);
    function postHook(bytes memory result, address operator, address target, bytes calldata data) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IAuthHook } from './IAuthHook.sol';

interface ICore {
    struct OperatorAuth {
        bool authorized;
        IAuthHook hook;
    }

    event VoterSet(address indexed newVoter);
    event OperatorExecuted(address indexed caller, address indexed target, bytes data);
    event OperatorSet(address indexed caller, address indexed target, bool authorized, bytes4 selector, IAuthHook authHook);

    function execute(address target, bytes calldata data) external returns (bytes memory);
    function epochLength() external view returns (uint256);
    function startTime() external view returns (uint256);
    function voter() external view returns (address);
    function ownershipTransferDeadline() external view returns (uint256);
    function pendingOwner() external view returns (address);
    function setOperatorPermissions(
        address caller,
        address target,
        bytes4 selector,
        bool authorized,
        IAuthHook authHook
    ) external;
    function setVoter(address newVoter) external;
    function operatorPermissions(address caller, address target, bytes4 selector) external view returns (bool authorized, IAuthHook hook);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IGovStaker {
    /* ========== EVENTS ========== */
    event RewardAdded(address indexed rewardToken, uint256 amount);
    event RewardTokenAdded(address indexed rewardsToken, address indexed rewardsDistributor, uint256 rewardsDuration);
    event Recovered(address indexed token, uint256 amount);
    event RewardsDurationUpdated(address indexed rewardsToken, uint256 duration);
    event RewardPaid(address indexed user, address indexed rewardToken, uint256 reward);
    event Staked(address indexed account, uint indexed epoch, uint amount);
    event Unstaked(address indexed account, uint amount);
    event Cooldown(address indexed account, uint amount, uint end);
    event CooldownEpochsUpdated(uint24 newDuration);

    /* ========== STRUCTS ========== */
    struct Reward {
        address rewardsDistributor;
        uint256 rewardsDuration;
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }

    struct AccountData {
        uint120 realizedStake; // Amount of stake that has fully realized weight.
        uint120 pendingStake; // Amount of stake that has not yet fully realized weight.
        uint16 lastUpdateEpoch;
    }

    struct UserCooldown {
        uint104 end;
        uint152 amount;
    }

    enum ApprovalStatus {
        None, // 0. Default value, indicating no approval
        StakeOnly, // 1. Approved for stake only
        UnstakeOnly, // 2. Approved for unstake only
        StakeAndUnstake // 3. Approved for both stake and unstake
    }

    /* ========== STATE VARIABLES ========== */
    function rewardTokens(uint256 index) external view returns (address);
    function rewardData(address token) external view returns (Reward memory);
    function rewards(address account, address token) external view returns (uint256);
    function userRewardPerTokenPaid(address account, address token) external view returns (uint256);
    function CORE() external view returns (address);
    function PRECISION() external view returns (uint256);
    function ESCROW() external view returns (address);
    function MAX_COOLDOWN_DURATION() external view returns (uint24);
    function totalPending() external view returns (uint120);
    function totalLastUpdateEpoch() external view returns (uint16);
    function cooldownEpochs() external view returns (uint256);
    function decimals() external view returns (uint8);
    function approvedCaller(address account, address caller) external view returns (ApprovalStatus);

    /* ========== EXTERNAL FUNCTIONS ========== */
    function accountData(address account) external view returns (AccountData memory);
    function stakeToken() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function getReward() external;
    function getOneReward(address rewardsToken) external;
    function addReward(address rewardsToken, address rewardsDistributor, uint256 rewardsDuration) external;
    function notifyRewardAmount(address rewardsToken, uint256 rewardAmount) external;
    function setRewardsDistributor(address rewardsToken, address rewardsDistributor) external;
    function setRewardsDuration(address rewardsToken, uint256 rewardsDuration) external;
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external;
    function stake(address account, uint amount) external returns (uint);
    function stakeFor(address account, uint amount) external returns (uint);
    function cooldown(address account, uint amount) external returns (uint);
    function cooldowns(address account) external view returns (UserCooldown memory);
    function cooldownFor(address account, uint amount) external returns (uint);
    function exit(address account) external returns (uint);
    function exitFor(address account) external returns (uint);
    function unstake(address account, address receiver) external returns (uint);
    function unstakeFor(address account, address receiver) external returns (uint);
    function checkpointAccount(address account) external returns (AccountData memory, uint weight);
    function checkpointAccountWithLimit(address account, uint epoch) external returns (AccountData memory, uint weight);
    function checkpointTotal() external returns (uint);
    function setApprovedCaller(address caller, ApprovalStatus status) external;
    function setCooldownEpochs(uint24 epochs) external;
    function getAccountWeight(address account) external view returns (uint);
    function getAccountWeightAt(address account, uint epoch) external view returns (uint);
    function getTotalWeight() external view returns (uint);
    function getTotalWeightAt(uint epoch) external view returns (uint);
    function getUnstakableAmount(address account) external view returns (uint);
    function isCooldownEnabled() external view returns (bool);
    function rewardTokensLength() external view returns (uint256);
    function earned(address account, address rewardsToken) external view returns (uint256 pending);
    function earnedMulti(address account) external view returns (uint256[] memory pending);
    function rewardPerToken(address rewardsToken) external view returns (uint256 rewardAmount);
    function lastTimeRewardApplicable(address rewardsToken) external view returns (uint256);
    function getRewardForDuration(address rewardsToken) external view returns (uint256);
    function owner() external view returns (address);
    function guardian() external view returns (address);
    function getEpoch() external view returns (uint);
    function epochLength() external view returns (uint);
    function startTime() external view returns (uint);
    function irreversiblyCommitAccountAsPermanentStaker(address account) external;
    function onPermaStakeMigrate(address account) external;
    function migrateStake() external returns (uint amount);
    function setDelegateApproval(address delegate, bool approved) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IGovStaker } from "./IGovStaker.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVestClaimCallback {
    event RecoveredERC20(address indexed token, address indexed recipient, uint256 amount);

    function govStaker() external view returns (IGovStaker);
    function vestManager() external view returns (address);
    function token() external view returns (IERC20);
    
    function onClaim(
        address account,
        address recipient,
        uint256 amount
    ) external returns (bool success);
    
    function recoverERC20(address token, address recipient, uint256 amount) external;
}