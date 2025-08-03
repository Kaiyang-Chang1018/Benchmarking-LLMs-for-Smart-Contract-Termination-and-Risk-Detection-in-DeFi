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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

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
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣤⣾⣿⣿⣿⣿⣷⣶⣶⣦⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⠿⠿⠿⠿⠿⠿⢿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣤⣴⣶⣶⣶⣶⣦⣤⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣶⣶⣤⣤⣤⣤⣶⣶⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣿⡉⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⡇⢻⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣥⣽⡇⢸⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁⠈⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀
  _  _   __  ___  ____________ _____ _____   _____  _   _  ___________ 
 | || | / / / _ \ | ___ \ ___ \  _  |_   _| /  __ \| | | ||  ___|  ___|
/ __) |/ / / /_\ \| |_/ / |_/ / | | | | |   | /  \/| |_| || |__ | |_   
\__ \    \ |  _  ||    /|    /| | | | | |   | |    |  _  ||  __||  _|  
(   / |\  \| | | || |\ \| |\ \\ \_/ / | |   | \__/\| | | || |___| |    
 |_|\_| \_/\_| |_/\_| \_\_| \_|\___/  \_/    \____/\_| |_/\____/\_| V2   
                                                                       
                                                                       
    https://twitter.com/Karrot_gg 
 */
 
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./interfaces/IRandomizer.sol";
import "./interfaces/IConfig.sol";
import "./interfaces/IKarrotsToken.sol";
import "./interfaces/IFullProtec.sol";
import "./interfaces/IStolenPool.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract KarrotChefV3 is Ownable, ReentrancyGuard {
    //=========================================================================
    // SETUP
    //=========================================================================
    using SafeERC20 for IERC20;
    using Address for address;

    uint256 public constant taxFreeRequestId = uint256(keccak256(abi.encodePacked("KARROT TAX EXEMPT (FOR COMPOUNDING)"))); //kek
    uint256 public constant REWARD_SCALING_FACTOR = 1e12;
    uint256 public constant KARROTS_DECIMALS = 1e18;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint224 rewardDebt; // Reward debt. See explanation below.
        uint32 lockEndedTimestamp;
        //
        //   pending reward = (user.amount * pool.accRewardPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accRewardPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint128 allocPoint; // How many allocation points assigned to this pool. Rewards to distribute per block.
        uint32 lastRewardBlock; // Last block number that Rewards distribution occurs.
        uint96 accRewardPerShare; // Accumulated Rewards per share.
    }

    IConfig public config;

    uint16 public karrotClaimTaxRate = 2500; // 25%
    uint16 public fullProtecProtocolLiqProportion = 3200; // "33"%
    uint24 public requestNonce;
    uint40 public startBlock;    
    /**
     * @dev scales debase linearly, 
     * s.t. 1e13 = 0.001% (~6.7%/day) debase per block, 
     * 113 * 1e11 = 0.00113% (~7.5%/day) debase per block
     * 138 * 1e11 =  0.00138% (~9%/day) debase per block
     */
    uint48 public debaseMultiplier = 138 * 1e11; 
    uint64 public lastBlock;
    uint16 public constant PERCENTAGE_DENOMINATOR = 10000;

    uint8 public constant blockOffset = 1; //just to keep math safer maybe, so that user cant deposit on "block 0"
    uint88 public karrotRewardPerBlock = uint88(13_000_000 * KARROTS_DECIMALS); //13M karrots/block
    uint128 public totalAllocPoint = 0;

    bool public vaultDepositsAreOpen = false; //all vaults closed. (big/smol)
    bool public depositsPaused = false; //for pausing without resetting startblock

    /// @dev Info of each pool.
    PoolInfo[] public poolInfo;
    /// @dev Info of each user.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    /// @dev user's withdrawable rewards
    mapping(uint256 => mapping(address => uint256)) private userRewards;
    /// @dev Lock duration in seconds
    mapping(uint256 => uint256) public lockDurations;

    // Events
    event SetDepositsEnabled(bool enabled);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPaid(address indexed user, uint256 indexed pid, uint256 amount);
    event TaxPaid(address indexed user, uint256 indexed pid, uint256 amount);
    event SetRewardPerBlock(uint88 amount);
    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint, IERC20 indexed lpToken);
    event SetAllocationPoint(uint256 indexed pid, uint256 allocPoint);
    event PoolUpdated(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accRewardPerShare);
    event SetLockDuration(uint256 indexed pid, uint256 lockDuration);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount, uint256 tax);
    event RewardQueued(address _account, uint256 _pid, uint256 pending);
    event Compound(address indexed user, uint256 amountKarrot, uint256 poolId);
    event TaxRatioUpdate(address indexed user, uint256 indexed newUserTaxRatio);
    
    error InvalidAllowance();
    error EOAsOnly();
    error RabbitsPerWalletLimitReached();
    error NoPendingRewards(address user);
    error ForwardFailed();
    error CallerIsNotConfig();
    error VaultsDepositsAreClosed();
    error CallerIsNotAccountOrThisContract();
    error PoolExists();
    error InvalidAmount();
    error StillLocked();

    constructor(address _configManager) Ownable() ReentrancyGuard() {
        config = IConfig(_configManager);

        IERC20(config.karrotsAddress()).safeApprove(config.karrotStolenPoolAddress(), type(uint).max);

        //default lockDurations
        lockDurations[0] = 1 days;
        lockDurations[1] = 1 days;
    }

    modifier onlyConfig() {
        if (msg.sender != address(config)) {
            revert CallerIsNotConfig();
        }
        _;
    }

    //=========================================================================
    // ADMIN POOL ACTIONS
    //=========================================================================

    // Add a new lp to the pool. Can only be called by the owner.
    function addPool(uint128 _allocPoint, address _lpToken, bool _withUpdatePools) external onlyOwner {
        if(!lpTokenIsNotAlreadyAdded(_lpToken)){
            revert PoolExists();
        }
        if (_withUpdatePools) {
            massUpdatePools();
        }

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(
            PoolInfo({
                lpToken: IERC20(_lpToken),
                allocPoint: _allocPoint,
                lastRewardBlock: uint32(lastRewardBlock),
                accRewardPerShare: 0
            })
        );

        emit LogPoolAddition(poolInfo.length - 1, _allocPoint, IERC20(_lpToken));
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function lpTokenIsNotAlreadyAdded(address _lpToken) internal view returns (bool) {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            if (address(poolInfo[pid].lpToken) == _lpToken) {
                return false;
            }
        }
        return true;
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 lpSupply;

        if(address(pool.lpToken) == address(0)){
            return;
        }
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        
        if (address(pool.lpToken) == config.karrotsAddress()) {
            lpSupply = IKarrotsToken(config.karrotsAddress()).balanceOfUnderlying(address(this));
        } else {
            lpSupply = pool.lpToken.balanceOf(address(this));
        }

        if (lpSupply == 0) {
            pool.lastRewardBlock = uint32(block.number);
            return;
        }

        uint256 karrotsReward = Math.mulDiv(
            block.number - pool.lastRewardBlock,
            karrotRewardPerBlock * pool.allocPoint,
            totalAllocPoint
        );

        pool.accRewardPerShare += uint96(Math.mulDiv(karrotsReward, REWARD_SCALING_FACTOR, lpSupply));
        pool.lastRewardBlock = uint32(block.number);

        emit PoolUpdated(_pid, pool.lastRewardBlock, lpSupply, pool.accRewardPerShare);
    }

    //=========================================================================
    // USER ACTIONS
    //=========================================================================

    /// @dev Deposit tokens to KarrotsChef for Karrots allocation.
    /// @dev 1e18 in 1e24 out 
    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {

        if (!vaultDepositsAreOpen || depositsPaused) {
            revert VaultsDepositsAreClosed();
        }

        if(_amount == 0){
            revert InvalidAmount();
        }

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        if(pool.lpToken.allowance(msg.sender, address(this)) < _amount){
            revert InvalidAllowance();
        }        
        
        user.lockEndedTimestamp = uint32(block.timestamp + lockDurations[_pid]);
        
        updatePool(_pid);
        _queueRewards(_pid, msg.sender);

        pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);

        /// @dev 1e18-->1e24
        if (address(pool.lpToken) == config.karrotsAddress()) {
            _amount = IKarrotsToken(config.karrotsAddress()).fragmentToKarrots(_amount);
        }
        /// @dev +n*1e24
        user.amount += _amount; 
        user.rewardDebt = uint224(Math.mulDiv(user.amount, pool.accRewardPerShare, REWARD_SCALING_FACTOR));

        emit Deposit(msg.sender, _pid, _amount);
        emit TaxRatioUpdate(msg.sender, getFullToChefRatio(msg.sender));

    }

    /// @dev Withdraw tokens from KarrotChef.
    /// @dev 1e24 in 1e18 out
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        if(_amount == 0){
            revert InvalidAmount();
        }
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if(user.lockEndedTimestamp > block.timestamp){
            revert StillLocked();
        }

        if(_amount > user.amount){
            revert InvalidAmount();
        }

        updatePool(_pid);
        _queueRewards(_pid, msg.sender);

        //expects 1e24 value
        user.amount -= _amount; //-n*1e24
        user.rewardDebt = uint224((user.amount * pool.accRewardPerShare) / REWARD_SCALING_FACTOR);
        user.lockEndedTimestamp = uint32(block.timestamp) + uint32(lockDurations[_pid]);

        //1e24-->1e18
        if (address(pool.lpToken) == config.karrotsAddress()) {
            _amount = IKarrotsToken(config.karrotsAddress()).karrotsToFragment(_amount);
        }
        
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
        emit TaxRatioUpdate(msg.sender, getFullToChefRatio(msg.sender));

    }

    function requestClaim(uint256 _pid) external payable nonReentrant {

        address sender = msg.sender;

        if (sender != tx.origin) {
            revert EOAsOnly();
        }

        updatePool(_pid);
        _queueRewards(_pid, sender);

        if (userRewards[_pid][sender] == 0) {
            revert NoPendingRewards(sender);
        }   

        uint256 randomNumber = IRandomizer(config.randomizerAddress()).getRandomNumber(
            sender,
            block.timestamp,
            requestNonce
        );

        (uint256 rewards, uint256 tax) = _claim(_pid, sender, randomNumber, requestNonce, false);
        ++requestNonce;

        emit Claim(sender, _pid, rewards, tax);
    }

    /// @dev claims pending karrot rewards in smol protec vault tax-free, then immediately deposits back into smol protec vault
    function compoundSmol() external {
        uint256 _randomNumber = 0;
        (uint256 rewards, ) = _claim(1, msg.sender, _randomNumber, taxFreeRequestId, true);
        deposit(1, rewards);
        emit Compound(msg.sender, rewards, 1);
    }


    //=========================================================================
    // INTERNAL WRITE FUNCTIONS
    //=========================================================================

    /// @dev Claim Karrots from KarrotChef
    function _claim(
        uint256 _pid,
        address _account,
        uint256 _randomNumber,
        uint256 _requestId,
        bool callerIsCompounder
    )
        internal
        returns (
            uint256,
            uint256
        )
    {
        uint256 tax = 0;

        //to avoid double queueing when calls are made through requestClaim
        if(_requestId == taxFreeRequestId){
            updatePool(_pid);
            _queueRewards(_pid, _account);
        }
        
        uint256 pendingRewards = userRewards[_pid][_account];
        if (pendingRewards == 0) {
            revert NoPendingRewards(_account);
        }

        IKarrotsToken karrots = IKarrotsToken(config.karrotsAddress());

        UserInfo storage user = userInfo[_pid][_account];
        user.lockEndedTimestamp = uint32(block.timestamp) + uint32(lockDurations[_pid]);

        userRewards[_pid][_account] = 0;
        userInfo[_pid][_account].rewardDebt = uint224(
            (userInfo[_pid][_account].amount * poolInfo[_pid].accRewardPerShare) /
            (REWARD_SCALING_FACTOR));

        if (lastBlock != block.number) {
            uint256 debaseIndexDelta = Math.mulDiv(block.number - lastBlock, debaseMultiplier, 1);
            karrots.rebase(block.number, debaseIndexDelta, false);
            lastBlock = uint64(block.number);
            IUniswapV2Pair(config.karrotsPoolAddress()).sync();
        }

        //[!] if user has enough deposited into the Full Protec Pool, no withdrawal tax
        //if they don't, there will be a 33% tax on their claim
        //the taxed amount will be sent to the stolen pool
        if (userIsExemptFromClaimTax(_account) || _requestId == taxFreeRequestId) {
            karrots.mint(_account, pendingRewards);
            emit RewardPaid(_account, _pid, pendingRewards);        
        } else {
            tax = Math.mulDiv(pendingRewards, karrotClaimTaxRate, PERCENTAGE_DENOMINATOR);
            karrots.mint(_account, pendingRewards - tax);
            
            IStolenPool(config.karrotStolenPoolAddress()).virtualDeposit(tax);

            emit TaxPaid(config.karrotStolenPoolAddress(), _pid, tax);  
            emit RewardPaid(_account, _pid, pendingRewards - tax);
        }
        
        return (pendingRewards, tax);
    }

    function _queueRewards(uint256 _pid, address _account) private {
        UserInfo storage user = userInfo[_pid][_account];
        uint256 pendingRewards = Math.mulDiv(user.amount, poolInfo[_pid].accRewardPerShare, REWARD_SCALING_FACTOR) - user.rewardDebt;
        if (pendingRewards > 0) {
            userRewards[_pid][_account] += pendingRewards;
        }
        emit RewardQueued(_account, _pid, pendingRewards);
    }

    //=========================================================================
    // GETTERS
    //=========================================================================

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // View function to see pending Karrots on frontend.
    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (address(pool.lpToken) == config.karrotsAddress()) {
            lpSupply = IKarrotsToken(config.karrotsAddress()).balanceOfUnderlying(address(this));
        }
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 karrotsReward = (block.number - pool.lastRewardBlock) * Math.mulDiv(karrotRewardPerBlock, pool.allocPoint, totalAllocPoint);
            accRewardPerShare += (karrotsReward * REWARD_SCALING_FACTOR) / lpSupply;
        }
        return userRewards[_pid][_user] + (user.amount * accRewardPerShare / REWARD_SCALING_FACTOR) - user.rewardDebt;
    }
    
    ///@dev check both threshold karrot amount in full protec, and % of total karrots in all vaults in full protec to be above 33% (or n%)
    function userIsExemptFromClaimTax(address _user) public view returns (bool) {
        IFullProtec fullProtec = IFullProtec(config.karrotFullProtecAddress());
        
        bool thresholdCheck = fullProtec.getIsUserAboveThresholdToAvoidClaimTax(_user);
        
        uint256 karrotsInFullProtec = fullProtec.getUserStakedAmount(_user);
        uint256 karrotsInBigAndSmol = getBigAndSmolKarrotEquivalent(_user);

        if(karrotsInBigAndSmol == 0) return thresholdCheck;

        uint256 karrotsInFullProtecRatio = Math.mulDiv(karrotsInFullProtec, PERCENTAGE_DENOMINATOR, karrotsInBigAndSmol);
        bool ratioCheck = karrotsInFullProtecRatio > fullProtecProtocolLiqProportion;

        if(thresholdCheck && ratioCheck) {
            return true;
        }
        
        return false;
    }

    /// @dev for UI - output the ratio of full / smol+big(equivalent) which determines whether user is exempt
    function getFullToChefRatio(address _user) public view returns (uint256) {
        IFullProtec fullProtec = IFullProtec(config.karrotFullProtecAddress());
        uint256 karrotsInFullProtec = fullProtec.getUserStakedAmount(_user);
        uint256 karrotsInBigAndSmol = getBigAndSmolKarrotEquivalent(_user);
        if(karrotsInBigAndSmol == 0) return karrotsInFullProtec;
        return Math.mulDiv(karrotsInFullProtec, PERCENTAGE_DENOMINATOR, karrotsInBigAndSmol);
    }

    function getBigAndSmolKarrotEquivalent(address _user) public view returns (uint256) {
        uint256 bigProtecKarrotEquivalentAmount = getKarrotEquivalent(getTotalAmountStakedInPoolByUser(0, _user));
        uint256 smolProtecAmount = getTotalAmountStakedInPoolByUser(1, _user);
        return bigProtecKarrotEquivalentAmount + smolProtecAmount;
    }

    /**
     * @dev returns the amount of karrots corresponding to the given amount of LP tokens
     * @param _amount the amount of LP tokens to convert to karrots
     */
    function getKarrotEquivalent(uint256 _amount) public view returns (uint256) {
            
        if(_amount == 0) return 0;
        
        IUniswapV2Pair karrotsEthPool = IUniswapV2Pair(config.karrotsPoolAddress());
        uint256 totalLpTokenSupply = karrotsEthPool.totalSupply();
        (uint112 _reserve0, uint112 _reserve1, ) = karrotsEthPool.getReserves();
        address token0 = karrotsEthPool.token0();
        address token1 = karrotsEthPool.token1();

        uint256 tokenReserve = 0;
        if(token0 == config.karrotsAddress()){
            tokenReserve = uint256(_reserve0);
        } else if(token1 == config.karrotsAddress()){
            tokenReserve = uint256(_reserve1);
        }

        // Calculate the ERC20 token equivalent for the given _amount of LP tokens
        return Math.mulDiv(_amount, tokenReserve, totalLpTokenSupply);
    }

    
    /**
     * @dev gets converted (wallet-visible, 10^18 units) amounts for each pool
     * @param _user the user to get the amounts for
     * @param _pid the pool id to get the amounts for
     */
    function getTotalAmountStakedInPoolByUser(uint256 _pid, address _user) public view returns (uint256) {
        if(_pid == 1){
            return IKarrotsToken(config.karrotsAddress()).karrotsToFragment(userInfo[_pid][_user].amount);
        } else {
            return userInfo[_pid][_user].amount;
        }
    }

    /// @dev get the address of the token corresponding to each pool, so karrot-ETH LP (0), karrot (1)
    function poolIdToToken(uint256 _pid) external view returns (address) {
        return address(poolInfo[_pid].lpToken);
    }

    /// @dev get 10^24 units of the total amount of karrots staked in the given pool
    function getUserInfoAmount(address _user, uint256 _pid) external view returns (uint256) {
        return userInfo[_pid][_user].amount;
    }

    //=========================================================================
    // SETTERS (CONFIG MANAGER CONTROLLED)
    //=========================================================================

    // Update the given pool's Karrots allocation point. Can only be called by the config manager.
    function setAllocationPoint(uint256 _pid, uint128 _allocPoint, bool _withUpdatePools) external onlyConfig {
        if (_withUpdatePools) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - uint128(poolInfo[_pid].allocPoint) + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        emit SetAllocationPoint(_pid, _allocPoint);
    }

    function setLockDuration(uint256 _pid, uint256 _lockDuration) external onlyConfig {
        lockDurations[_pid] = _lockDuration;
        emit SetLockDuration(_pid, _lockDuration);
    }

    function updateRewardPerBlock(uint88 _rewardPerBlock) external onlyConfig {
        massUpdatePools();
        karrotRewardPerBlock = _rewardPerBlock;
        emit SetRewardPerBlock(_rewardPerBlock);
    }

    function setDebaseMultiplier(uint48 _debaseMultiplier) external onlyConfig {
        debaseMultiplier = _debaseMultiplier;
    }

    function openKarrotChefDeposits() external onlyConfig {
        startBlock = uint40(block.number - blockOffset);
        lastBlock = startBlock;
        vaultDepositsAreOpen = true;
        emit SetDepositsEnabled(true);
    }

    function setDepositIsPaused(bool _isPaused) external onlyConfig {
        depositsPaused = _isPaused;
        emit SetDepositsEnabled(_isPaused);
    }

    function setClaimTaxRate(uint16 _maxTaxRate) external onlyConfig {
        karrotClaimTaxRate = _maxTaxRate;
    }

    function setFullProtecLiquidityProportion(uint16 _fullProtecLiquidityProportion) external onlyConfig {
        fullProtecProtocolLiqProportion = _fullProtecLiquidityProportion;
    }

    function setConfigManagerAddress(address _configManagerAddress) external onlyOwner {
        config = IConfig(_configManagerAddress);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IConfig {
    function dexInterfacerAddress() external view returns (address);
    function karrotsAddress() external view returns (address);
    function karrotChefAddress() external view returns (address);
    function karrotStolenPoolAddress() external view returns (address);
    function karrotFullProtecAddress() external view returns (address);
    function karrotsPoolAddress() external view returns (address);
    function rabbitAddress() external view returns (address);
    function randomizerAddress() external view returns (address);
    function uniswapRouterAddress() external view returns (address);
    function uniswapFactoryAddress() external view returns (address);
    function treasuryAddress() external view returns (address);
    function treasuryBAddress() external view returns (address);
    function teamSplitterAddress() external view returns (address);
    function presaleDistributorAddress() external view returns (address);
    function airdropDistributorAddress() external view returns (address);
    function attackRewardCalculatorAddress() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IFullProtec {
    function getUserStakedAmount(address _user) external view returns (uint256);
    function getTotalStakedAmount() external view returns (uint256);
    function getIsUserAboveThresholdToAvoidClaimTax(address _user) external view returns (bool);
    function updateConfig() external;
    function openFullProtecDeposits() external;
    function setFullProtecLockDuration(uint32 _lockDuration) external;
    function setThresholdFullProtecKarrotBalance(uint224 _thresholdFullProtecKarrotBalance) external;
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IKarrotsToken {
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function addDexAddress(address _dexAddress) external;
    function removeDexAddress(address _dexAddress) external;
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    function rebase(uint256 epoch, uint256 indexDelta, bool positive) external returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transferUnderlying(address to, uint256 value) external returns (bool);
    function fragmentToKarrots(uint256 value) external view returns (uint256);
    function karrotsToFragment(uint256 karrots) external view returns (uint256);
    function balanceOfUnderlying(address who) external view returns (uint256);
    function setSellTaxRate(uint16 _sellTaxRate) external;
    function setBuyTaxRate(uint16 _buyTaxRate) external;
    function setMaxScaleFactorDecreasePercentagePerDebase(uint256 _maxScaleFactorDecreasePercentagePerDebase) external;
    function setTaxSwapAmountThreshold(uint256 _taxSwapAmountThreshold) external;
    function setDivertTaxToStolenPoolRate(uint256 _divertRate) external;
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IRandomizer {
    function getRandomNumber(address input0, uint256 input1, uint256 input2) external returns (uint256 result);
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IStolenPool {
    function virtualDeposit(uint256 _amount) external;
    function attack(address _sender, uint256 _rabbitTier, uint256 _rabbitId) external;
    function updateConfig() external;
    function setStolenPoolOpenTimestamp() external;
    function setStolenPoolAttackIsOpen(bool _isOpen) external;
    function setAttackBurnPercentage(uint16 _attackBurnPercentage) external;
    function setIsApprovedDepositor(address _depositor, bool _isApproved) external;
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}