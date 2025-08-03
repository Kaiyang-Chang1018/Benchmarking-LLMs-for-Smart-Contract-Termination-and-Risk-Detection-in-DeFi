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
// Copyright (c) 2022-2023 Fellowship

pragma solidity ^0.8.22;
import "./libs/EarlyAccessSale.sol";
import "./libs/Shuffler.sol";

struct AuctionStage {
    /// @notice Amount that the price drops (in wei) every slot (every 12 seconds)
    uint256 priceDropPerSlot;
    /// @notice Price where this auction stage ends (in wei)
    uint256 endPrice;
    /// @notice The duration of time that this stage will last, in seconds
    uint256 duration;
}

struct AuctionStageConfiguration {
    /// @notice Amount that the price drops (in wei) every slot (every 12 seconds)
    uint256 priceDropPerSlot;
    /// @notice Price where this auction stage ends (in wei)
    uint256 endPrice;
}

contract FellowshipDutchAuction is EarlyAccessSale, Shuffler {
    INFT private constant CONTRACT_AD = INFT(0x9CF0aB1cc434dB83097B7E9c831a764481DEc747);
    INFT private constant CONTRACT_FPP = INFT(0xA8A425864dB32fCBB459Bf527BdBb8128e6abF21);

    /// @notice ERC-721 contract whose tokens are minted by this auction
    /// @dev Must implement MintableById and allow minting out of order
    address public tokenContract;

    /// @notice Starting price for the Dutch auction (in wei)
    uint256 public startPrice;

    /// @notice Lowest price at which a token was minted (in wei)
    uint256 public lowestPrice;

    uint256 public mintLimit;

    /// @notice Stages for this auction, in order
    AuctionStage[] public auctionStages;

    /// @notice Number of tokens that have been minted per address
    mapping(address => uint256) public mintCount;
    /// @notice Total amount paid to mint per address
    mapping(address => uint256) public mintPayment;

    mapping(address => uint256) public discountsCount;

    uint256 public totalMintedWithDiscount;

    uint256 private previousPayment = 0;

    /// @notice An event emitted upon purchases
    event Purchase(address purchaser, uint256 tokenId, uint256 price);

    /// @notice An event emitted when reserve tokens are minted
    event Reservation(address recipient, uint256 quantity, uint256 totalReserved);

    /// @notice An event emitted when a refund is sent to a minter
    event Refund(address recipient, uint256 amount);

    /// @notice An error returned when the auction has reached its `mintLimit`
    error SoldOut();

    error FailedWithdraw(uint256 amount, bytes data);

    constructor(
        address tokenContract_,
        uint256 startTime_,
        uint256 startPrice_,
        uint256 earlyPriceDrop,
        uint256 transitionPrice,
        uint256 latePriceDrop,
        uint256 restPrice,
        uint256 earlyAccessDuration_,
        uint16[] memory shufflerConfig
    ) EarlyAccessSale(startTime_, earlyAccessDuration_) {
        // CHECKS inputs
        require(address(tokenContract_) != address(0), "Token contract must not be the zero address");

        require(restPrice > 1e15, "Rest price too low: check that prices are in wei");
        require(startPrice_ >= transitionPrice, "Start price must not be lower than transition price");
        require(transitionPrice >= restPrice, "Transition price must not be lower than rest price");

        uint256 earlyPriceDifference;
        uint256 latePriceDifference;
        unchecked {
            earlyPriceDifference = startPrice_ - transitionPrice;
            latePriceDifference = transitionPrice - restPrice;
        }
        require(earlyPriceDrop * 25 <= earlyPriceDifference, "Initial stage must last at least 5 minutes");
        require(latePriceDrop * 25 <= latePriceDifference, "Final stage must last at least 5 minutes");
        require(earlyPriceDifference % earlyPriceDrop == 0, "Transition price must be reachable by earlyPriceDrop");
        require(latePriceDifference % latePriceDrop == 0, "Resting price must be reachable by latePriceDrop");
        require(
            earlyPriceDrop * (5 * 60 * 12) >= earlyPriceDifference,
            "Initial stage must not last longer than 12 hours"
        );
        require(latePriceDrop * (5 * 60 * 12) >= latePriceDifference, "Final stage must not last longer than 12 hours");

        // EFFECTS
        tokenContract = tokenContract_;
        lowestPrice = startPrice = startPrice_;

        unchecked {
            AuctionStage storage earlyStage = auctionStages.push();
            earlyStage.priceDropPerSlot = earlyPriceDrop;
            earlyStage.endPrice = transitionPrice;
            earlyStage.duration = (12 * earlyPriceDifference) / earlyPriceDrop;

            AuctionStage storage lateStage = auctionStages.push();
            lateStage.priceDropPerSlot = latePriceDrop;
            lateStage.endPrice = restPrice;
            lateStage.duration = (12 * latePriceDifference) / latePriceDrop;
        }
        _setUp(shufflerConfig);
        mintLimit = shufflerConfig.length;
    }

    /// @notice Mint multiple tokens on the `tokenContract` contract. Must pay at least `currentPrice` * `quantity`.
    /// @param quantity The number of tokens to mint: must not be greater than `publicLimit`
    function mintMultiple(uint256 quantity) public payable virtual publicMint whenNotPaused {
        // CHECKS state and inputs
        uint256 remaining = remainingValueCount;
        if (remaining == 0) revert SoldOut();
        uint256 alreadyMinted = mintCount[msg.sender];
        require(quantity > 0, "Must mint at least one token");

        uint256 price = msg.value / quantity;
        uint256 slotPrice = currentPrice();
        require(price >= slotPrice, "Insufficient payment");

        // EFFECTS
        if (quantity > remaining) {
            quantity = remaining;
        }

        unchecked {
            // Unchecked arithmetic: mintCount cannot exceed mintLimit
            mintCount[msg.sender] = alreadyMinted + quantity;
            // Unchecked arithmetic: can't exceed total existing wei; not expected to exceed mintLimit * startPrice
            mintPayment[msg.sender] += msg.value;
        }

        if (slotPrice < lowestPrice) {
            lowestPrice = slotPrice;
        }

        uint256 tokensOwnedInContractAD = CONTRACT_AD.balanceOf(msg.sender);
        uint256 tokensOwnedInContractFPP = CONTRACT_FPP.balanceOf(msg.sender);
        uint256 potentialDiscounts = tokensOwnedInContractAD + tokensOwnedInContractFPP;

        if (potentialDiscounts >=  quantity + discountsCount[msg.sender]) {
          discountsCount[msg.sender] += quantity;
          totalMintedWithDiscount += quantity;
        } else {
          if (potentialDiscounts > discountsCount[msg.sender]) {
            uint256 maxDiscounts = potentialDiscounts - discountsCount[msg.sender];
            discountsCount[msg.sender] += maxDiscounts;
            totalMintedWithDiscount += maxDiscounts;
          }
        }
        

        // INTERACTIONS: call mint on known contract (tokenContract.mint contains no external interactions)
        unchecked {
            for (uint256 i = 0; i < quantity; i++) {
                uint256 tokenId = drawNext();
                emit Purchase(msg.sender, tokenId, price);        
                try INFT(tokenContract).ownerOf(tokenId) returns (address _owner) {
                    if (_owner == address(0)){
                        INFT(tokenContract).mint(msg.sender, tokenId);
                    } else {
                        INFT(tokenContract).transferFrom(_owner, msg.sender, tokenId);
                    }
                }
                catch {
                    INFT(tokenContract).mint(msg.sender, tokenId);
                }
            }
        }
    }

    /// @notice Send any available refund to the message sender
    function refund() external returns (uint256) {
        // CHECK available refund
        uint256 refundAmount = refundAvailable(msg.sender);
        require(refundAmount > 0, "No refund available");

        // EFFECTS
        unchecked {
            // Unchecked arithmetic: refundAmount will always be less than mintPayment
            mintPayment[msg.sender] -= refundAmount;
        }

        emit Refund(msg.sender, refundAmount);

        // INTERACTIONS
        (bool refunded, ) = msg.sender.call{value: refundAmount}("");
        require(refunded, "Refund transfer was reverted");

        return refundAmount;
    }

    // OWNER FUNCTIONS

    /// @notice withdraw auction proceeds
    /// @dev Can only be called by the contract `owner`. Reverts if the final price is unknown, if proceeds have already
    ///  been withdrawn, or if the fund transfer fails.
    function withdraw(address recipient) external onlyOwner {
        // CHECKS contract state
        uint256 remaining = remainingValueCount;
        bool soldOut = remaining == 0;
        uint256 finalPrice = lowestPrice;
        if (!soldOut) {
            finalPrice = auctionStages[auctionStages.length - 1].endPrice;

            // Only allow a withdraw before the auction is sold out if the price has finished falling
            require(currentPrice() == finalPrice, "Price is still falling");
        }
        uint256 totalSold = (mintLimit - remainingValueCount);
        uint256 totalSoldWithoutDiscount = totalSold - totalMintedWithDiscount;
        uint256 totalPayment = (totalSoldWithoutDiscount * finalPrice)
          + (totalMintedWithDiscount * finalPrice * 90/100);
        require(totalPayment > previousPayment, "All funds have been withdrawn");

        // EFFECTS
        uint256 outstandingPayment = totalPayment - previousPayment;
        uint256 balance = address(this).balance;
        if (outstandingPayment > balance) {
            // Escape hatch to prevent stuck funds, but this shouldn't happen
            require(balance > 0, "All funds have been withdrawn");
            outstandingPayment = balance;
        }

        previousPayment += outstandingPayment;
        (bool success, bytes memory data) = recipient.call{value: outstandingPayment}("");
        if (!success) revert FailedWithdraw(outstandingPayment, data);
    }

    /// @notice Update the tokenContract contract address
    /// @dev Can only be called by the contract `owner`. Reverts if the auction has already started.
    function setMintable(address tokenContract_) external unstarted onlyOwner {
        // CHECKS inputs
        require(address(tokenContract_) != address(0), "Token contract must not be the zero address");
        // EFFECTS
        tokenContract = tokenContract_;
    }

    /// @notice Update the auction price ranges and rates of decrease
    /// @dev Since the values are validated against each other, they are all set together. Can only be called by the
    ///  contract `owner`. Reverts if the auction has already started.
    function setPricing(
        uint256 startPrice_,
        AuctionStageConfiguration[] calldata stages_
    ) external unstarted onlyOwner {
        // CHECKS inputs
        uint256 stageCount = stages_.length;
        require(stageCount > 0, "Must specify at least one auction stage");

        // EFFECTS + additional CHECKS
        uint256 previousPrice = startPrice = startPrice_;
        delete auctionStages;

        for (uint256 i; i < stageCount; i++) {
            AuctionStageConfiguration calldata config = stages_[i];
            require(config.endPrice < previousPrice, "Each stage price must be lower than the previous price");
            require(config.endPrice > 1e15, "Stage price too low: check that prices are in wei");

            uint256 priceDifference = previousPrice - config.endPrice;
            require(config.priceDropPerSlot * 25 <= priceDifference, "Each stage must last at least 5 minutes");
            require(
                priceDifference % config.priceDropPerSlot == 0,
                "Stage end price must be reachable by slot price drop"
            );
            require(
                config.priceDropPerSlot * (5 * 60 * 12) >= priceDifference,
                "Stage must not last longer than 12 hours"
            );

            AuctionStage storage newStage = auctionStages.push();
            newStage.duration = (12 * priceDifference) / config.priceDropPerSlot;
            newStage.priceDropPerSlot = config.priceDropPerSlot;
            newStage.endPrice = previousPrice = config.endPrice;
        }
    }

    // VIEW FUNCTIONS

    /// @notice Query the current price
    function currentPrice() public view returns (uint256 price) {
        uint256 time = timeElapsed();

        price = startPrice;
        uint256 stageCount = auctionStages.length;
        uint256 stageDuration;
        AuctionStage storage stage;
        for (uint256 i = 0; i < stageCount; i++) {
            stage = auctionStages[i];
            stageDuration = stage.duration;
            if (time < stageDuration) {
                unchecked {
                    uint256 drop = stage.priceDropPerSlot * (time / 12);
                    return price - drop;
                }
            }

            // Proceed to the next stage
            unchecked {
                time -= stageDuration;
            }
            price = auctionStages[i].endPrice;
        }

        // Auction has reached resting price
        return price;
    }

    /// @notice Query the refund available for the specified `minter`
    function refundAvailable(address minter) public view returns (uint256) {
        uint256 minted = mintCount[minter];
        if (minted == 0) return 0;

        uint256 refundPrice = remainingValueCount == 0 ? lowestPrice : currentPrice();

        uint256 payment = mintPayment[minter];
        uint256 newPayment;
        uint256 refundAmount;
        uint256 mintedWOD = minted - discountsCount[minter];
        unchecked {
            // Unchecked arithmetic: newPayment cannot exceed mintLimit * startPrice
            newPayment = (mintedWOD * refundPrice) + (discountsCount[minter] * refundPrice * 90/100);
            // Unchecked arithmetic: value only used if newPayment < payment
            refundAmount = payment - newPayment;
        }

        return (newPayment < payment) ? refundAmount : 0;
    }
}

