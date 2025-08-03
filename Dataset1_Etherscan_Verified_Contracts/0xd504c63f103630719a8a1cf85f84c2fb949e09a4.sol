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
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Interface to interact with Uniswap V2 Pair contracts
/// @notice Used to fetch ETH price in USD via reserve data
interface IUniswapV2Pair {
    /// @notice Retrieves the reserves of the pair
    /// @return reserve0 Amount of the first reserve
    /// @return reserve1 Amount of the second reserve
    /// @return blockTimestampLast Timestamp of the last block the reserves were updated
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

/**
 * @title PedroPresale
 * @dev Manages the presale of the PEDRO token with dynamic pricing and vesting mechanisms.
 * Supports purchases with ETH, USDT, and USDC, ensuring secure and efficient operations.
 */
contract PedroPresale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice The ERC20 token being sold in the presale
    IERC20 public immutable token;

    /// @notice Uniswap USDT pair for price fetching related to `getETHPriceUSDT` function
    IUniswapV2Pair public immutable eth_usdtPair;

    /// @notice The wallet address where collected funds are forwarded
    address payable public wallet;

    /// @notice Total number of PEDRO tokens allocated for the presale
    uint256 public constant TOTAL_PRESALE_TOKENS = 273_333_333 * 10 ** 18;

    /// @notice Unix timestamp marking the start of the presale
    uint256 public presaleStart;

    /// @notice Initial price per PEDRO token in USD (e.g., $0.02), scaled by 1e18 for precision
    uint256 public initialPriceUSD = 2 * 1e4;

    /// @notice Price increase factor per interval (1.5% represented in 18 decimals)
    uint256 public priceIncreaseFactor = 1015;

    /// @notice Denominator used for percentage calculations
    uint256 public constant percentageDenominator = 1000;

    /// @notice Duration of each price increase interval in seconds (48 hours)
    uint256 public priceIncreaseInterval = 48 hours;

    /// @notice Maximum number of supported ERC20 payment methods (e.g., USDT, USDC)
    uint8 public constant MAX_PAYMENT_METHODS = 5;

    /// @notice Mapping of supported ERC20 payment tokens
    mapping(address => bool) public supportedERC20;

    /// @notice Structure to store individual user contributions
    struct Contribution {
        uint256 amountUSD;        ///< Total contributed amount in USD
        uint256 tokensPurchased;  ///< Total PEDRO tokens purchased
        uint256 tokenBonus;       ///< Total PEDRO bonus tokens
        uint256 tokenTotal;       ///< Total PEDRO tokens (purchased + bonus)
    }

    /// @notice Structure for the Affiliate Program
    struct Affiliate {
        uint256 refCount;    ///< Number of referrals made by the affiliate
        uint256 usdtValue;   ///< Total USDT value contributed by referrals
    }

    /// @notice Mapping of user addresses to their contributions
    mapping(address => Contribution) public contributions;

    /// @notice Total amount raised in USD
    uint256 public totalUSDRaised;

    /// @notice Unix timestamp marking the DEX listing time
    uint256 public dexListingTime;

    /// @notice Mapping of user addresses to the number of tokens they have claimed
    mapping(address => uint256) public tokensClaimed;

    /// @notice Total number of PEDRO tokens sold in the presale
    uint256 public tokensSold;

    /// @notice Mapping from referral code to referrer address
    mapping(address => bool) public mapRefferals;

    /// @notice Mapping for the affiliate data
    mapping(address => Affiliate) public mapAffiliates;

    /// @notice Array of affiliate addresses
    address[] public affiliates;

    /// @notice Emitted when tokens are purchased
    /// @param purchaser Address of the purchaser
    /// @param amountUSD Amount contributed in USD
    /// @param tokens Number of PEDRO tokens purchased
    event TokensPurchased(
        address indexed purchaser,
        uint256 amountUSD,
        uint256 tokens
    );

    /// @notice Emitted when funds are withdrawn
    /// @param wallet Address where funds were withdrawn to
    /// @param amount Amount of funds withdrawn
    /// @param currency Type of currency withdrawn ("ETH" or "ERC20")
    event FundsWithdrawn(
        address indexed wallet,
        uint256 amount,
        string currency
    );

