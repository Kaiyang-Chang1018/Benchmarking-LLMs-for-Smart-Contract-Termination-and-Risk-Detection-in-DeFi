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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
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
// Creator: twitter.com/0xNox_ETH

//               .;::::::::::::::::::::::::::::::;.
//               ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:
//               ;XWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX;
//               ;KNNNWMMWMMMMMMWWNNNNNNNNNWMMMMMN:
//                .',oXMMMMMMMNk:''''''''';OMMMMMN:
//                 ,xNMMMMMMNk;            l00000k,
//               .lNMMMMMMNk;               .....
//                'dXMMWNO;                .......
//                  'd0k;.                .dXXXXX0;
//               .,;;:lc;;;;;;;;;;;;;;;;;;c0MMMMMN:
//               ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX:
//               ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:
//               ;XWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWX:
//               .,;,;;;;;;;;;;;;;;;;;;;;;;;,;;,;,.
//               'dkxkkxxkkkkkkkkkkkkkkkkkkxxxkxkd'
//               ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:
//               ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:
//               'xkkkOOkkkkkkkkkkkkkkkkkkkkkkkkkx'
//                          .,,,,,,,,,,,,,,,,,,,,,.
//                        .lKNWWWWWWWWWWWWWWWWWWWX;
//                      .lKWMMMMMMMMMMMMMMMMMMMMMX;
//                    .lKWMMMMMMMMMMMMMMMMMMMMMMMN:
//                  .lKWMMMMMWKo:::::::::::::::::;.
//                .lKWMMMMMWKl.
//               .lNMMMMMWKl.
//                 ;kNMWKl.
//                   ;dl.
//
//               We vow to Protect
//               Against the powers of Darkness
//               To rain down Justice
//               Against all who seek to cause Harm
//               To heed the call of those in Need
//               To offer up our Arms
//               In body and name we give our Code
//
//               FOR THE BLOCKCHAIN ⚔️

pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

struct User {
    uint ethDeposit;
    uint usdDeposit;
}

interface ForcePresaleEvents {
    event Deposit(
        address indexed user,
        address indexed referrer,
        string token,
        uint amount,
        uint timestamp
    );
}

contract ForcePresale is Ownable, ForcePresaleEvents, ReentrancyGuard {
    uint public totalEthDeposited;
    uint public totalUsdDeposited;
    mapping(address => User) public users;

    bool public presaleActive;

    address public usdc;
    address public usdt;
    address public force;

    uint public constant FORCE_USDC_PRICE_x_1e7 = 3013; // 1 FORCE = 0.0003013 USDC
    uint public constant REFERRAL_BONUS_RATE = 5; // 5% bonus for referee
    uint public constant REFERRER_PAYBACK_RATE = 10; // 10% payback for referrer
    uint public constant FORCE_DEPOSIT_BONUS_RATE = 20; // 20% bonus for FORCE deposit

    constructor(address _usdc, address _usdt, address _force) Ownable(msg.sender) {
        usdc = _usdc;
        usdt = _usdt;
        force = _force;
    }

    function togglePresale(bool _presaleActive) external onlyOwner {
        presaleActive = _presaleActive;
    }

    modifier presaleIsActive() {
        require(presaleActive, "ForcePresale: Presale is not active");
        _;
    }

    function depositEth(address referrer) external payable presaleIsActive nonReentrant {
        require(msg.value >= 0.001 ether, "ForcePresale: eth deposit must be at least 0.001");

        totalEthDeposited += msg.value;

        User storage user = users[msg.sender];

        if (referrer != address(0) && referrer != msg.sender) {
            user.ethDeposit += msg.value + (msg.value * REFERRAL_BONUS_RATE) / 100;

            uint referrerPaybackAmount = (msg.value * REFERRER_PAYBACK_RATE) / 100;
            if (referrerPaybackAmount > 0.001 ether) {
                // send referrer payback
                payable(referrer).transfer(referrerPaybackAmount);
            }
        } else {
            user.ethDeposit += msg.value;
        }

        emit Deposit(msg.sender, referrer, "ETH", msg.value, block.timestamp);
    }

    function depositUsd(
        address token,
        uint64 amount,
        address referrer
    ) external presaleIsActive nonReentrant {
        require(token == usdc || token == usdt, "ForcePresale: invalid token");
        require(amount >= 1e6, "ForcePresale: usd deposit must be at least 1");

        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            "ForcePresale: failed to transfer usd"
        );

        totalUsdDeposited += amount;

        User storage user = users[msg.sender];

        if (referrer != address(0) && referrer != msg.sender) {
            user.usdDeposit += amount + (amount * REFERRAL_BONUS_RATE) / 100;

            uint referrerPaybackAmount = (amount * REFERRER_PAYBACK_RATE) / 100;
            if (referrerPaybackAmount > 1) {
                // send referrer payback
                require(
                    IERC20(token).transfer(referrer, referrerPaybackAmount),
                    "ForcePresale: failed to send referrer payback"
                );
            }
        } else {
            user.usdDeposit += amount;
        }

        emit Deposit(msg.sender, referrer, "USD", amount, block.timestamp);
    }

    function depositForce(uint amount) external presaleIsActive nonReentrant {
        require(amount >= 1e18, "ForcePresale: $FORCE deposit must be at least 1");

        require(
            IERC20(force).transferFrom(msg.sender, address(this), amount),
            "ForcePresale: failed to transfer $FORCE"
        );

        // $FORCE is 1e18 decimals and USDC is 1e6 decimals, so we need to divide by 1e12 to get the correct value in USDC
        uint usdcValue = ((amount / 1e12) * FORCE_USDC_PRICE_x_1e7) / 1e7;
        uint bonus = (usdcValue * FORCE_DEPOSIT_BONUS_RATE) / 100;

        User storage user = users[msg.sender];
        user.usdDeposit += usdcValue + bonus;

        emit Deposit(msg.sender, address(0), "USD", usdcValue, block.timestamp);
    }

    function withdrawEth(uint amount) external nonReentrant onlyOwner {
        require(amount <= address(this).balance, "ForcePresale: insufficient balance");
        payable(msg.sender).transfer(amount);
    }

    function withdrawUsd(address token) external nonReentrant onlyOwner {
        uint balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "ForcePresale: insufficient balance");

        require(
            IERC20(token).transfer(msg.sender, balance),
            "ForcePresale: failed to transfer usd"
        );
    }
}