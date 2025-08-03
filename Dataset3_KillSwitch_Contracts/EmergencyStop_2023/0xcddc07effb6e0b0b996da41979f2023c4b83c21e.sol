// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Metadata.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * - The `operator` cannot be the caller.
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
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
/**
 _____
/  __ \
| /  \/ ___  _ ____   _____ _ __ __ _  ___ _ __   ___ ___
| |    / _ \| '_ \ \ / / _ \ '__/ _` |/ _ \ '_ \ / __/ _ \
| \__/\ (_) | | | \ V /  __/ | | (_| |  __/ | | | (_|  __/
 \____/\___/|_| |_|\_/ \___|_|  \__, |\___|_| |_|\___\___|
                                 __/ |
                                |___/
 */
pragma solidity ^0.8.0;

import "../interfaces/ICvgControlTower.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract VeSDTAirdrop is Ownable {
    enum State {
        NOT_ACTIVE,
        ACTIVE
    }
    uint256 public constant CLAIM = 1000 * 10 ** 18;
    uint256 public constant MAX_LOCK = 96;
    ICvgControlTower public immutable cvgControlTower;
    ICvg public immutable cvg;
    ILockingPositionService public immutable lockingPositionService;
    address public immutable treasuryAirdrop;

    State public state;
    bytes32 public merkleRoot;
    uint256 public cvgClaimable = 300_000 * 10 ** 18;
    mapping(address => bool) public isClaimed;

    constructor(ICvgControlTower _cvgControlTower) {
        cvgControlTower = _cvgControlTower;
        ILockingPositionService _lockingPositionService = _cvgControlTower.lockingPositionService();
        ICvg _cvg = _cvgControlTower.cvgToken();
        address _treasuryAirdrop = _cvgControlTower.treasuryAirdrop();
        address _treasuryDao = _cvgControlTower.treasuryDao();
        require(address(_lockingPositionService) != address(0), "LOCKING_ZERO");
        require(address(_cvg) != address(0), "CVG_ZERO");
        require(_treasuryAirdrop != address(0), "TREASURY_AIRDROP_ZERO");
        require(_treasuryDao != address(0), "TREASURY_DAO_ZERO");
        lockingPositionService = _lockingPositionService;
        cvg = _cvg;
        treasuryAirdrop = _treasuryAirdrop;

        cvg.approve(address(_lockingPositionService), cvgClaimable);
        _transferOwnership(_treasuryDao);
    }

    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                            EXTERNALS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */

    function claim(bytes32[] calldata _merkleProof) external {
        require(state == State.ACTIVE, "CLAIM_NOT_ACTIVE");
        require(merkleVerify(_merkleProof), "INVALID_PROOF");
        require(!isClaimed[msg.sender], "ALREADY_CLAIMED");
        require(cvgClaimable >= CLAIM, "CLAIM_OVER");
        cvgClaimable -= CLAIM;
        isClaimed[msg.sender] = true;
        cvg.transferFrom(treasuryAirdrop, address(this), CLAIM);
        lockingPositionService.mintPosition(
            uint24(MAX_LOCK - cvgControlTower.cvgCycle()),
            uint96(CLAIM),
            0,
            msg.sender,
            true
        );
    }

    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                            SETTERS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */
    function startAirdrop(bytes32 _merkleRoot) external onlyOwner {
        require(cvg.allowance(treasuryAirdrop, address(this)) >= cvgClaimable, "ALLOWANCE_INSUFFICIENT");
        merkleRoot = _merkleRoot;
        state = State.ACTIVE;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                            INTERNALS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */
    function merkleVerify(bytes32[] calldata _merkleProof) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBondStruct.sol";

interface IBondCalculator {
    function computeRoi(
        uint256 durationFromStart,
        uint256 totalDuration,
        IBondStruct.BondFunction composedFunction,
        uint256 totalTokenOut,
        uint256 amountTokenSold,
        uint256 gamma,
        uint256 scale,
        uint256 minRoi,
        uint256 maxRoi
    ) external pure returns (uint256 bondRoi);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICvgControlTower.sol";
import "./IBondStruct.sol";
import "./ICvgOracle.sol";

interface IBondDepository {
    // Deposit Principle token in Treasury through Bond contract
    function deposit(uint256 tokenId, uint256 amount, address receiver) external;

    function depositToLock(uint256 amount, address receiver) external returns (uint256 cvgToMint);

    function positionInfos(uint256 tokenId) external view returns (IBondStruct.BondPending memory);

    function getTokenVestingInfo(uint256 tokenId) external view returns (IBondStruct.TokenVestingInfo memory);

    function bondParams() external view returns (IBondStruct.BondParams memory);

    function pendingPayoutFor(uint256 tokenId) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBondLogo {
    struct LogoInfos {
        uint256 tokenId;
        uint256 termTimestamp;
        uint256 pending;
        uint256 cvgClaimable;
        uint256 unlockingTimestamp;
    }
    struct LogoInfosFull {
        uint256 tokenId;
        uint256 termTimestamp;
        uint256 pending;
        uint256 cvgClaimable;
        uint256 unlockingTimestamp;
        uint256 year;
        uint256 month;
        uint256 day;
        bool isLocked;
        uint256 hoursLock;
        uint256 cvgPrice;
    }

    function _tokenURI(LogoInfos memory logoInfos) external pure returns (string memory output);

    
    function getLogoInfo(uint256 tokenId) external view returns (IBondLogo.LogoInfosFull memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBondStruct.sol";
import "./IBondLogo.sol";
import "./IBondDepository.sol";

interface IBondPositionManager {
    function bondDepository() external view returns (IBondDepository);

    function getTokenIdsForWallet(address _wallet) external view returns (uint256[] memory);

    function bondPerTokenId(uint256 tokenId) external view returns (uint256);

    // Deposit Principle token in Treasury through Bond contract
    function mintOrCheck(uint256 bondId, uint256 tokenId, address receiver) external returns (uint256);

    function burn(uint256 tokenId) external;

    function unlockingTimestampPerToken(uint256 tokenId) external view returns (uint256);

    function logoInfo(uint256 tokenId) external view returns (IBondLogo.LogoInfos memory);

    function checkTokenRedeem(uint256[] calldata tokenIds, address receiver) external view;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBondStruct {
    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                        STORED STRUCTS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */
    struct BondParams {
        /**
         * @dev Type of function used to compute the actual ROI of a bond.
         *      - 0 is SquareRoot
         *      - 1 is Ln
         *      - 2 is Square
         *      - 3 is Linear
         */
        BondFunction composedFunction;
        /// @dev Address of the underlaying token of the bond.
        address token;
        /**
         * @dev Gamma is used in the BondCalculator.It's the value dividing the ratio between the amount already sold and the theorical amount sold.
         *      250_000 correspond to 0.25 (25%).
         */
        uint40 gamma;
        /// @dev Total duration of the bond, uint40 is enough for a timestamp.
        uint40 bondDuration;
        /// @dev Determine if a Bond is paused. Can't deposit on a bond paused.
        bool isPaused;
        /**
         * @dev Scale is used in the BondCalculator. When a scale is A, the ROI vary by incremental of A.
         *      If scale is 5_000 correspond to 0.5%, the ROI will vary from the maxROI to minROI by increment of 0.5%.
         */
        uint32 scale;
        /**
         * @dev Minimum ROI of the bond. Discount cannot be less than the minROI.
         *      If minRoi is 100_000, it represents 10%.
         */

        uint24 minRoi;
        /**
         * @dev Maximum ROI of the bond. Discount cannot be more than the maxROI.
         *      If maxRoi is 150_000, it represents 15%.
         */
        uint24 maxRoi;
        /**
         * @dev Percentage maximum of the cvgToSell that an user can buy in one deposit
         *      If percentageOneTx is 200, it represents 20% of cvgToSell.
         */
        uint24 percentageOneTx;
        /// @dev Duration of the vesting in second.
        uint32 vestingTerm;
        /**
         * @dev Maximum amount that can be bought through this bond.
         *      uint80 represents 1.2M tokens in ethers. It means that we are never going to open a bond with more than 1.2M tokens.
         */
        uint80 cvgToSell; // Limit of Max CVG to sell => 1.2M CVG max approx
        /// @dev Timestamp in second of the beginning of the bond. Has to be in the future.
        uint40 startBondTimestamp;
    }
    struct BondPending {
        /// @dev Timestamp in second of the last interaction with this position.
        uint64 lastTimestamp;
        /// @dev Time in seconds lefting before the position is fully unvested
        uint64 vestingTimeLeft;
        /**
         * @dev Total amount of CVG still vested in the position.
         *      uint128 is way enough because it's an amount in CVG that have a max supply of 150M tokens.
         */
        uint128 leftClaimable;
    }

    enum BondFunction {
        SQRT,
        LN,
        POWER_2,
        LINEAR
    }

    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                        VIEW STRUCTS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */
    struct BondTokenView {
        uint128 lastTimestamp;
        uint128 vestingEnd;
        uint256 claimableCvg;
        uint256 leftClaimable;
    }

    struct BondView {
        uint256 actualRoi;
        uint256 cvgAlreadySold;
        uint256 usdExecutionPrice;
        uint256 usdLimitPrice;
        uint256 assetBondPrice;
        uint256 usdBondPrice;
        bool isOracleValid;
        BondParams bondParameters;
        ERC20View token;
    }
    struct ERC20View {
        string token;
        address tokenAddress;
        uint256 decimals;
    }
    struct TokenVestingInfo {
        uint256 term;
        uint256 claimable;
        uint256 pending;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICommonStruct {
    struct TokenAmount {
        IERC20 token;
        uint256 amount;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

interface ICvg is IERC20Metadata {
    function MAX_AIRDROP() external view returns (uint256);

    function MAX_BOND() external view returns (uint256);

    function MAX_STAKING() external view returns (uint256);

    function MAX_VESTING() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burn(uint256 amount) external;

    function cvgControlTower() external view returns (address);

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function mintBond(address account, uint256 amount) external;

    function mintStaking(address account, uint256 amount) external;

    function mintedBond() external view returns (uint256);

    function mintedStaking() external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./IERC20Mintable.sol";
import "./ICvg.sol";
import "./IBondDepository.sol";
import "./IBondCalculator.sol";
import "./IBondStruct.sol";
import "./ICvgOracle.sol";
import "./IVotingPowerEscrow.sol";
import "./ICvgRewards.sol";
import "./ILockingPositionManager.sol";
import "./ILockingPositionDelegate.sol";
import "./IGaugeController.sol";
import "./IYsDistributor.sol";
import "./IBondPositionManager.sol";
import "./ISdtStakingPositionManager.sol";
import "./IBondLogo.sol";
import "./ILockingLogo.sol";
import "./ILockingPositionService.sol";
import "./IVestingCvg.sol";
import "./ISdtBuffer.sol";
import "./ISdtBlackHole.sol";
import "./ISdtStakingPositionService.sol";
import "./ISdtFeeCollector.sol";
import "./ISdtBuffer.sol";
import "./ISdtRewardDistributor.sol";

interface ICvgControlTower {
    function cvgToken() external view returns (ICvg);

    function cvgOracle() external view returns (ICvgOracle);

    function bondCalculator() external view returns (IBondCalculator);

    function gaugeController() external view returns (IGaugeController);

    function cvgCycle() external view returns (uint128);

    function votingPowerEscrow() external view returns (IVotingPowerEscrow);

    function treasuryDao() external view returns (address);

    function treasuryPod() external view returns (address);

    function treasuryPdd() external view returns (address);

    function treasuryAirdrop() external view returns (address);

    function treasuryTeam() external view returns (address);

    function cvgRewards() external view returns (ICvgRewards);

    function lockingPositionManager() external view returns (ILockingPositionManager);

    function lockingPositionService() external view returns (ILockingPositionService);

    function lockingPositionDelegate() external view returns (ILockingPositionDelegate);

    function isStakingContract(address contractAddress) external view returns (bool);

    function ysDistributor() external view returns (IYsDistributor);

    function isBond(address account) external view returns (bool);

    function bondPositionManager() external view returns (IBondPositionManager);

    function sdtStakingPositionManager() external view returns (ISdtStakingPositionManager);

    function sdtStakingLogo() external view returns (ISdtStakingLogo);

    function bondLogo() external view returns (IBondLogo);

    function lockingLogo() external view returns (ILockingLogo);

    function isSdtStaking(address contractAddress) external view returns (bool);

    function vestingCvg() external view returns (IVestingCvg);

    function sdt() external view returns (IERC20);

    function cvgSDT() external view returns (IERC20Mintable);

    function cvgSdtStaking() external view returns (ISdtStakingPositionService);

    function cvgSdtBuffer() external view returns (ISdtBuffer);

    function veSdtMultisig() external view returns (address);

    function cloneFactory() external view returns (address);

    function sdtUtilities() external view returns (address);

    function insertNewSdtStaking(address _sdtStakingClone) external;

    function allBaseSdAssetStaking(uint256 _index) external view returns (address);

    function allBaseSdAssetBuffer(uint256 _index) external view returns (address);

    function sdtFeeCollector() external view returns (ISdtFeeCollector);

    function updateCvgCycle() external;

    function sdtBlackHole() external view returns (ISdtBlackHole);

    function sdtRewardDistributor() external view returns (address);

    function poolCvgSdt() external view returns (address);

    function bondDepository() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./IOracleStruct.sol";

interface ICvgOracle {
    function getPriceVerified(address erc20) external view returns (uint256);

    function getPriceUnverified(address erc20) external view returns (uint256);

    function getAndVerifyTwoPrices(address tokenIn, address tokenOut) external view returns (uint256, uint256);

    function getTwoPricesAndIsValid(
        address tokenIn,
        address tokenOut
    ) external view returns (uint256, uint256, bool, uint256, uint256, bool);

    function getPriceAndValidationData(
        address erc20Address
    ) external view returns (uint256, uint256, bool, bool, bool, bool);

    function getPoolAddressByToken(address erc20) external view returns (address);

    function poolTypePerErc20(address) external view returns (IOracleStruct.PoolType);

    //OWNER

    function setPoolTypeForToken(address _erc20Address, IOracleStruct.PoolType _poolType) external;

    function setStableParams(address _erc20Address, IOracleStruct.StableParams calldata _stableParams) external;

    function setCurveDuoParams(address _erc20Address, IOracleStruct.CurveDuoParams calldata _curveDuoParams) external;

    function setCurveTriParams(address _erc20Address, IOracleStruct.CurveTriParams calldata _curveTriParams) external;

    function setUniV3Params(address _erc20Address, IOracleStruct.UniV3Params calldata _uniV3Params) external;

    function setUniV2Params(address _erc20Address, IOracleStruct.UniV2Params calldata _uniV2Params) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICvgRewards {
    function cvgCycleRewards() external view returns (uint256);

    function addGauge(address gaugeAddress) external;

    function removeGauge(address gaugeAddress) external;

    function getCycleLocking(uint256 timestamp) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

/**
 * @dev Interface for the optional mint function from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Mintable is IERC20Metadata {
    /**
     * @dev Mint `amount` of token to `account`
     */
    function mint(address account, uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGaugeController {
    struct WeightType {
        uint256 weight;
        uint256 type_weight;
        int128 gauge_type;
    }

    function add_type(string memory typeName, uint256 weight) external;

    function add_gauge(address addr, int128 gaugeType, uint256 weight) external;

    function get_gauge_weight(address gaugeAddress) external view returns (uint256);

    function get_gauge_weights(address[] memory gaugeAddresses) external view returns (uint256[] memory, uint256);

    function get_gauge_weights_and_types(address[] memory gaugeAddresses) external view returns (WeightType[] memory);

    function get_total_weight() external view returns (uint256);

    function n_gauges() external view returns (uint128);

    function gauges(uint256 index) external view returns (address);

    function gauge_types(address gaugeAddress) external view returns (int128);

    function get_type_weight(int128 typeId) external view returns (uint256);

    function gauge_relative_weight(address addr, uint256 time) external view returns (uint256);

    function set_lock(bool isLock) external;

    function gauge_relative_weight_write(address gaugeAddress) external;

    function gauge_relative_weight_writes(uint256 from, uint256 length) external;

    function simple_vote(uint256 tokenId, address gaugeAddress, uint256 tokenWeight) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILockingLogo {
    struct LogoInfos {
        uint256 tokenId;
        uint256 cvgLocked;
        uint256 lockEnd;
        uint256 ysPercentage;
        uint256 mgCvg;
        uint256 unlockingTimestamp;
    }
    struct GaugePosition {
        uint256 ysWidth; // width of the YS gauge part
        uint256 veWidth; // width of the VE gauge part
    }

    struct LogoInfosFull {
        uint256 tokenId;
        uint256 cvgLocked;
        uint256 lockEnd;
        uint256 ysPercentage;
        uint256 mgCvg;
        uint256 unlockingTimestamp;
        uint256 cvgLockedInUsd;
        uint256 ysCvgActual;
        uint256 ysCvgNext;
        uint256 veCvg;
        GaugePosition gaugePosition;
        uint256 claimableInUsd;
        bool isLocked;
        uint256 hoursLock;
    }

    function _tokenURI(LogoInfos memory logoInfos) external pure returns (string memory output);

    function getLogoInfo(uint256 tokenId) external view returns (ILockingLogo.LogoInfosFull memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILockingPositionDelegate {
    struct OwnedAndDelegated {
        uint256[] owneds;
        uint256[] mgDelegateds;
        uint256[] veDelegateds;
    }

    function delegatedYsCvg(uint256 tokenId) external view returns (address);

    function getMgDelegateeInfoPerTokenAndAddress(
        uint256 _tokenId,
        address _to
    ) external view returns (uint256, uint256, uint256);

    function getIndexForVeDelegatee(address _delegatee, uint256 _tokenId) external view returns (uint256);

    function getIndexForMgCvgDelegatee(address _delegatee, uint256 _tokenId) external view returns (uint256);

    function delegateVeCvg(uint256 _tokenId, address _to) external;

    function delegateYsCvg(uint256 _tokenId, address _to, bool _status) external;

    function delegateMgCvg(uint256 _tokenId, address _to, uint256 _percentage) external;

    function delegatedVeCvg(uint256 tokenId) external view returns (address);

    function getVeCvgDelegatees(address account) external view returns (uint256[] memory);

    function getMgCvgDelegatees(address account) external view returns (uint256[] memory);

    function getTokenOwnedAndDelegated(address _addr) external view returns (OwnedAndDelegated[] memory);

    function getTokenMgOwnedAndDelegated(address _addr) external view returns (uint256[] memory, uint256[] memory);

    function getTokenVeOwnedAndDelegated(address _addr) external view returns (uint256[] memory, uint256[] memory);

    function addTokenAtMint(uint256 _tokenId, address minter) external;

    function cleanDelegateesOnTransfer(uint256 _tokenId) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ILockingLogo.sol";

interface ILockingPositionManager {
    function ownerOf(uint256 tokenId) external view returns (address);

    function mint(address account) external returns (uint256);

    function burn(uint256 tokenId, address caller) external;

    function logoInfo(uint256 tokenId) external view returns (ILockingLogo.LogoInfos memory);

    function checkYsClaim(uint256 tokenId, address caller) external view;

    function checkOwnership(uint256 _tokenId, address operator) external view;

    function checkOwnerships(uint256[] memory _tokenIds, address operator) external view;

    function checkFullCompliance(uint256 tokenId, address operator) external view;

    function getTokenIdsForWallet(address _wallet) external view returns (uint256[] memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILockingPositionService {
    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                        STORED STRUCTS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */
    struct LockingPosition {
        /// @dev Starting cycle of a LockingPosition. Maximum value of uint24 is 16M, so 16M weeks is way enough.
        uint24 startCycle;
        /// @dev End cycle of a LockingPosition. Maximum value of uint24 is 16M, so 16M weeks is way enough.
        uint24 lastEndCycle;
        /** @dev Percentage of the token allocated to ysCvg. Amount dedicated to vote is so equal to 100 - ysPercentage.
         *  A position with ysPercentage as 60 will allocate 60% of his locking to YsCvg and 40% to veCvg and mgCvg.
         */
        uint8 ysPercentage;
        /** @dev Total Cvg amount locked in the position.
         *  Max supply of CVG is 150M, it so fits into an uint104 (20 000 billions approx).
         */
        uint104 totalCvgLocked;
        /**  @dev MgCvgAmount held by the position.
         *   Max supply of mgCVG is 150M, it so fits into an uint96 (20 billions approx).
         */
        uint96 mgCvgAmount;
    }

    struct TrackingBalance {
        /** @dev Amount of ysCvg to add to the total supply when the corresponding cvgCycle is triggered.
         *  Max supply of ysCVG is 150M, it so fits into an uint128.
         */
        uint128 ysToAdd;
        /** @dev Amount of ysCvg to remove from the total supply when the corresponding cvgCycle is triggered.
         *  Max supply of ysCVG is 150M, it so fits into an uint128.
         */
        uint128 ysToSub;
    }

    struct Checkpoints {
        uint24 cycleId;
        uint232 ysBalance;
    }

    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                        VIEW STRUCTS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */

    struct TokenView {
        uint256 tokenId;
        uint128 startCycle;
        uint128 endCycle;
        uint256 cvgLocked;
        uint256 ysActual;
        uint256 ysTotal;
        uint256 veCvgActual;
        uint256 mgCvg;
        uint256 ysPercentage;
    }

    struct LockingInfo {
        uint256 tokenId;
        uint256 cvgLocked;
        uint256 lockEnd;
        uint256 ysPercentage;
        uint256 mgCvg;
    }

    function TDE_DURATION() external view returns (uint256);

    function MAX_LOCK() external view returns (uint24);

    function updateYsTotalSupply() external;

    function ysTotalSupplyHistory(uint256) external view returns (uint256);

    function ysShareOnTokenAtTde(uint256, uint256) external view returns (uint256);

    function veCvgVotingPowerPerAddress(address _user) external view returns (uint256);

    function mintPosition(
        uint24 lockDuration,
        uint128 amount,
        uint8 ysPercentage,
        address receiver,
        bool isAddToManagedTokens
    ) external;

    function increaseLockAmount(uint256 tokenId, uint128 amount, address operator) external;

    function increaseLockTime(uint256 tokenId, uint256 durationAdd) external;

    function increaseLockTimeAndAmount(uint256 tokenId, uint24 durationAdd, uint128 amount, address operator) external;

    function totalSupplyYsCvgHistories(uint256 cycleClaimed) external view returns (uint256);

    function balanceOfYsCvgAt(uint256 tokenId, uint256 cycle) external view returns (uint256);

    function lockingPositions(uint256 tokenId) external view returns (LockingPosition memory);

    function unlockingTimestampPerToken(uint256 tokenId) external view returns (uint256);

    function lockingInfo(uint256 tokenId) external view returns (LockingInfo memory);

    function isContractLocker(address contractAddress) external view returns (bool);

    function getTotalSupplyAtAndBalanceOfYs(uint256 tokenId, uint256 cycleId) external view returns (uint256, uint256);

    function getTotalSupplyHistoryAndBalanceOfYs(
        uint256 tokenId,
        uint256 cycleId
    ) external view returns (uint256, uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IOracleStruct {
    enum PoolType {
        NOT_INIT,
        STABLE,
        CURVE_DUO,
        CURVE_TRI,
        UNI_V3,
        UNI_V2
    }

    struct StableParams {
        AggregatorV3Interface aggregatorOracle;
        uint40 deltaLimitOracle; // 5 % => 500 & 100 % => 10 000
        uint56 maxLastUpdate; // Buffer time before a not updated price is considered as stale
        uint128 minPrice;
        uint128 maxPrice;
    }

    struct CurveDuoParams {
        bool isReversed;
        bool isEthPriceRelated;
        address poolAddress;
        uint40 deltaLimitOracle; // 5 % => 500 & 100 % => 10 000
        uint40 maxLastUpdate; // Buffer time before a not updated price is considered as stale
        uint128 minPrice;
        uint128 maxPrice;
        address[] stablesToCheck;
    }

    struct CurveTriParams {
        bool isReversed;
        bool isEthPriceRelated;
        address poolAddress;
        uint40 deltaLimitOracle;
        uint40 maxLastUpdate;
        uint8 k;
        uint120 minPrice;
        uint128 maxPrice;
        address[] stablesToCheck;
    }

    struct UniV2Params {
        bool isReversed;
        bool isEthPriceRelated;
        address poolAddress;
        uint80 deltaLimitOracle;
        uint96 maxLastUpdate;
        AggregatorV3Interface aggregatorOracle;
        uint128 minPrice;
        uint128 maxPrice;
        address[] stablesToCheck;
    }

    struct UniV3Params {
        bool isReversed;
        bool isEthPriceRelated;
        address poolAddress;
        uint80 deltaLimitOracle;
        uint80 maxLastUpdate;
        uint16 twap;
        AggregatorV3Interface aggregatorOracle;
        uint128 minPrice;
        uint128 maxPrice;
        address[] stablesToCheck;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IPresaleCvgSeed is IERC721Enumerable {
    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                            ENUMS & STRUCTS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */
    enum SaleState {
        NOT_ACTIVE,
        PRESEED,
        SEED,
        OVER
    }

    struct PresaleInfo {
        uint256 vestingType; // Define the presaler type
        uint256 cvgAmount; // Total CVG amount claimable for the nft owner
    }

    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                            SETTERS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */
    function setSaleState(SaleState _saleState) external;

    function grantPreseed(address _wallet, uint256 _amount) external;

    function grantSeed(address _wallet, uint256 _amount) external;

    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                            EXTERNALS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */
    function investMint(bool _isDai) external;

    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                            GETTERS
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */
    function presaleInfoTokenId(uint256 _tokenId) external view returns (PresaleInfo memory);

    function saleState() external view returns (SaleState);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view override returns (uint256);

    function getTokenIdAndType(
        address _wallet,
        uint256 _index
    ) external view returns (uint256 tokenId, uint256 typeVesting);

    function getTokenIdsForWallet(address _wallet) external view returns (uint256[] memory);

    function getTotalCvg() external view returns (uint256);

    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                        WITHDRAW OWNER
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-= */
    function withdrawFunds() external;

    function withdrawToken(address _token) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./ICvgControlTower.sol";
import "./ISdtBuffer.sol";

interface IOperator {
    function token() external view returns (IERC20Metadata);

    function deposit(uint256 amount, bool isLock, bool isStake, address receiver) external;
}

interface ISdAsset is IERC20Metadata {
    function sdAssetGauge() external view returns (IERC20);

    function initialize(
        ICvgControlTower _cvgControlTower,
        IERC20 _sdAssetGauge,
        string memory setName,
        string memory setSymbol
    ) external;

    function setSdAssetBuffer(address _sdAssetBuffer) external;

    function mint(address to, uint256 amount) external;

    function operator() external view returns (IOperator);
}

interface ISdAssetGauge is IERC20Metadata {
    function deposit(uint256 value, address addr) external;

    function deposit(uint256 value, address addr, bool claimRewards) external;

    function staking_token() external view returns (IERC20);

    function reward_count() external view returns (uint256);

    function reward_tokens(uint256 i) external view returns (IERC20);

    function claim_rewards(address account) external;

    function set_rewards_receiver(address account) external;

    function claimable_reward(address account, address token) external view returns (uint256);

    function set_reward_distributor(address rewardToken, address distributor) external;

    function deposit_reward_token(address rewardToken, uint256 amount) external;

    function admin() external view returns (address);

    function working_balances(address) external view returns (uint256);

    function working_supply() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ICommonStruct.sol";

interface ISdtBlackHole {
    function withdraw(uint256 amount, address receiver) external;

    function setGaugeReceiver(address gaugeAddress, address bufferReceiver) external;

    function getBribeTokensForBuffer(address buffer) external view returns (IERC20[] memory);

    function pullSdStakingBribes(
        address _processor,
        uint256 _processorRewardsPercentage
    ) external returns (ICommonStruct.TokenAmount[] memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ICvgControlTower.sol";

import "./ISdAssets.sol";

import "./ICommonStruct.sol";

interface ISdtBuffer {
    function initialize(
        ICvgControlTower _cvgControlTower,
        address _sdAssetStaking,
        ISdAssetGauge _sdGaugeAsset,
        IERC20 _sdt
    ) external;

    function pullRewards(address _processor) external returns (ICommonStruct.TokenAmount[] memory);

    function processorRewardsPercentage() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISdtFeeCollector {
    function rootFees() external returns (uint256);

    function withdrawToken(IERC20[] calldata _tokens) external;

    function withdrawSdt() external;

    function feesRepartition(uint256 index) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ICommonStruct.sol";

interface ISdtRewardDistributor {
    function claimCvgSdtSimple(
        address receiver,
        uint256 cvgAmount,
        ICommonStruct.TokenAmount[] memory sdtRewards,
        uint256 minCvgSdtAmountOut,
        bool isConvert
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICommonStruct.sol";

interface ISdtStakingLogo {
    struct LogoInfos {
        uint256 tokenId;
        string symbol;
        uint256 pending;
        uint256 totalStaked;
        uint256 cvgClaimable;
        ICommonStruct.TokenAmount[] sdtClaimable;
        uint256 unlockingTimestamp;
    }

    struct LogoInfosFull {
        uint256 tokenId;
        string symbol;
        uint256 pending;
        uint256 totalStaked;
        uint256 cvgClaimable;
        ICommonStruct.TokenAmount[] sdtClaimable;
        uint256 unlockingTimestamp;
        uint256 claimableInUsd;
        bool erroneousAmount;
        bool isLocked;
        uint256 hoursLock;
    }

    function _tokenURI(LogoInfos memory logoInfos) external pure returns (string memory output);

    function getLogoInfo(uint256 tokenId) external view returns (ISdtStakingLogo.LogoInfosFull memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISdtStakingLogo.sol";
import "./ISdtStakingPositionService.sol";

interface ISdtStakingPositionManager {
    struct ClaimSdtStakingContract {
        ISdtStakingPositionService stakingContract;
        uint256[] tokenIds;
    }

    function mint(address account) external;

    function burn(uint256 tokenId) external;

    function nextId() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function checkMultipleClaimCompliance(ClaimSdtStakingContract[] calldata, address account) external view;

    function checkTokenFullCompliance(uint256 tokenId, address account) external view;

    function checkIncreaseDepositCompliance(uint256 tokenId, address account) external view;

    function stakingPerTokenId(uint256 tokenId) external view returns (address);

    function unlockingTimestampPerToken(uint256 tokenId) external view returns (uint256);

    function logoInfo(uint256 tokenId) external view returns (ISdtStakingLogo.LogoInfos memory);

    function getTokenIdsForWallet(address _wallet) external view returns (uint256[] memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./ICommonStruct.sol";
import "./ISdtBuffer.sol";

interface ISdtStakingPositionService {
    struct CycleInfo {
        uint256 cvgRewardsAmount;
        uint256 totalStaked;
        bool isSdtProcessed;
    }

    struct TokenInfo {
        uint256 amountStaked;
        uint256 pendingStaked;
    }
    struct CycleInfoMultiple {
        uint256 totalStaked;
        ICommonStruct.TokenAmount[] sdtClaimable;
    }
    struct StakingInfo {
        uint256 tokenId;
        string symbol;
        uint256 pending;
        uint256 totalStaked;
        uint256 cvgClaimable;
        ICommonStruct.TokenAmount[] sdtClaimable;
    }

    function setBuffer(address _buffer) external;

    function symbol() external view returns (string memory);

    function stakingCycle() external view returns (uint256);

    function cycleInfo(uint256 cycleId) external view returns (CycleInfo memory);

    function stakingAsset() external view returns (ISdAssetGauge);

    function buffer() external view returns (ISdtBuffer);

    function tokenTotalStaked(uint256 _tokenId) external view returns (uint256 amount);

    function stakedAmountEligibleAtCycle(
        uint256 cvgCycle,
        uint256 tokenId,
        uint256 actualCycle
    ) external view returns (uint256);

    function tokenInfoByCycle(uint256 cycleId, uint256 tokenId) external view returns (TokenInfo memory);

    function stakingInfo(uint256 tokenId) external view returns (StakingInfo memory);

    function getProcessedSdtRewards(uint256 _cycleId) external view returns (ICommonStruct.TokenAmount[] memory);

    function deposit(uint256 tokenId, uint256 amount, address operator) external;

    function claimCvgSdtMultiple(
        uint256 _tokenId,
        address operator
    ) external returns (uint256, ICommonStruct.TokenAmount[] memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IPresaleCvgSeed.sol";

interface IVestingCvg {
    /// @dev Struct Info about VestingSchedules
    struct VestingSchedule {
        uint16 daysBeforeCliff;
        uint16 daysAfterCliff;
        uint24 dropCliff;
        uint256 totalAmount;
        uint256 totalReleased;
    }

    struct InfoVestingTokenId {
        uint256 amountReleasable;
        uint256 totalCvg;
        uint256 amountRedeemed;
    }

    enum VestingType {
        SEED,
        WL,
        IBO,
        TEAM,
        DAO
    }

    function vestingSchedules(VestingType vestingType) external view returns (VestingSchedule memory);

    function getInfoVestingTokenId(
        uint256 _tokenId,
        VestingType vestingType
    ) external view returns (InfoVestingTokenId memory);

    function whitelistedTeam() external view returns (address);

    function presaleSeed() external view returns (IPresaleCvgSeed);

    function MAX_SUPPLY_TEAM() external view returns (uint256);

    function startTimestamp() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVotingPowerEscrow {
    function create_lock(uint256 tokenId, uint256 value, uint256 unlockTime) external;

    function increase_amount(uint256 tokenId, uint256 value) external;

    function increase_unlock_time(uint256 tokenId, uint256 unlockTime) external;

    function increase_unlock_time_and_amount(uint256 tokenId, uint256 unlockTime, uint256 amount) external;

    function withdraw(uint256 tokenId) external;

    function total_supply() external returns (uint256);

    function balanceOf(uint256 tokenId) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICommonStruct.sol";

interface IYsDistributor {
    struct TokenAmount {
        IERC20 token;
        uint96 amount;
    }

    struct Claim {
        uint256 tdeCycle;
        bool isClaimed;
        TokenAmount[] tokenAmounts;
    }

    function getPositionRewardsForTdes(
        uint256[] calldata _tdeIds,
        uint256 actualCycle,
        uint256 _tokenId
    ) external view returns (Claim[] memory);
}