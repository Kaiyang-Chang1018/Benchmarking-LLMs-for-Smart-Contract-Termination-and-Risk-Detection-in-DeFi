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
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

interface IInterchainSecurityModule {
    enum Types {
        UNUSED,
        ROUTING,
        AGGREGATION,
        LEGACY_MULTISIG,
        MERKLE_ROOT_MULTISIG,
        MESSAGE_ID_MULTISIG,
        NULL, // used with relayer carrying no metadata
        CCIP_READ,
        ARB_L2_TO_L1,
        WEIGHT_MERKLE_ROOT_MULTISIG,
        WEIGHT_MESSAGE_ID_MULTISIG,
        OP_L2_TO_L1
    }

    /**
     * @notice Returns an enum that represents the type of security model
     * encoded by this ISM.
     * @dev Relayers infer how to fetch and format metadata.
     */
    function moduleType() external view returns (uint8);

    /**
     * @notice Defines a security model responsible for verifying interchain
     * messages based on the provided metadata.
     * @param _metadata Off-chain metadata provided by a relayer, specific to
     * the security model encoded by the module (e.g. validator signatures)
     * @param _message Hyperlane encoded interchain message
     * @return True if the message was verified
     */
    function verify(
        bytes calldata _metadata,
        bytes calldata _message
    ) external returns (bool);
}

interface ISpecifiesInterchainSecurityModule {
    function interchainSecurityModule()
        external
        view
        returns (IInterchainSecurityModule);
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

import {IInterchainSecurityModule} from "./IInterchainSecurityModule.sol";
import {IPostDispatchHook} from "./hooks/IPostDispatchHook.sol";

interface IMailbox {
    // ============ Events ============
    /**
     * @notice Emitted when a new message is dispatched via Hyperlane
     * @param sender The address that dispatched the message
     * @param destination The destination domain of the message
     * @param recipient The message recipient address on `destination`
     * @param message Raw bytes of message
     */
    event Dispatch(
        address indexed sender,
        uint32 indexed destination,
        bytes32 indexed recipient,
        bytes message
    );

    /**
     * @notice Emitted when a new message is dispatched via Hyperlane
     * @param messageId The unique message identifier
     */
    event DispatchId(bytes32 indexed messageId);

    /**
     * @notice Emitted when a Hyperlane message is processed
     * @param messageId The unique message identifier
     */
    event ProcessId(bytes32 indexed messageId);

    /**
     * @notice Emitted when a Hyperlane message is delivered
     * @param origin The origin domain of the message
     * @param sender The message sender address on `origin`
     * @param recipient The address that handled the message
     */
    event Process(
        uint32 indexed origin,
        bytes32 indexed sender,
        address indexed recipient
    );

    function localDomain() external view returns (uint32);

    function delivered(bytes32 messageId) external view returns (bool);

    function defaultIsm() external view returns (IInterchainSecurityModule);

    function defaultHook() external view returns (IPostDispatchHook);

    function requiredHook() external view returns (IPostDispatchHook);

    function latestDispatchedId() external view returns (bytes32);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    ) external payable returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    ) external view returns (uint256 fee);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata body,
        bytes calldata defaultHookMetadata
    ) external payable returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody,
        bytes calldata defaultHookMetadata
    ) external view returns (uint256 fee);

    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata body,
        bytes calldata customHookMetadata,
        IPostDispatchHook customHook
    ) external payable returns (bytes32 messageId);

    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody,
        bytes calldata customHookMetadata,
        IPostDispatchHook customHook
    ) external view returns (uint256 fee);

    function process(
        bytes calldata metadata,
        bytes calldata message
    ) external payable;

    function recipientIsm(
        address recipient
    ) external view returns (IInterchainSecurityModule module);
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

/*@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
     @@@@@  HYPERLANE  @@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@
   @@@@@@@@@       @@@@@@@@@
  @@@@@@@@@       @@@@@@@@@
 @@@@@@@@@       @@@@@@@@@
@@@@@@@@@       @@@@@@@@*/

interface IPostDispatchHook {
    enum Types {
        UNUSED,
        ROUTING,
        AGGREGATION,
        MERKLE_TREE,
        INTERCHAIN_GAS_PAYMASTER,
        FALLBACK_ROUTING,
        ID_AUTH_ISM,
        PAUSABLE,
        PROTOCOL_FEE,
        LAYER_ZERO_V1,
        RATE_LIMITED,
        ARB_L2_TO_L1,
        OP_L2_TO_L1
    }

