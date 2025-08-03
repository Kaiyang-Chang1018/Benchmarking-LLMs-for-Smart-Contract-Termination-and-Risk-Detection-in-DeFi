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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

// LICENSE
// SlothAuctionHouse.sol is a modified version of Zora's AuctionHouse.sol:
// https://github.com/ourzora/auction-house/blob/54a12ec1a6cf562e49f0a4917990474b11350a2d/contracts/AuctionHouse.sol
//
// AuctionHouse.sol source code Copyright Zora licensed under the GPL-3.0 license.
// With modifications by Sloth.

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { ISlothAuctionHouse } from "./interfaces/ISlothAuctionHouse.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

contract SlothAuctionHouse is ISlothAuctionHouse, Ownable, ReentrancyGuard {
  using Counters for Counters.Counter;

  // The minimum amount of time left in an auction after a new bid is created
  uint256 public defaultTimeBuffer = 300; // 5min

  // Offset time for auction closing time (Based on UTC+0)
  uint256 public endTimeOffset = 3600 * 12;

  // The minimum price accepted in an auction
  uint256 public defaultReservePrice = 10000000000000000; // 0.01eth

  // The minimum percentage difference between the last bid amount and the current bid
  uint8 public defaultMinBidIncrementPercentage = 2; // 2%

  bool public paused = true;

  address private _treasuryAddress = 0x452Ccc6d4a818D461e20837B417227aB70C72B56;

  Counters.Counter private _auctionIdTracker;
  mapping(uint256 => ISlothAuctionHouse.Auction) public auctions;
  uint256[] private _currentAuctions;

  /**
    * @notice Require that the specified auction exists
    */
  modifier auctionExists(uint256 auctionId) {
    require(_exists(auctionId), "Auction doesn't exist");
    _;
  }

  function _exists(uint256 auctionId) internal view returns(bool) {
    return auctions[auctionId].tokenContract != address(0);
  }


  function settleAuction(uint256 _auctionId) external onlyOwner {
    _settleAuction(_auctionId);
  }

  function pause() external onlyOwner {
      _pause();
  }

  function unpause() external onlyOwner {
      _unpause();
  }

  function setTimeBuffer(uint256 _auctionId, uint256 _timeBuffer) external onlyOwner {
      auctions[_auctionId].timeBuffer = _timeBuffer;
  }

  function setReservePrice(uint256 _auctionId, uint256 _reservePrice) external onlyOwner {
    auctions[_auctionId].reservePrice = _reservePrice;
  }

  function setMinBidIncrementPercentage(uint256 _auctionId, uint8 _minBidIncrementPercentage) external onlyOwner {
    auctions[_auctionId].minBidIncrementPercentage = _minBidIncrementPercentage;
  }

  function setEndTimeOffset(uint256 _endTimeOffset) external onlyOwner {
    endTimeOffset = _endTimeOffset;
  }

  function setTreasuryAddress(address treasuryAddress) external onlyOwner {
    _treasuryAddress = treasuryAddress;
  }

  function createAuction(uint256 tokenId, address tokenContract, uint256 startTime, uint256 endTime) external onlyOwner nonReentrant returns (uint256) {
    require(startTime < endTime, "start must be before end");
    require(startTime > block.timestamp, "start must be in the future");
    require(msg.sender == IERC721(tokenContract).ownerOf(tokenId), "sender must be token owner");
    require(
      IERC721(tokenContract).getApproved(tokenId) == address(this) || IERC721(tokenContract).isApprovedForAll(msg.sender, address(this)),
      "tokenContract is not approved"
    );

    uint256 auctionId = _auctionIdTracker.current();

    auctions[auctionId] = ISlothAuctionHouse.Auction({
      tokenId: tokenId,
      tokenOwner: msg.sender,
      tokenContract: tokenContract,
      amount: 0,
      timeBuffer: defaultTimeBuffer,
      reservePrice: defaultReservePrice,
      minBidIncrementPercentage: defaultMinBidIncrementPercentage,
      bidder: payable(0),
      startTime: startTime,
      endTime: endTime,
      settled: false
    });
    _currentAuctions.push(auctionId);
    _auctionIdTracker.increment();
    emit AuctionCreated(auctionId, tokenId, msg.sender, tokenContract, startTime, endTime);
    return auctionId;
  }

  function currentAuctions() external view returns (uint256[] memory) {
    uint[] memory arr = new uint256[](_currentAuctions.length);
    arr = _currentAuctions;
    return arr;
  }

  function createBid(uint256 _auctionId, uint256 amount) external payable auctionExists(_auctionId) nonReentrant {
    require(!auctions[_auctionId].settled, "Auction has already been settled");
    require(block.timestamp < auctions[_auctionId].endTime, "Auction expired");
    require(block.timestamp >= auctions[_auctionId].startTime, "not started");
    require(amount >= auctions[_auctionId].reservePrice, "Must send at least reservePrice");
    require(
      msg.value >= auctions[_auctionId].amount + ((auctions[_auctionId].amount * auctions[_auctionId].minBidIncrementPercentage) / 100),
      'Must send more than last bid by minBidIncrementPercentage amount'
    );

    address payable lastBidder = auctions[_auctionId].bidder;
    if (lastBidder != address(0)) {
      _safeTransferETHWithFallback(lastBidder, auctions[_auctionId].amount);
    }

    auctions[_auctionId].amount = msg.value;
    auctions[_auctionId].bidder = payable(msg.sender);
    bool extended = auctions[_auctionId].endTime - block.timestamp < auctions[_auctionId].timeBuffer;
    if (extended) {
      auctions[_auctionId].endTime = block.timestamp + auctions[_auctionId].timeBuffer;
    }
    emit AuctionBid(_auctionId, auctions[_auctionId].tokenId, auctions[_auctionId].tokenContract, msg.sender, msg.value, extended);

    if (extended) {
      emit AuctionExtended(_auctionId, auctions[_auctionId].endTime);
    }
  }

  function _settleAuction(uint256 _auctionId) internal onlyOwner auctionExists(_auctionId) nonReentrant {
    ISlothAuctionHouse.Auction memory auction = auctions[_auctionId];
    require(block.timestamp > auction.endTime, "Auction hasn't completed yet");
    require(!auction.settled, "Auction has already been settled");
    auctions[_auctionId].settled = true;

    if (auction.bidder != payable(0)) {
      IERC721(auction.tokenContract).safeTransferFrom(auction.tokenOwner, auction.bidder, auction.tokenId);
    }

    if (auction.amount > 0 && address(this).balance >= auction.amount) {
      _safeTransferETHWithFallback(_treasuryAddress, auction.amount);
    }

    emit AuctionSettled(_auctionId, auction.bidder, auction.amount);
  }

  function cancelAuction(uint256 auctionId) external onlyOwner nonReentrant auctionExists(auctionId) {
    if (auctions[auctionId].bidder != payable(0) && !auctions[auctionId].settled) {
      revert("already bidded");
    }
    _cancelAuction(auctionId);
  }

  function _cancelAuction(uint256 auctionId) internal {
    emit AuctionCanceled(auctionId, auctions[auctionId].tokenId, auctions[auctionId].tokenContract);
    delete auctions[auctionId];
  }

  /**
    * @notice Transfer ETH. If the ETH transfer fails,send to Owner.
    */
  function _safeTransferETHWithFallback(address to, uint256 amount) internal {
    if (!_safeTransferETH(to, amount)) {
      require(_safeTransferETH(owner(), amount), "receiver rejected ETH transfer");
    }
  }

  /**
    * @notice Transfer ETH and return the success status.
    * @dev This function only forwards 30,000 gas to the callee.
    */
  function _safeTransferETH(address to, uint256 value) internal returns (bool) {
    (bool success, ) = to.call{ value: value, gas: 30_000 }(new bytes(0));
    return success;
  }

  function _pause() internal {
      paused = true;
  }

  function _unpause() internal {
      paused = false;
  }

  function owner() public view override returns (address) {
    return super.owner();
  }

  function withdraw() external onlyOwner {
    (bool sent,) = _treasuryAddress.call{value: address(this).balance}("");
    require(sent, "Failed to send Ether");
  }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

/**
 * @title Interface for Auction Houses
 */
interface ISlothAuctionHouse {
    struct Auction {
        // ID for the ERC721 token
        uint256 tokenId;
        address tokenOwner;
        // Address for the ERC721 contract
        address tokenContract;
        // The current highest bid amount
        uint256 amount;
        // The length of time to run the auction for, after the first bid was made
        uint256 timeBuffer;
        // The minimum price of the first bid
        uint256 reservePrice;
        uint8 minBidIncrementPercentage;
        // The address of the current highest bid
        address payable bidder;
        // The time that the auction started
        uint256 startTime;
        // The time that the auction is scheduled to end
        uint256 endTime;
        // Whether or not the auction has been settled
        bool settled;
    }

    event AuctionCreated(
        uint256 indexed auctionId,
        uint256 tokenId,
        address tokenOwner,
        address indexed tokenContract,
        uint256 startTime,
        uint256 endTime
    );

    event AuctionBid(
        uint256 indexed auctionId,
        uint256 indexed tokenId,
        address indexed tokenContract,
        address sender,
        uint256 value,
        bool extended
    );

    event AuctionExtended(
        uint256 indexed auctionId,
        uint256 endTime
    );

    event AuctionCanceled(
        uint256 indexed auctionId,
        uint256 indexed tokenId,
        address indexed tokenContract
    );

    event AuctionSettled(
      uint256 indexed auctionId,
      address bidder,
      uint256 amount
    );

    function createAuction(
        uint256 tokenId,
        address tokenContract,
        uint256 startTime,
        uint256 endTime
    ) external returns (uint256);

    function createBid(uint256 auctionId, uint256 amount) external payable;

    function cancelAuction(uint256 auctionId) external;
}