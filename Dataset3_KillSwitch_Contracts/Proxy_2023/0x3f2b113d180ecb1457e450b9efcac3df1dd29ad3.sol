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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
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
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;

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

        (bool success,) = recipient.call{value: amount}("");
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
    function verifyCallResultFromTarget(address target, bool success, bytes memory returndata)
        internal
        view
        returns (bytes memory)
    {
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
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
pragma solidity >=0.6.2;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./interfaces/IElement280.sol";
import "./interfaces/ITitanOnBurn.sol";
import "./interfaces/ITITANX.sol";
import "./interfaces/IWETH9.sol";

import "./lib/constants.sol";

/// @title Element 280 Buy&Burn Contract
contract ElementBuyBurn is Ownable2Step, IERC165, ITitanOnBurn {
    using SafeERC20 for IERC20;

    // --------------------------- STATE VARIABLES --------------------------- //

    struct EcosystemToken {
        uint256 capPerSwapTitanX;
        uint256 capPerSwapEco;
        uint256 interval;
        uint256 lastTimestamp;
        uint256 totalE280Burned;
        uint256 totalTokensBurned;
        uint256 titanXAllocation;
        uint8 allocationPercent;
    }

    address public treasury;
    address public devWallet;
    address public immutable E280;

    /// @notice Incentive fee amount, measured in basis points (100 bps = 1%).
    uint16 public incentiveFeeBps = 30;

    /// @notice The total amount of TitanX allocated for Buy&Burn.
    uint256 public totalTitanXAllocated;
    /// @notice The total amount of TitanX tokens used in Buy&Burn to date.
    uint256 public totalTitanXUsed;
    /// @notice The total amount of Element 280 tokens burned to date.
    uint256 public totalE280Burned;

    /// @notice The maximum amount of ETH/WETH that can be swapped per rebalance.
    uint256 public capPerSwapETH = 2 ether;
    /// @notice Time between rebalances in seconds.
    uint256 public rebalanceInterval = 2 hours;
    /// @notice Time of the last rebalance in seconds.
    uint256 public lastRebalance;
    uint256 private constant minTitanX = 1 ether;

    /// @notice The list of all ecosystem tokens integrated in the Buy&Burn contract.
    address[] public ecosystemTokens;

    /// @notice A mapping of ecosystem token addresses to their corresponding data.
    /// @return capPerSwapTitanX The maximum amount of TitanX that can be allocated for each swap.
    /// @return capPerSwapEco The maximum amount of the ecosystem token that can be swapped at one time.
    /// @return interval The cooldown period (in seconds) between Buy&Burn operations for the token.
    /// @return lastTimestamp The timestamp of the last Buy&Burn operation for the token.
    /// @return totalE280Burned The total amount of E280 tokens burned through this ecosystem token's swaps.
    /// @return totalTokensBurned The total amount of the ecosystem token burned.
    /// @return titanXAllocation The amount of TitanX allocated for this ecosystem token to be used for Buy&Burn.
    /// @return allocationPercent The percentage of total TitanX to be allocated to this ecosystem token during rebalance.
    mapping(address token => EcosystemToken) public tokens;

    // --------------------------- EVENTS --------------------------- //
    event Rebalance();
    event BuyBurn(address token);

    // --------------------------- CONSTRUCTOR --------------------------- //
    constructor(
        address _E280,
        address _owner,
        address _devWallet,
        address _treasury,
        address[] memory _ecosystemTokens,
        uint8[] memory _percentages,
        uint256[] memory _capsPerSwapTitanX,
        uint256[] memory _capsPerSwapEco,
        uint256[] memory _intervals
    ) Ownable(_owner) {
        require(_ecosystemTokens.length == NUM_ECOSYSTEM_TOKENS, "Incorrect number of tokens");
        require(_percentages.length == NUM_ECOSYSTEM_TOKENS, "Incorrect number of tokens");
        require(_capsPerSwapTitanX.length == NUM_ECOSYSTEM_TOKENS, "Incorrect number of tokens");
        require(_capsPerSwapEco.length == NUM_ECOSYSTEM_TOKENS, "Incorrect number of tokens");
        require(_intervals.length == NUM_ECOSYSTEM_TOKENS, "Incorrect number of tokens");
        require(_E280 != address(0), "E280 token address not provided");
        require(_owner != address(0), "Owner wallet not provided");
        require(_devWallet != address(0), "Dev wallet address not provided");
        require(_treasury != address(0), "Treasury address not provided");

        E280 = _E280;
        devWallet = _devWallet;
        treasury = _treasury;
        ecosystemTokens = _ecosystemTokens;

        uint8 totalPercentage;
        for (uint256 i = 0; i < _ecosystemTokens.length; i++) {
            address token = _ecosystemTokens[i];
            uint8 allocation = _percentages[i];
            require(token != address(0), "Incorrect token address");
            require(allocation > 0, "Incorrect percentage value");
            require(tokens[token].allocationPercent == 0, "Duplicate token");
            tokens[token] =
                EcosystemToken(_capsPerSwapTitanX[i], _capsPerSwapEco[i], _intervals[i], 0, 0, 0, 0, allocation);
            totalPercentage += allocation;
        }
        require(totalPercentage == 100, "Percentages do not add up to 100");
    }

    receive() external payable {}

    // --------------------------- PUBLIC FUNCTIONS --------------------------- //

    /// @notice Rebalances ecosystem token allocations by redistributing ETH, WETH, and TitanX tokens.
    /// @dev Has a cooldown equal to rebalanceInterval.
    function rebalance() external {
        require(address(msg.sender).code.length == 0 && msg.sender == tx.origin, "No contracts");
        require(block.timestamp > lastRebalance + rebalanceInterval, "Cooldown in progress");
        //Swap ETH to WETH if available
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) IWETH9(WETH9).deposit{value: ethBalance}();

        //Check if WETH is available
        uint256 wethBalance = IERC20(WETH9).balanceOf(address(this));
        uint256 wethToSwap = wethBalance > capPerSwapETH ? capPerSwapETH : wethBalance;
        if (wethToSwap > 0) _swapWETHForTitanX(wethToSwap);

        uint256 unaccountedTitan = getUnaccountedTitanX();
        if (unaccountedTitan > 0) {
            lastRebalance = block.timestamp;
            for (uint256 i = 0; i < ecosystemTokens.length; i++) {
                EcosystemToken storage token = tokens[ecosystemTokens[i]];
                uint256 allocation = unaccountedTitan * token.allocationPercent / 100;
                unchecked {
                    token.titanXAllocation += allocation;
                    totalTitanXAllocated += allocation;
                }
            }
        }
        emit Rebalance();
    }

    /// @notice Buys and burns the Element 280 tokens based on TitanX allocations or native balance of a specific ecosystem token.
    /// @param tokenAddress The address of the ecosystem token to be used in Buy&Burn.
    /// @param minTokenAmount The minimum amount out for the TitanX -> Ecosystem token swap.
    /// @param minE280Amount The minimum amount out for Ecosystem token -> ELMT swap.
    /// @param deadline The deadline for the swaps.
    function buyAndBurn(address tokenAddress, uint256 minTokenAmount, uint256 minE280Amount, uint256 deadline)
        external
    {
        require(address(msg.sender).code.length == 0 && msg.sender == tx.origin, "No contracts");
        if (tokenAddress == TITANX) return _handleTitanXBuyAndBurn(tokenAddress, minE280Amount, deadline);
        EcosystemToken storage token = tokens[tokenAddress];
        require(block.timestamp > token.lastTimestamp + token.interval, "Cooldown in progress");
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 tokenBalance = tokenContract.balanceOf(address(this));
        (uint256 totalAllocation, bool isNative) = _getNextSwapValue(token, tokenBalance);
        require(totalAllocation > 0, "No allocation available");
        uint256 tokensToDistribute;
        if (isNative) {
            tokensToDistribute = _processIncentiveFee(tokenContract, totalAllocation);
        } else {
            tokenBalance += _swapTitanXToToken(tokenAddress, totalAllocation, minTokenAmount, deadline);
            uint256 newTotalAllocation = tokenBalance > token.capPerSwapEco ? token.capPerSwapEco : tokenBalance;
            tokensToDistribute = _processIncentiveFee(tokenContract, newTotalAllocation);
        }
        (uint256 tokenBurnFee, uint256 tokensToSwap) = _handleTokenDisperse(tokenContract, tokensToDistribute);
        _handleTokenBurn(tokenAddress, tokenBurnFee);
        _handleE280Swap(tokenAddress, tokensToSwap, minE280Amount, deadline);
        uint256 totalBurned = _handleE280Burn();
        unchecked {
            if (!isNative) {
                totalTitanXUsed += totalAllocation;
                token.titanXAllocation -= totalAllocation;
            }
            token.totalE280Burned += totalBurned;
        }
        token.lastTimestamp = block.timestamp;
        emit BuyBurn(tokenAddress);
    }

    // --------------------------- ADMINISTRATIVE FUNCTIONS --------------------------- //

    /// @notice Sets the treasury address.
    /// @param _address The new treasury address.
    function setTreasury(address _address) external onlyOwner {
        require(_address != address(0), "Treasury address not provided");
        treasury = _address;
    }

    /// @notice Sets the incentive fee basis points (bps) for token swaps.
    /// @param bps The incentive fee in basis points (0 - 1000), (100 bps = 1%).
    function setIncentiveFee(uint16 bps) external onlyOwner {
        require(bps < 1001, "Incentive should not exceed 10%");
        incentiveFeeBps = bps;
    }

    /// @notice Sets the cap per swap for ETH/TitanX and WETH/TitanX swaps.
    /// @param limit The new cap limit in WEI.
    function setEthCapPerSwap(uint256 limit) external onlyOwner {
        capPerSwapETH = limit;
    }

    /// @notice Sets the rebalance interval.
    /// @param interval The new rebalance interval in seconds.
    function setRebalanceInterval(uint256 interval) external onlyOwner {
        rebalanceInterval = interval;
    }

    /// @notice Sets the cooldown interval for a specific token.
    /// @param tokenAddress The address of the token.
    /// @param interval The new cooldown interval in seconds for the token.
    function setTokenInterval(address tokenAddress, uint256 interval) external onlyOwner {
        EcosystemToken storage token = tokens[tokenAddress];
        require(token.allocationPercent > 0, "Not an ecosystem token");
        token.interval = interval;
    }

    /// @notice Sets the cap per swap for a specific token.
    /// @param tokenAddress The address of the token.
    /// @param capPerSwapTitanX The new TitanX cap per swap in WEI.
    /// @param capPerSwapEco The new token cap per swap in WEI.
    function setTokenCapPerSwap(address tokenAddress, uint256 capPerSwapTitanX, uint256 capPerSwapEco)
        external
        onlyOwner
    {
        EcosystemToken storage token = tokens[tokenAddress];
        require(token.allocationPercent > 0, "Not an ecosystem token");
        token.capPerSwapTitanX = capPerSwapTitanX;
        token.capPerSwapEco = capPerSwapEco;
    }

    // --------------------------- VIEW FUNCTIONS --------------------------- //

    /// @notice Checks if rebalance is available.
    function isRebalanceAvailable() external view returns (bool) {
        if (block.timestamp <= lastRebalance + rebalanceInterval) return false;
        return address(this).balance > 0 || IERC20(WETH9).balanceOf(address(this)) > 0 || getUnaccountedTitanX() > 0;
    }

    /// @notice Returns the amount of unaccounted TitanX tokens held by the contract.
    /// @return unaccountedTitan The amount of TitanX tokens available for rebalancing.
    function getUnaccountedTitanX() public view returns (uint256 unaccountedTitan) {
        uint256 titanBalance = IERC20(TITANX).balanceOf(address(this));
        unchecked {
            unaccountedTitan = titanBalance + totalTitanXUsed - totalTitanXAllocated;
        }
        if (unaccountedTitan < minTitanX) return 0;
        return unaccountedTitan;
    }

    /// @notice Returns the next amount of tokens that will be swaped in next Buy&Burn operation and whether the swap is in native tokens.
    /// @param tokenAddress The address of the ecosystem token to use in Buy&Burn.
    /// @return tokensToSwap The amount of tokens that will be used in Buy&Burn.
    /// @return isNative Whether the ecosystem token or TitanX allocation will be used for the Buy&Burn operation.
    function getNextSwapValue(address tokenAddress) public view returns (uint256 tokensToSwap, bool isNative) {
        EcosystemToken storage token = tokens[tokenAddress];
        require(token.capPerSwapTitanX > 0, "Token is disabled");
        uint256 nativeBalance = IERC20(tokenAddress).balanceOf(address(this));
        isNative = tokenAddress == TITANX ? false : token.capPerSwapEco <= nativeBalance;
        tokensToSwap = isNative
            ? token.capPerSwapEco
            : token.titanXAllocation > token.capPerSwapTitanX ? token.capPerSwapTitanX : token.titanXAllocation;
    }

    /// @notice Calculates the incentive fee to be applied based on the input token amount.
    /// @param tokenAmount The amount of tokens being used.
    /// @return The calculated incentive fee in tokens.
    function calculateIncentiveFee(uint256 tokenAmount) public view returns (uint256) {
        unchecked {
            return tokenAmount * incentiveFeeBps / 10000;
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return interfaceId == INTERFACE_ID_ERC165 || interfaceId == INTERFACE_ID_ITITANONBURN;
    }

    // --------------------------- INTERNAL FUNCTIONS --------------------------- //

    function _getNextSwapValue(EcosystemToken memory token, uint256 tokenBalance)
        internal
        pure
        returns (uint256 tokensToSwap, bool isNative)
    {
        require(token.capPerSwapTitanX > 0, "Token is disabled");
        isNative = token.capPerSwapEco <= tokenBalance;
        tokensToSwap = isNative
            ? token.capPerSwapEco
            : token.titanXAllocation > token.capPerSwapTitanX ? token.capPerSwapTitanX : token.titanXAllocation;
    }

    function _processIncentiveFee(IERC20 token, uint256 tokenAmount) internal returns (uint256) {
        uint256 incentiveFee = calculateIncentiveFee(tokenAmount);
        token.safeTransfer(msg.sender, incentiveFee);
        unchecked {
            return tokenAmount - incentiveFee;
        }
    }

    function _handleTitanXBuyAndBurn(address tokenAddress, uint256 minE280Amount, uint256 deadline) internal {
        EcosystemToken storage token = tokens[tokenAddress];
        require(block.timestamp > token.lastTimestamp + token.interval, "Cooldown in progress");
        (uint256 totalTitanXAllocation,) = _getNextSwapValue(token, 0);
        require(totalTitanXAllocation > 0, "No allocation available");
        uint256 titanXToSwap = _processIncentiveFee(IERC20(tokenAddress), totalTitanXAllocation);
        (uint256 tokensToSwap, uint256 burnFee) = _handleTitanXDisperse(titanXToSwap);
        _handleE280Swap(tokenAddress, tokensToSwap, minE280Amount, deadline);
        uint256 totalBurned = _handleE280Burn();
        unchecked {
            totalTitanXUsed += totalTitanXAllocation;
            token.titanXAllocation -= totalTitanXAllocation;
            token.totalE280Burned += totalBurned;
            token.totalTokensBurned += burnFee;
            token.lastTimestamp = block.timestamp;
        }
        emit BuyBurn(tokenAddress);
    }

    function _handleTitanXDisperse(uint256 amount) internal returns (uint256 tokensToSwap, uint256 burnFee) {
        IERC20 titanX = IERC20(TITANX);
        uint256 devFee;
        uint256 treasuryFee;
        unchecked {
            devFee = amount * DEV_PERCENT / 100;
            burnFee = amount * BURN_PERCENT / 100;
            treasuryFee = amount * TREASURY_PERCENT / 100 + burnFee;
            tokensToSwap = amount - devFee - treasuryFee;
        }
        titanX.safeTransfer(devWallet, devFee);
        titanX.safeTransfer(treasury, treasuryFee);
    }

    function _handleTokenDisperse(IERC20 token, uint256 amount)
        internal
        returns (uint256 burnFee, uint256 tokensToSwap)
    {
        uint256 devFee;
        uint256 treasuryFee;
        unchecked {
            devFee = amount * DEV_PERCENT / 100;
            treasuryFee = amount * TREASURY_PERCENT / 100;
            burnFee = amount * BURN_PERCENT / 100;
            tokensToSwap = amount - devFee - treasuryFee - burnFee;
        }
        token.safeTransfer(devWallet, devFee);
        token.safeTransfer(treasury, treasuryFee);
    }

    function _handleE280Swap(address tokenIn, uint256 amount, uint256 minAmountOut, uint256 deadline)
        internal
        returns (uint256)
    {
        require(minAmountOut > 0, "minAmountOut not provided");
        IERC20(tokenIn).safeIncreaseAllowance(UNISWAP_V2_ROUTER, amount);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = E280;

        uint256[] memory amounts = IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            amount, minAmountOut, path, address(this), deadline
        );
        return amounts[1];
    }

    function _handleTokenBurn(address tokenAddress, uint256 amountToBurn) internal {
        if (tokenAddress == HELIOS_ADDRESS || tokenAddress == HYPER_ADDRESS || tokenAddress == HYDRA_ADDRESS) {
            IERC20(tokenAddress).safeIncreaseAllowance(address(this), amountToBurn);
            ITITANX(tokenAddress).burnTokensToPayAddress(address(this), amountToBurn, 0, 8, devWallet);
        } else if (tokenAddress == DRAGONX_ADDRESS) {
            IERC20(tokenAddress).safeTransfer(DRAGONX_BURN_ADDRESS, amountToBurn);
            tokens[tokenAddress].totalTokensBurned += amountToBurn;
        } else {
            IERC20Burnable(tokenAddress).burn(amountToBurn);
            tokens[tokenAddress].totalTokensBurned += amountToBurn;
        }
    }

    function _handleE280Burn() internal returns (uint256) {
        IElement280 e280 = IElement280(E280);
        uint256 amountToBurn = IERC20(E280).balanceOf(address(this));
        e280.burn(amountToBurn);
        totalE280Burned += amountToBurn;
        return amountToBurn;
    }

    function _swapWETHForTitanX(uint256 amountIn) private returns (uint256) {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: WETH9,
            tokenOut: TITANX,
            fee: POOL_FEE_1PERCENT,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        IERC20(WETH9).safeIncreaseAllowance(UNISWAP_V3_ROUTER, amountIn);
        uint256 amountOut = ISwapRouter(UNISWAP_V3_ROUTER).exactInputSingle(params);
        return amountOut;
    }

    /// @notice ITitanOnBurn interface function.
    function onBurn(address, uint256 amount) external {
        EcosystemToken storage token = tokens[msg.sender];
        require(token.allocationPercent != 0, "Not an ecosystem token");
        unchecked {
            token.totalTokensBurned += amount;
        }
    }

    function _swapTitanXToToken(address outputToken, uint256 amount, uint256 minAmountOut, uint256 deadline)
        internal
        returns (uint256)
    {
        if (outputToken == BLAZE_ADDRESS) return _swapUniswapV2Pool(outputToken, amount, minAmountOut, deadline);
        if (outputToken == BDX_ADDRESS || outputToken == HYDRA_ADDRESS || outputToken == AWESOMEX_ADDRESS) {
            return _swapMultihop(outputToken, DRAGONX_ADDRESS, amount, minAmountOut, deadline);
        }
        if (outputToken == FLUX_ADDRESS) {
            return _swapMultihop(outputToken, INFERNO_ADDRESS, amount, minAmountOut, deadline);
        }
        return _swapUniswapV3Pool(outputToken, amount, minAmountOut, deadline);
    }

    function _swapUniswapV3Pool(address outputToken, uint256 amountIn, uint256 minAmountOut, uint256 deadline)
        private
        returns (uint256)
    {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: TITANX,
            tokenOut: outputToken,
            fee: POOL_FEE_1PERCENT,
            recipient: address(this),
            deadline: deadline,
            amountIn: amountIn,
            amountOutMinimum: minAmountOut,
            sqrtPriceLimitX96: 0
        });
        IERC20(TITANX).safeIncreaseAllowance(UNISWAP_V3_ROUTER, amountIn);
        uint256 amountOut = ISwapRouter(UNISWAP_V3_ROUTER).exactInputSingle(params);
        return amountOut;
    }

    function _swapUniswapV2Pool(address outputToken, uint256 amountIn, uint256 minAmountOut, uint256 deadline)
        internal
        returns (uint256)
    {
        require(minAmountOut > 0, "minAmountOut not provided");
        IERC20(TITANX).safeIncreaseAllowance(UNISWAP_V2_ROUTER, amountIn);

        address[] memory path = new address[](2);
        path[0] = TITANX;
        path[1] = outputToken;

        uint256[] memory amounts = IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            amountIn, minAmountOut, path, address(this), deadline
        );

        return amounts[1];
    }

    function _swapMultihop(
        address outputToken,
        address midToken,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline
    ) internal returns (uint256) {
        bytes memory path = abi.encodePacked(TITANX, POOL_FEE_1PERCENT, midToken, POOL_FEE_1PERCENT, outputToken);

        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: address(this),
            deadline: deadline,
            amountIn: amountIn,
            amountOutMinimum: minAmountOut
        });
        IERC20(TITANX).safeIncreaseAllowance(UNISWAP_V3_ROUTER, amountIn);
        uint256 amoutOut = ISwapRouter(UNISWAP_V3_ROUTER).exactInput(params);
        return amoutOut;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20Burnable {
    function burn(uint256 value) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20Burnable.sol";

interface IElement280 is IERC20Burnable {
    function presaleEnd() external returns (uint256);
    function handleRedeem(uint256 amount, address receiver) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface ITITANX {
    error TitanX_InvalidAmount();
    error TitanX_InsufficientBalance();
    error TitanX_NotSupportedContract();
    error TitanX_InsufficientProtocolFees();
    error TitanX_FailedToSendAmount();
    error TitanX_NotAllowed();
    error TitanX_NoCycleRewardToClaim();
    error TitanX_NoSharesExist();
    error TitanX_EmptyUndistributeFees();
    error TitanX_InvalidBurnRewardPercent();
    error TitanX_InvalidBatchCount();
    error TitanX_InvalidMintLadderInterval();
    error TitanX_InvalidMintLadderRange();
    error TitanX_MaxedWalletMints();
    error TitanX_LPTokensHasMinted();
    error TitanX_InvalidAddress();
    error TitanX_InsufficientBurnAllowance();

    function getBalance() external;

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

    function burnTokensToPayAddress(
        address user,
        uint256 amount,
        uint256 userRebatePercentage,
        uint256 rewardPaybackPercentage,
        address rewardPaybackAddress
    ) external;

    function burnTokens(address user, uint256 amount, uint256 userRebatePercentage, uint256 rewardPaybackPercentage)
        external;

    function userBurnTokens(uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ITitanOnBurn {
    function onBurn(address user, uint256 amount) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/ITitanOnBurn.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

// ===================== Contract Addresses =====================================
uint8 constant NUM_ECOSYSTEM_TOKENS = 14;

address constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant TITANX = 0xF19308F923582A6f7c465e5CE7a9Dc1BEC6665B1;
address constant HYPER_ADDRESS = 0xE2cfD7a01ec63875cd9Da6C7c1B7025166c2fA2F;
address constant HELIOS_ADDRESS = 0x2614f29C39dE46468A921Fd0b41fdd99A01f2EDf;
address constant DRAGONX_ADDRESS = 0x96a5399D07896f757Bd4c6eF56461F58DB951862;
address constant BDX_ADDRESS = 0x9f278Dc799BbC61ecB8e5Fb8035cbfA29803623B;
address constant BLAZE_ADDRESS = 0xfcd7cceE4071aA4ecFAC1683b7CC0aFeCAF42A36;
address constant INFERNO_ADDRESS = 0x00F116ac0c304C570daAA68FA6c30a86A04B5C5F;
address constant HYDRA_ADDRESS = 0xCC7ed2ab6c3396DdBc4316D2d7C1b59ff9d2091F;
address constant AWESOMEX_ADDRESS = 0xa99AFcC6Aa4530d01DFFF8E55ec66E4C424c048c;
address constant FLUX_ADDRESS = 0xBFDE5ac4f5Adb419A931a5bF64B0f3BB5a623d06;

address constant DRAGONX_BURN_ADDRESS = 0x1d59429571d8Fde785F45bf593E94F2Da6072Edb;

// ===================== Presale ================================================
uint256 constant PRESALE_LENGTH = 28 days;
uint256 constant COOLDOWN_PERIOD = 48 hours;
uint256 constant LP_POOL_SIZE = 200_000_000_000 ether;

// ===================== Fees ===================================================
uint256 constant DEV_PERCENT = 6;
uint256 constant TREASURY_PERCENT = 4;
uint256 constant BURN_PERCENT = 10;

// ===================== Sell Tax ===============================================
uint256 constant PRESALE_TRANSFER_TAX_PERCENTAGE = 16;
uint256 constant TRANSFER_TAX_PERCENTAGE = 4;
uint256 constant NFT_REDEEM_TAX_PERCENTAGE = 3;

// ===================== Holder Vault ===========================================
uint16 constant MAX_CYCLES_PER_CLAIM = 100;
uint32 constant CYCLE_INTERVAL = 7 days;

// ===================== UNISWAP Interface ======================================

address constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
address constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
address constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
uint24 constant POOL_FEE_1PERCENT = 10000;

// ===================== Interface IDs ==========================================
bytes4 constant INTERFACE_ID_ERC165 = 0x01ffc9a7;
bytes4 constant INTERFACE_ID_ERC20 = type(IERC20).interfaceId;
bytes4 constant INTERFACE_ID_ERC721 = 0x80ac58cd;
bytes4 constant INTERFACE_ID_ERC721Metadata = 0x5b5e139f;
bytes4 constant INTERFACE_ID_ITITANONBURN = type(ITitanOnBurn).interfaceId;