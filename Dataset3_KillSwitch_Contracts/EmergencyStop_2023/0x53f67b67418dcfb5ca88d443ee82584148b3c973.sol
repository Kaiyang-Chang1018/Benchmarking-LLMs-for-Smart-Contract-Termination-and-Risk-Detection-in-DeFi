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
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// (c)2021-2024 Atlas
// security-contact: atlas@vialabs.io

pragma solidity ^0.8.9;
import "../message/MessageClient.sol";

abstract contract FeatureBase is MessageClient {
}
// SPDX-License-Identifier: MIT
// (c)2021-2024 Atlas
// security-contact: atlas@vialabs.io

pragma solidity ^0.8.9;
import "./FeatureBase.sol";

interface IMessageTransmitter {
    function receiveMessage(bytes calldata message, bytes calldata attestation) external returns (bool success);
}

interface ITokenMessenger {
    function depositForBurnWithCaller(uint256 amount, uint32 destinationDomain, bytes32 mintRecipient, address burnToken, bytes32 destinationCaller) external returns (uint64 nonce);
}

interface IFeatureCCTP {
    function tokenMessenger() external view returns (address);
    function usdc() external view returns (address);
    function circleDomain(uint _chainId) external view returns (uint32);
    function endpoints(uint _chainId) external view returns (address);
}

abstract contract FeatureCCTP is FeatureBase {
    address public usdc;

    ITokenMessenger public tokenMessenger;
    IFeatureCCTP public feature;

    function configure(IFeatureGateway _featureGateway) public onlyMessageOwner() {
        feature = IFeatureCCTP(_featureGateway.featureAddresses(uint32(9000000)));
        tokenMessenger = ITokenMessenger(feature.tokenMessenger());
        usdc = feature.usdc();
    }

    function _sendUSDC(uint _destChainId, address _recipient, uint _amount) internal {
        _sendUSDC(_destChainId, _recipient, _amount, '');
    }

    function _sendUSDC(uint _destChainId, address _recipient, uint _amount, bytes memory _data) internal {
        uint32 _destCircleDomain = feature.circleDomain(_destChainId);
        IERC20cl(usdc).approve(address(tokenMessenger), _amount);
        tokenMessenger.depositForBurnWithCaller(
            _amount, 
            _destCircleDomain, 
            addressToBytes32(_recipient), 
            usdc,
            addressToBytes32(feature.endpoints(_destChainId))
        );
        _sendMessageWithFeature(_destChainId, _data, uint32(9000000), '');
    }

    function addressToBytes32(address _address) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_address)));
    }
}
// SPDX-License-Identifier: MIT
// (c)2021-2024 Atlas
// security-contact: atlas@vialabs.io

pragma solidity ^0.8.9;

interface IERC20cl {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// (c)2021-2024 Atlas
// security-contact: atlas@vialabs.io

pragma solidity ^0.8.9;

interface IMessageV3 {
    event SendRequested(uint txId, address sender, address recipient, uint chain, bool express, bytes data, uint16 confirmations);
    event SendProcessed(uint txId, uint sourceChainId, address sender, address recipient);
    event Success(uint txId, uint sourceChainId, address sender, address recipient, uint amount);
    event ErrorLog(uint txId, string message);
    event SetExsig(address caller, address signer);
    event SetMaxgas(address caller, uint maxGas);
    event SetMaxfee(address caller, uint maxFee);

    function chainsig() external view returns (address signer);
    function weth() external view returns (address wethTokenAddress);
    function feeToken() external view returns (address feeToken);
    function feeTokenDecimals() external view returns (uint feeTokenDecimals);
    function minFee() external view returns (uint minFee);
    function bridgeEnabled() external view returns (bool bridgeEnabled);
    function takeFeesOffline() external view returns (bool takeFeesOffline);
    function whitelistOnly() external view returns (bool whitelistOnly);

    function enabledChains(uint destChainId) external view returns (bool enabled);
    function customSourceFee(address caller) external view returns (uint customSourceFee);
    function maxgas(address caller) external view returns (uint maxgas);
    function exsig(address caller) external view returns (address signer);