    /// @notice Emitted when the DEX listing time is set
    /// @param listingTime Unix timestamp of the DEX listing
    event DexListed(uint256 listingTime);

    /// @notice Emitted when presale endet
    /// @param endtime Unix timestamp of end of presale
    event PresaleEnded(uint256 endtime);

    /// @notice Emitted when a referral code is successfully added
    /// @param user Address of the user who added the referral code
    /// @param refcode The referral code that was added
    event RefCodeAdded(address indexed user, string refcode);

    /**
     * @notice Constructor to initialize the PEDROPresale contract
     * @param _token Address of the ERC20 PEDRO token being sold
     * @param initialOwner Address of the initial owner of the contract
     * @param _wallet Address where collected funds will be forwarded
     * @param _pair Address of the Uniswap V2 pair for ETH/USDT
     * @param _supportedERC20 Array of ERC20 token addresses accepted as payment (e.g., USDT, USDC)
     */
    constructor(
        address _token,
        address initialOwner,
        address payable _wallet,
        address _pair,
        address[] memory _supportedERC20
    ) Ownable(initialOwner) {
        require(address(_token) != address(0), "PedroPresale: Token address cannot be zero");
        require(_wallet != address(0), "PedroPresale: Wallet address cannot be zero");
        require(
            _supportedERC20.length <= MAX_PAYMENT_METHODS,
            "PedroPresale: Exceeds max ERC20 payment methods"
        );

        token = IERC20(_token);
        wallet = _wallet;
        eth_usdtPair = IUniswapV2Pair(_pair);

        for (uint256 i = 0; i < _supportedERC20.length; i++) {
            supportedERC20[_supportedERC20[i]] = true;
        }
    }

    /**
     * @notice Sets the start time for the presale
     * @dev Can only be called once by the contract owner
     * @param _presaleStart Unix timestamp for the presale start
     */
    function setPresaleStart(uint256 _presaleStart) external onlyOwner {
        require(presaleStart == 0, "PedroPresale: Presale start time already set");
        require(dexListingTime == 0, "PedroPresale: Claiming started");

        presaleStart = _presaleStart;
    }

    /**
     * @notice Purchases PEDRO tokens using ETH
     * @dev Users send ETH to this function to buy tokens. Ensures sufficient tokens are available before processing.
     */
    function buyTokensWithETH() public payable nonReentrant {
        require(
            presaleStart != 0 && block.timestamp >= presaleStart,
            "PedroPresale: Presale not active"
        );
        require(msg.value > 0, "PedroPresale: ETH amount must be greater than zero");

        // Retrieve the current ETH price in USD using an oracle in production.
        uint256 ethPriceUSD = getETHPriceUSDT();
        uint256 amountUSD = (msg.value * ethPriceUSD) / 10 ** 18;

        // Check if the purchase is at least $50
        checkMinAmountUSD(amountUSD);

        // Calculate the number of tokens to purchase based on the current rate.
        uint256 tokens = getCurrentTokenAmount(amountUSD);
        uint256 tokenBonus = getBonusAmount(amountUSD, tokens);

        // Verify that enough presale tokens are available.
        require(
            _hasEnoughTokens(tokens),
            "PedroPresale: Insufficient presale tokens available"
        );

        uint256 refAmount = contributions[msg.sender].amountUSD + amountUSD;

        if(refAmount >= 50*1e6 && mapRefferals[msg.sender] == false) {
            mapRefferals[msg.sender] = true;
            affiliates.push(msg.sender);
        }

        // Update state variables before transferring tokens to prevent reentrancy.
        _updateState(msg.sender, amountUSD, tokens, tokenBonus);

        // Transfer ETH to the designated wallet.
        (bool success, ) = wallet.call{value: msg.value}("");
        require(success, "PedroPresale: ETH transfer to wallet failed");

        emit TokensPurchased(msg.sender, amountUSD, tokens);
    }

