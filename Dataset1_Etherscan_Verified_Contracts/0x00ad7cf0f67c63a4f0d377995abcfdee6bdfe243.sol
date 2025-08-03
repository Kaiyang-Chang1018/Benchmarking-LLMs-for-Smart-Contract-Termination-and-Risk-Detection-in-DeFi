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
// SPDX-License-Identifier: MIT


/**

    ░██████╗███████╗░█████╗░████████╗░░██████╗░░█████╗░████████╗
    ██╔════╝██╔════╝██╔══██╗╚══██╔══╝░░██╔══██╗██╔══██╗╚══██╔══╝
    ╚█████╗░█████╗░░██║░░╚═╝░░░██║░░░░░██████╦╝██║░░██║░░░██║░░░
    ░╚═══██╗██╔══╝░░██║░░██╗░░░██║░░░░░██╔══██╗██║░░██║░░░██║░░░
    ██████╔╝███████╗╚█████╔╝░░░██║░░░░░██████╦╝╚█████╔╝░░░██║░░░
    ╚═════╝░╚══════╝░╚════╝░░░░╚═╝░░░░░╚═════╝░░╚════╝░░░░╚═╝░░░
    ░░░███████╗████████╗░█████╗░██╗░░██╗██╗███╗░░░██╗░██████╗░░░  
    ░░░██╔════╝╚══██╔══╝██╔══██╗██║░██╔╝██║████╗░░██║██╔════╝░░░  
    ░░░███████╗░░░██║░░░███████║█████╔╝░██║██╔██╗░██║██║░░███╗░░ 
    ░░░╚════██║░░░██║░░░██╔══██║██╔═██╗░██║██║╚██╗██║██║░░░██║░░
    ░░░███████║░░░██║░░░██║░░██║██║░░██╗██║██║░╚████║╚██████╔╝░░    
    ░░░╚══════╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚═══╝░╚═════╝░░░

    Official Telegram: https://t.me/SectTokenPortal
    Official Twitter: https://twitter.com/thesectbot
    Official Website: https://sectbot.com
    Official Whitepaper: https://sectbot.gitbook.io/sect-bot-whitepaper/
    
    Add SectBot to your group now: https://t.me/sectleaderboardbot
**/

pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract SectStaking is Ownable, ReentrancyGuard {
    //Fit vars into 2 slots
    struct UserInfo {
        uint128 shares; // shares of token staked
        uint128 userRewardPerTokenPaid; // user reward per token paid
        uint128 rewards; // pending rewards
        uint64 lastLockBlock; // last block when user locked
        uint64 lastLockTimestamp; // last timestamp when user locked. For easier readability
    }
    
    //Fit vars into 1 slot
    struct PackageInfo {
        uint128 totalLockedShares;
        uint64 minLockPeriodInBlocks;
        uint8 id;
        uint8 isActive;
        uint8 multiplier; //
    }

    // Precision factor for calculating rewards and exchange rate
    uint256 public constant PRECISION_FACTOR = 10**18;

    // The staking and reward tokens. Intended to be the same
    IERC20 public immutable sectToken;
    IERC20 public immutable rewardToken;

    //Fit into 3 slots

    // Total rewards deposited. For tracking purposes
    uint256 public totalRewardsForDistribution;

    // Reward rate (block)
    uint128 public currentRewardPerBlock;

    // Last update block for rewards
    uint64 public lastUpdateBlock;
    
    // Current end block for the current reward period
    uint64 public periodEndBlock;

    // Reward per token stored
    uint128 public rewardPerTokenStored;

    // Total existing shares
    uint256 public totalShares;

    // Minimum claim amount
    uint256 public minClaimAmount = 1 ether;

    // Owner
    address internal _owner;

    // Users info mapped for each package
    mapping(address => mapping(uint8 => UserInfo)) internal userInfo;
    // Packages info mapping
    mapping(uint8 => PackageInfo) public packageInfo;
    // Packages ids array
    uint8[] public packageIds;

    event Deposit(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 claimedAmount);
    event Withdraw(address indexed user, uint256 amount, uint256 claimedAmount);
    event NewRewardPeriod(uint256 numberBlocks, uint256 rewardPerBlock, uint256 reward);
    event AddMoreRewards(uint256 reward);
    event CreatePackage(uint8 id, bool _isActive, uint8 multiplier, uint64 minLockPeriodInBlocks);
    event SetPackageIsActive(uint8 packageId, bool isActive);
    event SetMinClaimAmount(uint256 minClaimAmount);

    /**
     * @notice Constructor
     * @param _sectToken address of the token staked (SECT)
     * @param _rewardToken address of the reward token
     */
    constructor(
        address _sectToken,
        address _rewardToken
    ) Ownable(msg.sender) {
        _owner = msg.sender;
        rewardToken = IERC20(_rewardToken);
        sectToken = IERC20(_sectToken);

        uint64 thirtyDaysInBlocks = 30 * 7170; 

        createPackage(10, true, 1, thirtyDaysInBlocks);
        createPackage(20, true, 2, thirtyDaysInBlocks * 2);
        createPackage(30, true, 4, thirtyDaysInBlocks * 4);
    }

    /**
     * @notice modifier
     * @notice Only the SECT token contract can call functions with this modifier
     */
    modifier onlyTokenContract() {
        require(address(sectToken) == msg.sender, "Caller is not SECT Token");
        _;
    }

    /**
     * @notice Create a new package
     * @param _id package id
     * @param _isActive whether the package is active
     * @param _multiplier multiplier for the package
     * @param _minLockPeriodInBlocks minimum lock period in blocks
     */
    function createPackage(uint8 _id, bool _isActive, uint8 _multiplier, uint64 _minLockPeriodInBlocks) public onlyOwner {
        packageInfo[_id] = PackageInfo({
            id: _id,
            isActive: _isActive ? 1 : 0,
            totalLockedShares: 0,
            multiplier: _multiplier,
            minLockPeriodInBlocks: _minLockPeriodInBlocks
        });
        packageIds.push(_id);

        emit CreatePackage(_id, _isActive, _multiplier, _minLockPeriodInBlocks);
    }

    /**
     * @notice Set package as active or inactive
     * @param packageId package id
     * @param isActive whether the package is active
     */
    function setPackageIsActive(uint8 packageId, bool isActive) external onlyOwner {
        packageInfo[packageId].isActive = isActive ? 1 : 0;

        emit SetPackageIsActive(packageId, isActive);
    }

    /**
     * @notice Get user stakes for all packages
     * @param user address of the user
     */
    function getUsersStakes(address user) external view returns (UserInfo[] memory) {
        return _getUsersStakes(user);
    }

    /**
     * @notice Get user stakes for all packages
     * @param user address of the user
     */
    function _getUsersStakes(address user) internal view returns (UserInfo[] memory) {
        UserInfo[] memory userStakes = new UserInfo[](packageIds.length);

        for (uint8 i = 0; i < packageIds.length; i++) {
            userStakes[i] = userInfo[user][packageIds[i]];
            userStakes[i].rewards = uint128(_calculatePendingRewards(user, packageIds[i]));
        }

        return userStakes;
    }

    /**
     * @notice Get user stakes for a specific package
     * @param user address of the user
     * @param packageKey package id
     */
    function getUserStakesForPackage(address user, uint8 packageKey) external view returns (UserInfo memory) {
        UserInfo memory userStake = userInfo[user][packageKey];
        userStake.rewards = uint128(_calculatePendingRewards(user, packageKey));

        return userStake;
    }

    /**
     * @notice Get all packages
     */
    function getPackages() external view returns (PackageInfo[] memory) {
        return _getPackages();
    }

    /**
     * @notice Get all packages
     */
    function _getPackages() internal view returns (PackageInfo[] memory) {
        PackageInfo[] memory packages = new PackageInfo[](packageIds.length);

        for (uint8 i = 0; i < packageIds.length; i++) {
            packages[i] = packageInfo[packageIds[i]];
        }

        return packages;
    }

    /**
     * @notice Get a specific package
     * @param packageKey package id
     */
    function getPackage(uint8 packageKey) external view returns (PackageInfo memory) {
        return packageInfo[packageKey];
    }

    /**
     * @notice make a staking deposit
     * @param amount amount to deposit
     * @param packageId package id
     * @dev Non-reentrant
     */
    function deposit(uint256 amount, uint8 packageId) external nonReentrant() {
        require(amount >= PRECISION_FACTOR, "Deposit: Amount must be >= 1 SECT");
        require(packageInfo[packageId].id != 0, "Deposit: Package does not exist");
        require(userInfo[msg.sender][packageId].shares == 0, "Deposit: User already has locked in this package");
        require(packageInfo[packageId].isActive == 1, "Deposit: Package is not active");

        // Update reward for user
        _updateReward(msg.sender);

        // Transfer SECT tokens to this address
        sectToken.transferFrom(msg.sender, address(this), amount);

        uint256 currentShares;

        // Calculate the number of shares to issue for the user
        if (totalShares != 0) {
            currentShares = (amount * totalShares) / totalShares;
            // This is a sanity check to prevent deposit for 0 shares
            require(currentShares != 0, "Deposit: Fail");
        } else {
            currentShares = amount;
        }

        currentShares *= packageInfo[packageId].multiplier;

        // Adjust internal shares
        userInfo[msg.sender][packageId].shares += uint128(currentShares);
        userInfo[msg.sender][packageId].lastLockBlock = uint64(block.number);
        userInfo[msg.sender][packageId].lastLockTimestamp = uint64(block.timestamp);
        packageInfo[packageId].totalLockedShares += uint128(currentShares);
        totalShares += currentShares;

        emit Deposit(msg.sender, amount);
    }

    /**
     * @notice Withdraw staked tokens (and collect reward tokens if requested)
     * @param shares shares to withdraw
     * @param claimRewardToken whether to claim reward tokens
     */
    function withdraw(uint256 shares, uint8 packageId, bool claimRewardToken) external {
        require(
            (shares > 0) && (shares <= userInfo[msg.sender][packageId].shares),
            "Withdraw: Shares equal to 0 or larger than user shares"
        );

        _withdraw(shares, packageId, claimRewardToken);
    }

    /**
     * @notice Withdraw all staked tokens (and collect reward tokens if requested)
     * @param claimRewardToken whether to claim reward tokens
     */
    function withdrawAll(uint8 packageId, bool claimRewardToken) external {
        _withdraw(userInfo[msg.sender][packageId].shares, packageId, claimRewardToken);
    }

    /**
     * @notice Update reward for a user account
     * @param _user address of the user
     */
    function _updateReward(address _user) internal {
        if (block.number != lastUpdateBlock) {
            rewardPerTokenStored = uint128(_rewardPerToken());
            lastUpdateBlock = uint64(_lastRewardBlock());
        }

        for (uint8 i = 0; i < packageIds.length; i++) {
            userInfo[_user][packageIds[i]].rewards = uint128(_calculatePendingRewards(_user, packageIds[i]));
            userInfo[_user][packageIds[i]].userRewardPerTokenPaid = uint128(rewardPerTokenStored);
        }
    }
     /**
     * @notice Calculate pending rewards (WETH) for a user
     * @param user address of the user
     */
    function calculatePendingRewards(address user, uint8 packageId) external view returns (uint256) {
        return _calculatePendingRewards(user, packageId);
    }

    /**
     * @notice Calculate pending rewards for a user
     * @param user address of the user
     */
    function _calculatePendingRewards(address user, uint8 packageId) internal view returns (uint256) {
        return
            ((userInfo[user][packageId].shares * (_rewardPerToken() - (userInfo[user][packageId].userRewardPerTokenPaid))) /
                PRECISION_FACTOR) + userInfo[user][packageId].rewards;
    }

    /**
     * @notice Return last block where rewards must be distributed
     */
    function _lastRewardBlock() internal view returns (uint256) {
        return block.number < periodEndBlock ? block.number : periodEndBlock;
    }

    /**
     * @notice Return reward per token extrenal
     */
    function rewardPerToken() external view returns (uint256) {
        return _rewardPerToken();
    }

    /**
     * @notice Return reward per token
     */
    function _rewardPerToken() internal view returns (uint256) {
        if (totalShares == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            ((_lastRewardBlock() - lastUpdateBlock) * (currentRewardPerBlock * PRECISION_FACTOR)) /
            totalShares;
    }

    /**
     * @notice Withdraw staked tokens (and collect reward tokens if requested)
     * @param shares shares to withdraw
     * @param claimRewardToken whether to claim reward tokens
     */
    function _withdraw(uint256 shares, uint8 packageId, bool claimRewardToken) internal nonReentrant() {
        require(
            (block.number - userInfo[msg.sender][packageId].lastLockBlock) >= packageInfo[packageId].minLockPeriodInBlocks,
            "Withdraw: Minimum lock period not reached"
        );
        // Update reward for user
        _updateReward(msg.sender);

        userInfo[msg.sender][packageId].shares -= uint128(shares);
        packageInfo[packageId].totalLockedShares -= uint128(shares);
        totalShares -= shares;

        uint256 pendingRewards;

        if (claimRewardToken) {
            // Fetch pending rewards
            pendingRewards = userInfo[msg.sender][packageId].rewards;

            if (pendingRewards > 0) {
                userInfo[msg.sender][packageId].rewards = 0;
                rewardToken.transfer(msg.sender, pendingRewards);
            }
        }

        uint256 sharesToAmount = shares / packageInfo[packageId].multiplier;

        // Transfer SECT tokens to sender
        sectToken.transfer(msg.sender, sharesToAmount);

        emit Withdraw(msg.sender, sharesToAmount, pendingRewards);
    }

    /**
     * @notice Claim rewards
     * @param packageId package id
     * @dev Non-reentrant
     */
    function claim(uint8 packageId) external nonReentrant() returns(uint claimed){
        // Update reward for user
        _updateReward(msg.sender);
        require(userInfo[msg.sender][packageId].rewards >= minClaimAmount, "Claim: Insufficient rewards");

        uint256 pendingRewards = userInfo[msg.sender][packageId].rewards;

        if (pendingRewards > 0) {
            userInfo[msg.sender][packageId].rewards = 0;
            rewardToken.transfer(msg.sender, pendingRewards);
            claimed = pendingRewards;
        }

        emit Claim(msg.sender, pendingRewards);
    }

    /**
     * @notice Update the reward per block (in rewardToken)
     * @dev Only callable by owner.
     */
    function updateRewards(uint256 reward, uint256 rewardDurationInBlocks) external onlyOwner {
        require(rewardDurationInBlocks > 0, "Deposit: Reward duration must be > 0");

        // Adjust the current reward per block
        if (block.number >= periodEndBlock) {            
            currentRewardPerBlock = uint128(reward / rewardDurationInBlocks);
        } else {
            currentRewardPerBlock = uint128(
                (reward + ((periodEndBlock - block.number) * currentRewardPerBlock)) /
                rewardDurationInBlocks);
        }

        require(currentRewardPerBlock > 0, "Deposit: Reward per block must be > 0");

        lastUpdateBlock = uint64(block.number);
        periodEndBlock = uint64(block.number + rewardDurationInBlocks);
        totalRewardsForDistribution = reward;

        emit NewRewardPeriod(rewardDurationInBlocks, currentRewardPerBlock, reward);
    }

    /**
     * @notice Add more rewards to the pool
     * @param reward amount of reward tokens to add
     * @dev Only callable by owner.
     */
    function addRewards(uint256 reward) external onlyOwner nonReentrant(){
        require(periodEndBlock > block.number, "Deposit: Reward period ended");
        require(reward > (periodEndBlock - block.number), "Deposit: Reward must be > 0");
        rewardToken.transferFrom(msg.sender, address(this), reward);

        if (block.number != lastUpdateBlock) {
            rewardPerTokenStored = uint128(_rewardPerToken());
            lastUpdateBlock = uint64(_lastRewardBlock());
        }

        unchecked {
            totalRewardsForDistribution += reward;
            currentRewardPerBlock += uint128(reward / (periodEndBlock - block.number));
        }
        emit AddMoreRewards(reward);
    }

    /**
     * @notice Deposit rewards
     * @param reward amount of reward tokens to deposit
     * @dev Only callable by the SECT token contract.
     */
    function depositRewards(uint256 reward) external onlyTokenContract {
        require(periodEndBlock > block.number, "Deposit: Reward period ended");
        require(reward > (periodEndBlock - block.number), "Deposit: Reward must be > 0");

        if (block.number != lastUpdateBlock) {
            rewardPerTokenStored = uint128(_rewardPerToken());
            lastUpdateBlock = uint64(_lastRewardBlock());
        }

        unchecked {
            totalRewardsForDistribution += reward;
            currentRewardPerBlock += uint128(reward / (periodEndBlock - block.number));
        }
        emit AddMoreRewards(reward);
    }

    /**
     * @notice Set the minimum claim amount
     * @param _minClaimAmount minimum claim amount
     * @dev Only callable by owner.
     */
    function setMinClaimAmount(uint256 _minClaimAmount) external onlyOwner {
        require(_minClaimAmount < 100 ether, "setMinClaimAmount: Min claim amount must be < 100 SECT");
        minClaimAmount = _minClaimAmount;

        emit SetMinClaimAmount(_minClaimAmount);
    }

    /**
     * @notice Get total rewards for distribution to this block
     */
    function getTotalRewardsForDistributionToThisBlock() external view returns(uint256){
        return _getTotalRewardsForDistributionToThisBlock();
    }

    /**
     * @notice Get total rewards for distribution to this block
     */
    function _getTotalRewardsForDistributionToThisBlock() internal view returns(uint256){
        return totalRewardsForDistribution - (currentRewardPerBlock * (periodEndBlock - block.number));
    }

    /**
     * @notice Get full info for a user and packages. Useful for frontend visualization
     * @param user address of the user
     */
    function getFullInfoForUser(address user) external view returns (UserInfo[] memory, PackageInfo[] memory, uint256, uint256) {
        return (_getUsersStakes(user), _getPackages(), _getTotalRewardsForDistributionToThisBlock(), _rewardPerToken());
    }

    /**
     * @notice Get full contract info. Useful for frontend visualization
     */
    function getFullContractInfo() external view returns (PackageInfo[] memory, uint256, uint256) {
        return (_getPackages(), _getTotalRewardsForDistributionToThisBlock(), _rewardPerToken());
    }
}