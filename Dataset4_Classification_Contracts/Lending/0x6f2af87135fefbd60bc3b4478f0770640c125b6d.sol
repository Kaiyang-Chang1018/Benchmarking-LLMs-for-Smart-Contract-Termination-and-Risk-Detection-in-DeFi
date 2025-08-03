// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

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
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * - The `operator` cannot be the caller.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

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
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
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
            set._indexes[value] = set._values.length;
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
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
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
// SPDX-License-Identifier: PROPRIERTARY

// Author: Ilya A. Shlyakhovoy
// Email: is@unicsoft.com
pragma solidity 0.8.17;

/**
 * @dev Collection of structures
 */
library Structures {
    struct ActorData {
        uint256 adultTime;
        uint256 bornTime;
        string kidTokenUriHash;
        string adultTokenUriHash;
        uint16[10] props;
        uint8 childs;
        uint8 childsPossible;
        bool sex;
        bool born;
        bool immaculate;
        uint16 rank;
        address initialOwner;
    }

    struct Item {
        string itemKey;
        uint256 location;
        uint8 slots;
        string uri;
    }

    struct LootBox {
        uint256 price;
        uint16 total;
        uint16 available;
        bool paused;
        bool deleted;
        string uri;
        LootBoxItem[] items;
    }

    struct LootBoxItem {
        uint256 class;
        uint256 model;
        uint8 slots;
        uint16 promilles;
    }

    struct Estate {
        address lender;
        uint256 location;
        uint8 estateType;
        uint256 parent;
        uint256 coordinates;
    }

    struct Villa {
        uint256 location;
        uint256 fraction;
    }

    struct ManageAction {
        address target;
        address author;
        uint256 expiration;
        bytes4 signature;
        bytes data;
        bool executed;
    }

    struct InvestorData {
        address investor;
        uint256 promille;
    }

    struct Benefit {
        uint256 price;
        uint256 from;
        uint256 until;
        uint16 id;
        uint16 amount;
        uint8 level;
        uint8 issued;
    }

    struct BreedingParams {
        uint256 motherId;
        uint256 fatherId;
        uint256 breedingId;
        uint256 sessionId;
        uint256 breedingFee;
        uint256 deadline;
        address asset;
        bool isKidForMother;
    }
}
// SPDX-License-Identifier: PROPRIERTARY

// Author: Dmitry Kharlanchuk
// Email: kharlanchuk@scand.com

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../utils/GuardExtension.sol";
import "../persons/interfaces/IActors.sol";
import "./interfaces/IStaking.sol";

