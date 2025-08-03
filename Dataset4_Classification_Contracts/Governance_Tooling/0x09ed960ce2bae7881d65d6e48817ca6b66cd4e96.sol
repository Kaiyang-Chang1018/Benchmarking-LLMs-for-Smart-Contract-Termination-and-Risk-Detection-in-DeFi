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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import '@openzeppelin/contracts/access/Ownable.sol';
import 'contracts/interfaces/IERC1155CreatorCore.sol';
import 'contracts/Whitelist.sol';

// based on the single necessary interface from 'IERC1155CreatorCore'
interface DefiPassContract {
  /**
 * @dev burn tokens. Can only be called by token owner or approved address.
   * On burn, calls back to the registered extension's onBurn method
   */
  function burn(
    address account,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts
  ) external;
}

contract OrdinalsBurnRegistry is Ownable, Whitelist {
  // ------------------ STRUCTS ------------------

  /// @notice Burn details
  struct BurnRecord {
    /// @notice burner's ETH address
    address ownerEthereumAddress;
    /// @notice amounts of tokens burned
    uint8 amountBurned;
    /// @notice Target ordinals address of the owner
    string ownerOrdinalsAddress;
  }

  // ------------------ EVENTS ------------------

  /// @notice Event emitted when a token is burned
  /// @param ownerEthereumAddress ETH address of the owner
  /// @param totalRequestedByUser Quantity of tokens burned
  /// @param ownerOrdinalsAddress Target ordinals address of the owner
  event Burn(
    address indexed ownerEthereumAddress,
    uint8 totalRequestedByUser,
    string indexed ownerOrdinalsAddress
  );

  // ------------------ STORAGE ------------------
  /// @notice Maximum number of burns allowed
  uint256 public immutable MAX_NUMBER_OF_BURNS;

  /// @notice Token ID to burn
  uint256 public immutable TOKEN_ID_TO_BURN;

  /// @notice Current number of burns
  uint256 public supply;

  /// @notice Contract to register ordinals burns for
  DefiPassContract public immutable NFT_CONTRACT;

  /// @notice Stored burn data
  BurnRecord[] public burnRecords;

  /// @notice Mapping of owner to ref. burn records (index in burnRecords array)
  mapping(address => uint256[]) public burnRecordsByOwner;

  /// @notice Whether or not burning is enabled
  bool public burnEnabled;

  // ------------------ CONSTRUCTOR ------------------

  /// @param nftContract Address of the NFT contract to register burns for
  /// @param maxNumberOfBurns Maximum number of burns allowed
  /// @param tokenIdToBurn Token ID to burn
  constructor(
    DefiPassContract nftContract,
    uint256 maxNumberOfBurns,
    uint256 tokenIdToBurn
  ) Ownable(msg.sender) {
    NFT_CONTRACT = nftContract;
    MAX_NUMBER_OF_BURNS = maxNumberOfBurns;
    TOKEN_ID_TO_BURN = tokenIdToBurn;
  }

  // ------------------ BURN FUNCTIONS ------------------

  /// @notice Burns the given amounts of token IDs, registers the burn details and emits a Burn event
  /// @param totalRequestedByUser Quantity of tokens to be burned
  /// @param maxAmount Maximum amount of tokens allowed to be burned by msg.sender
  /// @param proof Merkle proof to verify the owner's whitelist status
  /// @param ordinalsAddress Target ordinals address to receive the ordinals
  function burn(
    uint8 totalRequestedByUser,
    uint256 maxAmount,
    bytes32[] calldata proof,
    string calldata ordinalsAddress
  ) public {
    require(burnEnabled, 'BurnRegistry: Burning is disabled');

    // Check if the user is burning at least one token
    require(
      totalRequestedByUser > 0,
      'BurnRegistry: Must burn at least one token'
    );

    // Check if the user is in the whitelist
    require(
      _verify(proof, msg.sender, maxAmount),
      'BurnRegistry: user is not whitelisted'
    );

    uint256 totalBurntByUser = getTotalBurntForOwner(msg.sender);

    require(
      // Check if the total amount of tokens burned by the owner is less than the user's limit
      totalBurntByUser + totalRequestedByUser <= maxAmount &&
        // Check if the total amount of tokens burned is less than the contract's limit
        supply + totalRequestedByUser <= MAX_NUMBER_OF_BURNS,
      'BurnRegistry: Burn amount exceeds the limit'
    );

    uint256[] memory tokenIds = new uint256[](1);
    tokenIds[0] = TOKEN_ID_TO_BURN;

    uint256[] memory amounts = new uint256[](1);
    amounts[0] = totalRequestedByUser;

    // Burn the tokens
    NFT_CONTRACT.burn(msg.sender, tokenIds, amounts);

    // increment the total number of burns
    supply += totalRequestedByUser;

    // Save the index of the new burn record
    uint256 burnIndex = burnRecords.length;

    // Record the burn details
    burnRecords.push(
      BurnRecord({
        ownerEthereumAddress: msg.sender,
        amountBurned: totalRequestedByUser,
        ownerOrdinalsAddress: ordinalsAddress
      })
    );

    // Add the burn record index to the owner's list of burn records
    burnRecordsByOwner[msg.sender].push(burnIndex);

    // Emit the Burn event
    emit Burn(msg.sender, totalRequestedByUser, ordinalsAddress);
  }

  // ------------------ OWNER FUNCTIONS ------------------

  /// @notice Enables or disables burning
  /// @param enabled Whether or not burning should be enabled
  function setBurnEnabled(bool enabled) external onlyOwner {
    burnEnabled = enabled;
  }

  /// @notice Sets the merkle root for the whitelist
  /// @param newMerkleRoot New merkle root
  function setWhitelistRoot(bytes32 newMerkleRoot) external onlyOwner {
    _setMerkleRoot(newMerkleRoot);
  }

  // ------------------ VIEW FUNCTIONS ------------------

  /// @notice Returns the burn records for the given owner
  /// @param owner Owner to get the burn records for
  /// @return burnRecordsForOwner Burn records for the given owner
  function getBurnRecordsByOwner(
    address owner
  ) external view returns (BurnRecord[] memory burnRecordsForOwner) {
    uint256[] memory burnIndices = burnRecordsByOwner[owner];
    burnRecordsForOwner = new BurnRecord[](burnIndices.length);

    for (uint256 i = 0; i < burnIndices.length; i++) {
      burnRecordsForOwner[i] = burnRecords[burnIndices[i]];
    }
  }

  /// @notice Returns the indices of the burn records for the given owner
  /// @param owner Owner to get the burn record indices for
  /// @return burnIndices Indices of the burn records for the given owner
  function getBurnRecordIndicesForOwner(
    address owner
  ) external view returns (uint256[] memory burnIndices) {
    burnIndices = burnRecordsByOwner[owner];
  }

  /// @notice Returns the total amount of tokens burned by the given owner
  /// @param owner Owner to get the total amount of tokens burned for
  function getTotalBurntForOwner(
    address owner
  ) public view returns (uint256 burnt) {
    uint256[] memory burnIndices = burnRecordsByOwner[owner];
    for (uint256 i = 0; i < burnIndices.length; i++) {
      BurnRecord memory record = burnRecords[burnIndices[i]];

      burnt += record.amountBurned;
    }
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

contract Whitelist {
  bytes32 public merkleRoot;

  function _setMerkleRoot(bytes32 _merkleRoot) internal {
    merkleRoot = _merkleRoot;
  }

  function _verify(
    bytes32[] memory proof,
    address user,
    uint256 amount
  ) internal view returns (bool) {
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(user, amount))));
    return MerkleProof.verify(proof, merkleRoot, leaf);
  }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

