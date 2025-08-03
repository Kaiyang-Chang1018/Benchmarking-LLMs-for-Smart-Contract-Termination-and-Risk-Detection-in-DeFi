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
pragma solidity >=0.8.19;

// Common.sol
//
// Common mathematical functions needed by both SD59x18 and UD60x18. Note that these global functions do not
// always operate with SD59x18 and UD60x18 numbers.

/*//////////////////////////////////////////////////////////////////////////
                                CUSTOM ERRORS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Thrown when the resultant value in {mulDiv} overflows uint256.
error PRBMath_MulDiv_Overflow(uint256 x, uint256 y, uint256 denominator);

/// @notice Thrown when the resultant value in {mulDiv18} overflows uint256.
error PRBMath_MulDiv18_Overflow(uint256 x, uint256 y);

/// @notice Thrown when one of the inputs passed to {mulDivSigned} is `type(int256).min`.
error PRBMath_MulDivSigned_InputTooSmall();

/// @notice Thrown when the resultant value in {mulDivSigned} overflows int256.
error PRBMath_MulDivSigned_Overflow(int256 x, int256 y);

/*//////////////////////////////////////////////////////////////////////////
                                    CONSTANTS
//////////////////////////////////////////////////////////////////////////*/

/// @dev The maximum value a uint128 number can have.
uint128 constant MAX_UINT128 = type(uint128).max;

/// @dev The maximum value a uint40 number can have.
uint40 constant MAX_UINT40 = type(uint40).max;

/// @dev The unit number, which the decimal precision of the fixed-point types.
uint256 constant UNIT = 1e18;

/// @dev The unit number inverted mod 2^256.
uint256 constant UNIT_INVERSE = 78156646155174841979727994598816262306175212592076161876661_508869554232690281;

/// @dev The the largest power of two that divides the decimal value of `UNIT`. The logarithm of this value is the least significant
/// bit in the binary representation of `UNIT`.
uint256 constant UNIT_LPOTD = 262144;

/*//////////////////////////////////////////////////////////////////////////
                                    FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Calculates the binary exponent of x using the binary fraction method.
/// @dev Has to use 192.64-bit fixed-point numbers. See https://ethereum.stackexchange.com/a/96594/24693.
/// @param x The exponent as an unsigned 192.64-bit fixed-point number.
/// @return result The result as an unsigned 60.18-decimal fixed-point number.
/// @custom:smtchecker abstract-function-nondet
function exp2(uint256 x) pure returns (uint256 result) {
    unchecked {
        // Start from 0.5 in the 192.64-bit fixed-point format.
        result = 0x800000000000000000000000000000000000000000000000;

        // The following logic multiplies the result by $\sqrt{2^{-i}}$ when the bit at position i is 1. Key points:
        //
        // 1. Intermediate results will not overflow, as the starting point is 2^191 and all magic factors are under 2^65.
        // 2. The rationale for organizing the if statements into groups of 8 is gas savings. If the result of performing
        // a bitwise AND operation between x and any value in the array [0x80; 0x40; 0x20; 0x10; 0x08; 0x04; 0x02; 0x01] is 1,
        // we know that `x & 0xFF` is also 1.
        if (x & 0xFF00000000000000 > 0) {
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
        }

        if (x & 0xFF000000000000 > 0) {
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
        }

        if (x & 0xFF0000000000 > 0) {
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
        }

        if (x & 0xFF00000000 > 0) {
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
        }

        if (x & 0xFF000000 > 0) {
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
        }

        if (x & 0xFF0000 > 0) {
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
        }

        if (x & 0xFF00 > 0) {
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
        }

        if (x & 0xFF > 0) {
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
        }

        // In the code snippet below, two operations are executed simultaneously:
        //
        // 1. The result is multiplied by $(2^n + 1)$, where $2^n$ represents the integer part, and the additional 1
        // accounts for the initial guess of 0.5. This is achieved by subtracting from 191 instead of 192.
        // 2. The result is then converted to an unsigned 60.18-decimal fixed-point format.
        //
        // The underlying logic is based on the relationship $2^{191-ip} = 2^{ip} / 2^{191}$, where $ip$ denotes the,
        // integer part, $2^n$.
        result *= UNIT;
        result >>= (191 - (x >> 64));
    }
}

/// @notice Finds the zero-based index of the first 1 in the binary representation of x.
///
/// @dev See the note on "msb" in this Wikipedia article: https://en.wikipedia.org/wiki/Find_first_set
///
/// Each step in this implementation is equivalent to this high-level code:
///
/// ```solidity
/// if (x >= 2 ** 128) {
///     x >>= 128;
///     result += 128;
/// }
/// ```
///
/// Where 128 is replaced with each respective power of two factor. See the full high-level implementation here:
/// https://gist.github.com/PaulRBerg/f932f8693f2733e30c4d479e8e980948
///
/// The Yul instructions used below are:
///
/// - "gt" is "greater than"
/// - "or" is the OR bitwise operator
/// - "shl" is "shift left"
/// - "shr" is "shift right"
///
/// @param x The uint256 number for which to find the index of the most significant bit.
/// @return result The index of the most significant bit as a uint256.
/// @custom:smtchecker abstract-function-nondet
function msb(uint256 x) pure returns (uint256 result) {
    // 2^128
    assembly ("memory-safe") {
        let factor := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^64
    assembly ("memory-safe") {
        let factor := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^32
    assembly ("memory-safe") {
        let factor := shl(5, gt(x, 0xFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^16
    assembly ("memory-safe") {
        let factor := shl(4, gt(x, 0xFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^8
    assembly ("memory-safe") {
        let factor := shl(3, gt(x, 0xFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^4
    assembly ("memory-safe") {
        let factor := shl(2, gt(x, 0xF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^2
    assembly ("memory-safe") {
        let factor := shl(1, gt(x, 0x3))
        x := shr(factor, x)
        result := or(result, factor)
    }
    // 2^1
    // No need to shift x any more.
    assembly ("memory-safe") {
        let factor := gt(x, 0x1)
        result := or(result, factor)
    }
}

/// @notice Calculates x*y÷denominator with 512-bit precision.
///
/// @dev Credits to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - The denominator must not be zero.
/// - The result must fit in uint256.
///
/// @param x The multiplicand as a uint256.
/// @param y The multiplier as a uint256.
/// @param denominator The divisor as a uint256.
/// @return result The result as a uint256.
/// @custom:smtchecker abstract-function-nondet
function mulDiv(uint256 x, uint256 y, uint256 denominator) pure returns (uint256 result) {
    // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
    // use the Chinese Remainder Theorem to reconstruct the 512-bit result. The result is stored in two 256
    // variables such that product = prod1 * 2^256 + prod0.
    uint256 prod0; // Least significant 256 bits of the product
    uint256 prod1; // Most significant 256 bits of the product
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    // Handle non-overflow cases, 256 by 256 division.
    if (prod1 == 0) {
        unchecked {
            return prod0 / denominator;
        }
    }

    // Make sure the result is less than 2^256. Also prevents denominator == 0.
    if (prod1 >= denominator) {
        revert PRBMath_MulDiv_Overflow(x, y, denominator);
    }

    ////////////////////////////////////////////////////////////////////////////
    // 512 by 256 division
    ////////////////////////////////////////////////////////////////////////////

    // Make division exact by subtracting the remainder from [prod1 prod0].
    uint256 remainder;
    assembly ("memory-safe") {
        // Compute remainder using the mulmod Yul instruction.
        remainder := mulmod(x, y, denominator)

        // Subtract 256 bit number from 512-bit number.
        prod1 := sub(prod1, gt(remainder, prod0))
        prod0 := sub(prod0, remainder)
    }

    unchecked {
        // Calculate the largest power of two divisor of the denominator using the unary operator ~. This operation cannot overflow
        // because the denominator cannot be zero at this point in the function execution. The result is always >= 1.
        // For more detail, see https://cs.stackexchange.com/q/138556/92363.
        uint256 lpotdod = denominator & (~denominator + 1);
        uint256 flippedLpotdod;

        assembly ("memory-safe") {
            // Factor powers of two out of denominator.
            denominator := div(denominator, lpotdod)

            // Divide [prod1 prod0] by lpotdod.
            prod0 := div(prod0, lpotdod)

            // Get the flipped value `2^256 / lpotdod`. If the `lpotdod` is zero, the flipped value is one.
            // `sub(0, lpotdod)` produces the two's complement version of `lpotdod`, which is equivalent to flipping all the bits.
            // However, `div` interprets this value as an unsigned value: https://ethereum.stackexchange.com/q/147168/24693
            flippedLpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
        }

        // Shift in bits from prod1 into prod0.
        prod0 |= prod1 * flippedLpotdod;

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
    }
}

/// @notice Calculates x*y÷1e18 with 512-bit precision.
///
/// @dev A variant of {mulDiv} with constant folding, i.e. in which the denominator is hard coded to 1e18.
///
/// Notes:
/// - The body is purposely left uncommented; to understand how this works, see the documentation in {mulDiv}.
/// - The result is rounded toward zero.
/// - We take as an axiom that the result cannot be `MAX_UINT256` when x and y solve the following system of equations:
///
/// $$
/// \begin{cases}
///     x * y = MAX\_UINT256 * UNIT \\
///     (x * y) \% UNIT \geq \frac{UNIT}{2}
/// \end{cases}
/// $$
///
/// Requirements:
/// - Refer to the requirements in {mulDiv}.
/// - The result must fit in uint256.
///
/// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
/// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
/// @return result The result as an unsigned 60.18-decimal fixed-point number.
/// @custom:smtchecker abstract-function-nondet
function mulDiv18(uint256 x, uint256 y) pure returns (uint256 result) {
    uint256 prod0;
    uint256 prod1;
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    if (prod1 == 0) {
        unchecked {
            return prod0 / UNIT;
        }
    }

    if (prod1 >= UNIT) {
        revert PRBMath_MulDiv18_Overflow(x, y);
    }

    uint256 remainder;
    assembly ("memory-safe") {
        remainder := mulmod(x, y, UNIT)
        result :=
            mul(
                or(
                    div(sub(prod0, remainder), UNIT_LPOTD),
                    mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, UNIT_LPOTD), UNIT_LPOTD), 1))
                ),
                UNIT_INVERSE
            )
    }
}

/// @notice Calculates x*y÷denominator with 512-bit precision.
///
/// @dev This is an extension of {mulDiv} for signed numbers, which works by computing the signs and the absolute values separately.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - Refer to the requirements in {mulDiv}.
/// - None of the inputs can be `type(int256).min`.
/// - The result must fit in int256.
///
/// @param x The multiplicand as an int256.
/// @param y The multiplier as an int256.
/// @param denominator The divisor as an int256.
/// @return result The result as an int256.
/// @custom:smtchecker abstract-function-nondet
function mulDivSigned(int256 x, int256 y, int256 denominator) pure returns (int256 result) {
    if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
        revert PRBMath_MulDivSigned_InputTooSmall();
    }

    // Get hold of the absolute values of x, y and the denominator.
    uint256 xAbs;
    uint256 yAbs;
    uint256 dAbs;
    unchecked {
        xAbs = x < 0 ? uint256(-x) : uint256(x);
        yAbs = y < 0 ? uint256(-y) : uint256(y);
        dAbs = denominator < 0 ? uint256(-denominator) : uint256(denominator);
    }

    // Compute the absolute value of x*y÷denominator. The result must fit in int256.
    uint256 resultAbs = mulDiv(xAbs, yAbs, dAbs);
    if (resultAbs > uint256(type(int256).max)) {
        revert PRBMath_MulDivSigned_Overflow(x, y);
    }

    // Get the signs of x, y and the denominator.
    uint256 sx;
    uint256 sy;
    uint256 sd;
    assembly ("memory-safe") {
        // "sgt" is the "signed greater than" assembly instruction and "sub(0,1)" is -1 in two's complement.
        sx := sgt(x, sub(0, 1))
        sy := sgt(y, sub(0, 1))
        sd := sgt(denominator, sub(0, 1))
    }

    // XOR over sx, sy and sd. What this does is to check whether there are 1 or 3 negative signs in the inputs.
    // If there are, the result should be negative. Otherwise, it should be positive.
    unchecked {
        result = sx ^ sy ^ sd == 0 ? -int256(resultAbs) : int256(resultAbs);
    }
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - If x is not a perfect square, the result is rounded down.
/// - Credits to OpenZeppelin for the explanations in comments below.
///
/// @param x The uint256 number for which to calculate the square root.
/// @return result The result as a uint256.
/// @custom:smtchecker abstract-function-nondet
function sqrt(uint256 x) pure returns (uint256 result) {
    if (x == 0) {
        return 0;
    }

    // For our first guess, we calculate the biggest power of 2 which is smaller than the square root of x.
    //
    // We know that the "msb" (most significant bit) of x is a power of 2 such that we have:
    //
    // $$
    // msb(x) <= x <= 2*msb(x)$
    // $$
    //
    // We write $msb(x)$ as $2^k$, and we get:
    //
    // $$
    // k = log_2(x)
    // $$
    //
    // Thus, we can write the initial inequality as:
    //
    // $$
    // 2^{log_2(x)} <= x <= 2*2^{log_2(x)+1} \\
    // sqrt(2^k) <= sqrt(x) < sqrt(2^{k+1}) \\
    // 2^{k/2} <= sqrt(x) < 2^{(k+1)/2} <= 2^{(k/2)+1}
    // $$
    //
    // Consequently, $2^{log_2(x) /2} is a good first approximation of sqrt(x) with at least one correct bit.
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 2 ** 128) {
        xAux >>= 128;
        result <<= 64;
    }
    if (xAux >= 2 ** 64) {
        xAux >>= 64;
        result <<= 32;
    }
    if (xAux >= 2 ** 32) {
        xAux >>= 32;
        result <<= 16;
    }
    if (xAux >= 2 ** 16) {
        xAux >>= 16;
        result <<= 8;
    }
    if (xAux >= 2 ** 8) {
        xAux >>= 8;
        result <<= 4;
    }
    if (xAux >= 2 ** 4) {
        xAux >>= 4;
        result <<= 2;
    }
    if (xAux >= 2 ** 2) {
        result <<= 1;
    }

    // At this point, `result` is an estimation with at least one bit of precision. We know the true value has at
    // most 128 bits, since it is the square root of a uint256. Newton's method converges quadratically (precision
    // doubles at every iteration). We thus need at most 7 iteration to turn our partial result with one bit of
    // precision into the expected uint128 result.
    unchecked {
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;

        // If x is not a perfect square, round the result toward zero.
        uint256 roundedResult = x / result;
        if (result >= roundedResult) {
            result = roundedResult;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/*

██████╗ ██████╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔══██╗╚══██╔══╝██║  ██║
██████╔╝██████╔╝██████╔╝██╔████╔██║███████║   ██║   ███████║
██╔═══╝ ██╔══██╗██╔══██╗██║╚██╔╝██║██╔══██║   ██║   ██╔══██║
██║     ██║  ██║██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

██╗   ██╗██████╗ ██████╗ ██╗  ██╗ ██╗ █████╗
██║   ██║██╔══██╗╚════██╗╚██╗██╔╝███║██╔══██╗
██║   ██║██║  ██║ █████╔╝ ╚███╔╝ ╚██║╚█████╔╝
██║   ██║██║  ██║██╔═══╝  ██╔██╗  ██║██╔══██╗
╚██████╔╝██████╔╝███████╗██╔╝ ██╗ ██║╚█████╔╝
 ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═╝ ╚════╝

*/

import "./ud2x18/Casting.sol";
import "./ud2x18/Constants.sol";
import "./ud2x18/Errors.sol";
import "./ud2x18/ValueType.sol";
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/*

██████╗ ██████╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔══██╗╚══██╔══╝██║  ██║
██████╔╝██████╔╝██████╔╝██╔████╔██║███████║   ██║   ███████║
██╔═══╝ ██╔══██╗██╔══██╗██║╚██╔╝██║██╔══██║   ██║   ██╔══██║
██║     ██║  ██║██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

██╗   ██╗██████╗  ██████╗  ██████╗ ██╗  ██╗ ██╗ █████╗
██║   ██║██╔══██╗██╔════╝ ██╔═████╗╚██╗██╔╝███║██╔══██╗
██║   ██║██║  ██║███████╗ ██║██╔██║ ╚███╔╝ ╚██║╚█████╔╝
██║   ██║██║  ██║██╔═══██╗████╔╝██║ ██╔██╗  ██║██╔══██╗
╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝██╔╝ ██╗ ██║╚█████╔╝
 ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═╝ ╚════╝

*/

import "./ud60x18/Casting.sol";
import "./ud60x18/Constants.sol";
import "./ud60x18/Conversions.sol";
import "./ud60x18/Errors.sol";
import "./ud60x18/Helpers.sol";
import "./ud60x18/Math.sol";
import "./ud60x18/ValueType.sol";
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as CastingErrors;
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD1x18 } from "./ValueType.sol";

