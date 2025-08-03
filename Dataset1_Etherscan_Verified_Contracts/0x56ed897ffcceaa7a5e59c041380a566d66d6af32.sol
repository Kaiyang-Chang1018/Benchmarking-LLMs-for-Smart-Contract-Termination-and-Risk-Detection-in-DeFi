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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

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
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
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
pragma solidity 0.8.25;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./utils/Clonable.sol";
import "./rewards/SDAOSimpleRewardAPI.sol";

/*
 * @title SDAO Locked Staking contract
 * @notice requirements:
 *  1. users lock their tokens for a certain period
 *  2. users can extend their locking period to increase their score
 *  3. users can withdraw after their tokens unlock or withdraw immediately deducting an early unlock fee
 *  4. protocol should be able to query per wallet the score calculated by locked amount times locking period
 *  5. users can claim rewards proportionaly in the ratio of their score in respect to totalScore
 */
contract SDAOLockedStaking is Clonable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 constant public MAX_PERCENTAGE = 10000; // 100.00%
    uint256 constant public MAX_EARLY_UNLOCK_FEE = 5000; // 50.00%
    uint256 constant public MAX_LOCKING_PERIOD = 360 days;
    uint256 constant public MAX_EARLY_UNLOCK_FEE_PER_DAY = 5; // 0.05%

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        uint256 lockDate; // Last date when user locked funds
        uint256 unlockDate; // Unlock date for user funds
        uint256 score; // Aggregation of locked amount times locked days
    }
    // Info of each user that locks tokens.
    mapping(address => UserInfo) public userInfo;

    bool public depositsEnabled; // deposits are enabled
    address public depositToken; // Address of deposit token contract.
    address public rewardToken; // Address of reward token contract.
    address public rewardsAPI;  // Rewards API module
    address public zapperContract; // Zapper contract allowed to deposit on behalf of a user
    uint256 public totalScore; // total score of all users
    uint256 public earlyUnlockFees; // accumulated fees for early withdrawals
    uint256 public earlyUnlockFeePerDay; // Default unlockFeePerDay 0.05%

    event Deposit(address indexed user, uint256 amount, uint256 lockingPeriod);
    event Withdraw(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 claimed);
    event PaidEarlyUnlockFee(address indexed user, uint256 fee, uint256 secondsUntilUnlock);
    event CollectedFees(address admin, uint256 fees);
    event SetDepositsEnabled(address admin, bool depositsEnabled);
    event SetEarlyUnlockFeePerDay(address admin, uint256 earlyUnlockFeePerDay);
    event SetZapperContract(address admin, address zapperContract);
    
    error AlreadyInitialized();
    error MissingToken();
    error MissingAmount();
    error MissingDepositToken();
    error MissingRewardsAPI();
    error MissingZapperContract();
    error DepositsDisabled();
    error DepositTokenRecoveryNotAllowed();
    error SenderIsNotZapper(address sender, address zapper);
    error ExceedsMaxEarlyUnlockFeePerDay(uint256 fee, uint maxFee);
    error ExceedsMaxLockingPeriod(uint256 period, uint256 maxPeriod);
    error WithdrawalRequestExceedsDeposited(uint256 requestedWithdrawal, uint256 currentBalance);
    error RequestedUnlockDateBeforeCurrent(uint256 requestedUnlockDate, uint256 currentUnlockDate);

    /*
     * @dev initialize function to setup cloned instance
     * @notice marked the initialize function as payable, because it costs less gas to execute,
     * since the compiler does not have to add extra checks to ensure that a payment wasn't provided.
     */
    function initialize(address _depositToken, address _rewardsAPI) external payable onlyOwner {
        if (depositToken != address(0)) {
            revert AlreadyInitialized();
        }
        if (_depositToken == address(0)) {
            revert MissingDepositToken();
        }
        if (_rewardsAPI == address(0)) {
            revert MissingRewardsAPI();
        }
        depositToken = _depositToken;
        rewardsAPI = _rewardsAPI;      
        rewardToken = SDAOSimpleRewardAPI(_rewardsAPI).rewardToken();
        earlyUnlockFeePerDay = 5;
    }


    /*
     * @dev Deposit tokens
     */
    function deposit(uint256 _amount, uint256 _lockingPeriod) external nonReentrant {
        uint256 _tokens_deposited = _deposit(_amount, msg.sender, msg.sender, _lockingPeriod);
        emit Deposit(msg.sender, _tokens_deposited, _lockingPeriod);
    }

    /*
     * @dev Deposit tokens from zapper contract on behalf of the user
     */
    function depositFor(address _recipient, uint256 _amount, uint256 _lockingPeriod) external nonReentrant {
        if (msg.sender != zapperContract) {
            revert SenderIsNotZapper(msg.sender, zapperContract);
        }
        uint256 _tokens_deposited = _deposit(_amount, msg.sender, _recipient, _lockingPeriod);
        emit Deposit(msg.sender, _tokens_deposited, _lockingPeriod);
    }

    /*
     * @dev Withdraw tokens
     */
    function withdraw(uint256 _amount) external nonReentrant {
        _withdraw(_amount, msg.sender);
        emit Withdraw(msg.sender, _amount);
    }

    /*
     * @dev Pending rewards
     */
    function pending() external view returns(uint256) {
        return SDAOSimpleRewardAPI(rewardsAPI).claimableForUser(msg.sender);
    }

    /*
     * @dev Pending rewards for user
     */
    function pendingFor(address _user) external view returns(uint256) {
        return SDAOSimpleRewardAPI(rewardsAPI).claimableForUser(_user);
    }

    /*
     * @dev Claim rewards
     */
    function claim() external {
        uint256 _claimed = SDAOSimpleRewardAPI(rewardsAPI).claimForUser(msg.sender);
        emit Claimed(msg.sender, _claimed);
    }

    /*
     * @dev withdraw and claim in one transaction
     */
    function withdrawAndClaim(uint256 _amount) external nonReentrant {
        _withdraw(_amount, msg.sender);
        emit Withdraw(msg.sender, _amount);
        SDAOSimpleRewardAPI(rewardsAPI).claimForUser(msg.sender);
    }
  
    /*
     * @dev enable/disable new deposits
     */
    function setDepositsEnabled(bool _depositsEnabled) external onlyOwner {
        depositsEnabled = _depositsEnabled;
        emit SetDepositsEnabled(msg.sender, _depositsEnabled);
    }

    /**
      * @dev change earlyUnlockFeePerDay
      */
    function setEarlyUnlockFeePerDay(uint256 _earlyUnlockFeePerDay) external onlyOwner {
        if (_earlyUnlockFeePerDay > MAX_EARLY_UNLOCK_FEE_PER_DAY) {
            revert ExceedsMaxEarlyUnlockFeePerDay(_earlyUnlockFeePerDay, MAX_EARLY_UNLOCK_FEE_PER_DAY);
        }
        earlyUnlockFeePerDay = _earlyUnlockFeePerDay;
        emit SetEarlyUnlockFeePerDay(msg.sender, _earlyUnlockFeePerDay);
    }
  
    /*
     * @dev Register zapper contract
     */
    function setZapperContract(address _zapperContract) external onlyOwner {
        if (_zapperContract == address(0)) {
            revert MissingZapperContract();
        }
        zapperContract = _zapperContract;
        emit SetZapperContract(msg.sender, _zapperContract);
    }

    /**
      * @dev recover unsupported tokens
      */
    function recoverUnsupportedTokens(address _token, uint256 amount, address to) external onlyOwner {
        if (_token == address(0)) {
            revert MissingToken();
        }
        if (_token == depositToken) {
            revert DepositTokenRecoveryNotAllowed();
        }
        IERC20(_token).safeTransfer(to, amount);
    }
  
    /**
      * @dev collect accumulated early unlock fees
      */
    function collectFees() external onlyOwner {
        uint256 fees = earlyUnlockFees;
        earlyUnlockFees = 0;
        IERC20(depositToken).safeTransfer(msg.sender, fees);
        emit CollectedFees(msg.sender, fees);
    }

    /*
     * @dev internal deposit function
     */
    function _deposit(uint256 _amount, 
                      address _depositor, 
                      address _recipient, 
                      uint256 _lockingPeriod) internal returns (uint256 tokensDeposited) {
        if (_lockingPeriod > MAX_LOCKING_PERIOD) {
            revert ExceedsMaxLockingPeriod(_lockingPeriod, MAX_LOCKING_PERIOD);
        }
        if (!depositsEnabled) {
            revert DepositsDisabled();
        }
        UserInfo memory user = userInfo[_recipient];
        if (_amount == 0 && user.amount == 0) {
            revert MissingAmount();
        }
        uint256 newEndPeriod = block.timestamp + _lockingPeriod;
        if (newEndPeriod < user.unlockDate) {
            revert RequestedUnlockDateBeforeCurrent(newEndPeriod, user.unlockDate);
        }
        uint256 deltaScore;
        
        if (_amount > 0) {
            IERC20 _depositToken = IERC20(depositToken);
            uint256 _before = _depositToken.balanceOf(address(this));
            _depositToken.safeTransferFrom(_depositor, address(this), _amount);
            tokensDeposited = _depositToken.balanceOf(address(this)) - _before;
        } 

        if (user.amount > 0) {
            // extend unlock date
            uint256 extensionPeriod = newEndPeriod - user.unlockDate;
            deltaScore += user.amount * extensionPeriod;
        }

        // handle new deposit
        deltaScore += tokensDeposited * _lockingPeriod;
      
        totalScore += deltaScore;
        user.score += deltaScore;
        SDAOSimpleRewardAPI(rewardsAPI).changeUserShares(_recipient, user.score);
        user.amount += tokensDeposited;
        user.lockDate = block.timestamp;
        user.unlockDate = newEndPeriod;
        userInfo[_recipient] = user;
    }

    /*
     * @dev internal withdraw function
     */
    function _withdraw(uint256 _amount, address _user) internal {
        UserInfo storage user = userInfo[_user];
        if (user.amount < _amount) {
            revert WithdrawalRequestExceedsDeposited(_amount, user.amount);
        }
        if (_amount == 0) {
            revert MissingAmount();
        }
        uint256 originalUnlockDate = user.unlockDate;
        uint256 deltaScore;
        // when unlock date has passed
        if (originalUnlockDate < block.timestamp) {
            // extend unlock date
            uint256 extensionPeriod = block.timestamp - originalUnlockDate; 
            deltaScore = user.amount * extensionPeriod;
            totalScore += deltaScore;
            user.score += deltaScore;
            user.unlockDate = block.timestamp;
        }
        uint256 withdrawalAmount = _amount;
        // score will be reduced proportional to the amount withdrawn
        deltaScore = user.score * withdrawalAmount / user.amount;
        // apply withdrawal amount
        user.amount -= withdrawalAmount;
        // update scores
        totalScore -= deltaScore;
        user.score -= deltaScore;
        SDAOSimpleRewardAPI(rewardsAPI).changeUserShares(_user, user.score);
        // when not yet completely unlocked, apply early unlock fee
        if (user.unlockDate > block.timestamp) {
            uint256 earlyUnlockFee = withdrawalAmount * (originalUnlockDate - block.timestamp) * earlyUnlockFeePerDay 
                                                      / 1 days                                 / MAX_PERCENTAGE;
            earlyUnlockFees += earlyUnlockFee;
            withdrawalAmount -= earlyUnlockFee;
            emit PaidEarlyUnlockFee(_user, earlyUnlockFee, originalUnlockDate - block.timestamp);
        }
        // when completely withdrawn, reset unlockdate
        if (user.amount == 0) {
            user.unlockDate = block.timestamp;
        }
        IERC20(depositToken).safeTransfer(_user, withdrawalAmount);
    }
  
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Interface for holding and managing emission of rewards for single reward token
// - reward contract can collect accrued reward tokens
interface SDAOSimpleRewardAPI {

