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

// Project A-Heart: https://a-he.art

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./interfaces/IAHeart.sol";
import "./interfaces/IAHeartSales.sol";

uint256 constant PRE_SALE_INDEX = 0;
uint256 constant PARTNER_SALE_INDEX = 1;
uint256 constant PUBLIC_SALE_INDEX = 2;
uint256 constant FREE_MINT_INDEX = 3;

contract AHeartSales is IAHeartSales, Ownable {
  uint256 public constant RESERVED_TOKENS = 150;

  uint256 public constant MAX_SUPPLY = 2690;

  uint256 public constant MAX_AMOUNT_PER_TX = 69;

  uint256 public totalSold;

  uint256 public totalReservedTokensMinted;

  uint256 public totalMinted;

  IAHeart public token;

  address public manager;

  bool public salesClosed;

  SaleInfo private _initialPreSaleInfo =
    SaleInfo({
      index: PRE_SALE_INDEX,
      // JST 2023-04-07T14:00:00+09:00
      // EDT 2023-04-07T01:00:00-04:00
      startTimestamp: 1680843600,
      // JST 2023-04-08T14:00:00+09:00
      // EDT 2023-04-08T01:00:00-04:00
      endTimestamp: 1680930000,
      price: 0.0369 ether,
      merkleRoot: 0xb194d4bcba328090b835a00ab692741e19d7d4abebafc6ae4f80f4ad09dee7a7
    });

  SaleInfo private _initialPartnerSaleInfo =
    SaleInfo({
      index: PARTNER_SALE_INDEX,
      // JST 2023-04-08T14:00:00+09:00
      // EDT 2023-04-08T01:00:00-04:00
      startTimestamp: 1680930000,
      // JST 2023-04-09T14:00:00+09:00
      // EDT 2023-04-09T01:00:00-04:00
      endTimestamp: 1681016400,
      price: 0.0369 ether,
      merkleRoot: 0x7413090089cb488ccb99f8b4518e4e18fa2de08ebe23d83f47ec3dabdf58d188
    });

  SaleInfo private _initialPublicSaleInfo =
    SaleInfo({
      index: PUBLIC_SALE_INDEX,
      // JST 2023-04-09T14:00:00+09:00
      // EDT 2023-04-09T01:00:00-04:00
      startTimestamp: 1681016400,
      // JST 2023-04-10T14:00:00+09:00
      // EDT 2023-04-10T01:00:00-04:00
      endTimestamp: 1681102800,
      price: 0.0369 ether,
      merkleRoot: 0x0
    });

  SaleInfo private _initialFreeMintInfo =
    SaleInfo({
      index: FREE_MINT_INDEX,
      // JST 2023-04-07T14:00:00+09:00
      // EDT 2023-04-07T01:00:00-04:00
      startTimestamp: 1680843600,
      // JST 2023-04-10T14:00:00+09:00
      // EDT 2023-04-10T01:00:00-04:00
      endTimestamp: 1681102800,
      price: 0,
      merkleRoot: 0x82a314f5575ff7d4c7256b6b05b27606482ab7f1b4cec44a94d5ffe69d41e4f6
    });

  mapping(uint256 => SaleInfo) private _saleInfo;

  mapping(uint256 => mapping(address => uint256)) private _mintedCount;

  constructor(address tokenAddress, address managerAddress) {
    require(tokenAddress != address(0), "tokenAddress is required");
    require(managerAddress != address(0), "managerAddress is required");

    token = IAHeart(tokenAddress);
    manager = managerAddress;

    _saleInfo[_initialPreSaleInfo.index] = _initialPreSaleInfo;
    _saleInfo[_initialPartnerSaleInfo.index] = _initialPartnerSaleInfo;
    _saleInfo[_initialPublicSaleInfo.index] = _initialPublicSaleInfo;
    _saleInfo[_initialFreeMintInfo.index] = _initialFreeMintInfo;
  }

  function _requireSaleIsActive(uint256 saleIndex) internal view {
    require(!salesClosed, "Sale is closed");

    SaleInfo memory info = _saleInfo[saleIndex];
    if (info.startTimestamp > 0) {
      require(info.startTimestamp <= block.timestamp, "Sale has not started yet");
    }
    if (info.endTimestamp > 0) {
      require(block.timestamp < info.endTimestamp, "Sale is over");
    }
  }

  modifier whenSaleIsActive(uint256 saleIndex) {
    _requireSaleIsActive(saleIndex);
    _;
  }

  function verify(address addr, uint256 spots, bytes32[] memory proof, bytes32 root) public pure returns (bool) {
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, spots))));
    return MerkleProof.verify(proof, root, leaf);
  }

  function preSaleInfo() public view returns (SaleInfo memory) {
    return _saleInfo[PRE_SALE_INDEX];
  }

  function partnerSaleInfo() public view returns (SaleInfo memory) {
    return _saleInfo[PARTNER_SALE_INDEX];
  }

  function publicSaleInfo() public view returns (SaleInfo memory) {
    return _saleInfo[PUBLIC_SALE_INDEX];
  }

  function freeMintInfo() public view returns (SaleInfo memory) {
    return _saleInfo[FREE_MINT_INDEX];
  }

  function saleInfo(uint256 saleIndex) public view returns (SaleInfo memory) {
    return _saleInfo[saleIndex];
  }

  function setMerkleRoot(uint256 saleIndex, bytes32 root) external onlyOwner {
    _saleInfo[saleIndex].merkleRoot = root;
  }

  function setTimestamps(uint256 saleIndex, uint256 start, uint256 end) external onlyOwner {
    _saleInfo[saleIndex].startTimestamp = start;
    _saleInfo[saleIndex].endTimestamp = end;
  }

  function setPrice(uint256 saleIndex, uint256 price) external onlyOwner {
    _saleInfo[saleIndex].price = price;
  }

  function mintedCount(uint256 saleIndex, address addr) public view returns (uint256) {
    return _mintedCount[saleIndex][addr];
  }

  function mintPreSale(uint256 amount, uint256 spots, bytes32[] calldata proof) external payable whenSaleIsActive(PRE_SALE_INDEX) {
    _sale(PRE_SALE_INDEX, amount, spots, proof, false);
  }

  function mintPartnerSale(uint256 amount, uint256 spots, bytes32[] calldata proof) external payable whenSaleIsActive(PARTNER_SALE_INDEX) {
    _sale(PARTNER_SALE_INDEX, amount, spots, proof, false);
  }

  function mintPublicSale(uint256 amount) external payable whenSaleIsActive(PUBLIC_SALE_INDEX) {
    _sale(PUBLIC_SALE_INDEX, amount, 0, new bytes32[](0), false);
  }

  function mintFree(uint256 amount, uint256 spots, bytes32[] calldata proof) external whenSaleIsActive(FREE_MINT_INDEX) {
    _sale(FREE_MINT_INDEX, amount, spots, proof, true);
  }

  function _sale(uint256 saleIndex, uint256 amount, uint256 spots, bytes32[] memory proof, bool reserved) internal {
    require(amount > 0, "Invalid amount");
    require(amount <= MAX_AMOUNT_PER_TX, "Too many amount");

    SaleInfo memory info = _saleInfo[saleIndex];

    if (info.merkleRoot != bytes32(0)) {
      require(verify(_msgSender(), spots, proof, info.merkleRoot), "Proof is invalid");
    }

    if (spots != 0) {
      require(_mintedCount[info.index][_msgSender()] + amount <= spots, "All spots have been consumed");
    }

    if (info.price != 0) {
      require(msg.value >= info.price * amount, "Insufficient amount of eth");
    }

    unchecked {
      _mintedCount[info.index][_msgSender()] += amount;
    }

    if (reserved) {
      _mintReservedTokens(_msgSender(), amount);
    } else {
      _mintSales(_msgSender(), amount);
    }
  }

  function _mintReservedTokens(address to, uint256 amount) internal {
    require(totalReservedTokensMinted + amount <= RESERVED_TOKENS, "Minted out");

    for (uint256 i = 0; i < amount; ) {
      token.mint(to, totalReservedTokensMinted + i + 1);
      unchecked {
        i++;
      }
    }

    unchecked {
      totalReservedTokensMinted += amount;
      totalMinted += amount;
    }
  }

  function _mintSales(address to, uint256 amount) internal {
    require(RESERVED_TOKENS + totalSold + amount <= MAX_SUPPLY, "Sold out");

    for (uint256 i = 0; i < amount; ) {
      token.mint(to, RESERVED_TOKENS + totalSold + i + 1);
      unchecked {
        i++;
      }
    }

    unchecked {
      totalSold += amount;
      totalMinted += amount;
    }
  }

  function mintTeam(address to, uint256 amount) external onlyOwner {
    require(to != address(0), "Recipient address is necessary");

    _mintReservedTokens(to, amount);
  }

  function setSalesClosed(bool value) external onlyOwner {
    salesClosed = value;
  }

  function setManager(address newManager) external onlyOwner {
    manager = newManager;
  }

  function withdraw() external onlyOwner {
    require(manager != address(0), "Manager address is not set");

    (bool success, ) = manager.call{value: address(this).balance}("");
    require(success, "Failed to send to manager");
  }
}
// SPDX-License-Identifier: MIT

