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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC1271.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.20;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.20;

import {StorageSlot} from "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using
     * {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;

import {Math} from "./math/Math.sol";
import {SignedMath} from "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;

import {MessageHashUtils} from "./MessageHashUtils.sol";
import {ShortStrings, ShortString} from "../ShortStrings.sol";
import {IERC5267} from "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _name which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _name.toStringWithFallback(_nameFallback);
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _version which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _version.toStringWithFallback(_versionFallback);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.20;

import {Strings} from "../Strings.sol";

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[EIP 191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (EIP-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^0.8.20;

import {ECDSA} from "./ECDSA.sol";
import {IERC1271} from "../../interfaces/IERC1271.sol";

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Safe Wallet (previously Gnosis Safe).
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error, ) = ECDSA.tryRecover(hash, signature);
        return
            (error == ECDSA.RecoverError.NoError && recovered == signer) ||
            isValidERC1271SignatureNow(signer, hash, signature);
    }

    /**
     * @dev Checks if a signature is valid for a given signer and data hash. The signature is validated
     * against the signer smart contract using ERC1271.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeCall(IERC1271.isValidSignature, (hash, signature))
        );
        return (success &&
            result.length >= 32 &&
            abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector));
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
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
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: ISC
pragma solidity 0.8.25;

import "./Pricing.sol";
import "./interfaces/ICollateral.sol";
import "./interfaces/ICollateralPool.sol";
import "./SignatureNonces.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

/**
 * @title Collateral Vault providing authorized Collateralizable contracts access to collateral via the `ICollateral` interface.
 *
 * @notice Approved Collateralizable contracts may reserve, claim, modify, pool, and release collateral on behalf of an
 * account to fulfill their business logic. Note: CollateralVault contract governance AND the account must approve a
 * Collateralizable contract for it to use an account's collateral.
 *
 * A withdrawal fee will be applied to any collateral that exits this contract unless it is an account moving
 * available collateral to an approved upgraded Collateral contract if/when such contracts exist (no current plans). Any
 * updates to withdrawal fee through governance will not affect collateral that is already in use in a
 * `CollateralReservation` at the time of the update. The initial withdrawal fee can be found in the
 * `withdrawalFeeBasisPoints` variable declaration below.
 *
 * The specific ERC-20 tokens permitted for use as collateral within this contract and their usage limits may vary over
 * time through governance. If an existing token is disallowed in the future, existing CollateralReservations will be
 * honored, but no new collateral reservations may be created for that token.
 *
 * @custom:security-contact security@af.xyz
 */
contract CollateralVault is ICollateral, ERC165, Ownable2Step, EIP712, SignatureNonces {
    using SafeERC20 for IERC20;

    /******************
     * CONTRACT STATE *
     ******************/

    bytes32 public constant COLLATERALIZABLE_TOKEN_ALLOWANCE_ADJUSTMENT_TYPEHASH =
        keccak256(
            "CollateralizableTokenAllowanceAdjustment(address collateralizableAddress,address tokenAddress,int256 allowanceAdjustment,uint256 approverNonce)"
        );

    bytes32 public constant COLLATERALIZABLE_DEPOSIT_APPROVAL_TYPEHASH =
        keccak256(
            "CollateralizableDepositApproval(address collateralizableAddress,address tokenAddress,uint256 depositAmount,uint256 approverNonce)"
        );

    /// can be modified via governance through setWithdrawalFeeBasisPoints(...).
    uint16 public withdrawalFeeBasisPoints = 50;

    /// also known as reservationId in the ICollateral interface.
    /// NB: uint96 stores up to 7.9 x 10^28 and packs tightly with addresses (12 + 20 = 32 bytes).
    uint96 private collateralReservationNonce;

    /// account address => token address => CollateralBalance of the account.
    mapping(address => mapping(address => CollateralBalance)) public accountBalances;

    /// account address => collateralizable contract address => token address => approved amount, set by account to
    /// allow specified amount of collateral to be used by the associated collateralizable contract.
    mapping(address => mapping(address => mapping(address => uint256))) public accountCollateralizableTokenAllowances;

    /// contract address => approval, set by governance to [dis]allow use of this contract's ICollateral interface.
    mapping(address => bool) public collateralizableContracts;

    /// reservationId => CollateralReservation of active collateral reservations.
    mapping(uint96 => CollateralReservation) public collateralReservations;

    /// token address => CollateralToken modified via governance to indicate tokens approved for use within this contract.
    mapping(address => CollateralToken) public collateralTokens;

    /// CollateralUpgradeTarget address => enabled, set by governance to indicate valid Collateral contracts accounts may freely move available collateral to.
    mapping(address => bool) public permittedCollateralUpgradeContracts;

    /***********
     * STRUCTS *
     ***********/

    struct CollateralTokenConfig {
        bool enabled;
        address tokenAddress;
    }

    struct CollateralizableContractApprovalConfig {
        address collateralizableAddress;
        bool isApproved;
    }

    /*************
     * MODIFIERS *
     *************/

    /**
     * Asserts that the provided collateral token address is enabled by the protocol, reverting if not.
     * @param _collateralTokenAddress The collateral token address to check.
     */
    modifier onlyEnabledCollateralTokens(address _collateralTokenAddress) {
        _verifyTokenEnabled(_collateralTokenAddress);

        _;
    }

    /****************
     * PUBLIC VIEWS *
     ****************/

    /**
     * @inheritdoc ICollateral
     */
    function getCollateralToken(address _tokenAddress) public view returns (CollateralToken memory) {
        return collateralTokens[_tokenAddress];
    }

    /**
     * @inheritdoc ICollateral
     */
    function getAccountCollateralBalance(
        address _accountAddress,
        address _tokenAddress
    ) public view returns (CollateralBalance memory _balance) {
        return accountBalances[_accountAddress][_tokenAddress];
    }

    /**
     * @inheritdoc ICollateral
     */
    function getCollateralReservation(uint96 _reservationId) public view returns (CollateralReservation memory) {
        return collateralReservations[_reservationId];
    }

    /// Gets the claimable amount for the provided CollateralReservation, accounting for fees.
    function getClaimableAmount(uint96 _reservationId) public view returns (uint256) {
        return collateralReservations[_reservationId].claimableTokenAmount;
    }

    /**
     * @inheritdoc ICollateral
     */
    function getCollateralizableTokenAllowance(
        address _accountAddress,
        address _collateralizableContract,
        address _tokenAddress
    ) public view returns (uint256) {
        return accountCollateralizableTokenAllowances[_accountAddress][_collateralizableContract][_tokenAddress];
    }

    /**
     * @inheritdoc ICollateral
     */
    function getWithdrawalFeeBasisPoints() external view returns (uint16) {
        return withdrawalFeeBasisPoints;
    }

    /**
     * Indicates support for IERC165, ICollateral, and ICollateralUpgradeTarget.
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 _interfaceID) public view override returns (bool) {
        return
            _interfaceID == type(ICollateral).interfaceId ||
            _interfaceID == type(ICollateralDepositTarget).interfaceId ||
            super.supportsInterface(_interfaceID);
    }

    /*****************************
     * STATE-MODIFYING FUNCTIONS *
     *****************************/

    /**
     * @notice Constructs a `CollateralVault` contract with the `CollateralTokens` according to the provided configs.
     * @param _collateralTokens The `CollateralTokenConfig` array, specifying supported collateral token addresses and
     * their constraints.
     */
    constructor(CollateralTokenConfig[] memory _collateralTokens) Ownable(msg.sender) EIP712("CollateralVault", "1") {
        _authorizedUpsertCollateralTokens(_collateralTokens);
    }

    /**
     * Combines the deposit & approve steps, as accounts wishing to use this contract will likely not want to do one
     * without doing the other. This will add the provided amounts to the collateralizable allowance of the caller for
     * the tokens in question.
     *
     * @param _tokenAddresses The array of addresses of the Tokens to transfer. Indexes must correspond to _amounts.
     * @param _amounts The list of amounts of the Tokens to transfer. Indexes must correspond to _tokenAddresses.
     * @param _collateralizableContractAddressToApprove The Collateralizable contract to approve to use deposited collateral.
     */
    function depositAndApprove(
        address[] calldata _tokenAddresses,
        uint256[] calldata _amounts,
        address _collateralizableContractAddressToApprove
    ) external {
        if (!collateralizableContracts[_collateralizableContractAddressToApprove])
            revert ContractNotApprovedByProtocol(_collateralizableContractAddressToApprove);

        depositToAccount(msg.sender, _tokenAddresses, _amounts);
        for (uint256 i = 0; i < _amounts.length; i++) {
            _authorizedModifyCollateralizableTokenAllowance(
                msg.sender,
                _collateralizableContractAddressToApprove,
                _tokenAddresses[i],
                Pricing.safeCastToInt256(_amounts[i])
            );
        }
    }

    /**
     * @inheritdoc ICollateralDepositTarget
     */
    function depositToAccount(
        address _accountAddress,
        address[] calldata _tokenAddresses,
        uint256[] calldata _amounts
    ) public {
        if (_tokenAddresses.length != _amounts.length)
            revert RelatedArraysLengthMismatch(_tokenAddresses.length, _amounts.length);

        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            _deposit(msg.sender, _accountAddress, _tokenAddresses[i], _amounts[i]);
        }
    }

    /**
     * @inheritdoc ICollateral
     */
    function claimCollateral(
        uint96 _reservationId,
        uint256 _amountToReceive,
        address _toAddress,
        bool _releaseRemainder
    ) external returns (uint256, uint256) {
        return _claimCollateral(_reservationId, _amountToReceive, _toAddress, _releaseRemainder);
    }

    /**
     * @inheritdoc ICollateral
     */
    function depositFromAccount(
        address _accountAddress,
        address _tokenAddress,
        uint256 _amount,
        bytes calldata _collateralizableDepositApprovalSignature
    ) external {
        if (!collateralizableContracts[msg.sender]) revert Unauthorized(msg.sender);

        _verifyDepositApprovalSignature(
            _accountAddress,
            _tokenAddress,
            _amount,
            _collateralizableDepositApprovalSignature
        );

        uint256 allowance = accountCollateralizableTokenAllowances[_accountAddress][msg.sender][_tokenAddress];
        if (allowance < _amount) {
            _authorizedModifyCollateralizableTokenAllowance(
                _accountAddress,
                msg.sender,
                _tokenAddress,
                int256(_amount - allowance)
            );
        }

        _deposit(_accountAddress, _accountAddress, _tokenAddress, _amount);
    }

    /**
     * @notice Modifies the amount of the calling account's collateral the Collateralizable contract may use through this contract.
     * @param _collateralizableContractAddress The address of the Collateralizable contract `msg.sender` is [dis]allowing.
     * @param _tokenAddress The address of the token for which the allowance is being checked and updated.
     * @param _byAmount The signed number by which the approved amount will be modified. Negative approved amounts
     * function the same as 0 when attempting to reserve collateral. An account may choose to modify such that the allowance
     * is negative since reservations, once released, add to the approved amount since that collateral was previously approved for use.
     */
    function modifyCollateralizableTokenAllowance(
        address _collateralizableContractAddress,
        address _tokenAddress,
        int256 _byAmount
    ) external {
        if (_byAmount > 0 && !collateralizableContracts[_collateralizableContractAddress])
            revert ContractNotApprovedByProtocol(_collateralizableContractAddress);

        _authorizedModifyCollateralizableTokenAllowance(
            msg.sender,
            _collateralizableContractAddress,
            _tokenAddress,
            _byAmount
        );
    }

    /**
     * @inheritdoc ICollateral
     */
    function modifyCollateralizableTokenAllowanceWithSignature(
        address _accountAddress,
        address _collateralizableContractAddress,
        address _tokenAddress,
        int256 _allowanceAdjustment,
        bytes calldata _signature
    ) external {
        if (_allowanceAdjustment > 0 && !collateralizableContracts[_collateralizableContractAddress])
            revert ContractNotApprovedByProtocol(_collateralizableContractAddress);

        _modifyCollateralizableTokenAllowanceWithSignature(
            _accountAddress,
            _collateralizableContractAddress,
            _tokenAddress,
            _allowanceAdjustment,
            _signature
        );
    }

    /**
     * @inheritdoc ICollateral
     */
    function modifyCollateralReservation(uint96 _reservationId, int256 _byAmount) external returns (uint256, uint256) {
        return _modifyCollateralReservation(_reservationId, _byAmount);
    }

    /**
     * @inheritdoc ICollateral
     */
    function poolCollateral(
        address _accountAddress,
        address _tokenAddress,
        uint256 _amount
    ) external onlyEnabledCollateralTokens(_tokenAddress) {
        _requireCollateralizableAndDecreaseApprovedAmount(msg.sender, _accountAddress, _tokenAddress, _amount);

        _transferCollateral(_tokenAddress, _accountAddress, _amount, msg.sender);
    }

    /**
     * @inheritdoc ICollateral
     */
    function releaseAllCollateral(uint96 _reservationId) external returns (uint256) {
        return _releaseAllCollateral(_reservationId);
    }

    /**
     * @inheritdoc ICollateral
     */
    function reserveClaimableCollateral(
        address _accountAddress,
        address _tokenAddress,
        uint256 _claimableAmount
    ) external returns (uint96 _reservationId, uint256 _totalAmountReserved) {
        _totalAmountReserved = Pricing.amountWithFee(_claimableAmount, withdrawalFeeBasisPoints);
        _reservationId = _reserveCollateral(
            msg.sender,
            _accountAddress,
            _tokenAddress,
            _totalAmountReserved,
            _claimableAmount
        );
    }

    /**
     * @inheritdoc ICollateral
     */
    function reserveCollateral(
        address _accountAddress,
        address _tokenAddress,
        uint256 _amount
    ) external returns (uint96 _reservationId, uint256 _claimableAmount) {
        _claimableAmount = Pricing.amountBeforeFee(_amount, withdrawalFeeBasisPoints);
        _reservationId = _reserveCollateral(msg.sender, _accountAddress, _tokenAddress, _amount, _claimableAmount);
    }

    /**
     * @inheritdoc ICollateral
     */
    function transferCollateral(address _tokenAddress, uint256 _amount, address _destinationAddress) external {
        _transferCollateral(_tokenAddress, msg.sender, _amount, _destinationAddress);
    }

    /**
     * @notice Upgrades the sender's account, sending the specified collateral tokens to a new ICollateralDepositTarget contract.
     * Note that the target ICollateral address must have previously been approved within this contract by governance.
     * @param _targetContractAddress The ICollateralDepositTarget contract that will be sent the collateral.
     * NOTE: the ICollateralDepositTarget implementation MUST iterate and transfer all tokens to itself or revert or
     * collateral will be "lost" within this contract. See ICollateralDepositTarget for more information.
     * @param _tokenAddresses The addresses of the tokens to be transferred. Indexes in this array correspond to those of _amounts.
     * @param _amounts The amounts to be transferred. Indexes in this array correspond to those of _tokenAddresses.
     */
    function upgradeAccount(
        address _targetContractAddress,
        address[] calldata _tokenAddresses,
        uint256[] calldata _amounts
    ) external {
        if (!permittedCollateralUpgradeContracts[_targetContractAddress])
            revert ContractNotApprovedByProtocol(_targetContractAddress);
        if (_tokenAddresses.length != _amounts.length)
            revert RelatedArraysLengthMismatch(_tokenAddresses.length, _amounts.length);

        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            address tokenAddress = _tokenAddresses[i];
            CollateralBalance storage accountBalanceStorage = accountBalances[msg.sender][tokenAddress];
            uint256 available = accountBalanceStorage.available;

            uint256 amount = _amounts[i];
            if (available < amount) revert InsufficientCollateral(amount, available);
            accountBalanceStorage.available = available - amount;
            collateralTokens[tokenAddress].cumulativeUserBalance -= amount;
            IERC20(tokenAddress).forceApprove(_targetContractAddress, amount);
        }

        ICollateralDepositTarget(_targetContractAddress).depositToAccount(msg.sender, _tokenAddresses, _amounts);

        emit AccountInitiatedUpgrade(msg.sender, _targetContractAddress, _tokenAddresses, _amounts);
    }

    /**
     * @inheritdoc ICollateral
     */
    function withdraw(address _tokenAddress, uint256 _amount, address _destinationAddress) external {
        if (_amount == 0) revert InvalidZeroAmount();
        uint256 available = accountBalances[msg.sender][_tokenAddress].available;
        if (available < _amount) revert InsufficientCollateral(_amount, available);
        if (_destinationAddress == address(0)) revert InvalidTargetAddress(_destinationAddress);

        accountBalances[msg.sender][_tokenAddress].available = available - _amount;
        collateralTokens[_tokenAddress].cumulativeUserBalance -= _amount;

        uint256 fee = Pricing.percentageOf(_amount, uint256(withdrawalFeeBasisPoints));

        IERC20(_tokenAddress).safeTransfer(_destinationAddress, _amount - fee);

        emit FundsWithdrawn(msg.sender, _tokenAddress, _amount, fee, _destinationAddress);
    }

    /************************
     * GOVERNANCE FUNCTIONS *
     ************************/

    /**
     * @notice Updates the fee for withdrawing from this contract, via `withdraw(...)`, `claimCollateral(...)`, or any
     * other mechanism other than upgrading to an approved `ICollateralDepositTarget`.
     * Note: this may only be done through governance.
     * @param _feeBasisPoints The new fee in basis points.
     */
    function setWithdrawalFeeBasisPoints(uint16 _feeBasisPoints) external onlyOwner {
        // NB: No intention to raise fee, but 10% cap to offer at least some guarantee to depositors.
        if (_feeBasisPoints > 1_000) revert WithdrawalFeeTooHigh(_feeBasisPoints, 1_000);

        emit WithdrawalFeeUpdated(withdrawalFeeBasisPoints, _feeBasisPoints);

        withdrawalFeeBasisPoints = _feeBasisPoints;
    }

    /**
     * @notice Updates the approval status of one or more Collateralizable contracts that may use this contract's collateral.
     * Note: this may only be done through governance.
     * @dev Note: if disapproving an existing Collateralizable contract, its collateral status will enter a decrease-only
     * status, in which it may claim or release reserved collateral but not create new `CollateralReservations`.
     * @param _updates The array of CollateralizableContractApprovalConfigs containing all the contract approvals to modify.
     */
    function upsertCollateralizableContractApprovals(
        CollateralizableContractApprovalConfig[] calldata _updates
    ) external onlyOwner {
        for (uint256 i = 0; i < _updates.length; i++) {
            address contractAddress = _updates[i].collateralizableAddress;
            if (contractAddress == address(0)) revert InvalidTargetAddress(contractAddress);
            collateralizableContracts[contractAddress] = _updates[i].isApproved;

            bool isCollateralPool;
            try IERC165(contractAddress).supportsInterface(type(ICollateralPool).interfaceId) {
                // NB: We have to get the returndata this way because if contractAddress does not implement IERC165,
                // it will not return a boolean, so adding `returns (bool isCollateralPool)` to the try above reverts.
                assembly ("memory-safe") {
                    // Booleans, despite being a single bit, are ABI-encoded to a full 32-byte word.
                    if eq(returndatasize(), 0x20) {
                        // Memory at byte indexes 0-64 are to be used as "scratch space" -- perfect for this use.
                        returndatacopy(0, 0, 0x20)
                        // Since this block could be hit by any fallback function that returns 32-bytes (i.e. an integer),
                        // do a check for exactly 1 when setting `isCollateralPool`. Note: fallback functions should not
                        // return data, and the consequences of getting this wrong are extremely minor and off-chain.
                        if eq(mload(0), 1) {
                            isCollateralPool := true
                        }
                    }
                }
            } catch (bytes memory) {
                // contractAddress does not implement IERC165. `isCollateralPool` should be false in this case
            }

            emit CollateralizableContractApprovalUpdated(_updates[i].isApproved, contractAddress, isCollateralPool);
        }
    }

    /**
     * @notice Updates the `CollateralTokens` at the provided addresses. This permits adding new `CollateralTokens`
     * and/or disallowing future use of or updating the fields of an existing `CollateralToken`.
     * Note: this may only be done through governance.
     *
     * NOTE: Great care should be taken in reviewing tokens prior to addition, with the default being to disallow tokens
     * if unsure. A few types of tokens are generally considered unsafe, however this is not an exhaustive list:
     *   - Fee-on-transfer tokens. These tokens will result in erroneous accounting upon deposit actions as the amount
     *   received by the vault will be lower than the provided deposit amount.
     *   - Rebasing tokens. If the contract's balance is increasing after a rebase then the extra amount will be
     *   eventually held by the CollateralVault contract as fee which is unfair to the depositors. On the other hand, if
     *   after a token's rebase the contract's balance is decreasing, then the whole accounting is against the protocol
     *   and any depositor can benefit until all the contract's funds are drained.
     *   - Upgradeable token contracts. It is generally a risk to whitelist upgradeable contracts since their
     *   implementation might be altered.
     *
     * @dev Calling this with an `enabled` value of `false` disallows future use of this `CollateralToken` until it is
     * overridden by a subsequent call to this function setting it to `true`.
     * Calling this function has no impact on existing `CollateralReservations`. If a limit is decreased or the token is
     * disabled, existing reservations may not be increased, but they may still be claimed or released.
     * @param _collateralTokens The array of collateral token objects, containing their addresses and constraints.
     */
    function upsertCollateralTokens(CollateralTokenConfig[] memory _collateralTokens) public onlyOwner {
        _authorizedUpsertCollateralTokens(_collateralTokens);
    }

    /**
     * @notice Updates the approval status of a `ICollateralDepositTarget` contract that may be sent an account's
     * available collateral upon the account's request.
     * Note: this may only be done through governance.
     * The caller MUST verify that all approved addresses properly implement ICollateralDepositTarget. See all documentation in that interface for more information.
     * @param _collateralUpgradeContractAddress The address of the contract being approved/disapproved.
     * @param _approved true if the contract should be allowed to receive this contract's collateral, false otherwise.
     */
    function upsertCollateralUpgradeContractApproval(
        address _collateralUpgradeContractAddress,
        bool _approved
    ) external onlyOwner {
        permittedCollateralUpgradeContracts[_collateralUpgradeContractAddress] = _approved;

        emit CollateralUpgradeContractApprovalUpdated(_approved, _collateralUpgradeContractAddress);

        // NB: if the _collateralUpgradeContractAddress is an EOA, the transaction will revert without a reason.
        try
            IERC165(_collateralUpgradeContractAddress).supportsInterface(type(ICollateralDepositTarget).interfaceId)
        returns (bool supported) {
            if (!supported) revert InvalidUpgradeTarget(_collateralUpgradeContractAddress);
        } catch (bytes memory) {
            revert InvalidUpgradeTarget(_collateralUpgradeContractAddress);
        }
    }

    /**
     * @notice Withdraws assets amassed by the protocol to the target address.
     * Note: this may only be done through governance.
     * @param _tokenAddresses The addresses of the ERC-20 tokens being withdrawn.
     * Note: the indexes of this array correspond to those of _amounts.
     * @param _amounts The amounts of tokens being withdrawn.
     * Note: the indexes of this array correspond to those of _amounts.
     * @param _destination The address to which withdrawn assets will be sent.
     */
    function withdrawFromProtocolBalance(
        address[] calldata _tokenAddresses,
        uint256[] calldata _amounts,
        address _destination
    ) external onlyOwner {
        if (_tokenAddresses.length != _amounts.length)
            revert RelatedArraysLengthMismatch(_tokenAddresses.length, _amounts.length);
        if (_destination == address(0)) revert InvalidTargetAddress(_destination);

        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            address tokenAddress = _tokenAddresses[i];
            uint256 amount = _amounts[i];
            uint256 protocolBalance = IERC20(tokenAddress).balanceOf(address(this)) -
                collateralTokens[tokenAddress].cumulativeUserBalance;
            if (protocolBalance < amount) revert InsufficientCollateral(amount, protocolBalance);

            IERC20(tokenAddress).safeTransfer(_destination, amount);
        }

        emit ProtocolBalanceWithdrawn(_destination, _tokenAddresses, _amounts);
    }

    /********************************
     * PRIVATE / INTERNAL FUNCTIONS *
     ********************************/

    /**
     * @notice Modifies the allowance of the provided collateralizable contract for the provided token and account by
     * the provided amount.
     * @dev It is assumed to have been done by the caller.
     * @param _accountAddress The account for which the allowance is being modified.
     * @param _collateralizableContractAddress The collateralizable contract to which the allowance pertains.
     * @param _tokenAddress The token of the allowance being  modified.
     * @param _byAmount The signed integer amount (positive if adding to the allowance, negative otherwise).
     */
    function _authorizedModifyCollateralizableTokenAllowance(
        address _accountAddress,
        address _collateralizableContractAddress,
        address _tokenAddress,
        int256 _byAmount
    ) private {
        uint256 newAllowance;
        uint256 currentAllowance = accountCollateralizableTokenAllowances[_accountAddress][
            _collateralizableContractAddress
        ][_tokenAddress];

        if (_byAmount > 0) {
            unchecked {
                newAllowance = currentAllowance + uint256(_byAmount);
            }
            if (newAllowance < currentAllowance) {
                // This means we overflowed, but the intention was to increase the allowance, so set the allowance to the max.
                newAllowance = type(uint256).max;
            }
        } else {
            unchecked {
                newAllowance = currentAllowance - uint256(-_byAmount);
            }
            if (newAllowance > currentAllowance) {
                // This means we underflowed, but the intention was to decrease the allowance, so set the allowance to 0.
                newAllowance = 0;
            }
        }

        // Only update storage and emit an event if the allowance was actually updated.
        if (newAllowance != currentAllowance) {
            accountCollateralizableTokenAllowances[_accountAddress][_collateralizableContractAddress][
                _tokenAddress
            ] = newAllowance;

            emit AccountCollateralizableContractAllowanceUpdated(
                _accountAddress,
                _collateralizableContractAddress,
                _tokenAddress,
                _byAmount,
                newAllowance
            );
        }
    }

    /**
     * @notice Does the same thing as `upsertCollateralTokens(...)` just without checking authorization. It is assumed that
     * the caller of this function will handle auth prior to calling this.
     */
    function _authorizedUpsertCollateralTokens(CollateralTokenConfig[] memory _tokens) private {
        for (uint256 i = 0; i < _tokens.length; i++) {
            address tokenAddress = _tokens[i].tokenAddress;
            // NB: we are not actually verifying that the _tokenAddress is an ERC-20.
            collateralTokens[tokenAddress] = CollateralToken(
                collateralTokens[tokenAddress].cumulativeUserBalance,
                _tokens[i].enabled
            );

            emit CollateralTokenUpdated(_tokens[i].enabled, tokenAddress);
        }
    }

    /// @dev Internal function with the same signature as similar external function to allow efficient reuse.
    function _claimCollateral(
        uint96 _reservationId,
        uint256 _amountToReceive,
        address _toAddress,
        bool _releaseRemainder
    ) internal returns (uint256 _remainingReservedCollateral, uint256 _remainingClaimableCollateral) {
        if (_amountToReceive == 0) revert ClaimAmountZero();

        if (_toAddress == address(0)) revert InvalidTargetAddress(_toAddress);
        CollateralReservation storage reservationStorage = collateralReservations[_reservationId];
        if (msg.sender != reservationStorage.collateralizableContract) revert Unauthorized(msg.sender);

        uint256 claimableTokenAmount = reservationStorage.claimableTokenAmount;
        if (claimableTokenAmount < _amountToReceive)
            revert InsufficientCollateral(_amountToReceive, claimableTokenAmount);

        uint256 amountWithFee;
        uint256 tokenAmount = reservationStorage.tokenAmount;
        _remainingClaimableCollateral = claimableTokenAmount - _amountToReceive;
        if (_remainingClaimableCollateral == 0) {
            _releaseRemainder = true;
            _remainingReservedCollateral = 0;
            amountWithFee = tokenAmount;
        } else {
            _remainingReservedCollateral = Pricing.amountWithFee(
                _remainingClaimableCollateral,
                reservationStorage.feeBasisPoints
            );
            amountWithFee = tokenAmount - _remainingReservedCollateral;
        }

        address tokenAddress = reservationStorage.tokenAddress;
        collateralTokens[tokenAddress].cumulativeUserBalance -= amountWithFee;
        if (_releaseRemainder) {
            CollateralBalance storage balanceStorage = accountBalances[reservationStorage.account][tokenAddress];
            balanceStorage.reserved -= tokenAmount;
            balanceStorage.available += _remainingReservedCollateral;

            delete collateralReservations[_reservationId];
        } else {
            accountBalances[reservationStorage.account][tokenAddress].reserved -= amountWithFee;

            reservationStorage.tokenAmount = _remainingReservedCollateral;
            reservationStorage.claimableTokenAmount = _remainingClaimableCollateral;
        }
        uint256 fee = amountWithFee - _amountToReceive;

        emit CollateralClaimed(_reservationId, amountWithFee, fee, _releaseRemainder);

        IERC20(tokenAddress).safeTransfer(_toAddress, _amountToReceive);
    }

    /**
     * @dev Helper function to ensure consistent processing of deposits, however they are received.
     * @param _transferSource The address from which collateral will be transferred. Preapproval is assumed.
     * @param _accountAddress The address to credit with the deposited collateral within the `CollateralVault`.
     * @param _tokenAddress The address of the token being deposited.
     * @param _amount The amount of the token being deposited.
     */
    function _deposit(
        address _transferSource,
        address _accountAddress,
        address _tokenAddress,
        uint256 _amount
    ) internal onlyEnabledCollateralTokens(_tokenAddress) {
        CollateralToken storage collateralTokenStorage = collateralTokens[_tokenAddress];

        CollateralBalance storage accountBalanceStorage = accountBalances[_accountAddress][_tokenAddress];
        uint256 available = accountBalanceStorage.available;
        accountBalanceStorage.available = available + _amount;
        collateralTokenStorage.cumulativeUserBalance += _amount;

        IERC20(_tokenAddress).safeTransferFrom(_transferSource, address(this), _amount);

        emit FundsDeposited(_transferSource, _accountAddress, _tokenAddress, _amount);
    }

    /// Internal function with the same signature as the one exposed externally so that it may be reused.
    function _modifyCollateralReservation(
        uint96 _reservationId,
        int256 _byAmount
    ) internal returns (uint256 _reservedCollateral, uint256 _claimableCollateral) {
        CollateralReservation storage reservationStorage = collateralReservations[_reservationId];
        uint256 oldReservedAmount = reservationStorage.tokenAmount;
        if (oldReservedAmount == 0) revert CollateralReservationNotFound(_reservationId);
        if (_byAmount == 0) {
            // NB: return early for efficiency and because it may otherwise change state, recalculating claimable
            // collateral from total collateral. We never want to do that unless there is a real modification.
            return (reservationStorage.tokenAmount, reservationStorage.claimableTokenAmount);
        }

        address collateralizable = reservationStorage.collateralizableContract;
        if (msg.sender != collateralizable) revert Unauthorized(msg.sender);

        if (_byAmount < 0) {
            uint256 byAmountUint = uint256(-_byAmount);
            if (byAmountUint >= oldReservedAmount) revert InsufficientCollateral(byAmountUint, oldReservedAmount);

            _reservedCollateral = oldReservedAmount - byAmountUint;
            reservationStorage.tokenAmount = _reservedCollateral;

            address account = reservationStorage.account;
            address tokenAddress = reservationStorage.tokenAddress;

            CollateralBalance storage balanceStorage = accountBalances[account][tokenAddress];
            balanceStorage.reserved -= byAmountUint;
            balanceStorage.available += byAmountUint;
        } else {
            address tokenAddress = reservationStorage.tokenAddress;
            // Cannot increase reservation if token is disabled.
            _verifyTokenEnabled(tokenAddress);

            uint256 byAmountUint = uint256(_byAmount);

            address account = reservationStorage.account;
            // Note: If no longer collateralizable, the calling contract may only decrease collateral usage.
            _requireCollateralizableAndDecreaseApprovedAmount(collateralizable, account, tokenAddress, byAmountUint);

            uint256 available = accountBalances[account][tokenAddress].available;
            if (byAmountUint > available) revert InsufficientCollateral(byAmountUint, available);

            _reservedCollateral = oldReservedAmount + byAmountUint;
            reservationStorage.tokenAmount = _reservedCollateral;

            CollateralBalance storage balanceStorage = accountBalances[account][tokenAddress];
            balanceStorage.reserved += byAmountUint;
            balanceStorage.available = available - byAmountUint;
        }
        _claimableCollateral = Pricing.amountBeforeFee(_reservedCollateral, reservationStorage.feeBasisPoints);
        if (_claimableCollateral == 0) revert ClaimableAmountZero();

        uint256 oldClaimableAmount = reservationStorage.claimableTokenAmount;
        reservationStorage.claimableTokenAmount = _claimableCollateral;
        emit CollateralReservationModified(
            _reservationId,
            oldReservedAmount,
            _reservedCollateral,
            oldClaimableAmount,
            _claimableCollateral
        );
    }

    /// Same as the external function with a similar name, but private for easy reuse.
    function _modifyCollateralizableTokenAllowanceWithSignature(
        address _accountAddress,
        address _collateralizableContractAddress,
        address _tokenAddress,
        int256 _allowanceAdjustment,
        bytes calldata _signature
    ) private {
        {
            bytes32 hash = _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        COLLATERALIZABLE_TOKEN_ALLOWANCE_ADJUSTMENT_TYPEHASH,
                        _collateralizableContractAddress,
                        _tokenAddress,
                        _allowanceAdjustment,
                        _useNonce(_accountAddress, COLLATERALIZABLE_TOKEN_ALLOWANCE_ADJUSTMENT_TYPEHASH)
                    )
                )
            );
            if (!SignatureChecker.isValidSignatureNow(_accountAddress, hash, _signature)) {
                revert InvalidSignature(_accountAddress);
            }
        }

        _authorizedModifyCollateralizableTokenAllowance(
            _accountAddress,
            _collateralizableContractAddress,
            _tokenAddress,
            _allowanceAdjustment
        );
    }

    /// Internal function with the same signature as the one exposed externally so that it may be reused.
    function _releaseAllCollateral(uint96 _reservationId) internal returns (uint256 _totalCollateralReleased) {
        CollateralReservation storage reservationStorage = collateralReservations[_reservationId];
        address collateralizable = reservationStorage.collateralizableContract;
        if (msg.sender != collateralizable) revert Unauthorized(msg.sender);

        _totalCollateralReleased = reservationStorage.tokenAmount;
        address tokenAddress = reservationStorage.tokenAddress;
        address account = reservationStorage.account;

        CollateralBalance storage balanceStorage = accountBalances[account][tokenAddress];
        balanceStorage.available += _totalCollateralReleased;
        balanceStorage.reserved -= _totalCollateralReleased;

        delete collateralReservations[_reservationId];

        emit CollateralReleased(_reservationId, _totalCollateralReleased);
    }

    /**
     * @dev Helper function to ensure the `msg.sender` is approved by governance and the `_accountAddress`. If either
     * has not approved, this transaction will revert.
     * NOTE: This function updates the account's approved amount for the collateralizable address. The caller should
     * use that amount or revert.
     * @param _collateralizableAddress The address of the collateralizable in question.
     * @param _accountAddress The account address that must have approved the calling collateralizable contract.
     * @param _tokenAddress The address of the token being verified and for which the allowance will be decreased.
     * @param _amount the amount that must be approved and by which the collateralizable allowance will be decreased.
     */
    function _requireCollateralizableAndDecreaseApprovedAmount(
        address _collateralizableAddress,
        address _accountAddress,
        address _tokenAddress,
        uint256 _amount
    ) internal {
        if (_collateralizableAddress == _accountAddress) {
            return;
        }
        if (!collateralizableContracts[_collateralizableAddress])
            revert ContractNotApprovedByProtocol(_collateralizableAddress);

        uint256 approvedAmount = accountCollateralizableTokenAllowances[_accountAddress][_collateralizableAddress][
            _tokenAddress
        ];
        if (approvedAmount < _amount)
            revert InsufficientAllowance(
                _collateralizableAddress,
                _accountAddress,
                _tokenAddress,
                _amount,
                approvedAmount
            );

        accountCollateralizableTokenAllowances[_accountAddress][_collateralizableAddress][_tokenAddress] =
            approvedAmount -
            _amount;
    }

    /**
     * @notice Reserves `_accountAddress`'s collateral on behalf of the `_reservingContract` so that it may not be rehypothecated.
     * @dev Note that the full _amount reserved will not be withdrawable via a claim due to withdrawalFeeBasisPoints.
     * The max that can be claimed is _amount * (10000 - withdrawalFeeBasisPoints) / 10000.
     * Use `reserveClaimableCollateral` to reserve a specific claimable amount.
     * @param _reservingContract The contract that called this contract to reserve the collateral.
     * @param _accountAddress The address of the account whose funds are being reserved.
     * @param _tokenAddress The address of the Token being reserved as collateral.
     * @param _reservedCollateral The total amount of the Token being reserved as collateral.
     * @param _claimableCollateral The collateral that may be claimed (factoring in the withdrawal fee).
     * @return _reservationId The ID that can be used to refer to this reservation when claiming or releasing collateral.
     */
    function _reserveCollateral(
        address _reservingContract,
        address _accountAddress,
        address _tokenAddress,
        uint256 _reservedCollateral,
        uint256 _claimableCollateral
    ) private onlyEnabledCollateralTokens(_tokenAddress) returns (uint96 _reservationId) {
        if (_claimableCollateral == 0) revert ClaimableAmountZero();

        _requireCollateralizableAndDecreaseApprovedAmount(
            _reservingContract,
            _accountAddress,
            _tokenAddress,
            _reservedCollateral
        );

        CollateralBalance storage accountBalanceStorage = accountBalances[_accountAddress][_tokenAddress];
        uint256 available = accountBalanceStorage.available;
        if (available < _reservedCollateral) revert InsufficientCollateral(_reservedCollateral, available);
        // sanity check -- this can never happen.
        if (_reservedCollateral < _claimableCollateral)
            revert InsufficientCollateral(_claimableCollateral, _reservedCollateral);

        accountBalanceStorage.available = available - _reservedCollateral;
        accountBalanceStorage.reserved += _reservedCollateral;

        uint16 withdrawalFee = withdrawalFeeBasisPoints;
        // NB: Return fields
        _reservationId = ++collateralReservationNonce;

        collateralReservations[_reservationId] = CollateralReservation(
            _reservingContract,
            _accountAddress,
            _tokenAddress,
            withdrawalFee,
            _reservedCollateral,
            _claimableCollateral
        );

        emit CollateralReserved(
            _reservationId,
            _accountAddress,
            _reservingContract,
            _tokenAddress,
            _reservedCollateral,
            _claimableCollateral,
            withdrawalFee
        );
    }

    /**
     * @dev Transfers tokens from the provided address's available balance to the available balance of the provided
     * destination address without incurring a fee.
     * NOTE: Since this function is private it trusts the caller to do authentication.
     * @param _tokenAddress The token to transfer.
     * @param _fromAddress The token sender's address.
     * @param _amount The amount of tokens being transferred.
     * @param _destinationAddress The token receiver's address.
     */
    function _transferCollateral(
        address _tokenAddress,
        address _fromAddress,
        uint256 _amount,
        address _destinationAddress
    ) private {
        if (_amount == 0 || _fromAddress == _destinationAddress) {
            // NB: 0 amounts should not revert, as transferCollateral may be used by pool contracts to do the reverse of
            // poolCollateral(...). If those contracts do not check for 0, reverting here may cause them to deadlock.
            return;
        }

        CollateralBalance storage fromStorage = accountBalances[_fromAddress][_tokenAddress];
        uint256 fromAvailable = fromStorage.available;
        if (_amount > fromAvailable) {
            revert InsufficientCollateral(_amount, fromAvailable);
        }

        accountBalances[_destinationAddress][_tokenAddress].available += _amount;
        fromStorage.available = fromAvailable - _amount;

        emit CollateralTransferred(_fromAddress, _tokenAddress, _destinationAddress, _amount);
    }

    /**
     * @notice Verifies that the provided collateral token is enabled by the protocol (owner), reverting if it is not.
     * @param _collateralTokenAddress The address of the collateral token being verified.
     */
    function _verifyTokenEnabled(address _collateralTokenAddress) private view {
        if (!collateralTokens[_collateralTokenAddress].enabled) revert TokenNotAllowed(_collateralTokenAddress);
    }

    /**
     * @dev verifies the provided collateralizable deposit approval signature, reverting with InvalidSignature if not valid.
     * Note: this function exists and is virtual so it can be overridden in tests that care to test the deposit
     * functionality but mock or otherwise ignore signature checking.
     * @param _accountAddress The address of the account that should have signed the deposit approval.
     * @param _tokenAddress The address of the token of the deposit approval.
     * @param _amount The amount of the deposit approval.
     * @param _signature The signature being verified.
     */
    function _verifyDepositApprovalSignature(
        address _accountAddress,
        address _tokenAddress,
        uint256 _amount,
        bytes memory _signature
    ) internal virtual {
        bytes32 hash = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    COLLATERALIZABLE_DEPOSIT_APPROVAL_TYPEHASH,
                    msg.sender,
                    _tokenAddress,
                    _amount,
                    _useNonce(_accountAddress, COLLATERALIZABLE_DEPOSIT_APPROVAL_TYPEHASH)
                )
            )
        );
        if (!SignatureChecker.isValidSignatureNow(_accountAddress, hash, _signature)) {
            revert InvalidSignature(_accountAddress);
        }
    }
}
// SPDX-License-Identifier: ISC
pragma solidity 0.8.25;

