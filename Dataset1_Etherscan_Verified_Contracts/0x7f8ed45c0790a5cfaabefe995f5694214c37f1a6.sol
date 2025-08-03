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
// SPDX-License-Identifier: MIT
/**
 * @dev @brougkr
 */
pragma solidity 0.8.19;
interface IGT 
{ 
    /**
     * @dev { Golden Token Burn }
     */
    function _LiveMintBurn(uint TicketID) external returns (address Recipient); 
}
// SPDX-License-Identifier: MIT
/**
 * @dev @brougkr
 */
pragma solidity 0.8.19;
interface IMP 
{ 
    /**
     * @dev { For Instances Where Golden Token Or Artists Have A Bespoke Mint Pass Contract }
     */
    function _LiveMintBurn(uint TicketID) external returns (address Recipient, uint ArtistID); 
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
// SPDX-License-Identifier: MIT
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
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { IMinter } from "./IMinter.sol";
import { IMP } from "./IMP.sol";
import { IGT } from "./IGT.sol";
contract LiveMintParis is Ownable, ReentrancyGuard
{  
    struct City
    {
        string _Name;                       // _Name
        uint _QRCurrentIndex;               // _QRCurrentIndex
        bytes32 _RootEligibility;           // _RootEligibility
        bytes32 _RootAmount;                // _RootAmount
        bool _RemoteMintingEnabledArtists;  // _RemoteMintingEnabledArtists
        bool _RemoteMintingEnabledCitizens; // _RemoteMintingEnabledCitizen
    }

    struct Artist
    {
        address _MintPass;        // _MintPass
        address _Minter;          // _Minter
        address _AlternateMinter; // _AlternateMinter
        uint _MaxSupply;          // _MaxSupply
        uint _ArtBlocksProjectID; // _ArtBlocksProjectID 
        uint _PolyStart;          // _PolyStart
        uint _PolyEnd;            // _PolyEnd
    }

    /*-------------------*/
    /*  STATE VARIABLES  */
    /*-------------------*/

    bytes32 private constant _AUTHORIZED = keccak256("AUTHORIZED");                        // Authorized Role
    bytes32 private constant _MINTER_ROLE = keccak256("MINTER_ROLE");                      // Minter Role
    address private constant _DN = 0x00000000000076A84feF008CDAbe6409d2FE638B;             // delegate.cash Delegation Registry
    uint private constant _CCI = 8;                                                        // Current City Index
    address private constant _GOLDEN_TOKEN = 0x985e1932FFd2aA4bC9cE611DFe12816A248cD2cE;   // Golden Token Address
    address private constant _CITIZEN_MINTER = 0xDd06d8483868Cd0C5E69C24eEaA2A5F2bEaFd42b; // ArtBlocks Minter Contract
    address private constant _BRT_MULTISIG = 0xB96E81f80b3AEEf65CB6d0E280b15FD5DBE71937;   // BRT Multisig
    address public _MARKETPLACE;                                                           // Marketplace Address
    uint public _UniqueArtistsInvoked;                                                     // Unique Artists Invoked
    uint public _MaxQRDelegationsPerDay = 10;                                              // Max QR Delegations Per Day
    bool public _QRDelegationsEnabled = true;                                              // QR Delegations Enabled

    /*-------------------*/
    /*     MAPPINGS      */
    /*-------------------*/
    
    mapping(uint => Artist) public Artists;                              // [ArtistID] => Artist
    mapping(uint => City) public Cities;                                 // [CityIndex] => City Struct
    mapping(uint => mapping(address => bool)) public _QRRedeemed;        // [CityIndex][Wallet] => If User Has Redeemed QR
    mapping(uint => mapping(address => uint)) public _QRAllocation;      // [CityIndex][Wallet] => Wallet's QR Code Allocation
    mapping(uint => mapping(uint => address)) public _BrightListCitizen; // [CityIndex][TicketID] => Address Of CryptoCitizen Minting Recipient 
    mapping(uint => mapping(uint => address)) public _BrightListArtist;  // [ArtistID][TicketID] => Address Of Artist NFT Recipient
    mapping(uint => mapping(uint => uint)) public _MintedTokenIDCitizen; // [CityIndex][TicketID] => MintedTokenID
    mapping(uint => mapping(uint => uint)) public _MintedTokenIDArtist;  // [ArtistID][TicketID] => MintedTokenID
    mapping(uint => mapping(uint => bool)) public _MintedArtist;         // [ArtistID][TicketID] => If Minted
    mapping(uint => mapping(uint => bool)) public _MintedCitizen;        // [CityIndex][TicketID] => If Golden Ticket ID Has Minted Or Not
    mapping(uint => mapping(uint => uint)) public _ArtBlocksProjectID;   // [ArtistID][TicketID] => ArtBlocksProjectID
    mapping(uint => mapping(address => uint)) public _QRsRedeemed;       // [CityIndex][Wallet] => Amount Of QRs Redeemed
    mapping(uint => uint) public AmountRemaining;                        // [ArtistID] => Mints Remaining
    mapping(uint => uint) public DailyCalls;                             // [ElapsedDaysSinceUnixEpoch] => Amount Of Function Calls Today                       
    mapping(address => bytes32) public Role;                             // [Wallet] => BRT Minter Role

    /*-------------------*/
    /*      EVENTS       */
    /*-------------------*/

    /**
     * @dev Emitted When `Redeemer` IRL-mints CryptoCitizen Corresponding To Their Redeemed `TicketID`.
     **/
    event LiveMintComplete(address Redeemer, uint TicketID, uint TokenID);

    /**
     * @dev Emitted When `Redeemer` IRL-mints A Artist NFT Corresponding To Their Redeemed `TicketID`.
     */
    event LiveMintCompleteArtist(address Recipient, uint ArtistID, uint TicketID, uint MintedWorkTokenID);

    /**
     * @dev Emitted When `Redeemer` Redeems Golden Token Corresponding To `TicketID` 
     **/
    event QRRedeemed(address Redeemer, uint TicketID);

    /**
     * @dev Emitted When A Contract Is Authorized
     */
    event AuthorizedContract(address NewAddress);

    /**
     * @dev Emitted When A Contract Is Deauthorized
     */
    event DeauthorizedContract(address NewAddress);

    /**
     * @dev Emitted When A TokenID Is Minted From Marketplace
     */
    event Minted(uint TokenID);

    /*-------------------*/
    /*    CONSTRUCTOR    */
    /*-------------------*/

    constructor()
    { 
        Cities[0]._Name = "CryptoGalacticans";  
        Cities[1]._Name = "CryptoVenetians";    
        Cities[2]._Name = "CryptoNewYorkers";   
        Cities[3]._Name = "CryptoBerliners";    
        Cities[4]._Name = "CryptoLondoners";    
        Cities[5]._Name = "CryptoMexas";        
        Cities[6]._Name = "CryptoTokyites";     
        Cities[7]._Name = "CryptoPatagonians"; 
        Cities[8]._Name = "CryptoParisians";
        Cities[8]._QRCurrentIndex = 999;
        Cities[8]._RootEligibility = 0x302dc7afac84ccea916b1efa18450e9a52cadd533f1e74d596f541fe8a115905;
        Cities[8]._RootAmount = 0x4dd20fff095ef5aaf17d6d33b39873402fdc5ff05a0bf8088b2e01fcde3b22ff;
        Cities[9]._Name = "CryptoVenezians";
        Cities[9]._QRCurrentIndex = 1332; 
        Role[msg.sender] = _AUTHORIZED; 
        Role[0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700] = _AUTHORIZED;  // `operator.brightmoments.eth`
        Role[0x18B7511938FBe2EE08ADf3d4A24edB00A5C9B783] = _AUTHORIZED;  // `phil.brightmoments.eth`
        Role[0x91594b5E5d74FCCB3f71674eE74C5F4D44f333D5] = _AUTHORIZED;  // `future.brightmoments.eth`
        Role[0x1A0a3E3AE390a0710f8A6d00587082273eA8F6C9] = _MINTER_ROLE; // BRT Minter #1
        Role[0x4d8013b0c264034CBf22De9DF33e22f58D52F207] = _MINTER_ROLE; // BRT Minter #2
        Role[0x4D9A8CF2fE52b8D49C7F7EAA87b2886c2bCB4160] = _MINTER_ROLE; // BRT Minter #3
        Role[0x124fd966A0D83aA020D3C54AE2c9f4800b46F460] = _MINTER_ROLE; // BRT Minter #4
        Role[0x100469feA90Ac1Fe1073E1B2b5c020A8413635c4] = _MINTER_ROLE; // BRT Minter #5
        Role[0x756De4236373fd17652b377315954ca327412bBA] = _MINTER_ROLE; // BRT Minter #6
        Role[0xc5Dfba6ef7803665C1BDE478B51Bd7eB257A2Cb9] = _MINTER_ROLE; // BRT Minter #7
        Role[0xFBF32b29Bcf8fEe32d43a4Bfd3e7249daec457C0] = _MINTER_ROLE; // BRT Minter #8
        Role[0xF2A15A83DEE7f03C70936449037d65a1C100FF27] = _MINTER_ROLE; // BRT Minter #9
        Role[0x1D2BAB965a4bB72f177Cd641C7BacF3d8257230D] = _MINTER_ROLE; // BRT Minter #10
        Role[0x2e51E8b950D72BDf003b58E357C2BA28FB77c7fB] = _MINTER_ROLE; // BRT Minter #11
        Role[0x8a7186dECb91Da854090be8226222eA42c5eeCb6] = _MINTER_ROLE; // BRT Minter #12
        _transferOwnership(0xe06F5FAE754e81Bc050215fF89B03d9e9FF20700); // `operator.brightmoments.eth`
    }

    /*---------------------*/
    /*    QR REDEMPTION    */
    /*---------------------*/

    /**
     * @dev Redeems Spot(s) For IRL Minting
     * @param ProofEligibility Proof For Merkle Eligibility
     * @param ProofAmounts Proof For Merkle Amounts
     * @param Vault Address Of Vault For Merkle Eligibility (Delegate.xyz)
     * @param Amount Amount Of QR Codes To Redeem
     */
    function RedeemQR (
        bytes32[] calldata ProofEligibility, 
        bytes32[] calldata ProofAmounts,
        address Vault, 
        uint Amount
   ) external nonReentrant {    
        address Recipient = msg.sender;
        if(Vault != address(0)) { if(IDelegationRegistry(_DN).checkDelegateForAll(msg.sender, Vault)) { Recipient = Vault; } } 
        readQREligibility(Recipient, ProofEligibility, ProofAmounts, Amount);
        _QRsRedeemed[_CCI][Recipient] += Amount;
        if(_QRAllocation[_CCI][Recipient] == 0) // User Is Able To Redeem Explicitly 1 QR Code
        {
            require(!_QRRedeemed[_CCI][Recipient], "LiveMint: User Has Already Redeemed");
            _BrightListCitizen[_CCI][Cities[_CCI]._QRCurrentIndex] = Recipient;
            emit QRRedeemed(Recipient, Cities[_CCI]._QRCurrentIndex);
            Cities[_CCI]._QRCurrentIndex++; 
        }
        else // User Is Able To Redeem More Than 1 QR Code Because Their Allocation Is Greater Than 1
        {
            require (
                _QRsRedeemed[_CCI][Recipient] <= _QRAllocation[_CCI][Recipient],
                "LiveMint: User Has No Remaining Authorized QRs To Redeem"
            );
            uint _CurrentQR = Cities[_CCI]._QRCurrentIndex;
            uint _Limit = Amount + _CurrentQR;
            Cities[_CCI]._QRCurrentIndex = _Limit;
            for(_CurrentQR; _CurrentQR < _Limit; _CurrentQR++)
            {
                _BrightListCitizen[_CCI][_CurrentQR] = Recipient;
                emit QRRedeemed(Recipient, _CurrentQR);
            }
        }
        _QRRedeemed[_CCI][Recipient] = true;
    }

    /**
     * @dev Remote Mints Artist NFTs Via Mint Pass LiveMintBurn
     * @param ArtistIDs Array Of ArtistIDs To Mint
     * @param TicketIDs Array Of TicketIDs To Mint
     */
    function RemoteMintArtists(uint[] calldata ArtistIDs, uint[][] calldata TicketIDs) external nonReentrant
    {
        require(tx.origin == msg.sender, "LiveMint: msg.sender Must Be EOA");
        require(Cities[_CCI]._RemoteMintingEnabledArtists, "LiveMint: Remote Minting Of Artists Not Active");
        address Recipient;
        address MintPass;
        address Minter;
        uint ArtBlocksProjectID;
        uint MintedWorkTokenID;
        uint TicketID;
        uint ActiveArtistID;
        for(uint ArtistIDIndex; ArtistIDIndex < ArtistIDs.length; ArtistIDIndex++)
        {
            ActiveArtistID = ArtistIDs[ArtistIDIndex];
            MintPass = Artists[ActiveArtistID]._MintPass;
            Minter = Artists[ActiveArtistID]._Minter;
            for(uint TicketIDIndex; TicketIDIndex < TicketIDs[ArtistIDIndex].length; TicketIDIndex++)
            {
                TicketID = TicketIDs[ArtistIDIndex][TicketIDIndex];
                require(!_MintedArtist[ActiveArtistID][TicketID], "LiveMint: Artist Mint Pass Already Minted");
                _MintedArtist[ActiveArtistID][TicketID] = true;
                (Recipient, ArtBlocksProjectID) = IMP(MintPass)._LiveMintBurn(TicketID);
                require(Recipient == msg.sender, "LiveMint: msg.sender Is Not The Owner Of Input Mint Pass");
                MintedWorkTokenID = IMinter(Minter).purchaseTo(Recipient, ArtBlocksProjectID);
                _MintedTokenIDArtist[ActiveArtistID][TicketID] = MintedWorkTokenID;
                emit LiveMintCompleteArtist(Recipient, ActiveArtistID, TicketID, MintedWorkTokenID);
            }
        }
    }

    /**
     * @dev Remote Mints GoldenTokens For Citizens
     * @param TicketIDs Array Of TicketIDs To Mint
     */
    function RemoteMintCitizens(uint[] calldata TicketIDs) external nonReentrant
    {
        require(tx.origin == msg.sender, "LiveMint: msg.sender Must Be EOA");
        require(Cities[_CCI]._RemoteMintingEnabledCitizens, "LiveMint: Remote Minting Of Citizens Not Active");
        address Recipient;
        uint MintedWorkTokenID;
        for(uint TicketID; TicketID < TicketIDs.length; TicketID++)
        {
            require(TicketIDs[TicketID] < 999, "LiveMint: Invalid Input TicketID, Must Be Golden Token");
            require(!_MintedCitizen[_CCI][TicketIDs[TicketID]], "LiveMint: Golden Token Already Minted");
            _MintedCitizen[_CCI][TicketIDs[TicketID]] = true;
            Recipient = IGT(_GOLDEN_TOKEN)._LiveMintBurn(TicketIDs[TicketID]);
            require(Recipient == msg.sender, "LiveMint: msg.sender Is Not Owner Of Golden Token");
            MintedWorkTokenID = IMinter(_CITIZEN_MINTER).purchaseTo(Recipient, _CCI);
            _MintedTokenIDCitizen[_CCI][TicketIDs[TicketID]] = MintedWorkTokenID;
            emit LiveMintComplete(Recipient, TicketIDs[TicketID], MintedWorkTokenID); 
        }
    }

    /*--------------------*/
    /*    LIVE MINTING    */
    /*--------------------*/

    /**
     * @dev Batch Mints Verified Users On The Brightlist CryptoCitizens
     * @param TicketIDs Array Of TicketIDs To Mint
     * note: { For CryptoCitizen Cities }
     */
    function _LiveMintCitizen(uint[] calldata TicketIDs) external onlyMinter
    {
        address Recipient;
        uint MintedWorkTokenID;
        for(uint TicketID; TicketID < TicketIDs.length; TicketID++)
        {
            require(!_MintedCitizen[_CCI][TicketIDs[TicketID]], "LiveMint: Golden Token Already Minted");
            if(_BrightListCitizen[_CCI][TicketIDs[TicketID]] != address(0)) { Recipient = _BrightListCitizen[_CCI][TicketIDs[TicketID]]; }
            else if (TicketIDs[TicketID] < 999) { Recipient = IGT(_GOLDEN_TOKEN)._LiveMintBurn(TicketIDs[TicketID]); }
            else { revert("LiveMint: TicketID Is Not Eligible To Mint Citizen"); }
            require(Recipient != address(0), "LiveMint: Invalid Recipient");
            _MintedCitizen[_CCI][TicketIDs[TicketID]] = true;
            MintedWorkTokenID = IMinter(_CITIZEN_MINTER).purchaseTo(Recipient, _CCI);
            _MintedTokenIDCitizen[_CCI][TicketIDs[TicketID]] = MintedWorkTokenID;
            emit LiveMintComplete(Recipient, TicketIDs[TicketID], MintedWorkTokenID); 
        }
    }

    /**
     * @dev Burns Artist Mint Pass In Exchange For The Minted Work
     * @param ArtistID ArtistID To Mint
     * @param TicketIDs Array Of TicketIDs To Mint
     * note: { For Instances Where Multiple Artists Share The Same Mint Pass & Return (Recipient, ArtBlocksProjectID) }
     */
    function _LiveMintArtist(uint ArtistID, uint[] calldata TicketIDs) external onlyMinter
    {
        address Recipient;
        address MintPass = Artists[ArtistID]._MintPass;
        address Minter = Artists[ArtistID]._Minter;
        uint ArtBlocksProjectID;
        uint MintedWorkTokenID;
        uint TicketID;
        require(AmountRemaining[ArtistID] > 0, "LiveMint: ArtistID Mint Limit Reached");
        require(TicketIDs.length <= AmountRemaining[ArtistID], "LiveMint: TicketID Length Exceeds ArtistID Mint Limit");
        AmountRemaining[ArtistID] = AmountRemaining[ArtistID] - TicketIDs.length;
        for(uint x; x < TicketIDs.length; x++)
        {
            TicketID = TicketIDs[x];
            require(!_MintedArtist[ArtistID][TicketID], "LiveMint: Artist Mint Pass Already Minted");
            _MintedArtist[ArtistID][TicketID] = true;
            (Recipient, ArtBlocksProjectID) = IMP(MintPass)._LiveMintBurn(TicketID);
            MintedWorkTokenID = IMinter(Minter).purchaseTo(Recipient, ArtBlocksProjectID); // Pre-Defined Minter Contract
            _MintedTokenIDArtist[ArtistID][TicketID] = MintedWorkTokenID;
            emit LiveMintCompleteArtist(Recipient, ArtistID, TicketID, MintedWorkTokenID);
        }
    }

    /**
     * @dev Burns Artist Mint Pass In Exchange For The Minted Work
     * @param ArtistIDs Array Of ArtistIDs To Mint
     * @param TicketIDs 2D-Array Of TicketIDs To Mint
     * note: { For Instances Where Multiple Artists Share The Same Mint Pass & Return (Recipient, ArtBlocksProjectID) }
     */
    function _LiveMintArtistBatch(uint[] calldata ArtistIDs, uint[][] calldata TicketIDs) external onlyMinter
    {
        address Recipient;
        address MintPass;
        address Minter;
        uint ArtBlocksProjectID;
        uint MintedWorkTokenID;
        uint TicketID;
        uint ActiveArtistID;
        for(uint ArtistIDIndex; ArtistIDIndex < ArtistIDs.length; ArtistIDIndex++)
        {
            ActiveArtistID = ArtistIDs[ArtistIDIndex];
            MintPass = Artists[ActiveArtistID]._MintPass;
            Minter = Artists[ActiveArtistID]._Minter;
            for(uint TicketIDIndex; TicketIDIndex < TicketIDs[ArtistIDIndex].length; TicketIDIndex++)
            {
                TicketID = TicketIDs[ArtistIDIndex][TicketIDIndex];
                require(!_MintedArtist[ActiveArtistID][TicketID], "LiveMint: Artist Mint Pass Already Minted");
                _MintedArtist[ActiveArtistID][TicketID] = true;
                (Recipient, ArtBlocksProjectID) = IMP(MintPass)._LiveMintBurn(TicketID);
                MintedWorkTokenID = IMinter(Minter).purchaseTo(Recipient, ArtBlocksProjectID);
                _MintedTokenIDArtist[ActiveArtistID][TicketID] = MintedWorkTokenID;
                emit LiveMintCompleteArtist(Recipient, ActiveArtistID, TicketID, MintedWorkTokenID);
            }
        }
    }

    /**
     * @dev Mints An Artist Work Directly From Marketplace
     * @param Recipient Address To Mint To
     * @param ArtistID ArtistID To Mint
     * @param Amount Amount To Mint
     */
    function _LiveMintMarketplace(address Recipient, uint ArtistID, uint Amount) external onlyMarketplace
    {
        uint _AmountRemaining = AmountRemaining[ArtistID];
        require(Amount <= _AmountRemaining, "LiveMint: Not Enough Mints Remaining For Desired ArtistID");
        AmountRemaining[ArtistID] = _AmountRemaining - Amount;
        address _Minter = Artists[ArtistID]._Minter;
        uint _ABProjectID = Artists[ArtistID]._ArtBlocksProjectID;
        uint _TokenID;
        for(uint PurchaseAmt; PurchaseAmt < Amount; PurchaseAmt++)
        {
            _TokenID = IMinter(_Minter).purchaseTo(Recipient, _ABProjectID);
            emit Minted (_TokenID);
        }
    }

    /*-------------------*/
    /*  OWNER FUNCTIONS  */
    /*-------------------*/

    /**
     * @dev Initializes A LiveMint Artist
     */
    function __InitLiveMint (Artist memory _Params) external onlyAdmin returns (uint ArtistID)
    {
        ArtistID = _UniqueArtistsInvoked;
        AmountRemaining[ArtistID] = _Params._MaxSupply;
        Artists[ArtistID] = _Params;
        _UniqueArtistsInvoked = ArtistID + 1;
        return ArtistID;
    }

    /**
     * @dev Changes The Current Active Marketplace Address
     */
    function __DelegateQR (address Recipient) external onlyAdmin
    {
        require(_QRDelegationsEnabled, "LiveMint: QR Delegations Not Enabled");
        uint _DaysElapsed = block.timestamp / 86400;
        require(DailyCalls[_DaysElapsed] + 1 <= _MaxQRDelegationsPerDay, "LiveMint: Max Per Day Reached");
        require(!_QRRedeemed[_CCI][Recipient], "LiveMint: User Has Already Redeemed");
        DailyCalls[_DaysElapsed]++;
        _QRRedeemed[_CCI][Recipient] = true;
        _BrightListCitizen[_CCI][Cities[_CCI]._QRCurrentIndex] = Recipient;
        emit QRRedeemed(Recipient, Cities[_CCI]._QRCurrentIndex);
        Cities[_CCI]._QRCurrentIndex++;
    }

    /**
     * @dev Changes Merkle Root For Citizen LiveMint Eligibility
     * @param NewRoot The New Merkle Root To Seed
     */
    function __ChangeRootEligibility (bytes32 NewRoot) external onlyAdmin { Cities[_CCI]._RootEligibility = NewRoot; }

    /**
     * @dev Changes Merkle Root For Citizen LiveMint Amounts
     * @param NewRoot The New Merkle Root To Seed
     */
    function __ChangeRootAmounts (bytes32 NewRoot) external onlyAdmin { Cities[_CCI]._RootAmount = NewRoot; }

    /**
     * @dev Changes Merkle Root For Artist LiveMints
     * @param EligibilityRoot The New Merkle Eligibility Root To Seed
     * @param EligibilityAmount The New Merkle Amount Root To Seed
     */
    function __ChangeRoots (bytes32 EligibilityRoot, bytes32 EligibilityAmount) external onlyAdmin
    {
        Cities[_CCI]._RootEligibility = EligibilityRoot;
        Cities[_CCI]._RootAmount = EligibilityAmount;
    }

    /**
     * @dev Overwrites QR Allocation(s)
     * @param Addresses Array Of Addresses To Overwrite
     * @param Amounts Array Of Amounts To Overwrite
     */
    function __QRAllocationsOverwrite (address[] calldata Addresses, uint[] calldata Amounts) external onlyAdmin
    {
        require(Addresses.length == Amounts.length, "LiveMint: Input Arrays Must Match");
        for(uint x; x < Addresses.length; x++) { _QRAllocation[_CCI][Addresses[x]] = Amounts[x]; }
    }

    /**
     * @dev Increments QR Allocation(s)
     * @param Addresses Array Of Addresses To Increment
     * @param Amounts Array Of Amounts To Increment
     */
    function __QRAllocationsIncrement (address[] calldata Addresses, uint[] calldata Amounts) external onlyAdmin
    {
        require(Addresses.length == Amounts.length, "LiveMint: Input Arrays Must Match");
        for(uint x; x < Addresses.length; x++) { _QRAllocation[_CCI][Addresses[x]] += Amounts[x]; }
    }

    /**
     * @dev Overrides QR To Mint To Multisig
     * @param TicketIDs Array Of TicketIDs To Override
     */
    function __QRAllocationsSetNoShow (uint[] calldata TicketIDs) external onlyAdmin
    {
        for(uint TicketIndex; TicketIndex < TicketIDs.length; TicketIndex++)
        {
            require(!_MintedCitizen[_CCI][TicketIDs[TicketIndex]], "LiveMint: Ticket ID Already Minted");
            require(TicketIDs[TicketIndex] > 999, "LiveMint: Invalid TicketID");
            _BrightListCitizen[_CCI][TicketIDs[TicketIndex]] = _BRT_MULTISIG;
        }
    }

    /*-------------------*/
    /*  OWNER FUNCTIONS  */
    /*-------------------*/

    /**
     * @dev Changes Max QR Delegations Per Day
     */
    function __ChangeQRDelegationsEnabled(bool NewState) external onlyOwner { _QRDelegationsEnabled = NewState; }
    
    /**
     * @dev Changes Max QR Delegations Per Day
     */
    function __ChangeMaxPerDay(uint NewMax) external onlyOwner { _MaxQRDelegationsPerDay = NewMax; }

    /**
     * @dev Changes The Current Active Marketplace Address
     * @param NewAddress The New Address To Seed
     */
    function __ChangeMarketplaceAddress(address NewAddress) external onlyOwner { _MARKETPLACE = NewAddress; }

    /**
     * @dev Flips Remote Minting State For CryptoCitizens (True or False)
     */
    function __FlipRemoteMintingCitizens() external onlyOwner 
    { 
        Cities[_CCI]._RemoteMintingEnabledCitizens = !Cities[_CCI]._RemoteMintingEnabledCitizens; 
    }

    /**
     * @dev Flips Remote Minting State For Artists
     */
    function __FlipRemoteMintingArtists() external onlyOwner 
    { 
        Cities[_CCI]._RemoteMintingEnabledArtists = !Cities[_CCI]._RemoteMintingEnabledArtists; 
    }

    /**
     * @dev Flips Remote Minting State For Both Artists & Citizens
     */
    function __FlipRemoteMintingStates() external onlyOwner
    {
        Cities[_CCI]._RemoteMintingEnabledArtists = !Cities[_CCI]._RemoteMintingEnabledArtists; 
        Cities[_CCI]._RemoteMintingEnabledCitizens = !Cities[_CCI]._RemoteMintingEnabledCitizens;
    }

    /**
     * @dev Grants Address BRT Minter Role
     * @param Minter Address To Grant Role
     * note: BRT Minter Role Is Required To Mint NFTs
     **/
    function __AddMinter(address Minter) external onlyOwner { Role[Minter] = _MINTER_ROLE; }
    
    /**
     * @dev Deactivates Address From BRT Minter Role
     * @param Minter Address To Remove Role
     * note: BRT Minter Role Is Required To Mint NFTs
     **/
    function __RemoveMinter(address Minter) external onlyOwner { Role[Minter] = 0x0; }

    /**
     * @dev Changes Mint Pass Address For Artist LiveMints
     * @param ProjectID Artist ProjectID
     * @param Contract Mint Pass Contract Address
     * note: Mint Pass Is Burned In Exchange For Minted Work
     */
    function __ChangeMintPass(uint ProjectID, address Contract) external onlyOwner { Artists[ProjectID]._MintPass = Contract; }

    /**
     * @dev Changes Minter Address For Artist LiveMints
     * @param ProjectID Artist ProjectID
     * @param Contract Minter Contract Address
     */
    function __ChangeMinter(uint ProjectID, address Contract) external onlyOwner { Artists[ProjectID]._Minter = Contract; }

    /**
     * @dev Changes QR Current Index
     * @param NewIndex The Next QR Index To Redeem
     */
    function __ChangeQRIndex(uint NewIndex) external onlyOwner { Cities[_CCI]._QRCurrentIndex = NewIndex; }

    /**
     * @dev Instantiates New City
     * @param Name Name Of City
     * @param CityIndex CityIndex Of City
     * @param QRIndex QRIndex Of City
     * @param RemoteMintingEnabledArtists Remote Minting Enabled For Artists
     * @param RemoteMintingEnabledCitizens Remote Minting Enabled For Citizens
     * note: CityIndex Always Corresponds To ArtBlocks ProjectID For CryptoCitizens
     */
    function __NewCity (
        string calldata Name,
        uint CityIndex,
        uint QRIndex,
        bool RemoteMintingEnabledArtists,
        bool RemoteMintingEnabledCitizens
   ) external onlyOwner {
        Cities[CityIndex] = City(
            Name,
            QRIndex,
            0x6942069420694206942069420694206942069420694206942069420694206942,
            0x6942069420694206942069420694206942069420694206942069420694206942,
            RemoteMintingEnabledArtists,
            RemoteMintingEnabledCitizens
        );
    }

    /**
     * @dev Changes The Amount Remaining For An Artist Mint
     * @param ArtistID ArtistID To Change
     * @param Amount Amount To Change To
     */
    function __NewAmountRemaining(uint ArtistID, uint Amount) external onlyOwner
    {
        AmountRemaining[ArtistID] = Amount;
    }
    
    /**
     * @dev Instantiates A New City
     * @param CityIndex CityIndex Of New City
     * @param NewCity The City Struct
     */
    function __NewCityStruct(uint CityIndex, City memory NewCity) external onlyOwner { Cities[CityIndex] = NewCity; }

    /**
     * @dev Returns An Artist Struct
     * @param ArtistID The ArtistID To Change
     * @param NewArtist The Artist Struct
     */
    function __NewArtistStruct(uint ArtistID, Artist memory NewArtist) external onlyOwner { Artists[ArtistID] = NewArtist; }

    /**
     * @dev Changes The Minter Address For An Artist
     * @param ArtistID ArtistID To Change
     * @param Minter New Minter Address
     */
    function __NewArtistMinter(uint ArtistID, address Minter) external onlyOwner { Artists[ArtistID]._Minter = Minter; }

    /**
     * @dev Withdraws Any Ether Mistakenly Sent to Contract to Multisig
     **/
    function __WithdrawEther() external onlyOwner { payable(msg.sender).transfer(address(this).balance); }

    /**
     * @dev Executes Arbitrary Transaction(s)
     * @param Targets Array Of Addresses To Execute Transactions On
     * @param Values Array Of Values To Execute Transactions With
     * @param Datas Array Of Datas To Execute Transactions With
     */
    function __InitTransaction(address[] memory Targets, uint[] memory Values, bytes[] memory Datas) external onlyOwner
    {
        for(uint x; x < Targets.length; x++) 
        {
            (bool success,) = Targets[x].call{value:(Values[x])}(Datas[x]);
            require(success, "i have failed u anakin");
        }
    }

    /**
     * @dev Authorizes An Address
     * @param NewAddress Address To Authorize
     */
    function ____AddressAuthorize(address NewAddress) external onlyOwner 
    { 
        Role[NewAddress] = _AUTHORIZED; 
        emit AuthorizedContract(NewAddress);
    }

    /**
     * @dev Deauthorizes An Address
     * @param NewAddress Address To Deauthorize
     */
    function ____AddressDeauthorize(address NewAddress) external onlyOwner 
    { 
        Role[NewAddress] = 0x0; 
        emit DeauthorizedContract(NewAddress);
    }
    
    /*-------------------*/
    /*    PUBLIC VIEW    */
    /*-------------------*/

    /**
     * @dev Returns A User's QR Allocation Amount, Or 0 If Not Eligible
     */
    function readEligibility (
        address Recipient, 
        bytes32[] memory Proof, 
        bytes32[] memory ProofAmount, 
        uint Amount
    ) public view returns (uint ) {
        bool Eligible = readQREligibility(Recipient, Proof, ProofAmount, Amount);
        uint Allocation = _QRAllocation[_CCI][Recipient];
        uint AmountRedeemed = _QRsRedeemed[_CCI][Recipient];
        if(Eligible && Allocation > AmountRedeemed) { return Allocation - AmountRedeemed; }
        else if (Eligible && Allocation == 0 && AmountRedeemed == 0) { return 1; }
        else { return 0; }
    }

    /**
     * @dev Returns If User Is Eligible To Redeem QR Code
     */
    function readQREligibility (
        address Recipient, 
        bytes32[] memory ProofEligibility, 
        bytes32[] memory ProofAmount, 
        uint Amount
    ) public view returns (bool) {
        require(Amount > 0, "LiveMint: QR Redemption Amount Must Be > 0");
        bytes32 Leaf = keccak256(abi.encodePacked(Recipient));
        bytes32 LeafAmount = keccak256(abi.encodePacked(Recipient, Amount));
        require(MerkleProof.verify(ProofEligibility, Cities[_CCI]._RootEligibility, Leaf), "LiveMint: Invalid Merkle Eligibility Proof");
        require(MerkleProof.verify(ProofAmount, Cities[_CCI]._RootAmount, LeafAmount), "LiveMint: Invalid Merkle Amount Proof");
        return true;
    }

    /**
     * @dev Returns How Many QR Codes A User Has Redeemed
     */
    function readAmountRedeemed(address Recipient) public view returns(uint) { return _QRsRedeemed[_CCI][Recipient]; }

    /**
     * @dev Returns An Array Of Unminted Golden Tokens
     */
    function readCitizenUnmintedTicketIDs() public view returns(uint[] memory)
    {
        uint[] memory UnmintedTokenIDs = new uint[](1000);
        uint Counter;
        uint CityIDBuffer = _CCI % 6 * 333;
        uint _TokenID;
        for(uint TokenID; TokenID < 1000; TokenID++)
        {
            _TokenID = TokenID + CityIDBuffer;
            if
            (
                (!_MintedCitizen[_CCI][_TokenID]
                &&
                _BrightListCitizen[_CCI][_TokenID] != address(0))
                ||
                (!_MintedCitizen[_CCI][_TokenID] && _TokenID < 999)
            ) 
            { 
                UnmintedTokenIDs[Counter] = _TokenID; 
                Counter++;
            }
        }
        uint[] memory FormattedUnMintedTokenIDs = new uint[](Counter);
        for(uint Index; Index < Counter; Index++)
        {
            FormattedUnMintedTokenIDs[Index] = UnmintedTokenIDs[Index];
        }
        return FormattedUnMintedTokenIDs;
    }

    /**
     * @dev Returns An Array Of Unminted Golden Tokens
     */
    function readCitizenMintedTicketIDs(uint CityID) public view returns(uint[] memory)
    {
        uint[] memory MintedTokenIDs = new uint[](1000);
        uint Counter;
        uint CityIDBuffer = (CityID % 6) * 333;
        uint _TicketID;
        for(uint TicketID; TicketID < 1000; TicketID++)
        {
            _TicketID = TicketID + CityIDBuffer;
            if(_MintedCitizen[CityID][_TicketID]) 
            { 
                MintedTokenIDs[Counter] = _TicketID; 
                Counter++;
            }
        }
        uint[] memory FormattedMintedTokenIDs = new uint[](Counter);
        uint Found;
        for(uint FormattedTokenID; FormattedTokenID < Counter; FormattedTokenID++)
        {
            if(MintedTokenIDs[FormattedTokenID] != 0 || (MintedTokenIDs[FormattedTokenID] == 0 && FormattedTokenID == 0))
            {
                FormattedMintedTokenIDs[Found] = MintedTokenIDs[FormattedTokenID];
                Found++;
            }
        }
        return FormattedMintedTokenIDs;
    }

    /**
     * @dev Returns A 2d Array Of Checked In & Unminted TicketIDs Awaiting A Mint
     */
    function readCitizenCheckedInTicketIDs() public view returns(uint[] memory TokenIDs)
    {
        uint[] memory _TokenIDs = new uint[](1000);
        uint CityIDBuffer = (_CCI % 6) * 333;
        uint _TicketID;
        uint Counter;
        for(uint TicketID; TicketID < 1000; TicketID++)
        {
            _TicketID = TicketID + CityIDBuffer;
            if(
                !_MintedCitizen[_CCI][_TicketID]
                &&
                _BrightListCitizen[_CCI][_TicketID] != address(0)
            ) 
            { 
                _TokenIDs[Counter] = _TicketID; 
                Counter++;
            }
        }
        uint[] memory FormattedCheckedInTickets = new uint[](Counter);
        uint Found;
        for(uint x; x < Counter; x++)
        {
            if(_TokenIDs[x] != 0 || (_TokenIDs[x] == 0 && x == 0))
            {
                FormattedCheckedInTickets[Found] = _TokenIDs[x];
                Found++;
            }
        }
        return FormattedCheckedInTickets;
    }

    /**
     * @dev Returns A 2d Array Of Minted ArtistIDs
     */
    function readArtistUnmintedTicketIDs(uint[] calldata ArtistIDs, uint Range) public view returns(uint[][] memory TokenIDs)
    {
        uint[][] memory _TokenIDs = new uint[][](ArtistIDs.length);
        uint Index;
        for(uint ArtistID; ArtistID < ArtistIDs.length; ArtistID++)
        {
            uint[] memory UnmintedArtistTokenIDs = new uint[](Range);
            uint Counter;
            for(uint TokenID; TokenID < Range; TokenID++)
            {
                if(!_MintedArtist[ArtistIDs[ArtistID]][TokenID]) 
                { 
                    UnmintedArtistTokenIDs[Counter] = TokenID; 
                    Counter++;
                }
            }
            uint[] memory FormattedUnMintedArtistIDs = new uint[](Counter);
            uint Found;
            for(uint x; x < Counter; x++)
            {
                if(UnmintedArtistTokenIDs[x] != 0 || (UnmintedArtistTokenIDs[x] == 0 && x == 0))
                {
                    FormattedUnMintedArtistIDs[Found] = UnmintedArtistTokenIDs[x];
                    Found++;
                }
            }
            _TokenIDs[Index] = FormattedUnMintedArtistIDs;
            Index++;
        }
        return (_TokenIDs);
    }

    /**
     * @dev Returns A 2d Array Of Minted ArtistIDs
     */
    function readArtistMintedTicketIDs(uint[] calldata ArtistIDs, uint Range) public view returns(uint[][] memory TokenIDs)
    {
        uint[][] memory _TokenIDs = new uint[][](ArtistIDs.length);
        uint Index;
        for(uint ArtistID; ArtistID < ArtistIDs.length; ArtistID++)
        {
            uint[] memory MintedTokenIDs = new uint[](Range);
            uint Counter;
            for(uint TokenID; TokenID < Range; TokenID++)
            {
                if(_MintedArtist[ArtistIDs[ArtistID]][TokenID])
                { 
                    MintedTokenIDs[Counter] = TokenID; 
                    Counter++;
                }
            }
            uint[] memory FormattedMintedTokenIDs = new uint[](Counter);
            uint Found;
            for(uint x; x < Counter; x++)
            {
                if(MintedTokenIDs[x] != 0 || (MintedTokenIDs[x] == 0 && x == 0))
                {
                    FormattedMintedTokenIDs[Found] = MintedTokenIDs[x];
                    Found++;
                }
            }
            _TokenIDs[Index] = FormattedMintedTokenIDs;
            Index++;
        }
        return (_TokenIDs);
    }

    /**
     * @dev Returns Original Recipients Of CryptoCitizens
     */
    function readCitizenBrightList(uint CityIndex) public view returns(address[] memory Recipients)
    {
        address[] memory _Recipients = new address[](1000);
        uint Start = (CityIndex % 6) * 333;
        for(uint x; x < 1000; x++) { _Recipients[x] = _BrightListCitizen[CityIndex][Start+x]; }
        return _Recipients;
    }

    /**
     * @dev Returns Original Recipient Of Artist NFTs
     */
    function readArtistBrightList(uint ArtistID, uint Range) public view returns(address[] memory Recipients)
    {
        address[] memory _Recipients = new address[](Range);
        for(uint x; x < Range; x++) { _Recipients[x] = _BrightListArtist[ArtistID][x]; }
        return _Recipients;    
    }

    /**
     * @dev Returns The City Struct At Index Of `CityIndex`
     */
    function readCitizenCity(uint CityIndex) public view returns(City memory) { return Cities[CityIndex]; }

    /**
     * @dev Returns The Artist Struct At Index Of `ArtistID`
     */
    function readArtist(uint ArtistID) public view returns(Artist memory) { return Artists[ArtistID]; }

    /**
     * @dev Returns A Minted Work TokenID Corresponding To The Input Artist TicketID 
     */
    function readArtistMintedTokenID(uint ArtistID, uint TicketID) external view returns (uint)
    {
        if(!_MintedArtist[ArtistID][TicketID]) { return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff; }
        else { return _MintedTokenIDArtist[ArtistID][TicketID]; }
    }

    /**
     * @dev Returns A Minted Citizen TokenID Corresponding To Input TicketID
     */
    function readCitizenMintedTokenID(uint CityIndex, uint TicketID) external view returns(uint)
    {
        if(!_MintedCitizen[CityIndex][TicketID]) { return type(uint).max; }
        else { return _MintedTokenIDCitizen[CityIndex][TicketID]; }  
    }

    /*-------------------------*/
    /*     ACCESS MODIFIERS    */
    /*-------------------------*/

    /**
     * @dev Access Modifier That Allows Only BrightListed BRT Minters
     **/
    modifier onlyMinter() 
    {
        require(Role[msg.sender] == _MINTER_ROLE, "LiveMint | onlyMinter | Caller Is Not Approved BRT Minter");
        _;
    }

    /**
     * @dev Access Modifier That Allows Only Authorized Contracts
     */
    modifier onlyAdmin()
    {
        require(Role[msg.sender] == _AUTHORIZED || msg.sender == owner(), "LiveMint | onlyAdmin | Caller Is Not Approved Admin");
        _;
    }

    /**
     * @dev onlyMarketplace Access Modifier
     */
    modifier onlyMarketplace
    {
        require(_MARKETPLACE == msg.sender, "LiveMint | onlyMarketplace | Caller Is Not Marketplace");
        _;
    }
}

/**
 * @dev Interface For Delegate.cash
 */
interface IDelegationRegistry
{
    /**
     * @dev Checks If A Vault Has Delegated To The Delegate
     */
    function checkDelegateForAll(address delegate, address delegator) external view returns (bool);
}