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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
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
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.19;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import { IERC20Facet } from "./diamond/interfaces/IERC20Facet.sol";

/// @title Degen ATM
/// @author Daniel <danieldegendev@gmail.com>
/// @notice Funds collecting and vesting smart contract
/// @custom:version 1.0.0
contract DegenATM is Ownable, ReentrancyGuard {
    using Address for address payable;

    uint256 public constant LOCK_PERIOD = 31_536_000; // 365 days
    uint256 public constant DENOMINATOR = 10_000_000;
    uint256 public constant TOTAL_REWARD_BPS = 2_400; // 24%
    uint256 public constant REWARD_PENALTY_BPS = 7_000; // 70%

    bool public claiming;
    bool public collecting;
    uint256 public totalDeposits;
    uint256 public startTimestamp;
    uint256 public allocationLimit = 3 * 10 ** 18;
    uint256 public totalLockedTokens;
    uint256 public tokensPerOneNative;
    uint256 public totalClaimedTokens;
    address public token;
    mapping(address => bool) public locked;
    mapping(address => bool) public claimed;
    mapping(address => bool) public whitelist;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public lockedAmount;
    mapping(address => uint256) public claimedAmount;

    event Deposit(address depositer, uint256 amount);
    event Claimed(address claimer, uint256 amount);
    event LockJoin(address locker, uint256 amount);
    event LockLeave(address locker, uint256 amount, uint256 reward, uint256 penalty);
    event CollectingEnabled();
    event CollectingDisabled();
    event ClaimingEnabled();
    event ClaimingDisabled();
    event LockingEnabled();
    event LockingDisabled();
    event UpdatedAllocationRate(uint256 rate);
    event UpdatedAllocationLimit(uint256 limit);
    event UpdatedToken(address token);
    event AddToWhitelist(address candidate);
    event RemoveFromWhitelist(address candidate);
    event StartLockPeriod();

    modifier qualifyCheck() {
        _checkQualification();
        _;
    }

    /// Deposit native token
    function deposit() external payable {
        _deposit(msg.value, _msgSender());
    }

    /// Claiming the tokens
    /// @notice claiming is only possible when the claiming period has started
    /// @dev it also makes some qualify checks whether sender is allowed to execute, otherwise it reverts
    /// @dev possible to execute when claming is started
    function claimTokens() external nonReentrant qualifyCheck {
        if (!claiming) revert("not started");
        uint256 _amount = _calcClaimAmount(_msgSender());
        if (!IERC20(token).transfer(_msgSender(), _amount)) revert("payout failed");
        claimed[_msgSender()] = true;
        claimedAmount[_msgSender()] = _amount;
        totalClaimedTokens += _amount;
        emit Claimed(_msgSender(), _amount);
    }

    /// Locks the tokens
    /// @notice the sender will enter a lock state with his allocated amount of tokens
    /// @dev it also makes some qualify checks whether sender is allowed to execute, otherwise it reverts
    /// @dev possible to execute when claming is started
    function lockJoin() external qualifyCheck {
        if (!claiming) revert("not started");
        if (startTimestamp > 0) revert("lock not possible anymore");
        uint256 _amount = _calcClaimAmount(_msgSender());
        locked[_msgSender()] = true;
        lockedAmount[_msgSender()] = _amount;
        totalLockedTokens += _amount;
        emit LockJoin(_msgSender(), _amount);
    }

    /// Leaves the lock of the tokens
    /// @notice The sender will leave the locked state if he has joined it.
    /// @notice After leaving, he will auto claim the tokens and not be able to join the lock anymore.
    /// @notice The sender can leave at any time. Before the lock period, he has not gained any rewards
    /// @notice and claims only his initial allocated amount of tokens. If the lock period has started
    /// @notice and not ended yet, the sender will receive his initial allocated tokens with 30% of the
    /// @notice rewards, because of the desined penalty when leaving the locked state before end of period.
    /// @notice After the lock period has ended, the sender will receive the allocated amount of tokens
    /// @notice and the full amount of rewards.
    function lockLeave() external nonReentrant {
        if (!locked[_msgSender()]) revert("not locked");
        uint256 _penalty = 0;
        uint256 _reward = 0;
        uint256 _amount = lockedAmount[_msgSender()];
        locked[_msgSender()] = false;
        lockedAmount[_msgSender()] = 0;
        totalLockedTokens -= _amount;

        if (startTimestamp > 0) {
            (, _penalty, _reward) = _calcRewards(_amount, startTimestamp);
            _amount += _reward;
        } else emit Claimed(_msgSender(), _amount);

        if (!IERC20(token).transfer(_msgSender(), _amount)) revert("payout failed");
        claimed[_msgSender()] = true;
        claimedAmount[_msgSender()] = _amount;
        totalClaimedTokens += _amount;

        emit LockLeave(_msgSender(), _amount, _reward, _penalty);
    }

    /// viewables

    struct StatsForQualifier {
        bool isWhitelisted;
        bool hasClaimed;
        bool hasLocked;
        uint256 tokenBalance;
        uint256 lockedAmount;
        uint256 claimedAmount;
        uint256 totalDeposited;
        uint256 currentRewardAmount;
        uint256 currentPenaltyAmount;
        uint256 currentRewardAmountNet;
        uint256 estimatedTotalRewardAmount;
        uint256 estimatedTotalClaimAmount;
    }

    /// Returns atm stats for a given qualifier
    /// @param _qualifier address of the account
    /// @return _stats statistics for a qualifier
    /// @dev `isWhitelisted` flag if the qualifier is whitelisted or not
    /// @dev `hasClaimed` flag if the qualifier has claimed his tokens
    /// @dev `hasLocked` flag if the qualifier has locked his tokens
    /// @dev `tokenBalance` qualifiers balance of the token
    /// @dev `lockedAmount` amount of locked tokens
    /// @dev `claimedAmount` amount of claimed tokens
    /// @dev `totalDeposited` amount of deposited native
    /// @dev `currentRewardAmount` returns the current reward amount (only if lock period has started, else 0)
    /// @dev `currentPenaltyAmount` returns the current penalty amount if the qualifier leaves the lock (only if lock period has started, else 0)
    /// @dev `currentRewardAmountNet` returns the current rewart amount excl. penalty amount (only if lock period has started, else 0)
    /// @dev `estimatedTotalRewardAmount` potential amount of rewards qualifier receives after whole lock period
    /// @dev `estimatedTotalClaimAmount` potential total amount (accumulated + rewards) which the qualifier will receive after whole lock period
    function getStatsForQualifier(address _qualifier) external view returns (StatsForQualifier memory _stats) {
        uint256 _amount = locked[_qualifier] ? lockedAmount[_qualifier] : _calcClaimAmount(_qualifier);
        (uint256 _currentRewardAmount, uint256 _currentPenaltyAmount, uint256 _currentRewardAmountNet) = _calcRewards(
            lockedAmount[_qualifier],
            startTimestamp > 0 ? startTimestamp : block.timestamp
        );
        _stats = StatsForQualifier(
            whitelist[_qualifier],
            claimed[_qualifier],
            locked[_qualifier],
            token != address(0) ? IERC20(token).balanceOf(_qualifier) : 0,
            lockedAmount[_qualifier],
            claimedAmount[_qualifier],
            deposits[_qualifier],
            _currentRewardAmount,
            _currentPenaltyAmount,
            _currentRewardAmountNet,
            (_amount * TOTAL_REWARD_BPS) / 10_000,
            _amount + (_amount * TOTAL_REWARD_BPS) / 10_000
        );
    }

    struct Stats {
        bool collecting;
        bool claiming;
        bool lockPeriodActive;
        address token;
        uint256 tokenBalance;
        uint256 allocationLimit;
        uint256 tokensPerOneNative;
        uint256 totalDeposits;
        uint256 totalLockedTokens;
        uint256 totalClaimedTokens;
        uint256 estimatedTotalLockedTokensRewards;
        uint256 estimatedTotalLockedTokensPayouts;
        uint256 estimatedTotalTokensPayout;
        uint256 lockPeriodStarts;
        uint256 lockPeriodEnds;
        uint256 lockPeriodInSeconds;
        uint256 rewardPenaltyBps;
        uint256 totalRewardBps;
    }

    /// Returns general atm stats
    /// @return _stats statistics for a qualifier
    /// @dev `collecting` flag if the native token collection has started or not
    /// @dev `claiming` flag if the claiming has started or not (will enable claiming and locking functionality)
    /// @dev `lockPeriodActive` flag is the lock period has started
    /// @dev `token` address of the token
    /// @dev `tokenBalance` contract balance of the token
    /// @dev `allocationLimit` defined alloctaion limit
    /// @dev `tokensPerOneNative` defined tokens per one native
    /// @dev `totalDeposits` total amount of native deposits
    /// @dev `totalLockedTokens` total amount of locked tokens
    /// @dev `totalClaimedTokens` total amount of claimed tokens
    /// @dev `estimatedTotalLockedTokensRewards` estimated amount of total rewards paid for current locked tokens
    /// @dev `estimatedTotalLockedTokensPayouts` estimated amount of tokens incl. rewards which are getting paid out
    /// @dev `estimatedTotalTokensPayout` estimated amount of ALL possible paid out tokens (claimed + locked + rewards)
    /// @dev `lockPeriodStarts` the timestamp when the lock period starts
    /// @dev `lockPeriodEnds` the timestamp when the lock period ends
    /// @dev `lockPeriodInSeconds` lock period in seconds which result in 365d or 1y
    /// @dev `rewardPenaltyBps` % loyalty penalty in basis points
    /// @dev `totalRewardBps` % reward in basis points
    function getStats() external view returns (Stats memory _stats) {
        _stats = Stats(
            collecting,
            claiming,
            startTimestamp > 0,
            token,
            token != address(0) ? IERC20(token).balanceOf(address(this)) : 0,
            allocationLimit,
            tokensPerOneNative,
            totalDeposits,
            totalLockedTokens,
            totalClaimedTokens,
            (totalLockedTokens * TOTAL_REWARD_BPS) / 10_000,
            totalLockedTokens + ((totalLockedTokens * TOTAL_REWARD_BPS) / 10_000),
            ((totalDeposits * tokensPerOneNative) / 10 ** 18) + ((totalLockedTokens * TOTAL_REWARD_BPS) / 10_000),
            startTimestamp,
            startTimestamp > 0 ? startTimestamp + LOCK_PERIOD : 0,
            LOCK_PERIOD,
            REWARD_PENALTY_BPS,
            TOTAL_REWARD_BPS
        );
    }

    /// admin

    /// Starts the lock period
    function startLockPeriod() external onlyOwner {
        if (!claiming) revert("not started");
        if (startTimestamp > 0) revert("lock period already started");
        startTimestamp = block.timestamp;
        emit StartLockPeriod();
    }

    /// Recovers the native funds and sends it to the owner
    function recoverNative() external onlyOwner {
        uint256 _balance = address(this).balance;
        if (_balance > 0) payable(owner()).sendValue(_balance);
    }

    /// Recovers the tokens and sends it to the owner
    function recoverTokens(address _asset) external onlyOwner {
        uint256 _balance = IERC20(_asset).balanceOf(address(this));
        if (_balance > 0) IERC20(_asset).transfer(owner(), _balance);
    }

    /// Sets the state of the claiming
    /// @param _enable true enables, false disables
    /// @dev when enabling, automaticall disabled collectiong flag and vice versa
    function enableClaiming(bool _enable) external onlyOwner {
        if (_enable && tokensPerOneNative == 0) revert("no rate set");
        claiming = _enable;
        enableCollecting(!_enable);
        if (_enable) emit ClaimingEnabled();
        else emit ClaimingDisabled();
    }

    /// Sets the state of the collecting
    /// @param _enable true enables, false disables
    function enableCollecting(bool _enable) public onlyOwner {
        collecting = _enable;
        if (_enable) emit CollectingEnabled();
        else emit CollectingDisabled();
    }

    /// Sets the allocation rate
    /// @param _rate amount of tokens
    /// @notice this number is used to calculate the accumulated token
    function setAllocationRate(uint256 _rate) external onlyOwner {
        tokensPerOneNative = _rate;
        emit UpdatedAllocationRate(_rate);
    }

    /// Sets the deposit limit for accounts
    /// @param _limit amount of native token a participant can deposit
    function setAllocationLimit(uint256 _limit) external onlyOwner {
        allocationLimit = _limit;
        emit UpdatedAllocationLimit(_limit);
    }

    /// Sets the token address which to pay out
    /// @param _token address of the token
    function setToken(address _token) external onlyOwner {
        if (claiming) revert("claiming already started");
        token = _token;
        emit UpdatedToken(_token);
    }

    /// Adds an account to the whitelist
    /// @param _account address of the participant
    function addToWhitelist(address _account) public onlyOwner {
        whitelist[_account] = true;
        emit AddToWhitelist(_account);
    }

    /// Adds multiple accounts to the whitelist
    /// @param _accounts array of addresses of participants
    function addToWhitelistInBulk(address[] calldata _accounts) external onlyOwner {
        for (uint256 i = 0; i < _accounts.length; i++) addToWhitelist(_accounts[i]);
    }

    /// Removes the address from the whitelist
    /// @param _account address of the participant
    /// @notice When the address is being removed and has already deposited, this amount will be sent back to the account
    function removeFromWhitelist(address payable _account) external onlyOwner {
        uint256 _returnAmount = deposits[_account];
        if (_returnAmount > 0) {
            delete deposits[_account];
            totalDeposits -= _returnAmount;
            _account.sendValue(_returnAmount);
        }
        delete whitelist[_account];
        emit RemoveFromWhitelist(_account);
    }

    /// internals

    function _checkQualification() internal view {
        if (!whitelist[_msgSender()]) revert("not whitelisted");
        if (deposits[_msgSender()] == 0) revert("not deposited");
        if (claimed[_msgSender()]) revert("already claimed");
        if (locked[_msgSender()]) revert("already locked");
    }

    function _deposit(uint256 _amount, address _sender) internal nonReentrant {
        if (!collecting) revert("not started");
        if (!whitelist[_sender]) revert("not whitelisted");
        uint256 _depositAmount = _amount;
        uint256 _actual = deposits[_sender] + _depositAmount;
        if (_actual > allocationLimit) {
            uint256 _sendBack = _actual - allocationLimit;
            payable(_sender).sendValue(_sendBack);
            _depositAmount = allocationLimit - deposits[_sender];
        }
        deposits[_sender] += _depositAmount;
        totalDeposits += _depositAmount;
        emit Deposit(_sender, _amount);
    }

    function _calcClaimAmount(address _depositer) internal view returns (uint256 _amount) {
        return (tokensPerOneNative * deposits[_depositer]) / 10 ** 18;
    }

    // function _calcClaimAmountTotal() internal view returns (uint256 _amount) {
    //     return (tokensPerOneNative * totalDeposits) / 10 ** 18;
    // }

    function _calcRewards(
        uint256 _lockedAmount,
        uint256 _startTimestamp
    ) internal view returns (uint256 _amount, uint256 _penalty, uint256 _amountNet) {
        _amount = (_lockedAmount * TOTAL_REWARD_BPS) / 10_000;
        _amountNet = _amount;
        if (block.timestamp > _startTimestamp && block.timestamp < _startTimestamp + LOCK_PERIOD) {
            _amount = (((_amount * DENOMINATOR) / LOCK_PERIOD) * (block.timestamp - _startTimestamp)) / DENOMINATOR;
            _penalty = (_amount * REWARD_PENALTY_BPS) / 10_000;
        } else if (block.timestamp <= _startTimestamp) {
            _amount = 0;
            _amountNet = 0;
        }

        _amountNet = _amount - _penalty;
    }

    /// receiver
    receive() external payable {
        _deposit(msg.value, _msgSender());
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.19;

/// @title ERC20 Facet Interface
/// @author Daniel <danieldegendev@gmail.com>
interface IERC20Facet {
    /// Minting an amount of tokens for a designated receiver
    /// @param _to receiver address of the token
    /// @param _amount receiving amount
    /// @return _success Returns true is operation succeeds
    /// @notice It allows to mint specified amount until the bridge supply cap is reached
    function mint(address _to, uint256 _amount) external returns (bool _success);

    /// Burning an amount of tokens from sender
    /// @param _amount burnable amount
    /// @return _success Returns true is operation succeeds
    /// @notice It allows to burn a bridge supply until its supply is 0, even if the cap is already set to 0
    function burn(uint256 _amount) external returns (bool _success);

    /// Burning an amount of tokens from a designated holder
    /// @param _from holder address to burn the tokens from
    /// @param _amount burnable amount
    /// @return _success Returns true is operation succeeds
    /// @notice It allows to burn a bridge supply until its supply is 0, even if the cap is already set to 0
    function burn(address _from, uint256 _amount) external returns (bool _success);

    /// Burning an amount of tokens from a designated holder
    /// @param _from holder address to burn the tokens from
    /// @param _amount burnable amount
    /// @return _success Returns true is operation succeeds
    /// @notice It allows to burn a bridge supply until its supply is 0, even if the cap is already set to 0
    function burnFrom(address _from, uint256 _amount) external returns (bool _success);

    /// @notice This enables the transfers of this tokens
    function enable() external;

    /// @notice This disables the transfers of this tokens
    function disable() external;

    /// Exclude an account from being charged on fees
    /// @param _account address to exclude
    function excludeAccountFromTax(address _account) external;

    /// Includes an account againt to pay fees
    /// @param _account address to include
    function includeAccountForTax(address _account) external;

    /// Adds a liquidity pool address
    /// @param _lp address of the liquidity pool of the token
    function addLP(address _lp) external;

    /// Removes a liquidity pool address
    /// @param _lp address of the liquidity pool of the token
    function removeLP(address _lp) external;

    /// Returns the existence of an lp address
    /// @return _has has lp or not
    function hasLP(address _lp) external view returns (bool _has);

    /// Adds a buy fee based on a fee id
    /// @param _id fee id
    function addBuyFee(bytes32 _id) external;

    /// Adds a sell fee based on a fee id
    /// @param _id fee id
    function addSellFee(bytes32 _id) external;
}