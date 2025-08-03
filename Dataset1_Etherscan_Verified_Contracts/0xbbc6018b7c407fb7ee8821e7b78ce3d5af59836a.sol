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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/BitMaps.sol)
pragma solidity ^0.8.20;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, provided the keys are sequential.
 * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 *
 * BitMaps pack 256 booleans across each bit of a single 256-bit slot of `uint256` type.
 * Hence booleans corresponding to 256 _sequential_ indices would only consume a single slot,
 * unlike the regular `bool` which would consume an entire slot for a single value.
 *
 * This results in gas savings in two ways:
 *
 * - Setting a zero value to non-zero only once every 256 times
 * - Accessing the same warm slot for every 256 _sequential_ indices
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 bucket => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(BitMap storage bitmap, uint256 index, bool value) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import './IDelegateRegistry.sol';
import './IDelegationRegistry.sol';

contract GrapePreSale is Ownable, Pausable {
    /**
     * @dev Public immutable state
     */
    IERC721 public immutable grapeNFT;
    uint256 public immutable minimumSpendAmount; // must be in WEI. set by constructor only
    bytes32 public immutable referralCodeMerkleRoot;
    uint256 public immutable referralCapPerBuyer; // must be in WEI. set by constructor only
    uint256 public immutable capPerNFT; // must be in WEI. set by constructor only
    uint256 public immutable nftStartDate;
    uint256 public immutable referralStartDate;
    uint256 public immutable endDate;
    uint256 public immutable nftSaleCap;
    address payable public immutable receiverWallet;
    IDelegateRegistry public immutable delegateRegistryV2 =
        IDelegateRegistry(0x00000000000000447e69651d841bD8D104Bed493);
    IDelegationRegistry public immutable delegateRegistryV1 =
        IDelegationRegistry(0x00000000000076A84feF008CDAbe6409d2FE638B);

    /**
     * @dev Public mutable state
     */
    uint256 public nftSoldSupply = 0; // managed internally
    mapping(uint256 tokenId => uint256 amount) public nftPurchases; // managed internally
    mapping(address buyer => uint256 amount) public referralPurchases; // managed internally

    /**
     * @notice Emitted when a purchase is made with an NFT
     */
    event PurchaseWithNFT(address indexed buyer, uint256 amount);

    /**
     * @notice Emitted when a purchase is made with a referral code
     */
    event PurchaseWithReferralCode(address indexed buyer, uint256 amount);

    /**
     * @dev Errors
     */
    error BelowMinimumSpend();
    error Closed();
    error AmountExceedsSupply();
    error NotTokenOwner(uint256 tokenId);
    error InvalidPaymentAmount();
    error InvalidReferralCode();

    /**
     * @notice Creates a new instance of the GrapePreSale contract.
     * @param grapeNFTAddress_ The address of the ERC721 token (Grape NFT) involved in the pre-sale.
     * @param initialOwner_ The initial owner of the contract, typically the deployer or the main administrative account.
     * @param receiverWallet_ The wallet address where funds (ETH) collected from the pre-sale will be sent.
     * @param referralCodeMerkleRoot_ The root of the Merkle tree used for validating referral codes.
     * @param config_ Array containing the following config in order:
     *        referralCapPerBuyer: The maximum amount of WEI a buyer can spend using referral codes.
     *        capPerNFT: The maximum amount of WEI that can be spent per NFT in the pre-sale.
     *        nftStartDate: The start date of the NFT pre-sale, represented as a Unix timestamp.
     *        referralStartDate: The start date of the referral pre-sale, represented as a Unix timestamp.
     *        endDate: The end date of the pre-sale, represented as a Unix timestamp.
     *        minimumSpendAmount: The minimum amount of WEI that can be spent in the pre-sale.
     *        nftSaleCap: The maximum amount of WEI that can be spend for NFT purchases.
     */
    constructor(
        address grapeNFTAddress_,
        address initialOwner_,
        address payable receiverWallet_,
        bytes32 referralCodeMerkleRoot_,
        uint256[7] memory config_
    ) Ownable(initialOwner_) {
        grapeNFT = IERC721(grapeNFTAddress_);
        receiverWallet = receiverWallet_;
        referralCodeMerkleRoot = referralCodeMerkleRoot_;
        referralCapPerBuyer = config_[0];
        capPerNFT = config_[1];
        nftStartDate = config_[2];
        referralStartDate = config_[3];
        endDate = config_[4];
        minimumSpendAmount = config_[5];
        nftSaleCap = config_[6];
    }

    /**
     * @dev Modifiers
     */

    /**
     * @notice Require the amount to spend to be greater than the minimum spend value
     */
    modifier checkMinimumSpend() {
        if (msg.value < minimumSpendAmount) revert BelowMinimumSpend();
        _;
    }

    /**
     * @dev Public functions
     */

    /**
     * @notice Allows a buyer to purchase with a list of NFTs
     * @dev This function calculates the total amount of Ether sent and ensures it does not exceed the NFT Sale Cap.
     *      It checks each NFT provided, verifies ownership, and calculates the amount included for each NFT.
     *      It reverts if the NFT is not owned by the sender or their delegate, if the NFT Sale Cap is reached,
     *      or if the payment amount is not valid.
     * @param tokenIds_ An array of token IDs which the buyer uses to make the purchase.
     */
    function buyWithNFTs(
        uint256[] calldata tokenIds_
    ) external payable whenNotPaused checkMinimumSpend {
        // check if the nft sale is closed
        if (block.timestamp < nftStartDate || block.timestamp > endDate) {
            revert Closed();
        }

        // calculate new nft sold supply
        uint256 _newNftSoldSupply = nftSoldSupply + msg.value;

        // verify nft sold supply is not greater than the nft sale cap
        if (_newNftSoldSupply > nftSaleCap) {
            revert AmountExceedsSupply();
        }

        // update nft sold supply
        nftSoldSupply = _newNftSoldSupply;

        // track amount included in NFT
        uint256 _amountIncluded = 0;

        // check each provided NFTs
        uint256 _i;
        do {
            uint256 _tokenId = tokenIds_[_i];

            // verify tokenId is owned by sender
            _verifyTokenOwner(_tokenId);

            // grab current NFT purchase amount
            uint256 _nftPurchaseAmount = nftPurchases[_tokenId];

            // calculate how much amount can be used for this NFT
            uint256 _maxAmount = Math.min(
                capPerNFT - _nftPurchaseAmount, // maximum the cap per NFT minus the amount previously purchase with this NFT
                msg.value - _amountIncluded // otherwise the difference between the total amount and the amount already included in other NFT
            );

            // update amount used for this NFT
            nftPurchases[_tokenId] = _nftPurchaseAmount + _maxAmount;

            // increase amount included
            _amountIncluded += _maxAmount;
        } while (++_i < tokenIds_.length && _amountIncluded < msg.value);

        // check amount is fully included across the NFTs
        if (_amountIncluded != msg.value) {
            revert InvalidPaymentAmount();
        }

        // transfer ETH to receiver wallet
        receiverWallet.transfer(_amountIncluded);

        // emit event
        emit PurchaseWithNFT(msg.sender, _amountIncluded);
    }

    /**
     * @notice Allows a buyer to purchase using a referral code.
     * @dev This function allows users to buy with a referral code and ensures purchases per wallet do not exceed the referralCapPerBuyer
     *      It validates the referral code and calculates the total sold per wallet.
     *      It transfers the ETH to the receiver wallet.
     * @param referralCode_ An array of bytes32 representing the referral code used for the purchase.
     */
    function buyWithReferralCode(
        bytes32[] calldata referralCode_
    ) external payable whenNotPaused checkMinimumSpend {
        // check if the referral sale is closed
        if (block.timestamp < referralStartDate || block.timestamp > endDate) {
            revert Closed();
        }

        // verify referral code is valid
        if (!verifyReferralCode(msg.sender, referralCode_)) {
            revert InvalidReferralCode();
        }

        // calculate new referral purchase for this sender
        uint256 _newReferralPurchase = referralPurchases[msg.sender] +
            msg.value;

        // verify amount is not greater than the referral cap per buyer
        if (_newReferralPurchase > referralCapPerBuyer) {
            revert InvalidPaymentAmount();
        }

        // update referral amount bought by sender
        referralPurchases[msg.sender] = _newReferralPurchase;

        // transfer ETH to receiver wallet
        receiverWallet.transfer(msg.value);

        // emit event
        emit PurchaseWithReferralCode(msg.sender, msg.value);
    }

    /**
     * @notice Verifies if a given referral code is valid for a specific wallet address.
     * @dev Uses a Merkle proof to verify if the provided referral code is part of the Merkle tree
     *      represented by the referralCodeMerkleRoot. This is used to validate the authenticity of the referral codes.
     * @param wallet_ The address of the wallet for which the referral code is being verified.
     * @param referralCode_ Merkle Proof to check against.
     * @return bool True if the referral code is valid for the given wallet address, false otherwise.
     */
    function verifyReferralCode(
        address wallet_,
        bytes32[] calldata referralCode_
    ) public view returns (bool) {
        return
            MerkleProof.verify(
                referralCode_,
                referralCodeMerkleRoot,
                keccak256(bytes.concat(keccak256(abi.encode(wallet_))))
            );
    }

    /**
     * @dev Only owner functions
     */

    /**
     * @notice Pause the purchase functions, only owner can call this function
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the purchase functions, only owner can call this function
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Internal functions
     */

    /**
     * @notice Verifies if the sender is the owner of a given token or a valid delegate.
     * @dev This internal function checks if the sender is either the owner of the specified token or an authorized delegate.
     *      It supports two versions of delegate checks: a newer version (`dcV2`) and an older one (`dc`).
     *      The function reverts with `NotTokenOwner` if the sender is neither the owner nor a valid delegate.
     * @param tokenId_ The token ID to verify ownership or delegation for.
     */
    function _verifyTokenOwner(uint256 tokenId_) internal view {
        address _tokenOwner = grapeNFT.ownerOf(tokenId_);

        // check sender is owner
        if (_tokenOwner == msg.sender) return;

        // check with delegate registry v2
        if (
            delegateRegistryV2.checkDelegateForERC721(
                msg.sender,
                _tokenOwner,
                address(grapeNFT),
                tokenId_,
                ''
            )
        ) return;

        // check with delegate registry v1
        if (
            delegateRegistryV1.checkDelegateForToken(
                msg.sender,
                _tokenOwner,
                address(grapeNFT),
                tokenId_
            )
        ) return;

        // revert if not owner or delegate
        revert NotTokenOwner(tokenId_);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@openzeppelin/contracts/utils/structs/BitMaps.sol';
import './GrapePreSale.sol';

contract GrapePreSaleRefund is Ownable, Pausable {
    /// @dev Library for managing uint256 to bool mapping in a compact and efficient way
    using BitMaps for BitMaps.BitMap;

    /// @notice Merkle root of wallets that DID NOT win in the raffle
    bytes32 public refundMerkleRoot;

    /// @notice The GrapePreSale contract
    GrapePreSale public immutable grapePreSale;

    /// @dev Wallets that already claimed their refund
    BitMaps.BitMap private _refundedWallets;

    /// @notice Emitted when a refund is claimed
    event RefundClaimed(address indexed wallet, uint256 amount);

    /// @notice Returned when the wallet is already refunded
    error AlreadyRefunded();

    /// @notice Returned when the wallet did not participate in the pre-sale
    error NothingToRefund();

    /// @notice Returned when the provided merkle proof is invalid or the merkle root is not set
    error InvalidMerkleProof();

    /// @notice Returned when the transfer of the refund failed, mostly due because this contract doesn't have enough ETH
    error RefundFailed();

    /// @notice Returned when the refund Merkle root is already set
    error RefundMerkleRootAlreadySet();

    /// @notice Returned when the withdraw all ETH fails
    error WithdrawAllFailed();

    /// @notice Initializes the contract with a given owner.
    /// @dev The constructor sets the initial owner, then puts the contract into a paused state.
    ///      It inherits from the Ownable contract using the provided initial owner.
    /// @param initialOwner_ The address of the initial owner of the contract.
    /// @param grapePreSale_ The address of the pre-sale contract.
    constructor(
        address initialOwner_,
        address grapePreSale_
    ) Ownable(initialOwner_) {
        grapePreSale = GrapePreSale(grapePreSale_);

        // default to paused
        _pause();
    }

    /// @notice This function allows users to claim a refund based on a valid Merkle proof.
    /// @dev The function first verifies the Merkle proof, checks if the wallet has already collected the refund,
    ///      and then processes the refund to prevent reentrancy attacks. It interacts with the `GrapePreSale` contract.
    /// @param merkleProof_ An array of bytes32, the Merkle Proof
    function claimRefund(
        bytes32[] calldata merkleProof_
    ) external whenNotPaused {
        // verify referral code is valid
        if (!verifyMerkleProof(msg.sender, merkleProof_))
            revert InvalidMerkleProof();

        // check if the wallet has already collected
        if (_refundedWallets.get(uint160(msg.sender))) revert AlreadyRefunded();

        // log as claimed before paying to prevent reentrancy attacks
        _refundedWallets.set(uint160(msg.sender));

        // get amount to be refunded
        uint256 refundAmount = grapePreSale.referralPurchases(msg.sender);

        // check if the wallet participated in the pre-sale
        if (refundAmount == 0) revert NothingToRefund();

        // emit refund claimed event
        emit RefundClaimed(msg.sender, refundAmount);

        // transfer refund
        (bool sent, ) = payable(msg.sender).call{value: refundAmount}('');

        // check transfer was successful
        if (!sent) revert RefundFailed();
    }

    /// @notice Verifies if a given referral code is valid for a specific wallet address.
    /// @dev Uses a Merkle proof to verify if the provided referral code is part of the Merkle tree
    ///      represented by the referralCodeMerkleRoot. This is used to validate the authenticity of the referral codes.
    /// @param wallet_ The address of the wallet for which the referral code is being verified.
    /// @param merkleProof_ Merkle Proof to check against.
    /// @return bool True if the referral code is valid for the given wallet address, false otherwise.
    function verifyMerkleProof(
        address wallet_,
        bytes32[] calldata merkleProof_
    ) public view returns (bool) {
        // check refundMerkleRoot is set
        if (refundMerkleRoot == bytes32(0)) return false;

        return
            MerkleProof.verify(
                merkleProof_,
                refundMerkleRoot,
                keccak256(bytes.concat(keccak256(abi.encode(wallet_))))
            );
    }

    /// @notice Pause the purchase functions, only owner can call this function
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause the purchase functions, only owner can call this function
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Withdraw all ETH from the contract. Only owner can execute this function.
    /// @param to_ The address to send the ETH to.
    function withdrawAll(address payable to_) external onlyOwner {
        (bool sent, ) = to_.call{value: address(this).balance}('');
        if (!sent) revert WithdrawAllFailed();
    }

    /// @notice Set the refund Merkle root. Only owner can execute this function.
    /// @param refundMerkleRoot_ The Merkle root used for verifying refund wallets.
    function setRefundMerkleRoot(bytes32 refundMerkleRoot_) external onlyOwner {
        // prevent setting the Merkle root if already set
        if (refundMerkleRoot != bytes32(0)) revert RefundMerkleRootAlreadySet();

        refundMerkleRoot = refundMerkleRoot_;
    }

    /// @notice Function to allow contract to receive ETH
    receive() external payable {}
}
// SPDX-License-Identifier: CC0-1.0
pragma solidity >=0.8.13;

/**
 * @title IDelegateRegistry
 * @custom:version 2.0
 * @custom:author foobar (0xfoobar)
 * @notice A standalone immutable registry storing delegated permissions from one address to another
 */
interface IDelegateRegistry {
    /// @notice Delegation type, NONE is used when a delegation does not exist or is revoked
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        ERC721,
        ERC20,
        ERC1155
    }

    /// @notice Struct for returning delegations
    struct Delegation {
        DelegationType type_;
        address to;
        address from;
        bytes32 rights;
        address contract_;
        uint256 tokenId;
        uint256 amount;
    }

    /// @notice Emitted when an address delegates or revokes rights for their entire wallet
    event DelegateAll(address indexed from, address indexed to, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for a contract address
    event DelegateContract(address indexed from, address indexed to, address indexed contract_, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for an ERC721 tokenId
    event DelegateERC721(address indexed from, address indexed to, address indexed contract_, uint256 tokenId, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for an amount of ERC20 tokens
    event DelegateERC20(address indexed from, address indexed to, address indexed contract_, bytes32 rights, uint256 amount);

    /// @notice Emitted when an address delegates or revokes rights for an amount of an ERC1155 tokenId
    event DelegateERC1155(address indexed from, address indexed to, address indexed contract_, uint256 tokenId, bytes32 rights, uint256 amount);

    /// @notice Thrown if multicall calldata is malformed
    error MulticallFailed();

    /**
     * -----------  WRITE -----------
     */

    /**
     * @notice Call multiple functions in the current contract and return the data from all of them if they all succeed
     * @param data The encoded function data for each of the calls to make to this contract
     * @return results The results from each of the calls passed in via data
     */
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for all contracts
     * @param to The address to act as delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateAll(address to, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific contract
     * @param to The address to act as delegate
     * @param contract_ The contract whose rights are being delegated
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateContract(address to, address contract_, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific ERC721 token
     * @param to The address to act as delegate
     * @param contract_ The contract whose rights are being delegated
     * @param tokenId The token id to delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC721(address to, address contract_, uint256 tokenId, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific amount of ERC20 tokens
     * @dev The actual amount is not encoded in the hash, just the existence of a amount (since it is an upper bound)
     * @param to The address to act as delegate
     * @param contract_ The address for the fungible token contract
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param amount The amount to delegate, > 0 delegates and 0 revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC20(address to, address contract_, bytes32 rights, uint256 amount) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific amount of ERC1155 tokens
     * @dev The actual amount is not encoded in the hash, just the existence of a amount (since it is an upper bound)
     * @param to The address to act as delegate
     * @param contract_ The address of the contract that holds the token
     * @param tokenId The token id to delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param amount The amount of that token id to delegate, > 0 delegates and 0 revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC1155(address to, address contract_, uint256 tokenId, bytes32 rights, uint256 amount) external payable returns (bytes32 delegationHash);

    /**
     * ----------- CHECKS -----------
     */

    /**
     * @notice Check if `to` is a delegate of `from` for the entire wallet
     * @param to The potential delegate address
     * @param from The potential address who delegated rights
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on the from's behalf
     */
    function checkDelegateForAll(address to, address from, bytes32 rights) external view returns (bool);

    /**
     * @notice Check if `to` is a delegate of `from` for the specified `contract_` or the entire wallet
     * @param to The delegated address to check
     * @param contract_ The specific contract address being checked
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on from's behalf for entire wallet or that specific contract
     */
    function checkDelegateForContract(address to, address from, address contract_, bytes32 rights) external view returns (bool);

    /**
     * @notice Check if `to` is a delegate of `from` for the specific `contract` and `tokenId`, the entire `contract_`, or the entire wallet
     * @param to The delegated address to check
     * @param contract_ The specific contract address being checked
     * @param tokenId The token id for the token to delegating
     * @param from The wallet that issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on from's behalf for entire wallet, that contract, or that specific tokenId
     */
    function checkDelegateForERC721(address to, address from, address contract_, uint256 tokenId, bytes32 rights) external view returns (bool);

    /**
     * @notice Returns the amount of ERC20 tokens the delegate is granted rights to act on the behalf of
     * @param to The delegated address to check
     * @param contract_ The address of the token contract
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return balance The delegated balance, which will be 0 if the delegation does not exist
     */
    function checkDelegateForERC20(address to, address from, address contract_, bytes32 rights) external view returns (uint256);

    /**
     * @notice Returns the amount of a ERC1155 tokens the delegate is granted rights to act on the behalf of
     * @param to The delegated address to check
     * @param contract_ The address of the token contract
     * @param tokenId The token id to check the delegated amount of
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return balance The delegated balance, which will be 0 if the delegation does not exist
     */
    function checkDelegateForERC1155(address to, address from, address contract_, uint256 tokenId, bytes32 rights) external view returns (uint256);

    /**
     * ----------- ENUMERATIONS -----------
     */

    /**
     * @notice Returns all enabled delegations a given delegate has received
     * @param to The address to retrieve delegations for
     * @return delegations Array of Delegation structs
     */
    function getIncomingDelegations(address to) external view returns (Delegation[] memory delegations);

    /**
     * @notice Returns all enabled delegations an address has given out
     * @param from The address to retrieve delegations for
     * @return delegations Array of Delegation structs
     */
    function getOutgoingDelegations(address from) external view returns (Delegation[] memory delegations);

    /**
     * @notice Returns all hashes associated with enabled delegations an address has received
     * @param to The address to retrieve incoming delegation hashes for
     * @return delegationHashes Array of delegation hashes
     */
    function getIncomingDelegationHashes(address to) external view returns (bytes32[] memory delegationHashes);

    /**
     * @notice Returns all hashes associated with enabled delegations an address has given out
     * @param from The address to retrieve outgoing delegation hashes for
     * @return delegationHashes Array of delegation hashes
     */
    function getOutgoingDelegationHashes(address from) external view returns (bytes32[] memory delegationHashes);

    /**
     * @notice Returns the delegations for a given array of delegation hashes
     * @param delegationHashes is an array of hashes that correspond to delegations
     * @return delegations Array of Delegation structs, return empty structs for nonexistent or revoked delegations
     */
    function getDelegationsFromHashes(bytes32[] calldata delegationHashes) external view returns (Delegation[] memory delegations);

    /**
     * ----------- STORAGE ACCESS -----------
     */

    /**
     * @notice Allows external contracts to read arbitrary storage slots
     */
    function readSlot(bytes32 location) external view returns (bytes32);

    /**
     * @notice Allows external contracts to read an arbitrary array of storage slots
     */
    function readSlots(bytes32[] calldata locations) external view returns (bytes32[] memory);
}
// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.17;

/**
 * @title An immutable registry contract to be deployed as a standalone primitive
 * @dev See EIP-5639, new project launches can read previous cold wallet -> hot wallet delegations
 * from here and integrate those permissions into their flow
 */
interface IDelegationRegistry {
    /// @notice Delegation type
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        TOKEN
    }

    /// @notice Info about a single delegation, used for onchain enumeration
    struct DelegationInfo {
        DelegationType type_;
        address vault;
        address delegate;
        address contract_;
        uint256 tokenId;
    }

    /// @notice Info about a single contract-level delegation
    struct ContractDelegation {
        address contract_;
        address delegate;
    }

    /// @notice Info about a single token-level delegation
    struct TokenDelegation {
        address contract_;
        uint256 tokenId;
        address delegate;
    }

    /// @notice Emitted when a user delegates their entire wallet
    event DelegateForAll(address vault, address delegate, bool value);

    /// @notice Emitted when a user delegates a specific contract
    event DelegateForContract(address vault, address delegate, address contract_, bool value);

    /// @notice Emitted when a user delegates a specific token
    event DelegateForToken(address vault, address delegate, address contract_, uint256 tokenId, bool value);

    /// @notice Emitted when a user revokes all delegations
    event RevokeAllDelegates(address vault);

    /// @notice Emitted when a user revoes all delegations for a given delegate
    event RevokeDelegate(address vault, address delegate);

    /**
     * -----------  WRITE -----------
     */

    /**
     * @notice Allow the delegate to act on your behalf for all contracts
     * @param delegate The hotwallet to act on your behalf
     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking
     */
    function delegateForAll(address delegate, bool value) external;

    /**
     * @notice Allow the delegate to act on your behalf for a specific contract
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking
     */
    function delegateForContract(address delegate, address contract_, bool value) external;

    /**
     * @notice Allow the delegate to act on your behalf for a specific token
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param tokenId The token id for the token you're delegating
     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking
     */
    function delegateForToken(address delegate, address contract_, uint256 tokenId, bool value) external;

    /**
     * @notice Revoke all delegates
     */
    function revokeAllDelegates() external;

    /**
     * @notice Revoke a specific delegate for all their permissions
     * @param delegate The hotwallet to revoke
     */
    function revokeDelegate(address delegate) external;

    /**
     * @notice Remove yourself as a delegate for a specific vault
     * @param vault The vault which delegated to the msg.sender, and should be removed
     */
    function revokeSelf(address vault) external;

    /**
     * -----------  READ -----------
     */

    /**
     * @notice Returns all active delegations a given delegate is able to claim on behalf of
     * @param delegate The delegate that you would like to retrieve delegations for
     * @return info Array of DelegationInfo structs
     */
    function getDelegationsByDelegate(address delegate) external view returns (DelegationInfo[] memory);

    /**
     * @notice Returns an array of wallet-level delegates for a given vault
     * @param vault The cold wallet who issued the delegation
     * @return addresses Array of wallet-level delegates for a given vault
     */
    function getDelegatesForAll(address vault) external view returns (address[] memory);

    /**
     * @notice Returns an array of contract-level delegates for a given vault and contract
     * @param vault The cold wallet who issued the delegation
     * @param contract_ The address for the contract you're delegating
     * @return addresses Array of contract-level delegates for a given vault and contract
     */
    function getDelegatesForContract(address vault, address contract_) external view returns (address[] memory);

    /**
     * @notice Returns an array of contract-level delegates for a given vault's token
     * @param vault The cold wallet who issued the delegation
     * @param contract_ The address for the contract holding the token
     * @param tokenId The token id for the token you're delegating
     * @return addresses Array of contract-level delegates for a given vault's token
     */
    function getDelegatesForToken(address vault, address contract_, uint256 tokenId)
        external
        view
        returns (address[] memory);

    /**
     * @notice Returns all contract-level delegations for a given vault
     * @param vault The cold wallet who issued the delegations
     * @return delegations Array of ContractDelegation structs
     */
    function getContractLevelDelegations(address vault)
        external
        view
        returns (ContractDelegation[] memory delegations);

    /**
     * @notice Returns all token-level delegations for a given vault
     * @param vault The cold wallet who issued the delegations
     * @return delegations Array of TokenDelegation structs
     */
    function getTokenLevelDelegations(address vault) external view returns (TokenDelegation[] memory delegations);

    /**
     * @notice Returns true if the address is delegated to act on the entire vault
     * @param delegate The hotwallet to act on your behalf
     * @param vault The cold wallet who issued the delegation
     */
    function checkDelegateForAll(address delegate, address vault) external view returns (bool);

    /**
     * @notice Returns true if the address is delegated to act on your behalf for a token contract or an entire vault
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param vault The cold wallet who issued the delegation
     */
    function checkDelegateForContract(address delegate, address vault, address contract_)
        external
        view
        returns (bool);

    /**
     * @notice Returns true if the address is delegated to act on your behalf for a specific token, the token's contract or an entire vault
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param tokenId The token id for the token you're delegating
     * @param vault The cold wallet who issued the delegation
     */
    function checkDelegateForToken(address delegate, address vault, address contract_, uint256 tokenId)
        external
        view
        returns (bool);
}