interface INFT {
  function balanceOf(address account) external view returns (uint256);
  function mint(address to, uint256 tokenId) external;
  function ownerOf(uint256 tokenId) external view returns (address);
  function transferFrom(address from, address to, uint256 tokenId) external;
}
// SPDX-License-Identifier: MIT
// Copyright (c) 2022 - 2023 Fellowship

pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract EarlyAccessSale is Ownable {
    /// @notice Timestamp when this auction starts allowing minting
    uint256 public startTime;

    /// @notice Duration of the early access period where minting is limited to pass holders
    uint256 public earlyAccessDuration;

    /// @notice Whether or not this contract is paused
    /// @dev The exact meaning of "paused" will vary by contract, but in general paused contracts should prevent most
    ///  interactions from non-owners
    bool public isPaused = false;
    uint256 private pauseStart;
    uint256 internal pastPauseDelay;

    event Paused();
    event Unpaused();

    /// @notice An error returned when the auction has already started
    error AlreadyStarted();
    /// @notice An error returned when the auction has not yet started
    error NotYetStarted();

    /// @notice An error returned when minting during early access without a pass
    error EarlyAccessWithoutPass();

    error ContractIsPaused();
    error ContractNotPaused();

    constructor(uint256 startTime_, uint256 earlyAccessDuration_) {
        // CHECKS inputs
        require(startTime_ >= block.timestamp, "Start time cannot be in the past");
        require(earlyAccessDuration_ <= 60 * 60 * 24, "Early access must not last longer than 24 hours");

        // EFFECTS
        startTime = startTime_;
        earlyAccessDuration = earlyAccessDuration_;
    }

    modifier started() {
        if (!isStarted()) revert NotYetStarted();
        _;
    }
    modifier unstarted() {
        if (isStarted()) revert AlreadyStarted();
        _;
    }

    modifier publicMint() {
        if (!isPublic()) revert EarlyAccessWithoutPass();
        _;
    }

    modifier whenPaused() {
        if (!isPaused) revert ContractNotPaused();
        _;
    }

    modifier whenNotPaused() {
        if (isPaused) revert ContractIsPaused();
        _;
    }

    // OWNER FUNCTIONS

    /// @notice Pause this contract
    /// @dev Can only be called by the contract `owner`
    function pause() public virtual whenNotPaused onlyOwner {
        // EFFECTS (checks already handled by modifiers)
        isPaused = true;
        pauseStart = block.timestamp;
        emit Paused();
    }

    /// @notice Resume this contract
    /// @dev Can only be called by the contract `owner`
    function unpause() public virtual whenPaused onlyOwner {
        // EFFECTS (checks already handled by modifiers)
        isPaused = false;
        emit Unpaused();

        // See if pastPauseDelay needs updated
        if (block.timestamp <= startTime) {
            return;
        }
        // Find the amount time the auction should have been live, but was paused
        unchecked {
            // Unchecked arithmetic: computed value will be < block.timestamp and >= 0
            if (pauseStart < startTime) {
                pastPauseDelay = block.timestamp - startTime;
            } else {
                pastPauseDelay += (block.timestamp - pauseStart);
            }
        }
    }

    /// @notice Update the auction start time
    /// @dev Can only be called by the contract `owner`. Reverts if the auction has already started.
    function setStartTime(uint256 startTime_) external unstarted onlyOwner {
        // CHECKS inputs
        require(startTime_ >= block.timestamp, "New start time cannot be in the past");
        // EFFECTS
        startTime = startTime_;
    }

    /// @notice Update the duration of the early access period
    /// @dev Can only be called by the contract `owner`. Reverts if the auction has already started.
    function setEarlyAccessDuration(uint256 duration) external unstarted onlyOwner {
        // CHECKS inputs
        require(duration <= 60 * 60 * 24, "Early access must not last longer than 24 hours");

        // EFFECTS
        earlyAccessDuration = duration;
    }

    // VIEW FUNCTIONS

    /// @notice Query if the early access period has ended
    function isPublic() public view returns (bool) {
        return isStarted() && block.timestamp >= (startTime + pastPauseDelay + earlyAccessDuration);
    }

    /// @notice Query if this contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @return `true` if `interfaceID` is implemented and is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x7f5828d0 || // ERC-173 Contract Ownership Standard
            interfaceId == 0x01ffc9a7; // ERC-165 Standard Interface Detection
    }

    // INTERNAL FUNCTIONS

    function isStarted() internal view virtual returns (bool) {
        return (isPaused ? pauseStart : block.timestamp) >= startTime;
    }

    function timeElapsed() internal view returns (uint256) {
        if (!isStarted()) return 0;
        unchecked {
            // pastPauseDelay cannot be greater than the time passed since startTime
            if (!isPaused) {
                return block.timestamp - startTime - pastPauseDelay;
            }

            // pastPauseDelay cannot be greater than the time between startTime and pauseStart
            return pauseStart - startTime - pastPauseDelay;
        }
    }
}
// SPDX-License-Identifier: MIT
// Copyright (c) 2023 Fellowship

pragma solidity ^0.8.20;

/// @notice A contract that draws (without replacement) pseudorandom shuffled values
/// @dev Uses prevrandao and Fisher-Yates shuffle to return values one at a time
contract Shuffler {
    uint256 internal remainingValueCount;
    uint16[] private shuffleValues;

    function _setUp(uint16[] memory remainingValues) internal {
        shuffleValues = remainingValues;
        remainingValueCount = remainingValues.length;
    }

    function drawNext() internal returns (uint256) {
        require(remainingValueCount > 0, "Shuffled values have been exhausted");

        uint16 swapValue;
        swapValue = shuffleValues[remainingValueCount - 1];

        if (remainingValueCount == 1) {
            remainingValueCount = 0;
            return swapValue;
        }

        uint256 randomIndex = uint256(keccak256(abi.encodePacked(remainingValueCount, block.prevrandao))) %
            remainingValueCount;
        remainingValueCount--;

        uint256 drawnValue = shuffleValues[randomIndex];
        shuffleValues[randomIndex] = swapValue;

        return drawnValue;
    }
}