/**
 * @dev Core creator interface
 */
interface ICreatorCore is IERC165 {
  event ExtensionRegistered(address indexed extension, address indexed sender);
  event ExtensionUnregistered(
    address indexed extension,
    address indexed sender
  );
  event ExtensionBlacklisted(address indexed extension, address indexed sender);
  event MintPermissionsUpdated(
    address indexed extension,
    address indexed permissions,
    address indexed sender
  );
  event RoyaltiesUpdated(
    uint256 indexed tokenId,
    address payable[] receivers,
    uint256[] basisPoints
  );
  event DefaultRoyaltiesUpdated(
    address payable[] receivers,
    uint256[] basisPoints
  );
  event ApproveTransferUpdated(address extension);
  event ExtensionRoyaltiesUpdated(
    address indexed extension,
    address payable[] receivers,
    uint256[] basisPoints
  );
  event ExtensionApproveTransferUpdated(
    address indexed extension,
    bool enabled
  );

  /**
   * @dev gets address of all extensions
   */
  function getExtensions() external view returns (address[] memory);

  /**
   * @dev add an extension.  Can only be called by contract owner or admin.
   * extension address must point to a contract implementing ICreatorExtension.
   * Returns True if newly added, False if already added.
   */
  function registerExtension(
    address extension,
    string calldata baseURI
  ) external;

