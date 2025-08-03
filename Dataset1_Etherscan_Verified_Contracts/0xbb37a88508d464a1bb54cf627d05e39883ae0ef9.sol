// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import { AuctionOwnable } from "./utils/AuctionOwnable.sol";
import { ERC165Checker } from "./oz-simplified/ERC165Checker.sol";
import { ECDSA } from "./oz-simplified/ECDSA.sol";
import { IEscrow } from "./interfaces/IEscrow.sol";
import { ISellerToken } from './interfaces/ISellerToken.sol';
import { ReentrancyGuard } from 'solmate/src/utils/ReentrancyGuard.sol';

import { Errors } from "./library/errors/Errors.sol";

enum BidReturnValue {
    Success,
    BidTooLow,
    AuctionClosed,
    ExtendedBidding
}

enum AuctionStatus {
    Closed,
    Open,
    InExtended,
    Ended,
    DoesntExist,
    Cancelled
}

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Auction is AuctionOwnable, ReentrancyGuard {
    event AuctionAdded(uint256 indexed auctionId, uint48 startTime, uint48 endTime, uint256 indexed claimId, uint256 indexed tokenId);
    event AuctionChanged(uint256 indexed auctionId, uint48 startTime, uint48 endTime, uint256 indexed claimId);
    event AuctionEnded(uint256 indexed auctionId, address indexed winner, uint128 indexed bid);
    event AuctionAborted(uint256 indexed auctionId, bool indexed refunded, string reason);
    event AuctionProceedsClaimed(uint256 indexed auctionId, address indexed seller, address recipient, uint128 indexed amount);
    event AuctionLotClaimed(uint256 indexed auctionId, uint256 indexed claimId, address indexed winner, address recipient);
    event AuctionClosed(uint256 indexed auctionId);
    event AuctionInExtendedBidding(uint indexed auctionId);
    event BidTooLow(uint256 indexed auctionId, uint128 indexed bid, uint128 indexed minHighBid);

    event Bid(
        uint256 indexed auctionId,
        uint256 when,
        address indexed bidder,
        uint128 indexed amount
    );

    struct AuctionData {
        uint256 claimId;

        // token that grants seller claim rights to this auction
        uint256 tokenId;

        // when can bidding start
        uint48 startTime;
        // when is auction over
        uint48 endTime;
        // time in seconds that extended bidding lasts
        uint32 extendedBiddingTime;
        // how much does each bid have to increment over the last bid
        uint64 minBidIncrement;
        // is auction active (accepting bids)
        bool active;
        // has the winner claimed
        bool claimed;
        // was the auction cancelled
        bool cancelled;
        // basis points for buyer's premium
        uint8 basis;

        // high bidder
        address highBidder;
        // amount of high bid
        uint64 highBid;
        // last bid timestamp
        // storing as a delta value so we can fit it in fewer bits, optimizing
        // the cost of reading/writing it from storage
        uint32 lastBidDelta;
    }

    IEscrow private _escrow;
    ISellerToken public _sellerToken;

    uint256 private _lastId;

    mapping(uint256 => AuctionData) private _auctions;
    mapping(uint256 => uint256) public _tokenAuctionMap;

    bool private _requireAuctionVerification = true;

    constructor() {
        __Ownable_init();
    }

    // function initialize() public initializer {
    // 	__Ownable_init();
    // }

    function setup(address escrow, address sellerToken_, bool requireAuctionVerification_) public onlyOwner {
        if (!ERC165Checker.supportsInterface(escrow, type(IEscrow).interfaceId)) {
            revert Errors.InterfaceNotSupported();
        }
        _escrow = IEscrow(escrow);
        _requireAuctionVerification = requireAuctionVerification_;
        _sellerToken = ISellerToken(sellerToken_);
    }

    function addAuction(
        uint48 startTime,
        uint48 endTime,
        uint32 extendedBiddingTime,
        uint64 startBid,
        uint64 increment,
        uint8 basis,
        uint256 claimId,
        address seller
    ) public onlyAuctioneer nonReentrant {
        if (endTime < block.timestamp) {
            revert Errors.OutOfRange(endTime);
        }

        uint256 auctionId = ++_lastId;
        uint256 tokenId = _sellerToken.mint(seller, auctionId);

        _auctions[ auctionId ] = AuctionData({
            claimId: claimId,
            tokenId: tokenId,
            startTime: startTime,
            endTime: endTime,
            extendedBiddingTime: extendedBiddingTime,
            minBidIncrement: increment,
            active: true,
            basis: basis,
            lastBidDelta: uint32(0),
            highBidder: address(0),
            highBid: startBid,
            claimed: false,
            cancelled: false
        });
        emit AuctionAdded(auctionId, startTime, endTime, claimId, tokenId);
    }

    function editAuction(
        uint256 auctionId,
        uint48 startTime,
        uint48 endTime,
        uint32 extendedBiddingTime,
        uint64 increment,
        uint8 basis,
        uint256 claimId
    ) public onlyAuctioneer {
        _auctions[auctionId].startTime = startTime;
        _auctions[auctionId].endTime = endTime;
        _auctions[auctionId].extendedBiddingTime = extendedBiddingTime;
        _auctions[auctionId].minBidIncrement = increment;
        _auctions[auctionId].basis = basis;
        _auctions[auctionId].claimId = claimId;

        emit AuctionChanged(auctionId, startTime, endTime, claimId);
    }

    function abortAuction(uint256 auctionId, bool issueRefund, string memory reason) public onlyAuctioneer {
        _auctions[auctionId].active = false;
        _auctions[auctionId].cancelled = true;
        _sellerToken.burn(_auctions[auctionId].tokenId);
        if (issueRefund) {
            address highBidder = _auctions[auctionId].highBidder;
            if (highBidder != address(0)) {
                uint8 basis = _auctions[auctionId].basis;
                uint256 premium = basis == 0 ? 0 : _auctions[auctionId].highBid * basis / 100;
                _escrow.withdraw(highBidder, _auctions[auctionId].highBid + premium);
            }
        }
        emit AuctionAborted(auctionId, issueRefund, reason);
    }

    function claimLot(uint256 auctionId, address deliverTo) public nonReentrant {
        AuctionData storage auction = _auctions[ auctionId ];
        if (_requireAuctionVerification) {
            if ( auction.active ) {
                revert Errors.AuctionActive(auctionId);
            }
        }

        if (block.timestamp < auction.endTime + 1) {
            revert Errors.AuctionActive(auctionId);
        }

        if (_auctionInExtendedBidding(auction)) {
            revert Errors.AuctionActive(auctionId);
        }

        if (auction.cancelled) {
            revert Errors.AuctionAborted(auctionId);
        }

        if (auction.claimed) {
            revert Errors.AlreadyClaimed(auctionId);
        }

        if (_msgSender() != auction.highBidder) {
            revert Errors.BadSender(auction.highBidder, _msgSender());
        }

        if (false == _requireAuctionVerification) {
            _escrow.authorizeClaim(auction.claimId, auction.highBidder);
        }
        auction.claimed = true;
        _escrow.claimFor(_msgSender(), auction.claimId, deliverTo);
        emit AuctionLotClaimed(auctionId, auction.claimId, _msgSender(), deliverTo);
    }

    function claimProceeds(uint256 auctionId, address deliverTo) public nonReentrant {
        AuctionData storage auction = _auctions[ auctionId ];

        if (_requireAuctionVerification) {
            if ( true == auction.active ) {
                revert Errors.AuctionActive(auctionId);
            }
        }

        if (block.timestamp < auction.endTime + 1) {
            revert Errors.AuctionActive(auctionId);
        }

        if (_auctionInExtendedBidding(auction)) {
            revert Errors.AuctionActive(auctionId);
        }

        if (auction.cancelled) {
            revert Errors.AuctionAborted(auctionId);
        }

        address tokenOwner = _sellerToken.ownerOf(auction.tokenId);

        if ( _msgSender() != tokenOwner) {
            revert Errors.BadSender(tokenOwner, _msgSender());
        }

        _sellerToken.burn(auction.tokenId);
        _escrow.withdraw(deliverTo, auction.highBid);
        emit AuctionProceedsClaimed(auctionId, _msgSender(), deliverTo, auction.highBid);
    }

    function confirmAuctions(uint256[] calldata auctionIds, address[] calldata premiumRecipients) public nonReentrant onlyAuctioneer {
        uint256 auctionLength = auctionIds.length;
        if (auctionLength != premiumRecipients.length) {
            revert Errors.ArrayMismatch();
        }

        for (uint i = 0; i < auctionLength;) {
            confirmAuction(auctionIds[ i ], premiumRecipients[ i ]);

            unchecked {
                ++i;
            }
        }
    }

    function confirmAuction(uint256 auctionId, address premiumRecipient) public nonReentrant onlyAuctioneer {
        AuctionData storage auction = _auctions[auctionId];

        if (block.timestamp < auction.endTime + 1) {
            revert Errors.AuctionActive(auctionId);
        }

        if (_auctionInExtendedBidding(auction)) {
            revert Errors.AuctionActive(auctionId);
        }

        if (auction.cancelled) {
            revert Errors.AuctionAborted(auctionId);
        }

        // require auctions to be active to call this method, so we don't
        // double-widthdraw the buyer premium
        if (false == auction.active) {
            revert Errors.AuctionInactive(auctionId);
        }

        auction.active = false;
        emit AuctionEnded(auctionId, auction.highBidder, auction.highBid);

        if (auction.highBidder != address(0)) {
            if (false == auction.claimed && _requireAuctionVerification) {
                _escrow.authorizeClaim(auction.claimId, auction.highBidder);
            }

            if (auction.basis > 0) {
                if (address(0) == premiumRecipient) {
                    revert Errors.AddressTarget(premiumRecipient);
                }

                _escrow.withdraw(premiumRecipient, auction.highBid * auction.basis / 100);
            }
        }
    }

    function getAuctionMetadata(uint256 auctionId) public view returns (AuctionData memory) {
        return _auctions[auctionId];
    }

    function bid(
        uint256 auctionId,
        uint64 amount,
        bool revertOnFail
    ) public nonReentrant {
        _bid(_msgSender(), auctionId, amount, revertOnFail);
    }

    function multiBid(
        uint256[] memory auctionIds,
        uint64[] memory amounts,
        bool revertOnFail
    ) public nonReentrant {
        uint256 arrayLength = auctionIds.length;
        if (arrayLength != amounts.length) {
            revert Errors.ArrayMismatch();
        }

        address bidder = _msgSender();

        for (uint256 i = 0; i < arrayLength;) {
            _bid(bidder, auctionIds[i], amounts[i], revertOnFail);

            unchecked {
                ++i;
            }
        }
    }

    function auctionStatus(uint256 auctionId) public view returns(AuctionStatus) {
        AuctionData storage a = _auctions[ auctionId ];

        if (a.startTime == 0) {
            return AuctionStatus.DoesntExist;
        }

        if (a.cancelled) {
            return AuctionStatus.Cancelled;
        }

        if (block.timestamp < a.startTime) {
            return AuctionStatus.Closed;
        }

        if (block.timestamp < a.endTime + 1) {
            return AuctionStatus.Open;
        }

        if (_auctionInExtendedBidding(a)) {
            return AuctionStatus.InExtended;
        }

        return AuctionStatus.Ended;
    }

    /**
     *  ================== INTERNAL METHODS ====================
     */

    function _bid(
        address bidder,
        uint256 auctionId,
        uint64 amount,
        bool revertOnError
    ) internal returns (BidReturnValue) {
        uint256 timestamp = block.timestamp;
        AuctionData storage auction = _auctions[ auctionId ];
        if (timestamp > auction.endTime) {
            if ( false == _auctionInExtendedBidding(auction)) {
               // auction is over
                if (revertOnError) {
                    revert Errors.AuctionClosed(auctionId);
                }

                emit AuctionClosed(auctionId);
                return BidReturnValue.AuctionClosed;
            }
        }

        if (false == auction.active) {
            if (revertOnError) {
                revert Errors.AuctionClosed(auctionId);
            }

            emit AuctionClosed(auctionId);
            return BidReturnValue.AuctionClosed;
        }

        if (timestamp < auction.startTime) {
            if (revertOnError) {
                revert Errors.AuctionClosed(auctionId);
            }

            emit AuctionClosed(auctionId);
            return BidReturnValue.AuctionClosed;
        }

        uint64 previousAmount = auction.highBid;

        // bid is too low
        if (amount < previousAmount + auction.minBidIncrement) {
            if (revertOnError) {
                revert Errors.BidTooLow(auctionId, amount, previousAmount + auction.minBidIncrement);
            }

            emit BidTooLow(auctionId, amount, previousAmount + auction.minBidIncrement);
            return BidReturnValue.BidTooLow;
        }

        uint256 premium = auction.basis == 0 ? 0 : amount * auction.basis / 100;

        _escrow.deposit(bidder, amount + premium);
        address prevBidder = auction.highBidder;
        if (prevBidder != address(0)) {
            uint256 prevPremium = auction.basis == 0 ? 0 : previousAmount * auction.basis / 100;
            _escrow.withdraw(prevBidder, previousAmount + prevPremium);
        }

        /**
         * There needs to be 2 bidders on a Lot to send it into extended bidding
         * when no bids, bidder == 0x0. first bidder != 0x0, so decrement required count
         * if second bidder != first bidder, decrement required count
         * once we get to zero, we know we'll be going into extended bidding.
         */
        // if (0 < auction.extendedBiddingTime) {
        //     if (0 < auction.extBidRequiredBids) {
        //         if (prevBidder != bidder) {
        //             unchecked {
        //                 // can't overflow, value checked to be above zero, above.
        //                 --auction.extBidRequiredBids;
        //             }
        //         }
        //     }
        // }

        auction.highBidder = bidder;
        auction.highBid = amount;
        // only write the bid-time delta if we're in extended bidding
        // it's irrelevant, otherwise.
        if (auction.endTime < timestamp) {
            auction.lastBidDelta = uint32(timestamp - auction.endTime);
        }

        emit Bid(auctionId, timestamp, bidder, amount);
        return BidReturnValue.Success;
    }

    function _auctionInExtendedBidding(AuctionData storage auction) internal view returns(bool) {
        uint tmpEndTime = auction.endTime;
        if (block.timestamp > auction.endTime) {
            uint tmpExtTime = auction.extendedBiddingTime;
            if (0 < tmpExtTime) {
                uint extendedEndTime = tmpEndTime + tmpExtTime;
                // uint tmpDelta = auction.lastBidDelta;
                if (0 < auction.lastBidDelta) {
                    extendedEndTime = tmpEndTime + auction.lastBidDelta + tmpExtTime;
                }

                /*
                * auction is over if we're past the extended bidding time, no matter what
                *
                * or
                *
                * we require 2+ bids to enter extended bidding. so, if we're past the auction endTime (tested above)
                * and we need more than 0 bids to enter extended bidding
                * (required bids is decremented from 2 to 0 on the first two bids)
                * then we never went into extended bidding, and thus, the auction is over
                **/
                if (block.timestamp > extendedEndTime) {
                    // auction is over
                    return false;
                }

                // if we get here, then current timestamp is between endTime and extendedEndTime
                // and aucton.extBidRequireBids == 0
                return true;
            }
        }

        return false;
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer.
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
     * - If the caller is not `from`, it must have been allowed to move this token by either
     * {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer.
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
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

interface IEscrow {
    event Withdrawal(uint256 indexed amount, address indexed withdrawer);
    event Deposit(uint256 indexed amount, address indexed depositer);
    event ClaimAuthorized(uint256 indexed claimId, address indexed claimant);
    event PrizeAdded(uint256 indexed claimId);
    event PrizeRemoved(uint256 indexed claimId, address indexed recipient);
    event PrizeReceived(uint256 indexed claimId, address indexed recipient);

    function currencyBalance() external returns (uint256);

    function deposit(address spender, uint256 amount) external;

    function withdraw(address recipient, uint256 amount) external;

    function authorizeClaim(uint256 claimId, address claimant) external;

    function claimFor(address claimant, uint256 claimId, address recipient) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import './IERC721.sol';

interface ISellerToken is IERC721 {
    function mint(address dest, uint256 tokenId) external returns (uint256);
    function burn(uint256 tokenId) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.4 <0.9.0;

library Errors {
    error LinkError();
    error ArrayMismatch();
    error OutOfRange(uint256 value);
    error OutOfRangeSigned(int256 value);
    error UnsignedOverflow(uint256 value);
    error SignedOverflow(int256 value);
    error DuplicateCall();

    error NotAContract();
    error InterfaceNotSupported();
    error NotInitialized();
    error AlreadyInitialized();
    error BadSender(address expected, address caller);
    error AddressTarget(address target);
    error UserPermissions();

    error InvalidHash();
    error InvalidSignature();
    error InvalidSignatureLength();
    error InvalidSignatureS();

    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientSupply(uint256 supply, uint256 available, int256 requested);  // 0x5437b336
    error InsufficientAvailable(uint256 available, uint256 requested);
    error InvalidToken(uint256 tokenId);                                            // 0x925d6b18
    error TokenNotMintable(uint256 tokenId);
    error InvalidTokenType();

    error ERC1155Receiver();

    error ContractPaused();

    error PaymentFailed(uint256 amount);
    error IncorrectPayment(uint256 required, uint256 provided);                     // 0x0d35e921
	error TooManyForTransaction(uint256 mintLimit, uint256 amount);

    error AuctionInactive(uint256 auctionId);
    error AuctionActive(uint256 auctionId);
    error InvalidBid(uint256 auctionId, uint256 amount);
    error BidTooLow(uint256 auctionId, uint256 bid, uint256 minBid);
    error AuctionClosed(uint256 auctionId);
    error AuctionInExtendedBidding(uint256 auctionId);
    error AuctionAborted(uint256 auctionId);

    error AlreadyClaimed(uint256 lotId);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import { Initializable } from "./Initializable.sol";

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
abstract contract Context is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import { Errors } from "../library/errors/Errors.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert Errors.InvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert Errors.InvalidSignatureLength();
        } else if (error == RecoverError.InvalidSignatureS) {
            revert Errors.InvalidSignatureS();
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "../interfaces/IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface.
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && supportsERC165InterfaceUnchecked(account, interfaceId);
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import { Errors } from "../library/errors/Errors.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // require(_initializing || !_initialized, "Initializable: contract is already initialized");
        if (!_initializing && _initialized) revert Errors.AlreadyInitialized();

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import { Context } from "../oz-simplified/Context.sol";
import { Initializable } from "../oz-simplified/Initializable.sol";

import { Errors } from "../library/errors/Errors.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there are two accounts (an owner and a proxy) that can be granted exclusive
 * access to specific functions. Only the owner can set the proxy.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract AuctionOwnable is Initializable, Context {
    address private _owner;
    address private _auctioneer;
    address private _broker;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // /**
    //  * @dev Returns the address of the current auctioneer.
    //  */
    // function auctioneer() public view virtual returns (address) {
    //     return _auctioneer;
    // }

    // /**
    //  * @dev Returns the address of the current broker.
    //  */
    // function broker() public view virtual returns (address) {
    //     return _broker;
    // }

    /**
     * @dev Returns true if the account has the auctioneer role.
     */

    function isAuctioneer(address account) public view virtual returns (bool) {
        return account == _auctioneer;
    }

    /**
     * @dev Returns true if the account has the broker role.
     */

    function isBroker(address account) public view virtual returns (bool) {
        return account == _broker;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        if (_owner != _msgSender()) revert Errors.UserPermissions();
        _;
    }

    /**
     * @dev Throws if called by any account other than the auctioneer.
     */
    modifier onlyAuctioneer() {
        if (
            _auctioneer != _msgSender()
            && _owner != _msgSender()
        ) revert Errors.UserPermissions();
        _;
    }

    /**
     * @dev Throws if called by any account other than the broker.
     */
    modifier onlyBroker() {
        if (
            _broker != _msgSender()
            && _owner != _msgSender()
        ) revert Errors.UserPermissions();
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) revert Errors.AddressTarget(newOwner);
        _setOwner(newOwner);
    }

    /**
     * @dev Sets the auctioneer for the contract to a new account (`newAuctioneer`).
     * Can only be called by the current owner.
     */
    function setAuctioneer(address newAuctioneer) public virtual onlyOwner {
        _auctioneer = newAuctioneer;
    }

    /**
     * @dev Sets the auctioneer for the contract to a new account (`newAuctioneer`).
     * Can only be called by the current owner.
     */
    function setBroker(address newBroker) public virtual onlyOwner {
        _broker = newBroker;
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}