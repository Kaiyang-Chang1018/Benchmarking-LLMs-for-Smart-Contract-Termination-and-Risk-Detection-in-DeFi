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

import {ICollectionHolderMint} from "../interfaces/ICollectionHolderMint.sol";
import {ICre8ors} from "../interfaces/ICre8ors.sol";
import {IERC721A} from "lib/ERC721A/contracts/interfaces/IERC721A.sol";
import {IERC721Drop} from "../interfaces/IERC721Drop.sol";
import {IFriendsAndFamilyMinter} from "../interfaces/IFriendsAndFamilyMinter.sol";
import {IMinterUtilities} from "../interfaces/IMinterUtilities.sol";
import {IERC721ACH} from "ERC721H/interfaces/IERC721ACH.sol";

contract CollectionHolderMint is ICollectionHolderMint {
    ///@notice Mapping to track whether a specific uint256 value (token ID) has been claimed or not.
    mapping(uint256 => bool) public freeMintClaimed;

    ///@notice The address of the collection contract that mints and manages the tokens.
    address public cre8orsNFTContractAddress;

    ///@notice The address of the passport contract.
    address public passportContractAddress;

    ///@notice The address of the minter utility contract that contains shared utility info.
    address public minterUtilityContractAddress;

    ///@notice The address of the friends and family minter contract.
    address public friendsAndFamilyMinterContractAddress;

    ///@notice mapping of address to quantity of free mints claimed.
    mapping(address => uint256) public totalClaimed;

    /**
     * @notice Constructs a new CollectionHolderMint contract.
     * @param _cre8orsNFTContractAddress The address of the collection contract that mints and manages the tokens.
     * @param _passportContractAddress The address of the passport contract.
     * @param _minterUtility The address of the minter utility contract that contains shared utility info.
     * @param _friendsAndFamilyMinterContractAddress The address of the friends and family minter contract.
     */
    constructor(
        address _cre8orsNFTContractAddress,
        address _passportContractAddress,
        address _minterUtility,
        address _friendsAndFamilyMinterContractAddress
    ) {
        cre8orsNFTContractAddress = _cre8orsNFTContractAddress;
        passportContractAddress = _passportContractAddress;
        minterUtilityContractAddress = _minterUtility;
        friendsAndFamilyMinterContractAddress = _friendsAndFamilyMinterContractAddress;
    }

    /**
     * @dev Mint function to create a new token, assign it to the specified recipient, and trigger additional actions.
     *
     * This function creates a new token with the given `tokenId` and assigns it to the `recipient` address.
     * It requires the `tokenId` to be eligible for a free mint, and the caller must be the owner of the specified `tokenId`
     * to successfully execute the minting process.
     *
     * @param passportTokenIDs The IDs of passports.
     * @param recipient The address to whom the newly minted token will be assigned.
     * @return pfpTokenId The ID of the corresponding PFP token that was minted for the `recipient`.
     *
     */
    function mint(
        uint256[] calldata passportTokenIDs,
        address recipient
    )
        external
        tokensPresentInList(passportTokenIDs)
        noDuplicates(passportTokenIDs)
        onlyTokenOwner(passportTokenIDs, recipient)
        hasFreeMint(passportTokenIDs)
        returns (uint256)
    {
        _friendsAndFamilyMint(recipient);

        return _passportMint(passportTokenIDs, recipient);
    }

    /**
     * @notice Toggle the free mint claim status of a token.
     * @param tokenId Passport token ID to toggle free mint claim status.
     */
    function toggleHasClaimedFreeMint(uint256 tokenId) external onlyAdmin {
        freeMintClaimed[tokenId] = !freeMintClaimed[tokenId];
    }

    ////////////////////////////////////////
    ////////////// MODIFIERS //////////////
    ///////////////////////////////////////

    /**
     * @dev Modifier to ensure the caller owns the specified tokens or has appropriate approval.
     * @param passportTokenIDs An array of token IDs.
     * @param recipient The recipient address.
     */
    modifier onlyTokenOwner(
        uint256[] calldata passportTokenIDs,
        address recipient
    ) {
        for (uint256 i = 0; i < passportTokenIDs.length; i++) {
            if (
                IERC721A(passportContractAddress).ownerOf(
                    passportTokenIDs[i]
                ) != recipient
            ) {
                revert IERC721A.ApprovalCallerNotOwnerNorApproved();
            }
        }
        _;
    }

    /**
     * @dev Modifier to ensure the caller is an admin.
     */
    modifier onlyAdmin() {
        if (!ICre8ors(cre8orsNFTContractAddress).isAdmin(msg.sender)) {
            revert IERC721Drop.Access_OnlyAdmin();
        }

        _;
    }

    /**
     * @dev Modifier to ensure the specified token IDs are not duplicates.
     */
    modifier noDuplicates(uint[] calldata _passportpassportTokenIDs) {
        if (_hasDuplicates(_passportpassportTokenIDs)) {
            revert DuplicatesFound();
        }
        _;
    }
    /**
     * @dev Modifier to ensure the specified token IDs are eligible for a free mint.
     * @param passportTokenIDs An array of token IDs.
     */
    modifier hasFreeMint(uint256[] calldata passportTokenIDs) {
        for (uint256 i = 0; i < passportTokenIDs.length; i++) {
            if (freeMintClaimed[passportTokenIDs[i]]) {
                revert AlreadyClaimedFreeMint();
            }
        }
        _;
    }

    /**
     * @dev Modifier to ensure the specified token ID list is not empty.
     * @param passportTokenIDs An array of token IDs.
     */
    modifier tokensPresentInList(uint256[] calldata passportTokenIDs) {
        if (passportTokenIDs.length == 0) {
            revert NoTokensProvided();
        }
        _;
    }

    ///////////////////////////////////////
    ////////// SETTER FUNCTIONS //////////
    /////////////////////////////////////
    /**
     * @notice Set New Minter Utility Contract Address
     * @notice Allows the admin to set a new address for the Minter Utility Contract.
     * @param _newMinterUtilityContractAddress The address of the new Minter Utility Contract.
     * @dev Only the admin can call this function.
     */
    function setNewMinterUtilityContractAddress(
        address _newMinterUtilityContractAddress
    ) external onlyAdmin {
        minterUtilityContractAddress = _newMinterUtilityContractAddress;
    }

    /**
     * @notice Set the address of the friends and family minter contract.
     * @param _newfriendsAndFamilyMinterContractAddressAddress The address of the new friends and family minter contract.
     */
    function setFriendsAndFamilyMinterContractAddress(
        address _newfriendsAndFamilyMinterContractAddressAddress
    ) external onlyAdmin {
        friendsAndFamilyMinterContractAddress = _newfriendsAndFamilyMinterContractAddressAddress;
    }

    /**
     * @notice Updates the passport contract address.
     * @dev This function can only be called by the admin.
     * @param _newPassportContractAddress The new passport contract address.
     */
    function setNewPassportContractAddress(
        address _newPassportContractAddress
    ) external onlyAdmin {
        passportContractAddress = _newPassportContractAddress;
    }

    /**
     * @notice Updates the Cre8ors NFT contract address.
     * @dev This function can only be called by the admin.
     * @param _newCre8orsNFTContractAddress The new Cre8ors NFT contract address.
     */
    function setNewCre8orsNFTContractAddress(
        address _newCre8orsNFTContractAddress
    ) external onlyAdmin {
        cre8orsNFTContractAddress = _newCre8orsNFTContractAddress;
    }

    ////////////////////////////////////////
    ////////// INTERNALFUNCTIONS //////////
    ///////////////////////////////////////

    function _setpassportTokenIDsToClaimed(
        uint256[] calldata passportTokenIDs
    ) internal {
        for (uint256 i = 0; i < passportTokenIDs.length; i++) {
            freeMintClaimed[passportTokenIDs[i]] = true;
        }
    }

    function _lockAndStakeTokens(uint256[] memory _mintedPFPTokenIDs) internal {
        IMinterUtilities minterUtility = IMinterUtilities(
            minterUtilityContractAddress
        );
        uint256 lockupDate = block.timestamp + 8 weeks;
        uint256 unlockPrice = minterUtility.getTierInfo(3).price;
        bytes memory data = abi.encode(lockupDate, unlockPrice);
        ICre8ors(
            IERC721ACH(cre8orsNFTContractAddress).getHook(
                IERC721ACH.HookType.BeforeTokenTransfers
            )
        ).cre8ing().inializeStakingAndLockup(
                cre8orsNFTContractAddress,
                _mintedPFPTokenIDs,
                data
            );
    }

    function _passportMint(
        uint256[] calldata _passportTokenIDs,
        address recipient
    ) internal returns (uint256) {
        uint256 pfpTokenId = ICre8ors(cre8orsNFTContractAddress).adminMint(
            recipient,
            _passportTokenIDs.length
        );
        uint256[] memory _pfpTokenIds = new uint256[](_passportTokenIDs.length);
        uint256 startingTokenId = pfpTokenId - _passportTokenIDs.length + 1;
        for (uint256 i = 0; i < _passportTokenIDs.length; ) {
            _pfpTokenIds[i] = startingTokenId + i;
            unchecked {
                i++;
            }
        }
        totalClaimed[recipient] += _passportTokenIDs.length;
        _lockAndStakeTokens(_pfpTokenIds);
        _setpassportTokenIDsToClaimed(_passportTokenIDs);
        return pfpTokenId;
    }

    function _friendsAndFamilyMint(address buyer) internal {
        IFriendsAndFamilyMinter ffMinter = IFriendsAndFamilyMinter(
            friendsAndFamilyMinterContractAddress
        );

        if (ffMinter.hasDiscount(buyer)) {
            ffMinter.mint(buyer);
        }
    }

    function _hasDuplicates(
        uint[] calldata values
    ) internal pure returns (bool) {
        for (uint i = 0; i < values.length; i++) {
            for (uint j = i + 1; j < values.length; j++) {
                if (values[i] == values[j]) {
                    return true;
                }
            }
        }
        return false;
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