  /**
   * @dev add an extension.  Can only be called by contract owner or admin.
   * extension address must point to a contract implementing ICreatorExtension.
   * Returns True if newly added, False if already added.
   */
  function registerExtension(
    address extension,
    string calldata baseURI,
    bool baseURIIdentical
  ) external;

  /**
   * @dev add an extension.  Can only be called by contract owner or admin.
   * Returns True if removed, False if already removed.
   */
  function unregisterExtension(address extension) external;

  /**
   * @dev blacklist an extension.  Can only be called by contract owner or admin.
   * This function will destroy all ability to reference the metadata of any tokens created
   * by the specified extension. It will also unregister the extension if needed.
   * Returns True if removed, False if already removed.
   */
  function blacklistExtension(address extension) external;

  /**
   * @dev set the baseTokenURI of an extension.  Can only be called by extension.
   */
  function setBaseTokenURIExtension(string calldata uri) external;

  /**
   * @dev set the baseTokenURI of an extension.  Can only be called by extension.
   * For tokens with no uri configured, tokenURI will return "uri+tokenId"
   */
  function setBaseTokenURIExtension(
    string calldata uri,
    bool identical
  ) external;

  /**
   * @dev set the common prefix of an extension.  Can only be called by extension.
   * If configured, and a token has a uri set, tokenURI will return "prefixURI+tokenURI"
   * Useful if you want to use ipfs/arweave
   */
  function setTokenURIPrefixExtension(string calldata prefix) external;

  /**
   * @dev set the tokenURI of a token extension.  Can only be called by extension that minted token.
   */
  function setTokenURIExtension(uint256 tokenId, string calldata uri) external;

  /**
   * @dev set the tokenURI of a token extension for multiple tokens.  Can only be called by extension that minted token.
   */
  function setTokenURIExtension(
    uint256[] memory tokenId,
    string[] calldata uri
  ) external;

  /**
   * @dev set the baseTokenURI for tokens with no extension.  Can only be called by owner/admin.
   * For tokens with no uri configured, tokenURI will return "uri+tokenId"
   */
  function setBaseTokenURI(string calldata uri) external;

  /**
   * @dev set the common prefix for tokens with no extension.  Can only be called by owner/admin.
   * If configured, and a token has a uri set, tokenURI will return "prefixURI+tokenURI"
   * Useful if you want to use ipfs/arweave
   */
  function setTokenURIPrefix(string calldata prefix) external;

  /**
   * @dev set the tokenURI of a token with no extension.  Can only be called by owner/admin.
   */
  function setTokenURI(uint256 tokenId, string calldata uri) external;

  /**
   * @dev set the tokenURI of multiple tokens with no extension.  Can only be called by owner/admin.
   */
  function setTokenURI(
    uint256[] memory tokenIds,
    string[] calldata uris
  ) external;

  /**
   * @dev set a permissions contract for an extension.  Used to control minting.
   */
  function setMintPermissions(address extension, address permissions) external;

