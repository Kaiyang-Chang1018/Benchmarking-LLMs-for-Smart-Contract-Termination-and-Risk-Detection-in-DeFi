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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RankedAuction is Ownable, Pausable, ReentrancyGuard {
    event Start();
    event Bid(address bidder, uint256 bidAmount);
    event TopUpBid(address bidder, uint256 bidAmount);
    event End();

    struct SellerInfo {
        address seller;
        uint256 bp;
    }

    struct BidState {
        address bidder; // Bidder address
        uint256 bidAmount; // Bid price
    }

    uint256 public constant DENOMINATOR = 10000;
    SellerInfo[3] public sellers;
    uint256 public endAt;
    bool public started;
    bool public ended;
    mapping(uint256 => BidState) public winners;
    uint256 public bidCount;

    constructor(SellerInfo[3] memory infos) ReentrancyGuard() {
        require(
            infos[0].bp + infos[1].bp + infos[2].bp == 10000,
            "invalid bps"
        );

        sellers[0] = infos[0];
        sellers[1] = infos[1];
        sellers[2] = infos[2];
    }

    function start(uint256 duration) external onlyOwner {
        require(!started, "started");

        started = true;
        endAt = block.timestamp + duration;

        emit Start();
    }

    function bid() external payable nonReentrant whenNotPaused {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > 0, "none bid amount");

        if (bidCount < 10) {
            uint256 index = bidCount;
            for (; index > 0; index--) {
                if (msg.value <= winners[index - 1].bidAmount) {
                    break;
                }
                winners[index] = winners[index - 1];
            }
            winners[index].bidder = msg.sender;
            winners[index].bidAmount = msg.value;
            bidCount++;
        } else {
            require(
                msg.value > winners[9].bidAmount,
                "need more fund to be a winner"
            );

            if (block.timestamp + 10 minutes > endAt) {
                endAt = block.timestamp + 10 minutes;
            }

            (bool sent, ) = winners[9].bidder.call{value: winners[9].bidAmount}(
                ""
            );
            if (!sent) {
                // The function call will fail only in case when the winner is a contract and can't recieve eth
                // In this case, the call should not revert.
            }

            uint256 index = 9;
            for (; index > 0; index--) {
                if (msg.value <= winners[index - 1].bidAmount) {
                    break;
                }
                winners[index] = winners[index - 1];
            }
            winners[index].bidder = msg.sender;
            winners[index].bidAmount = msg.value;
        }

        emit Bid(msg.sender, msg.value);
    }

    function topUpBid() external payable nonReentrant whenNotPaused {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > 0, "none bid amount");

        uint256 pos = 0;
        for (; pos < bidCount; pos++) {
            if (winners[pos].bidder == msg.sender) {
                break;
            }
        }

        require(pos < bidCount, "not eligible for top-up-bid");

        if (block.timestamp + 10 minutes > endAt) {
            endAt = block.timestamp + 10 minutes;
        }

        uint256 newBidAmount = winners[pos].bidAmount + msg.value;
        uint256 index = pos;
        for (; index > 0; index--) {
            if (newBidAmount <= winners[index - 1].bidAmount) {
                break;
            }
            winners[index] = winners[index - 1];
        }
        winners[index].bidder = msg.sender;
        winners[index].bidAmount = newBidAmount;

        emit TopUpBid(msg.sender, newBidAmount);
    }

    function end() external nonReentrant whenNotPaused {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");

        ended = true;

        // withdraw funds
        uint256 total = address(this).balance;
        uint256 amount1 = (total * sellers[0].bp) / DENOMINATOR;
        transfer(sellers[0].seller, amount1);
        uint256 amount2 = (total * sellers[1].bp) / DENOMINATOR;
        transfer(sellers[1].seller, amount2);
        transfer(sellers[2].seller, total - amount1 - amount2);

        emit End();
    }

    function transfer(address to, uint256 amount) internal {
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function withdraw() external onlyOwner {
        transfer(msg.sender, address(this).balance);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function getAllWinners() public view returns (BidState[] memory) {
        BidState[] memory winnersLst = new BidState[](bidCount);

        for (uint ix = 0; ix < bidCount; ix++) {
            winnersLst[ix] = winners[ix];
        }
        return (winnersLst);
    }
}