// Project A-Heart: https://a-he.art

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IAHeart is IERC721 {
  function emitBatchMetadataUpdate(uint256 fromTokenId, uint256 toTokenId) external;

  function setMinter(address newMinter) external;

  function mint(address to, uint256 tokenId) external;

  function setBaseTokenURI(string calldata newBaseTokenURI) external;

  function setExtension(address extension, bool value) external;

  function addSuffixKey(string calldata key) external;

  function removeSuffixKey(uint256 keyIndex) external;

  function setSuffixValue(uint256 keyIndex, uint256 tokenId, string calldata value) external;

  function tokenURISuffix(uint256 tokenId) external view returns (string memory);

  function setEmissionRateDelta(uint256 tokenId, uint96 value) external;

  function chemistry(address tokenOwner, uint256 tokenId) external pure returns (uint256);

  function emissionRate(uint256 tokenId) external view returns (uint256);

  function rewardAmount(uint256 tokenId) external view returns (uint256);

  function addReward(uint256 tokenId, uint256 amount) external;

  function removeReward(uint256 tokenId, uint256 amount) external;

  function transferWithReward(address to, uint256 tokenId) external;
}
// SPDX-License-Identifier: MIT

// Project A-Heart: https://a-he.art

pragma solidity ^0.8.18;