contract Staking is IStaking, GuardExtension {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    mapping(address => EnumerableSet.UintSet) _stakesByAddress;
    mapping(uint128 => Stake) _stakes;

    uint256 private _maxAPR; // two decimals 100% == 10000
    uint128[6] private _intervalsMonth;
    uint128[6] private _intervalCoefficient;
    uint128[5] private _boosterCoefficient;
    uint128 private _counter;

    // Decimal places are not taken
    // Total supply 250,000,000 UDS
    uint128 private _totalShares;
    uint128 private totalStakes;

    IERC20 private _udsToken;
    IActors private _zombies;

    string private constant ZERO_AMOUNT = "Staking: Required amount > 0";
    string private constant NOT_ZOMBIE_OWNER = "Staking: Zombie owner required";
    string private constant NOT_EXISTS = "Staking: Staking not exists";
    string private constant NOT_OVER = "Staking Staking is not over";
    string private constant ALREADY_REWARDED = "Staking: Already rewarded";
    string private constant INVALID_ZOMBIE_LEVEL =
        "Staking: Zombie level is invalid";
    string private constant INVALID_INTERVAL =
        "Staking: Staking interval is invalid";
    string private constant INVALID_STAKING_ID =
        "Staking: Staking id is invalid";
    string private constant INVALID_INPUT = "Staking: Input is invalid";

    constructor(
        address rights_,
        address udsToken_,
        address zombies_,
        uint16 maxAPR_,
        uint128[6] memory intervalsMonth_,
        uint128[6] memory intervalCoefficients_,
        uint128[5] memory boosterCoefficients_
    ) GuardExtension(rights_) {
        _udsToken = IERC20(udsToken_);
        _zombies = IActors(zombies_);
        _setCoefficients(intervalCoefficients_, boosterCoefficients_);
        _setMaxApr(maxAPR_);
        _intervalsMonth = intervalsMonth_;
        _totalShares = 1; // set minimal shares to avoid devide by zero
    }

    /**
     * @dev Sets coefficients for staking time and the presence of zombie.
     *      The coefficient requires 2 decimal places (1.0 == 100)
     * @param intervalCoefficients_ Coefficients for staking time correspond to _intervalsMonth.
     * @param boosterCoefficients_ Coefficients for owning zombies correspond to the level of zombies.
     */
    function setCoefficients(
        uint128[6] memory intervalCoefficients_,
        uint128[5] memory boosterCoefficients_
    ) external haveRights {
        _setCoefficients(intervalCoefficients_, boosterCoefficients_);
    }

    /**
     * @dev Sets the upper limit of APR.
     * @param maxAPR_ Maximum APR percentage to two decimal places (100% == 10000).
     */
    function setMaxApr(uint32 maxAPR_) external haveRights {
        _setMaxApr(maxAPR_);
    }

    /**
     * @dev Stake user tokens for a specified period of time.
     * @param stakeAmount_ Number of tokens for staking. Specified without decimal places.
     * @param interval_ Time interval index 0-5 (see getMonthIntervals()).
     */
    function stake(uint64 stakeAmount_, uint8 interval_) public {
        _stake(stakeAmount_, interval_, 100, 0);
    }

    /**
     * @dev Stake user tokens for a specified period of time with discount for zombiew owners.
     * @param stakeAmount_ Number of tokens for staking. Specified without decimal places.
     * @param interval_ Time interval index 0-5 (see getMonthIntervals()).
     * @param zombieId_ Zombie ID.
     */
    function stakeByZombieOwner(
        uint64 stakeAmount_,
        uint8 interval_,
        uint256 zombieId_
    ) public {
        require(msg.sender == _zombies.ownerOf(zombieId_), NOT_ZOMBIE_OWNER);
        uint16 rank = _zombies.getRank(zombieId_);
        _stake(stakeAmount_, interval_, _getBoostByRank(rank), zombieId_);
    }

    /**
     * @dev Returns staked tokens along with the reward.
     * @param stakeId_ Staking ID.
     */
    function claim(uint128 stakeId_) public {
        require(
            _stakesByAddress[msg.sender].contains(stakeId_),
            INVALID_STAKING_ID
        );
        Stake memory currentStake = _stakes[stakeId_];
        require(currentStake.lockedUntil < block.timestamp, NOT_OVER);

        uint256 unwrappedStakeAmount = uint256(currentStake.amount) * 1e18;
        uint256 totalAmount = _calcReward(
            currentStake.amount,
            currentStake.shares,
            _totalShares,
            currentStake.interval
        ) + unwrappedStakeAmount;

        _totalShares -= currentStake.shares;
        totalStakes -= currentStake.amount;
        _stakesByAddress[msg.sender].remove(stakeId_);
        delete _stakes[stakeId_];

        _udsToken.safeTransfer(msg.sender, totalAmount);
        emit StakeClaimed(msg.sender, stakeId_, totalAmount);
    }

    /**
     * @dev Returns staking by ID.
     * @param stakeId_ Staking ID.
     */
    function getStake(uint128 stakeId_) public view returns (Stake memory) {
        return _stakes[stakeId_];
    }

    /**
     * @dev Returns all staking IDs by stake holder address.
     * @param stakeholder_ Address of stake holder.
     */
    function getStakesOf(
        address stakeholder_
    ) public view returns (uint256[] memory) {
        return _stakesByAddress[stakeholder_].values();
    }

    /**
     * @dev Returns shares for the staking by ID.
     * @param stakeId_ Staking ID.
     */
    function sharesOf(uint128 stakeId_) public view returns (uint128) {
        return _stakes[stakeId_].shares;
    }

    /**
     * @dev Returns the reward size for the specified staking ID under current conditions.
     * @param stakeId_ Staking ID.
     */
    function rewardOf(uint128 stakeId_) public view returns (uint256) {
        Stake memory currentStake = _stakes[stakeId_];
        require(currentStake.lockedUntil < block.timestamp, NOT_OVER);
        require(currentStake.amount > 0, NOT_EXISTS);
        return
            _calcReward(
                currentStake.amount,
                currentStake.shares,
                _totalShares,
                currentStake.interval                
            );
    }

    /**
     * @dev Calculates the reward based on the staking amount and interval.
     * @param stakeAmount_ Number of tokens for staking. Specified without decimal places.
     * @param interval_ Time interval index 0-5 (see getMonthIntervals()).
     */
    function estimateReward(
        uint64 stakeAmount_,
        uint8 interval_
    ) public view returns (uint256) {
        require(stakeAmount_ > 0, ZERO_AMOUNT);
        require(interval_ < 6, INVALID_INTERVAL);
        uint128 shares = _intervalCoefficient[interval_] * stakeAmount_ * 100;
        return _calcReward(stakeAmount_, shares, _totalShares + shares, interval_);
    }

    /**
     * @dev Calculates the reward based on the staking amount, interval and zombie level.
     * @param stakeAmount_ Number of tokens for staking. Specified without decimal places.
     * @param interval_ Time interval index 0-5 (see getMonthIntervals()).
     * @param zombieLevel_ Zombie level.
     */
    function estimateRewardForZombieOwner(
        uint64 stakeAmount_,
        uint8 interval_,
        uint8 zombieLevel_
    ) public view returns (uint256) {
        require(stakeAmount_ > 0, ZERO_AMOUNT);
        require(interval_ < 6, INVALID_INTERVAL);
        require(zombieLevel_ < 5, INVALID_ZOMBIE_LEVEL);
        uint128 shares = _boosterCoefficient[zombieLevel_] *
            _intervalCoefficient[interval_] *
            stakeAmount_;
        return _calcReward(stakeAmount_, shares, _totalShares + shares, interval_);
    }

    /**
     * @dev Returns total staked amount.
     */
    function getTotalStakes() public view returns (uint256) {
        return uint256(totalStakes) * 1e18;
    }

    /**
     * @dev Returns total staked shares.
     */
    function getTotalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Returns current reward pool for stake holder.
     */
    function getCurrentRewardsPool() public view returns (uint256) {
        return
            _udsToken.balanceOf(address(this)) - (uint256(totalStakes) * 1e18);
    }

    /**
     * @dev Returns an array of staking intervals specified in months (1 month == 30 days).
     */
    function getMonthIntervals() public view returns (uint128[6] memory) {
        return _intervalsMonth;
    }

    /**
     * @dev Returns boost coefficients for staking time in accordance with the interval.
     */
    function getIntervalCoefficients() public view returns (uint128[6] memory) {
        return _intervalCoefficient;
    }

    /**
     * @dev Returns boost coefficients for zombie ownership in accordance with the zombie level.
     */
    function getBoostCoefficients() public view returns (uint128[5] memory) {
        return _boosterCoefficient;
    }

    /**
     * @dev Returns APR limit for rewards.
     */
    function getMaxApr() public view returns (uint256) {
        return _maxAPR;
    }

    function _getBoostByRank(
        uint16 zombieRank_
    ) private view returns (uint128) {
        if (zombieRank_ <= 1150) {
            return _boosterCoefficient[0];
        } else if (zombieRank_ <= 1270) {
            return _boosterCoefficient[1];
        } else if (zombieRank_ <= 1390) {
            return _boosterCoefficient[2];
        } else if (zombieRank_ <= 1490) {
            return _boosterCoefficient[3];
        } else {
            return _boosterCoefficient[4];
        }
    }

    function _stake(
        uint64 stakeAmount_,
        uint8 interval_,
        uint128 boostCoefficient_,
        uint256 zombieId_
    ) private {
        require(stakeAmount_ > 0, ZERO_AMOUNT);
        require(interval_ < 6, INVALID_INTERVAL);
        uint128 shares = boostCoefficient_ *
            _intervalCoefficient[interval_] *
            stakeAmount_;
        ++_counter;
        uint128 stakeId = _counter;
        _stakesByAddress[msg.sender].add(stakeId);
        _stakes[stakeId] = Stake({
            amount: stakeAmount_,
            shares: shares,
            lockedUntil: uint40(
                block.timestamp + (_intervalsMonth[interval_] * 30 * 1 days)
            ),
            interval: interval_
        });

        totalStakes += stakeAmount_;
        _totalShares += shares;

        uint256 unwrappedAmount = uint256(stakeAmount_) * 1e18;
        _udsToken.safeTransferFrom(msg.sender, address(this), unwrappedAmount);

        emit StakeAdded(msg.sender, stakeId, zombieId_, boostCoefficient_);
    }

    function _setMaxApr(uint32 maxAPR_) private {
        _maxAPR = maxAPR_;
        emit MaxAprUpdated(maxAPR_);
    }

    function _setCoefficients(
        uint128[6] memory intervalCoefficients_,
        uint128[5] memory boosterCoefficients_
    ) private {
        for (uint256 i; i < 6; ++i) {
            require(intervalCoefficients_[i] > 0, INVALID_INPUT);
        }
        for (uint256 i; i < 5; ++i) {
            require(boosterCoefficients_[i] > 0, INVALID_INPUT);
        }
        _intervalCoefficient = intervalCoefficients_;
        _boosterCoefficient = boosterCoefficients_;
        emit CoefficientsUpdated(intervalCoefficients_, boosterCoefficients_);
    }

    function _calcReward(
        uint128 stakeAmount_,
        uint128 shares_,
        uint128 totalShares_,
        uint8 interval_        
    ) private view returns (uint256) {
        uint256 rewardPool = _udsToken.balanceOf(address(this)) -
            (uint256(totalStakes) * 1e18);
        uint256 rewards = rewardPool * shares_ / totalShares_;
        uint256 maxRewards = (_maxAPR * stakeAmount_ * 1e18 * _intervalsMonth[interval_]) /
            120000;

        return rewards < maxRewards ? rewards : maxRewards;
    }
}
// SPDX-License-Identifier: PROPRIERTARY

