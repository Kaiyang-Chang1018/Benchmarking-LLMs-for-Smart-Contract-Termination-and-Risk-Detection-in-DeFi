// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity ^0.8.4;

/**
 * @dev Interface of ERC721A.
 */
interface IERC721A {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the
     * ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    /**
     * The `quantity` minted with ERC2309 exceeds the safety limit.
     */
    error MintERC2309QuantityExceedsLimit();

    /**
     * The `extraData` cannot be set on an unintialized ownership slot.
     */
    error OwnershipNotInitializedForExtraData();

    // =============================================================
    //                            STRUCTS
    // =============================================================

    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Stores the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
        // Arbitrary data similar to `startTimestamp` that can be set via {_extraData}.
        uint24 extraData;
    }

    // =============================================================
    //                         TOKEN COUNTERS
    // =============================================================

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function totalSupply() external view returns (uint256);

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // =============================================================
    //                            IERC721
    // =============================================================

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables
     * (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in `owner`'s account.
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
     * @dev Safely transfers `tokenId` token from `from` to `to`,
     * checking first that contract recipients are aware of the ERC721 protocol
     * to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move
     * this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external payable;

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom}
     * whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external payable;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
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
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    // =============================================================
    //                           IERC2309
    // =============================================================

    /**
     * @dev Emitted when tokens in `fromTokenId` to `toTokenId`
     * (inclusive) is transferred from `from` to `to`, as defined in the
     * [ERC2309](https://eips.ethereum.org/EIPS/eip-2309) standard.
     *
     * See {_mintERC2309} for more details.
     */
    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import '../IERC721A.sol';
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC721ACH {
    /**
     * @dev Enumerated list of all available hook types for the ERC721ACH contract.
     */
    enum HookType {
        /// @notice Hook for custom logic before a token transfer occurs.
        BeforeTokenTransfers,
        /// @notice Hook for custom logic after a token transfer occurs.
        AfterTokenTransfers,
        /// @notice Hook for custom logic for ownerOf() function.
        OwnerOf
    }

    /**
     * @notice An event that gets emitted when a hook is updated.
     * @param setter The address that set the hook.
     * @param hookType The type of the hook that was set.
     * @param hookAddress The address of the contract that implements the hook.
     */
    event UpdatedHook(
        address indexed setter,
        HookType hookType,
        address indexed hookAddress
    );

    /**
     * @notice Sets the contract address for a specified hook type.
     * @param hookType The type of hook to set, as defined in the HookType enum.
     * @param hookAddress The address of the contract implementing the hook interface.
     */
    function setHook(HookType hookType, address hookAddress) external;

    /**
     * @notice Returns the contract address for a specified hook type.
     * @param hookType The type of hook to set, as defined in the HookType enum.
     * @return The address of the contract implementing the hook interface.
     */
    function getHook(HookType hookType) external view returns (address);
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
pragma solidity ^0.8.15;

/**
 * @title ICollectionHolderMint
 * @dev This interface represents the functions related to minting a collection of tokens.
 */
interface ICollectionHolderMint {
    // Events
    error AlreadyClaimedFreeMint(); // Fired when a free mint has already been claimed
    error NoTokensProvided(); // Fired when a mint function is called with no tokens provided
    error DuplicatesFound(); // Fired when a mint function is called with duplicate tokens

    /**
     * @dev Returns whether a specific mint has been claimed
     * @param tokenId The ID of the token in question
     * @return A boolean indicating whether the mint has been claimed
     */
    function freeMintClaimed(uint256 tokenId) external view returns (bool);

    /**
     * @dev Returns the address of the collection contract
     * @return The address of the collection contract
     */
    function cre8orsNFTContractAddress() external view returns (address);

    /**
     * @dev Returns the address of the minter utility contract
     * @return The address of the minter utility contract
     */
    function minterUtilityContractAddress() external view returns (address);

    /**
     * @dev Returns the maximum number of free mints claimed by an address
     * @return The maximum number of free mints claimed
     */
    function totalClaimed(address) external view returns (uint256);

    /**
     * @dev Mints a batch of tokens and sends them to a recipient
     * @param tokenIds An array of token IDs to mint
     * @param recipient The address to send the minted tokens to
     * @return The last token ID minted in this batch
     */
    function mint(
        uint256[] calldata tokenIds,
        address recipient
    ) external returns (uint256);

    /**
     * @dev Changes the address of the minter utility contract
     * @param _newMinterUtilityContractAddress The new minter utility contract address
     */
    function setNewMinterUtilityContractAddress(
        address _newMinterUtilityContractAddress
    ) external;

    /**
     * @dev Toggles the claim status of a free mint
     * @param tokenId The ID of the token whose claim status is being toggled
     */
    function toggleHasClaimedFreeMint(uint256 tokenId) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ILockup} from "./ILockup.sol";

interface ICre8ing {
    /// @notice Getter for Lockup interface
    function lockUp(address) external view returns (ILockup);

    /// @dev Emitted when a CRE8OR begins cre8ing.
    event Cre8ed(address, uint256 indexed tokenId);

    /// @dev Emitted when a CRE8OR stops cre8ing; either through standard means or
    ///     by expulsion.
    event Uncre8ed(address, uint256 indexed tokenId);

    /// @dev Emitted when a CRE8OR is expelled from the Warehouse.
    event Expelled(address, uint256 indexed tokenId);

    /// @notice Missing cre8ing status
    error CRE8ING_NotCre8ing(address, uint256 tokenId);

    /// @notice Cre8ing Closed
    error Cre8ing_Cre8ingClosed();

    /// @notice Cre8ing
    error Cre8ing_Cre8ing();

    /// @notice Missing Lockup
    error Cre8ing_MissingLockup();

    /// @notice Cre8ing period
    function cre8ingPeriod(
        address,
        uint256
    ) external view returns (bool cre8ing, uint256 current, uint256 total);

    /// @notice open / close staking
    function setCre8ingOpen(address, bool) external;

    /// @notice force removal from staking
    function expelFromWarehouse(address, uint256) external;

    /// @notice function getCre8ingStarted(
    function getCre8ingStarted(
        address _target,
        uint256 tokenId
    ) external view returns (uint256);

    /// @notice array of staked tokenIDs
    /// @dev used in cre8ors ui to quickly get list of staked NFTs.
    function cre8ingTokens(
        address _target
    ) external view returns (uint256[] memory stakedTokens);

    /// @notice initialize both staking and lockups
    function inializeStakingAndLockup(
        address _target,
        uint256[] memory,
        bytes memory
    ) external;

    /// @notice Set a new lockup for the target.
    /// @param _target The target address.
    /// @param newLockup The new lockup contract address.
    function setLockup(address _target, ILockup newLockup) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IERC721Drop} from "./IERC721Drop.sol";
import {ILockup} from "./ILockup.sol";
import {IERC721A} from "erc721a/contracts/IERC721A.sol";
import {ICre8ing} from "./ICre8ing.sol";
import {ISubscription} from "../subscription/interfaces/ISubscription.sol";

/**
 ██████╗██████╗ ███████╗ █████╗  ██████╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝
██║     ██████╔╝█████╗  ╚█████╔╝██║   ██║██████╔╝███████╗
██║     ██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██╗╚════██║
╚██████╗██║  ██║███████╗╚█████╔╝╚██████╔╝██║  ██║███████║
 ╚═════╝╚═╝  ╚═╝╚══════╝ ╚════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝                                                       
*/
/// @notice Interface for Cre8ors Drops contract
interface ICre8ors is IERC721Drop, IERC721A {
    function cre8ing() external view returns (ICre8ing);

    /// @notice Getter for last minted token ID (gets next token id and subtracts 1)
    function _lastMintedTokenId() external view returns (uint256);

    /// @dev Returns `true` if `account` has been granted `role`.
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    function subscription() external view returns (address);

    function setSubscription(address newSubscription) external;

    function setCre8ing(ICre8ing _cre8ing) external;

    function MINTER_ROLE() external returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IMetadataRenderer} from "../interfaces/IMetadataRenderer.sol";

/**
 ██████╗██████╗ ███████╗ █████╗  ██████╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝
██║     ██████╔╝█████╗  ╚█████╔╝██║   ██║██████╔╝███████╗
██║     ██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██╗╚════██║
╚██████╗██║  ██║███████╗╚█████╔╝╚██████╔╝██║  ██║███████║
 ╚═════╝╚═╝  ╚═╝╚══════╝ ╚════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝                                                       
*/
/// @notice Interface for Cre8ors Drop contract
interface IERC721Drop {
    // Access errors

    /// @notice Only admin can access this function
    error Access_OnlyAdmin();
    /// @notice Missing the given role or admin access
    error Access_MissingRoleOrAdmin(bytes32 role);
    /// @notice Withdraw is not allowed by this user
    error Access_WithdrawNotAllowed();
    /// @notice Cannot withdraw funds due to ETH send failure.
    error Withdraw_FundsSendFailure();
    /// @notice Missing the owner role.
    error Access_OnlyOwner();
    /// @notice Missing the owner role or approved nft access.
    error Access_MissingOwnerOrApproved();

    // Sale/Purchase errors
    /// @notice Sale is inactive
    error Sale_Inactive();
    /// @notice Presale is inactive
    error Presale_Inactive();
    /// @notice Presale merkle root is invalid
    error Presale_MerkleNotApproved();
    /// @notice Wrong price for purchase
    error Purchase_WrongPrice(uint256 correctPrice);
    /// @notice NFT sold out
    error Mint_SoldOut();
    /// @notice Too many purchase for address
    error Purchase_TooManyForAddress();
    /// @notice Too many presale for address
    error Presale_TooManyForAddress();

    // Admin errors
    /// @notice Royalty percentage too high
    error Setup_RoyaltyPercentageTooHigh(uint16 maxRoyaltyBPS);
    /// @notice Invalid admin upgrade address
    error Admin_InvalidUpgradeAddress(address proposedAddress);
    /// @notice Unable to finalize an edition not marked as open (size set to uint64_max_value)
    error Admin_UnableToFinalizeNotOpenEdition();

    /// @notice Event emitted for each sale
    /// @param to address sale was made to
    /// @param quantity quantity of the minted nfts
    /// @param pricePerToken price for each token
    /// @param firstPurchasedTokenId first purchased token ID (to get range add to quantity for max)
    event Sale(
        address indexed to,
        uint256 indexed quantity,
        uint256 indexed pricePerToken,
        uint256 firstPurchasedTokenId
    );

    /// @notice Sales configuration has been changed
    /// @dev To access new sales configuration, use getter function.
    /// @param changedBy Changed by user
    event SalesConfigChanged(address indexed changedBy);

    /// @notice Event emitted when the funds recipient is changed
    /// @param newAddress new address for the funds recipient
    /// @param changedBy address that the recipient is changed by
    event FundsRecipientChanged(
        address indexed newAddress,
        address indexed changedBy
    );

    /// @notice Event emitted when the funds are withdrawn from the minting contract
    /// @param withdrawnBy address that issued the withdraw
    /// @param withdrawnTo address that the funds were withdrawn to
    /// @param amount amount that was withdrawn
    event FundsWithdrawn(
        address indexed withdrawnBy,
        address indexed withdrawnTo,
        uint256 amount
    );

    /// @notice Event emitted when an open mint is finalized and further minting is closed forever on the contract.
    /// @param sender address sending close mint
    /// @param numberOfMints number of mints the contract is finalized at
    event OpenMintFinalized(address indexed sender, uint256 numberOfMints);

    /// @notice Event emitted when metadata renderer is updated.
    /// @param sender address of the updater
    /// @param renderer new metadata renderer address
    event UpdatedMetadataRenderer(address sender, IMetadataRenderer renderer);

    /// @notice General configuration for NFT Minting and bookkeeping
    struct Configuration {
        /// @dev Metadata renderer (uint160)
        IMetadataRenderer metadataRenderer;
        /// @dev Total size of edition that can be minted (uint160+64 = 224)
        uint64 editionSize;
        /// @dev Royalty amount in bps (uint224+16 = 240)
        uint16 royaltyBPS;
        /// @dev Funds recipient for sale (new slot, uint160)
        address payable fundsRecipient;
    }

    /// @notice Sales states and configuration
    /// @dev Uses 3 storage slots
    struct SalesConfiguration {
        /// @dev Public sale price (max ether value > 1000 ether with this value)
        uint104 publicSalePrice;
        /// @dev ERC20 Token
        address erc20PaymentToken;
        /// @notice Purchase mint limit per address (if set to 0 === unlimited mints)
        /// @dev Max purchase number per txn (90+32 = 122)
        uint32 maxSalePurchasePerAddress;
        /// @dev uint64 type allows for dates into 292 billion years
        /// @notice Public sale start timestamp (136+64 = 186)
        uint64 publicSaleStart;
        /// @notice Public sale end timestamp (186+64 = 250)
        uint64 publicSaleEnd;
        /// @notice Presale start timestamp
        /// @dev new storage slot
        uint64 presaleStart;
        /// @notice Presale end timestamp
        uint64 presaleEnd;
        /// @notice Presale merkle root
        bytes32 presaleMerkleRoot;
    }

    /// @notice CRE8ORS - General configuration for Builder Rewards burn requirements
    struct BurnConfiguration {
        /// @dev Token to burn
        address burnToken;
        /// @dev Required number of tokens to burn
        uint256 burnQuantity;
    }

    /// @notice Sales states and configuration
    /// @dev Uses 3 storage slots
    struct ERC20SalesConfiguration {
        /// @notice Public sale price
        /// @dev max ether value > 1000 ether with this value
        uint104 publicSalePrice;
        /// @dev ERC20 Token
        address erc20PaymentToken;
        /// @notice Purchase mint limit per address (if set to 0 === unlimited mints)
        /// @dev Max purchase number per txn (90+32 = 122)
        uint32 maxSalePurchasePerAddress;
        /// @dev uint64 type allows for dates into 292 billion years
        /// @notice Public sale start timestamp (136+64 = 186)
        uint64 publicSaleStart;
        /// @notice Public sale end timestamp (186+64 = 250)
        uint64 publicSaleEnd;
        /// @notice Presale start timestamp
        /// @dev new storage slot
        uint64 presaleStart;
        /// @notice Presale end timestamp
        uint64 presaleEnd;
        /// @notice Presale merkle root
        bytes32 presaleMerkleRoot;
    }

    /// @notice Return value for sales details to use with front-ends
    struct SaleDetails {
        // Synthesized status variables for sale and presale
        bool publicSaleActive;
        bool presaleActive;
        // Price for public sale
        uint256 publicSalePrice;
        // Timed sale actions for public sale
        uint64 publicSaleStart;
        uint64 publicSaleEnd;
        // Timed sale actions for presale
        uint64 presaleStart;
        uint64 presaleEnd;
        // Merkle root (includes address, quantity, and price data for each entry)
        bytes32 presaleMerkleRoot;
        // Limit public sale to a specific number of mints per wallet
        uint256 maxSalePurchasePerAddress;
        // Information about the rest of the supply
        // Total that have been minted
        uint256 totalMinted;
        // The total supply available
        uint256 maxSupply;
    }

    /// @notice Return value for sales details to use with front-ends
    struct ERC20SaleDetails {
        /// @notice Synthesized status variables for sale
        bool publicSaleActive;
        /// @notice Synthesized status variables for presale
        bool presaleActive;
        /// @notice Price for public sale
        uint256 publicSalePrice;
        /// @notice ERC20 contract address for payment. address(0) for ETH.
        address erc20PaymentToken;
        /// @notice public sale start
        uint64 publicSaleStart;
        /// @notice public sale end
        uint64 publicSaleEnd;
        /// @notice Timed sale actions for presale start
        uint64 presaleStart;
        /// @notice Timed sale actions for presale end
        uint64 presaleEnd;
        /// @notice Merkle root (includes address, quantity, and price data for each entry)
        bytes32 presaleMerkleRoot;
        /// @notice Limit public sale to a specific number of mints per wallet
        uint256 maxSalePurchasePerAddress;
        /// @notice Total that have been minted
        uint256 totalMinted;
        /// @notice The total supply available
        uint256 maxSupply;
    }

    /// @notice Return type of specific mint counts and details per address
    struct AddressMintDetails {
        /// Number of total mints from the given address
        uint256 totalMints;
        /// Number of presale mints from the given address
        uint256 presaleMints;
        /// Number of public mints from the given address
        uint256 publicMints;
    }

    /// @notice External purchase function (payable in eth)
    /// @param quantity to purchase
    /// @return first minted token ID
    function purchase(uint256 quantity) external payable returns (uint256);

    /// @notice External purchase presale function (takes a merkle proof and matches to root) (payable in eth)
    /// @param quantity to purchase
    /// @param maxQuantity can purchase (verified by merkle root)
    /// @param pricePerToken price per token allowed (verified by merkle root)
    /// @param merkleProof input for merkle proof leaf verified by merkle root
    /// @return first minted token ID
    function purchasePresale(
        uint256 quantity,
        uint256 maxQuantity,
        uint256 pricePerToken,
        bytes32[] memory merkleProof
    ) external payable returns (uint256);

    /// @notice Function to return the global sales details for the given drop
    function saleDetails() external view returns (ERC20SaleDetails memory);

    /// @notice Function to return the specific sales details for a given address
    /// @param minter address for minter to return mint information for
    function mintedPerAddress(
        address minter
    ) external view returns (AddressMintDetails memory);

    /// @notice This is the opensea/public owner setting that can be set by the contract admin
    function owner() external view returns (address);

    /// @notice Update the metadata renderer
    /// @param newRenderer new address for renderer
    /// @param setupRenderer data to call to bootstrap data for the new renderer (optional)
    function setMetadataRenderer(
        IMetadataRenderer newRenderer,
        bytes memory setupRenderer
    ) external;

    /// @notice This is an admin mint function to mint a quantity to a specific address
    /// @param to address to mint to
    /// @param quantity quantity to mint
    /// @return the id of the first minted NFT
    function adminMint(address to, uint256 quantity) external returns (uint256);

    /// @notice This is an admin mint function to mint a single nft each to a list of addresses
    /// @param to list of addresses to mint an NFT each to
    /// @return the id of the first minted NFT
    function adminMintAirdrop(address[] memory to) external returns (uint256);

    /// @dev Getter for admin role associated with the contract to handle metadata
    /// @return boolean if address is admin
    function isAdmin(address user) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title FriendsAndFamilyMinter Interface
/// @notice This interface defines the functions and events for the FriendsAndFamilyMinter contract.
interface IFriendsAndFamilyMinter {
    // Events
    error MissingDiscount();
    error ExistingDiscount();

    // Functions

    /// @dev Checks if the specified recipient has a discount.
    /// @param recipient The address of the recipient to check for the discount.
    /// @return A boolean indicating whether the recipient has a discount or not.
    function hasDiscount(address recipient) external view returns (bool);

    /// @dev Retrieves the address of the Cre8orsNFT contract used by the FriendsAndFamilyMinter.
    /// @return The address of the Cre8orsNFT contract.
    function cre8orsNFT() external view returns (address);

    /// @dev Retrieves the address of the MinterUtilities contract used by the FriendsAndFamilyMinter.
    /// @return The address of the MinterUtilities contract.
    function minterUtilityContractAddress() external view returns (address);

    /// @dev Retrieves the maximum number of tokens claimed for free by the specified recipient.
    /// @param recipient The address of the recipient to query for the maximum claimed free tokens.
    /// @return The maximum number of tokens claimed for free by the recipient.
    function totalClaimed(address recipient) external view returns (uint256);

    /// @dev Mints a new token for the specified recipient and returns the token ID.
    /// @param recipient The address of the recipient who will receive the minted token.
    /// @return The token ID of the minted token.
    function mint(address recipient) external returns (uint256);

    /// @dev Grants a discount to the specified recipient, allowing them to mint tokens without paying the regular price.
    /// @param recipient The address of the recipient who will receive the discount.
    function addDiscount(address recipient) external;

    /// @dev Grants a discount to the specified recipient, allowing them to mint tokens without paying the regular price.
    /// @param recipient The address of the recipients who will receive the discount.
    function addDiscount(address[] memory recipient) external;

    /// @dev Removes the discount from the specified recipient, preventing them from minting tokens with a discount.
    /// @param recipient The address of the recipient whose discount will be removed.
    function removeDiscount(address recipient) external;

    /// @dev Sets a new address for the MinterUtilities contract.
    /// @param _newMinterUtilityContractAddress The address of the new MinterUtilities contract.
    function setNewMinterUtilityContractAddress(
        address _newMinterUtilityContractAddress
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/**
 ██████╗██████╗ ███████╗ █████╗  ██████╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝
██║     ██████╔╝█████╗  ╚█████╔╝██║   ██║██████╔╝███████╗
██║     ██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██╗╚════██║
╚██████╗██║  ██║███████╗╚█████╔╝╚██████╔╝██║  ██║███████║
 ╚═════╝╚═╝  ╚═╝╚══════╝ ╚════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝                                                     
 */
interface ILockup {
    /// @notice Storage for token edition information
    struct TokenLockupInfo {
        uint64 unlockDate;
        uint256 priceToUnlock;
    }

    /// @notice Locked
    error Lockup_Locked();

    /// @notice Wrong price for unlock
    error Unlock_WrongPrice(uint256 correctPrice);

    /// @notice Event for updated Lockup
    event TokenLockupUpdated(
        address indexed target,
        uint256 tokenId,
        uint64 unlockDate,
        uint256 priceToUnlock
    );

    /// @notice retrieves locked state for token
    function isLocked(address, uint256) external view returns (bool);

    /// @notice retieves unlock date for token
    function unlockInfo(
        address,
        uint256
    ) external view returns (TokenLockupInfo memory);

    /// @notice sets unlock tier for token
    function setUnlockInfo(address, uint256, bytes memory) external;

    /// @notice pay to unlock a locked token
    function payToUnlock(address payable, uint256) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/**
 ██████╗██████╗ ███████╗ █████╗  ██████╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝
██║     ██████╔╝█████╗  ╚█████╔╝██║   ██║██████╔╝███████╗
██║     ██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██╗╚════██║
╚██████╗██║  ██║███████╗╚█████╔╝╚██████╔╝██║  ██║███████║
 ╚═════╝╚═╝  ╚═╝╚══════╝ ╚════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝                                                     
 */

/// @dev credit: https://github.com/ourzora/zora-drops-contracts
interface IMetadataRenderer {
    function tokenURI(uint256) external view returns (string memory);

    function contractURI() external view returns (string memory);

    function initializeWithData(bytes memory initData) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/**
 * @title Minter Utilities Interface
 * @notice Interface for the MinterUtilities contract, which provides utility functions for the minter.
 */
interface IMinterUtilities {
    /**
     * @dev Emitted when the price of a tier is updated.
     * @param tier The tier whose price is updated.
     * @param price The new price for the tier.
     */
    event TierPriceUpdated(uint256 tier, uint256 price);

    /**
     * @dev Emitted when the lockup period of a tier is updated.
     * @param tier The tier whose lockup period is updated.
     * @param lockup The new lockup period for the tier.
     */
    event TierLockupUpdated(uint256 tier, uint256 lockup);

    /**
     * @dev Represents pricing and lockup information for a specific tier.
     */
    struct TierInfo {
        uint256 price;
        uint256 lockup;
    }

    /**
     * @dev Represents a tier and quantity of NFTs.
     */
    struct Cart {
        uint8 tier;
        uint256 quantity;
    }

    /**
     * @notice Calculates the total price for a given quantity of NFTs in a specific tier.
     * @param tier The tier to calculate the price for.
     * @param quantity The quantity of NFTs to calculate the price for.
     * @return The total price in wei for the given quantity in the specified tier.
     */
    function calculatePrice(
        uint8 tier,
        uint256 quantity
    ) external view returns (uint256);

    /**
     * @notice Returns the quantity of NFTs left that can be minted by the given recipient.
     * @param passportHolderMinter The address of the PassportHolderMinter contract.
     * @param friendsAndFamilyMinter The address of the FriendsAndFamilyMinter contract.
     * @param target The address of the target contract (ICre8ors contract).
     * @param recipient The recipient's address.
     * @return The quantity of NFTs that can still be minted by the recipient.
     */
    function quantityLeft(
        address passportHolderMinter,
        address friendsAndFamilyMinter,
        address target,
        address recipient
    ) external view returns (uint256);

    /**
     * @notice Calculates the total cost for a given list of NFTs in different tiers.
     * @param carts An array of Cart struct representing the tiers and quantities.
     * @return The total cost in wei for the given list of NFTs.
     */
    function calculateTotalCost(
        uint256[] memory carts
    ) external view returns (uint256);

    /**
     * @dev Calculates the unlock price for a given tier and minting option.
     * @param tier The tier for which to calculate the unlock price.
     * @param freeMint A boolean flag indicating whether the minting option is free or not.
     * @return The calculated unlock price in wei.
     */
    function calculateUnlockPrice(
        uint8 tier,
        bool freeMint
    ) external view returns (uint256);

    /**
     * @notice Calculates the lockup period for a specific tier.
     * @param tier The tier to calculate the lockup period for.
     * @return The lockup period in seconds for the specified tier.
     */
    function calculateLockupDate(uint8 tier) external view returns (uint256);

    /**
     * @notice Calculates the total quantity of NFTs in a given list of Cart structs.
     * @param carts An array of Cart struct representing the tiers and quantities.
     * @return Total quantity of NFTs in the given list of carts.
     */

    function calculateTotalQuantity(
        uint256[] memory carts
    ) external view returns (uint256);

    /**
     * @notice Updates the prices for all tiers in the MinterUtilities contract.
     * @param tierPrices A bytes array representing the new prices for all tiers (in wei).
     */
    function updateAllTierPrices(bytes calldata tierPrices) external;

    /**
     * @notice Sets new default lockup periods for all tiers.
     * @param lockupInfo A bytes array representing the new lockup periods for all tiers (in seconds).
     */
    function setNewDefaultLockups(bytes calldata lockupInfo) external;

    /**
     * @notice Retrieves tier information for a specific tier ID.
     * @param tierId The ID of the tier to get information for.
     * @return TierInfo tier information struct containing lockup duration and unlock price in wei.
     */
    function getTierInfo(uint8 tierId) external view returns (TierInfo memory);

    /**
     * @notice Retrieves all tier information.
     * @return bytes data of tier information struct containing lockup duration and unlock price in wei.
     */
    function getTierInfo() external view returns (bytes memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import {IMinterUtilities} from "../interfaces/IMinterUtilities.sol";

interface ISharedPaidMinterFunctions {
    error InvalidTier();

    error InvalidArrayLength();
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {MinterUtilities} from "../utils/MinterUtilities.sol";
import {ICre8ors} from "../interfaces/ICre8ors.sol";
import {ILockup} from "../interfaces/ILockup.sol";
import {IERC721A} from "lib/ERC721A/contracts/interfaces/IERC721A.sol";
import {IERC721Drop} from "../interfaces/IERC721Drop.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IMinterUtilities} from "../interfaces/IMinterUtilities.sol";
import {IFriendsAndFamilyMinter} from "../interfaces/IFriendsAndFamilyMinter.sol";
import {ICollectionHolderMint} from "../interfaces/ICollectionHolderMint.sol";
import {SharedPaidMinterFunctions} from "../utils/SharedPaidMinterFunctions.sol";

contract AllowlistMinter is SharedPaidMinterFunctions {
    constructor(
        address _cre8orsNFT,
        address _minterUtility,
        address _collectionHolderMint,
        address _friendsAndFamilyMinter
    ) {
        cre8orsNFT = _cre8orsNFT;
        minterUtility = _minterUtility;
        collectionHolderMint = _collectionHolderMint;
        friendsAndFamilyMinter = _friendsAndFamilyMinter;
    }

    function mintPfp(
        address recipient,
        uint256[] memory carts,
        bytes32[] calldata merkleProof
    )
        external
        payable
        arrayLengthMustBe3(carts)
        onlyPreSaleOrAlreadyMinted(recipient)
        checkProof(recipient, merkleProof)
        verifyCost(carts)
        returns (uint256)
    {
        uint256 quantity = calculateTotalQuantity(carts);
        address _recipient = recipient; /// @dev to avoid stack too deep error
        if (
            quantity >
            IMinterUtilities(minterUtility).quantityLeft(
                collectionHolderMint,
                friendsAndFamilyMinter,
                cre8orsNFT,
                _recipient
            )
        ) {
            revert IERC721Drop.Presale_TooManyForAddress();
        }

        uint256 pfpTokenId = ICre8ors(cre8orsNFT).adminMint(
            _recipient,
            quantity
        );
        payable(address(cre8orsNFT)).call{value: msg.value}("");

        _lockUp(carts, pfpTokenId - quantity + 1);

        return pfpTokenId;
    }

    modifier checkProof(address _recipient, bytes32[] calldata merkleProof) {
        if (
            !MerkleProof.verify(
                merkleProof,
                IERC721Drop(cre8orsNFT).saleDetails().presaleMerkleRoot,
                keccak256(
                    abi.encode(
                        _recipient,
                        uint256(8),
                        uint256(150000000000000000)
                    )
                )
            )
        ) {
            revert IERC721Drop.Presale_MerkleNotApproved();
        }
        _;
    }

    modifier onlyPreSaleOrAlreadyMinted(address recipient) {
        if (
            ICre8ors(cre8orsNFT).saleDetails().presaleStart > block.timestamp &&
            ICre8ors(cre8orsNFT).mintedPerAddress(recipient).totalMints == 0
        ) {
            revert IERC721Drop.Presale_Inactive();
        }
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IERC721A} from "lib/ERC721A/contracts/interfaces/IERC721A.sol";
import {ICre8ors} from "../interfaces/ICre8ors.sol";
import {IERC721Drop} from "../interfaces/IERC721Drop.sol";
import {ILockup} from "../interfaces/ILockup.sol";
import {IMinterUtilities} from "../interfaces/IMinterUtilities.sol";
import {IFriendsAndFamilyMinter} from "../interfaces/IFriendsAndFamilyMinter.sol";
import {IERC721ACH} from "ERC721H/interfaces/IERC721ACH.sol";

contract FriendsAndFamilyMinter is IFriendsAndFamilyMinter {
    ///@notice Mapping to track whether an address has discount for free mint.
    mapping(address => bool) public hasDiscount;

    ///@notice The address of the collection contract that mints and manages the tokens.
    address public cre8orsNFT;
    ///@notice The address of the minter utility contract that contains shared utility info.
    address public minterUtilityContractAddress;

    ///@notice mapping of address to quantity of free mints claimed.
    mapping(address => uint256) public totalClaimed;

    constructor(address _cre8orsNFT, address _minterUtilityContractAddress) {
        cre8orsNFT = _cre8orsNFT;
        minterUtilityContractAddress = _minterUtilityContractAddress;
    }

    /// @dev Mints a new token for the specified recipient and performs additional actions, such as setting the lockup (if applicable).
    /// @param recipient The address of the recipient who will receive the minted token.
    /// @return The token ID of the minted token.
    function mint(
        address recipient
    ) external onlyExistingDiscount(recipient) returns (uint256) {
        // Mint the token
        uint256 pfpTokenId = ICre8ors(cre8orsNFT).adminMint(recipient, 1);
        totalClaimed[recipient] += 1;

        // Reset discount for the recipient
        hasDiscount[recipient] = false;

        // Set lockup information (optional)
        IMinterUtilities minterUtility = IMinterUtilities(
            minterUtilityContractAddress
        );
        uint256 lockupDate = block.timestamp + 8 weeks;
        uint256 unlockPrice = minterUtility.getTierInfo(3).price;
        bytes memory data = abi.encode(lockupDate, unlockPrice);
        uint256[] memory tokenIDs = new uint256[](1);
        tokenIDs[0] = pfpTokenId;
        ICre8ors(
            IERC721ACH(cre8orsNFT).getHook(
                IERC721ACH.HookType.BeforeTokenTransfers
            )
        ).cre8ing().inializeStakingAndLockup(cre8orsNFT, tokenIDs, data);

        // Return the token ID of the minted token
        return pfpTokenId;
    }

    /// @dev Grants a discount to the specified recipient, allowing them to mint tokens without paying the regular price.
    /// @param recipient The address of the recipient who will receive the discount.
    function addDiscount(address recipient) external onlyAdmin {
        if (hasDiscount[recipient]) {
            revert ExistingDiscount();
        }
        hasDiscount[recipient] = true;
    }

    /// @dev Grants a discount to the specified array of recipients, allowing them to mint tokens without paying the regular price.
    /// @param recipient The address of the recipients who will receive the discount.
    function addDiscount(address[] memory recipient) external onlyAdmin {
        for (uint256 i = 0; i < recipient.length; ) {
            if (!hasDiscount[recipient[i]]) {
                hasDiscount[recipient[i]] = true;
            }
            unchecked {
                i += 1;
            }
        }
    }

    /// @dev Removes the discount from the specified recipient, preventing them from minting tokens with a discount.
    /// @param recipient The address of the recipient whose discount will be removed.
    function removeDiscount(
        address recipient
    ) external onlyAdmin onlyExistingDiscount(recipient) {
        hasDiscount[recipient] = false;
    }

    /// @dev Sets a new address for the MinterUtilities contract.
    /// @param _newMinterUtilityContractAddress The address of the new MinterUtilities contract.
    function setNewMinterUtilityContractAddress(
        address _newMinterUtilityContractAddress
    ) external onlyAdmin {
        minterUtilityContractAddress = _newMinterUtilityContractAddress;
    }

    /// @dev Modifier that restricts access to only the contract's admin.
    modifier onlyAdmin() {
        if (!ICre8ors(cre8orsNFT).isAdmin(msg.sender)) {
            revert IERC721Drop.Access_OnlyAdmin();
        }
        _;
    }

    /// @dev Modifier that checks if the specified recipient has a discount.
    /// @param recipient The address of the recipient to check for the discount.
    modifier onlyExistingDiscount(address recipient) {
        if (!hasDiscount[recipient]) {
            revert MissingDiscount();
        }
        _;
    }
}
/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title ISubscription
/// @dev Interface for managing subscriptions to NFTs.
interface ISubscription {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice The subscription associated with the provided token ID is invalid or has expired.
    error InvalidSubscription();

    /// @notice Attempting to set a subscription contract address with a zero address value.
    error SubscriptionCannotBeZeroAddress();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @dev Emitted when the renewability status of subscriptions is updated.
    event RenewableUpdate(bool renewable);

    /// @dev Emitted when the minimum duration for subscription renewal is updated.
    event MinRenewalDurationUpdate(uint64 duration);

    /// @dev Emitted when the maximum duration for subscription renewal is updated.
    event MaxRenewalDurationUpdate(uint64 duration);

    /*//////////////////////////////////////////////////////////////
                           CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Checks the subscription for the given `tokenId`.
    /// Throws if `tokenId` subscription has expired.
    /// @param tokenId The unique identifier of the NFT token.
    function checkSubscription(uint256 tokenId) external view;

    /// @notice Returns whether the subscription for the given `tokenId` is valid.
    /// @param tokenId The unique identifier of the NFT token.
    /// @return A boolean indicating if the subscription is valid.
    function isSubscriptionValid(uint256 tokenId) external view returns (bool);

    /*//////////////////////////////////////////////////////////////
                         NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*//////////   updateSubscriptionForFree variants   //////////*/

    /// @notice Extends the subscription for the given `tokenId` with a specified `duration` for free.
    /// @dev This function is meant to be called by the minter when minting the NFT to subscribe.
    /// @param target The address of the contract implementing the access control
    /// @param duration The duration (in seconds) to extend the subscription for.
    /// @param tokenId The unique identifier of the NFT token to be subscribed.
    function updateSubscriptionForFree(address target, uint64 duration, uint256 tokenId) external;

    /// @notice Extends the subscription for the given `tokenIds` with a specified `duration` for free.
    /// @dev This function is meant to be called by the minter when minting the NFT to subscribe.
    /// @param target The address of the contract implementing the access control
    /// @param duration The duration (in seconds) to extend the subscription for.
    /// @param tokenIds An array of unique identifiers of the NFT tokens to update the subscriptions for.
    function updateSubscriptionForFree(address target, uint64 duration, uint256[] calldata tokenIds) external;

    /*//////////////   updateSubscription variants   /////////////*/

    /// @notice Extends the subscription for the given `tokenId` with a specified `duration`, using native currency as
    /// payment.
    /// @dev This function is meant to be called by the minter when minting the NFT to subscribe.
    /// @param target The address of the contract implementing the access control
    /// @param duration The duration (in seconds) to extend the subscription for.
    /// @param tokenId The unique identifier of the NFT token to be subscribed.
    function updateSubscription(address target, uint64 duration, uint256 tokenId) external payable;

    /// @notice Extends the subscription for the given `tokenIds` with a specified `duration`, using native currency as
    /// payment.
    /// @dev This function is meant to be called by the minter when minting the NFT to subscribe.
    /// @param target The address of the contract implementing the access control
    /// @param duration The duration (in seconds) to extend the subscription for.
    /// @param tokenIds An array of unique identifiers of the NFT tokens to update the subscriptions for.
    function updateSubscription(address target, uint64 duration, uint256[] calldata tokenIds) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import {IERC721A} from "lib/ERC721A/contracts/interfaces/IERC721A.sol";
import {ICre8ors} from "../interfaces/ICre8ors.sol";
import {IERC721Drop} from "../interfaces/IERC721Drop.sol";
import {ICollectionHolderMint} from "../interfaces/ICollectionHolderMint.sol";
import {FriendsAndFamilyMinter} from "../minter/FriendsAndFamilyMinter.sol";
import {IMinterUtilities} from "../interfaces/IMinterUtilities.sol";

contract MinterUtilities is IMinterUtilities {
    /// @dev The maximum quantity allowed for each address in the whitelist.
    uint256 public maxAllowlistQuantity = 8;

    /// @dev The maximum quantity allowed for public minting.
    uint256 public maxPublicMintQuantity = 18;

    /// @dev The address of the collection contract.
    address public cre8orsNFT;

    /// @dev Mapping to store tier information for each tier represented by an integer key.
    /// @notice Tier information includes price and lockup details.
    mapping(uint8 => TierInfo) public tierInfo;

    constructor(
        address _cre8orsNFT,
        uint256 _tier1Price,
        uint256 _tier2Price,
        uint256 _tier3Price
    ) {
        cre8orsNFT = _cre8orsNFT;
        tierInfo[1] = TierInfo(_tier1Price, 32 weeks);
        tierInfo[2] = TierInfo(_tier2Price, 8 weeks);
        tierInfo[3] = TierInfo(_tier3Price, 0 weeks);
    }

    /// @dev Calculates the total price based on the tier and quantity of items to be purchased.
    /// @param tier The tier of the item.
    /// @param quantity The quantity of the items to be purchased.
    /// @return The total price for the specified tier and quantity.
    function calculatePrice(
        uint8 tier,
        uint256 quantity
    ) public view returns (uint256) {
        uint256 tierPrice = tier > 0 && tier < 4
            ? tierInfo[tier].price
            : tierInfo[3].price;
        uint256 price = tierPrice * quantity;
        return price;
    }

    /// @dev Retrieves the quantity of items remaining that can be minted by the specified recipient.
    /// @param passportHolderMinter The address of the passport holder minter contract.
    /// @param friendsAndFamilyMinter The address of the friends and family minter contract.
    /// @param target The address of the ICre8ors contract.
    /// @param recipient The recipient address for which the quantity is to be calculated.
    /// @return The quantity of items that can be minted by the specified recipient.
    function quantityLeft(
        address passportHolderMinter,
        address friendsAndFamilyMinter,
        address target,
        address recipient
    ) external view returns (uint256) {
        ICre8ors cre8ors = ICre8ors(target);
        ICollectionHolderMint passportMinter = ICollectionHolderMint(
            passportHolderMinter
        );
        FriendsAndFamilyMinter friendsAndFamily = FriendsAndFamilyMinter(
            friendsAndFamilyMinter
        );

        uint256 totalMints = cre8ors.mintedPerAddress(recipient).totalMints;
        uint256 totalClaimed = passportMinter.totalClaimed(recipient) +
            friendsAndFamily.totalClaimed(recipient);
        uint256 maxQuantity = maxAllowedQuantity(totalClaimed);

        if (maxQuantity < totalMints) {
            return 0;
        }
        return maxQuantity - totalMints;
    }

    /// @dev Calculates the total cost of all items in the given carts array.
    /// @param carts An array of Cart structs containing information about each item in the cart.
    /// @return The total cost of all items in the carts array.
    function calculateTotalCost(
        uint256[] memory carts
    ) external view returns (uint256) {
        uint256 totalCost = 0;
        for (uint256 i = 0; i < carts.length; i++) {
            totalCost += calculatePrice(uint8(i + 1), carts[i]);
        }
        return totalCost;
    }

    /// @dev Calculates the lockup date for a given tier.
    /// @param tier The tier for which the lockup date is being calculated.
    /// @return The lockup date for the specified tier, expressed as a Unix timestamp.
    function calculateLockupDate(uint8 tier) external view returns (uint256) {
        return block.timestamp + tierInfo[tier].lockup;
    }

    /// @dev Calculates the total quantity of items across all carts.
    /// @param carts An array of Cart structs containing information about each item in the cart.
    /// @return uint256 total quantity of items across all carts.
    function calculateTotalQuantity(
        uint256[] memory carts
    ) public pure returns (uint256) {
        uint256 totalQuantity = 0;
        for (uint256 i = 0; i < carts.length; i++) {
            totalQuantity += carts[i];
        }
        return totalQuantity;
    }

    /**
     * @dev Calculates the unlock price for a given tier and minting option.
     * @param tier The tier for which to calculate the unlock price.
     * @param freeMint A boolean flag indicating whether the minting option is free or not.
     * @return The calculated unlock price in wei.
     */
    function calculateUnlockPrice(
        uint8 tier,
        bool freeMint
    ) external view returns (uint256) {
        if (freeMint) {
            return tierInfo[3].price - tierInfo[1].price;
        } else {
            return tierInfo[3].price - tierInfo[tier].price;
        }
    }

    /// @dev Updates the prices for all tiers.
    /// @param tierPrices A bytes array containing the new prices for tier 1, tier 2, and tier 3.
    ///                  The bytes array should be encoded using the `abi.encode` function with three uint256 values
    ///                  corresponding to the prices of tier 1, tier 2, and tier 3, respectively.
    /// @notice This function can only be called by the contract's admin.
    function updateAllTierPrices(bytes calldata tierPrices) external onlyAdmin {
        (uint256 tier1, uint256 tier2, uint256 tier3) = abi.decode(
            tierPrices,
            (uint256, uint256, uint256)
        );
        tierInfo[1].price = tier1;
        tierInfo[2].price = tier2;
        tierInfo[3].price = tier3;
    }

    /// @dev Sets new default lockup periods for all tiers.
    /// @param lockupInfo A bytes array containing the new lockup periods for tier 1, tier 2, and tier 3.
    ///                   The bytes array should be encoded using the `abi.encode` function with three uint256 values
    ///                   corresponding to the lockup periods of tier 1, tier 2, and tier 3, respectively.
    /// @notice This function can only be called by the contract's admin.
    function setNewDefaultLockups(
        bytes calldata lockupInfo
    ) external onlyAdmin {
        (uint256 tier1, uint256 tier2, uint256 tier3) = abi.decode(
            lockupInfo,
            (uint256, uint256, uint256)
        );
        tierInfo[1].lockup = tier1;
        tierInfo[2].lockup = tier2;
        tierInfo[3].lockup = tier3;
    }

    /// @dev Retrieves tier information for a given tier.
    /// @param tier The tier for which the information is being retrieved.
    /// @return TierInfo struct containing price and lockup information for the specified tier.
    function getTierInfo(uint8 tier) external view returns (TierInfo memory) {
        return tierInfo[tier];
    }

    /// @dev Retrieves tier information for all tiers.
    /// @return A bytes array containing the tier information for all tiers.
    function getTierInfo() external view returns (bytes memory) {
        TierInfo[] memory tierInfoArray = new TierInfo[](3);
        tierInfoArray[0] = tierInfo[1];
        tierInfoArray[1] = tierInfo[2];
        tierInfoArray[2] = tierInfo[3];
        return abi.encode(tierInfoArray);
    }

    /// @dev allows user to convert tier prices or tier unlock periods to bytes for using in update functions.
    /// @param tierOne The price(in wei) or lockup period (in seconds) for tier 1.
    /// @param tierTwo The price(in wei) or lockup period (in seconds) for tier 2.
    /// @param tierThree The price(in wei) or lockup period (in seconds) for tier 3.
    function convertTierInfoToBytes(
        uint256 tierOne,
        uint256 tierTwo,
        uint256 tierThree
    ) external pure returns (bytes memory) {
        return abi.encode(tierOne, tierTwo, tierThree);
    }

    /// @dev Updates the maximum allowed quantity for the whitelist.
    /// @param _maxAllowlistQuantity The new maximum allowed quantity for the whitelist.
    /// @notice This function can only be called by the contract's admin.
    function updateMaxAllowlistQuantity(
        uint256 _maxAllowlistQuantity
    ) external onlyAdmin {
        maxAllowlistQuantity = _maxAllowlistQuantity;
    }

    /// @dev Updates the maximum allowed quantity for the public mint.
    /// @param _maxPublicMintQuantity The new maximum allowed quantity for the public mint.
    /// @notice This function can only be called by the contract's admin.
    function updateMaxPublicMintQuantity(
        uint256 _maxPublicMintQuantity
    ) external onlyAdmin {
        maxPublicMintQuantity = _maxPublicMintQuantity;
    }

    //////////////////////////
    // MODIFIERS //
    //////////////////////////
    /// @dev Modifier that restricts access to only the contract's admin.
    modifier onlyAdmin() {
        require(
            ICre8ors(cre8orsNFT).isAdmin(msg.sender),
            "IERC721Drop: Access restricted to admin"
        );
        _;
    }

    //////////////////////////
    // INTERNAL FUNCTIONS ////
    //////////////////////////

    /// @dev Calculates the maximum allowed quantity based on the current timestamp and the public sale start time.
    /// @param totalClaimedFree The base starting point for calculating the maximum allowed quantity.
    /// @return The maximum allowed quantity based on the current timestamp and the public sale start time.
    function maxAllowedQuantity(
        uint256 totalClaimedFree
    ) internal view returns (uint256) {
        uint256 currentTimestamp = block.timestamp;
        uint256 publicSaleStart = ICre8ors(cre8orsNFT)
            .saleDetails()
            .publicSaleStart;
        if (currentTimestamp < publicSaleStart) {
            return maxAllowlistQuantity + totalClaimedFree;
        }
        if (totalClaimedFree > 0) {
            return
                maxAllowlistQuantity + maxPublicMintQuantity + totalClaimedFree;
        }
        return maxPublicMintQuantity + totalClaimedFree;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import {IMinterUtilities} from "../interfaces/IMinterUtilities.sol";
import {ILockup} from "../interfaces/ILockup.sol";
import {ICre8ors} from "../interfaces/ICre8ors.sol";
import {IERC721Drop} from "../interfaces/IERC721Drop.sol";
import {ICre8ing} from "../interfaces/ICre8ing.sol";
import {ISharedPaidMinterFunctions} from "../interfaces/ISharedPaidMinterFunctions.sol";
import {IERC721ACH} from "ERC721H/interfaces/IERC721ACH.sol";

contract SharedPaidMinterFunctions is ISharedPaidMinterFunctions {
    address public cre8orsNFT;
    address public minterUtility;
    address public collectionHolderMint;
    address public friendsAndFamilyMinter;

    modifier arrayLengthMustBe3(uint256[] memory array) {
        if (array.length != 3) {
            revert ISharedPaidMinterFunctions.InvalidArrayLength();
        }
        _;
    }
    modifier verifyCost(uint256[] memory carts) {
        uint256 totalCost = IMinterUtilities(minterUtility).calculateTotalCost(
            carts
        );
        if (msg.value < totalCost) {
            revert IERC721Drop.Purchase_WrongPrice(totalCost);
        }
        _;
    }
    modifier onlyValidTier(uint256 tier) {
        if (tier < 1 || tier > 3) {
            revert InvalidTier();
        }
        _;
    }
    /// @dev Modifier that restricts access to only the contract's admin.
    modifier onlyAdmin() {
        if (!ICre8ors(cre8orsNFT).isAdmin(msg.sender)) {
            revert IERC721Drop.Access_OnlyAdmin();
        }
        _;
    }

    function calculateTotalQuantity(
        uint256[] memory carts
    ) internal pure returns (uint256) {
        uint256 totalQuantity;
        for (uint256 i = 0; i < carts.length; i++) {
            totalQuantity += carts[i];
        }
        return totalQuantity;
    }

    function _lockUp(uint256[] memory carts, uint256 startingTokenId) internal {
        uint256 tokenId = startingTokenId;
        IMinterUtilities.TierInfo[] memory tiers = abi.decode(
            IMinterUtilities(minterUtility).getTierInfo(),
            (IMinterUtilities.TierInfo[])
        );
        for (uint256 i = 0; i < carts.length; i++) {
            if (i == 3 || carts[i] == 0) {
                continue;
            }
            uint256[] memory tokenIds = new uint256[](carts[i]);
            for (uint256 j = 0; j < carts[i]; j++) {
                tokenIds[j] = tokenId;
                tokenId++;
            }
            ICre8ors(
                IERC721ACH(cre8orsNFT).getHook(
                    IERC721ACH.HookType.BeforeTokenTransfers
                )
            ).cre8ing().inializeStakingAndLockup(
                    cre8orsNFT,
                    tokenIds,
                    _getLockUpDateAndPrice(tiers, i + 1)
                );
        }
    }

    function _getLockUpDateAndPrice(
        IMinterUtilities.TierInfo[] memory tiers,
        uint256 tier
    ) internal view onlyValidTier(tier) returns (bytes memory) {
        IMinterUtilities.TierInfo memory selectedTier = tiers[tier - 1];
        uint256 lockupDate = block.timestamp + selectedTier.lockup;
        uint256 tierPrice = selectedTier.price;

        return abi.encode(lockupDate, tierPrice);
    }
}