/**
 * @title Library with often used math-related helper functions related to the Anvil protocol.
 *
 * @custom:security-contact security@af.xyz
 */
library Pricing {
    error CastOverflow(uint256 input);

    /// Example: human-readable price is 25000, {price: 25, exponent: 3, ...}
    /// Example: human-readable price is 0.00004, {price: 4, exponent: -5, ...}
    struct OraclePrice {
        // Price
        uint256 price;
        // The exchange rate may be a decimal, but it will always be represented as a uint256.
        // The price should be multiplied by 10**exponent to get the proper scale.
        int32 exponent;
        // Unix timestamp describing when the price was published
        uint256 publishTime;
    }

    /**
     * @notice Calculates the collateral factor implied by the provided amounts of collateral and credited tokens.
     * @param _collateralTokenAmount The amount of the collateral token.
     * @param _creditedTokenAmount The amount of the credited token.
     * @param _price The price of the market in which the collateral is the input token and credited is the output token.
     * @return The calculated collateral factor in basis points.
     */
    function collateralFactorInBasisPoints(
        uint256 _collateralTokenAmount,
        uint256 _creditedTokenAmount,
        OraclePrice memory _price
    ) internal pure returns (uint16) {
        uint256 collateralInCredited = collateralAmountInCreditedToken(_collateralTokenAmount, _price);
        // Don't divide by 0
        if (collateralInCredited == 0) {
            return 0;
        }
        return uint16((_creditedTokenAmount * 10_000) / collateralInCredited);
    }

    /**
     * @notice Calculates the amount of the credited token the provided collateral would yield, given the provided price.
     * @param _collateralTokenAmount The amount of the collateral token.
     * @param _price The price of the market in which the collateral is the input token and credited is the output token.
     * @return _creditedTokenAmount The calculated amount of the credited token.
     */
    function collateralAmountInCreditedToken(
        uint256 _collateralTokenAmount,
        OraclePrice memory _price
    ) internal pure returns (uint256) {
        if (_price.exponent < 0) {
            return (_collateralTokenAmount * _price.price) / (10 ** uint256(int256(-1 * _price.exponent)));
        } else {
            return _collateralTokenAmount * _price.price * (10 ** uint256(int256(_price.exponent)));
        }
    }

    /**
     * @notice Calculates the provided percentage of the provided amount.
     * @param _amount The base amount for which the percentage will be calculated.
     * @param _percentageBasisPoints The percentage, represented in basis points. For example, 10_000 is 100%.
     * @return The resulting percentage.
     */
    function percentageOf(uint256 _amount, uint256 _percentageBasisPoints) internal pure returns (uint256) {
        return (_amount * _percentageBasisPoints) / 10_000;
    }

    /**
     * @notice Gets the result of the provided amount being increased by a relative fee.
     * @dev This is the exact reverse of the `amountBeforeFee` function. Please note that calling one
     * and then the other is not guaranteed to produce the starting value due to integer math.
     * @param _amount The amount, to which the fee will be added.
     * @param _feeBasisPoints The relative basis points value that amount should be increased by.
     * @return The resulting amount with the relative fee applied.
     */
    function amountWithFee(uint256 _amount, uint16 _feeBasisPoints) internal pure returns (uint256) {
        return _amount + percentageOf(_amount, uint256(_feeBasisPoints));
    }

    /**
     * @notice Given an amount with a relative fee baked in, returns the amount before the fee was added.
     * @dev This is the exact reverse of the `amountWithFee` function. Please note that calling one
     * and then the other is not guaranteed to produce the starting value due to integer math.
     * @param _amountWithFee The amount that includes the provided fee in its value.
     * @param _feeBasisPoints The basis points value of the fee baked into the provided amount.
     * @return The value of _amountWithFee before the _feeBasisPoints was added to it.
     */
    function amountBeforeFee(uint256 _amountWithFee, uint16 _feeBasisPoints) internal pure returns (uint256) {
        return (_amountWithFee * 10_000) / (10_000 + _feeBasisPoints);
    }

    /**
     * @dev Calculates the amount that is proportional to the provided fraction, given the denominator of the amount.
     * For instance if a1/a2 = b1/b2, then b1 = calculateProportionOfTotal(a1, a2, b2).
     * @param _aPortion The numerator of the reference proportion used to calculate the other numerator.
     * @param _aTotal The numerator of the reference proportion used to calculate the other numerator.
     * @param _bTotal The denominator for which we are calculating the numerator such that aPortion/aTotal = bPortion/bTotal.
     * @param _bPortion The numerator that is an equal proportion of _bTotal that _aPortion is to _aTotal.
     */
    function calculateProportionOfTotal(
        uint256 _aPortion,
        uint256 _aTotal,
        uint256 _bTotal
    ) internal pure returns (uint256 _bPortion) {
        if (_aTotal == 0) return 0;

        // NB: It is a conscious choice to not catch overflows before they happen. This means that callers need to
        // handle possible overflow reverts, but it saves gas for the great majority of cases.

        // _bPortion / _bTotal = _aPortion / _aTotal;
        // _bPortion = _bTotal * _aPortion / _aTotal
        _bPortion = (_bTotal * _aPortion) / _aTotal;
    }

    /**
     * @dev Safely casts the provided uint256 to an int256, reverting with CastOverflow on overflow.
     * @param _input The input uint256 to cast.
     * @return The safely casted uint256.
     */
    function safeCastToInt256(uint256 _input) internal pure returns (int256) {
        if (_input > uint256(type(int256).max)) {
            revert CastOverflow(_input);
        }
        return int256(_input);
    }
}
// SPDX-License-Identifier: ISC
pragma solidity 0.8.25;