  /**
   * @dev Configure so transfers of tokens created by the caller (must be extension) gets approval
   * from the extension before transferring
   */
  function setApproveTransferExtension(bool enabled) external;

  /**
   * @dev get the extension of a given token
   */
  function tokenExtension(uint256 tokenId) external view returns (address);

  /**
   * @dev Set default royalties
   */
  function setRoyalties(
    address payable[] calldata receivers,
    uint256[] calldata basisPoints
  ) external;

  /**
   * @dev Set royalties of a token
   */
  function setRoyalties(
    uint256 tokenId,
    address payable[] calldata receivers,
    uint256[] calldata basisPoints
  ) external;

  /**
   * @dev Set royalties of an extension
   */
  function setRoyaltiesExtension(
    address extension,
    address payable[] calldata receivers,
    uint256[] calldata basisPoints
  ) external;

  /**
   * @dev Get royalites of a token.  Returns list of receivers and basisPoints
   */
  function getRoyalties(
    uint256 tokenId
  ) external view returns (address payable[] memory, uint256[] memory);

  // Royalty support for various other standards
  function getFeeRecipients(
    uint256 tokenId
  ) external view returns (address payable[] memory);

  function getFeeBps(uint256 tokenId) external view returns (uint[] memory);

  function getFees(
    uint256 tokenId
  ) external view returns (address payable[] memory, uint256[] memory);

  function royaltyInfo(
    uint256 tokenId,
    uint256 value
  ) external view returns (address, uint256);

  /**
   * @dev Set the default approve transfer contract location.
   */
  function setApproveTransfer(address extension) external;

  /**
   * @dev Get the default approve transfer contract location.
   */
  function getApproveTransfer() external view returns (address);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import './ICreatorCore.sol';

/**
 * @dev Core ERC1155 creator interface
 */
interface IERC1155CreatorCore is ICreatorCore {
  /**
   * @dev mint a token with no extension. Can only be called by an admin.
   *
   * @param to       - Can be a single element array (all tokens go to same address) or multi-element array (single token to many recipients)
   * @param amounts  - Can be a single element array (all recipients get the same amount) or a multi-element array
   * @param uris     - If no elements, all tokens use the default uri.
   *                   If any element is an empty string, the corresponding token uses the default uri.
   *
   *
   * Requirements: If to is a multi-element array, then uris must be empty or single element array
   *               If to is a multi-element array, then amounts must be a single element array or a multi-element array of the same size
   *               If to is a single element array, uris must be empty or the same length as amounts
   *
   * Examples:
   *    mintBaseNew(['0x....1', '0x....2'], [1], [])
   *        Mints a single new token, and gives 1 each to '0x....1' and '0x....2'.  Token uses default uri.
   *
   *    mintBaseNew(['0x....1', '0x....2'], [1, 2], [])
   *        Mints a single new token, and gives 1 to '0x....1' and 2 to '0x....2'.  Token uses default uri.
   *
   *    mintBaseNew(['0x....1'], [1, 2], ["", "http://token2.com"])
   *        Mints two new tokens to '0x....1'. 1 of the first token, 2 of the second.  1st token uses default uri, second uses "http://token2.com".
   *
   * @return Returns list of tokenIds minted
   */
  function mintBaseNew(
    address[] calldata to,
    uint256[] calldata amounts,
    string[] calldata uris
  ) external returns (uint256[] memory);