    /**
    * @notice Purchases PEDRO tokens using ETH with a referral code
    * @dev Distributes a portion of the payment to the referrer after validating the referral code
    * @param _refcode Referral code provided by the referrer
    */
    function buyTokensWithETHWithRef(address _refcode) public payable nonReentrant {
        require(
            presaleStart != 0 && block.timestamp >= presaleStart,
            "PedroPresale: Presale not active"
        );
        require(msg.value > 0, "PedroPresale: ETH amount must be greater than zero");

        require(_refcode != msg.sender, "PedroPresale: You couldnt ref yourself");
        require(mapRefferals[_refcode] != false, "PedroPresale: Invalid Refcode!");

        // Retrieve the current ETH price in USD using an oracle in production.
        uint256 ethPriceUSD = getETHPriceUSDT();
        uint256 amountUSD = (msg.value * ethPriceUSD) / 10 ** 18;

        // Check if the purchase is at least $50
        checkMinAmountUSD(amountUSD);

        // Calculate the number of tokens to purchase based on the current rate.
        uint256 tokens = getCurrentTokenAmount(amountUSD);
        uint256 tokenBonus = getBonusAmount(amountUSD, tokens);

        // Verify that enough presale tokens are available.
        require(
            _hasEnoughTokens(tokens),
            "PedroPresale: Insufficient presale tokens available"
        );

        uint256 refAmount = contributions[msg.sender].amountUSD + amountUSD;

        if(refAmount >= 50 * 1e6 && mapRefferals[msg.sender] == false) {
            mapRefferals[msg.sender] = true;
            affiliates.push(msg.sender);
        }

        // Update state variables before transferring tokens to prevent reentrancy.
        _updateState(msg.sender, amountUSD, tokens, tokenBonus);
        _updateAffilite(_refcode, ((amountUSD * 100) / 100));

        // Transfer ETH to the designated wallet and referrer
        (bool success, ) = wallet.call{value: ((msg.value * 85) / 100)}("");
        require(success, "PedroPresale: ETH transfer to wallet failed");

        (bool successRef, ) = _refcode.call{value: ((msg.value * 15) / 100)}("");
        require(successRef, "PedroPresale: ETH transfer to referrer failed");

        emit TokensPurchased(msg.sender, amountUSD, tokens);
    }


    /**
     * @notice Purchases PEDRO tokens using a supported ERC20 token (e.g., USDT, USDC)
     * @param _erc20Token Address of the ERC20 token used for payment
     * @param _amount Amount of ERC20 tokens to contribute
     */
    function buyTokensWithERC20(
        address _erc20Token,
        uint256 _amount
    ) external nonReentrant {
        require(
            presaleStart != 0 && block.timestamp >= presaleStart,
            "PedroPresale: Presale not active"
        );
        require(_amount > 0, "PedroPresale: ERC20 amount must be greater than zero");
        require(isSupportedERC20(_erc20Token), "PedroPresale: Unsupported ERC20 token");

        // Assume 1 ERC20 token = 1 USD for stablecoins like USDT and USDC.
        uint256 amountUSD = _amount;

        // Check if the purchase is at least $50
        checkMinAmountUSD(amountUSD);

        // Calculate the number of tokens to purchase based on the current rate.
        uint256 tokens = getCurrentTokenAmount(amountUSD);
        uint256 tokenBonus = getBonusAmount(amountUSD, tokens);

        // Verify that enough presale tokens are available.
        require(
            _hasEnoughTokens(tokens),
            "PedroPresale: Insufficient presale tokens available"
        );

        // Transfer ERC20 tokens from the purchaser to the wallet.
        IERC20 paymentToken = IERC20(_erc20Token);
        paymentToken.safeTransferFrom(msg.sender, wallet, _amount);

        uint256 refAmount = contributions[msg.sender].amountUSD + amountUSD;

        if(refAmount >= 50*1e6 && mapRefferals[msg.sender] == false) {
            mapRefferals[msg.sender] = true;
            affiliates.push(msg.sender);
        }

        // Update state variables before transferring tokens to prevent reentrancy.
        _updateState(msg.sender, amountUSD, tokens, tokenBonus);

        emit TokensPurchased(msg.sender, amountUSD, tokens);
    }


    /**
     * @notice Checks if the contributed amount meets the minimum USD requirement
     * @param _amount Amount contributed in USD
     */
    function checkMinAmountUSD(uint256 _amount) internal pure { 
        require(_amount >= 50*1e6, "PedroPresale: Buy needs at least $50 volume.");
    }