/**
 * @notice Builds off of "@openzeppelin/contracts/utils/Nonces.sol" by copying its code to make the nonces more useful
 * for signatures, namely:
 * - tracking nonces per account per operation rather than just per account
 * - allowing public nonce use by the account in question (e.g. for cancellation)
 *
 * @custom:security-contact security@af.xyz
 */
abstract contract SignatureNonces {
    /// @dev The nonce used for an `account` and `signatureType` is not the expected current nonce.
    error InvalidNonce(address account, bytes32 signatureType, uint256 currentNonce);

    /// @dev More than `maxNoncesUsedAtOneTime()` nonces are being used at once.
    error SimultaneousUseLimitExceeded(uint256 amountRequested, uint256 max);

    /// account address => signature type (e.g. a hash) => nonce
    mapping(address => mapping(bytes32 => uint256)) private _accountTypeNonces;

    /**
     * @dev Returns the next unused nonce for an address and signature type.
     */
    function nonces(address _owner, bytes32 _signatureType) public view virtual returns (uint256) {
        return _accountTypeNonces[_owner][_signatureType];
    }

    /**
     * @dev The maximum number of nonces that can be used at one time in `_useNoncesUpToAndIncluding`.
     *
     * NOTE: This may be overridden, but the definition of a nonce is that it will not be reused. Setting this to a
     * larger number increases the risk of overflow and reuse.
     * See: `unchecked` blocks in `_useNonce` and `_useNoncesUpToAndIncluding`.
     * @return The maximum number of nonces that may be used at one time.
     */
    function maxNoncesUsedAtOneTime() public view virtual returns (uint256) {
        // This is large enough to allow many to be used at once and supports over 1e74 uses of the max before overflow.
        return 1_000;
    }

    /**
     * @dev Uses all nonces up to and including the provided nonce for the (sender, signature type) pair. A simple use
     * case for this function is to cancel a signature, nullifying the nonce that has been included in it. This function
     * also allows multiple nonces to be used/canceled at once or to cancel a future nonce if many have been exposed.
     *
     * Note: the amount of nonces used is capped by `maxNoncesUsedAtOneTime` and should be tiny compared to `type(uint256).max`.
     * @param _signatureType The signature type for the nonces being used.
     * @param _upToAndIncludingNonce The greatest sequential nonce being used.
     */
    function useNoncesUpToAndIncluding(bytes32 _signatureType, uint256 _upToAndIncludingNonce) public virtual {
        _useNoncesUpToAndIncluding(msg.sender, _signatureType, _upToAndIncludingNonce);
    }

    /**
     * @dev Consumes a nonce for the provided owner and signature type.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address _owner, bytes32 _signatureType) internal virtual returns (uint256) {
        // For each account and signature type, the nonce has an initial value of 0, a relatively small number of nonces
        // may be used at one time, and the nonce cannot be decremented or reset.
        // This makes nonce overflow infeasible.
        unchecked {
            // It is important to do x++ and not ++x here.
            return _accountTypeNonces[_owner][_signatureType]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address _owner, bytes32 _signatureType, uint256 _nonce) internal virtual {
        uint256 current = _useNonce(_owner, _signatureType);
        if (_nonce != current) {
            revert InvalidNonce(_owner, _signatureType, current);
        }
    }

    /**
     * @dev Internal function with the same signature as `useNoncesUpToAndIncluding`, assuming authorization has been done.
     */
    function _useNoncesUpToAndIncluding(
        address _owner,
        bytes32 _signatureType,
        uint256 _upToAndIncludingNonce
    ) internal virtual {
        uint256 currentNonce = nonces(_owner, _signatureType);
        if (currentNonce > _upToAndIncludingNonce) revert InvalidNonce(_owner, _signatureType, currentNonce);

        // maxNoncesUsedAtOneTime returning a relatively small number makes underflow and overflow infeasible.
        unchecked {
            uint256 newNonce = _upToAndIncludingNonce + 1;
            if (newNonce - currentNonce > maxNoncesUsedAtOneTime())
                revert SimultaneousUseLimitExceeded(newNonce - currentNonce, maxNoncesUsedAtOneTime());

            _accountTypeNonces[_owner][_signatureType] = newNonce;
        }
    }
}
// SPDX-License-Identifier: ISC
pragma solidity 0.8.25;

