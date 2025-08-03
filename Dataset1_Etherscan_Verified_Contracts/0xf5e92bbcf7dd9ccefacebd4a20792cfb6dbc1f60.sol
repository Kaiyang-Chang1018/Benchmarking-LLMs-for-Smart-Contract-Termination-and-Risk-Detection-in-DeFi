// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
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
// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)

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
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
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
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

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
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
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
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

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
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
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
/**
 * @title DelegateCashEnabled
 * @author @brougkr
 * @notice For Easily Integrating `delegate.cash`
 */
pragma solidity ^0.8.19;
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
    // function purchaseTo(address _to) external returns (uint tokenID); // Custom
    // function purchaseTo(address _to, uint _projectId, address _ownedNFTAddress, uint _ownedNFTTokenID) payable external returns (uint tokenID); // ArtBlocks PolyMinter
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
    struct SaleTypeFixedPrice
    {
        string _Name;                 // [0] -> _Name
        uint _Price;                  // [1] -> _Price
        uint _MintPassProjectID;      // [2] -> _MintPassProjectID
        uint _Type;                   // [3] -> _Type (The Type Of Sale) (Must Be Configured To One Of The Following Options)
                                      // { ----------------------------------------------- }
                                      // |  0 = _MintToFactory() Single Mint               |
                                      // |  1 = _MintToFactory() Mint Pack                 |
                                      // |  2 = _LiveMintMarketplace() Single Mint         |
                                      // |  3 = _LiveMintMarketplace() Mint Pack           |
                                      // |  4 = purchaseTo() ArtBlocks Direct Sale         |
                                      // |  5 = transferFrom() Already-Minted ERC721 Sale  |
                                      // |  6 = purchaseTo() ArtBlocks Direct Sale /w ETH  |
                                      // { ----------------------------------------------- }
        uint _MinterProjectID;        // [4] -> _MinterProjectID (ArtBlocks or LiveMint)
        uint _AmountForSale;          // [5] -> _AmountForSale
        uint _TimestampStart;         // [6] -> _TimestampStart
        uint _CurrentIndex;           // [7] -> _CurrentIndex
        uint _BatchPurchaseAmount;    // [8] -> _BatchPurchaseAmount (Transfer Amount Per Purchase) (MintPack or Direct Mint)
        address _NFT;                 // [9] -> _NFT
        address _Operator;            // [10] -> _Operator
        bytes32[] _RootEligibilities; // [11] -> _RootEligibilities
        bytes32[] _RootAmounts;       // [12] -> _RootAmounts
        uint[] _LiveMintProjectIDs;   // [13] -> _LiveMintProjectIDs
    }

    struct FixedPriceSaleInfo
    {
        string _Name;                        // [0] -> _Price
        uint _Price;                         // [1] -> _Price
        uint _MintPassProjectID;             // [2] -> _MintPassProjectID
        uint _Type;                          // [3] -> _Type (The Type Of Sale) (Must Be Configured To One Of These Options)
                                             // { ----------------------------------------------- }
                                             // |  0 = _MintToFactory() Single Mint               |
                                             // |  1 = _MintToFactory() Mint Pack                 |
                                             // |  2 = _LiveMintMarketplace() Single Mint         |
                                             // |  3 = _LiveMintMarketplace() Mint Pack           |
                                             // |  4 = purchaseTo() ArtBlocks Direct Sale         |
                                             // |  5 = transferFrom() Already-Minted ERC721 Sale  |
                                             // |  6 = purchaseTo() ArtBlocks Direct Sale /w ETH  |
                                             // { ----------------------------------------------- }
        uint _MinterProjectID;               // [4] -> _MinterProjectID (ArtBlocks or LiveMint)
        uint _AmountForSale;                 // [5] -> _AmountForSale
        uint _TimestampStart;                // [6] -> _TimestampStart
        uint _CurrentIndex;                  // [7] -> _CurrentIndex
        uint _BatchPurchaseAmount;           // [8] -> _BatchPurchaseAmount (Transfer Amount Per Purchase)
        address _NFT;                        // [9] -> _NFT
        address _Operator;                   // [10] -> _Operator
        bytes32[] _RootEligibilities;        // [11] -> _RootEligibilities
        bytes32[] _RootAmounts;              // [12] -> _RootAmounts
        uint[] _LiveMintProjectIDs;          // [13] -> _LiveMintProjectIDs
        uint[] _DiscountAmountWEIValues;     // [14] -> _DiscountAmountWEIValues
        uint _ETHRevenue;                    // [15] -> _ETHRevenue
        uint _AmountRemaining;               // [16] -> _AmountRemaining
        uint _Priority;                      // [17] -> _Priority
        uint _AmountRemainingMerklePriority; // [18] -> _AmountRemainingMerklePriority
        uint _AmountPurchasedUser;           // [19] -> _AmountPurchasedUser
        bool _BrightListEligible;            // [20] -> _BrightListEligible
        bool _BrightListAmounts;             // [21] -> _BrightListAmounts
    }
    
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

    /*------------------
     * STATE VARIABLES *
    -------------------*/

    uint public _TOTAL_UNIQUE_PRESALE_SALES; // Total Unique Presale Sales                
    uint public _TOTAL_UNIQUE_FIXED_SALES; // Total Unique Fixed Price Sales
    address private constant _BRT_MULTISIG = 0x0BC56e3c1397e4570069e89C07936A5c6020e3BE; // `sales.brightmoments.eth`a
    
    /*-----------
     * MAPPINGS *
    ------------*/

    mapping(uint=>SaleTypeFixedPrice) public FixedPriceSales;                                 // [SaleIndex] -> SaleTypeFixedPrice
    mapping(uint=>SaleTypePresale) public PresaleSales;                                       // [SaleIndex] -> SaleTypePresale
    mapping(uint=>InternalPresaleSale) public PresaleSalesInternal;                           // [SaleIndex] -> InternalPresaleSale
    mapping(uint=>uint) public AmountSoldFixedPrice;                                          // [SaleIndex] -> Amount Sold
    mapping(uint=>uint[]) public DiscountAmounts;                                             // [SaleIndex] -> Discount Amounts
    mapping(uint=>InternalPresaleSaleRoots) public InternalRoots;                             // [SaleIndex] -> InternalPresaleSaleRoots
    mapping(uint=>mapping(address=>InternalPresaleWalletInfo)) public InternalSaleWalletInfo; // [SaleIndex][Wallet] -> InternalPresaleWalletInfo
    mapping(uint=>uint) public ETHRevenueFixedPriceSale;                                      // [SaleIndex] -> ETH Amount
    mapping(uint=>uint) public ETHRevenueWithdrawn;                                           // [SaleIndex] -> ETH Amount Withdrawn
    mapping(uint=>mapping(address=>mapping(uint=>uint))) public PriorityPurchaseAmount;       // [SaleIndex][Wallet][Priority] => Purchased Amount For Priority Level
    mapping(address=>bool) public Admin;                                                      // [Address] -> Admin Status
    mapping(uint=>mapping(address=>uint)) public UserPurchasedAmount;                         // [SaleIndex][Wallet] -> Purchased Amount

    /*---------
     * EVENTS *
    ----------*/

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
     * @dev Purchases One Fixed Price Sale
     * @param SaleIndex The Sale Index To Purchase
     * @param DesiredAmount The Desired Amount To Purchase
     * @param MaxAmount The Maximum Merkle Priority To Purchase
     * @param Vault Delegate Vault Address
     * @param ProofEligibility Merkle Proof For Eligibility
     * @param ProofAmount Merkle Proof For MaxAmount
     */
    function PurchaseFixedPrice (
        uint SaleIndex,
        uint DesiredAmount,
        uint MaxAmount,
        address Vault,
        bytes32[] calldata ProofEligibility,
        bytes32[] calldata ProofAmount
    ) external payable nonReentrant {
        __FinalizeFixedPriceSale(
            SaleIndex, 
            DesiredAmount, 
            MaxAmount, 
            Vault, 
            ProofEligibility, 
            ProofAmount, 
            msg.value,
            msg.sender
        );
    }

    /**
     * @dev Purchases Multiple Fixed Price Sales
     * @param SaleIndexes The Sale Indexes To Purchase
     * @param DesiredAmounts The Desired Amounts To Purchase
     * @param MaxAmounts The Maximum Merkle Priority To Purchase
     * @param Vaults Delegate Vault Addresses
     * @param ProofEligibilities Merkle Proofs For Eligibility
     * @param ProofAmounts Merkle Proofs For MaxAmount
     * @param MessageValues The Amounts To Purchase Per Sale
     */
    function PurchaseFixedPriceMulti (
        uint[] calldata SaleIndexes,
        uint[] calldata DesiredAmounts,
        uint[] calldata MaxAmounts,
        address[] calldata Vaults,
        bytes32[][] calldata ProofEligibilities,
        bytes32[][] calldata ProofAmounts,
        uint[] calldata MessageValues
    ) external payable nonReentrant {
        uint MessageValueSum;
        require(
            SaleIndexes.length == DesiredAmounts.length 
            &&
            DesiredAmounts.length == MaxAmounts.length
            &&
            MaxAmounts.length == Vaults.length
            &&
            Vaults.length == ProofEligibilities.length
            &&
            ProofEligibilities.length == ProofAmounts.length
            && 
            ProofAmounts.length == MessageValues.length,
            "Marketplace: Incorrect Array Lengths"
        );
        for(uint x; x < SaleIndexes.length; x++)
        {
            __FinalizeFixedPriceSale(
                SaleIndexes[x], 
                DesiredAmounts[x], 
                MaxAmounts[x], 
                Vaults[x], 
                ProofEligibilities[x], 
                ProofAmounts[x],
                MessageValues[x],
                msg.sender
            );
            MessageValueSum += MessageValues[x];
        }
        require(MessageValueSum == msg.value, "Marketplace: `msg.value` & `MessageValues` Input Incorrect");
    }

    /**
     * @dev Presale Purchase
     * @param SaleIndex The Sale Index To Purchase
     * @param DesiredAmount The Desired Amount To Purchase
     * @param MaxAmount The Maximum Amount For Merkle Priority Purchase
     * @param Vault Delegate Vault Address
     * @param ProofEligibility Merkle Proof For Eligibility
     * @param ProofAmount Merkle Proof For MaxAmount
     */
    function PurchasePresale (
        uint SaleIndex,                      
        uint DesiredAmount,                  
        uint MaxAmount,                      
        address Vault,                       
        bytes32[] calldata ProofEligibility, 
        bytes32[] calldata ProofAmount 
    ) external payable nonReentrant {
        __FinalizePresale(
            SaleIndex, 
            DesiredAmount, 
            MaxAmount, 
            Vault, 
            ProofEligibility, 
            ProofAmount,
            msg.value,
            msg.sender
        );
    }

    /*------------------
     * ADMIN FUNCTIONS *
    -------------------*/

    /**
     * @dev Instantiates A New Presale Sale
     * @param _Sale The Presale Sale Struct
     * @param _Roots The Presale Sale Roots Struct
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
    ) external onlyAdmin returns (uint SaleIndex) { return __FixedPriceSaleInit(_Sale, Discounts); }

    /**
     * @dev Starts Multiple Fixed Price Sales
     * @param _Sales The Sale Struct
     * @param Discounts The Array Of Discount Amounts ([80,90] = [20%,10%]) Discounts
     */
    function __StartFixedPriceSales (
        SaleTypeFixedPrice[] memory _Sales,
        uint[][] calldata Discounts
    ) external onlyAdmin returns (uint[] memory SaleIndexes) {
        SaleIndexes = new uint[](_Sales.length);
        for(uint x; x < _Sales.length; x++) { SaleIndexes[x] = __FixedPriceSaleInit(_Sales[x], Discounts[x]); }
        return SaleIndexes;
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
    function __ChangeFixedPriceABProjectID(uint SaleIndex, uint ABProjectID) external onlyAdmin { FixedPriceSales[SaleIndex]._MinterProjectID = ABProjectID; }

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
     * @dev Changes Fixed Price Sale Discount Amounts (IN BIPS)
     * @param SaleIndex The Sale Index To Edit
     * @param Discounts The Array Of Discount Amounts ([80,90] = 20%, 10% Discount) To Seed
     */
    function __ChangeFixedPriceDiscountAmounts(uint SaleIndex, uint[] calldata Discounts) external onlyAdmin
    {
        for(uint x; x < Discounts.length; x++) { require(Discounts[x] <= 100, "Marketplace: Invalid Discount Amounts");}
        DiscountAmounts[SaleIndex] = Discounts;
    }

    /**
     * @dev Changes The Fixed Price LiveMint ProjectIDs
     * @param SaleIndex The Sale Index To Edit
     * @param LiveMintProjectIDs The LiveMint ProjectIDs To Seed
     */
    function __ChangeFixedPriceLiveMintProjecIDs(uint SaleIndex, uint[] calldata LiveMintProjectIDs) external onlyAdmin
    {
        FixedPriceSales[SaleIndex]._LiveMintProjectIDs = LiveMintProjectIDs;
    }

    /**
     * @dev Changes The Fixed Price Sale Mint Pack Amount
     * @param SaleIndex The Sale Index To Edit
     * @param MintPackAmount The Mint Pack Amount To Seed
     */
    function __ChangeFixedPriceMintPackAmount(uint SaleIndex, uint MintPackAmount) external onlyAdmin
    {
        FixedPriceSales[SaleIndex]._BatchPurchaseAmount = MintPackAmount;
    }

    /**
     * @dev Sweeps Proceeds From A Sale Index To Multisig
     * @param SaleIndex The Sale Index To Withdraw From
     */
    function __WithdrawETHFromSaleIndex(uint SaleIndex) external onlyAdmin
    {
        require(ETHRevenueFixedPriceSale[SaleIndex] - ETHRevenueWithdrawn[SaleIndex] > 0, "Marketplace: No ETH To Withdraw");
        uint WithdrawAmount = ETHRevenueFixedPriceSale[SaleIndex] - ETHRevenueWithdrawn[SaleIndex];
        ETHRevenueWithdrawn[SaleIndex] += WithdrawAmount;
        (bool success,) = _BRT_MULTISIG.call { value: WithdrawAmount }(""); 
        require(success, "Marketplace: ETH Withdraw Failed"); 
    }

    /*--------------*/
    /*  ONLY OWNER  */
    /*--------------*/

    /**
     * @dev onlyOwner: Grants Admin Role
     * @param Wallet The Admin To Add
     */
    function ____AddressAuthorize(address Wallet) external onlyOwner { Admin[Wallet] = true; }

    /**
     * @dev onlyOwner: Removes Admin Role
     * @param Wallet The Admin To Remove
     */
    function ____DeuthorizeAddress(address Wallet) external onlyOwner { Admin[Wallet] = false; }

    /**
     * @dev onlyOwner: Withdraws Ether From Contract To Address With A Specified Amount
     * @param Recipient The Recipient Of The Ether
     * @param Amount The Amount Of Ether To Withdraw
     */
    function ____WithdrawEtherToAddress(address payable Recipient, uint Amount) external onlyOwner
    {
        require(Amount > 0 && Amount <= address(this).balance, "Invalid Amount");
        (bool Success, ) = Recipient.call{value: Amount}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }

    /**
     * @dev Withdraws ETH In Contract To Multisig
     */
    function __WithdrawAllETHToMultisig() external onlyOwner 
    {
        (bool success,) = _BRT_MULTISIG.call { value: address(this).balance }(""); 
        require(success, "Marketplace: ETH Withdraw Failed"); 
    }

    /*-----------------
     * VIEW FUNCTIONS *
    ------------------*/

    /**
     * @dev Returns The Fixed Price Merkle Roots
     */
    function ViewFixedPriceRoots(uint SaleIndex) external view returns (bytes32[] memory, bytes32[] memory)
    {
        return (FixedPriceSales[SaleIndex]._RootEligibilities, FixedPriceSales[SaleIndex]._RootAmounts);
    }

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
     * @dev Returns Information Of A Fixed Price Sale
     */
    function ViewSaleInfoFixedPrice (
        uint SaleIndex,
        address Wallet,
        uint MaxAmount,
        bytes32[] calldata ProofEligibility,
        bytes32[] calldata ProofAmount
    ) public view returns (FixedPriceSaleInfo memory) {
        return __ViewSaleInfoFixedPrice(
            SaleIndex,
            Wallet,
            MaxAmount,
            ProofEligibility,
            ProofAmount
        );
    }

    /**
     * @dev Returns Information Of Multiple Fixed Price Sales
     */
    function ViewSaleInfosFixedPrice(
        uint[] calldata SaleIndexes,
        address[] calldata Wallets,
        uint[] calldata MaxAmounts,
        bytes32[][] calldata ProofEligibilities,
        bytes32[][] calldata ProofAmounts
    ) public view returns (FixedPriceSaleInfo[] memory _Sales)
    {
        _Sales = new FixedPriceSaleInfo[](SaleIndexes.length);
        for(uint x; x < SaleIndexes.length; x++)
        {
            _Sales[x] = __ViewSaleInfoFixedPrice(
                SaleIndexes[x],
                Wallets[x],
                MaxAmounts[x],
                ProofEligibilities[x],
                ProofAmounts[x]
            );
        }
        return _Sales;
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
     * INTERNAL *
    ------------*/  

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
     * @dev Initializes A Sale Via A Struct
     */
    function __FixedPriceSaleInit(SaleTypeFixedPrice memory _Sale, uint[] calldata Discounts) internal returns (uint SaleIndex) { 
        require(
            _Sale._RootEligibilities.length == _Sale._RootAmounts.length
            &&
            _Sale._RootAmounts.length == Discounts.length,
            "Marketplace: All Array Lengths Must Match"
        );
        for(uint x; x < Discounts.length; x++) { require(Discounts[x] <= 100 && Discounts[x] > 0, "Marketplace: Discount Amounts Must Be <= 100 & > 0"); }
        SaleIndex = _TOTAL_UNIQUE_FIXED_SALES;
        FixedPriceSales[SaleIndex] = _Sale; 
        DiscountAmounts[SaleIndex] = Discounts;
        _TOTAL_UNIQUE_FIXED_SALES += 1;
        return SaleIndex;
    }

    /**
     * @dev Finalizes A Fixed Price Sale
     */
    function __FinalizeFixedPriceSale(
        uint SaleIndex,
        uint DesiredAmount,
        uint MaxAmount,
        address Vault,
        bytes32[] calldata ProofEligibility,
        bytes32[] calldata ProofAmount,
        uint MessageValue,
        address Purchaser
    ) internal {
        require(tx.origin == Purchaser, "Marketplace: EOA Only");
        address MerkleRecipient = Purchaser;
        if(Vault != address(0)) { if(DelegateCash.checkDelegateForAll(Purchaser, Vault)) { MerkleRecipient = Vault; } }
        require(block.timestamp >= FixedPriceSales[SaleIndex]._TimestampStart, "Marketplace: Sale Not Started");
        (bool BrightList, uint Priority) = VerifyBrightListWithPriority(SaleIndex, MerkleRecipient, ProofEligibility);
        if(BrightList)  
        {
            require(
                VerifyBrightListAmount( 
                    MerkleRecipient, 
                    MaxAmount, 
                    FixedPriceSales[SaleIndex]._RootAmounts[Priority], 
                    ProofAmount
                ), 
                "DutchMarketplace: Invalid Max Amount Merkle Proof For Provided Merkle Priority"
            );
            require(
                MessageValue
                == 
                (((FixedPriceSales[SaleIndex]._Price * DesiredAmount) * DiscountAmounts[SaleIndex][Priority]) / 100), 
                "Marketplace: Incorrect BrightList ETH Sent"
            );
            require(
                DesiredAmount + PriorityPurchaseAmount[SaleIndex][MerkleRecipient][Priority] 
                <= 
                MaxAmount, 
                "Marketplace: Desired Purchase Amount Exceeds Purchase Allocation"
            );
            PriorityPurchaseAmount[SaleIndex][MerkleRecipient][Priority] += DesiredAmount;
        }
        else { require(MessageValue == FixedPriceSales[SaleIndex]._Price * DesiredAmount, "Marketplace: Incorrect ETH Amount Sent"); }
        require(AmountSoldFixedPrice[SaleIndex] + DesiredAmount <= FixedPriceSales[SaleIndex]._AmountForSale, "Marketplace: Not Enough NFTs Left For Sale");
        AmountSoldFixedPrice[SaleIndex] = AmountSoldFixedPrice[SaleIndex] + DesiredAmount;
        if(FixedPriceSales[SaleIndex]._Type == 0) // Factory MintPass Direct Mint
        { 
            IMinter(FixedPriceSales[SaleIndex]._NFT)._MintToFactory(
                Purchaser, 
                DesiredAmount
            ); 
        }
        else if (FixedPriceSales[SaleIndex]._Type == 1) // Factory MintPass MintPack Direct Mint
        {
            for(uint x; x < DesiredAmount; x++)
            {
                IMinter(FixedPriceSales[SaleIndex]._NFT)._MintToFactory(
                    Purchaser, 
                    FixedPriceSales[SaleIndex]._BatchPurchaseAmount
                ); 
            }
        }
        else if (FixedPriceSales[SaleIndex]._Type == 2) // LiveMint Direct Mint
        {
            ILiveMint(FixedPriceSales[SaleIndex]._NFT)._LiveMintMarketplace(
                Purchaser, 
                FixedPriceSales[SaleIndex]._MinterProjectID, 
                DesiredAmount
            );
        }
        else if (FixedPriceSales[SaleIndex]._Type == 3) // LiveMint Direct Mint Pack
        {
            for(uint x; x < FixedPriceSales[SaleIndex]._LiveMintProjectIDs.length; x++)
            {
                ILiveMint(FixedPriceSales[SaleIndex]._NFT)._LiveMintMarketplace(
                    Purchaser, 
                    FixedPriceSales[SaleIndex]._LiveMintProjectIDs[x], 
                    DesiredAmount
                );
            }
        }
        else if(FixedPriceSales[SaleIndex]._Type == 4) // ArtBlocks purchaseTo() Mint
        { 
            uint ProjectID = FixedPriceSales[SaleIndex]._MinterProjectID;
            for(uint x; x < DesiredAmount; x++) { IMinter(FixedPriceSales[SaleIndex]._NFT).purchaseTo(Purchaser, ProjectID); }
        } 
        else if (FixedPriceSales[SaleIndex]._Type == 5) // ERC721 transferFrom() Sale
        {
            IERC721 _NFT = IERC721(FixedPriceSales[SaleIndex]._NFT);
            address _Operator = FixedPriceSales[SaleIndex]._Operator;
            uint _StartingIndex = FixedPriceSales[SaleIndex]._CurrentIndex;
            for(uint Index; Index < DesiredAmount; Index++) { _NFT.transferFrom(_Operator, Purchaser, _StartingIndex + Index); }
            FixedPriceSales[SaleIndex]._CurrentIndex += DesiredAmount;
        }
        else if (FixedPriceSales[SaleIndex]._Type == 6)
        {
            IMinter _NFT = IMinter(FixedPriceSales[SaleIndex]._NFT);
            uint _BatchPurchaseAmount = FixedPriceSales[SaleIndex]._BatchPurchaseAmount;
            uint _ETHValue = FixedPriceSales[SaleIndex]._Price / _BatchPurchaseAmount;
            uint _MinterProjectID = FixedPriceSales[SaleIndex]._MinterProjectID;
            for(uint x; x < DesiredAmount; x++) // Iterates Over The Desired Units Of Purchase
            {
                for(uint y; y < _BatchPurchaseAmount; y++) // Mints Configured Amount Of NFTs Per Unit Purchased
                { 
                    _NFT.purchaseTo{value: _ETHValue}(Purchaser, _MinterProjectID); 
                }
            }
        }
        else { revert('Marketplace: Incorrect Sale Configuration'); }
        UserPurchasedAmount[SaleIndex][Purchaser] += DesiredAmount;
        ETHRevenueFixedPriceSale[SaleIndex] += MessageValue;
        emit Purchased(SaleIndex, Purchaser, DesiredAmount, Priority);
    }

    /**
     * @dev Finalizes A Presale Purchase
     * @param SaleIndex The Sale Index To Purchase
     * @param DesiredAmount The Desired Amount To Purchase
     * @param MaxAmount The Maximum Amount For Merkle Priority Purchase
     * @param Vault Delegate Vault Address
     * @param Proof Merkle Proof For Eligibility
     * @param ProofAmount Merkle Proof For MaxAmount
     */
    function __FinalizePresale(
        uint SaleIndex,
        uint DesiredAmount,
        uint MaxAmount,
        address Vault,
        bytes32[] calldata Proof,
        bytes32[] calldata ProofAmount,
        uint MessageValue,
        address Purchaser
    ) internal {
        require(tx.origin == Purchaser, "Marketplace: EOA Only");
        require(block.timestamp >= PresaleSales[SaleIndex]._TimestampSaleStart, "Marketplace: Sale Not Started");
        address MerkleRecipient = Purchaser;
        if(Vault != address(0)) { if(DelegateCash.checkDelegateForAll(Purchaser, Vault)) { MerkleRecipient = Vault; } }
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
                    VerifyBrightList(MerkleRecipient, InternalRoots[SaleIndex]._RootEligibilityFullSet, Proof), 
                    "Full Set Window: Not Eligible For Presale Window Or Block Pending, Please Try Again In A Few Seconds..."
                ); 
                require(VerifyAmount(MerkleRecipient, MaxAmount, InternalRoots[SaleIndex]._RootAmountFullSet, ProofAmount), "Invalid Full Set Amount Proof");
                require(InternalSaleWalletInfo[SaleIndex][MerkleRecipient]._AmountPurchasedWallet + DesiredAmount <= MaxAmount, "All Full Set Allocation Used");
                InternalSaleWalletInfo[SaleIndex][MerkleRecipient]._AmountPurchasedFullSetWindow += DesiredAmount;
                PresaleSalesInternal[SaleIndex]._GlobalPurchasesFullSet += DesiredAmount;
                emit Fullset();
            }
            else // Citizen Window
            { 
                require ( // Eligible For Citizen Window
                    VerifyBrightList(MerkleRecipient, InternalRoots[SaleIndex]._RootEligibilityCitizen, Proof), 
                    "Citizen Window: Not Eligible For Presale Window Or Block Pending, Please Try Again In A Few Seconds..."
                ); 
                require(VerifyAmount(MerkleRecipient, MaxAmount, InternalRoots[SaleIndex]._RootAmountCitizen, ProofAmount), "Invalid Citizen Amount Proof");
                require(InternalSaleWalletInfo[SaleIndex][MerkleRecipient]._AmountPurchasedCitizenWindow + DesiredAmount <= MaxAmount, "All Citizen Allocation Used");
                InternalSaleWalletInfo[SaleIndex][MerkleRecipient]._AmountPurchasedWallet += DesiredAmount;
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
        require(MessageValue >= _Price, "Invalid ETH Amount"); // Ensures ETH Amount Sent Is Correct
        if(MessageValue > _Price) { __Refund(Purchaser, MessageValue - _Price); } // Refunds The Difference
        if(_PresaleSale._Type == 0) { IMinter(_PresaleSale._NFT)._MintToFactory(0, Purchaser, DesiredAmount); }
        else if (_PresaleSale._Type == 1) 
        { 
            for(uint x; x < DesiredAmount; x++) { IMinter(_PresaleSale._NFT).purchaseTo(Purchaser, _PresaleSale._ProjectID); }
        }
        PresaleSalesInternal[SaleIndex]._AmountSold += DesiredAmount;
        PresaleSalesInternal[SaleIndex]._CurrentTokenIndex += DesiredAmount;
        PresaleSalesInternal[SaleIndex]._ETHRevenue += _Price;
        InternalSaleWalletInfo[SaleIndex][MerkleRecipient]._AmountPurchasedWallet += DesiredAmount;
        emit PurchasedPresale(SaleIndex, Purchaser, DesiredAmount, MessageValue, PresaleEnded);
    }

    /**
     * @dev Returns The Sale Info For A Fixed Price Sale
     */
    function __ViewSaleInfoFixedPrice (
        uint SaleIndex,
        address Wallet,
        uint MaxAmount,
        bytes32[] calldata ProofEligibility,
        bytes32[] calldata ProofAmount
    ) internal view returns (FixedPriceSaleInfo memory) {
        uint Price = FixedPriceSales[SaleIndex]._Price;
        uint AmountForSale = FixedPriceSales[SaleIndex]._AmountForSale;
        uint AmountRemaining = AmountForSale - AmountSoldFixedPrice[SaleIndex];
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
            FixedPriceSales[SaleIndex]._Name,
            Price, 
            FixedPriceSales[SaleIndex]._MintPassProjectID,
            FixedPriceSales[SaleIndex]._Type,
            FixedPriceSales[SaleIndex]._MinterProjectID,
            AmountForSale, 
            FixedPriceSales[SaleIndex]._TimestampStart,
            FixedPriceSales[SaleIndex]._CurrentIndex,
            FixedPriceSales[SaleIndex]._BatchPurchaseAmount,
            FixedPriceSales[SaleIndex]._NFT,
            FixedPriceSales[SaleIndex]._Operator,
            FixedPriceSales[SaleIndex]._RootEligibilities,
            FixedPriceSales[SaleIndex]._RootAmounts,
            FixedPriceSales[SaleIndex]._LiveMintProjectIDs,
            DiscountAmountWEIValues,
            ETHRevenue, 
            AmountRemaining, 
            Priority, 
            AmountRemainingMerklePriority,
            AmountPurchasedUser,
            BrightListEligible, 
            BrightListMerkleAmount
        );
    }

    /*-----------
     * MODIFIER *
    ------------*/

    /**
     * @dev onlyAdmin Modifier
     */
    modifier onlyAdmin
    {
        require(Admin[msg.sender], "Marketplace | onlyAdmin | Caller Is Not Admin");
        _;
    }
}

interface IERC20 { function approve(address From, address To, uint Amount) external; }
interface IERC721 { function transferFrom(address From, address To, uint TokenID) external; }
interface ILiveMint { function _LiveMintMarketplace(address Recipient, uint ArtistID, uint Amount) external; }