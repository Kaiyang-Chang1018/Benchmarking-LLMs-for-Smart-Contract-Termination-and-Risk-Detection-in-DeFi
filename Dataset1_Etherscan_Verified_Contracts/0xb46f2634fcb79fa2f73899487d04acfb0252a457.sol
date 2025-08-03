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
pragma solidity 0.8.24;

error InvalidStartime();
error InvalidEndTime();
error InvalidAllocation();
error InvalidEmission();

error NotStarted();
error DeadlineExceeded();

error InvalidOwner();
error IncorrectClaimable();
error EmptyArray();
error StreamPaused();
error InvalidDelegate();

error OnlyDepositor();
error ExcessDeposit();
error WithdrawDisabled();
error PrematureWithdrawal();
error InvalidNewDeadline();

error ZeroAddress();
error StaticCallFailed();
error UnregisteredModule();

error IsFrozen();
error NotFrozen();
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;


event ClaimedSingle(address indexed user, uint256 tokenId, uint256 amount);
event Claimed(address indexed user, uint256[] tokenIds, uint256[] amounts);
event ClaimedByDelegate(address indexed delegate, address[] owners, uint256[] tokenIds, uint256[] amounts);
event ClaimedByModule(address indexed module, address indexed msgSender, uint256[] tokenIds, uint256[] amounts);

event Deposited(address indexed operator, uint256 amount);
event Withdrawn(address indexed operator, uint256 amount);

event ModuleUpdated(address indexed module, bool set);
event DeadlineUpdated(uint256 indexed newDeadline);
event DepositorUpdated(address indexed oldDepositor, address indexed newDepositor);
event OperatorUpdated(address indexed oldOperator, address indexed newOperator);

event StreamsPaused(uint256[] indexed tokenIds);
event StreamsUnpaused(uint256[] indexed tokenIds);

event Frozen(uint256 indexed timestamp);
event EmergencyExit(address receiver, uint256 balance);
// SPDX-License-Identifier: CC0-1.0
pragma solidity >=0.8.13;

/**
 * @title IDelegateRegistry
 * @custom:version 2.0
 * @custom:author foobar (0xfoobar)
 * @notice A standalone immutable registry storing delegated permissions from one address to another
 */