import "./ICollateralDepositTarget.sol";

/**
 * @title The Collateral interface that must be exposed to make stored collateral useful to a Collateralizable contract.
 */
interface ICollateral is ICollateralDepositTarget {
    /***************
     * ERROR TYPES *
     ***************/

    error CollateralReservationNotFound(uint96 _id);
    error ContractNotApprovedByProtocol(address _contract);
    error ClaimAmountZero();
    error ClaimableAmountZero();
    error InsufficientAllowance(
        address _contract,
        address _accountAddress,
        address _tokenAddress,
        uint256 _need,
        uint256 _have
    );
    error InsufficientCollateral(uint256 _need, uint256 _have);
    error InvalidSignature(address _accountAddress);
    error InvalidTargetAddress(address _address);
    error InvalidUpgradeTarget(address _contract);
    error InvalidZeroAmount();
    error RelatedArraysLengthMismatch(uint256 _firstLength, uint256 _secondLength);
    error TokenNotAllowed(address _address);
    error Unauthorized(address _address);
    error WithdrawalFeeTooHigh(uint16 _wouldBeValue, uint16 _max);

    /**********
     * EVENTS *
     **********/

    // common protocol events
    event AccountCollateralizableContractAllowanceUpdated(
        address indexed account,
        address indexed contractAddress,
        address indexed tokenAddress,
        int256 modifiedByAmount,
        uint256 newTotal
    );
    event AccountInitiatedUpgrade(
        address indexed account,
        address indexed toCollateralContract,
        address[] tokenAddresses,
        uint256[] amounts
    );

