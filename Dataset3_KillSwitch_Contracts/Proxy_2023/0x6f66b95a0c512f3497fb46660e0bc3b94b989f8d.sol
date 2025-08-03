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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
pragma solidity ^0.8.20;

interface IChainalysisSanctionsOracle {
    function isSanctioned(address addr) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin-contracts-5.0.2/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IChainalysisSanctionsOracle} from "./IChainalysisSanctionsOracle.sol";

/// @title Sanctions Compliance
/// @notice Abstract contract to comply with U.S. sanctioned addresses
/// @dev Uses the Chainalysis Sanctions Oracle for checking sanctions
/// @author transientlabs.xyz
/// @custom:version 3.0.0
contract SanctionsCompliance {
    /*//////////////////////////////////////////////////////////////////////////
                                State Variables
    //////////////////////////////////////////////////////////////////////////*/

    IChainalysisSanctionsOracle public oracle;

    /*//////////////////////////////////////////////////////////////////////////
                                    Errors
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Sanctioned address by OFAC
    error SanctionedAddress();

    /*//////////////////////////////////////////////////////////////////////////
                                    Events
    //////////////////////////////////////////////////////////////////////////*/

    event SanctionsOracleUpdated(address indexed prevOracle, address indexed newOracle);

    /*//////////////////////////////////////////////////////////////////////////
                                    Constructor
    //////////////////////////////////////////////////////////////////////////*/

    constructor(address initOracle) {
        _updateSanctionsOracle(initOracle);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Internal Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Internal function to change the sanctions oracle
    /// @param newOracle The new sanctions oracle address
    function _updateSanctionsOracle(address newOracle) internal {
        address prevOracle = address(oracle);
        oracle = IChainalysisSanctionsOracle(newOracle);

        emit SanctionsOracleUpdated(prevOracle, newOracle);
    }

    /// @notice Internal function to check the sanctions oracle for an address
    /// @dev Disable sanction checking by setting the oracle to the zero address
    /// @param sender The address that is trying to send money
    /// @param shouldRevertIfSanctioned A flag indicating if the call should revert if the sender is sanctioned. Set to false if wanting to get a result.
    /// @return isSanctioned Boolean indicating if the sender is sanctioned
    function _isSanctioned(address sender, bool shouldRevertIfSanctioned) internal view returns (bool isSanctioned) {
        if (address(oracle) == address(0)) {
            return false;
        }
        isSanctioned = oracle.isSanctioned(sender);
        if (shouldRevertIfSanctioned && isSanctioned) revert SanctionedAddress();
        return isSanctioned;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SafeERC20} from "@openzeppelin-contracts-5.0.2/token/ERC20/utils/SafeERC20.sol";
import {IWETH, IERC20} from "./IWETH.sol";

/// @title Transfer Helper
/// @notice Abstract contract that has helper function for sending ETH and ERC20's safely
/// @author transientlabs.xyz
/// @custom:version 3.0.0
abstract contract TransferHelper {
    /*//////////////////////////////////////////////////////////////////////////
                                    Types
    //////////////////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;
    using SafeERC20 for IWETH;

    /*//////////////////////////////////////////////////////////////////////////
                                    Errors
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev ETH transfer failed
    error ETHTransferFailed();

    /// @dev Transferred too few ERC-20 tokens
    error InsufficentERC20Transfer();

    /*//////////////////////////////////////////////////////////////////////////
                                   ETH Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to force transfer ETH, defaulting to forwarding 100k gas
    /// @dev On failure to send the ETH, the ETH is converted to WETH and sent
    /// @dev Care should be taken to always pass the proper WETH address that adheres to IWETH
    /// @param recipient The recipient of the ETH
    /// @param amount The amount of ETH to send
    /// @param weth The WETH token address
    function _safeTransferETH(address recipient, uint256 amount, address weth) internal {
        _safeTransferETH(recipient, amount, weth, 1e5);
    }

    /// @notice Function to force transfer ETH, with a gas limit
    /// @dev On failure to send the ETH, the ETH is converted to WETH and sent
    /// @dev Care should be taken to always pass the proper WETH address that adheres to IWETH
    /// @dev If the `amount` is zero, the function returns in order to save gas
    /// @param recipient The recipient of the ETH
    /// @param amount The amount of ETH to send
    /// @param weth The WETH token address
    /// @param gasLimit The gas to forward
    function _safeTransferETH(address recipient, uint256 amount, address weth, uint256 gasLimit) internal {
        if (amount == 0) return;
        (bool success,) = recipient.call{value: amount, gas: gasLimit}("");
        if (!success) {
            IWETH token = IWETH(weth);
            token.deposit{value: amount}();
            token.safeTransfer(recipient, amount);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  ERC-20 Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Function to safely transfer ERC-20 tokens from the contract, without checking for token tax
    /// @dev Does not check if the sender has enough balance as that is handled by the token contract
    /// @dev Does not check for token tax as that could lock up funds in the contract
    /// @dev Reverts on failure to transfer
    /// @dev If the `amount` is zero, the function returns in order to save gas
    /// @param recipient The recipient of the ERC-20 token
    /// @param currency The address of the ERC-20 token
    /// @param amount The amount of ERC-20 to send
    function _safeTransferERC20(address recipient, address currency, uint256 amount) internal {
        if (amount == 0) return;
        IERC20(currency).safeTransfer(recipient, amount);
    }

    /// @notice Function to safely transfer ERC-20 tokens from another address to a recipient
    /// @dev Does not check if the sender has enough balance or allowance for this contract as that is handled by the token contract
    /// @dev Reverts on failure to transfer
    /// @dev Reverts if there is a token tax taken out
    /// @dev Returns and doesn't do anything if the sender and recipient are the same address
    /// @dev If the `amount` is zero, the function returns in order to save gas
    /// @param sender The sender of the tokens
    /// @param recipient The recipient of the ERC-20 token
    /// @param currency The address of the ERC-20 token
    /// @param amount The amount of ERC-20 to send
    function _safeTransferFromERC20(address sender, address recipient, address currency, uint256 amount) internal {
        if (amount == 0) return;
        if (sender == recipient) return;
        IERC20 token = IERC20(currency);
        uint256 intialBalance = token.balanceOf(recipient);
        token.safeTransferFrom(sender, recipient, amount);
        uint256 finalBalance = token.balanceOf(recipient);
        if (finalBalance - intialBalance < amount) revert InsufficentERC20Transfer();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Ownable} from "@openzeppelin-contracts-5.0.2/access/Ownable.sol";
import {Pausable} from "@openzeppelin-contracts-5.0.2/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin-contracts-5.0.2/utils/ReentrancyGuard.sol";
import {IERC721} from "@openzeppelin-contracts-5.0.2/token/ERC721/IERC721.sol";
import {TransferHelper} from "tl-sol-tools-3.1.4/payments/TransferHelper.sol";
import {SanctionsCompliance} from "tl-sol-tools-3.1.4/payments/SanctionsCompliance.sol";
import {ListingType, Listing, ITLAuctionHouseEvents} from "./utils/TLAuctionHouseUtils.sol";
import {ICreatorLookup} from "./helpers/ICreatorLookup.sol";
import {IRoyaltyLookup} from "./helpers/IRoyaltyLookup.sol";

/// @title TLAuctionHouse
/// @notice Transient Labs Auction House for ERC-721 tokens
/// @author transientlabs.xyz
/// @custom:version-last-updated 2.6.1
contract TLAuctionHouse is
    Ownable,
    Pausable,
    ReentrancyGuard,
    SanctionsCompliance,
    TransferHelper,
    ITLAuctionHouseEvents
{
    ///////////////////////////////////////////////////////////////////////////
    /// CONSTANTS
    ///////////////////////////////////////////////////////////////////////////

    string public constant VERSION = "2.6.1";
    uint256 public constant EXTENSION_TIME = 5 minutes;
    uint256 public constant BASIS = 10_000;
    uint256 public constant BID_INCREASE_BPS = 500; // 5% increase between bids

    ///////////////////////////////////////////////////////////////////////////
    /// STATE VARIABLES
    ///////////////////////////////////////////////////////////////////////////

    uint256 private _id; // listing id
    address public protocolFeeReceiver; // receives protocol fee
    uint256 public protocolFeeBps; // basis points for protocol fee
    address public weth; // weth address
    ICreatorLookup public creatorLookup; // creator lookup contract
    IRoyaltyLookup public royaltyLookup; // royalty lookup contract

    mapping(address => mapping(uint256 => Listing)) private _listings; // nft address -> token id -> listing

    ///////////////////////////////////////////////////////////////////////////
    /// ERRORS
    ///////////////////////////////////////////////////////////////////////////

    error InvalidListingType();
    error NotTokenOwner();
    error TokenNotTransferred();
    error NotSeller();
    error ListingNotSetup();
    error AuctionStarted();
    error AuctionNotStarted();
    error AuctionNotEnded();
    error CannotBidYet();
    error CannotBuyYet();
    error InvalidRecipient();
    error BidTooLow();
    error AuctionEnded();
    error UnexpectedMsgValue();
    error InvalidProtocolFeeBps();

    ///////////////////////////////////////////////////////////////////////////
    /// CONSTRUCTOR
    ///////////////////////////////////////////////////////////////////////////

    constructor(address initOwner, address initSanctionsOracle)
        Ownable(initOwner)
        Pausable()
        ReentrancyGuard()
        SanctionsCompliance(initSanctionsOracle)
    {}

    ///////////////////////////////////////////////////////////////////////////
    /// PUBLIC FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Function to list an NFT for sale
    /// @dev Requirements
    ///      - only the token owner can list
    ///      - the token is escrowed upon listing
    ///      - if the auction house isn't approved for the token, escrowing will fail, so no need to check for that explicitly
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    /// @param type_ The ListingType
    /// @param payoutReceiver The address that will receive payout for the sale
    /// @param currencyAddress The address of the currency to use (zero address == ETH)
    /// @param openTime The time at which the listing will open (if in the past, defaults to current block timestamp)
    /// @param reservePrice The reserve price for the auction (if part of the listing type)
    /// @param auctionDuration The duration of the auction
    /// @param buyNowPrice The price at which the token can be instantly bought if the listing if properly configured for this
    function list(
        address nftAddress,
        uint256 tokenId,
        ListingType type_,
        address payoutReceiver,
        address currencyAddress,
        uint256 openTime,
        uint256 reservePrice,
        uint256 auctionDuration,
        uint256 buyNowPrice
    ) external whenNotPaused nonReentrant {
        // check for sanctioned addresses
        _isSanctioned(msg.sender, true);
        _isSanctioned(payoutReceiver, true);

        // check that the sender owns the token
        IERC721 nftContract = IERC721(nftAddress);
        if (nftContract.ownerOf(tokenId) != msg.sender) revert NotTokenOwner(); // once listed, can't list again as the msg.sender wouldn't be the owner

        // if openTime is in a previous block, set to the current block timestamp
        if (openTime < block.timestamp) {
            openTime = block.timestamp;
        }

        // create listing
        uint256 id = ++_id;
        Listing memory listing = Listing({
            type_: type_,
            zeroProtocolFee: false,
            seller: msg.sender,
            payoutReceiver: payoutReceiver,
            currencyAddress: currencyAddress,
            openTime: openTime,
            reservePrice: reservePrice,
            buyNowPrice: buyNowPrice,
            startTime: 0,
            duration: auctionDuration,
            recipient: address(0),
            highestBidder: address(0),
            highestBid: 0,
            id: id
        });

        // adjust listing based on listing type
        if (type_ == ListingType.SCHEDULED_AUCTION) {
            listing.startTime = openTime;
            listing.buyNowPrice = 0;
        } else if (type_ == ListingType.RESERVE_AUCTION) {
            listing.buyNowPrice = 0;
        } else if (type_ == ListingType.RESERVE_AUCTION_PLUS_BUY_NOW) {
            // do nothing
        } else if (type_ == ListingType.BUY_NOW) {
            listing.reservePrice = 0;
            listing.duration = 0;
        } else {
            revert InvalidListingType();
        }

        // set listing
        _listings[nftAddress][tokenId] = listing;

        // escrow token, should revert if contract isn't approved
        nftContract.transferFrom(msg.sender, address(this), tokenId);

        // check to ensure it was escrowed
        if (nftContract.ownerOf(tokenId) != address(this)) revert TokenNotTransferred();

        emit ListingConfigured(msg.sender, nftAddress, tokenId, listing);
    }

    /// @notice Function to cancel a listing
    /// @dev Requirements
    ///      - only the seller of the listing can delist
    ///      - the listing must be active
    ///      - the auction cannot have been started when delisting
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    function delist(address nftAddress, uint256 tokenId) external whenNotPaused nonReentrant {
        // cache data
        IERC721 nftContract = IERC721(nftAddress);
        Listing memory listing = _listings[nftAddress][tokenId];

        // revert if caller is not seller
        // this also catches if the nft is not listing, as the seller is the zero address
        if (msg.sender != listing.seller) revert NotSeller();

        // check if auction has been bid on (this should always pass if listing type is BUY_NOW)
        if (listing.highestBidder != address(0)) revert AuctionStarted();

        // delete listing & auction
        delete _listings[nftAddress][tokenId];

        // transfer token back to seller
        nftContract.transferFrom(address(this), listing.seller, tokenId);

        emit ListingCanceled(msg.sender, nftAddress, tokenId, listing);
    }

    /// @notice Function to bid on a token that has an auction configured
    /// @dev Requirements
    ///      - msg.sender & recipient can't be sanctioned addresses
    ///      - recipient cannot be the zero address
    ///      - a listing must be configured as an auction
    ///      - the block timestamp is past the listing open time
    ///      - the bid can't be too low (under reserve price for first bid or under next bid for subsequent bids)
    ///      - the auction can't have ended
    ///      - the funds sent must match `amount` exactly when bidding
    ///      - the previous bid is sent back
    ///      - if bidding with ERC-20 tokens, no ETH is allowed to be sent
    ///      - if a bid comes within `EXTENSION_TIME`, extend the auction back to `EXTENSION_TIME`
    ///      - the bidder can specify a recipient for the nft they are bidding on, which allows for cross-chain bids to occur
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    /// @param recipient The recipient that will receive the NFT if the bid is the winning bid
    /// @param amount The amount to bid
    function bid(address nftAddress, uint256 tokenId, address recipient, uint256 amount)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        // check sender & recipient
        _isSanctioned(msg.sender, true);
        if (!_isValidRecipient(recipient)) revert InvalidRecipient();

        // cache data
        Listing memory listing = _listings[nftAddress][tokenId];
        uint256 previousBid = listing.highestBid;
        address previousBidder = listing.highestBidder;

        // check the listing type
        if (listing.type_ == ListingType.NOT_CONFIGURED || listing.type_ == ListingType.BUY_NOW) {
            revert InvalidListingType();
        }

        // cannot bid if prior to listing.openTime
        if (block.timestamp < listing.openTime) revert CannotBidYet();

        // check constraints on first bid versus other bids
        if (previousBidder == address(0)) {
            // first bid cannot bid under reserve price
            if (amount < listing.reservePrice) revert BidTooLow();

            // set start time if reserve auction
            if (
                listing.type_ == ListingType.RESERVE_AUCTION
                    || listing.type_ == ListingType.RESERVE_AUCTION_PLUS_BUY_NOW
            ) {
                listing.startTime = block.timestamp;
            }

            // if scheduled auction, make sure that can't bid on a token that has gone past the scheduled duration without bids
            if (listing.type_ == ListingType.SCHEDULED_AUCTION) {
                if (block.timestamp > listing.startTime + listing.duration) revert AuctionEnded();
            }
        } else {
            // subsequent bids
            // cannot bid after auction is ended
            if (block.timestamp > listing.startTime + listing.duration) revert AuctionEnded();

            // ensure amount being bid is greater than minimum next bid
            if (amount < _calcNextBid(listing.highestBid)) revert BidTooLow();
        }

        // update auction, extending duration if needed
        listing.highestBid = amount;
        listing.highestBidder = msg.sender;
        listing.recipient = recipient;
        uint256 timeRemaining = listing.startTime + listing.duration - block.timestamp; // checks for being past auction end time avoid underflow issues here
        if (timeRemaining < EXTENSION_TIME) {
            listing.duration += EXTENSION_TIME - timeRemaining;
        }

        // save new listing items in storage
        _listings[nftAddress][tokenId].highestBid = listing.highestBid;
        _listings[nftAddress][tokenId].highestBidder = listing.highestBidder;
        _listings[nftAddress][tokenId].recipient = listing.recipient;
        if (_listings[nftAddress][tokenId].startTime != listing.startTime) {
            _listings[nftAddress][tokenId].startTime = listing.startTime;
        }
        if (_listings[nftAddress][tokenId].duration != listing.duration) {
            _listings[nftAddress][tokenId].duration = listing.duration;
        }

        // transfer funds as needed for the bid
        if (listing.currencyAddress == address(0)) {
            // ETH
            // escrow msg.value
            if (msg.value != amount) revert UnexpectedMsgValue();
        } else {
            // ERC-20
            // make sure they didn't send any ETH along
            if (msg.value != 0) revert UnexpectedMsgValue();

            // escrow amount from sender (not recipient)
            _safeTransferFromERC20(msg.sender, address(this), listing.currencyAddress, amount);
        }

        // return previous bid, if it's a subsequent bid
        _payout(previousBidder, listing.currencyAddress, previousBid);

        emit AuctionBid(msg.sender, nftAddress, tokenId, listing);
    }

    /// @notice Function to settle an auction
    /// @dev Requirements
    ///      - can be called by anyone on the blockchain
    ///      - the listing must be configured as an auction
    ///      - the auction must have been started AND ended
    ///      - royalties are paid out on secondary sales, where the creator of the token is not the seller
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    function settleAuction(address nftAddress, uint256 tokenId) external whenNotPaused nonReentrant {
        // cache data
        Listing memory listing = _listings[nftAddress][tokenId];

        // check to make sure the listing is the right type
        if (listing.type_ == ListingType.NOT_CONFIGURED || listing.type_ == ListingType.BUY_NOW) {
            revert InvalidListingType();
        }

        // check that auction was bid on
        if (listing.highestBidder == address(0)) revert AuctionNotStarted();

        // ensure auction is ended
        if (block.timestamp <= listing.startTime + listing.duration) revert AuctionNotEnded();

        // delete listing & auction
        delete _listings[nftAddress][tokenId];

        // settle up
        _settleUp(
            nftAddress,
            tokenId,
            listing.zeroProtocolFee,
            listing.recipient,
            listing.currencyAddress,
            listing.seller,
            listing.payoutReceiver,
            listing.highestBid
        );

        emit AuctionSettled(msg.sender, nftAddress, tokenId, listing);
    }

    /// @notice Function to buy a token at a fixed price
    /// @dev Requirements
    ///      - msg.sender and recipient cannot be sanctioned
    ///      - recipient cannot be the zero address
    ///      - listing must be configured as a reserve auction with a buy now price or just a buy now
    ///      - if it's an auction + buy now, the auction cannot be started
    ///      - the listing must be open
    ///      - royalties are paid out for secondary sales, where the creator of the token is not the seller
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    /// @param recipient The recipient that will receive the NFT if the bid is the winning bid
    function buyNow(address nftAddress, uint256 tokenId, address recipient)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        // check sender & recipient
        _isSanctioned(msg.sender, true);
        if (!_isValidRecipient(recipient)) revert InvalidRecipient();

        // cache data
        Listing memory listing = _listings[nftAddress][tokenId];

        // check the listing type
        if (
            listing.type_ == ListingType.NOT_CONFIGURED || listing.type_ == ListingType.SCHEDULED_AUCTION
                || listing.type_ == ListingType.RESERVE_AUCTION
        ) {
            revert InvalidListingType();
        }

        // cannot buy if an auction is live
        if (listing.highestBidder != address(0)) revert AuctionStarted();

        // cannot buy if prior to listing.openTime
        if (block.timestamp < listing.openTime) revert CannotBuyYet();

        // delete listing & auction
        delete _listings[nftAddress][tokenId];

        // handle funds transfer
        if (listing.currencyAddress == address(0)) {
            // ETH
            // escrow msg.value
            if (msg.value != listing.buyNowPrice) revert UnexpectedMsgValue();
        } else {
            // ERC-20
            // make sure they didn't send any ETH along
            if (msg.value != 0) revert UnexpectedMsgValue();

            // escrow amount from sender (not recipient)
            _safeTransferFromERC20(msg.sender, address(this), listing.currencyAddress, listing.buyNowPrice);
        }

        // settle up
        _settleUp(
            nftAddress,
            tokenId,
            listing.zeroProtocolFee,
            recipient,
            listing.currencyAddress,
            listing.seller,
            listing.payoutReceiver,
            listing.buyNowPrice
        );

        emit BuyNowFulfilled(msg.sender, nftAddress, tokenId, recipient, listing);
    }

    ///////////////////////////////////////////////////////////////////////////
    /// ADMIN FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Function to set a new weth address
    /// @dev Requires owner
    /// @param newWethAddress The weth contract address
    function setWethAddress(address newWethAddress) external onlyOwner {
        address prevWethAddress = weth;
        weth = newWethAddress;

        emit WethUpdated(prevWethAddress, newWethAddress);
    }

    /// @notice Function to set the protocol fee settings
    /// @dev Requires owner
    /// @dev The new protocol fee bps must be out of `BASIS`
    /// @param newProtocolFeeReceiver The new address to receive protocol fees
    /// @param newProtocolFeeBps The new bps for the protocol fee
    function setProtocolFeeSettings(address newProtocolFeeReceiver, uint256 newProtocolFeeBps) external onlyOwner {
        if (!_isValidRecipient(newProtocolFeeReceiver)) revert InvalidRecipient();
        if (newProtocolFeeBps > BASIS) revert InvalidProtocolFeeBps();

        protocolFeeReceiver = newProtocolFeeReceiver;
        protocolFeeBps = newProtocolFeeBps;

        emit ProtocolFeeUpdated(newProtocolFeeReceiver, newProtocolFeeBps);
    }

    /// @notice Function to set the sanctions oracle
    /// @dev Requires owner
    /// @param newOracle The new sanctions oracle address (zero address disables)
    function setSanctionsOracle(address newOracle) external onlyOwner {
        _updateSanctionsOracle(newOracle);
    }

    /// @notice Function to update the creator lookup contract
    /// @dev Requires owner
    /// @param newCreatorLookupAddress The helper contract address for looking up a token creator
    function setCreatorLookup(address newCreatorLookupAddress) external onlyOwner {
        address prevCreatorLookup = address(creatorLookup);
        creatorLookup = ICreatorLookup(newCreatorLookupAddress);

        emit CreatorLookupUpdated(prevCreatorLookup, newCreatorLookupAddress);
    }

    /// @notice Function to update the royalty lookup contract
    /// @dev Requires owner
    /// @param newRoyaltyLookupAddress The helper contract address for looking up token royalties
    function setRoyaltyLookup(address newRoyaltyLookupAddress) external onlyOwner {
        address prevRoyaltyLookup = address(royaltyLookup);
        royaltyLookup = IRoyaltyLookup(newRoyaltyLookupAddress);

        emit RoyaltyLookupUpdated(prevRoyaltyLookup, newRoyaltyLookupAddress);
    }

    /// @notice Function to pause the contract
    /// @dev Requires owner
    /// @param status The boolean flag for the paused status
    function pause(bool status) external onlyOwner {
        if (status) {
            _pause();
        } else {
            _unpause();
        }
    }

    /// @notice Function to remove protocol fee from a specific listing
    /// @dev Requires owner
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    function removeProtocolFee(address nftAddress, uint256 tokenId) external onlyOwner {
        if (_listings[nftAddress][tokenId].type_ == ListingType.NOT_CONFIGURED) revert InvalidListingType();

        _listings[nftAddress][tokenId].zeroProtocolFee = true;
    }

    ///////////////////////////////////////////////////////////////////////////
    /// VIEW FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Function to get a specific listing
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        Listing memory listing = _listings[nftAddress][tokenId];

        return listing;
    }

    /// @notice Function to get the next bid amount for a token
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    function getNextBid(address nftAddress, uint256 tokenId) external view returns (uint256) {
        Listing memory listing = _listings[nftAddress][tokenId];

        return _calcNextBid(listing.highestBid);
    }

    /// @notice Function to understand if the sale is a primary or secondary sale
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    function getIfPrimarySale(address nftAddress, uint256 tokenId) external view returns (bool) {
        Listing memory listing = _listings[nftAddress][tokenId];
        return creatorLookup.getCreator(nftAddress, tokenId) == listing.seller;
    }

    /// @notice Function to get the royalty amount that will be paid to the creator
    /// @param nftAddress The nft contract address
    /// @param tokenId The nft token id
    /// @param value The value to check against
    function getRoyalty(address nftAddress, uint256 tokenId, uint256 value)
        external
        view
        returns (address payable[] memory, uint256[] memory)
    {
        if (address(royaltyLookup).code.length == 0) return (new address payable[](0), new uint256[](0));
        try royaltyLookup.getRoyaltyView(nftAddress, tokenId, value) returns (
            address payable[] memory recipients, uint256[] memory amounts
        ) {
            return (recipients, amounts);
        } catch {
            return (new address payable[](0), new uint256[](0));
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    /// HELPER FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Internal function to check if an nft recipient is valid
    /// @dev Returns false if the recipient is sanctioned or if it is the zero address
    function _isValidRecipient(address recipient) private view returns (bool) {
        if (recipient == address(0)) return false;
        if (_isSanctioned(recipient, false)) return false;
        return true;
    }

    /// @notice Internal function to calculate the next bid price
    /// @param currentBid The current bid
    /// @return nextBid The next bid
    function _calcNextBid(uint256 currentBid) private pure returns (uint256 nextBid) {
        uint256 inc = currentBid * BID_INCREASE_BPS / BASIS;
        if (inc == 0) {
            return currentBid + 1;
        } else {
            return currentBid + inc;
        }
    }

    /// @notice Internal function to abstract payouts when settling a listing
    function _payout(address to, address currencyAddress, uint256 value) private {
        if (to == address(0) || value == 0) return;

        if (currencyAddress == address(0)) {
            _safeTransferETH(to, value, weth);
        } else {
            _safeTransferERC20(to, currencyAddress, value);
        }
    }

    /// @notice Internal function to settle a sale/Auction
    function _settleUp(
        address nftAddress,
        uint256 tokenId,
        bool zeroProtocolFee,
        address recipient,
        address currencyAddress,
        address seller,
        address payoutReceiver,
        uint256 value
    ) private {
        uint256 remainingValue = value;

        // take protocol fee (if not zeroed by contract owner)
        if (!zeroProtocolFee) {
            uint256 protocolFee = value * protocolFeeBps / BASIS;
            remainingValue -= protocolFee;
            _payout(protocolFeeReceiver, currencyAddress, protocolFee);
        }

        // if secondary sale, payout royalties (seller is not the creator)
        address creator = creatorLookup.getCreator(nftAddress, tokenId);
        if (seller != creator && address(royaltyLookup).code.length > 0) {
            // secondary sale
            try royaltyLookup.getRoyalty(nftAddress, tokenId, remainingValue) returns (
                address payable[] memory recipients, uint256[] memory amounts
            ) {
                if (recipients.length == amounts.length) {
                    // payout if array lengths match
                    for (uint256 i = 0; i < recipients.length; ++i) {
                        if (_isSanctioned(recipients[i], false)) continue; // don't pay to sanctioned addresses
                        if (amounts[i] > remainingValue) break;
                        remainingValue -= amounts[i];
                        _payout(recipients[i], currencyAddress, amounts[i]);
                    }
                }
            } catch {
                // do nothing if royalty lookup call fails
                // this causes the coverage test to say a line is missing coverage
            }
        }

        // pay remaining amount to payout receiver (set by the seller)
        _payout(payoutReceiver, currencyAddress, remainingValue);

        // transfer nft to recipient
        IERC721(nftAddress).transferFrom(address(this), recipient, tokenId);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title ICreatorLookup.sol
/// @notice Interface for the creator lookup helper contracts that help the TLAuctionHouse determine a primary from secondary sale
/// @author transientlabs.xyz
interface ICreatorLookup {
    /// @notice Function to lookup the creator address for a given token
    /// @dev Should return the null address if the creator can't be determined
    function getCreator(address nftAddress, uint256 tokenId) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title IRoyaltyLookup.sol
/// @notice Interface for royalty lookup helper contracts that help the TLAuctionHouse determine the royalty to pay
/// @author transientlabs.xyz
interface IRoyaltyLookup {
    /// @notice Function to lookup the creator address for a given token
    /// @dev Should attempt to use the royalty registry under the hood where possible
    function getRoyalty(address nftAddress, uint256 tokenId, uint256 value)
        external
        returns (address payable[] memory recipients, uint256[] memory amounts);

    /// @notice Funciton to lookup the creator address for a given token, but only in a read-only view
    /// @dev Should attempt to use the royalty registry under the hood where possible
    function getRoyaltyView(address nftAddress, uint256 tokenId, uint256 value)
        external
        view
        returns (address payable[] memory recipients, uint256[] memory amounts);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

enum ListingType {
    NOT_CONFIGURED,
    SCHEDULED_AUCTION,
    RESERVE_AUCTION,
    RESERVE_AUCTION_PLUS_BUY_NOW,
    BUY_NOW
}

/// @dev The Listing struct contains general information about the sale on the auction house,
/// such as the type of sale, seller, currency, when the listing opens, and the pricing mechanics (based on type)
struct Listing {
    ListingType type_;
    bool zeroProtocolFee;
    address seller;
    address payoutReceiver;
    address currencyAddress;
    uint256 openTime;
    uint256 reservePrice;
    uint256 buyNowPrice;
    uint256 startTime;
    uint256 duration;
    address recipient;
    address highestBidder;
    uint256 highestBid;
    uint256 id;
}

interface ITLAuctionHouseEvents {
    event WethUpdated(address indexed prevWeth, address indexed newWeth);
    event ProtocolFeeUpdated(address indexed newProtocolFeeReceiver, uint256 indexed newProtocolFee);
    event CreatorLookupUpdated(address indexed prevCreatorLookup, address indexed newCreatorLookup);
    event RoyaltyLookupUpdated(address indexed prevRoyaltyLookup, address indexed newRoyaltyLookup);

    event ListingConfigured(
        address indexed sender, address indexed nftAddress, uint256 indexed tokenId, Listing listing
    );
    event ListingCanceled(address indexed sender, address indexed nftAddress, uint256 indexed tokenId, Listing listing);

    event AuctionBid(address indexed sender, address indexed nftAddress, uint256 indexed tokenId, Listing listing);
    event AuctionSettled(address indexed sender, address indexed nftAddress, uint256 indexed tokenId, Listing listing);

    event BuyNowFulfilled(
        address indexed sender, address indexed nftAddress, uint256 indexed tokenId, address recipient, Listing listing
    );
}