interface IDelegateRegistry {
    /// @notice Delegation type, NONE is used when a delegation does not exist or is revoked
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        ERC721,
        ERC20,
        ERC1155
    }

    /// @notice Struct for returning delegations
    struct Delegation {
        DelegationType type_;
        address to;
        address from;
        bytes32 rights;
        address contract_;
        uint256 tokenId;
        uint256 amount;
    }

    /// @notice Emitted when an address delegates or revokes rights for their entire wallet
    event DelegateAll(address indexed from, address indexed to, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for a contract address
    event DelegateContract(address indexed from, address indexed to, address indexed contract_, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for an ERC721 tokenId
    event DelegateERC721(address indexed from, address indexed to, address indexed contract_, uint256 tokenId, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for an amount of ERC20 tokens
    event DelegateERC20(address indexed from, address indexed to, address indexed contract_, bytes32 rights, uint256 amount);

    /// @notice Emitted when an address delegates or revokes rights for an amount of an ERC1155 tokenId
    event DelegateERC1155(address indexed from, address indexed to, address indexed contract_, uint256 tokenId, bytes32 rights, uint256 amount);

    /// @notice Thrown if multicall calldata is malformed
    error MulticallFailed();

    /**
     * -----------  WRITE -----------
     */

    /**
     * @notice Call multiple functions in the current contract and return the data from all of them if they all succeed
     * @param data The encoded function data for each of the calls to make to this contract
     * @return results The results from each of the calls passed in via data
     */
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for all contracts
     * @param to The address to act as delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateAll(address to, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific contract
     * @param to The address to act as delegate
     * @param contract_ The contract whose rights are being delegated
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateContract(address to, address contract_, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific ERC721 token
     * @param to The address to act as delegate
     * @param contract_ The contract whose rights are being delegated
     * @param tokenId The token id to delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC721(address to, address contract_, uint256 tokenId, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific amount of ERC20 tokens
     * @dev The actual amount is not encoded in the hash, just the existence of a amount (since it is an upper bound)
     * @param to The address to act as delegate
     * @param contract_ The address for the fungible token contract
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param amount The amount to delegate, > 0 delegates and 0 revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC20(address to, address contract_, bytes32 rights, uint256 amount) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific amount of ERC1155 tokens
     * @dev The actual amount is not encoded in the hash, just the existence of a amount (since it is an upper bound)
     * @param to The address to act as delegate
     * @param contract_ The address of the contract that holds the token
     * @param tokenId The token id to delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param amount The amount of that token id to delegate, > 0 delegates and 0 revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC1155(address to, address contract_, uint256 tokenId, bytes32 rights, uint256 amount) external payable returns (bytes32 delegationHash);

    /**
     * ----------- CHECKS -----------
     */

    /**
     * @notice Check if `to` is a delegate of `from` for the entire wallet
     * @param to The potential delegate address
     * @param from The potential address who delegated rights
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on the from's behalf
     */
    function checkDelegateForAll(address to, address from, bytes32 rights) external view returns (bool);

    /**
     * @notice Check if `to` is a delegate of `from` for the specified `contract_` or the entire wallet
     * @param to The delegated address to check
     * @param contract_ The specific contract address being checked
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on from's behalf for entire wallet or that specific contract
     */
    function checkDelegateForContract(address to, address from, address contract_, bytes32 rights) external view returns (bool);

    /**
     * @notice Check if `to` is a delegate of `from` for the specific `contract` and `tokenId`, the entire `contract_`, or the entire wallet
     * @param to The delegated address to check
     * @param contract_ The specific contract address being checked
     * @param tokenId The token id for the token to delegating
     * @param from The wallet that issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on from's behalf for entire wallet, that contract, or that specific tokenId
     */
    function checkDelegateForERC721(address to, address from, address contract_, uint256 tokenId, bytes32 rights) external view returns (bool);

    /**
     * @notice Returns the amount of ERC20 tokens the delegate is granted rights to act on the behalf of
     * @param to The delegated address to check
     * @param contract_ The address of the token contract
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return balance The delegated balance, which will be 0 if the delegation does not exist
     */
    function checkDelegateForERC20(address to, address from, address contract_, bytes32 rights) external view returns (uint256);

    /**
     * @notice Returns the amount of a ERC1155 tokens the delegate is granted rights to act on the behalf of
     * @param to The delegated address to check
     * @param contract_ The address of the token contract
     * @param tokenId The token id to check the delegated amount of
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return balance The delegated balance, which will be 0 if the delegation does not exist
     */
    function checkDelegateForERC1155(address to, address from, address contract_, uint256 tokenId, bytes32 rights) external view returns (uint256);

    /**
     * ----------- ENUMERATIONS -----------
     */

    /**
     * @notice Returns all enabled delegations a given delegate has received
     * @param to The address to retrieve delegations for
     * @return delegations Array of Delegation structs
     */
    function getIncomingDelegations(address to) external view returns (Delegation[] memory delegations);

    /**
     * @notice Returns all enabled delegations an address has given out
     * @param from The address to retrieve delegations for
     * @return delegations Array of Delegation structs
     */
    function getOutgoingDelegations(address from) external view returns (Delegation[] memory delegations);

    /**
     * @notice Returns all hashes associated with enabled delegations an address has received
     * @param to The address to retrieve incoming delegation hashes for
     * @return delegationHashes Array of delegation hashes
     */
    function getIncomingDelegationHashes(address to) external view returns (bytes32[] memory delegationHashes);

    /**
     * @notice Returns all hashes associated with enabled delegations an address has given out
     * @param from The address to retrieve outgoing delegation hashes for
     * @return delegationHashes Array of delegation hashes
     */
    function getOutgoingDelegationHashes(address from) external view returns (bytes32[] memory delegationHashes);

    /**
     * @notice Returns the delegations for a given array of delegation hashes
     * @param delegationHashes is an array of hashes that correspond to delegations
     * @return delegations Array of Delegation structs, return empty structs for nonexistent or revoked delegations
     */
    function getDelegationsFromHashes(bytes32[] calldata delegationHashes) external view returns (Delegation[] memory delegations);

    /**
     * ----------- STORAGE ACCESS -----------
     */

    /**
     * @notice Allows external contracts to read arbitrary storage slots
     */
    function readSlot(bytes32 location) external view returns (bytes32);

    /**
     * @notice Allows external contracts to read an arbitrary array of storage slots
     */
    function readSlots(bytes32[] calldata locations) external view returns (bytes32[] memory);
}
// SPDX-License-Identifier: MIT 
pragma solidity 0.8.24;

interface IModule {
   
    /**
     * @notice Check if tokenIds owner matches supplied address
     * @dev If user is owner of all tokenIds, fn expected to revert
     * @param user Address to check against 
     * @param tokenIds TokenIds to check
     */
    function streamingOwnerCheck(address user, uint256[] calldata tokenIds) external view;
}
// SPDX-License-Identifier: MIT 
pragma solidity 0.8.24;

import {IERC721} from "./../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {SafeERC20, IERC20} from "./../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable2Step, Ownable} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {Pausable} from "openzeppelin-contracts/contracts/utils/Pausable.sol";

import {IModule} from "./IModule.sol";
import {IDelegateRegistry} from "./IDelegateRegistry.sol";

import "./Events.sol";
import "./Errors.sol";

/**
 * @title NftStreaming
 * @custom:version 1.0
 * @custom:author Calnix(@cal_nix)
 * @notice Contract to stream token rewards to NFT holders 
 */

contract NftStreaming is Pausable, Ownable2Step {
    using SafeERC20 for IERC20;

    // assets
    IERC721 public immutable NFT;
    IERC20 public immutable TOKEN;

    // external 
    address public immutable DELEGATE_REGISTRY;  // https://docs.delegate.xyz/technical-documentation/delegate-registry/contract-addresses

    // total supply of NFTs
    uint256 public constant totalSupply = 8_888;
    
    // stream period
    uint256 public immutable startTime;
    uint256 public immutable endTime;
    
    // allocation
    uint256 public immutable allocationPerNft;    // expressed together with appropriate decimal precision [1 ether -> 1e18]
    uint256 public immutable emissionPerSecond;   // per NFT
    uint256 public immutable totalAllocation;

    // financing
    address public depositor;
    uint256 public totalClaimed;
    uint256 public totalDeposited;
    
    // optional: Users can claim until this timestamp
    uint256 public deadline;    

    // operator role: can pause, cannot unpause
    address public operator;            

    // emergency state: 1 is Frozed. 0 is not.
    uint256 public isFrozen;

    /**
     * @notice Struct encapsulating the claimed and refunded amounts, all denoted in units of the asset's decimals.
     * @dev Because the claimed amount and lastTimestamp are often read together, declaring them in the same slot saves gas.
     * @param claimed The cumulative amount withdrawn from the stream.
     * @param lastClaimedTimestamp Last claim time
     * @param isPaused Is the stream paused 
     */
    struct Stream {
        // slot0
        uint128 claimed;
        uint128 lastClaimedTimestamp;
        // slot 1
        bool isPaused;
    }

    // Streams 
    mapping(uint256 tokenId => Stream stream) public streams;
    
    // Trusted contracts to call
    mapping(address module => bool isRegistered) public modules;    

    // note: uint128(allocationPerNft) is used to ensure downstream calculations involving claimable do not overflow
    constructor(
        address nft, address token, address owner, address depositor_, address operator_, address delegateRegistry,
        uint128 allocationPerNft_, uint256 startTime_, uint256 endTime_) Ownable(owner) {
             
        // check inputs 
        if(startTime_ <= block.timestamp) revert InvalidStartime();
        if(endTime_ <= startTime_) revert InvalidEndTime(); 
        if(allocationPerNft_ == 0) revert InvalidAllocation();

        // calculate emissionPerSecond
        uint256 period = endTime_ - startTime_;       
        uint256 emissionPerSecond_ = allocationPerNft_ / period; 
        if(emissionPerSecond_ == 0) revert InvalidEmission();

        /**
            Note:
                Solidity rounds down on division, 
                so there could be disregarded remainder on calc. emissionPerSecond

                Therefore, the remainder is distributed on the last tick,
                as seen in the if statement in _calculateClaimable()
         */

        // update storage
        NFT = IERC721(nft);
        TOKEN = IERC20(token);
        DELEGATE_REGISTRY = delegateRegistry;

        depositor = depositor_;
        operator = operator_;

        startTime = startTime_;
        endTime = endTime_;
        emissionPerSecond = emissionPerSecond_;

        allocationPerNft = uint256(allocationPerNft_);        
        totalAllocation = allocationPerNft_ * totalSupply;

        deadline = 1791709200;
    }

    /*//////////////////////////////////////////////////////////////
                                 USERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Users to claim for a single Nft
     * @dev msg.sender must be owner of Nft
     * @param tokenId Nft's tokenId
     */
    function claimSingle(uint256 tokenId) external whenStartedAndBeforeDeadline whenNotPaused {

        // validate ownership
        address ownerOf = NFT.ownerOf(tokenId);
        if(msg.sender != ownerOf) revert InvalidOwner();  
        
        uint256 claimable = _updateLastClaimed(tokenId);

        // update totalClaimed
        totalClaimed += claimable;

        emit ClaimedSingle(msg.sender, tokenId, claimable);
 
        //transfer 
        TOKEN.safeTransfer(msg.sender, claimable);        
    }

    /**
     * @notice Users to claim for multiple Nfts
     * @dev msg.sender must be owner of all Nfts
     * @param tokenIds Nfts' tokenId
     */    
    function claim(uint256[] calldata tokenIds) external whenStartedAndBeforeDeadline whenNotPaused {
        
        // array validation
        uint256 tokenIdsLength = tokenIds.length;
        if(tokenIdsLength == 0) revert EmptyArray(); 


        uint256 totalAmount;
        uint256[] memory amounts = new uint256[](tokenIdsLength);
        for (uint256 i = 0; i < tokenIdsLength; ++i) {

            uint256 tokenId = tokenIds[i];

            // validate ownership: msg.sender == ownerOf
            address ownerOf = NFT.ownerOf(tokenId);
            if(msg.sender != ownerOf) revert InvalidOwner();  

            // update claims
            uint256 claimable = _updateLastClaimed(tokenId);
            
            amounts[i] = claimable;
            totalAmount += claimable;
        }
        
        // update totalClaimed
        totalClaimed += totalAmount;

        // claimed per tokenId
        emit Claimed(msg.sender, tokenIds, amounts);
 
        // transfer all
        TOKEN.safeTransfer(msg.sender, totalAmount);      
    }

    /**
     * @notice Users to claim via delegated hot wallets
     * @dev Expects tokenIds to be ordered based on common ownership: [ownerA, ownerA, ownerB]
     * @param tokenIds Nfts' tokenId
     */  
    function claimDelegated(uint256[] calldata tokenIds) external whenStartedAndBeforeDeadline whenNotPaused {
        
        // array validation
        uint256 tokenIdsLength = tokenIds.length;
        if(tokenIdsLength == 0) revert EmptyArray(); 

        // check delegation on msg.sender
        bytes[] memory data = new bytes[](tokenIdsLength);
        address[] memory owners = new address[](tokenIdsLength);
        for (uint256 i = 0; i < tokenIdsLength; ++i) {
            
            uint256 tokenId = tokenIds[i];

            // get and store nft Owner
            address nftOwner = NFT.ownerOf(tokenId);          
            owners[i] = nftOwner;

            // data for multicall
            data[i] = abi.encodeCall(IDelegateRegistry(DELEGATE_REGISTRY).checkDelegateForERC721, 
                        (msg.sender, nftOwner, address(NFT), tokenId, ""));
        }
        
        // data for staticCall
        bytes memory staticData = abi.encodeCall(IDelegateRegistry(DELEGATE_REGISTRY).multicall, data); 
        
        // staticCall
        (bool success, bytes memory result) = DELEGATE_REGISTRY.staticcall(staticData); 
        if (!success) revert StaticCallFailed();

        // if a tokenId is not delegated will return false; as a bool
        bytes[] memory results = abi.decode(result, (bytes[]));

        uint256 totalAmount;
        uint256[] memory amounts = new uint256[](tokenIdsLength);

        address addressCache; 
        uint256 amountCache;

        for (uint256 i = 0; i < tokenIdsLength; ++i) {
            
            // multiCall uses delegateCall: decode return data
            bool isDelegated = abi.decode(results[i], (bool));
            if(!isDelegated) revert InvalidDelegate();

            // update tokenId: storage is updated
            uint256 tokenId = tokenIds[i];
            uint256 claimable = _updateLastClaimed(tokenId);
            
            totalAmount += claimable;
            amounts[i] = claimable;

            // initial reference
            if (i == 0) {

                addressCache = owners[i];
                amountCache = claimable;

            } else { 

                // check owner matches previous tokenid's owner
                if (addressCache == owners[i]) {
                    // increment amountCache
                    amountCache += claimable; 

                } else {  // if different owner from previous token id

                    // transfer current amountCache
                    TOKEN.safeTransfer(addressCache, amountCache); 

                    // update cache to current token id info
                    addressCache = owners[i];
                    amountCache = claimable;
                } 
            }
        }
       

        if (amountCache != 0) {
            TOKEN.safeTransfer(addressCache, amountCache); 
        }

        // update totalClaimed
        totalClaimed += totalAmount;

        // claimed per tokenId
        emit ClaimedByDelegate(msg.sender, owners, tokenIds, amounts);
    }
    

    /**
     * @notice Users to claim, if nft is locked on some contract (e.g. staking pro)
     * @dev Owner must have enabled module address
     * @param module Nfts' tokenId
     * @param tokenIds Nfts' tokenId
     */  
    function claimViaModule(address module, uint256[] calldata tokenIds) external whenStartedAndBeforeDeadline whenNotPaused {
        if(module == address(0)) revert ZeroAddress();      // in-case someone fat-fingers and allows zero address in modules mapping

        // array validation
        uint256 tokenIdsLength = tokenIds.length;
        if(tokenIdsLength == 0) revert EmptyArray(); 

        // ensure valid module
        if(!modules[module]) revert UnregisteredModule(); 

        // check ownership via moduleCall
        // if not msg.sender is not owner, execution expected to revert within module;
        IModule(module).streamingOwnerCheck(msg.sender, tokenIds);

        uint256 totalAmount;
        uint256[] memory amounts = new uint256[](tokenIdsLength);
        
        for (uint256 i = 0; i < tokenIdsLength; ++i) {

                uint256 tokenId = tokenIds[i];
                uint256 claimable = _updateLastClaimed(tokenId);
                
                totalAmount += claimable;
                amounts[i] = claimable;
        }

        // update totalClaimed
        totalClaimed += totalAmount;

        // claimed per tokenId
        emit ClaimedByModule(module, msg.sender, tokenIds, amounts);

        // transfer 
        TOKEN.safeTransfer(msg.sender, totalAmount);    
    }


    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    //note: safeCast not used in downcasting, since overflowing uint128 is not expected
    function _updateLastClaimed(uint256 tokenId) internal returns(uint256) {
        
        // get data
        Stream memory stream = streams[tokenId];

        // stream previously updated: return
        if(stream.lastClaimedTimestamp == block.timestamp) return(0);

        // stream ended: return
        if(stream.lastClaimedTimestamp == endTime) return(0);

        // stream paused: revert
        if(stream.isPaused) revert StreamPaused();

        // calc claimable
        (uint256 claimable, uint256 currentTimestamp) = _calculateClaimable(stream.lastClaimedTimestamp, stream.claimed);

        /** Note: 
            uint128 max value: 340,282,366,920,938,463,463,374,607,431,768,211,455 [340 undecillion]
            If token supply is >= 340 undecillion, SafeCast should be used
         */

        // update timestamp + claimed        
        stream.lastClaimedTimestamp = uint128(currentTimestamp);
        stream.claimed += uint128(claimable);

        // sanity check: ensure does not exceed max
        if(stream.claimed > allocationPerNft) revert IncorrectClaimable();

        // update storage
        streams[tokenId] = stream;

        return claimable;
    }

    function _calculateClaimable(uint128 lastClaimedTimestamp, uint128 claimed) internal view returns(uint256, uint256) {
        
        // currentTimestamp <= endTime
        uint256 currentTimestamp = block.timestamp > endTime ? endTime : block.timestamp;

        // last tick distributes any remainder, above the usual emissionPerSecond
        if (currentTimestamp == endTime) {

            return (allocationPerNft - claimed, currentTimestamp);

        } else {

            // lastClaimedTimestamp >= startTime
            uint256 lastClaimedTimestamp = lastClaimedTimestamp < startTime ? startTime : lastClaimedTimestamp;

            uint256 timeDelta = currentTimestamp - lastClaimedTimestamp;
            uint256 claimable = emissionPerSecond * timeDelta;

            return (claimable, currentTimestamp);
        }
    }

    /*//////////////////////////////////////////////////////////////
                                 OWNER
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Owner to update deadline variable
     * @dev By default deadline = 0 
     * @param newDeadline must be after last claim round + 14 days
     */
    function updateDeadline(uint256 newDeadline) external onlyOwner {

        // allow for 14 days buffer: prevent malicious premature ending
        // if the newDeadline is in the past: can insta-withdraw w/o informing users
        uint256 latestTime = block.timestamp > endTime ? block.timestamp : endTime;
        if (newDeadline < (latestTime + 14 days)) revert InvalidNewDeadline();

        deadline = newDeadline;
        emit DeadlineUpdated(newDeadline);
    }

    /**
     * @notice Owner to update depositor address
     * @dev Depositor role allows calling of deposit and withdraw fns
     * @param newDepositor new address
     */
    function updateDepositor(address newDepositor) external onlyOwner {
        
        address oldDepositor = depositor;
        depositor = newDepositor;

        emit DepositorUpdated(oldDepositor, newDepositor);
    }

    /**
     * @notice Enable or disable a module. Only Owner.
     * @dev Module is expected to implement fn 'streamingOwnerCheck(address,uint256[])'
     * @param module Address of contract
     * @param set True - enable | False - disable
     */ 
    function updateModule(address module, bool set) external onlyOwner {
        
        modules[module] = set;

        emit ModuleUpdated(module, set);
    }

    /**
     * @notice Owner to update operator role
     * @dev Can be set to address(0) to eliminiate the role
     * @param newOperator new operator address
     */ 
    function updateOperator(address newOperator) external onlyOwner {
        
        address oldOperator = operator;
        operator = newOperator;

        emit OperatorUpdated(oldOperator, newOperator);
    }

    /**
     * @notice Owner or operator can pause streams
     * @param tokenIds Nfts' tokenId
     */ 
    function pauseStreams(uint256[] calldata tokenIds) external {
        
        // if not operator, check if owner; else revert
        if(msg.sender != operator) {
            _checkOwner();
        }


        // array validation
        uint256 tokenIdsLength = tokenIds.length;
        if(tokenIdsLength == 0) revert EmptyArray(); 

        // pause streams
        for (uint256 i = 0; i < tokenIdsLength; ++i) {

            uint256 tokenId = tokenIds[i];

            streams[tokenId].isPaused = true;
        }

        emit StreamsPaused(tokenIds);
    }

    /**
     * @notice Only owner can unpause streams
     */ 
    function unpauseStreams(uint256[] calldata tokenIds) external onlyOwner {

        // array validation
        uint256 tokenIdsLength = tokenIds.length;
        if(tokenIdsLength == 0) revert EmptyArray(); 

        // unpause streams
        for (uint256 i = 0; i < tokenIdsLength; ++i) {

            uint256 tokenId = tokenIds[i];

            delete streams[tokenId].isPaused;
        }        

        emit StreamsUnpaused(tokenIds);

    }

    /*//////////////////////////////////////////////////////////////
                               DEPOSITOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Depositor to deposit the tokens required for streaming
     * @dev Depositor can fund in totality at once or incrementally, 
            to avoid having to commit a large initial sum
     * @param amount Amount to deposit
     */
    function deposit(uint256 amount) external whenNotPaused {
        if(msg.sender != depositor) revert OnlyDepositor(); 

        // surplus check
        if((totalDeposited + amount) > totalAllocation) revert ExcessDeposit(); 

        totalDeposited += amount;

        emit Deposited(msg.sender, amount);

        TOKEN.safeTransferFrom(msg.sender, address(this), amount);
    }


    /**
     * @notice Depositor to withdraw all unclaimed tokens past the specified deadline
     * @dev Only possible if deadline is non-zero and exceeded
     */
    function withdraw() external whenNotPaused {
        if(msg.sender != depositor) revert OnlyDepositor(); 

        // if deadline is not defined; cannot withdraw
        if(deadline == 0) revert WithdrawDisabled();
        
        // can only withdraw after deadline
        if(block.timestamp <= deadline) revert PrematureWithdrawal();

        // only can withdraw what was deposited. disregards random transfers
        uint256 available = totalDeposited - totalClaimed;

        emit Withdrawn(msg.sender, available);

        TOKEN.safeTransfer(msg.sender, available);       

    }


    /*//////////////////////////////////////////////////////////////
                                PAUSABLE
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Pause claiming, deposit and withdraw
     * @dev Either the operator or owner can call; no one else
     */
    function pause() external whenNotPaused {
        
        // if not operator, check if owner; else revert
        if(msg.sender != operator) {
            _checkOwner();
        }

        _pause();
    }

    /**
     * @notice Unpause claim. Cannot unpause once frozen
     * @dev Only owner can unpause
     */
    function unpause() external onlyOwner whenPaused {
        if(isFrozen == 1) revert IsFrozen(); 

        _unpause();
    }

    /*//////////////////////////////////////////////////////////////
                                RECOVERY
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Freeze the contract in the event of something untoward occuring
     * @dev Only callable from a paused state, affirming that distribution should not resume
     *      Nothing to be updated. Freeze as is.
            Enables emergencyExit() to be called.
     */
    function freeze() external whenPaused onlyOwner {
        if(isFrozen == 1) revert IsFrozen(); 
        
        isFrozen = 1;

        emit Frozen(block.timestamp);
    }  


    /**
     * @notice Recover assets in a black swan event. 
               Assumed that this contract will no longer be used. 
     * @dev Transfers all tokens to specified address 
     * @param receiver Address of beneficiary of transfer
     */
    function emergencyExit(address receiver) external whenPaused onlyOwner {
        if(isFrozen == 0) revert NotFrozen();

        uint256 balance = TOKEN.balanceOf(address(this));

        emit EmergencyExit(receiver, balance);

        TOKEN.safeTransfer(receiver, balance);
    }


    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/


    modifier whenStartedAndBeforeDeadline() {

        if(block.timestamp <= startTime) revert NotStarted();

        // check that deadline as not been exceeded; if deadline has been defined
        if(deadline > 0) {
            if (block.timestamp > deadline) {
                revert DeadlineExceeded();
            }
        }

        _;
    }
  


    /*//////////////////////////////////////////////////////////////
                                  VIEW
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns claimable amount for specified tokenId
     * @param tokenId Nft's tokenId
     */ 
    function claimable(uint256 tokenId) external view returns(uint256) {
        
        // get data
        Stream memory stream = streams[tokenId];

        // nothing to claim
        if(stream.lastClaimedTimestamp == block.timestamp) return(0);

        // calc. claimable
        (uint256 claimable, /*uint256 currentTimestamp*/) = _calculateClaimable(stream.lastClaimedTimestamp, stream.claimed);

        return claimable;
    }

}