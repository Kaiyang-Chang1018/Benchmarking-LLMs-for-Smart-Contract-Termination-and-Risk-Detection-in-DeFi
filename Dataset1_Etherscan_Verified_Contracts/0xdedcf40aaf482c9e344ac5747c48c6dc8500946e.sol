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
// Copyright (c) 2022-2023 Fellowship

pragma solidity ^0.8.25;
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

contract AUDutch is EarlyAccessSale, Shuffler {
    
    address public tokenContract;
    uint256 public startPrice;
    uint256 public lowestPrice;
    uint256 private immutable mintLimit;
    INFT private immutable CONTRACT_AD; //mainnet: 0x9CF0aB1cc434dB83097B7E9c831a764481DEc747;


    IDelegateRegistry private constant REGISTRY = IDelegateRegistry(0x00000000000000447e69651d841bD8D104Bed493);
    uint256 private constant START_PRICE = 0.5 ether;
    uint256 private constant END_PRICE = 0.1 ether;
    uint256 private constant PRICE_DROP = 0.00177777777 ether;
    uint256 private constant DURATION = 45 minutes;
    uint256 private constant MINTS_PER = 50;

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
        address aDContract_,
        uint256 startTime_,
        uint16[] memory shufflerConfig
    ) EarlyAccessSale(startTime_, 0) {
        tokenContract = tokenContract_;
        lowestPrice = startPrice = START_PRICE;
        CONTRACT_AD = INFT(aDContract_);

        AuctionStage storage onlyStage = auctionStages.push();
        onlyStage.priceDropPerSlot = PRICE_DROP;
        onlyStage.endPrice = END_PRICE;
        onlyStage.duration = DURATION;
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

        // EFFECTS_PER - mintCount[msg.sender];
        require(MINTS_PER >= mintCount[msg.sender] + quantity, "Only 50 mints per address.");

        if (quantity > remaining) {
            quantity = remaining;
        }

        unchecked {
            mintCount[msg.sender] = alreadyMinted + quantity;
            mintPayment[msg.sender] += msg.value;
        }

        if (slotPrice < lowestPrice) {
            lowestPrice = slotPrice;
        }
        uint256 potentialDiscounts = aDCount(msg.sender);

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
                INFT(tokenContract).mint(msg.sender, tokenId);
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
          + (totalMintedWithDiscount * finalPrice * 50/100);
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
            newPayment = (mintedWOD * refundPrice) + (discountsCount[minter] * refundPrice * 50/100);
            // Unchecked arithmetic: value only used if newPayment < payment
            refundAmount = payment - newPayment;
        }

        return (newPayment < payment) ? refundAmount : 0;
    }

    function aDCount(address user) public view returns (uint256 total) {
        total = CONTRACT_AD.balanceOf(user);
        IDelegateRegistry.Delegation[] memory delegations = REGISTRY.getIncomingDelegations(user);
        for(uint256 i; i < delegations.length; i++) {
            IDelegateRegistry.Delegation memory dele = delegations[i];
            if (dele.type_ == IDelegateRegistry.DelegationType.ALL) {
                total += CONTRACT_AD.balanceOf(dele.from);
            }
            if (dele.type_ == IDelegateRegistry.DelegationType.CONTRACT && dele.contract_ == address(CONTRACT_AD)) {
                total += CONTRACT_AD.balanceOf(dele.from);
            }
        }
  }
}

interface INFT {
  function balanceOf(address account) external view returns (uint256);
  function mint(address to, uint256 tokenId) external;
  function ownerOf(uint256 tokenId) external view returns (address);
  function transferFrom(address from, address to, uint256 tokenId) external;
}

interface IDelegateRegistry {
    /// @notice Delegation type, NONE is used when a delegation does not exist or is revoked
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        ERC721,
        ERC20,
        ERC1155
    }

    /// @notice Struct for returning delegations
    struct Delegation {
        DelegationType type_;
        address to;
        address from;
        bytes32 rights;
        address contract_;
        uint256 tokenId;
        uint256 amount;
    }

    function getIncomingDelegations(address to) external view returns (Delegation[] memory delegations);
}
// SPDX-License-Identifier: MIT
// Copyright (c) 2022 - 2023 Fellowship

pragma solidity ^0.8.25;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/access/Ownable.sol";
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

    constructor(uint256 startTime_, uint256 earlyAccessDuration_) Ownable(msg.sender) {
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
    uint16[] internal shuffleValues;

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