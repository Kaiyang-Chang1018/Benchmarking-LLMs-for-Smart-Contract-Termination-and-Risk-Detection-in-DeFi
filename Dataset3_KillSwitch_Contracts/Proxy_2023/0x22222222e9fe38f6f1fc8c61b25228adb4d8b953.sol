// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC165} from "./IERC165.sol";

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC1363} from "../../../interfaces/IERC1363.sol";
import {Address} from "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
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
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
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
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Address.sol)

pragma solidity ^0.8.20;

import {Errors} from "./Errors.sol";

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

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
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
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
     * {Errors.FailedCall} error.
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
            revert Errors.InsufficientBalance(address(this).balance, value);
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
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
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
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors.FailedCall();
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

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
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { MultiRewardsDistributor } from 'src/dao/staking/MultiRewardsDistributor.sol';
import { IERC20, SafeERC20 } from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import { EpochTracker } from 'src/dependencies/EpochTracker.sol';
import { DelegatedOps } from 'src/dependencies/DelegatedOps.sol';
import { GovStakerEscrow } from 'src/dao/staking/GovStakerEscrow.sol';
import { IResupplyRegistry } from "src/interfaces/IResupplyRegistry.sol";
import { IGovStaker } from "src/interfaces/IGovStaker.sol";

