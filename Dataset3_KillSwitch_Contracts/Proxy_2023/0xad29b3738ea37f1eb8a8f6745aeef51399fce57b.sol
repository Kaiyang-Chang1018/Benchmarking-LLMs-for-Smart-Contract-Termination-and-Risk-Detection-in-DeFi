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
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC2612.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Permit.sol";

interface IERC2612 is IERC20Permit {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/**
 * @title Guardable
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (a guardian) that can be granted exclusive access to
 * specific functions.
 *
 * This module is essentially a renamed version of the OpenZeppelin Ownable contract.
 * The main difference is in terminology:
 * - 'owner' is renamed to 'guardian'
 * - 'ownership' concepts are renamed to 'watch' or 'guard'
 *
 * By default, the guardian account will be the one that deploys the contract. This
 * can later be changed with {transferWatch}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyGuardian`, which can be applied to your functions to restrict their use to
 * the guardian.
 */
abstract contract Guardable {
    address private _guardian;

    event WatchTransferred(address indexed previousGuardian, address indexed newGuardian);

    /**
     * @dev Initializes the contract setting the deployer as the initial guardian.
     */
    constructor() {
        _transferWatch(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the guardian.
     */
    modifier onlyGuardian() {
        _checkGuardian();
        _;
    }

    /**
     * @dev Returns the address of the current guardian.
     */
    function guardian() public view virtual returns (address) {
        return _guardian;
    }

    /**
     * @dev Throws if the sender is not the guardian.
     */
    function _checkGuardian() internal view virtual {
        require(guardian() == msg.sender, "Guardable: caller is not the guardian");
    }

    /**
     * @dev Leaves the contract without guardian. It will not be possible to call
     * `onlyGuardian` functions anymore. Can only be called by the current guardian.
     *
     * NOTE: Renouncing guardianship will leave the contract without a guardian,
     * thereby removing any functionality that is only available to the guardian.
     */
    function releaseGuard() public virtual onlyGuardian {
        _transferWatch(address(0));
    }

    /**
     * @dev Transfers guardianship of the contract to a new account (`newGuardian`).
     * Can only be called by the current guardian.
     */
    function transferWatch(address newGuardian) public virtual onlyGuardian {
        require(newGuardian != address(0), "Guardable: new guardian is the zero address");
        _transferWatch(newGuardian);
    }

    /**
     * @dev Transfers guardianship of the contract to a new account (`newGuardian`).
     * Internal function without access restriction.
     */
    function _transferWatch(address newGuardian) internal virtual {
        address oldGuardian = _guardian;
        _guardian = newGuardian;
        emit WatchTransferred(oldGuardian, newGuardian);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./BaseMath.sol";

/* Contains global system constants and common functions. */
contract Base is BaseMath {
    uint constant internal SECONDS_IN_ONE_MINUTE = 60;

    /*
     * Half-life of 12h. 12h = 720 min
     * (1/2) = d^720 => d = (1/2)^(1/720)
     */
    uint constant internal MINUTE_DECAY_FACTOR = 999037758833783000;

    /*
    * BETA: 18 digit decimal. Parameter by which to divide the redeemed fraction, in order to calc the new base rate from a redemption.
    * Corresponds to (1 / ALPHA) in the white paper.
    */
    uint constant internal BETA = 2;

    uint constant public _100pct = 1000000000000000000; // 1e18 == 100%

    // Min net debt remains a system global due to its rationale for keeping SortedPositions relatively small
    uint constant public MIN_NET_DEBT = 1800e18;

    uint constant internal PERCENT_DIVISOR = 200; // dividing by 200 yields 0.5%

    // Gas compensation is not configurable per collateral type, as this is
    // more-so a chain specific consideration rather than collateral specific
    uint constant public GAS_COMPENSATION = 200e18;

    // A dynamic fee, which kicks in and acts as a floor if the custom min fee % attached to a collateral instance is too low.
    uint constant public DYNAMIC_BORROWING_FEE_FLOOR = DECIMAL_PRECISION / 1000 * 5; // 0.5%
    uint constant public DYNAMIC_REDEMPTION_FEE_FLOOR = DECIMAL_PRECISION / 1000 * 5; // 0.5%

    address internal positionControllerAddress;
    address internal gasPoolAddress;

    // Return the amount of Collateral to be drawn from a position's collateral and sent as gas compensation.
    function _getCollGasCompensation(uint _entireColl) internal pure returns (uint) {
        return _entireColl / PERCENT_DIVISOR;
    }

    function _requireUserAcceptsFee(uint _fee, uint _amount, uint _maxFeePercentage) internal pure {
        uint feePercentage = (_fee * DECIMAL_PRECISION) / _amount;
        require(feePercentage <= _maxFeePercentage, "Fee exceeded");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract BaseMath {
    uint constant public DECIMAL_PRECISION = 1e18;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

library StableMath {
    uint internal constant DECIMAL_PRECISION = 1e18;

    /* Precision for Nominal ICR (independent of price). Rationale for the value:
     *
     * - Making it “too high” could lead to overflows.
     * - Making it “too low” could lead to an ICR equal to zero, due to truncation from Solidity floor division. 
     *
     * This value of 1e20 is chosen for safety: the NICR will only overflow for numerator > ~1e39 ETH,
     * and will only truncate to 0 if the denominator is at least 1e20 times greater than the numerator.
     *
     */
    uint internal constant NICR_PRECISION = 1e20;

    function _min(uint _a, uint _b) internal pure returns (uint) {
        return (_a < _b) ? _a : _b;
    }

    function _max(uint _a, uint _b) internal pure returns (uint) {
        return (_a >= _b) ? _a : _b;
    }

    /* 
    * Multiply two decimal numbers and use normal rounding rules:
    * -round product up if 19'th mantissa digit >= 5
    * -round product down if 19'th mantissa digit < 5
    *
    * Used only inside the exponentiation, _decPow().
    */
    function decMul(uint x, uint y) internal pure returns (uint decProd) {
        uint prod_xy = x * y;
        decProd = (prod_xy + (DECIMAL_PRECISION / 2)) / DECIMAL_PRECISION;
    }

    /* 
    * _decPow: Exponentiation function for 18-digit decimal base, and integer exponent n.
    * 
    * Uses the efficient "exponentiation by squaring" algorithm. O(log(n)) complexity. 
    * 
    * Called by PositionManager._calcDecayedBaseRate
    *
    * The exponent is capped to avoid reverting due to overflow. The cap 525600000 equals
    * "minutes in 1000 years": 60 * 24 * 365 * 1000
    * 
    * If a period of > 1000 years is ever used as an exponent in either of the above functions, the result will be
    * negligibly different from just passing the cap, since: 
    *
    * In function 1), the decayed base rate will be 0 for 1000 years or > 1000 years
    * In function 2), the difference in tokens issued at 1000 years and any time > 1000 years, will be negligible
    */
    function _decPow(uint _base, uint _minutes) internal pure returns (uint) {
       
        if (_minutes > 525600000) {_minutes = 525600000;}  // cap to avoid overflow
    
        if (_minutes == 0) {return DECIMAL_PRECISION;}

        uint y = DECIMAL_PRECISION;
        uint x = _base;
        uint n = _minutes;

        // Exponentiation-by-squaring
        while (n > 1) {
            if (n % 2 == 0) {
                x = decMul(x, x);
                n = n / 2;
            } else { // if (n % 2 != 0)
                y = decMul(x, y);
                x = decMul(x, x);
                n = (n - 1) / 2;
            }
        }

        return decMul(x, y);
  }

    function _getAbsoluteDifference(uint _a, uint _b) internal pure returns (uint) {
        return (_a >= _b) ? _a - _b : _b - _a;
    }

    function _adjustDecimals(uint _val, uint8 _collDecimals) internal pure returns (uint) {
        if (_collDecimals < 18) {
            return _val * (10 ** (18 - _collDecimals));
        } else if (_collDecimals > 18) {
            // Assuming _collDecimals won't exceed 25, this should be safe from overflow.
            return _val / (10 ** (_collDecimals - 18));
        } else {
            return _val;
        }
    }

    function _computeNominalCR(uint _coll, uint _debt, uint8 _collDecimals) internal pure returns (uint) {
        if (_debt > 0) {
            _coll = _adjustDecimals(_coll, _collDecimals);
            return (_coll * NICR_PRECISION) / _debt;
        }
        // Return the maximal value for uint256 if the Position has a debt of 0. Represents "infinite" CR.
        else { // if (_debt == 0)
            return type(uint256).max;
        }
    }

    function _computeCR(uint _coll, uint _debt, uint _price, uint8 _collDecimals) internal pure returns (uint) {
        // Check for zero debt to avoid division by zero
        if (_debt == 0) {
            return type(uint256).max; // Infinite CR since there's no debt.
        }

        _coll = _adjustDecimals(_coll, _collDecimals);
        uint newCollRatio = (_coll * _price) / _debt;
        return newCollRatio;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./IPool.sol";
import "./ICanReceiveCollateral.sol";

/// @title IActivePool Interface
/// @notice Interface for the ActivePool contract which manages the main collateral pool
interface IActivePool is IPool, ICanReceiveCollateral {
    /// @notice Emitted when the stable debt in the ActivePool is updated
    /// @param _STABLEDebt The new total stable debt amount
    event ActivePoolStableDebtUpdated(uint _STABLEDebt);

    /// @notice Emitted when the collateral balance in the ActivePool is updated
    /// @param _Collateral The new total collateral amount
    event ActivePoolCollateralBalanceUpdated(uint _Collateral);

    /// @notice Sends collateral from the ActivePool to a specified account
    /// @param _account The address of the account to receive the collateral
    /// @param _amount The amount of collateral to send
    function sendCollateral(address _account, uint _amount) external;

    /// @notice Sets the addresses of connected contracts and components
    /// @param _positionControllerAddress Address of the PositionController contract
    /// @param _positionManagerAddress Address of the PositionManager contract
    /// @param _backstopPoolAddress Address of the BackstopPool contract
    /// @param _defaultPoolAddress Address of the DefaultPool contract
    /// @param _collateralAssetAddress Address of the collateral asset token
    function setAddresses(
        address _positionControllerAddress,
        address _positionManagerAddress,
        address _backstopPoolAddress,
        address _defaultPoolAddress,
        address _collateralAssetAddress
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IBackstopPool Interface
/// @notice Interface for the BackstopPool contract which manages deposits and collateral gains
interface IBackstopPool {
    /// @notice Struct to represent collateral gains for a specific asset
    struct CollateralGain {
        address asset;
        uint gains;
    }

    /// @notice Emitted when the collateral balance of the BackstopPool is updated
    /// @param asset The address of the collateral asset
    /// @param _newBalance The new balance of the collateral
    event BackstopPoolCollateralBalanceUpdated(address asset, uint _newBalance);

    /// @notice Emitted when the stable token balance of the BackstopPool is updated
    /// @param _newBalance The new balance of stable tokens
    event BackstopPoolStableBalanceUpdated(uint _newBalance);

    /// @notice Emitted when the product P is updated
    /// @param _P The new value of P
    event P_Updated(uint _P);

    /// @notice Emitted when the sum S is updated for a specific collateral asset
    /// @param collateralAsset The address of the collateral asset
    /// @param _S The new value of S
    /// @param _epoch The current epoch
    /// @param _scale The current scale
    event S_Updated(address collateralAsset, uint _S, uint128 _epoch, uint128 _scale);

    /// @notice Emitted when the sum G is updated
    /// @param _G The new value of G
    /// @param _epoch The current epoch
    /// @param _scale The current scale
    event G_Updated(uint _G, uint128 _epoch, uint128 _scale);

    /// @notice Emitted when the current epoch is updated
    /// @param _currentEpoch The new current epoch
    event EpochUpdated(uint128 _currentEpoch);

    /// @notice Emitted when the current scale is updated
    /// @param _currentScale The new current scale
    event ScaleUpdated(uint128 _currentScale);

    /// @notice Emitted when a depositor's snapshot is updated
    /// @param _depositor The address of the depositor
    /// @param _asset The address of the asset
    /// @param _P The current value of P
    /// @param _S The current value of S
    /// @param _G The current value of G
    event DepositSnapshotUpdated(address indexed _depositor, address indexed _asset, uint _P, uint _S, uint _G);

    /// @notice Emitted when a user's deposit amount changes
    /// @param _depositor The address of the depositor
    /// @param _newDeposit The new deposit amount
    event UserDepositChanged(address indexed _depositor, uint _newDeposit);

    /// @notice Emitted when collateral gains are withdrawn
    /// @param _depositor The address of the depositor
    /// @param gains An array of CollateralGain structs representing the gains
    /// @param _stableLoss The amount of stable tokens lost
    event CollateralGainsWithdrawn(address indexed _depositor, IBackstopPool.CollateralGain[] gains, uint _stableLoss);

    /// @notice Emitted when collateral is sent to an address
    /// @param asset The address of the collateral asset
    /// @param _to The recipient address
    /// @param _amount The amount of collateral sent
    event CollateralSent(address indexed asset, address indexed _to, uint _amount);

    /// @notice Emitted when fee tokens are paid to a depositor
    /// @param _depositor The address of the depositor
    /// @param _feeToken The amount of fee tokens paid
    event FeeTokenPaidToDepositor(address indexed _depositor, uint _feeToken);

    /// @notice Sets the addresses of connected contracts
    /// @param _collateralController The address of the CollateralController contract
    /// @param _stableTokenAddress The address of the StableToken contract
    /// @param _positionController The address of the PositionController contract
    /// @param _incentivesIssuance The address of the IncentivesIssuance contract
    function setAddresses(address _collateralController, address _stableTokenAddress, address _positionController, address _incentivesIssuance) external;

    /// @notice Allows a user to provide stable tokens to the BackstopPool
    /// @param _amount The amount of stable tokens to provide
    function provideToBP(uint _amount) external;

    /// @notice Allows a user to withdraw stable tokens from the BackstopPool
    /// @param _amount The amount of stable tokens to withdraw
    function withdrawFromBP(uint _amount) external;

    /// @notice Allows a user to withdraw collateral gains to their position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _upperHint The upper hint for position insertion
    /// @param _lowerHint The lower hint for position insertion
    function withdrawCollateralGainToPosition(address asset, uint8 version, address _upperHint, address _lowerHint) external;

    /// @notice Offsets debt with collateral
    /// @param collateralAsset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _debt The amount of debt to offset
    /// @param _coll The amount of collateral to add
    function offset(address collateralAsset, uint8 version, uint _debt, uint _coll) external;

    /// @notice Gets the total amount of a specific collateral in the BackstopPool
    /// @param asset The address of the collateral asset
    /// @return The amount of collateral
    function getCollateral(address asset) external view returns (uint);

    /// @notice Gets the total amount of stable token deposits in the BackstopPool
    /// @return The total amount of stable token deposits
    function getTotalStableDeposits() external view returns (uint);

    /// @notice Gets the collateral gains for a depositor
    /// @param _depositor The address of the depositor
    /// @return An array of CollateralGain structs representing the gains
    function getDepositorCollateralGains(address _depositor) external view returns (IBackstopPool.CollateralGain[] memory);

    /// @notice Gets the collateral gain for a specific asset and depositor
    /// @param asset The address of the collateral asset
    /// @param _depositor The address of the depositor
    /// @return The amount of collateral gain
    function getDepositorCollateralGain(address asset, address _depositor) external view returns (uint);

    /// @notice Gets the compounded stable deposit for a depositor
    /// @param _depositor The address of the depositor
    /// @return The compounded stable deposit amount
    function getCompoundedStableDeposit(address _depositor) external view returns (uint);

    /// @notice Gets the sum S for a specific asset, epoch, and scale
    /// @param asset The address of the collateral asset
    /// @param epoch The epoch number
    /// @param scale The scale number
    /// @return The sum S
    function getEpochToScaleToSum(address asset, uint128 epoch, uint128 scale) external view returns(uint);

    /// @notice Gets the fee token gain for a depositor
    /// @param _depositor The address of the depositor
    /// @return The amount of fee token gain
    function getDepositorFeeTokenGain(address _depositor) external view returns (uint);

    /// @notice Gets the sum S from the deposit snapshot for a specific user and asset
    /// @param user The address of the user
    /// @param asset The address of the asset
    /// @return The sum S from the deposit snapshot
    function getDepositSnapshotToAssetToSum(address user, address asset) external view returns(uint);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

// Common interface for the contracts which need internal collateral counters to be updated.
interface ICanReceiveCollateral {
    function receiveCollateral(address asset, uint amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./IActivePool.sol";
import "./ICollateralSurplusPool.sol";
import "./IDefaultPool.sol";
import "./IPriceFeed.sol";
import "./ISortedPositions.sol";
import "./IPositionManager.sol";

/// @title ICollateralController Interface
/// @notice Interface for the CollateralController contract which manages multiple collateral types and their settings
interface ICollateralController {
    /// @notice Emitted when the redemption cooldown requirement is changed
    /// @param newRedemptionCooldownRequirement The new cooldown period for redemptions
    event RedemptionCooldownRequirementChanged(uint newRedemptionCooldownRequirement);

    /// @notice Gets the address of the guardian
    /// @return The address of the guardian
    function getGuardian() external view returns (address);

    /// @notice Structure to hold redemption settings for a collateral type
    struct RedemptionSettings {
        uint256 redemptionCooldownPeriod;
        uint256 redemptionGracePeriod;
        uint256 maxRedemptionPoints;
        uint256 availableRedemptionPoints;
        uint256 redemptionRegenerationRate;
        uint256 lastRedemptionRegenerationTimestamp;
    }

    /// @notice Structure to hold loan settings for a collateral type
    struct LoanSettings {
        uint256 loanCooldownPeriod;
        uint256 loanGracePeriod;
        uint256 maxLoanPoints;
        uint256 availableLoanPoints;
        uint256 loanRegenerationRate;
        uint256 lastLoanRegenerationTimestamp;
    }

    /// @notice Enum to represent the base rate type
    enum BaseRateType {
        Global,
        Local
    }

    /// @notice Structure to hold fee settings for a collateral type
    struct FeeSettings {
        uint256 redemptionsTimeoutFeePct;
        uint256 maxRedemptionsFeePct;
        uint256 minRedemptionsFeePct;
        uint256 minBorrowingFeePct;
        uint256 maxBorrowingFeePct;
        BaseRateType baseRateType;
    }

    /// @notice Structure to hold all settings for a collateral type
    struct Settings {
        uint256 debtCap;
        uint256 decommissionedOn;
        uint256 MCR;
        uint256 CCR;
        RedemptionSettings redemptionSettings;
        LoanSettings loanSettings;
        FeeSettings feeSettings;
    }

    /// @notice Structure to represent a collateral type and its associated contracts
    struct Collateral {
        uint8 version;
        IActivePool activePool;
        ICollateralSurplusPool collateralSurplusPool;
        IDefaultPool defaultPool;
        IERC20Metadata asset;
        IPriceFeed priceFeed;
        ISortedPositions sortedPositions;
        IPositionManager positionManager;
        bool sunset;
    }

    /// @notice Structure to represent a collateral type with its settings and associated contracts
    struct CollateralWithSettings {
        string name;
        string symbol;
        uint8 decimals;
        uint8 version;
        Settings settings;
        IActivePool activePool;
        ICollateralSurplusPool collateralSurplusPool;
        IDefaultPool defaultPool;
        IERC20Metadata asset;
        IPriceFeed priceFeed;
        ISortedPositions sortedPositions;
        IPositionManager positionManager;
        bool sunset;
        uint256 availableRedemptionPoints;
        uint256 availableLoanPoints;
    }

    /// @notice Adds support for a new collateral type
    /// @param collateralAddress Address of the collateral token
    /// @param positionManagerAddress Address of the PositionManager contract
    /// @param sortedPositionsAddress Address of the SortedPositions contract
    /// @param activePoolAddress Address of the ActivePool contract
    /// @param priceFeedAddress Address of the PriceFeed contract
    /// @param defaultPoolAddress Address of the DefaultPool contract
    /// @param collateralSurplusPoolAddress Address of the CollateralSurplusPool contract
    function supportCollateral(
        address collateralAddress,
        address positionManagerAddress,
        address sortedPositionsAddress,
        address activePoolAddress,
        address priceFeedAddress,
        address defaultPoolAddress,
        address collateralSurplusPoolAddress
    ) external;

    /// @notice Gets all active collateral types
    /// @return An array of Collateral structs representing active collateral types
    function getActiveCollaterals() external view returns (Collateral[] memory);

    /// @notice Gets the unique addresses of all active collateral tokens
    /// @return An array of addresses representing active collateral token addresses
    function getUniqueActiveCollateralAddresses() external view returns (address[] memory);

    /// @notice Gets the debt cap for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return debtCap The debt cap for the specified collateral type
    function getDebtCap(address asset, uint8 version) external view returns (uint debtCap);

    /// @notice Gets the Critical Collateral Ratio (CCR) for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The CCR for the specified collateral type
    function getCCR(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the Minimum Collateral Ratio (MCR) for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The MCR for the specified collateral type
    function getMCR(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the minimum borrowing fee percentage for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The minimum borrowing fee percentage for the specified collateral type
    function getMinBorrowingFeePct(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the maximum borrowing fee percentage for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The maximum borrowing fee percentage for the specified collateral type
    function getMaxBorrowingFeePct(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the minimum redemption fee percentage for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The minimum redemption fee percentage for the specified collateral type
    function getMinRedemptionsFeePct(address asset, uint8 version) external view returns (uint);

    /// @notice Requires that the commissioning period has passed for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    function requireAfterCommissioningPeriod(address asset, uint8 version) external view;

    /// @notice Requires that a specific collateral type is active
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    function requireIsActive(address asset, uint8 version) external view;

    /// @notice Gets the Collateral struct for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return A Collateral struct representing the specified collateral type
    function getCollateralInstance(address asset, uint8 version) external view returns (ICollateralController.Collateral memory);

    /// @notice Gets the Settings struct for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return A Settings struct representing the settings for the specified collateral type
    function getSettings(address asset, uint8 version) external view returns (ICollateralController.Settings memory);

    /// @notice Gets the total collateral amount for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return assetColl The total collateral amount for the specified collateral type
    function getAssetColl(address asset, uint8 version) external view returns (uint assetColl);

    /// @notice Gets the total debt amount for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return assetDebt The total debt amount for the specified collateral type
    function getAssetDebt(address asset, uint8 version) external view returns (uint assetDebt);

    /// @notice Gets the version of a specific PositionManager
    /// @param positionManager Address of the PositionManager contract
    /// @return version The version of the specified PositionManager
    function getVersion(address positionManager) external view returns (uint8 version);

    /// @notice Checks if a specific collateral type is in Recovery Mode
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param price Current price of the collateral
    /// @return A boolean indicating whether the collateral type is in Recovery Mode
    function checkRecoveryMode(address asset, uint8 version, uint price) external returns (bool);

    /// @notice Requires that there are no undercollateralized positions across all collateral types
    function requireNoUnderCollateralizedPositions() external;

    /// @notice Checks if a given address is a valid PositionManager
    /// @param positionManager Address to check
    /// @return A boolean indicating whether the address is a valid PositionManager
    function validPositionManager(address positionManager) external view returns (bool);

    /// @notice Checks if a specific collateral type is decommissioned
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return A boolean indicating whether the collateral type is decommissioned
    function isDecommissioned(address asset, uint8 version) external view returns (bool);

    /// @notice Checks if a specific PositionManager is decommissioned and its sunset period has elapsed
    /// @param pm Address of the PositionManager
    /// @param collateral Address of the collateral token
    /// @return A boolean indicating whether the PositionManager is decommissioned and its sunset period has elapsed
    function decommissionedAndSunsetPositionManager(address pm, address collateral) external view returns (bool);

    /// @notice Gets the base rate type (Global or Local)
    /// @return The base rate type
    function getBaseRateType() external view returns (BaseRateType);

    /// @notice Gets the timestamp of the last fee operation
    /// @return The timestamp of the last fee operation
    function getLastFeeOperationTime() external view returns (uint);

    /// @notice Gets the current base rate
    /// @return The current base rate
    function getBaseRate() external view returns (uint);

    /// @notice Decays the base rate from borrowing
    function decayBaseRateFromBorrowing() external;

    /// @notice Updates the timestamp of the last fee operation
    function updateLastFeeOpTime() external;

    /// @notice Calculates the number of minutes passed since the last fee operation
    /// @return The number of minutes passed since the last fee operation
    function minutesPassedSinceLastFeeOp() external view returns (uint);

    /// @notice Calculates the decayed base rate
    /// @return The decayed base rate
    function calcDecayedBaseRate() external view returns (uint);

    /// @notice Updates the base rate from redemption
    /// @param _CollateralDrawn Amount of collateral drawn
    /// @param _price Current price of the collateral
    /// @param _totalStableSupply Total supply of stable tokens
    /// @return The updated base rate
    function updateBaseRateFromRedemption(uint _CollateralDrawn, uint _price, uint _totalStableSupply) external returns (uint);

    /// @notice Regenerates and consumes redemption points
    /// @param amount Amount of redemption points to consume
    /// @return utilizationPCT The utilization percentage after consumption
    /// @return loadIncrease The increase in load after consumption
    function regenerateAndConsumeRedemptionPoints(uint amount) external returns (uint utilizationPCT, uint loadIncrease);

    /// @notice Gets the redemption cooldown requirement for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return escrowDuration The duration of the escrow period
    /// @return gracePeriod The grace period for redemptions
    /// @return redemptionsTimeoutFeePct The fee percentage for redemption timeouts
    function getRedemptionCooldownRequirement(address asset, uint8 version) external returns (uint escrowDuration,uint gracePeriod,uint redemptionsTimeoutFeePct);

    /// @notice Calculates the redemption points at a specific timestamp for a collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param targetTimestamp The timestamp to calculate the redemption points for
    /// @return workingRedemptionPoints The redemption points at the specified timestamp
    function redemptionPointsAt(address asset, uint8 version, uint targetTimestamp) external view returns (uint workingRedemptionPoints);

    /// @notice Regenerates and consumes loan points
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param amount Amount of loan points to consume
    /// @return utilizationPCT The utilization percentage after consumption
    /// @return loadIncrease The increase in load after consumption
    function regenerateAndConsumeLoanPoints(address asset, uint8 version, uint amount) external returns (uint utilizationPCT, uint loadIncrease);

    /// @notice Gets the loan cooldown requirement for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return escrowDuration The duration of the escrow period
    /// @return gracePeriod The grace period for loans
    function getLoanCooldownRequirement(address asset, uint8 version) external view returns (uint escrowDuration, uint gracePeriod);

    /// @notice Calculates the loan points at a specific timestamp for a collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param targetTimestamp The timestamp to calculate the loan points for
    /// @return workingLoanPoints The loan points at the specified timestamp
    function loanPointsAt(address asset, uint8 version, uint targetTimestamp) external view returns (uint workingLoanPoints);

    /// @notice Calculates the borrowing rate for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param baseRate The base rate to use in the calculation
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The calculated borrowing rate
    function calcBorrowingRate(address asset, uint baseRate, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Calculates the redemption rate for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param baseRate The base rate to use in the calculation
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The calculated redemption rate
    function calcRedemptionRate(address asset, uint baseRate, uint suggestedAdditiveFeePCT) external view returns (uint);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./ICanReceiveCollateral.sol";

/// @title ICollateralSurplusPool Interface
/// @notice Interface for the CollateralSurplusPool contract which manages surplus collateral
interface ICollateralSurplusPool is ICanReceiveCollateral {
    /// @notice Emitted when a user's collateral balance is updated
    /// @param _account The address of the account
    /// @param _newBalance The new balance of the account
    event CollBalanceUpdated(address indexed _account, uint _newBalance);

    /// @notice Emitted when collateral is sent to an account
    /// @param _to The address receiving the collateral
    /// @param _amount The amount of collateral sent
    event CollateralSent(address _to, uint _amount);

    /// @notice Sets the addresses of connected contracts
    /// @param _positionControllerAddress Address of the PositionController contract
    /// @param _positionManagerAddress Address of the PositionManager contract
    /// @param _activePoolAddress Address of the ActivePool contract
    /// @param _collateralAssetAddress Address of the collateral asset token
    function setAddresses(address _positionControllerAddress, address _positionManagerAddress, address _activePoolAddress, address _collateralAssetAddress) external;

    /// @notice Gets the total amount of collateral in the pool
    /// @return The total amount of collateral
    function getCollateral() external view returns (uint);

    /// @notice Gets the amount of claimable collateral for a specific account
    /// @param _account The address of the account
    /// @return The amount of claimable collateral for the account
    function getUserCollateral(address _account) external view returns (uint);

    /// @notice Accounts for surplus collateral for a specific account
    /// @param _account The address of the account
    /// @param _amount The amount of surplus collateral to account for
    function accountSurplus(address _account, uint _amount) external;

    /// @notice Allows an account to claim their surplus collateral
    /// @param _account The address of the account claiming the collateral
    function claimColl(address _account) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./IPool.sol";
import "./ICanReceiveCollateral.sol";

/// @title IDefaultPool Interface
/// @notice Interface for the DefaultPool contract which manages defaulted debt and collateral
interface IDefaultPool is IPool, ICanReceiveCollateral {
    /// @notice Emitted when the STABLE debt in the DefaultPool is updated
    /// @param _STABLEDebt The new total STABLE debt amount
    event DefaultPoolSTABLEDebtUpdated(uint _STABLEDebt);

    /// @notice Emitted when the collateral balance in the DefaultPool is updated
    /// @param _Collateral The new total collateral amount
    event DefaultPoolCollateralBalanceUpdated(uint _Collateral);

    /// @notice Sends collateral from the DefaultPool to the ActivePool
    /// @param _amount The amount of collateral to send
    function sendCollateralToActivePool(uint _amount) external;

    /// @notice Sets the addresses of connected contracts
    /// @param _positionManagerAddress Address of the PositionManager contract
    /// @param _activePoolAddress Address of the ActivePool contract
    /// @param _collateralAssetAddress Address of the collateral asset token
    function setAddresses(address _positionManagerAddress, address _activePoolAddress, address _collateralAssetAddress) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;
import "./IBackstopPool.sol";

/**
 * @title IFeeTokenStaking
 * @dev Interface for the FeeTokenStaking contract.
 */
interface IFeeTokenStaking {
    /**
     * @dev Emitted when a user's stake amount changes
     * @param staker Address of the staker
     * @param newStake New stake amount
     */
    event StakeChanged(address indexed staker, uint newStake);

    /**
     * @dev Emitted when stable token rewards are withdrawn
     * @param staker Address of the staker
     * @param stableGain Amount of stable tokens withdrawn
     */
    event StakingStablesWithdrawn(address indexed staker, uint stableGain);

    /**
     * @dev Emitted when collateral rewards are withdrawn
     * @param asset Address of the collateral asset
     * @param staker Address of the staker
     * @param _amount Amount of collateral withdrawn
     */
    event StakingCollateralWithdrawn(address indexed asset, address indexed staker, uint _amount);

    /**
     * @dev Emitted when the cumulative collateral rewards per staked token is updated
     * @param asset Address of the collateral asset
     * @param _F_Collateral New cumulative collateral rewards value
     */
    event F_CollateralUpdated(address asset, uint _F_Collateral);

    /**
     * @dev Emitted when the cumulative stable token rewards per staked token is updated
     * @param _F_STABLE New cumulative stable token rewards value
     */
    event F_STABLEUpdated(uint _F_STABLE);

    /**
     * @dev Emitted when the total amount of staked FeeTokens is updated
     * @param _totalfeeTokenStaked New total amount of staked FeeTokens
     */
    event TotalFeeTokenStakedUpdated(uint _totalfeeTokenStaked);

    /**
     * @dev Emitted when a staker's reward snapshots are updated
     * @param _staker Address of the staker
     * @param _F_Collateral New collateral rewards snapshot
     * @param _F_STABLE New stable token rewards snapshot
     */
    event StakerSnapshotsUpdated(address _staker, uint _F_Collateral, uint _F_STABLE);

    /**
     * @dev Sets the addresses for the contract dependencies
     * @param _feeTokenAddress Address of the FeeToken contract
     * @param _stableTokenAddress Address of the StableToken contract
     * @param _positionControllerAddress Address of the PositionController contract
     * @param _collateralControllerAddress Address of the CollateralController contract
     */
    function setAddresses(
        address _feeTokenAddress,
        address _stableTokenAddress,
        address _positionControllerAddress,
        address _collateralControllerAddress
    ) external;

    /**
     * @dev Allows users to stake FeeTokens
     * @param _feeTokenAmount Amount of FeeTokens to stake
     */
    function stake(uint _feeTokenAmount) external;

    /**
     * @dev Allows users to unstake FeeTokens and claim rewards
     * @param _feeTokenAmount Amount of FeeTokens to unstake
     */
    function unstake(uint _feeTokenAmount) external;

    /**
     * @dev Increases the cumulative collateral rewards per staked token
     * @param asset Address of the collateral asset
     * @param version Version of the collateral asset
     * @param _CollateralFee Amount of collateral fee to distribute
     */
    function increaseF_Collateral(address asset, uint8 version, uint _CollateralFee) external;

    /**
     * @dev Increases the cumulative stable token rewards per staked token
     * @param _feeTokenFee Amount of stable token fee to distribute
     */
    function increaseF_STABLE(uint _feeTokenFee) external;

    /**
     * @dev Gets the pending collateral gains for a user
     * @param _user Address of the user
     * @return An array of CollateralGain structs representing pending gains
     */
    function getPendingCollateralGains(address _user) external view returns (IBackstopPool.CollateralGain[] memory);

    /**
     * @dev Gets the pending collateral gain for a specific asset and user
     * @param asset Address of the collateral asset
     * @param _user Address of the user
     * @return The pending collateral gain amount
     */
    function getPendingCollateralGain(address asset, address _user) external view returns (uint);

    /**
     * @dev Gets the pending stable token gain for a user
     * @param _user Address of the user
     * @return The pending stable token gain amount
     */
    function getPendingStableGain(address _user) external view returns (uint);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPool Interface
/// @notice Interface for Pool contracts that manage collateral and stable debt
interface IPool {
    /// @notice Emitted when collateral is sent from the pool
    /// @param _to The address receiving the collateral
    /// @param _amount The amount of collateral sent
    event CollateralSent(address _to, uint _amount);

    /// @notice Gets the total amount of collateral in the pool
    /// @return The total amount of collateral
    function getCollateral() external view returns (uint);

    /// @notice Gets the total amount of stable debt in the pool
    /// @return The total amount of stable debt
    function getStableDebt() external view returns (uint);

    /// @notice Increases the stable debt in the pool
    /// @param _amount The amount to increase the debt by
    function increaseStableDebt(uint _amount) external;

    /// @notice Decreases the stable debt in the pool
    /// @param _amount The amount to decrease the debt by
    function decreaseStableDebt(uint _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPositionController Interface
/// @notice Interface for the PositionController contract which manages user positions
interface IPositionController {
    /// @notice Emitted when a new position is created
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _borrower The address of the position owner
    /// @param arrayIndex The index of the position in the positions array
    event PositionCreated(address indexed asset, uint8 indexed version, address indexed _borrower, uint arrayIndex);

    /// @notice Emitted when a position is updated
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _borrower The address of the position owner
    /// @param _debt The new debt amount of the position
    /// @param _coll The new collateral amount of the position
    /// @param stake The new stake amount of the position
    /// @param operation The type of operation performed (e.g., open, close, adjust)
    event PositionUpdated(address indexed asset, uint8 indexed version, address indexed _borrower, uint _debt, uint _coll, uint stake, uint8 operation);

    /// @notice Emitted when a borrowing fee is paid
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _borrower The address of the position owner
    /// @param _stableFee The amount of fee paid in stable tokens
    event StableBorrowingFeePaid(address indexed asset, uint8 indexed version, address indexed _borrower, uint _stableFee);

    /// @notice Sets the addresses of connected contracts
    /// @param _collateralController Address of the CollateralController contract
    /// @param _backstopPoolAddress Address of the BackstopPool contract
    /// @param _gasPoolAddress Address of the GasPool contract
    /// @param _stableTokenAddress Address of the StableToken contract
    /// @param _feeTokenStakingAddress Address of the FeeTokenStaking contract
    function setAddresses(
        address _collateralController,
        address _backstopPoolAddress,
        address _gasPoolAddress,
        address _stableTokenAddress,
        address _feeTokenStakingAddress
    ) external;

    /// @notice Opens a new position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param suppliedCollateral The amount of collateral supplied
    /// @param _maxFee The maximum fee percentage the user is willing to pay
    /// @param _stableAmount The amount of stable tokens to borrow
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function openPosition(address asset, uint8 version, uint suppliedCollateral, uint _maxFee, uint _stableAmount,
        address _upperHint, address _lowerHint) external;

    /// @notice Adds collateral to an existing position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _collAddition The amount of collateral to add
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function addColl(address asset, uint8 version, uint _collAddition, address _upperHint, address _lowerHint) external;

    /// @notice Moves collateral gain to a position (called by BackstopPool)
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _collAddition The amount of collateral to add
    /// @param _user The address of the position owner
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function moveCollateralGainToPosition(address asset, uint8 version, uint _collAddition, address _user,
        address _upperHint, address _lowerHint) external;

    /// @notice Withdraws collateral from a position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _amount The amount of collateral to withdraw
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function withdrawColl(address asset, uint8 version, uint _amount, address _upperHint, address _lowerHint) external;

    /// @notice Withdraws stable tokens from a position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _maxFee The maximum fee percentage the user is willing to pay
    /// @param _amount The amount of stable tokens to withdraw
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function withdrawStable(address asset, uint8 version, uint _maxFee, uint _amount,
        address _upperHint, address _lowerHint) external;

    /// @notice Repays stable tokens to a position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _amount The amount of stable tokens to repay
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function repayStable(address asset, uint8 version, uint _amount, address _upperHint, address _lowerHint) external;

    /// @notice Closes a position
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    function closePosition(address asset, uint8 version) external;

    /// @notice Adjusts a position's collateral and debt
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    /// @param _collAddition The amount of collateral to add
    /// @param _maxFee The maximum fee percentage the user is willing to pay
    /// @param _collWithdrawal The amount of collateral to withdraw
    /// @param _debtChange The amount of debt to change
    /// @param isDebtIncrease True if the debt is increasing, false if decreasing
    /// @param _upperHint The address hint for position insertion (upper bound)
    /// @param _lowerHint The address hint for position insertion (lower bound)
    function adjustPosition(address asset, uint8 version, uint _collAddition, uint _maxFee,
        uint _collWithdrawal, uint _debtChange, bool isDebtIncrease, address _upperHint, address _lowerHint) external;

    /// @notice Claims any remaining collateral after position closure
    /// @param asset The address of the collateral asset
    /// @param version The version of the collateral
    function claimCollateral(address asset, uint8 version) external;

    /// @notice Calculates the composite debt (debt + gas compensation)
    /// @param _debt The base debt amount
    /// @return The composite debt amount
    function getCompositeDebt(uint _debt) external view returns (uint);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPositionManager Interface
/// @notice Interface for the PositionManager contract which manages individual positions
interface IPositionManager {
    /// @notice Emitted when a redemption occurs
    /// @param _attemptedStableAmount The amount of stable tokens attempted to redeem
    /// @param _actualStableAmount The actual amount of stable tokens redeemed
    /// @param _CollateralSent The amount of collateral sent to the redeemer
    /// @param _CollateralFee The fee paid in collateral for the redemption
    event Redemption(uint _attemptedStableAmount, uint _actualStableAmount, uint _CollateralSent, uint _CollateralFee);

    /// @notice Emitted when total stakes are updated
    /// @param _newTotalStakes The new total stakes value
    event TotalStakesUpdated(uint _newTotalStakes);

    /// @notice Emitted when system snapshots are updated
    /// @param _totalStakesSnapshot The new total stakes snapshot
    /// @param _totalCollateralSnapshot The new total collateral snapshot
    event SystemSnapshotsUpdated(uint _totalStakesSnapshot, uint _totalCollateralSnapshot);

    /// @notice Emitted when L terms are updated
    /// @param _L_Collateral The new L_Collateral value
    /// @param _L_STABLE The new L_STABLE value
    event LTermsUpdated(uint _L_Collateral, uint _L_STABLE);

    /// @notice Emitted when position snapshots are updated
    /// @param _L_Collateral The new L_Collateral value for the position
    /// @param _L_STABLEDebt The new L_STABLEDebt value for the position
    event PositionSnapshotsUpdated(uint _L_Collateral, uint _L_STABLEDebt);

    /// @notice Emitted when a position's index is updated
    /// @param _borrower The address of the position owner
    /// @param _newIndex The new index value
    event PositionIndexUpdated(address _borrower, uint _newIndex);

    /// @notice Get the total count of position owners
    /// @return The number of position owners
    function getPositionOwnersCount() external view returns (uint);

    /// @notice Get a position owner's address by index
    /// @param _index The index in the position owners array
    /// @return The address of the position owner
    function getPositionFromPositionOwnersArray(uint _index) external view returns (address);

    /// @notice Get the nominal ICR (Individual Collateral Ratio) of a position
    /// @param _borrower The address of the position owner
    /// @return The nominal ICR of the position
    function getNominalICR(address _borrower) external view returns (uint);

    /// @notice Get the current ICR of a position
    /// @param _borrower The address of the position owner
    /// @param _price The current price of the collateral
    /// @return The current ICR of the position
    function getCurrentICR(address _borrower, uint _price) external view returns (uint);

    /// @notice Liquidate a single position
    /// @param _borrower The address of the position owner to liquidate
    function liquidate(address _borrower) external;

    /// @notice Liquidate multiple positions
    /// @param _n The number of positions to attempt to liquidate
    function liquidatePositions(uint _n) external;

    /// @notice Batch liquidate a specific set of positions
    /// @param _positionArray An array of position owner addresses to liquidate
    function batchLiquidatePositions(address[] calldata _positionArray) external;

    /// @notice Queue a redemption request
    /// @param _stableAmount The amount of stable tokens to queue for redemption
    function queueRedemption(uint _stableAmount) external;

    /// @notice Redeem collateral for stable tokens
    /// @param _stableAmount The amount of stable tokens to redeem
    /// @param _firstRedemptionHint The address of the first position to consider for redemption
    /// @param _upperPartialRedemptionHint The address of the position just above the partial redemption
    /// @param _lowerPartialRedemptionHint The address of the position just below the partial redemption
    /// @param _partialRedemptionHintNICR The nominal ICR of the partial redemption hint
    /// @param _maxIterations The maximum number of iterations to perform in the redemption algorithm
    /// @param _maxFee The maximum acceptable fee percentage for the redemption
    function redeemCollateral(
        uint _stableAmount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        uint _maxFee
    ) external;

    /// @notice Update the stake and total stakes for a position
    /// @param _borrower The address of the position owner
    /// @return The new stake value
    function updateStakeAndTotalStakes(address _borrower) external returns (uint);

    /// @notice Update the reward snapshots for a position
    /// @param _borrower The address of the position owner
    function updatePositionRewardSnapshots(address _borrower) external;

    /// @notice Add a position owner to the array of position owners
    /// @param _borrower The address of the position owner
    /// @return index The index of the new position owner in the array
    function addPositionOwnerToArray(address _borrower) external returns (uint index);

    /// @notice Apply pending rewards to a position
    /// @param _borrower The address of the position owner
    function applyPendingRewards(address _borrower) external;

    /// @notice Get the pending collateral reward for a position
    /// @param _borrower The address of the position owner
    /// @return The amount of pending collateral reward
    function getPendingCollateralReward(address _borrower) external view returns (uint);

    /// @notice Get the pending stable debt reward for a position
    /// @param _borrower The address of the position owner
    /// @return The amount of pending stable debt reward
    function getPendingStableDebtReward(address _borrower) external view returns (uint);

    /// @notice Check if a position has pending rewards
    /// @param _borrower The address of the position owner
    /// @return True if the position has pending rewards, false otherwise
    function hasPendingRewards(address _borrower) external view returns (bool);

    /// @notice Get the entire debt and collateral for a position, including pending rewards
    /// @param _borrower The address of the position owner
    /// @return debt The total debt of the position
    /// @return coll The total collateral of the position
    /// @return pendingStableDebtReward The pending stable debt reward
    /// @return pendingCollateralReward The pending collateral reward
    function getEntireDebtAndColl(address _borrower)
    external view returns (uint debt, uint coll, uint pendingStableDebtReward, uint pendingCollateralReward);

    /// @notice Close a position
    /// @param _borrower The address of the position owner
    function closePosition(address _borrower) external;

    /// @notice Remove the stake for a position
    /// @param _borrower The address of the position owner
    function removeStake(address _borrower) external;

    /// @notice Get the current redemption rate
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The current redemption rate
    function getRedemptionRate(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the redemption rate with decay
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The redemption rate with decay applied
    function getRedemptionRateWithDecay(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the redemption fee with decay
    /// @param _CollateralDrawn The amount of collateral drawn
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The redemption fee with decay applied
    function getRedemptionFeeWithDecay(uint _CollateralDrawn, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the current borrowing rate
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The current borrowing rate
    function getBorrowingRate(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the borrowing rate with decay
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The borrowing rate with decay applied
    function getBorrowingRateWithDecay(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the borrowing fee
    /// @param stableDebt The amount of stable debt
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The borrowing fee
    function getBorrowingFee(uint stableDebt, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the borrowing fee with decay
    /// @param _stableDebt The amount of stable debt
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The borrowing fee with decay applied
    function getBorrowingFeeWithDecay(uint _stableDebt, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Decay the base rate from borrowing
    function decayBaseRateFromBorrowing() external;

    /// @notice Get the status of a position
    /// @param _borrower The address of the position owner
    /// @return The status of the position
    function getPositionStatus(address _borrower) external view returns (uint);

    /// @notice Get the stake of a position
    /// @param _borrower The address of the position owner
    /// @return The stake of the position
    function getPositionStake(address _borrower) external view returns (uint);

    /// @notice Get the debt of a position
    /// @param _borrower The address of the position owner
    /// @return The debt of the position
    function getPositionDebt(address _borrower) external view returns (uint);

    /// @notice Get the collateral of a position
    /// @param _borrower The address of the position owner
    /// @return The collateral of the position
    function getPositionColl(address _borrower) external view returns (uint);

    /// @notice Set the status of a position
    /// @param _borrower The address of the position owner
    /// @param num The new status value
    function setPositionStatus(address _borrower, uint num) external;

    /// @notice Increase the collateral of a position
    /// @param _borrower The address of the position owner
    /// @param _collIncrease The amount of collateral to increase
    /// @return The new collateral amount
    function increasePositionColl(address _borrower, uint _collIncrease) external returns (uint);

    /// @notice Decrease the collateral of a position
    /// @param _borrower The address of the position owner
    /// @param _collDecrease The amount of collateral to decrease
    /// @return The new collateral amount
    function decreasePositionColl(address _borrower, uint _collDecrease) external returns (uint);

    /// @notice Increase the debt of a position
    /// @param _borrower The address of the position owner
    /// @param _debtIncrease The amount of debt to increase
    /// @return The new debt amount
    function increasePositionDebt(address _borrower, uint _debtIncrease) external returns (uint);

    /// @notice Decrease the debt of a position
    /// @param _borrower The address of the position owner
    /// @param _debtDecrease The amount of debt to decrease
    /// @return The new debt amount
    function decreasePositionDebt(address _borrower, uint _debtDecrease) external returns (uint);

    /// @notice Get the entire debt of the system
    /// @return total The total debt in the system
    function getEntireDebt() external view returns (uint total);

    /// @notice Get the entire collateral in the system
    /// @return total The total collateral in the system
    function getEntireCollateral() external view returns (uint total);

    /// @notice Get the Total Collateral Ratio (TCR) of the system
    /// @param _price The current price of the collateral
    /// @return TCR The Total Collateral Ratio
    function getTCR(uint _price) external view returns(uint TCR);

    /// @notice Check if the system is in Recovery Mode
    /// @param _price The current price of the collateral
    /// @return True if the system is in Recovery Mode, false otherwise
    function checkRecoveryMode(uint _price) external returns(bool);

    /// @notice Check if the position manager is in sunset mode
    /// @return True if the position manager is in sunset mode, false otherwise
    function isSunset() external returns(bool);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPriceFeed Interface
/// @notice Interface for price feed contracts that provide various price-related functionalities
interface IPriceFeed {
    /// @notice Enum to represent the current operational mode of the oracle
    enum OracleMode {AUTOMATED, FALLBACK}

    /// @notice Struct to hold detailed price information
    struct PriceDetails {
        uint lowestPrice;
        uint highestPrice;
        uint weightedAveragePrice;
        uint spotPrice;
        uint shortTwapPrice;
        uint longTwapPrice;
        uint suggestedAdditiveFeePCT;
        OracleMode currentMode;
    }

    /// @notice Fetches the current price details
    /// @param utilizationPCT The current utilization percentage
    /// @return A PriceDetails struct containing various price metrics
    function fetchPrice(uint utilizationPCT) external view returns (PriceDetails memory);

    /// @notice Fetches the weighted average price, used during liquidations
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The weighted average price
    function fetchWeightedAveragePrice(bool testLiquidity, bool testDeviation) external returns (uint price);

    /// @notice Fetches the lowest price, used when exiting escrow or testing for under-collateralized positions
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The lowest price
    function fetchLowestPrice(bool testLiquidity, bool testDeviation) external returns (uint price);

    /// @notice Fetches the lowest price with a fee suggestion, used when issuing new debt
    /// @param loadIncrease The increase in load
    /// @param originationOrRedemptionLoadPCT The origination or redemption load percentage
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The lowest price
    /// @return suggestedAdditiveFeePCT The suggested additive fee percentage
    function fetchLowestPriceWithFeeSuggestion(
        uint loadIncrease,
        uint originationOrRedemptionLoadPCT,
        bool testLiquidity,
        bool testDeviation
    ) external returns (uint price, uint suggestedAdditiveFeePCT);

    /// @notice Fetches the highest price with a fee suggestion, used during redemptions
    /// @param loadIncrease The increase in load
    /// @param originationOrRedemptionLoadPCT The origination or redemption load percentage
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The highest price
    /// @return suggestedAdditiveFeePCT The suggested additive fee percentage
    function fetchHighestPriceWithFeeSuggestion(
        uint loadIncrease,
        uint originationOrRedemptionLoadPCT,
        bool testLiquidity,
        bool testDeviation
    ) external returns (uint price, uint suggestedAdditiveFeePCT);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title ISortedPositions Interface
/// @notice Interface for a sorted list of positions, ordered by their Individual Collateral Ratio (ICR)
interface ISortedPositions {
    /// @notice Emitted when the PositionManager address is changed
    /// @param _positionManagerAddress The new address of the PositionManager
    event PositionManagerAddressChanged(address _positionManagerAddress);

    /// @notice Emitted when the PositionController address is changed
    /// @param _positionControllerAddress The new address of the PositionController
    event PositionControllerAddressChanged(address _positionControllerAddress);

    /// @notice Emitted when a new node (position) is added to the list
    /// @param _id The address of the new position
    /// @param _NICR The Nominal Individual Collateral Ratio of the new position
    event NodeAdded(address _id, uint _NICR);

    /// @notice Emitted when a node (position) is removed from the list
    /// @param _id The address of the removed position
    event NodeRemoved(address _id);

    /// @notice Sets the parameters for the sorted list
    /// @param _size The maximum size of the list
    /// @param _positionManagerAddress The address of the PositionManager contract
    /// @param _positionControllerAddress The address of the PositionController contract
    function setParams(uint256 _size, address _positionManagerAddress, address _positionControllerAddress) external;

    /// @notice Inserts a new node (position) into the list
    /// @param _id The address of the new position
    /// @param _ICR The Individual Collateral Ratio of the new position
    /// @param _prevId The address of the previous node in the insertion position
    /// @param _nextId The address of the next node in the insertion position
    function insert(address _id, uint256 _ICR, address _prevId, address _nextId) external;

    /// @notice Removes a node (position) from the list
    /// @param _id The address of the position to remove
    function remove(address _id) external;

    /// @notice Re-inserts a node (position) into the list with a new ICR
    /// @param _id The address of the position to re-insert
    /// @param _newICR The new Individual Collateral Ratio of the position
    /// @param _prevId The address of the previous node in the new insertion position
    /// @param _nextId The address of the next node in the new insertion position
    function reInsert(address _id, uint256 _newICR, address _prevId, address _nextId) external;

    /// @notice Checks if a position is in the list
    /// @param _id The address of the position to check
    /// @return bool True if the position is in the list, false otherwise
    function contains(address _id) external view returns (bool);

    /// @notice Checks if the list is full
    /// @return bool True if the list is full, false otherwise
    function isFull() external view returns (bool);

    /// @notice Checks if the list is empty
    /// @return bool True if the list is empty, false otherwise
    function isEmpty() external view returns (bool);

    /// @notice Gets the current size of the list
    /// @return uint256 The current number of positions in the list
    function getSize() external view returns (uint256);

    /// @notice Gets the maximum size of the list
    /// @return uint256 The maximum number of positions the list can hold
    function getMaxSize() external view returns (uint256);

    /// @notice Gets the first position in the list (highest ICR)
    /// @return address The address of the first position
    function getFirst() external view returns (address);

    /// @notice Gets the last position in the list (lowest ICR)
    /// @return address The address of the last position
    function getLast() external view returns (address);

    /// @notice Gets the next position in the list after a given position
    /// @param _id The address of the current position
    /// @return address The address of the next position
    function getNext(address _id) external view returns (address);

    /// @notice Gets the previous position in the list before a given position
    /// @param _id The address of the current position
    /// @return address The address of the previous position
    function getPrev(address _id) external view returns (address);

    /// @notice Checks if a given insertion position is valid for a new ICR
    /// @param _ICR The ICR of the position to insert
    /// @param _prevId The address of the proposed previous node
    /// @param _nextId The address of the proposed next node
    /// @return bool True if the insertion position is valid, false otherwise
    function validInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (bool);

    /// @notice Finds the correct insertion position for a given ICR
    /// @param _ICR The ICR of the position to insert
    /// @param _prevId A hint for the previous node
    /// @param _nextId A hint for the next node
    /// @return address The address of the previous node for insertion
    /// @return address The address of the next node for insertion
    function findInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (address, address);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC2612.sol";

/// @title IStable Interface
/// @notice Interface for the Stable token contract, extending ERC20 and ERC2612 functionality
interface IStable is IERC20, IERC2612 {
    /// @notice Mints new tokens to a specified account
    /// @param _account The address to receive the minted tokens
    /// @param _amount The amount of tokens to mint
    function mint(address _account, uint256 _amount) external;

    /// @notice Burns tokens from a specified account
    /// @param _account The address from which to burn tokens
    /// @param _amount The amount of tokens to burn
    function burn(address _account, uint256 _amount) external;

    /// @notice Transfers tokens from a sender to a pool
    /// @param _sender The address sending the tokens
    /// @param poolAddress The address of the pool receiving the tokens
    /// @param _amount The amount of tokens to transfer
    function sendToPool(address _sender, address poolAddress, uint256 _amount) external;

    /// @notice Transfers tokens for redemption escrow
    /// @param from The address sending the tokens
    /// @param to The address receiving the tokens (likely a position manager)
    /// @param amount The amount of tokens to transfer
    function transferForRedemptionEscrow(address from, address to, uint amount) external;

    /// @notice Returns tokens from a pool to a user
    /// @param poolAddress The address of the pool sending the tokens
    /// @param user The address of the user receiving the tokens
    /// @param _amount The amount of tokens to return
    function returnFromPool(address poolAddress, address user, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../common/Base.sol";
import "../common/StableMath.sol";
import "../interfaces/ICollateralController.sol";
import "../Guardable.sol";
import "../interfaces/IFeeTokenStaking.sol";
import "../interfaces/IPositionController.sol";
import "../interfaces/IStable.sol";

/**
 * @title PositionController
 * @dev Contract for managing positions, including opening, adjusting, and closing positions.
 *
 * Key features:
 *      1. Position Management: Allows users to open, adjust, and close positions with various collateral types.
 *      2. Collateral Handling: Manages different types of collateral, including deposit and withdrawal.
 *      3. Debt Management: Handles borrowing and repayment of stable tokens.
 *      4. Liquidation and Recovery: Implements recovery mode and handles liquidations.
 *      5. Fee Management: Calculates and applies borrowing fees.
 *      6. Escrow Mechanism: Implements an escrow system for newly minted stable tokens.
 *      7. Referral System: Supports a referral system for position creation.
 *      8. Safety Checks: Implements various safety checks to maintain system stability.
 */
contract PositionController is Base, Ownable, Guardable, IPositionController {
    using SafeERC20 for IERC20Metadata;

    // Address of the backstop pool
    address public backstopPoolAddress;
    // Interface for the stable token
    IStable public stableToken;
    // Interface for fee token staking
    IFeeTokenStaking public feeTokenStaking;
    // Address of the fee token staking contract
    address public feeTokenStakingAddress;
    // Interface for collateral controller
    ICollateralController public collateralController;

    // Mapping to store loan origination escrow for each asset, version, and user
    mapping(address => mapping(uint8 => mapping(address => LoanOriginationEscrow))) public assetToVersionToUserToEscrow;

    /**
     * @dev Struct to represent a loan origination escrow
     */
    struct LoanOriginationEscrow {
        address owner;
        address asset;
        uint8 version;
        uint startTimestamp;
        uint stables;
        uint quotePrice;

        // only set on external reads.  Do not use for contract operations.
        uint loanCooldownPeriod;
    }

    /**
    * @notice Distributes clawback rewards to fee token stakers
    * @param amount Amount of stable tokens to distribute
    */
    function distributeClawbackRewards(uint amount) external onlyGuardian {
        require(amount > 0, "Cannot distribute zero amount");
        require(stableToken.balanceOf(address(this)) >= amount, "Insufficient Balance");
        feeTokenStaking.increaseF_STABLE(amount);
        stableToken.transfer(feeTokenStakingAddress, amount);
    }

    /**
     * @dev Reclaims clawback rewards to multisig
     * @param amount Amount of rewards to reclaim
     * Can only be called by the guardian
     */
    function reclaimClawbackRewards(uint amount) external onlyGuardian {
        require(amount > 0, "Cannot reclaim zero amount");
        require(stableToken.balanceOf(address(this)) >= amount, "Insufficient Balance");
        stableToken.transfer(0x54FDAcea0af4026306A665E9dAB635Ef5fF2963f, amount);
    }

    /**
     * @dev Allows users to claim their escrowed stables
     * @param originator Address of the originator
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     */
    function claimEscrow(address originator, address asset, uint8 version) external {
        ICollateralController.Collateral memory c = collateralController.getCollateralInstance(asset, version);
        LoanOriginationEscrow storage escrow = assetToVersionToUserToEscrow[asset][version][originator];
        require(escrow.startTimestamp != 0, "No active escrow for this asset and version");

        (uint requiredEscrowDuration, uint claimGracePeriod) = collateralController.getLoanCooldownRequirement(asset, version);
        uint cooldownExpiry = escrow.startTimestamp + requiredEscrowDuration;

        uint currentPrice = c.priceFeed.fetchLowestPrice(false, false);
        uint gracePeriodExpiry = cooldownExpiry + claimGracePeriod;
        bool wasLiquidated = c.positionManager.getPositionStatus(escrow.owner) == 3;

        if ((block.timestamp < gracePeriodExpiry) && !wasLiquidated) {
            require(msg.sender == escrow.owner, "Only originator can unlock during grace period");
        }

        bool isRecoveryMode = collateralController.checkRecoveryMode(asset, version, currentPrice);
        uint ICR = c.positionManager.getCurrentICR(escrow.owner, currentPrice);

        uint thresholdRatio = isRecoveryMode ?
            collateralController.getCCR(asset, version)
            :
            collateralController.getMCR(asset, version);

        if ((ICR < thresholdRatio) || wasLiquidated) {
            stableToken.mint(address(this), escrow.stables);
        } else {
            require(block.timestamp >= cooldownExpiry, "Escrow claiming cooldown not met");
            stableToken.mint(escrow.owner, escrow.stables);
        }

        delete assetToVersionToUserToEscrow[asset][version][originator];
    }

    /**
     * @dev Retrieves the escrow information for a given account
     * @param account Address of the account
     * @param asset Asset which may have a pending escrow
     * @param version Corresponding asset version
     * @return LoanOriginationEscrow struct containing escrow details
     */
    function getEscrow(address account, address asset, uint8 version) external view returns (LoanOriginationEscrow memory) {
        LoanOriginationEscrow memory loe = assetToVersionToUserToEscrow[asset][version][account];
        (loe.loanCooldownPeriod,) = collateralController.getLoanCooldownRequirement(loe.asset, loe.version);
        return loe;
    }

    /**
     * @dev Struct to hold local variables for adjusting a position
     * Used to avoid stack too deep errors
     */
    struct LocalVariables_adjustPosition {
        uint price;
        uint collChange;
        uint netDebtChange;
        bool isCollIncrease;
        uint debt;
        uint coll;
        uint oldICR;
        uint newICR;
        uint newTCR;
        uint stableFee;
        uint newDebt;
        uint newColl;
        uint stake;
        uint suggestedAdditiveFeePCT;
        uint utilizationPCT;
        uint loadIncrease;
        bool isRecoveryMode;
    }

    /**
     * @dev Struct to hold local variables for opening a position
     * Used to avoid stack too deep errors
     */
    struct LocalVariables_openPosition {
        uint price;
        uint stableFee;
        uint netDebt;
        uint compositeDebt;
        uint ICR;
        uint NICR;
        uint stake;
        uint arrayIndex;
        uint suggestedFeePCT;
        uint utilizationPCT;
        uint loadIncrease;
        bool isRecoveryMode;
        uint requiredEscrowDuration;
    }

    /**
     * @dev Enum to represent different position operations
     */
    enum PositionOperation {
        openPosition,
        closePosition,
        adjustPosition
    }

    /**
     * @dev Sets the addresses for various components of the system
     * @param _collateralController Address of the collateral controller
     * @param _backstopPoolAddress Address of the backstop pool
     * @param _gasPoolAddress Address of the gas pool
     * @param _stableTokenAddress Address of the stable token
     * @param _feeTokenStakingAddress Address of the fee token staking contract
     * Can only be called by the owner
     */
    function setAddresses(
        address _collateralController,
        address _backstopPoolAddress,
        address _gasPoolAddress,
        address _stableTokenAddress,
        address _feeTokenStakingAddress
    ) external override onlyOwner {
        assert(MIN_NET_DEBT > 0);

        backstopPoolAddress = _backstopPoolAddress;
        gasPoolAddress = _gasPoolAddress;
        stableToken = IStable(_stableTokenAddress);
        feeTokenStakingAddress = _feeTokenStakingAddress;
        feeTokenStaking = IFeeTokenStaking(_feeTokenStakingAddress);
        collateralController = ICollateralController(_collateralController);
        renounceOwnership();
    }

    /**
     * @dev Opens a new position
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     * @param suppliedCollateral Amount of collateral supplied
     * @param _maxFeePercentage Maximum fee percentage allowed
     * @param _stableAmount Amount of stable tokens to borrow
     * @param _upperHint Upper hint for position insertion
     * @param _lowerHint Lower hint for position insertion
     */
    function openPosition(
        address asset, uint8 version, uint suppliedCollateral, uint _maxFeePercentage,
        uint _stableAmount, address _upperHint, address _lowerHint
    ) external override {
        ICollateralController.Collateral memory collateral = collateralController.getCollateralInstance(asset, version);
        LocalVariables_openPosition memory vars;

        collateralController.requireIsActive(asset, version);
        _requireNotSunsetting(address(collateral.asset), collateral.version);

        (vars.utilizationPCT, vars.loadIncrease) = collateralController.regenerateAndConsumeLoanPoints(asset, version, _stableAmount);
        (vars.price, vars.suggestedFeePCT) = collateral.priceFeed.fetchLowestPriceWithFeeSuggestion(
            vars.loadIncrease,
            vars.utilizationPCT,
            true, // Test health of liquidity before issuing more debt
            true  // Test market stability. We want to be extremely conservative with new debt creation, so this check includes SPOT price if spotConsideration is 'true' in the price feed.
        );

        vars.isRecoveryMode = collateralController.checkRecoveryMode(address(collateral.asset), collateral.version, vars.price);
        _requireValidMaxFeePercentage(_maxFeePercentage, vars.isRecoveryMode, asset, version, vars.suggestedFeePCT);
        _requirePositionIsNotActive(collateral.positionManager, msg.sender);

        vars.netDebt = _stableAmount;

        if (!vars.isRecoveryMode) {
            vars.stableFee = _triggerBorrowingFee(
                collateral.positionManager,
                stableToken,
                _stableAmount,
                _maxFeePercentage,
                vars.suggestedFeePCT
            );
            vars.netDebt = vars.netDebt + vars.stableFee;
        }

        _requireAtLeastMinNetDebt(vars.netDebt);

        // ICR is based on the composite debt, i.e. the requested stable amount + stable borrowing fee + stable gas comp.
        vars.compositeDebt = vars.netDebt + GAS_COMPENSATION;
        assert(vars.compositeDebt > 0);

        vars.ICR = StableMath._computeCR(suppliedCollateral, vars.compositeDebt, vars.price, collateral.asset.decimals());
        vars.NICR = StableMath._computeNominalCR(suppliedCollateral, vars.compositeDebt, collateral.asset.decimals());

        if (vars.isRecoveryMode) {
            _requireICRisAboveCCR(vars.ICR, asset, version);
        } else {
            _requireICRisAboveMCR(vars.ICR, asset, version);
            uint newTCR = _getNewTCRFromPositionChange(collateral, suppliedCollateral, true, vars.compositeDebt, true, vars.price);  // bools: coll increase, debt increase
            _requireNewTCRisAboveCCR(newTCR, asset, version);
        }

        _requireDoesNotExceedCap(collateral, vars.compositeDebt);

        collateral.positionManager.setPositionStatus(msg.sender, 1);
        collateral.positionManager.increasePositionColl(msg.sender, suppliedCollateral);
        collateral.positionManager.increasePositionDebt(msg.sender, vars.compositeDebt);

        collateral.positionManager.updatePositionRewardSnapshots(msg.sender);
        vars.stake = collateral.positionManager.updateStakeAndTotalStakes(msg.sender);

        collateral.sortedPositions.insert(msg.sender, vars.NICR, _upperHint, _lowerHint);
        vars.arrayIndex = collateral.positionManager.addPositionOwnerToArray(msg.sender);
        emit PositionCreated(asset, version, msg.sender, vars.arrayIndex);

        // Move the collateral to the Active Pool, and mint the stableAmount to the borrower
        _activePoolAddColl(collateral, suppliedCollateral);
        (vars.requiredEscrowDuration,) = collateralController.getLoanCooldownRequirement(asset, version);
        _withdrawStable(collateral.activePool, stableToken, msg.sender, _stableAmount, vars.netDebt, vars.requiredEscrowDuration != 0, asset, version, vars.price);
        // Move the stable gas compensation to the Gas Pool
        _withdrawStable(collateral.activePool, stableToken, gasPoolAddress, GAS_COMPENSATION, GAS_COMPENSATION, false, asset, version, vars.price);

        emit PositionUpdated(asset, version, msg.sender, vars.compositeDebt, suppliedCollateral, vars.stake, uint8(PositionOperation.openPosition));
        emit StableBorrowingFeePaid(asset, version, msg.sender, vars.stableFee);
    }

    /**
     * @dev Adds collateral to an existing position
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     * @param _collAddition Amount of collateral to add
     * @param _upperHint Upper hint for position insertion
     * @param _lowerHint Lower hint for position insertion
     */
    function addColl(address asset, uint8 version, uint _collAddition, address _upperHint, address _lowerHint) external override {
        _requireNotSunsetting(asset, version);
        _adjustPosition(AdjustPositionParams(asset, version, _collAddition, msg.sender, 0, 0, false, _upperHint, _lowerHint, 0));
    }

    /**
     * @dev Moves collateral gain to a position (only callable by Backstop Pool)
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     * @param _collAddition Amount of collateral to add
     * @param _borrower Address of the borrower
     * @param _upperHint Upper hint for position insertion
     * @param _lowerHint Lower hint for position insertion
     */
    function moveCollateralGainToPosition(address asset, uint8 version, uint _collAddition, address _borrower, address _upperHint, address _lowerHint) external override {
        _requireCallerIsBackstopPool();
        _requireNotSunsetting(asset, version);
        _adjustPosition(AdjustPositionParams(asset, version, _collAddition, _borrower, 0, 0, false, _upperHint, _lowerHint, 0));
    }

    /**
     * @dev Withdraws collateral from an existing position
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     * @param _collWithdrawal Amount of collateral to withdraw
     * @param _upperHint Upper hint for position insertion
     * @param _lowerHint Lower hint for position insertion
     */
    function withdrawColl(address asset, uint8 version, uint _collWithdrawal, address _upperHint, address _lowerHint) external override {
        _adjustPosition(AdjustPositionParams(asset, version, 0, msg.sender, _collWithdrawal, 0, false, _upperHint, _lowerHint, 0));
    }

    /**
     * @dev Withdraws stable tokens from a position
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     * @param _maxFeePercentage Maximum fee percentage allowed
     * @param _stableAmount Amount of stable tokens to withdraw
     * @param _upperHint Upper hint for position insertion
     * @param _lowerHint Lower hint for position insertion
     */
    function withdrawStable(address asset, uint8 version, uint _maxFeePercentage, uint _stableAmount, address _upperHint, address _lowerHint) external override {
        _requireNotSunsetting(asset, version);
        _adjustPosition(AdjustPositionParams(asset, version, 0, msg.sender, 0, _stableAmount, true, _upperHint, _lowerHint, _maxFeePercentage));
    }

    /**
     * @dev Repays stable tokens to a position
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     * @param _stableAmount Amount of stable tokens to repay
     * @param _upperHint Upper hint for position insertion
     * @param _lowerHint Lower hint for position insertion
     */
    function repayStable(address asset, uint8 version, uint _stableAmount, address _upperHint, address _lowerHint) external override {
        _adjustPosition(AdjustPositionParams(asset, version, 0, msg.sender, 0, _stableAmount, false, _upperHint, _lowerHint, 0));
    }

    /**
     * @dev Adjusts an existing position
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     * @param _collAddition Amount of collateral to add
     * @param _maxFeePercentage Maximum fee percentage allowed
     * @param _collWithdrawal Amount of collateral to withdraw
     * @param _stableChange Amount of stable tokens to change
     * @param _isDebtIncrease Whether the debt is increasing
     * @param _upperHint Upper hint for position insertion
     * @param _lowerHint Lower hint for position insertion
     */
    function adjustPosition(address asset, uint8 version, uint _collAddition, uint _maxFeePercentage, uint _collWithdrawal,
        uint _stableChange, bool _isDebtIncrease, address _upperHint, address _lowerHint) external override {
        if (_collAddition > 0 || (_stableChange > 0 && _isDebtIncrease)) {_requireNotSunsetting(asset, version);}
        _adjustPosition(AdjustPositionParams(asset, version, _collAddition, msg.sender, _collWithdrawal, _stableChange, _isDebtIncrease, _upperHint, _lowerHint, _maxFeePercentage));
    }

    /**
     * @dev Struct to hold parameters for position adjustment
     */
    struct AdjustPositionParams {
        address asset;
        uint8 version;
        uint _collAddition;
        address _borrower;
        uint _collWithdrawal;
        uint _stableChange;
        bool _isDebtIncrease;
        address _upperHint;
        address _lowerHint;
        uint _maxFeePercentage;
    }

    /**
     * @dev Internal function to adjust a position
     * @param params AdjustPositionParams struct containing adjustment parameters
     */
    function _adjustPosition(AdjustPositionParams memory params) internal {
        ICollateralController.Collateral memory collateral = collateralController.getCollateralInstance(params.asset, params.version);
        LocalVariables_adjustPosition memory vars;

        (vars.utilizationPCT, vars.loadIncrease) = params._isDebtIncrease ?
            collateralController.regenerateAndConsumeLoanPoints(params.asset, params.version, params._stableChange) :
            collateralController.regenerateAndConsumeLoanPoints(params.asset, params.version, 0);

        (vars.price, vars.suggestedAdditiveFeePCT) = collateral.priceFeed.fetchLowestPriceWithFeeSuggestion(
            vars.loadIncrease,
            vars.utilizationPCT,
            params._isDebtIncrease, // Test health of liquidity before issuing more debt
            params._isDebtIncrease  // Test market stability. We want to be extremely conservative with new debt creation, so this check includes SPOT price if spotConsideration is 'true' in the price feed.
        );

        vars.isRecoveryMode = collateralController.checkRecoveryMode(address(collateral.asset), collateral.version, vars.price);

        if (params._isDebtIncrease) {
            _requireValidMaxFeePercentage(params._maxFeePercentage, vars.isRecoveryMode, params.asset, params.version, vars.suggestedAdditiveFeePCT);
            _requireNonZeroDebtChange(params._stableChange);
        }
        _requireSingularCollChange(params._collWithdrawal, params._collAddition);
        _requireNonZeroAdjustment(params._collWithdrawal, params._stableChange, params._collAddition);
        _requirePositionIsActive(collateral.positionManager, params._borrower);

        assert(msg.sender == params._borrower || (msg.sender == backstopPoolAddress && params._collAddition > 0 && params._stableChange == 0));

        collateral.positionManager.applyPendingRewards(params._borrower);

        // Get the collChange based on whether or not Collateral was sent in the transaction
        (vars.collChange, vars.isCollIncrease) = _getCollChange(params._collAddition, params._collWithdrawal);

        vars.netDebtChange = params._stableChange;

        // If the adjustment incorporates a debt increase and system is in Normal Mode, then trigger a borrowing fee
        if (params._isDebtIncrease && !vars.isRecoveryMode) {
            vars.stableFee = _triggerBorrowingFee(
                collateral.positionManager,
                stableToken,
                params._stableChange,
                params._maxFeePercentage,
                vars.suggestedAdditiveFeePCT
            );
            vars.netDebtChange = vars.netDebtChange + vars.stableFee; // The raw debt change includes the fee
        }

        vars.debt = collateral.positionManager.getPositionDebt(params._borrower);
        vars.coll = collateral.positionManager.getPositionColl(params._borrower);

        // Get the Position's old ICR before the adjustment, and what its new ICR will be after the adjustment
        vars.oldICR = StableMath._computeCR(vars.coll, vars.debt, vars.price, collateral.asset.decimals());
        vars.newICR = _getNewICRFromPositionChange(vars.coll, vars.debt, vars.collChange, vars.isCollIncrease,
            vars.netDebtChange, params._isDebtIncrease, vars.price, collateral.asset.decimals());

        assert(params._collWithdrawal <= vars.coll);

        // Check the adjustment satisfies all conditions for the current system mode
        _requireValidAdjustmentInCurrentMode(collateral, vars.isRecoveryMode, params._collWithdrawal, params._isDebtIncrease, vars);

        if (params._isDebtIncrease) {
            _requireDoesNotExceedCap(collateral, vars.netDebtChange);
        }

        // When the adjustment is a debt repayment, check it's a valid amount and that the caller has enough stable
        if (!params._isDebtIncrease && params._stableChange > 0) {
            _requireAtLeastMinNetDebt((vars.debt - GAS_COMPENSATION) - vars.netDebtChange);
            _requireValidStableRepayment(vars.debt, vars.netDebtChange);
            _requireSufficientStableBalance(stableToken, params._borrower, vars.netDebtChange);
        }

        (vars.newColl, vars.newDebt) = _updatePositionFromAdjustment(
            collateral.positionManager, params._borrower, vars.collChange, vars.isCollIncrease, vars.netDebtChange, params._isDebtIncrease
        );

        vars.stake = collateral.positionManager.updateStakeAndTotalStakes(params._borrower);

        // Re-insert Position in to the sorted list
        uint newNICR = _getNewNominalICRFromPositionChange(
            vars.coll, vars.debt, vars.collChange, vars.isCollIncrease, vars.netDebtChange, params._isDebtIncrease, collateral.asset.decimals()
        );

        collateral.sortedPositions.reInsert(params._borrower, newNICR, params._upperHint, params._lowerHint);

        emit PositionUpdated(params.asset, params.version, params._borrower, vars.newDebt, vars.newColl, vars.stake, uint8(PositionOperation.adjustPosition));
        emit StableBorrowingFeePaid(params.asset, params.version, params._borrower, vars.stableFee);

        // Use the unmodified _stableChange here, as we don't send the fee to the user
        _moveTokensAndCollateralFromAdjustment(collateral, stableToken, msg.sender, vars, params);
    }

    /**
     * @dev Closes an existing position
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     */
    function closePosition(address asset, uint8 version) external override {
        require(
            assetToVersionToUserToEscrow[asset][version][msg.sender].startTimestamp == 0,
            "Claim your escrowed stables before closing position"
        );

        ICollateralController.Collateral memory collateral = collateralController.getCollateralInstance(asset, version);

        _requirePositionIsActive(collateral.positionManager, msg.sender);

        uint price = collateral.priceFeed.fetchLowestPrice(false, false);
        require(!collateralController.checkRecoveryMode(asset, collateral.version, price), "PositionController: Operation not permitted during Recovery Mode");

        collateral.positionManager.applyPendingRewards(msg.sender);

        uint coll = collateral.positionManager.getPositionColl(msg.sender);
        uint debt = collateral.positionManager.getPositionDebt(msg.sender);

        _requireSufficientStableBalance(stableToken, msg.sender, debt - GAS_COMPENSATION);

        uint newTCR = _getNewTCRFromPositionChange(collateral, coll, false, debt, false, price);
        _requireNewTCRisAboveCCR(newTCR, asset, version);

        collateral.positionManager.removeStake(msg.sender);
        collateral.positionManager.closePosition(msg.sender);

        emit PositionUpdated(asset, version, msg.sender, 0, 0, 0, uint8(PositionOperation.closePosition));

        // Burn the repaid stable from the user's balance and the gas compensation from the Gas Pool
        _repayStables(collateral.activePool, stableToken, msg.sender, debt - GAS_COMPENSATION);
        _repayStables(collateral.activePool, stableToken, gasPoolAddress, GAS_COMPENSATION);

        // Send the collateral back to the user
        collateral.activePool.sendCollateral(msg.sender, coll);
    }

    /**
     * @dev Allows users to claim remaining collateral from a redemption or from a liquidation with ICR > MCR in Recovery Mode
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     */
    function claimCollateral(address asset, uint8 version) external override {
        // send Collateral from CollSurplus Pool to owner
        collateralController.getCollateralInstance(asset, version).collateralSurplusPool.claimColl(msg.sender);
    }

    // --- Helper functions ---

    // ... (previous code remains unchanged)

    /**
     * @dev Triggers the borrowing fee calculation and distribution
     * @param _positionManager The position manager contract
     * @param _stableToken The stable token contract
     * @param _stableAmount The amount of stable tokens being borrowed
     * @param _maxFeePercentage The maximum fee percentage allowed by the user
     * @param suggestedAdditiveFeePCT The suggested additive fee percentage
     * @return The calculated stable fee
     */
    function _triggerBorrowingFee(
        IPositionManager _positionManager,
        IStable _stableToken,
        uint _stableAmount,
        uint _maxFeePercentage,
        uint suggestedAdditiveFeePCT
    ) internal returns (uint) {
        _positionManager.decayBaseRateFromBorrowing(); // decay the baseRate state variable
        uint stableFee = _positionManager.getBorrowingFee(_stableAmount, suggestedAdditiveFeePCT);
        _requireUserAcceptsFee(stableFee, _stableAmount, _maxFeePercentage);

        // Send fee to feetoken staking contract
        feeTokenStaking.increaseF_STABLE(stableFee);
        _stableToken.mint(feeTokenStakingAddress, stableFee);

        return stableFee;
    }

    /**
     * @dev Calculates the USD value of the collateral
     * @param _coll The amount of collateral
     * @param _price The price of the collateral
     * @return The USD value of the collateral
     */
    function _getUSDValue(uint _coll, uint _price) internal pure returns (uint) {
        uint usdValue = (_price * _coll) / DECIMAL_PRECISION;
        return usdValue;
    }

    /**
     * @dev Determines the collateral change amount and direction
     * @param _collReceived The amount of collateral received
     * @param _requestedCollWithdrawal The amount of collateral requested for withdrawal
     * @return collChange The amount of collateral change
     * @return isCollIncrease True if collateral is increasing, false if decreasing
     */
    function _getCollChange(
        uint _collReceived,
        uint _requestedCollWithdrawal
    )
    internal
    pure
    returns (uint collChange, bool isCollIncrease)
    {
        if (_collReceived != 0) {
            collChange = _collReceived;
            isCollIncrease = true;
        } else {
            collChange = _requestedCollWithdrawal;
        }
    }

    /**
     * @dev Updates a position's collateral and debt based on the adjustment
     * @param _positionManager The position manager contract
     * @param _borrower The address of the borrower
     * @param _collChange The amount of collateral change
     * @param _isCollIncrease True if collateral is increasing, false if decreasing
     * @param _debtChange The amount of debt change
     * @param _isDebtIncrease True if debt is increasing, false if decreasing
     * @return newColl The new collateral amount
     * @return newDebt The new debt amount
     */
    function _updatePositionFromAdjustment
    (
        IPositionManager _positionManager,
        address _borrower,
        uint _collChange,
        bool _isCollIncrease,
        uint _debtChange,
        bool _isDebtIncrease
    )
    internal
    returns (uint, uint)
    {
        uint newColl = (_isCollIncrease) ? _positionManager.increasePositionColl(_borrower, _collChange)
            : _positionManager.decreasePositionColl(_borrower, _collChange);
        uint newDebt = (_isDebtIncrease) ? _positionManager.increasePositionDebt(_borrower, _debtChange)
            : _positionManager.decreasePositionDebt(_borrower, _debtChange);

        return (newColl, newDebt);
    }

    /**
     * @dev Moves tokens and collateral based on the position adjustment
     * @param collateral The collateral struct
     * @param _stableToken The stable token contract
     * @param _borrower The address of the borrower
     * @param vars The local variables for position adjustment
     * @param params The parameters for position adjustment
     */
    function _moveTokensAndCollateralFromAdjustment
    (
        ICollateralController.Collateral memory collateral,
        IStable _stableToken,
        address _borrower,
        LocalVariables_adjustPosition memory vars,
        AdjustPositionParams memory params
    )
    internal
    {
        if (params._isDebtIncrease) {
            (uint requiredEscrowDuration,) = collateralController.getLoanCooldownRequirement(address(collateral.asset), collateral.version);
            bool shouldEscrow = requiredEscrowDuration != 0;
            _withdrawStable(collateral.activePool, _stableToken, _borrower, params._stableChange, vars.netDebtChange, shouldEscrow, address(collateral.asset), collateral.version, vars.price);
        } else {
            _repayStables(collateral.activePool, _stableToken, _borrower, params._stableChange);
        }

        if (vars.isCollIncrease) {
            _activePoolAddColl(collateral, vars.collChange);
        } else {
            collateral.activePool.sendCollateral(_borrower, vars.collChange);
        }
    }

    /**
     * @dev Adds collateral to the Active Pool
     * @param collateral The collateral struct
     * @param _amount The amount of collateral to add
     */
    function _activePoolAddColl(ICollateralController.Collateral memory collateral, uint _amount) internal {
        collateral.asset.safeTransferFrom(msg.sender, address(collateral.activePool), _amount);
        collateral.activePool.receiveCollateral(address(collateral.asset), _amount);
    }

    /**
     * @dev Withdraws stable tokens and updates the active debt
     * @param _activePool The active pool contract
     * @param _stableToken The stable token contract
     * @param _account The account to receive the stable tokens
     * @param _stableAmount The amount of stable tokens to withdraw
     * @param _netDebtIncrease The net increase in debt
     * @param shouldEscrow Whether the withdrawn amount should be escrowed
     * @param asset The address of the collateral asset
     * @param version The version of the collateral
     * @param quotePrice The current price quote
     */
    function _withdrawStable(
        IActivePool _activePool,
        IStable _stableToken,
        address _account,
        uint _stableAmount,
        uint _netDebtIncrease,
        bool shouldEscrow,
        address asset,
        uint8 version,
        uint quotePrice
    ) internal {
        _activePool.increaseStableDebt(_netDebtIncrease);
        if (shouldEscrow) {
            require(
                assetToVersionToUserToEscrow[asset][version][_account].startTimestamp == 0,
                "Claim your escrowed stables before creating more debt"
            );

            LoanOriginationEscrow memory loe =
                            LoanOriginationEscrow(_account, asset, version, block.timestamp, _stableAmount, quotePrice, 0);

            assetToVersionToUserToEscrow[asset][version][_account] = loe;
        } else {
            _stableToken.mint(_account, _stableAmount);
        }
    }

    /**
     * @dev Repays stable tokens and decreases the active debt
     * @param _activePool The active pool contract
     * @param _stableToken The stable token contract
     * @param _account The account repaying the stable tokens
     * @param _stables The amount of stable tokens to repay
     */
    function _repayStables(IActivePool _activePool, IStable _stableToken, address _account, uint _stables) internal {
        _activePool.decreaseStableDebt(_stables);
        _stableToken.burn(_account, _stables);
    }

    /**
     * @dev Ensures that only one type of collateral change (withdrawal or addition) is performed
     * @param _collWithdrawal The amount of collateral withdrawal
     * @param _collAddition The amount of collateral addition
     */
    function _requireSingularCollChange(uint _collWithdrawal, uint _collAddition) internal pure {
        require(_collAddition == 0 || _collWithdrawal == 0, "PositionController: Cannot withdraw and add coll");
    }

    /**
     * @dev Ensures that at least one type of adjustment (collateral or debt) is being made
     * @param _collWithdrawal The amount of collateral withdrawal
     * @param _stableChange The amount of stable token change
     * @param _collAddition The amount of collateral addition
     */
    function _requireNonZeroAdjustment(uint _collWithdrawal, uint _stableChange, uint _collAddition) internal pure {
        require(
            _collAddition != 0 || _collWithdrawal != 0 || _stableChange != 0,
            "PositionController: There must be either a collateral change or a debt change"
        );
    }

    /**
     * @dev Ensures that the position is active
     * @param _positionManager The position manager contract
     * @param _borrower The address of the borrower
     */
    function _requirePositionIsActive(IPositionManager _positionManager, address _borrower) internal view {
        uint status = _positionManager.getPositionStatus(_borrower);
        require(status == 1, "PositionController: Position does not exist or is closed");
    }

    /**
     * @dev Ensures that the position is not active
     * @param _positionManager The position manager contract
     * @param _borrower The address of the borrower
     */
    function _requirePositionIsNotActive(IPositionManager _positionManager, address _borrower) internal view {
        uint status = _positionManager.getPositionStatus(_borrower);
        require(status != 1, "PositionController: Position is active");
    }

    /**
     * @dev Ensures that the debt change is non-zero
     * @param _stableChange The amount of stable token change
     */
    function _requireNonZeroDebtChange(uint _stableChange) internal pure {
        require(_stableChange > 0, "PositionController: Debt increase requires non-zero debtChange");
    }

    /**
     * @dev Ensures that no collateral withdrawal is performed in Recovery Mode
     * @param _collWithdrawal The amount of collateral withdrawal
     */
    function _requireNoCollWithdrawal(uint _collWithdrawal) internal pure {
        require(_collWithdrawal == 0, "PositionController: Collateral withdrawal not permitted Recovery Mode");
    }

    /**
     * @dev Validates the position adjustment based on the current mode (Normal or Recovery)
     * @param collateral The collateral struct
     * @param _isRecoveryMode Whether the system is in Recovery Mode
     * @param _collWithdrawal The amount of collateral withdrawal
     * @param _isDebtIncrease Whether the debt is increasing
     * @param _vars The local variables for position adjustment
     */
    function _requireValidAdjustmentInCurrentMode(
        ICollateralController.Collateral memory collateral,
        bool _isRecoveryMode,
        uint _collWithdrawal,
        bool _isDebtIncrease,
        LocalVariables_adjustPosition memory _vars
    )
    internal
    view
    {
        /*
        *In Recovery Mode, only allow:
        *
        * - Pure collateral top-up
        * - Pure debt repayment
        * - Collateral top-up with debt repayment
        * - A debt increase combined with a collateral top-up which makes the ICR >= 150% and improves the ICR (and by extension improves the TCR).
        *
        * In Normal Mode, ensure:
        *
        * - The new ICR is above MCR
        * - The adjustment won't pull the TCR below CCR
        */
        if (_isRecoveryMode) {
            _requireNoCollWithdrawal(_collWithdrawal);
            if (_isDebtIncrease) {
                _requireICRisAboveCCR(_vars.newICR, address(collateral.asset), collateral.version);
                _requireNewICRisAboveOldICR(_vars.newICR, _vars.oldICR);
            }
        } else { // if Normal Mode
            _requireICRisAboveMCR(_vars.newICR, address(collateral.asset), collateral.version);
            _vars.newTCR = _getNewTCRFromPositionChange(collateral, _vars.collChange, _vars.isCollIncrease, _vars.netDebtChange, _isDebtIncrease, _vars.price);
            _requireNewTCRisAboveCCR(_vars.newTCR, address(collateral.asset), collateral.version);
        }
    }

    /**
     * @dev Ensures that the new ICR is above the Minimum Collateralization Ratio (MCR)
     * @param _newICR The new Individual Collateralization Ratio
     * @param asset The address of the collateral asset
     * @param version The version of the collateral
     */
    function _requireICRisAboveMCR(uint _newICR, address asset, uint8 version) internal view {
        require(
            _newICR >= collateralController.getMCR(asset, version),
            "PositionController: An operation that would result in ICR < MCR is not permitted"
        );
    }

    /**
     * @dev Ensures that the new ICR is above the Critical Collateralization Ratio (CCR)
     * @param _newICR The new Individual Collateralization Ratio
     * @param asset The address of the collateral asset
     * @param version The version of the collateral
     */
    function _requireICRisAboveCCR(uint _newICR, address asset, uint8 version) internal view {
        require(
            _newICR >= collateralController.getCCR(asset, version),
            "PositionController: Operation must leave position with ICR >= CCR"
        );
    }

    /**
     * @dev Ensures that the new ICR is above the old ICR in Recovery Mode
     * @param _newICR The new Individual Collateralization Ratio
     * @param _oldICR The old Individual Collateralization Ratio
     */
    function _requireNewICRisAboveOldICR(uint _newICR, uint _oldICR) internal pure {
        require(_newICR >= _oldICR, "PositionController: Cannot decrease your Position's ICR in Recovery Mode");
    }

    /**
     * @dev Ensures that the new TCR is above the Critical Collateralization Ratio (CCR)
     * @param _newTCR The new Total Collateralization Ratio
     * @param asset The address of the collateral asset
     * @param version The version of the collateral
     */
    function _requireNewTCRisAboveCCR(uint _newTCR, address asset, uint8 version) internal view {
        require(
            _newTCR >= collateralController.getCCR(asset, version),
            "PositionController: An operation that would result in TCR < CCR is not permitted"
        );
    }

    /**
     * @dev Ensures that the net debt is at least the minimum allowed
     * @param _netDebt The net debt amount
     */
    function _requireAtLeastMinNetDebt(uint _netDebt) internal pure {
        require(_netDebt >= MIN_NET_DEBT, "PositionController: Position's net debt must be greater than minimum");
    }

    /**
     * @dev Validates that the stable repayment amount is valid
     * @param _currentDebt The current debt of the position
     * @param _debtRepayment The amount of debt to be repaid
     */
    function _requireValidStableRepayment(uint _currentDebt, uint _debtRepayment) internal pure {
        require(_debtRepayment <= (_currentDebt - GAS_COMPENSATION), "PositionController: Amount repaid must not be larger than the Position's debt");
    }

    /**
     * @dev Ensures that the caller is the Backstop Pool
     */
    function _requireCallerIsBackstopPool() internal view {
        require(msg.sender == backstopPoolAddress, "PositionController: Caller is not Backstop Pool");
    }

    /**
     * @dev Checks if the borrower has sufficient stable balance for repayment
     * @param _stableToken The stable token contract
     * @param _borrower The address of the borrower
     * @param _debtRepayment The amount of debt to be repaid
     */
    function _requireSufficientStableBalance(IStable _stableToken, address _borrower, uint _debtRepayment) internal view {
        require(_stableToken.balanceOf(_borrower) >= _debtRepayment, "PositionController: Caller doesn't have enough stable to make repayment");
    }

    /**
     * @dev Validates the maximum fee percentage based on the current mode and suggested fee
     * @param _maxFeePercentage The maximum fee percentage specified by the user
     * @param _isRecoveryMode Whether the system is in Recovery Mode
     * @param asset The address of the collateral asset
     * @param version The version of the collateral
     * @param suggestedFeePCT The suggested fee percentage
     */
    function _requireValidMaxFeePercentage(uint _maxFeePercentage, bool _isRecoveryMode, address asset, uint8 version, uint suggestedFeePCT) internal view {
        uint minBorrowingFeePct = collateralController.getMinBorrowingFeePct(asset, version);

        if (_isRecoveryMode) {
            require(_maxFeePercentage <= DECIMAL_PRECISION, "Max fee percentage must less than or equal to 100%");
        } else {
            uint floor = StableMath._max(DYNAMIC_BORROWING_FEE_FLOOR, minBorrowingFeePct) + suggestedFeePCT;
            bool effectiveFeeAccepted = _maxFeePercentage >= floor && _maxFeePercentage <= DECIMAL_PRECISION;
            require(effectiveFeeAccepted, "Max fee percentage must be between 0.5% and 100%");
        }
    }

    /**
     * @dev Computes the new nominal ICR (Individual Collateralization Ratio) after a position change
     * @param _coll Current collateral amount
     * @param _debt Current debt amount
     * @param _collChange Amount of collateral change
     * @param _isCollIncrease True if collateral is increasing, false if decreasing
     * @param _debtChange Amount of debt change
     * @param _isDebtIncrease True if debt is increasing, false if decreasing
     * @param decimals Decimals of the collateral asset
     * @return The new nominal ICR
     */
    function _getNewNominalICRFromPositionChange
    (
        uint _coll,
        uint _debt,
        uint _collChange,
        bool _isCollIncrease,
        uint _debtChange,
        bool _isDebtIncrease,
        uint8 decimals
    )
    pure
    internal
    returns (uint)
    {
        (uint newColl, uint newDebt) = _getNewPositionAmounts(_coll, _debt, _collChange, _isCollIncrease, _debtChange, _isDebtIncrease);
        return StableMath._computeNominalCR(newColl, newDebt, decimals);
    }

    /**
     * @dev Computes the new ICR (Individual Collateralization Ratio) after a position change
     * @param _coll Current collateral amount
     * @param _debt Current debt amount
     * @param _collChange Amount of collateral change
     * @param _isCollIncrease True if collateral is increasing, false if decreasing
     * @param _debtChange Amount of debt change
     * @param _isDebtIncrease True if debt is increasing, false if decreasing
     * @param _price Current price of the collateral
     * @param _collateralDecimals Decimals of the collateral asset
     * @return The new ICR
     */
    function _getNewICRFromPositionChange
    (
        uint _coll,
        uint _debt,
        uint _collChange,
        bool _isCollIncrease,
        uint _debtChange,
        bool _isDebtIncrease,
        uint _price,
        uint8 _collateralDecimals
    )
    pure
    internal
    returns (uint)
    {
        (uint newColl, uint newDebt) = _getNewPositionAmounts(_coll, _debt, _collChange, _isCollIncrease, _debtChange, _isDebtIncrease);
        return StableMath._computeCR(newColl, newDebt, _price, _collateralDecimals);
    }

    /**
     * @dev Calculates new collateral and debt amounts after a position change
     * @param _coll Current collateral amount
     * @param _debt Current debt amount
     * @param _collChange Amount of collateral change
     * @param _isCollIncrease True if collateral is increasing, false if decreasing
     * @param _debtChange Amount of debt change
     * @param _isDebtIncrease True if debt is increasing, false if decreasing
     * @return New collateral amount and new debt amount
     */
    function _getNewPositionAmounts(
        uint _coll,
        uint _debt,
        uint _collChange,
        bool _isCollIncrease,
        uint _debtChange,
        bool _isDebtIncrease
    )
    internal
    pure
    returns (uint, uint)
    {
        uint newColl = _coll;
        uint newDebt = _debt;

        newColl = _isCollIncrease ? _coll + _collChange : _coll - _collChange;
        newDebt = _isDebtIncrease ? _debt + _debtChange : _debt - _debtChange;

        return (newColl, newDebt);
    }

    /**
     * @dev Calculates the new TCR (Total Collateralization Ratio) after a position change
     * @param collateral Struct containing collateral information
     * @param _collChange Amount of collateral change
     * @param _isCollIncrease True if collateral is increasing, false if decreasing
     * @param _debtChange Amount of debt change
     * @param _isDebtIncrease True if debt is increasing, false if decreasing
     * @param _price Current price of the collateral
     * @return The new TCR
     */
    function _getNewTCRFromPositionChange
    (
        ICollateralController.Collateral memory collateral,
        uint _collChange,
        bool _isCollIncrease,
        uint _debtChange,
        bool _isDebtIncrease,
        uint _price
    )
    internal
    view
    returns (uint)
    {
        uint totalColl = collateralController.getAssetColl(address(collateral.asset), collateral.version);
        uint totalDebt = collateralController.getAssetDebt(address(collateral.asset), collateral.version);

        totalColl = _isCollIncrease ? totalColl + _collChange : totalColl - _collChange;
        totalDebt = _isDebtIncrease ? totalDebt + _debtChange : totalDebt - _debtChange;

        uint newTCR = StableMath._computeCR(totalColl, totalDebt, _price, collateral.asset.decimals());
        return newTCR;
    }

    /**
     * @dev Ensures that the new debt does not exceed the debt cap for the collateral
     * @param collateral Struct containing collateral information
     * @param _debtChange Amount of debt change
     */
    function _requireDoesNotExceedCap(ICollateralController.Collateral memory collateral, uint _debtChange) internal view {
        uint totalDebt = collateralController.getAssetDebt(address(collateral.asset), collateral.version);
        require(
            totalDebt + _debtChange <= collateralController.getDebtCap(address(collateral.asset), collateral.version),
            "PositionController: Debt would exceed current debt cap"
        );
    }

    /**
     * @dev Ensures that the collateral is not in the process of being decommissioned
     * @param asset Address of the collateral asset
     * @param version Version of the collateral
     */
    function _requireNotSunsetting(address asset, uint8 version) internal view {
        require(!collateralController.isDecommissioned(asset, version), "PositionController: Collateral is sunsetting");
    }

    /**
     * @dev Calculates the composite debt (user debt + gas compensation)
     * @param _debt User debt amount
     * @return Composite debt amount
     */
    function getCompositeDebt(uint _debt) external view override returns (uint) {
        return _debt + GAS_COMPENSATION;
    }
}