    event CollateralClaimed(
        uint96 indexed reservationId,
        uint256 amountWithFee,
        uint256 feeAmount,
        bool remainderReleased
    );
    event CollateralReleased(uint96 indexed reservationId, uint256 amount);
    event CollateralReservationModified(
        uint96 indexed reservationId,
        uint256 oldAmount,
        uint256 newAmount,
        uint256 oldClaimableAmount,
        uint256 newClaimableAmount
    );
    event CollateralReserved(
        uint96 indexed reservationId,
        address indexed account,
        address reservingContract,
        address tokenAddress,
        uint256 amount,
        uint256 claimableAmount,
        uint16 claimFeeBasisPoints
    );
    event CollateralTransferred(
        address indexed fromAccount,
        address indexed tokenAddress,
        address indexed toAccount,
        uint256 tokenAmount
    );

    event FundsDeposited(address indexed from, address indexed toAccount, address tokenAddress, uint256 amount);
    event FundsWithdrawn(
        address indexed fromAccount,
        address tokenAddress,
        uint256 amountWithFee,
        uint256 feeAmount,
        address beneficiary
    );

    // governance events
    event CollateralizableContractApprovalUpdated(bool approved, address contractAddress, bool isCollateralPool);
    event CollateralTokenUpdated(bool enabled, address tokenAddress);
    event CollateralUpgradeContractApprovalUpdated(bool approved, address upgradeContractAddress);
    event ProtocolBalanceWithdrawn(address indexed destination, address[] tokenAddresses, uint256[] amounts);
    event WithdrawalFeeUpdated(uint16 oldFeeBasisPoints, uint16 newFeeBasisPoints);