    /**
     * @notice Returns an enum that represents the type of hook
     */
    function hookType() external view returns (uint8);

    /**
     * @notice Returns whether the hook supports metadata
     * @param metadata metadata
     * @return Whether the hook supports metadata
     */
    function supportsMetadata(
        bytes calldata metadata
    ) external view returns (bool);

    /**
     * @notice Post action after a message is dispatched via the Mailbox
     * @param metadata The metadata required for the hook
     * @param message The message passed from the Mailbox.dispatch() call
     */
    function postDispatch(
        bytes calldata metadata,
        bytes calldata message
    ) external payable;

    /**
     * @notice Compute the payment required by the postDispatch call
     * @param metadata The metadata required for the hook
     * @param message The message passed from the Mailbox.dispatch() call
     * @return Quoted payment for the postDispatch call
     */
    function quoteDispatch(
        bytes calldata metadata,
        bytes calldata message
    ) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract AddressConversion {
    /**
     * @notice Cast an address to a bytes32
     * @param _addr The address to cast
     * @dev Alignment presevering cast
     */
    function _toBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    /**
     * @notice Cast a bytes32 to an address
     * @param _buf The bytes32 to cast
     * @dev Alignment presevering cast
     */
    function _toAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IXERC20} from "../interfaces/IXERC20.sol";
import {IXERC20Lockbox} from "../interfaces/IXERC20Lockbox.sol";
import {IBridge} from "../interfaces/IBridge.sol";
import {IGateway} from "../interfaces/IGateway.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AddressConversion} from "./AddressConversion.sol";

abstract contract Bridge is Ownable2Step, AddressConversion, IBridge {
    using SafeERC20 for IERC20;

    /// @notice Chain id for Everclear roll-up
    uint32 public immutable EVERCLEAR_ID;

    /// @notice The origin ERC20 token on current chain if applicable (can be null)
    IERC20 public immutable CLEAR;

    /// @notice xCLEAR address on the current chain
    IXERC20 public immutable xCLEAR;

    /// @notice Lockbox address on the current chain (can be null)
    IXERC20Lockbox public immutable LOCKBOX;

    /// @notice Gateway address on the current chain
    IGateway public gateway;

    /// @notice Nonce used for errors
    uint128 internal nonce;

    /// @notice Error struct used for Bridge retries in abstract contract
    mapping(uint256 => Error) public errors;

    /// @notice Message gas limit stored by domain
    mapping(uint256 => uint256) public messageGasLimit;

    /// @notice Limits the caller to the gateway contract
    modifier onlyGateway() {
        if (msg.sender != address(gateway)) revert NotCalledByGateway();
        _;
    }

    constructor(
        uint32 _everclearId,
        address _gateway,
        address _xCLEAR,
        address _CLEAR,
        address _LOCKBOX,
        address _owner
    ) Ownable(_owner) {
        if (_xCLEAR == address(0)) revert ZeroAddress();

        EVERCLEAR_ID = _everclearId;
        gateway = IGateway(_gateway);
        xCLEAR = IXERC20(_xCLEAR);
        CLEAR = IERC20(_CLEAR);
        LOCKBOX = IXERC20Lockbox(_LOCKBOX);
    }
    /////////////////////////////// Admin Functions ////////////////////////////////
    /**
     * @notice Update the gateway address
     * @param _newGateway The new gateway address
     */

    function updateGateway(address _newGateway) external onlyOwner {
        address _oldGateway = address(gateway);
        gateway = IGateway(_newGateway);

        emit GatewayUpdated(_oldGateway, _newGateway);
    }

    /**
     * @notice Update the message gas limit for array of domains
     * @param _domain array of domains
     * @param _newGasLimit array of gas limits for each domain
     */
    function updateMessageGasLimit(uint256[] calldata _domain, uint256[] calldata _newGasLimit) external onlyOwner {
        if (_domain.length != _newGasLimit.length) revert InvalidInput();
        uint256[] memory _oldGasLimit = new uint256[](_domain.length);

        for (uint256 i; i < _domain.length; i++) {
            _oldGasLimit[i] = messageGasLimit[_domain[i]];
            messageGasLimit[_domain[i]] = _newGasLimit[i];
        }

        emit MessageGasLimitUpdated(_domain, _oldGasLimit, _newGasLimit);
    }

    /**
     * @notice Withdraw ETH from the contract to recipient
     * @dev Expect ETH to be in contract from users overpaying for the message and Gateway refund
     * @param _receiver The receiver address
     */
    function withdrawETH(address _receiver) external onlyOwner {
        (bool success,) = payable(_receiver).call{value: address(this).balance}("");
        if (!success) revert TransferFailed();
        emit WithdrawETH(_receiver, address(this).balance);
    }

    /////////////////////////////// Public Functions ////////////////////////////////
    /**
     * @notice Retry minting the xCLEAR token
     * @param _errorId The error id to retry
     */
    function retryMint(uint256 _errorId) external virtual {
        Error memory _error = errors[_errorId];
        delete errors[_errorId];

        if (_error.user == address(0)) revert NoErrorFound();

        emit RetryMint(_errorId, block.chainid, _error.user, _error.amount);
        _bridgeIn(_error.user, _error.amount);
    }

    /////////////////////////////// Internal Functions ////////////////////////////////
    /**
     * @notice Burn xCLEAR tokens
     * @param _user The user to burn tokens from
     * @param _amount The amount of tokens to burn
     */
    function _bridgeOut(address _user, uint256 _amount) internal virtual {
        // Lock CLEAR in lockbox and burn minted tokens.
        if (address(LOCKBOX) != address(0)) {
            CLEAR.safeTransferFrom(_user, address(this), _amount);
            CLEAR.approve(address(LOCKBOX), _amount);
            LOCKBOX.deposit(_amount);
            xCLEAR.burn(address(this), _amount);
        } else {
            xCLEAR.burn(_user, _amount);
        }
    }

    /**
     * @notice Mint xCLEAR tokens
     * @param _user The user to mint tokens to
     * @param _amount The amount of tokens to mint
     */
    function _bridgeIn(address _user, uint256 _amount) internal virtual {
        try xCLEAR.mint(address(this), _amount) {
            if (address(LOCKBOX) != address(0)) {
                LOCKBOX.withdraw(_amount);
                CLEAR.safeTransfer(_user, _amount);
            } else {
                IERC20(address(xCLEAR)).safeTransfer(_user, _amount);
            }
            emit BridgedIn(EVERCLEAR_ID, _user, _amount);
        } catch {
            uint256 _nonce = nonce;
            errors[_nonce] = Error(EVERCLEAR_ID, _user, _amount);
            nonce++;
            emit BridgeInError(_nonce, _user, _amount, block.timestamp);
        }
    }

    /**
     * @notice Received used when gateway sends refund back to this contract
     */
    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ITimeKeeper} from "../interfaces/ITimeKeeper.sol";

abstract contract TimeKeeper is ITimeKeeper {
    uint128 public constant WEEK = 7 days;
    uint128 public constant MAX_LOCK_TIME = 730 days;
    uint128 public constant MIN_LOCK_TIME = 90 days;

    /**
     * @notice Checks if a timestamp is currently expired (less than or equal to the current block timestamp)
     * @param expiry The timestamp to check
     */
    function _isCurrentlyExpired(uint256 expiry) internal view returns (bool) {
        return (expiry <= block.timestamp);
    }

    /**
     * @notice Checks if a provided time equals 0 when modulo used with WEEK i.e. timestamp aligns with start of week
     * @param time The timestamp to check
     */
    function _isValidWeekTime(uint256 time) internal pure returns (bool) {
        return time % WEEK == 0;
    }

    /**
     * @notice Checks if a provided timestamp is in the past
     * @param timestamp The timestamp to check
     */
    function _isTimeInThePast(uint256 timestamp) internal view returns (bool) {
        return (timestamp <= block.timestamp); // same definition as isCurrentlyExpired
    }

    /**
     * @notice Returns the current week start timestamp
     */
    function _getCurrentWeekStart() internal view returns (uint128) {
        return _getWeekStartTimestamp(uint128(block.timestamp));
    }

    /**
     * @notice Returns the week start timestamp for a given timestamp
     * @param timestamp The timestamp to check
     */
    function _getWeekStartTimestamp(uint128 timestamp) internal pure returns (uint128) {
        return (timestamp / WEEK) * WEEK;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IBridge {
    struct Error {
        uint256 chainId;
        address user;
        uint256 amount;
    }

    struct Claim {
        address token;
        bytes32 account;
        uint256 amount;
        bytes32[] merkleProof;
    }

    // Events
    event BridgedOut(uint256 dstChainId, address bridgeUser, address tokenReceiver, uint256 amount);
    event BridgedIn(uint256 srcChainId, bytes32 tokenReceiver, uint256 amount);
    event BridgedIn(uint256 srcChainId, address tokenReceiver, uint256 amount);
    event BridgeInError(uint256 errorId, address user, uint256 amount, uint256 timestamp);
    event BridgedLock(uint256 chainId, bytes32 receiver, uint128 amount, uint128 expiry);
    event BridgedLockError(uint256 errorId, address receiver, uint256 amount, uint256 expiry);
    event MessageGasLimitUpdated(uint256[] _domain, uint256[] oldGasLimit, uint256[] newGasLimit);
    event GatewayUpdated(address oldGateway, address newGateway);
    event RetryTransfer(uint256 errorId, uint256 chainId, bytes32 user, uint256 amount);
    event RetryMint(uint256 errorId, uint256 chainId, bytes32 user, uint256 amount);
    event RetryMint(uint256 errorId, uint256 chainId, address user, uint256 amount);
    event RetryLock(uint256 errorId, bytes32 receiver, uint256 amount, uint256 expiry);
    event RetryBridgeOut(uint256 errorId, bytes32 user, uint128 amount, uint32 domain);
    event RetryMessage(uint256 errorId, bytes32 user, uint128 amount, uint32 domain);
    event MintMessageSent(bytes32 sender, uint256 amount, uint32 domain, bytes32 messageId, uint256 feeSpent);
    event WithdrawETH(address receiver, uint256 amount);
    event ReturnFeeUpdated(uint256[] domain, uint256[] oldFee, uint256[] newFee);
    event ProcessError(uint256 nonce, uint8 id, bytes32 sender, uint256 amount, uint256 additionalData);
    event EthWithdrawn(address sender, uint256 amount, uint256 withdrawId);

    // Errors
    error ZeroAddress();
    error InvalidSender();
    error InvalidOriginDomain();
    error InvalidInput();
    error InvalidToken();
    error NoErrorFound();
    error NotCalledByMailbox();
    error NotCalledByGateway();
    error UnsupportedOperation();
    error NothingClaimed();
    error InvalidErrorId();
    error InvalidClaimLength();
    error TransferFailed();
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IMessageReceiver} from "./IMessageReceiver.sol";
import {IMailbox} from "@hyperlane/interfaces/IMailbox.sol";

interface IGateway {
    /*///////////////////////////////////////////////////////////////
                              EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when the mailbox is updated
     * @param _oldMailbox The old mailbox address
     * @param _newMailbox The new mailbox address
     */
    event MailboxUpdated(address _oldMailbox, address _newMailbox);

    /**
     * @notice Emitted when the security module is updated
     * @param _oldSecurityModule The old security module address
     * @param _newSecurityModule The new security module address
     */
    event SecurityModuleUpdated(address _oldSecurityModule, address _newSecurityModule);

    /*///////////////////////////////////////////////////////////////
                              ERRORS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Thrown when the message origin is invalid
     */
    error Gateway_Handle_InvalidOriginDomain();

    /**
     * @notice Thrown when the sender is not the appropriate remote Gateway
     */
    error Gateway_Handle_InvalidSender();

    /**
     * @notice Thrown when the caller is not the local mailbox
     */
    error Gateway_Handle_NotCalledByMailbox();

    /**
     * @notice Thrown when the GasTank does not have enough native asset to cover the fee
     */
    error Gateway_SendMessage_InsufficientBalance();

    /**
     * @notice Thrown when the message dispatcher is not the local receiver
     */
    error Gateway_SendMessage_UnauthorizedCaller();

    /**
     * @notice Thrown when the call returning the unused fee fails
     */
    error Gateway_SendMessage_UnsuccessfulRebate();

    /**
     * @notice Thrown when an address equals the address zero
     */
    error Gateway_ZeroAddress();

    /*///////////////////////////////////////////////////////////////
                              LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Send a message to the transport layer using the gas tank
     * @param _chainId The id of the destination chain
     * @param _message The message to send
     * @param _fee The fee to send the message
     * @param _gasLimit The gas limit to use on destination
     * @return _messageId The id message of the transport layer
     * @return _feeSpent The fee spent to send the message
     * @dev only called by the spoke contract
     */
    function sendMessage(uint32 _chainId, bytes memory _message, uint256 _fee, uint256 _gasLimit)
        external
        returns (bytes32 _messageId, uint256 _feeSpent);

    /**
     * @notice Send a message to the transport layer
     * @param _chainId The id of the destination chain
     * @param _message The message to send
     * @param _gasLimit The gas limit to use on destination
     * @return _messageId The id message of the transport layer
     * @return _feeSpent The fee spent to send the message
     * @dev only called by the spoke contract
     */
    function sendMessage(uint32 _chainId, bytes memory _message, uint256 _gasLimit)
        external
        payable
        returns (bytes32 _messageId, uint256 _feeSpent);

    /**
     * @notice Updates the mailbox
     * @param _mailbox The new mailbox address
     * @dev only called by the `receiver`
     */
    function updateMailbox(address _mailbox) external;

    /**
     * @notice Updates the gateway security module
     * @param _securityModule The address of the new security module
     * @dev only called by the `receiver`
     */
    function updateSecurityModule(address _securityModule) external;

    /*///////////////////////////////////////////////////////////////
                              VIEWS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the transport layer message routing smart contract
     * @dev this is independent of the transport layer used, adopting mailbox name because its descriptive enough
     *      using address instead of specific interface to be independent from HL or any other TL
     * @return _mailbox The address of the mailbox
     */
    function mailbox() external view returns (IMailbox _mailbox);

    /**
     * @notice Returns the message receiver for this Gateway (EverclearHub / EverclearSpoke)
     * @return _receiver The message receiver
     */
    function receiver() external view returns (IMessageReceiver _receiver);

    /**
     * @notice Quotes cost of sending a message to the transport layer
     * @param _chainId The id of the destination chain
     * @param _message The message to send
     * @param _gasLimit The gas limit for delivering the message
     * @return _fee The fee to send the message
     */
    function quoteMessage(uint32 _chainId, bytes memory _message, uint256 _gasLimit)
        external
        view
        returns (uint256 _fee);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title IMessageReceiver
 * @notice Interface for the transport layer communication with the message receiver
 */
interface IMessageReceiver {
    /*///////////////////////////////////////////////////////////////
                              LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Receive a message from the transport layer
     * @param _message The message to receive encoded as bytes
     * @dev This function should be called by the the gateway contract
     */
    function receiveMessage(bytes calldata _message) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface ITimeKeeper {
    error TimeInFuture();
    error ExceededMaxLockTime();
    error InsufficientLockTime();
    error InvalidWeekTime(uint256 _expiry);
    error ExpiryInThePast(uint256 _expiry);
    error InsufficientAmount(uint256 _amount);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <0.9.0;

interface IXERC20 {
    /**
     * @notice Emits when a lockbox is set
     *
     * @param _lockbox The address of the lockbox
     */
    event LockboxSet(address _lockbox);

    /**
     * @notice Emits when a limit is set
     *
     * @param _mintingLimit The updated minting limit we are setting to the bridge
     * @param _burningLimit The updated burning limit we are setting to the bridge
     * @param _bridge The address of the bridge we are setting the limit too
     */
    event BridgeLimitsSet(uint256 _mintingLimit, uint256 _burningLimit, address indexed _bridge);

    /**
     * @notice Reverts when a user with too low of a limit tries to call mint/burn
     */
    error IXERC20_NotHighEnoughLimits();

    /**
     * @notice Reverts when caller is not the factory
     */
    error IXERC20_NotFactory();

    /**
     * @notice Reverts when limits are too high
     */
    error IXERC20_LimitsTooHigh();

    /**
     * @notice Contains the full minting and burning data for a particular bridge
     *
     * @param minterParams The minting parameters for the bridge
     * @param burnerParams The burning parameters for the bridge
     */
    struct Bridge {
        BridgeParameters minterParams;
        BridgeParameters burnerParams;
    }

    /**
     * @notice Contains the mint or burn parameters for a bridge
     *
     * @param timestamp The timestamp of the last mint/burn
     * @param ratePerSecond The rate per second of the bridge
     * @param maxLimit The max limit of the bridge
     * @param currentLimit The current limit of the bridge
     */
    struct BridgeParameters {
        uint256 timestamp;
        uint256 ratePerSecond;
        uint256 maxLimit;
        uint256 currentLimit;
    }

    /**
     * @notice Sets the lockbox address
     *
     * @param _lockbox The address of the lockbox
     */
    function setLockbox(address _lockbox) external;

    /**
     * @notice Updates the limits of any bridge
     * @dev Can only be called by the owner
     * @param _mintingLimit The updated minting limit we are setting to the bridge
     * @param _burningLimit The updated burning limit we are setting to the bridge
     * @param _bridge The address of the bridge we are setting the limits too
     */
    function setLimits(address _bridge, uint256 _mintingLimit, uint256 _burningLimit) external;

    /**
     * @notice Returns the max limit of a minter
     *
     * @param _minter The minter we are viewing the limits of
     *  @return _limit The limit the minter has
     */
    function mintingMaxLimitOf(address _minter) external view returns (uint256 _limit);

    /**
     * @notice Returns the max limit of a bridge
     *
     * @param _bridge the bridge we are viewing the limits of
     * @return _limit The limit the bridge has
     */
    function burningMaxLimitOf(address _bridge) external view returns (uint256 _limit);

    /**
     * @notice Returns the current limit of a minter
     *
     * @param _minter The minter we are viewing the limits of
     * @return _limit The limit the minter has
     */
    function mintingCurrentLimitOf(address _minter) external view returns (uint256 _limit);

    /**
     * @notice Returns the current limit of a bridge
     *
     * @param _bridge the bridge we are viewing the limits of
     * @return _limit The limit the bridge has
     */
    function burningCurrentLimitOf(address _bridge) external view returns (uint256 _limit);

    /**
     * @notice Mints tokens for a user
     * @dev Can only be called by a minter
     * @param _user The address of the user who needs tokens minted
     * @param _amount The amount of tokens being minted
     */
    function mint(address _user, uint256 _amount) external;

    /**
     * @notice Burns tokens for a user
     * @dev Can only be called by a minter
     * @param _user The address of the user who needs tokens burned
     * @param _amount The amount of tokens being burned
     */
    function burn(address _user, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IXERC20Lockbox {
    /**
     * @notice Emitted when tokens are deposited into the lockbox
     */
    event Deposit(address _sender, uint256 _amount);

    /**
     * @notice Emitted when tokens are withdrawn from the lockbox
     */
    event Withdraw(address _sender, uint256 _amount);

    /**
     * @notice Reverts when a user tries to deposit native tokens on a non-native lockbox
     */
    error IXERC20Lockbox_NotNative();

    /**
     * @notice Reverts when a user tries to deposit non-native tokens on a native lockbox
     */
    error IXERC20Lockbox_Native();

    /**
     * @notice Reverts when a user tries to withdraw and the call fails
     */
    error IXERC20Lockbox_WithdrawFailed();

    /**
     * @notice Deposit ERC20 tokens into the lockbox
     *
     * @param _amount The amount of tokens to deposit
     */
    function deposit(uint256 _amount) external;

    /**
     * @notice Deposit ERC20 tokens into the lockbox, and send the XERC20 to a user
     *
     * @param _user The user to send the XERC20 to
     * @param _amount The amount of tokens to deposit
     */
    function depositTo(address _user, uint256 _amount) external;

    /**
     * @notice Deposit the native asset into the lockbox, and send the XERC20 to a user
     *
     * @param _user The user to send the XERC20 to
     */
    function depositNativeTo(address _user) external payable;

    /**
     * @notice Withdraw ERC20 tokens from the lockbox
     *
     * @param _amount The amount of tokens to withdraw
     */
    function withdraw(uint256 _amount) external;

    /**
     * @notice Withdraw ERC20 tokens from the lockbox
     *
     * @param _user The user to withdraw to
     * @param _amount The amount of tokens to withdraw
     */
    function withdrawTo(address _user, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IGateway} from "../interfaces/IGateway.sol";
import {TimeKeeper} from "../common/TimeKeeper.sol";
import {Bridge} from "../common/Bridge.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SpokeBridge is TimeKeeper, Bridge {
    using SafeERC20 for IERC20;

    /// @notice xCLEAR address on the Hub
    address public immutable hubCLEAR;

    /// @notice WETH address on the Hub
    address public immutable hubWETH;

    constructor(
        uint32 _everclearId,
        address _clear,
        address _xClear,
        address _lockbox,
        address _gateway,
        address _owner,
        address _hubCLEAR,
        address _hubWETH
    ) Bridge(_everclearId, _gateway, _xClear, _clear, _lockbox, _owner) {
        if (_hubCLEAR == address(0)) revert ZeroAddress();
        if (_hubWETH == address(0)) revert ZeroAddress();

        hubCLEAR = _hubCLEAR;
        hubWETH = _hubWETH;
    }

    /////////////////////////////// Admin Functions ////////////////////////////////
    /**
     * @notice Admin function to bridge xCLEAR to Hub and send to a recipient
     * @param _amount The amount of xCLEAR to bridge
     * @param _receiver address to receive xCLEAR
     * @param _gasLimit gas limit to use for Hyperlane
     * @return _messageId from Hyperlane
     * @return _feeSpent gas fee spent
     */
    function adminBridge(uint128 _amount, address _receiver, uint256 _gasLimit)
        external
        payable
        onlyOwner
        returns (bytes32 _messageId, uint256 _feeSpent)
    {
        _bridgeOut(msg.sender, _amount);
        bytes32 _sender = _toBytes32(msg.sender);
        bytes memory _message = abi.encode(1, _sender, _amount, _receiver);
        (_messageId, _feeSpent) = gateway.sendMessage{value: msg.value}(EVERCLEAR_ID, _message, _gasLimit);
    }

    /**
     * @notice Update the local mailbox address
     * @param _newMailbox The new mailbox address
     */
    function updateMailbox(address _newMailbox) external onlyOwner {
        if (_newMailbox == address(0)) revert ZeroAddress();
        gateway.updateMailbox(_newMailbox);
    }

    /**
     * @notice Update the interchain security module address
     * @param _newSecurityModule The new security module address
     */
    function updateSecurityModule(address _newSecurityModule) external onlyOwner {
        if (_newSecurityModule == address(0)) revert ZeroAddress();
        gateway.updateSecurityModule(_newSecurityModule);
    }

    /////////////////////////////// Public Functions ////////////////////////////////
    /**
     * @notice Execute increase lock position on vbCLEAR from Spoke
     * @dev User will need to call with msg.value for fee which should = _fee + ((_fee * _bufferBPS)
     * @param _additionalAmountToLock The additional amount to lock
     * @param _expiry expiry time for the lock
     * @param _gasLimit gas limit to use for Hyperlane
     * @return _messageId from Hyperlane
     * @return _feeSpent gas fee spent
     */
    function increaseLockPosition(uint128 _additionalAmountToLock, uint128 _expiry, uint256 _gasLimit)
        external
        payable
        returns (bytes32 _messageId, uint256 _feeSpent)
    {
        if (!_isValidWeekTime(_expiry)) revert InvalidWeekTime(_expiry);
        if (_isTimeInThePast(_expiry)) revert ExpiryInThePast(_expiry);
        if (_expiry > block.timestamp + MAX_LOCK_TIME) revert ExceededMaxLockTime();
        if (_expiry < block.timestamp + MIN_LOCK_TIME) revert InsufficientLockTime();

        _bridgeOut(msg.sender, _additionalAmountToLock);
        bytes32 _sender = _toBytes32(msg.sender);
        bytes memory _message = abi.encode(2, _sender, _additionalAmountToLock, _expiry);
        (_messageId, _feeSpent) = gateway.sendMessage{value: msg.value}(EVERCLEAR_ID, _message, _gasLimit);
    }

    /**
     * @notice Execute withdraw on vbCLEAR from Spoke
     * @param _domain The domain to withdraw from
     * @param _gasLimit gas limit to use for Hyperlane
     * @return _messageId from Hyperlane
     * @return _feeSpent gas fee spent
     */
    function withdraw(uint32 _domain, uint256 _gasLimit)
        external
        payable
        returns (bytes32 _messageId, uint256 _feeSpent)
    {
        bytes32 _sender = _toBytes32(msg.sender);
        bytes memory _message = abi.encode(3, _sender, _domain);
        (_messageId, _feeSpent) = gateway.sendMessage{value: msg.value}(EVERCLEAR_ID, _message, _gasLimit);
    }

    /**
     * @notice Execute delegate on vbCLEAR from Spoke
     * @param _delegate The address to delegate to
     * @param _gasLimit gas limit to use for Hyperlane
     * @return _messageId from Hyperlane
     * @return _feeSpent gas fee spent
     */
    function delegate(bytes32 _delegate, uint256 _gasLimit)
        external
        payable
        returns (bytes32 _messageId, uint256 _feeSpent)
    {
        bytes32 _sender = _toBytes32(msg.sender);
        bytes memory _message = abi.encode(4, _sender, _delegate);
        (_messageId, _feeSpent) = gateway.sendMessage{value: msg.value}(EVERCLEAR_ID, _message, _gasLimit);
    }

    /**
     * @notice Execute exit early on vbCLEAR from Spoke
     * @param _amountToUnlock The amount to unlock
     * @param _domain The domain to unlock from
     * @param _gasLimit gas limit to use for Hyperlane
     * @return _messageId from Hyperlane
     * @return _feeSpent gas fee spent
     */
    function exitEarly(uint128 _amountToUnlock, uint32 _domain, uint256 _gasLimit)
        external
        payable
        returns (bytes32 _messageId, uint256 _feeSpent)
    {
        bytes32 _sender = _toBytes32(msg.sender);
        bytes memory _message = abi.encode(5, _sender, _amountToUnlock, _domain);
        (_messageId, _feeSpent) = gateway.sendMessage{value: msg.value}(EVERCLEAR_ID, _message, _gasLimit);
    }

    /**
     * @notice Execute vote on HubGauge from Spoke
     * @param _domain The domain to vote on
     * @param _gasLimit gas limit to use for Hyperlane
     * @return _messageId from Hyperlane
     * @return _feeSpent gas fee spent
     */
    function submitVote(uint32 _domain, uint256 _gasLimit)
        external
        payable
        returns (bytes32 _messageId, uint256 _feeSpent)
    {
        bytes32 _sender = _toBytes32(msg.sender);
        bytes memory _message = abi.encode(6, _sender, _domain);
        (_messageId, _feeSpent) = gateway.sendMessage{value: msg.value}(EVERCLEAR_ID, _message, _gasLimit);
    }

    /**
     * @notice Execute delegated vote on HubGauge from Spoke
     * @param _grantors The grantors to vote on behalf of
     * @param _domain The domain to vote on
     * @param _gasLimit gas limit to use for Hyperlane
     * @return _messageId from Hyperlane
     * @return _feeSpent gas fee spent
     */
    function submitDelegatedVote(bytes32[] calldata _grantors, uint32 _domain, uint256 _gasLimit)
        external
        payable
        returns (bytes32 _messageId, uint256 _feeSpent)
    {
        bytes32 _sender = _toBytes32(msg.sender);
        bytes memory _message = abi.encode(7, _sender, _grantors, _domain);
        (_messageId, _feeSpent) = gateway.sendMessage{value: msg.value}(EVERCLEAR_ID, _message, _gasLimit);
    }

    /**
     * @notice Execute claim rewards on RewardDistributor from Spoke
     * @param _claim The claim to execute
     * @param _domain The domain to claim xCLEAR to
     * @param _gasLimit gas limit to use for Hyperlane
     * @return _messageId from Hyperlane
     * @return _feeSpent gas fee spent
     */
    function claimRewards(Claim[] memory _claim, uint32 _domain, address _receiver, uint256 _gasLimit)
        external
        payable
        returns (bytes32 _messageId, uint256 _feeSpent)
    {
        if (_claim.length == 0) revert InvalidInput();
        if (_receiver == address(0)) revert ZeroAddress();
        bytes32 _sender = _toBytes32(msg.sender);
        _claim = _rewriteClaim(_sender, _claim);
        bytes memory _message = abi.encode(8, _sender, _claim, _domain, _receiver);
        (_messageId, _feeSpent) = gateway.sendMessage{value: msg.value}(EVERCLEAR_ID, _message, _gasLimit);
    }

    /**
     * @notice Receive message from HubBridge via Hyperlane
     * @dev All messages will be bridgeIn xCLEAR to receiver from withdraw, exitEarly, or claimRewards tx's
     * that were originally executed from SpokeBridge
     * @param _message The message to receive
     */
    function receiveMessage(bytes memory _message) external onlyGateway {
        (bytes32 _receiverBytes, uint128 _amount) = abi.decode(_message, (bytes32, uint128));
        address _receiverAddress = _toAddress(_receiverBytes);
        _bridgeIn(_receiverAddress, _amount);
    }

    /////////////////////////////// Internal Functions ////////////////////////////////
    /**
     * @notice Rewrites the account for the claim to the msg.sender and ensures tokens valid
     * @param _sender msg.sender to use for rewrite
     * @param _claim The claim to rewrite
     */
    function _rewriteClaim(bytes32 _sender, Claim[] memory _claim) internal view returns (Claim[] memory) {
        for (uint256 i = 0; i < _claim.length; i++) {
            address _currentToken = _claim[i].token;
            if (_currentToken != hubWETH && _currentToken != hubCLEAR) revert InvalidToken();
            _claim[i].account = _sender;
        }

        return _claim;
    }

    /**
     * @notice Using Yul to pack command and address into single slot
     * @dev Command is from the function calling this and used on HubBridge to route the action
     * @param _command The command to pack
     */
    function _buildCommand(uint8 _command) private view returns (bytes32 _senderWithCommand) {
        assembly {
            _senderWithCommand := add(shl(mul(31, 8), _command), caller())
        }
    }
}