interface IAHeartSales {
  struct SaleInfo {
    uint256 index;
    uint256 startTimestamp;
    uint256 endTimestamp;
    uint256 price;
    bytes32 merkleRoot;
  }

  function verify(address addr, uint256 spots, bytes32[] memory proof, bytes32 root) external pure returns (bool);

  function preSaleInfo() external view returns (SaleInfo memory);

  function partnerSaleInfo() external view returns (SaleInfo memory);

  function publicSaleInfo() external view returns (SaleInfo memory);

  function freeMintInfo() external view returns (SaleInfo memory);

  function saleInfo(uint256 saleIndex) external view returns (SaleInfo memory);

  function setMerkleRoot(uint256 saleIndex, bytes32 root) external;

  function setTimestamps(uint256 saleIndex, uint256 start, uint256 end) external;

  function setPrice(uint256 saleIndex, uint256 price) external;

  function mintedCount(uint256 salesIndex, address addr) external view returns (uint256);

  function mintPreSale(uint256 amount, uint256 spots, bytes32[] calldata proof) external payable;

  function mintPartnerSale(uint256 amount, uint256 spots, bytes32[] calldata proof) external payable;

  function mintPublicSale(uint256 amount) external payable;

  function mintFree(uint256 amount, uint256 spots, bytes32[] calldata proof) external;

  function mintTeam(address to, uint256 amount) external;

  function setSalesClosed(bool value) external;

  function setManager(address newManager) external;

  function withdraw() external;
}