    // @dev backwards compat with BridgeClient
    function minTokenForChain(uint chainId) external returns (uint amount);

    function sendMessage(address recipient, uint chain, bytes calldata data, uint16 confirmations, bool express) external returns (uint txId);
    // @dev backwards compat with BridgeClient
    function sendRequest(address recipient, uint chainId, uint amount, address referrer, bytes calldata data, uint16 confirmations) external returns (uint txId);

    function setExsig(address signer) external;
    function setMaxgas(uint maxgas) external;
    function setMaxfee(uint maxfee) external;

    function getSourceFee(uint _destChainId, bool _express) external view returns (uint _fee);
}
// SPDX-License-Identifier: MIT
// (c)2021-2024 Atlas
// security-contact: atlas@vialabs.io

pragma solidity ^0.8.9;

import "./IMessageV3.sol";
import "./IERC20cl.sol";

interface IFeature {
    function getPayload(uint _txId) external view returns (bytes memory);
}

interface IFeatureGateway {
    function isFeatureEnabled(uint32) external view returns (bool);
    function featureAddresses(uint32) external view returns (address);
    function messageV3() external view returns (IMessageV3);
    function processForward(uint _txId, uint _sourceChainId, uint _destChainId, address _sender, address _recipient, uint _gas, bytes[] calldata _data) external;
    function process(uint txId, uint sourceChainId, uint destChainId, address sender, address recipient, uint gas, uint32 featureId, bytes calldata featureReply, bytes[] calldata data) external;
}

/**
 * @title MessageV3 Client
 * @author Atlas <atlas@vialabs.io>
 */
abstract contract MessageClient {
    IMessageV3 public MESSAGEv3;
    IERC20cl public FEE_TOKEN;
    IFeatureGateway public FEATURE_GATEWAY;
    mapping(uint => mapping(uint32 => ChainData)) public FEATURES;

    struct ChainData {
        address endpoint; // address of this contract on specified chain
        bytes endpointExtended; // address of this contract on non EVM
        uint16 confirmations; // source confirmations
        bool extended; // are we using extended endpoint? (addresses larger than uint256)
    }
    mapping(uint => ChainData) public CHAINS;
    address public MESSAGE_OWNER;

    modifier onlySelf(address _sender, uint _sourceChainId) {
        require(msg.sender == address(MESSAGEv3), "MessageClient: not authorized");
        require(_sender == CHAINS[_sourceChainId].endpoint, "MessageClient: not authorized");
        _;
    }

    modifier onlyActiveChain(uint _destinationChainId) {
        require(CHAINS[_destinationChainId].endpoint != address(0), "MessageClient: destination chain not active");
        _;
    }

    modifier onlyMessageOwner() {
        require(msg.sender == MESSAGE_OWNER, "MessageClient: not authorized");
        _;
    }

    event MessageOwnershipTransferred(address previousOwner, address newOwner);
    event RecoverToken(address owner, address token, uint amount);
    event SetMaxgas(address owner, uint maxGas);
    event SetMaxfee(address owner, uint maxfee);
    event SetExsig(address owner, address exsig);
    event SendMessageWithFeature(uint txId, uint destinationChainId, uint32 featureId, bytes featureData);

    constructor() {
        MESSAGE_OWNER = msg.sender;
    }

    function transferMessageOwnership(address _newMessageOwner) external onlyMessageOwner {
        MESSAGE_OWNER = _newMessageOwner;
        emit MessageOwnershipTransferred(msg.sender, _newMessageOwner);
    }

    /** BRIDGE RECEIVER */
    // @dev DEPRICATED kept for backwards compatibility
    function messageProcess(
        uint _txId,          // transaction id
        uint _sourceChainId, // source chain id
        address _sender,     // corresponding MessageClient address on source chain
        address,
        uint,
        bytes calldata _data // encoded message from source chain
    ) external virtual onlySelf (_sender, _sourceChainId) {
        _processMessage(_txId, _sourceChainId, _data);
    }

    // @dev PREFERRED if no Features used
    // this is extended by the implementing class if not using Features
    function _processMessage(uint _txId, uint _sourceChainId, bytes calldata _data) internal virtual {
        (uint32 _featureId, bytes memory _featureData, bytes memory _messageData) = abi.decode(_data, (uint32, bytes, bytes));
        
        // call the implementing class to process the message
        _processMessageWithFeature(_txId, _sourceChainId, _messageData, _featureId, _featureData, _getFeatureResponse(_featureId, _txId));
    }

    // @dev REQUIRED if using Features
    // this is extended by the implementing class if using Features
    function _processMessageWithFeature(
        uint,         // transaction id
        uint,         // source chain id
        bytes memory, // encoded message from source chain
        uint32,       // feature id
        bytes memory, // encoded feature data
        bytes memory  // reply from feature processing off-chain
    ) internal virtual {
        revert("MessageClient: _processMessage or _processMessageWithFeature not implemented");
    }

    function _getFeatureResponse(uint32 _featureId, uint _txId) internal view returns (bytes memory) {
        return IFeature(FEATURE_GATEWAY.featureAddresses(_featureId)).getPayload(_txId);
    }
    
    /** BRIDGE SENDER */
    function _sendMessage(uint _destinationChainId, bytes memory _data) internal returns (uint _txId) {
        ChainData memory _chain = CHAINS[_destinationChainId];
        if(_chain.extended) { // non-evm addresses larger than uint256
            _data = abi.encode(_data, _chain.endpointExtended);
        }
        return IMessageV3(MESSAGEv3).sendMessage(
            _chain.endpoint,      // corresponding MessageClient contract address on destination chain
            _destinationChainId,  // id of the destination chain
            _data,                // arbitrary data package to send
            _chain.confirmations, // amount of required transaction confirmations
            false                 // send express mode on destination
        );
    }

    function _sendMessageExpress(uint _destinationChainId, bytes memory _data) internal returns (uint _txId) {
        ChainData memory _chain = CHAINS[_destinationChainId];
        if(_chain.extended) { // non-evm addresses larger than uint256
            _data = abi.encode(_data, _chain.endpointExtended);
        }
        return IMessageV3(MESSAGEv3).sendMessage(
            _chain.endpoint,      // corresponding MessageV3Client contract address on destination chain
            _destinationChainId,  // id of the destination chain
            _data,                // arbitrary data package to send
            _chain.confirmations, // amount of required transaction confirmations
            true                  // send express mode on destination
        );
    }

    function _sendMessageWithFeature(uint _destinationChainId, bytes memory _messageData, uint32 _featureId, bytes memory _featureData) internal returns (uint _txId) {
        require(FEATURE_GATEWAY.isFeatureEnabled(_featureId), "MessageClient: feature not enabled");

        // wrap feature data into message data so it can be signed
        bytes memory _data = abi.encode(_featureId, _featureData, _messageData);

        ChainData memory _chain = CHAINS[_destinationChainId];
        if(_chain.extended) { // non-evm addresses larger than uint256
            _data = abi.encode(_data, _chain.endpointExtended);
        }

        _txId = IMessageV3(MESSAGEv3).sendMessage(
            _chain.endpoint,      // corresponding MessageV3Client contract address on destination chain
            _destinationChainId,  // id of the destination chain
            _data,                // arbitrary data package to send
            _chain.confirmations, // amount of required transaction confirmations
            false                 // send express mode on destination
        );

        // signal we have feature data included with the message data
        emit SendMessageWithFeature(_txId, _destinationChainId, _featureId, _featureData);
    }

    /** OWNER */
    function configureClientExtended(
        address _messageV3, // MessageV3 bridge address
        uint[] calldata _chains, // list of chains to accept as valid destinations
        bytes[] calldata _endpoints, // list of corresponding MessageV3Client addresses on each chain
        uint16[] calldata _confirmations // confirmations required on each chain before processing
    ) external onlyMessageOwner {
        uint _chainsLength = _chains.length;
        for(uint x=0; x < _chainsLength; x++) {
            CHAINS[_chains[x]].confirmations = _confirmations[x];
            CHAINS[_chains[x]].endpointExtended = _endpoints[x];
            CHAINS[_chains[x]].extended = true;
            CHAINS[_chains[x]].endpoint = address(1);
        }

        _configureMessageV3(_messageV3);
    }

    function configureClient(
        address _messageV3, // MessageV3 bridge address
        uint[] calldata _chains, // list of chains to accept as valid destinations
        address[] calldata _endpoints, // list of corresponding MessageV3Client addresses on each chain
        uint16[] calldata _confirmations // confirmations required on each chain before processing
    ) public onlyMessageOwner {
        uint _chainsLength = _chains.length;
        for(uint x=0; x < _chainsLength; x++) {
            CHAINS[_chains[x]].confirmations = _confirmations[x];
            CHAINS[_chains[x]].endpoint = _endpoints[x];
            CHAINS[_chains[x]].extended = false;
        }

        _configureMessageV3(_messageV3);
    }

    function configureFeatureGateway(address _featureGateway) external onlyMessageOwner {
        FEATURE_GATEWAY = IFeatureGateway(_featureGateway);
    }

    function _configureMessageV3(address _messageV3) internal {
        MESSAGEv3 = IMessageV3(_messageV3);
        FEE_TOKEN = IERC20cl(MESSAGEv3.feeToken());

        // approve bridge for source chain fees (limited per transaction with setMaxfee)
        if(address(FEE_TOKEN) != address(0)) {
            FEE_TOKEN.approve(address(MESSAGEv3), type(uint).max);
        }

        // approve bridge for destination gas fees (limited per transaction with setMaxgas)
        if(address(MESSAGEv3.weth()) != address(0)) {
            IERC20cl(MESSAGEv3.weth()).approve(address(MESSAGEv3), type(uint).max);
        }
    }

    function setExsig(address _signer) public onlyMessageOwner {
        MESSAGEv3.setExsig(_signer);
        emit SetExsig(msg.sender, _signer);
    }

    function setMaxgas(uint _maxGas) public onlyMessageOwner {
        MESSAGEv3.setMaxgas(_maxGas);
        emit SetMaxgas(msg.sender, _maxGas);
    }

    function setMaxfee(uint _maxFee) public onlyMessageOwner {
        MESSAGEv3.setMaxfee(_maxFee);
        emit SetMaxfee(msg.sender, _maxFee);
    }

    function recoverToken(address _token, uint _amount) public onlyMessageOwner {
        if(_token == address(0)) {
            // payable(msg.sender).transfer(_amount);
            // @note Zk needs
            (bool success, ) = payable(msg.sender).call{value: _amount}("");
            require(success, "Transfer failed");
        } else {
            IERC20cl(_token).transfer(msg.sender, _amount);
        }
        emit RecoverToken(msg.sender, _token, _amount);
    }

    function isSelf(address _sender, uint _sourceChainId) public view returns (bool) {
        if(_sender == CHAINS[_sourceChainId].endpoint) return true;
        return false;
    }

    function isAuthorized(address _sender, uint _sourceChainId) public view returns (bool) {
        return isSelf(_sender, _sourceChainId);
    }

    receive() external payable {}
    fallback() external payable {}
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
// SPDX-License-Identifier: UNLICENSED
// (c)2024 Atlas (atlas@vialabs.io)
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@vialabs-io/contracts/features/FeatureCCTP.sol";
import "./IUniswapV2.sol";

interface IProtoCCTPClient {
    function processMessage(uint _amount, bytes calldata _data) external;
}

interface IBridgedTokenFiatManager {
    function bridge(address _to, uint _amount, bytes calldata _userData) external;
}

contract ProtoCCTPGateway is FeatureCCTP, Pausable, Ownable {
    using SafeERC20 for IERC20;
    
    address public accountant;
    address public weth;
    address public router;
    address public usdcWethLP;
    address public swapper;

    uint public reimbursements;
    uint public baseWeth;

    mapping(uint => uint)    public pathwayLeafChainToRootChainMapping;
    mapping(uint => address) public pathwayRootContractForLeafChain;
    mapping(uint => address) public pathwayLeafContractForLeafChain;

    mapping(address => bool) public rootContracts;
    mapping(address => bool) public leafContracts;
    
    mapping(uint => bool)    public rootChains;
    mapping(uint => bool)    public leafChains;

    mapping(uint => uint)    public minimums; // @note chainId => amount in USDC. if eth higher minimum if citrea lower. Based on destination chain id, handled on source

    event ProtoCCTPMessageProcessed(address recipient, uint amount, bytes data);
    event ProtoCCTPMessageFailed(address recipient, uint amount, bytes data, string reason);
    event SetBaseWeth(uint baseWeth);
    event SetAccountant(address accountant);
    event SetMappings();
    event SetWeth(uint amount);
    event SetMinimums();
    event Swapper(address swapper);
    event SetRouter(address router);
    event SwapGas(uint wethToSwap, uint minAmountOutInWeth);
    event ResetMappingsForChains(uint[] chainIds);
    event TakeFee(string reason, uint amount);

    modifier onlySwapper() {
        require(msg.sender == swapper, "Sender is not swapper address");
        _;
    }

    constructor() { 
        MESSAGE_OWNER = msg.sender;
        accountant = msg.sender;
        swapper = msg.sender;
    }

    function send(uint _destChainId, address _recipient, uint _amount) external { 
        send(_destChainId, _recipient, _amount, "");
    }

    function send(uint _destChainId, address _recipient, uint _amount, bytes memory _userData) public whenNotPaused { 
        require(_recipient != address(0), "ProtoCCTPGateway: invalid recipient");
        require(_amount > minimums[_destChainId], "ProtoCCTPGateway: amount doesn't meet minimum");

        SafeERC20.safeTransferFrom(IERC20(usdc), msg.sender, address(this), _amount);

        _sendNextHop(_destChainId, _recipient, _amount, _userData);
    }

    // incoming message from a Pathway deployment
    function _processPathwayMessage(uint _amount, bytes calldata _protoData) external whenNotPaused { 
        // @dev this is the security that makes sure only the Pathway contract can call this function
        require(isLeafContract(msg.sender) || isRootContract(msg.sender), "ProtoCCTPGateway: invalid caller");

        // @dev the fees are already taken care of by the Pathway contract, _amount should be the remainder
        // and we are free to send it all along to the next hop
        (uint _destChainId, address _recipient, , bytes memory _userData) = abi.decode(_protoData, (uint, address, uint, bytes));
        
        _sendNextHop(_destChainId, _recipient, _amount, _userData);
    }   

    // incoming message from a CCTP deployment
    // @dev the FeatureCCTP should already restrict this function to only allow itself to call it
    function _processMessageWithFeature(uint, uint, bytes memory _protoData, uint32, bytes memory, bytes memory) internal whenNotPaused override {
        (uint _destChainId, address _recipient, uint _amount, bytes memory _userData) = abi.decode(_protoData, (uint, address, uint, bytes));

        // @dev the fees are taken out inside the _sendNextHop since it depends on if we are using Pathway or FeatureCCTP
        // If we are using the Pathway (.bridge()), the fees are automatically deducted from the USDC amount.
        // If we are using the FeatureCCTP (_sendUSDC), we need to take the fees as THIS contract is charged.

        uint _gasReimbursementUSDC = _takeGasReimbursement();

        _sendNextHop(_destChainId, _recipient, _amount - _gasReimbursementUSDC, _userData);
    }

    function _sendNextHop(uint _destChainId, address _recipient, uint _amount, bytes memory _userData) internal { 
        bytes memory _protoData = abi.encode(_destChainId, _recipient, _amount, _userData);
       
        if(block.chainid == _destChainId) {
            // @note This still triggers when dest is root
            SafeERC20.safeTransfer(IERC20(usdc), _recipient, _amount);

            if(_userData.length > 0) {
                try this._deliver(_recipient, _amount, _userData) returns (bool _success, string memory _reason) {
                    if(_success) {
                        emit ProtoCCTPMessageProcessed(_recipient, _amount, _userData);
                    } else {
                        emit ProtoCCTPMessageFailed(_recipient, _amount, _userData, _reason);
                    }
                } catch { 
                    emit ProtoCCTPMessageFailed(_recipient, _amount, _userData, "fatal failure calling destination contract");
                }
            }
        } else if(isLeafChain(block.chainid)) {
            SafeERC20.safeApprove(IERC20(usdc), getPathwayLeafContractForLeafChain(block.chainid), _amount);

            IBridgedTokenFiatManager(getPathwayLeafContractForLeafChain(block.chainid)).bridge(
                getSelfOn(getRootChainForLeafChain(block.chainid)),
                _amount, 
                _protoData
            );
        } else if(isRootChain(block.chainid)) {
            // we are not on the desired chain and we are a root
            if(pathwayLeafChainToRootChainMapping[_destChainId] == block.chainid) {
                SafeERC20.safeApprove(IERC20(usdc), getPathwayRootContractForLeafChain(_destChainId), _amount);

                IBridgedTokenFiatManager(getPathwayRootContractForLeafChain(_destChainId)).bridge(
                    getSelfOn(_destChainId), // "this" on the leaf chain
                    _amount, 
                    _protoData
                );
            } else {
                // @note _destChainID is the final final dest, NOT the next hop
                if(isRootChain(_destChainId)) {
                    uint _fee = _takeFee(_destChainId);
                    require(_fee < _amount, "ProtoCCTPGateway: Amount sent does not cover fees");

                    // @note Subtract fee from proto data too
                    _protoData = abi.encode(_destChainId, _recipient, _amount - _fee, _userData);

                    // @note this sends a message through MessageClient.sol. Needs to pay.
                    _sendUSDC(
                        _destChainId, 
                        getSelfOn(_destChainId), 
                        _amount - _fee, // @dev take out fee, leave it in the contract to pay for message fees
                        _protoData
                    );
                } else {
                    // @note Going to a leaf, but we want the root just before that leaf
                    uint _targetChainId = getRootChainForLeafChain(_destChainId);

                    uint _fee = _takeFee(_targetChainId);
                    require(_fee < _amount, "ProtoCCTPGateway: Amount sent does not cover fees");

                    // @note Subtract fee from proto data too
                    _protoData = abi.encode(_destChainId, _recipient, _amount - _fee, _userData);

                    _sendUSDC(
                        _targetChainId, 
                        getSelfOn(_targetChainId), 
                        _amount - _fee, // @dev take out fee, leave it in the contract to pay for message fees
                        _protoData
                    );
                }
            }
        } else {
            SafeERC20.safeTransfer(IERC20(usdc), _recipient, _amount);
        }
    }

    function _deliver(address _finalRecipient, uint _amount, bytes memory _userData) external returns (bool, string memory _reason) {
        require(msg.sender == address(this), "ProtoCCTPGateway: only internal calls allowed");

        try IProtoCCTPClient(_finalRecipient).processMessage(_amount, _userData) {
            return (true, "");
        } catch Error (string memory reason) {
            return (false, reason);
        } catch {
            return (false, "fatal failure");
        }
    }

    function setMinimums( 
        uint[] calldata _chainIds, 
        uint[] calldata _amounts
    ) external onlyOwner { 
        uint256 length = _chainIds.length;

        require(length <= 64, "ProtoCCTPGateway: Too many chains provided");
        require(length == _amounts.length, "ProtoCCTPGateway: invalid minimums");

        // @note 64 at most ever
        for(uint i = 0; i < length; i++) {
            minimums[_chainIds[i]] = _amounts[i];
        }

        emit SetMinimums();
    }

    function setMappings( 
        address _usdc,
        uint[] calldata _leafChainIds, 
        uint[] calldata _rootChainIds, 
        address[] calldata _rootContractsOnRoots, 
        address[] calldata _leafContractsOnLeafs,
        uint[] calldata _allRootChains
    ) external onlyOwner { 
        require(_leafChainIds.length <= 64, "ProtoCCTPGateway: Too many chains provided");
        require(_rootChainIds.length <= 64, "ProtoCCTPGateway: Too many chains provided");
        require(_allRootChains.length <= 64, "ProtoCCTPGateway: Too many chains provided");
        require(_leafChainIds.length == _rootContractsOnRoots.length, "ProtoCCTPGateway: invalid mappings");
        require(_leafChainIds.length == _leafContractsOnLeafs.length, "ProtoCCTPGateway: invalid mappings");
        require(_leafChainIds.length == _rootChainIds.length, "ProtoCCTPGateway: invalid mappings");
        require(_usdc != address(0), "ProtoCCTPGateway: invalid USDC address");

        // @note Taken from feature contract, but immutable inside that contract
        usdc = _usdc;

        // @note 64 at most ever
        for(uint i = 0; i < _leafChainIds.length; i++) {
            pathwayRootContractForLeafChain[_leafChainIds[i]] = _rootContractsOnRoots[i];
            pathwayLeafContractForLeafChain[_leafChainIds[i]] = _leafContractsOnLeafs[i];

            rootContracts[_rootContractsOnRoots[i]] = true;
            leafContracts[_leafContractsOnLeafs[i]] = true;
            pathwayLeafChainToRootChainMapping[_leafChainIds[i]] = _rootChainIds[i];
        }

        for(uint i = 0; i < _leafChainIds.length; i++) {
            leafChains[_leafChainIds[i]] = true;
        }

        for(uint i = 0; i < _rootChainIds.length; i++) {
            rootChains[_rootChainIds[i]] = true;
        }

        for(uint i = 0; i < _allRootChains.length; i++) {
            rootChains[_allRootChains[i]] = true;
        }

        emit SetMappings();
    }

    function resetMappingsForChains(uint[] calldata _chainIds) external onlyOwner {
        uint256 length = _chainIds.length;
        require(length <= 64, "ProtoCCTPGateway: Too many chains provided");

        // @note 64 at most ever
        for(uint c=0; c < length; c++) {
            uint chainId = _chainIds[c];

            address leafContract = pathwayLeafContractForLeafChain[chainId];
            address rootContract = pathwayRootContractForLeafChain[chainId];
            uint rootChainId = pathwayLeafChainToRootChainMapping[chainId];

            // Delete leaf contract mappings
            delete leafContracts[leafContract];
            delete pathwayLeafContractForLeafChain[chainId];
            delete leafChains[chainId];

            // Delete root contract mappings
            delete rootContracts[rootContract];
            delete pathwayRootContractForLeafChain[chainId];

            // Delete root chain mappings if applicable
            if(rootChainId != 0) {
                delete pathwayLeafChainToRootChainMapping[chainId];
                delete rootChains[rootChainId];
            }
        }

        emit ResetMappingsForChains(_chainIds);
    }

    function setAccountant(address _accountant) external onlyOwner { 
        require(_accountant != address(0), "ProtoCCTPGateway: invalid accountant");

        accountant = _accountant;
        emit SetAccountant(_accountant);
    }

    function setRouter(address _router) external onlyOwner {
        router = _router;

        weth = MESSAGEv3.weth();
        // @note This needs the ability to be set back to address(0) to disable the feature
        if (_router == address(0)) {
            usdcWethLP = address(0);
        }
        else {
            address _factory = IUniswapV2Router02(_router).factory();
            usdcWethLP = IUniswapV2Factory(_factory).getPair(weth, usdc);
        }
        
        emit SetRouter(router);
    }

    function setSwapper(address swapperAddr) external onlyOwner { 
        require(swapperAddr != address(0), "ProtoCCTPGateway: invalid swapper");

        swapper = swapperAddr;
        emit Swapper(swapper);
    }

    function swapGas(uint256 _minAmountOutInWeth) external onlySwapper { 
        require(reimbursements > 0, "ProtoCCTPGateway: nothing to swap");
        require(router != address(0), "ProtoCCTPGateway: feature is disabled");

        address[] memory _path;
        _path = new address[](2);
        _path[0] = address(usdc);
        _path[1] = address(weth);

        SafeERC20.safeApprove(IERC20(usdc), router, reimbursements);

        // @note Reset the count
        uint256 _amountIn = reimbursements;
        reimbursements = 0;

        IUniswapV2Router02(router).swapExactTokensForTokens(
            _amountIn, // @note Amount to send in
            _minAmountOutInWeth, // @note amount OUT min when giving in amountIn
            _path, // @note path to take
            address(this), // @note to
            block.timestamp // @note deadline
        );

        baseWeth = IERC20(weth).balanceOf(address(this));
        emit SwapGas(_amountIn, _minAmountOutInWeth);
    }

    function _takeFee(uint _destinationChain) internal view returns (uint) {
        address feeToken = MESSAGEv3.feeToken();
        require(
            feeToken == usdc,
            "Contract token doesn't match current message fee token"
        );

        uint256 feeAmount = MESSAGEv3.getSourceFee(_destinationChain, false);

        return feeAmount;
    }

    function _takeGasReimbursement() internal returns (uint) { 
        uint256 _wethToCollectBack = 0;
        uint256 _computedReimbursementInUSD = 0;
        if (router != address(0) && IERC20(weth).balanceOf(address(this)) < baseWeth) {
            _wethToCollectBack = baseWeth - IERC20(weth).balanceOf(address(this));

            baseWeth = baseWeth - _wethToCollectBack;
        }

        // @note DOES NOT perform the swap
        if (_wethToCollectBack > 0) {
            _computedReimbursementInUSD = _getAmountIn(_wethToCollectBack);
            require(_computedReimbursementInUSD < minimums[block.chainid], "Computed reimbursement is over the maximum");

            reimbursements += _computedReimbursementInUSD;
        }
        
        emit TakeFee("Takefee", _computedReimbursementInUSD);

        return _computedReimbursementInUSD;
    }

    // @note MUST use this chain's weth decimals
    function setWeth(uint256 customBaseAmount) external onlyOwner {
        weth = MESSAGEv3.weth();
        baseWeth = customBaseAmount > 0
            ? customBaseAmount
            : IERC20(weth).balanceOf(address(this));

        emit SetWeth(customBaseAmount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _getAmountIn(uint256 _amountOut) public view returns (uint256) {
        (uint256 _res0, uint256 _res1, ) = IUniswapV2Pair(usdcWethLP).getReserves();
        uint _stableIndex = usdc < weth ? 0 : 1; // @dev uniswap always sorts pairs by address for their indexes
        uint256 _usdReserve = _stableIndex == 1 ? _res1 : _res0;
        uint256 _wethReserve = _stableIndex == 1 ? _res0 : _res1;
        uint256 _amountInMin = IUniswapV2Router02(router).getAmountIn(_amountOut, _usdReserve, _wethReserve);
        return _amountInMin;
    }

    function isLeafContract(address _contract) public view returns (bool) {
        return leafContracts[_contract];
    }

    function isRootContract(address _contract) public view returns (bool) {
        return rootContracts[_contract];
    }

    function isLeafChain(uint _chainId) public view returns (bool) {
        return leafChains[_chainId];
    }

    function isRootChain(uint _chainId) public view returns (bool) {
        return rootChains[_chainId];
    }

    function getPathwayLeafContractForLeafChain(uint _chainId) public view returns (address) {
        return pathwayLeafContractForLeafChain[_chainId];
    }

    function getPathwayRootContractForLeafChain(uint _chainId) public view returns (address) {
        return pathwayRootContractForLeafChain[_chainId];
    }

    function getRootChainForLeafChain(uint _chainId) public view returns (uint) {
        return pathwayLeafChainToRootChainMapping[_chainId];
    }   

    function getSelfOn(uint _chainId) public view returns (address) {
        return CHAINS[_chainId].endpoint;
    }
}