/// @notice Casts an SD1x18 number into SD59x18.
/// @dev There is no overflow check because the domain of SD1x18 is a subset of SD59x18.
function intoSD59x18(SD1x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(SD1x18.unwrap(x)));
}

/// @notice Casts an SD1x18 number into UD2x18.
/// - x must be positive.
function intoUD2x18(SD1x18 x) pure returns (UD2x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUD2x18_Underflow(x);
    }
    result = UD2x18.wrap(uint64(xInt));
}

/// @notice Casts an SD1x18 number into UD60x18.
/// @dev Requirements:
/// - x must be positive.
function intoUD60x18(SD1x18 x) pure returns (UD60x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint256.
/// @dev Requirements:
/// - x must be positive.
function intoUint256(SD1x18 x) pure returns (uint256 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint256_Underflow(x);
    }
    result = uint256(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint128.
/// @dev Requirements:
/// - x must be positive.
function intoUint128(SD1x18 x) pure returns (uint128 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint128_Underflow(x);
    }
    result = uint128(uint64(xInt));
}

/// @notice Casts an SD1x18 number into uint40.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `MAX_UINT40`.
function intoUint40(SD1x18 x) pure returns (uint40 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD1x18_ToUint40_Underflow(x);
    }
    if (xInt > int64(uint64(Common.MAX_UINT40))) {
        revert CastingErrors.PRBMath_SD1x18_ToUint40_Overflow(x);
    }
    result = uint40(uint64(xInt));
}

/// @notice Alias for {wrap}.
function sd1x18(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}

/// @notice Unwraps an SD1x18 number into int64.
function unwrap(SD1x18 x) pure returns (int64 result) {
    result = SD1x18.unwrap(x);
}

/// @notice Wraps an int64 number into SD1x18.
function wrap(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD1x18 } from "./ValueType.sol";

/// @dev Euler's number as an SD1x18 number.
SD1x18 constant E = SD1x18.wrap(2_718281828459045235);

/// @dev The maximum value an SD1x18 number can have.
int64 constant uMAX_SD1x18 = 9_223372036854775807;
SD1x18 constant MAX_SD1x18 = SD1x18.wrap(uMAX_SD1x18);

/// @dev The maximum value an SD1x18 number can have.
int64 constant uMIN_SD1x18 = -9_223372036854775808;
SD1x18 constant MIN_SD1x18 = SD1x18.wrap(uMIN_SD1x18);

/// @dev PI as an SD1x18 number.
SD1x18 constant PI = SD1x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD1x18.
SD1x18 constant UNIT = SD1x18.wrap(1e18);
int256 constant uUNIT = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD1x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in UD2x18.
error PRBMath_SD1x18_ToUD2x18_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in UD60x18.
error PRBMath_SD1x18_ToUD60x18_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint128.
error PRBMath_SD1x18_ToUint128_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint256.
error PRBMath_SD1x18_ToUint256_Underflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint40.
error PRBMath_SD1x18_ToUint40_Overflow(SD1x18 x);

/// @notice Thrown when trying to cast a SD1x18 number that doesn't fit in uint40.
error PRBMath_SD1x18_ToUint40_Underflow(SD1x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The signed 1.18-decimal fixed-point number representation, which can have up to 1 digit and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type int64. This is useful when end users want to use int64 to save gas, e.g. with tight variable packing in contract
/// storage.
type SD1x18 is int64;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD59x18,
    Casting.intoUD2x18,
    Casting.intoUD60x18,
    Casting.intoUint256,
    Casting.intoUint128,
    Casting.intoUint40,
    Casting.unwrap
} for SD1x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Errors.sol" as CastingErrors;
import { MAX_UINT128, MAX_UINT40 } from "../Common.sol";
import { uMAX_SD1x18, uMIN_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { uMAX_UD2x18 } from "../ud2x18/Constants.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Casts an SD59x18 number into int256.
/// @dev This is basically a functional alias for {unwrap}.
function intoInt256(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}

/// @notice Casts an SD59x18 number into SD1x18.
/// @dev Requirements:
/// - x must be greater than or equal to `uMIN_SD1x18`.
/// - x must be less than or equal to `uMAX_SD1x18`.
function intoSD1x18(SD59x18 x) pure returns (SD1x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < uMIN_SD1x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD1x18_Underflow(x);
    }
    if (xInt > uMAX_SD1x18) {
        revert CastingErrors.PRBMath_SD59x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xInt));
}

/// @notice Casts an SD59x18 number into UD2x18.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `uMAX_UD2x18`.
function intoUD2x18(SD59x18 x) pure returns (UD2x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD2x18_Underflow(x);
    }
    if (xInt > int256(uint256(uMAX_UD2x18))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(uint256(xInt)));
}

/// @notice Casts an SD59x18 number into UD60x18.
/// @dev Requirements:
/// - x must be positive.
function intoUD60x18(SD59x18 x) pure returns (UD60x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint256(xInt));
}

/// @notice Casts an SD59x18 number into uint256.
/// @dev Requirements:
/// - x must be positive.
function intoUint256(SD59x18 x) pure returns (uint256 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint256_Underflow(x);
    }
    result = uint256(xInt);
}

/// @notice Casts an SD59x18 number into uint128.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `uMAX_UINT128`.
function intoUint128(SD59x18 x) pure returns (uint128 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint128_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT128))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint128_Overflow(x);
    }
    result = uint128(uint256(xInt));
}

/// @notice Casts an SD59x18 number into uint40.
/// @dev Requirements:
/// - x must be positive.
/// - x must be less than or equal to `MAX_UINT40`.
function intoUint40(SD59x18 x) pure returns (uint40 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint40_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT40))) {
        revert CastingErrors.PRBMath_SD59x18_IntoUint40_Overflow(x);
    }
    result = uint40(uint256(xInt));
}

/// @notice Alias for {wrap}.
function sd(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}

/// @notice Alias for {wrap}.
function sd59x18(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}

/// @notice Unwraps an SD59x18 number into int256.
function unwrap(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}

/// @notice Wraps an int256 number into SD59x18.
function wrap(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD59x18 } from "./ValueType.sol";

// NOTICE: the "u" prefix stands for "unwrapped".

/// @dev Euler's number as an SD59x18 number.
SD59x18 constant E = SD59x18.wrap(2_718281828459045235);

/// @dev The maximum input permitted in {exp}.
int256 constant uEXP_MAX_INPUT = 133_084258667509499440;
SD59x18 constant EXP_MAX_INPUT = SD59x18.wrap(uEXP_MAX_INPUT);

/// @dev The maximum input permitted in {exp2}.
int256 constant uEXP2_MAX_INPUT = 192e18 - 1;
SD59x18 constant EXP2_MAX_INPUT = SD59x18.wrap(uEXP2_MAX_INPUT);

/// @dev Half the UNIT number.
int256 constant uHALF_UNIT = 0.5e18;
SD59x18 constant HALF_UNIT = SD59x18.wrap(uHALF_UNIT);

/// @dev $log_2(10)$ as an SD59x18 number.
int256 constant uLOG2_10 = 3_321928094887362347;
SD59x18 constant LOG2_10 = SD59x18.wrap(uLOG2_10);

/// @dev $log_2(e)$ as an SD59x18 number.
int256 constant uLOG2_E = 1_442695040888963407;
SD59x18 constant LOG2_E = SD59x18.wrap(uLOG2_E);

/// @dev The maximum value an SD59x18 number can have.
int256 constant uMAX_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_792003956564819967;
SD59x18 constant MAX_SD59x18 = SD59x18.wrap(uMAX_SD59x18);

/// @dev The maximum whole value an SD59x18 number can have.
int256 constant uMAX_WHOLE_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MAX_WHOLE_SD59x18 = SD59x18.wrap(uMAX_WHOLE_SD59x18);

/// @dev The minimum value an SD59x18 number can have.
int256 constant uMIN_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_792003956564819968;
SD59x18 constant MIN_SD59x18 = SD59x18.wrap(uMIN_SD59x18);

/// @dev The minimum whole value an SD59x18 number can have.
int256 constant uMIN_WHOLE_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MIN_WHOLE_SD59x18 = SD59x18.wrap(uMIN_WHOLE_SD59x18);

/// @dev PI as an SD59x18 number.
SD59x18 constant PI = SD59x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of SD59x18.
int256 constant uUNIT = 1e18;
SD59x18 constant UNIT = SD59x18.wrap(1e18);

/// @dev The unit number squared.
int256 constant uUNIT_SQUARED = 1e36;
SD59x18 constant UNIT_SQUARED = SD59x18.wrap(uUNIT_SQUARED);

/// @dev Zero as an SD59x18 number.
SD59x18 constant ZERO = SD59x18.wrap(0);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { SD59x18 } from "./ValueType.sol";

/// @notice Thrown when taking the absolute value of `MIN_SD59x18`.
error PRBMath_SD59x18_Abs_MinSD59x18();

/// @notice Thrown when ceiling a number overflows SD59x18.
error PRBMath_SD59x18_Ceil_Overflow(SD59x18 x);

/// @notice Thrown when converting a basic integer to the fixed-point format overflows SD59x18.
error PRBMath_SD59x18_Convert_Overflow(int256 x);

/// @notice Thrown when converting a basic integer to the fixed-point format underflows SD59x18.
error PRBMath_SD59x18_Convert_Underflow(int256 x);

/// @notice Thrown when dividing two numbers and one of them is `MIN_SD59x18`.
error PRBMath_SD59x18_Div_InputTooSmall();

/// @notice Thrown when dividing two numbers and one of the intermediary unsigned results overflows SD59x18.
error PRBMath_SD59x18_Div_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when taking the natural exponent of a base greater than 133_084258667509499441.
error PRBMath_SD59x18_Exp_InputTooBig(SD59x18 x);

/// @notice Thrown when taking the binary exponent of a base greater than 192e18.
error PRBMath_SD59x18_Exp2_InputTooBig(SD59x18 x);

/// @notice Thrown when flooring a number underflows SD59x18.
error PRBMath_SD59x18_Floor_Underflow(SD59x18 x);

/// @notice Thrown when taking the geometric mean of two numbers and their product is negative.
error PRBMath_SD59x18_Gm_NegativeProduct(SD59x18 x, SD59x18 y);

/// @notice Thrown when taking the geometric mean of two numbers and multiplying them overflows SD59x18.
error PRBMath_SD59x18_Gm_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD1x18.
error PRBMath_SD59x18_IntoSD1x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD1x18.
error PRBMath_SD59x18_IntoSD1x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_SD59x18_IntoUD2x18_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_SD59x18_IntoUD2x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD60x18.
error PRBMath_SD59x18_IntoUD60x18_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_SD59x18_IntoUint128_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_SD59x18_IntoUint128_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint256.
error PRBMath_SD59x18_IntoUint256_Underflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
error PRBMath_SD59x18_IntoUint40_Overflow(SD59x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
error PRBMath_SD59x18_IntoUint40_Underflow(SD59x18 x);

/// @notice Thrown when taking the logarithm of a number less than or equal to zero.
error PRBMath_SD59x18_Log_InputTooSmall(SD59x18 x);

/// @notice Thrown when multiplying two numbers and one of the inputs is `MIN_SD59x18`.
error PRBMath_SD59x18_Mul_InputTooSmall();

/// @notice Thrown when multiplying two numbers and the intermediary absolute result overflows SD59x18.
error PRBMath_SD59x18_Mul_Overflow(SD59x18 x, SD59x18 y);

/// @notice Thrown when raising a number to a power and hte intermediary absolute result overflows SD59x18.
error PRBMath_SD59x18_Powu_Overflow(SD59x18 x, uint256 y);

/// @notice Thrown when taking the square root of a negative number.
error PRBMath_SD59x18_Sqrt_NegativeInput(SD59x18 x);

/// @notice Thrown when the calculating the square root overflows SD59x18.
error PRBMath_SD59x18_Sqrt_Overflow(SD59x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { wrap } from "./Casting.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Implements the checked addition operation (+) in the SD59x18 type.
function add(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap(x.unwrap() + y.unwrap());
}

/// @notice Implements the AND (&) bitwise operation in the SD59x18 type.
function and(SD59x18 x, int256 bits) pure returns (SD59x18 result) {
    return wrap(x.unwrap() & bits);
}

/// @notice Implements the AND (&) bitwise operation in the SD59x18 type.
function and2(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap(x.unwrap() & y.unwrap());
}

/// @notice Implements the equal (=) operation in the SD59x18 type.
function eq(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() == y.unwrap();
}

/// @notice Implements the greater than operation (>) in the SD59x18 type.
function gt(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() > y.unwrap();
}

/// @notice Implements the greater than or equal to operation (>=) in the SD59x18 type.
function gte(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() >= y.unwrap();
}

/// @notice Implements a zero comparison check function in the SD59x18 type.
function isZero(SD59x18 x) pure returns (bool result) {
    result = x.unwrap() == 0;
}

/// @notice Implements the left shift operation (<<) in the SD59x18 type.
function lshift(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() << bits);
}

/// @notice Implements the lower than operation (<) in the SD59x18 type.
function lt(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() < y.unwrap();
}

/// @notice Implements the lower than or equal to operation (<=) in the SD59x18 type.
function lte(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() <= y.unwrap();
}

/// @notice Implements the unchecked modulo operation (%) in the SD59x18 type.
function mod(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() % y.unwrap());
}

/// @notice Implements the not equal operation (!=) in the SD59x18 type.
function neq(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap() != y.unwrap();
}

/// @notice Implements the NOT (~) bitwise operation in the SD59x18 type.
function not(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(~x.unwrap());
}

/// @notice Implements the OR (|) bitwise operation in the SD59x18 type.
function or(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() | y.unwrap());
}

/// @notice Implements the right shift operation (>>) in the SD59x18 type.
function rshift(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() >> bits);
}

/// @notice Implements the checked subtraction operation (-) in the SD59x18 type.
function sub(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() - y.unwrap());
}

/// @notice Implements the checked unary minus operation (-) in the SD59x18 type.
function unary(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(-x.unwrap());
}

/// @notice Implements the unchecked addition operation (+) in the SD59x18 type.
function uncheckedAdd(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(x.unwrap() + y.unwrap());
    }
}

/// @notice Implements the unchecked subtraction operation (-) in the SD59x18 type.
function uncheckedSub(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(x.unwrap() - y.unwrap());
    }
}

/// @notice Implements the unchecked unary minus operation (-) in the SD59x18 type.
function uncheckedUnary(SD59x18 x) pure returns (SD59x18 result) {
    unchecked {
        result = wrap(-x.unwrap());
    }
}

/// @notice Implements the XOR (^) bitwise operation in the SD59x18 type.
function xor(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() ^ y.unwrap());
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import {
    uEXP_MAX_INPUT,
    uEXP2_MAX_INPUT,
    uHALF_UNIT,
    uLOG2_10,
    uLOG2_E,
    uMAX_SD59x18,
    uMAX_WHOLE_SD59x18,
    uMIN_SD59x18,
    uMIN_WHOLE_SD59x18,
    UNIT,
    uUNIT,
    uUNIT_SQUARED,
    ZERO
} from "./Constants.sol";
import { wrap } from "./Helpers.sol";
import { SD59x18 } from "./ValueType.sol";

/// @notice Calculates the absolute value of x.
///
/// @dev Requirements:
/// - x must be greater than `MIN_SD59x18`.
///
/// @param x The SD59x18 number for which to calculate the absolute value.
/// @param result The absolute value of x as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function abs(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Abs_MinSD59x18();
    }
    result = xInt < 0 ? wrap(-xInt) : x;
}

/// @notice Calculates the arithmetic average of x and y.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// @param x The first operand as an SD59x18 number.
/// @param y The second operand as an SD59x18 number.
/// @return result The arithmetic average as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function avg(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();

    unchecked {
        // This operation is equivalent to `x / 2 +  y / 2`, and it can never overflow.
        int256 sum = (xInt >> 1) + (yInt >> 1);

        if (sum < 0) {
            // If at least one of x and y is odd, add 1 to the result, because shifting negative numbers to the right
            // rounds toward negative infinity. The right part is equivalent to `sum + (x % 2 == 1 || y % 2 == 1)`.
            assembly ("memory-safe") {
                result := add(sum, and(or(xInt, yInt), 1))
            }
        } else {
            // Add 1 if both x and y are odd to account for the double 0.5 remainder truncated after shifting.
            result = wrap(sum + (xInt & yInt & 1));
        }
    }
}

