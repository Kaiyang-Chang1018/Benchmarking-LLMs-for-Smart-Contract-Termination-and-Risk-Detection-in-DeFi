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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IAbridge, IAbridgeMessageHandler } from "./IAbridge.sol";

/// @title AbridgeMessageHandler
/// @notice Abstract contract for handling messages received through the Abridge bridge
abstract contract AbridgeMessageHandler is IAbridgeMessageHandler {
    /// @notice The Abridge contract for bridging messages
    IAbridge private _abridge;

    /// @dev Emitted when the Abridge contract address is updated
    /// @param oldBridge The address of the previous Abridge contract
    /// @param newBridge The address of the new Abridge contract
    event AbridgeUpdated(address indexed oldBridge, address indexed newBridge);

    /// @dev Emitted when a route is updated for a sender
    /// @param sender The address of the sender
    /// @param allowed Whether the sender is allowed to use the route
    event RouteUpdated(address indexed sender, bool allowed);

    /// @dev Error thrown when a function is not called from the Abridge contract
    error NotCalledFromAbridge();

    /// @dev Modifier to ensure the function is called only from the Abridge contract
    modifier onlyAbridge() {
        if (msg.sender != address(_abridge)) {
            revert NotCalledFromAbridge();
        }
        _;
    }

    /// @dev Constructor to initialize the AbridgeMessageHandler
    /// @param abridge_ The address of the Abridge contract
    constructor(address abridge_) {
        _abridge = IAbridge(abridge_);
    }

    /// @notice Get the current Abridge contract
    /// @return The IAbridge interface of the current Abridge contract
    function abridge() public view returns (IAbridge) {
        return _abridge;
    }

    /// @dev Internal function to update the Abridge contract
    /// @param bridge The new Abridge contract
    function _setAbridge(address bridge) internal {
        address oldBridge = address(_abridge);
        _abridge = IAbridge(bridge);
        emit AbridgeUpdated(oldBridge, address(bridge));
    }

    /// @dev Internal function to update a route for a sender
    /// @param sender The address of the sender
    /// @param allowed Whether the sender is allowed to use the route
    function _updateRoute(address sender, bool allowed) internal {
        _abridge.updateRoute(sender, allowed);
        emit RouteUpdated(sender, allowed);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title BridgeReceiver
/// @notice Interface for contracts that can receive messages through the bridge
interface IAbridgeMessageHandler {
    /// @notice Handles incoming messages from the bridge.
    /// @param _from The address of the sender
    /// @param _msg The message data
    /// @return response The function selector to confirm successful handling
    function handleMessage(address _from, bytes calldata _msg, bytes32 guid) external returns (bytes4 response);
}

/// @title IAbridge
/// @notice Interface for the Abridge contract
interface IAbridge {
    /// @notice Emitted when a message is sent through the bridge
    event MessageSent(address indexed sender, address indexed receiver, bytes32 guid, uint256 fee);

    /// @notice Emitted when a message is received through the bridge
    event MessageReceived(address indexed sender, address indexed receiver, bytes32 guid);

    /// @notice Emitted when an authorized sender is updated
    event AuthorizedSenderUpdated(address indexed sender, bool authorized);

    /// @notice Emitted when a route is updated
    event RouteUpdated(address indexed receiver, address indexed sender, bool allowed);

    error InsufficientFee(uint256 _sent, uint256 _required);
    error UnauthorizedSender(address _sender);
    error DisallowedRoute(address _sender, address _receiver);
    error InvalidReceiverResponse(bytes4 _response);

    /// @notice Updates the route for a specific sender
    /// @param _sender Address of the sender
    /// @param _allowed Flag to allow or disallow the route
    function updateRoute(address _sender, bool _allowed) external;

    /// @notice Sends a message through the bridge
    /// @param _receiver Address of the receiver
    /// @param _executeGasLimit Gas limit for execution
    /// @param _msg The message to be sent
    /// @return _guid The unique identifier for the sent message
    function send(
        address _receiver,
        uint128 _executeGasLimit,
        bytes memory _msg
    ) external payable returns (bytes32 _guid);

    /// @notice The endpoint ID of the destination chain
    function eid() external view returns (uint32);

    /// @notice Checks if a sender is authorized
    /// @param sender The address of the sender to check
    /// @return authorized True if the sender is authorized, false otherwise
    function authorizedSenders(address sender) external view returns (bool authorized);

    /// @notice Estimates the fee for sending a message
    /// @param _receiver Address of the receiver
    /// @param _executeGasLimit Gas limit for execution
    /// @param _msg The message to be sent
    /// @return _token The token address for the fee (address(0) for native token)
    /// @return _fee The estimated fee amount
    function estimateFee(
        address _receiver,
        uint128 _executeGasLimit,
        bytes memory _msg
    ) external view returns (address _token, uint256 _fee);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library MessageLib {
    /// @notice Messages are transferred between chains as 60=byte long bytes
    ///        The first 8 bits are the value type.
    ///        The next 136 bits are the value amount.
    ///        The next 160 bits are the address related to the value.
    ///        The next 48 bits are the value timestamp.
    ///        The remaining 128 bits are the value delta.
    struct Message {
        uint8 valueType;
        uint256 value;
        address owner;
        uint256 timestamp;
        uint256 delta;
    }

    uint256 internal constant _MAX_VALUE = type(uint136).max;
    uint256 internal constant _MAX_TIMESTAMP = type(uint48).max;
    uint256 internal constant _MAX_DELTA = type(uint128).max;

    uint8 public constant TOTAL_DEPOSITS_TYPE = 1;
    uint8 public constant TOTAL_POOL_UNLOCKS_TYPE = 2;
    uint8 public constant TOTAL_CLAIMS_TYPE = 3;
    uint8 public constant TOTAL_REQUESTS_TYPE = 4;
    uint8 public constant TOTAL_REDEEMEDS_TYPE = 5;

    error MessageLib_ValueOverflow();
    error MessageLib_TimestampOverflow();
    error MessageLib_DeltaOverflow();
    error MessageLib_InvalidMessageLength(uint256 length);

    ///
    /// @notice Extracts a Message from bytes.
    ///
    function unpack(bytes memory b) internal pure returns (Message memory m) {
        uint8 valueType;
        uint136 value;
        address owner;
        uint48 _timestamp;
        uint128 _delta;

        if (b.length != 60) revert MessageLib_InvalidMessageLength(b.length);

        /* solhint-disable no-inline-assembly */
        assembly {
            valueType := mload(add(b, 1))
            value := mload(add(b, 18))
            owner := mload(add(b, 38))
            _timestamp := mload(add(b, 44))
            _delta := mload(add(b, 60))
        }
        /* solhint-enable no-inline-assembly */

        return Message(valueType, value, owner, _timestamp, _delta);
    }

    ///
    /// @notice Packs a Message into bytes.
    ///
    function pack(Message memory m) internal pure returns (bytes memory) {
        if (m.value > _MAX_VALUE) revert MessageLib_ValueOverflow();
        if (m.timestamp > _MAX_TIMESTAMP) revert MessageLib_TimestampOverflow();
        if (m.delta > _MAX_DELTA) revert MessageLib_DeltaOverflow();

        return abi.encodePacked(m.valueType, uint136(m.value), m.owner, uint48(m.timestamp), uint128(m.delta));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IRedemptionAssetVault {
    struct Redemption {
        uint256 amount; // amount of LSD
        address owner;
        uint48 timestamp;
        bool isFulfilled;
    }

    event RedemptionReceived(
        uint256 redemptionId,
        address lsd,
        uint256 amount,
        address owner,
        uint256 timestamp,
        bytes32 guid
    );

    event RedemptionFulfilled(uint256 redemptionId, address lsd, uint256 amount, address owner, uint256 timestamp);

    event NewUnstaker(address unstaker);
    event RedemptionOnGravityUpdated(address redemption);
    event NewMaxExchangeRateLimit(address token, uint256 maxExchangeRate);

    error SendFailed(address to, uint256 amount);
    error InvalidBackingAsset();
    error InvalidBridgeMessage(uint8 messageType);
    error InvalidRedeemAmount(uint256 amount);
    error InvalidTimestamp(uint256 timestamp);
    error RedemptionAlreadyFulfilled(uint256 redemptionId);
    error InvalidLSD();
    error InvalidCaller(address caller);
    error InvalidBridgeMessageFrom(address from);
    error InvalidRedemptionId(uint256 redemptionId);
    error ExceedMaxExchangeRate(address lsd, uint256 lsdAmount, uint256 minLSDAmount);

    function fulfillRedemption(
        uint256 _redemptionId,
        address[] calldata _tokens,
        uint256[] calldata _amount,
        address[] calldata _froms
    ) external payable;
    function nextPendingRedemption() external view returns (Redemption memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { MessageLib } from "../message-lib/MessageLib.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { IRedemptionAssetVault } from "./IRedemptionAssetVault.sol";
import { IAbridgeMessageHandler } from "../abridge/IAbridge.sol";
import { AbridgeMessageHandler } from "../abridge/AbridgeMessageHandler.sol";

/// @title RemptionAssetVault
/// @notice Responsiable for allowing unstaker to fulfill redemptions and sending backing asset to redeemers.
/// @dev The Redemption address on the Gravity should be set allowed sender to properly receive bridging message.
contract RedemptionAssetVault is AbridgeMessageHandler, Ownable2Step, Pausable, ERC165, IRedemptionAssetVault {
    using SafeERC20 for IERC20;

    /// @notice Address of LSD token.
    address public immutable LSD;
    /// @notice Address of the unstaker
    address public unstaker;

    /// @notice Accumulated LSD token amount of received redemptions.
    /// @dev owner => totalReceived
    mapping(address => uint256) public totalRecevieds;

    /// @notice Accumulated LSD token amount of received redemptions
    uint256 public accReceivedRedemptions;
    /// @notice Accumulated LSD token amount of fulfilled redemptions
    ///  Also is the next ID of redemption to be fulfilled.
    uint256 public accFulfilledRedemptions;

    /// @notice Received redemptions.
    /// @dev redemptionId => Redemption
    mapping(uint256 => Redemption) public redemptions;

    /// @notice The address of Redemption contract on Gravity.
    address public redemptionOnGravity;

    /// @notice The max exchange rate limit of LSD to other tokens, with 18 decimals.
    mapping(address => uint256) public maxExchangeRateLimits;

    modifier onlyUnstaker() {
        if (msg.sender != unstaker) {
            revert InvalidCaller(msg.sender);
        }
        _;
    }

    /// @dev Constructor to initialize the OAppCore with the provided endpoint and delegate.
    /// @param _lsd The address of bound LSD token.
    /// @param _owner The owner/admin of this contract.
    /// @param _abridge The address of the Abridge contract.
    constructor(
        address _lsd,
        address _owner, // solhint-disable-line no-unused-vars
        address _abridge // solhint-disable-line no-unused-vars
    ) Ownable(_owner) AbridgeMessageHandler(_abridge) {
        if (_lsd == address(0)) {
            revert InvalidLSD();
        }
        LSD = _lsd;
    }

    /// Fallback function to receive native token
    receive() external payable {}

    /// @notice Fulfill the `_redemptionId` redemption by sending backing assets to
    ///   related redeemer
    /// @param _redemptionId The ID of redemption to be fulfilled.
    /// @param _tokens Array of addresses of backing asset.
    /// @param _amounts Array of amount of backing asset.
    /// @param _froms Array of owners of backing asset.
    function fulfillRedemption(
        uint256 _redemptionId,
        address[] calldata _tokens,
        uint256[] calldata _amounts,
        address[] calldata _froms
    ) external payable whenNotPaused onlyUnstaker {
        if ((_tokens.length != _amounts.length) || (_tokens.length != _froms.length)) {
            revert InvalidBackingAsset();
        }

        Redemption storage redemption = redemptions[_redemptionId];
        if (redemption.isFulfilled) {
            revert RedemptionAlreadyFulfilled(_redemptionId);
        }
        if (redemption.owner == address(0)) {
            revert InvalidRedemptionId(_redemptionId);
        }

        _mustMeetsMaxExchangeRate(redemption.amount, _tokens, _amounts);

        redemption.isFulfilled = true;

        accFulfilledRedemptions += redemption.amount;

        // send backing asset
        _transferBackingAsset(_tokens, _amounts, _froms, redemption.owner);

        emit RedemptionFulfilled(_redemptionId, LSD, redemption.amount, redemption.owner, redemption.timestamp);

        redemption.amount = 0; // zeroing the variable to get gas refund
    }

    /// @notice Pause redemption.
    /// @dev Emit a `Paused` event.
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Pause redemption.
    /// @dev Emit a `Unpaused` event.
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Set the unstaker address
    /// @param _unstaker The address of the unstaker
    /// @dev Emit a `NewUnstaker` event
    function setUnstaker(address _unstaker) external onlyOwner {
        unstaker = _unstaker;
        emit NewUnstaker(_unstaker);
    }

    /// @notice Sets the abridge address
    /// @param _abridge The address of the Abridge contract
    function setAbridge(address _abridge) external onlyOwner {
        _setAbridge(_abridge);
    }

    /// @notice Sets the address of Redemption on the Gravity
    /// @dev Emits a `RedemptionOnGravityUpdated` event.
    /// @param _redemption The address of the Redemption contract on the Gravity
    function setRedemptionOnGravity(address _redemption) external onlyOwner {
        redemptionOnGravity = _redemption;
        emit RedemptionOnGravityUpdated(_redemption);
    }

    /// @notice Sets the max exchange rate limit of LSD to other tokens.
    /// @dev Emits `NewMaxExchangeRate` events.
    /// @param _tokens The list of address of the token
    /// @param _maxExchangeRates The list of max exchange rate limit of LSD to the token
    function setMaxExchangeRateLimit(
        address[] calldata _tokens,
        uint256[] calldata _maxExchangeRates
    ) external onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            maxExchangeRateLimits[_tokens[i]] = _maxExchangeRates[i];
            emit NewMaxExchangeRateLimit(_tokens[i], _maxExchangeRates[i]);
        }
    }

    /// @notice Handles incoming redemption messages from the Abridge contract
    /// @param _from The address that sent the message
    /// @param _message The encoded message data
    /// @param _guid A unique identifier for the message
    /// @return response The function selector indicating successful message handling
    function handleMessage(
        address _from,
        bytes calldata _message,
        bytes32 _guid
    ) external override onlyAbridge returns (bytes4 response) {
        MessageLib.Message memory m = MessageLib.unpack(_message);
        if (m.valueType != MessageLib.TOTAL_REDEEMEDS_TYPE) {
            revert InvalidBridgeMessage(m.valueType);
        }
        if (_from != redemptionOnGravity) {
            revert InvalidBridgeMessageFrom(_from);
        }
        _receiveRedemption(m.owner, m.value, m.timestamp, m.delta, _guid);

        return IAbridgeMessageHandler.handleMessage.selector;
    }

    /// @notice Updates the message route for the sender, allow or disallowed.
    function updateRoute(address _sender, bool allowed) external onlyOwner {
        _updateRoute(_sender, allowed);
    }

    /// @notice To withdraw unexpectedly received tokens.
    /// @param _token Address of token wanted to withdraw.
    /// @param _to Address to receive the withdrawed token.
    function rescueWithdraw(address _token, address _to) external onlyOwner {
        if (_token == address(0)) {
            uint256 amount = address(this).balance;
            (bool sent, ) = _to.call{ value: amount }("");
            if (!sent) {
                revert SendFailed(_to, amount);
            }
        } else {
            uint256 _amount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(_to, _amount);
        }
    }

    /// @notice To get next pending redemption.
    /// @return The next pending redemption to be fulfilled, or empty if none are pending.
    function nextPendingRedemption() external view returns (Redemption memory) {
        return redemptions[accFulfilledRedemptions];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IRedemptionAssetVault).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @notice To save received redemption.
    /// @dev update totalPoolClaims，emits a `RedemptionReceived` event
    /// @param _receiver Address of the account to receive the backing asset.
    /// @param _totalRedeemeds Accumulated redeemed lsd token amount
    /// @param _timestamp The timestamp when the redemption was initiated
    /// @param _newRedeemed The amount of new redemption to be saved.
    /// @param _guid The unique identifier for the received LayerZero message.
    function _receiveRedemption(
        address _receiver,
        uint256 _totalRedeemeds,
        uint256 _timestamp,
        uint256 _newRedeemed,
        bytes32 _guid
    ) internal {
        if (_timestamp == 0) {
            revert InvalidTimestamp(_timestamp);
        }
        if (_totalRedeemeds == 0) {
            revert InvalidRedeemAmount(_totalRedeemeds);
        }

        // reject unordered redemptions
        if (totalRecevieds[_receiver] + _newRedeemed != _totalRedeemeds) {
            revert InvalidRedeemAmount(_totalRedeemeds);
        }
        totalRecevieds[_receiver] = _totalRedeemeds;

        // amount of redempation needed to fulfill
        uint256 redemptionId = accReceivedRedemptions;
        accReceivedRedemptions += _newRedeemed;

        redemptions[redemptionId] = Redemption({
            amount: _newRedeemed,
            owner: _receiver,
            timestamp: uint48(_timestamp),
            isFulfilled: false
        });

        emit RedemptionReceived(redemptionId, LSD, _newRedeemed, _receiver, _timestamp, _guid);
    }

    /// @dev Transfer `_amount` of `_token` to `_receiver`.
    /// @param _tokens Array of addresses of backing asset.
    /// @param _amounts Array of amount of backing asset.
    /// @param _froms Array of owners of backing asset.
    /// @param _receiver The address of account to receive the transferred tokens.
    function _transferBackingAsset(
        address[] calldata _tokens,
        uint256[] calldata _amounts,
        address[] calldata _froms,
        address _receiver
    ) internal {
        uint256 nativeTokenAmount = 0;
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_tokens[i] == address(0)) {
                if (nativeTokenAmount > 0) {
                    // multiple native token transfers are not allowed
                    revert InvalidBackingAsset();
                }
                nativeTokenAmount = _amounts[i];
            } else {
                IERC20(_tokens[i]).safeTransferFrom(_froms[i], _receiver, _amounts[i]);
            }
        }
        if (nativeTokenAmount > 0) {
            if (msg.value != nativeTokenAmount) {
                revert InvalidBackingAsset();
            }
            (bool sent, ) = _receiver.call{ value: nativeTokenAmount }("");
            if (!sent) revert SendFailed(_receiver, nativeTokenAmount);
        }
    }

    /// @notice To check if the exchange rate of LSD to `_token` meets the max exchange rate limit.
    /// @param _lsdAmount The amount of LSD token to be exchanged.
    /// @param _tokens The address array of the token to be exchanged.
    /// @param _amounts The amount array of the token to be exchanged.
    function _mustMeetsMaxExchangeRate(
        uint256 _lsdAmount,
        address[] calldata _tokens,
        uint256[] calldata _amounts
    ) internal view {
        uint256 minLSDAmount = 0;
        for (uint256 i = 0; i < _tokens.length; i++) {
            minLSDAmount += (1e18 * _amounts[i]) / maxExchangeRateLimits[_tokens[i]];
        }

        if (_lsdAmount < minLSDAmount) {
            revert ExceedMaxExchangeRate(LSD, _lsdAmount, minLSDAmount);
        }
    }
}