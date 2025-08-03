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
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
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
pragma solidity 0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {RewardsLogic, RewardsPeriod} from "src/rewardsPeriod.sol";

/// @title PinLink Staking Contract
/// @author PinLink (@jacopod: https://twitter.com/jacolansac)
/// @notice A staking contract to deposit PIN tokens and get rewards in PIN tokens.
contract PinStaking is Ownable2Step {
    using SafeERC20 for IERC20;
    using RewardsLogic for RewardsPeriod;

    // token to stake, and also reward token
    address public immutable stakedToken;

    // scaling factor using for precision, to minimize rounding errors
    uint256 public constant PRECISION = 1e18;

    // Everytime a unstake is made, a lockup period of 7 days must pass before they can be withdrawn
    uint256 public constant UNSTAKE_LOCKUP_PERIOD = 7 days;

    // The maximum number of active pending unstakes per account
    uint8 public constant MAX_PENDING_UNSTAKES = 50;

    // The info about the rewards period that is currently active, how much, the start and end times, etc.
    RewardsPeriod public rewardsData;

    // The accumulated rewards per staked token over time (in wei, scaled up by PRECISION)
    // updated every time a deposit is made
    uint256 public globalRewardsPerStakedToken;

    // The sum of all staked amounts  // units: wei
    uint256 public totalStakedTokens;

    // Staking info per account
    mapping(address => StakeInfo) public stakeInfo;

    // Array of pending unstakes per account. 
    // The unstakes are sorted by releaseTime, so the last in the array is always the latest unstake.
    mapping(address => Unstake[]) public pendingUnstakes;

    struct StakeInfo {
        // accumulated staked amount by the account
        uint256 balance;
        // accumulated rewards by the account pending to be withdrawn. units: wei (absolute, not per token)
        uint256 pendingRewards;
        // the claimed rewards, as "rewards per staked token", following the global rewards per staked token scaled up by PRECISION
        uint256 updatedRewardsPerStakedToken;
        // number of pending unstakes for this account
        uint256 pendingUnstakesCount;
        // sum of historical reward claims by the account. // units: wei
        uint256 totalRewardsClaimed;
    }

    struct Unstake {
        // amount of unstaked tokens in this operation
        uint128 amount;
        // timestamp when it is possible to withdraw
        uint64 releaseTime;
        // If it has been withdrawn or not
        bool withdrawn;
    }

    //////////////////////// EVENTS ////////////////////////

    event Deposited(uint256 amountDeposited, uint256 amountDistributed, uint256 periodInDays);
    event Staked(address indexed account, uint256 amount);
    event Unstaked(address indexed account, uint256 amount);
    event ClaimedRewards(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);
    event GlobalRewardsPerStakedTokenUpdated(uint256 amountReleased, uint256 newGlobalRewardsPerToken);

    //////////////////////// MODIFIERS ////////////////////////

    /// @dev this modifier triggers an update in the globalRewardsPerToken,
    //       by triggering a release of rewards since the last update, following the linear schedule
    modifier updateRewards(address account) {
        // if no rewards have been deposited, there is no rewardsData, and therefore there is no update
        if (rewardsData.isInitialized()) {
            // This updates the released rewards, and the global rewards per token, 
            // taking into account the current totalStaked
            uint256 newGlobalRewardsPerToken = _updateGlobalRewardsPerStakedToken();

            // For the first-time stake, first the pendingRewards is updated to 0 (balance==0), 
            // and then the individual rewardsPerTokenStaked is matched to the global, so that the staker doesn't earn past rewards
            // update earned rewards for the account (in absolute value)
            StakeInfo storage accountInfo = stakeInfo[account];
            // global is always larger than the individual updatedRewardsPerStakedToken, so this should never underflow
            accountInfo.pendingRewards += (
                accountInfo.balance * (newGlobalRewardsPerToken - accountInfo.updatedRewardsPerStakedToken)
            ) / PRECISION;

            // now that pendingRewards has been updated, we match the individual updatedRewardsPerStakedToken to the global one
            accountInfo.updatedRewardsPerStakedToken = newGlobalRewardsPerToken;
        }
        _;
    }

    constructor(address _stakedToken) Ownable(msg.sender) {
        stakedToken = _stakedToken;
    }

    //////////////////////// RESTRICTED ACCESS FUNCTIONS ////////////////////////

    /// @notice  Allows an account with the proper role to start a new rewards period and deposit rewards
    /// @dev     The pending rewards that haven't been released yet in this period are bundled with the deposited amount for the next period
    /// @dev     Noticeably, a new deposit can finish an existing period way before its end, and that's why it is a protected function.
    //          Once rewards are deposited, they cannot be withdrawn from this contract. They are fully distributed to stakers.
    //          Admins can only accelerate its distribution by starting a new rewards period before the previous one ends
    function depositRewards(uint256 _amount, uint256 _periodInDays) external onlyOwner {
        // The deposit of rewards to be distributed linearly until the end of the period
        require(_amount > 0, "Invalid input: _amount=0");
        require(_periodInDays >= 1, "Invalid: _periodInDays < 1 day");
        require(_periodInDays < 5 * 365, "Invalid: _periodInDays > 5 years");

        // transfer tokens to the contract, but only register what actually arrives after fees
        uint256 pendingRewards = 0;

        if (rewardsData.isInitialized()) {
            // first update the linear release and the global rewards per token
            // The output of the function deliberately ignored
            _updateGlobalRewardsPerStakedToken();

            // incrase amount with the pending rewards that haven't been released yet
            pendingRewards = rewardsData.nonDistributedRewards();
        }

        uint256 distributedAmount = _amount + pendingRewards;

        // overwrite all fields of the RewardsPeriod info struct
        // the rewardsDeposited includes the remaining rewards from the previous period that were not distributed
        rewardsData.rewardsDeposited = uint128(distributedAmount);
        rewardsData.lastReleasedAmount = 0; // nothing has ben released yet
        rewardsData.startDate = uint64(block.timestamp);
        rewardsData.endDate = uint64(block.timestamp + _periodInDays * 1 days);

        IERC20(stakedToken).safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposited(_amount, distributedAmount, _periodInDays);
    }

    //////////////////////// EXTERNAL USER-FACING FUNCTIONS ////////////////////////

    /// @notice  Any account can stake the PIN token
    /// @dev     The modifier triggers a rewards upate for msg.sender and an update of the global rewards per token
    /// @dev     So the rewards are up to date before the staking operation is executed
    /// @dev     If this contract is not excluded from transfer fees, the staked amount will differ from `_amount`
    function stake(uint256 _amount) external updateRewards(msg.sender) {
        require(_amount > 0, "Amount must be greater than 0");

        stakeInfo[msg.sender].balance += _amount;
        totalStakedTokens += _amount;

        IERC20(stakedToken).safeTransferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount);
    }

    /// @notice  Any account with positive staking balance can unstake the PIN tokens
    /// @dev     The modifier triggers a rewards upate for msg.sender and update of the global rewards per token,
    ///          so rewards are up to date before the unstake action takes place
    /// @dev     If this contract is not excluded from transfer fees, the unstaked amount will differ from `_amount`
    function unstake(uint256 _amount) external updateRewards(msg.sender) {
        StakeInfo storage accountInfo = stakeInfo[msg.sender];

        require(_amount > 0, "Invalid: _amount=0");
        require(accountInfo.balance >= _amount, "Insufficient staked amount");
        require(accountInfo.pendingUnstakesCount <= MAX_PENDING_UNSTAKES, "Too many pending unstakes");

        uint256 totalStaked = totalStakedTokens;

        accountInfo.balance -= _amount;
        totalStakedTokens = totalStaked - _amount;

        pendingUnstakes[msg.sender].push(
            Unstake({
                amount: uint128(_amount),
                releaseTime: uint64(block.timestamp + UNSTAKE_LOCKUP_PERIOD),
                withdrawn: false
            })
        );

        // the pending unstakes are always at the tail of `pendingUnstakes[msg.sender]`
        // With this counter, we know how long the tail is, and we can iterate only the pending ones
        accountInfo.pendingUnstakesCount++;

        // if we reach totalStaked==0 due to an unstake, during an active period
        // we wrapup the rewards period so rewards in no-mans-land period are pushed forward
        if ((totalStaked == _amount) && (rewardsData.endDate > block.timestamp)) {
            uint256 pendingForDistribution = rewardsData.nonDistributedRewards();
            // the end Date is not altered, only the start date and the remaining rewards
            rewardsData.rewardsDeposited = uint128(pendingForDistribution);
            rewardsData.startDate = uint64(block.timestamp);
            rewardsData.lastReleasedAmount = 0;
        }

        emit Unstaked(msg.sender, _amount);
    }

    /// @notice  Allows an account to claim pending staking rewards
    /// @dev     The modifier triggers a rewards upate for msg.sender, 
    ///          so the `pendingRewards` are updated before sending the rewards
    function claimRewards() external updateRewards(msg.sender) {
        // the pendingRewards have just been upated in the `updateRewards` modifer, so this value is up-to-date
        uint256 pendingRewards = stakeInfo[msg.sender].pendingRewards;

        // delete to get some gas back
        delete stakeInfo[msg.sender].pendingRewards;

        stakeInfo[msg.sender].totalRewardsClaimed += pendingRewards;

        IERC20(stakedToken).safeTransfer(msg.sender, pendingRewards);
        emit ClaimedRewards(msg.sender, pendingRewards);
    }

    /// @notice  This withdraws ALL pending unstakes that have fulfilled the lockup period.
    /// @dev     The modifier updating rewards has no effect in the withdrawn tokens, but better keep the system updated as frequently as possible
    function withdraw() external updateRewards(msg.sender) {
        uint256 totalToWithdraw;
        uint256 stakesWithdrawn;
        uint256 length = pendingUnstakes[msg.sender].length;
        uint256 firstPendingUnstake = length - stakeInfo[msg.sender].pendingUnstakesCount;

        // here we iterate since he first unstake that hasn't been withdrawn yet, and we "break" when we find one that hasn't been released yet
        // this ensures that we never iterate unstakes that have been already withdrawn
        for (uint256 i = firstPendingUnstake; i < length; i++) {
            Unstake storage pendingUnstake = pendingUnstakes[msg.sender][i];
            // as soon as we hit a unstake that is not ready yet, we know that all the following ones are not ready either,
            // because the unstakes are sorted by `releaseTime`
            if (pendingUnstake.releaseTime > block.timestamp) break;

            pendingUnstake.withdrawn = true;
            stakesWithdrawn++;
            totalToWithdraw += pendingUnstake.amount;
        }

        if (totalToWithdraw > 0) {
            // update the storage count only after the loop
            stakeInfo[msg.sender].pendingUnstakesCount -= stakesWithdrawn;
            IERC20(stakedToken).safeTransfer(msg.sender, totalToWithdraw);
            emit Withdrawn(msg.sender, totalToWithdraw);
        }
    }

    /// @notice updates the rewards release, and the global rewards per token 
    /// @dev    The rewards release update is triggered by all functions with the updateRewards modifier.
    /// @dev    But this function allows to manually triggering the rewards update, to minimize the step sizes
    function updateRewardsRelease() external {
        _updateGlobalRewardsPerStakedToken();
    }

    //////////////////////// VIEW FUNCTIONS ////////////////////////

    /// @notice returns the sum of all active pending unstakes that can be withdrawn now
    /// @dev see withdraw() for more info about the for-loop iteration boundaries
    function getWithdrawableAmount(address account) public view returns (uint256 totalWithdrawable) {
        uint256 length = pendingUnstakes[account].length;
        uint256 firstPendingUnstake = length - stakeInfo[account].pendingUnstakesCount;

        for (uint256 i = firstPendingUnstake; i < length; i++) {
            if (pendingUnstakes[account][i].releaseTime > block.timestamp) break;
            totalWithdrawable += pendingUnstakes[account][i].amount;
        }
    }

    /// @notice returns the sum of all active pending unstakes of `account` that cannot be withdrawn yet
    /// @dev see withdraw() for more info about the for-loop iteration boundaries
    function getLockedUnstakedAmount(address account) public view returns (uint256 totalLocked) {
        uint256 length = pendingUnstakes[account].length;
        if (length == 0) return 0;

        uint256 firstPendingUnstake = length - stakeInfo[account].pendingUnstakesCount;

        if (firstPendingUnstake == length) return 0; // all unstakes are withdrawable (or there are no unstakes at all

        // here we start iterating from the tail, and go backwards until we hit an unstake that is already withdrawable
        for (uint256 i = length; i > firstPendingUnstake; i--) {
            uint256 index = i - 1;
            if (pendingUnstakes[account][index].releaseTime <= block.timestamp) break;
            totalLocked += pendingUnstakes[account][index].amount;
        }
        return totalLocked;
    }

    /// @notice returns the sum of all staked tokens for `account`
    function getStakingBalance(address account) public view returns (uint256) {
        return stakeInfo[account].balance;
    }

    // @notice returns the sum of all historical rewards claimed plus the pending rewards.
    function getHistoricalRewardsEarned(address account) public view returns (uint256) {
        return stakeInfo[account].totalRewardsClaimed + getClaimableRewards(account);
    }

    /// @notice  returns the amount of rewards that would be received by `account` if he/she called `claimRewards()`
    /// @dev     includes an estimation of the pending linear release since the last time it was updated,
    //          because we cannot run the updateRewards modifier here as it is a view function
    function getClaimableRewards(address account) public view returns (uint256 estimatedRewards) {
        // the below calculations would revert when the array has no elements
        if (!rewardsData.isInitialized()) return 0;

        StakeInfo storage accountInfo = stakeInfo[account];

        // here we estimate the increase in globalRewardsPerStaked token if the pending rewards were released
        uint256 globalRewardPerToken = globalRewardsPerStakedToken;

        // only update globalRewardPerToken if there are staked tokens to distribute among
        uint256 estimatedRewardsFromUnreleased;
        if (totalStakedTokens > 0) {
            globalRewardPerToken += (rewardsData.releasedSinceLastUpdate() * PRECISION) / totalStakedTokens;
            // this estimated rewards are only relevant if there is any balance in the account (and then necessarily totalStakeTokens>0)
            estimatedRewardsFromUnreleased =
                (accountInfo.balance * (globalRewardPerToken - accountInfo.updatedRewardsPerStakedToken)) / PRECISION;
        }

        return estimatedRewardsFromUnreleased + accountInfo.pendingRewards;
    }

    /// @notice returns an array of Unstake objects that haven't been withdrawn yet.
    /// @dev    This includes the ones that are in lockup period, and the ones that are already withdrawable
    /// @dev    The unstakes that have been already withdrawn are not included here.
    /// @dev    Note that the withdrawn field in the Unstake struct will always be `false` in these ones
    /// @dev    The length of the array can be read in advace with `unstakeInfo[account].pendingUnstakesCount`
    function getPendingUnstakes(address account) public view returns (Unstake[] memory unstakes) {
        uint256 length = pendingUnstakes[account].length;
        uint256 pendingUnstakesCount = stakeInfo[account].pendingUnstakesCount;
        uint256 firstPendingUnstake = length - pendingUnstakesCount;

        // the lenght of the output arrays is known before iteration
        unstakes = new Unstake[](pendingUnstakesCount);

        // item `firstPendinUnstake` goes into index=0 of the output array
        for (uint256 i = firstPendingUnstake; i < length; i++) {
            unstakes[i - firstPendingUnstake] = Unstake({
                amount: pendingUnstakes[account][i].amount,
                releaseTime: pendingUnstakes[account][i].releaseTime,
                withdrawn: false // because we are only returning the pending ones
            });
        }
    }

    /// @notice     gives an approximated APR for the current rewards period and the current totalStakedTokens
    /// @dev        This is only a rough estimation which makes the following assumptions:
    ///             - It uses the current period rewards and duration: as soon as a new period is created, the APR can change.
    ///             - It uses the current totalStakedTokens: the APR will change with every stake/unstake
    ///             - If the period duration is 0, or there are no staked tokens, this function returns APR=0
    function getEstimatedAPR() public view returns (uint256) {
        return rewardsData.estimatedAPR(totalStakedTokens);
    }

    //////////////////////// INTERNAL FUNCTIONS ////////////////////////

    /// @notice     Triggers a release of the linear rewards distribution since the last update, 
    //              and with the released rewards, the global rewards per token is updated
    /// @dev        If there are no staked tokens, there is no update
    function _updateGlobalRewardsPerStakedToken() internal returns (uint256 globalRewardPerToken) {
        // cache storage variables for gas savings
        uint256 totalTokens = totalStakedTokens;
        globalRewardPerToken = globalRewardsPerStakedToken;

        // if there are no staked tokens, there is no distribution, so the global rewards per token is not updated
        if (totalTokens == 0) {
            if (rewardsData.endDate > block.timestamp) {
                // push the start date forward until there are staked tokens
                rewardsData.startDate = uint64(block.timestamp);
            }
            return globalRewardPerToken;
        }

        // The difference between the last distribution and the released tokens following the linear release
        // is what needs to be distributed in this update
        uint256 released = rewardsData.releasedSinceLastUpdate();

        // The rounding error here will be included in the next time `released` is calculated
        uint256 extraRewardsPerToken = (released * PRECISION) / totalTokens;

        // globalRewardsPerStakedToken is always incremented, it can never go down
        globalRewardPerToken += extraRewardsPerToken;

        // update storage
        globalRewardsPerStakedToken = globalRewardPerToken;
        // the actual amount of distributed tokens is (extraRewardsPerToken * totalTokens) / PRECISION, 
        // however, as this result is rounded down, it can break some critical invariants by dust amounts. 
        // Instead we store the last released amount, knowing that the difference between released and actually distributed
        // will be lost as dust wei in the contract
        // trying to keep track of those dust amounts would require more storage operations 
        // and are not be worth the gas spent
        rewardsData.lastReleasedAmount += uint128(released);

        emit GlobalRewardsPerStakedTokenUpdated(released, globalRewardPerToken);
    }
}
pragma solidity 0.8.20;

