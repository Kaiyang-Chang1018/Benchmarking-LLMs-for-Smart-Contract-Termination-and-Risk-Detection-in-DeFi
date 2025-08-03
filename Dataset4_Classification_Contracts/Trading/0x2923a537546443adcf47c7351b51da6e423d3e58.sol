// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

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
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
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
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
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
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
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
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
//SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @title Auction
 * @author @brougkr
 * @notice A Smart Contract To Facilitate Ascending Rebate Auctions (With Ascending Rebate Reserve Floor) For Multiple NFTs (Or Whatever Else You Want To Sell) 
 */
pragma solidity 0.8.19;
import { DelegateCashEnabled } from "./DelegateCashEnabled.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
contract AuctionMarketplace is DelegateCashEnabled, ReentrancyGuard, Ownable
{
    struct Bid
    {
        uint _OGBidIndex; // [0] -> Original Bid Index
        uint _Priority;   // [1] -> Priority Of Bid (Merkle Rank)
        uint _ETHValue;   // [2] -> ETH Value Of Bid
        uint _Timestamp;  // [3] -> Unix Timestamp Of Bid Confirmation
        address _Bidder;  // [4] -> Wallet Address Of Bidder
        address _Vault;   // [5] -> Wallet Address Of Vault (optional `delegate.cash` support)
        bool _Rebated;    // [6] -> If Bidder Rebated ETH From Bid
        bool _Winner;     // [7] -> If Bidder Is A Winner (Top Placing) In The Auction
        bool _NFTSent;    // [8] -> If Bidder Has Received Their NFT
    }

    struct Params
    {
        string _Name;                // [0] -> Name Of Auction
        bool _KickbackEnabled;       // [1] -> If Next Bidder Rebate Previous Bidder
        bool _ClearingEnabled;       // [2] -> If Rebate Last Price Is Enabled (Everyone Pays Lowest Leaderboard Price)
        bool _UserSettlementEnabled; // [3] -> If Self-Service User Settlement Is Enabled (Bidders Can Settle Their Own Bids ETH & NFTs)
        uint _LeaderboardSize;       // [4] -> The Bid Threshold For NewMinimumBid (eg. 50 Valid Bids)
        uint _UnixStartTime;         // [5] -> Unix Start Time Of Auction
        uint _UnixEndTime;           // [6] -> Unix End Time Of Auction
        uint _MinBIPSIncrease;       // [7] -> Minimum BIPS (%) Increase On Each Subsequent Bid After Configured LeaderboardSize 
        uint _SecondsExtension;      // [8] -> # Of Second(s) Of Extension For Auction (Input In Seconds)
        uint _SecondsThreshold;      // [9] -> # Of Seconds Within Auction End Time To Be Eligible For Auction Extension
        uint _InitialMinimumBid;     // [10] -> Initial Minimum Bid
        uint _ProjectIDMintPass;     // [11] -> The Factory MintPass ProjectID
        address _NFT;                // [12] -> Address Of NFT Contract
        address _Operator;           // [13] -> Wallet Holding NFTs To Disperse
    }

    struct State
    {
        bool _Active;           // [0] -> _Active
        bool _NFTsDispersed;    // [1] -> _NFTsDispersed
        uint _LastMinBid;       // [2] -> _LastMinBid
        uint _GlobalUniqueBids; // [3] -> _GlobalUniqueBids
    }

    struct AllAuctionParams
    {
        string _Name;            // [0] -> Name Of Auction
        bool _Active;            // [1] -> If Sale Is Active
        bool _NFTsDispersed;     // [2] -> If NFTs Have Been Dispersed
        bool _KickbackEnabled;   // [3] -> If Next Bidder Rebate Previous Bidder
        bool _ClearingEnabled;   // [4] -> If Rebate Last Price Is Enabled (Everyone Pays Lowest Leaderboard Price)
        uint _LeaderboardSize;   // [5] -> The Bid Threshold For NewMinimumBid (eg. 50 Valid Bids)
        uint _UnixStartTime;     // [6] -> Unix Start Time Of Auction
        uint _UnixEndTime;       // [7] -> Unix End Time Of Auction
        uint _MinBIPSIncrease;   // [8] -> Minimum BIPS (%) Increase On Each Subsequent Bid After 50 Unique Bids 
        uint _SecondsExtension;  // [9] -> # Of Seconds(s) Of Extension For Auction (Input In # Of Seconds)
        uint _SecondsThreshold;  // [10] -> # Of Seconds Within Auction End Time To Be Eligible For Auction Extension
        uint _LastMinBid;        // [11] -> Value Of The Last Minimum Bid
        uint _GlobalUniqueBids;  // [12] -> # Of Global Unique Bids
        uint _ProjectIDMintPass; // [13] -> The Factory MintPass ProjectID
        address _NFT;            // [14] -> Address Of NFT Contract
    }

    /*-----------------------------
     * STATE VARIABLES & MAPPINGS *
    ------------------------------*/

    mapping(uint=>Params) public AuctionParams;
    mapping(uint=>State) public SaleState;
    mapping(uint=>mapping(uint=>Bid)) public Bids;
    mapping(uint=>mapping(uint=>uint)) public Leaderboard;
    mapping(uint=>mapping(address=>uint[])) public UserBidIndexes;
    mapping(address=>bool) public Admin;
    mapping(uint=>mapping(uint=>bool)) public NFTTokenIDHasBeenSent;
    mapping(uint=>uint[]) public Discounts;
    mapping(uint=>bytes32[]) public Roots;
    mapping(uint=>mapping(address=>mapping(uint=>uint))) public PriorityPurchaseAmount; // [SaleIndex][Wallet][Priority] => Purchased Amount For Priority Level
    address private constant _BRT_MULTISIG = 0x0BC56e3c1397e4570069e89C07936A5c6020e3BE;
    uint public _GLOBAL_UNIQUE_SALES;

    /*---------
     * EVENTS *
    ----------*/

    /**
     * @dev Emitted When A New Bid Is Submitted
     */
    event NewBidComplete(uint BidIndex, address Bidder, uint MessageValue, uint Unixtimestamp, address Vault);

    /**
     * @dev Emitted When A Bid Is Topped Up
     */
    event BidToppedUp(uint BidIndex, uint ETHForBid, uint Unixtimestamp, address Bidder);

    /**
     * @dev Emitted When A Bid Reclaim Fails
     */
    event BidReclaimFailed(uint BidIndex);

    /**
     * @dev Emitted When A Bid Reclaim Succeeds
     */
    event BidReclaimSuccess(uint BidIndex);

    /**
     * @dev Emitted When A Bidder's ETH Is Rebated (The Bid They Are Trying To Top Up Was Frontran)
     */
    event BidTopupRefunded(uint Rebate);

    /**
     * @dev Emitted When The Auction End Time Is Extended
     */
    event AuctionExtended();

    /**
     * @dev Emitted When A Bid Is Refunded (Kicked Back To Losing Bidder)
     */
    event BidRefunded(uint BidIndex);

    /*--------------
     * CONSTRUCTOR *
    ---------------*/

    constructor() 
    {
        Admin[msg.sender] = true; // sets owner as admin
        SaleState[0]._Active = true; // activates auction
        SaleState[0]._LastMinBid = 2.5 ether; // starts auction specified ETH value
        AuctionParams[0]._Name = 'Hashmarks'; // sets auction name
        AuctionParams[0]._KickbackEnabled = true; // enables kickback
        // AuctionParams[0]._ClearingEnabled = false; // enables rebate last price
        // AuctionParams[0]._UserSettlementEnabled = false; // enables self-service user auction settlement
        AuctionParams[0]._LeaderboardSize = 50; // (max # of bids on leaderboard)
        AuctionParams[0]._UnixStartTime = block.timestamp; // sets auction start time
        AuctionParams[0]._UnixEndTime = block.timestamp + 694200 seconds; // sets auction end time
        AuctionParams[0]._MinBIPSIncrease = 105; // 5% Increase On Each Subsequent Bid After 50 Unique Bids
        AuctionParams[0]._SecondsExtension = 600 seconds; // # Of Seconds Of Extension
        AuctionParams[0]._SecondsThreshold = 600 seconds; // # Of Seconds Within Auction End Time Where Auction Extension Is Enabled
        AuctionParams[0]._NFT = 0x37fa4aCa3125660d4B8f4A6b1d0Ab8AF6a6C1f13; // Hashmarks Mint Pass
        Roots[0].push(0xbb9d32f908b1b7ec4241468d3ec82305ac46bddc361b4da9a500625a5bed5986); // Merkle Root
        Roots[0].push(0xbb9d32f908b1b7ec4241468d3ec82305ac46bddc361b4da9a500625a5bed5986);
        Discounts[0].push(80); // 20% Discount
        Discounts[0].push(90); // 10% Discount
    }

    /*-----------------
     * USER FUNCTIONS *
    ------------------*/
    
    /**
     * @dev Submits A New Bid To The Auction
     * @param SaleIndex The Sale Index To Target
     * @param Vault Optional delegate.xyz Integration | note: Input 0x0000000000000000000000000000000000000000 If No Delegate
     * @param Proof The Merkle Proof For The Bidder's Priority | note: Input [0x0000000000000000000000000000000000000000000000000000000000000000] If No Merkle Proof
     */
    function NewBid(uint SaleIndex, address Vault, bytes32[] calldata Proof) external payable nonReentrant
    {
        require(tx.origin == msg.sender, "Auction: EOA Only, Use `delegate.cash` For Wallet Delegation"); // Requires `msg.sender` Is A Valid EOA
        require(SaleState[SaleIndex]._Active, "Auction: Auction Has Ended"); // Requires The Auction Is Active
        require(block.timestamp >= AuctionParams[SaleIndex]._UnixStartTime, "Auction: Auction Has Not Started"); // Requires The Auction Has Started
        require(block.timestamp < AuctionParams[SaleIndex]._UnixEndTime, "Auction: Auction Has Concluded"); // Requires The Auction Has Not Ended
        address Recipient = msg.sender;
        if(Vault != address(0)) { if(DelegateCash.checkDelegateForAll(msg.sender, Vault)) { Recipient = Vault; } } // `delegate.cash` Integration
        __FinalizeNewBid(SaleIndex, msg.value); // Auto-Calculates The Required Reserve Price For The Bid (+5%)
        __CheckAndSeedAuctionEndTime(SaleIndex); // Checks If Auction End Time Should Be Extended And Extends If Necessary
        uint Priority = _ValidateMerkleProof(SaleIndex, Recipient, Proof); // Validates Merkle Proof And Returns Merkle Priority
        uint CurrentBidIndex = SaleState[SaleIndex]._GlobalUniqueBids; // Current Bid Index
        Bids[SaleIndex][CurrentBidIndex] = Bid(CurrentBidIndex, Priority, msg.value, block.timestamp, msg.sender, Recipient, false, false, false); // Registers New Bid
        UserBidIndexes[SaleIndex][msg.sender].push(CurrentBidIndex); // Appends Bid Index To User's Bid Indexes
        SaleState[SaleIndex]._GlobalUniqueBids = CurrentBidIndex + 1; // Increments Global Unique Bids
        emit NewBidComplete(CurrentBidIndex, msg.sender, msg.value, block.timestamp, Recipient); // Emits Bid Event
    }

    /**
     * @dev Tops Up Bid(s) With Additional ETH
     * @param SaleIndex The Sale Index To Target
     * @param BidIndexes[] The Bid Indexes To Top Up
     * @param Amounts[] The Amounts (In WEI) To Top Up The Corresponding Bid Indexes By
     */
    function IncreaseBid(uint SaleIndex, uint[] calldata BidIndexes, uint[] calldata Amounts) external payable nonReentrant
    {
        require(tx.origin == msg.sender, "Auction: EOA Only, Use `delegate.cash` For Wallet Delegation"); // Requires `msg.sender` Is A Valid EOA
        require(SaleState[SaleIndex]._Active, "Auction: Auction Has Ended"); // Requires The Auction Is Active
        require(block.timestamp >= AuctionParams[SaleIndex]._UnixStartTime, "Auction: Auction Has Not Started"); // Requires The Auction Has Started
        require(block.timestamp < AuctionParams[SaleIndex]._UnixEndTime, "Auction: Auction Has Concluded"); // Requires The Auction Has Not Ended
        require(BidIndexes.length == Amounts.length, "Auction: BidIndexes And Amounts Array Length Mismatch"); // Requires BidIndexes And Amounts Length Match
        require(BidIndexes.length > 0, "Auction: User Has Input No Bids To Top Up"); // Requires User Has Bids To Top Up
        require(AuctionParams[SaleIndex]._KickbackEnabled, "Auction: Cannot Top Up, Kickback Must Be Enabled For Entire Auction"); // Requires Kickback Is Enabled
        if(!AuctionParams[SaleIndex]._ClearingEnabled) { __CheckAndSeedAuctionEndTime(SaleIndex); } // Checks If Auction End Time Should Be Extended And Extends If Necessary
        Bid memory _Bid;
        uint Total;
        uint BidValue;
        for(uint x; x < BidIndexes.length; x++)
        { 
            _Bid = Bids[SaleIndex][BidIndexes[x]];
            BidValue = _Bid._ETHValue;
            if(!_Bid._Rebated && !_Bid._Winner)
            {
                require(msg.sender == _Bid._Bidder, "Auction: `msg.sender` Is Not The Bidder Of Desired Bid Index");
                require(BidValue + Amounts[x] >= (BidValue * AuctionParams[SaleIndex]._MinBIPSIncrease) / 100, "Auction: Bid Amount Topup Requires >= 5% Increase");
                Bids[SaleIndex][BidIndexes[x]]._ETHValue += Amounts[x];
                Bids[SaleIndex][BidIndexes[x]]._Timestamp = block.timestamp;
                Total += Amounts[x];
                emit BidToppedUp(BidIndexes[x], Amounts[x], block.timestamp, msg.sender);
            }
        }
        uint Rebate = msg.value - Total; // Rebates Excess ETH (If Total > msg.value This Will Revert)
        if(Rebate > 0)
        {
            (bool Success, ) = msg.sender.call { value: Rebate }("");
            require(Success, "Auction: Failed To Rebate Excess ETH To Bidder, Resubmit Transaction");
            emit BidTopupRefunded(Rebate);
        }
    }

    /**
     * @dev Rebates ETH From Bid(s) If Bidder Is Not A Winner & Disperses NFTs If Winner
     * @param SaleIndex The Sale Index To Finalize
     */
    function UserSettleAuction(uint SaleIndex) external nonReentrant
    {
        require(tx.origin == msg.sender, "Auction: EOA Only, Use `delegate.cash` For Wallet Delegation"); // Requires `msg.sender` Is A Valid EOA
        require(!SaleState[SaleIndex]._NFTsDispersed, "Auction: NFTs Have Been Dispersed");
        require(AuctionParams[SaleIndex]._KickbackEnabled, "Auction: Cannot Finalize, Kickback Must Be Enabled For Entire Auction");
        require(AuctionParams[SaleIndex]._UserSettlementEnabled, "Auction: User Settlement Is Not Enabled");
        require(UserBidIndexes[SaleIndex][msg.sender].length > 0, "Auction: User Has No Bids To Settle");
        require(block.timestamp > AuctionParams[SaleIndex]._UnixEndTime, "Auction: Cannot Finalize, Auction Is Still Active");
        address Bidder = msg.sender;
        __UserDisperseETH(SaleIndex, Bidder);
        __UserDisperseNFT(SaleIndex, Bidder);
    }

    /*------------------
     * ADMIN FUNCTIONS *
    -------------------*/

    /**
     * @dev Starts Auction
     * @param AuctionInfo The Struct Of Auction Info 
     * @param MerkleRoots The Merkle Roots For The Auction
     * @param DiscountAmounts The Discount Amounts For The Auction ([80,90] = 20% Discount, 10% Discount)
     */
    function __StartAuction(Params memory AuctionInfo, bytes32[] calldata MerkleRoots, uint[] calldata DiscountAmounts) external onlyAdmin returns (uint SaleIndex)
    { 
        require(AuctionInfo._UnixStartTime > block.timestamp, "Auction: Start Time Must Be In The Future");
        if(AuctionInfo._UserSettlementEnabled) { require(AuctionInfo._KickbackEnabled, "Auction: Kickback & User Settlement Must Both Be Active"); }
        AuctionParams[_GLOBAL_UNIQUE_SALES] = AuctionInfo; 
        SaleState[_GLOBAL_UNIQUE_SALES]._LastMinBid = AuctionParams[_GLOBAL_UNIQUE_SALES]._InitialMinimumBid;
        Discounts[_GLOBAL_UNIQUE_SALES] = DiscountAmounts;
        Roots[_GLOBAL_UNIQUE_SALES] = MerkleRoots;
        _GLOBAL_UNIQUE_SALES = _GLOBAL_UNIQUE_SALES + 1;
        for(uint x; x < DiscountAmounts.length; x++) { require(DiscountAmounts[x] <= 100, "Invalid Discount Amount"); }
        return _GLOBAL_UNIQUE_SALES - 1;
    }

    /**
     * @dev Changes The Sale Roots
     * @param SaleIndex The Sale Index To Change
     * @param NewRoots The New Merkle Roots To Change
     */
    function ___ChangeRoots(uint SaleIndex, bytes32[] calldata NewRoots) external onlyAdmin { Roots[SaleIndex] = NewRoots; }

    /**
     * @dev Changes The Sale Discounts
     * @param SaleIndex The Sale Index To Change
     * @param NewDiscountAmounts The New Discount Amounts To Change
     */
    function ___ChangeDiscountAmounts(uint SaleIndex, uint[] calldata NewDiscountAmounts) external onlyAdmin { Discounts[SaleIndex] = NewDiscountAmounts; }

    /**
     * @dev Changes The MintPass ProjectID
     * @param SaleIndex The Sale Index To Change
     * @param MintPassProjectID The New MintPass ProjectID To Change
     */
    function ___ChangeMintPassProjectID(uint SaleIndex, uint MintPassProjectID) external onlyAdmin { AuctionParams[SaleIndex]._ProjectIDMintPass = MintPassProjectID;}

    /**
     * @dev Changes The Auction Global Pause State At `SaleIndex`
     * @param SaleIndex The Sale Index To Change
     */
    function ___ChangeActiveState(uint SaleIndex) external onlyAdmin { SaleState[SaleIndex]._Active = !SaleState[SaleIndex]._Active; }

    /**
     * @dev Changes If The Lowest Valid Leaderboard Bid Gets Sent/Kicked Back Their ETH If Removed From Leaderboard
     * @param SaleIndex The Sale Index To Change
     * @param NewState The New State (Boolean) (True = Rebate Lowest Valid Leaderboard Bid, False = Do Not Rebate Lowest Valid Leaderboard Bid)
     */
    function ___ChangeKickbackEnabled(uint SaleIndex, bool NewState) external onlyAdmin { AuctionParams[SaleIndex]._KickbackEnabled = NewState; }

    /**
     * @dev Changes Min Bid
     * @param SaleIndex The Sale Index To Change
     * @param NewMinBid The New Minimum Bid 
     */
    function ___ChangeMinBid(uint SaleIndex, uint NewMinBid) external onlyAdmin { SaleState[SaleIndex]._LastMinBid = NewMinBid; }
    
    /**
     * @dev Changes If The Lowest Valid Leaderboard Bid Is What Everyone Pays
     * @param SaleIndex The Sale Index To Change
     * @param NewState The New State (Boolean) (True = Everyone Pays Lowest Leaderboard Bid, False = Everyone Pays Their Bid ETH Value) 
     */
    function ___ChangeClearingEnabled(uint SaleIndex, bool NewState) external onlyAdmin { AuctionParams[SaleIndex]._ClearingEnabled = NewState; }
    
    /**
     * @dev Changes The Bid Threshold (Controls The Leaderboard Size)
     * @param SaleIndex The Sale Index To Change
     * @param NewLeaderboardSize The New Leaderboard Size
     */
    function ___ChangeLeaderboardSize(uint SaleIndex, uint NewLeaderboardSize) external onlyAdmin { AuctionParams[SaleIndex]._LeaderboardSize = NewLeaderboardSize; }

    /**
     * @dev Changes The Unix Start Time
     * @param SaleIndex The Sale Index To Change
     * @param NewUnixStartTime The New Unix Start Time
     */
    function ___ChangeUnixStartTime(uint SaleIndex, uint NewUnixStartTime) external onlyAdmin { AuctionParams[SaleIndex]._UnixStartTime = NewUnixStartTime; }

    /**
     * @dev Changes The Unix End Time
     * @param SaleIndex The Sale Index To Change
     * @param NewUnixEndTime The New Unix End Time
     */
    function ___ChangeUnixEndTime(uint SaleIndex, uint NewUnixEndTime) external onlyAdmin { AuctionParams[SaleIndex]._UnixEndTime = NewUnixEndTime; }

    /**
     * @dev Changes The Minimum BIPs Increase
     * @param SaleIndex The Sale Index To Change
     * @param NewMinBIPSIncrease The New Minimum BIPs Increase (In BIPS) (105 = 5% Increase, 150 = 50% Increase etc...)
     */
    function ___ChangeMinBIPSIncrease(uint SaleIndex, uint NewMinBIPSIncrease) external onlyAdmin { AuctionParams[SaleIndex]._MinBIPSIncrease = NewMinBIPSIncrease; }

    /**
     * @dev Changes The # Of Seconds The Auction Is Extended By If Auction End Time Is Within `AuctionParams[SaleIndex]._SecondsThreshold`
     * @param SaleIndex The Sale Index To Change
     * @param Seconds The New # Of Seconds To Extend Auction By
     */
    function ___ChangeSecondsExtension(uint SaleIndex, uint Seconds) external onlyAdmin { AuctionParams[SaleIndex]._SecondsExtension = Seconds; }

    /**
     * @dev Changes The # Of Seconsd Within Auction End Time To Be Eligible For Auction Extension
     * @param SaleIndex The Sale Index To Change
     * @param Seconds The New # Of Seconds Within Auction End Time To Be Eligible For Auction Extension
     */
    function ___ChangeSecondsThreshold(uint SaleIndex, uint Seconds) external onlyAdmin { AuctionParams[SaleIndex]._SecondsThreshold = Seconds; }

    /**
     * @dev Changes The Current NFT Address
     * @param SaleIndex The Sale Index To Change
     * @param NewAddress The New NFT Address
     */
    function ___ChangeNFTAddress(uint SaleIndex, address NewAddress) external onlyAdmin { AuctionParams[SaleIndex]._NFT = NewAddress; }

    /**
     * @dev Changes The Current Operator Address (Address That Holds NFTs To Disperse)
     * @param SaleIndex The Sale Index To Change
     * @param Operator The New Operator Address (Address Holding NFTs To Disperse)
     */
    function ___ChangeOperator(uint SaleIndex, address Operator) external onlyAdmin { AuctionParams[SaleIndex]._Operator = Operator; }

    /**
     * @dev Rebate All Unclaimed Bids & Sends Remaining ETH To Multisig
     * @param SaleIndex The Sale Index To Trigger Disbursement
     */
    function ___InitiateRebateAndProceeds(uint SaleIndex) external onlyAdmin 
    { 
        SaleState[SaleIndex]._Active = false; // Ends Auction
        __AdminInitiateProceeds(SaleIndex); // Initiates Admin Withdraw Of Proceeds (MUST BE CALLED FIRST)
    }

    /**
     * @dev Initiates Withdrawl Proceeds & Disperses NFTs To The Top Bidders On The Leaderboard (First-Come-First-Serve) (When TokenID Is Ambiguous)
     * @param SaleIndex The Sale Index To Trigger Disbursement
     */
    function ___ProcessETHAndNFTsTokenIDsAmbiguous(uint SaleIndex) external onlyAdmin
    {
        SaleState[SaleIndex]._Active = false;     // Ends Auction
        __AdminInitiateProceeds(SaleIndex);       // Initiates Admin Withdraw Of Proceeds (MUST BE CALLED FIRST)
        __DisperseNFTsByFCFSAmbiguous(SaleIndex); // Initiates Admin Disperse Of NFTs (MUST BE CALLED LAST)
    }

    /**
     * @dev Initiates Withdrawl Proceeds & Disperses NFTs To The Top Bidders On The Leaderboard (Ascending Ranking) (When TokenID Matters)
     * @param SaleIndex The Sale Index To Trigger Disbursement
     */
    function ___ProcessETHAndNFTsTokenIDsDistinct(uint SaleIndex) external onlyAdmin
    {
        SaleState[SaleIndex]._Active = false;     // Ends Auction
        __AdminInitiateProceeds(SaleIndex);       // Initiates Admin Withdraw Of Proceeds (MUST BE CALLED FIRST)
        __DisperseNFTsByAscendingRank(SaleIndex); // Initiates Admin Disperse Of NFTs (MUST BE CALLED LAST)
    }

    /**
     * @dev Initiates Withdrawl Proceeds & Disperses NFTs To The Top Bidders On The Leaderboard With Specific TokenIDs (No Ranking)
     * @param SaleIndex The Sale Index To Trigger Disbursement
     */
    function ___ProcessETHAndNFTsTokenIDsSpecificUnranked(uint SaleIndex, uint[] calldata TokenIDs) external onlyAdmin
    {
        SaleState[SaleIndex]._Active = false;                // Ends Auction
        __AdminInitiateProceeds(SaleIndex);                  // Initiates Admin Withdraw Of Proceeds (MUST BE CALLED FIRST)
        __DisperseNFTsByUniqueTokenIDs(SaleIndex, TokenIDs); // Initiates Admin Disperse Of NFTs (MUST BE CALLED LAST)
    }

    /**
     * @dev Initiates Withdrawl Proceeds & Disperses NFTs To The Top Bidders On The Leaderboard With Specific TokenIDs (Ascending Ranking)
     * @param SaleIndex The Sale Index To Trigger Disbursement
     */
    function ___ProcessETHAndNFTsTokenIDsSpecificRanked(uint SaleIndex, uint[] calldata TokenIDs) external onlyAdmin
    {
        SaleState[SaleIndex]._Active = false;                         // Ends Auction
        __AdminInitiateProceeds(SaleIndex);                           // Initiates Admin Withdraw Of Proceeds (MUST BE CALLED FIRST)
        __DisperseNFTsByUniqueTokenIDsAscending(SaleIndex, TokenIDs); // Initiates Admin Disperse Of NFTs (MUST BE CALLED LAST)
    }

    /*------------------
     * OWNER FUNCTIONS *
    -------------------*/

    /**
     * @dev Adds An Admin
     * @param Wallet The Wallet To Add As An Admin
     */
    function ____AuthorizeAddress(address Wallet) external onlyOwner { Admin[Wallet] = true; }

    /**
     * @dev Removes An Admin
     * @param Wallet The Wallet To Remove As An Admin
     */
    function ____DeuthorizeAddress(address Wallet) external onlyOwner { Admin[Wallet] = false; }

    /**
     * @dev Initiates Withdrawl Proceeds For The Leaderboard
     * @param SaleIndex The Sale Index To Trigger Disbursement
     */
    function ____InitiateOnlyProceeds(uint SaleIndex) external onlyOwner { __AdminInitiateProceeds(SaleIndex); }

    /**
     * @dev Withdraws All Ether From The Contract   
     * @notice This Is A Safety Function To Prevent Ether Locking, Only Use In An Emergency
     */
    function ____WithdrawEther() external onlyOwner { payable(msg.sender).transfer(address(this).balance); }

    /**
     * @dev Withdraws Ether From Contract To Address With An Amount
     * @param Recipient The Recipient Of The Ether
     * @param Amount The Amount Of Ether To Withdraw (In WEI)
     * @notice This Is A Safety Function To Prevent Ether Locking, Only Use In An Emergency
     */
    function ____WithdrawEtherToAddress(address payable Recipient, uint Amount) external onlyOwner
    {
        require(Amount > 0 && Amount <= address(this).balance, "Invalid Amount");
        (bool Success, ) = Recipient.call{value: Amount}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }

    /*---------------------
     * INTERNAL FUNCTIONS *
    ----------------------*/

    /**
     * @dev Calculates The Minimum Valid Bid And Seeds The Leaderboard
     * @param SaleIndex The Sale Index To Calculate The Minimum Valid Bid For
     * @param MsgValue The Message Value (In WEI) To Calculate The Minimum Valid Bid For
     */
    function __FinalizeNewBid(uint SaleIndex, uint MsgValue) internal
    {
        (uint MinBid, uint LeaderboardIndex) = _ViewMinimumValidBidAndIndex(SaleIndex);
        require(MsgValue >= MinBid, "Auction: Bid Amount Must Be >= Current Leaderboard Floor * 1.05"); // Requires Min Bid
        bool Valid = (SaleState[SaleIndex]._GlobalUniqueBids >= AuctionParams[SaleIndex]._LeaderboardSize);
        if(AuctionParams[SaleIndex]._KickbackEnabled && Valid) { __KickbackETH(SaleIndex, LeaderboardIndex); } // Rebate ETH To Previous Bidder
        if(Valid) { SaleState[SaleIndex]._LastMinBid = MinBid; }
        Leaderboard[SaleIndex][LeaderboardIndex] = SaleState[SaleIndex]._GlobalUniqueBids; // Kicks Old Bid Index Out Of Leaderboard
    }

    /**
     * @dev Kicks Losing Bidder's ETH Back To Them
     * @param SaleIndex The Sale Index To Trigger Disbursement
     * @param LeaderboardIndex The Leaderboard Index To Kickback ETH To
     */
    function __KickbackETH(uint SaleIndex, uint LeaderboardIndex) internal 
    {
        if(!Bids[SaleIndex][Leaderboard[SaleIndex][LeaderboardIndex]]._Rebated)
        {
            Bids[SaleIndex][Leaderboard[SaleIndex][LeaderboardIndex]]._Rebated = true;
            (bool Success,) = Bids[SaleIndex][Leaderboard[SaleIndex][LeaderboardIndex]]._Bidder.call 
            { value: Bids[SaleIndex][Leaderboard[SaleIndex][LeaderboardIndex]]._ETHValue }("");
            require(Success, "Auction: Kickback Failed");
            emit BidRefunded(Bids[SaleIndex][Leaderboard[SaleIndex][LeaderboardIndex]]._OGBidIndex);
        } 
    }

    /**
     * @dev Finalizes ETH From User's Pending Bid(s)
     * @param SaleIndex The Sale Index To Trigger Disbursement
     * @param Bidder The Bidder To Disperse ETH To
     */
    function __UserDisperseETH(uint SaleIndex, address Bidder) internal
    {
        uint[] memory _UserBidIndexes = UserBidIndexes[SaleIndex][Bidder];
        uint LLB = _ViewLowestLeaderboardBid(SaleIndex);
        uint TotalRebate;
        uint TotalPaid;
        uint CurrentRebate;
        uint CurrentPaid;
        uint Discount;
        for(uint x; x < UserBidIndexes[SaleIndex][Bidder].length; x++) 
        { 
            if (
                !Bids[SaleIndex][_UserBidIndexes[x]]._Winner 
                && 
                !Bids[SaleIndex][_UserBidIndexes[x]]._Rebated 
                && 
                Bids[SaleIndex][_UserBidIndexes[x]]._ETHValue >= LLB
            )
            {
                Bids[SaleIndex][UserBidIndexes[SaleIndex][Bidder][x]]._Winner = true; 
                if(Bids[SaleIndex][_UserBidIndexes[x]]._Priority != 69420) { Discount = Discounts[SaleIndex][Bids[SaleIndex][_UserBidIndexes[x]]._Priority]; }
                else { Discount = 100; }    
                if(AuctionParams[SaleIndex]._ClearingEnabled)
                {
                    Bids[SaleIndex][_UserBidIndexes[x]]._Rebated = true;
                    CurrentRebate = ((Bids[SaleIndex][_UserBidIndexes[x]]._ETHValue - LLB) * Discount) / 100;
                    CurrentPaid = Bids[SaleIndex][_UserBidIndexes[x]]._ETHValue - CurrentRebate;
                    TotalRebate += CurrentRebate;
                }
                else { CurrentPaid = Bids[SaleIndex][_UserBidIndexes[x]]._ETHValue; }
                TotalPaid += (CurrentPaid * Discount) / 100;
            }
        }
        (bool MultisigWithdraw, ) = _BRT_MULTISIG.call { value: TotalPaid }("");
        require(MultisigWithdraw, "Auction: Multisig Withdraw Failed");
        if(TotalRebate > 0)
        {
            (bool UserWithdraw, ) = Bidder.call { value: TotalRebate }("");
            require(UserWithdraw, "Auction: User Withdraw Failed");
        }
    }

    /**
     * @dev Disperses NFTs
     * @param SaleIndex The Sale Index To Trigger Disbursement
     * @param Bidder The Bidder To Disperse NFTs To
     */
    function __UserDisperseNFT(uint SaleIndex, address Bidder) internal
    {
        IERC721 _NFT = IERC721(AuctionParams[SaleIndex]._NFT);
        for(uint x; x < UserBidIndexes[SaleIndex][Bidder].length; x++) 
        { 
            if(
                Bids[SaleIndex][UserBidIndexes[SaleIndex][Bidder][x]]._Winner 
                && 
                !Bids[SaleIndex][UserBidIndexes[SaleIndex][Bidder][x]]._NFTSent
            )
            {
                Bids[SaleIndex][UserBidIndexes[SaleIndex][Bidder][x]]._NFTSent = true;
                _NFT._MintToFactory(Bidder, 1); 
            }
        }
    }

    /**
     * @dev Initiates Proceeds From The Leaderboard
     * @param SaleIndex The Sale Index To Trigger Disbursement
     */
    function __AdminInitiateProceeds(uint SaleIndex) internal
    {
        uint TotalProceeds;
        uint LLB = _ViewLowestLeaderboardBid(SaleIndex);
        uint RebateAmount;
        uint Discount;
        uint Priority;
        uint ETHValue;
        for(uint x; x < AuctionParams[SaleIndex]._LeaderboardSize; x++)
        {
            if (
                !Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Rebated 
                && 
                !Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Winner 
                && 
                Bids[SaleIndex][Leaderboard[SaleIndex][x]]._ETHValue >= LLB
            )
            {
                Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Winner = true;
                Priority = Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Priority;
                ETHValue = Bids[SaleIndex][Leaderboard[SaleIndex][x]]._ETHValue;
                if(Priority != 69420) { Discount = Discounts[SaleIndex][Priority]; }
                else { Discount = 100; }
                if(AuctionParams[SaleIndex]._ClearingEnabled)
                {
                    Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Rebated = true;
                    RebateAmount = ((ETHValue - LLB) * Discount) / 100;
                }
                else { RebateAmount = ETHValue - ((ETHValue * Discount) / 100); }
                if(RebateAmount > 0)
                {
                    (bool Rebate, ) = Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Bidder.call { value: RebateAmount }("");                    
                    require(Rebate, "Auction: Failed To Rebate ETH To Bidder, Use Failsafe Withdraw");
                }
                TotalProceeds += (ETHValue - RebateAmount);
            }
        }
        (bool MultisigWithdraw, ) = _BRT_MULTISIG.call { value: TotalProceeds }("");
        require(MultisigWithdraw, "Auction: Admin Failed To Withdraw ETH To Multisig, Use Failsafe Withdraw");
    }

    /**
     * @dev Validates The Auction End Time & Extends If Necessary
     * @param SaleIndex The Sale Index To Check
     */
    function __CheckAndSeedAuctionEndTime(uint SaleIndex) internal 
    {
        // Extends Auction If Rebate Last Price (Clearing Price) Is Not Enabled (For Sales Where Leaderboard Placement Matters)
        if((AuctionParams[SaleIndex]._UnixEndTime - block.timestamp) < AuctionParams[SaleIndex]._SecondsThreshold) // If Bid Placed In Last 5 Minutes
        { 
            AuctionParams[SaleIndex]._UnixEndTime = block.timestamp + AuctionParams[SaleIndex]._SecondsExtension; // Extends Auction By The # Of Configured Seconds 
            emit AuctionExtended();
        }
    }

    /**
     * @dev Disperses NFTs With Unique TokenIDs
     * @param TokenIDs Array Of TokenIDs To Be Dispersed
     */
    function __DisperseNFTsByUniqueTokenIDs(uint SaleIndex, uint[] calldata TokenIDs) internal
    {
        require(!SaleState[SaleIndex]._Active, "Auction: Auction Is Still Active, Must Disperse Funds & Finalize Auction First");
        require(!SaleState[SaleIndex]._NFTsDispersed, "Auction: NFTs Already Dispersed");
        require(TokenIDs.length == AuctionParams[SaleIndex]._LeaderboardSize, "Auction: TokenIDs Array Length Must Match Leaderboard Size");
        address _Op = AuctionParams[SaleIndex]._Operator;
        IERC721 _NFT = IERC721(AuctionParams[SaleIndex]._NFT);
        for(uint x; x < TokenIDs.length; x++)
        {
            require(!NFTTokenIDHasBeenSent[SaleIndex][TokenIDs[x]], "Auction: TokenID Already Sent");
            NFTTokenIDHasBeenSent[SaleIndex][TokenIDs[x]] = true;
            _NFT.transferFrom(_Op, Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Bidder, TokenIDs[x]);
        }
    }

    /**
     * @dev Disperses NFTs With Unique TokenIDs
     * @param TokenIDs Array Of TokenIDs To Be Dispersed
     */
    function __DisperseNFTsByUniqueTokenIDsAscending(uint SaleIndex, uint[] calldata TokenIDs) internal
    {
        require(!SaleState[SaleIndex]._Active, "Auction: Auction Is Still Active, Must Disperse Funds & Finalize Auction First");
        require(!SaleState[SaleIndex]._NFTsDispersed, "Auction: NFTs Already Dispersed");
        require(TokenIDs.length == AuctionParams[SaleIndex]._LeaderboardSize, "Auction: TokenIDs Array Length Must Match Leaderboard Size");
        uint[] memory _Ind = _ViewSortedLeaderboardBidIndexes(SaleIndex);
        address _Op = AuctionParams[SaleIndex]._Operator;
        IERC721 _NFT = IERC721(AuctionParams[SaleIndex]._NFT);
        for(uint x; x < TokenIDs.length; x++)
        {
            require(!NFTTokenIDHasBeenSent[SaleIndex][TokenIDs[x]], "Auction: TokenID Already Sent");
            NFTTokenIDHasBeenSent[SaleIndex][TokenIDs[x]] = true;
            _NFT.transferFrom(_Op, Bids[SaleIndex][_Ind[x]]._Bidder, TokenIDs[x]);
        }
    }

    /**
     * @dev Disperses NFTs To The Top Bidders On The Leaderboard (First-Come-First-Serve) (Use When TokenID Is Ambiguous)
     * @param SaleIndex The Sale Index To Trigger Disbursement
     */
    function __DisperseNFTsByFCFSAmbiguous(uint SaleIndex) internal
    {
        require(!SaleState[SaleIndex]._Active, "Auction: Auction Is Still Active, Must Disperse Funds & Finalize Auction First");
        require(!SaleState[SaleIndex]._NFTsDispersed, "Auction: NFTs Already Dispersed");
        SaleState[SaleIndex]._NFTsDispersed = true;
        IERC721 _NFT = IERC721(AuctionParams[SaleIndex]._NFT);
        for(uint x; x < AuctionParams[SaleIndex]._LeaderboardSize; x++) 
        { 
            if(Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Winner && !Bids[SaleIndex][Leaderboard[SaleIndex][x]]._NFTSent)
            {
                Bids[SaleIndex][Leaderboard[SaleIndex][x]]._NFTSent = true;
                _NFT._MintToFactory(Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Bidder, 1); 
            }
        }
    }

    /**
     * @dev Disperses NFTs By Ascending Ranking Of The Leaderboard (Use When TokenID Matters)
     * @param SaleIndex The Sale Index To Trigger Disbursement
     */
    function __DisperseNFTsByAscendingRank(uint SaleIndex) internal
    {
        require(SaleState[SaleIndex]._Active == false, "Auction: Auction Is Still Active, Must Disperse Funds First");
        require(!SaleState[SaleIndex]._NFTsDispersed, "Auction: NFTs Already Dispersed");
        SaleState[SaleIndex]._NFTsDispersed = true;
        IERC721 _NFT = IERC721(AuctionParams[SaleIndex]._NFT);
        uint[] memory _Ind = _ViewSortedLeaderboardBidIndexes(SaleIndex);
        for(uint x; x < _Ind.length; x++)
        { 
            if(Bids[SaleIndex][_Ind[x]]._Winner && !Bids[SaleIndex][_Ind[x]]._NFTSent)
            {
                Bids[SaleIndex][_Ind[x]]._NFTSent = true;
                _NFT._MintToFactory(Bids[SaleIndex][_Ind[x]]._Bidder, 1); 
            }
        }
    }

    /*------------------------
     * PUBLIC VIEW FUNCTIONS *
    -------------------------*/

    /**
     * @dev Returns All Necessary Leaderboard Components
     * @param SaleIndex The Sale Index To View
     * @param Wallet The Wallet Address Of The Bidder ('0x0000000000000000000000000000000000000000') If No Wallet
     */
    function ViewFrontend(uint SaleIndex, address Wallet) public view returns (
        uint _LLB, 
        uint _MVB, 
        AllAuctionParams memory _AuctionParams, 
        Bid[] memory _RankedLeaderboard,
        Bid[] memory _MasterBids,
        uint[] memory _UserBidIndexes
    ) {
        uint LLB = _ViewLowestLeaderboardBid(SaleIndex);
        _MasterBids = _ViewBidsUnique(SaleIndex);
        _RankedLeaderboard = _ViewLeaderboardRanked(SaleIndex);
        uint MVB = LLB * (AuctionParams[SaleIndex]._MinBIPSIncrease) / 100;
        if(SaleState[SaleIndex]._GlobalUniqueBids < AuctionParams[SaleIndex]._LeaderboardSize) 
        { (LLB, MVB) = (SaleState[SaleIndex]._LastMinBid, SaleState[SaleIndex]._LastMinBid); }
        return (
            LLB,
            MVB,
            ViewAuctionParams(SaleIndex),
            ViewLeaderboardRanked(SaleIndex),
            _MasterBids,
            UserBidIndexes[SaleIndex][Wallet]
        );
    }

    /**
     * @dev Returns The Total Bid Volume Of The Auction
     * @param SaleIndex The Sale Index To View
     */
    function ViewTotalBidVolume(uint SaleIndex) public view returns (uint) 
    { 
        uint TotalBidVolume;
        for(uint x; x < SaleState[SaleIndex]._GlobalUniqueBids; x++) { TotalBidVolume += Bids[SaleIndex][x]._ETHValue; }
        return TotalBidVolume;
    }

    /**
     * @dev Returns The Total Proceeds For An Auction
     * @param SaleIndex The Sale Index To View
     */
    function ViewTotalProceeds(uint SaleIndex) public view returns (uint)
    {
        uint LLB = _ViewLowestLeaderboardBid(SaleIndex);
        uint Rev;
        uint Rebate;
        uint Discount;
        uint Priority;
        uint ETHValue;
        for(uint x; x < AuctionParams[SaleIndex]._LeaderboardSize; x++) 
        { 
            ETHValue = Bids[SaleIndex][Leaderboard[SaleIndex][x]]._ETHValue;
            Priority = Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Priority;
            if(Priority != 69420) { Discount = Discounts[SaleIndex][Priority]; }
            else { Discount = 100; }
            if(AuctionParams[SaleIndex]._ClearingEnabled) 
            { 
                Rebate = ((Bids[SaleIndex][Leaderboard[SaleIndex][x]]._ETHValue - LLB) * Discount) / 100; 
            }
            else { Rebate = ETHValue - ((ETHValue * Discount) / 100); }
            Rev += (ETHValue - Rebate); 
        }
        return Rev;
    }

    /**
     * @dev Returns The Total Rebates For An Auction
     * @param SaleIndex The Sale Index To View
     */
    function ViewTotalRebate(uint SaleIndex) public view returns(uint) { return (ViewTotalBidVolume(SaleIndex) - ViewTotalProceeds(SaleIndex)); }

    /**
     * @dev Returns A `bool` If Math Checks Out
     * @param SaleIndex The Sale Index To View
     */
    function ViewTotalBalanceResult(uint SaleIndex) public view returns (bool)
    {
        return(ViewTotalBidVolume(SaleIndex) - ViewTotalRebate(SaleIndex) - ViewTotalProceeds(SaleIndex) == 0);
    }

    /**
     * @dev Returns A Raw Sum Of The ETH Volume From The Leaderboard
     * @param SaleIndex The Sale Index To View
     */
    function ViewLeaderboardTotalBidVolume(uint SaleIndex) public view returns(uint)
    {
        uint TotalBidVolume;
        for(uint x; x < AuctionParams[SaleIndex]._LeaderboardSize; x++) 
        { 
            TotalBidVolume += Bids[SaleIndex][Leaderboard[SaleIndex][x]]._ETHValue;
        }
        return TotalBidVolume;
    }

    /**
     * @dev Returns A Raw Sum Of The ETH Volume From The Leaderboard
     * @param SaleIndex The Sale Index To View
     */
    function ViewLeaderboardTotalBidValue(uint SaleIndex) public view returns(uint)
    {
        uint LLB = _ViewLowestLeaderboardBid(SaleIndex);
        uint Rebate;
        uint TotalBidValue;
        for(uint x; x < AuctionParams[SaleIndex]._LeaderboardSize; x++) 
        { 
            if(AuctionParams[SaleIndex]._ClearingEnabled) { Rebate = Bids[SaleIndex][Leaderboard[SaleIndex][x]]._ETHValue - LLB; }
            TotalBidValue += (Bids[SaleIndex][Leaderboard[SaleIndex][x]]._ETHValue - Rebate);
        }
        return TotalBidValue;
    }

    /**
     * @dev Returns All Bid Values In The Leaderboard
     * @param SaleIndex The Sale Index To View
     */
    function ViewLeaderboardBids(uint SaleIndex) public view returns (uint[] memory)
    {
        uint[] memory _Indexes = ViewLeaderboardIndexes(SaleIndex);
        uint[] memory _BidValues = new uint[](AuctionParams[SaleIndex]._LeaderboardSize);
        for(uint x; x < AuctionParams[SaleIndex]._LeaderboardSize; x++) { _BidValues[x] = Bids[SaleIndex][_Indexes[x]]._ETHValue; }
        return _BidValues;
    }

    /**
     * @dev Returns The Current Bid Leaderboard
     * @param SaleIndex The Sale Index To View
     */
    function ViewLeaderboardRaw(uint SaleIndex) public view returns (Bid[] memory)
    {
        Bid[] memory _Leaderboard = new Bid[](AuctionParams[SaleIndex]._LeaderboardSize);
        for(uint x; x < AuctionParams[SaleIndex]._LeaderboardSize; x++) { _Leaderboard[x] = Bids[SaleIndex][Leaderboard[SaleIndex][x]]; }
        return _Leaderboard;
    }

    /**
     * @dev Returns A Bid Array Of Ranked Top Bids
     * @param SaleIndex The Sale Index To View
     */
    function ViewLeaderboardRanked(uint SaleIndex) public view returns(Bid[] memory) { return _ViewLeaderboardRanked(SaleIndex); }

    /**
     * @dev Returns All Bid Indexes In The Leaderboard
     * @param SaleIndex The Sale Index To View
     */
    function ViewLeaderboardIndexes(uint SaleIndex) public view returns (uint[] memory)
    {
        uint[] memory _LeaderboardIndexes = new uint[](AuctionParams[SaleIndex]._LeaderboardSize);
        for(uint x; x < AuctionParams[SaleIndex]._LeaderboardSize; x++) { _LeaderboardIndexes[x] = Leaderboard[SaleIndex][x]; }
        return _LeaderboardIndexes;
    }

    /**
     * @dev Returns A Individual 'Bid' Struct Corresponding To Input Index
     * @param SaleIndex The Sale Index To View
     */
    function ViewBid(uint SaleIndex, uint Index) public view returns (Bid memory) { return Bids[SaleIndex][Index]; }

    /**
     * @dev Returns The Minimum Valid Bid 
     * @param SaleIndex The Sale Index To View
     */
    function ViewMinimumValidBid(uint SaleIndex) public view returns (uint ValidBid) 
    { 
        (ValidBid,) = _ViewMinimumValidBidAndIndex(SaleIndex);
        return ValidBid;
    }

    /**
     * @dev Returns A 'Bid' Struct Array Corresponding To Input Indexes
     * @param SaleIndex The Sale Index To View
     * @param Indexes The Indexes To Return
     */
    function ViewBidsAtIndexes(uint SaleIndex, uint[] calldata Indexes) public view returns(Bid[] memory) 
    {
        Bid[] memory _Bids = new Bid[](Indexes.length);
        for(uint x; x < Indexes.length; x++) { _Bids[x] = Bids[SaleIndex][Indexes[x]]; }
        return _Bids;
    }

    /**
     * @dev Returns A 'Bid' Struct Array Of All Unique Bids In The Auction
     * @param SaleIndex The Sale Index To View
     * note: this will throw `out of gas` after 1648~ unique bids because block gas limit is 30M, use `ViewBids()` with indexes after 1648~ unique bids
     */
    function ViewBidsUnique(uint SaleIndex) public view returns(Bid[] memory) { return _ViewBidsUnique(SaleIndex); }

    /**
     * @dev Returns A `Bid` Struct Array Of All Unique Bids In The Auction Submitted By `Wallet`
     * @param SaleIndex The Sale Index To View
     * @param Wallet The Wallet Address To View
     */
    function ViewWalletBids(uint SaleIndex, address Wallet) public view returns(Bid[] memory)
    {
        uint[] memory _Indexes = UserBidIndexes[SaleIndex][Wallet];
        Bid[] memory _Bids = new Bid[](_Indexes.length);
        for(uint x; x < _Indexes.length; x++) { _Bids[x] = Bids[SaleIndex][_Indexes[x]]; }
        return _Bids;
    }

    /**
     * @dev Returns An Array Of `Wallet` Submitted Bid Indexes
     * @param SaleIndex The Sale Index To View
     * @param Wallet The Wallet Address To View
     */
    function ViewWalletBidIndexes(uint SaleIndex, address Wallet) public view returns(uint[] memory) { return UserBidIndexes[SaleIndex][Wallet]; }

    /**
     * @dev Returns All Of The Current Auction Parameters
     * @param SaleIndex The Sale Index To View
     */
    function ViewAuctionParams(uint SaleIndex) public view returns (AllAuctionParams memory)
    {
        return AllAuctionParams (
            AuctionParams[SaleIndex]._Name,
            SaleState[SaleIndex]._Active,
            SaleState[SaleIndex]._NFTsDispersed,
            AuctionParams[SaleIndex]._KickbackEnabled,
            AuctionParams[SaleIndex]._ClearingEnabled,
            AuctionParams[SaleIndex]._LeaderboardSize,
            AuctionParams[SaleIndex]._UnixStartTime,
            AuctionParams[SaleIndex]._UnixEndTime,
            AuctionParams[SaleIndex]._MinBIPSIncrease,
            AuctionParams[SaleIndex]._SecondsExtension,
            AuctionParams[SaleIndex]._SecondsThreshold,
            SaleState[SaleIndex]._LastMinBid,
            SaleState[SaleIndex]._GlobalUniqueBids,
            AuctionParams[SaleIndex]._ProjectIDMintPass,
            AuctionParams[SaleIndex]._NFT
        );
    }

    /**
     * @dev Returns Merkle Roots For A Specific Sale
     * @param SaleIndex The Sale Index To View
     */
    function ViewRoots(uint SaleIndex) public view returns (bytes32[] memory) { return Roots[SaleIndex]; }

    /**
     * @dev Returns A Sorted uint[] Of Leaderboard Bid Indexes
     * @param SaleIndex The Sale Index To View
     */
    function ViewSortLeaderboardBidIndexes(uint SaleIndex) public view returns (uint[] memory) { return _ViewSortedLeaderboardBidIndexes(SaleIndex); }

    /*--------------------------
     * INTERNAL VIEW FUNCTIONS *
    ---------------------------*/

    /**
     * @dev Validates Merkle Proof And Returns Merkle Priority
     * @param SaleIndex The Sale Index To View
     * @param Bidder The Bidder To Validate
     * @param Proof The Merkle Proof To Validate
     */
    function _ValidateMerkleProof(uint SaleIndex, address Bidder, bytes32[] calldata Proof) internal view returns (uint)
    {
        bytes32 Leaf = keccak256(abi.encodePacked(Bidder));
        for(uint Priority; Priority < Roots[SaleIndex].length; Priority++) 
        { 
            if(MerkleProof.verify(Proof, Roots[SaleIndex][Priority], Leaf)) { return Priority; } 
        }
        return 69420; // Returns Default Out Of Bounds Priority
    }

    /**
     * @dev Returns The Leaderboard Index Of The Smallest Bid In The Leaderboard 
     * @param SaleIndex The Sale Index To View
     */
    function _ViewMinimumValidLeaderboardIndex(uint SaleIndex) internal view returns (uint)
    {
        uint CurrentMinBid = type(uint).max;
        uint LeaderboardIndexToReplace;
        uint ETHValue;
        if(SaleState[SaleIndex]._GlobalUniqueBids < AuctionParams[SaleIndex]._LeaderboardSize) { return SaleState[SaleIndex]._GlobalUniqueBids; }
        for(uint IndexLeaderboard; IndexLeaderboard < AuctionParams[SaleIndex]._LeaderboardSize; IndexLeaderboard++)
        {
            ETHValue = Bids[SaleIndex][Leaderboard[SaleIndex][IndexLeaderboard]]._ETHValue;
            if(ETHValue <= CurrentMinBid)
            { 
                CurrentMinBid = ETHValue;
                LeaderboardIndexToReplace = IndexLeaderboard; 
            }
        }
        return LeaderboardIndexToReplace;
    }

    /**
     * @dev Returns The Lowest Bid In The Leaderboard
     * @param SaleIndex The Sale Index To View
     */
    function _ViewLowestLeaderboardBid(uint SaleIndex) internal view returns (uint LLB)
    {
        LLB = type(uint).max;
        for(uint x; x < AuctionParams[SaleIndex]._LeaderboardSize; x++)
        {
            if(Bids[SaleIndex][Leaderboard[SaleIndex][x]]._ETHValue < LLB) { LLB = Bids[SaleIndex][Leaderboard[SaleIndex][x]]._ETHValue; }
        }
        return LLB;
    }

    /**
     * @dev Returns The Minimum Valid Bid Which Is The Current Lowest Bid In The Leaderboard * 1.05
     * @param SaleIndex The Sale Index To View
     */
    function _ViewMinimumValidBidAndIndex(uint SaleIndex) internal view returns (uint, uint) 
    {
        uint LeaderboardIndex = _ViewMinimumValidLeaderboardIndex(SaleIndex);
        return (        
            SaleState[SaleIndex]._GlobalUniqueBids < AuctionParams[SaleIndex]._LeaderboardSize 
            ? // If Unique Bids Less Than LeaderboardSize Return NewMinimumBid & Eligible LeaderboardIndex
            (SaleState[SaleIndex]._LastMinBid, LeaderboardIndex) 
            : // Else Return NewMinimumBid & Eligible LeaderboardIndex
            ((Bids[SaleIndex][Leaderboard[SaleIndex][LeaderboardIndex]]._ETHValue * AuctionParams[SaleIndex]._MinBIPSIncrease) / 100, LeaderboardIndex) 
        );
    }

    /**
     * @dev Returns A 'Bid' Struct Array Of All Unique Bids In The Auction
     * @param SaleIndex The Sale Index To View
     * note: this will throw `out of gas` after 1648~ unique bids because block gas limit is 30M, use `ViewBids()` with indexes after 1648~ unique bids
     */
    function _ViewBidsUnique(uint SaleIndex) internal view returns(Bid[] memory)
    {
        uint GlobalUniqueBids = SaleState[SaleIndex]._GlobalUniqueBids;
        Bid[] memory _Bids = new Bid[](GlobalUniqueBids);
        for(uint x; x < GlobalUniqueBids; x++) { _Bids[x] = Bids[SaleIndex][x]; }
        return _Bids;
    }
    
    /**
     * @dev Returns A Bid Array Of Ranked Top Bids
     * @param SaleIndex The Sale Index To View
     */
    function _ViewLeaderboardRanked(uint SaleIndex) internal view returns(Bid[] memory)
    {
        uint[] memory _Ind = _ViewSortedLeaderboardBidIndexes(SaleIndex);
        Bid[] memory _Leaderboard = new Bid[](_Ind.length);
        for(uint x; x < _Ind.length; x++) { _Leaderboard[x] = Bids[SaleIndex][_Ind[x]]; }
        return _Leaderboard;
    }

    /**
     * @dev Returns A Sorted List Of ETH Bids @ '[n][0]' & The Indexes Of The Original Bids @ '[n][1]' & The Timestamps @ '[n][2]'
     * @param SaleIndex The Sale Index To View
     * note: This Will Give Priority To Earlier Bid Indexes & Timestamps
     * note: insertion sort O(n^2) seemed like best approach because english auction bids increase as auction progresses, otherwise quicksort prob better O(nlogn)
     * note: because block gas limit is 30M, this will `out-of-gas` dependant on how much sorting needs done if you have a more eloquent way of doing this hmu
     * note: you should (in general) not sort large things in solidity (as of 0.8~) because it is very gas inefficient, this is just for demonstration purposes
     */
    function _ViewSortedLeaderboardBidIndexes(uint SaleIndex) internal view returns (uint[] memory)
    {
        uint Size;
        if(SaleState[SaleIndex]._GlobalUniqueBids < AuctionParams[SaleIndex]._LeaderboardSize) { Size = SaleState[SaleIndex]._GlobalUniqueBids; }
        else { Size = AuctionParams[SaleIndex]._LeaderboardSize; }
        uint[][] memory BidsAndIndexes = new uint[][](Size);
        for(uint x; x < BidsAndIndexes.length; x++) 
        {
            BidsAndIndexes[x] = new uint[](3);                      // Init Sub-Array
            BidsAndIndexes[x][0] = Bids[SaleIndex][Leaderboard[SaleIndex][x]]._ETHValue;  // Assign [x][0] -> ETHValue
            BidsAndIndexes[x][1] = Leaderboard[SaleIndex][x];                  // Assign [x][1] -> Original Index
            BidsAndIndexes[x][2] = Bids[SaleIndex][Leaderboard[SaleIndex][x]]._Timestamp; // Assign [x][2] -> Timestamp
        }
        for(uint i; i < BidsAndIndexes.length; i++)
        {
            uint ETHValue = BidsAndIndexes[i][0];   // Preserve ETHValue
            uint OGBidIndex = BidsAndIndexes[i][1]; // Preserve OGBidIndex
            uint Timestamp = BidsAndIndexes[i][2];  // Preserve Timestamp
            uint j = i;
            while(j > 0 && BidsAndIndexes[j-1][0] >= ETHValue)
            {
                if(
                    BidsAndIndexes[j-1][0] == ETHValue && BidsAndIndexes[j-1][1] > OGBidIndex // Preserve Lower Original Index
                    ||
                    BidsAndIndexes[j-1][0] == ETHValue && BidsAndIndexes[j-1][2] > Timestamp  // Preserve Lower Timestamp
                ) { break; } 
                BidsAndIndexes[j][0] = BidsAndIndexes[j-1][0]; // Move Larger Element To The Right
                BidsAndIndexes[j][1] = BidsAndIndexes[j-1][1]; // Move OG Index
                BidsAndIndexes[j][2] = BidsAndIndexes[j-1][2]; // Move Timestamp
                j--;
            }
            BidsAndIndexes[j][0] = ETHValue;   // Insert ETHValue In Correct Location
            BidsAndIndexes[j][1] = OGBidIndex; // Insert OGBidIndex In Correct Location
            BidsAndIndexes[j][2] = Timestamp;  // Insert Timestamp In Correct Location
        } 
        uint[] memory SortedBidIndexes = new uint[](Size);
        for(uint y; y < BidsAndIndexes.length; y++) { SortedBidIndexes[Size - 1 - y] = BidsAndIndexes[y][1]; }
        return SortedBidIndexes;
    }

    /**
     * @dev onlyAdmin Modifier
     */
    modifier onlyAdmin
    {
        require(Admin[msg.sender], "Auction: onlyAdmin: Caller Is Not Admin");
        _;
    }
}