  /**
   * @dev batch mint existing token with no extension. Can only be called by an admin.
   *
   * @param to        - Can be a single element array (all tokens go to same address) or multi-element array (single token to many recipients)
   * @param tokenIds  - Can be a single element array (all recipients get the same token) or a multi-element array
   * @param amounts   - Can be a single element array (all recipients get the same amount) or a multi-element array
   *
   * Requirements: If any of the parameters are multi-element arrays, they need to be the same length as other multi-element arrays
   *
   * Examples:
   *    mintBaseExisting(['0x....1', '0x....2'], [1], [10])
   *        Mints 10 of tokenId 1 to each of '0x....1' and '0x....2'.
   *
   *    mintBaseExisting(['0x....1', '0x....2'], [1, 2], [10, 20])
   *        Mints 10 of tokenId 1 to '0x....1' and 20 of tokenId 2 to '0x....2'.
   *
   *    mintBaseExisting(['0x....1'], [1, 2], [10, 20])
   *        Mints 10 of tokenId 1 and 20 of tokenId 2 to '0x....1'.
   *
   *    mintBaseExisting(['0x....1', '0x....2'], [1], [10, 20])
   *        Mints 10 of tokenId 1 to '0x....1' and 20 of tokenId 1 to '0x....2'.
   *
   */
  function mintBaseExisting(
    address[] calldata to,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts
  ) external;

  /**
   * @dev mint a token from an extension. Can only be called by a registered extension.
   *
   * @param to       - Can be a single element array (all tokens go to same address) or multi-element array (single token to many recipients)
   * @param amounts  - Can be a single element array (all recipients get the same amount) or a multi-element array
   * @param uris     - If no elements, all tokens use the default uri.
   *                   If any element is an empty string, the corresponding token uses the default uri.
   *
   *
   * Requirements: If to is a multi-element array, then uris must be empty or single element array
   *               If to is a multi-element array, then amounts must be a single element array or a multi-element array of the same size
   *               If to is a single element array, uris must be empty or the same length as amounts
   *
   * Examples:
   *    mintExtensionNew(['0x....1', '0x....2'], [1], [])
   *        Mints a single new token, and gives 1 each to '0x....1' and '0x....2'.  Token uses default uri.
   *
   *    mintExtensionNew(['0x....1', '0x....2'], [1, 2], [])
   *        Mints a single new token, and gives 1 to '0x....1' and 2 to '0x....2'.  Token uses default uri.
   *
   *    mintExtensionNew(['0x....1'], [1, 2], ["", "http://token2.com"])
   *        Mints two new tokens to '0x....1'. 1 of the first token, 2 of the second.  1st token uses default uri, second uses "http://token2.com".
   *
   * @return Returns list of tokenIds minted
   */
  function mintExtensionNew(
    address[] calldata to,
    uint256[] calldata amounts,
    string[] calldata uris
  ) external returns (uint256[] memory);

  /**
   * @dev batch mint existing token from extension. Can only be called by a registered extension.
   *
   * @param to        - Can be a single element array (all tokens go to same address) or multi-element array (single token to many recipients)
   * @param tokenIds  - Can be a single element array (all recipients get the same token) or a multi-element array
   * @param amounts   - Can be a single element array (all recipients get the same amount) or a multi-element array
   *
   * Requirements: If any of the parameters are multi-element arrays, they need to be the same length as other multi-element arrays
   *
   * Examples:
   *    mintExtensionExisting(['0x....1', '0x....2'], [1], [10])
   *        Mints 10 of tokenId 1 to each of '0x....1' and '0x....2'.
   *
   *    mintExtensionExisting(['0x....1', '0x....2'], [1, 2], [10, 20])
   *        Mints 10 of tokenId 1 to '0x....1' and 20 of tokenId 2 to '0x....2'.
   *
   *    mintExtensionExisting(['0x....1'], [1, 2], [10, 20])
   *        Mints 10 of tokenId 1 and 20 of tokenId 2 to '0x....1'.
   *
   *    mintExtensionExisting(['0x....1', '0x....2'], [1], [10, 20])
   *        Mints 10 of tokenId 1 to '0x....1' and 20 of tokenId 1 to '0x....2'.
   *
   */
  function mintExtensionExisting(
    address[] calldata to,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts
  ) external;

  /**
   * @dev burn tokens. Can only be called by token owner or approved address.
   * On burn, calls back to the registered extension's onBurn method
   */
  function burn(
    address account,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts
  ) external;

  /**
   * @dev Total amount of tokens in with a given tokenId.
   */
  function totalSupply(uint256 tokenId) external view returns (uint256);
}