    /***********
     * STRUCTS *
     ***********/

    struct CollateralBalance {
        uint256 available;
        uint256 reserved;
    }

    struct CollateralToken {
        // total deposits for all users for this token.
        uint256 cumulativeUserBalance;
        bool enabled;
    }

    struct CollateralReservation {
        address collateralizableContract;
        address account;
        address tokenAddress;
        uint16 feeBasisPoints;
        uint256 tokenAmount;
        uint256 claimableTokenAmount;
    }

    /*************
     * FUNCTIONS *
     *************/

    /*** Views ***/

    /**
     * @notice Gets the CollateralToken with the provided address. If this collateral token does not exist, it will
     * not revert but return a CollateralToken with default values for every field.
     * @param _tokenAddress The address of the CollateralToken being fetched.
     * @return _token The populated CollateralToken if found, empty otherwise.
     */
    function getCollateralToken(address _tokenAddress) external view returns (CollateralToken memory _token);

    /**
     * @notice Gets the CollateralBalance for the provided account and token.
     * @param _accountAddress The account for which the CollateralBalance will be returned.
     * @param _tokenAddress The address of the token for which the account's CollateralBalance will be returned.
     * @return _balance The CollateralBalance for the account and token.
     */
    function getAccountCollateralBalance(
        address _accountAddress,
        address _tokenAddress
    ) external view returns (CollateralBalance memory _balance);

