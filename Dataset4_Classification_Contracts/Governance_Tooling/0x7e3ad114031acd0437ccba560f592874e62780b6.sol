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
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
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
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

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
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

interface IVotingEscrow {
    /// @dev Lockup struct
    struct Lockup {
        uint128 amount; // Locked amount
        uint128 duration; // Lock duration in seconds
        uint128 end; // Lock end timestamp in seconds
        uint256 points; // veTRUF points
        bool isVesting; // True if locked from vesting
    }

    function stakeVesting(uint256 amount, uint256 duration, address to, uint256 startTime) external returns (uint256 lockupId);

    function unstakeVesting(address user, uint256 lockupId, bool force) external returns (uint256 amount);

    function migrateVestingLock(address oldUser, address newUser, uint256 lockupId)
        external
        returns (uint256 newLockupId);

    function extendVestingLock(address user, uint256 lockupId, uint256 amount, uint256 duration) external;

    // Events
    /// Emitted when user staked TRUF or vesting
    event Stake(
        address indexed user, bool indexed isVesting, uint256 lockupId, uint256 amount, uint256 start, uint256 end, uint256 points
    );

    /// Emitted when user unstaked
    event Unstake(
        address indexed user, bool indexed isVesting, uint256 lockupId, uint256 amount, uint256 end, uint256 points
    );

    /// Emitted when lockup migrated to another user (for vesting only)
    event Migrated(address indexed oldUser, address indexed newUser, uint256 oldLockupId, uint256 newLockupId);

    /// Emitted when lockup cancelled (for vesting only)
    event Cancelled(address indexed user, uint256 lockupId, uint256 amount, uint256 points);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IVotingEscrow} from "../interfaces/IVotingEscrow.sol";

/**
 * @title TRUF vesting contract
 * @author Ryuhei Matsuda
 * @notice Admin registers vesting information for users,
 *      and users could claim or lock vesting to veTRUF to get voting power and TRUF staking rewards
 */
