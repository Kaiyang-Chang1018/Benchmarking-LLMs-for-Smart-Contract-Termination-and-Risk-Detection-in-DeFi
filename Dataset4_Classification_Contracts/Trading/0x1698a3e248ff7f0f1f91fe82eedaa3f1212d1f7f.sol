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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./interfaces/IERC20Burnable.sol";
import "./interfaces/IWETH9.sol";
import "./lib/constants.sol";

/// @title Stax Buy & Burn Contract
contract StaxBuyBurn is Ownable2Step {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Burnable;

    // -------------------------- STATE VARIABLES -------------------------- //

    address immutable STAX;

    /// @notice Incentive fee amount, measured in basis points (100 bps = 1%).
    uint16 public incentiveFeeBps = 30;
    /// @notice The maximum amount of ELMNT that can be swapped per Buy & Burn.
    uint256 public capPerSwapE280;
    /// @notice The maximum amount of X28/E280 that can be swapped per Buy & Burn.
    uint256 public capPerSwapX28 = 3_000_000_000 ether;
    /// @notice The minimum amount of X28 tokens to trigger X28/ELMNT swap.
    uint256 public minSwapAmountX28 = 1_000_000_000 ether;
    /// @notice Cooldown for Buy & Burns in seconds.
    uint32 public buyBurnInterval = 1 hours;
    /// @notice Time of the last Buy & Burn in seconds.
    uint256 public lastBuyBurn;

    /// @notice Whitelisted addresses to run Buy & Burn.
    mapping(address account => bool) public whitelisted;

    // ------------------------------- EVENTS ------------------------------ //

    event BuyBurn();

    // ------------------------------- ERRORS ------------------------------ //

    error Prohibited();
    error Cooldown();
    error ZeroAddress();
    error NoAllocation();

    // ----------------------------- CONSTRUCTOR --------------------------- //

    constructor(address _owner, address _stax) Ownable(_owner) {
        if (_stax == address(0)) revert ZeroAddress();
        STAX = _stax;
    }

    // --------------------------- PUBLIC FUNCTIONS ------------------------ //

    /// @notice Buys and burns the Stax tokens using ELMNT and X28 balance.
    /// @param minStaxAmount The minimum amount out for ELMNT -> Stax swap.
    /// @param minE280Amount The minimum amount out for the X28 -> ELMNT swap (if applicalbe).
    /// @param deadline The deadline for the swaps.
    function buyAndBurn(uint256 minStaxAmount, uint256 minE280Amount, uint256 deadline) external {
        if (!whitelisted[msg.sender]) revert Prohibited();
        if (block.timestamp < lastBuyBurn + buyBurnInterval) revert Cooldown();

        lastBuyBurn = block.timestamp;
        uint256 e280Balance = IERC20(E280).balanceOf(address(this));
        bool additionalSwap;
        if (e280Balance < capPerSwapE280) {
            uint256 e280BalanceAfterSwap = _handleX28BalanceCheck(e280Balance, minE280Amount, deadline);
            additionalSwap = e280BalanceAfterSwap > e280Balance;
            e280Balance = e280BalanceAfterSwap;
        }
        if (e280Balance == 0) revert NoAllocation();
        uint256 amountToSwap = e280Balance > capPerSwapE280 ? capPerSwapE280 : e280Balance;
        amountToSwap = _processIncentiveFee(amountToSwap, additionalSwap);
        _swapE280toStax(amountToSwap, minStaxAmount, deadline);
        _handleStaxBurn();
        emit BuyBurn();
    }

    // ----------------------- ADMINISTRATIVE FUNCTIONS -------------------- //

    /// @notice Sets the incentive fee basis points (bps) for Buy & Burns.
    /// @param bps The incentive fee in basis points (0 - 1000), (100 bps = 1%).
    function setIncentiveFee(uint16 bps) external onlyOwner {
        if (bps > 1000) revert Prohibited();
        incentiveFeeBps = bps;
    }

    /// @notice Sets the Buy & Burn interval.
    /// @param limit The new interval in seconds.
    function setBuyBurnInterval(uint32 limit) external onlyOwner {
        if (limit == 0) revert Prohibited();
        buyBurnInterval = limit;
    }

    /// @notice Sets the cap per swap for ELMNT -> Stax swaps.
    /// @param limit The new cap limit in WEI applied to ELMNT balance.
    function setCapPerSwapE280(uint256 limit) external onlyOwner {
        capPerSwapE280 = limit;
    }

    /// @notice Sets the cap per swap for X28 -> ELMNT swaps.
    /// @param limit The new cap limit in WEI applied to X28 balance.
    function setCapPerSwapX28(uint256 limit) external onlyOwner {
        capPerSwapX28 = limit;
    }

    /// @notice Sets the new minimum threshold for triggering the X28/ELMNT swap.
    /// @param limit The new threshold in WEI applied to X28 balance.
    function setMinSwapAmountX28(uint256 limit) external onlyOwner {
        minSwapAmountX28 = limit;
    }

    /// @notice Sets the whitelist status for provided addresses for Buy & Burn.
    /// @param accounts List of wallets which status will be changed.
    /// @param isWhitelisted Status to be set.
    function setWhitelisted(address[] calldata accounts, bool isWhitelisted) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            whitelisted[accounts[i]] = isWhitelisted;
        }
    }

    // ---------------------------- VIEW FUNCTIONS ------------------------- //

    /// @notice Get the Buy & Burn information for the next call.
    /// @return isX28SwapPossible Will the X28 swap be performed on the next call.
    /// @return nextE280Swap Amount of E280 used in the next call.
    /// @return nextX28Swap Amount of X28 used in the next call.
    /// @return nextBuyBurn Time when next Buy & Burn will be available (in seconds).
    function getBuyBurnParams()
        public
        view
        returns (bool isX28SwapPossible, uint256 nextE280Swap, uint256 nextX28Swap, uint256 nextBuyBurn)
    {
        uint256 e280Balance = IERC20(E280).balanceOf(address(this));
        uint256 x28Balance = IERC20(X28).balanceOf(address(this));
        isX28SwapPossible = e280Balance < capPerSwapE280 && x28Balance > minSwapAmountX28;
        nextE280Swap = e280Balance > capPerSwapE280 ? capPerSwapE280 : e280Balance;
        if (isX28SwapPossible) nextX28Swap = x28Balance > capPerSwapX28 ? capPerSwapX28 : x28Balance;
        nextBuyBurn = lastBuyBurn + buyBurnInterval;
    }

    // -------------------------- INTERNAL FUNCTIONS ----------------------- //

    function _handleX28BalanceCheck(uint256 currentE280Balance, uint256 minE280Amount, uint256 deadline)
        internal
        returns (uint256)
    {
        uint256 x28Balance = IERC20(X28).balanceOf(address(this));
        if (x28Balance < minSwapAmountX28) return currentE280Balance;
        uint256 amountToSwap = x28Balance > capPerSwapX28 ? capPerSwapX28 : x28Balance;
        uint256 swappedAmount = _swapX28toE280(amountToSwap, minE280Amount, deadline);
        return currentE280Balance + swappedAmount;
    }

    function _processIncentiveFee(uint256 e280Amount, bool additionalSwap) internal returns (uint256) {
        uint16 _incentiveFeeBps = additionalSwap ? (incentiveFeeBps * 150) / 100 : incentiveFeeBps;
        uint256 incentiveFee = e280Amount * _incentiveFeeBps / BPS_BASE;
        IERC20(E280).safeTransfer(msg.sender, incentiveFee);
        unchecked {
            return e280Amount - incentiveFee;
        }
    }

    function _handleStaxBurn() internal {
        IERC20Burnable stax = IERC20Burnable(STAX);
        uint256 amountToBurn = stax.balanceOf(address(this));
        stax.burn(amountToBurn);
    }

    function _swapE280toStax(uint256 amountIn, uint256 minAmountOut, uint256 deadline) internal {
        if (minAmountOut == 0) revert Prohibited();
        IERC20(E280).safeIncreaseAllowance(UNISWAP_V2_ROUTER, amountIn);

        address[] memory path = new address[](2);
        path[0] = E280;
        path[1] = STAX;

        IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            amountIn, minAmountOut, path, address(this), deadline
        );
    }

    function _swapX28toE280(uint256 amountIn, uint256 minAmountOut, uint256 deadline) private returns (uint256) {
        if (minAmountOut == 0) revert Prohibited();
        IERC20(X28).safeIncreaseAllowance(UNISWAP_V2_ROUTER, amountIn);

        address[] memory path = new address[](2);
        path[0] = X28;
        path[1] = E280;

        uint256[] memory amounts = IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            amountIn, minAmountOut, path, address(this), deadline
        );

        return amounts[1];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IERC20Burnable is IERC20 {
    function burn(uint256 value) external;
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "../interfaces/ITitanOnBurn.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

// ===================== Contract Addresses =====================================

address constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant TITANX = 0xF19308F923582A6f7c465e5CE7a9Dc1BEC6665B1;
address constant X28 = 0x5c47902c8C80779CB99235E42C354E53F38C3B0d;
address constant HYPER = 0xE2cfD7a01ec63875cd9Da6C7c1B7025166c2fA2F;
address constant HELIOS = 0x2614f29C39dE46468A921Fd0b41fdd99A01f2EDf;
address constant BLAZE = 0xfcd7cceE4071aA4ecFAC1683b7CC0aFeCAF42A36;
address constant FLUX = 0xBFDE5ac4f5Adb419A931a5bF64B0f3BB5a623d06;
address constant E280 = 0xe9A53C43a0B58706e67341C4055de861e29Ee943;

address constant BLAZE_STAKING = 0xBc0043bc5b0c394D9d05d49768f9548F8CF9587b;
address constant FLUX_STAKING = 0xd605a87187563C94c577a6E57e4a36eC8433B9aE;

address constant TITANX_WETH_POOL = 0xc45A81BC23A64eA556ab4CdF08A86B61cdcEEA8b;
address constant TITANX_X28_POOL = 0x99f60479da6A49D55eBA34893958cdAACc710eE9;
address constant TITANX_HYPER_POOL = 0x14d725edB1299fF560d96f42462f0234B65B00AF;
address constant TITANX_HELIOS_POOL = 0x2C83C54C5612BfD62a78124D4A0eA001278a689c;
address constant INFERNO = 0x00F116ac0c304C570daAA68FA6c30a86A04B5C5F;
address constant TITANX_INFERNO_POOL = 0x1E90B67149e688DfB95fD73Acacd8ADefd16d88D;
address constant INFERNO_FLUX_POOL = 0x09848D115e085942E6fa9D85b6B6C73fb0E63CB1;


// ===================== MINT ===================================================

uint256 constant PRESALE_LENGTH = 28 days;
uint256 constant COOLDOWN_PERIOD = 48 hours;
uint256 constant LP_POOL_SIZE = 200_000_000_000 ether;

uint8 constant PERCENTAGE_BASE = 100;
uint16 constant BPS_BASE = 100_00;

uint256 constant COMMON_BASE_PRICE = 100_000_000 ether;
uint256 constant RARE_BASE_PRICE = 1_000_000_000 ether;
uint256 constant LEGENDARY_BASE_PRICE = 10_000_000_000 ether;

uint16 constant COMMON_BASE_MULTIPLIER = 10;
uint16 constant RARE_BASE_MULTIPLIER = 100;
uint16 constant LEGENDARY_BASE_MULTIPLIER = 1000;

// ===================== NFT ===================================================

uint8 constant NFT_CLAIM_COOLDOWN = 2;
uint256 constant BITPOS_NFT_TIER = 0;
uint256 constant BITMASK_NFT_TIER = (1 << 8) - 1;

uint256 constant BITPOS_MULTIPLIER = 8;
uint256 constant BITMASK_MULTIPLIER = (1 << 16) - 1;

uint256 constant BITPOS_MINT_CYCLE = 24;
uint256 constant BITMASK_MINT_CYCLE = (1 << 32) - 1;

uint256 constant BITPOS_BURN_CYCLE = 56;
uint256 constant BITMASK_BURN_CYCLE = (1 << 32) - 1;

uint256 constant BITPOS_BURN_ADDRESS = 88;
uint256 constant BITMASK_BURN_ADDRESS = (1 << 160) - 1;

// ===================== VAULT ==================================================

uint256 constant CYCLE_COOLDOWN = 9 days;

uint16 constant BANK_ALLOCATION_BPS = 80_00;
uint64 constant GENESIS_BASE_BPS = 8_00 * uint64(BPS_BASE);
uint64 constant HOLDER_BASE_BPS = 10_00 * uint64(BPS_BASE);
uint64 constant DIANOND_BASE_BPS = 2_00 * uint64(BPS_BASE);
uint16 constant DIAMOND_HAND_PAYOUT_BPS = 8_00;
uint16 constant CYCLE_COMPOUND_REDUCTION = 2_00;

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