/// @notice Yields the smallest whole number greater than or equal to x.
///
/// @dev Optimized for fractional value inputs, because every whole value has (1e18 - 1) fractional counterparts.
/// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x must be less than or equal to `MAX_WHOLE_SD59x18`.
///
/// @param x The SD59x18 number to ceil.
/// @param result The smallest whole number greater than or equal to x, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function ceil(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt > uMAX_WHOLE_SD59x18) {
        revert Errors.PRBMath_SD59x18_Ceil_Overflow(x);
    }

    int256 remainder = xInt % uUNIT;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            // Solidity uses C fmod style, which returns a modulus with the same sign as x.
            int256 resultInt = xInt - remainder;
            if (xInt > 0) {
                resultInt += uUNIT;
            }
            result = wrap(resultInt);
        }
    }
}

/// @notice Divides two SD59x18 numbers, returning a new SD59x18 number.
///
/// @dev This is an extension of {Common.mulDiv} for signed numbers, which works by computing the signs and the absolute
/// values separately.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
/// - The result is rounded toward zero.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
/// - None of the inputs can be `MIN_SD59x18`.
/// - The denominator must not be zero.
/// - The result must fit in SD59x18.
///
/// @param x The numerator as an SD59x18 number.
/// @param y The denominator as an SD59x18 number.
/// @param result The quotient as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function div(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Div_InputTooSmall();
    }

    // Get hold of the absolute values of x and y.
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }

    // Compute the absolute value (x*UNIT÷y). The resulting value must fit in SD59x18.
    uint256 resultAbs = Common.mulDiv(xAbs, uint256(uUNIT), yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Div_Overflow(x, y);
    }

    // Check if x and y have the same sign using two's complement representation. The left-most bit represents the sign (1 for
    // negative, 0 for positive or zero).
    bool sameSign = (xInt ^ yInt) > -1;

    // If the inputs have the same sign, the result should be positive. Otherwise, it should be negative.
    unchecked {
        result = wrap(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}

/// @notice Calculates the natural exponent of x using the following formula:
///
/// $$
/// e^x = 2^{x * log_2{e}}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {exp2}.
///
/// Requirements:
/// - Refer to the requirements in {exp2}.
/// - x must be less than 133_084258667509499441.
///
/// @param x The exponent as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();

    // This check prevents values greater than 192e18 from being passed to {exp2}.
    if (xInt > uEXP_MAX_INPUT) {
        revert Errors.PRBMath_SD59x18_Exp_InputTooBig(x);
    }

    unchecked {
        // Inline the fixed-point multiplication to save gas.
        int256 doubleUnitProduct = xInt * uLOG2_E;
        result = exp2(wrap(doubleUnitProduct / uUNIT));
    }
}

/// @notice Calculates the binary exponent of x using the binary fraction method using the following formula:
///
/// $$
/// 2^{-x} = \frac{1}{2^x}
/// $$
///
/// @dev See https://ethereum.stackexchange.com/q/79903/24693.
///
/// Notes:
/// - If x is less than -59_794705707972522261, the result is zero.
///
/// Requirements:
/// - x must be less than 192e18.
/// - The result must fit in SD59x18.
///
/// @param x The exponent as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp2(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        // The inverse of any number less than this is truncated to zero.
        if (xInt < -59_794705707972522261) {
            return ZERO;
        }

        unchecked {
            // Inline the fixed-point inversion to save gas.
            result = wrap(uUNIT_SQUARED / exp2(wrap(-xInt)).unwrap());
        }
    } else {
        // Numbers greater than or equal to 192e18 don't fit in the 192.64-bit format.
        if (xInt > uEXP2_MAX_INPUT) {
            revert Errors.PRBMath_SD59x18_Exp2_InputTooBig(x);
        }

        unchecked {
            // Convert x to the 192.64-bit fixed-point format.
            uint256 x_192x64 = uint256((xInt << 64) / uUNIT);

            // It is safe to cast the result to int256 due to the checks above.
            result = wrap(int256(Common.exp2(x_192x64)));
        }
    }
}

/// @notice Yields the greatest whole number less than or equal to x.
///
/// @dev Optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional
/// counterparts. See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x must be greater than or equal to `MIN_WHOLE_SD59x18`.
///
/// @param x The SD59x18 number to floor.
/// @param result The greatest whole number less than or equal to x, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function floor(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < uMIN_WHOLE_SD59x18) {
        revert Errors.PRBMath_SD59x18_Floor_Underflow(x);
    }

    int256 remainder = xInt % uUNIT;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            // Solidity uses C fmod style, which returns a modulus with the same sign as x.
            int256 resultInt = xInt - remainder;
            if (xInt < 0) {
                resultInt -= uUNIT;
            }
            result = wrap(resultInt);
        }
    }
}

/// @notice Yields the excess beyond the floor of x for positive numbers and the part of the number to the right.
/// of the radix point for negative numbers.
/// @dev Based on the odd function definition. https://en.wikipedia.org/wiki/Fractional_part
/// @param x The SD59x18 number to get the fractional part of.
/// @param result The fractional part of x as an SD59x18 number.
function frac(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(x.unwrap() % uUNIT);
}

/// @notice Calculates the geometric mean of x and y, i.e. $\sqrt{x * y}$.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x * y must fit in SD59x18.
/// - x * y must not be negative, since complex numbers are not supported.
///
/// @param x The first operand as an SD59x18 number.
/// @param y The second operand as an SD59x18 number.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function gm(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == 0 || yInt == 0) {
        return ZERO;
    }

    unchecked {
        // Equivalent to `xy / x != y`. Checking for overflow this way is faster than letting Solidity do it.
        int256 xyInt = xInt * yInt;
        if (xyInt / xInt != yInt) {
            revert Errors.PRBMath_SD59x18_Gm_Overflow(x, y);
        }

        // The product must not be negative, since complex numbers are not supported.
        if (xyInt < 0) {
            revert Errors.PRBMath_SD59x18_Gm_NegativeProduct(x, y);
        }

        // We don't need to multiply the result by `UNIT` here because the x*y product picked up a factor of `UNIT`
        // during multiplication. See the comments in {Common.sqrt}.
        uint256 resultUint = Common.sqrt(uint256(xyInt));
        result = wrap(int256(resultUint));
    }
}

/// @notice Calculates the inverse of x.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x must not be zero.
///
/// @param x The SD59x18 number for which to calculate the inverse.
/// @return result The inverse as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function inv(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap(uUNIT_SQUARED / x.unwrap());
}

/// @notice Calculates the natural logarithm of x using the following formula:
///
/// $$
/// ln{x} = log_2{x} / log_2{e}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
/// - The precision isn't sufficiently fine-grained to return exactly `UNIT` when the input is `E`.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The SD59x18 number for which to calculate the natural logarithm.
/// @return result The natural logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function ln(SD59x18 x) pure returns (SD59x18 result) {
    // Inline the fixed-point multiplication to save gas. This is overflow-safe because the maximum value that
    // {log2} can return is ~195_205294292027477728.
    result = wrap(log2(x).unwrap() * uUNIT / uLOG2_E);
}

/// @notice Calculates the common logarithm of x using the following formula:
///
/// $$
/// log_{10}{x} = log_2{x} / log_2{10}
/// $$
///
/// However, if x is an exact power of ten, a hard coded value is returned.
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The SD59x18 number for which to calculate the common logarithm.
/// @return result The common logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function log10(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        revert Errors.PRBMath_SD59x18_Log_InputTooSmall(x);
    }

    // Note that the `mul` in this block is the standard multiplication operation, not {SD59x18.mul}.
    // prettier-ignore
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT, sub(0, 18)) }
        case 10 { result := mul(uUNIT, sub(1, 18)) }
        case 100 { result := mul(uUNIT, sub(2, 18)) }
        case 1000 { result := mul(uUNIT, sub(3, 18)) }
        case 10000 { result := mul(uUNIT, sub(4, 18)) }
        case 100000 { result := mul(uUNIT, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT }
        case 100000000000000000000 { result := mul(uUNIT, 2) }
        case 1000000000000000000000 { result := mul(uUNIT, 3) }
        case 10000000000000000000000 { result := mul(uUNIT, 4) }
        case 100000000000000000000000 { result := mul(uUNIT, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 58) }
        default { result := uMAX_SD59x18 }
    }

    if (result.unwrap() == uMAX_SD59x18) {
        unchecked {
            // Inline the fixed-point division to save gas.
            result = wrap(log2(x).unwrap() * uUNIT / uLOG2_10);
        }
    }
}

/// @notice Calculates the binary logarithm of x using the iterative approximation algorithm:
///
/// $$
/// log_2{x} = n + log_2{y}, \text{ where } y = x*2^{-n}, \ y \in [1, 2)
/// $$
///
/// For $0 \leq x \lt 1$, the input is inverted:
///
/// $$
/// log_2{x} = -log_2{\frac{1}{x}}
/// $$
///
/// @dev See https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation.
///
/// Notes:
/// - Due to the lossy precision of the iterative approximation, the results are not perfectly accurate to the last decimal.
///
/// Requirements:
/// - x must be greater than zero.
///
/// @param x The SD59x18 number for which to calculate the binary logarithm.
/// @return result The binary logarithm as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function log2(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt <= 0) {
        revert Errors.PRBMath_SD59x18_Log_InputTooSmall(x);
    }

    unchecked {
        int256 sign;
        if (xInt >= uUNIT) {
            sign = 1;
        } else {
            sign = -1;
            // Inline the fixed-point inversion to save gas.
            xInt = uUNIT_SQUARED / xInt;
        }

        // Calculate the integer part of the logarithm.
        uint256 n = Common.msb(uint256(xInt / uUNIT));

        // This is the integer part of the logarithm as an SD59x18 number. The operation can't overflow
        // because n is at most 255, `UNIT` is 1e18, and the sign is either 1 or -1.
        int256 resultInt = int256(n) * uUNIT;

        // Calculate $y = x * 2^{-n}$.
        int256 y = xInt >> n;

        // If y is the unit number, the fractional part is zero.
        if (y == uUNIT) {
            return wrap(resultInt * sign);
        }

        // Calculate the fractional part via the iterative approximation.
        // The `delta >>= 1` part is equivalent to `delta /= 2`, but shifting bits is more gas efficient.
        int256 DOUBLE_UNIT = 2e18;
        for (int256 delta = uHALF_UNIT; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT;

            // Is y^2 >= 2e18 and so in the range [2e18, 4e18)?
            if (y >= DOUBLE_UNIT) {
                // Add the 2^{-m} factor to the logarithm.
                resultInt = resultInt + delta;

                // Halve y, which corresponds to z/2 in the Wikipedia article.
                y >>= 1;
            }
        }
        resultInt *= sign;
        result = wrap(resultInt);
    }
}

/// @notice Multiplies two SD59x18 numbers together, returning a new SD59x18 number.
///
/// @dev Notes:
/// - Refer to the notes in {Common.mulDiv18}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv18}.
/// - None of the inputs can be `MIN_SD59x18`.
/// - The result must fit in SD59x18.
///
/// @param x The multiplicand as an SD59x18 number.
/// @param y The multiplier as an SD59x18 number.
/// @return result The product as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function mul(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert Errors.PRBMath_SD59x18_Mul_InputTooSmall();
    }

    // Get hold of the absolute values of x and y.
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }

    // Compute the absolute value (x*y÷UNIT). The resulting value must fit in SD59x18.
    uint256 resultAbs = Common.mulDiv18(xAbs, yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Mul_Overflow(x, y);
    }

    // Check if x and y have the same sign using two's complement representation. The left-most bit represents the sign (1 for
    // negative, 0 for positive or zero).
    bool sameSign = (xInt ^ yInt) > -1;

    // If the inputs have the same sign, the result should be positive. Otherwise, it should be negative.
    unchecked {
        result = wrap(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}

/// @notice Raises x to the power of y using the following formula:
///
/// $$
/// x^y = 2^{log_2{x} * y}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {exp2}, {log2}, and {mul}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - Refer to the requirements in {exp2}, {log2}, and {mul}.
///
/// @param x The base as an SD59x18 number.
/// @param y Exponent to raise x to, as an SD59x18 number
/// @return result x raised to power y, as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function pow(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    int256 yInt = y.unwrap();

    // If both x and y are zero, the result is `UNIT`. If just x is zero, the result is always zero.
    if (xInt == 0) {
        return yInt == 0 ? UNIT : ZERO;
    }
    // If x is `UNIT`, the result is always `UNIT`.
    else if (xInt == uUNIT) {
        return UNIT;
    }

    // If y is zero, the result is always `UNIT`.
    if (yInt == 0) {
        return UNIT;
    }
    // If y is `UNIT`, the result is always x.
    else if (yInt == uUNIT) {
        return x;
    }

    // Calculate the result using the formula.
    result = exp2(mul(log2(x), y));
}

/// @notice Raises x (an SD59x18 number) to the power y (an unsigned basic integer) using the well-known
/// algorithm "exponentiation by squaring".
///
/// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv18}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - Refer to the requirements in {abs} and {Common.mulDiv18}.
/// - The result must fit in SD59x18.
///
/// @param x The base as an SD59x18 number.
/// @param y The exponent as a uint256.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function powu(SD59x18 x, uint256 y) pure returns (SD59x18 result) {
    uint256 xAbs = uint256(abs(x).unwrap());

    // Calculate the first iteration of the loop in advance.
    uint256 resultAbs = y & 1 > 0 ? xAbs : uint256(uUNIT);

    // Equivalent to `for(y /= 2; y > 0; y /= 2)`.
    uint256 yAux = y;
    for (yAux >>= 1; yAux > 0; yAux >>= 1) {
        xAbs = Common.mulDiv18(xAbs, xAbs);

        // Equivalent to `y % 2 == 1`.
        if (yAux & 1 > 0) {
            resultAbs = Common.mulDiv18(resultAbs, xAbs);
        }
    }

    // The result must fit in SD59x18.
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert Errors.PRBMath_SD59x18_Powu_Overflow(x, y);
    }

    unchecked {
        // Is the base negative and the exponent odd? If yes, the result should be negative.
        int256 resultInt = int256(resultAbs);
        bool isNegative = x.unwrap() < 0 && y & 1 == 1;
        if (isNegative) {
            resultInt = -resultInt;
        }
        result = wrap(resultInt);
    }
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - Only the positive root is returned.
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x cannot be negative, since complex numbers are not supported.
/// - x must be less than `MAX_SD59x18 / UNIT`.
///
/// @param x The SD59x18 number for which to calculate the square root.
/// @return result The result as an SD59x18 number.
/// @custom:smtchecker abstract-function-nondet
function sqrt(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap();
    if (xInt < 0) {
        revert Errors.PRBMath_SD59x18_Sqrt_NegativeInput(x);
    }
    if (xInt > uMAX_SD59x18 / uUNIT) {
        revert Errors.PRBMath_SD59x18_Sqrt_Overflow(x);
    }

    unchecked {
        // Multiply x by `UNIT` to account for the factor of `UNIT` picked up when multiplying two SD59x18 numbers.
        // In this case, the two numbers are both the square root.
        uint256 resultUint = Common.sqrt(uint256(xInt * uUNIT));
        result = wrap(int256(resultUint));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;
import "./Helpers.sol" as Helpers;
import "./Math.sol" as Math;

/// @notice The signed 59.18-decimal fixed-point number representation, which can have up to 59 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type int256.
type SD59x18 is int256;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoInt256,
    Casting.intoSD1x18,
    Casting.intoUD2x18,
    Casting.intoUD60x18,
    Casting.intoUint256,
    Casting.intoUint128,
    Casting.intoUint40,
    Casting.unwrap
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

using {
    Math.abs,
    Math.avg,
    Math.ceil,
    Math.div,
    Math.exp,
    Math.exp2,
    Math.floor,
    Math.frac,
    Math.gm,
    Math.inv,
    Math.log10,
    Math.log2,
    Math.ln,
    Math.mul,
    Math.pow,
    Math.powu,
    Math.sqrt
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                HELPER FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

using {
    Helpers.add,
    Helpers.and,
    Helpers.eq,
    Helpers.gt,
    Helpers.gte,
    Helpers.isZero,
    Helpers.lshift,
    Helpers.lt,
    Helpers.lte,
    Helpers.mod,
    Helpers.neq,
    Helpers.not,
    Helpers.or,
    Helpers.rshift,
    Helpers.sub,
    Helpers.uncheckedAdd,
    Helpers.uncheckedSub,
    Helpers.uncheckedUnary,
    Helpers.xor
} for SD59x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                    OPERATORS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes it possible to use these operators on the SD59x18 type.
using {
    Helpers.add as +,
    Helpers.and2 as &,
    Math.div as /,
    Helpers.eq as ==,
    Helpers.gt as >,
    Helpers.gte as >=,
    Helpers.lt as <,
    Helpers.lte as <=,
    Helpers.mod as %,
    Math.mul as *,
    Helpers.neq as !=,
    Helpers.not as ~,
    Helpers.or as |,
    Helpers.sub as -,
    Helpers.unary as -,
    Helpers.xor as ^
} for SD59x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import { uMAX_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD60x18 } from "../ud60x18/ValueType.sol";
import { UD2x18 } from "./ValueType.sol";

/// @notice Casts a UD2x18 number into SD1x18.
/// - x must be less than or equal to `uMAX_SD1x18`.
function intoSD1x18(UD2x18 x) pure returns (SD1x18 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(uMAX_SD1x18)) {
        revert Errors.PRBMath_UD2x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xUint));
}

/// @notice Casts a UD2x18 number into SD59x18.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of SD59x18.
function intoSD59x18(UD2x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(uint256(UD2x18.unwrap(x))));
}