// Author: Dmitry Kharlanchuk
// Email: kharlanchuk@scand.com

pragma solidity 0.8.17;

interface IStaking {
    event StakeAdded(address indexed staker, uint128 indexed stakeId, uint256 zombieId, uint128 boostCoefficient);
    event StakeClaimed(address indexed staker, uint128 indexed stakeId, uint256 totalAmount);
    event CoefficientsUpdated(uint128[6] intervalCoefficients, uint128[5] boosterCoefficients);
    event MaxAprUpdated(uint32 maxAPR_);

    struct Stake {
        uint64 amount;
        uint128 shares;
        uint40 lockedUntil;
        uint8 interval;
    }
}
// SPDX-License-Identifier: PROPRIERTARY

// Author: Ilya A. Shlyakhovoy
// Email: is@unicsoft.com

pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {Structures} from "../../lib/Structures.sol";

interface IActors is IERC721Metadata {
    event Minted(address indexed owner, uint256 indexed id);

    event MintedImmaculate(address indexed owner, uint256 indexed id);

    event TokenUriDefined(uint256 indexed id, string kidUri, string adultUri);

    event ActorWasBorn(uint256 indexed id, uint256 bornTime);

    /**
@notice Get a total amount of issued tokens
@return The number of tokens minted
*/

    function total() external view returns (uint256);

