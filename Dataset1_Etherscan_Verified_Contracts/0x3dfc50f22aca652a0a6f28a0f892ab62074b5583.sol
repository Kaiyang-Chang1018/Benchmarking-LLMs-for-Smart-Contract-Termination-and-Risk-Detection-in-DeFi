// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` amount of tokens of type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the value of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155Received} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155BatchReceived} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits either a {TransferSingle} or a {TransferBatch} event, depending on the length of the array arguments.
     *
     * Requirements:
     *
     * - `ids` and `values` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;
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
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

import { ICSVerifier } from "./interfaces/ICSVerifier.sol";
import { ICSModule } from "./interfaces/ICSModule.sol";

import { BeaconBlockHeader, Slot, Validator, Withdrawal } from "./lib/Types.sol";
import { GIndex } from "./lib/GIndex.sol";
import { SSZ } from "./lib/SSZ.sol";

/// @notice Convert withdrawal amount to wei
/// @param withdrawal Withdrawal struct
function amountWei(Withdrawal memory withdrawal) pure returns (uint256) {
    return gweiToWei(withdrawal.amount);
}

/// @notice Convert gwei to wei
/// @param amount Amount in gwei
function gweiToWei(uint64 amount) pure returns (uint256) {
    return uint256(amount) * 1 gwei;
}