/// @notice Casts a UD2x18 number into UD60x18.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of UD60x18.
function intoUD60x18(UD2x18 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint128.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of uint128.
function intoUint128(UD2x18 x) pure returns (uint128 result) {
    result = uint128(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint256.
/// @dev There is no overflow check because the domain of UD2x18 is a subset of uint256.
function intoUint256(UD2x18 x) pure returns (uint256 result) {
    result = uint256(UD2x18.unwrap(x));
}

/// @notice Casts a UD2x18 number into uint40.
/// @dev Requirements:
/// - x must be less than or equal to `MAX_UINT40`.
function intoUint40(UD2x18 x) pure returns (uint40 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(Common.MAX_UINT40)) {
        revert Errors.PRBMath_UD2x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}

/// @notice Alias for {wrap}.
function ud2x18(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}

/// @notice Unwrap a UD2x18 number into uint64.
function unwrap(UD2x18 x) pure returns (uint64 result) {
    result = UD2x18.unwrap(x);
}

/// @notice Wraps a uint64 number into UD2x18.
function wrap(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD2x18 } from "./ValueType.sol";

/// @dev Euler's number as a UD2x18 number.
UD2x18 constant E = UD2x18.wrap(2_718281828459045235);

/// @dev The maximum value a UD2x18 number can have.
uint64 constant uMAX_UD2x18 = 18_446744073709551615;
UD2x18 constant MAX_UD2x18 = UD2x18.wrap(uMAX_UD2x18);

/// @dev PI as a UD2x18 number.
UD2x18 constant PI = UD2x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of UD2x18.
uint256 constant uUNIT = 1e18;
UD2x18 constant UNIT = UD2x18.wrap(1e18);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD2x18 } from "./ValueType.sol";

/// @notice Thrown when trying to cast a UD2x18 number that doesn't fit in SD1x18.
error PRBMath_UD2x18_IntoSD1x18_Overflow(UD2x18 x);

/// @notice Thrown when trying to cast a UD2x18 number that doesn't fit in uint40.
error PRBMath_UD2x18_IntoUint40_Overflow(UD2x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;

/// @notice The unsigned 2.18-decimal fixed-point number representation, which can have up to 2 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the underlying Solidity
/// type uint64. This is useful when end users want to use uint64 to save gas, e.g. with tight variable packing in contract
/// storage.
type UD2x18 is uint64;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD1x18,
    Casting.intoSD59x18,
    Casting.intoUD60x18,
    Casting.intoUint256,
    Casting.intoUint128,
    Casting.intoUint40,
    Casting.unwrap
} for UD2x18 global;
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Errors.sol" as CastingErrors;
import { MAX_UINT128, MAX_UINT40 } from "../Common.sol";
import { uMAX_SD1x18 } from "../sd1x18/Constants.sol";
import { SD1x18 } from "../sd1x18/ValueType.sol";
import { uMAX_SD59x18 } from "../sd59x18/Constants.sol";
import { SD59x18 } from "../sd59x18/ValueType.sol";
import { uMAX_UD2x18 } from "../ud2x18/Constants.sol";
import { UD2x18 } from "../ud2x18/ValueType.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Casts a UD60x18 number into SD1x18.
/// @dev Requirements:
/// - x must be less than or equal to `uMAX_SD1x18`.
function intoSD1x18(UD60x18 x) pure returns (SD1x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(int256(uMAX_SD1x18))) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(uint64(xUint)));
}

/// @notice Casts a UD60x18 number into UD2x18.
/// @dev Requirements:
/// - x must be less than or equal to `uMAX_UD2x18`.
function intoUD2x18(UD60x18 x) pure returns (UD2x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uMAX_UD2x18) {
        revert CastingErrors.PRBMath_UD60x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(xUint));
}

/// @notice Casts a UD60x18 number into SD59x18.
/// @dev Requirements:
/// - x must be less than or equal to `uMAX_SD59x18`.
function intoSD59x18(UD60x18 x) pure returns (SD59x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(uMAX_SD59x18)) {
        revert CastingErrors.PRBMath_UD60x18_IntoSD59x18_Overflow(x);
    }
    result = SD59x18.wrap(int256(xUint));
}

/// @notice Casts a UD60x18 number into uint128.
/// @dev This is basically an alias for {unwrap}.
function intoUint256(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}

/// @notice Casts a UD60x18 number into uint128.
/// @dev Requirements:
/// - x must be less than or equal to `MAX_UINT128`.
function intoUint128(UD60x18 x) pure returns (uint128 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT128) {
        revert CastingErrors.PRBMath_UD60x18_IntoUint128_Overflow(x);
    }
    result = uint128(xUint);
}

/// @notice Casts a UD60x18 number into uint40.
/// @dev Requirements:
/// - x must be less than or equal to `MAX_UINT40`.
function intoUint40(UD60x18 x) pure returns (uint40 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT40) {
        revert CastingErrors.PRBMath_UD60x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}

/// @notice Alias for {wrap}.
function ud(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}

/// @notice Alias for {wrap}.
function ud60x18(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}

/// @notice Unwraps a UD60x18 number into uint256.
function unwrap(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}

/// @notice Wraps a uint256 number into the UD60x18 value type.
function wrap(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD60x18 } from "./ValueType.sol";

// NOTICE: the "u" prefix stands for "unwrapped".

/// @dev Euler's number as a UD60x18 number.
UD60x18 constant E = UD60x18.wrap(2_718281828459045235);

/// @dev The maximum input permitted in {exp}.
uint256 constant uEXP_MAX_INPUT = 133_084258667509499440;
UD60x18 constant EXP_MAX_INPUT = UD60x18.wrap(uEXP_MAX_INPUT);

/// @dev The maximum input permitted in {exp2}.
uint256 constant uEXP2_MAX_INPUT = 192e18 - 1;
UD60x18 constant EXP2_MAX_INPUT = UD60x18.wrap(uEXP2_MAX_INPUT);

/// @dev Half the UNIT number.
uint256 constant uHALF_UNIT = 0.5e18;
UD60x18 constant HALF_UNIT = UD60x18.wrap(uHALF_UNIT);

/// @dev $log_2(10)$ as a UD60x18 number.
uint256 constant uLOG2_10 = 3_321928094887362347;
UD60x18 constant LOG2_10 = UD60x18.wrap(uLOG2_10);

/// @dev $log_2(e)$ as a UD60x18 number.
uint256 constant uLOG2_E = 1_442695040888963407;
UD60x18 constant LOG2_E = UD60x18.wrap(uLOG2_E);

/// @dev The maximum value a UD60x18 number can have.
uint256 constant uMAX_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_584007913129639935;
UD60x18 constant MAX_UD60x18 = UD60x18.wrap(uMAX_UD60x18);

/// @dev The maximum whole value a UD60x18 number can have.
uint256 constant uMAX_WHOLE_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_000000000000000000;
UD60x18 constant MAX_WHOLE_UD60x18 = UD60x18.wrap(uMAX_WHOLE_UD60x18);

/// @dev PI as a UD60x18 number.
UD60x18 constant PI = UD60x18.wrap(3_141592653589793238);

/// @dev The unit number, which gives the decimal precision of UD60x18.
uint256 constant uUNIT = 1e18;
UD60x18 constant UNIT = UD60x18.wrap(uUNIT);

/// @dev The unit number squared.
uint256 constant uUNIT_SQUARED = 1e36;
UD60x18 constant UNIT_SQUARED = UD60x18.wrap(uUNIT_SQUARED);

/// @dev Zero as a UD60x18 number.
UD60x18 constant ZERO = UD60x18.wrap(0);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { uMAX_UD60x18, uUNIT } from "./Constants.sol";
import { PRBMath_UD60x18_Convert_Overflow } from "./Errors.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Converts a UD60x18 number to a simple integer by dividing it by `UNIT`.
/// @dev The result is rounded toward zero.
/// @param x The UD60x18 number to convert.
/// @return result The same number in basic integer form.
function convert(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x) / uUNIT;
}

/// @notice Converts a simple integer to UD60x18 by multiplying it by `UNIT`.
///
/// @dev Requirements:
/// - x must be less than or equal to `MAX_UD60x18 / UNIT`.
///
/// @param x The basic integer to convert.
/// @param result The same number converted to UD60x18.
function convert(uint256 x) pure returns (UD60x18 result) {
    if (x > uMAX_UD60x18 / uUNIT) {
        revert PRBMath_UD60x18_Convert_Overflow(x);
    }
    unchecked {
        result = UD60x18.wrap(x * uUNIT);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { UD60x18 } from "./ValueType.sol";

/// @notice Thrown when ceiling a number overflows UD60x18.
error PRBMath_UD60x18_Ceil_Overflow(UD60x18 x);

/// @notice Thrown when converting a basic integer to the fixed-point format overflows UD60x18.
error PRBMath_UD60x18_Convert_Overflow(uint256 x);

/// @notice Thrown when taking the natural exponent of a base greater than 133_084258667509499441.
error PRBMath_UD60x18_Exp_InputTooBig(UD60x18 x);

/// @notice Thrown when taking the binary exponent of a base greater than 192e18.
error PRBMath_UD60x18_Exp2_InputTooBig(UD60x18 x);

/// @notice Thrown when taking the geometric mean of two numbers and multiplying them overflows UD60x18.
error PRBMath_UD60x18_Gm_Overflow(UD60x18 x, UD60x18 y);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD1x18.
error PRBMath_UD60x18_IntoSD1x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in SD59x18.
error PRBMath_UD60x18_IntoSD59x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in UD2x18.
error PRBMath_UD60x18_IntoUD2x18_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint128.
error PRBMath_UD60x18_IntoUint128_Overflow(UD60x18 x);

/// @notice Thrown when trying to cast a UD60x18 number that doesn't fit in uint40.
error PRBMath_UD60x18_IntoUint40_Overflow(UD60x18 x);

/// @notice Thrown when taking the logarithm of a number less than 1.
error PRBMath_UD60x18_Log_InputTooSmall(UD60x18 x);

/// @notice Thrown when calculating the square root overflows UD60x18.
error PRBMath_UD60x18_Sqrt_Overflow(UD60x18 x);
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { wrap } from "./Casting.sol";
import { UD60x18 } from "./ValueType.sol";

/// @notice Implements the checked addition operation (+) in the UD60x18 type.
function add(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() + y.unwrap());
}

/// @notice Implements the AND (&) bitwise operation in the UD60x18 type.
function and(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() & bits);
}

/// @notice Implements the AND (&) bitwise operation in the UD60x18 type.
function and2(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() & y.unwrap());
}

/// @notice Implements the equal operation (==) in the UD60x18 type.
function eq(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() == y.unwrap();
}

/// @notice Implements the greater than operation (>) in the UD60x18 type.
function gt(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() > y.unwrap();
}

/// @notice Implements the greater than or equal to operation (>=) in the UD60x18 type.
function gte(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() >= y.unwrap();
}

/// @notice Implements a zero comparison check function in the UD60x18 type.
function isZero(UD60x18 x) pure returns (bool result) {
    // This wouldn't work if x could be negative.
    result = x.unwrap() == 0;
}

/// @notice Implements the left shift operation (<<) in the UD60x18 type.
function lshift(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() << bits);
}

/// @notice Implements the lower than operation (<) in the UD60x18 type.
function lt(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() < y.unwrap();
}

/// @notice Implements the lower than or equal to operation (<=) in the UD60x18 type.
function lte(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() <= y.unwrap();
}

/// @notice Implements the checked modulo operation (%) in the UD60x18 type.
function mod(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() % y.unwrap());
}

/// @notice Implements the not equal operation (!=) in the UD60x18 type.
function neq(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap() != y.unwrap();
}

/// @notice Implements the NOT (~) bitwise operation in the UD60x18 type.
function not(UD60x18 x) pure returns (UD60x18 result) {
    result = wrap(~x.unwrap());
}

/// @notice Implements the OR (|) bitwise operation in the UD60x18 type.
function or(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() | y.unwrap());
}

/// @notice Implements the right shift operation (>>) in the UD60x18 type.
function rshift(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() >> bits);
}

/// @notice Implements the checked subtraction operation (-) in the UD60x18 type.
function sub(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() - y.unwrap());
}

/// @notice Implements the unchecked addition operation (+) in the UD60x18 type.
function uncheckedAdd(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(x.unwrap() + y.unwrap());
    }
}

/// @notice Implements the unchecked subtraction operation (-) in the UD60x18 type.
function uncheckedSub(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(x.unwrap() - y.unwrap());
    }
}

/// @notice Implements the XOR (^) bitwise operation in the UD60x18 type.
function xor(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(x.unwrap() ^ y.unwrap());
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "../Common.sol" as Common;
import "./Errors.sol" as Errors;
import { wrap } from "./Casting.sol";
import {
    uEXP_MAX_INPUT,
    uEXP2_MAX_INPUT,
    uHALF_UNIT,
    uLOG2_10,
    uLOG2_E,
    uMAX_UD60x18,
    uMAX_WHOLE_UD60x18,
    UNIT,
    uUNIT,
    uUNIT_SQUARED,
    ZERO
} from "./Constants.sol";
import { UD60x18 } from "./ValueType.sol";

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

/// @notice Calculates the arithmetic average of x and y using the following formula:
///
/// $$
/// avg(x, y) = (x & y) + ((xUint ^ yUint) / 2)
/// $$
//
/// In English, this is what this formula does:
///
/// 1. AND x and y.
/// 2. Calculate half of XOR x and y.
/// 3. Add the two results together.
///
/// This technique is known as SWAR, which stands for "SIMD within a register". You can read more about it here:
/// https://devblogs.microsoft.com/oldnewthing/20220207-00/?p=106223
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// @param x The first operand as a UD60x18 number.
/// @param y The second operand as a UD60x18 number.
/// @return result The arithmetic average as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function avg(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();
    unchecked {
        result = wrap((xUint & yUint) + ((xUint ^ yUint) >> 1));
    }
}

/// @notice Yields the smallest whole number greater than or equal to x.
///
/// @dev This is optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional
/// counterparts. See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
///
/// Requirements:
/// - x must be less than or equal to `MAX_WHOLE_UD60x18`.
///
/// @param x The UD60x18 number to ceil.
/// @param result The smallest whole number greater than or equal to x, as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function ceil(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    if (xUint > uMAX_WHOLE_UD60x18) {
        revert Errors.PRBMath_UD60x18_Ceil_Overflow(x);
    }

    assembly ("memory-safe") {
        // Equivalent to `x % UNIT`.
        let remainder := mod(x, uUNIT)

        // Equivalent to `UNIT - remainder`.
        let delta := sub(uUNIT, remainder)

        // Equivalent to `x + remainder > 0 ? delta : 0`.
        result := add(x, mul(delta, gt(remainder, 0)))
    }
}

/// @notice Divides two UD60x18 numbers, returning a new UD60x18 number.
///
/// @dev Uses {Common.mulDiv} to enable overflow-safe multiplication and division.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
///
/// @param x The numerator as a UD60x18 number.
/// @param y The denominator as a UD60x18 number.
/// @param result The quotient as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function div(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(Common.mulDiv(x.unwrap(), uUNIT, y.unwrap()));
}

/// @notice Calculates the natural exponent of x using the following formula:
///
/// $$
/// e^x = 2^{x * log_2{e}}
/// $$
///
/// @dev Requirements:
/// - x must be less than 133_084258667509499441.
///
/// @param x The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    // This check prevents values greater than 192e18 from being passed to {exp2}.
    if (xUint > uEXP_MAX_INPUT) {
        revert Errors.PRBMath_UD60x18_Exp_InputTooBig(x);
    }

    unchecked {
        // Inline the fixed-point multiplication to save gas.
        uint256 doubleUnitProduct = xUint * uLOG2_E;
        result = exp2(wrap(doubleUnitProduct / uUNIT));
    }
}

/// @notice Calculates the binary exponent of x using the binary fraction method.
///
/// @dev See https://ethereum.stackexchange.com/q/79903/24693
///
/// Requirements:
/// - x must be less than 192e18.
/// - The result must fit in UD60x18.
///
/// @param x The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function exp2(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    // Numbers greater than or equal to 192e18 don't fit in the 192.64-bit format.
    if (xUint > uEXP2_MAX_INPUT) {
        revert Errors.PRBMath_UD60x18_Exp2_InputTooBig(x);
    }

    // Convert x to the 192.64-bit fixed-point format.
    uint256 x_192x64 = (xUint << 64) / uUNIT;

    // Pass x to the {Common.exp2} function, which uses the 192.64-bit fixed-point number representation.
    result = wrap(Common.exp2(x_192x64));
}