    /**
    @notice Set an uri for the adult token (only for non immaculate)
    @param id_ token id
    @param adultHash_ ipfs hash of the kids metadata
    */
    function setMetadataHash(uint256 id_, string calldata adultHash_) external;

    /**
    @notice Set an uri for the adult and kid token (only for immaculate)
    @param id_ token id
    @param kidHash_ ipfs hash of the kids metadata
    @param adultHash_ ipfs hash of the adult metadata
    */
    function setMetadataHashes(
        uint256 id_,
        string calldata kidHash_,
        string calldata adultHash_
    ) external;

    /**
    @notice Get an uri for the kid token
    @param id_ token id
    @return Token uri for the kid actor
    */
    function tokenKidURI(uint256 id_) external view returns (string memory);

    /**
    @notice Get an uri for the adult token
    @param id_ token id
    @return Token uri for the adult actor
    */
    function tokenAdultURI(uint256 id_) external view returns (string memory);

    /**
@notice Create a new person token (not born yet)
@param id_ The id of new minted token
@param owner_ Owner of the token
@param props_ Array of the actor properties
@param sex_ The person sex (true = male, false = female)
@param born_ Is the child born or not
@param adultTime_ When child become adult actor, if 0 actor is not born yet
@param childs_ The amount of childs can be born (only for female)
@param immaculate_ True only for potion-breeded
@return The new id
*/
    function mint(
        uint256 id_,
        address owner_,
        uint16[10] memory props_,
        bool sex_,
        bool born_,
        uint256 adultTime_,
        uint8 childs_,
        bool immaculate_
    ) external returns (uint256);

    /**
@notice Get the person props
@param id_ Person token id
@return Array of the props
*/
    function getProps(uint256 id_) external view returns (uint16[10] memory);

    /**
    @notice Get the actor
    @param id_ Person token id
    @return Structures.ActorData full struct of actor
    */
    function getActor(uint256 id_)
        external
        view
        returns (Structures.ActorData memory);

    /**
@notice Get the person sex
@param id_ Person token id
@return true = male, false = female
*/
    function getSex(uint256 id_) external view returns (bool);

    /**
@notice Get the person childs
@param id_ Person token id
@return childs and possible available childs
*/
    function getChilds(uint256 id_) external view returns (uint8, uint8);

    /**
@notice Breed a child
@param id_ Person token id
*/
    function breedChild(uint256 id_) external;