    /**
     * @notice Gets the CollateralReservation for the provided ID.
     * @dev NOTE: If a reservation does not exist for the provided ID, an empty CollateralReservation will be returned.
     * @param _reservationId The ID of the CollateralReservation to be returned.
     * @return _reservation The CollateralReservation.
     */
    function getCollateralReservation(
        uint96 _reservationId
    ) external view returns (CollateralReservation memory _reservation);

    /**
     * @notice Gets the claimable amount for the provided CollateralReservation ID.
     * @dev NOTE: If a reservation does not exist for the provided ID, 0 will be returned.
     * @param _reservationId The ID of the CollateralReservation to be returned.
     * @return _claimable The claimable amount.
     */
    function getClaimableAmount(uint96 _reservationId) external view returns (uint256 _claimable);

    /**
     * @notice Gets amount of the account's assets in the provided token that the Collateralizable contract may use
     * through this contract.
     * @param _accountAddress The address of the account in question.
     * @param _collateralizableContract The address of the Collateralizable contract.
     * @param _tokenAddress The address of the token to which the allowance pertains.
     * @return _allowance The allowance for the account-collateralizable-token combination. Note: If collateral is
     * released, it is added to the allowance, so negative allowances are allowed to disable future collateral use.
     */
    function getCollateralizableTokenAllowance(
        address _accountAddress,
        address _collateralizableContract,
        address _tokenAddress
    ) external view returns (uint256 _allowance);

    /**
     * @notice Gets the fee for withdrawing funds from this vault, either directly or through claim.
     * @return The fee in basis points.
     */
    function getWithdrawalFeeBasisPoints() external view returns (uint16);

    /*** State-modifying functions ***/

    /**
     * @notice Claims reserved collateral, withdrawing it from the ICollateral contract.
     * @dev The ICollateral contract will handle fee calculation and transfer _amountToReceive, supposing there is
     * sufficient collateral reserved to cover _amountToReceive and the _reservationId's _claimFeeBasisPoints.
     * @param _reservationId The ID of the collateral reservation in question.
     * @param _amountToReceive The amount of collateral needed.
     * @param _toAddress The address to which the `_amountToReceive` will be sent.
     * @param _releaseRemainder Whether or not the remaining collateral should be released.
     * Note: if the full amount is claimed, regardless of this value, the reservation is deleted.
     * @return _remainingReservedCollateral The amount of collateral that remains reserved, if not released.
     * @return _remainingClaimableCollateral The portion of the remaining collateral that may be claimed.
     */
    function claimCollateral(
        uint96 _reservationId,
        uint256 _amountToReceive,
        address _toAddress,
        bool _releaseRemainder
    ) external returns (uint256 _remainingReservedCollateral, uint256 _remainingClaimableCollateral);

    /**
     * @notice Deposits the provided amount of the specified token into the specified account. Assets are sourced from
     * the specified account's ERC-20 token balance.
     *
     * Note: Even if an account has previously approved a collateralizable to use its collateral, it must provide a
     * deposit signature allowing it to deposit on its behalf. If the account-collateralizable allowance is less than
     * the amount being deposited, the result of this call will be that the account-collateraliazble allowance is equal
     * to the amount being deposited. If the allowance was already sufficient to use this newly deposited amount, the
     * allowance will remain the same.
     *
     * @param _accountAddress The account address from which assets will be deposited and with which deposited assets will
     * be associated in this contract.
     * @param _tokenAddress The address of the token to be deposited.
     * @param _amount The amount of the token to be deposited.
     * @param _collateralizableDepositApprovalSignature Deposit approval signature permitting the calling collateralizable
     * to deposit the account's collateral. This enables deposit-approve-and-use functionality in a single transaction.
     */
    function depositFromAccount(
        address _accountAddress,
        address _tokenAddress,
        uint256 _amount,
        bytes calldata _collateralizableDepositApprovalSignature
    ) external;