/**
 * @dev Interface For ERC721 Contracts
 */
interface IERC721 
{ 
    /**
     * @dev Mints A NFT From Custom Smart Contract Directly
     */
    function _MintToFactory(address Recipient, uint Amount) external; 

    /**
     * @dev Transfers An Already Minted NFT
     */
    function transferFrom(address from, address to, uint tokenID) external;
}
//SPDX-License-Identifier: MIT
/**
 * @title DelegateCashEnabled
 * @author @brougkr
 * @notice For Easily Integrating `delegate.cash`
 */
pragma solidity 0.8.19;
abstract contract DelegateCashEnabled
{
    address private constant _DN = 0x00000000000076A84feF008CDAbe6409d2FE638B;
    IDelegation public constant DelegateCash = IDelegation(_DN);
}

interface IDelegation
{
    /**
     * @dev Returns If A Vault Has Delegated To The Delegate
     */
    function checkDelegateForAll(address delegate, address vault) external view returns (bool);
}
// SPDX-License-Identifier: MIT
/**
 * @title IMinter Minter Interface
 * @author @brougkr
 */
pragma solidity ^0.8.19;
interface IMinter 
{ 
    function purchase(uint256 _projectId) payable external returns (uint tokenID); // Custom
    function purchaseTo(address _to, uint _projectId) payable external returns (uint tokenID); // ArtBlocks Standard Minter
    function purchaseTo(address _to) external returns (uint tokenID); // Custom
    function purchaseTo(address _to, uint _projectId, address _ownedNFTAddress, uint _ownedNFTTokenID) payable external returns (uint tokenID); // ArtBlocks PolyMinter
    function tokenURI(uint256 _tokenId) external view returns (string memory);
    function _MintToFactory(uint ProjectID, address To, uint Amount) external; // MintPassFactory
    function _MintToFactory(address To, uint Amount) external; // MintPassBespoke
}
//SPDX-License-Identifier: MIT
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/**
 * @dev: @brougkr
 */
