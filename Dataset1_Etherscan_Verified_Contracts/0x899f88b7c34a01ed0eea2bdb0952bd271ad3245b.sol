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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDepositPool {
    /// @notice ERC-2612 permit. Always use this contract as spender and use
    /// msg.sender as owner
    struct PermitInput {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    event Deposited(
        address indexed from,
        address indexed to,
        address token,
        uint256 amount,
        address lsd,
        uint256 lsdAmount,
        uint256 timestamp,
        bytes32 guid,
        uint256 fee
    );

    event Withdrawn(address indexed _to, address _token, uint256 _amount, address _lsd);

    event NewWithdrawer(address withdrawer);
    event NewDepositCap(uint256 cap);
    event NewTreasury(address treasury);
    event NewLzReceiveGasLimit(uint128 gasLimit);
    event SmartSavingsOnGravityUpdated(address addr);
    event TotalLsdMintedInitialized(uint256 amount);

    error InvalidLSD();
    error InvalidVaultToken();
    error InvalidDepositAmount();
    error AmountExceedsDepositCap();
    error InvalidDepositCap(uint256 _cap);
    error SendFailed(address to, uint256 amount);
    error InvalidWithdrawer(address withdrawer);
    error InvalidWithdrawalAmount(uint256 amount);
    error InvalidAddress(address addr);
    error DepositAmountTooSmall(uint256 amount);
    error InsufficientFee(uint256 wanted, uint256 provided);
    error NotImplemented(bytes4 selector);
    error InvalidInitialLsdMinted(uint256 amount);

    function deposit(address _to, uint256 _amount, bool mintOnGravity) external payable;
    function depositWithPermit(
        address _to,
        uint256 _amount,
        bool mintOnGravity,
        PermitInput calldata _permit
    ) external payable;

    function setDepositCap(uint256 _amount) external;

    function setWithdrawer(address _withdrawer) external;

    function setTreasury(address _treasury) external;

    function withdraw(uint256 _amount) external;

    function remainingDepositCap() external view returns (uint256);
    function depositFee(address _to) external view returns (uint256);

    function LSD() external view returns (address); // solhint-disable-line style-guide-casing
    function ASSET_TOKEN() external view returns (address); // solhint-disable-line style-guide-casing
    function ASSET_TOKEN_DECIMALS() external view returns (uint256); // solhint-disable-line style-guide-casing
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IStakingPoolChild } from "./IStakingPoolChild.sol";

/// @title IRedemptionFulfiller is the interface for redemption fulfiller contract
/// It's used to fulfill redemption request from RedemptionAssetVault
interface IRedemptionFulfiller is IStakingPoolChild {
    /// @notice Emitted when a redemption request is fulfilled
    event RedemptionFulfilled(uint256 redemptionId, address[] tokens, uint256[] amounts);

    /// @notice Fulfill redemption request to RedemptionAssetVault
    /// @param _redemptionId The redemption request id
    /// @param _tokens The token addresses to fulfill
    /// @param _amount The amount of token to fulfill
    function fulfillRedemption(
        uint256 _redemptionId,
        address[] calldata _tokens,
        uint256[] calldata _amount
    ) external payable;

    /// @notice Withdraw unexpected token
    /// @param _token The token address to withdraw
    /// @param _amount The amount of token to withdraw
    /// @param _to The address to receive the withdrawn token
    function rescueWithdraw(address _token, uint256 _amount, address _to) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IStakingPoolChild } from "./IStakingPoolChild.sol";

/// @title IStakingExecutor is the interface for staking executor contract.
/// It's used to stake asset token to staked token and withdraw staked token back to asset token.
/// The result of staking and withdrawing should be transferred to the owner of the staking executor.
interface IStakingExecutor is IStakingPoolChild {
    /// @notice Emitted when the asset token is staked to staked token
    /// @param assetAmount The amount of asset token staked
    /// @param stakedAmount The amount of staked token get by staking
    event Staked(uint256 assetAmount, uint256 stakedAmount);
    /// @notice Emitted when a withdraw request is submitted
    /// @param stakedAmount The amount of staked token to withdraw
    event WithdrawRequestSubmitted(uint256 stakedAmount);
    /// @notice Emitted when the withdrawn asset token is claimed
    event WithdrawRequestClaimed(uint256 assetAmount);

    /// @notice Stake asset token to staked token
    /// @param _amount The amount of asset token to stake
    /// @param _opt The optional data for staking
    function stake(uint256 _amount, bytes calldata _opt) external payable;
    /// @notice Withdraw staked token to asset token
    /// @param _amount The amount of staked token to withdraw
    /// @param _opt The optional data for withdrawing
    /// @dev The request NFT or other credentials may be stored here temporarily
    function requestWithdraw(uint256 _amount, bytes calldata _opt) external;
    /// @notice Claim The withdrawn asset token
    /// @param _opt The optional data for claiming
    /// @dev The claimed asset token should be transferred to the owner of the staking executor
    function claimWithdraw(bytes calldata _opt) external;
    /// @notice Withdraw unexpected token
    /// @param _token The token address to withdraw
    /// @param _amount The amount of token to withdraw
    /// @param _to The address to receive the withdrawn token
    function rescueWithdraw(address _token, uint256 _amount, address _to) external;

    /// @notice Check if the staking executor is claimable
    /// @param _opt The optional data for claiming
    function isClaimable(bytes calldata _opt) external view returns (bool);
    /// @notice Get staked token address
    /// @return The staked token address
    function stakedToken() external view returns (address);
    /// @notice Get asset token address
    /// @return The asset token address
    function assetToken() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IStakingPool is the interface for StakingPool contract
/// This contract will hold most of asset token and staked token
interface IStakingPool {
    /// @notice emit when the operator is changed
    /// @param _operator The new operator address
    event NewOperator(address _operator);
    /// @notice emit when the next treasury is changed
    /// @param _nextTreasury The new next treasury address
    event NewNextTreasury(address _nextTreasury);
    /// @notice emit when the nav float rate is scheduled to change
    /// @param _newRate The new nav float rate
    /// @param _delay The delay time for the schedule operation
    event NewNavFloatRateScheduled(uint256 _newRate, uint256 _delay);
    /// @notice emit when the nav float rate is confirmed
    /// @param _newRate The new nav float rate
    event NewNavFloatRateConfirmed(uint256 _newRate);
    /// @notice emit when the scheduled operation to change nav float rate is cancelled
    /// @param _newRate The new nav float rate that has been cancelled
    event NewNavFloatRateCancelled(uint256 _newRate);
    /// @notice emit when the delay time is scheduled to change
    /// @param _newDelay The new delay time
    /// @param _delay The delay time for the schedule operation
    event NewDelayScheduled(uint256 _newDelay, uint256 _delay);
    /// @notice emit when the delay time is confirmed
    /// @param _newDelay The min delay time
    event NewDelayConfirmed(uint256 _newDelay);
    /// @notice emit when the scheduled operation to change delay time is cancelled
    /// @param _newDelay The new delay time that has been cancelled
    event NewDelayCancelled(uint256 _newDelay);
    /// @notice emit when the redemption fulfiller is scheduled to change
    /// @param _redemptionFulfiller The new redemption fulfiller address
    /// @param _delay The delay time for the schedule operation
    event NewRedemptionFulfillerScheduled(address _redemptionFulfiller, uint256 _delay);
    /// @notice emit when the redemption fulfiller is confirmed
    /// @param _redemptionFulfiller The new redemption fulfiller address
    event NewRedemptionFulfillerConfirmed(address _redemptionFulfiller);
    /// @notice emit when the scheduled operation to change redemption fulfiller is cancelled
    /// @param _redemptionFulfiller The new redemption fulfiller address
    event NewRedemptionFulfillerCancelled(address _redemptionFulfiller);
    /// @notice emit when the withdraw pool unlocks checker is scheduled to change
    /// @param _withdrawPoolUnlocksChecker The new withdraw pool unlocks checker address
    /// @param _delay The delay time for the schedule operation
    event NewWithdrawPoolUnlocksCheckerScheduled(address _withdrawPoolUnlocksChecker, uint256 _delay);
    /// @notice emit when the withdraw pool unlocks checker is confirmed
    /// @param _withdrawPoolUnlocksChecker The new withdraw pool unlocks checker address
    event NewWithdrawPoolUnlocksCheckerConfirmed(address _withdrawPoolUnlocksChecker);
    /// @notice emit when the scheduled operation to change withdraw pool unlocks checker is cancelled
    /// @param _withdrawPoolUnlocksChecker The new withdraw pool unlocks checker address
    event NewWithdrawPoolUnlocksCheckerCancelled(address _withdrawPoolUnlocksChecker);
    /// @notice emit when a executor is removed
    /// @param _executor The executor address
    event ExecutorRemoved(address _executor);
    /// @notice emit when a executor is scheduled to be added
    /// @param _executor The executor address
    /// @param _delay The delay time for the schedule operation
    event ExecutorAddedScheduled(address _executor, uint256 _delay);
    /// @notice emit when a executor is confirmed to be added
    /// @param _executor The executor address
    event ExecutorAddedConfirmed(address _executor);
    /// @notice emit when the scheduled operation to add executor is cancelled
    /// @param _executor The executor address
    event ExecutorAddedCancelled(address _executor);
    /// @notice emit when a token converter is scheduled to be added
    /// @param _converter The token converter address
    /// @param _delay The delay time for the schedule operation
    event TokenConverterAddedScheduled(address _converter, uint256 _delay);
    /// @notice emit when a token converter is confirmed to be added
    /// @param _converter The token converter address
    event TokenConverterAddedConfirmed(address _converter);
    /// @notice emit when the scheduled operation to add token converter is cancelled
    /// @param _converter The token converter address
    event TokenConverterAddedCancelled(address _converter);
    /// @notice emit when a token converter is removed
    /// @param _converter The token converter address
    event TokenConverterRemoved(address _converter);
    /// @notice emit when a air dropper is scheduled to be added
    /// @param _airDropper The air dropper address
    /// @param _delay The delay time for the schedule operation
    event AirDropperAddedScheduled(address _airDropper, uint256 _delay);
    /// @notice emit when a air dropper is confirmed to be added
    /// @param _airDropper The air dropper address
    event AirDropperAddedConfirmed(address _airDropper);
    /// @notice emit when the scheduled operation to add air dropper is cancelled
    /// @param _airDropper The air dropper address
    event AirDropperAddedCancelled(address _airDropper);
    /// @notice emit when a air dropper is removed
    /// @param _airDropper The air dropper address
    event AirDropperRemoved(address _airDropper);

    /// emit when a new token converter is added or removed
    /// @param _converter The token converter address
    /// @param _added True if the token converter is added, false if the token converter is removed
    event TokenConverterUpdated(address _converter, bool _added);

    /// @notice Revert when the child's staking pool is not this contract
    error InvalidChild(address _child, address _stakingPool);
    /// @notice Revert when the staking executor is not registered
    error InvalidStakingExecutor(address _executor);
    /// @notice Revert when the token converter is not registered
    error InvalidTokenConverter(address _converter);
    /// @notice Revert when the air dropper is not registered
    error InvalidAirDropper(address _airDropper);
    /// @notice Revert when the redemption fulfiller is not registered
    error InvalidRedemptionFulfiller(address _fulfiller);
    /// @notice Revert when the msg sender is not the operator
    error InvalidOperator(address _operator);
    /// @notice Revert when the msg sender is not the manager
    error InvalidManager(address _manager);
    /// @notice Revert when unlock amount is invalid
    error InvalidUnlockAmount(uint256 _lsdAmount, uint256 _assetAmount);
    /// @notice Revert when the claim airdrop failed
    error ClaimAirdropFailed(bytes ret);

    /// @notice Convert token from one to another
    /// @param _converter The token converter address
    /// @param _amount The amount of token to convert
    /// @param _opt The optional data for converting
    function convertToken(address _converter, uint256 _amount, bytes calldata _opt) external;
    /// @notice Withdraw asset token from deposit pool
    /// @param _amount The amount of asset token to withdraw
    function withdrawFromDepositPool(uint256 _amount) external;
    /// @notice Stake asset token to staked token
    /// @param _stakingExecutors The staking executor addresses
    /// @param _amounts The amount of asset token to stake
    /// @param _opts The optional data for staking
    function stake(address[] calldata _stakingExecutors, uint256[] calldata _amounts, bytes[] calldata _opts) external;
    /// @notice Withdraw asset token from deposit pool and stake to staked token
    /// @param _withdrawAmount The amount of asset token to withdraw from deposit pool
    /// @param _stakingExecutors The staking executor addresses
    /// @param _amounts The amount of asset token to stake
    /// @param _opts The optional data for staking
    function stakeFromDepositPool(
        uint256 _withdrawAmount,
        address[] calldata _stakingExecutors,
        uint256[] calldata _amounts,
        bytes[] calldata _opts
    ) external;
    /// @notice Request to withdraw staked token to asset token
    /// @param _stakingExecutors The staking executor addresses
    /// @param _amounts The amount of staked token to withdraw
    /// @param _opts The optional data for withdrawing
    function requestWithdraw(
        address[] calldata _stakingExecutors,
        uint256[] calldata _amounts,
        bytes[] calldata _opts
    ) external;
    /// @notice Claim the withdrawn asset token
    /// @param _stakingExecutors The staking executor addresses
    /// @param _opts The optional data for claiming
    function claimWithdraw(address[] calldata _stakingExecutors, bytes[] calldata _opts) external;
    /// @notice Claim the withdrawn asset token and transfer to withdraw pool to unlock
    /// @param _stakingExecutors The staking executor addresses
    /// @param _opts The optional data for claiming
    /// @param _lsdAmount The amount of LSD token to unlock
    /// @param _totalAmount The total amount of asset token to fulfill unlock
    function claimWithdrawToUnlock(
        address[] calldata _stakingExecutors,
        bytes[] calldata _opts,
        uint256 _lsdAmount,
        uint256 _totalAmount
    ) external payable;
    /// @notice Transfer asset token to add withdraw pool unlock
    /// @param _lsdAmount The amount of LSD token to unlock
    /// @param _amount The amount of asset token to fulfill unlock
    function addWithdrawPoolUnlocks(uint256 _lsdAmount, uint256 _amount) external payable;
    /// @notice Fulfill redemption request to RedemptionAssetVault
    /// @param _redemptionId The redemption request id
    /// @param _tokens The token addresses to fulfill
    /// @param _amount The amount of token to fulfill
    function fulfillRedemption(
        uint256 _redemptionId,
        address[] calldata _tokens,
        uint256[] calldata _amount
    ) external payable;
    /// @notice Claim airdrop on any contract
    /// @dev Should be called carefully, because this method would call any contract with the given call data
    /// @param _to The address to claim the airdrop
    /// @param _opt The call data for calling the contract on contract(_to) to claim airdrop
    function claimAirdrop(address _to, bytes calldata _opt) external payable;
    /// @notice Withdraw unexpected token or staked token to the next treasury
    /// The staked token will be used for further investment
    /// @param _token The token address to withdraw
    /// @param _amount The amount of token to withdraw
    function rescueWithdraw(address _token, uint256 _amount) external;

    /// @notice Check if a withdraw request on the staking executor is claimable
    /// @param _stakingExecutor The staking executor address
    /// @param _opt The bytes data for specified withdraw request
    /// @return True if the withdraw request is claimable, otherwise false
    function isClaimable(address _stakingExecutor, bytes calldata _opt) external view returns (bool);
    /// @notice Get the asset token address
    /// @return The asset token address
    function assetToken() external view returns (address);
    /// @notice Get the deposit pool address
    /// @return The deposit pool address
    function depositPool() external view returns (address);
    /// @notice Get the withdraw pool address
    /// @return The withdraw pool address
    function withdrawPool() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IStakingPoolChild is the interface for staking pool child contract
/// it's a abstract contract which is fully controlled by the staking pool
interface IStakingPoolChild {
    /// @notice Emitted when the staking pool is updated
    /// @param _stakingPool The new staking pool address
    event NewStakingPool(address _stakingPool);

    /// @notice Revert when the caller is not the staking pool
    error InvalidStakingPool(address _msgSender);

    /// @notice Get the staking pool address
    /// @return The staking pool address
    function stakingPool() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IStakingPoolChild } from "./IStakingPoolChild.sol";

/// @title ITokenConverter is the interface for the token converter contract
/// It's used to convert token from one to another
interface ITokenConverter is IStakingPoolChild {
    /// @notice Emitted when token is converted
    /// @param fromToken The token address to convert from
    /// @param amountIn The amount of token to convert
    /// @param toToken The token address to convert to
    /// @param amountOut The amount of token converted
    event TokenConverted(address fromToken, uint256 amountIn, address toToken, uint256 amountOut);

    /// @notice Convert token from one to another
    /// @dev The _toToken should be transferred to the staking pool
    /// @param _amount The amount of token to convert
    /// @param _opt The optional data for converting
    function convertToken(uint256 _amount, bytes calldata _opt) external payable;
    function fromToken() external view returns (address);
    function toToken() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IWithdrawPool {
    event SetUnstaker(address unstaker);
    event SetLzReceiveGasLimit(uint128 gasLimit);
    event Unlocked(uint256 unlockedLSDAmount, uint256 amount);
    event SmartSavingsOnGravityUpdated(address addr);

    event PoolUnlocksBridged(uint256 totalPoolUnlocks, uint256 fee, bytes32 guid);
    event Claimed(address to, uint256 underlyingTokenAmount, uint256 amountOfLSD, uint256 timestamp, bytes32 guid);

    error InvalidCaller();
    error WithdrawSentFailed();
    error InvalidLSD();
    error InvalidUnlockAmount();
    error InvalidBridgeMessage();
    error InvalidBridgeMessageFrom(address _address);
    error InvalidUnderlyingToken();
    error InvalidNav(uint256 _nav);
    error InvalidClaimAmount(uint256 _amount);
    error InvalidTimestamp(uint256 _tradingDays);
    error ClaimAmountTooSmall(uint256 _amount);
    error InsufficientFee(uint256 wanted, uint256 provided);
    error SendFailed(address to, uint256 amount);

    function setUnstaker(address _unstaker) external;
    function rescueWithdraw(address _token, address _to) external;
    function addPoolUnlocks(uint256 _unlockedLSDAmount, uint256 _amount) external payable;
    function totalPoolUnlocks() external returns (uint256);
    function unlockFee() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IWithdrawPoolUnlocksChecker is the interface for WithdrawPoolUnlocksChecker contract
interface IWithdrawPoolUnlocksChecker {
    /// @notice revert when the unlock amount is invalid
    /// @param _unlockLSDAmount The amount of LSD to unlock
    /// @param _maxUnlockLSDAmount The maximum amount of LSD allowed to be unlocked
    error InvalidUnlocks(uint256 _unlockLSDAmount, uint256 _maxUnlockLSDAmount);

    /// @notice Check if the unlock amount is valid
    function checkUnlocksLSDAmount(uint256 _unlockLSDAmount) external view;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IStakingPool } from "../interfaces/IStakingPool.sol";
import { IStakingExecutor } from "../interfaces/IStakingExecutor.sol";
import { ITokenConverter } from "../interfaces/ITokenConverter.sol";
import { IDepositPool } from "../depositPool/IDepositPool.sol";
import { IWithdrawPool } from "../interfaces/IWithdrawPool.sol";
import { IVaultNav } from "../vaultNav/IVaultNav.sol";
import { IRedemptionFulfiller } from "../interfaces/IRedemptionFulfiller.sol";
import { TimelockedOperations } from "../utils/TimelockedOperations.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { RescueWithdraw } from "../utils/RescueWithdraw.sol";
import { EmptyChecker } from "../utils/EmptyChecker.sol";
import { IStakingPool } from "../interfaces/IStakingPool.sol";
import { IStakingPoolChild } from "../interfaces/IStakingPoolChild.sol";
import { IWithdrawPoolUnlocksChecker } from "../interfaces/IWithdrawPoolUnlocksChecker.sol";

/// @title StakingPool is the contract to manage asset token and staked tokens
contract StakingPool is Ownable2Step, Pausable, RescueWithdraw, IStakingPool {
    using TimelockedOperations for TimelockedOperations.AddressOperation;
    using TimelockedOperations for TimelockedOperations.Uint256Operation;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    /// @notice deposit pool address, asset token are deposited here
    /// and will be withdrew to this contract to do batch stake
    address public immutable DEPOSIT_POOL;
    /// @notice withdraw pool address, to hold asset token for claim
    /// and this contract will do batch withdraw to fulfill unlock request
    address public immutable WITHDRAW_POOL;
    /// @notice the address to store the NAV of the vault
    address public immutable VAULT_NAV;
    /// @notice operator address, to call stake, withdraw, claim and fulfill redemption
    address public operator;
    /// @notice manager address, to call convert token
    address public manager;
    /// @notice the address to hold some staked tokens beside this contract
    /// such as pendle pt.
    address public nextTreasury;
    /// @notice the nav float rate to calculate the nav
    /// @dev nav in range [nav * (1 - navFloatRate / 10000), nav * (1 + navFloatRate / 10000)] is acceptable
    /// nav = assetTokenAmount / lsdTokenAmount
    uint256 public navFloatRate = 100;
    TimelockedOperations.Uint256Operation private _pendingNavFloatRate;
    /// @notice the delay time for the schedule operation
    uint256 public delay;
    TimelockedOperations.Uint256Operation private _pendingDelay;
    /// @notice the redemption fulfiller address to fulfill redemption request
    address public redemptionFulfiller;
    TimelockedOperations.AddressOperation private _pendingRedemptionFulfiller;
    /// @notice the hooker contract address to check the _lsdAmount argument of addWithdrawPoolUnlocks function
    address public withdrawPoolUnlocksChecker;
    TimelockedOperations.AddressOperation private _pendingWithdrawPoolUnlocksChecker;

    /// @notice staking executors set
    EnumerableSet.AddressSet private _innerStakingExecutors;
    TimelockedOperations.AddressOperation private _pendingStakingExecutor;
    /// @notice token converters set
    EnumerableSet.AddressSet private _innerTokenConverters;
    TimelockedOperations.AddressOperation private _pendingTokenConverter;
    /// @notice air droppers set
    EnumerableSet.AddressSet private _innerAirDroppers;
    TimelockedOperations.AddressOperation private _pendingAirDropper;

    modifier onlyOperator() {
        if (msg.sender != operator) {
            revert InvalidOperator(msg.sender);
        }
        _;
    }

    modifier onlyManager() {
        if (msg.sender != manager) {
            revert InvalidManager(msg.sender);
        }
        _;
    }

    modifier onlyValidStakingExecutor(address executor) {
        if (!_innerStakingExecutors.contains(executor)) {
            revert InvalidStakingExecutor(executor);
        }
        _;
    }

    modifier onlyValidStakingExecutors(address[] calldata executors) {
        for (uint256 i = 0; i < executors.length; i++) {
            if (!_innerStakingExecutors.contains(executors[i])) {
                revert InvalidStakingExecutor(executors[i]);
            }
        }
        _;
    }

    modifier onlyValidTokenConverter(address converter) {
        if (!_innerTokenConverters.contains(converter)) {
            revert InvalidTokenConverter(converter);
        }
        _;
    }

    modifier onlyValidAirDropper(address airDropper) {
        if (!_innerAirDroppers.contains(airDropper)) {
            revert InvalidAirDropper(airDropper);
        }
        _;
    }

    modifier onlyValidRedemptionFulfiller(address fulfiller) {
        if (fulfiller != redemptionFulfiller) {
            revert InvalidRedemptionFulfiller(fulfiller);
        }
        _;
    }

    modifier onlyValidChildToAdd(address child) {
        if (IStakingPoolChild(child).stakingPool() != address(this)) {
            revert InvalidChild(child, IStakingPoolChild(child).stakingPool());
        }
        _;
    }

    modifier onlyValidUnlockAmount(uint256 lsdAmount, uint256 assetAmount) {
        address lsd = IDepositPool(DEPOSIT_POOL).LSD();
        uint256 assetTokenDecimals = IDepositPool(DEPOSIT_POOL).ASSET_TOKEN_DECIMALS();
        uint256 assetAmountE18 = assetAmount * 10 ** (18 - assetTokenDecimals);
        uint256 averageNav = (assetAmountE18 * 10 ** 18) / lsdAmount;
        (uint256 currentNav, ) = IVaultNav(VAULT_NAV).getNavByTimestamp(lsd, uint48(block.timestamp));
        // The unlock amount is the accumulated amount of withdraw requests submitted within a period.
        // And the averageNav of the period should be close to the currentNav.
        // So we can get a limit to ensure the unlock amount is valid.
        // currentNav * (1 - navFloatRate / 10000) <= averageNav <= currentNav * (1 + navFloatRate / 10000)
        if (
            averageNav < (currentNav * (10000 - navFloatRate)) / 10000 ||
            averageNav > (currentNav * (10000 + navFloatRate)) / 10000
        ) {
            revert InvalidUnlockAmount(lsdAmount, assetAmount);
        }
        if (withdrawPoolUnlocksChecker != address(0)) {
            IWithdrawPoolUnlocksChecker(withdrawPoolUnlocksChecker).checkUnlocksLSDAmount(lsdAmount);
        }
        _;
    }

    constructor(
        address _owner, // solhint-disable-line no-unused-vars
        address _nextTreasury,
        address _depositPool,
        address _withdrawPool,
        address _vaultNav,
        address _operator,
        address _manager
    ) Ownable(_owner) {
        EmptyChecker.checkEmptyAddress(_nextTreasury);
        EmptyChecker.checkEmptyAddress(_depositPool);
        EmptyChecker.checkEmptyAddress(_withdrawPool);
        EmptyChecker.checkEmptyAddress(_vaultNav);
        EmptyChecker.checkEmptyAddress(_operator);
        EmptyChecker.checkEmptyAddress(_manager);
        nextTreasury = _nextTreasury;
        DEPOSIT_POOL = _depositPool;
        WITHDRAW_POOL = _withdrawPool;
        VAULT_NAV = _vaultNav;
        operator = _operator;
        manager = _manager;
    }

    receive() external payable {}

    /// @notice Pause the contract.
    /// @dev Emit a `Paused` event.
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Pause the contract.
    /// @dev Emit a `Unpaused` event.
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Update the operator address.
    /// @param _operator The new operator address.
    function updateOperator(address _operator) external onlyOwner {
        EmptyChecker.checkEmptyAddress(_operator);
        operator = _operator;
        emit NewOperator(_operator);
    }

    /// @notice Update the next treasury address.
    /// @param _nextTreasury The new next treasury address.
    function updateNextTreasury(address _nextTreasury) external onlyOwner {
        EmptyChecker.checkEmptyAddress(_nextTreasury);
        nextTreasury = _nextTreasury;
        emit NewNextTreasury(_nextTreasury);
    }

    function updateNavFloatRate(uint256 _newNavFloatRate) external onlyOwner {
        _pendingNavFloatRate.scheduleOperation(_newNavFloatRate, delay);
        emit NewNavFloatRateScheduled(_newNavFloatRate, delay);
    }

    function confirmNavFloatRate(uint256 _newNavFloatRate) external onlyOwner {
        _pendingNavFloatRate.executeOperation(_newNavFloatRate);
        navFloatRate = _newNavFloatRate;
        emit NewNavFloatRateConfirmed(_newNavFloatRate);
    }

    function cancelNavFloatRate() external onlyOwner {
        uint256 toCancel = pendingNavFloatRate();
        _pendingNavFloatRate.cancelOperation();
        emit NewNavFloatRateCancelled(toCancel);
    }

    /// @notice Update the delay time.
    /// @param _newDelay The new min delay time.
    function updateDelay(uint256 _newDelay) external onlyOwner {
        _pendingDelay.scheduleOperation(_newDelay, delay);
        emit NewDelayScheduled(_newDelay, delay);
    }

    /// @notice Confirm the scheduled operation to change delay time.
    /// @param _newDelay The new min delay time.
    function confirmDelay(uint256 _newDelay) external onlyOwner {
        _pendingDelay.executeOperation(_newDelay);
        delay = _newDelay;
        emit NewDelayConfirmed(_newDelay);
    }

    /// @notice Cancel the scheduled operation to change delay time.
    function cancelDelay() external onlyOwner {
        uint256 toCancel = pendingDelay();
        _pendingDelay.cancelOperation();
        emit NewDelayCancelled(toCancel);
    }

    /// @notice Update the redemption fulfiller address.
    /// @param _newRedemptionFulfiller The new redemption fulfiller address.
    function updateRedemptionFulfiller(
        address _newRedemptionFulfiller
    ) external onlyOwner onlyValidChildToAdd(_newRedemptionFulfiller) {
        EmptyChecker.checkEmptyAddress(_newRedemptionFulfiller);
        _pendingRedemptionFulfiller.scheduleOperation(_newRedemptionFulfiller, delay);
        emit NewRedemptionFulfillerScheduled(_newRedemptionFulfiller, delay);
    }

    /// @notice Confirm the scheduled operation to change redemption fulfiller.
    /// @param _newRedemptionFulfiller The new redemption fulfiller address.
    function confirmRedemptionFulfiller(address _newRedemptionFulfiller) external onlyOwner {
        _pendingRedemptionFulfiller.executeOperation(_newRedemptionFulfiller);
        redemptionFulfiller = _newRedemptionFulfiller;
        emit NewRedemptionFulfillerConfirmed(_newRedemptionFulfiller);
    }

    /// @notice Cancel the scheduled operation to change redemption fulfiller.
    function cancelRedemptionFulfiller() external onlyOwner {
        address toCancelAddr = pendingRedemptionFulfiller();
        _pendingRedemptionFulfiller.cancelOperation();
        emit NewRedemptionFulfillerCancelled(toCancelAddr);
    }

    /// @notice Update the withdraw pool unlocks checker address.
    /// @param _newWithdrawPoolUnlocksChecker The new withdraw pool unlocks checker address.
    function updateWithdrawPoolUnlocksChecker(address _newWithdrawPoolUnlocksChecker) external onlyOwner {
        _pendingWithdrawPoolUnlocksChecker.scheduleOperation(_newWithdrawPoolUnlocksChecker, delay);
        emit NewWithdrawPoolUnlocksCheckerScheduled(_newWithdrawPoolUnlocksChecker, delay);
    }

    /// @notice Confirm the scheduled operation to change withdraw pool unlocks checker.
    /// @param _newWithdrawPoolUnlocksChecker The new withdraw pool unlocks checker address.
    function confirmWithdrawPoolUnlocksChecker(address _newWithdrawPoolUnlocksChecker) external onlyOwner {
        _pendingWithdrawPoolUnlocksChecker.executeOperation(_newWithdrawPoolUnlocksChecker);
        withdrawPoolUnlocksChecker = _newWithdrawPoolUnlocksChecker;
        emit NewWithdrawPoolUnlocksCheckerConfirmed(_newWithdrawPoolUnlocksChecker);
    }

    /// @notice Cancel the scheduled operation to change withdraw pool unlocks checker.
    function cancelWithdrawPoolUnlocksChecker() external onlyOwner {
        address toCancelAddr = pendingWithdrawPoolUnlocksChecker();
        _pendingWithdrawPoolUnlocksChecker.cancelOperation();
        emit NewWithdrawPoolUnlocksCheckerCancelled(toCancelAddr);
    }

    /// @notice Remove staking executor address.
    /// @param _executor The staking executor address.
    function removeStakingExecutor(address _executor) external onlyOwner {
        _innerStakingExecutors.remove(_executor);
        emit ExecutorRemoved(_executor);
    }

    /// @notice Add staking executor address.
    /// @param _executor The staking executor address.
    function addStakingExecutor(address _executor) external onlyOwner onlyValidChildToAdd(_executor) {
        EmptyChecker.checkEmptyAddress(_executor);
        _pendingStakingExecutor.scheduleOperation(_executor, delay);
        emit ExecutorAddedScheduled(_executor, delay);
    }

    /// @notice Confirm the scheduled operation to add staking executor.
    /// @param _executor The staking executor address.
    function confirmAddStakingExecutor(address _executor) external onlyOwner {
        _pendingStakingExecutor.executeOperation(_executor);
        _innerStakingExecutors.add(_executor);
        emit ExecutorAddedConfirmed(_executor);
    }

    /// @notice Cancel the scheduled operation to add staking executor.
    function cancelAddStakingExecutor() external onlyOwner {
        address toCancelAddr = pendingStakingExecutor();
        _pendingStakingExecutor.cancelOperation();
        emit ExecutorAddedCancelled(toCancelAddr);
    }

    /// @notice Remove token converter address.
    /// @param _converter The token converter address.
    function removeTokenConverter(address _converter) external onlyOwner {
        _innerTokenConverters.remove(_converter);
        emit TokenConverterRemoved(_converter);
    }

    /// @notice Add token converter address.
    /// @param _converter The token converter address.
    function addTokenConverter(address _converter) external onlyOwner onlyValidChildToAdd(_converter) {
        EmptyChecker.checkEmptyAddress(_converter);
        _pendingTokenConverter.scheduleOperation(_converter, delay);
        emit TokenConverterAddedScheduled(_converter, delay);
    }

    /// @notice Confirm the scheduled operation to add token converter.
    /// @param _converter The token converter address.
    function confirmAddTokenConverter(address _converter) external onlyOwner {
        _pendingTokenConverter.executeOperation(_converter);
        _innerTokenConverters.add(_converter);
        emit TokenConverterAddedConfirmed(_converter);
    }

    /// @notice Cancel the scheduled operation to add token converter.
    function cancelAddTokenConverter() external onlyOwner {
        address toCancelAddr = pendingTokenConverter();
        _pendingTokenConverter.cancelOperation();
        emit TokenConverterAddedCancelled(toCancelAddr);
    }

    /// @notice Remove air dropper address.
    /// @param _airDropper The air dropper address.
    function removeAirDropper(address _airDropper) external onlyOwner {
        _innerAirDroppers.remove(_airDropper);
        emit AirDropperRemoved(_airDropper);
    }

    /// @notice Add air dropper address.
    /// @param _airDropper The air dropper address.
    function addAirDropper(address _airDropper) external onlyOwner {
        EmptyChecker.checkEmptyAddress(_airDropper);
        _pendingAirDropper.scheduleOperation(_airDropper, delay);
        emit AirDropperAddedScheduled(_airDropper, delay);
    }

    /// @notice Confirm the scheduled operation to add air dropper.
    /// @param _airDropper The air dropper address.
    function confirmAddAirDropper(address _airDropper) external onlyOwner {
        _pendingAirDropper.executeOperation(_airDropper);
        _innerAirDroppers.add(_airDropper);
        emit AirDropperAddedConfirmed(_airDropper);
    }

    /// @notice Cancel the scheduled operation to add air dropper.
    function cancelAddAirDropper() external onlyOwner {
        address toCancelAddr = pendingAirDropper();
        _pendingAirDropper.cancelOperation();
        emit AirDropperAddedCancelled(toCancelAddr);
    }

    /// @notice Claim airdrop on any contract
    /// @dev Should be called carefully, because this method would call any contract with the given call data
    /// @param _to The address to claim the airdrop
    /// @param _opt The call data for calling the contract on contract(_to) to claim airdrop
    function claimAirdrop(
        address _to,
        bytes calldata _opt
    ) external payable override onlyOwner onlyValidAirDropper(_to) {
        (bool success, bytes memory ret) = _to.call{ value: msg.value }(_opt);
        if (!success) {
            revert ClaimAirdropFailed(ret);
        }
    }

    /// @notice Withdraw asset token from deposit pool and stake to staking executor
    /// @param _withdrawAmount The amount of asset token to withdraw
    /// @param _stakingExecutors The staking executor addresses
    /// @param _amounts The amount of asset token to stake
    /// @param _opts The optional data for staking
    function stakeFromDepositPool(
        uint256 _withdrawAmount,
        address[] calldata _stakingExecutors,
        uint256[] calldata _amounts,
        bytes[] calldata _opts
    ) external override onlyOperator onlyValidStakingExecutors(_stakingExecutors) {
        withdrawFromDepositPool(_withdrawAmount);
        stake(_stakingExecutors, _amounts, _opts);
    }

    /// @notice Request to withdraw staked token to asset token
    /// @param _stakingExecutors The staking executor addresses
    /// @param _amounts The amount of staked token to withdraw
    /// @param _opts The optional data for withdrawing
    function requestWithdraw(
        address[] calldata _stakingExecutors,
        uint256[] calldata _amounts,
        bytes[] calldata _opts
    ) external override onlyOperator onlyValidStakingExecutors(_stakingExecutors) {
        for (uint256 i = 0; i < _stakingExecutors.length; i++) {
            IERC20(IStakingExecutor(_stakingExecutors[i]).stakedToken()).forceApprove(
                _stakingExecutors[i],
                _amounts[i]
            );
            IStakingExecutor(_stakingExecutors[i]).requestWithdraw(_amounts[i], _opts[i]);
        }
    }

    /// @notice Claim the withdrawn asset token and transfer to withdraw pool to unlock
    /// @param _stakingExecutors The staking executor addresses
    /// @param _opts The optional data for claiming
    /// @param _lsdAmount The amount of LSD token to unlock
    /// @param _totalAmount The total amount of asset token to fulfill unlock
    function claimWithdrawToUnlock(
        address[] calldata _stakingExecutors,
        bytes[] calldata _opts,
        uint256 _lsdAmount,
        uint256 _totalAmount
    ) external payable override onlyOperator onlyValidStakingExecutors(_stakingExecutors) {
        claimWithdraw(_stakingExecutors, _opts);
        addWithdrawPoolUnlocks(_lsdAmount, _totalAmount);
    }

    /// @notice Fulfill redemption request by redemption fulfiller
    /// @param _redemptionId The redemption request id
    /// @param _tokens The token addresses to fulfill
    /// @param _amount The amount of token to fulfill
    function fulfillRedemption(
        uint256 _redemptionId,
        address[] calldata _tokens,
        uint256[] calldata _amount
    ) external payable override onlyOperator {
        uint256 sendValue = 0;
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_tokens[i] == address(0)) {
                sendValue += _amount[i];
            } else {
                IERC20(_tokens[i]).forceApprove(redemptionFulfiller, _amount[i]);
            }
        }
        IRedemptionFulfiller(redemptionFulfiller).fulfillRedemption{ value: sendValue }(
            _redemptionId,
            _tokens,
            _amount
        );
    }

    /// @notice Convert token from one to another
    /// @param _converter The token converter address
    /// @param _amount The amount of token to convert
    /// @param _opt The optional data for converting
    function convertToken(
        address _converter,
        uint256 _amount,
        bytes calldata _opt
    ) external override onlyManager onlyValidTokenConverter(_converter) {
        address _fromToken = ITokenConverter(_converter).fromToken();
        if (_fromToken == address(0)) {
            // If fromToken is native token, transfer by calling with value
            ITokenConverter(_converter).convertToken{ value: _amount }(_amount, _opt);
        } else {
            // If fromToken is erc20 token, transfer by erc20 approve and transferFrom
            IERC20(_fromToken).forceApprove(_converter, _amount);
            ITokenConverter(_converter).convertToken(_amount, _opt);
        }
    }

    /// @notice Withdraw unexpected token or staked token for further investment
    /// @dev These tokens should be only sent to next treasury address
    /// @param token The token address to withdraw
    /// @param amount The amount of token to withdraw
    function rescueWithdraw(address token, uint256 amount) external onlyOwner {
        _sendToken(token, nextTreasury, amount);
    }

    /// @notice Check if the staking executor is claimable
    /// @param _stakingExecutor The staking executor address
    /// @param _opt The optional data for check claimable
    function isClaimable(address _stakingExecutor, bytes calldata _opt) external view returns (bool) {
        return IStakingExecutor(_stakingExecutor).isClaimable(_opt);
    }

    /// @notice Get the deposit pool address
    /// @return The deposit pool address
    function depositPool() external view override returns (address) {
        return DEPOSIT_POOL;
    }

    /// @notice Get the withdraw pool address
    /// @return The withdraw pool address
    function withdrawPool() external view override returns (address) {
        return WITHDRAW_POOL;
    }

    /// @notice Claim the withdrawn asset token
    /// @param _stakingExecutors The staking executor addresses
    /// @param _opts The optional data for claiming
    function claimWithdraw(
        address[] calldata _stakingExecutors,
        bytes[] calldata _opts
    ) public override onlyOperator onlyValidStakingExecutors(_stakingExecutors) {
        for (uint256 i = 0; i < _stakingExecutors.length; i++) {
            IStakingExecutor(_stakingExecutors[i]).claimWithdraw(_opts[i]);
        }
    }

    /// @notice Add unlock to withdraw pool
    /// @param _lsdAmount The amount of LSD token to unlock
    /// @param _amount The amount of asset token to unlock
    function addWithdrawPoolUnlocks(
        uint256 _lsdAmount,
        uint256 _amount
    ) public payable onlyOperator onlyValidUnlockAmount(_lsdAmount, _amount) {
        // unlock fee in native token
        uint256 valueToSend = IWithdrawPool(WITHDRAW_POOL).unlockFee();
        address token = assetToken();
        if (token == address(0)) {
            // If asset token is native token, unlock fee and asset token amount should be sent together
            valueToSend += _amount;
        } else {
            // If asset token is erc20 token, should approve withdraw pool to transfer asset token
            IERC20(token).forceApprove(WITHDRAW_POOL, _amount);
        }
        IWithdrawPool(WITHDRAW_POOL).addPoolUnlocks{ value: valueToSend }(_lsdAmount, _amount);
    }

    /// @notice Withdraw asset token from deposit pool
    /// @param _withdrawAmount The amount of asset token to withdraw
    function withdrawFromDepositPool(uint256 _withdrawAmount) public onlyOperator {
        IDepositPool(DEPOSIT_POOL).withdraw(_withdrawAmount);
    }

    /// @notice Stake asset token to staked token
    /// @param _stakingExecutors The staking executor addresses
    /// @param _amounts The amount of asset token to stake
    /// @param _opts The optional data for staking
    function stake(
        address[] calldata _stakingExecutors,
        uint256[] calldata _amounts,
        bytes[] calldata _opts
    ) public override onlyOperator onlyValidStakingExecutors(_stakingExecutors) {
        for (uint256 i = 0; i < _stakingExecutors.length; i++) {
            if (assetToken() == address(0)) {
                // If asset token is native token, transfer by calling with value
                IStakingExecutor(_stakingExecutors[i]).stake{ value: _amounts[i] }(_amounts[i], _opts[i]);
            } else {
                // If asset token is erc20 token, transfer by erc20 approve and transferFrom
                IERC20(assetToken()).forceApprove(_stakingExecutors[i], _amounts[i]);
                IStakingExecutor(_stakingExecutors[i]).stake(_amounts[i], _opts[i]);
            }
        }
    }

    /// @notice Get staked token address
    /// @return The staked token address
    function assetToken() public view override returns (address) {
        return IDepositPool(DEPOSIT_POOL).ASSET_TOKEN();
    }

    /// @notice Get staking executors
    /// @return The staking executor addresses
    function stakingExecutors() public view returns (address[] memory) {
        return _innerStakingExecutors.values();
    }

    /// @notice Get token converters
    /// @return The token converter addresses
    function tokenConverters() public view returns (address[] memory) {
        return _innerTokenConverters.values();
    }

    /// @notice Get air droppers
    /// @return The air dropper addresses
    function airDroppers() public view returns (address[] memory) {
        return _innerAirDroppers.values();
    }

    /// @notice Get the pending nav float rate
    /// @return The pending nav float rate
    function pendingNavFloatRate() public view returns (uint256) {
        return _pendingNavFloatRate.pendingValue();
    }

    /// @notice Get the pending delay time
    /// @return The pending delay time
    function pendingDelay() public view returns (uint256) {
        return _pendingDelay.pendingValue();
    }

    /// @notice Get the pending redemption fulfiller
    /// @return The pending redemption fulfiller
    function pendingRedemptionFulfiller() public view returns (address) {
        return _pendingRedemptionFulfiller.pendingValue();
    }

    /// @notice Get the pending withdraw pool unlocks checker
    /// @return The pending withdraw pool unlocks checker
    function pendingWithdrawPoolUnlocksChecker() public view returns (address) {
        return _pendingWithdrawPoolUnlocksChecker.pendingValue();
    }

    /// @notice Get the pending staking executor
    /// @return The pending staking executor
    function pendingStakingExecutor() public view returns (address) {
        return _pendingStakingExecutor.pendingValue();
    }

    /// @notice Get the pending token converter
    /// @return The pending token converter
    function pendingTokenConverter() public view returns (address) {
        return _pendingTokenConverter.pendingValue();
    }

    /// @notice Get the pending air dropper address
    /// @return The pending air dropper address
    function pendingAirDropper() public view returns (address) {
        return _pendingAirDropper.pendingValue();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library EmptyChecker {
    error EmptyAddress(address arg);

    function checkEmptyAddress(address _address) internal pure {
        if (_address == address(0)) {
            revert EmptyAddress(_address);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract RescueWithdraw {
    using SafeERC20 for IERC20;

    error SendNativeFailed(address _to, uint256 _value);

    /// @notice withdraw unexpected erc20 or native token
    /// @param _token The token address to withdraw
    /// @param _amount The amount of token to withdraw
    /// @param _to The address to receive the withdrawn token
    function _rescueWithdraw(address _token, uint256 _amount, address _to) internal {
        _sendToken(_token, _to, _amount);
    }

    /// @notice withdraw unexpected erc721 token
    /// @param _token The token address to withdraw
    /// @param _tokenId The tokenId of token to withdraw
    /// @param _to The address to receive the withdrawn token
    function _rescueWithdrawERC721(address _token, uint256 _tokenId, address _to) internal {
        IERC721(_token).safeTransferFrom(address(this), _to, _tokenId);
    }

    /// @notice send erc20 or native token
    /// @param _token The token address to send
    /// @param _to The address to receive the token
    /// @param _amount The amount of token to send
    function _sendToken(address _token, address _to, uint256 _amount) internal {
        if (_token != address(0)) {
            IERC20(_token).safeTransfer(_to, _amount);
        } else {
            (bool sent, ) = _to.call{ value: _amount }("");
            if (!sent) {
                revert SendNativeFailed(_to, _amount);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library TimelockedOperations {
    struct Operation {
        uint256 timestamp; // Time when the operation can be executed
        bool executed;
    }

    struct AddressOperation {
        address _pendingValue;
        Operation _operation;
    }

    struct Uint256Operation {
        uint256 _pendingValue;
        Operation _operation;
    }

    error OperationNotReady(uint256 currentTime, uint256 readyTime);
    error NoOperationToExecute();
    error OperationAlreadyExecuted();
    error AddressOperationInvalid(address expected, address received);
    error Uint256OperationInvalid(uint256 expected, uint256 received);

    modifier onlyExecutableOperation(Operation storage operation) {
        if (operation.timestamp == 0) {
            revert NoOperationToExecute();
        }
        // verify operation delay is fulfilled
        if (operation.timestamp > block.timestamp) {
            revert OperationNotReady(block.timestamp, operation.timestamp);
        }
        // verify operation is not executed
        if (operation.executed) {
            revert OperationAlreadyExecuted();
        }
        _;
    }

    modifier onlyValidAddressOperationValue(AddressOperation storage operation, address value) {
        if (operation._pendingValue != value) {
            revert AddressOperationInvalid(operation._pendingValue, value);
        }
        _;
    }

    modifier onlyValidUint256OperationValue(Uint256Operation storage operation, uint256 value) {
        if (operation._pendingValue != value) {
            revert Uint256OperationInvalid(operation._pendingValue, value);
        }
        _;
    }

    // internal functions for base operation scheduling
    function scheduleOperation(Operation storage _operation, uint256 _delay) internal {
        _operation.timestamp = block.timestamp + _delay;
        _operation.executed = false;
    }

    function cancelOperation(Operation storage _operation) internal {
        if (_operation.executed) {
            revert OperationAlreadyExecuted();
        }
        _operation.timestamp = 0;
    }

    function executeOperation(Operation storage _operation) internal onlyExecutableOperation(_operation) {
        _operation.executed = true;
    }

    // internal functions for address operation scheduling
    function scheduleOperation(AddressOperation storage _operation, address _value, uint256 _delay) internal {
        _operation._pendingValue = _value;
        scheduleOperation(_operation._operation, _delay);
    }

    function cancelOperation(AddressOperation storage _operation) internal {
        cancelOperation(_operation._operation);
    }

    function executeOperation(
        AddressOperation storage _operation,
        address _value // solhint-disable-line no-unused-vars
    ) internal onlyValidAddressOperationValue(_operation, _value) {
        executeOperation(_operation._operation);
    }

    // internal functions for uint256 operation scheduling
    function scheduleOperation(Uint256Operation storage _operation, uint256 _value, uint256 _delay) internal {
        _operation._pendingValue = _value;
        scheduleOperation(_operation._operation, _delay);
    }

    function cancelOperation(Uint256Operation storage _operation) internal {
        cancelOperation(_operation._operation);
    }

    function executeOperation(
        Uint256Operation storage _operation,
        uint256 _value // solhint-disable-line no-unused-vars
    ) internal onlyValidUint256OperationValue(_operation, _value) {
        executeOperation(_operation._operation);
    }

    // internal view functions for address operation
    function pendingValue(AddressOperation storage _operation) internal view returns (address) {
        return _operation._pendingValue;
    }

    function pendingValue(Uint256Operation storage _operation) internal view returns (uint256) {
        return _operation._pendingValue;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVaultNav {
    event NavUpdated(address indexed lsd, uint256 nav, uint256 timestamp);
    event SetNavUpdater(address indexed lsd, address updater);

    error NavNotFound(uint48 _timestamp);
    error InvalidNavUpdater(address updater);
    error NavInvalidValue(uint256 nav);
    error TimestampTooLarge();
    error InvalidUpdatePeriod();
    error NavUpdateInvalidTimestamp();

    function appendNav(address lsd, uint256 nav, uint48 timestamp) external;
    function setNavUpdater(address lsd, address updater) external;
    function getNavByTimestamp(
        address vaultType,
        uint48 timestamp
    ) external view returns (uint256 nav, uint48 updateTime);

    function lsdToTokenE18AtTime(address _lsd, uint256 _amount, uint48 _timestamp) external view returns (uint256);
    function tokenE18ToLsdAtTime(
        address _lsd,
        uint256 _tokenAmountE18,
        uint48 _timestamp
    ) external view returns (uint256);
}