    /**
     * @notice Modifies the amount of the calling account's assets the Collateralizable contract may use through this contract.
     * @param _collateralizableContractAddress The address of the Collateralizable contract `msg.sender` is [dis]allowing.
     * @param _tokenAddress The address of the token for which the allowance is being checked and updated.
     * @param _byAmount The signed number by which the approved amount will be modified. Negative approved amounts
     * function the same as 0 when attempting to reserve collateral. An account may choose to modify such that the allowance
     * is negative since reservations, once released, add to the approved amount since those assets were previously approved.
     */
    function modifyCollateralizableTokenAllowance(
        address _collateralizableContractAddress,
        address _tokenAddress,
        int256 _byAmount
    ) external;

    /**
     * @notice Approves the provided collateralizable contract on behalf of the provided account address using the
     * account's signature.
     * @dev The signature is the EIP-712 signature formatted according to the following type hash variable:
     * bytes32 public constant COLLATERALIZABLE_TOKEN_ALLOWANCE_ADJUSTMENT_TYPEHASH =
     *  keccak256("CollateralizableTokenAllowanceAdjustment(uint256 chainId,address approver,address collateralizableAddress,address tokenAddress,int256 allowanceAdjustment,uint256 approverNonce)");
     *
     * If this call is not successful, it will revert. If it succeeds, the caller may assume the modification succeeded.
     * @param _accountAddress The account for which approval will take place.
     * @param _collateralizableContractAddress The address of the collateralizable to approve.
     * @param _allowanceAdjustment The allowance adjustment to approve. Note: this is a relative amount.
     * @param _signature The signature to prove the account has authorized the approval.
     */
    function modifyCollateralizableTokenAllowanceWithSignature(
        address _accountAddress,
        address _collateralizableContractAddress,
        address _tokenAddress,
        int256 _allowanceAdjustment,
        bytes calldata _signature
    ) external;

    /**
     * @notice Adds/removes collateral to/from the reservation in question, leaving the reservation intact.
     * @dev This call will revert if the modification is not successful.
     * @param _reservationId The ID of the collateral reservation.
     * @param _byAmount The amount by which the reservation will be modified (adding if positive, removing if negative).
     * @return _reservedCollateral The total resulting reserved collateral.
     * @return _claimableCollateral The total resulting claimable collateral.
     */
    function modifyCollateralReservation(
        uint96 _reservationId,
        int256 _byAmount
    ) external returns (uint256 _reservedCollateral, uint256 _claimableCollateral);

    /**
     * @notice Pools assets from the provided account within the collateral contract into the calling Pool's account.
     * This allows the caller to use assets from one or more accounts as a pool of assets.
     * @dev This assumes the `_fromAccount` has given `msg.sender` permission to pool the provided amount of the token.
     * @param _fromAccount The account from which collateral assets will be pooled.
     * @param _tokenAddress The address of the token to pool.
     * @param _tokensToPool The number of tokens to pool from the provided account.
     */
    function poolCollateral(address _fromAccount, address _tokenAddress, uint256 _tokensToPool) external;

    /**
     * @notice Releases all collateral from the reservation in question, releasing the reservation.
     * @param _reservationId The ID of the collateral reservation.
     * @return _totalCollateralReleased The collateral amount that was released.
     */
    function releaseAllCollateral(uint96 _reservationId) external returns (uint256 _totalCollateralReleased);

    /**
     * @notice Reserves collateral from the storing contract so that it may not be rehypothecated.
     * @dev This call reserves the requisite amount of collateral such that the full `_amount` may be claimed. That is
     * to say that `_amount` + `_claimFeeBasisPoints` will actually be reserved.
     * @param _accountAddress The address of the account whose assets are being reserved.
     * @param _tokenAddress The address of the Token being reserved as collateral.
     * @param _claimableAmount The amount of the Token that must be claimable.
     * @return _reservationId The ID that can be used to refer to this reservation when claiming or releasing collateral.
     * @return _totalAmountReserved The total amount reserved from the account in question.
     */
    function reserveClaimableCollateral(
        address _accountAddress,
        address _tokenAddress,
        uint256 _claimableAmount
    ) external returns (uint96 _reservationId, uint256 _totalAmountReserved);

    /**
     * @notice Reserves collateral from the storing contract so that it may not be rehypothecated.
     * @dev Note that the full _amount reserved will not be received when claimed due to _claimFeeBasisPoints. Supposing
     * the whole amount is claimed, _amount * (1000 - _claimFeeBasisPoints) / 1000 will be received if claimed.
     * @param _accountAddress The address of the account whose assets are being reserved.
     * @param _tokenAddress The address of the Token being reserved as collateral.
     * @param _amount The amount of the Token being reserved as collateral.
     * @return _reservationId The ID that can be used to refer to this reservation when claiming or releasing collateral.
     * @return _claimableCollateral The collateral that may be claimed (factoring in the withdrawal fee).
     */
    function reserveCollateral(
        address _accountAddress,
        address _tokenAddress,
        uint256 _amount
    ) external returns (uint96 _reservationId, uint256 _claimableCollateral);

    /**
     * @notice Transfers the provided amount of the caller's available collateral to the provided destination address.
     * @param _tokenAddress The address of the collateral token being transferred.
     * @param _amount The number of collateral tokens being transferred.
     * @param _destinationAddress The address of the account to which assets will be released.
     */
    function transferCollateral(address _tokenAddress, uint256 _amount, address _destinationAddress) external;

    /**
     * @notice Withdraws an ERC-20 token from this `Collateral` vault to the provided address on behalf of the sender,
     * provided the requester has sufficient available balance.
     * @notice There is a protocol fee for withdrawals, so a successful withdrawal of `_amount` will entail the
     * account's balance being lowered by `_amount`, but the `_destination` address receiving `_amount` less the fee.
     * @param _tokenAddress The token address of the ERC-20 token to withdraw.
     * @param _amount The amount of the ERC-20 token to withdraw.
     * @param _destinationAddress The address that will receive the assets. Note: cannot be 0.
     */
    function withdraw(address _tokenAddress, uint256 _amount, address _destinationAddress) external;
}
// SPDX-License-Identifier: ISC
pragma solidity 0.8.25;

/**
 * @title An interface allowing the deposit of assets into a new ICollateral contract for benefit of a specified account.
 * @dev This function may be used to transfer account assets from one ICollateral contract to another as an upgrade.
 */
interface ICollateralDepositTarget {
    /**
     * @notice Deposits assets from the calling contract into the implementing target on behalf of users.
     * @dev The calling contract should iterate and approve _amounts of all Tokens in _tokenAddresses to be transferred
     * by the implementing contract.
     * @dev The implementing contract MUST iterate and transfer each of the Tokens in _tokenAddresses and transfer the
     * _amounts to itself from the calling contract or revert if that is not possible.
     * @param _accountAddress The address of the account to be credited assets in the implementing contract.
     * @param _tokenAddresses The list of addresses of the Tokens to transfer. Indexes must correspond to _amounts.
     * @param _amounts The list of amounts of the Tokens to transfer. Indexes must correspond to _tokenAddresses.
     */
    function depositToAccount(
        address _accountAddress,
        address[] calldata _tokenAddresses,
        uint256[] calldata _amounts
    ) external;
}
// SPDX-License-Identifier: ISC
pragma solidity 0.8.25;

/**
 * @title The interface that should be implemented by all collateral pools using ICollateral's pooling functions.
 */
interface ICollateralPool {
    /**
     * @notice Gets the provided account's pool balance in the provided token. This should be calculated based on the
     * account's stake in the pool, multiplied by the pool's balance of the token in question.
     * In many cases, some or all of this amount will be staked, locked, or otherwise inaccessible by the account at the
     * time of the call, but the account's current portion of the pool will still be returned.
     *
     * Note: if staked, locked, or otherwise inaccessible, the account's pool balance may be at risk of future seizure.
     * That is to say that the value returned from this function may not be the future withdrawable balance for the account.
     * @param _accountAddress The address of the account for which the pool balance will be returned.
     * @param _tokenAddress The address of the token for which the account pool balance will be returned.
     * @return _balance The balance of the account in the pool at this moment in time.
     */
    function getAccountPoolBalance(
        address _accountAddress,
        address _tokenAddress
    ) external view returns (uint256 _balance);
}