    /**
    * @notice Purchases PEDRO tokens using a supported ERC20 token with a referral code
    * @param _erc20Token Address of the ERC20 token used for payment
    * @param _amount Amount of ERC20 tokens to contribute
    * @param _refcode Referral code provided by the referrer
    */
    function buyTokensWithERC20WithRef(
        address _erc20Token,
        uint256 _amount,
        address _refcode
    ) external nonReentrant {
        require(
            presaleStart != 0 && block.timestamp >= presaleStart,
            "PedroPresale: Presale not active"
        );
        require(_amount > 0, "PedroPresale: ERC20 amount must be greater than zero");
        require(isSupportedERC20(_erc20Token), "PedroPresale: Unsupported ERC20 token");

        require(_refcode != msg.sender, "PedroPresale: You couldnt ref yourself");
        require(mapRefferals[_refcode] != false, "PedroPresale: Invalid Refcode!");

        // Assume 1 ERC20 token = 1 USD for stablecoins like USDT and USDC.
        uint256 amountUSD = _amount;

        // Check if the purchase is at least $50
        checkMinAmountUSD(amountUSD);

        // Calculate the number of tokens to purchase based on the current rate.
        uint256 tokens = getCurrentTokenAmount(amountUSD);
        uint256 tokenBonus = getBonusAmount(amountUSD, tokens);

        // Verify that enough presale tokens are available.
        require(
            _hasEnoughTokens(tokens),
            "PedroPresale: Insufficient presale tokens available"
        );

        // Transfer ERC20 tokens from the purchaser to the wallet and referrer
        IERC20 paymentToken = IERC20(_erc20Token);
        paymentToken.safeTransferFrom(msg.sender, wallet, (_amount * 85) / 100);
        paymentToken.safeTransferFrom(msg.sender, _refcode, (_amount * 15) / 100);

        uint256 refAmount = contributions[msg.sender].amountUSD + amountUSD;

        if(refAmount >= 50 * 1e6 && mapRefferals[msg.sender] == false) {            
            mapRefferals[msg.sender] = false;
            affiliates.push(msg.sender);
        }

        // Update state variables before transferring tokens to prevent reentrancy.
        _updateState(msg.sender, amountUSD, tokens, tokenBonus);
        _updateAffilite(_refcode, ((amountUSD * 100) / 100));

        emit TokensPurchased(msg.sender, amountUSD, tokens);
    }

    /**
     * @notice Set end of presale
     * @dev C
     */
    function endPresale() public onlyOwner {
        require(presaleStart != 0, "PedroPresale: Presale not started!");

        presaleStart = 0;

        emit PresaleEnded(block.timestamp);
    }
    /**
     * @notice Sets the DEX listing time
     * @dev Can only be called once by the contract owner
     * @param _dexListingTime Unix timestamp when the token is listed on a DEX
     */
    function setDexListingTime(uint256 _dexListingTime) external onlyOwner {
        require(dexListingTime == 0, "PedroPresale: DEX listing time already set");
        require(presaleStart == 0, "PedroPresale: Presale not ended");
        require(
            _dexListingTime > block.timestamp,
            "PedroPresale: Listing time must be in the future"
        );
        dexListingTime = _dexListingTime;

        emit DexListed(_dexListingTime);
    }

    /**
     * @notice Allows users to claim their vested PEDRO tokens based on the vesting schedule
     * @dev Users can claim 25% of their purchased tokens each month for four months after a 7-day lock period post-DEX listing
     */
    function claimTokens() external nonReentrant {
        require(dexListingTime != 0, "PedroPresale: DEX listing time not set");
        require(
            block.timestamp >= dexListingTime + 7 days,
            "PedroPresale: Token claims not started"
        );

        uint256 claimable = getClaimableTokens(msg.sender);
        require(claimable > 0, "PedroPresale: No tokens to claim");

        tokensClaimed[msg.sender] += claimable;
        token.transfer(msg.sender, claimable);
    }

