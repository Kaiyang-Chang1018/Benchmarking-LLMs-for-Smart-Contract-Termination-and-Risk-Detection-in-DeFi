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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

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
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
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
pragma solidity 0.8.26;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface Aggregator {
    function decimals() external view returns (uint8);
    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

interface StakingManager {
    function deposit(address user, uint256 amount) external;
    function depositByPresale(address user, uint256 amount) external;
}

contract Presale is ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;

    // Digest
    string private constant DIGEST = "2025-01-30"; // Compile version

    // Main
    bool public isMainNetwork; // Set true if its the main network where the coin will be deployed
    address public saleToken;
    address public admin;
    StakingManager public stakingManager;
    Aggregator public priceFeed;
    IERC20 public usdt;
    IERC20 public usdc;
    bool public usdtFound;
    bool public usdcFound;
    uint256 public usdtDecimals;
    uint256 public usdcDecimals;
    uint256 public tokenDecimals;
    uint256 private tokenPrecision;

    // Constants
    uint256 private constant DAY_SECONDS = 86400;

    // Controls
    uint256 public daysPerRound;
    bool public updateRoundTimeAutomaticallyFlag;
    uint256 public minBuyInDolar;
    uint256 public maxTokensToBuy;
    uint256 public claimStartTime;
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;
    uint256 public currentRound;
    uint256[][3] public rounds;
    uint256 public checkpoint;
    address[] public addressPayment;
    uint256[] public addressPercentage;
    uint256[] public remainingTokensTracker;
    bool public claimAvailableForWhitelistOnlyFlag;
    bool public stakeAvailableForWhitelistOnlyFlag;

    // History
    uint256 public totalTokensSold;
    uint256 public totalTokensSoldAndStaked;
    uint256 public usdRaised;
    uint256[] public checkpointHistory;
    bool public isImportDone;

    // Maps
    mapping(address => uint256) public userDeposits;
    mapping(address => bool) public hasClaimed;
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public isWertWhitelisted;
    mapping(address => bool) public imported;
    address[] private addressUserDeposits;

    // Enums
    enum CoinSymbol {
        NETWORK,
        USDC, // USD Coin
        USDT // USD Tether
    }

    // Events
    event PresaleTimeSet(uint256 _start, uint256 _end, uint256 _timestamp);
    event PresaleTimeUpdated(bytes32 indexed _key, uint256 _oldTime, uint256 _newTime, uint256 _timestamp);
    event TokensBought(address indexed _address, uint256 indexed _tokensBought, address indexed _paymentTokenAddress, uint256 _amountPaid, uint256 _amountPaidUSD, uint256 _timestamp, string _id);
    event TokensBoughtAndStaked(
        address indexed _address,
        uint256 indexed _tokensBought,
        address indexed _paymentTokenAddress,
        uint256 _amountPaid,
        uint256 _amountPaidUSD,
        uint256 _timestamp,
        string _id
    );
    event TokensAdded(address indexed _tokenAddress, uint256 _tokenAmount, uint256 _timestamp);
    event TokensClaimed(address indexed _address, uint256 _amount, uint256 _timestamp); //After presale, only main network
    event TokensStaked(address indexed _address, uint256 _amount, uint256 _timestamp); //During presale, all networks
    event ClaimStartTimeUpdated(uint256 _startTimeOld, uint256 _startTimeNew, uint256 _timestamp);
    event MinBuyInDolarUpdated(uint256 _minBuyInDolarOld, uint256 _minBuyInDolarNew, uint256 _timestamp);
    event MaxTokensToBuyUpdated(uint256 _maxTokensToBuyOld, uint256 _maxTokensToBuyNew, uint256 _timestamp);
    event RoundUpdated(uint256 _amount, uint256 _timestamp);
    event AdminUpdated(address indexed _admin);
    event UsdtUpdated(bool _usdtFound, address _usdt, uint256 _usdtDecimals);
    event UsdcUpdated(bool _usdcFound, address _usdc, uint256 _usdcDecimals);
    event CurrentRoundUpdated(uint256 _round, uint256 _checkpointAmount);
    event DaysPerRoundUpdated(uint256 _daysPerRound);
    event TokenDecimalsUpdated(uint256 _tokenDecimals);
    event BlacklistImported(address[] addresses);
    event UserDepositsImported(address[] addresses, uint256[] deposits);

    // Modifiers
    modifier onlyOwnerOrAdmin() {
        require(msg.sender == admin || msg.sender == owner(), "Only owner or admin");
        _;
    }

    // Constructor
    struct ConstructorStruct {
        bool cIsMainNetwork; // True if this is the network where the presale token will be deployed
        address cAdmin; // Address of admin
        address cPriceFeed; // The aggregator contract address
        address cUsdt; // USDT contract address
        address cUsdc; // USDC contract address
        bool cUsdtFound; // If this network have USDT
        bool cUsdcFound; // If this network have USDC
        uint256 cUsdtDecimals; // USDT decimals
        uint256 cUsdcDecimals; // USDC decimals
        uint256 cDaysPerRound; // Number of days rounds will last (Default: 7 days)
        bool cUpdateRoundTimeAutomaticallyFlag; // If flag is true the round end time will be updated, if its false the next round will add the remaining time (Default: true)
        uint256 cMinBuyInDolar; // Minimum amount in dolars that users will be able to purchase
        uint256 cMaxTokensToBuy; // Maximum amount of tokens that users will be able to purchase (Default: 1.000.000.000 Less than a full round)
        uint256 cPresaleStartTime; // Timestamp to set presale start date
        uint256 cPresaleEndTime; // Timestamp to set presale end date
        uint256 cTokenDecimals; // Number of decimals of the Token
        uint256[][3] cRounds; // Array of round details ([0] -> ROUND_TOTAL, [1] -> ROUND_PRICE, [2] -> ROUND_FINAL_TIMESTAMP)
        address[] cAddressPayment; // Array of addresses that will receive payments
        uint256[] cAddressPercentage; // Array of percentage of each payment address
    }

    /**
     * @dev Initializes the contract and sets initial parameters
     *
     * @param _constructor The constructor tuple
     */
    constructor(ConstructorStruct memory _constructor) Ownable(msg.sender) {
        require(_constructor.cAdmin != address(0), "Admin contract is required");
        require(_constructor.cPriceFeed != address(0), "Price feed contract is required");
        if (_constructor.cUsdtFound) require(_constructor.cUsdt != address(0), "USDT contract is required");
        if (_constructor.cUsdcFound) require(_constructor.cUsdc != address(0), "USDC contract is required");
        require(_constructor.cDaysPerRound > 0, "Days per round must be greater than zero");
        require(_constructor.cMaxTokensToBuy > 0, "Max tokens to buy must be greater than zero");
        require(_constructor.cPresaleStartTime < _constructor.cPresaleEndTime, "Presale end time must be greater than start time");
        require(_constructor.cPresaleEndTime > block.timestamp, "Presale end time must be in the future");
        require(_constructor.cRounds[0].length > 0, "At least one round is required");
        require(_constructor.cAddressPayment.length > 0, "At least one payment address is required");
        require(_constructor.cAddressPayment.length == _constructor.cAddressPercentage.length, "Payment addresses and addresses percentages arrays must have same size");

        isMainNetwork = _constructor.cIsMainNetwork;
        admin = _constructor.cAdmin;
        daysPerRound = _constructor.cDaysPerRound;
        updateRoundTimeAutomaticallyFlag = _constructor.cUpdateRoundTimeAutomaticallyFlag;
        minBuyInDolar = _constructor.cMinBuyInDolar;
        maxTokensToBuy = _constructor.cMaxTokensToBuy;
        presaleStartTime = _constructor.cPresaleStartTime;
        presaleEndTime = _constructor.cPresaleEndTime;
        currentRound = 0;
        rounds = _constructor.cRounds;
        tokenDecimals = _constructor.cTokenDecimals;
        tokenPrecision = 10 ** tokenDecimals;

        //Fill token information
        require(_constructor.cUsdtFound || _constructor.cUsdcFound, "No USDT/USDC found on this network");
        usdtFound = _constructor.cUsdtFound;
        usdcFound = _constructor.cUsdcFound;
        if (usdtFound) {
            usdt = IERC20(_constructor.cUsdt);
            usdtDecimals = _constructor.cUsdtDecimals;
        }
        if (usdcFound) {
            usdc = IERC20(_constructor.cUsdc);
            usdcDecimals = _constructor.cUsdcDecimals;
        }

        //Get network aggregator
        require(_constructor.cPriceFeed != address(0), "Aggregator contract is required");
        priceFeed = Aggregator(_constructor.cPriceFeed);

        addressPayment = _constructor.cAddressPayment;
        addressPercentage = _constructor.cAddressPercentage;

        emit PresaleTimeSet(presaleStartTime, presaleEndTime, block.timestamp);
    }

    /**
     * @dev Pause the presale
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause the presale
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Calculate price in USD for given amount of tokens
     *
     * @param pAmount Amount in tokens the user wants to receive
     *
     * @return Amount in dolars the user will pay for this amount of tokens
     */
    function calculatePrice(uint256 pAmount) public view returns (uint256) {
        require(pAmount <= maxTokensToBuy, "Amount exceeds max tokens to buy");

        //Check if amount is enough to advance to next round
        if (pAmount + checkpoint > rounds[0][currentRound] || block.timestamp >= rounds[2][currentRound]) {
            //Must be in a round before the last
            require(currentRound < (rounds[0].length - 1), "Last round, it is not possible to buy this quantity");

            //Must purchase fewer tokens than the available amount of a full round
            require(rounds[0][currentRound] + pAmount <= rounds[0][currentRound + 1], "Can not buy this amount in a single tx");

            if (block.timestamp > rounds[2][currentRound]) {
                return rounds[1][currentRound + 1] * pAmount;
            } else {
                uint256 _amountCurrentPrice = rounds[0][currentRound] - checkpoint;
                return rounds[1][currentRound] * _amountCurrentPrice + rounds[1][currentRound + 1] * (pAmount - _amountCurrentPrice);
            }
        } else {
            return rounds[1][currentRound] * pAmount;
        }
    }

    /**
     * @dev Calculate amount of tokens for given amount in USD
     *
     * @param pAmountUsd amount in USD (Need to add the decimals equivalent to the TOKEN_DECIMALS)
     *
     * @return array with [0] -> amountToken amount of tokens, [1] -> amountInMain amount in main network symbol
     */
    function calculateAmountTokens(uint256 pAmountUsd) external view returns (uint256[2] memory) {
        //Amount should be bigger than one unit of token
        require(pAmountUsd > rounds[1][currentRound == rounds[0].length - 1 ? currentRound : currentRound + 1], "Invalid amount");

        //Calculate tokens available in current round
        uint256 _amountAvailableCurrentRound = rounds[0][currentRound] - checkpoint;

        //Calculate amount of tokens for given usd amount
        uint256 _amountToken = pAmountUsd / rounds[1][currentRound];

        //If round will increase by time
        if (block.timestamp >= rounds[2][currentRound]) {
            //Must be in a round before the last
            require(currentRound < (rounds[0].length - 1), "The presale timestamp have ended");

            _amountToken = pAmountUsd / rounds[1][currentRound + 1];
        }
        //If amount of tokens exceeds amount available, calculate with next round
        else if (_amountToken > _amountAvailableCurrentRound) {
            //Must be in a round before the last
            require(currentRound < (rounds[0].length - 1), "Last round, it is not possible to buy this quantity");

            uint256 _rest = pAmountUsd - _amountAvailableCurrentRound * rounds[1][currentRound];
            _amountToken = _amountAvailableCurrentRound + (_rest / rounds[1][currentRound + 1]);

            require(rounds[0][currentRound] + _amountToken <= rounds[0][currentRound + 1], "Can not buy this amount in a single tx");
        }

        require(_amountToken <= maxTokensToBuy, "Amount exceeds max tokens to buy");

        return [_amountToken, mainBuyHelper(_amountToken)];
    }

    /**
     * @dev Get latest Main Network Symbol price to x decimals places
     */
    function getLatestPrice() public view returns (uint256) {
        uint256 aggregatorDecimals = priceFeed.decimals();
        require(aggregatorDecimals <= tokenDecimals, "Invalid aggregator decimals");

        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Error getting price");

        //Normalize price to x decimals
        return uint256(price) * 10 ** (tokenDecimals - aggregatorDecimals);
    }

    /**
     * @dev Buy with Main Network Symbol
     *
     * @param pAmount amount of tokens to buy
     * @param pStake flag to stake purchased tokens
     * @param pId identficator
     */
    function buyWithMain(uint256 pAmount, bool pStake, string calldata pId) external payable nonReentrant whenNotPaused returns (bool) {
        require(block.timestamp >= presaleStartTime && block.timestamp <= presaleEndTime, "Out of presale period");
        require(pAmount > 0, "Amount must be greater than zero");
        require(pAmount <= maxTokensToBuy, "Amount exceeds max tokens to buy");

        buyWithNetwork(msg.sender, pAmount, pStake, pId);

        return true;
    }

    /**
     * @dev Buy with Main Network Symbol from Wert
     * Wert address must be whitelisted
     *
     * @param pUser address who made the purchase
     * @param pAmount amount of tokens to buy
     * @param pStake flag to stake purchased tokens
     * @param pCoinSymbol the coin symbol
     */
    function buyWithWert(address pUser, uint256 pAmount, bool pStake, CoinSymbol pCoinSymbol, string calldata pId) external payable nonReentrant whenNotPaused returns (bool) {
        require(block.timestamp >= presaleStartTime && block.timestamp <= presaleEndTime, "Out of presale period");
        require(pAmount > 0, "Amount must be greater than zero");
        require(pAmount <= maxTokensToBuy, "Amount exceeds max tokens to buy");
        require(isWertWhitelisted[msg.sender], "Address not whitelisted for this transaction");
        require(pCoinSymbol == CoinSymbol.NETWORK || pCoinSymbol == CoinSymbol.USDT || pCoinSymbol == CoinSymbol.USDC, "Symbol not found");

        if (pCoinSymbol == CoinSymbol.NETWORK) {
            buyWithNetwork(pUser, pAmount, pStake, pId);
        } else {
            buyWithToken(pUser, pAmount, pStake, pCoinSymbol, pId);
        }

        return true;
    }

    /**
     * @dev Buy with Main Network Symbol
     *
     * @param pUser address who made the purchase
     * @param pAmount amount of tokens to buy
     * @param pStake flag to stake purchased tokens
     */
    function buyWithNetwork(address pUser, uint256 pAmount, bool pStake, string calldata pId) internal {
        uint256 _usdPrice = calculatePrice(pAmount);
        uint256 _mainAmount = (_usdPrice * tokenPrecision) / getLatestPrice();
        require(msg.value >= _mainAmount, "Insufficient payment");
        require(_usdPrice >= minBuyInDolar, "Payment lower than minimum");
        uint256 _excess = msg.value - _mainAmount;

        totalTokensSold += pAmount;
        checkpoint += pAmount;
        usdRaised += _usdPrice;

        if (checkpoint > rounds[0][currentRound] || block.timestamp >= rounds[2][currentRound]) {
            incrementCurrentRound(pAmount, block.timestamp);
        }

        if (pStake) {
            require(address(stakingManager) != address(0), "Staking manager not configured");
            if (stakeAvailableForWhitelistOnlyFlag) {
                require(isWhitelisted[pUser], "User not whitelisted for stake");
            }
            totalTokensSoldAndStaked += pAmount;
            stakingManager.depositByPresale(pUser, pAmount * tokenPrecision);
            emit TokensBoughtAndStaked(pUser, pAmount, address(0), _mainAmount, _usdPrice, block.timestamp, pId);
        } else {
            if (userDeposits[pUser] == 0) addressUserDeposits.push(pUser);
            userDeposits[pUser] += (pAmount * tokenPrecision);
            emit TokensBought(pUser, pAmount, address(0), _mainAmount, _usdPrice, block.timestamp, pId);
        }

        splitCoin(_mainAmount, CoinSymbol.NETWORK);
        if (_excess > 0) sendCoin(pUser, _excess, CoinSymbol.NETWORK);
    }

    /**
     * @dev Buy with USDT
     *
     * @param pAmount amount of tokens to buy
     * @param pStake flag to stake purchased tokens
     */
    function buyWithUSDT(uint256 pAmount, bool pStake, string calldata pId) external nonReentrant whenNotPaused returns (bool) {
        require(usdtFound, "USDT contract found on this network");
        require(block.timestamp >= presaleStartTime && block.timestamp <= presaleEndTime, "Out of presale period");
        require(pAmount > 0, "Amount must be greater than zero");
        require(pAmount <= maxTokensToBuy, "Amount exceeds max tokens to buy");

        buyWithToken(msg.sender, pAmount, pStake, CoinSymbol.USDT, pId);

        return true;
    }

    /**
     * @dev Buy with USDC
     *
     * @param pAmount amount of tokens to buy
     * @param pStake flag to stake purchased tokens
     */
    function buyWithUSDC(uint256 pAmount, bool pStake, string calldata pId) external nonReentrant whenNotPaused returns (bool) {
        require(usdcFound, "USDC contract found on this network");
        require(block.timestamp >= presaleStartTime && block.timestamp <= presaleEndTime, "Out of presale period");
        require(pAmount > 0, "Amount must be greater than zero");
        require(pAmount <= maxTokensToBuy, "Amount exceeds max tokens to buy");

        buyWithToken(msg.sender, pAmount, pStake, CoinSymbol.USDC, pId);

        return true;
    }

    /**
     * @dev Buy with USDT/USDC
     *
     * @param pUser address who made the purchase
     * @param pAmount amount received
     * @param pStake flag to stake purchased tokens
     * @param pCoinSymbol the coin symbol
     */
    function buyWithToken(address pUser, uint256 pAmount, bool pStake, CoinSymbol pCoinSymbol, string calldata pId) internal {
        IERC20 _token = pCoinSymbol == CoinSymbol.USDT ? usdt : usdc;
        uint256 _usdPrice = calculatePrice(pAmount);
        require(_usdPrice >= minBuyInDolar, "Payment lower than minimum");

        totalTokensSold += pAmount;
        checkpoint += pAmount;
        usdRaised += _usdPrice;

        if (checkpoint > rounds[0][currentRound] || block.timestamp >= rounds[2][currentRound]) {
            incrementCurrentRound(pAmount, block.timestamp);
        }

        if (pStake) {
            require(address(stakingManager) != address(0), "Staking manager not configured");
            if (stakeAvailableForWhitelistOnlyFlag) {
                require(isWhitelisted[pUser], "User not whitelisted for stake");
            }
            totalTokensSoldAndStaked += pAmount;
            stakingManager.depositByPresale(pUser, pAmount * tokenPrecision);
            emit TokensBoughtAndStaked(pUser, pAmount, address(_token), _usdPrice, _usdPrice, block.timestamp, pId);
        } else {
            if (userDeposits[pUser] == 0) addressUserDeposits.push(pUser);
            userDeposits[pUser] += (pAmount * tokenPrecision);
            emit TokensBought(pUser, pAmount, address(_token), _usdPrice, _usdPrice, block.timestamp, pId);
        }

        uint256 _usdPriceNormalized = _usdPrice / (10 ** (tokenDecimals - usdtDecimals));

        uint256 _ourAllowance = _token.allowance(pUser, address(this));
        require(_usdPriceNormalized <= _ourAllowance, "Not enough allowance");

        splitCoin(_usdPriceNormalized, pCoinSymbol);
    }

    /**
     * @dev Transfer to given recipient
     *
     * @param pRecipient payable address of transaction recipient
     * @param pAmount amount received
     * @param pCoinSymbol the coin symbol
     */
    function sendCoin(address pRecipient, uint256 pAmount, CoinSymbol pCoinSymbol) internal {
        if (pCoinSymbol == CoinSymbol.NETWORK) {
            require(address(this).balance >= pAmount, "Main network symbol balance not enough");
            Address.sendValue(payable(pRecipient), pAmount);
        } else if (pCoinSymbol == CoinSymbol.USDT) {
            require(usdt.balanceOf(msg.sender) >= pAmount, "USDT balance not enough");
            usdt.safeTransferFrom(msg.sender, pRecipient, pAmount);
        } else if (pCoinSymbol == CoinSymbol.USDC) {
            require(usdc.balanceOf(msg.sender) >= pAmount, "USDC balance not enough");
            usdc.safeTransferFrom(msg.sender, pRecipient, pAmount);
        }
    }

    /**
     * @dev Divides the amount received in between the configured wallets
     *
     * @param pAmount amount received
     * @param pCoinSymbol the coin symbol
     */
    function splitCoin(uint256 pAmount, CoinSymbol pCoinSymbol) internal {
        require(addressPayment.length > 0, "Payment address not configured");
        require(addressPayment.length == addressPercentage.length, "Wrong configuration payment addresses and percentages");

        uint256 _totalTransferred;
        uint256 size = addressPayment.length;
        for (uint256 i = 0; i < size; i++) {
            uint256 _amountToTransfer = (pAmount * addressPercentage[i]) / 100;
            sendCoin(addressPayment[i], _amountToTransfer, pCoinSymbol);
            _totalTransferred += _amountToTransfer;
        }

        if (_totalTransferred < pAmount) {
            sendCoin(addressPayment[addressPayment.length - 1], pAmount - _totalTransferred, pCoinSymbol);
        }
    }

    /**
     * @dev Helper function to get Main Network Symbol price for given amount
     *
     * @param pAmount Amount in tokens the user wants to receive
     *
     * @return Amount in dolars the user will pay for this amount of tokens
     */
    function mainBuyHelper(uint256 pAmount) public view returns (uint256) {
        return (calculatePrice(pAmount) * tokenPrecision) / getLatestPrice();
    }

    /**
     * @dev Helper function to get USD price for given amount
     *
     * @param pAmount Amount in tokens the user wants to receive
     *
     * @return Amount in dolars the user will pay for this amount of tokens
     */
    function usdBuyHelper(uint256 pAmount) external view returns (uint256) {
        return calculatePrice(pAmount);
    }

    /**
     * @dev Stake tokens purchased during presale
     */
    function stake() external nonReentrant whenNotPaused returns (bool) {
        require(address(stakingManager) != address(0), "Staking manager not configured");
        require(!isBlacklisted[msg.sender], "This address is blacklisted");

        if (stakeAvailableForWhitelistOnlyFlag) {
            require(isWhitelisted[msg.sender], "User not whitelisted for stake");
        }

        uint256 _amount = userDeposits[msg.sender];
        require(_amount > 0, "Nothing to stake");

        delete userDeposits[msg.sender];

        //If claim the presale is still live call the deposit by presale
        if (block.timestamp < claimStartTime) {
            stakingManager.depositByPresale(msg.sender, _amount);
        } else {
            //If the presale is over make a stake
            stakingManager.deposit(msg.sender, _amount);
        }

        emit TokensStaked(msg.sender, _amount, block.timestamp);
        return true;
    }

    /**
     * @dev Claim tokens after presale ends and claiming starts
     */
    function claim() external nonReentrant whenNotPaused returns (bool) {
        require(isMainNetwork, "This is not the main network");
        require(saleToken != address(0), "Sale token is not configured");
        require(!isBlacklisted[msg.sender], "This address is blacklisted");
        require(block.timestamp >= claimStartTime, "Claim has not started yet");
        require(!hasClaimed[msg.sender], "Already claimed");
        if (claimAvailableForWhitelistOnlyFlag) {
            require(isWhitelisted[msg.sender], "User not whitelisted for claim");
        }

        hasClaimed[msg.sender] = true;
        uint256 _amount = userDeposits[msg.sender];
        require(_amount > 0, "Nothing to claim");

        delete userDeposits[msg.sender];

        IERC20(saleToken).safeTransfer(msg.sender, _amount);

        emit TokensClaimed(msg.sender, _amount, block.timestamp);
        return true;
    }

    /**
     * @dev Increment current round
     *
     * @param pAmount Amount of tokens purchased when round was incremented
     */
    function incrementCurrentRound(uint256 pAmount, uint256 pTimestamp) internal {
        require(currentRound < rounds[0].length - 1, "Last round reached, it is not possible to increment");
        require(checkpoint > rounds[0][currentRound] || pTimestamp >= rounds[2][currentRound] || pAmount == 0, "Round limits not reached");
        require(pTimestamp < presaleEndTime, "Cannot increment round after presale end time");

        if (updateRoundTimeAutomaticallyFlag) {
            //Update the end time of each round after the current one
            uint256 size = rounds[2].length;
            for (uint256 i; i < size - currentRound; i++) {
                rounds[2][currentRound + i] = pTimestamp + (i * daysPerRound * DAY_SECONDS);
            }
            //Update the presaleEndTime according the last round end timestamp
            presaleEndTime = rounds[2][size - 1];
        }

        //If round is being incremented but there are remaining tokens
        if (checkpoint < rounds[0][currentRound]) {
            remainingTokensTracker.push(rounds[0][currentRound] - checkpoint + pAmount);
            checkpointHistory.push(checkpoint - pAmount);
            checkpoint = rounds[0][currentRound] + pAmount;
        } else {
            remainingTokensTracker.push(0);
            checkpointHistory.push(rounds[0][currentRound]);
        }

        currentRound++;
        emit RoundUpdated(pAmount, pTimestamp);
    }

    /**
     * @dev Increment current round from backend
     */
    function incrementCurrentRound(uint256 pTimestamp) external onlyOwnerOrAdmin {
        incrementCurrentRound(0, pTimestamp);
    }

    /**
     * @dev Set payment addresses and percentages of each one
     *
     * @param pAddresses array of payment addresses
     * @param pPercentages array of percentage of each payment address
     */
    function setAddressPayment(address[] memory pAddresses, uint256[] memory pPercentages) external onlyOwner {
        require(pAddresses.length > 0, "Must configure at least one address");
        require(pAddresses.length == pPercentages.length, "Arrays sizes are mismatched");

        delete addressPayment;
        delete addressPercentage;
        uint256 _totalPercentage;
        uint256 size = pAddresses.length;
        for (uint256 i = 0; i < size; i++) {
            require(pPercentages[i] > 0, "Percentages must be greater than zero");
            _totalPercentage += pPercentages[i];
            addressPayment.push(pAddresses[i]);
            addressPercentage.push(pPercentages[i]);
        }

        require(_totalPercentage == 100, "Total percentage must be equal 100");
    }

    /**
     * @dev Set minimum amount in dolars users will be able to purchase
     *
     * @param pMinBuyInDolar minimum amount in dolars to buy
     */
    function setMinBuyInDolar(uint256 pMinBuyInDolar) external onlyOwner {
        uint256 _minBuyInDolarOld = minBuyInDolar;
        minBuyInDolar = pMinBuyInDolar;

        emit MinBuyInDolarUpdated(_minBuyInDolarOld, minBuyInDolar, block.timestamp);
    }

    /**
     * @dev Set maximum amount of tokens users will be able to purchase
     *
     * @param pMaxTokensToBuy maximum amount of tokens to buy
     */
    function setMaxTokensToBuy(uint256 pMaxTokensToBuy) external onlyOwner {
        require(pMaxTokensToBuy > 0, "Max tokens to buy must be greater than zero");

        uint256 _maxTokensToBuyOld = maxTokensToBuy;
        maxTokensToBuy = pMaxTokensToBuy;

        emit MaxTokensToBuyUpdated(_maxTokensToBuyOld, maxTokensToBuy, block.timestamp);
    }

    /**
     * @dev Set new price feed contract
     *
     * @param pPriceFeed price feed contract address
     */
    function setPriceFeed(address pPriceFeed) external onlyOwner {
        require(pPriceFeed != address(0), "Invalid address");
        priceFeed = Aggregator(pPriceFeed);
    }

    /**
     * @dev Set is main network on/off
     *
     * @param pIsMainNetwork boolean is main network
     */
    function setIsMainNetwork(bool pIsMainNetwork) external onlyOwner {
        isMainNetwork = pIsMainNetwork;
    }

    /**
     * @dev Set token decimals
     *
     * @param pTokenDecimals number of token decimals
     */
    function setTokenDecimals(uint256 pTokenDecimals) external onlyOwner {
        tokenDecimals = pTokenDecimals;
        tokenPrecision = 10 ** tokenDecimals;
        emit TokenDecimalsUpdated(pTokenDecimals);
    }

    /**
     * @dev Set usdt info
     *
     * @param pUsdtFound usdt exists or not
     * @param pUsdt usdt contract address
     * @param pUsdtDecimals usdt exists or not
     */
    function setUsdt(bool pUsdtFound, address pUsdt, uint256 pUsdtDecimals) external onlyOwner {
        require((pUsdtFound && pUsdt != address(0)) || !pUsdtFound, "Invalid address");
        usdt = IERC20(pUsdt);
        usdtFound = pUsdtFound;
        usdtDecimals = pUsdtDecimals;
        emit UsdtUpdated(pUsdtFound, pUsdt, pUsdtDecimals);
    }

    /**
     * @dev Set usdc info
     *
     * @param pUsdcFound usdc exists or not
     * @param pUsdc usdc contract address
     * @param pUsdcDecimals usdc exists or not
     */
    function setUsdc(bool pUsdcFound, address pUsdc, uint256 pUsdcDecimals) external onlyOwner {
        require((pUsdcFound && pUsdc != address(0)) || !pUsdcFound, "Invalid address");
        usdc = IERC20(pUsdc);
        usdcFound = pUsdcFound;
        usdcDecimals = pUsdcDecimals;
        emit UsdcUpdated(pUsdcFound, pUsdc, pUsdcDecimals);
    }

    /**
     * @dev Set admin
     * @param pAdmin new admin address
     */
    function setAdmin(address pAdmin) external onlyOwner {
        require(pAdmin != address(0), "Invalid address");
        admin = pAdmin;
        emit AdminUpdated(pAdmin);
    }

    /**
     * @dev Configure Staking Manager with the contract address
     *
     * @param pStakingManager address of staking manager contract
     */
    function setStakingManager(address pStakingManager) external onlyOwner {
        stakingManager = StakingManager(pStakingManager);

        if (isMainNetwork && pStakingManager != address(0)) {
            require(saleToken != address(0), "Sale token not configured yet");
            IERC20(saleToken).safeIncreaseAllowance(pStakingManager, type(uint256).max);
        }
    }

    /**
     * @dev Update presale start and end timestamp
     *
     * @param pPresaleStartTime Presale start time
     * @param pPresaleEndTime Presale end time
     */
    function setPresaleTimes(uint256 pPresaleStartTime, uint256 pPresaleEndTime) external onlyOwner {
        require(pPresaleStartTime > 0 || pPresaleEndTime > 0, "Invalid parameters");

        if (pPresaleStartTime > 0) {
            require(block.timestamp < presaleStartTime, "Presale already started");
            require(block.timestamp < pPresaleStartTime, "Presale start must be in future");

            uint256 _presaleStartTimeOld = presaleStartTime;
            presaleStartTime = pPresaleStartTime;
            emit PresaleTimeUpdated(bytes32("START"), _presaleStartTimeOld, pPresaleStartTime, block.timestamp);
        }

        if (pPresaleEndTime > 0) {
            require(block.timestamp <= presaleEndTime, "Presale already finished");
            require(pPresaleEndTime > presaleStartTime, "Presale end must be after presale start");

            uint256 _presaleEndTimeOld = presaleEndTime;
            presaleEndTime = pPresaleEndTime;
            emit PresaleTimeUpdated(bytes32("END"), _presaleEndTimeOld, pPresaleEndTime, block.timestamp);
        }
    }

    /**
     * @dev Get specifc details of all rounds
     *
     * @param pIndex index detail ([0] -> ROUND_TOTAL, [1] -> ROUND_PRICE, [2] -> ROUND_FINAL_TIMESTAMP)
     */
    function getRoundDetails(uint256 pIndex) external view returns (uint256[] memory) {
        return rounds[pIndex];
    }

    /**
     * @dev Get current round details
     // Array of round details
     [0] -> ROUND_TOTAL, 
     [1] -> ROUND_PRICE, 
     [2] -> ROUND_FINAL_TIMESTAMP, 
     [3] -> TOTAL_TOKENS_SOLD, 
     [4] -> CURRENT_ROUND, 
     [5] -> LAST_ROUND 
     [6] -> LAST_ROUND_TOTAL, 
     [7] -> LAST_ROUND_FINAL_TIMESTAMP, 
     [8] -> PRESALE_END_TIME,
     [9] -> USER_DEPOSIT_LENGTH,
     [10] -> IS_IMPORT_DONE
     */
    function getCurrentRoundDetails() external view returns (uint256[11] memory) {
        uint256 _lastRoundFinalTimestamp = currentRound == 0 ? 0 : rounds[2][currentRound - 1];
        uint256 _lastRoundTotalTokens = currentRound == 0 ? 0 : rounds[0][currentRound - 1];
        return [
            rounds[0][currentRound],
            rounds[1][currentRound],
            rounds[2][currentRound],
            checkpoint - _lastRoundTotalTokens,
            currentRound,
            rounds[0].length,
            _lastRoundTotalTokens,
            _lastRoundFinalTimestamp,
            presaleEndTime,
            addressUserDeposits.length,
            isImportDone ? 1 : 0
        ];
    }

    /**
     * @dev Get usd raised target for current round
     */
    function getUsdRaisedTarget() external view returns (uint256) {
        if (currentRound == 0) return rounds[0][currentRound] * rounds[1][currentRound];

        uint256 _usdRaisedTarget;
        for (uint256 i; i < currentRound; i++) {
            _usdRaisedTarget += (rounds[0][i] - remainingTokensTracker[i]) * rounds[1][i];
        }

        return _usdRaisedTarget + rounds[0][currentRound] * rounds[1][currentRound];
    }

    /**
     * @dev Change rounds details
     * Can only be called by the current owner.
     *
     * @param pRounds array of round details ([0] -> ROUND_TOTAL, [1] -> ROUND_PRICE, [2] -> ROUND_FINAL_TIMESTAMP)
     */
    function setRounds(uint256[][3] memory pRounds) external onlyOwner {
        rounds = pRounds;
        //Update the presaleEndTime according the last round end timestamp
        presaleEndTime = rounds[2][rounds[2].length - 1];
    }

    /**
     * @dev Change details of the current round
     * @param pRound round for which you want to change
     * @param pCheckpointAmount token tracker amount
     */
    function setCurrentRound(uint256 pRound, uint256 pCheckpointAmount) external onlyOwner {
        require(pRound < rounds[0].length, "Invalid round");
        require(rounds[0][pRound] > pCheckpointAmount, "Checkpoint cannot be greater than round total");

        currentRound = pRound;
        checkpoint = pCheckpointAmount;

        emit CurrentRoundUpdated(pRound, pCheckpointAmount);
    }

    /**
     * @dev Set how many days each round will last
     * - It will take effect from the moment the current round ends
     *
     * @param pDaysPerRound number of days
     */
    function setDaysPerRound(uint256 pDaysPerRound) external onlyOwner {
        require(pDaysPerRound > 0, "Number of days per round must be greater than zero");
        daysPerRound = pDaysPerRound;
        emit DaysPerRoundUpdated(pDaysPerRound);
    }

    /**
     * @dev Set flag to control if round time will be updated automatically
     *
     * @param pFlag boolean flag
     */
    function setUpdateRoundTimeAutomaticallyFlag(bool pFlag) external onlyOwner {
        updateRoundTimeAutomaticallyFlag = pFlag;
    }

    /**
     * @dev Add address to whitelist
     *
     * @param pAddresses list of addresses to add in whitelist
     */
    function addToWhitelist(address[] calldata pAddresses) external onlyOwner {
        uint256 size = pAddresses.length;
        for (uint256 i = 0; i < size; i++) {
            isWhitelisted[pAddresses[i]] = true;
        }
    }

    /**
     * @dev Remove address from whitelist
     *
     * @param pAddresses list of addresses to remove from whitelist
     */
    function removeFromWhitelist(address[] calldata pAddresses) external onlyOwner {
        uint256 size = pAddresses.length;
        for (uint256 i = 0; i < size; i++) {
            isWhitelisted[pAddresses[i]] = false;
        }
    }

    /**
     * @dev Add address to blacklist
     *
     * @param pAddresses list of addresses to add in blacklist
     */
    function addToBlacklist(address[] calldata pAddresses) external onlyOwner {
        uint256 size = pAddresses.length;
        for (uint256 i = 0; i < size; i++) {
            isBlacklisted[pAddresses[i]] = true;
        }

        emit BlacklistImported(pAddresses);
    }

    /**
     * @dev Remove address from blacklist
     *
     * @param pAddresses list of addresses to remove from blacklist
     */
    function removeFromBlacklist(address[] calldata pAddresses) external onlyOwner {
        uint256 size = pAddresses.length;
        for (uint256 i = 0; i < size; i++) {
            isBlacklisted[pAddresses[i]] = false;
        }
    }

    /**
     * @dev Add address to Wert whitelist
     *
     * @param pAddresses list of addresses to add in Wert whitelist
     */
    function addToWertWhitelist(address[] calldata pAddresses) external onlyOwner {
        uint256 size = pAddresses.length;
        for (uint256 i = 0; i < size; i++) {
            isWertWhitelisted[pAddresses[i]] = true;
        }
    }

    /**
     * @dev Remove address from Wert whitelist
     *
     * @param pAddresses list of addresses to remove from Wert whitelist
     */
    function removeFromWertWhitelist(address[] calldata pAddresses) external onlyOwner {
        uint256 size = pAddresses.length;
        for (uint256 i = 0; i < size; i++) {
            isWertWhitelisted[pAddresses[i]] = false;
        }
    }

    /**
     * @dev Set flag to control if stake is available only for whitelisted aaddresses
     *
     * @param pFlag boolean flag
     */
    function setStakeAvailableForWhitelistOnlyFlag(bool pFlag) external onlyOwner {
        stakeAvailableForWhitelistOnlyFlag = pFlag;
    }

    /**
     * @dev Set flag to control if claim is available only for whitelisted addresses
     *
     * @param pFlag boolean flag
     */
    function setClaimAvailableForWhitelistOnlyFlag(bool pFlag) external onlyOwner {
        claimAvailableForWhitelistOnlyFlag = pFlag;
    }

    /**
     * @dev Set saleToken address
     *
     * @param pSaleToken boolean flag
     */
    function setSaleToken(address pSaleToken) external onlyOwner {
        saleToken = pSaleToken;
    }

    /**
     * @dev Set configurations of claim
     *
     * @param pStakingManager Address of stake contract
     * @param pSaleToken Address of sale token
     * @param pTokenAmount Amount of tokens available to claim
     * @param pClaimStartTime Claim start timestamp
     */
    function setupClaim(address pStakingManager, address pSaleToken, uint256 pTokenAmount, uint256 pClaimStartTime) external onlyOwner returns (bool) {
        require(isMainNetwork, "This is not the main network");
        require(pSaleToken != address(0), "Invalid sale token address");
        require(pTokenAmount > 0, "Token amount must be greater than zero");
        require(pClaimStartTime >= presaleEndTime, "Claim must start after presale ends");

        //Initilize sale token and staking manager instances
        IERC20 _token = IERC20(pSaleToken);
        stakingManager = StakingManager(pStakingManager); //Initilize sale token

        claimStartTime = pClaimStartTime;
        saleToken = pSaleToken;

        emit TokensAdded(pSaleToken, pTokenAmount, block.timestamp);

        if (pStakingManager != address(0)) {
            _token.safeIncreaseAllowance(pStakingManager, type(uint256).max); //Set allowance to staking manager contract spend sale tokens
        }

        //Check if presale contract has enough allowance to transfer tokens
        uint256 _presaleAllowance = _token.allowance(msg.sender, address(this));
        require(_presaleAllowance >= pTokenAmount, "Not enough allowance");

        //Transfer sale tokens to presale contract
        require(_token.balanceOf(msg.sender) >= pTokenAmount, "Balance not enough");
        _token.safeTransferFrom(msg.sender, address(this), pTokenAmount);

        return true;
    }

    /**
     * @dev To change the claim start time
     *
     * @param pClaimStartTime New claim start timestamp
     */
    function setClaimStartTime(uint256 pClaimStartTime) external onlyOwner returns (bool) {
        require(pClaimStartTime >= presaleEndTime, "Claim must start after presale ends");

        uint256 _claimStartTimeOld = claimStartTime;
        claimStartTime = pClaimStartTime;

        emit ClaimStartTimeUpdated(_claimStartTimeOld, claimStartTime, block.timestamp);
        return true;
    }

    /**
     * @dev Return array of remaining tokens per round
     */
    function getRemainingTokensTracker() external view returns (uint256[] memory) {
        return remainingTokensTracker;
    }

    /**
     * @dev Update remaining tokens tracker per round array
     *
     * @param pRemainingTokensTracker new array of remaining tokens tracker
     */
    function setRemainingTokensTracker(uint256[] calldata pRemainingTokensTracker) external onlyOwnerOrAdmin {
        require(pRemainingTokensTracker.length > 0, "Invalid parameter");

        delete remainingTokensTracker;

        uint256 size = pRemainingTokensTracker.length;
        for (uint256 i; i < size; i++) {
            remainingTokensTracker.push(pRemainingTokensTracker[i]);
        }
    }

    /**
     * @dev This function allows the contract owner or admin to retrieve the address of a staker from the list of stakers that joined during the presale
     *
     * @param pIndex The index of the staker's address in the array
     *
     * Requirements:
     * - Only the contract owner or admin can call this function
     *
     * @return The address of the staker at the specified index
     *
     */
    function getAddressUserDeposits(uint256 pIndex) external view returns (address) {
        return addressUserDeposits[pIndex];
    }

    /**
     * @dev Set imported value for a given address
     *
     * @param pAddresses address
     * @param pValues flag to indicate if address was imported or not
     */
    function setImported(address[] calldata pAddresses, bool[] calldata pValues) external onlyOwner {
        require(pAddresses.length == pValues.length, "Parameters length mismatch");

        uint256 size = pAddresses.length;
        for (uint256 i = 0; i < size; i++) {
            imported[pAddresses[i]] = pValues[i];
        }
    }

    /**
     * @dev Set is import done
     */
    function setIsImportDone(bool pIsImportDone) external onlyOwner {
        isImportDone = pIsImportDone;
    }

    /**
     * @dev Import userDeposits for purchases on other networks
     *
     * @param pAddresses array of users addresses
     * @param pDeposits array of userDeposits associated with users addresses
     */
    function importUserDeposits(address[] calldata pAddresses, uint256[] calldata pDeposits) external onlyOwner {
        require(isMainNetwork, "This is not the main network");
        require(pAddresses.length == pDeposits.length, "Parameters length mismatch");

        uint256 size = pAddresses.length;
        for (uint256 i = 0; i < size; i++) {
            require(!imported[pAddresses[i]], "Deposits already imported for this address");
            userDeposits[pAddresses[i]] += pDeposits[i];
            imported[pAddresses[i]] = true;
        }

        isImportDone = true;

        emit UserDepositsImported(pAddresses, pDeposits);
    }
}