contract CSVerifier is ICSVerifier {
    using { amountWei } for Withdrawal;

    using SSZ for BeaconBlockHeader;
    using SSZ for Withdrawal;
    using SSZ for Validator;

    // See `BEACON_ROOTS_ADDRESS` constant in the EIP-4788.
    address public constant BEACON_ROOTS =
        0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    uint64 public immutable SLOTS_PER_EPOCH;

    /// @dev This index is relative to a state like: `BeaconState.latest_execution_payload_header.withdrawals[0]`.
    GIndex public immutable GI_FIRST_WITHDRAWAL_PREV;

    /// @dev This index is relative to a state like: `BeaconState.latest_execution_payload_header.withdrawals[0]`.
    GIndex public immutable GI_FIRST_WITHDRAWAL_CURR;

    /// @dev This index is relative to a state like: `BeaconState.validators[0]`.
    GIndex public immutable GI_FIRST_VALIDATOR_PREV;

    /// @dev This index is relative to a state like: `BeaconState.validators[0]`.
    GIndex public immutable GI_FIRST_VALIDATOR_CURR;

    /// @dev This index is relative to a state like: `BeaconState.historical_summaries`.
    GIndex public immutable GI_HISTORICAL_SUMMARIES_PREV;

    /// @dev This index is relative to a state like: `BeaconState.historical_summaries`.
    GIndex public immutable GI_HISTORICAL_SUMMARIES_CURR;

    /// @dev The very first slot the verifier is supposed to accept proofs for.
    Slot public immutable FIRST_SUPPORTED_SLOT;

    /// @dev The first slot of the currently compatible fork.
    Slot public immutable PIVOT_SLOT;

    /// @dev An address withdrawals are supposed to happen to (Lido withdrawal credentials).
    address public immutable WITHDRAWAL_ADDRESS;

    /// @dev Staking module contract
    ICSModule public immutable MODULE;

    error RootNotFound();
    error InvalidGIndex();
    error InvalidBlockHeader();
    error InvalidChainConfig();
    error PartialWithdrawal();
    error ValidatorNotWithdrawn();
    error InvalidWithdrawalAddress();
    error UnsupportedSlot(Slot slot);
    error ZeroModuleAddress();
    error ZeroWithdrawalAddress();
    error InvalidPivotSlot();

    /// @dev The previous and current forks can be essentially the same.
    constructor(
        address withdrawalAddress,
        address module,
        uint64 slotsPerEpoch,
        GIndex gIFirstWithdrawalPrev,
        GIndex gIFirstWithdrawalCurr,
        GIndex gIFirstValidatorPrev,
        GIndex gIFirstValidatorCurr,
        GIndex gIHistoricalSummariesPrev,
        GIndex gIHistoricalSummariesCurr,
        Slot firstSupportedSlot,
        Slot pivotSlot
    ) {
        if (withdrawalAddress == address(0)) revert ZeroWithdrawalAddress();
        if (module == address(0)) revert ZeroModuleAddress();

        if (slotsPerEpoch == 0) revert InvalidChainConfig();
        if (firstSupportedSlot > pivotSlot) revert InvalidPivotSlot();

        WITHDRAWAL_ADDRESS = withdrawalAddress;
        MODULE = ICSModule(module);

        SLOTS_PER_EPOCH = slotsPerEpoch;

        GI_FIRST_WITHDRAWAL_PREV = gIFirstWithdrawalPrev;
        GI_FIRST_WITHDRAWAL_CURR = gIFirstWithdrawalCurr;

        GI_FIRST_VALIDATOR_PREV = gIFirstValidatorPrev;
        GI_FIRST_VALIDATOR_CURR = gIFirstValidatorCurr;

        GI_HISTORICAL_SUMMARIES_PREV = gIHistoricalSummariesPrev;
        GI_HISTORICAL_SUMMARIES_CURR = gIHistoricalSummariesCurr;

        FIRST_SUPPORTED_SLOT = firstSupportedSlot;
        PIVOT_SLOT = pivotSlot;
    }

    /// @notice Verify slashing proof and report slashing to the module for valid proofs
    /// @param beaconBlock Beacon block header
    /// @param witness Slashing witness
    /// @param nodeOperatorId ID of the Node Operator
    /// @param keyIndex Index of the validator key in the Node Operator's key storage
    function processSlashingProof(
        ProvableBeaconBlockHeader calldata beaconBlock,
        SlashingWitness calldata witness,
        uint256 nodeOperatorId,
        uint256 keyIndex
    ) external {
        if (beaconBlock.header.slot < FIRST_SUPPORTED_SLOT) {
            revert UnsupportedSlot(beaconBlock.header.slot);
        }

        {
            bytes32 trustedHeaderRoot = _getParentBlockRoot(
                beaconBlock.rootsTimestamp
            );
            if (trustedHeaderRoot != beaconBlock.header.hashTreeRoot()) {
                revert InvalidBlockHeader();
            }
        }

        bytes memory pubkey = MODULE.getSigningKeys(
            nodeOperatorId,
            keyIndex,
            1
        );

        Validator memory validator = Validator({
            pubkey: pubkey,
            withdrawalCredentials: witness.withdrawalCredentials,
            effectiveBalance: witness.effectiveBalance,
            slashed: true,
            activationEligibilityEpoch: witness.activationEligibilityEpoch,
            activationEpoch: witness.activationEpoch,
            exitEpoch: witness.exitEpoch,
            withdrawableEpoch: witness.withdrawableEpoch
        });

        SSZ.verifyProof({
            proof: witness.validatorProof,
            root: beaconBlock.header.stateRoot,
            leaf: validator.hashTreeRoot(),
            gI: _getValidatorGI(witness.validatorIndex, beaconBlock.header.slot)
        });

        MODULE.submitInitialSlashing(nodeOperatorId, keyIndex);
    }

    /// @notice Verify withdrawal proof and report withdrawal to the module for valid proofs
    /// @param beaconBlock Beacon block header
    /// @param witness Withdrawal witness
    /// @param nodeOperatorId ID of the Node Operator
    /// @param keyIndex Index of the validator key in the Node Operator's key storage
    function processWithdrawalProof(
        ProvableBeaconBlockHeader calldata beaconBlock,
        WithdrawalWitness calldata witness,
        uint256 nodeOperatorId,
        uint256 keyIndex
    ) external {
        if (beaconBlock.header.slot < FIRST_SUPPORTED_SLOT) {
            revert UnsupportedSlot(beaconBlock.header.slot);
        }

        {
            bytes32 trustedHeaderRoot = _getParentBlockRoot(
                beaconBlock.rootsTimestamp
            );
            if (trustedHeaderRoot != beaconBlock.header.hashTreeRoot()) {
                revert InvalidBlockHeader();
            }
        }

        bytes memory pubkey = MODULE.getSigningKeys(
            nodeOperatorId,
            keyIndex,
            1
        );

        uint256 withdrawalAmount = _processWithdrawalProof({
            witness: witness,
            stateSlot: beaconBlock.header.slot,
            stateRoot: beaconBlock.header.stateRoot,
            pubkey: pubkey
        });

        MODULE.submitWithdrawal(
            nodeOperatorId,
            keyIndex,
            withdrawalAmount,
            witness.slashed
        );
    }

    /// @notice Verify withdrawal proof against historical summaries data and report withdrawal to the module for valid proofs
    /// @param beaconBlock Beacon block header
    /// @param oldBlock Historical block header witness
    /// @param witness Withdrawal witness
    /// @param nodeOperatorId ID of the Node Operator
    /// @param keyIndex Index of the validator key in the Node Operator's key storage
    function processHistoricalWithdrawalProof(
        ProvableBeaconBlockHeader calldata beaconBlock,
        HistoricalHeaderWitness calldata oldBlock,
        WithdrawalWitness calldata witness,
        uint256 nodeOperatorId,
        uint256 keyIndex
    ) external {
        if (beaconBlock.header.slot < FIRST_SUPPORTED_SLOT) {
            revert UnsupportedSlot(beaconBlock.header.slot);
        }

        if (oldBlock.header.slot < FIRST_SUPPORTED_SLOT) {
            revert UnsupportedSlot(oldBlock.header.slot);
        }

        {
            bytes32 trustedHeaderRoot = _getParentBlockRoot(
                beaconBlock.rootsTimestamp
            );
            bytes32 headerRoot = beaconBlock.header.hashTreeRoot();
            if (trustedHeaderRoot != headerRoot) {
                revert InvalidBlockHeader();
            }
        }

        // It's up to a user to provide a valid generalized index of a historical block root in a summaries list.
        // Ensuring the provided generalized index is for a node somewhere below the historical_summaries root.
        if (
            !_getHistoricalSummariesGI(beaconBlock.header.slot).isParentOf(
                oldBlock.rootGIndex
            )
        ) {
            revert InvalidGIndex();
        }

        SSZ.verifyProof({
            proof: oldBlock.proof,
            root: beaconBlock.header.stateRoot,
            leaf: oldBlock.header.hashTreeRoot(),
            gI: oldBlock.rootGIndex
        });

        bytes memory pubkey = MODULE.getSigningKeys(
            nodeOperatorId,
            keyIndex,
            1
        );

        uint256 withdrawalAmount = _processWithdrawalProof({
            witness: witness,
            stateSlot: oldBlock.header.slot,
            stateRoot: oldBlock.header.stateRoot,
            pubkey: pubkey
        });

        MODULE.submitWithdrawal(
            nodeOperatorId,
            keyIndex,
            withdrawalAmount,
            witness.slashed
        );
    }

    function _getParentBlockRoot(
        uint64 blockTimestamp
    ) internal view returns (bytes32) {
        (bool success, bytes memory data) = BEACON_ROOTS.staticcall(
            abi.encode(blockTimestamp)
        );

        if (!success || data.length == 0) {
            revert RootNotFound();
        }

        return abi.decode(data, (bytes32));
    }

    /// @dev `stateRoot` is supposed to be trusted at this point.
    function _processWithdrawalProof(
        WithdrawalWitness calldata witness,
        Slot stateSlot,
        bytes32 stateRoot,
        bytes memory pubkey
    ) internal view returns (uint256 withdrawalAmount) {
        // WC to address
        address withdrawalAddress = address(
            uint160(uint256(witness.withdrawalCredentials))
        );
        if (withdrawalAddress != WITHDRAWAL_ADDRESS) {
            revert InvalidWithdrawalAddress();
        }

        if (_computeEpochAtSlot(stateSlot) < witness.withdrawableEpoch) {
            revert ValidatorNotWithdrawn();
        }

        // See https://hackmd.io/1wM8vqeNTjqt4pC3XoCUKQ
        //
        // ISSUE:
        // There is a possible way to bypass this check:
        // - wait for full withdrawal & sweep
        // - be lucky enough that no one provides proof for this withdrawal for at least 1 sweep cycle
        //  (~8 days with the network of 1M active validators)
        // - deposit 1 ETH for slashed or 8 ETH for non-slashed validator
        // - wait for a sweep of this deposit
        // - provide proof of the last withdrawal
        // As a result, the Node Operator's bond will be penalized for 32 ETH - additional deposit value
        // However, all ETH involved,
        // including 1 or 8 ETH deposited by the attacker will remain in the Lido on Ethereum protocol
        // Hence, the only consequence of the attack is an inconsistency in the bond accounting that can be resolved
        // through the bond deposit approved by the corresponding DAO decision
        //
        // Resolution:
        // Given no losses for the protocol,
        // significant cost of attack (1 or 8 ETH),
        // and lack of feasible ways to mitigate it in the smart contract's code,
        // it is proposed to acknowledge possibility of the attack
        // and be ready to propose a corresponding vote to the DAO if it will ever happen
        if (!witness.slashed && gweiToWei(witness.amount) < 8 ether) {
            revert PartialWithdrawal();
        }

        Validator memory validator = Validator({
            pubkey: pubkey,
            withdrawalCredentials: witness.withdrawalCredentials,
            effectiveBalance: witness.effectiveBalance,
            slashed: witness.slashed,
            activationEligibilityEpoch: witness.activationEligibilityEpoch,
            activationEpoch: witness.activationEpoch,
            exitEpoch: witness.exitEpoch,
            withdrawableEpoch: witness.withdrawableEpoch
        });

        SSZ.verifyProof({
            proof: witness.validatorProof,
            root: stateRoot,
            leaf: validator.hashTreeRoot(),
            gI: _getValidatorGI(witness.validatorIndex, stateSlot)
        });

        Withdrawal memory withdrawal = Withdrawal({
            index: witness.withdrawalIndex,
            validatorIndex: witness.validatorIndex,
            withdrawalAddress: withdrawalAddress,
            amount: witness.amount
        });

        SSZ.verifyProof({
            proof: witness.withdrawalProof,
            root: stateRoot,
            leaf: withdrawal.hashTreeRoot(),
            gI: _getWithdrawalGI(witness.withdrawalOffset, stateSlot)
        });

        return withdrawal.amountWei();
    }

    function _getValidatorGI(
        uint256 offset,
        Slot stateSlot
    ) internal view returns (GIndex) {
        GIndex gI = stateSlot < PIVOT_SLOT
            ? GI_FIRST_VALIDATOR_PREV
            : GI_FIRST_VALIDATOR_CURR;
        return gI.shr(offset);
    }

    function _getWithdrawalGI(
        uint256 offset,
        Slot stateSlot
    ) internal view returns (GIndex) {
        GIndex gI = stateSlot < PIVOT_SLOT
            ? GI_FIRST_WITHDRAWAL_PREV
            : GI_FIRST_WITHDRAWAL_CURR;
        return gI.shr(offset);
    }

    function _getHistoricalSummariesGI(
        Slot stateSlot
    ) internal view returns (GIndex) {
        return
            stateSlot < PIVOT_SLOT
                ? GI_HISTORICAL_SUMMARIES_PREV
                : GI_HISTORICAL_SUMMARIES_CURR;
    }

    // From HashConsensus contract.
    function _computeEpochAtSlot(Slot slot) internal view returns (uint256) {
        // See: github.com/ethereum/consensus-specs/blob/dev/specs/phase0/beacon-chain.md#compute_epoch_at_slot
        return slot.unwrap() / SLOTS_PER_EPOCH;
    }
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

import { ICSBondCore } from "./ICSBondCore.sol";
import { ICSBondCurve } from "./ICSBondCurve.sol";
import { ICSBondLock } from "./ICSBondLock.sol";
import { ICSFeeDistributor } from "./ICSFeeDistributor.sol";
import { IAssetRecovererLib } from "../lib/AssetRecovererLib.sol";

interface ICSAccounting is
    ICSBondCore,
    ICSBondCurve,
    ICSBondLock,
    IAssetRecovererLib
{
    struct PermitInput {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function feeDistributor() external view returns (ICSFeeDistributor);

    function chargePenaltyRecipient() external view returns (address);

    function getRequiredBondForNextKeys(
        uint256 nodeOperatorId,
        uint256 additionalKeys
    ) external view returns (uint256);

    function getBondAmountByKeysCountWstETH(
        uint256 keysCount,
        uint256 curveId
    ) external view returns (uint256);

    function getBondAmountByKeysCountWstETH(
        uint256 keysCount,
        BondCurve memory curve
    ) external view returns (uint256);

    function getRequiredBondForNextKeysWstETH(
        uint256 nodeOperatorId,
        uint256 additionalKeys
    ) external view returns (uint256);

    function getUnbondedKeysCount(
        uint256 nodeOperatorId
    ) external view returns (uint256);

    function getUnbondedKeysCountToEject(
        uint256 nodeOperatorId
    ) external view returns (uint256);

    function depositWstETH(
        address from,
        uint256 nodeOperatorId,
        uint256 wstETHAmount,
        PermitInput calldata permit
    ) external;

    function depositStETH(
        address from,
        uint256 nodeOperatorId,
        uint256 stETHAmount,
        PermitInput calldata permit
    ) external;

    function depositETH(address from, uint256 nodeOperatorId) external payable;

    function claimRewardsStETH(
        uint256 nodeOperatorId,
        uint256 stETHAmount,
        address rewardAddress,
        uint256 cumulativeFeeShares,
        bytes32[] calldata rewardsProof
    ) external;

    function claimRewardsWstETH(
        uint256 nodeOperatorId,
        uint256 wstETHAmount,
        address rewardAddress,
        uint256 cumulativeFeeShares,
        bytes32[] calldata rewardsProof
    ) external;

    function claimRewardsUnstETH(
        uint256 nodeOperatorId,
        uint256 stEthAmount,
        address rewardAddress,
        uint256 cumulativeFeeShares,
        bytes32[] calldata rewardsProof
    ) external;

    function lockBondETH(uint256 nodeOperatorId, uint256 amount) external;

    function releaseLockedBondETH(
        uint256 nodeOperatorId,
        uint256 amount
    ) external;

    function settleLockedBondETH(uint256 nodeOperatorId) external;

    function compensateLockedBondETH(uint256 nodeOperatorId) external payable;

    function setBondCurve(uint256 nodeOperatorId, uint256 curveId) external;

    function resetBondCurve(uint256 nodeOperatorId) external;

    function penalize(uint256 nodeOperatorId, uint256 amount) external;

    function chargeFee(uint256 nodeOperatorId, uint256 amount) external;
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

interface ICSBondCore {
    function totalBondShares() external view returns (uint256);

    function getBondShares(
        uint256 nodeOperatorId
    ) external view returns (uint256);

    function getBond(uint256 nodeOperatorId) external view returns (uint256);
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

interface ICSBondCurve {
    /// @dev Bond curve structure.
    /// It contains:
    ///  - points |> total bond amount for particular keys count
    ///  - trend  |> value for the next keys after described points
    ///
    /// For example, how the curve points look like:
    ///   Points Array Index  |>       0          1          2          i
    ///   Bond Amount         |>   [ 2 ETH ] [ 3.9 ETH ] [ 5.7 ETH ] [ ... ]
    ///   Keys Count          |>       1          2          3        i + 1
    ///
    ///   Bond Amount (ETH)
    ///       ^
    ///       |
    ///     6 -
    ///       | ------------------ 5.7 ETH --> .
    ///   5.5 -                              ..^
    ///       |                             .  |
    ///     5 -                            .   |
    ///       |                           .    |
    ///   4.5 -                          .     |
    ///       |                         .      |
    ///     4 -                       ..       |
    ///       | ------- 3.9 ETH --> ..         |
    ///   3.5 -                    .^          |
    ///       |                  .. |          |
    ///     3 -                ..   |          |
    ///       |               .     |          |
    ///   2.5 -              .      |          |
    ///       |            ..       |          |
    ///     2 - -------->..         |          |
    ///       |          ^          |          |
    ///       |----------|----------|----------|----------|----> Keys Count
    ///       |          1          2          3          i
    ///
    struct BondCurve {
        uint256[] points;
        uint256 trend;
    }

    // solhint-disable-next-line
    function DEFAULT_BOND_CURVE_ID() external view returns (uint256);

    function getCurveInfo(
        uint256 curveId
    ) external view returns (BondCurve memory);

    function getBondCurve(
        uint256 nodeOperatorId
    ) external view returns (BondCurve memory);

    function getBondCurveId(
        uint256 nodeOperatorId
    ) external view returns (uint256);

    function getBondAmountByKeysCount(
        uint256 keys,
        uint256 curveId
    ) external view returns (uint256);

    function getBondAmountByKeysCount(
        uint256 keys,
        BondCurve memory curve
    ) external view returns (uint256);

    function getKeysCountByBondAmount(
        uint256 amount,
        uint256 curveId
    ) external view returns (uint256);

    function getKeysCountByBondAmount(
        uint256 amount,
        BondCurve memory curve
    ) external view returns (uint256);
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

interface ICSBondLock {
    /// @dev Bond lock structure.
    /// It contains:
    ///  - amount         |> amount of locked bond
    ///  - retentionUntil |> timestamp until locked bond is retained
    struct BondLock {
        uint128 amount;
        uint128 retentionUntil;
    }

    function getBondLockRetentionPeriod()
        external
        view
        returns (uint256 retention);

    function getLockedBondInfo(
        uint256 nodeOperatorId
    ) external view returns (BondLock memory);

    function getActualLockedBond(
        uint256 nodeOperatorId
    ) external view returns (uint256);
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

import { IAssetRecovererLib } from "../lib/AssetRecovererLib.sol";

pragma solidity 0.8.24;

interface ICSFeeDistributor is IAssetRecovererLib {
    function getFeesToDistribute(
        uint256 nodeOperatorId,
        uint256 shares,
        bytes32[] calldata proof
    ) external view returns (uint256);

    function distributeFees(
        uint256 nodeOperatorId,
        uint256 shares,
        bytes32[] calldata proof
    ) external returns (uint256);

    function processOracleReport(
        bytes32 _treeRoot,
        string calldata _treeCid,
        string calldata _logCid,
        uint256 _distributedShares
    ) external;

    /// @notice Returns the amount of shares that are pending to be distributed
    function pendingSharesToDistribute() external view returns (uint256);
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

import { IStakingModule } from "./IStakingModule.sol";
import { ICSAccounting } from "./ICSAccounting.sol";
import { IQueueLib } from "../lib/QueueLib.sol";
import { INOAddresses } from "../lib/NOAddresses.sol";
import { IAssetRecovererLib } from "../lib/AssetRecovererLib.sol";

struct NodeOperator {
    // All the counters below are used together e.g. in the _updateDepositableValidatorsCount
    /* 1 */ uint32 totalAddedKeys; // @dev increased and decreased when removed
    /* 1 */ uint32 totalWithdrawnKeys; // @dev only increased
    /* 1 */ uint32 totalDepositedKeys; // @dev only increased
    /* 1 */ uint32 totalVettedKeys; // @dev both increased and decreased
    /* 1 */ uint32 stuckValidatorsCount; // @dev both increased and decreased
    /* 1 */ uint32 depositableValidatorsCount; // @dev any value
    /* 1 */ uint32 targetLimit;
    /* 1 */ uint8 targetLimitMode;
    /* 2 */ uint32 totalExitedKeys; // @dev only increased except for the unsafe updates
    /* 2 */ uint32 enqueuedCount; // Tracks how many places are occupied by the node operator's keys in the queue.
    /* 2 */ address managerAddress;
    /* 3 */ address proposedManagerAddress;
    /* 4 */ address rewardAddress;
    /* 5 */ address proposedRewardAddress;
    /* 5 */ bool extendedManagerPermissions;
}

struct NodeOperatorManagementProperties {
    address managerAddress;
    address rewardAddress;
    bool extendedManagerPermissions;
}

/// @title Lido's Community Staking Module interface
interface ICSModule is
    IStakingModule,
    IQueueLib,
    INOAddresses,
    IAssetRecovererLib
{
    error NodeOperatorDoesNotExist();
    error ZeroRewardAddress();

    /// @notice Gets node operator non-withdrawn keys
    /// @param nodeOperatorId ID of the node operator
    /// @return Non-withdrawn keys count
    function getNodeOperatorNonWithdrawnKeys(
        uint256 nodeOperatorId
    ) external view returns (uint256);

    /// @notice Returns the node operator by id
    /// @param nodeOperatorId Node Operator id
    function getNodeOperator(
        uint256 nodeOperatorId
    ) external view returns (NodeOperator memory);

    /// @notice Gets node operator signing keys
    /// @param nodeOperatorId ID of the node operator
    /// @param startIndex Index of the first key
    /// @param keysCount Count of keys to get
    /// @return Signing keys
    function getSigningKeys(
        uint256 nodeOperatorId,
        uint256 startIndex,
        uint256 keysCount
    ) external view returns (bytes memory);

    /// @notice Gets node operator signing keys with signatures
    /// @param nodeOperatorId ID of the node operator
    /// @param startIndex Index of the first key
    /// @param keysCount Count of keys to get
    /// @return keys Signing keys
    /// @return signatures Signatures of (deposit_message, domain) tuples
    function getSigningKeysWithSignatures(
        uint256 nodeOperatorId,
        uint256 startIndex,
        uint256 keysCount
    ) external view returns (bytes memory keys, bytes memory signatures);

    /// @notice Report node operator's key as slashed and apply initial slashing penalty.
    /// @param nodeOperatorId Operator ID in the module.
    /// @param keyIndex Index of the slashed key in the node operator's keys.
    function submitInitialSlashing(
        uint256 nodeOperatorId,
        uint256 keyIndex
    ) external;

    /// @notice Report node operator's key as withdrawn and settle withdrawn amount.
    /// @param nodeOperatorId Operator ID in the module.
    /// @param keyIndex Index of the withdrawn key in the node operator's keys.
    /// @param amount Amount of withdrawn ETH in wei.
    /// @param isSlashed Validator is slashed or not
    function submitWithdrawal(
        uint256 nodeOperatorId,
        uint256 keyIndex,
        uint256 amount,
        bool isSlashed
    ) external;

    function depositWstETH(
        uint256 nodeOperatorId,
        uint256 wstETHAmount,
        ICSAccounting.PermitInput calldata permit
    ) external;

    function depositStETH(
        uint256 nodeOperatorId,
        uint256 stETHAmount,
        ICSAccounting.PermitInput calldata permit
    ) external;

    function depositETH(uint256 nodeOperatorId) external payable;
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

import { BeaconBlockHeader } from "../lib/Types.sol";
import { GIndex } from "../lib/GIndex.sol";

interface ICSVerifier {
    struct ProvableBeaconBlockHeader {
        BeaconBlockHeader header; // Header of a block which root is a root at rootsTimestamp.
        uint64 rootsTimestamp; // To be passed to the EIP-4788 block roots contract.
    }

    struct SlashingWitness {
        uint64 validatorIndex;
        bytes32 withdrawalCredentials;
        uint64 effectiveBalance;
        uint64 activationEligibilityEpoch;
        uint64 activationEpoch;
        uint64 exitEpoch;
        uint64 withdrawableEpoch;
        bytes32[] validatorProof;
    }

    struct WithdrawalWitness {
        // ── Withdrawal fields ─────────────────────────────────────────────────
        uint8 withdrawalOffset; // In the withdrawals list.
        uint64 withdrawalIndex; // Network-wise.
        uint64 validatorIndex;
        uint64 amount;
        // ── Validator fields ──────────────────────────────────────────────────
        bytes32 withdrawalCredentials;
        uint64 effectiveBalance;
        bool slashed;
        uint64 activationEligibilityEpoch;
        uint64 activationEpoch;
        uint64 exitEpoch;
        uint64 withdrawableEpoch;
        // ── Proofs ────────────────────────────────────────────────────────────
        // We accept the `withdrawalProof` against a state root, because it saves a few hops.
        bytes32[] withdrawalProof;
        bytes32[] validatorProof;
    }

    // A witness for a block header which root is accessible via `historical_summaries` field.
    struct HistoricalHeaderWitness {
        BeaconBlockHeader header;
        GIndex rootGIndex;
        bytes32[] proof;
    }

    /// @notice `witness` is a slashing witness against the `beaconBlock`'s state root.
    function processSlashingProof(
        ProvableBeaconBlockHeader calldata beaconBlock,
        SlashingWitness calldata witness,
        uint256 nodeOperatorId,
        uint256 keyIndex
    ) external;

    /// @notice `witness` is a withdrawal witness against the `beaconBlock`'s state root.
    function processWithdrawalProof(
        ProvableBeaconBlockHeader calldata beaconBlock,
        WithdrawalWitness calldata witness,
        uint256 nodeOperatorId,
        uint256 keyIndex
    ) external;

    /// @notice `oldHeader` is a beacon block header witness against the `beaconBlock`'s state root.
    /// @notice `witness` is a withdrawal witness against the `oldHeader`'s state root.
    function processHistoricalWithdrawalProof(
        ProvableBeaconBlockHeader calldata beaconBlock,
        HistoricalHeaderWitness calldata oldBlock,
        WithdrawalWitness calldata witness,
        uint256 nodeOperatorId,
        uint256 keyIndex
    ) external;
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

import { IStETH } from "./IStETH.sol";

/**
 * @title Interface defining Lido contract
 */
interface ILido is IStETH {
    function STAKING_CONTROL_ROLE() external view returns (bytes32);

    function submit(address _referal) external payable returns (uint256);

    function deposit(
        uint256 _maxDepositsCount,
        uint256 _stakingModuleId,
        bytes calldata _depositCalldata
    ) external;

    function removeStakingLimit() external;

    function kernel() external returns (address);

    function sharesOf(address _account) external view returns (uint256);
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

/**
 * @title Interface defining ERC20-compatible StETH token
 */
interface IStETH {
    /**
     * @notice Get stETH amount by the provided shares amount
     * @param _sharesAmount shares amount
     * @dev dual to `getSharesByPooledEth`.
     */
    function getPooledEthByShares(
        uint256 _sharesAmount
    ) external view returns (uint256);

    /**
     * @notice Get shares amount by the provided stETH amount
     * @param _pooledEthAmount stETH amount
     * @dev dual to `getPooledEthByShares`.
     */
    function getSharesByPooledEth(
        uint256 _pooledEthAmount
    ) external view returns (uint256);

    /**
     * @notice Get shares amount of the provided account
     * @param _account provided account address.
     */
    function sharesOf(address _account) external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    /**
     * @notice Transfer `_sharesAmount` stETH shares from `_sender` to `_receiver` using allowance.
     */
    function transferSharesFrom(
        address _sender,
        address _recipient,
        uint256 _sharesAmount
    ) external returns (uint256);

    /**
     * @notice Moves `_sharesAmount` token shares from the caller's account to the `_recipient` account.
     */
    function transferShares(
        address _recipient,
        uint256 _sharesAmount
    ) external returns (uint256);

    /**
     * @notice Moves `_pooledEthAmount` stETH from the caller's account to the `_recipient` account.
     */
    function transfer(
        address _recipient,
        uint256 _amount
    ) external returns (bool);

    /**
     * @notice Moves `_pooledEthAmount` stETH from the `_sender` account to the `_recipient` account.
     */
    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external returns (bool);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256);
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

/// @title Lido's Staking Module interface
interface IStakingModule {
    /// @notice Returns the type of the staking module
    function getType() external view returns (bytes32);

    /// @notice Returns all-validators summary in the staking module
    /// @return totalExitedValidators total number of validators in the EXITED state
    ///     on the Consensus Layer. This value can't decrease in normal conditions
    /// @return totalDepositedValidators total number of validators deposited via the
    ///     official Deposit Contract. This value is a cumulative counter: even when the validator
    ///     goes into EXITED state this counter is not decreasing
    /// @return depositableValidatorsCount number of validators in the set available for deposit
    function getStakingModuleSummary()
        external
        view
        returns (
            uint256 totalExitedValidators,
            uint256 totalDepositedValidators,
            uint256 depositableValidatorsCount
        );

    /// @notice Returns all-validators summary belonging to the node operator with the given id
    /// @param _nodeOperatorId id of the operator to return report for
    /// @return targetLimitMode shows whether the current target limit applied to the node operator (1 = soft mode, 2 = forced mode)
    /// @return targetValidatorsCount relative target active validators limit for operator
    /// @return stuckValidatorsCount number of validators with an expired request to exit time
    /// @return refundedValidatorsCount number of validators that can't be withdrawn, but deposit
    ///     costs were compensated to the Lido by the node operator
    /// @return stuckPenaltyEndTimestamp time when the penalty for stuck validators stops applying
    ///     to node operator rewards
    /// @return totalExitedValidators total number of validators in the EXITED state
    ///     on the Consensus Layer. This value can't decrease in normal conditions
    /// @return totalDepositedValidators total number of validators deposited via the official
    ///     Deposit Contract. This value is a cumulative counter: even when the validator goes into
    ///     EXITED state this counter is not decreasing
    /// @return depositableValidatorsCount number of validators in the set available for deposit
    function getNodeOperatorSummary(
        uint256 _nodeOperatorId
    )
        external
        view
        returns (
            uint256 targetLimitMode,
            uint256 targetValidatorsCount,
            uint256 stuckValidatorsCount,
            uint256 refundedValidatorsCount,
            uint256 stuckPenaltyEndTimestamp,
            uint256 totalExitedValidators,
            uint256 totalDepositedValidators,
            uint256 depositableValidatorsCount
        );

    /// @notice Returns a counter that MUST change its value whenever the deposit data set changes.
    ///     Below is the typical list of actions that requires an update of the nonce:
    ///     1. a node operator's deposit data is added
    ///     2. a node operator's deposit data is removed
    ///     3. a node operator's ready-to-deposit data size is changed
    ///     4. a node operator was activated/deactivated
    ///     5. a node operator's deposit data is used for the deposit
    ///     Note: Depending on the StakingModule implementation above list might be extended
    /// @dev In some scenarios, it's allowed to update nonce without actual change of the deposit
    ///      data subset, but it MUST NOT lead to the DOS of the staking module via continuous
    ///      update of the nonce by the malicious actor
    function getNonce() external view returns (uint256);

    /// @notice Returns total number of node operators
    function getNodeOperatorsCount() external view returns (uint256);

    /// @notice Returns number of active node operators
    function getActiveNodeOperatorsCount() external view returns (uint256);

    /// @notice Returns if the node operator with given id is active
    /// @param _nodeOperatorId Id of the node operator
    function getNodeOperatorIsActive(
        uint256 _nodeOperatorId
    ) external view returns (bool);

    /// @notice Returns up to `_limit` node operator ids starting from the `_offset`. The order of
    ///     the returned ids is not defined and might change between calls.
    /// @dev This view must not revert in case of invalid data passed. When `_offset` exceeds the
    ///     total node operators count or when `_limit` is equal to 0 MUST be returned empty array.
    function getNodeOperatorIds(
        uint256 _offset,
        uint256 _limit
    ) external view returns (uint256[] memory nodeOperatorIds);

    /// @notice Called by StakingRouter to signal that stETH rewards were minted for this module.
    /// @param _totalShares Amount of stETH shares that were minted to reward all node operators.
    /// @dev IMPORTANT: this method SHOULD revert with empty error data ONLY because of "out of gas".
    ///      Details about error data: https://docs.soliditylang.org/en/v0.8.9/control-structures.html#error-handling-assert-require-revert-and-exceptions
    function onRewardsMinted(uint256 _totalShares) external;

    /// @notice Called by StakingRouter to decrease the number of vetted keys for node operator with given id
    /// @param _nodeOperatorIds bytes packed array of the node operators id
    /// @param _vettedSigningKeysCounts bytes packed array of the new number of vetted keys for the node operators
    function decreaseVettedSigningKeysCount(
        bytes calldata _nodeOperatorIds,
        bytes calldata _vettedSigningKeysCounts
    ) external;

    /// @notice Updates the number of the validators of the given node operator that were requested
    ///         to exit but failed to do so in the max allowed time
    /// @param _nodeOperatorIds bytes packed array of the node operators id
    /// @param _stuckValidatorsCounts bytes packed array of the new number of STUCK validators for the node operators
    function updateStuckValidatorsCount(
        bytes calldata _nodeOperatorIds,
        bytes calldata _stuckValidatorsCounts
    ) external;

    /// @notice Updates the number of the validators in the EXITED state for node operator with given id
    /// @param _nodeOperatorIds bytes packed array of the node operators id
    /// @param _exitedValidatorsCounts bytes packed array of the new number of EXITED validators for the node operators
    function updateExitedValidatorsCount(
        bytes calldata _nodeOperatorIds,
        bytes calldata _exitedValidatorsCounts
    ) external;

    /// @notice Updates the number of the refunded validators for node operator with the given id
    /// @param _nodeOperatorId Id of the node operator
    /// @param _refundedValidatorsCount New number of refunded validators of the node operator
    function updateRefundedValidatorsCount(
        uint256 _nodeOperatorId,
        uint256 _refundedValidatorsCount
    ) external;

    /// @notice Updates the limit of the validators that can be used for deposit
    /// @param _nodeOperatorId Id of the node operator
    /// @param _targetLimitMode target limit mode
    /// @param _targetLimit Target limit of the node operator
    function updateTargetValidatorsLimits(
        uint256 _nodeOperatorId,
        uint256 _targetLimitMode,
        uint256 _targetLimit
    ) external;

    /// @notice Unsafely updates the number of validators in the EXITED/STUCK states for node operator with given id
    ///      'unsafely' means that this method can both increase and decrease exited and stuck counters
    /// @param _nodeOperatorId Id of the node operator
    /// @param _exitedValidatorsCount New number of EXITED validators for the node operator
    /// @param _stuckValidatorsCount New number of STUCK validator for the node operator
    function unsafeUpdateValidatorsCount(
        uint256 _nodeOperatorId,
        uint256 _exitedValidatorsCount,
        uint256 _stuckValidatorsCount
    ) external;

    /// @notice Obtains deposit data to be used by StakingRouter to deposit to the Ethereum Deposit
    ///     contract
    /// @dev The method MUST revert when the staking module has not enough deposit data items
    /// @param _depositsCount Number of deposits to be done
    /// @param _depositCalldata Staking module defined data encoded as bytes.
    ///        IMPORTANT: _depositCalldata MUST NOT modify the deposit data set of the staking module
    /// @return publicKeys Batch of the concatenated public validators keys
    /// @return signatures Batch of the concatenated deposit signatures for returned public keys
    function obtainDepositData(
        uint256 _depositsCount,
        bytes calldata _depositCalldata
    ) external returns (bytes memory publicKeys, bytes memory signatures);

    /// @notice Called by StakingRouter after it finishes updating exited and stuck validators
    /// counts for this module's node operators.
    ///
    /// Guaranteed to be called after an oracle report is applied, regardless of whether any node
    /// operator in this module has actually received any updated counts as a result of the report
    /// but given that the total number of exited validators returned from getStakingModuleSummary
    /// is the same as StakingRouter expects based on the total count received from the oracle.
    ///
    /// @dev IMPORTANT: this method SHOULD revert with empty error data ONLY because of "out of gas".
    ///      Details about error data: https://docs.soliditylang.org/en/v0.8.9/control-structures.html#error-handling-assert-require-revert-and-exceptions
    function onExitedAndStuckValidatorsCountsUpdated() external;

    /// @notice Called by StakingRouter when withdrawal credentials are changed.
    /// @dev This method MUST discard all StakingModule's unused deposit data cause they become
    ///      invalid after the withdrawal credentials are changed
    ///
    /// @dev IMPORTANT: this method SHOULD revert with empty error data ONLY because of "out of gas".
    ///      Details about error data: https://docs.soliditylang.org/en/v0.8.9/control-structures.html#error-handling-assert-require-revert-and-exceptions
    function onWithdrawalCredentialsChanged() external;

    /// @dev Event to be emitted on StakingModule's nonce change
    event NonceChanged(uint256 nonce);

    /// @dev Event to be emitted when a signing key is added to the StakingModule
    event SigningKeyAdded(uint256 indexed nodeOperatorId, bytes pubkey);

    /// @dev Event to be emitted when a signing key is removed from the StakingModule
    event SigningKeyRemoved(uint256 indexed nodeOperatorId, bytes pubkey);
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ILido } from "../interfaces/ILido.sol";

interface IAssetRecovererLib {
    event EtherRecovered(address indexed recipient, uint256 amount);
    event ERC20Recovered(
        address indexed token,
        address indexed recipient,
        uint256 amount
    );
    event StETHSharesRecovered(address indexed recipient, uint256 shares);
    event ERC721Recovered(
        address indexed token,
        uint256 tokenId,
        address indexed recipient
    );
    event ERC1155Recovered(
        address indexed token,
        uint256 tokenId,
        address indexed recipient,
        uint256 amount
    );

    error FailedToSendEther();
    error NotAllowedToRecover();
}

/*
 * @title AssetRecovererLib
 * @dev Library providing mechanisms for recovering various asset types (ETH, ERC20, ERC721, ERC1155).
 * This library is designed to be used by a contract that implements the AssetRecoverer interface.
 */
library AssetRecovererLib {
    using SafeERC20 for IERC20;

    /**
     * @dev Allows the sender to recover Ether held by the contract.
     * Emits an EtherRecovered event upon success.
     */
    function recoverEther() external {
        uint256 amount = address(this).balance;
        (bool success, ) = msg.sender.call{ value: amount }("");
        if (!success) revert IAssetRecovererLib.FailedToSendEther();
        emit IAssetRecovererLib.EtherRecovered(msg.sender, amount);
    }

    /**
     * @dev Allows the sender to recover ERC20 tokens held by the contract.
     * @param token The address of the ERC20 token to recover.
     * @param amount The amount of the ERC20 token to recover.
     * Emits an ERC20Recovered event upon success.
     */
    function recoverERC20(address token, uint256 amount) external {
        IERC20(token).safeTransfer(msg.sender, amount);
        emit IAssetRecovererLib.ERC20Recovered(token, msg.sender, amount);
    }

    /**
     * @dev Allows the sender to recover stETH shares held by the contract.
     * The use of a separate method for stETH is to avoid rounding problems when converting shares to stETH.
     * @param lido The address of the Lido contract.
     * @param shares The amount of stETH shares to recover.
     * Emits an StETHRecovered event upon success.
     */
    function recoverStETHShares(address lido, uint256 shares) external {
        ILido(lido).transferShares(msg.sender, shares);
        emit IAssetRecovererLib.StETHSharesRecovered(msg.sender, shares);
    }

    /**
     * @dev Allows the sender to recover ERC721 tokens held by the contract.
     * @param token The address of the ERC721 token to recover.
     * @param tokenId The token ID of the ERC721 token to recover.
     * Emits an ERC721Recovered event upon success.
     */
    function recoverERC721(address token, uint256 tokenId) external {
        IERC721(token).safeTransferFrom(address(this), msg.sender, tokenId);
        emit IAssetRecovererLib.ERC721Recovered(token, tokenId, msg.sender);
    }

    /**
     * @dev Allows the sender to recover ERC1155 tokens held by the contract.
     * @param token The address of the ERC1155 token to recover.
     * @param tokenId The token ID of the ERC1155 token to recover.
     * Emits an ERC1155Recovered event upon success.
     */
    function recoverERC1155(address token, uint256 tokenId) external {
        uint256 amount = IERC1155(token).balanceOf(address(this), tokenId);
        IERC1155(token).safeTransferFrom({
            from: address(this),
            to: msg.sender,
            id: tokenId,
            value: amount,
            data: ""
        });
        emit IAssetRecovererLib.ERC1155Recovered(
            token,
            tokenId,
            msg.sender,
            amount
        );
    }
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

type GIndex is bytes32;

using {
    isRoot,
    isParentOf,
    index,
    width,
    shr,
    shl,
    concat,
    unwrap,
    pow
} for GIndex global;

error IndexOutOfRange();

/// @param gI Is a generalized index of a node in a tree.
/// @param p Is a power of a tree level the node belongs to.
/// @return GIndex
function pack(uint256 gI, uint8 p) pure returns (GIndex) {
    if (gI > type(uint248).max) {
        revert IndexOutOfRange();
    }

    // NOTE: We can consider adding additional metadata like a fork version.
    return GIndex.wrap(bytes32((gI << 8) | p));
}

function unwrap(GIndex self) pure returns (bytes32) {
    return GIndex.unwrap(self);
}

function isRoot(GIndex self) pure returns (bool) {
    return index(self) == 1;
}

function index(GIndex self) pure returns (uint256) {
    return uint256(unwrap(self)) >> 8;
}

function width(GIndex self) pure returns (uint256) {
    return 1 << pow(self);
}

function pow(GIndex self) pure returns (uint8) {
    return uint8(uint256(unwrap(self)));
}

/// @return Generalized index of the nth neighbor of the node to the right.
function shr(GIndex self, uint256 n) pure returns (GIndex) {
    uint256 i = index(self);
    uint256 w = width(self);

    if ((i % w) + n >= w) {
        revert IndexOutOfRange();
    }

    return pack(i + n, pow(self));
}

/// @return Generalized index of the nth neighbor of the node to the left.
function shl(GIndex self, uint256 n) pure returns (GIndex) {
    uint256 i = index(self);
    uint256 w = width(self);

    if (i % w < n) {
        revert IndexOutOfRange();
    }

    return pack(i - n, pow(self));
}

// See https://github.com/protolambda/remerkleable/blob/91ed092d08ef0ba5ab076f0a34b0b371623db728/remerkleable/tree.py#L46
function concat(GIndex lhs, GIndex rhs) pure returns (GIndex) {
    uint256 lhsMSbIndex = fls(index(lhs));
    uint256 rhsMSbIndex = fls(index(rhs));

    if (lhsMSbIndex + 1 + rhsMSbIndex > 248) {
        revert IndexOutOfRange();
    }

    return
        pack(
            (index(lhs) << rhsMSbIndex) | (index(rhs) ^ (1 << rhsMSbIndex)),
            pow(rhs)
        );
}

function isParentOf(GIndex self, GIndex child) pure returns (bool) {
    uint256 parentIndex = index(self);
    uint256 childIndex = index(child);

    if (parentIndex >= childIndex) {
        return false;
    }

    while (childIndex > 0) {
        if (childIndex == parentIndex) {
            return true;
        }

        childIndex = childIndex >> 1;
    }

    return false;
}

/// @dev From Solady LibBit, see https://github.com/Vectorized/solady/blob/main/src/utils/LibBit.sol.
/// @dev Find last set.
/// Returns the index of the most significant bit of `x`,
/// counting from the least significant bit position.
/// If `x` is zero, returns 256.
function fls(uint256 x) pure returns (uint256 r) {
    /// @solidity memory-safe-assembly
    assembly {
        // prettier-ignore
        r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, x)))
        r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
        r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
        r := or(r, shl(4, lt(0xffff, shr(r, x))))
        r := or(r, shl(3, lt(0xff, shr(r, x))))
        // prettier-ignore
        r := or(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0x0706060506020504060203020504030106050205030304010505030400000000))
    }
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

import { NodeOperator, ICSModule } from "../interfaces/ICSModule.sol";

/// Library for changing and reset node operator's manager and reward addresses
/// @dev the only use of this to be a library is to save CSModule contract size via delegatecalls
interface INOAddresses {
    event NodeOperatorManagerAddressChangeProposed(
        uint256 indexed nodeOperatorId,
        address indexed oldProposedAddress,
        address indexed newProposedAddress
    );
    event NodeOperatorRewardAddressChangeProposed(
        uint256 indexed nodeOperatorId,
        address indexed oldProposedAddress,
        address indexed newProposedAddress
    );
    // args order as in https://github.com/OpenZeppelin/openzeppelin-contracts/blob/11dc5e3809ebe07d5405fe524385cbe4f890a08b/contracts/access/Ownable.sol#L33
    event NodeOperatorManagerAddressChanged(
        uint256 indexed nodeOperatorId,
        address indexed oldAddress,
        address indexed newAddress
    );
    event NodeOperatorRewardAddressChanged(
        uint256 indexed nodeOperatorId,
        address indexed oldAddress,
        address indexed newAddress
    );

    error AlreadyProposed();
    error SameAddress();
    error SenderIsNotManagerAddress();
    error SenderIsNotRewardAddress();
    error SenderIsNotProposedAddress();
    error MethodCallIsNotAllowed();
}

library NOAddresses {
    /// @notice Propose a new manager address for the Node Operator
    /// @param nodeOperatorId ID of the Node Operator
    /// @param proposedAddress Proposed manager address
    function proposeNodeOperatorManagerAddressChange(
        mapping(uint256 => NodeOperator) storage nodeOperators,
        uint256 nodeOperatorId,
        address proposedAddress
    ) external {
        NodeOperator storage no = nodeOperators[nodeOperatorId];
        if (no.managerAddress == address(0))
            revert ICSModule.NodeOperatorDoesNotExist();
        if (no.managerAddress != msg.sender)
            revert INOAddresses.SenderIsNotManagerAddress();
        if (no.managerAddress == proposedAddress)
            revert INOAddresses.SameAddress();
        if (no.proposedManagerAddress == proposedAddress)
            revert INOAddresses.AlreadyProposed();

        address oldProposedAddress = no.proposedManagerAddress;
        no.proposedManagerAddress = proposedAddress;

        emit INOAddresses.NodeOperatorManagerAddressChangeProposed(
            nodeOperatorId,
            oldProposedAddress,
            proposedAddress
        );
    }

    /// @notice Confirm a new manager address for the Node Operator.
    ///         Should be called from the currently proposed address
    /// @param nodeOperatorId ID of the Node Operator
    function confirmNodeOperatorManagerAddressChange(
        mapping(uint256 => NodeOperator) storage nodeOperators,
        uint256 nodeOperatorId
    ) external {
        NodeOperator storage no = nodeOperators[nodeOperatorId];
        if (no.managerAddress == address(0))
            revert ICSModule.NodeOperatorDoesNotExist();
        if (no.proposedManagerAddress != msg.sender)
            revert INOAddresses.SenderIsNotProposedAddress();

        address oldAddress = no.managerAddress;
        no.managerAddress = msg.sender;
        delete no.proposedManagerAddress;

        emit INOAddresses.NodeOperatorManagerAddressChanged(
            nodeOperatorId,
            oldAddress,
            msg.sender
        );
    }

    /// @notice Propose a new reward address for the Node Operator
    /// @param nodeOperatorId ID of the Node Operator
    /// @param proposedAddress Proposed reward address
    function proposeNodeOperatorRewardAddressChange(
        mapping(uint256 => NodeOperator) storage nodeOperators,
        uint256 nodeOperatorId,
        address proposedAddress
    ) external {
        NodeOperator storage no = nodeOperators[nodeOperatorId];
        if (no.rewardAddress == address(0))
            revert ICSModule.NodeOperatorDoesNotExist();
        if (no.rewardAddress != msg.sender)
            revert INOAddresses.SenderIsNotRewardAddress();
        if (no.rewardAddress == proposedAddress)
            revert INOAddresses.SameAddress();
        if (no.proposedRewardAddress == proposedAddress)
            revert INOAddresses.AlreadyProposed();

        address oldProposedAddress = no.proposedRewardAddress;
        no.proposedRewardAddress = proposedAddress;

        emit INOAddresses.NodeOperatorRewardAddressChangeProposed(
            nodeOperatorId,
            oldProposedAddress,
            proposedAddress
        );
    }

    /// @notice Confirm a new reward address for the Node Operator.
    ///         Should be called from the currently proposed address
    /// @param nodeOperatorId ID of the Node Operator
    function confirmNodeOperatorRewardAddressChange(
        mapping(uint256 => NodeOperator) storage nodeOperators,
        uint256 nodeOperatorId
    ) external {
        NodeOperator storage no = nodeOperators[nodeOperatorId];
        if (no.rewardAddress == address(0))
            revert ICSModule.NodeOperatorDoesNotExist();
        if (no.proposedRewardAddress != msg.sender)
            revert INOAddresses.SenderIsNotProposedAddress();

        address oldAddress = no.rewardAddress;
        no.rewardAddress = msg.sender;
        delete no.proposedRewardAddress;

        emit INOAddresses.NodeOperatorRewardAddressChanged(
            nodeOperatorId,
            oldAddress,
            msg.sender
        );
    }

    /// @notice Reset the manager address to the reward address.
    ///         Should be called from the reward address
    /// @param nodeOperatorId ID of the Node Operator
    function resetNodeOperatorManagerAddress(
        mapping(uint256 => NodeOperator) storage nodeOperators,
        uint256 nodeOperatorId
    ) external {
        NodeOperator storage no = nodeOperators[nodeOperatorId];
        if (no.rewardAddress == address(0))
            revert ICSModule.NodeOperatorDoesNotExist();
        if (no.extendedManagerPermissions)
            revert INOAddresses.MethodCallIsNotAllowed();
        if (no.rewardAddress != msg.sender)
            revert INOAddresses.SenderIsNotRewardAddress();
        if (no.managerAddress == no.rewardAddress)
            revert INOAddresses.SameAddress();
        address previousManagerAddress = no.managerAddress;

        no.managerAddress = no.rewardAddress;
        // @dev Gas golfing
        if (no.proposedManagerAddress != address(0))
            delete no.proposedManagerAddress;

        emit INOAddresses.NodeOperatorManagerAddressChanged(
            nodeOperatorId,
            previousManagerAddress,
            no.rewardAddress
        );
    }

    /// @notice Change rewardAddress if extendedManagerPermissions is enabled for the Node Operator.
    ///         Should be called from the current manager address
    /// @param nodeOperatorId ID of the Node Operator
    /// @param newAddress New reward address
    function changeNodeOperatorRewardAddress(
        mapping(uint256 => NodeOperator) storage nodeOperators,
        uint256 nodeOperatorId,
        address newAddress
    ) external {
        NodeOperator storage no = nodeOperators[nodeOperatorId];
        if (no.managerAddress == address(0))
            revert ICSModule.NodeOperatorDoesNotExist();
        if (!no.extendedManagerPermissions)
            revert INOAddresses.MethodCallIsNotAllowed();
        if (no.managerAddress != msg.sender)
            revert INOAddresses.SenderIsNotManagerAddress();

        address oldAddress = no.rewardAddress;
        no.rewardAddress = newAddress;
        // @dev Gas golfing
        if (no.proposedRewardAddress != address(0))
            delete no.proposedRewardAddress;

        emit INOAddresses.NodeOperatorRewardAddressChanged(
            nodeOperatorId,
            oldAddress,
            newAddress
        );
    }
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

import { NodeOperator } from "../interfaces/ICSModule.sol";
import { TransientUintUintMap, TransientUintUintMapLib } from "./TransientUintUintMapLib.sol";

// Batch is an uint256 as it's the internal data type used by solidity.
// Batch is a packed value, consisting of the following fields:
//    - uint64  nodeOperatorId
//    - uint64  keysCount -- count of keys enqueued by the batch
//    - uint128 next -- index of the next batch in the queue
type Batch is uint256;

/// @notice Batch of the operator with index 0, with no keys in it and the next Batch' index 0 is meaningless.
function isNil(Batch self) pure returns (bool) {
    return Batch.unwrap(self) == 0;
}

/// @dev Syntactic sugar for the type.
function unwrap(Batch self) pure returns (uint256) {
    return Batch.unwrap(self);
}

function noId(Batch self) pure returns (uint64 n) {
    assembly {
        n := shr(192, self)
    }
}

function keys(Batch self) pure returns (uint64 n) {
    assembly {
        n := shl(64, self)
        n := shr(192, n)
    }
}

function next(Batch self) pure returns (uint128 n) {
    assembly {
        n := shl(128, self)
        n := shr(128, n)
    }
}

/// @dev keys count cast is unsafe
function setKeys(Batch self, uint256 keysCount) pure returns (Batch) {
    assembly {
        self := or(
            and(
                self,
                0xffffffffffffffff0000000000000000ffffffffffffffffffffffffffffffff
            ),
            shl(128, and(keysCount, 0xffffffffffffffff))
        ) // self.keys = keysCount
    }

    return self;
}

/// @dev can be unsafe if the From batch is previous to the self
function setNext(Batch self, Batch from) pure returns (Batch) {
    assembly {
        self := or(
            and(
                self,
                0xffffffffffffffffffffffffffffffff00000000000000000000000000000000
            ),
            and(
                from,
                0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff
            )
        ) // self.next = from.next
    }
    return self;
}

/// @dev Instantiate a new Batch to be added to the queue. The `next` field will be determined upon the enqueue.
/// @dev Parameters are uint256 to make usage easier.
function createBatch(
    uint256 nodeOperatorId,
    uint256 keysCount
) pure returns (Batch item) {
    // NOTE: No need to safe cast due to internal logic.
    nodeOperatorId = uint64(nodeOperatorId);
    keysCount = uint64(keysCount);

    assembly {
        item := shl(128, keysCount) // `keysCount` in [64:127]
        item := or(item, shl(192, nodeOperatorId)) // `nodeOperatorId` in [0:63]
    }
}

using { noId, keys, setKeys, setNext, next, isNil, unwrap } for Batch global;
using QueueLib for QueueLib.Queue;

interface IQueueLib {
    event BatchEnqueued(uint256 indexed nodeOperatorId, uint256 count);

    error QueueIsEmpty();
    error QueueLookupNoLimit();
}

/// @author madlabman
library QueueLib {
    struct Queue {
        // Pointer to the item to be dequeued.
        uint128 head;
        // Tracks the total number of batches ever enqueued.
        uint128 tail;
        // Mapping saves a little in costs and allows easily fallback to a zeroed batch on out-of-bounds access.
        mapping(uint128 => Batch) queue;
    }

    //////
    /// External methods
    //////
    function normalize(
        Queue storage self,
        mapping(uint256 => NodeOperator) storage nodeOperators,
        uint256 nodeOperatorId
    ) external {
        NodeOperator storage no = nodeOperators[nodeOperatorId];
        uint32 depositable = no.depositableValidatorsCount;
        uint32 enqueued = no.enqueuedCount;

        if (enqueued < depositable) {
            uint32 count;
            unchecked {
                count = depositable - enqueued;
            }
            no.enqueuedCount = depositable;
            self.enqueue(nodeOperatorId, count);
        }
    }

    function clean(
        Queue storage self,
        mapping(uint256 => NodeOperator) storage nodeOperators,
        uint256 maxItems
    ) external returns (uint256 removed, uint256 lastRemovedAtDepth) {
        if (maxItems == 0) revert IQueueLib.QueueLookupNoLimit();

        Batch prev;
        uint128 indexOfPrev;

        uint128 head = self.head;
        uint128 curr = head;

        TransientUintUintMap queueLookup = TransientUintUintMapLib.create();

        for (uint256 i; i < maxItems; ++i) {
            Batch item = self.queue[curr];
            if (item.isNil()) {
                break;
            }

            NodeOperator storage no = nodeOperators[item.noId()];
            if (queueLookup.get(item.noId()) >= no.depositableValidatorsCount) {
                // NOTE: Since we reached that point there's no way for a Node Operator to have a depositable batch
                // later in the queue, and hence we don't update _queueLookup for the Node Operator.
                if (curr == head) {
                    self.dequeue();
                    head = self.head;
                } else {
                    // There's no `prev` item while we call `dequeue`, and removing an item will keep the `prev` intact
                    // other than changing its `next` field.
                    prev = prev.setNext(item);
                    self.queue[indexOfPrev] = prev;
                }

                // We assume that the invariant `enqueuedCount` >= `keys` is kept.
                // NOTE: No need to safe cast due to internal logic.
                no.enqueuedCount -= uint32(item.keys());

                unchecked {
                    lastRemovedAtDepth = i + 1;
                    ++removed;
                }
            } else {
                queueLookup.add(item.noId(), item.keys());
                indexOfPrev = curr;
                prev = item;
            }

            curr = item.next();
        }
    }

    /////
    /// Internal methods
    /////
    function enqueue(
        Queue storage self,
        uint256 nodeOperatorId,
        uint256 keysCount
    ) internal returns (Batch item) {
        uint128 tail = self.tail;
        item = createBatch(nodeOperatorId, keysCount);

        assembly {
            item := or(
                and(
                    item,
                    0xffffffffffffffffffffffffffffffff00000000000000000000000000000000
                ),
                add(tail, 1)
            ) // item.next = self.tail + 1;
        }

        self.queue[tail] = item;
        unchecked {
            ++self.tail;
        }
        emit IQueueLib.BatchEnqueued(nodeOperatorId, keysCount);
    }

    function dequeue(Queue storage self) internal returns (Batch item) {
        item = peek(self);

        if (item.isNil()) {
            revert IQueueLib.QueueIsEmpty();
        }

        self.head = item.next();
    }

    function peek(Queue storage self) internal view returns (Batch) {
        return self.queue[self.head];
    }

    function at(
        Queue storage self,
        uint128 index
    ) internal view returns (Batch) {
        return self.queue[index];
    }
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

import { BeaconBlockHeader, Withdrawal, Validator } from "./Types.sol";
import { GIndex } from "./GIndex.sol";

library SSZ {
    error BranchHasMissingItem();
    error BranchHasExtraItem();
    error InvalidProof();

    function hashTreeRoot(
        BeaconBlockHeader memory header
    ) internal view returns (bytes32 root) {
        bytes32[8] memory nodes = [
            toLittleEndian(header.slot.unwrap()),
            toLittleEndian(header.proposerIndex),
            header.parentRoot,
            header.stateRoot,
            header.bodyRoot,
            bytes32(0),
            bytes32(0),
            bytes32(0)
        ];

        /// @solidity memory-safe-assembly
        assembly {
            // Count of nodes to hash
            let count := 8

            // Loop over levels
            // prettier-ignore
            for { } 1 { } {
                // Loop over nodes at the given depth

                // Initialize `offset` to the offset of `proof` elements in memory.
                let target := nodes
                let source := nodes
                let end := add(source, shl(5, count))

                // prettier-ignore
                for { } 1 { } {
                    // Read next two hashes to hash
                    mcopy(0x00, source, 0x40)

                    // Call sha256 precompile
                    let result := staticcall(
                        gas(),
                        0x02,
                        0x00,
                        0x40,
                        0x00,
                        0x20
                    )

                    if iszero(result) {
                        // Precompiles returns no data on OutOfGas error.
                        revert(0, 0)
                    }

                    // Store the resulting hash at the target location
                    mstore(target, mload(0x00))

                    // Advance the pointers
                    target := add(target, 0x20)
                    source := add(source, 0x40)

                    if iszero(lt(source, end)) {
                        break
                    }
                }

                count := shr(1, count)
                if eq(count, 1) {
                    root := mload(0x00)
                    break
                }
            }
        }
    }

    function hashTreeRoot(
        Validator memory validator
    ) internal view returns (bytes32 root) {
        bytes32 pubkeyRoot;

        assembly {
            // Dynamic data types such as bytes are stored at the specified offset.
            let offset := mload(validator)
            // Copy the pubkey to the scratch space.
            mcopy(0x00, add(offset, 32), 48)
            // Clear the last 16 bytes.
            mcopy(48, 0x60, 16)
            // Call sha256 precompile.
            let result := staticcall(gas(), 0x02, 0x00, 0x40, 0x00, 0x20)

            if iszero(result) {
                // Precompiles returns no data on OutOfGas error.
                revert(0, 0)
            }

            pubkeyRoot := mload(0x00)
        }

        bytes32[8] memory nodes = [
            pubkeyRoot,
            validator.withdrawalCredentials,
            toLittleEndian(validator.effectiveBalance),
            toLittleEndian(validator.slashed),
            toLittleEndian(validator.activationEligibilityEpoch),
            toLittleEndian(validator.activationEpoch),
            toLittleEndian(validator.exitEpoch),
            toLittleEndian(validator.withdrawableEpoch)
        ];

        /// @solidity memory-safe-assembly
        assembly {
            // Count of nodes to hash
            let count := 8

            // Loop over levels
            // prettier-ignore
            for { } 1 { } {
                // Loop over nodes at the given depth

                // Initialize `offset` to the offset of `proof` elements in memory.
                let target := nodes
                let source := nodes
                let end := add(source, shl(5, count))

                // prettier-ignore
                for { } 1 { } {
                    // Read next two hashes to hash
                    mcopy(0x00, source, 0x40)

                    // Call sha256 precompile
                    let result := staticcall(
                        gas(),
                        0x02,
                        0x00,
                        0x40,
                        0x00,
                        0x20
                    )

                    if iszero(result) {
                        // Precompiles returns no data on OutOfGas error.
                        revert(0, 0)
                    }

                    // Store the resulting hash at the target location
                    mstore(target, mload(0x00))

                    // Advance the pointers
                    target := add(target, 0x20)
                    source := add(source, 0x40)

                    if iszero(lt(source, end)) {
                        break
                    }
                }

                count := shr(1, count)
                if eq(count, 1) {
                    root := mload(0x00)
                    break
                }
            }
        }
    }

    /// @notice Modified version of `verify` from Solady `MerkleProofLib` to support generalized indices and sha256 precompile.
    /// @dev Reverts if `leaf` doesn't exist in the Merkle tree with `root`, given `proof`.
    function verifyProof(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf,
        GIndex gI
    ) internal view {
        uint256 index = gI.index();

        /// @solidity memory-safe-assembly
        assembly {
            // Check if `proof` is empty.
            if iszero(proof.length) {
                // revert InvalidProof()
                mstore(0x00, 0x09bde339)
                revert(0x1c, 0x04)
            }
            // Left shift by 5 is equivalent to multiplying by 0x20.
            let end := add(proof.offset, shl(5, proof.length))
            // Initialize `offset` to the offset of `proof` in the calldata.
            let offset := proof.offset
            // Iterate over proof elements to compute root hash.
            // prettier-ignore
            for { } 1 { } {
                // Slot of `leaf` in scratch space.
                // If the condition is true: 0x20, otherwise: 0x00.
                let scratch := shl(5, and(index, 1))
                index := shr(1, index)
                if iszero(index) {
                    // revert BranchHasExtraItem()
                    mstore(0x00, 0x5849603f)
                    // 0x1c = 28 => offset in 32-byte word of a slot 0x00
                    revert(0x1c, 0x04)
                }
                // Store elements to hash contiguously in scratch space.
                // Scratch space is 64 bytes (0x00 - 0x3f) and both elements are 32 bytes.
                mstore(scratch, leaf)
                mstore(xor(scratch, 0x20), calldataload(offset))
                // Call sha256 precompile.
                let result := staticcall(
                    gas(),
                    0x02,
                    0x00,
                    0x40,
                    0x00,
                    0x20
                )

                if iszero(result) {
                    // Precompile returns no data on OutOfGas error.
                    revert(0, 0)
                }

                // Reuse `leaf` to store the hash to reduce stack operations.
                leaf := mload(0x00)
                offset := add(offset, 0x20)
                if iszero(lt(offset, end)) {
                    break
                }
            }

            if iszero(eq(index, 1)) {
                // revert BranchHasMissingItem()
                mstore(0x00, 0x1b6661c3)
                revert(0x1c, 0x04)
            }

            if iszero(eq(leaf, root)) {
                // revert InvalidProof()
                mstore(0x00, 0x09bde339)
                revert(0x1c, 0x04)
            }
        }
    }

    // Inspired by https://github.com/succinctlabs/telepathy-contracts/blob/5aa4bb7/src/libraries/SimpleSerialize.sol#L59
    function hashTreeRoot(
        Withdrawal memory withdrawal
    ) internal pure returns (bytes32) {
        return
            sha256(
                bytes.concat(
                    sha256(
                        bytes.concat(
                            toLittleEndian(withdrawal.index),
                            toLittleEndian(withdrawal.validatorIndex)
                        )
                    ),
                    sha256(
                        bytes.concat(
                            bytes20(withdrawal.withdrawalAddress),
                            bytes12(0),
                            toLittleEndian(withdrawal.amount)
                        )
                    )
                )
            );
    }

    // See https://github.com/succinctlabs/telepathy-contracts/blob/5aa4bb7/src/libraries/SimpleSerialize.sol#L17-L28
    function toLittleEndian(uint256 v) internal pure returns (bytes32) {
        v =
            ((v &
                0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00) >>
                8) |
            ((v &
                0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) <<
                8);
        v =
            ((v &
                0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000) >>
                16) |
            ((v &
                0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) <<
                16);
        v =
            ((v &
                0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000) >>
                32) |
            ((v &
                0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) <<
                32);
        v =
            ((v &
                0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000) >>
                64) |
            ((v &
                0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) <<
                64);
        v = (v >> 128) | (v << 128);
        return bytes32(v);
    }

    function toLittleEndian(bool v) internal pure returns (bytes32) {
        return bytes32(v ? 1 << 248 : 0);
    }
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

type TransientUintUintMap is uint256;

using TransientUintUintMapLib for TransientUintUintMap global;

library TransientUintUintMapLib {
    function create() internal returns (TransientUintUintMap self) {
        // keccak256(abi.encode(uint256(keccak256("TransientUintUintMap")) - 1)) & ~bytes32(uint256(0xff))
        uint256 anchor = 0x6e38e7eaa4307e6ee6c66720337876ca65012869fbef035f57219354c1728400;

        // `anchor` slot in the transient storage tracks the "address" of the last created object.
        // The next address is being computed as keccak256(`anchor` . `prev`).
        assembly ("memory-safe") {
            let prev := tload(anchor)
            mstore(0x00, anchor)
            mstore(0x20, prev)
            self := keccak256(0x00, 0x40)
            tstore(anchor, self)
        }
    }

    function add(
        TransientUintUintMap self,
        uint256 key,
        uint256 value
    ) internal {
        uint256 slot = _slot(self, key);
        assembly ("memory-safe") {
            let v := tload(slot)
            // NOTE: Here's no overflow check.
            v := add(v, value)
            tstore(slot, v)
        }
    }

    function get(
        TransientUintUintMap self,
        uint256 key
    ) internal view returns (uint256 v) {
        uint256 slot = _slot(self, key);
        assembly ("memory-safe") {
            v := tload(slot)
        }
    }

    function _slot(
        TransientUintUintMap self,
        uint256 key
    ) internal pure returns (uint256 slot) {
        // Compute an address in the transient storage in the same manner it works for storage mappings.
        // `slot` = keccak256(`self` . `key`)
        assembly ("memory-safe") {
            mstore(0x00, self)
            mstore(0x20, key)
            slot := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

// As defined in phase0/beacon-chain.md:159
type Slot is uint64;

function unwrap(Slot slot) pure returns (uint64) {
    return Slot.unwrap(slot);
}

function gt(Slot lhs, Slot rhs) pure returns (bool) {
    return lhs.unwrap() > rhs.unwrap();
}

function lt(Slot lhs, Slot rhs) pure returns (bool) {
    return lhs.unwrap() < rhs.unwrap();
}

using { unwrap, lt as <, gt as > } for Slot global;

// As defined in capella/beacon-chain.md:99
struct Withdrawal {
    uint64 index;
    uint64 validatorIndex;
    address withdrawalAddress;
    uint64 amount;
}

// As defined in phase0/beacon-chain.md:356
struct Validator {
    bytes pubkey;
    bytes32 withdrawalCredentials;
    uint64 effectiveBalance;
    bool slashed;
    uint64 activationEligibilityEpoch;
    uint64 activationEpoch;
    uint64 exitEpoch;
    uint64 withdrawableEpoch;
}

// As defined in phase0/beacon-chain.md:436
struct BeaconBlockHeader {
    Slot slot;
    uint64 proposerIndex;
    bytes32 parentRoot;
    bytes32 stateRoot;
    bytes32 bodyRoot;
}