    /**
     * @notice Calculates the number of claimable tokens for a user based on the vesting schedule
     * @param _beneficiary Address of the user
     * @return Number of claimable PEDRO tokens
     */
    function getClaimableTokens(
        address _beneficiary
    ) public view returns (uint256) {
        if (block.timestamp < dexListingTime + 7 days) {
            return 0;
        }

        uint256 monthsPassed = ((block.timestamp - (dexListingTime + 7 days)) /
            30 days) + 1;
        
        if (monthsPassed > 4) {
            monthsPassed = 4;
        }

        uint256 totalVested = (contributions[_beneficiary].tokenTotal *
            25 *
            monthsPassed) / 100;
        if (totalVested > contributions[_beneficiary].tokenTotal) {
            totalVested = contributions[_beneficiary].tokenTotal;
        }

        return totalVested - tokensClaimed[_beneficiary];
    }

    /**
     * @notice Allows the owner to withdraw all collected ETH funds
     * @dev Transfers the entire ETH balance to the designated wallet
     */
    function withdrawETH() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "PedroPresale: No ETH to withdraw");
        (bool success, ) = wallet.call{value: balance}("");
        require(success, "PedroPresale: ETH withdrawal failed");
        emit FundsWithdrawn(wallet, balance, "ETH");
    }

    /**
     * @notice Allows the owner to withdraw all collected ERC20 tokens (e.g., USDT, USDC)
     * @param _erc20Token Address of the ERC20 token to withdraw
     */
    function withdrawERC20(
        address _erc20Token
    ) external onlyOwner nonReentrant {
        require(isSupportedERC20(_erc20Token), "PedroPresale: Unsupported ERC20 token");
        IERC20 erc20 = IERC20(_erc20Token);
        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 0, "PedroPresale: No ERC20 tokens to withdraw");
        erc20.transfer(wallet, balance);
        emit FundsWithdrawn(wallet, balance, "ERC20");
    }

    /**
     * @notice Checks if an ERC20 token is supported for payment
     * @param _erc20Token Address of the ERC20 token
     * @return Boolean indicating support status
     */
    function isSupportedERC20(address _erc20Token) public view returns (bool) {
        return supportedERC20[_erc20Token];
    }

    /**
     * @notice Adds a new ERC20 token to the list of supported payment methods
     * @dev Can only be called by the contract owner
     * @param _erc20Token Address of the ERC20 token to add
     */
    function addSupportedERC20(address _erc20Token) external onlyOwner {
        require(_erc20Token != address(0), "PedroPresale: Cannot add zero address");
        require(!supportedERC20[_erc20Token], "PedroPresale: ERC20 token already supported");
        supportedERC20[_erc20Token] = true;
    }

    /**
     * @notice Removes an ERC20 token from the list of supported payment methods
     * @dev Can only be called by the contract owner
     * @param _erc20Token Address of the ERC20 token to remove
     */
    function removeSupportedERC20(address _erc20Token) external onlyOwner {
        require(supportedERC20[_erc20Token], "PedroPresale: ERC20 token not supported");
        supportedERC20[_erc20Token] = false;
    }

    /**
     * @notice Retrieves the maximum presale cap in USD
     * @return Cap in USD represented with 18 decimal places
     */
    function getCapUSD() public pure returns (uint256) {
        // Total presale tokens: 273,333,333 PEDRO
        // Initial price: $0.02 USD per token
        // Cap USD = 273,333,333 * 0.02 = 5,466,666.66 USD
        return 5_466_666_66 * 10**16; // 5,466,666.66 * 10^18
    }

    /**
     * @notice Retrieves affiliate data for a specific user
     * @param _user Address of the user to fetch affiliate data
     * @return Affiliate struct containing referral count and USDT value
     */
    function getAffiliateData(address _user) public view returns(Affiliate memory) {
        return mapAffiliates[_user];
    }

    /**
     * @notice Retrieves the ETH price in USD using the Uniswap V2 pair reserves
     * @dev In production, integrate with a reliable oracle like Chainlink
     * @return ETH price in USD with 18 decimal places
     */
    function getETHPriceUSDT() public view returns(uint256) {
        (uint256 res0, uint256 res1, ) = eth_usdtPair.getReserves();
        
        return ((res1 * 1e18) / res0);
    }

    /**
     * @notice Calculates the current price per PEDRO token in USD based on elapsed time
     * @return Current price per token in USD with 18 decimal places
     */
    function getCurrentRateUSD() public view returns (uint256) {
        if (block.timestamp < presaleStart) {
            return initialPriceUSD;
        }

        uint256 periods = (block.timestamp - presaleStart) /
            priceIncreaseInterval;
        uint256 currentRate = initialPriceUSD;

        for (uint256 i = 0; i < periods; i++) {
            currentRate =
                ((currentRate * priceIncreaseFactor) / percentageDenominator);
        }

        return currentRate;
    }

    /**
     * @notice Calculates the number of PEDRO tokens purchasable for a given USD amount
     * @param _amountUSD Amount in USD
     * @return Number of PEDRO tokens purchasable
     */
    function getCurrentTokenAmount(
        uint256 _amountUSD
    ) public view returns (uint256) {
        uint256 currentRateUSD = getCurrentRateUSD();

        uint256 tempTokenAmount = (_amountUSD * 10 ** 18) / currentRateUSD;

        return tempTokenAmount;
    }

    /**
     * @notice Retrieves the array of affiliate addresses
     * @return Array of affiliate addresses
     */
    function getAffilites() public view returns (address[] memory) {
        return affiliates;
    }

    /**
     * @notice Calculates the token bonus based on the contributed USD amount
     * @param _amountUSD Amount in USD
     * @param _amountToken Amount of tokens purchased
     * @return Token bonus amount
     */
    function getBonusAmount(uint256 _amountUSD, uint256 _amountToken) public pure returns (uint256) {
        uint256 multiplier = 0;

        if(_amountUSD >= 250*1e6 && _amountUSD < 500*1e6) {
            multiplier = 5;
        } else if(_amountUSD >= 500*1e6 && _amountUSD < 1000*1e6) {
            multiplier = 7;
        } else if(_amountUSD >= 1000*1e6 && _amountUSD < 2500*1e6) {
            multiplier = 10;
        } else if(_amountUSD >= 2500*1e6 && _amountUSD < 5000*1e6) {
            multiplier = 12;
        } else if(_amountUSD >= 5000*1e6 && _amountUSD < 10000*1e6) {
            multiplier = 15;
        } else if(_amountUSD >= 10000*1e6 && _amountUSD < 25000*1e6) {
            multiplier = 20;
        }  else if(_amountUSD >= 25000*1e6) {
            multiplier = 30;
        }

        uint256 tokenBonus = (_amountToken * multiplier) / 100;

        return tokenBonus;
    }

    /**
     * @notice Internal function to check if enough presale tokens are available
     * @param _tokens Number of tokens requested for purchase
     * @return Boolean indicating if enough tokens are available
     */
    function _hasEnoughTokens(uint256 _tokens) internal view returns (bool) {
        return tokensSold + _tokens <= TOTAL_PRESALE_TOKENS;
    }

    /**
     * @notice Internal function to update affiliate data
     * @param _ref Address of the referrer
     * @param _usdtamount USDT amount contributed by the referral
     */
    function _updateAffilite(
        address _ref,
        uint256 _usdtamount
    ) internal {
        mapAffiliates[_ref].refCount++;
        mapAffiliates[_ref].usdtValue += _usdtamount;
    }

    /**
     * @notice Internal function to update state variables post-purchase
     * @param _beneficiary Address of the purchaser
     * @param _amountUSD Amount contributed in USD
     * @param _tokens Number of PEDRO tokens purchased
     * @param _bonusTokens Number of PEDRO bonus tokens
     */
    function _updateState(
        address _beneficiary,
        uint256 _amountUSD,
        uint256 _tokens,
        uint256 _bonusTokens
    ) internal {
        contributions[_beneficiary].amountUSD += _amountUSD;
        contributions[_beneficiary].tokensPurchased += _tokens;
        contributions[_beneficiary].tokenBonus += _bonusTokens;
        contributions[_beneficiary].tokenTotal += _tokens + _bonusTokens;
        tokensSold += _tokens;
        totalUSDRaised += _amountUSD;
    }
}