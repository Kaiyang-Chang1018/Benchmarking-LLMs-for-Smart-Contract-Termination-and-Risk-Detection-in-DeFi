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
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

// OpenZeppelin dependencies
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Vesting
 */
contract Vesting is Ownable, ReentrancyGuard {
    struct VestingPlan {
        address beneficiary;
        uint256 cliff;
        uint256 start;
        uint256 launch;
        uint256 duration;
        uint256 interval;
        bool canRevoke;
        uint256 totalAmount;
        uint256 launchPercent;
        uint256 released;
        bool revoked;
    }

    IERC20 public immutable token;

    bytes32[] private planIds;
    mapping(bytes32 => VestingPlan) private plans;
    uint256 private totalAmountVested;
    mapping(address => uint256) private vestingCount;

    modifier activePlan(bytes32 planId) {
        require(!plans[planId].revoked, "Plan is revoked");
        _;
    }

    constructor(address token_) Ownable(msg.sender) {
        require(token_ != address(0x0), "Invalid token address");
        token = IERC20(token_);
    }

    receive() external payable {}

    fallback() external payable {}

    function addPlan(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _launch,
        uint256 _duration,
        uint256 _interval,
        uint256 _launchPercent,
        bool _canRevoke,
        uint256 _amount
    ) external onlyOwner {
        require(getAvailableAmount() >= _amount, "Insufficient tokens");
        require(_duration > 0, "Duration must be > 0");
        require(_launch > 0, "Launch must be > 0");
        require(_amount > 0, "Amount must be > 0");
        require(_interval >= 1, "Interval must be >= 1");
        require(_duration >= _cliff, "Duration must be >= cliff");

        bytes32 planId = getNextPlanId(_beneficiary);
        uint256 cliffTime = _start + _cliff;
        uint256 launchTime = _start + _launch;

        plans[planId] = VestingPlan(
            _beneficiary,
            cliffTime,
            _start,
            launchTime,
            _duration,
            _interval,
            _canRevoke,
            _amount,
            _launchPercent,
            0,
            false
        );

        totalAmountVested += _amount;
        planIds.push(planId);
        vestingCount[_beneficiary]++;
    }

    function cancelPlan(
        bytes32 planId
    ) external onlyOwner activePlan(planId) {
        VestingPlan storage plan = plans[planId];
        require(plan.canRevoke, "Plan cannot be revoked");

        uint256 releasableAmount = calculateReleasable(plan);
        if (releasableAmount > 0) {
            releaseTokens(planId, releasableAmount);
        }

        uint256 remainingAmount = plan.totalAmount - plan.released;
        totalAmountVested -= remainingAmount;
        plan.revoked = true;
    }

    function withdrawFunds(uint256 amount) external nonReentrant onlyOwner {
        require(getAvailableAmount() >= amount, "Insufficient funds");
        token.transfer(msg.sender, amount);
    }

    function releaseTokens(
        bytes32 planId,
        uint256 amount
    ) public nonReentrant activePlan(planId) {
        VestingPlan storage plan = plans[planId];
        bool isAuthorized = (msg.sender == plan.beneficiary || msg.sender == owner());
        
        require(isAuthorized, "Only beneficiary or owner can release tokens");
        uint256 releasableAmount = calculateReleasable(plan);
        require(releasableAmount >= amount, "Not enough vested tokens");

        plan.released += amount;
        totalAmountVested -= amount;
        token.transfer(payable(plan.beneficiary), amount);
    }

    function getPlanCount(address _beneficiary) external view returns (uint256) {
        return vestingCount[_beneficiary];
    }

    function getPlanId(uint256 index) external view returns (bytes32) {
        require(index < getPlanTotal(), "Index out of bounds");
        return planIds[index];
    }

    function getPlanByAddressAndIndex(
        address holder,
        uint256 index
    ) external view returns (VestingPlan memory) {
        return getPlan(computePlanId(holder, index));
    }

    function getTotalVested() external view returns (uint256) {
        return totalAmountVested;
    }

    function getPlanTotal() public view returns (uint256) {
        return planIds.length;
    }

    function getReleasableAmount(
        bytes32 planId
    )
        external
        view
        activePlan(planId)
        returns (uint256)
    {
        VestingPlan storage plan = plans[planId];
        return calculateReleasable(plan);
    }

    function getPlan(
        bytes32 planId
    ) public view returns (VestingPlan memory) {
        return plans[planId];
    }

    function getAvailableAmount() public view returns (uint256) {
        return token.balanceOf(address(this)) - totalAmountVested;
    }

    function getNextPlanId(address holder) public view returns (bytes32) {
        return computePlanId(holder, vestingCount[holder]);
    }

    function getLastPlan(address holder) external view returns (VestingPlan memory) {
        return plans[computePlanId(holder, vestingCount[holder] - 1)];
    }

    function computePlanId(
        address holder,
        uint256 index
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    function calculateReleasable(
        VestingPlan memory plan
    ) internal view returns (uint256) {
        uint256 currentTime = block.timestamp;

        if (currentTime < plan.cliff || currentTime < plan.launch || plan.revoked) {
            return 0;
        } else if (currentTime >= plan.start + plan.duration) {
            return plan.totalAmount - plan.released;
        } else {
            uint256 launchAmount = (plan.totalAmount * plan.launchPercent) / 100;
            uint256 remainingAmount = plan.totalAmount - launchAmount;
            uint256 elapsedTime = currentTime - plan.start;
            uint256 elapsedPeriods = elapsedTime / plan.interval;
            uint256 vestedTime = elapsedPeriods * plan.interval;

            uint256 vestedAmount = (remainingAmount * vestedTime) / plan.duration;
            return vestedAmount + launchAmount - plan.released;
        }
    }
}