/// @notice Yields the greatest whole number less than or equal to x.
/// @dev Optimized for fractional value inputs, because every whole value has (1e18 - 1) fractional counterparts.
/// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
/// @param x The UD60x18 number to floor.
/// @param result The greatest whole number less than or equal to x, as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function floor(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        // Equivalent to `x % UNIT`.
        let remainder := mod(x, uUNIT)

        // Equivalent to `x - remainder > 0 ? remainder : 0)`.
        result := sub(x, mul(remainder, gt(remainder, 0)))
    }
}

/// @notice Yields the excess beyond the floor of x using the odd function definition.
/// @dev See https://en.wikipedia.org/wiki/Fractional_part.
/// @param x The UD60x18 number to get the fractional part of.
/// @param result The fractional part of x as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function frac(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        result := mod(x, uUNIT)
    }
}

/// @notice Calculates the geometric mean of x and y, i.e. $\sqrt{x * y}$, rounding down.
///
/// @dev Requirements:
/// - x * y must fit in UD60x18.
///
/// @param x The first operand as a UD60x18 number.
/// @param y The second operand as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function gm(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();
    if (xUint == 0 || yUint == 0) {
        return ZERO;
    }

    unchecked {
        // Checking for overflow this way is faster than letting Solidity do it.
        uint256 xyUint = xUint * yUint;
        if (xyUint / xUint != yUint) {
            revert Errors.PRBMath_UD60x18_Gm_Overflow(x, y);
        }

        // We don't need to multiply the result by `UNIT` here because the x*y product picked up a factor of `UNIT`
        // during multiplication. See the comments in {Common.sqrt}.
        result = wrap(Common.sqrt(xyUint));
    }
}

/// @notice Calculates the inverse of x.
///
/// @dev Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x must not be zero.
///
/// @param x The UD60x18 number for which to calculate the inverse.
/// @return result The inverse as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function inv(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        result = wrap(uUNIT_SQUARED / x.unwrap());
    }
}

/// @notice Calculates the natural logarithm of x using the following formula:
///
/// $$
/// ln{x} = log_2{x} / log_2{e}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
/// - The precision isn't sufficiently fine-grained to return exactly `UNIT` when the input is `E`.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The UD60x18 number for which to calculate the natural logarithm.
/// @return result The natural logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function ln(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        // Inline the fixed-point multiplication to save gas. This is overflow-safe because the maximum value that
        // {log2} can return is ~196_205294292027477728.
        result = wrap(log2(x).unwrap() * uUNIT / uLOG2_E);
    }
}

/// @notice Calculates the common logarithm of x using the following formula:
///
/// $$
/// log_{10}{x} = log_2{x} / log_2{10}
/// $$
///
/// However, if x is an exact power of ten, a hard coded value is returned.
///
/// @dev Notes:
/// - Refer to the notes in {log2}.
///
/// Requirements:
/// - Refer to the requirements in {log2}.
///
/// @param x The UD60x18 number for which to calculate the common logarithm.
/// @return result The common logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function log10(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    if (xUint < uUNIT) {
        revert Errors.PRBMath_UD60x18_Log_InputTooSmall(x);
    }

    // Note that the `mul` in this assembly block is the standard multiplication operation, not {UD60x18.mul}.
    // prettier-ignore
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT, sub(0, 18)) }
        case 10 { result := mul(uUNIT, sub(1, 18)) }
        case 100 { result := mul(uUNIT, sub(2, 18)) }
        case 1000 { result := mul(uUNIT, sub(3, 18)) }
        case 10000 { result := mul(uUNIT, sub(4, 18)) }
        case 100000 { result := mul(uUNIT, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT }
        case 100000000000000000000 { result := mul(uUNIT, 2) }
        case 1000000000000000000000 { result := mul(uUNIT, 3) }
        case 10000000000000000000000 { result := mul(uUNIT, 4) }
        case 100000000000000000000000 { result := mul(uUNIT, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 58) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT, 59) }
        default { result := uMAX_UD60x18 }
    }

    if (result.unwrap() == uMAX_UD60x18) {
        unchecked {
            // Inline the fixed-point division to save gas.
            result = wrap(log2(x).unwrap() * uUNIT / uLOG2_10);
        }
    }
}

/// @notice Calculates the binary logarithm of x using the iterative approximation algorithm:
///
/// $$
/// log_2{x} = n + log_2{y}, \text{ where } y = x*2^{-n}, \ y \in [1, 2)
/// $$
///
/// For $0 \leq x \lt 1$, the input is inverted:
///
/// $$
/// log_2{x} = -log_2{\frac{1}{x}}
/// $$
///
/// @dev See https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation
///
/// Notes:
/// - Due to the lossy precision of the iterative approximation, the results are not perfectly accurate to the last decimal.
///
/// Requirements:
/// - x must be greater than zero.
///
/// @param x The UD60x18 number for which to calculate the binary logarithm.
/// @return result The binary logarithm as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function log2(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    if (xUint < uUNIT) {
        revert Errors.PRBMath_UD60x18_Log_InputTooSmall(x);
    }

    unchecked {
        // Calculate the integer part of the logarithm.
        uint256 n = Common.msb(xUint / uUNIT);

        // This is the integer part of the logarithm as a UD60x18 number. The operation can't overflow because n
        // n is at most 255 and UNIT is 1e18.
        uint256 resultUint = n * uUNIT;

        // Calculate $y = x * 2^{-n}$.
        uint256 y = xUint >> n;

        // If y is the unit number, the fractional part is zero.
        if (y == uUNIT) {
            return wrap(resultUint);
        }

        // Calculate the fractional part via the iterative approximation.
        // The `delta >>= 1` part is equivalent to `delta /= 2`, but shifting bits is more gas efficient.
        uint256 DOUBLE_UNIT = 2e18;
        for (uint256 delta = uHALF_UNIT; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT;

            // Is y^2 >= 2e18 and so in the range [2e18, 4e18)?
            if (y >= DOUBLE_UNIT) {
                // Add the 2^{-m} factor to the logarithm.
                resultUint += delta;

                // Halve y, which corresponds to z/2 in the Wikipedia article.
                y >>= 1;
            }
        }
        result = wrap(resultUint);
    }
}

/// @notice Multiplies two UD60x18 numbers together, returning a new UD60x18 number.
///
/// @dev Uses {Common.mulDiv} to enable overflow-safe multiplication and division.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv}.
///
/// Requirements:
/// - Refer to the requirements in {Common.mulDiv}.
///
/// @dev See the documentation in {Common.mulDiv18}.
/// @param x The multiplicand as a UD60x18 number.
/// @param y The multiplier as a UD60x18 number.
/// @return result The product as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function mul(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap(Common.mulDiv18(x.unwrap(), y.unwrap()));
}

/// @notice Raises x to the power of y.
///
/// For $1 \leq x \leq \infty$, the following standard formula is used:
///
/// $$
/// x^y = 2^{log_2{x} * y}
/// $$
///
/// For $0 \leq x \lt 1$, since the unsigned {log2} is undefined, an equivalent formula is used:
///
/// $$
/// i = \frac{1}{x}
/// w = 2^{log_2{i} * y}
/// x^y = \frac{1}{w}
/// $$
///
/// @dev Notes:
/// - Refer to the notes in {log2} and {mul}.
/// - Returns `UNIT` for 0^0.
/// - It may not perform well with very small values of x. Consider using SD59x18 as an alternative.
///
/// Requirements:
/// - Refer to the requirements in {exp2}, {log2}, and {mul}.
///
/// @param x The base as a UD60x18 number.
/// @param y The exponent as a UD60x18 number.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function pow(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();
    uint256 yUint = y.unwrap();

    // If both x and y are zero, the result is `UNIT`. If just x is zero, the result is always zero.
    if (xUint == 0) {
        return yUint == 0 ? UNIT : ZERO;
    }
    // If x is `UNIT`, the result is always `UNIT`.
    else if (xUint == uUNIT) {
        return UNIT;
    }

    // If y is zero, the result is always `UNIT`.
    if (yUint == 0) {
        return UNIT;
    }
    // If y is `UNIT`, the result is always x.
    else if (yUint == uUNIT) {
        return x;
    }

    // If x is greater than `UNIT`, use the standard formula.
    if (xUint > uUNIT) {
        result = exp2(mul(log2(x), y));
    }
    // Conversely, if x is less than `UNIT`, use the equivalent formula.
    else {
        UD60x18 i = wrap(uUNIT_SQUARED / xUint);
        UD60x18 w = exp2(mul(log2(i), y));
        result = wrap(uUNIT_SQUARED / w.unwrap());
    }
}

/// @notice Raises x (a UD60x18 number) to the power y (an unsigned basic integer) using the well-known
/// algorithm "exponentiation by squaring".
///
/// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring.
///
/// Notes:
/// - Refer to the notes in {Common.mulDiv18}.
/// - Returns `UNIT` for 0^0.
///
/// Requirements:
/// - The result must fit in UD60x18.
///
/// @param x The base as a UD60x18 number.
/// @param y The exponent as a uint256.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function powu(UD60x18 x, uint256 y) pure returns (UD60x18 result) {
    // Calculate the first iteration of the loop in advance.
    uint256 xUint = x.unwrap();
    uint256 resultUint = y & 1 > 0 ? xUint : uUNIT;

    // Equivalent to `for(y /= 2; y > 0; y /= 2)`.
    for (y >>= 1; y > 0; y >>= 1) {
        xUint = Common.mulDiv18(xUint, xUint);

        // Equivalent to `y % 2 == 1`.
        if (y & 1 > 0) {
            resultUint = Common.mulDiv18(resultUint, xUint);
        }
    }
    result = wrap(resultUint);
}

