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
pragma solidity ^0.8.15;

import {ICre8ing} from "./interfaces/ICre8ing.sol";
import {ICre8ors} from "./interfaces/ICre8ors.sol";
import {ILockup} from "./interfaces/ILockup.sol";
import {IERC721Drop} from "./interfaces/IERC721Drop.sol";
import {IERC721A} from "erc721a/contracts/IERC721A.sol";
import {MinterAdminCheck} from "./minter/MinterAdminCheck.sol";

/**
 ██████╗██████╗ ███████╗ █████╗  ██████╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝
██║     ██████╔╝█████╗  ╚█████╔╝██║   ██║██████╔╝███████╗
██║     ██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██╗╚════██║
╚██████╗██║  ██║███████╗╚█████╔╝╚██████╔╝██║  ██║███████║
 ╚═════╝╚═╝  ╚═╝╚══════╝ ╚════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝                                                       
 */
/// @dev inspiration: https://etherscan.io/address/0x23581767a106ae21c074b2276d25e5c3e136a68b#code
contract Cre8ing is ICre8ing, MinterAdminCheck {
    /// @dev tokenId to cre8ing start time (0 = not cre8ing).
    mapping(address => mapping(uint256 => uint256)) internal cre8ingStarted;
    /// @dev Cumulative per-token cre8ing, excluding the current period.
    mapping(address => mapping(uint256 => uint256)) internal cre8ingTotal;
    /// @dev Lockup for target.
    mapping(address => ILockup) public lockup;

    /// @notice Whether cre8ing is currently allowed.
    /// @dev If false then cre8ing is blocked, but uncre8ing is always allowed.
    mapping(address => bool) public cre8ingOpen;

    /// @notice Returns the length of time, in seconds, that the CRE8OR has cre8ed.
    /// @dev Cre8ing is tied to a specific CRE8OR, not to the owner, so it doesn't
    ///     reset upon sale.
    /// @param _target The target address for the CRE8OR.
    /// @param tokenId The token ID to query.
    /// @return cre8ing Whether the CRE8OR is currently cre8ing. MAY be true with
    ///     zero current cre8ing if in the same block as cre8ing began.
    /// @return current Zero if not currently cre8ing, otherwise the length of time
    ///     since the most recent cre8ing began.
    /// @return total Total period of time for which the CRE8OR has cre8ed across
    ///     its life, including the current period.
    function cre8ingPeriod(
        address _target,
        uint256 tokenId
    ) external view returns (bool cre8ing, uint256 current, uint256 total) {
        uint256 start = cre8ingStarted[_target][tokenId];
        if (start != 0) {
            cre8ing = true;
            current = block.timestamp - start;
        }
        total = current + cre8ingTotal[_target][tokenId];
    }

    /// @notice Toggles the `cre8ingOpen` flag.
    /// @param _target The target address.
    /// @param open Boolean value to open or close cre8ing.
    function setCre8ingOpen(
        address _target,
        bool open
    ) external onlyAdmin(_target) {
        cre8ingOpen[_target] = open;
    }

    /// @notice Admin-only ability to expel a CRE8OR from the Warehouse.
    /// @dev As most sales listings use off-chain signatures it's impossible to
    ///     detect someone who has cre8ed and then deliberately undercuts the floor
    ///     price in the knowledge that the sale can't proceed. This function allows for
    ///     monitoring of such practices and expulsion if abuse is detected, allowing
    ///     the undercutting CRE8OR to be sold on the open market. Since OpenSea uses
    ///     isApprovedForAll() in its pre-listing checks, we can't block by that means
    ///     because cre8ing would then be all-or-nothing for all of a particular owner's
    ///     CRE8OR.
    /// @param _target The target address.
    /// @param tokenId The token ID to expel.
    function expelFromWarehouse(
        address _target,
        uint256 tokenId
    ) external onlyAdmin(_target) {
        if (cre8ingStarted[_target][tokenId] == 0) {
            revert CRE8ING_NotCre8ing(_target, tokenId);
        }
        cre8ingTotal[_target][tokenId] +=
            block.timestamp -
            cre8ingStarted[_target][tokenId];
        cre8ingStarted[_target][tokenId] = 0;
        emit Uncre8ed(_target, tokenId);
        emit Expelled(_target, tokenId);
    }

    /// @notice Enter a CRE8OR into the warehouse.
    /// @param _target The target address.
    /// @param tokenId The token ID to enter.
    function enterWarehouse(address _target, uint256 tokenId) internal {
        if (!cre8ingOpen[_target]) {
            revert Cre8ing_Cre8ingClosed();
        }
        cre8ingStarted[_target][tokenId] = block.timestamp;
        emit Cre8ed(_target, tokenId);
    }

    /// @notice Exit a CRE8OR from the warehouse.
    /// @param _target The target address.
    /// @param tokenId The token ID to exit.
    function leaveWarehouse(address _target, uint256 tokenId) internal {
        _requireUnlocked(_target, tokenId);
        uint256 start = cre8ingStarted[_target][tokenId];
        cre8ingTotal[_target][tokenId] += block.timestamp - start;
        cre8ingStarted[_target][tokenId] = 0;
        emit Uncre8ed(_target, tokenId);
    }

    /////////////////////////////////////////////////
    /// CRE8ING
    /////////////////////////////////////////////////

    /// @notice Toggles cre8ing status for multiple tokens.
    /// @param _target The target address.
    /// @param tokenIds Array of token IDs to toggle.
    function toggleCre8ingTokens(
        address _target,
        uint256[] calldata tokenIds
    ) external {
        uint256 n = tokenIds.length;
        for (uint256 i = 0; i < n; ++i) {
            _toggleCre8ingToken(_target, tokenIds[i]);
        }
    }

    /// @notice Toggle cre8ing status for a specific token.
    /// @param _target The target address.
    /// @param tokenId The token ID to toggle.
    function _toggleCre8ingToken(
        address _target,
        uint256 tokenId
    ) internal onlyApprovedOrOwner(_target, tokenId) {
        uint256 start = cre8ingStarted[_target][tokenId];
        if (start == 0) {
            enterWarehouse(_target, tokenId);
        } else {
            leaveWarehouse(_target, tokenId);
        }
    }

    /// @notice Returns the array of staked token IDs.
    /// @param _target The target address.
    /// @return stakedTokens Array of staked token IDs.
    function cre8ingTokens(
        address _target
    ) external view returns (uint256[] memory stakedTokens) {
        uint256 size = ICre8ors(_target)._lastMintedTokenId();
        stakedTokens = new uint256[](size);
        for (uint256 i = 1; i < size + 1; ++i) {
            uint256 start = cre8ingStarted[_target][i];
            if (start != 0) {
                stakedTokens[i - 1] = i;
            }
        }
    }

    /// @notice Get the cre8ing start time for a token.
    /// @param _target The target address.
    /// @param tokenId The token ID to query.
    /// @return The cre8ing start time for the token.
    function getCre8ingStarted(
        address _target,
        uint256 tokenId
    ) external view returns (uint256) {
        return cre8ingStarted[_target][tokenId];
    }

    /////////////////////////////////////////////////
    /// LOCK UP
    /////////////////////////////////////////////////

    /// @notice Get the lockup for an address.
    /// @param _target The target address.
    /// @return The lockup contract for the address.
    function lockUp(address _target) external view returns (ILockup) {
        return lockup[_target];
    }

    /// @notice Set a new lockup for the target.
    /// @param _target The target address.
    /// @param newLockup The new lockup contract address.
    function setLockup(
        address _target,
        ILockup newLockup
    ) external onlyAdmin(_target) {
        lockup[_target] = newLockup;
    }

    function _requireUnlocked(address _target, uint256 tokenId) internal view {
        if (
            address(lockup[_target]) != address(0) &&
            lockup[_target].isLocked(_target, tokenId)
        ) {
            revert ILockup.Lockup_Locked();
        }
    }

    /// @notice Initialize both staking and lockups for a set of tokens.
    /// @param _target The target address.
    /// @param _tokenIds Array of token IDs.
    /// @param _data Additional data for lockup initialization.
    function inializeStakingAndLockup(
        address _target,
        uint256[] memory _tokenIds,
        bytes memory _data
    )
        external
        onlyIfLockupSet(_target)
        onlyMinterOrAdmin(_target)
        onlyUnstakedTokens(_target, _tokenIds)
    {
        for (uint256 i = 0; i < _tokenIds.length; ) {
            // start staking
            enterWarehouse(_target, _tokenIds[i]);
            // set lockup info
            lockup[_target].setUnlockInfo(_target, _tokenIds[i], _data);
            unchecked {
                i++;
            }
        }
    }

    /////////////////////////////////////////////////
    /// Admin
    /////////////////////////////////////////////////

    /// @notice Check if an address has admin access.
    /// @param _target The target address.
    /// @param user The user address to check.
    /// @return true if the address has admin access, false otherwise.
    function isAdmin(address _target, address user) public view returns (bool) {
        return IERC721Drop(_target).isAdmin(user);
    }

    /////////////////////////////////////////////////
    /// MODIFIERS
    /////////////////////////////////////////////////

    /// @notice Modifier for only approved or owner access.
    /// @param _target The target address.
    /// @param tokenId The token ID to verify.
    modifier onlyApprovedOrOwner(address _target, uint256 tokenId) {
        if (
            ICre8ors(_target).ownerOf(tokenId) != msg.sender &&
            ICre8ors(_target).getApproved(tokenId) != msg.sender
        ) {
            revert IERC721Drop.Access_MissingOwnerOrApproved();
        }

        _;
    }

    /// @notice Modifier for admin access only.
    /// @param _target The target address.
    modifier onlyAdmin(address _target) {
        if (!isAdmin(_target, msg.sender)) {
            revert IERC721Drop.Access_OnlyAdmin();
        }

        _;
    }

    /// @notice Modifier for only lockup enabled staking.
    /// @param _target The target address.
    modifier onlyIfLockupSet(address _target) {
        if (address(lockup[_target]) == address(0)) {
            revert Cre8ing_MissingLockup();
        }

        _;
    }

    /**
     * @dev Modifier to check that the tokens are not currently staked (i.e., cre8ing).
     * Reverts with 'Cre8ing_Cre8ing' if any of the tokens are staked.
     * @param _target The target address owning the tokens.
     * @param _tokenIds Array of token IDs to be checked.
     */
    modifier onlyUnstakedTokens(address _target, uint256[] memory _tokenIds) {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if (cre8ingStarted[_target][_tokenIds[i]] != 0) {
                revert Cre8ing_Cre8ing();
            }
        }
        _;
    }
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

import {ICre8ors} from "../interfaces/ICre8ors.sol";

contract MinterAdminCheck {
    /// @notice Access control roles
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public immutable MINTER_ROLE = keccak256("MINTER");

    /// @notice Missing the minter role or admin access
    error AdminAccess_MissingMinterOrAdmin();

    /// @notice Modifier to require the sender to be an admin
    /// @param target address that the user wants to modify
    modifier onlyMinterOrAdmin(address target) {
        if (
            target != msg.sender &&
            !ICre8ors(target).hasRole(DEFAULT_ADMIN_ROLE, msg.sender) &&
            !ICre8ors(target).hasRole(MINTER_ROLE, msg.sender)
        ) {
            revert AdminAccess_MissingMinterOrAdmin();
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