    event UpdatedRewardEmission(uint256 amount, uint256 start, uint256 end);
    event ReservedForUser(address user, address token, uint256 rewards);
    event ClaimedByUser(address user, address token, uint256 amount);


    struct UserInfo {
        uint256 shares; // user shares
        uint256 rewardFloor; // reward floor to calculate pending
        uint256 reserved; // reserved for user
    }
    
    struct RewardTokenInfo {
          address rewardToken; // token to be distributed as rewards
          uint256 balance; // total claimed and held for reward contract to collect
          uint256 totalAmount; // total amount to be distributed during emissionPeriod
          uint256 emissionPeriod; // emission period in seconds to distribute these reward tokens
          uint256 startOfEmission; // start time of emissions
          uint256 endOfEmission; // last time when these rewards are emitted
          uint256 lastClaim; // last time when rewards have been claimed
    }

    function depositContract() external view returns (address);
    function rewardToken() external view returns (address);
    function getRewardInfo() external view returns (RewardTokenInfo memory);
    
    function changeUserShares(address _user, uint256 _newShares) external;
    function pendingForUser(address _user) external view returns (uint256 pendingRewards);
    function claimableForUser(address _user) external view returns (uint256 claimable);
    function claimForUser(address _user) external returns (uint256 claimed);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract Clonable {
    address private _owner;

    event Cloned(address newInstance);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    error CallerIsNotOwner();
    error AlreadyInitializedOwner();
    error MissingOwner();
    
    /*
     * @notice marked the constructor function as payable, because it costs less gas to execute,
     * since the compiler does not have to add extra checks to ensure that a payment wasn't provided.
     * A constructor can safely be marked as payable, since only the deployer would be able to pass funds, 
     * and the project itself would not pass any funds.
     */
    constructor() payable {
        _owner = msg.sender;
    }
    
    function owner() external view returns(address) {
        return _owner;
    }

    modifier onlyOwner() {
        if (_owner != msg.sender) {
            revert CallerIsNotOwner();
        }
        _;
    }

    function setOwnerAfterClone(address initialOwner) external {
        if (_owner != address(0)) {
            revert AlreadyInitializedOwner();
        }
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) {
            revert MissingOwner();
        }
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function clone(address newOwner) public returns (address newInstance){
        if (newOwner == address(0)) {
            revert MissingOwner();
        }
        // Copied from https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol
        bytes20 addressBytes = bytes20(address(this));
        assembly {
            // EIP-1167 bytecode
            let clone_code := mload(0x40)
            mstore(clone_code, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone_code, 0x14), addressBytes)
            mstore(add(clone_code, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            newInstance := create(0, clone_code, 0x37)
        }
        emit Cloned(newInstance);
        Clonable(newInstance).setOwnerAfterClone(newOwner);
    }
    
    function getClone() external returns (address) {
        return clone(msg.sender);
    }
}