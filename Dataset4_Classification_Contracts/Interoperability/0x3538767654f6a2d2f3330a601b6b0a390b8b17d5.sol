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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
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
pragma solidity 0.8.20;

import { SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

// BridgeWrapper Interface implementing BridgeWrapper.sol
interface IBridgeWrapper {
    function receiveFromChain(uint16 _srcChainId, uint256 _amount, address _toAddress) external;
	function wToken() external returns (address);

}

// Errors
error InvalidValsetNonce(uint256 newNonce, uint256 currentNonce);
error InvalidBatchNonce(uint256 newNonce, uint256 currentNonce);
error IncorrectCheckpoint();
error MalformedNewValidatorSet();
error MalformedCurrentValidatorSet();
error MalformedBatch();
error InsufficientPower(uint256 cumulativePower, uint256 powerThreshold);
error DeadlineExceeded();
error NewPowerThresholdTooLow();
error InvalidSignature();

/**
 * @title ConsensusBridge
 * @author Tensorplex Lab
 * @notice This contract in addition to BridgeWrapper.sol, helps to facilitate the bridging of tokens from a given chain to Ethereum. 
 *         In the short-term we intend to use these contracts to bridge TAO from BitTensor to a new wrapped TAO on Ethereum.
 *         In the future we hope to reuse these contracts to bridge from future partner blockchains to Ethereum.
 * 
 *         Specifically this contract implements
 *           1. batch minting of wrapped Tokens on Ethereum in submitBatch()
 *           2. replacing current bridge validators in updateValset()
 * 
 * 		  To successfully execute submitBatch or updateValset, a checkpoint (hash) validation must be passed.
 * 		  In both functions, a new checkpoint (hash) is created with the input valset. 
 *        This checkpoint is checked against the bridge's state checkpoint. If they do not match the function will fail.
 *        This enforces that successful execution requires signatures from the state validators, ie. only the Tensorplex multisig wallet. 
 *        We expect to use our relayers as validators.
 * 
 */
contract ConsensusBridge is ReentrancyGuard{
	// Libraries
    using SafeERC20 for IERC20;

	// Variables
    bytes32 public immutable state_gravityId;
    uint256 public powerThreshold = 0;          // powerThreshold must be >= 2. If submitted powers < powerThreshold then the transaction will fail.
	uint256 public state_lastValsetNonce = 0; 
	uint256 public state_lastEventNonce = 0;
	bytes32 public state_lastValsetCheckpoint; // is a hash that is assigned whenever bridge validators are updated (see updateValset() ). 

	mapping(address => uint256) public state_lastBatchNonces;
	mapping(address => uint256) public state_lastTransactionNonce;
	
    struct ValsetArgs {
        // the validators in this set, represented by an Ethereum address
        address[] validators;

        // the powers of the given validators in the same order as above
		// powers is a generalized representation of the voting influence held by that validator. 
		// For our inital implementation we intend for all validators to have the same power value of 1.
		// In future deployments, powers might represent the # of governance tokens held by that validator.
        uint256[] powers;

		// Nonce value for a given valset, to prevent double execution. 
        uint256 valsetNonce;
    }

	// ECDSA Signature format
	struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

	// Events
    event TransactionBatchExecutedEvent(
		uint256 indexed _batchNonce,
		address indexed _token,
		uint256 _eventNonce
	);
    event ValsetUpdatedEvent(
		uint256 indexed _newValsetNonce,
		uint256 _eventNonce,
		address[] _validators,
		uint256[] _powers
	);
    event ReceiveFromChain(
		uint16 indexed _srcChainId,
		address indexed _to,
		uint _amount,
		address wToken,
		bytes32 txnId,
		uint256 transactionNonce
	);

	/**
	 * @notice initializes a ConsensusBridge contract.
	 * @param _gravityId A unique identifier for this gravity instance to use in signatures
	 * @param _validators is an array of validator addresses. These should be the addresses of the Tensorplex relayers. 
	 * @param _powers is an array of corresponding power values for the validators.
	 */
	constructor(
		bytes32 _gravityId,
		// The validator set, not in valset args format since many of it's arguments would never be used in this case
		address[] memory _validators,
		uint256[] memory _powers
	) {
		// CHECKS

		// Check that validators, powers, and signatures (v,r,s) set is well-formed
		if (_validators.length != _powers.length || _validators.length == 0) {
			revert MalformedCurrentValidatorSet();
		}

		// assigning inital valset
		ValsetArgs memory _valset;
		_valset = ValsetArgs(_validators, _powers, 0);

		bytes32 newCheckpoint = makeCheckpoint(_valset, _gravityId);

		// ACTIONS

		// If new powerThreshold is >= 2 then set the new powerThreshold, else revert. 
		uint256 newThreshold = calculatePowerThreshold(_powers);
		if (newThreshold >= 2) {
			powerThreshold = newThreshold;
		} else {
			revert NewPowerThresholdTooLow();
		}

		// set initial state checkpoint
		state_gravityId = _gravityId;
		state_lastValsetCheckpoint = newCheckpoint;

		// LOGS
		emit ValsetUpdatedEvent(
			state_lastValsetNonce,
			state_lastEventNonce,
			_validators,
			_powers
		);
	}

	/**
	 * @dev ceil is a helper function to round up. It is a workaround to solidity's default rounding down behaviour. 
	 * @dev used in PowerThreshold calculation to ensure that threshold is rounded up rather than down.
	 * 
	 * @param a is the input value to be rounded
	 * @param m is the decimal to be rounded to (eg 10 to round to closest 10)
	 */
	function ceil(uint a, uint m) private pure returns (uint ) {
        return ((a + m - 1) / m) * m;
    }

	/**
	 * @notice makeCheckpoint returns a checkpoint of an input valset
	 * @dev under the hood, this function returns a keccak256 hash of the valset and _gravityId. 
	 * @dev used internally by this contract, and is also called by our relayers.
	 * 
	 * @param _valsetArgs is the input valset that will be hashed
	 * @param _gravityId is the unique ID for this gravity instance to be used in signing. 
	 */
	function makeCheckpoint(ValsetArgs memory _valsetArgs, bytes32 _gravityId)
		public
		pure
		returns (bytes32)
	{
		// bytes32 encoding of the string "checkpoint"
		bytes32 methodName = 0x636865636b706f696e7400000000000000000000000000000000000000000000;

		bytes32 checkpoint = keccak256(
			abi.encode(
                _gravityId,
				methodName,
				_valsetArgs.valsetNonce,
				_valsetArgs.validators,
				_valsetArgs.powers
			)
		);

		return checkpoint;
	}

	/**
	 * @notice calculatePowerThreshold returns the threshold for an input valset that is necessary for a vote to pass. 
	 * @dev this is hardcoded to return 2/3rds of the input. 
	 * @dev because solidity rounds down on divsion, we use scaling factor to retain decimal value.
	 * @dev because we are using a scaling factor of 1e18, powers in excess of 5.79 * 10^76 could cause an interger overflow.
	 * 
	 * @param _powers is an array of power values. The threshold is calculated on the sum of this array.
	 */
    function calculatePowerThreshold(uint256[] memory _powers) internal returns (uint256) {
		uint256 totalPower = 0;
        for (uint256 i = 0; i < _powers.length; i++) {
            totalPower += _powers[i];
        }

		// numerator = 2
		// denominator = 3
		// scalingFactor = 1e18
		uint256 result = (totalPower * 2 * 1e18) / 3;
		powerThreshold = (ceil(result, 1e18) / 1e18);

		return powerThreshold;
    }

	/**
	 * @notice updateValset replaces the bridge's current valset with a new valset.
	 * @dev This function is expected to be called with the current validators.
	 * @dev To succeed, the checkpoint (hash) of input _currentValset must match the state valset checkpoint, 
	 *      meaning only the current validators can successfully call this function.
	 * @dev It is intended that only Tensorplex can successfully updateValset as enforced by this checkpoint matching.

	 * @param _newValset is the valset to be inserted
	 * @param _currentValset is the valset that is replaced
	 * @param _sigs is an array of signatures from _currentValset that have signed on the newValset.
	 */
	function updateValset(
		// The new version of the validator set
		ValsetArgs calldata _newValset,
		// The current validators that approve the change
		ValsetArgs calldata _currentValset,
		// These are arrays of the parts of the current validator's signatures
		Signature[] calldata _sigs
	) external {
		// Check that the valset nonce is greater than the old one
		if (_newValset.valsetNonce <= _currentValset.valsetNonce) {
			revert InvalidValsetNonce({
				newNonce: _newValset.valsetNonce,
				currentNonce: _currentValset.valsetNonce
			});
		}

		// Check that the valset nonce is less than a million nonces forward from the old one
		// this makes it difficult for an attacker to lock out the contract by getting a single
		// bad validator set through with uint256 max nonce
		if (_newValset.valsetNonce > _currentValset.valsetNonce + 1000000) {
			revert InvalidValsetNonce({
				newNonce: _newValset.valsetNonce,
				currentNonce: _currentValset.valsetNonce
			});
		}

		// Check that new validators and powers set is well-formed
		if (
			_newValset.validators.length != _newValset.powers.length ||
			_newValset.validators.length == 0
		) {
			revert MalformedNewValidatorSet();
		}

		// Check that current validators, powers, and signatures (v,r,s) set is well-formed
		validateValset(_currentValset, _sigs);

		// Check that the supplied current validator set matches the saved checkpoint
		if (makeCheckpoint(_currentValset, state_gravityId) != state_lastValsetCheckpoint) {
			revert IncorrectCheckpoint();
		}

		// Check that enough current validators have signed off on the new validator set
		bytes32 newCheckpoint = makeCheckpoint(_newValset, state_gravityId);

		// Checks that current valset has signed on newCheckpoint and that it has sufficient power to pass.
		checkValidatorSignatures(_currentValset, _sigs, newCheckpoint, powerThreshold);

		// If new powerThreshold is >= 2 then set the new powerThreshold, else revert. 
		uint256 newThreshold = calculatePowerThreshold(_newValset.powers);
		if (newThreshold >= 2) {
			powerThreshold = newThreshold;
		} else {
			revert NewPowerThresholdTooLow();
		}
		// ACTIONS

		// Stored to be used next time to validate that the valset
		// supplied by the caller is correct.
		state_lastValsetCheckpoint = newCheckpoint;

		// Store new nonce
		state_lastValsetNonce = _newValset.valsetNonce;

		state_lastEventNonce = state_lastEventNonce + 1;
		emit ValsetUpdatedEvent(
			_newValset.valsetNonce,
			state_lastEventNonce,
			_newValset.validators,
			_newValset.powers
		);
	}

	// @notice Ensures a valset is well-formed against input signatures
	// @param _valset is the valset to be validated
	// @param _sigs is an array of signatures
	function validateValset(ValsetArgs calldata _valset, Signature[] calldata _sigs) private pure {
		// Check that current validators, powers, and signatures (v,r,s) set is well-formed
		if (
			_valset.validators.length != _valset.powers.length ||
			_valset.validators.length != _sigs.length
		) {
			revert MalformedCurrentValidatorSet();
		}
	}

	/**
	 * @notice verifySig checks if a signed message _sig was created by the input address _signer.
	 * @param _signer is the expected address that signed _sig
	 * @param _theHash is the expected hash used to sign the message
	 * @param _sig is the signature containing (r,s,v)
	 */
    function verifySig(
		address _signer,
		bytes32 _theHash,
		Signature calldata _sig
	) private pure returns (bool) {
		bytes32 messageDigest = keccak256(
			abi.encodePacked("\x19Ethereum Signed Message:\n32", _theHash)
		);

		address retrievedSigner = ECDSA.recover(messageDigest, _sig.v, _sig.r, _sig.s);
		if(_signer != retrievedSigner) {
			return false;
		}
		return true;
	}

	/**
	 * @notice checkValidatorSignatures checks if the input validator set has signed on the input hash value. 
	 * @dev there is a 2/3rds quorum requirement. If 2/3rds of total validator power has signed, then the transaction can pass.
	 * 
	 * @param _currentValset is the expected currentValset
	 * @param _sigs is an array of signatures to be validated
	 * @param _theHash is the hash of the transaction that was signed
	 * @param _powerThreshold is the value of power required to pass a vote. Cumulative validator power must exceed this to pass.
	 */
	function checkValidatorSignatures(
		// The current validator set and their powers
		ValsetArgs calldata _currentValset,
		// The current validator's signatures
		Signature[] calldata _sigs,
		// This is what we are checking they have signed
		bytes32 _theHash,
		uint256 _powerThreshold
	) private pure {
		uint256 cumulativePower = 0;

		for (uint256 i = 0; i < _currentValset.validators.length; i++) {
			// V must be more than 0
			// If not we shall not process it 
			if(_sigs[i].v != 0) {
				// If v is set to 0, this signifies that it was not possible to get a signature from this validator and we skip evaluation
				// (In a valid signature, it is either 27 or 28)
				// Check that the current validator has signed off on the hash
				bool result = verifySig(_currentValset.validators[i], _theHash, _sigs[i]);
				if(!result) {
					revert InvalidSignature();
				}
				// Sum up cumulative power
				cumulativePower = cumulativePower + _currentValset.powers[i];
			}

			// Break early to avoid wasting gas
			if (cumulativePower > _powerThreshold) {
				break;
			}
		}

		if (cumulativePower < _powerThreshold) {
			revert InsufficientPower(cumulativePower, _powerThreshold);
		}
		// Success
	}

	/**
	 * @notice submitBatch batch executes minting of wrapped Token on Ethereum, sending tokens from the bridge to input addresses on Ethereum.
	 * @dev submitBatch should be triggered after corresponding events emitted on Finney
	 * @dev it is expected that this function is only called by Tensorplex validators.
	 * 
	 * @param _currentValset is expected to be the state valset. If it is not, the submission will fail.
	 * @param _sigs is a corresponding array of validator signatures
	 * @param _amounts is an array of amounts to be transferred
	 * @param _destinations is an array of destination EVM addresses that will recieve amounts. 
	 * @param _transactionIds is an array of transactionIds containing the hashes of corresponding transfer events from source chain.
	 * @param _sourceChainId a unqiue ID identifying the source chain. It is used by the Tensorplex relayers for record keeping.
	 * @param _batchNonce is the nonce.
	 * @param _tokenWrapperAddress is expected to be the address of a deployed BridgeWrapper.sol
	 * @param _deadline is the timestamp that the batch must be executed by. 
	 */
    function submitBatch(
		// The validators that approve the batch
		ValsetArgs calldata _currentValset,
		// These are arrays of the parts of the validators signatures
		Signature[] calldata _sigs,
		// The batch of transactions
		uint256[] calldata _amounts,
		address[] calldata _destinations,
		bytes32[] calldata _transactionIds,
        uint16 _sourceChainId,
		uint256 _batchNonce,
		address _tokenWrapperAddress,
		uint256 _deadline
    ) external nonReentrant {
		if (block.timestamp > _deadline) {
			revert DeadlineExceeded();
		}

        if (_batchNonce <= state_lastBatchNonces[_tokenWrapperAddress] || _batchNonce > state_lastBatchNonces[_tokenWrapperAddress] + 1000000) {
            revert InvalidBatchNonce({
                newNonce: _batchNonce,
                currentNonce: state_lastBatchNonces[_tokenWrapperAddress]
            });
        }

        validateValset(_currentValset, _sigs);
        if (_amounts.length != _destinations.length || _destinations.length != _transactionIds.length) {
            revert MalformedBatch();
        }

		// Check that the supplied current validator set matches the saved checkpoint
		if (makeCheckpoint(_currentValset, state_gravityId) != state_lastValsetCheckpoint) {
			revert IncorrectCheckpoint();
		}

        checkValidatorSignatures(
            _currentValset,
            _sigs,
            // Get hash of the transaction batch and checkpoint
            keccak256(
                abi.encode(
                    state_gravityId,
					// bytes encoding for bridge batching 
                    0x7472616e73616374696f6e426174636800000000000000000000000000000000,
                    _amounts,
                    _destinations,
					_transactionIds,
					_sourceChainId,
                    _batchNonce,
                    _tokenWrapperAddress,
					_deadline
                )
            ),
            powerThreshold
        );
        state_lastBatchNonces[_tokenWrapperAddress] = _batchNonce;
		state_lastEventNonce = state_lastEventNonce + 1;
        {
			// if any of the destination chains have a revert fallback, the whole function will revert
			// should be okay considering destinations are expected to be wallet addresses?
            for (uint256 i = 0; i < _destinations.length; i++) {
                address destination = _destinations[i];
                uint256 amount = _amounts[i];
				address wToken = IBridgeWrapper(_tokenWrapperAddress).wToken();
				bytes32 txnId = _transactionIds[i];
				uint256 oldTxnNonce = state_lastTransactionNonce[_tokenWrapperAddress];
				state_lastTransactionNonce[_tokenWrapperAddress] += 1;
                IBridgeWrapper(_tokenWrapperAddress).receiveFromChain(_sourceChainId, amount, destination);
				emit ReceiveFromChain(_sourceChainId, destination, amount, wToken, txnId, oldTxnNonce);
            }
        }
        {
			emit TransactionBatchExecutedEvent(_batchNonce, _tokenWrapperAddress, state_lastEventNonce);
		}
    }


}