/// @notice Calculates the square root of x using the Babylonian method.
///
/// @dev See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
///
/// Notes:
/// - The result is rounded toward zero.
///
/// Requirements:
/// - x must be less than `MAX_UD60x18 / UNIT`.
///
/// @param x The UD60x18 number for which to calculate the square root.
/// @return result The result as a UD60x18 number.
/// @custom:smtchecker abstract-function-nondet
function sqrt(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap();

    unchecked {
        if (xUint > uMAX_UD60x18 / uUNIT) {
            revert Errors.PRBMath_UD60x18_Sqrt_Overflow(x);
        }
        // Multiply x by `UNIT` to account for the factor of `UNIT` picked up when multiplying two UD60x18 numbers.
        // In this case, the two numbers are both the square root.
        result = wrap(Common.sqrt(xUint * uUNIT));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "./Casting.sol" as Casting;
import "./Helpers.sol" as Helpers;
import "./Math.sol" as Math;

/// @notice The unsigned 60.18-decimal fixed-point number representation, which can have up to 60 digits and up to 18
/// decimals. The values of this are bound by the minimum and the maximum values permitted by the Solidity type uint256.
/// @dev The value type is defined here so it can be imported in all other files.
type UD60x18 is uint256;

/*//////////////////////////////////////////////////////////////////////////
                                    CASTING
//////////////////////////////////////////////////////////////////////////*/

using {
    Casting.intoSD1x18,
    Casting.intoUD2x18,
    Casting.intoSD59x18,
    Casting.intoUint128,
    Casting.intoUint256,
    Casting.intoUint40,
    Casting.unwrap
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                            MATHEMATICAL FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes the functions in this library callable on the UD60x18 type.
using {
    Math.avg,
    Math.ceil,
    Math.div,
    Math.exp,
    Math.exp2,
    Math.floor,
    Math.frac,
    Math.gm,
    Math.inv,
    Math.ln,
    Math.log10,
    Math.log2,
    Math.mul,
    Math.pow,
    Math.powu,
    Math.sqrt
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                HELPER FUNCTIONS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes the functions in this library callable on the UD60x18 type.
using {
    Helpers.add,
    Helpers.and,
    Helpers.eq,
    Helpers.gt,
    Helpers.gte,
    Helpers.isZero,
    Helpers.lshift,
    Helpers.lt,
    Helpers.lte,
    Helpers.mod,
    Helpers.neq,
    Helpers.not,
    Helpers.or,
    Helpers.rshift,
    Helpers.sub,
    Helpers.uncheckedAdd,
    Helpers.uncheckedSub,
    Helpers.xor
} for UD60x18 global;

/*//////////////////////////////////////////////////////////////////////////
                                    OPERATORS
//////////////////////////////////////////////////////////////////////////*/

// The global "using for" directive makes it possible to use these operators on the UD60x18 type.
using {
    Helpers.add as +,
    Helpers.and2 as &,
    Math.div as /,
    Helpers.eq as ==,
    Helpers.gt as >,
    Helpers.gte as >=,
    Helpers.lt as <,
    Helpers.lte as <=,
    Helpers.or as |,
    Helpers.mod as %,
    Math.mul as *,
    Helpers.neq as !=,
    Helpers.not as ~,
    Helpers.sub as -,
    Helpers.xor as ^
} for UD60x18 global;
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/**
 * @title Abstract ownable contract that can be inherited by other contracts
 * @notice Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The `owner` is first set by passing the address of the `initialOwner` to the Ownable constructor.
 *
 * The owner account can be transferred through a two steps process:
 *      1. The current `owner` calls {transferOwnership} to set a `pendingOwner`
 *      2. The `pendingOwner` calls {claimOwnership} to accept the ownership transfer
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to the owner.
 */
abstract contract Ownable {
    address private _owner;
    address private _pendingOwner;

    /**
     * @dev Emitted when `_pendingOwner` has been changed.
     * @param pendingOwner new `_pendingOwner` address.
     */
    event OwnershipOffered(address indexed pendingOwner);

    /**
     * @dev Emitted when `_owner` has been changed.
     * @param previousOwner previous `_owner` address.
     * @param newOwner new `_owner` address.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /* ============ Deploy ============ */

    /**
     * @notice Initializes the contract setting `_initialOwner` as the initial owner.
     * @param _initialOwner Initial owner of the contract.
     */
    constructor(address _initialOwner) {
        _setOwner(_initialOwner);
    }

    /* ============ External Functions ============ */

    /**
     * @notice Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @notice Gets current `_pendingOwner`.
     * @return Current `_pendingOwner` address.
     */
    function pendingOwner() external view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @notice Renounce ownership of the contract.
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
    * @notice Allows current owner to set the `_pendingOwner` address.
    * @param _newOwner Address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Ownable/pendingOwner-not-zero-address");

        _pendingOwner = _newOwner;

        emit OwnershipOffered(_newOwner);
    }

    /**
    * @notice Allows the `_pendingOwner` address to finalize the transfer.
    * @dev This function is only callable by the `_pendingOwner`.
    */
    function claimOwnership() external onlyPendingOwner {
        _setOwner(_pendingOwner);
        _pendingOwner = address(0);
    }

    /* ============ Internal Functions ============ */

    /**
     * @notice Internal function to set the `_owner` of the contract.
     * @param _newOwner New `_owner` address.
     */
    function _setOwner(address _newOwner) private {
        address _oldOwner = _owner;
        _owner = _newOwner;
        emit OwnershipTransferred(_oldOwner, _newOwner);
    }

    /* ============ Modifier Functions ============ */

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable/caller-not-owner");
        _;
    }

    /**
    * @dev Throws if called by any account other than the `pendingOwner`.
    */
    modifier onlyPendingOwner() {
        require(msg.sender == _pendingOwner, "Ownable/caller-not-pendingOwner");
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @notice Thrown if the executor is set to the zero address.
error ExecutorZeroAddress();

/**
 * @title ExecutorAware abstract contract
 * @notice The ExecutorAware contract allows contracts on a receiving chain to execute messages from an origin chain.
 *         These messages are sent by the `MessageDispatcher` contract which live on the origin chain.
 *         The `MessageExecutor` contract on the receiving chain executes these messages
 *         and then forward them to an ExecutorAware contract on the receiving chain.
 * @dev This contract implements EIP-2771 (https://eips.ethereum.org/EIPS/eip-2771)
 *      to ensure that messages are sent by a trusted `MessageExecutor` contract.
 */
abstract contract ExecutorAware {
  /* ============ Events ============ */

  /// @notice Emitted when a new trusted executor is set.
  /// @param previousExecutor The previous trusted executor address
  /// @param newExecutor The new trusted executor address
  event SetTrustedExecutor(address indexed previousExecutor, address indexed newExecutor);

  /* ============ Variables ============ */

  /// @notice Address of the trusted executor contract.
  address public trustedExecutor;

  /* ============ Constructor ============ */

  /**
   * @notice ExecutorAware constructor.
   * @param _executor Address of the `MessageExecutor` contract
   */
  constructor(address _executor) {
    _setTrustedExecutor(_executor);
  }

  /* ============ Public Functions ============ */

  /**
   * @notice Check which executor this contract trust.
   * @param _executor Address to check
   */
  function isTrustedExecutor(address _executor) public view returns (bool) {
    return _executor == trustedExecutor;
  }

  /* ============ Internal Functions ============ */

  /**
   * @notice Sets a new trusted executor.
   * @param _executor The new address to trust as the executor
   */
  function _setTrustedExecutor(address _executor) internal {
    if (address(0) == _executor) revert ExecutorZeroAddress();
    emit SetTrustedExecutor(trustedExecutor, _executor);
    trustedExecutor = _executor;
  }

}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "../libraries/MessageLib.sol";

/**
 * @title ERC-5164: Cross-Chain Execution Standard
 * @dev See https://eips.ethereum.org/EIPS/eip-5164
 */
interface IMessageDispatcher {
  /**
   * @notice Emitted when a message has successfully been dispatched to the executor chain.
   * @param messageId ID uniquely identifying the message
   * @param from Address that dispatched the message
   * @param toChainId ID of the chain receiving the message
   * @param to Address that will receive the message
   * @param data Data that was dispatched
   */
  event MessageDispatched(
    bytes32 indexed messageId,
    address indexed from,
    uint256 indexed toChainId,
    address to,
    bytes data
  );

  /**
   * @notice Dispatch a message to the receiving chain.
   * @dev Must compute and return an ID uniquely identifying the message.
   * @dev Must emit the `MessageDispatched` event when successfully dispatched.
   * @param toChainId ID of the receiving chain
   * @param to Address on the receiving chain that will receive `data`
   * @param data Data dispatched to the receiving chain
   * @return bytes32 ID uniquely identifying the message
   */
  function dispatchMessage(
    uint256 toChainId,
    address to,
    bytes calldata data
  ) external returns (bytes32);

  /**
   * @notice Retrieves address of the MessageExecutor contract on the receiving chain.
   * @dev Must revert if `toChainId` is not supported.
   * @param toChainId ID of the chain with which MessageDispatcher is communicating
   * @return address MessageExecutor contract address
   */
  function getMessageExecutorAddress(uint256 toChainId) external returns (address);
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "./IMessageDispatcher.sol";

/**
 * @title ERC-5164: Cross-Chain Execution Standard
 * @dev IMessageDispatcher interface extended to support a custom gas limit for Optimism.
 * @dev See https://eips.ethereum.org/EIPS/eip-5164
 */
interface IMessageDispatcherOptimism is IMessageDispatcher {
  /**
   * @notice Dispatch and process a message to the receiving chain.
   * @dev Must compute and return an ID uniquely identifying the message.
   * @dev Must emit the `MessageDispatched` event when successfully dispatched.
   * @param _toChainId ID of the receiving chain
   * @param _to Address on the receiving chain that will receive `data`
   * @param _data Data dispatched to the receiving chain
   * @param _gasLimit Gas limit at which the message will be executed on Optimism
   * @return bytes32 ID uniquely identifying the message
   */
  function dispatchMessageWithGasLimit(
    uint256 _toChainId,
    address _to,
    bytes calldata _data,
    uint32 _gasLimit
  ) external returns (bytes32);

  /**
   * @notice Dispatch and process `messages` to the receiving chain.
   * @dev Must compute and return an ID uniquely identifying the `messages`.
   * @dev Must emit the `MessageBatchDispatched` event when successfully dispatched.
   * @param _toChainId ID of the receiving chain
   * @param _messages Array of Message dispatched
   * @param _gasLimit Gas limit at which the message will be executed on Optimism
   * @return bytes32 ID uniquely identifying the `messages`
   */
  function dispatchMessageWithGasLimitBatch(
    uint256 _toChainId,
    MessageLib.Message[] calldata _messages,
    uint32 _gasLimit
  ) external returns (bytes32);
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "./IMessageDispatcher.sol";

import "../libraries/MessageLib.sol";

/**
 * @title MessageExecutor interface
 * @notice MessageExecutor interface of the ERC-5164 standard as defined in the EIP.
 */
interface IMessageExecutor {
  /**
   * @notice Emitted when a message has successfully been executed.
   * @param fromChainId ID of the chain that dispatched the message
   * @param messageId ID uniquely identifying the message that was executed
   */
  event MessageIdExecuted(uint256 indexed fromChainId, bytes32 indexed messageId);

  /**
   * @notice Execute message from the origin chain.
   * @dev Should authenticate that the call has been performed by the bridge transport layer.
   * @dev Must revert if the message fails.
   * @dev Must emit the `MessageIdExecuted` event once the message has been executed.
   * @param to Address that will receive `data`
   * @param data Data forwarded to address `to`
   * @param messageId ID uniquely identifying the message
   * @param fromChainId ID of the chain that dispatched the message
   * @param from Address of the sender on the origin chain
   */
  function executeMessage(
    address to,
    bytes calldata data,
    bytes32 messageId,
    uint256 fromChainId,
    address from
  ) external;

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title ExecutorParserLib
 * @notice Library to parse additional data from Executor messages.
 */
library ExecutorParserLib {

  /// @notice Parses the message ID from `msg.data`.
  /// @return The bytes32 message ID uniquely identifying the message that was executed
  function messageId() internal pure returns (bytes32) {
    bytes32 _messageId;
    if (msg.data.length >= 84) {
      assembly {
        _messageId := calldataload(sub(calldatasize(), 84))
      }
    }
    return _messageId;
  }

  /// @notice Parses the from chain ID from `msg.data`.
  /// @return ID of the chain that dispatched the messages
  function fromChainId() internal pure returns (uint256) {
    uint256 _fromChainId;
    if (msg.data.length >= 52) {
      assembly {
        _fromChainId := calldataload(sub(calldatasize(), 52))
      }
    }
    return _fromChainId;
  }

  /// @notice Parses the sender address from `msg.data`.
  /// @return The payable sender address
  function msgSender() internal pure returns (address payable) {
    address payable _sender;
    if (msg.data.length >= 20) {
      assembly {
        _sender := shr(96, calldataload(sub(calldatasize(), 20)))
      }
    }
    return _sender;
  }

}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import { IMessageExecutor } from "../interfaces/IMessageExecutor.sol";

/**
 * @title MessageLib
 * @notice Library to declare and manipulate Message(s).
 */
library MessageLib {
  /* ============ Structs ============ */

  /**
   * @notice Message data structure
   * @param to Address that will be dispatched on the receiving chain
   * @param data Data that will be sent to the `to` address
   */
  struct Message {
    address to;
    bytes data;
  }

  /* ============ Events ============ */

  /* ============ Custom Errors ============ */

  /**
   * @notice Emitted when a messageId has already been executed.
   * @param messageId ID uniquely identifying the message that was re-executed
   */
  error MessageIdAlreadyExecuted(bytes32 messageId);

  /**
   * @notice Emitted if a call to a contract fails.
   * @param messageId ID uniquely identifying the message
   * @param errorData Error data returned by the call
   */
  error MessageFailure(bytes32 messageId, bytes errorData);

  /* ============ Internal Functions ============ */

  /**
   * @notice Helper to compute messageId.
   * @param nonce Monotonically increased nonce to ensure uniqueness
   * @param from Address that dispatched the message
   * @param to Address that will receive the message
   * @param data Data that was dispatched
   * @return bytes32 ID uniquely identifying the message that was dispatched
   */
  function computeMessageId(
    uint256 nonce,
    address from,
    address to,
    bytes memory data
  ) internal pure returns (bytes32) {
    return keccak256(abi.encode(nonce, from, to, data));
  }

  /**
   * @notice Helper to encode message for execution by the MessageExecutor.
   * @param to Address that will receive the message
   * @param data Data that will be dispatched
   * @param messageId ID uniquely identifying the message being dispatched
   * @param fromChainId ID of the chain that dispatched the message
   * @param from Address that dispatched the message
   */
  function encodeMessage(
    address to,
    bytes memory data,
    bytes32 messageId,
    uint256 fromChainId,
    address from
  ) internal pure returns (bytes memory) {
    return
      abi.encodeCall(IMessageExecutor.executeMessage, (to, data, messageId, fromChainId, from));
  }

  /**
   * @notice Execute message from the origin chain.
   * @dev Will revert if `message` has already been executed.
   * @param to Address that will receive the message
   * @param data Data that was dispatched
   * @param messageId ID uniquely identifying message
   * @param fromChainId ID of the chain that dispatched the `message`
   * @param from Address of the sender on the origin chain
   * @param executedMessageId Whether `message` has already been executed or not
   */
  function executeMessage(
    address to,
    bytes memory data,
    bytes32 messageId,
    uint256 fromChainId,
    address from,
    bool executedMessageId
  ) internal {
    if (executedMessageId) {
      revert MessageIdAlreadyExecuted(messageId);
    }

    _requireContract(to);

    (bool _success, bytes memory _returnData) = to.call(
      abi.encodePacked(data, messageId, fromChainId, from)
    );

    if (!_success) {
      revert MessageFailure(messageId, _returnData);
    }
  }

  /**
   * @notice Check that the call is being made to a contract.
   * @param to Address to check
   */
  function _requireContract(address to) internal view {
    require(to.code.length > 0, "MessageLib/no-contract-at-to");
  }
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

/**
 * @title Random Number Generator Interface
 * @notice Provides an interface for requesting random numbers from 3rd-party RNG services (Chainlink VRF, Starkware VDF, etc..)
 */
interface RNGInterface {
  /**
   * @notice Emitted when a new request for a random number has been submitted
   * @param requestId The indexed ID of the request used to get the results of the RNG service
   * @param sender The indexed address of the sender of the request
   */
  event RandomNumberRequested(uint32 indexed requestId, address indexed sender);

  /**
   * @notice Emitted when an existing request for a random number has been completed
   * @param requestId The indexed ID of the request used to get the results of the RNG service
   * @param randomNumber The random number produced by the 3rd-party service
   */
  event RandomNumberCompleted(uint32 indexed requestId, uint256 randomNumber);

  /**
   * @notice Gets the last request id used by the RNG service
   * @return requestId The last request id used in the last request
   */
  function getLastRequestId() external view returns (uint32 requestId);

  /**
   * @notice Gets the Fee for making a Request against an RNG service
   * @return feeToken The address of the token that is used to pay fees
   * @return requestFee The fee required to be paid to make a request
   */
  function getRequestFee() external view returns (address feeToken, uint256 requestFee);

  /**
   * @notice Sends a request for a random number to the 3rd-party service
   * @dev Some services will complete the request immediately, others may have a time-delay
   * @dev Some services require payment in the form of a token, such as $LINK for Chainlink VRF
   * @return requestId The ID of the request used to get the results of the RNG service
   * @return lockBlock The block number at which the RNG service will start generating time-delayed randomness.
   * The calling contract should "lock" all activity until the result is available via the `requestId`
   */
  function requestRandomNumber() external returns (uint32 requestId, uint32 lockBlock);

  /**
   * @notice Checks if the request for randomness from the 3rd-party service has completed
   * @dev For time-delayed requests, this function is used to check/confirm completion
   * @param requestId The ID of the request used to get the results of the RNG service
   * @return isCompleted True if the request has completed and a random number is available, false otherwise
   */
  function isRequestComplete(uint32 requestId) external view returns (bool isCompleted);

  /**
   * @notice Gets the random number produced by the 3rd-party service
   * @param requestId The ID of the request used to get the results of the RNG service
   * @return randomNum The random number
   */
  function randomNumber(uint32 requestId) external returns (uint256 randomNum);

  /**
   * @notice Returns the timestamps at which the request was completed
   * @param requestId The ID of the request used to get the results of the RNG service
   * @return completedAtTimestamp The timestamp at which the request was completed
   */
  function completedAt(uint32 requestId) external view returns (uint64 completedAtTimestamp);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ExecutorAware, ExecutorZeroAddress } from "erc5164-interfaces/abstract/ExecutorAware.sol";
import { ExecutorParserLib } from "erc5164-interfaces/libraries/ExecutorParserLib.sol";

/* ============ Custom Errors ============ */

/// @notice Thrown when the originChainId passed to the constructor is zero.
error OriginChainIdZero();

/// @notice Thrown when the Owner address passed to the constructor is zero address.
error OwnerZeroAddress();

/// @notice Thrown when the message was dispatched from an unsupported chain ID.
error OriginChainIdUnsupported(uint256 fromChainId);

/// @notice Thrown when the message was not executed by the executor.
error LocalSenderNotExecutor(address sender);

/// @notice Thrown when the message was not executed by the pending executor.
error LocalSenderNotPendingExecutor(address sender);

/// @notice Thrown when the message was not dispatched by the Owner on the origin chain.
error OriginSenderNotOwner(address sender);

/// @notice Thrown when the message was not dispatched by the pending owner on the origin chain.
error OriginSenderNotPendingOwner(address sender);

/// @notice Thrown when the call to the target contract failed.
error CallFailed(bytes returnData);

/// @title RemoteOwner
/// @author G9 Software Inc.
/// @notice RemoteOwner allows a contract on one chain to control a contract on another chain.
contract RemoteOwner is ExecutorAware {

  /* ============ Events ============ */

  /**
    * @dev Emitted when `_pendingOwner` has been changed.
    * @param pendingOwner new `_pendingOwner` address.
    */
  event OwnershipOffered(address indexed pendingOwner);

  /**
    * @dev Emitted when `_owner` has been changed.
    * @param previousOwner previous `_owner` address.
    * @param newOwner new `_owner` address.
    */
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
    * @dev Emitted when `_pendingExecutor` has been declared by the owner.
    * @param pendingTrustedExecutor the pending trusted executor address.
    */
  event PendingExecutorPermissionTransfer(address indexed pendingTrustedExecutor);

  /**
   * @notice Emitted when ether is received to this contract via the `receive` function.
   * @param from The sender of the ether
   * @param value The value received
   */
  event Received(address indexed from, uint256 value);

  /* ============ Variables ============ */

  /// @notice ID of the origin chain that dispatches the auction auction results and random number.
  uint256 internal immutable _originChainId;

  /// @notice Address of the Owner on the origin chain that dispatches the auction results and random number.
  address private _owner;

  /// @notice Address of the new pending owner.
  address private _pendingOwner;

  /// @notice Address of the new pending trusted executor.
  address private _pendingExecutor;

  /* ============ Constructor ============ */

  /**
   * @notice ownerReceiver constructor.
   */
  constructor(
    uint256 originChainId_,
    address executor_,
    address __owner
  ) ExecutorAware(executor_) {
    if (__owner == address(0)) revert OwnerZeroAddress();
    if (originChainId_ == 0) revert OriginChainIdZero();
    _originChainId = originChainId_;
    _setOwner(__owner);
  }

  /* ============ Receive Ether Function ============ */

  /// @dev Emits a `Received` event
  receive() external payable {
    emit Received(msg.sender, msg.value);
  }

  /* ============ External Functions ============ */

  /**
   * @notice Executes a call on the target contract. Can only be called by the owner from the origin chain.
   * @param target The address to call
   * @param value Any eth value to pass along with the call
   * @param data The calldata
   * @return The return data of the call
   */
  function execute(address target, uint256 value, bytes calldata data) external onlyExecutorAndOriginChain onlyOwner returns (bytes memory) {
    (bool success, bytes memory returnData) = target.call{ value: value }(data);
    if (!success) revert CallFailed(returnData);
    assembly {
      return (add(returnData, 0x20), mload(returnData))
    }
  }

  /**
    * @notice Renounce ownership of the contract.
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
  function renounceOwnership() external virtual onlyExecutorAndOriginChain onlyOwner {
    _setOwner(address(0));
  }

  /**
   * @notice Transfer ownership to another origin chain account
   * @param _newOwner Address of the new owner
   */
  function transferOwnership(address _newOwner) external onlyExecutorAndOriginChain onlyOwner {
    if (_newOwner == address(0)) revert OwnerZeroAddress();
    _pendingOwner = _newOwner;
    emit OwnershipOffered(_newOwner);
  }

  /**
  * @notice Allows the `_pendingOwner` address to finalize the transfer.
  * @dev This function is only callable by the `_pendingOwner`.
  */
  function claimOwnership() external onlyExecutorAndOriginChain onlyPendingOwner {
    _setOwner(_pendingOwner);
    delete _pendingOwner;
  }

  /**
   * @notice Transfers the executor permission to a new address.
   * @dev The owner must successfully call `claimExecutorPermission` through the new executor
   * to complete the transfer.
   * @param _executor Address of the new executor
   */
  function transferExecutorPermission(address _executor) external onlyExecutorAndOriginChain onlyOwner {
    if (_executor == address(0)) revert ExecutorZeroAddress();
    _pendingExecutor = _executor;
    emit PendingExecutorPermissionTransfer(_executor);
  }

  /**
   * @notice Activates the pending executor.
   * @dev This can only be called by the owner through the pending executor.
   */
  function claimExecutorPermission() external onlyPendingExecutorAndOriginChain onlyOwner {
    _setTrustedExecutor(_pendingExecutor);
    delete _pendingExecutor;
  }

  /* ============ Getters ============ */

  /**
   * @notice Get the ID of the origin chain.
   * @return ID of the origin chain
   */
  function originChainId() external view returns (uint256) {
    return _originChainId;
  }

  /**
   * @notice The owner address. This address is on the origin chain.
   * @return The owner address
   */
  function owner() external view returns (address) {
    return _owner;
  }

  /**
    * @notice Gets current `_pendingOwner`.
    * @return Current `_pendingOwner` address.
    */
  function pendingOwner() external view virtual returns (address) {
    return _pendingOwner;
  }

  /**
    * @notice Gets current `_pendingExecutor`.
    * @return Current `_pendingExecutor` address.
    */
  function pendingTrustedExecutor() external view virtual returns (address) {
    return _pendingExecutor;
  }

  /* ============ Internal Functions ============ */

  /**
   * @notice Sets the owner of the contract.
   * @param _newOwner Address of the new owner
   */
  function _setOwner(address _newOwner) internal {
    address _oldOwner = _owner;
    _owner = _newOwner;

    emit OwnershipTransferred(_oldOwner, _newOwner);
  }

  /**
   * @notice Asserts that the caller is the 5164 executor, and that the origin chain id is correct.
   */
  modifier onlyExecutorAndOriginChain() {
    if (!isTrustedExecutor(msg.sender)) revert LocalSenderNotExecutor(msg.sender);
    if (ExecutorParserLib.fromChainId() != _originChainId) revert OriginChainIdUnsupported(ExecutorParserLib.fromChainId());
    _;
  }

  /**
   * @notice Asserts that the caller is the pending 5164 executor, and that the origin chain id is correct.
   */
  modifier onlyPendingExecutorAndOriginChain() {
    if (msg.sender != _pendingExecutor) revert LocalSenderNotPendingExecutor(msg.sender);
    if (ExecutorParserLib.fromChainId() != _originChainId) revert OriginChainIdUnsupported(ExecutorParserLib.fromChainId());
    _;
  }

  /**
   * @notice Asserts that the 5164 sender matches the current owner
   */
  modifier onlyOwner() {
    if (ExecutorParserLib.msgSender() != address(_owner)) revert OriginSenderNotOwner(ExecutorParserLib.msgSender());
    _;
  }

  /**
   * @notice Asserts that the 5164 sender matches the pending owner
   */
  modifier onlyPendingOwner() {
    if (ExecutorParserLib.msgSender() != address(_pendingOwner)) revert OriginSenderNotPendingOwner(ExecutorParserLib.msgSender());
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { RemoteOwner } from "../RemoteOwner.sol";

/// @title RemoteOwnerCallEncoder
/// @author G9 Software Inc.
/// @notice Provides an interface to encode calldata for a RemoteOwner to execute.
library RemoteOwnerCallEncoder {

    /// @notice Encodes calldata for a RemoteOwner to execute on `target`.
    /// @param target The target address that RemoteOwner will call with the given value and data
    /// @param value The value that RemoteOwner will send to `target`
    /// @param data The data that RemoteOwner will call `target` with
    /// @return The encoded calldata
    function encodeCalldata(address target, uint256 value, bytes memory data) internal pure returns (bytes memory) {
        return abi.encodeCall(
            RemoteOwner.execute,
            (
                target,
                value,
                data
            )
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IERC20 } from "openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "owner-manager/Ownable.sol";
import { RNGInterface } from "rng/RNGInterface.sol";
import { UD2x18 } from "prb-math/UD2x18.sol";
import { UD60x18, convert, intoUD2x18 } from "prb-math/UD60x18.sol";

import { RewardLib } from "./libraries/RewardLib.sol";
import { IAuction, AuctionResult } from "./interfaces/IAuction.sol";

/**
 * @notice The results of a successful RNG auction.
 * @param recipient The recipient of the auction reward
 * @param rewardFraction The reward fraction that the user will receive
 * @param sequenceId The id of the sequence that this auction belonged to
 * @param rng The RNG service that was used to generate the random number
 * @param rngRequestId The id of the RNG request that was made
 * @dev   The `sequenceId` value should not be assumed to be the same as a prize pool drawId, but the sequence and offset should match the prize pool.
 */
struct RngAuctionResult {
  address recipient;
  UD2x18 rewardFraction;
  uint32 sequenceId;
  RNGInterface rng;
  uint32 rngRequestId;
}

/* ============ Custom Errors ============ */

/// @notice Thrown when the auction duration is zero.
error AuctionDurationZero();

/// @notice Thrown if the auction target time is zero.
error AuctionTargetTimeZero();

/**
 * @notice Thrown if the auction target time exceeds the auction duration.
 * @param auctionTargetTime The auction target time to complete in seconds
 * @param auctionDuration The auction duration in seconds
 */
error AuctionTargetTimeExceedsDuration(uint64 auctionTargetTime, uint64 auctionDuration);

/// @notice Thrown when the sequence period is zero.
error SequencePeriodZero();

/**
 * @notice Thrown when the auction duration is greater than or equal to the sequence.
 * @param auctionDuration The auction duration in seconds
 * @param sequencePeriod The sequence period in seconds
 */
error AuctionDurationGTSequencePeriod(uint64 auctionDuration, uint64 sequencePeriod);

/// @notice Thrown when the first auction target reward fraction is greater than one.
error TargetRewardFractionGTOne();

/// @notice Thrown when the RNG address passed to the setter function is zero address.
error RngZeroAddress();

/// @notice Thrown if the next sequence cannot yet be started
error CannotStartNextSequence();

/// @notice Thrown if the time elapsed since the start of the auction is greater than the auction duration.
error AuctionExpired();

/// @notice Thrown if owner set is the zero address.
error OwnerZeroAddress();

/// @notice Emitted when the zero address is passed as reward recipient
error RewardRecipientIsZero();

/**
 * @title PoolTogether V5 RngAuction
 * @author G9 Software Inc.
 * @notice The RngAuction allows anyone to request a new random number using the RNG service set.
 *         The auction incentivises RNG requests to be started in-sync with prize pool draw
 *         periods across all chains.
 */
contract RngAuction is IAuction, Ownable {
  using SafeERC20 for IERC20;

  /* ============ Variables ============ */

  /// @notice Duration of the auction in seconds
  /// @dev This must always be less than the sequence period since the auction needs to complete each period.
  uint64 public immutable auctionDuration;

  /// @notice The target time to complete the auction in seconds
  uint64 public immutable auctionTargetTime;

  /// @notice The target time to complete the auction as a fraction of the auction duration
  UD2x18 internal immutable _auctionTargetTimeFraction;

  /// @notice Target reward fraction to complete the first auction.
  UD2x18 internal immutable _firstAuctionTargetRewardFraction;

  /// @notice Duration of the sequence that the auction should align with
  /// @dev This must always be greater than the auction duration.
  uint64 public immutable sequencePeriod;

  /**
   * @notice Offset of the sequence in seconds
   * @dev If the next sequence starts at unix timestamp `t`, then a valid offset is equal to `t % sequencePeriod`.
   * @dev If the offset is set to some point in the future, some calculations will fail until that time, effectively
   * preventing any auctions until then.
   */
  uint64 public immutable sequenceOffset;

  /// @notice New RNG instance that will be applied before the next auction completion
  RNGInterface internal _nextRng;

  /// @notice The last auction result
  RngAuctionResult internal _lastAuction;

  /* ============ Events ============ */

  /**
   * @notice Emitted when the RNG service address is set.
   * @param rngService RNG service address
   */
  event SetNextRngService(RNGInterface indexed rngService);

  /**
   * @notice Emitted when the auction is completed.
   * @param recipient The recipient of the auction reward
   * @param sequenceId The sequence ID for the auction
   * @param rng The RNGInterface that was used for this auction
   * @param rngRequestId The RNGInterface request ID
   * @param elapsedTime The amount of time that the auction ran for in seconds
   * @param rewardFraction The fraction of the available rewards to be allocated to the recipient
   */
  event RngAuctionCompleted(
    address indexed sender,
    address indexed recipient,
    uint32 indexed sequenceId,
    RNGInterface rng,
    uint32 rngRequestId,
    uint64 elapsedTime,
    UD2x18 rewardFraction
  );

  /* ============ Constructor ============ */

  /**
   * @notice Deploy the RngAuction smart contract.
   * @param rng_ Address of the RNG service
   * @param owner_ Address of the RngAuction owner. The owner may swap out the RNG service.
   * @param sequencePeriod_ Sequence period in seconds
   * @param sequenceOffset_ Sequence offset in seconds
   * @param auctionDurationSeconds_ Auction duration in seconds
   * @param auctionTargetTime_ Target time to complete the auction in seconds
   * @param firstAuctionTargetRewardFraction_ Target reward fraction to complete the first auction
   */
  constructor(
    RNGInterface rng_,
    address owner_,
    uint64 sequencePeriod_,
    uint64 sequenceOffset_,
    uint64 auctionDurationSeconds_,
    uint64 auctionTargetTime_,
    UD2x18 firstAuctionTargetRewardFraction_
  ) Ownable(owner_) {
    if (address(0) == owner_) revert OwnerZeroAddress();
    if (sequencePeriod_ == 0) revert SequencePeriodZero();
    if (auctionTargetTime_ > auctionDurationSeconds_) {
      revert AuctionTargetTimeExceedsDuration(
        uint64(auctionTargetTime_),
        uint64(auctionDurationSeconds_)
      );
    }

    if (auctionDurationSeconds_ > sequencePeriod_)
      revert AuctionDurationGTSequencePeriod(
        uint64(auctionDurationSeconds_),
        uint64(sequencePeriod_)
      );

    if (firstAuctionTargetRewardFraction_.unwrap() > 1e18) revert TargetRewardFractionGTOne();

    sequencePeriod = sequencePeriod_;
    sequenceOffset = sequenceOffset_;
    auctionDuration = auctionDurationSeconds_;
    auctionTargetTime = auctionTargetTime_;
    _auctionTargetTimeFraction = (
      intoUD2x18(
        convert(uint256(auctionTargetTime_)).div(convert(uint256(auctionDurationSeconds_)))
      )
    );

    _firstAuctionTargetRewardFraction = firstAuctionTargetRewardFraction_;

    _setNextRngService(rng_);
  }

  /* ============ External Functions ============ */

  /**
   * @notice  Starts the RNG Request, ends the current auction, and stores the reward fraction to
   *          be allocated to the recipient.
   * @dev     Will revert if the current auction has already been completed or expired.
   * @dev     If the RNG service expects the fee to already be in possession, the caller should not
   *          call this function directly and should instead call a helper function that transfers
   *          the funds to the RNG service before calling this function.
   * @dev     If there is a pending RNG service (see _nextRng), it will be swapped in before the
   *          auction is completed.
   * @param _rewardRecipient Address that will be allocated the auction reward for starting the RNG request.
   * The recipient can withdraw the rewards from the Prize Pools that use the random number once all
   * subsequent auctions are complete.
   */
  function startRngRequest(address _rewardRecipient) external {
    if (_rewardRecipient == address(0)) revert RewardRecipientIsZero();
    if (!_canStartNextSequence()) revert CannotStartNextSequence();

    RNGInterface rng = _nextRng;

    uint64 _auctionElapsedTimeSeconds = _auctionElapsedTime();
    if (_auctionElapsedTimeSeconds > auctionDuration) revert AuctionExpired();

    (address _feeToken, uint256 _requestFee) = rng.getRequestFee();
    if (
      _feeToken != address(0) &&
      _requestFee > 0 &&
      IERC20(_feeToken).allowance(address(this), address(rng)) < _requestFee
    ) {
      /**
       * Set approval for the RNG service to take the request fee to support RNG services
       * that pull funds from the caller.
       * NOTE: Not compatible with safeApprove or safeIncreaseAllowance.
       */
      IERC20(_feeToken).approve(address(rng), _requestFee);
    }

    (uint32 rngRequestId, ) = rng.requestRandomNumber();
    uint32 sequenceId = _openSequenceId();
    UD2x18 rewardFraction = _currentFractionalReward();

    _lastAuction = RngAuctionResult({
      recipient: _rewardRecipient,
      rewardFraction: rewardFraction,
      sequenceId: sequenceId,
      rng: rng,
      rngRequestId: rngRequestId
    });

    emit RngAuctionCompleted(
      msg.sender,
      _rewardRecipient,
      sequenceId,
      rng,
      rngRequestId,
      _auctionElapsedTimeSeconds,
      rewardFraction
    );
  }

  /* ============ State Functions ============ */

  /**
   * @notice Determines if the next sequence can be started.
   * @dev The auction is complete when the RNG has been requested for the current sequence, therefore
   * the next sequence can be started if the current sequenceId is different from the last
   * auction's sequenceId.
   * @return True if the next sequence can be started, false otherwise.
   */
  function canStartNextSequence() external view returns (bool) {
    return _canStartNextSequence();
  }

  /**
   * @notice Checks if the auction is still open and if it can be completed.
   * @dev The auction is open if RNG has not been requested yet this sequence and the
   * auction has not expired.
   * @return True if the auction is open and can be completed, false otherwise.
   */
  function isAuctionOpen() external view returns (bool) {
    return _canStartNextSequence() && _auctionElapsedTime() <= auctionDuration;
  }

  /**
   * @notice The amount of time remaining in the current open auction
   * @return The elapsed time since the auction started in seconds
   */
  function auctionElapsedTime() external view returns (uint64) {
    return _auctionElapsedTime();
  }

  /**
   * @notice Calculates the reward fraction for the current auction if it were to be completed at this time.
   * @dev Uses the last sold fraction as the target price for this auction.
   * @return The current reward fraction as a UD2x18 value
   */
  function currentFractionalReward() external view returns (UD2x18) {
    return _currentFractionalReward();
  }

  /**
   * @notice The last auction results.
   * @return RngAuctionResults struct from the last auction.
   */
  function getLastAuction() external view returns (RngAuctionResult memory) {
    return _lastAuction;
  }

  /**
   * @notice Returns the last auction as an AuctionResult struct to be used to calculate rewards.
   * @return AuctionResult struct with data from the last auction
   */
  function getLastAuctionResult() external view returns (AuctionResult memory) {
    return
      AuctionResult({
        recipient: _lastAuction.recipient,
        rewardFraction: _lastAuction.rewardFraction
      });
  }

  /**
   * @notice Calculates a unique identifier for the current sequence.
   * @return The current sequence ID.
   */
  function openSequenceId() external view returns (uint32) {
    return _openSequenceId();
  }

  /**
   * @notice Returns the sequence ID from the last auction.
   * @return The last sequence ID.
   */
  function lastSequenceId() external view returns (uint32) {
    return _lastAuction.sequenceId;
  }

  /**
   * @notice Returns whether the RNG request has completed or not for the current sequence.
   * @return True if the RNG request has completed, false otherwise.
   */
  function isRngComplete() external view returns (bool) {
    RNGInterface rng = _lastAuction.rng;
    uint32 requestId = _lastAuction.rngRequestId;
    return !_canStartNextSequence() && rng.isRequestComplete(requestId);
  }

  /**
   * @notice Returns the result of the last RNG Request.
   * @dev The RNG service may revert if the current RNG request is not complete.
   * @dev Not marked as view since RNGInterface.randomNumber is not a view function.
   * @return randomNumber The random number result
   * @return rngCompletedAt The timestamp at which the random number request was completed
   */
  function getRngResults() external returns (uint256 randomNumber, uint64 rngCompletedAt) {
    RNGInterface rng = _lastAuction.rng;
    uint32 requestId = _lastAuction.rngRequestId;
    randomNumber = rng.randomNumber(requestId);
    rngCompletedAt = rng.completedAt(requestId);
  }

  /// @notice Computes the reward fraction for the given auction elapsed time.
  /// @param __auctionElapsedTime The elapsed time of the auction in seconds
  /// @return The reward fraction as a UD2x18 value
  function computeRewardFraction(uint64 __auctionElapsedTime) external view returns (UD2x18) {
    return _computeRewardFraction(__auctionElapsedTime);
  }

  /* ============ Getter Functions ============ */

  /**
   * @notice Returns the RNG service used to generate random numbers.
   * @return RNG service instance
   */
  function getLastRngService() external view returns (RNGInterface) {
    return _lastAuction.rng;
  }

  /**
   * @notice Returns the pending RNG service that will replace the current service before the next auction completes.
   * @return RNG service instance
   */
  function getNextRngService() external view returns (RNGInterface) {
    return _nextRng;
  }

  /* ============ Setters ============ */

  /**
   * @notice Sets the RNG service used to generate random numbers.
   * @dev Only callable by the owner.
   * @dev The service will not be updated immediately so the current auction is not disturbed. Instead,
   * it will be swapped out right before the next auction is completed.
   * @param _rngService Address of the new RNG service
   */
  function setNextRngService(RNGInterface _rngService) external onlyOwner {
    _setNextRngService(_rngService);
  }

  /* ============ Internal Functions ============ */

  /**
   * @notice Calculates a unique identifier for the current sequence.
   * @return The current sequence ID.
   */
  function _openSequenceId() internal view returns (uint32) {
    /**
     * Use integer division to calculate a unique ID based off the current timestamp that will remain the same
     * throughout the entire sequence.
     */
    uint64 currentTime = uint64(block.timestamp);
    if (currentTime < sequenceOffset) {
      return 0;
    }
    return uint32((currentTime - sequenceOffset) / sequencePeriod);
  }

  /**
   * @notice Calculates the elapsed time for the current RNG auction.
   * @return The elapsed time since the start of the current RNG auction in seconds.
   */
  function _auctionElapsedTime() internal view returns (uint64) {
    uint64 currentTime = uint64(block.timestamp);
    if (currentTime < sequenceOffset) {
      return 0;
    }
    return (uint64(block.timestamp) - sequenceOffset) % sequencePeriod;
  }

  /**
   * @notice Calculates the reward fraction for the current auction if it were to be completed at this time.
   * @dev Uses the last sold fraction as the target price for this auction.
   * @return The current reward fraction as a UD2x18 value
   */
  function _currentFractionalReward() internal view returns (UD2x18) {
    return _computeRewardFraction(_auctionElapsedTime());
  }

  /**
   * @notice Calculates the reward fraction for the current auction based on the given elapsed time.
   * @param __auctionElapsedTime The elapsed time of the auction in seconds
   * @dev Uses the last sold fraction as the target price for this auction.
   * @return The current reward fraction as a UD2x18 value
   */
  function _computeRewardFraction(uint64 __auctionElapsedTime) internal view returns (UD2x18) {
    return
      RewardLib.fractionalReward(
        __auctionElapsedTime,
        auctionDuration,
        _auctionTargetTimeFraction,
        _lastAuction.sequenceId == 0
          ? _firstAuctionTargetRewardFraction
          : _lastAuction.rewardFraction
      );
  }

  /**
   * @notice Determines if the next sequence can be started.
   * @dev The auction is complete when the RNG has been requested for the current sequence, therefore
   * the next sequence can be started if the current sequenceId is different from the last
   * auction's sequenceId.
   * @return True if the next sequence can be started, false otherwise.
   */
  function _canStartNextSequence() internal view returns (bool) {
    return _lastAuction.sequenceId != _openSequenceId();
  }

  /**
   * @notice Sets the RNG service used to generate random numbers.
   * @param _newRng Address of the new RNG service
   */
  function _setNextRngService(RNGInterface _newRng) internal {
    if (address(_newRng) == address(0)) revert RngZeroAddress();

    // Set as pending if RNG is being replaced.
    // The RNG will be swapped with the pending one before the next random number is requested.
    _nextRng = _newRng;

    emit SetNextRngService(_newRng);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { RemoteOwner } from "remote-owner/RemoteOwner.sol";
import { RemoteOwnerCallEncoder } from "remote-owner/libraries/RemoteOwnerCallEncoder.sol";
import {
  IMessageDispatcherOptimism
} from "erc5164-interfaces/interfaces/IMessageDispatcherOptimism.sol";

import {
  RngAuctionRelayer,
  RngAuction,
  IRngAuctionRelayListener
} from "./abstract/RngAuctionRelayer.sol";

/// @notice Emitted when the message dispatcher is the zero address.
error MessageDispatcherIsZeroAddress();

/// @notice Emitted when the remote owner is the zero address.
error RemoteOwnerIsZeroAddress();

/// @notice Emitted when the relayer listener is the zero address.
error RemoteRngAuctionRelayListenerIsZeroAddress();

/// @notice Emitted when the `gasLimit` passed to the `relay` function is zero.
error GasLimitIsZero();

/**
 * @title RngAuctionRelayerRemoteOwner
 * @author G9 Software Inc.
 * @notice This contract allows anyone to relay RNG results to an IRngAuctionRelayListener on another chain.
 * @dev This contract uses a Remote Owner, which allows a contract on one chain to operate an address on another chain.
 */
contract RngAuctionRelayerRemoteOwner is RngAuctionRelayer {
  /**
   * @notice Emitted when the relay was successfully dispatched to the ERC-5164 Dispatcher
   * @param messageDispatcher The ERC-5164 Dispatcher to use to bridge messages
   * @param remoteOwnerChainId The chain ID that the Remote Owner is deployed to.
   * @param remoteOwner The address of the Remote Owner on the other chain whom should call the remote relayer
   * @param remoteRngAuctionRelayListener The address of the IRngAuctionRelayListener to relay to on the other chain.
   * @param rewardRecipient The address that shall receive the RNG relay reward.
   * @param messageId The message ID of the dispatched message.
   */
  event RelayedToDispatcher(
    IMessageDispatcherOptimism messageDispatcher,
    uint256 indexed remoteOwnerChainId,
    RemoteOwner remoteOwner,
    IRngAuctionRelayListener remoteRngAuctionRelayListener,
    address indexed rewardRecipient,
    bytes32 indexed messageId
  );

  /**
   * @notice Constructs a new contract
   * @param _rngAuction The RNG auction to pull results from.
   */
  constructor(RngAuction _rngAuction) RngAuctionRelayer(_rngAuction) {}

  /**
   * @notice Relays the RNG results through the 5164 message dispatcher to the remote rngAuctionRelayListener on the other chain.
   * @dev Note that some bridges require an additional transaction to bridge the message.
   * For example, both Arbitrum and zkSync require off-chain information to accomplish this. See ERC-5164 implementations for more details.
   * @param _messageDispatcher The ERC-5164 Dispatcher to use to bridge messages
   * @param _remoteOwnerChainId The chain ID that the Remote Owner is deployed to
   * @param _remoteOwner The address of the Remote Owner on the other chain whom should call the remote relayer
   * @param _remoteRngAuctionRelayListener The address of the IRngAuctionRelayListener to relay to on the other chain
   * @param _rewardRecipient The address that shall receive the RngAuctionRelay reward. Note that this address must be able to receive rewards on the other chain.
   * @param _gasLimit Gas limit at which the message will be executed on the receiving chain
   * @return The message ID of the dispatched message
   */
  function relay(
    IMessageDispatcherOptimism _messageDispatcher,
    uint256 _remoteOwnerChainId,
    RemoteOwner _remoteOwner,
    IRngAuctionRelayListener _remoteRngAuctionRelayListener,
    address _rewardRecipient,
    uint32 _gasLimit
  ) external returns (bytes32) {
    if (address(_messageDispatcher) == address(0)) {
      revert MessageDispatcherIsZeroAddress();
    }

    if (address(_remoteOwner) == address(0)) {
      revert RemoteOwnerIsZeroAddress();
    }

    if (address(_remoteRngAuctionRelayListener) == address(0)) {
      revert RemoteRngAuctionRelayListenerIsZeroAddress();
    }

    if (_gasLimit == 0) {
      revert GasLimitIsZero();
    }

    bytes memory listenerCalldata = _encodeCalldata(_rewardRecipient);
    bytes32 messageId = _messageDispatcher.dispatchMessageWithGasLimit(
      _remoteOwnerChainId,
      address(_remoteOwner),
      RemoteOwnerCallEncoder.encodeCalldata(
        address(_remoteRngAuctionRelayListener),
        0,
        listenerCalldata
      ),
      _gasLimit
    );

    emit RelayedToDispatcher(
      _messageDispatcher,
      _remoteOwnerChainId,
      _remoteOwner,
      _remoteRngAuctionRelayListener,
      _rewardRecipient,
      messageId
    );

    return messageId;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AddressRemapper
 * @author G9 Software Inc.
 * @notice Allows addresses to provide a remapping to a new address.
 * @dev The RngAuction lives on L1, but the rewards are given out on L2s. This contract allows the L1 reward recipients to remap their addresses to their L2 addresses if needed.
 */
contract AddressRemapper {
  /* ============ Variables ============ */

  /// @notice User-defined address remapping
  mapping(address => address) internal _destinationAddress;

  /* ============ Events ============ */

  /**
   @notice Emitted when a remapping is set.
   @param caller Caller address
   @param destination Remapped destination address that will be used in place of the caller address
   */
  event AddressRemapped(address indexed caller, address indexed destination);

  /* ============ Public Functions ============ */

  /**
   * @notice Retrieves the remapping for the given address.
   * @param _addr The address to check for remappings
   * @dev If the address does not have a remapping, the input address will be returned.
   * @return The remapped destination address for `_addr`
   */
  function remappingOf(address _addr) public view returns (address) {
    if (_destinationAddress[_addr] == address(0)) {
      return _addr;
    } else {
      return _destinationAddress[_addr];
    }
  }

  /* ============ External Functions ============ */

  /**
   * @notice Remaps the caller's address to the specified destination address
   * @param _destination The destination address to remap caller to
   * @dev Reset the destination to the zero address to remove the remapping.
   */
  function remapTo(address _destination) external {
    if (_destination == address(0) || _destination == msg.sender) {
      delete _destinationAddress[msg.sender];
      emit AddressRemapped(msg.sender, msg.sender);
    } else {
      _destinationAddress[msg.sender] = _destination;
      emit AddressRemapped(msg.sender, _destination);
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { RngAuction } from "../RngAuction.sol";
import { AuctionResult } from "../interfaces/IAuction.sol";
import { AddressRemapper } from "../abstract/AddressRemapper.sol";
import { IRngAuctionRelayListener } from "../interfaces/IRngAuctionRelayListener.sol";

/// @notice Emitted when the RNG has not yet completed
error RngNotCompleted();

/// @notice Emitted when the RngAuction is zero
error RngAuctionIsZeroAddress();

/// @notice Emitted when recipient is zero
error RewardRecipientIsZeroAddress();

/// @title RngAuctionRelayer
/// @author G9 Software Inc.
/// @notice Base contarct that relays RNG auction results to a listener
abstract contract RngAuctionRelayer is AddressRemapper {
  /// @notice The RNG Auction to get the random number from
  RngAuction public immutable rngAuction;

  /// @notice Constructs a new contract
  /// @param _rngAuction The RNG auction to retrieve the random number from
  constructor(RngAuction _rngAuction) {
    if (address(_rngAuction) == address(0)) revert RngAuctionIsZeroAddress();
    rngAuction = _rngAuction;
  }

  /// @notice Encodes the calldata for the RNG auction relay listener
  /// @param _rewardRecipient The address of the relay reward recipient
  /// @return The calldata to call the listener with
  function _encodeCalldata(address _rewardRecipient) internal returns (bytes memory) {
    if (_rewardRecipient == address(0)) {
      revert RewardRecipientIsZeroAddress();
    }
    if (!rngAuction.isRngComplete()) revert RngNotCompleted();
    (uint256 randomNumber, uint64 rngCompletedAt) = rngAuction.getRngResults();
    AuctionResult memory results = rngAuction.getLastAuctionResult();
    uint32 sequenceId = rngAuction.openSequenceId();
    results.recipient = remappingOf(results.recipient);
    return
      abi.encodeCall(
        IRngAuctionRelayListener.rngComplete,
        (randomNumber, rngCompletedAt, _rewardRecipient, sequenceId, results)
      );
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { UD2x18 } from "prb-math/UD2x18.sol";

/* ============ Structs ============ */

/// @notice Stores the results of an auction.
/// @param recipient The recipient of the auction awards
/// @param rewardFraction The fraction of the available rewards to be sent to the recipient
struct AuctionResult {
  address recipient;
  UD2x18 rewardFraction;
}

/* ============ Interface ============ */

/// @title IAuction
/// @author G9 Software Inc.
/// @notice Defines some common interfaces for auctions
interface IAuction {
  /// @notice Returns the auction duration in seconds.
  /// @return The auction duration in seconds
  function auctionDuration() external view returns (uint64);

  /// @notice Returns the last completed auction's sequence id
  function lastSequenceId() external view returns (uint32);

  /// @notice Computes the reward fraction given the auction elapsed time
  /// @param _auctionElapsedTime The elapsed time of the auction
  /// @return The reward fraction
  function computeRewardFraction(uint64 _auctionElapsedTime) external view returns (UD2x18);

  /// @notice Returns the results of the last completed auction.
  /// @return auctionResults The completed auction results
  function getLastAuctionResult() external view returns (AuctionResult memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { AuctionResult } from "./IAuction.sol";

/// @title IRngAuctionRelayListener
/// @author G9 Software Inc.
/// @notice Interface to receive RNG auction relays
interface IRngAuctionRelayListener {
  /// @notice Called by the relayer when the RNG auction is complete
  /// @param randomNumber The random number generated by the RNG auction
  /// @param rngCompletedAt The timestamp when the RNG service delivered the random number
  /// @param rewardRecipient The address of the recipient for the relay reward
  /// @param sequenceId The sequence id of the RNG auction
  /// @return any custom data it likes to track the relay.
  function rngComplete(
    uint256 randomNumber,
    uint256 rngCompletedAt,
    address rewardRecipient,
    uint32 sequenceId,
    AuctionResult calldata auctionResult
  ) external returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { UD2x18 } from "prb-math/UD2x18.sol";
import { UD60x18, convert } from "prb-math/UD60x18.sol";

import { AuctionResult } from "../interfaces/IAuction.sol";

/// @title RewardLib
/// @author G9 Software Inc.
/// @notice Library for calculating auction rewards.
/// @dev This library uses a parabolic fractional dutch auction (PFDA) to calculate rewards. For more details see https://dev.pooltogether.com/protocol/next/design/draw-auction#parabolic-fractional-dutch-auction-pfda
library RewardLib {
  /* ============ Internal Functions ============ */

  /**
   * @notice Calculates the fractional reward using a Parabolic Fractional Dutch Auction (PFDA)
   * given the elapsed time, auction time, and target sale parameters.
   * @param _elapsedTime The elapsed time since the start of the auction in seconds
   * @param _auctionDuration The auction duration in seconds
   * @param _targetTimeFraction The target sale time as a fraction of the total auction duration (0.0,1.0]
   * @param _targetRewardFraction The target fractional sale price
   * @return The reward fraction as a UD2x18 fraction
   */
  function fractionalReward(
    uint64 _elapsedTime,
    uint64 _auctionDuration,
    UD2x18 _targetTimeFraction,
    UD2x18 _targetRewardFraction
  ) internal pure returns (UD2x18) {
    UD60x18 x = convert(_elapsedTime).div(convert(_auctionDuration));
    UD60x18 t = UD60x18.wrap(_targetTimeFraction.unwrap());
    UD60x18 r = UD60x18.wrap(_targetRewardFraction.unwrap());
    UD60x18 rewardFraction;
    if (x.gt(t)) {
      UD60x18 tDelta = x.sub(t);
      UD60x18 oneMinusT = convert(1).sub(t);
      rewardFraction = r.add(
        convert(1).sub(r).mul(tDelta).mul(tDelta).div(oneMinusT).div(oneMinusT)
      );
    } else {
      UD60x18 tDelta = t.sub(x);
      rewardFraction = r.sub(r.mul(tDelta).mul(tDelta).div(t).div(t));
    }
    return UD2x18.wrap(uint64(rewardFraction.unwrap()));
  }

  /**
   * @notice Calculates rewards to distribute given the available reserve and completed
   * auction results.
   * @dev Each auction takes a fraction of the remaining reserve. This means that if the
   * reserve is equal to 100 and the first auction takes 50% and the second takes 50%, then
   * the first reward will be equal to 50 while the second will be 25.
   * @param _auctionResults Auction results to get rewards for
   * @param _reserve Reserve available for the rewards
   * @return Rewards in the same order as the auction results they correspond to
   */
  function rewards(
    AuctionResult[] memory _auctionResults,
    uint256 _reserve
  ) internal pure returns (uint256[] memory) {
    uint256 remainingReserve = _reserve;
    uint256 _auctionResultsLength = _auctionResults.length;
    uint256[] memory _rewards = new uint256[](_auctionResultsLength);
    for (uint256 i; i < _auctionResultsLength; i++) {
      _rewards[i] = reward(_auctionResults[i], remainingReserve);
      remainingReserve = remainingReserve - _rewards[i];
    }
    return _rewards;
  }

  /**
   * @notice Calculates the reward for the given auction result and available reserve.
   * @dev If the auction reward recipient is the zero address, no reward will be given.
   * @param _auctionResult Auction result to get reward for
   * @param _reserve Reserve available for the reward
   * @return Reward amount
   */
  function reward(
    AuctionResult memory _auctionResult,
    uint256 _reserve
  ) internal pure returns (uint256) {
    if (_auctionResult.recipient == address(0)) return 0;
    if (_reserve == 0) return 0;
    return
      convert(UD60x18.wrap(UD2x18.unwrap(_auctionResult.rewardFraction)).mul(convert(_reserve)));
  }
}