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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
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
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./extensions/IERC721RoyaltiesStorage.sol";

interface IIOGINALITY is IERC721, IERC721RoyaltiesStorage {}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721RoyaltiesStorage is IERC721 {

    function getRoyalties(uint256 tokenId) external view returns (address[] memory, uint32[] memory);

    function getRoyaltiesAmount(uint256 tokenId) external view returns (uint32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "hardhat/console.sol";

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./ERC721/IIOGINALITY.sol";
import "./utils/Manageable.sol";

contract MarketManagerV1 is Ownable, Manageable, ReentrancyGuard {
    mapping(uint256 => Listing) private listings;

    string private _name;

    bool private isActive = true;

    uint32 private defaultBidIncreasePercentage;

    uint256 private marketplaceIncome = 0;

    mapping(address => uint256) private debts;

    enum ListingType {
        None,
        FixedPrice,
        Auction
        // ReversAuction
    }

    /* 
        Royalties struct is used to store royalties for NFT token
        There is some method to define royalties for secindary sales
        1. Royalties can be set by seller when he creates fixed price listing
        2. Royalties can be set by seller when he creates auction listing

        Royalties can be set only once for each sale
    */
    struct Royalties {
        address[] recipients;
        uint32[] amounts;
        uint32 total;
    }

    struct RoyaltiesInput {
        address[] recipients;
        uint32[] amounts;
    }

    /*
        contract supports only native blockchain currency
    */
    struct Listing {
        IIOGINALITY tokenContract;
        uint256 tokenId;
        ListingType listingType;
        address sellerManager;
        address seller;
        uint128 price; // for ListingType.Auction the same as buyNowPrice
        uint64 end; // time of listing ending
        address whitelistBuyer; // seller can create listing only for specific buyer address
        uint128 startPrice; // start price for Auction and ReverseAuction
        uint128 reservePrice; // minimum price for Auction must finish successful
        uint128 highestBid;
        address highestBidder;
        uint32 bidStep; // for ListingType.Auction value to increase for ListingType.ReverseAuction value to decrease
        uint32 marketplaceFee; // fee for marketplace
        Royalties royalties;
    }

    /**
     * EVENTS START
     */

    event FixedPriceListingCreated(
        uint256 listingId,
        address tokenContract,
        uint256 tokenId,
        address seller,
        uint128 price,
        uint64 end,
        address whitelistBuyer
    );

    event AuctionListingCreated(
        uint256 listingId,
        address tokenContract,
        uint256 tokenId,
        address seller,
        uint128 startPrice,
        uint128 reservePrice,
        uint128 buyNowPrice,
        uint64 end,
        address whitelistBuyer
    );

    event BidMade(
        uint256 listingId,
        address bidder,
        uint128 amount,
        address prevBidder,
        uint128 prevAmount,
        uint256 timestamp
    );

    event BidRefunded(
        uint256 listingId,
        address bidder,
        uint128 amount,
        address newBidder,
        uint128 newAmount,
        uint256 timestamp
    );

    event ListingCancelled(uint256 listingId, uint256 timestamp);

    event ListingFinished(uint256 listingId, uint256 timestamp);

    event ListingSold(
        uint256 listingId,
        uint128 price,
        address buyer,
        ListingType type_,
        uint256 timestamp
    );

    event ContractStarted(uint256 timestamp);
    event ContractStoppped(uint256 timestamp);

    event MarketplaceFeeReceived(
        IIOGINALITY tokenContract,
        uint256 tokenId,
        uint128 amount,
        uint256 timestamp
    );

    event SetRoyalty(
        uint256 tokenId,
        address seller,
        uint128 amount,
        uint256 timestamp
    );

    event RoyaltiesPaid(
        uint256 listingId,
        address reciever,
        uint128 amount,
        IIOGINALITY tokenContract,
        uint256 tokenId,
        uint256 timestamp
    );

    event SecondaryRoyaltiesPaid(
        uint256 listingId,
        address reciever,
        uint128 amount,
        IIOGINALITY tokenContract,
        uint256 tokenId,
        uint256 timestamp
    );

    event SellerPaid(
        uint256 listingId,
        address seller,
        uint128 amount,
        IIOGINALITY tokenContract,
        uint256 tokenId,
        uint256 timestamp
    );

    /**
     * EVENTS END
     */

    /**
     * MODIFIERS START
     */

    modifier contractIsActive() {
        require(isActive, "Contract is stopped now");
        _;
    }

    modifier listingExists(uint256 listingId) {
        require(listings[listingId].tokenId > 0, "Listing does not exist");
        _;
    }

    modifier listingIsNonexistent(uint256 _listingId) {
        require(listings[_listingId].tokenId < 1, "Listing is already exists");
        _;
    }

    modifier listingIsOngoing(uint256 listingId) {
        require(listings[listingId].tokenId > 0, "Listing is not exists");
        require(
            listings[listingId].end > block.timestamp,
            "Listing time is over"
        );
        _;
    }

    modifier isAuction(uint256 _listingId) {
        require(
            listings[_listingId].listingType == ListingType.Auction,
            "Listing is not the auction type"
        );
        _;
    }

    modifier isFixedPrice(uint256 tokenId) {
        require(
            listings[tokenId].listingType == ListingType.FixedPrice,
            "Listing is not the fixed price type"
        );
        _;
    }

    modifier correctMarketplaceFee(uint32 _marketplaceFee) {
        require(
            _marketplaceFee <= (50 * 100),
            "Max value for marketplace fee 50 pecent"
        );
        _;
    }

    modifier isPaymentAcceptable(uint256 tokenId) {
        require(
            msg.sender != address(0),
            "sender must not be an empty address"
        );
        require(
            msg.sender != listings[tokenId].seller,
            "sender must not be a seller"
        );
        require(
            msg.value == listings[tokenId].price,
            "sent money is insufficient"
        );

        _;
    }

    modifier isBidAcceptable(uint256 tokenId) {
        require(
            msg.sender != address(0),
            "sender must not be an empty address"
        );
        require(
            msg.sender != listings[tokenId].seller,
            "sender must not be a seller"
        );

        if (listings[tokenId].whitelistBuyer != address(0)) {
            require(
                listings[tokenId].whitelistBuyer == msg.sender,
                "Auction accepts bid only from whitelist buyer"
            );
        }

        /* check it's a bid(not a buy now)  */
        if (
            !(listings[tokenId].price > 0 &&
                listings[tokenId].price == msg.value)
        ) {
            if (listings[tokenId].highestBid > 0) {
                require(
                    msg.value > listings[tokenId].highestBid,
                    "The bet must be greater than the last bet"
                );

                uint128 requiredNextBid = listings[tokenId].highestBid +
                    ((listings[tokenId].highestBid *
                        _getBidIncreaseIndex(tokenId)) / 10000);
                require(msg.value >= requiredNextBid, "Bid insufficient");
            } else if (listings[tokenId].startPrice > 0) {
                require(
                    msg.value >= listings[tokenId].startPrice,
                    "Bid insufficient"
                );
            } else {
                require(msg.value >= 0, "Bid insufficient");
            }
        }

        _;
    }

    modifier onlyOwnerOrManagerOrSeller(uint256 listingId) {
        require(
            owner() == msg.sender ||
                manager() == msg.sender ||
                listings[listingId].sellerManager == msg.sender ||
                listings[listingId].seller == msg.sender,
            "Method can call only owner/manager/seller"
        );
        _;
    }

    modifier isRoyaltiesInputCorrect(RoyaltiesInput calldata royaltiesInput) {
        require(
            royaltiesInput.recipients.length == royaltiesInput.amounts.length,
            "roylties recipients and amounts number should be equal"
        );
        _;
    }

    /**
     * MODIFIERS END
     */

    /**
     * address _nftTokenContract is the address of ERC721 token contract
     */
    constructor(
        string memory name_,
        uint32 _defaultBidIncreasePercentage,
        address manager_
    ) Ownable(msg.sender) {
        _name = name_;
        defaultBidIncreasePercentage = _defaultBidIncreasePercentage;

        _transferMangership(manager_);
    }

    function _getBidIncreaseIndex(
        uint256 _listingId
    ) private view returns (uint32) {
        if (listings[_listingId].bidStep > 0) {
            return listings[_listingId].bidStep;
        }

        return defaultBidIncreasePercentage;
    }

    /* check does auction has winner */
    function _hasAuctionWinner(uint256 _listingId) private view returns (bool) {
        /* if we have someone who has palced a bet */
        if (
            listings[_listingId].highestBidder != address(0) &&
            listings[_listingId].highestBid > 0
        ) {
            if (listings[_listingId].reservePrice > 0) {
                if (
                    listings[_listingId].reservePrice <=
                    listings[_listingId].highestBid
                ) {
                    return true;
                }
            } else {
                return true;
            }
        }

        return false;
    }

    function _getPortionOfAmount(
        uint128 _amount,
        uint32 _percentage
    ) internal pure returns (uint128) {
        return (_amount * (_percentage)) / 10000;
    }

    function _tokenExists(IIOGINALITY _contract, uint256 tokenId) private view {
        require(
            _contract.ownerOf(tokenId) != address(0),
            "Token is not exists"
        );
    }

    function checkAbilityToManageToken(
        IIOGINALITY _contract,
        uint256 tokenId
    ) internal view {
        require(
            _contract.getApproved(tokenId) == address(this),
            "Current contract not approved to manage token"
        );
    }

    function _checkTotalFeesAndGetSecondaryRoyalties(
        IIOGINALITY tokenContract,
        uint256 tokenId,
        uint64 _marketplaceFee,
        RoyaltiesInput memory royaties
    ) internal view returns (Royalties memory) {
        require(
            royaties.recipients.length == royaties.amounts.length,
            "roylties recipients and amounts number should be equal"
        );

        uint32 total;
        for (uint256 i = 0; i < royaties.amounts.length; i++) {
            total += royaties.amounts[i];
        }

        require(
            (total + _marketplaceFee) <= 10000,
            "Secondary royalties should not exceed 100%"
        );

        uint32 tokenRoyalties = tokenContract.getRoyaltiesAmount(tokenId);
        require(
            (tokenRoyalties + _marketplaceFee + total) <= 10000,
            "Total fees should not exceed 100%"
        );

        return Royalties(royaties.recipients, royaties.amounts, total);
    }

    /**
     * Fixed price sale
     */
    function makeFixedPriceListing(
        uint256 _listingId,
        address _contract,
        uint256 _tokenId,
        uint128 _price,
        uint64 _end,
        uint32 _marketplaceFee
    )
        external
        nonReentrant
        contractIsActive
        listingIsNonexistent(_listingId)
        correctMarketplaceFee(_marketplaceFee)
    {
        IIOGINALITY tokenContract = IIOGINALITY(_contract);
        _tokenExists(tokenContract, _tokenId);
        checkAbilityToManageToken(tokenContract, _tokenId);
        RoyaltiesInput memory royaltiesInput;
        _checkTotalFeesAndGetSecondaryRoyalties(
            tokenContract,
            _tokenId,
            _marketplaceFee,
            royaltiesInput
        );

        // we can create new sale only when no has another listing with the same tokenId
        _createFixedPriceSale(
            _listingId,
            tokenContract,
            _tokenId,
            _price,
            _end,
            address(0),
            _marketplaceFee
        );

        emit FixedPriceListingCreated(
            _listingId,
            _contract,
            _tokenId,
            msg.sender,
            _price,
            _end,
            address(0)
        );
    }

    /**
     * Fixed price sale with secondary sale royalties
     */
    function makeFixedPriceListing(
        uint256 _listingId,
        address _contract,
        uint256 _tokenId,
        uint128 _price,
        uint64 _end,
        uint32 _marketplaceFee,
        RoyaltiesInput calldata royaltiesInput
    )
        external
        nonReentrant
        contractIsActive
        listingIsNonexistent(_listingId)
        correctMarketplaceFee(_marketplaceFee)
        isRoyaltiesInputCorrect(royaltiesInput)
    {
        IIOGINALITY tokenContract = IIOGINALITY(_contract);
        _tokenExists(tokenContract, _tokenId);
        checkAbilityToManageToken(tokenContract, _tokenId);
        Royalties memory royalties = _checkTotalFeesAndGetSecondaryRoyalties(
            tokenContract,
            _tokenId,
            _marketplaceFee,
            royaltiesInput
        );

        // we can create new sale only when no has another listing with the same tokenId
        _createFixedPriceSale(
            _listingId,
            IIOGINALITY(_contract),
            _tokenId,
            _price,
            _end,
            address(0),
            _marketplaceFee
        );
        listings[_listingId].royalties = royalties;

        emit FixedPriceListingCreated(
            _listingId,
            _contract,
            _tokenId,
            msg.sender,
            _price,
            _end,
            address(0)
        );
    }

    /**
     * British auction sale
     */
    function makeBritishAuctionListing(
        uint256 _listingId,
        address _contract,
        uint256 _tokenId,
        uint32 _bidStep,
        uint128 _startPrice,
        uint128 _reservePrice,
        uint128 _buyNowPrice,
        uint64 _end,
        uint32 _marketplaceFee
    ) external nonReentrant contractIsActive listingIsNonexistent(_listingId) {
        IIOGINALITY tokenContract = IIOGINALITY(_contract);
        _tokenExists(tokenContract, _tokenId);
        checkAbilityToManageToken(tokenContract, _tokenId);
        RoyaltiesInput memory royaltiesInput;
        _checkTotalFeesAndGetSecondaryRoyalties(
            tokenContract,
            _tokenId,
            _marketplaceFee,
            royaltiesInput
        );

        _createAuctionSale(
            _listingId,
            tokenContract,
            _tokenId,
            _bidStep,
            _startPrice,
            _reservePrice,
            _buyNowPrice,
            _end,
            address(0),
            _marketplaceFee
        );

        emit AuctionListingCreated(
            _listingId,
            _contract,
            _tokenId,
            msg.sender,
            _startPrice,
            _reservePrice,
            _buyNowPrice,
            _end,
            address(0)
        );
    }

    /**
     * British auction sale with secondary sale royalties
     */
    // function makeBritishAuctionListing(uint256 _tokenId, uint32 aa, uint128 _startPrice, uint128 _reservePrice, uint128 _buyNowPrice, uint64 _end, address[] memory _royaltyRecipients, uint32[] memory _royaltyAmounts)
    function makeBritishAuctionListing(
        uint256 _listingId,
        address _contract,
        uint256 _tokenId,
        uint32 _bidStep,
        uint128 _startPrice,
        uint128 _reservePrice,
        uint128 _buyNowPrice,
        uint64 _end,
        uint32 _marketplaceFee,
        RoyaltiesInput calldata royaltiesInput
    )
        external
        nonReentrant
        contractIsActive
        listingIsNonexistent(_listingId)
        isRoyaltiesInputCorrect(royaltiesInput)
    {
        IIOGINALITY tokenContract = IIOGINALITY(_contract);
        _tokenExists(tokenContract, _tokenId);
        checkAbilityToManageToken(tokenContract, _tokenId);
        Royalties memory royalties = _checkTotalFeesAndGetSecondaryRoyalties(
            tokenContract,
            _tokenId,
            _marketplaceFee,
            royaltiesInput
        );

        // we can create new sale only when no has another listing with the same tokenId
        _createAuctionSale(
            _listingId,
            tokenContract,
            _tokenId,
            _bidStep,
            _startPrice,
            _reservePrice,
            _buyNowPrice,
            _end,
            address(0),
            _marketplaceFee
        );
        listings[_listingId].royalties = royalties;

        emit AuctionListingCreated(
            _listingId,
            _contract,
            _tokenId,
            msg.sender,
            _startPrice,
            _reservePrice,
            _buyNowPrice,
            _end,
            address(0)
        );
    }

    function buy(
        uint256 _listingId
    )
        external
        payable
        nonReentrant
        contractIsActive
        listingIsOngoing(_listingId)
        isPaymentAcceptable(_listingId)
    {
        uint128 _value = uint128(msg.value);
        _release(_listingId, msg.sender, _value);

        emit ListingSold(
            _listingId,
            _value,
            msg.sender,
            listings[_listingId].listingType,
            block.timestamp
        );
    }

    /**
     * Accept bid of auction only from recepient
     */
    function bid(
        uint256 _listingId
    )
        external
        payable
        nonReentrant
        contractIsActive
        listingIsOngoing(_listingId)
        isAuction(_listingId)
        isBidAcceptable(_listingId)
    {
        uint128 newBid = uint128(msg.value);

        _revertHighestBid(_listingId, msg.sender, newBid);

        address prevHighestBidder = listings[_listingId].highestBidder;
        uint128 prevHighestBid = listings[_listingId].highestBid;

        /* handle buy now price */
        if (
            listings[_listingId].price > 0 &&
            listings[_listingId].price == msg.value
        ) {
            _release(_listingId, msg.sender, newBid);
        } else {
            listings[_listingId].highestBid = newBid;
            listings[_listingId].highestBidder = msg.sender;

            emit BidMade(
                _listingId,
                listings[_listingId].highestBidder,
                listings[_listingId].highestBid,
                prevHighestBidder,
                prevHighestBid,
                block.timestamp
            );
        }
    }

    function getPrice(
        uint256 _listingId
    ) external view listingIsOngoing(_listingId) returns (uint128) {
        return listings[_listingId].price;
    }

    function getBidPrice(
        uint256 _listingId
    )
        external
        view
        listingIsOngoing(_listingId)
        isAuction(_listingId)
        returns (uint128)
    {
        if (listings[_listingId].highestBid > 0) {
            uint128 minNextBid = listings[_listingId].highestBid +
                ((listings[_listingId].highestBid *
                    _getBidIncreaseIndex(_listingId)) / 10000);
            return minNextBid;
        } else if (listings[_listingId].startPrice > 0) {
            return listings[_listingId].startPrice;
        } else {
            return uint128(2 gwei);
        }
    }

    function getEndTime(
        uint256 _listingId
    ) external view listingIsOngoing(_listingId) returns (uint64) {
        return listings[_listingId].end;
    }

    function getMarketplaceFee(
        uint256 _listingId
    ) external view listingIsOngoing(_listingId) returns (uint32) {
        return listings[_listingId].marketplaceFee;
    }

    function getSecondaryRoyalties(uint256 _listingId)
        external view
        listingIsOngoing(_listingId)
        returns (address[] memory, uint32[] memory)
    {
        return (listings[_listingId].royalties.recipients, listings[_listingId].royalties.amounts);
    }

    function cancel(
        uint256 _listingId
    )
        external
        nonReentrant
        contractIsActive
        listingIsOngoing(_listingId)
        listingExists(_listingId)
        onlyOwnerOrManagerOrSeller(_listingId)
    {
        if (listings[_listingId].listingType == ListingType.Auction) {
            _revertHighestBid(_listingId, address(0), 0);
        }

        _resetListing(_listingId);

        emit ListingCancelled(_listingId, block.timestamp);
    }

    function finish(
        uint256 _listingId
    )
        external
        nonReentrant
        contractIsActive
        listingExists(_listingId)
        onlyOwnerOrManagerOrSeller(_listingId)
    {
        if (
            listings[_listingId].listingType == ListingType.Auction &&
            _hasAuctionWinner(_listingId)
        ) {
            _release(
                _listingId,
                listings[_listingId].highestBidder,
                listings[_listingId].highestBid
            );

            emit ListingSold(
                _listingId,
                listings[_listingId].highestBid,
                listings[_listingId].highestBidder,
                ListingType.Auction,
                uint64(block.timestamp)
            );
        } else {
            _resetListing(_listingId);

            emit ListingFinished(_listingId, block.timestamp);
        }
    }

    function getIncome() external view onlyOwner returns (uint256) {
        return marketplaceIncome;
    }

    function withdrawIncome(
        address to,
        uint256 _amount
    ) external nonReentrant onlyOwner {
        if (_amount > 0) {
            require(_amount <= marketplaceIncome, "Not enough income");
        } else {
            _amount = marketplaceIncome;
        }

        require(
            _amount <= address(this).balance,
            "The contract balance is not enaugh"
        );

        (bool sent, ) = payable(to).call{value: _amount}("");

        require(sent, "Failed to send Ether");
    }

    function withdraw() external nonReentrant {
        if (debts[msg.sender] > 0) {
            uint256 _amount = debts[msg.sender];
            debts[msg.sender] = 0;

            require(
                _amount <= address(this).balance,
                "The contract balance is not enaugh"
            );

            (bool sent, ) = payable(msg.sender).call{value: _amount}("");

            require(sent, "Failed to send Ether");
        }
    }

    function _createFixedPriceSale(
        uint256 _listingId,
        IIOGINALITY _contract,
        uint256 _tokenId,
        uint128 _price,
        uint64 _end,
        address _whitelistBuyer,
        uint32 _marketplaceFee
    ) private listingIsNonexistent(_listingId) {
        listings[_listingId].tokenContract = _contract;
        listings[_listingId].tokenId = _tokenId;
        listings[_listingId].listingType = ListingType.FixedPrice;
        listings[_listingId].sellerManager = msg.sender;
        listings[_listingId].seller = _contract.ownerOf(_tokenId);
        listings[_listingId].price = _price;
        listings[_listingId].end = _end;
        listings[_listingId].whitelistBuyer = _whitelistBuyer;
        listings[_listingId].marketplaceFee = _marketplaceFee;
    }

    function _createAuctionSale(
        uint256 _listingId,
        IIOGINALITY _contract,
        uint256 _tokenId,
        uint32 _bidStep,
        uint128 _startPrice,
        uint128 _reservePrice,
        uint128 _buyNowPrice,
        uint64 _end,
        address _whitelistBuyer,
        uint32 _marketplaceFee
    ) private listingIsNonexistent(_listingId) {
        require(
            _reservePrice == 0 || _reservePrice >= _startPrice,
            "reserve price must equal zero or greater than start price"
        );
        require(
            _buyNowPrice == 0 ||
                (_buyNowPrice >= _startPrice && _buyNowPrice >= _reservePrice),
            "buy now price must equal zero or greater or equal than start and reserve prices"
        );

        listings[_listingId].tokenContract = _contract;
        listings[_listingId].tokenId = _tokenId;
        listings[_listingId].listingType = ListingType.Auction;
        listings[_listingId].sellerManager = msg.sender;
        listings[_listingId].seller = _contract.ownerOf(_tokenId);
        listings[_listingId].price = _buyNowPrice;
        listings[_listingId].end = _end;
        listings[_listingId].whitelistBuyer = _whitelistBuyer;
        listings[_listingId].startPrice = _startPrice;
        listings[_listingId].reservePrice = _reservePrice;
        listings[_listingId].bidStep = _bidStep;
        listings[_listingId].marketplaceFee = _marketplaceFee;
    }

    function _resetListing(uint256 _listingId) private {
        listings[_listingId].tokenContract = IIOGINALITY(address(0));
        listings[_listingId].tokenId = 0;
        listings[_listingId].listingType = ListingType.None;
        listings[_listingId].sellerManager = address(0);
        listings[_listingId].seller = address(0);
        listings[_listingId].price = 0;
        listings[_listingId].end = 0;
        listings[_listingId].whitelistBuyer = address(0);
        listings[_listingId].startPrice = 0;
        listings[_listingId].reservePrice = 0;
        listings[_listingId].highestBid = 0;
        listings[_listingId].highestBidder = address(0);
        listings[_listingId].bidStep = 0;
    }

    function _revertHighestBid(uint256 _listingId, address newBidder, uint128 newAmount) private {
        if (
            listings[_listingId].highestBid > 0 &&
            listings[_listingId].highestBidder != address(0)
        ) {
            (bool sent, ) = payable(listings[_listingId].highestBidder).call{
                value: listings[_listingId].highestBid
            }("");

            if (! sent) {
                debts[listings[_listingId].highestBidder] += listings[
                    _listingId
                ].highestBid;
            } else {
                emit BidRefunded(
                    _listingId,
                    listings[_listingId].highestBidder,
                    listings[_listingId].highestBid,
                    newBidder,
                    newAmount,
                    block.timestamp
                );
            }
        }
    }

    function _release(
        uint256 _listingId,
        address buyer,
        uint128 amount
    ) private {
        checkAbilityToManageToken(
            listings[_listingId].tokenContract,
            listings[_listingId].tokenId
        );

        if (amount > 0) {
            uint128 marketplaceFeeAmount = _getPortionOfAmount(
                amount,
                listings[_listingId].marketplaceFee
            );
            uint128 royaltiesTotal = 0;

            (
                address[] memory royaltyRecipients,
                uint32[] memory royaltyAmounts
            ) = listings[_listingId].tokenContract.getRoyalties(
                    listings[_listingId].tokenId
                );

            for (uint i = 0; i < royaltyRecipients.length; i++) {
                uint128 royaltyAmount = _getPortionOfAmount(
                    amount,
                    royaltyAmounts[i]
                );

                (bool sentRoyalty, ) = payable(royaltyRecipients[i]).call{
                    value: royaltyAmount
                }("");

                if (sentRoyalty) {
                    emit RoyaltiesPaid(
                        _listingId,
                        royaltyRecipients[i],
                        royaltyAmount,
                        listings[_listingId].tokenContract,
                        listings[_listingId].tokenId,
                        block.timestamp
                    );
                } else {
                    debts[royaltyRecipients[i]] += royaltyAmount;
                }

                royaltiesTotal += royaltyAmount;
            }

            if (listings[_listingId].royalties.total > 0) {
                for (
                    uint i = 0;
                    i < listings[_listingId].royalties.recipients.length;
                    i++
                ) {
                    uint128 royaltyAmount = _getPortionOfAmount(
                        amount,
                        listings[_listingId].royalties.amounts[i]
                    );

                    (bool sentRoyalty2, ) = payable(
                        listings[_listingId].royalties.recipients[i]
                    ).call{value: royaltyAmount}("");

                    if (sentRoyalty2) {
                        emit SecondaryRoyaltiesPaid(
                            _listingId,
                            listings[_listingId].royalties.recipients[i],
                            royaltyAmount,
                            listings[_listingId].tokenContract,
                            listings[_listingId].tokenId,
                            block.timestamp
                        );
                    } else {
                        debts[
                            listings[_listingId].royalties.recipients[i]
                        ] += royaltyAmount;
                    }

                    royaltiesTotal += royaltyAmount;
                }
            }

            uint128 sellerAmount = amount -
                marketplaceFeeAmount -
                royaltiesTotal;

            (bool sent, ) = payable(listings[_listingId].seller).call{
                value: sellerAmount
            }("");

            require(sent, "Failed to send money");
            emit SellerPaid(
                _listingId,
                listings[_listingId].seller,
                sellerAmount,
                listings[_listingId].tokenContract,
                listings[_listingId].tokenId,
                block.timestamp
            );

            marketplaceIncome += marketplaceFeeAmount;
            if (marketplaceFeeAmount > 0) {
                emit MarketplaceFeeReceived(
                    listings[_listingId].tokenContract,
                    listings[_listingId].tokenId,
                    marketplaceFeeAmount,
                    block.timestamp
                );
            }
        }

        listings[_listingId].tokenContract.transferFrom(
            listings[_listingId].tokenContract.ownerOf(
                listings[_listingId].tokenId
            ),
            buyer,
            listings[_listingId].tokenId
        );

        _resetListing(_listingId);
    }

    function stop() external onlyOwner {
        if (isActive) {
            isActive = false;

            emit ContractStoppped(block.timestamp);
        }
    }

    function start() external onlyOwner {
        if (!isActive) {
            isActive = true;

            emit ContractStarted(block.timestamp);
        }
    }

    function name() external view virtual returns (string memory) {
        return _name;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Manageable is Ownable {

    // the manager of contract from marketplace side
    address private _manager;

    event ManagershipTransfered(address newManager, address oldManager);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyManager() {
        _checkManager();
        _;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkManager() internal view virtual {
        require(manager() == _msgSender(), "Caller is not the manager of contract");
    }

    function manager() public view returns(address)
    {
        return _manager;
    }

    function transferMangership(address newManager) onlyOwner
        external
    {
        require(newManager != address(0), 'Manager can not be a null address');

        _transferMangership(newManager);
    }

    function _transferMangership(address newManager)
        internal virtual
    {
        address oldManager = _manager;
        _manager = newManager;

        emit ManagershipTransfered(_manager, oldManager);
    }
}