contract GovStaker is MultiRewardsDistributor, EpochTracker, DelegatedOps {
    using SafeERC20 for IERC20;

    uint24 public constant MAX_COOLDOWN_DURATION = 90 days;
    address private immutable _stakeToken;
    GovStakerEscrow public immutable escrow;
    IResupplyRegistry public immutable registry;

    // Account tracking state vars.
    mapping(address account => AccountData data) public accountData;
    mapping(address account => mapping(uint epoch => uint weight)) private accountWeightAt;

    // Global weight tracking state vars.
    uint112 public totalPending;
    uint16 public totalLastUpdateEpoch;
    mapping(uint epoch => uint weight) private totalWeightAt;

    // Cooldown tracking vars.
    uint public cooldownEpochs;
    mapping(address => UserCooldown) public cooldowns;

    // Generic token interface.
    uint private _totalSupply;

    struct AccountData {
        uint112 realizedStake; // Amount of stake that has fully realized weight.
        uint112 pendingStake; // Amount of stake that has not yet fully realized weight.
        uint16 lastUpdateEpoch;
        bool isPermaStaker;
    }

    struct UserCooldown {
        uint104 end;
        uint152 amount;
    }

    error InvalidAmount();
    error InsufficientRealizedStake();
    error InvalidCooldown();
    error InvalidDuration();
    error OldEpoch();

    /* ========== EVENTS ========== */

    event Staked(address indexed account, uint indexed epoch, uint amount);
    event Unstaked(address indexed account, uint amount);
    event Cooldown(address indexed account, uint amount, uint end);
    event CooldownEpochsUpdated(uint24 newDuration);
    event PermaStakerSet(address indexed account);


    /* ========== CONSTRUCTOR ========== */

    /**
        @param _core            Core contract address.
        @param _registry        Registry contract address.
        @param _token           Token to be staked.
        @param _cooldownEpochs  Number of epochs to cooldown for.
    */
    constructor(
        address _core,
        address _registry,
        address _token,
        uint24 _cooldownEpochs
    ) MultiRewardsDistributor(_core) EpochTracker(_core) {
        escrow = new GovStakerEscrow(address(this), _token);
        _stakeToken = _token;
        cooldownEpochs = _cooldownEpochs;
        registry = IResupplyRegistry(_registry);
        emit CooldownEpochsUpdated(_cooldownEpochs);
    }

    function stake(uint _amount) external returns (uint) {
        return _stake(msg.sender, _amount);
    }

    function stake(address _account, uint _amount) external returns (uint) {
        return _stake(_account, _amount);
    }

    function _stake(address _account, uint _amount) internal updateReward(_account) returns (uint) {
        if (_amount == 0 || _amount >= type(uint112).max) revert InvalidAmount();

        // Before going further, let's sync our account and total weights
        uint systemEpoch = getEpoch();
        (AccountData memory acctData, ) = _checkpointAccount(_account, systemEpoch);
        _checkpointTotal(systemEpoch);

        acctData.pendingStake += uint112(_amount);
        totalPending += uint112(_amount);

        accountData[_account] = acctData;
        _totalSupply += _amount;

        IERC20(_stakeToken).safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(_account, systemEpoch, _amount);

        return _amount;
    }

    /**
        @notice Request a cooldown tokens from the contract.
    */
    function cooldown(address _account, uint _amount) external callerOrDelegated(_account) returns (uint) {
        uint systemEpoch = getEpoch();
        (AccountData memory acctData, ) = _checkpointAccount(_account, systemEpoch);
        require(!acctData.isPermaStaker, "perma staker account");
        return _cooldown(_account, _amount, acctData, systemEpoch); // triggers updateReward
    }

    /**
     * @notice Initiate cooldown and claim any outstanding rewards.
     */
    function exit(address _account) external nonReentrant callerOrDelegated(_account) returns (uint) {
        uint systemEpoch = getEpoch();
        (AccountData memory acctData, ) = _checkpointAccount(_account, systemEpoch);
        require(!acctData.isPermaStaker, "perma staker account");
        _cooldown(_account, acctData.realizedStake, acctData, systemEpoch); // triggers updateReward
        _getRewardFor(_account);
        return acctData.realizedStake;
    }

    function _cooldown(address _account, uint _amount, AccountData memory acctData, uint systemEpoch) internal updateReward(_account) returns (uint) {
        if (_amount == 0 || _amount > type(uint112).max) revert InvalidAmount();
        if (acctData.realizedStake < _amount) revert InsufficientRealizedStake();
        _checkpointTotal(systemEpoch);

        acctData.realizedStake -= uint112(_amount);
        accountData[_account] = acctData;

        totalWeightAt[systemEpoch] -= _amount;
        accountWeightAt[_account][systemEpoch] -= _amount;

        _totalSupply -= _amount;

        UserCooldown memory userCooldown = cooldowns[_account];
        userCooldown.end = uint104(block.timestamp + (cooldownEpochs * epochLength));
        userCooldown.amount += uint152(_amount);
        cooldowns[_account] = userCooldown;

        emit Cooldown(_account, userCooldown.amount, userCooldown.end);
        IERC20(_stakeToken).safeTransfer(address(escrow), _amount);

        return _amount;
    }

    function unstake(address _account, address _receiver) external callerOrDelegated(_account) returns (uint) {
        return _unstake(_account, _receiver);
    }

    function _unstake(address _account, address _receiver) internal returns (uint) {
        UserCooldown storage userCooldown = cooldowns[_account];
        uint256 amount = userCooldown.amount;
        if(amount == 0) return 0;
        if(block.timestamp < userCooldown.end && cooldownEpochs != 0) revert InvalidCooldown();
        delete cooldowns[_account];
        escrow.withdraw(_receiver, amount);
        emit Unstaked(_account, amount);
        return amount;
    }

    /**
        @notice Get the current realized weight for an account
        @param _account Account to checkpoint.
        @return acctData Most recent account data written to storage.
        @return weight Most current account weight.
        @dev Prefer to use this function over it's view counterpart for
             contract -> contract interactions.
    */
    function checkpointAccount(address _account) external returns (AccountData memory acctData, uint weight) {
        (acctData, weight) = _checkpointAccount(_account, getEpoch());
        accountData[_account] = acctData;
    }

    /**
        @notice Checkpoint an account using a specified epoch limit.
        @dev    To use in the event that significant number of epochs have passed since last 
                heckpoint and single call becomes too expensive.
        @param _account Account to checkpoint.
        @param _epoch epoch number which we want to checkpoint up to.
        @return acctData Most recent account data written to storage.
        @return weight Account weight for provided epoch.
    */
    function checkpointAccountWithLimit(
        address _account,
        uint _epoch
    ) external returns (AccountData memory acctData, uint weight) {
        uint systemEpoch = getEpoch();
        if (_epoch >= systemEpoch) _epoch = systemEpoch;
        (acctData, weight) = _checkpointAccount(_account, _epoch);
        accountData[_account] = acctData;
    }

    function _checkpointAccount(
        address _account,
        uint _systemEpoch
    ) internal returns (AccountData memory acctData, uint weight) {
        acctData = accountData[_account];
        uint lastUpdateEpoch = acctData.lastUpdateEpoch;

        if (_systemEpoch == lastUpdateEpoch) {
            return (acctData, accountWeightAt[_account][lastUpdateEpoch]);
        }

        if (_systemEpoch <= lastUpdateEpoch) revert OldEpoch();

        uint pending = uint(acctData.pendingStake);
        uint realized = acctData.realizedStake;

        if (pending == 0) {
            if (realized != 0) {
                weight = accountWeightAt[_account][lastUpdateEpoch];
                while (lastUpdateEpoch < _systemEpoch) {
                    unchecked { lastUpdateEpoch++; }
                    accountWeightAt[_account][lastUpdateEpoch] = weight;
                }
            }
            accountData[_account].lastUpdateEpoch = uint16(_systemEpoch);
            acctData.lastUpdateEpoch = uint16(_systemEpoch);
            return (acctData, weight);
        }

        weight = accountWeightAt[_account][lastUpdateEpoch];

        // Add pending to realized weight
        weight += pending;
        realized = weight;

        // Fill in any missed epochs.
        while (lastUpdateEpoch < _systemEpoch) {
            unchecked { lastUpdateEpoch++; }
            accountWeightAt[_account][lastUpdateEpoch] = weight;
        }

        // Write new account data to storage.
        acctData = AccountData({
            pendingStake: 0,
            realizedStake: uint112(weight),
            lastUpdateEpoch: uint16(_systemEpoch),
            isPermaStaker: acctData.isPermaStaker
        });
    }

    /**
        @notice Get the current total system weight
        @dev Also updates local storage values for total weights. Using
             this function over it's `view` counterpart is preferred for
             contract -> contract interactions.
    */
    function checkpointTotal() external returns (uint) {
        uint systemEpoch = getEpoch();
        return _checkpointTotal(systemEpoch);
    }

    /**
        @notice Get the current total system weight
        @dev Also updates local storage values for total weights. Using
             this function over it's `view` counterpart is preferred for
             contract -> contract interactions.
    */
    function _checkpointTotal(uint systemEpoch) internal returns (uint) {
        // These two share a storage slot.
        uint16 lastUpdateEpoch = totalLastUpdateEpoch;
        uint pending = totalPending;

        uint weight = totalWeightAt[lastUpdateEpoch];

        if (lastUpdateEpoch == systemEpoch) {
            return weight;
        }

        totalLastUpdateEpoch = uint16(systemEpoch);
        weight += pending;
        totalPending = 0;

        while (lastUpdateEpoch < systemEpoch) {
            unchecked { lastUpdateEpoch++; }
            totalWeightAt[lastUpdateEpoch] = weight;
        }

        return weight;
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setCooldownEpochs(uint24 _epochs) external onlyOwner {
        if (_epochs * epochLength > MAX_COOLDOWN_DURATION) revert InvalidDuration();
        cooldownEpochs = _epochs;
        emit CooldownEpochsUpdated(_epochs);
    }

    function stakeToken() public view override returns (address) {
        return _stakeToken;
    }

    /* ========== OVERRIDES ========== */

    /**
        @notice Returns the balance of underlying staked tokens for an account
        @param _account Account to query balance.
        @return balance of account.
    */
    function balanceOf(address _account) public view override returns (uint) {
        AccountData memory acctData = accountData[_account];
        return acctData.pendingStake + acctData.realizedStake;
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    /* ========== VIEWS ========== */

    /**
        @notice View function to get the current weight for an account
    */
    function getAccountWeight(address account) external view returns (uint) {
        return getAccountWeightAt(account, getEpoch());
    }

    /**
        @notice Get the weight for an account in a given epoch
    */
    function getAccountWeightAt(address _account, uint _epoch) public view returns (uint) {
        if (_epoch > getEpoch()) return 0;

        AccountData memory acctData = accountData[_account];

        uint16 lastUpdateEpoch = acctData.lastUpdateEpoch;

        if (lastUpdateEpoch >= _epoch) return accountWeightAt[_account][_epoch];

        uint weight = accountWeightAt[_account][lastUpdateEpoch];

        uint pending = uint(acctData.pendingStake);
        if (pending == 0) return weight;

        return pending + weight;
    }

    /**
        @notice Get the system weight for current epoch.
    */
    function getTotalWeight() external view returns (uint) {
        return getTotalWeightAt(getEpoch());
    }

    /**
        @notice Get the system weight for a specified epoch in the past.
        @dev querying a epoch in the future will always return 0.
        @param epoch the epoch number to query total weight for.
    */
    function getTotalWeightAt(uint epoch) public view returns (uint) {
        uint systemEpoch = getEpoch();
        if (epoch > systemEpoch) return 0;

        // Read these together since they are packed in the same slot.
        uint16 lastUpdateEpoch = totalLastUpdateEpoch;
        uint pending = totalPending;

        if (epoch <= lastUpdateEpoch) return totalWeightAt[epoch];

        return totalWeightAt[lastUpdateEpoch] + pending;
    }

    /// @notice Get the amount of tokens that have passed cooldown.
    /// @param _account The account to query.
    /// @return . amount of tokens that have passed cooldown.
    function getUnstakableAmount(address _account) external view returns (uint) {
        UserCooldown memory userCooldown = cooldowns[_account];
        if (isCooldownEnabled() && block.timestamp < userCooldown.end) return 0;
        return userCooldown.amount;
    }

    function isCooldownEnabled() public view returns (bool) {
        return cooldownEpochs > 0;
    }

    function isPermaStaker(address _account) external view returns (bool) {
        return accountData[_account].isPermaStaker;
    }

    /* ========== PERMA STAKER FUNCTIONS ========== */

    /**
     * @notice  Set account as a permanent staker, preventing them from ever unstaking their staked tokens. 
     *          This action cannot be undone, and is irreversible.
     */
    function irreversiblyCommitAccountAsPermanentStaker(address _account) external callerOrDelegated(_account) {
        require(!accountData[_account].isPermaStaker, "already perma staker account");
        accountData[_account].isPermaStaker = true;
        emit PermaStakerSet(_account);
    }

    /**
     * @notice Migrates a perma staker's stake to a new staking contract
     * @dev Only callable when cooldown epochs are set to 0
     * @dev The new staking contract must be set in the registry
     * @dev Will claim any pending rewards before migrating
     * @dev The new staking contract must have delegate approval from this contract
     * @return amount The amount of tokens that were migrated to the new staking contract
     */
    function migrateStake() external returns (uint amount) {
        require(cooldownEpochs == 0, "cooldownEpochs != 0");
        IGovStaker staker = IGovStaker(registry.staker());
        require(address(this) != address(staker), "!migrate");
        uint systemEpoch = getEpoch();
        (AccountData memory acctData, ) = _checkpointAccount(msg.sender, systemEpoch);
        require(acctData.isPermaStaker, "not perma staker account");
        if (acctData.realizedStake > 0) {
            _cooldown(msg.sender, acctData.realizedStake, acctData, systemEpoch); // triggers updateReward
            amount = _unstake(msg.sender, address(this));
            _getRewardFor(msg.sender);
            IERC20(_stakeToken).approve(address(staker), amount);
            staker.stake(msg.sender, amount);
        }
        staker.onPermaStakeMigrate(msg.sender);
        return amount;
    }

    function onPermaStakeMigrate(address _account) external virtual {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract GovStakerEscrow {
    address immutable staker;
    IERC20 immutable token;

    constructor(address _staker, address _token) {
        staker = _staker;
        token = IERC20(_token);
    }

    modifier onlyStaker() {
        require(msg.sender == staker, "!Staker");
        _;
    }

    function withdraw(address to, uint256 amount) external onlyStaker {
        token.transfer(to, amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IERC20, SafeERC20 } from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import { ReentrancyGuard } from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import { CoreOwnable } from '../../dependencies/CoreOwnable.sol';
import { IERC20Decimals } from '../../interfaces/IERC20Decimals.sol';

abstract contract MultiRewardsDistributor is ReentrancyGuard, CoreOwnable {
    using SafeERC20 for IERC20;

    address[] public rewardTokens;
    mapping(address => Reward) public rewardData;
    mapping(address => mapping(address => uint256)) public rewards;
    mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;
    mapping(address => address) public rewardRedirect;

    uint256 public constant PRECISION = 1e18;

    function stakeToken() public view virtual returns (address);
    function balanceOf(address account) public view virtual returns (uint256);
    function totalSupply() public view virtual returns (uint256);

    struct Reward {
        address rewardsDistributor; // address with permission to update reward amount.
        uint256 rewardsDuration;
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }

    // Add these error declarations at the contract level, after the state variables
    error ZeroAddress();
    error MustBeGreaterThanZero();
    error RewardAlreadyAdded();
    error Unauthorized();
    error SupplyMustBeGreaterThanZero();
    error RewardTooHigh();
    error RewardsStillActive();
    error DecimalsMustBe18();
    error CannotAddStakeToken();
    
    /* ========== EVENTS ========== */

    event RewardAdded(address indexed rewardToken, uint256 amount);
    event RewardTokenAdded(address indexed rewardsToken, address indexed rewardsDistributor, uint256 rewardsDuration);
    event RewardsDurationUpdated(address indexed rewardsToken, uint256 duration);
    event RewardPaid(address indexed user, address indexed rewardToken, address indexed recipient, uint256 reward);
    event RewardsDistributorSet(address indexed rewardsToken, address indexed rewardsDistributor);
    event RewardRedirected(address indexed user, address indexed redirect);

    /* ========== MODIFIERS ========== */

    modifier updateReward(address _account) {
        uint256 length = rewardTokens.length;
        for (uint256 i; i < length; ++i) {
            address token = rewardTokens[i];
            uint256 rewardPerToken = rewardPerToken(token);
            rewardData[token].rewardPerTokenStored = rewardPerToken;
            rewardData[token].lastUpdateTime = lastTimeRewardApplicable(token);
            if (_account != address(0)) {
                rewards[_account][token] = earned(_account, token);
                userRewardPerTokenPaid[_account][token] = rewardPerToken;
            }
        }
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(address _core) CoreOwnable(_core) {}

    /* ========== EXTERNAL STATE CHANGE FUNCTIONS ========== */

    /**
     * @notice Claim any (and all) earned reward tokens.
     * @dev Can claim rewards even if no tokens still staked.
     * @param _account Address of the account to claim rewards for.
     */
    function getReward(address _account) external nonReentrant updateReward(_account) {
        _getRewardFor(_account);
    }

    /**
     * @notice Claim any (and all) earned reward tokens for the caller.
     * @dev Can claim rewards even if no tokens still staked.
     */
    function getReward() external nonReentrant updateReward(msg.sender) {
        _getRewardFor(msg.sender);
    }

    /**
     * @notice Claim any one earned reward token.
     * @dev Can claim rewards even if no tokens still staked.
     * @param _account Address of the account to claim rewards for.
     * @param _rewardsToken Address of the rewards token to claim.
     */
    function getOneReward(address _account, address _rewardsToken) external nonReentrant updateReward(_account) {
        uint256 reward = rewards[_account][_rewardsToken];
        if (reward > 0) {
            rewards[_account][_rewardsToken] = 0;
            address _recipient = rewardRedirect[_account];
            _recipient = _recipient != address(0) ? _recipient : _account;
            IERC20(_rewardsToken).safeTransfer(_recipient, reward);
            emit RewardPaid(_account, _rewardsToken, _recipient, reward);
        }
    }

    /* ========== EXTERNAL RESTRICTED FUNCTIONS ========== */

    /**
     * @notice Add a new reward token to the staking contract.
     * @dev May only be called by owner, and can't be set to zero address. Add reward tokens sparingly, as each new one
     *  will increase gas costs. This must be set before notifyRewardAmount can be used.
     * @param _rewardsToken Address of the rewards token.
     * @param _rewardsDistributor Address of the rewards distributor.
     * @param _rewardsDuration The duration of our rewards distribution for staking in seconds.
     * @dev To avoid precision loss, reward tokens must have 18 decimals.
     */
    function addReward(
        address _rewardsToken,
        address _rewardsDistributor,
        uint256 _rewardsDuration
    ) external onlyOwner {
        if (_rewardsToken == address(0) || _rewardsDistributor == address(0)) revert ZeroAddress();
        if (_rewardsDuration == 0) revert MustBeGreaterThanZero();
        if (rewardData[_rewardsToken].rewardsDuration != 0) revert RewardAlreadyAdded();
        if (IERC20Decimals(_rewardsToken).decimals() != 18) revert DecimalsMustBe18();
        if (_rewardsToken == stakeToken()) revert CannotAddStakeToken();

        rewardTokens.push(_rewardsToken);
        rewardData[_rewardsToken].rewardsDistributor = _rewardsDistributor;
        rewardData[_rewardsToken].rewardsDuration = _rewardsDuration;

        emit RewardTokenAdded(_rewardsToken, _rewardsDistributor, _rewardsDuration);
    }

    /**
     * @notice Notify staking contract that it has more reward to account for.
     * @dev May only be called by rewards distribution role. Set up token first via addReward().
     * @param _rewardsToken Address of the rewards token.
     * @param _rewardAmount Amount of reward tokens to add.
     */
    function notifyRewardAmount(address _rewardsToken, uint256 _rewardAmount) external updateReward(address(0)) {
        Reward memory _rewardData = rewardData[_rewardsToken];
        if (_rewardData.rewardsDistributor != msg.sender) revert Unauthorized();
        if (_rewardAmount == 0) revert MustBeGreaterThanZero();
        if (totalSupply() == 0) revert SupplyMustBeGreaterThanZero();

        // handle the transfer of reward tokens via `transferFrom` to reduce the number
        // of transactions required and ensure correctness of the reward amount
        IERC20(_rewardsToken).safeTransferFrom(msg.sender, address(this), _rewardAmount);

        // store locally to save gas
        uint256 newRewardRate;

        if (block.timestamp >= _rewardData.periodFinish) {
            newRewardRate = _rewardAmount / _rewardData.rewardsDuration;
        } else {
            newRewardRate =
                (_rewardAmount + (_rewardData.periodFinish - block.timestamp) * _rewardData.rewardRate) /
                _rewardData.rewardsDuration;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        if (newRewardRate > (IERC20(_rewardsToken).balanceOf(address(this)) / _rewardData.rewardsDuration)) {
            revert RewardTooHigh();
        }

        _rewardData.rewardRate = newRewardRate;
        _rewardData.lastUpdateTime = block.timestamp;
        _rewardData.periodFinish = block.timestamp + _rewardData.rewardsDuration;
        rewardData[_rewardsToken] = _rewardData; // Write to storage

        emit RewardAdded(_rewardsToken, _rewardAmount);
    }

    /**
     * @notice Set rewards distributor address for a given reward token.
     * @dev May only be called by owner, and can't be set to zero address.
     * @param _rewardsToken Address of the rewards token.
     * @param _rewardsDistributor Address of the rewards distributor. This is the only address that can add new rewards
     *  for this token.
     */
    function setRewardsDistributor(address _rewardsToken, address _rewardsDistributor) external onlyOwner {
        if (_rewardsToken == address(0) || _rewardsDistributor == address(0)) revert ZeroAddress();
        rewardData[_rewardsToken].rewardsDistributor = _rewardsDistributor;
        emit RewardsDistributorSet(_rewardsToken, _rewardsDistributor);
    }

    /**
     * @notice Set the duration of our rewards period.
     * @dev May only be called by rewards distributor, and must be done after most recent period ends.
     * @param _rewardsToken Address of the rewards token.
     * @param _rewardsDuration New length of period in seconds.
     */
    function setRewardsDuration(address _rewardsToken, uint256 _rewardsDuration) external {
        if (block.timestamp <= rewardData[_rewardsToken].periodFinish) revert RewardsStillActive();
        if (msg.sender != rewardData[_rewardsToken].rewardsDistributor && msg.sender != owner()) revert Unauthorized();
        if (_rewardsDuration == 0) revert MustBeGreaterThanZero();
        rewardData[_rewardsToken].rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(_rewardsToken, _rewardsDuration);
    }

    /**
     * @notice Sweep out tokens accidentally sent here.
     * @dev May only be called by owner. If a pool has multiple tokens to sweep out, call this once for each.
     * @param _tokenAddress Address of token to sweep.
     * @param _tokenAmount Amount of tokens to sweep.
     */
    function recoverERC20(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        if (_tokenAddress == stakeToken()) {
            _tokenAmount = IERC20(_tokenAddress).balanceOf(address(this)) - totalSupply();
            if (_tokenAmount > 0) {
                IERC20(_tokenAddress).safeTransfer(owner(), _tokenAmount);
            }
            return;
        }

        address[] memory _rewardTokens = rewardTokens;

        for (uint256 i; i < _rewardTokens.length; ++i) {
            if (_rewardTokens[i] == _tokenAddress) {
                return; // Can't recover reward token
            }
        }

        IERC20(_tokenAddress).safeTransfer(owner(), _tokenAmount);
    }


    /* ========== INTERNAL FUNCTIONS ========== */

    // internal function to get rewards.
    function _getRewardFor(address _account) internal {
        uint256 length = rewardTokens.length;
        address _recipient = rewardRedirect[_account];
        _recipient = _recipient != address(0) ? _recipient : _account;
        for (uint256 i; i < length; ++i) {
            address _rewardsToken = rewardTokens[i];
            uint256 reward = rewards[_account][_rewardsToken];
            if (reward > 0) {
                rewards[_account][_rewardsToken] = 0;
                IERC20(_rewardsToken).safeTransfer(_recipient, reward);
                emit RewardPaid(_account, _rewardsToken, _recipient, reward);
            }
        }
    }

    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

    /* ========== VIEWS ========== */

    /**
     * @notice Amount of reward token pending claim by an account.
     * @param _account Account to check earned balance for.
     * @param _rewardsToken Rewards token to check.
     * @return pending Amount of reward token pending claim.
     */
    function earned(address _account, address _rewardsToken) public view returns (uint256 pending) {
        pending = (
                balanceOf(_account) 
                * (
                    rewardPerToken(_rewardsToken) 
                    - userRewardPerTokenPaid[_account][_rewardsToken]
                )
            ) 
            / PRECISION 
            + rewards[_account][_rewardsToken];
    }

    /**
     * @notice Amount of reward token(s) pending claim by an account.
     * @dev Checks for all rewardTokens.
     * @param _account Account to check earned balance for.
     * @return pending Amount of reward token(s) pending claim.
     */
    function earnedMulti(address _account) external view returns (uint256[] memory pending) {
        address[] memory _rewardTokens = rewardTokens;
        uint256 length = _rewardTokens.length;
        pending = new uint256[](length);

        for (uint256 i; i < length; ++i) {
            pending[i] = earned(_account, _rewardTokens[i]);
        }
    }

    /**
     * @notice Reward paid out per whole token.
     * @param _rewardsToken Reward token to check.
     * @return rewardAmount Reward paid out per whole token.
     */
    function rewardPerToken(address _rewardsToken) public view returns (uint256 rewardAmount) {
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            return rewardData[_rewardsToken].rewardPerTokenStored;
        }

        rewardAmount =
            rewardData[_rewardsToken].rewardPerTokenStored +
            (((lastTimeRewardApplicable(_rewardsToken) - rewardData[_rewardsToken].lastUpdateTime) *
                rewardData[_rewardsToken].rewardRate *
                PRECISION) / _totalSupply);
    }

    function lastTimeRewardApplicable(address _rewardsToken) public view returns (uint256) {
        return min(block.timestamp, rewardData[_rewardsToken].periodFinish);
    }

    /// @notice Number reward tokens we currently have.
    function rewardTokensLength() external view returns (uint256) {
        return rewardTokens.length;
    }

    /**
     * @notice Total reward that will be paid out over the reward duration.
     * @dev These values are only updated when notifying, adding, or adjust duration of rewards.
     * @param _rewardsToken Reward token to check.
     * @return Total reward tokens paid out over the reward duration.
     */
    function getRewardForDuration(address _rewardsToken) external view returns (uint256) {
        return rewardData[_rewardsToken].rewardRate * rewardData[_rewardsToken].rewardsDuration;
    }

    /**
     * @notice Sets new target address for staker's rewards.
     * @param _to Address to redirect rewards to. Set to address(0) to clear redirect.
     */
    function setRewardRedirect(address _to) external nonReentrant{
        rewardRedirect[msg.sender] = _to;
        emit RewardRedirected(msg.sender, _to);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ICore} from "../interfaces/ICore.sol";

/**
    @title Core Ownable
    @author Prisma Finance (with edits by Resupply Finance)
    @notice Contracts inheriting `CoreOwnable` have the same owner as `Core`.
            The ownership cannot be independently modified or renounced.
 */
contract CoreOwnable {
    ICore public immutable core;

    constructor(address _core) {
        core = ICore(_core);
    }

    modifier onlyOwner() {
        require(msg.sender == address(core), "!core");
        _;
    }

    function owner() public view returns (address) {
        return address(core);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
    @title Delegated Operations
    @author Prisma Finance (with edits by Resupply Finance)
    @notice Allows delegation to specific contract functionality. Useful for creating
            wrapper contracts to bundle multiple interactions into a single call.
 */
contract DelegatedOps {
    event DelegateApprovalSet(address indexed account, address indexed delegate, bool isApproved);

    mapping(address owner => mapping(address caller => bool isApproved)) public isApprovedDelegate;

    modifier callerOrDelegated(address _account) {
        require(msg.sender == _account || isApprovedDelegate[_account][msg.sender], "!CallerOrDelegated");
        _;
    }

    function setDelegateApproval(address _delegate, bool _isApproved) external {
        isApprovedDelegate[msg.sender][_delegate] = _isApproved;
        emit DelegateApprovalSet(msg.sender, _delegate, _isApproved);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "../interfaces/ICore.sol";

/**
    @title EpochTracker
    @dev Provides a unified `startTime` and `getEpoch`, used for tracking epochs.
 */
contract EpochTracker {
    uint256 public immutable startTime;
    
    /// @notice Length of an epoch, in seconds
    uint256 public immutable epochLength;

    constructor(address _core) {
        startTime = ICore(_core).startTime();
        epochLength = ICore(_core).epochLength();
    }

    function getEpoch() public view returns (uint256 epoch) {
        return (block.timestamp - startTime) / epochLength;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IAuthHook {
    function preHook(address operator, address target, bytes calldata data) external returns (bool);
    function postHook(bytes memory result, address operator, address target, bytes calldata data) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IAuthHook } from './IAuthHook.sol';

interface ICore {
    struct OperatorAuth {
        bool authorized;
        IAuthHook hook;
    }

    event VoterSet(address indexed newVoter);
    event OperatorExecuted(address indexed caller, address indexed target, bytes data);
    event OperatorSet(address indexed caller, address indexed target, bool authorized, bytes4 selector, IAuthHook authHook);

    function execute(address target, bytes calldata data) external returns (bytes memory);
    function epochLength() external view returns (uint256);
    function startTime() external view returns (uint256);
    function voter() external view returns (address);
    function ownershipTransferDeadline() external view returns (uint256);
    function pendingOwner() external view returns (address);
    function setOperatorPermissions(
        address caller,
        address target,
        bytes4 selector,
        bool authorized,
        IAuthHook authHook
    ) external;
    function setVoter(address newVoter) external;
    function operatorPermissions(address caller, address target, bytes4 selector) external view returns (bool authorized, IAuthHook hook);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IERC20Decimals {
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IGovStaker {
    /* ========== EVENTS ========== */
    event RewardAdded(address indexed rewardToken, uint256 amount);
    event RewardTokenAdded(address indexed rewardsToken, address indexed rewardsDistributor, uint256 rewardsDuration);
    event Recovered(address indexed token, uint256 amount);
    event RewardsDurationUpdated(address indexed rewardsToken, uint256 duration);
    event RewardPaid(address indexed user, address indexed rewardToken, uint256 reward);
    event Staked(address indexed account, uint indexed epoch, uint amount);
    event Unstaked(address indexed account, uint amount);
    event Cooldown(address indexed account, uint amount, uint end);
    event CooldownEpochsUpdated(uint24 newDuration);

    /* ========== STRUCTS ========== */
    struct Reward {
        address rewardsDistributor;
        uint256 rewardsDuration;
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }

    struct AccountData {
        uint120 realizedStake; // Amount of stake that has fully realized weight.
        uint120 pendingStake; // Amount of stake that has not yet fully realized weight.
        uint16 lastUpdateEpoch;
    }

    struct UserCooldown {
        uint104 end;
        uint152 amount;
    }

    enum ApprovalStatus {
        None, // 0. Default value, indicating no approval
        StakeOnly, // 1. Approved for stake only
        UnstakeOnly, // 2. Approved for unstake only
        StakeAndUnstake // 3. Approved for both stake and unstake
    }

    /* ========== STATE VARIABLES ========== */
    function rewardTokens(uint256 index) external view returns (address);
    function rewardData(address token) external view returns (Reward memory);
    function rewards(address account, address token) external view returns (uint256);
    function userRewardPerTokenPaid(address account, address token) external view returns (uint256);
    function CORE() external view returns (address);
    function PRECISION() external view returns (uint256);
    function ESCROW() external view returns (address);
    function MAX_COOLDOWN_DURATION() external view returns (uint24);
    function totalPending() external view returns (uint120);
    function totalLastUpdateEpoch() external view returns (uint16);
    function cooldownEpochs() external view returns (uint256);
    function decimals() external view returns (uint8);
    function approvedCaller(address account, address caller) external view returns (ApprovalStatus);

    /* ========== EXTERNAL FUNCTIONS ========== */
    function accountData(address account) external view returns (AccountData memory);
    function stakeToken() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function getReward() external;
    function getOneReward(address rewardsToken) external;
    function addReward(address rewardsToken, address rewardsDistributor, uint256 rewardsDuration) external;
    function notifyRewardAmount(address rewardsToken, uint256 rewardAmount) external;
    function setRewardsDistributor(address rewardsToken, address rewardsDistributor) external;
    function setRewardsDuration(address rewardsToken, uint256 rewardsDuration) external;
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external;
    function stake(address account, uint amount) external returns (uint);
    function stakeFor(address account, uint amount) external returns (uint);
    function cooldown(address account, uint amount) external returns (uint);
    function cooldowns(address account) external view returns (UserCooldown memory);
    function cooldownFor(address account, uint amount) external returns (uint);
    function exit(address account) external returns (uint);
    function exitFor(address account) external returns (uint);
    function unstake(address account, address receiver) external returns (uint);
    function unstakeFor(address account, address receiver) external returns (uint);
    function checkpointAccount(address account) external returns (AccountData memory, uint weight);
    function checkpointAccountWithLimit(address account, uint epoch) external returns (AccountData memory, uint weight);
    function checkpointTotal() external returns (uint);
    function setApprovedCaller(address caller, ApprovalStatus status) external;
    function setCooldownEpochs(uint24 epochs) external;
    function getAccountWeight(address account) external view returns (uint);
    function getAccountWeightAt(address account, uint epoch) external view returns (uint);
    function getTotalWeight() external view returns (uint);
    function getTotalWeightAt(uint epoch) external view returns (uint);
    function getUnstakableAmount(address account) external view returns (uint);
    function isCooldownEnabled() external view returns (bool);
    function rewardTokensLength() external view returns (uint256);
    function earned(address account, address rewardsToken) external view returns (uint256 pending);
    function earnedMulti(address account) external view returns (uint256[] memory pending);
    function rewardPerToken(address rewardsToken) external view returns (uint256 rewardAmount);
    function lastTimeRewardApplicable(address rewardsToken) external view returns (uint256);
    function getRewardForDuration(address rewardsToken) external view returns (uint256);
    function owner() external view returns (address);
    function guardian() external view returns (address);
    function getEpoch() external view returns (uint);
    function epochLength() external view returns (uint);
    function startTime() external view returns (uint);
    function irreversiblyCommitAccountAsPermanentStaker(address account) external;
    function onPermaStakeMigrate(address account) external;
    function migrateStake() external returns (uint amount);
    function setDelegateApproval(address delegate, bool approved) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IResupplyRegistry {
    event AddPair(address pairAddress);
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SetDeployer(address deployer, bool _bool);

    function acceptOwnership() external;

    function addPair(address _pairAddress) external;

    function registeredPairs(uint256) external view returns (address);

    function pairsByName(string memory) external view returns (address);

    function defaultSwappersLength() external view returns (uint256);
    function registeredPairsLength() external view returns (uint256);

    function getAllPairAddresses() external view returns (address[] memory _deployedPairsArray);
    
    function getAllDefaultSwappers() external view returns (address[] memory _defaultSwappers);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    function claimFees(address _pair) external;
    function claimRewards(address _pair) external;
    function claimInsuranceRewards() external;
    function withdrawTo(address _asset, uint256 _amount, address _to) external;
    function mint( address receiver, uint256 amount) external;
    function burn( address target, uint256 amount) external;
    function liquidationHandler() external view returns(address);
    function feeDeposit() external view returns(address);
    function redemptionHandler() external view returns(address);
    function rewardHandler() external view returns(address);
    function insurancePool() external view returns(address);
    function setRewardClaimer(address _newAddress) external;
    function setRedemptionHandler(address _newAddress) external;
    function setFeeDeposit(address _newAddress) external;
    function setLiquidationHandler(address _newAddress) external;
    function setInsurancePool(address _newAddress) external;
    function setStaker(address _newAddress) external;
    function setTreasury(address _newAddress) external;
    function staker() external view returns(address);
    function token() external view returns(address);
    function treasury() external view returns(address);
    function govToken() external view returns(address);
    function l2manager() external view returns(address);
    function setRewardHandler(address _newAddress) external;
    function setVestManager(address _newAddress) external;
    function setDefaultSwappers(address[] memory _swappers) external;
    function collateralId(address _collateral) external view returns(uint256);
}