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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

interface IPsChainlinkManager {
    /// @notice Recovers signer wallet from signature
    /// @dev View function for signature recovering
    /// @param weekNumber Week number for claim
    /// @param claimIndex Claim index for a particular user for a week
    /// @param walletAddress Token owner wallet address
    /// @param signature Signature from signer wallet
    function isSignerVerifiedFromSignature (
        uint256 weekNumber,
        uint256 claimIndex,
        address walletAddress,
        bytes calldata signature
    ) external returns (bool);

    /// @notice Generate random number from Chainlink
    /// @param _weekNumber Number of the week
    /// @return requestId Chainlink requestId
    function generateChainLinkRandomNumbers(uint256 _weekNumber) external returns (uint256 requestId);

    /// @notice Get weekly random numbers for specific week
    /// @param _weekNumber The number of the week
    /// @return randomNumbers weekly random numbers
    function getWeeklyRandomNumbers(uint256 _weekNumber) external view returns (uint256[] memory randomNumbers);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

/// @title Pixelmon Party Squad Smart Contract
/// @author LiquidX
/// @notice This smart contract provides configuration for the Party Squad event on Pixelmon
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IPsChainlinkManager.sol";
import "./PxUtils.sol";

/// @notice Thrown when end timestamp is less than or equal to start timestamp
error InvalidTimeStamp();
/// @notice Thrown when week number doesn't exist
error InvalidWeekNumber();
/// @notice Thrown when week duration is less than total period for updating treasure and set the winners
error InvalidDuration();
/// @notice Thrown when updating treasure is beyond the schedule
error InvalidUpdationPeriod();
/// @notice Thrown when claiming treasure is beyond the schedule
error InvalidClaimingPeriod();
/// @notice Thrown when address has no "Admin" role
error NotAdmin();
/// @notice Thrown when address has no "Moderator" role
error NotModerator();
/// @notice Thrown when length of both arrays are not equal
error InvalidLength();

contract PsWeekManager is Ownable, PxUtils {
    
    /// @notice Struct object for winner information
    /// @param claimLimit Maximum treasure that can be claimed by winner for a particular week
    /// @param claimed Number of treasure that has been claimed by winner for a particular week
    /// @param treasureTypeClaimed Type of treasure that has been claimed by a winner for a particular week
    struct Winner {
        uint8 claimLimit;
        uint8 claimed;
        mapping(uint256 => bool) treasureTypeClaimed;
    }

    /// @notice Struct object to store treasure information
    /// @dev If the treasure is ERC1155,tokenIds is an  empty array
    ///      if the treasure is ERC721,tokenId value is a dummy
    /// @param collectionAddress Contract address of the treasure
    /// @param tokenId ERC1155 Treasure token ID 
    /// @param tokenIds ERC721 Treasure token IDs
    /// @param claimedToken Amount of token that has been claimed
    /// @param contractType 1 for ERC1155, 2 for ERC721
    /// @param treasureType Similar IDs for the treasure.Treasure ID is used
    ///        to identify the treasure that claimed by winner and it's used to make
    ///        sure the winner will get different set of prizes.
    struct Treasure {
        address collectionAddress;
        uint256 tokenId;
        uint256[] tokenIds;
        uint256 claimedToken;
        uint8 contractType;
        uint8 treasureType;
    }

    /// @notice Struct object to store information about treasure that distributed within a week
    /// @param treasureIndex Index of the treasure in the smart contract
    /// @param totalSupply Total supply of the treasure within a week
    struct TreasureDistribution {
        uint8 treasureIndex;
        uint16 totalSupply;
    }

    /// @notice Struct object to store week information
    /// @param startTimeStamp Start timestamp of the week
    /// @param ticketDrawTimeStamp ticket draw timestamp 
    /// @param claimStartTimeStamp claiming start timestamp
    /// @param endTimeStamp End timestamp of a week
    /// @param remainingSupply The remaining treasure supply that hasn't been claimed during
    ///        the week. This supply is the sum of every treasure supply excluding Special Treasures
    /// @param treasureCount How many treasure option is available
    /// @param specialTreasureCount How many Special Treasures are available in a week
    /// @param specialTreasureWinners Winners of Special Treasures
    /// @param specialTreasureWinnerMap Map that contains address of the Special Treasures winner.
    ///        Map is used to easily validate whether the address is a winner rather than
    ///        iterating every index in a list/array to find a winner
    /// @param distributions Map of treasure that is distributed during the week
    /// @param winners List of winner of the week
    struct Week {
        uint256 startTimeStamp;
        uint256 ticketDrawTimeStamp;
        uint256 claimStartTimeStamp;
        uint256 endTimeStamp;
        uint256 remainingSupply;
        uint8 treasureCount;
        uint8 specialTreasureCount;
        uint8 availableSpecialTreasureCount;
        address[] specialTreasureWinners;
        mapping(address => bool) specialTreasureWinnerMap;
        mapping(uint256 => TreasureDistribution) distributions;
        mapping(address => Winner) winners;
    }

    /// @notice Struct object for week information
    /// @dev This struct is only used as return type for getWeekInfo method
    /// @param specialTreasureWinners Winner of Special Treasures
    /// @param randomNumbers random numbers generated from chainlink
    struct WeekData {
        address[] specialTreasureWinners;
        uint256[] randomNumbers;
    }

    /// @notice Total treasure options
    uint256 public totalTreasureCount;

    /// @notice Variable to store treasure information such as the collection
    ///         address, token ID, amount, and token type
    /// @custom:key treasure ID
    /// @custom:value Treasure information
    mapping(uint256 => Treasure) public treasures;

    /// @notice Total week to claim treasure
    uint256 public totalWeek;
    /// @notice Collection of information for each week
    mapping(uint256 => Week) public weekInfos;

    /// @notice List of address that has "Admin" role, 'true' means it has the privilege
    mapping(address => bool) public adminWallets;
    /// @notice List of address that has "Moderator" role, 'true' means it has the privilege
    mapping(address => bool) public moderatorWallets;

    /// @dev Signature Contract
    IPsChainlinkManager public psChainlinkManagerContract;

    /// @notice Check whether address has "Admin" role
    /// @param _walletAddress Valid ethereum address
    modifier onlyAdmin(address _walletAddress) {
        if (!adminWallets[_walletAddress]) {
            revert NotAdmin();
        }
        _;
    }

    /// @notice Check whether address has "Moderator" role
    /// @param _walletAddress Valid ethereum address
    modifier onlyModerator(address _walletAddress) {
        if (!moderatorWallets[_walletAddress]) {
            revert NotModerator();
        }
        _;
    }

    /// @notice Check whether block.timestamp is within the schedule
    ///         to set treasure distribution
    /// @param _weekNumber Number of the week
    modifier validTreaureDistributionPeriod(uint256 _weekNumber) {
        if (!(block.timestamp >= weekInfos[_weekNumber].startTimeStamp && block.timestamp < weekInfos[_weekNumber].ticketDrawTimeStamp)) {
            revert InvalidUpdationPeriod();
        }
        _;
    }

    /// @notice Check whether block.timestamp is beyond the schedule
    ///         to update winner merkle root and chainlink
    /// @param _weekNumber Number of the week
    modifier validWinnerUpdationPeriod(uint256 _weekNumber) {
        if (!(block.timestamp >= weekInfos[_weekNumber].ticketDrawTimeStamp && block.timestamp < weekInfos[_weekNumber].claimStartTimeStamp)) {
            revert InvalidUpdationPeriod();
        }
        _;
    }

    /// @notice Check whether the input week number is valid
    /// @param _weekNumber Number of the week
    modifier validWeekNumber(uint256 _weekNumber) {
        if (_weekNumber == 0 || _weekNumber > totalWeek) {
            revert InvalidWeekNumber();
        }
        _;
    }

    /// @notice Emit when winners of the week has been selected
    /// @param weekNumber The week number
    /// @param specialTreasureWinners The winner for Special Treasures treasure
    event WeeklyWinnersSet(uint256 weekNumber, address[] specialTreasureWinners);

    /// @notice Constructor function
    constructor() {}

    /// @notice Set "Admin" role for specific address, 'true' means it has privilege
    /// @dev Only owner can call this method
    /// @param _walletAddress The address that will be set as admin
    /// @param _flag 'true' means the address is an admin
    function setAdminWallet(address _walletAddress, bool _flag) external onlyOwner {
        adminWallets[_walletAddress] = _flag;
    }

    /// @notice Set "Moderator" role for specific address, 'true' means it has privilege
    /// @dev Only owner can call this method
    /// @param _walletAddress The address that will be set as moderator
    /// @param _flag 'true' means the address is a moderator
    function setModeratorWallet(address _walletAddress, bool _flag) external onlyOwner {
        moderatorWallets[_walletAddress] = _flag;
    }

    /// @notice Update the week information related with timestamp
    /// @param _weekNumber Number of the week
    /// @param _startTimeStamp The start time of the event
    /// @param _prizeUpdationDuration Duration to update the treasure distribution
    /// @param _winnerUpdationDuration Duration to update winner list 
    /// @param _weeklyDuration How long the event will be held within a week
    function updateWeeklyTimeStamp(
        uint256 _weekNumber,
        uint256 _startTimeStamp,
        uint256 _prizeUpdationDuration,
        uint256 _winnerUpdationDuration,
        uint256 _weeklyDuration
    ) external onlyAdmin(msg.sender) validWeekNumber(_weekNumber) {
        if (_weeklyDuration <= (_prizeUpdationDuration + _winnerUpdationDuration)) {
            revert InvalidDuration();
        }
        if (_weekNumber != 1 && _startTimeStamp <= weekInfos[_weekNumber - 1].endTimeStamp) {
            revert InvalidTimeStamp();
        }
        if (_weekNumber != totalWeek && _startTimeStamp + _weeklyDuration - 1 >= weekInfos[_weekNumber + 1].startTimeStamp) {
            revert InvalidTimeStamp();
        }

        weekInfos[_weekNumber].startTimeStamp = _startTimeStamp;
        weekInfos[_weekNumber].ticketDrawTimeStamp = _startTimeStamp + _prizeUpdationDuration;
        weekInfos[_weekNumber].claimStartTimeStamp = _startTimeStamp + _prizeUpdationDuration + _winnerUpdationDuration;
        weekInfos[_weekNumber].endTimeStamp = _startTimeStamp + _weeklyDuration - 1;
    }

    /// @notice Set the week information related with timestamp
    /// @param _numberOfWeeks How many weeks the event will be held
    /// @param _startTimeStamp The start time of the event
    /// @param _prizeUpdationDuration Duration to update the treasure distribution
    /// @param _winnerUpdationDuration Duration to update winner list i
    /// @param _weeklyDuration How long the event will be held within a week
    function setWeeklyTimeStamp(
        uint256 _numberOfWeeks,
        uint256 _startTimeStamp,
        uint256 _prizeUpdationDuration,
        uint256 _winnerUpdationDuration,
        uint256 _weeklyDuration
    ) external onlyAdmin(msg.sender) {
        if (_weeklyDuration <= (_prizeUpdationDuration + _winnerUpdationDuration)) {
            revert InvalidDuration();
        }
        for (uint256 index = 0; index < _numberOfWeeks; index = _uncheckedInc(index)) {
            totalWeek++;
            weekInfos[totalWeek].startTimeStamp = _startTimeStamp;
            weekInfos[totalWeek].ticketDrawTimeStamp = _startTimeStamp + _prizeUpdationDuration;
            weekInfos[totalWeek].claimStartTimeStamp = _startTimeStamp + _prizeUpdationDuration + _winnerUpdationDuration;
            weekInfos[totalWeek].endTimeStamp = _startTimeStamp + _weeklyDuration - 1;
            _startTimeStamp += _weeklyDuration;
        }
    }

    // @notice Generate random number from Chainlink
    /// @param _weekNumber Number of the week
    function generateChainLinkRandomNumbers(uint256 _weekNumber) external onlyModerator(msg.sender) validWinnerUpdationPeriod(_weekNumber) {
        psChainlinkManagerContract.generateChainLinkRandomNumbers(_weekNumber);
    }

    /// @notice Get week informations for specific week
    /// @param _weekNumber The number of the week
    /// @return week Information for specific week
    function getWeekInfo(uint256 _weekNumber) external view returns (WeekData memory week) {
        week.specialTreasureWinners = weekInfos[_weekNumber].specialTreasureWinners;
        week.randomNumbers = psChainlinkManagerContract.getWeeklyRandomNumbers(_weekNumber);
    }

    /// @notice Get claimed count for a winner for specific week
    /// @param _weekNumber The number of the week
    /// @param _walletAddress wallet address of the winner
    /// @return count claim count
    function getWeeklyClaimedCount(uint256 _weekNumber, address _walletAddress) external view returns (uint8 count) {
        return weekInfos[_weekNumber].winners[_walletAddress].claimed;
    }

    /// @notice Get treasure distribution for specific week
    /// @param _weekNumber The number of the week
    /// @return tmp distribution for specific week
    function getWeeklyDistributions(uint256 _weekNumber) external view returns (TreasureDistribution[] memory tmp) {
        TreasureDistribution[] memory distributions = new TreasureDistribution[](weekInfos[_weekNumber].treasureCount);
        for (uint256 index = 1; index <= weekInfos[_weekNumber].treasureCount; index++) {
            distributions[index - 1] = weekInfos[_weekNumber].distributions[index];
        }
        return distributions;
    }

    /// @notice Get all treasures information
    /// @return tmp all treasures information
    function getTreasures() external view returns (Treasure[] memory tmp) {
        Treasure[] memory allTreasures = new Treasure[](totalTreasureCount);
        for (uint256 index = 1; index <= totalTreasureCount; index++) {
            allTreasures[index - 1] = treasures[index];
        }
        return allTreasures;
    }
    
    /// @notice Get treasures information by index
    /// @param _index treasure index
    /// @return tmp particular treasure information
    function getTreasureById(uint256 _index) external view returns (Treasure memory tmp) {
        return treasures[_index];
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./PsWeekManager.sol";
import "./IPsChainlinkManager.sol";

/// @notice Thrown when all treasures are already claimed
error AlreadyClaimed();
/// @notice Thrown when address is not a winner
error NotAWinner();
/// @notice Thrown when input is not as expected condition
error InvalidInput();
/// @notice Thrown when treasure index doesn't exist
error InvalidTreasureIndex();
/// @notice Thrown when no available treasures to be transferred to the winner
error InsufficientToken();
/// @notice Thrown when the input signature is invalid.
error InvalidSignature();

contract PxPartySquad is PsWeekManager, ReentrancyGuard {
    /// @notice code number for ERC1155 token
    uint8 public constant ERC_1155_TYPE = 1;
    /// @notice code number for ERC721 token
    uint8 public constant ERC_721_TYPE = 2;

    /// @notice Wallet address that keeps all treasures
    address public vaultWalletAddress;

    uint256 public maxSpecialTreasureLimit = 1;

    
    /// @notice Variable to store Special Treasures treasure information such
    ///         as the collection address, token ID, amount, and token type
    Treasure public specialTreasure;
    /// @notice List of addresses who have won Special Treasures 
    /// @custom:key wallet address
    mapping(address => uint256) public specialTreasureWinnersLimit;

    /// @notice Check whether both array input has the same length or not
    /// @param length1 first length of the array input
    /// @param length2 second length of the array input
    modifier validArrayLength(uint256 length1, uint256 length2) {
        if (length1 != length2) {
            revert InvalidLength();
        }
        _;
    }

    /// @notice Check treasure token type and token ID input
    /// @dev Only ERC1155 and ERC721 are supported
    /// @param _treasure Treasure information
    modifier validTreasure(Treasure memory _treasure) {
        if (_treasure.contractType != ERC_1155_TYPE && _treasure.contractType != ERC_721_TYPE) {
            revert InvalidInput();
        }
        if (
            (_treasure.contractType == ERC_1155_TYPE && _treasure.tokenIds.length > 0) ||
            (_treasure.contractType == ERC_721_TYPE && _treasure.tokenIds.length == 0)
        ) {
            revert InvalidInput();
        }
        _;
    }

    /// @notice Emits when a treasure is claimed
    /// @param weekNumber Week number when the treasure is claimed
    /// @param userWallet Wallet address who claims the treasure
    /// @param collectionAddress The contract address of the treasure
    /// @param tokenId The treasure token ID in its contract address
    /// @param tokenType The token type 
    event TreasureTransferred(uint256 weekNumber, address userWallet, address collectionAddress, uint256 tokenId, uint256 tokenType);

    /// @notice The contract constructor
    /// @dev The constructor parameters only used as input
    ///      from PsWeekManager contract
    ///        More https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    /// @param _psChainlinkContractAddress signature contract address
    constructor(address _psChainlinkContractAddress) PsWeekManager() {
        psChainlinkManagerContract = IPsChainlinkManager(_psChainlinkContractAddress);
    }

    /// @notice Sets Chainlink manager contract address
    /// @dev Chainlink manager is used as signer and to interact with Chainlink
    /// @param _psChainlinkContractAddress Chainlink manager contract address
    function setPsChainlinkManagerContractAddress(address _psChainlinkContractAddress) external onlyOwner {
        psChainlinkManagerContract = IPsChainlinkManager(_psChainlinkContractAddress);
    }

    /// @notice Set address to become vault
    /// @param _walletAddress Wallet address that will be the vault
    function setVaultWalletAddress(address _walletAddress) external onlyOwner {
        vaultWalletAddress = _walletAddress;
    }

    /// @notice Adds treasure information
    /// @dev This method is used to add information about the treasure that exists
    ///      in the vault wallet address. Only admin can call this method
    /// @param _treasure Treasure information
    function addTreasures(Treasure memory _treasure) external onlyAdmin(msg.sender) validTreasure(_treasure) {
        totalTreasureCount++;
        _treasure.claimedToken = 0;
        treasures[totalTreasureCount] = _treasure;
    }

    /// @notice Update existing treasure information
    /// @dev Only admin can call this method
    /// @param _index Treasure index
    /// @param _treasure New treasure information
    function updateTreasure(uint256 _index, Treasure memory _treasure) external onlyAdmin(msg.sender) validTreasure(_treasure) {
        _treasure.claimedToken = 0;
        treasures[_index] = _treasure;
    }

    /// @notice Add Special treasure to the smart contract
    /// @dev Can only be called by adminis
    /// @param _treasure Special Treasure information according to Treasure struct
    function addSpecialTreasure(Treasure memory _treasure) external onlyAdmin(msg.sender) validTreasure(_treasure) {
        _treasure.claimedToken = 0;
        specialTreasure = _treasure;
    }

    /// @notice claim function for the winner
    /// @dev Only winner of the week can call this method
    /// @param _weekNumber The week number to claim treasure
    /// @param _signature Signature from signer wallet
    function claimTreasure(uint256 _weekNumber, bytes calldata _signature) external noContracts nonReentrant {
        if (!(block.timestamp >= weekInfos[_weekNumber].claimStartTimeStamp && block.timestamp <= weekInfos[_weekNumber].endTimeStamp)) {
            revert InvalidClaimingPeriod();
        }
        bool isValidSigner = psChainlinkManagerContract.isSignerVerifiedFromSignature(
            _weekNumber,
            weekInfos[_weekNumber].winners[msg.sender].claimed,
            msg.sender,
            _signature
        );

        if (!isValidSigner) {
            revert InvalidSignature();
        }

        if (weekInfos[_weekNumber].winners[msg.sender].claimLimit == 0) {
            revert NotAWinner();
        }
        if (weekInfos[_weekNumber].winners[msg.sender].claimed == weekInfos[_weekNumber].winners[msg.sender].claimLimit) {
            revert AlreadyClaimed();
        }
        if (weekInfos[_weekNumber].winners[msg.sender].claimed == 0) {
            primaryClaim(_weekNumber);
        } else {
            secondaryClaim(_weekNumber);
        }
    }

    /// @notice Method to claim the first treasure
    /// @dev This method is also used to claim Special Treasures if
    ///      the caller is selected as a special treasure winner
    /// @param _weekNumber The week number to claim treasure
    function primaryClaim(uint256 _weekNumber) internal {
        Week storage week = weekInfos[_weekNumber];
        if (week.specialTreasureWinnerMap[msg.sender]) {
            specialTreasureWinnersLimit[msg.sender]++;
            week.specialTreasureWinnerMap[msg.sender] = false;

            unchecked {
                week.winners[msg.sender].claimed++;
                week.availableSpecialTreasureCount--;
                specialTreasure.claimedToken++;
            }
            transferToken(_weekNumber, specialTreasure);
        } else {
            uint256 randomNumber = getRandomNumber();
            uint256 random = randomNumber - ((randomNumber / week.remainingSupply) * week.remainingSupply) + 1;

            uint256 selectedIndex;
            uint16 sumOfTotalSupply;

            for (uint256 index = 1; index <= week.treasureCount; index = _uncheckedInc(index)) {
                if (week.distributions[index].totalSupply == 0) {
                    continue;
                }
                unchecked {
                    sumOfTotalSupply += week.distributions[index].totalSupply;
                }
                if (random <= sumOfTotalSupply) {
                    selectedIndex = index;
                    break;
                }
            }
            uint256 selectedTreasureIndex = week.distributions[selectedIndex].treasureIndex;
            week.winners[msg.sender].treasureTypeClaimed[treasures[selectedTreasureIndex].treasureType] = true;

            unchecked {
                week.distributions[selectedIndex].totalSupply--;
                week.winners[msg.sender].claimed++;
                week.remainingSupply--;
                treasures[selectedTreasureIndex].claimedToken++;
            }

            transferToken(_weekNumber, treasures[selectedTreasureIndex]);
        }
    }

    /// @notice Method to claim the next treasure
    /// @dev This method will give different treasures than the first
    ///      one if there are still other treasure option available
    /// @param _weekNumber The week number to claim treasure
    function secondaryClaim(uint256 _weekNumber) internal {
        Week storage week = weekInfos[_weekNumber];
        uint16 remaining;
        uint16 altRemaining;

        for (uint256 index = 1; index <= week.treasureCount; index = _uncheckedInc(index)) {
            uint256 treasureType = treasures[week.distributions[index].treasureIndex].treasureType;
            if (week.winners[msg.sender].treasureTypeClaimed[treasureType]) {
                unchecked {
                    altRemaining += week.distributions[index].totalSupply;
                }
            } else {
                unchecked {
                    remaining += week.distributions[index].totalSupply;
                }
            }
        }
        uint256 randomNumber = getRandomNumber();

        uint256 selectedIndex;
        uint256 sumOfTotalSupply;
        if (altRemaining == week.remainingSupply) {
            uint256 random = randomNumber - ((randomNumber / altRemaining) * altRemaining) + 1;
            for (uint256 index = 1; index <= week.treasureCount; index = _uncheckedInc(index)) {
                uint256 treasureType = treasures[week.distributions[index].treasureIndex].treasureType;
                if (week.distributions[index].totalSupply == 0 || !week.winners[msg.sender].treasureTypeClaimed[treasureType]) {
                    continue;
                }
                unchecked {
                    sumOfTotalSupply += week.distributions[index].totalSupply;
                }
                if (random <= sumOfTotalSupply) {
                    selectedIndex = index;
                    break;
                }
            }
        } else {
            uint256 random = randomNumber - ((randomNumber / remaining) * remaining) + 1;

            for (uint256 index = 1; index <= week.treasureCount; index = _uncheckedInc(index)) {
                uint256 treasureType = treasures[week.distributions[index].treasureIndex].treasureType;
                if (week.distributions[index].totalSupply == 0 || week.winners[msg.sender].treasureTypeClaimed[treasureType]) {
                    continue;
                }
                unchecked {
                    sumOfTotalSupply += week.distributions[index].totalSupply;
                }
                if (random <= sumOfTotalSupply) {
                    selectedIndex = index;
                    break;
                }
            }
        }

        uint256 selectedTreasureIndex = week.distributions[selectedIndex].treasureIndex;
        week.winners[msg.sender].treasureTypeClaimed[treasures[selectedTreasureIndex].treasureType] = true;
        unchecked {
            week.distributions[selectedIndex].totalSupply--;
            week.winners[msg.sender].claimed++;
            week.remainingSupply--;
            treasures[selectedTreasureIndex].claimedToken++;
        }

        transferToken(_weekNumber, treasures[selectedTreasureIndex]);
    }

    /// @notice Transfers token from vault to the method caller's wallet address
    /// @dev This method will be used in a public method and user who call the
    ///      method will get a token from vault wallet address
    /// @param _treasure Treasure to transfer
    function transferToken(uint256 _weekNumber, Treasure memory _treasure) internal {
        if (_treasure.contractType == ERC_1155_TYPE) {
            IERC1155 erc1155Contract = IERC1155(_treasure.collectionAddress);
            erc1155Contract.safeTransferFrom(vaultWalletAddress, msg.sender, _treasure.tokenId, 1, "");
            emit TreasureTransferred(_weekNumber, msg.sender, _treasure.collectionAddress, _treasure.tokenId, _treasure.contractType);
        }
        if (_treasure.contractType == ERC_721_TYPE) {
            IERC721 erc721Contract = IERC721(_treasure.collectionAddress);
            if (_treasure.tokenIds.length < _treasure.claimedToken) {
                revert InsufficientToken();
            }
            erc721Contract.transferFrom(vaultWalletAddress, msg.sender, _treasure.tokenIds[_treasure.claimedToken - 1]);
            emit TreasureTransferred(_weekNumber, msg.sender, _treasure.collectionAddress,_treasure.tokenIds[_treasure.claimedToken - 1] , _treasure.contractType);
        }
    }

    /// @notice Set treasure distributions for a week
    /// @dev Only admin can call this method
    /// @param _weekNumber The week number
    /// @param _treasureindexes The index of the treasure in 'treasures' mapping variable
    /// @param _treasureCounts Amount of treasure that will be available to claim during the week
    /// @param _specialTreasuresCount Amount of special treasure that will be available to claim during the week
    function setWeeklyTreasureDistribution(
        uint256 _weekNumber,
        uint8[] memory _treasureindexes,
        uint16[] memory _treasureCounts,
        uint8 _specialTreasuresCount
    ) external onlyAdmin(msg.sender) validTreaureDistributionPeriod(_weekNumber) validArrayLength(_treasureindexes.length, _treasureCounts.length) {
        Week storage week = weekInfos[_weekNumber];
        week.specialTreasureCount = _specialTreasuresCount;
        week.availableSpecialTreasureCount = _specialTreasuresCount;
        week.treasureCount = 0;
        for (uint256 index = 0; index < _treasureindexes.length; index = _uncheckedInc(index)) {
            if (_treasureindexes[index] == 0 || _treasureindexes[index] > totalTreasureCount) {
                revert InvalidTreasureIndex();
            }
            week.treasureCount++;
            week.distributions[week.treasureCount].treasureIndex = _treasureindexes[index];
            week.distributions[week.treasureCount].totalSupply = _treasureCounts[index];
            week.remainingSupply += _treasureCounts[index];
        }
    }

    /// @notice Set a list of winners for a particular week
    /// @param _weekNumber The current week number
    /// @param _winners List of wallet addresses that have been selected as winners
    /// @param _treasureCounts Amount of treasure that have been awarded to the corresponding winner
    function updateWeeklyWinners(
        uint256 _weekNumber,
        address[] memory _winners,
        uint8[] memory _treasureCounts
    ) external onlyModerator(msg.sender) validArrayLength(_winners.length, _treasureCounts.length) validWinnerUpdationPeriod(_weekNumber) {
        for (uint256 index = 0; index < weekInfos[_weekNumber].specialTreasureWinners.length; index++) {
            address specialTreasureWinner = weekInfos[_weekNumber].specialTreasureWinners[index];
            weekInfos[_weekNumber].specialTreasureWinnerMap[specialTreasureWinner] = false;
        }
        uint256 randomNumber = getRandomNumber();
        uint256 randomIndex = randomNumber - ((randomNumber / _treasureCounts.length) * _treasureCounts.length);
        uint256 counter = 0;
        uint256 specialTreasureWinnerCount = 0;
        uint256 treasureCount = 0;
        address[] memory tmpSpecialTreasureWinners = new address[](weekInfos[_weekNumber].specialTreasureCount);
        while (counter < _treasureCounts.length) {
            if (randomIndex == _treasureCounts.length) {
                randomIndex = 0;
            }
            if (
                specialTreasureWinnersLimit[_winners[randomIndex]] < maxSpecialTreasureLimit &&
                specialTreasureWinnerCount < weekInfos[_weekNumber].specialTreasureCount &&
                _treasureCounts[randomIndex] > 0
            ) {
                weekInfos[_weekNumber].specialTreasureWinnerMap[_winners[randomIndex]] = true;
                tmpSpecialTreasureWinners[specialTreasureWinnerCount] = _winners[randomIndex];
                specialTreasureWinnerCount++;
            }

            weekInfos[_weekNumber].winners[_winners[randomIndex]].claimLimit = _treasureCounts[randomIndex];
            treasureCount += _treasureCounts[randomIndex];
            unchecked {
                randomIndex++;
                counter++;
            }
        }
        if (treasureCount > weekInfos[_weekNumber].remainingSupply + weekInfos[_weekNumber].specialTreasureCount) {
            revert("Invalid Treasure Amount");
        }

        weekInfos[_weekNumber].specialTreasureWinners = tmpSpecialTreasureWinners;
        emit WeeklyWinnersSet(_weekNumber, tmpSpecialTreasureWinners);
    }

    /// @notice Add a list of wallet addresses that have won Special Treasure
    /// @param _previousWinners List of addresses that have won Special Treasure
    /// @param _counts number of special treasures have already won
    function setSpecialTreasureWinnerLimit(
        address[] memory _previousWinners,
        uint256[] memory _counts
    ) external onlyAdmin(msg.sender) validArrayLength(_previousWinners.length, _counts.length) {
        for (uint256 index = 0; index < _previousWinners.length; index = _uncheckedInc(index)) {
            specialTreasureWinnersLimit[_previousWinners[index]] = _counts[index];
        }
    }

    /// @notice update max limit for special treasure
    /// @param _maxSpecialTreasureLimit List of addresses that have won Special Treasure
    function updateMaxSpecialTreasureLimit(
        uint256 _maxSpecialTreasureLimit
    ) external onlyAdmin(msg.sender) {
        maxSpecialTreasureLimit = _maxSpecialTreasureLimit;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract PxUtils {
    modifier noContracts() {
        uint256 size;
        address acc = msg.sender;
        assembly {
            size := extcodesize(acc)
        }
        require(msg.sender == tx.origin, "tx.origin != msg.sender");
        require(size == 0, "Contract calls are not allowed");
        _;
    }

    function _uncheckedInc(uint256 value) internal pure returns (uint256) {
        unchecked {
            return value + 1;
        }
    }

    function getRandomNumber() internal view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
                        block.number
                )
            )
        );

        return randomNumber;
    }
}