    /**
@notice Get the person immaculate status
@param id_ Person token id
*/
    function getImmaculate(uint256 id_) external view returns (bool);

    /**
@notice Get the person born time
@param id_ Person token id
@return 0 = complete adult, or amount of tokens needed to be paid for
*/
    function getBornTime(uint256 id_) external view returns (uint256);

    /**
@notice Get the person born state
@param id_ Person token id
@return true = person is born
*/
    function isBorn(uint256 id_) external view returns (bool);

    /**
@notice Birth the person
@param id_ Person token id 
@param adultTime_ When person becomes adult
*/
    function born(uint256 id_, uint256 adultTime_) external;

    /**
@notice Get the person adult timestamp
@param id_ Person token id
@return timestamp
*/
    function getAdultTime(uint256 id_) external view returns (uint256);

    /**
@notice Grow the 
@param id_ Person token id 
@param time_ the deadline to grow
*/
    function setAdultTime(uint256 id_, uint256 time_) external;

    /**
@notice Get the person adult state
@param id_ Person token id
@return true = person is adult (price is 0 and current date > person's grow deadline)
*/
    function isAdult(uint256 id_) external view returns (bool);

    /**
@notice Get the person rank
@param id_ Person token id
@return person rank value
*/
    function getRank(uint256 id_) external view returns (uint16);
}
// SPDX-License-Identifier: PROPRIERTARY

// Author: Ilya A. Shlyakhovoy
// Email: is@unicsoft.com

pragma solidity 0.8.17;
import "./interfaces/IRights.sol";

abstract contract Guard {
    string constant NO_RIGHTS = "Guard: No rights";

    /// @notice only if person with rights calls the contract
    modifier haveRights() {
        require(_rights().haveRights(address(this), msg.sender), NO_RIGHTS);
        _;
    }

    /// @notice only if someone with rights calls the contract
    modifier haveRightsPerson(address who_) {
        require(_rights().haveRights(address(this), who_), NO_RIGHTS);
        _;
    }

    /// @notice only if who with rights calls the target function
    modifier haveRightsExt(address target_, address who_) {
        require(_rights().haveRights(target_, who_), NO_RIGHTS);
        _;
    }

    function _rights() internal view virtual returns (IRights);

    function setRights(address rights_) external virtual;
}
// SPDX-License-Identifier: PROPRIERTARY

// Author: Ilya A. Shlyakhovoy
// Email: is@unicsoft.com

pragma solidity 0.8.17;
import "./interfaces/IRights.sol";
import "../utils/Guard.sol";

abstract contract GuardExtension is Guard {
    IRights private _rightsContract;

    string private constant SAME_VALUE = "Guard: same value";
    string private constant ZERO_ADDRESS = "Guard: zero address";

    constructor(address rights_) {
        require(rights_ != address(0), ZERO_ADDRESS);
        _rightsContract = IRights(rights_);
    }

    function _rights() internal view virtual override returns (IRights) {
        return _rightsContract;
    }

    function setRights(address rights_) external virtual override haveRights {
        require(address(_rightsContract) != rights_, SAME_VALUE);
        require(rights_ != address(0), ZERO_ADDRESS);
        _rightsContract = IRights(rights_);
    }
}
// SPDX-License-Identifier: PROPRIERTARY

// Author: Ilya A. Shlyakhovoy
// Email: is@unicsoft.com

pragma solidity 0.8.17;

interface IRights {
    event AdminAdded(address indexed admin);
    event AdminDefined(address indexed admin, address indexed contractHash);
    event AdminRemoved(address indexed admin);
    event AdminCleared(address indexed admin, address indexed contractHash);

    /**
@notice Add a new admin for the Rigths contract
@param admin_ New admin address
*/

    function addAdmin(address admin_) external;

    /**
@notice Add a new admin for the any other contract
@param contract_ Contract address packed into address
@param admin_ New admin address
*/

    function addAdmin(address contract_, address admin_) external;

    /**
@notice Remove the existing admin from the Rigths contract
@param admin_ Admin address
*/

    function removeAdmin(address admin_) external;

    /**
@notice Remove the existing admin from the specified contract
@param contract_ Contract address packed into address
@param admin_ Admin address
*/

    function removeAdmin(address contract_, address admin_) external;

    /**
@notice Get the rights for the contract for the caller
@param contract_ Contract address packed into address
@return have rights or not
*/
    function haveRights(address contract_) external view returns (bool);

    /**
@notice Get the rights for the contract
@param contract_ Contract address packed into address
@param admin_ Admin address
@return have rights or not
*/
    function haveRights(address contract_, address admin_)
        external
        view
        returns (bool);
}