pragma solidity 0.8.19;
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IMinter } from "./IMinter.sol";
import { DelegateCashEnabled } from "./DelegateCashEnabled.sol";
contract Marketplace is Ownable, ReentrancyGuard, DelegateCashEnabled
{
    struct SaleTypePresale 
    {
        string _Name;              // [0] -> _Name
        address _Operator;         // [1] -> _Operator
        address _NFT;              // [2] -> _NFT
        uint _MaxForSale;          // [3] -> _MaxForSale
        uint _MaxPerPurchase;      // [4] -> _MaxPerPurchase
        uint _PricePresale;        // [5] -> _PricePresale
        uint _PricePublic;         // [6] -> _PricePublic
        uint _TimestampEndFullSet; // [7] -> _TimestampEndFullSet
        uint _TimestampEndCitizen; // [8] -> _TimestampEndCitizen
        uint _TimestampSaleStart;  // [9] -> _TimestampSaleStart
        uint _Type;                // [10] -> _Type
        uint _ProjectID;           // [11] -> _ProjectID
    }

    struct InternalPresaleSale
    {
        bool _Active;                 // [0] -> _Active
        uint _AmountSold;             // [1] -> _AmountSold
        uint _ETHRevenue;             // [2] -> _ETHRevenue
        uint _GlobalPurchasesFullSet; // [3] -> _GlobalPurchasesFullSet
        uint _GlobalPurchasesCitizen; // [4] -> _GlobalPurchasesCitizen
        uint _GlobalPurchasesPublic;  // [5] -> _GlobalPurchasesPublic
        uint _CurrentTokenIndex;      // [6] -> _CurrentTokenIndex
        uint _AmountSoldFullSet;      // [7] -> _AmountSoldFullSet
        uint _AmountSoldCitizen;      // [8] -> _AmountSoldCitizen
        uint _AmountSoldPublic;       // [9] -> _AmountSoldPublic
    }

    struct InternalPresaleSaleRoots
    {
        bytes32 _RootEligibilityFullSet; // [0] -> _RootEligibilityFullSet
        bytes32 _RootEligibilityCitizen; // [1] -> _RootEligibilityCitizen
        bytes32 _RootAmountFullSet;      // [2] -> _RootAmountFullSet
        bytes32 _RootAmountCitizen;      // [3] -> _RootAmountCitizen
    }

    struct InternalPresaleWalletInfo    
    {
        uint _AmountPurchasedFullSetWindow; // [0] -> _AmountPurchasedFullSetWindow
        uint _AmountPurchasedCitizenWindow; // [1] -> _AmountPurchasedCitizenWindow
        uint _AmountPurchasedWallet;        // [2] -> _AmountPurchasedWallet
    }

    struct SaleInfoPresale
    {
        uint _ETHRevenue;                   // [0] -> _ETHRevenue
        uint _PricePresale;                 // [1] -> _PricePresale
        uint _PricePublic;                  // [2] -> _PricePublic
        uint _MaxForSale;                   // [3] -> _MaxForSale
        uint _AmountRemaining;              // [4] -> _AmountRemaining
        uint _TimestampEndFullSet;          // [5] -> _TimestampEndFullSet
        uint _TimestampEndCitizen;          // [6] -> _TimestampEndCitizen
        uint _TimestampSaleStart;           // [7] -> _TimestampSaleStart
        uint _AmountPurchasableFullSet;     // [8] -> _AmountPurchasableFullSet
        uint _AmountPurchasableCitizen;     // [9] -> _AmountPurchasableCitizen
        uint _AmountPurchasedFullSetWindow; // [10] -> _AmountPurchasedFullSetWindow
        uint _AmountPurchasedCitizenWindow; // [11] -> _AmountPurchasedCitizenWindow
        uint _GlobalPurchasesFullSet;       // [12] -> _GlobalPurchasesFullSet
        uint _GlobalPurchasesCitizen;       // [13] -> _GlobalPurchasesCitizen
        uint _GlobalPurchasesPublic;        // [14] -> _GlobalPurchasesPublic
        uint _AmountPurchasedWallet;        // [15] -> _AmountPurchasedWallet
        bool _EligibleFullSet;              // [16] -> _EligibleFullSet
        bool _EligibleCitizen;              // [17] -> _EligibleCitizen
        bool _ValidMaxAmountFullSet;        // [18] -> _ValidMaxAmountFullSet
        bool _ValidMaxAmountCitizen;        // [19] -> _ValidMaxAmountCitizen
    }

    struct SaleTypeFixedPrice
    {
        string _Name;                 // [0] -> _Name
        uint _Price;                  // [1] -> _Price
        uint _MintPassProjectID;      // [2] -> _MintPassProjectID
        uint _Type;                   // [3] -> _Type
        uint _ABProjectID;            // [4] -> _ABProjectID
        uint _AmountForSale;          // [5] -> _AmountForSale
        uint _TimestampStart;         // [6] -> _TimestampStart
        uint _CurrentIndex;           // [7] -> _CurrentIndex
        address _NFT;                 // [8] -> _NFT
        address _Operator;            // [9] -> _Operator
        bytes32[] _RootEligibilities; // [10] -> _RootEligibilities
        bytes32[] _RootAmounts;       // [11] -> _RootAmounts
    }

    struct FixedPriceSaleInfo
    {
        uint _ETHRevenue;                    // [0] -> _ETHRevenue
        uint _Price;                         // [1] -> _Price
        uint _AmountForSale;                 // [2] -> _AmountForSale
        uint _AmountRemaining;               // [3] -> _AmountRemaining
        uint _TimestampStart;                // [4] -> _TimestampStart
        uint _Priority;                      // [5] -> _Priority
        uint _AmountRemainingMerklePriority; // [6] -> _AmountRemainingMerklePriority
        uint _AmountPurchasedUser;           // [7] -> _AmountPurchasedUser
        bool _BrightListEligible;            // [8] -> _BrightListEligible
        bool _BrightListAmounts;             // [9] -> _BrightListAmounts
        uint[] _DiscountAmountWEIValues;     // [10] -> _DiscountAmountWEIValues
    }

    /*------------------
     * STATE VARIABLES *
    -------------------*/

    uint public _TOTAL_UNIQUE_PRESALE_SALES; // Total Unique Presale Sales                
    uint public _TOTAL_UNIQUE_FIXED_SALES; // Total Unique Fixed Price Sales
    address private constant _BRT_MULTISIG = 0x0BC56e3c1397e4570069e89C07936A5c6020e3BE; // `sales.brightmoments.eth`
    
    /*-----------
     * MAPPINGS *
    ------------*/

    mapping(uint=>SaleTypeFixedPrice) public FixedPriceSales;
    mapping(uint=>SaleTypePresale) public PresaleSales;                           
    mapping(uint=>InternalPresaleSale) public PresaleSalesInternal;            
    mapping(uint=>uint) public AmountSoldFixedPrice;
    mapping(uint=>uint[]) public DiscountAmounts;
    mapping(uint=>InternalPresaleSaleRoots) public InternalRoots;              
    mapping(uint=>mapping(address=>InternalPresaleWalletInfo)) public InternalSaleWalletInfo;
    mapping(uint=>uint) public ETHRevenueFixedPriceSale;
    mapping(uint=>mapping(address=>mapping(uint=>uint))) public PriorityPurchaseAmount; // [SaleIndex][Wallet][Priority] => Purchased Amount For Priority Level
    mapping(address=>bool) public Admin;  
    mapping(uint=>mapping(address=>uint)) public UserPurchasedAmount;


    event PurchasedPresale(uint SaleIndex, address Purchaser, uint DesiredAmount, uint MessageValue, bool PresaleEnded);    
    event SaleStarted(uint SaleIndex);
    event Refunded(address Refundee, uint Amount);
    event Purchased(uint SaleIndex, address Purchaser, uint Amount, uint Priority);
    event Fullset();
    event Citizen();
    event Public();

    constructor() 
    { 
        Admin[msg.sender] = true; 
        Admin[0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700] = true;
        Admin[0x90D98d5A1fD21B7cEa4D5c18341607ed1a8345c0] = true;
        Admin[0x18B7511938FBe2EE08ADf3d4A24edB00A5C9B783] = true;
        _transferOwnership(0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700);
    }

    /*---------------------
     * EXTERNAL FUNCTIONS *
    ----------------------*/

    /**
     * @dev Presale Purchase
     */
    function PurchasePresale (
        uint SaleIndex,                // Index Of Sale
        uint DesiredAmount,            // Desired Purchase Amount
        uint MaxAmount,                // Maximum Purchase Allocation Per Wallet
        address Vault,                 // Delegate.Cash Delegation Registry
        bytes32[] calldata Proof,      // MerkleProof For Eligibility
        bytes32[] calldata ProofAmount // MerkleProof For MaxAmount
    ) external payable nonReentrant {
        require(tx.origin == msg.sender, "Marketplace: EOA Only");
        require(block.timestamp >= PresaleSales[SaleIndex]._TimestampSaleStart, "Marketplace: Sale Not Started");
        address Recipient = msg.sender;
        if(Vault != address(0)) { if(DelegateCash.checkDelegateForAll(msg.sender, Vault)) { Recipient = Vault; } }
        InternalPresaleSale memory _InternalPresaleSale = PresaleSalesInternal[SaleIndex];
        SaleTypePresale memory _PresaleSale = PresaleSales[SaleIndex];
        bool PresaleEnded;
        uint _Price;
        uint _MaxPerPurchase = _PresaleSale._MaxPerPurchase;
        if(_InternalPresaleSale._AmountSold + DesiredAmount > _PresaleSale._MaxForSale) 
        { 
            DesiredAmount = _PresaleSale._MaxForSale - _InternalPresaleSale._AmountSold; // Partial Fill
        } 
        if(block.timestamp <= _PresaleSale._TimestampEndCitizen) // Presale
        {
            if(block.timestamp <= _PresaleSale._TimestampEndFullSet) // Full Set Window
            { 
                require ( // Eligible For Full Set Window
                    VerifyBrightList(Recipient, InternalRoots[SaleIndex]._RootEligibilityFullSet, Proof), 
                    "Full Set Window: Not Eligible For Presale Window Or Block Pending, Please Try Again In A Few Seconds..."
                ); 
                require(VerifyAmount(Recipient, MaxAmount, InternalRoots[SaleIndex]._RootAmountFullSet, ProofAmount), "Invalid Full Set Amount Proof");
                require(InternalSaleWalletInfo[SaleIndex][Recipient]._AmountPurchasedWallet + DesiredAmount <= MaxAmount, "All Full Set Allocation Used");
                InternalSaleWalletInfo[SaleIndex][Recipient]._AmountPurchasedFullSetWindow += DesiredAmount;
                PresaleSalesInternal[SaleIndex]._GlobalPurchasesFullSet += DesiredAmount;
                emit Fullset();
            }
            else // Citizen Window
            { 
                require ( // Eligible For Citizen Window
                    VerifyBrightList(Recipient, InternalRoots[SaleIndex]._RootEligibilityCitizen, Proof), 
                    "Citizen Window: Not Eligible For Presale Window Or Block Pending, Please Try Again In A Few Seconds..."
                ); 
                require(VerifyAmount(Recipient, MaxAmount, InternalRoots[SaleIndex]._RootAmountCitizen, ProofAmount), "Invalid Citizen Amount Proof");
                require(InternalSaleWalletInfo[SaleIndex][Recipient]._AmountPurchasedCitizenWindow + DesiredAmount <= MaxAmount, "All Citizen Allocation Used");
                InternalSaleWalletInfo[SaleIndex][Recipient]._AmountPurchasedWallet += DesiredAmount;
                PresaleSalesInternal[SaleIndex]._GlobalPurchasesCitizen += DesiredAmount;
                emit Citizen();
            }
            _Price = _PresaleSale._PricePresale * DesiredAmount;
        }
        else // Public Sale
        { 
            _Price = _PresaleSale._PricePublic * DesiredAmount;
            PresaleSalesInternal[SaleIndex]._GlobalPurchasesPublic += DesiredAmount;
            PresaleEnded = true; 
            emit Public();
        }
        require(DesiredAmount <= _MaxPerPurchase, "Invalid Desired Purchase Amount. Must Be <= Max Purchase Limit"); // Purchase Limiter
        require(_InternalPresaleSale._AmountSold + DesiredAmount <= _PresaleSale._MaxForSale, "Sale Ended"); // Sale End State
        require(DesiredAmount > 0 && _Price > 0, "Sale Ended"); // Sale End State
        require(msg.value >= _Price, "Invalid ETH Amount"); // Ensures ETH Amount Sent Is Correct
        if(msg.value > _Price) { __Refund(msg.sender, msg.value - _Price); } // Refunds The Difference
        if(_PresaleSale._Type == 0) { IMinter(_PresaleSale._NFT)._MintToFactory(0, msg.sender, DesiredAmount); }
        else if (_PresaleSale._Type == 1) 
        { 
            for(uint x; x < DesiredAmount; x++) { IMinter(_PresaleSale._NFT).purchaseTo(msg.sender, _PresaleSale._ProjectID); }
        }
        PresaleSalesInternal[SaleIndex]._AmountSold += DesiredAmount;
        PresaleSalesInternal[SaleIndex]._CurrentTokenIndex += DesiredAmount;
        PresaleSalesInternal[SaleIndex]._ETHRevenue += _Price;
        InternalSaleWalletInfo[SaleIndex][Recipient]._AmountPurchasedWallet += DesiredAmount;
        emit PurchasedPresale(SaleIndex, Recipient, DesiredAmount, msg.value, PresaleEnded);
    }

    /**
     * @dev Fixed Price Purchase
     */
    function PurchaseFixedPrice (
        uint SaleIndex,
        uint DesiredAmount,
        uint MaxAmount,
        address Vault,
        bytes32[] calldata ProofEligibility,
        bytes32[] calldata ProofAmount
    ) external payable nonReentrant {
        require(tx.origin == msg.sender, "Marketplace: EOA Only");
        address Recipient = msg.sender;
        if(Vault != address(0)) { if(DelegateCash.checkDelegateForAll(msg.sender, Vault)) { Recipient = Vault; } }
        require(block.timestamp >= FixedPriceSales[SaleIndex]._TimestampStart, "Marketplace: Sale Not Started");
        (bool BrightList, uint Priority) = VerifyBrightListWithPriority(SaleIndex, Recipient, ProofEligibility);
        if(BrightList)  
        {
            require (
                VerifyBrightListAmount ( 
                    Recipient, 
                    MaxAmount, 
                    FixedPriceSales[SaleIndex]._RootAmounts[Priority], 
                    ProofAmount
                ), 
                "DutchMarketplace: Invalid Max Amount Merkle Proof For Provided Merkle Priority"
            );
            require (
                msg.value
                == 
                (((FixedPriceSales[SaleIndex]._Price * DesiredAmount) * DiscountAmounts[SaleIndex][Priority]) / 100), 
                "Marketplace: Incorrect BrightList ETH Sent"
            );
            require(DesiredAmount + PriorityPurchaseAmount[SaleIndex][Recipient][Priority] <= MaxAmount, "Marketplace: Desired Purchase Amount Exceeds Purchase Allocation");
            PriorityPurchaseAmount[SaleIndex][Recipient][Priority] += DesiredAmount;
        }
        else { require(msg.value == FixedPriceSales[SaleIndex]._Price * DesiredAmount, "Marketplace: Incorrect ETH Amount Sent"); }
        require(AmountSoldFixedPrice[SaleIndex] + DesiredAmount <= FixedPriceSales[SaleIndex]._AmountForSale, "Marketplace: Not Enough NFTs Left For Sale");
        AmountSoldFixedPrice[SaleIndex] = AmountSoldFixedPrice[SaleIndex] + DesiredAmount;
        if(FixedPriceSales[SaleIndex]._Type == 0) // Factory MintPass Direct Mint
        { 
            IMinter(FixedPriceSales[SaleIndex]._NFT)._MintToFactory(FixedPriceSales[SaleIndex]._MintPassProjectID, msg.sender, DesiredAmount); 
        }
        else if(FixedPriceSales[SaleIndex]._Type == 1) // ArtBlocks purchaseTo() Mint
        { 
            uint ProjectID = FixedPriceSales[SaleIndex]._ABProjectID;
            for(uint x; x < DesiredAmount; x++) { IMinter(FixedPriceSales[SaleIndex]._NFT).purchaseTo(msg.sender, ProjectID); }
        } 
        else if (FixedPriceSales[SaleIndex]._Type == 2) // ERC721 transferFrom() Sale
        {
            IERC721 _NFT = IERC721(FixedPriceSales[SaleIndex]._NFT);
            address _Operator = FixedPriceSales[SaleIndex]._Operator;
            uint _StartingIndex = FixedPriceSales[SaleIndex]._CurrentIndex;
            for(uint x; x < DesiredAmount; x++) { _NFT.transferFrom(_Operator, msg.sender, _StartingIndex + x); }
            FixedPriceSales[SaleIndex]._CurrentIndex += DesiredAmount;
        }
        else { revert('Marketplace: Incorrect Sale Configuration'); }
        UserPurchasedAmount[SaleIndex][Recipient] += DesiredAmount;
        ETHRevenueFixedPriceSale[SaleIndex] += msg.value;
        emit Purchased(SaleIndex, msg.sender, DesiredAmount, Priority);
    }

    /*------------------
     * ADMIN FUNCTIONS *
    -------------------*/

    /**
     * @dev Instantiates A New Presale Sale
     */
    function __StartPresaleSale(SaleTypePresale memory _Sale, InternalPresaleSaleRoots memory _Roots) external onlyAdmin 
    {
        PresaleSales[_TOTAL_UNIQUE_PRESALE_SALES] = _Sale; 
        PresaleSalesInternal[_TOTAL_UNIQUE_PRESALE_SALES]._Active = true;
        InternalRoots[_TOTAL_UNIQUE_PRESALE_SALES] = _Roots;
        emit SaleStarted(_TOTAL_UNIQUE_PRESALE_SALES);
        _TOTAL_UNIQUE_PRESALE_SALES++;
    }

    /**
     * @dev Overwrites A Presale Sale
     * @param SaleIndex The Sale Index To Edit
     * @param _Sale The Fixed Price Sale Struct
     */
    function __OverwritePresaleSale(uint SaleIndex, SaleTypePresale memory _Sale) external onlyAdmin { PresaleSales[SaleIndex] = _Sale; }
    
    /**
     * @dev Changes The Presale Sale Type
     * @param SaleIndex The Sale Index To Edit
     * @param Type The Sale Type (0 = _MintToFactory() | 1 = purchaseTo() | 2 = transferFrom())
     */
    function __ChangePresaleType(uint SaleIndex, uint Type) external onlyAdmin
    {
        PresaleSales[SaleIndex]._Type = Type;
    }

    /**
     * @dev Changes Presale ArtBlocks ProjectID
     * @param SaleIndex The Sale Index To Edit
     * @param ProjectID ArtBlocks ProjectID
     */
    function __ChangePresaleProjectID(uint SaleIndex, uint ProjectID) external onlyAdmin
    {
        PresaleSales[SaleIndex]._ProjectID = ProjectID;
    }

    /**
     * @dev Changes Presale Times
     * @param SaleIndex The Sale Index To Edit
     * @param TimestampSaleStart The Unix Timestamp For Sale Start
     * @param TimestampFullSetEnd The Unix Timestamp When Full Set Window Ends
     * @param TimestampCitizenEnd The Unix Timestamp When Citizen Window Ends (Public Begins)
     */
    function __ChangePresaleTimes (
        uint SaleIndex,
        uint TimestampSaleStart,
        uint TimestampFullSetEnd,
        uint TimestampCitizenEnd
    ) external onlyAdmin {
        PresaleSales[SaleIndex]._TimestampSaleStart = TimestampSaleStart;
        PresaleSales[SaleIndex]._TimestampEndFullSet = TimestampFullSetEnd;
        PresaleSales[SaleIndex]._TimestampEndCitizen = TimestampCitizenEnd;
    }

    /**
     * @dev Changes All Presale Roots
     * @param SaleIndex The Sale Index To Edit
     * @param RootEligibilityFullSet The Merkle Eligibility Root For Full Set
     * @param RootAmountsFullSet The Merkle Amounts Root For Full Set
     * @param RootEligibilityCitizen The Merkle Eligibility Root For Citizens
     * @param RootAmountsCitizen The Merkle Amounts Root For Citizens
     */
    function __ChangePresaleRootsAll (
        uint SaleIndex,
        bytes32 RootEligibilityFullSet,
        bytes32 RootAmountsFullSet,
        bytes32 RootEligibilityCitizen,
        bytes32 RootAmountsCitizen
    ) external onlyAdmin { 
        InternalRoots[SaleIndex]._RootEligibilityFullSet = RootEligibilityFullSet;
        InternalRoots[SaleIndex]._RootEligibilityCitizen = RootEligibilityCitizen;
        InternalRoots[SaleIndex]._RootAmountFullSet = RootAmountsFullSet;
        InternalRoots[SaleIndex]._RootAmountCitizen = RootAmountsCitizen;
    }

    /**
     * @dev Changes The Presale Roots For Merkle Eligibility
     * @param SaleIndex The Sale Index To Edit
     * @param RootCitizen The Merkle Eligibility Root For Citizens
     * @param RootFullSet The Merkle Eligibility Root For Full Set Holders
     */
    function __ChangePresaleRootsEligibility (
        uint SaleIndex, 
        bytes32 RootCitizen,
        bytes32 RootFullSet
    ) external onlyAdmin {
        InternalRoots[SaleIndex]._RootEligibilityCitizen = RootCitizen;
        InternalRoots[SaleIndex]._RootEligibilityFullSet = RootFullSet;
    }

    /**
     * @dev Changes The Presale Roots For Merkle Amounts
     * @param SaleIndex The Sale Index To Edit
     * @param RootCitizen The Merkle Amount Root For Citizens
     * @param RootFullSet The Merkle Amount Root For Full Set Holders
     */
    function __ChangePresaleRootsAmounts (
        uint SaleIndex,
        bytes32 RootCitizen,
        bytes32 RootFullSet
    ) external onlyAdmin {
        InternalRoots[SaleIndex]._RootAmountCitizen = RootCitizen;
        InternalRoots[SaleIndex]._RootAmountFullSet = RootFullSet;
    }

    /**
     * @dev Changes Presale Sale Max For Sale
     * @param SaleIndex The Sale Index To Edit
     * @param MaxForSale The Total Amount For Sale
     */
    function __ChangePresaleSaleMaxForSale(uint SaleIndex, uint MaxForSale) external onlyAdmin 
    {   
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._MaxForSale = MaxForSale; 
    }

    /**
     * @dev Change Presale Sale Max Per Purchase
     * @param SaleIndex The Sale Index To Edit
     * @param MaxPerPurchase The Maximum Purchase Amount Per Transaction
     */
    function __ChangePresaleSaleMaxPerPurchase(uint SaleIndex, uint MaxPerPurchase) external onlyAdmin 
    {   
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._MaxPerPurchase = MaxPerPurchase; 
    }

    /**
     * @dev Changes Presale Sale Mint Pass Price
     * @param SaleIndex The Sale Index To Edit
     * @param Price The Sale Presale Price Input In WEI
     */
    function __ChangePresaleSalePresalePrice(uint SaleIndex, uint Price) external onlyAdmin 
    {   
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._PricePresale = Price; 
    }

    /**
     * @dev Changes Presale Sale Public Price
     * @param SaleIndex The Sale Index To Edit
     * @param Price The Sale Public Price Input In WEI
     */
    function __ChangePresaleSalePublicPrice(uint SaleIndex, uint Price) external onlyAdmin 
    {   
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._PricePublic = Price; 
    }

    /**
     * @dev Changes Timestamp End Full Set
     * @param SaleIndex The Sale Index To Edit
     * @param Timestamp The Unix Timestamp Of The End Of Full Set Window (1st Priority)
     */
    function __ChangePresaleSaleEndFullSet(uint SaleIndex, uint Timestamp) external onlyAdmin 
    {   
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._TimestampEndFullSet = Timestamp; 
    }

    /**
     * @dev Changes Timestamp End Citizen
     * @param SaleIndex The Sale Index To Edit
     * @param Timestamp The Unix Timestamp Of The End Of Citizen Window (2nd Priority)
     */
    function __ChangePresaleSaleEndCitizen(uint SaleIndex, uint Timestamp) external onlyAdmin
    {
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._TimestampEndCitizen = Timestamp; 
    }

    /**
     * @dev Changes Timestamp Sale Start
     * @param SaleIndex The Sale Index To Edit
     * @param Timestamp The Unix Timestamp For Sale Start
     */
    function __ChangePresaleSaleStart(uint SaleIndex, uint Timestamp) external onlyAdmin
    {
        require(PresaleSalesInternal[SaleIndex]._Active, "Marketplace: Sale Not Active");
        PresaleSales[SaleIndex]._TimestampSaleStart = Timestamp; 
    }

    /**
     * @dev Changes Presale Sale Full Set Root
     * @param SaleIndex The Sale Index To Edit
     * @param RootFullSet The Full Set Priority Root
     */
    function __ChangePresaleSaleRootFullSet(uint SaleIndex, bytes32 RootFullSet) external onlyAdmin 
    { 
        InternalRoots[SaleIndex]._RootEligibilityFullSet = RootFullSet; 
    }

    /**
     * @dev Changes Presale Sale Citizen Root
     * @param SaleIndex The Sale Index To Edit
     * @param RootCitizen The Citizen Priority Root
     */
    function __ChangePresaleSaleRootCitizen(uint SaleIndex, bytes32 RootCitizen) external onlyAdmin
    {
        InternalRoots[SaleIndex]._RootAmountCitizen = RootCitizen; 
    }

    /**
     * @dev Initializes A Sale Via A Struct
     * @param _Sale The Sale Struct
     * @param Discounts The Array Of Discount Amounts ([80,90] = [20%,10%]) Discounts
     */
    function __StartFixedPriceSale (
        SaleTypeFixedPrice memory _Sale, 
        uint[] calldata Discounts
    ) external onlyAdmin returns (uint SaleIndex) { 
        for(uint x; x < Discounts.length; x++) { require(Discounts[x] <= 100, "Marketplace: Invalid Discount Amouns"); }
        SaleIndex = _TOTAL_UNIQUE_FIXED_SALES;
        FixedPriceSales[SaleIndex] = _Sale; 
        DiscountAmounts[SaleIndex] = Discounts;
        _TOTAL_UNIQUE_FIXED_SALES += 1;
        return SaleIndex;
    }

    /**
     * @dev Changes The Price Of A Fixed Price Sale
     * @param SaleIndex The Sale Index To Edit
     * @param Price The Sale Price (IN WEI)
     */
    function __ChangeFixedPrice(uint SaleIndex, uint Price) external onlyAdmin { FixedPriceSales[SaleIndex]._Price = Price; }

    /**
     * @dev Changes The MintPass ProjectID
     * @param SaleIndex The Sale Index To Edit
     * @param MintPassProjectID The Mint Pass ProjectID
     */
    function __ChangeFixedPriceMintPassProjectID(uint SaleIndex, uint MintPassProjectID) external onlyAdmin 
    { 
        FixedPriceSales[SaleIndex]._MintPassProjectID = MintPassProjectID; 
    }

    /**
     * @dev Changes The Type Of A Sale
     * @param SaleIndex The Sale Index To Edit
     * @param Type The Sale Type (0 = _MintToFactory() | 1 = purchaseTo() | 2 = transferFrom())
     */
    function __ChangeFixedPriceType(uint SaleIndex, uint Type) external onlyAdmin { FixedPriceSales[SaleIndex]._Type = Type; }

    /**
     * @dev Changes The ArtBlocks ProjectID
     * @param SaleIndex The Sale Index To Edit
     * @param ABProjectID ArtBlocks ProjectID
     */
    function __ChangeFixedPriceABProjectID(uint SaleIndex, uint ABProjectID) external onlyAdmin { FixedPriceSales[SaleIndex]._ABProjectID = ABProjectID; }

    /**
     * @dev Changes The Amount Of NFTs For Sale
     * @param SaleIndex The Sale Index To Edit
     * @param AmountForSale The Total Amount For Sale
     */
    function __ChangeFixedPriceAmountForSale(uint SaleIndex, uint AmountForSale) external onlyAdmin { FixedPriceSales[SaleIndex]._AmountForSale = AmountForSale; }

    /**
     * @dev Changes A Fixed Price Sale's Unix Start Time
     * @param SaleIndex The Sale Index To Edit
     * @param UnixTimestamp The Unix Timestamp To Store
     */
    function __ChangeFixedPriceStartTimestamp(uint SaleIndex, uint UnixTimestamp) external onlyAdmin { FixedPriceSales[SaleIndex]._TimestampStart = UnixTimestamp; }
   
   /**
     * @dev Changes A Fixed Price Sale's Unix Start Time
     * @param SaleIndex The Sale Index To Edit
     * @param CurrentIndex The Current TokenID To Disperse
     */
    function __ChangeFixedPriceCurrentIndex(uint SaleIndex, uint CurrentIndex) external onlyAdmin { FixedPriceSales[SaleIndex]._CurrentIndex = CurrentIndex; }

    /**
     * @dev Changes The NFT Address Of A Fixed Price Sale
     * @param SaleIndex The Sale Index To Edit
     * @param NewAddress The NFT Contract Address To Store
     */
    function __ChangeFixedPriceNFTAddress(uint SaleIndex, address NewAddress) external onlyAdmin { FixedPriceSales[SaleIndex]._NFT = NewAddress; }

    /**
     * @dev Changes The NFT Address Of A Fixed Price Sale
     * @param SaleIndex The Sale Index To Edit
     * @param Operator The Operator Holding The NFTs To Disperse
     */
    function __ChangeFixedPriceOperator(uint SaleIndex, address Operator) external onlyAdmin { FixedPriceSales[SaleIndex]._Operator = Operator; }

    /**
     * @dev Changes The Fixed Price Merkle Root For Merkle Eligibility
     * @param SaleIndex The Sale Index To Edit
     * @param NewRoots The Merkle Roots To Store
     */
    function __ChangeFixedPriceRootEligibility(uint SaleIndex, bytes32[] calldata NewRoots) external onlyAdmin { FixedPriceSales[SaleIndex]._RootEligibilities = NewRoots; }

    /**
     * @dev Changes The Fixed Price Merkle Root For Merkle Eligibility
     * @param SaleIndex The Sale Index To Edit
     * @param NewRoots The Merkle Root To Store
     */
    function __ChangeFixedPriceRootAmounts(uint SaleIndex, bytes32[] calldata NewRoots) external onlyAdmin { FixedPriceSales[SaleIndex]._RootAmounts = NewRoots; }

    /**
     * @dev Changes The Fixed Price Sale Roots
     * @param SaleIndex The Sale Index To Edit
     * @param RootEligibilities The Merkle Root For Merkle Eligibility
     * @param RootAmounts The Merkle Root For Amounts
     */
    function __ChangeFixedPriceSaleRoots(uint SaleIndex, bytes32[] calldata RootEligibilities, bytes32[] calldata RootAmounts) external onlyAdmin
    {
        FixedPriceSales[SaleIndex]._RootEligibilities = RootEligibilities;
        FixedPriceSales[SaleIndex]._RootAmounts = RootAmounts;
    }

    /**
     * @dev Changes Presale Sale Discount Amounts (IN BIPS)
     * @param SaleIndex The Sale Index To Edit
     * @param Discounts The Array Of Discount Amounts ([80,90] = 20%, 10% Discount)
     */
    function __ChangeFixedPriceDiscountAmounts(uint SaleIndex, uint[] calldata Discounts) external onlyAdmin
    {
        for(uint x; x < Discounts.length; x++) { require(Discounts[x] <= 100, "Marketplace: Invalid Discount Amounts");}
        DiscountAmounts[SaleIndex] = Discounts;
    }

    /**
     * @dev Withdraws ETH In Contract To Multisig
     */
    function __WithdrawETHToMultisig() external onlyAdmin 
    {
        (bool success,) = _BRT_MULTISIG.call { value: address(this).balance }(""); 
        require(success, "Marketplace: ETH Withdraw Failed"); 
    }

    /*--------------*/
    /*  ONLY OWNER  */
    /*--------------*/

    /**
     * @dev onlyOwner: Grants Admin Role
     */
    function ___AdminGrant(address _Admin) external onlyOwner { Admin[_Admin] = true; }

    /**
     * @dev onlyOwner: Removes Admin Role
     */
    function ___AdminRemove(address _Admin) external onlyOwner { Admin[_Admin] = false; }

    /**
     * @dev onlyOwner: Withdraws All Ether From The Contract
     */
    function ___WithdrawEther() external onlyOwner { payable(msg.sender).transfer(address(this).balance); }

    /**
     * @dev onlyOwner: Withdraws Ether From Contract To Address With A Specified Amount
     */
    function ___WithdrawEtherToAddress(address payable Recipient, uint Amount) external onlyOwner
    {
        require(Amount > 0 && Amount <= address(this).balance, "Invalid Amount");
        (bool Success, ) = Recipient.call{value: Amount}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }

    /**
     * @dev Withdraws ERC721s From Contract
     */
    function ___WithdrawERC721(address Contract, address Recipient, uint[] calldata TokenIDs) external onlyOwner 
    { 
        for(uint TokenID; TokenID < TokenIDs.length;)
        {
            IERC721(Contract).transferFrom(address(this), Recipient, TokenIDs[TokenID]);
            unchecked { TokenID++; }
        }
    }

    /*-----------------
     * VIEW FUNCTIONS *
    ------------------*/

    /**
     * @dev Verifies BrightList For Presale
     */
    function VerifyBrightList(address _Wallet, bytes32 _RootEligibilities, bytes32[] calldata _Proof) public pure returns(bool)
    {
        bytes32 _Leaf = keccak256(abi.encodePacked(_Wallet));
        return MerkleProof.verify(_Proof, _RootEligibilities, _Leaf);
    }

    /**
     * @dev Verifies BrightList For Presale Fixed Price Sale
     */
    function VerifyBrightListWithPriority (
        uint SaleIndex, 
        address _Wallet, 
        bytes32[] calldata _ProofEligibility
    ) public view returns (bool, uint) {
        bytes32 _Leaf = keccak256(abi.encodePacked(_Wallet));
        for(uint x; x < DiscountAmounts[SaleIndex].length; x++) 
        { 
            if(MerkleProof.verify(_ProofEligibility, FixedPriceSales[SaleIndex]._RootEligibilities[x], _Leaf)) { return (true, x); } 
        }
        return (false, 69420);
    }

    /**
     * @dev Verifies Merkle Amount Is Passed Correctly
     */
    function VerifyBrightListAmount (
        address _Wallet,
        uint _Amount,
        bytes32 _RootAmounts,
        bytes32[] calldata _ProofAmount
    ) public pure returns (bool) {
        bytes32 _Leaf = (keccak256(abi.encodePacked(_Wallet, _Amount)));
        return MerkleProof.verify(_ProofAmount, _RootAmounts, _Leaf);
    }

    /**
     * @dev Verifies Maximum Purchase Amount Being Passed Is Valid
     */
    function VerifyAmount(address _Wallet, uint _Amount, bytes32 _RootEligibilities, bytes32[] calldata _Proof) public pure returns(bool)
    {
        bytes32 _Leaf = (keccak256(abi.encodePacked(_Wallet, _Amount)));
        return MerkleProof.verify(_Proof, _RootEligibilities, _Leaf);
    }

    /**
     * @dev Refunds `Recipient` ETH Amount `Value`
     */
    function __Refund(address Recipient, uint Value) internal
    {
        (bool Confirmed,) = Recipient.call{value: Value}(""); 
        require(Confirmed, "Marketplace: Refund failed");
        emit Refunded(Recipient, Value);
    }

    /**
     * @dev Returns The Sale Info For A Fixed Price Sale
     */
    function ViewSaleInfoFixedPrice (
        uint SaleIndex,
        address Wallet,
        uint MaxAmount,
        bytes32[] calldata ProofEligibility,
        bytes32[] calldata ProofAmount
    ) public view returns (FixedPriceSaleInfo memory) {
        uint Price = FixedPriceSales[SaleIndex]._Price;
        uint AmountForSale = FixedPriceSales[SaleIndex]._AmountForSale;
        uint AmountRemaining = AmountForSale - AmountSoldFixedPrice[SaleIndex];
        uint TimestampStart = FixedPriceSales[SaleIndex]._TimestampStart;
        uint ETHRevenue = ETHRevenueFixedPriceSale[SaleIndex];
        uint AmountPurchasedUser = UserPurchasedAmount[SaleIndex][Wallet];
        uint AmountRemainingMerklePriority;
        uint PurchasedAmountMerklePriority;
        bool BrightListMerkleAmount;
        uint[] memory DiscountAmountWEIValues = new uint[](FixedPriceSales[SaleIndex]._RootEligibilities.length);
        for(uint x; x < FixedPriceSales[SaleIndex]._RootEligibilities.length; x++)
        {
            DiscountAmountWEIValues[x] = (Price * DiscountAmounts[SaleIndex][x]) / 100;
        }
        (bool BrightListEligible, uint Priority) = VerifyBrightListWithPriority(
            SaleIndex, 
            Wallet, 
            ProofEligibility
        );
        if(BrightListEligible)
        {
            BrightListMerkleAmount = VerifyBrightListAmount(Wallet, MaxAmount, FixedPriceSales[SaleIndex]._RootAmounts[Priority], ProofAmount);
            PurchasedAmountMerklePriority = PriorityPurchaseAmount[SaleIndex][Wallet][Priority];
            if(MaxAmount > PurchasedAmountMerklePriority)
            {
                AmountRemainingMerklePriority = MaxAmount - PurchasedAmountMerklePriority;
            }
        }
        return FixedPriceSaleInfo(
            ETHRevenue, 
            Price, 
            AmountForSale, 
            AmountRemaining, 
            TimestampStart, 
            Priority, 
            AmountRemainingMerklePriority,
            AmountPurchasedUser,
            BrightListEligible, 
            BrightListMerkleAmount,
            DiscountAmountWEIValues
        );
    }
    
    /**
     * @dev Returns A Wallet's Sale Information For A Presale Sale
     */
    function ViewSaleInfoPresale (
        uint SaleIndex,
        address Wallet,
        uint MaxAmountFullSet,
        uint MaxAmountCitizen,
        bytes32[] calldata FullsetProof, 
        bytes32[] calldata CitizenProof,
        bytes32[] calldata ProofAmountFullSet,
        bytes32[] calldata ProofAmountCitizen
    ) public view returns (SaleInfoPresale memory) {
        uint AmountPurchaseableFullset;
        uint AmountPurchaseableCitizen;
        SaleTypePresale memory _Sale = PresaleSales[SaleIndex];
        InternalPresaleSale memory _SaleInternal = PresaleSalesInternal[SaleIndex];
        InternalPresaleWalletInfo memory _WalletInfo = InternalSaleWalletInfo[SaleIndex][Wallet];
        uint AmountRemaining = _Sale._MaxForSale - _SaleInternal._AmountSold;
        uint ETHRevenue = _SaleInternal._ETHRevenue;
        if(_WalletInfo._AmountPurchasedFullSetWindow >= MaxAmountFullSet) { AmountPurchaseableFullset = 0; }
        else { AmountPurchaseableFullset = MaxAmountFullSet - _WalletInfo._AmountPurchasedFullSetWindow; }
        if(_WalletInfo._AmountPurchasedCitizenWindow >= MaxAmountCitizen) { AmountPurchaseableCitizen = 0; }
        else { AmountPurchaseableCitizen = MaxAmountCitizen - _WalletInfo._AmountPurchasedCitizenWindow; }
        return SaleInfoPresale (
            ETHRevenue, // ETHRevenue
            _Sale._PricePresale, // _PricePresale
            _Sale._PricePublic, // _PricePublic
            _Sale._MaxForSale, // _MintPassesAvailable
            AmountRemaining, // _AmountRemaining
            _Sale._TimestampEndFullSet, // _TimestampEndFullSet
            _Sale._TimestampEndCitizen, // _TimestampEndCitizen
            _Sale._TimestampSaleStart, // _TimestampSaleStart
            AmountPurchaseableFullset, // _AmountPurchasableFullSet
            AmountPurchaseableCitizen, // _AmountPurchasableCitizen
            _WalletInfo._AmountPurchasedFullSetWindow, // _AmountPurchasedFullSetWindow
            _WalletInfo._AmountPurchasedCitizenWindow, // _AmountPurchasedCitizenWindow
            _SaleInternal._GlobalPurchasesFullSet, // _GlobalPurchasesFullSet
            _SaleInternal._GlobalPurchasesCitizen, // _GlobalPurchasesCitizen
            _SaleInternal._GlobalPurchasesPublic, // _GlobalPurchasesPublic
            _WalletInfo._AmountPurchasedWallet, // _AmountPurchasedWallet
            VerifyBrightList(Wallet, InternalRoots[SaleIndex]._RootEligibilityFullSet, FullsetProof), // _EligibleFullSet
            VerifyBrightList(Wallet, InternalRoots[SaleIndex]._RootEligibilityCitizen, CitizenProof), // _EligibleCitizen
            VerifyAmount(Wallet, MaxAmountFullSet, InternalRoots[SaleIndex]._RootAmountFullSet, ProofAmountFullSet), // _ValidMaxAmountFullSet
            VerifyAmount(Wallet, MaxAmountCitizen, InternalRoots[SaleIndex]._RootAmountCitizen, ProofAmountCitizen) // _ValidMaxAmountCitizen
        );
    }

    /*-----------
     * MODIFIER *
    ------------*/

    modifier onlyAdmin
    {
        require(Admin[msg.sender]);
        _;
    }
}

interface IERC20 { function approve(address From, address To, uint Amount) external; }
interface IERC721 { function transferFrom(address From, address To, uint TokenID) external; }