contract TrufVesting is Ownable2Step {
    using SafeERC20 for IERC20;

    error ZeroAddress();
    error ZeroAmount();
    error Forbidden(address sender);
    error InvalidTimestamp();
    error InvalidAmount();
    error InvalidVestingCategory(uint256 id);
    error InvalidEmissions();
    error InvalidVestingInfo(uint256 categoryIdx, uint256 id);
    error InvalidUserVesting();
    error ClaimAmountExceed();
    error UserVestingAlreadySet(uint256 categoryIdx, uint256 vestingId, address user);
    error UserVestingDoesNotExists(uint256 categoryIdx, uint256 vestingId, address user);
    error MaxAllocationExceed();
    error AlreadyVested(uint256 categoryIdx, uint256 vestingId, address user);
    error LockExist();
    error LockDoesNotExist();
    error InvalidInitialReleasePct();
    error InvalidInitialReleasePeriod();
    error InvalidCliff();
    error InvalidPeriod();
    error InvalidUnit();
    error Initialized();

    /// @dev Emitted when vesting category is set
    event VestingCategorySet(uint256 indexed id, string category, uint256 maxAllocation, bool adminClaimable);

    /// @dev Emitted when emission schedule is set
    event EmissionScheduleSet(uint256 indexed categoryId, uint256[] emissions);

    /// @dev Emitted when vesting info is set
    event VestingInfoSet(uint256 indexed categoryId, uint256 indexed id, VestingInfo info);

    /// @dev Emitted when user vesting info is set
    event UserVestingSet(
        uint256 indexed categoryId, uint256 indexed vestingId, address indexed user, uint256 amount, uint64 startTime
    );

    /// @dev Emitted when user vesting is migrated using the migrator contract.
    event UserVestingMigrated(
        uint256 indexed categoryId,
        uint256 indexed vestingId,
        address indexed user,
        uint256 amount,
        uint256 claimed,
        uint256 locked,
        uint64 startTime
    );

    /// @dev Emitted when admin migrates user's vesting to another address
    event MigrateUser(
        uint256 indexed categoryId, uint256 indexed vestingId, address prevUser, address newUser, uint256 newLockupId
    );

    /// @dev Emitted when admin cancel user's vesting
    event CancelVesting(
        uint256 indexed categoryId, uint256 indexed vestingId, address indexed user, bool giveUnclaimed
    );

    /// @dev Emitted when admin has been set
    event AdminSet(address indexed admin, bool indexed flag);

    /// @dev Emitted when user claimed vested TRUF tokens
    event Claimed(uint256 indexed categoryId, uint256 indexed vestingId, address indexed user, uint256 amount);

    /// @dev Emitted when veTRUF token has been set
    event VeTrufSet(address indexed veTRUF);

    /// @dev Emitted when user stakes vesting to veTRUF
    event Staked(
        uint256 indexed categoryId,
        uint256 indexed vestingId,
        address indexed user,
        uint256 amount,
        uint256 start,
        uint256 duration,
        uint256 lockupId
    );

    /// @dev Emitted when user extended veTRUF staking period or increased amount
    event ExtendedStaking(
        uint256 indexed categoryId, uint256 indexed vestingId, address indexed user, uint256 amount, uint256 duration
    );

    /// @dev Emitted when user unstakes from veTRUF
    event Unstaked(uint256 indexed categoryId, uint256 indexed vestingId, address indexed user, uint256 amount);

    /// @dev Vesting Category struct
    struct VestingCategory {
        string category; // Category name
        uint256 maxAllocation; // Maximum allocation for this category
        uint256 allocated; // Current allocated amount
        bool adminClaimable; // Allow admin to claim if value is true
        uint256 totalClaimed; // Total claimed amount
    }

    /// @dev Vesting info struct
    struct VestingInfo {
        uint64 initialReleasePct; // Initial Release percentage
        uint64 initialReleasePeriod; // Initial release period after TGE
        uint64 cliff; // Cliff period
        uint64 period; // Total period
        uint64 unit; // The period to claim. ex. monthly or 6 monthly
    }

    /// @dev User vesting info struct
    struct UserVesting {
        uint256 amount; // Total vesting amount
        uint256 claimed; // Total claimed amount
        uint256 locked; // Locked amount at VotingEscrow
        uint64 startTime; // Vesting start time
    }

    uint256 public constant DENOMINATOR = 1e18;
    uint64 public constant ONE_MONTH = 30 days;

    /// @dev Is category initialized
    mapping(uint256 => bool) public isInitialized;

    /// @dev TRUF token address
    IERC20 public immutable trufToken;

    /// @dev TRUF Migration contract address
    address public immutable trufMigrator;

    /// @dev veTRUF token address
    IVotingEscrow public veTRUF;

    /// @dev TGE timestamp
    uint64 public immutable tgeTime;

    /// @dev Vesting categories
    VestingCategory[] public categories;

    // @dev Emission schedule per category. x index item of array indicates emission limit on x+1 months after TGE time.
    mapping(uint256 => uint256[]) public emissionSchedule;

    /// @dev Vesting info per category
    mapping(uint256 => VestingInfo[]) public vestingInfos;

    /// @dev User vesting information (category => info => user address => user vesting)
    mapping(uint256 => mapping(uint256 => mapping(address => UserVesting))) public userVestings;

    /// @dev Vesting lockup ids (category => info => user address => lockup id)
    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) public lockupIds;

    /// @dev True if account has admin permission
    mapping(address => bool) public isAdmin;

    modifier onlyAdmin() {
        if (!isAdmin[msg.sender] && msg.sender != owner()) {
            revert Forbidden(msg.sender);
        }
        _;
    }

    /**
     * @notice TRUF Vesting constructor
     * @param _trufToken TRUF token address
     */
    constructor(IERC20 _trufToken, address _trufMigrator, uint64 _tgeTime) {
        if (address(_trufToken) == address(0)) revert ZeroAddress();

        trufToken = _trufToken;
        trufMigrator = _trufMigrator;
        tgeTime = _tgeTime;
    }

    /**
     * @notice Calculate claimable amount (total vested amount - previously claimed amount - locked amount)
     * @param categoryId Vesting category id
     * @param vestingId Vesting id
     * @param user user address
     * @return claimableAmount Claimable amount
     */
    function claimable(uint256 categoryId, uint256 vestingId, address user)
        public
        view
        returns (uint256 claimableAmount)
    {
        if (isInitialized[categoryId] == false) revert Initialized();

        UserVesting memory userVesting = userVestings[categoryId][vestingId][user];

        VestingInfo memory info = vestingInfos[categoryId][vestingId];

        uint64 startTime = userVesting.startTime + info.initialReleasePeriod;

        if (startTime > block.timestamp) {
            return 0;
        }

        uint256 totalAmount = userVesting.amount;

        uint256 initialRelease = (totalAmount * info.initialReleasePct) / DENOMINATOR;

        startTime += info.cliff;

        uint256 vestedAmount;

        if (startTime > block.timestamp) {
            vestedAmount = initialRelease;
        } else {
            uint64 timeElapsed = ((uint64(block.timestamp) - startTime) / info.unit) * info.unit;

            vestedAmount = ((totalAmount - initialRelease) * timeElapsed) / info.period + initialRelease;
        }

        uint256 maxClaimable = userVesting.amount - userVesting.locked;
        if (vestedAmount > maxClaimable) {
            vestedAmount = maxClaimable;
        }
        if (vestedAmount <= userVesting.claimed) {
            return 0;
        }

        claimableAmount = vestedAmount - userVesting.claimed;
        uint256 emissionLeft = getEmission(categoryId) - categories[categoryId].totalClaimed;

        if (claimableAmount > emissionLeft) {
            claimableAmount = emissionLeft;
        }
    }

    /**
     * @notice Claim available amount
     * @dev Owner is able to claim for admin claimable categories.
     * @param user user account(For non-admin claimable categories, it must be msg.sender)
     * @param categoryId category id
     * @param vestingId vesting id
     * @param claimAmount token amount to claim
     */
    function claim(address user, uint256 categoryId, uint256 vestingId, uint256 claimAmount) public {
        if (isInitialized[categoryId] == false) revert Initialized();

        if (user != msg.sender && (!categories[categoryId].adminClaimable || !isAdmin[msg.sender])) {
            revert Forbidden(msg.sender);
        }

        uint256 claimableAmount = claimable(categoryId, vestingId, user);
        if (claimAmount == type(uint256).max) {
            claimAmount = claimableAmount;
        } else if (claimAmount > claimableAmount) {
            revert ClaimAmountExceed();
        }
        if (claimAmount == 0) {
            revert ZeroAmount();
        }

        categories[categoryId].totalClaimed += claimAmount;
        userVestings[categoryId][vestingId][user].claimed += claimAmount;
        trufToken.safeTransfer(user, claimAmount);

        emit Claimed(categoryId, vestingId, user, claimAmount);
    }

    /**
     * @notice Stake vesting to veTRUF to get voting power and get staking TRUF rewards
     * @param categoryId category id
     * @param vestingId vesting id
     * @param amount amount to stake
     * @param duration lock period in seconds
     */
    function stake(uint256 categoryId, uint256 vestingId, uint256 amount, uint256 duration) external {
        _stake(msg.sender, categoryId, vestingId, amount, block.timestamp, duration);
    }

    /**
     * @notice Extend veTRUF staking period and increase amount
     * @param categoryId category id
     * @param vestingId vesting id
     * @param amount token amount to increase
     * @param duration lock period from now
     */
    function extendStaking(uint256 categoryId, uint256 vestingId, uint256 amount, uint256 duration) external {
        if (isInitialized[categoryId] == false) revert Initialized();

        uint256 lockupId = lockupIds[categoryId][vestingId][msg.sender];
        if (lockupId == 0) {
            revert LockDoesNotExist();
        }

        if (amount != 0) {
            UserVesting storage userVesting = userVestings[categoryId][vestingId][msg.sender];

            if (amount > userVesting.amount - userVesting.claimed - userVesting.locked) {
                revert InvalidAmount();
            }

            userVesting.locked += amount;

            trufToken.safeIncreaseAllowance(address(veTRUF), amount);
        }
        veTRUF.extendVestingLock(msg.sender, lockupId - 1, amount, duration);

        emit ExtendedStaking(categoryId, vestingId, msg.sender, amount, duration);
    }

    /**
     * @notice Unstake vesting from veTRUF
     * @param categoryId category id
     * @param vestingId vesting id
     */
    function unstake(uint256 categoryId, uint256 vestingId) external {
        if (isInitialized[categoryId] == false) revert Initialized();

        uint256 lockupId = lockupIds[categoryId][vestingId][msg.sender];
        if (lockupId == 0) {
            revert LockDoesNotExist();
        }

        uint256 amount = veTRUF.unstakeVesting(msg.sender, lockupId - 1, false);

        UserVesting storage userVesting = userVestings[categoryId][vestingId][msg.sender];

        userVesting.locked -= amount;
        delete lockupIds[categoryId][vestingId][msg.sender];

        emit Unstaked(categoryId, vestingId, msg.sender, amount);
    }

    /**
     * @notice Migrate owner of vesting. Used when user lost his private key
     * @dev Only admin can migrate users vesting
     * @param categoryId Category id
     * @param vestingId Vesting id
     * @param prevUser previous user address
     * @param newUser new user address
     */
    function migrateUser(uint256 categoryId, uint256 vestingId, address prevUser, address newUser) external onlyAdmin {
        if (newUser == address(0)) {
            revert ZeroAddress();
        }

        UserVesting storage prevVesting = userVestings[categoryId][vestingId][prevUser];
        UserVesting storage newVesting = userVestings[categoryId][vestingId][newUser];

        if (newVesting.amount != 0) {
            revert UserVestingAlreadySet(categoryId, vestingId, newUser);
        }
        if (prevVesting.amount == 0) {
            revert UserVestingDoesNotExists(categoryId, vestingId, prevUser);
        }

        newVesting.amount = prevVesting.amount;
        newVesting.claimed = prevVesting.claimed;
        newVesting.startTime = prevVesting.startTime;

        uint256 lockupId = lockupIds[categoryId][vestingId][prevUser];
        uint256 newLockupId;

        if (lockupId != 0) {
            newLockupId = veTRUF.migrateVestingLock(prevUser, newUser, lockupId - 1) + 1;
            lockupIds[categoryId][vestingId][newUser] = newLockupId;
            delete lockupIds[categoryId][vestingId][prevUser];

            newVesting.locked = prevVesting.locked;
        }
        delete userVestings[categoryId][vestingId][prevUser];

        emit MigrateUser(categoryId, vestingId, prevUser, newUser, newLockupId);
    }

    /**
     * @notice Cancel vesting and force cancel from voting escrow
     * @dev Only admin can cancel users vesting
     * @param categoryId Category id
     * @param vestingId Vesting id
     * @param user user address
     * @param giveUnclaimed Send currently vested, but unclaimed amount to use or not
     */
    function cancelVesting(uint256 categoryId, uint256 vestingId, address user, bool giveUnclaimed)
        external
        onlyAdmin
    {
        UserVesting storage userVesting = userVestings[categoryId][vestingId][user];

        if (userVesting.amount == 0) {
            revert UserVestingDoesNotExists(categoryId, vestingId, user);
        }

        VestingInfo memory vestingInfo = vestingInfos[categoryId][vestingId];
        if (
            userVesting.startTime + vestingInfo.initialReleasePeriod + vestingInfo.cliff + vestingInfo.period
                <= block.timestamp
        ) {
            revert AlreadyVested(categoryId, vestingId, user);
        }

        uint256 lockupId = lockupIds[categoryId][vestingId][user];

        if (lockupId != 0) {
            veTRUF.unstakeVesting(user, lockupId - 1, true);
            delete lockupIds[categoryId][vestingId][user];
            userVesting.locked = 0;
        }

        VestingCategory storage category = categories[categoryId];

        uint256 claimableAmount = claimable(categoryId, vestingId, user);

        uint256 unvested = userVesting.amount - (userVesting.claimed + (giveUnclaimed ? claimableAmount : 0));

        delete userVestings[categoryId][vestingId][user];

        category.allocated -= unvested;

        if (giveUnclaimed && claimableAmount != 0) {
            trufToken.safeTransfer(user, claimableAmount);

            category.totalClaimed += claimableAmount;
            emit Claimed(categoryId, vestingId, user, claimableAmount);
        }

        emit CancelVesting(categoryId, vestingId, user, giveUnclaimed);
    }

    /**
     * @notice Add a new vesting category
     * @dev Only admin can add a vesting category
     * @param category new vesting category
     * @param maxAllocation Max allocation amount for this category
     * @param adminClaimable Admin claimable flag
     */
    function setVestingCategory(string calldata category, uint256 maxAllocation, bool adminClaimable)
        public
        onlyOwner
    {
        if (maxAllocation == 0) {
            revert ZeroAmount();
        }

        uint256 id = categories.length;
        categories.push(VestingCategory(category, maxAllocation, 0, adminClaimable, 0));

        emit VestingCategorySet(id, category, maxAllocation, adminClaimable);
    }

    /**
     * @notice Set emission schedule
     * @dev Only admin can set emission schedule
     * @param categoryId category id
     * @param emissions Emission schedule
     */
    function setEmissionSchedule(uint256 categoryId, uint256[] memory emissions) public onlyOwner {
        if (isInitialized[categoryId]) {
            revert Initialized();
        }

        uint256 maxAllocation = categories[categoryId].maxAllocation;

        if (emissions.length == 0 || emissions[emissions.length - 1] != maxAllocation) {
            revert InvalidEmissions();
        }

        delete emissionSchedule[categoryId];
        emissionSchedule[categoryId] = emissions;

        emit EmissionScheduleSet(categoryId, emissions);
    }

    /**
     * @notice Add or modify vesting information
     * @dev Only admin can set vesting info
     * @param categoryIdx category id
     * @param id id to modify or uint256.max to add new info
     * @param info new vesting info
     */
    function setVestingInfo(uint256 categoryIdx, uint256 id, VestingInfo calldata info) public onlyAdmin {
        if (info.initialReleasePct > DENOMINATOR) {
            revert InvalidInitialReleasePct();
        } else if (info.initialReleasePeriod > info.period) {
            revert InvalidInitialReleasePeriod();
        } else if (info.cliff > 365 days) {
            revert InvalidCliff();
        } else if (info.period > 8 * 365 days) {
            revert InvalidPeriod();
        } else if (info.period % info.unit != 0) {
            revert InvalidUnit();
        }
        if (id == type(uint256).max) {
            id = vestingInfos[categoryIdx].length;
            vestingInfos[categoryIdx].push(info);
        } else {
            vestingInfos[categoryIdx][id] = info;
        }

        emit VestingInfoSet(categoryIdx, id, info);
    }

    /**
     * @notice Migrate vesting from old contracts.
     * @param categoryId category id
     * @param vestingId vesting id
     * @param user user address
     * @param amount vesting amount
     * @param claimed vesting claimed amount
     * @param locked vesting locked amount, 0 if no staking
     * @param vestingStartTime zero to start from TGE or non-zero to set up custom start time
     * @param stakingStartTime timestamp where the staking began, 0 if no staking
     * @param stakingDuration duration of the staking, 0 if no staking
     */
    function migrate(
        uint256 categoryId,
        uint256 vestingId,
        address user,
        uint256 amount,
        uint256 claimed,
        uint256 locked,
        uint64 vestingStartTime,
        uint256 stakingStartTime,
        uint256 stakingDuration
    ) public {
        if (msg.sender != trufMigrator) {
            revert();
        }
        if (user == address(0)) {
            revert ZeroAddress();
        }
        if (amount == 0) {
            revert ZeroAmount();
        }
        if (categoryId >= categories.length) {
            revert InvalidVestingCategory(categoryId);
        }
        if (vestingId >= vestingInfos[categoryId].length) {
            revert InvalidVestingInfo(categoryId, vestingId);
        }
        if (isInitialized[categoryId]) {
            trufToken.safeTransferFrom(msg.sender, address(this), amount - claimed);
        } else if (locked > 0) {
            revert Initialized();
        }

        VestingCategory storage category = categories[categoryId];
        UserVesting storage userVesting = userVestings[categoryId][vestingId][user];

        if (amount < claimed + locked) {
            revert InvalidUserVesting();
        }

        category.allocated += amount;
        category.totalClaimed += claimed;
        if (category.allocated > category.maxAllocation) {
            revert MaxAllocationExceed();
        }

        if (vestingStartTime != 0 && vestingStartTime < tgeTime) revert InvalidTimestamp();

        userVesting.amount += amount;
        userVesting.claimed += claimed;
        userVesting.startTime = vestingStartTime == 0 ? tgeTime : vestingStartTime;

        emit UserVestingMigrated(categoryId, vestingId, user, amount, claimed, locked, userVesting.startTime);

        if (locked > 0) {
            _stake(user, categoryId, vestingId, locked, stakingStartTime, stakingDuration);
        }
    }

    /**
     * @notice Set user vesting amount
     * @dev Only admin can set user vesting
     * @dev It will be failed if it exceeds max allocation
     * @param categoryId category id
     * @param vestingId vesting id
     * @param user user address
     * @param startTime zero to start from TGE or non-zero to set up custom start time
     * @param amount vesting amount
     */
    function setUserVesting(uint256 categoryId, uint256 vestingId, address user, uint64 startTime, uint256 amount)
        public
        onlyAdmin
    {
        if (user == address(0)) {
            revert ZeroAddress();
        }
        if (amount == 0) {
            revert ZeroAmount();
        }
        if (categoryId >= categories.length) {
            revert InvalidVestingCategory(categoryId);
        }
        if (vestingId >= vestingInfos[categoryId].length) {
            revert InvalidVestingInfo(categoryId, vestingId);
        }

        VestingCategory storage category = categories[categoryId];
        UserVesting storage userVesting = userVestings[categoryId][vestingId][user];

        category.allocated += amount;
        category.allocated -= userVesting.amount;
        if (category.allocated > category.maxAllocation) {
            revert MaxAllocationExceed();
        }

        if (amount < userVesting.claimed + userVesting.locked) {
            revert InvalidUserVesting();
        }
        if (startTime != 0 && startTime < tgeTime) revert InvalidTimestamp();

        userVesting.amount = amount;
        userVesting.startTime = startTime == 0 ? tgeTime : startTime;

        emit UserVestingSet(categoryId, vestingId, user, amount, userVesting.startTime);
    }

    /**
     * @notice Set veTRUF token
     * @dev Only admin can set veTRUF
     * @param _veTRUF veTRUF token address
     */
    function setVeTruf(address _veTRUF) external onlyOwner {
        if (_veTRUF == address(0)) {
            revert ZeroAddress();
        }
        veTRUF = IVotingEscrow(_veTRUF);

        emit VeTrufSet(_veTRUF);
    }

    /**
     * @notice Set admin
     * @dev Only owner can set
     * @param _admin admin address
     * @param _flag true to set, false to remove
     */
    function setAdmin(address _admin, bool _flag) external onlyOwner {
        isAdmin[_admin] = _flag;

        emit AdminSet(_admin, _flag);
    }

    /**
     * @notice Initialize category by transferring TRUF tokens
     * @param _categoryId category to initialize
     */
    function initialize(uint256 _categoryId) external {
        if (isInitialized[_categoryId]) {
            revert Initialized();
        }

        isInitialized[_categoryId] = true;

        // Categories ID 0 and 7 have already been initialized previously and will be handled in `migrate` function.
        if (_categoryId != 0 && _categoryId != 7) {
            trufToken.safeTransferFrom(msg.sender, address(this), categories[_categoryId].maxAllocation);
        }
    }

    /**
     * @notice Multicall several functions in single transaction
     * @dev Could be for setting vesting categories, vesting info, and user vesting in single transaction at once
     * @param payloads list of payloads
     */
    function multicall(bytes[] calldata payloads) external {
        uint256 len = payloads.length;
        for (uint256 i; i < len;) {
            (bool success, bytes memory result) = address(this).delegatecall(payloads[i]);
            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            unchecked {
                i += 1;
            }
        }
    }

    /**
     * @return emissions returns emission schedule of category
     */
    function getEmissionSchedule(uint256 categoryId) external view returns (uint256[] memory emissions) {
        emissions = emissionSchedule[categoryId];
    }

    /**
     * @return emissionLimit returns current emission limit of category
     */
    function getEmission(uint256 categoryId) public view returns (uint256 emissionLimit) {
        uint64 _tgeTime = tgeTime;

        if (block.timestamp >= _tgeTime) {
            uint256 maxAllocation = categories[categoryId].maxAllocation;

            if (emissionSchedule[categoryId].length == 0) {
                return maxAllocation;
            }
            uint64 elapsedTime = uint64(block.timestamp) - _tgeTime + ONE_MONTH;
            uint64 elapsedMonth = elapsedTime / ONE_MONTH;

            if (elapsedMonth >= emissionSchedule[categoryId].length) {
                return maxAllocation;
            }

            uint256 lastMonthEmission = elapsedMonth == 0 ? 0 : emissionSchedule[categoryId][elapsedMonth - 1];
            uint256 thisMonthEmission = emissionSchedule[categoryId][elapsedMonth];

            uint64 elapsedTimeOfLastMonth = elapsedTime % ONE_MONTH;
            emissionLimit =
                (thisMonthEmission - lastMonthEmission) * elapsedTimeOfLastMonth / ONE_MONTH + lastMonthEmission;
            if (emissionLimit > maxAllocation) {
                emissionLimit = maxAllocation;
            }
        }
    }

    /**
     * @notice Stake vesting to veTRUF to get voting power and get staking TRUF rewards
     * @param user user address
     * @param categoryId category id
     * @param vestingId vesting id
     * @param amount amount to stake
     * @param start lock start timestamp
     * @param duration lock period in seconds
     */
    function _stake(
        address user,
        uint256 categoryId,
        uint256 vestingId,
        uint256 amount,
        uint256 start,
        uint256 duration
    ) internal {
        if (isInitialized[categoryId] == false) revert Initialized();

        if (amount == 0) {
            revert ZeroAmount();
        }
        if (lockupIds[categoryId][vestingId][user] != 0) {
            revert LockExist();
        }

        UserVesting storage userVesting = userVestings[categoryId][vestingId][user];

        if (amount > userVesting.amount - userVesting.claimed - userVesting.locked) {
            revert InvalidAmount();
        }

        userVesting.locked += amount;

        trufToken.safeIncreaseAllowance(address(veTRUF), amount);
        uint256 lockupId = veTRUF.stakeVesting(amount, duration, user, start) + 1;
        lockupIds[categoryId][vestingId][user] = lockupId;

        emit Staked(categoryId, vestingId, user, amount, start, duration, lockupId);
    }
}