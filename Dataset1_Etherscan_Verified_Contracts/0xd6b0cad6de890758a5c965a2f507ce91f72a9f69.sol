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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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
pragma solidity ^0.8.13;

import { IERC20 } from "openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "openzeppelin/contracts/access/Ownable.sol";
import { MerkleProof } from "openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { INexusGaming } from "./interface/INexusGaming.sol";

/**
 * <<< nexus-gaming.io >>>
 *
 * @title   Nexus Gaming Preseller
 * @notice  Prepurchase and claim Nexus Gaming NFTs
 * @dev     The preseller must be authorized to mint the NFTs
 * @author  Tuxedo Development
 * @custom:developer BowTiedPickle
 * @custom:developer Lumoswiz
 * @custom:developer BowTiedOriole
 */
contract Preseller is Ownable {
    // ----- Structs -----

    /**
     * @notice  The mint info for a given mint id
     * @dev     Price array must be of length 5
     * @param   startTime       The start time of the presale
     * @param   endTime         The end time of the presale
     * @param   claimTime       The time when the presale NFTs can be claimed
     * @param   merkleRoot      The merkle root of the presale allocations
     * @param   maxPurchased    The max amount of NFTs that can be purchased during this mint id
     * @param   totalPurchased  The total amount of NFTs that have been purchased during this mint id
     * @param   prices          The price of each level in units of USDC
     */
    struct MintInfo {
        uint48 startTime;
        uint48 endTime;
        uint48 claimTime;
        bytes32 merkleRoot;
        uint256 maxPurchased;
        uint256 totalPurchased;
        uint256[] prices;
    }

    // ----- Storage -----

    /// @notice The Nexus Gaming NFT contract
    INexusGaming public immutable nft;

    /// @notice The next mint id
    uint256 public nextMintId;

    /// @notice The mint info for each mint id
    mapping(uint256 => MintInfo) public mintInfos;

    /// @notice The number of Nexus Gaming NFTs of each tier purchased by each user for each mint id
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public numberPurchased;

    /// @notice The USDC token contract
    IERC20 public immutable usdc;

    uint256 internal constant TRANCHE_COUNT = 5;

    // ----- Constructor -----

    /**
     * @notice  Construct a new Preseller contract
     * @param   _owner  The owner of the contract
     * @param   _nft    The Nexus Gaming NFT contract
     * @param   _usdc   The USDC token contract
     */
    constructor(address _owner, address _nft, address _usdc) {
        if (_owner == address(0) || _nft == address(0) || _usdc == address(0)) revert Preseller__ZeroAddressInvalid();

        _transferOwnership(_owner);

        nft = INexusGaming(_nft);
        usdc = IERC20(_usdc);
    }

    // ----- User Actions -----

    /**
     * @notice  Purchase Nexus Gaming NFTs during the presale
     * @dev     The amounts and allocations must be in the same order, and of length 5
     * @param   mintId      The mint id to purchase from
     * @param   amounts     The number of Nexus Gaming NFTs to purchase at each price level
     * @param   allocations The maximum number of Nexus Gaming NFTs that can be purchased at each price level
     * @param   proof       The merkle proof of the user's allocation
     */
    function purchasePresale(
        uint256 mintId,
        uint256[] calldata amounts,
        uint256[] calldata allocations,
        bytes32[] calldata proof
    ) external {
        MintInfo storage info = mintInfos[mintId];

        if (block.timestamp < info.startTime || block.timestamp >= info.endTime)
            revert Preseller__NotTimeForPresalePurchases();

        if (amounts.length != allocations.length) revert Preseller__ArrayLengthMismatch();
        if (amounts.length != TRANCHE_COUNT) revert Preseller__ArrayLengthInvalid();

        if (!_verifyMerkleProof(allocations, info.merkleRoot, proof)) revert Preseller__ProofInvalid();

        uint256 cost;
        uint256 amount;
        uint256[] memory cachedPrices = info.prices;
        for (uint256 i; i < TRANCHE_COUNT; ) {
            if (amounts[i] + numberPurchased[mintId][msg.sender][i] > allocations[i])
                revert Preseller__ExceedsMaxAllocation(); // The correctness of the sum of the allocations is left implicit in the whitelist

            cost += amounts[i] * cachedPrices[i];
            amount += amounts[i];
            numberPurchased[mintId][msg.sender][i] += amounts[i];

            unchecked {
                ++i;
            }
        }

        if (info.totalPurchased + amount > info.maxPurchased) revert Preseller__ExceedsMaxSupply();
        if (amount == 0) revert Preseller__ZeroAmount();

        info.totalPurchased += amount;

        if (!usdc.transferFrom(msg.sender, address(this), cost)) {
            revert Preseller__USDCTransferFailed();
        }

        emit PresalePurchase(msg.sender, amount);
    }

    /**
     * @notice  Claim Nexus Gaming NFTs after the presale
     * @param   user    The user to claim for
     * @param   mintId  The mint id to claim from
     */
    function claimPresale(address user, uint256 mintId) external {
        _claimPresale(user, mintId);
    }

    /**
     * @notice  Claim Nexus Gaming NFTs after the presale for multiple users and/or mint ids
     * @param   users   The users to claim for
     * @param   mintIds The mint ids to claim from
     */
    function claimPresaleBatch(address[] calldata users, uint256[] calldata mintIds) external {
        if (users.length != mintIds.length) revert Preseller__ArrayLengthMismatch();
        for (uint256 i; i < users.length; ) {
            _claimPresale(users[i], mintIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    // ----- Internal -----

    function _claimPresale(address user, uint256 mintId) internal {
        uint256 amount;
        MintInfo memory info = mintInfos[mintId];

        if (block.timestamp < info.claimTime) revert Preseller__NotTimeForClaim();

        for (uint256 i; i < TRANCHE_COUNT; ) {
            amount += numberPurchased[mintId][user][i];
            numberPurchased[mintId][user][i] = 0;
            unchecked {
                ++i;
            }
        }
        if (amount == 0) revert Preseller__ZeroAmount();

        nft.mint(user, amount);
    }

    // ----- Admin -----

    /**
     * @notice Setup a mint phase
     * @param   _startTime      The start time of the mint phase
     * @param   _endTime        The end time of the mint phase
     * @param   _claimTime      The time when the mint phase can be claimed
     * @param   _merkleRoot     The merkle root of the mint phase
     * @param   _maxPurchased   The maximum number of Nexus Gaming NFTs that can be purchased at each price level
     * @param   _prices         The price of each Nexus Gaming NFT at each price level
     */
    function setupMintPhase(
        uint48 _startTime,
        uint48 _endTime,
        uint48 _claimTime,
        bytes32 _merkleRoot,
        uint256 _maxPurchased,
        uint256[] calldata _prices
    ) external onlyOwner returns (uint256) {
        if (_startTime >= _endTime || _startTime <= block.timestamp || _claimTime <= _endTime)
            revert Preseller__MintTimesInvalid();

        if (_merkleRoot == bytes32(0)) revert Preseller__ZeroRootInvalid();
        if (_prices.length != TRANCHE_COUNT) revert Preseller__ArrayLengthInvalid();

        uint256 mintId = nextMintId;

        mintInfos[mintId] = MintInfo({
            startTime: _startTime,
            endTime: _endTime,
            claimTime: _claimTime,
            merkleRoot: _merkleRoot,
            maxPurchased: _maxPurchased,
            totalPurchased: 0,
            prices: _prices
        });

        unchecked {
            ++nextMintId;
        }

        emit NewMintPhaseCreated(mintId);
        return mintId;
    }

    /**
     * @notice  Update the price of each Nexus Gaming NFT at each price level for a mint id
     * @param   mintId  The mint id to update
     * @param   _prices The new price of each Nexus Gaming NFT at each price level
     */
    function updatePrices(uint256 mintId, uint256[] calldata _prices) external onlyOwner {
        if (mintId >= nextMintId) revert Preseller__MintIdInvalid();
        if (_prices.length != TRANCHE_COUNT) revert Preseller__ArrayLengthInvalid();

        mintInfos[mintId].prices = _prices;
        emit PricesUpdated(mintId);
    }

    /**
     * @notice  Update the start time for a mint id
     * @param   mintId      The mint id to update
     * @param   _startTime  The new start time in unix epoch seconds
     */
    function updateMintStartTime(uint256 mintId, uint48 _startTime) external onlyOwner {
        if (mintId >= nextMintId) revert Preseller__MintIdInvalid();
        if (_startTime >= mintInfos[mintId].endTime || _startTime <= block.timestamp) {
            revert Preseller__MintTimesInvalid();
        }

        emit StartTimeUpdated(mintId, _startTime, mintInfos[mintId].startTime);
        mintInfos[mintId].startTime = _startTime;
    }

    /**
     * @notice  Update the end time for a mint id
     * @param   mintId      The mint id to update
     * @param   _endTime    The new end time in unix epoch seconds
     */
    function updateMintEndTime(uint256 mintId, uint48 _endTime) external onlyOwner {
        if (mintId >= nextMintId) revert Preseller__MintIdInvalid();
        if (mintInfos[mintId].startTime >= _endTime || mintInfos[mintId].claimTime <= _endTime) {
            revert Preseller__MintTimesInvalid();
        }

        emit EndTimeUpdated(mintId, _endTime, mintInfos[mintId].endTime);
        mintInfos[mintId].endTime = _endTime;
    }

    /**
     * @notice  Update the claim time for a mint id
     * @param   mintId      The mint id to update
     * @param   _claimTime  The new claim time in unix epoch seconds
     */
    function updateMintClaimTime(uint256 mintId, uint48 _claimTime) external onlyOwner {
        if (mintId >= nextMintId) revert Preseller__MintIdInvalid();
        if (_claimTime <= mintInfos[mintId].endTime) {
            revert Preseller__MintTimesInvalid();
        }

        emit ClaimTimeUpdated(mintId, _claimTime, mintInfos[mintId].claimTime);
        mintInfos[mintId].claimTime = _claimTime;
    }

    /**
     * @notice  Update the merkle root for a mint id
     * @param   mintId      The mint id to update
     * @param   _merkleRoot The new merkle root
     */
    function updateMintMerkleRoot(uint256 mintId, bytes32 _merkleRoot) external onlyOwner {
        if (mintId >= nextMintId) revert Preseller__MintIdInvalid();

        emit MerkleRootUpdated(mintId, _merkleRoot, mintInfos[mintId].merkleRoot);
        mintInfos[mintId].merkleRoot = _merkleRoot;
    }

    /**
     * @notice  Update the max purchased for a mint id
     * @param   mintId          The mint id to update
     * @param   _maxPurchased   The new max purchased amount
     */
    function updateMintMaxPurchased(uint256 mintId, uint256 _maxPurchased) external onlyOwner {
        if (mintId >= nextMintId) revert Preseller__MintIdInvalid();
        if (_maxPurchased < mintInfos[mintId].totalPurchased) revert Preseller__MaxPurchasedInvalid();

        emit MaxPurchasedUpdated(mintId, _maxPurchased, mintInfos[mintId].maxPurchased);
        mintInfos[mintId].maxPurchased = _maxPurchased;
    }

    /**
     * @notice Withdraw the USDC balance from the contract
     */
    function withdraw() external onlyOwner {
        uint256 balance = usdc.balanceOf(address(this));
        usdc.transfer(owner(), balance);
        emit Withdrawal(balance);
    }

    // ----- Verification -----

    function _verifyMerkleProof(
        uint256[] calldata _allocations,
        bytes32 _merkleRoot,
        bytes32[] calldata _proof
    ) private view returns (bool) {
        // Use of abi.encode here instead of abi.encodePacked due to: https://github.com/ethereum/solidity/issues/11593
        bytes32 leaf = keccak256(abi.encode(msg.sender, _allocations));
        return MerkleProof.verifyCalldata(_proof, _merkleRoot, leaf);
    }

    // ----- View -----

    /**
     * @notice  Get a mint's information by ID
     */
    function getMintInfo(uint256 mintId) external view returns (MintInfo memory) {
        return mintInfos[mintId];
    }

    /**
     * @notice  Check if a mint id is active
     * @param   mintId  The mint id to check
     * @return  True if the mint id is active, false otherwise
     */
    function isMintActive(uint256 mintId) external view returns (bool) {
        MintInfo storage info = mintInfos[mintId];
        return (block.timestamp >= info.startTime) && (block.timestamp < info.endTime);
    }

    /**
     * @notice  Returns user purchases by tier for given mintId
     * @dev     Will only be accurate prior to user claiming their NFTs
     * @param   mintId  Mint id
     * @param   user    User address
     * @return  Array of user purchases by tier
     */
    function getUserPurchasesPerMintId(uint256 mintId, address user) external view returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](5);
        for (uint256 i; i < TRANCHE_COUNT; ) {
            amounts[i] = numberPurchased[mintId][user][i];
            unchecked {
                ++i;
            }
        }

        return amounts;
    }

    // ----- Events -----

    event PricesUpdated(uint256 indexed mintId);

    event StartTimeUpdated(uint256 indexed mintId, uint48 startTime, uint48 oldStartTime);

    event EndTimeUpdated(uint256 indexed mintId, uint48 endTime, uint48 oldEndTime);

    event ClaimTimeUpdated(uint256 indexed mintId, uint48 claimTime, uint48 oldClaimTime);

    event MerkleRootUpdated(uint256 indexed mintId, bytes32 merkleRoot, bytes32 oldMerkleRoot);

    event MaxPurchasedUpdated(uint256 indexed mintId, uint256 supply, uint256 oldSupply);

    event NewMintPhaseCreated(uint256 indexed mintId);

    event Withdrawal(uint256 balance);

    event PresalePurchase(address indexed purchaser, uint256 indexed amount);

    // ----- Errors -----

    error Preseller__ZeroAddressInvalid();

    error Preseller__ZeroRootInvalid();

    error Preseller__ZeroAmount();

    error Preseller__ArrayLengthMismatch();

    error Preseller__ArrayLengthInvalid();

    error Preseller__ProofInvalid();

    error Preseller__MintTimesInvalid();

    error Preseller__MintIdInvalid();

    error Preseller__MaxPurchasedInvalid();

    error Preseller__USDCTransferFailed();

    error Preseller__ExceedsMaxSupply();

    error Preseller__ExceedsMaxAllocation();

    error Preseller__NotTimeForClaim();

    error Preseller__NotTimeForPresalePurchases();
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC721 } from "openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INexusGaming is IERC721 {
    function mint(address to, uint256 amount) external;
}