struct RewardsPeriod {
    // amount of rewards to be distributed linearly until the end of the period. // units: wei
    uint128 rewardsDeposited;
    // released amount in the last update // units: wei
    uint128 lastReleasedAmount;
    // timestamp when the period starts
    uint64 startDate;
    // timestamp when the period ends
    uint64 endDate;
}

library RewardsLogic {
    using RewardsLogic for RewardsPeriod;

    uint256 public constant PRECISSION = 1e18;

    /// @notice Reward tokens that have been released in this period according to the linear release
    function releasedRewardsSincePeriodStarted(RewardsPeriod storage self)
        internal
        view
        returns (uint256 releasedAmount)
    {
        // once the end date has passed all rewards are released
        if (block.timestamp > self.endDate) return self.rewardsDeposited;
        // before the period starts, no rewards are released
        if (block.timestamp < self.startDate) return 0;
        // between start and end, there is a linear release of the rewardsDeposited
        return (self.rewardsDeposited * (block.timestamp - self.startDate)) / (self.endDate - self.startDate);
    }

    /// @notice difference between the released amount according to the linear release, and the total released amount up to last update
    function releasedSinceLastUpdate(RewardsPeriod storage self) internal view returns (uint256 releasedAmount) {
        return self.releasedRewardsSincePeriodStarted() - self.lastReleasedAmount;
    }

    /// @notice This returns the value of rewards that haven't been distributed in a storage operation.
    /// @dev It does not take into account potential amounts that
    //      might be released since the last update until now.
    function nonDistributedRewards(RewardsPeriod storage self) internal view returns (uint256 pendingToDistribute) {
        return self.rewardsDeposited - self.lastReleasedAmount;
    }

    /// @dev if endDate==0 it means that no rewards have been deposited yet any time
    /// @notice determines if there was at least one rewards deposit
    function isInitialized(RewardsPeriod storage self) internal view returns (bool) {
        return self.endDate > 0;
    }

    /// @notice This estimates the APR of the current period for the CURRENT TOTAL STAKED
    /// @dev This assumes that the totalStaked is constant over the entire period, which is of course a very relaxed assumption.
    /// @dev This therefore only provides a snapshot of the APR in this moment for the current totalStaked
    /// @dev units: ratio APR scaled up by PRECISION. Examples:
    ///         - for 5% APR, the function would return 0.05 * 1e18.
    ///         - for 100% APR, the function would return 1e18.
    function estimatedAPR(RewardsPeriod storage self, uint256 totalStaked) internal view returns (uint256) {
        // If there are no staked tokens, nobody is getting rewards, so APR is 0.
        if (totalStaked == 0) return 0;

        uint256 periodDuration = self.endDate - self.startDate;

        // This can only happen when no rewards have been distributed yet, in which case APR is also 0
        if (periodDuration == 0) return 0;

        return (PRECISSION * self.rewardsDeposited * 365 days) / (totalStaked * periodDuration);
    }
}