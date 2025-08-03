// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
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
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

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
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function setApprovalForAll(address operator, bool _approved) external;

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
pragma solidity ^0.8.4;

/// @notice Minimal proxy library.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibClone.sol)
/// @author Minimal proxy by 0age (https://github.com/0age)
/// @author Clones with immutable args by wighawag, zefram.eth, Saw-mon & Natalie
/// (https://github.com/Saw-mon-and-Natalie/clones-with-immutable-args)
///
/// @dev Minimal proxy:
/// Although the sw0nt pattern saves 5 gas over the erc-1167 pattern during runtime,
/// it is not supported out-of-the-box on Etherscan. Hence, we choose to use the 0age pattern,
/// which saves 4 gas over the erc-1167 pattern during runtime, and has the smallest bytecode.
///
/// @dev Clones with immutable args (CWIA):
/// The implementation of CWIA here implements a `receive()` method that emits the
/// `ReceiveETH(uint256)` event. This skips the `DELEGATECALL` when there is no calldata,
/// enabling us to accept hard gas-capped `sends` & `transfers` for maximum backwards
/// composability. The minimal proxy implementation does not offer this feature.
library LibClone {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Unable to deploy the clone.
    error DeploymentFailed();

    /// @dev The salt must start with either the zero address or the caller.
    error SaltDoesNotStartWithCaller();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  MINIMAL PROXY OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Deploys a clone of `implementation`.
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            /**
             * --------------------------------------------------------------------------+
             * CREATION (9 bytes)                                                        |
             * --------------------------------------------------------------------------|
             * Opcode     | Mnemonic          | Stack     | Memory                       |
             * --------------------------------------------------------------------------|
             * 60 runSize | PUSH1 runSize     | r         |                              |
             * 3d         | RETURNDATASIZE    | 0 r       |                              |
             * 81         | DUP2              | r 0 r     |                              |
             * 60 offset  | PUSH1 offset      | o r 0 r   |                              |
             * 3d         | RETURNDATASIZE    | 0 o r 0 r |                              |
             * 39         | CODECOPY          | 0 r       | [0..runSize): runtime code   |
             * f3         | RETURN            |           | [0..runSize): runtime code   |
             * --------------------------------------------------------------------------|
             * RUNTIME (44 bytes)                                                        |
             * --------------------------------------------------------------------------|
             * Opcode  | Mnemonic       | Stack                  | Memory                |
             * --------------------------------------------------------------------------|
             *                                                                           |
             * ::: keep some values in stack ::::::::::::::::::::::::::::::::::::::::::: |
             * 3d      | RETURNDATASIZE | 0                      |                       |
             * 3d      | RETURNDATASIZE | 0 0                    |                       |
             * 3d      | RETURNDATASIZE | 0 0 0                  |                       |
             * 3d      | RETURNDATASIZE | 0 0 0 0                |                       |
             *                                                                           |
             * ::: copy calldata to memory ::::::::::::::::::::::::::::::::::::::::::::: |
             * 36      | CALLDATASIZE   | cds 0 0 0 0            |                       |
             * 3d      | RETURNDATASIZE | 0 cds 0 0 0 0          |                       |
             * 3d      | RETURNDATASIZE | 0 0 cds 0 0 0 0        |                       |
             * 37      | CALLDATACOPY   | 0 0 0 0                | [0..cds): calldata    |
             *                                                                           |
             * ::: delegate call to the implementation contract :::::::::::::::::::::::: |
             * 36      | CALLDATASIZE   | cds 0 0 0 0            | [0..cds): calldata    |
             * 3d      | RETURNDATASIZE | 0 cds 0 0 0 0          | [0..cds): calldata    |
             * 73 addr | PUSH20 addr    | addr 0 cds 0 0 0 0     | [0..cds): calldata    |
             * 5a      | GAS            | gas addr 0 cds 0 0 0 0 | [0..cds): calldata    |
             * f4      | DELEGATECALL   | success 0 0            | [0..cds): calldata    |
             *                                                                           |
             * ::: copy return data to memory :::::::::::::::::::::::::::::::::::::::::: |
             * 3d      | RETURNDATASIZE | rds success 0 0        | [0..cds): calldata    |
             * 3d      | RETURNDATASIZE | rds rds success 0 0    | [0..cds): calldata    |
             * 93      | SWAP4          | 0 rds success 0 rds    | [0..cds): calldata    |
             * 80      | DUP1           | 0 0 rds success 0 rds  | [0..cds): calldata    |
             * 3e      | RETURNDATACOPY | success 0 rds          | [0..rds): returndata  |
             *                                                                           |
             * 60 0x2a | PUSH1 0x2a     | 0x2a success 0 rds     | [0..rds): returndata  |
             * 57      | JUMPI          | 0 rds                  | [0..rds): returndata  |
             *                                                                           |
             * ::: revert :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * fd      | REVERT         |                        | [0..rds): returndata  |
             *                                                                           |
             * ::: return :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 5b      | JUMPDEST       | 0 rds                  | [0..rds): returndata  |
             * f3      | RETURN         |                        | [0..rds): returndata  |
             * --------------------------------------------------------------------------+
             */

            mstore(0x21, 0x5af43d3d93803e602a57fd5bf3)
            mstore(0x14, implementation)
            mstore(0x00, 0x602c3d8160093d39f33d3d3d3d363d3d37363d73)
            instance := create(0, 0x0c, 0x35)
            // Restore the part of the free memory pointer that has been overwritten.
            mstore(0x21, 0)
            // If `instance` is zero, revert.
            if iszero(instance) {
                // Store the function selector of `DeploymentFailed()`.
                mstore(0x00, 0x30116425)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Deploys a deterministic clone of `implementation` with `salt`.
    function cloneDeterministic(address implementation, bytes32 salt)
        internal
        returns (address instance)
    {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x21, 0x5af43d3d93803e602a57fd5bf3)
            mstore(0x14, implementation)
            mstore(0x00, 0x602c3d8160093d39f33d3d3d3d363d3d37363d73)
            instance := create2(0, 0x0c, 0x35, salt)
            // Restore the part of the free memory pointer that has been overwritten.
            mstore(0x21, 0)
            // If `instance` is zero, revert.
            if iszero(instance) {
                // Store the function selector of `DeploymentFailed()`.
                mstore(0x00, 0x30116425)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Returns the initialization code hash of the clone of `implementation`.
    /// Used for mining vanity addresses with create2crunch.
    function initCodeHash(address implementation) internal pure returns (bytes32 hash) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x21, 0x5af43d3d93803e602a57fd5bf3)
            mstore(0x14, implementation)
            mstore(0x00, 0x602c3d8160093d39f33d3d3d3d363d3d37363d73)
            hash := keccak256(0x0c, 0x35)
            // Restore the part of the free memory pointer that has been overwritten.
            mstore(0x21, 0)
        }
    }

    /// @dev Returns the address of the deterministic clone of `implementation`,
    /// with `salt` by `deployer`.
    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer)
        internal
        pure
        returns (address predicted)
    {
        bytes32 hash = initCodeHash(implementation);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*           CLONES WITH IMMUTABLE ARGS OPERATIONS            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Deploys a minimal proxy with `implementation`,
    /// using immutable arguments encoded in `data`.
    function clone(address implementation, bytes memory data) internal returns (address instance) {
        assembly {
            // Compute the boundaries of the data and cache the memory slots around it.
            let mBefore3 := mload(sub(data, 0x60))
            let mBefore2 := mload(sub(data, 0x40))
            let mBefore1 := mload(sub(data, 0x20))
            let dataLength := mload(data)
            let dataEnd := add(add(data, 0x20), dataLength)
            let mAfter1 := mload(dataEnd)

            // +2 bytes for telling how much data there is appended to the call.
            let extraLength := add(dataLength, 2)
            // The `creationSize` is `extraLength + 108`
            // The `runSize` is `creationSize - 10`.

            /**
             * ---------------------------------------------------------------------------------------------------+
             * CREATION (10 bytes)                                                                                |
             * ---------------------------------------------------------------------------------------------------|
             * Opcode     | Mnemonic          | Stack     | Memory                                                |
             * ---------------------------------------------------------------------------------------------------|
             * 61 runSize | PUSH2 runSize     | r         |                                                       |
             * 3d         | RETURNDATASIZE    | 0 r       |                                                       |
             * 81         | DUP2              | r 0 r     |                                                       |
             * 60 offset  | PUSH1 offset      | o r 0 r   |                                                       |
             * 3d         | RETURNDATASIZE    | 0 o r 0 r |                                                       |
             * 39         | CODECOPY          | 0 r       | [0..runSize): runtime code                            |
             * f3         | RETURN            |           | [0..runSize): runtime code                            |
             * ---------------------------------------------------------------------------------------------------|
             * RUNTIME (98 bytes + extraLength)                                                                   |
             * ---------------------------------------------------------------------------------------------------|
             * Opcode   | Mnemonic       | Stack                    | Memory                                      |
             * ---------------------------------------------------------------------------------------------------|
             *                                                                                                    |
             * ::: if no calldata, emit event & return w/o `DELEGATECALL` ::::::::::::::::::::::::::::::::::::::: |
             * 36       | CALLDATASIZE   | cds                      |                                             |
             * 60 0x2c  | PUSH1 0x2c     | 0x2c cds                 |                                             |
             * 57       | JUMPI          |                          |                                             |
             * 34       | CALLVALUE      | cv                       |                                             |
             * 3d       | RETURNDATASIZE | 0 cv                     |                                             |
             * 52       | MSTORE         |                          | [0..0x20): callvalue                        |
             * 7f sig   | PUSH32 0x9e..  | sig                      | [0..0x20): callvalue                        |
             * 59       | MSIZE          | 0x20 sig                 | [0..0x20): callvalue                        |
             * 3d       | RETURNDATASIZE | 0 0x20 sig               | [0..0x20): callvalue                        |
             * a1       | LOG1           |                          | [0..0x20): callvalue                        |
             * 00       | STOP           |                          | [0..0x20): callvalue                        |
             * 5b       | JUMPDEST       |                          |                                             |
             *                                                                                                    |
             * ::: copy calldata to memory :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 36       | CALLDATASIZE   | cds                      |                                             |
             * 3d       | RETURNDATASIZE | 0 cds                    |                                             |
             * 3d       | RETURNDATASIZE | 0 0 cds                  |                                             |
             * 37       | CALLDATACOPY   |                          | [0..cds): calldata                          |
             *                                                                                                    |
             * ::: keep some values in stack :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d       | RETURNDATASIZE | 0                        | [0..cds): calldata                          |
             * 3d       | RETURNDATASIZE | 0 0                      | [0..cds): calldata                          |
             * 3d       | RETURNDATASIZE | 0 0 0                    | [0..cds): calldata                          |
             * 3d       | RETURNDATASIZE | 0 0 0 0                  | [0..cds): calldata                          |
             * 61 extra | PUSH2 extra    | e 0 0 0 0                | [0..cds): calldata                          |
             *                                                                                                    |
             * ::: copy extra data to memory :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 80       | DUP1           | e e 0 0 0 0              | [0..cds): calldata                          |
             * 60 0x62  | PUSH1 0x62     | 0x62 e e 0 0 0 0         | [0..cds): calldata                          |
             * 36       | CALLDATASIZE   | cds 0x62 e e 0 0 0 0     | [0..cds): calldata                          |
             * 39       | CODECOPY       | e 0 0 0 0                | [0..cds): calldata, [cds..cds+e): extraData |
             *                                                                                                    |
             * ::: delegate call to the implementation contract ::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 36       | CALLDATASIZE   | cds e 0 0 0 0            | [0..cds): calldata, [cds..cds+e): extraData |
             * 01       | ADD            | cds+e 0 0 0 0            | [0..cds): calldata, [cds..cds+e): extraData |
             * 3d       | RETURNDATASIZE | 0 cds+e 0 0 0 0          | [0..cds): calldata, [cds..cds+e): extraData |
             * 73 addr  | PUSH20 addr    | addr 0 cds+e 0 0 0 0     | [0..cds): calldata, [cds..cds+e): extraData |
             * 5a       | GAS            | gas addr 0 cds+e 0 0 0 0 | [0..cds): calldata, [cds..cds+e): extraData |
             * f4       | DELEGATECALL   | success 0 0              | [0..cds): calldata, [cds..cds+e): extraData |
             *                                                                                                    |
             * ::: copy return data to memory ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 3d       | RETURNDATASIZE | rds success 0 0          | [0..cds): calldata, [cds..cds+e): extraData |
             * 3d       | RETURNDATASIZE | rds rds success 0 0      | [0..cds): calldata, [cds..cds+e): extraData |
             * 93       | SWAP4          | 0 rds success 0 rds      | [0..cds): calldata, [cds..cds+e): extraData |
             * 80       | DUP1           | 0 0 rds success 0 rds    | [0..cds): calldata, [cds..cds+e): extraData |
             * 3e       | RETURNDATACOPY | success 0 rds            | [0..rds): returndata                        |
             *                                                                                                    |
             * 60 0x60  | PUSH1 0x60     | 0x60 success 0 rds       | [0..rds): returndata                        |
             * 57       | JUMPI          | 0 rds                    | [0..rds): returndata                        |
             *                                                                                                    |
             * ::: revert ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * fd       | REVERT         |                          | [0..rds): returndata                        |
             *                                                                                                    |
             * ::: return ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |
             * 5b       | JUMPDEST       | 0 rds                    | [0..rds): returndata                        |
             * f3       | RETURN         |                          | [0..rds): returndata                        |
             * ---------------------------------------------------------------------------------------------------+
             */
            // Write the bytecode before the data.
            mstore(data, 0x5af43d3d93803e606057fd5bf3)
            // Write the address of the implementation.
            mstore(sub(data, 0x0d), implementation)
            // Write the rest of the bytecode.
            mstore(
                sub(data, 0x21),
                or(shl(0x48, extraLength), 0x593da1005b363d3d373d3d3d3d610000806062363936013d73)
            )
            // `keccak256("ReceiveETH(uint256)")`
            mstore(
                sub(data, 0x3a), 0x9e4ac34f21c619cefc926c8bd93b54bf5a39c7ab2127a895af1cc0691d7e3dff
            )
            mstore(
                sub(data, 0x5a),
                or(shl(0x78, add(extraLength, 0x62)), 0x6100003d81600a3d39f336602c57343d527f)
            )
            mstore(dataEnd, shl(0xf0, extraLength))

            // Create the instance.
            instance := create(0, sub(data, 0x4c), add(extraLength, 0x6c))

            // If `instance` is zero, revert.
            if iszero(instance) {
                // Store the function selector of `DeploymentFailed()`.
                mstore(0x00, 0x30116425)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Restore the overwritten memory surrounding `data`.
            mstore(dataEnd, mAfter1)
            mstore(data, dataLength)
            mstore(sub(data, 0x20), mBefore1)
            mstore(sub(data, 0x40), mBefore2)
            mstore(sub(data, 0x60), mBefore3)
        }
    }

    /// @dev Deploys a deterministic clone of `implementation`,
    /// using immutable arguments encoded in `data`, with `salt`.
    function cloneDeterministic(address implementation, bytes memory data, bytes32 salt)
        internal
        returns (address instance)
    {
        assembly {
            // Compute the boundaries of the data and cache the memory slots around it.
            let mBefore3 := mload(sub(data, 0x60))
            let mBefore2 := mload(sub(data, 0x40))
            let mBefore1 := mload(sub(data, 0x20))
            let dataLength := mload(data)
            let dataEnd := add(add(data, 0x20), dataLength)
            let mAfter1 := mload(dataEnd)

            // +2 bytes for telling how much data there is appended to the call.
            let extraLength := add(dataLength, 2)

            // Write the bytecode before the data.
            mstore(data, 0x5af43d3d93803e606057fd5bf3)
            // Write the address of the implementation.
            mstore(sub(data, 0x0d), implementation)
            // Write the rest of the bytecode.
            mstore(
                sub(data, 0x21),
                or(shl(0x48, extraLength), 0x593da1005b363d3d373d3d3d3d610000806062363936013d73)
            )
            // `keccak256("ReceiveETH(uint256)")`
            mstore(
                sub(data, 0x3a), 0x9e4ac34f21c619cefc926c8bd93b54bf5a39c7ab2127a895af1cc0691d7e3dff
            )
            mstore(
                sub(data, 0x5a),
                or(shl(0x78, add(extraLength, 0x62)), 0x6100003d81600a3d39f336602c57343d527f)
            )
            mstore(dataEnd, shl(0xf0, extraLength))

            // Create the instance.
            instance := create2(0, sub(data, 0x4c), add(extraLength, 0x6c), salt)

            // If `instance` is zero, revert.
            if iszero(instance) {
                // Store the function selector of `DeploymentFailed()`.
                mstore(0x00, 0x30116425)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Restore the overwritten memory surrounding `data`.
            mstore(dataEnd, mAfter1)
            mstore(data, dataLength)
            mstore(sub(data, 0x20), mBefore1)
            mstore(sub(data, 0x40), mBefore2)
            mstore(sub(data, 0x60), mBefore3)
        }
    }

    /// @dev Returns the initialization code hash of the clone of `implementation`
    /// using immutable arguments encoded in `data`.
    /// Used for mining vanity addresses with create2crunch.
    function initCodeHash(address implementation, bytes memory data)
        internal
        pure
        returns (bytes32 hash)
    {
        assembly {
            // Compute the boundaries of the data and cache the memory slots around it.
            let mBefore3 := mload(sub(data, 0x60))
            let mBefore2 := mload(sub(data, 0x40))
            let mBefore1 := mload(sub(data, 0x20))
            let dataLength := mload(data)
            let dataEnd := add(add(data, 0x20), dataLength)
            let mAfter1 := mload(dataEnd)

            // +2 bytes for telling how much data there is appended to the call.
            let extraLength := add(dataLength, 2)

            // Write the bytecode before the data.
            mstore(data, 0x5af43d3d93803e606057fd5bf3)
            // Write the address of the implementation.
            mstore(sub(data, 0x0d), implementation)
            // Write the rest of the bytecode.
            mstore(
                sub(data, 0x21),
                or(shl(0x48, extraLength), 0x593da1005b363d3d373d3d3d3d610000806062363936013d73)
            )
            // `keccak256("ReceiveETH(uint256)")`
            mstore(
                sub(data, 0x3a), 0x9e4ac34f21c619cefc926c8bd93b54bf5a39c7ab2127a895af1cc0691d7e3dff
            )
            mstore(
                sub(data, 0x5a),
                or(shl(0x78, add(extraLength, 0x62)), 0x6100003d81600a3d39f336602c57343d527f)
            )
            mstore(dataEnd, shl(0xf0, extraLength))

            // Compute and store the bytecode hash.
            hash := keccak256(sub(data, 0x4c), add(extraLength, 0x6c))

            // Restore the overwritten memory surrounding `data`.
            mstore(dataEnd, mAfter1)
            mstore(data, dataLength)
            mstore(sub(data, 0x20), mBefore1)
            mstore(sub(data, 0x40), mBefore2)
            mstore(sub(data, 0x60), mBefore3)
        }
    }

    /// @dev Returns the address of the deterministic clone of
    /// `implementation` using immutable arguments encoded in `data`, with `salt`, by `deployer`.
    function predictDeterministicAddress(
        address implementation,
        bytes memory data,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 hash = initCodeHash(implementation, data);
        predicted = predictDeterministicAddress(hash, salt, deployer);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      OTHER OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the address when a contract with initialization code hash,
    /// `hash`, is deployed with `salt`, by `deployer`.
    function predictDeterministicAddress(bytes32 hash, bytes32 salt, address deployer)
        internal
        pure
        returns (address predicted)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and store the bytecode hash.
            mstore8(0x00, 0xff) // Write the prefix.
            mstore(0x35, hash)
            mstore(0x01, shl(96, deployer))
            mstore(0x15, salt)
            predicted := keccak256(0x00, 0x55)
            // Restore the part of the free memory pointer that has been overwritten.
            mstore(0x35, 0)
        }
    }

    /// @dev Reverts if `salt` does not start with either the zero address or the caller.
    function checkStartsWithCaller(bytes32 salt) internal view {
        /// @solidity memory-safe-assembly
        assembly {
            // If the salt does not start with the zero address or the caller.
            if iszero(or(iszero(shr(96, salt)), eq(caller(), shr(96, salt)))) {
                // Store the function selector of `SaltDoesNotStartWithCaller()`.
                mstore(0x00, 0x2f634836)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

// ETH pseudo-token address
address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

// The maximum value that can be represented as an unsigned 250-bit integer
uint256 constant MAX_250_BIT_UNSIGNED = 0x03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

/// @notice Starknet function selector constants
library Selector {
    // print(get_selector_from_name("register_round"))
    uint256 constant REGISTER_ROUND = 0x26490f901ea8ad5a245d987479919f1d20fbb0c164367e33ef09a9ea4ba8d04;

    // print(get_selector_from_name("cancel_round"))
    uint256 constant CANCEL_ROUND = 0x8af3ea41808c9515720e56add54a2d8008458a8bc5e347b791c6d75cd0e407;

    // print(get_selector_from_name("finalize_round"))
    uint256 constant FINALIZE_ROUND = 0x2445872c1b7a1219e1e75f2a60719ce0a68a8442fee1bdbee6c3c649340e6f3;

    // print(get_selector_from_name("route_call_to_round"))
    uint256 constant ROUTE_CALL_TO_ROUND = 0x24931ca109ce0ffa87913d91f12d6ac327550c015a573c7b17a187c29ed8c1a;
}

/// @notice Prop House metadata constants
library PHMetadata {
    // The Prop House NFT name
    string constant NAME = 'Prop House';

    // The Prop House entrypoint NFT symbol
    string constant SYMBOL = 'PROP';

    // The Prop House entrypoint NFT contract URI
    string constant URI = 'ipfs://bafkreiagexn2wbv5t63y2xbf6mmcx3rktrqxrsyzf5gl5l7c2lm3bkqjc4';
}

/// @notice Community house metadata constants
library CHMetadata {
    // The Community House type
    bytes32 constant TYPE = 'COMMUNITY';

    // The Community House NFT name
    string constant NAME = 'Community House';

    // The Community House NFT symbol
    string constant SYMBOL = 'COMM';
}

/// @notice Round type constants
library RoundType {
    // The Timed Round type
    bytes32 constant TIMED = 'TIMED';

    // The Infinite Round type
    bytes32 constant INFINITE = 'INFINITE';
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { IManager } from './interfaces/IManager.sol';
import { AssetController } from './lib/utils/AssetController.sol';
import { IDepositReceiver } from './interfaces/IDepositReceiver.sol';
import { AssetHelper } from './lib/utils/AssetHelper.sol';
import { AssetType, Asset } from './lib/types/Common.sol';
import { IPropHouse } from './interfaces/IPropHouse.sol';
import { LibClone } from 'solady/src/utils/LibClone.sol';
import { Uint256 } from './lib/utils/Uint256.sol';
import { IHouse } from './interfaces/IHouse.sol';
import { IRound } from './interfaces/IRound.sol';
import { ERC721 } from './lib/token/ERC721.sol';
import { PHMetadata } from './Constants.sol';

/// @notice The entrypoint for house and round creation
contract PropHouse is IPropHouse, ERC721, AssetController {
    using { Uint256.toUint256 } for address;
    using { AssetHelper.toID } for Asset;
    using LibClone for address;

    /// @notice The Prop House manager contract
    IManager public immutable manager;

    /// @param _manager The Prop House manager contract address
    constructor(address _manager) ERC721(PHMetadata.NAME, PHMetadata.SYMBOL) {
        manager = IManager(_manager);

        _setContractURI(PHMetadata.URI);
    }

    /// @notice Returns house metadata for `tokenId`
    /// @param tokenId The token ID
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return manager.getMetadataRenderer(address(this)).tokenURI(tokenId);
    }

    /// @notice Deposit an asset to the provided round and return any remaining
    /// ether to the caller.
    /// @param round The round to deposit to
    /// @param asset The asset to transfer to the round
    /// @dev For safety, this function validates the round before the transfer
    function depositTo(address payable round, Asset calldata asset) external payable {
        if (!isRound(round)) {
            revert INVALID_ROUND();
        }

        uint256 etherRemaining = _depositTo(msg.sender, round, asset);
        if (etherRemaining != 0) {
            _transferETH(payable(msg.sender), etherRemaining);
        }
    }

    /// @notice Deposit many assets to the provided round and return any remaining
    /// ether to the caller.
    /// @param round The round to deposit to
    /// @param assets The assets to transfer to the round
    /// @dev For safety, this function validates the round before the transfer
    function batchDepositTo(address payable round, Asset[] calldata assets) external payable {
        if (!isRound(round)) {
            revert INVALID_ROUND();
        }

        uint256 etherRemaining = _batchDepositTo(msg.sender, round, assets);
        if (etherRemaining != 0) {
            _transferETH(payable(msg.sender), etherRemaining);
        }
    }

    /// @notice Create a round on an existing house
    /// @param house The house to create the round on
    /// @param newRound The round creation data
    function createRoundOnExistingHouse(
        address house,
        Round calldata newRound
    ) external payable returns (address round) {
        if (!isHouse(house)) {
            revert INVALID_HOUSE();
        }
        if (!manager.isRoundRegistered(_getImpl(house), newRound.impl)) {
            revert INVALID_ROUND_IMPL_FOR_HOUSE();
        }

        round = _createRound(house, newRound);
        IRound(round).initialize{ value: msg.value }(newRound.config);
    }

    /// @notice Create a round on an existing house and deposit assets to the round
    /// @param house The house to create the round on
    /// @param newRound The round creation data
    /// @param assets Assets to deposit to the round
    function createAndFundRoundOnExistingHouse(
        address house,
        Round calldata newRound,
        Asset[] calldata assets
    ) external payable returns (address round) {
        if (!isHouse(house)) {
            revert INVALID_HOUSE();
        }
        if (!manager.isRoundRegistered(_getImpl(house), newRound.impl)) {
            revert INVALID_ROUND_IMPL_FOR_HOUSE();
        }

        round = _createRound(house, newRound);

        uint256 etherRemaining = _batchDepositTo(msg.sender, payable(round), assets);
        IRound(round).initialize{ value: etherRemaining }(newRound.config);
    }

    /// @notice Create a round on a new house
    /// @param newHouse The house creation data
    /// @param newRound The round creation data
    function createRoundOnNewHouse(
        House calldata newHouse,
        Round calldata newRound
    ) external payable returns (address house, address round) {
        if (!manager.isHouseRegistered(newHouse.impl)) {
            revert INVALID_HOUSE_IMPL();
        }
        if (!manager.isRoundRegistered(newHouse.impl, newRound.impl)) {
            revert INVALID_ROUND_IMPL_FOR_HOUSE();
        }

        house = _createHouse(newHouse);
        round = _createRound(house, newRound);

        IRound(round).initialize{ value: msg.value }(newRound.config);
    }

    /// @notice Create a round on a new house and deposit assets to the round
    /// @param newHouse The house creation data
    /// @param newRound The round creation data
    /// @param assets Assets to deposit to the round
    function createAndFundRoundOnNewHouse(
        House calldata newHouse,
        Round calldata newRound,
        Asset[] calldata assets
    ) external payable returns (address house, address round) {
        if (!manager.isHouseRegistered(newHouse.impl)) {
            revert INVALID_HOUSE_IMPL();
        }
        if (!manager.isRoundRegistered(newHouse.impl, newRound.impl)) {
            revert INVALID_ROUND_IMPL_FOR_HOUSE();
        }

        house = _createHouse(newHouse);
        round = _createRound(house, newRound);

        uint256 etherRemaining = _batchDepositTo(msg.sender, payable(round), assets);
        IRound(round).initialize{ value: etherRemaining }(newRound.config);
    }

    /// @notice Create a new house
    /// @param newHouse The house creation data
    function createHouse(House calldata newHouse) external returns (address house) {
        if (!manager.isHouseRegistered(newHouse.impl)) {
            revert INVALID_HOUSE_IMPL();
        }
        house = _createHouse(newHouse);
    }

    /// @notice Returns `true` if the passed `house` address is valid
    /// @param house The house address
    function isHouse(address house) public view returns (bool) {
        return exists(house.toUint256());
    }

    /// @notice Returns `true` if the passed `round` address is valid on any house
    /// @param round The round address
    function isRound(address round) public view returns (bool) {
        try IRound(round).house() returns (address house) {
            return isHouse(house) && IHouse(house).isRound(round);
        } catch {
            return false;
        }
    }

    /// @notice Create and initialize a new house contract
    /// @param newHouse The house creation data
    function _createHouse(House memory newHouse) internal returns (address house) {
        house = newHouse.impl.clone();

        // Mint the ownership token to the house creator
        _mint(msg.sender, house.toUint256());

        emit HouseCreated(msg.sender, house, IHouse(house).kind());

        IHouse(house).initialize(newHouse.config);
    }

    /// @notice Create a new round and emit an event
    /// @param house The house address on which to create the round
    /// @param newRound The round creation data
    function _createRound(address house, Round calldata newRound) internal returns (address round) {
        round = IHouse(house).createRound(newRound.impl, newRound.title, msg.sender);

        emit RoundCreated(msg.sender, house, round, IRound(round).kind(), newRound.title, newRound.description);
    }

    /// @notice Deposit an asset to the provided round
    /// @param user The user depositing the asset
    /// @param round The round address
    /// @param asset The asset to transfer to the round
    function _depositTo(address user, address payable round, Asset memory asset) internal returns (uint256) {
        uint256 etherRemaining = msg.value;

        // Reduce amount of remaining ether, if necessary
        if (asset.assetType == AssetType.Native) {
            // Ensure that sufficient native tokens are still available.
            if (asset.amount > etherRemaining) {
                revert INSUFFICIENT_ETHER_SUPPLIED();
            }
            // Skip underflow check as a comparison has just been made
            unchecked {
                etherRemaining -= asset.amount;
            }
        }

        _transfer(asset, user, round);

        emit DepositToRound(user, round, asset);

        // If supported, call the round's deposit receiver callback
        if (IRound(round).supportsInterface(type(IDepositReceiver).interfaceId)) {
            IDepositReceiver(round).onDepositReceived(user, asset.toID(), asset.amount);
        }
        return etherRemaining;
    }

    /// @notice Deposit many assets to the provided round
    /// @param user The user depositing the assets
    /// @param round The round address
    /// @param assets The assets to transfer to the strategy
    function _batchDepositTo(address user, address payable round, Asset[] memory assets) internal returns (uint256) {
        uint256 assetCount = assets.length;

        uint256 etherRemaining = msg.value;

        uint256[] memory assetIds = new uint256[](assetCount);
        uint256[] memory assetAmounts = new uint256[](assetCount);
        for (uint256 i = 0; i < assetCount; ) {
            // Populate asset IDs and amounts in preparation for deposit token minting
            assetIds[i] = assets[i].toID();
            assetAmounts[i] = assets[i].amount;

            // Reduce amount of remaining ether, if necessary
            if (assets[i].assetType == AssetType.Native) {
                // Ensure that sufficient native tokens are still available.
                if (assets[i].amount > etherRemaining) {
                    revert INSUFFICIENT_ETHER_SUPPLIED();
                }

                // Skip underflow check as a comparison has just been made
                unchecked {
                    etherRemaining -= assets[i].amount;
                }
            }

            _transfer(assets[i], user, round);

            unchecked {
                ++i;
            }
        }

        emit BatchDepositToRound(user, round, assets);

        // If supported, call the round's deposit receiver callback
        if (IRound(round).supportsInterface(type(IDepositReceiver).interfaceId)) {
            IDepositReceiver(round).onDepositsReceived(user, assetIds, assetAmounts);
        }
        return etherRemaining;
    }

    /// @notice Returns the implementation address for the provided `clone`
    /// @param clone The clone contract address
    function _getImpl(address clone) internal view returns (address impl) {
        assembly {
            extcodecopy(clone, 0x0, 0xB, 0x14)
            impl := shr(0x60, mload(0x0))
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { IRound } from './IRound.sol';

/// @notice Interface that can be implemented by rounds that receive deposits
interface IDepositReceiver is IRound {
    /// @notice A callback that is called when a deposit is received
    function onDepositReceived(address depositor, uint256 id, uint256 amount) external;

    /// @notice A callback that is called when a batch of deposits is received
    function onDepositsReceived(address depositor, uint256[] calldata ids, uint256[] calldata amounts) external;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

/// @title IERC165
/// @notice Interface of the ERC165 standard, as defined in the https://eips.ethereum.org/EIPS/eip-165[EIP].
interface IERC165 {
    /// @dev Returns true if this contract implements the interface defined by
    /// `interfaceId`. See the corresponding
    /// https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
    /// to learn more about how these ids are created.
    /// This function call must use less than 30000 gas.
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

/// @title IERC721
/// @notice The external ERC721 events, errors, and functions
interface IERC721 {
    /// @dev Thrown when a caller is not authorized to approve or transfer a token
    error INVALID_APPROVAL();

    /// @dev Thrown when a transfer is called with the incorrect token owner
    error INVALID_OWNER();

    /// @dev Thrown when a transfer is attempted to address(0)
    error INVALID_RECIPIENT();

    /// @dev Thrown when an existing token is called to be minted
    error ALREADY_MINTED();

    /// @dev Thrown when a non-existent token is called to be burned
    error NOT_MINTED();

    /// @dev Thrown when address(0) is incorrectly provided
    error ADDRESS_ZERO();

    /// @notice Emitted when a token is transferred from sender to recipient
    /// @param from The sender address
    /// @param to The recipient address
    /// @param tokenId The ERC-721 token id
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /// @notice Emitted when an owner approves an account to manage a token
    /// @param owner The owner address
    /// @param approved The account address
    /// @param tokenId The ERC-721 token id
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /// @notice Emitted when an owner sets an approval for a spender to manage all tokens
    /// @param owner The owner address
    /// @param operator The spender address
    /// @param approved If the approval is being set or removed
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /// @notice Emitted when the contract URI is updated
    /// @param uri The updated contract URI
    event ContractURIUpdated(string uri);

    /// @notice Contract-level metadata
    function contractURI() external view returns (string memory);

    /// @notice The number of tokens owned
    /// @param owner The owner address
    function balanceOf(address owner) external view returns (uint256);

    /// @notice The owner of a token
    /// @param tokenId The ERC-721 token id
    function ownerOf(uint256 tokenId) external view returns (address);

    /// @notice The account approved to manage a token
    /// @param tokenId The ERC-721 token id
    function getApproved(uint256 tokenId) external view returns (address);

    /// @notice If an operator is authorized to manage all of an owner's tokens
    /// @param owner The owner address
    /// @param operator The operator address
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /// @notice Authorizes an account to manage a token
    /// @param to The account address
    /// @param tokenId The ERC-721 token id
    function approve(address to, uint256 tokenId) external;

    /// @notice Authorizes an account to manage all tokens
    /// @param operator The account address
    /// @param approved If permission is being given or removed
    function setApprovalForAll(address operator, bool approved) external;

    /// @notice Safe transfers a token from sender to recipient with additional data
    /// @param from The sender address
    /// @param to The recipient address
    /// @param tokenId The ERC-721 token id
    /// @param data The additional data sent in the call to the recipient
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /// @notice Safe transfers a token from sender to recipient
    /// @param from The sender address
    /// @param to The recipient address
    /// @param tokenId The ERC-721 token id
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /// @notice Transfers a token from sender to recipient
    /// @param from The sender address
    /// @param to The recipient address
    /// @param tokenId The ERC-721 token id
    function transferFrom(address from, address to, uint256 tokenId) external;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { IERC721 } from './IERC721.sol';

/// @notice Common House interface
interface IHouse is IERC721 {
    /// @notice Thrown when the caller is not the prop house contract
    error ONLY_PROP_HOUSE();

    /// @notice Thrown when the caller does not hold the house ownership token
    error ONLY_HOUSE_OWNER();

    /// @notice Thrown when the provided value does not fit into 8 bits
    error VALUE_DOES_NOT_FIT_IN_8_BITS();

    /// @notice The house type
    function kind() external view returns (bytes32);

    /// @notice Initialize the house
    /// @param data Initialization data
    function initialize(bytes calldata data) external;

    /// @notice Returns `true` if the provided address is a valid round on the house
    /// @param round The round to validate
    function isRound(address round) external view returns (bool);

    /// @notice Create a new round
    /// @param impl The round implementation contract
    /// @param title The round title
    /// @param creator The round creator address
    function createRound(address impl, string calldata title, address creator) external returns (address);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { ITokenMetadataRenderer } from './ITokenMetadataRenderer.sol';

/// @notice Interface for the Manager contract
interface IManager {
    /// @notice Emitted when a house implementation is registered
    /// @param houseImpl The house implementation address
    /// @param houseType The house implementation type
    event HouseRegistered(address houseImpl, bytes32 houseType);

    /// @notice Emitted when a house implementation is unregistered
    /// @param houseImpl The house implementation address
    event HouseUnregistered(address houseImpl);

    /// @notice Emitted when a round implementation is registered on a house
    /// @param houseImpl The house implementation address
    /// @param roundImpl The round implementation address
    /// @param roundType The round implementation type
    event RoundRegistered(address houseImpl, address roundImpl, bytes32 roundType);

    /// @notice Emitted when a round implementation is unregistered on a house
    /// @param houseImpl The house implementation address
    /// @param roundImpl The round implementation address
    event RoundUnregistered(address houseImpl, address roundImpl);

    /// @notice Emitted when a metadata renderer is set for a contract
    /// @param addr The contract address
    /// @param renderer The renderer address
    event MetadataRendererSet(address addr, address renderer);

    /// @notice Emitted when the security council address is set
    /// @param securityCouncil The security council address
    event SecurityCouncilSet(address securityCouncil);

    /// @notice Determine if a house implementation is registered
    /// @param houseImpl The house implementation address
    function isHouseRegistered(address houseImpl) external view returns (bool);

    /// @notice Determine if a round implementation is registered on the provided house
    /// @param houseImpl The house implementation address
    /// @param roundImpl The round implementation address
    function isRoundRegistered(address houseImpl, address roundImpl) external view returns (bool);

    /// @notice Get the metadata renderer for a contract
    /// @param contract_ The contract address
    function getMetadataRenderer(address contract_) external view returns (ITokenMetadataRenderer);

    /// @notice Get the security council address
    function getSecurityCouncil() external view returns (address);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { Asset } from '../lib/types/Common.sol';
import { IERC721 } from './IERC721.sol';

/// @notice Interface implemented by the Prop House entry contract
interface IPropHouse is IERC721 {
    /// @notice House creation data, including the implementation contract and config
    struct House {
        address impl;
        bytes config;
    }

    /// @notice Round creation data, including the implementation contract, config, and other metadata
    struct Round {
        address impl;
        bytes config;
        string title;
        string description;
    }

    /// @notice Thrown when an insufficient amount of ether is provided to `msg.value`
    error INSUFFICIENT_ETHER_SUPPLIED();

    /// @notice Thrown when a provided house is invalid
    error INVALID_HOUSE();

    /// @notice Thrown when a provided round is invalid
    error INVALID_ROUND();

    /// @notice Thrown when a provided house implementation is invalid
    error INVALID_HOUSE_IMPL();

    /// @notice Thrown when a round implementation contract is invalid for a house
    error INVALID_ROUND_IMPL_FOR_HOUSE();

    /// @notice Thrown when a house attempts to pull tokens from a user who has not approved it
    error HOUSE_NOT_APPROVED_BY_USER();

    /// @notice Emitted when a house is created
    /// @param creator The house creator
    /// @param house The house contract address
    /// @param kind The house contract type
    event HouseCreated(address indexed creator, address indexed house, bytes32 kind);

    /// @notice Emitted when a round is created
    /// @param creator The round creator
    /// @param house The house that the round was created on
    /// @param round The round contract address
    /// @param kind The round contract type
    /// @param title The round title
    /// @param description The round description
    event RoundCreated(
        address indexed creator,
        address indexed house,
        address indexed round,
        bytes32 kind,
        string title,
        string description
    );

    /// @notice Emitted when an asset is deposited to a round
    /// @param from The user who deposited the asset
    /// @param round The round that received the asset
    /// @param asset The asset information
    event DepositToRound(address from, address round, Asset asset);

    /// @notice Emitted when one or more assets are deposited to a round
    /// @param from The user who deposited the asset(s)
    /// @param round The round that received the asset(s)
    /// @param assets The asset information
    event BatchDepositToRound(address from, address round, Asset[] assets);

    /// @notice Returns `true` if the passed `house` address is valid
    /// @param house The house address
    function isHouse(address house) external view returns (bool);

    /// @notice Returns `true` if the passed `round` address is valid on any house
    /// @param round The round address
    function isRound(address round) external view returns (bool);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { IERC165 } from './IERC165.sol';

/// @notice Interface that must be implemented by all round types
interface IRound is IERC165 {
    /// @notice Thrown when the caller of a guarded function is not the prop house contract
    error ONLY_PROP_HOUSE();

    /// @notice Thrown when the caller of a guarded function is not the round manager
    error ONLY_ROUND_MANAGER();

    /// @notice Thrown when the address of a provided strategy is zero
    /// @param strategy The address of the strategy
    error INVALID_STRATEGY(uint256 strategy);

    /// @notice The round type
    function kind() external view returns (bytes32);

    /// @notice Get the round title
    function title() external pure returns (string memory);

    /// @notice Initialize the round
    /// @param data The optional round data. If empty, round registration is deferred.
    function initialize(bytes calldata data) external payable;

    /// @notice The house that the round belongs to
    function house() external view returns (address);

    /// @notice The round ID
    function id() external view returns (uint256);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

interface ITokenMetadataRenderer {
    /// @notice Returns metadata for `tokenId` as a Base64-JSON blob
    /// @param tokenId The token ID
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { IERC721 } from '../../interfaces/IERC721.sol';
import { ERC721TokenReceiver } from '../utils/TokenReceiver.sol';
import { ImmutableStrings } from '../utils/ImmutableStrings.sol';
import { Address } from '../utils/Address.sol';

/// @title ERC721
/// @notice Modified from Rohan Kulkarni's work for Nouns Builder
/// Originally modified from OpenZeppelin Contracts v4.7.3 (token/ERC721/ERC721Upgradeable.sol)
/// - Uses custom errors declared in IERC721
/// - Includes contract-level metadata via `contractURI`
/// - Uses immutable name and symbol via `ImmutableStrings`
abstract contract ERC721 is IERC721 {
    using ImmutableStrings for string;
    using ImmutableStrings for ImmutableStrings.ImmutableString;

    /// @notice The token name
    ImmutableStrings.ImmutableString internal immutable _name;

    /// @notice The token symbol
    ImmutableStrings.ImmutableString internal immutable _symbol;

    /// @notice Contract-level metadata
    string public contractURI;

    /// @notice The token owners
    /// @dev ERC-721 token id => Owner
    mapping(uint256 => address) internal owners;

    /// @notice The owner balances
    /// @dev Owner => Balance
    mapping(address => uint256) internal balances;

    /// @notice The token approvals
    /// @dev ERC-721 token id => Manager
    mapping(uint256 => address) internal tokenApprovals;

    /// @notice The balance approvals
    /// @dev Owner => Operator => Approved
    mapping(address => mapping(address => bool)) internal operatorApprovals;

    /// @param name_ The token name
    /// @param symbol_ The token symbol
    constructor(string memory name_, string memory symbol_) {
        _name = name_.toImmutableString();
        _symbol = symbol_.toImmutableString();
    }

    /// @notice The token URI
    /// @param tokenId The ERC-721 token id
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {}

    /// @notice The token name
    function name() public view virtual returns (string memory) {
        return _name.toString();
    }

    /// @notice The token symbol
    function symbol() public view virtual returns (string memory) {
        return _symbol.toString();
    }

    /// @notice If the contract implements an interface
    /// @param interfaceId The interface id
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID
            interfaceId == 0x80ac58cd || // ERC721 Interface ID
            interfaceId == 0x5b5e139f; // ERC721Metadata Interface ID
    }

    /// @notice The account approved to manage a token
    /// @param tokenId The ERC-721 token id
    function getApproved(uint256 tokenId) external view returns (address) {
        return tokenApprovals[tokenId];
    }

    /// @notice If an operator is authorized to manage all of an owner's tokens
    /// @param owner The owner address
    /// @param operator The operator address
    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return operatorApprovals[owner][operator];
    }

    /// @notice The number of tokens owned
    /// @param owner The owner address
    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert ADDRESS_ZERO();

        return balances[owner];
    }

    /// @notice Returns whether `tokenId` exists.
    /// @param tokenId The ERC-721 token id
    function exists(uint256 tokenId) public view returns (bool) {
        return owners[tokenId] != address(0);
    }

    /// @notice The owner of a token
    /// @param tokenId The ERC-721 token id
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = owners[tokenId];

        if (owner == address(0)) revert INVALID_OWNER();

        return owner;
    }

    /// @notice Authorizes an account to manage a token
    /// @param to The account address
    /// @param tokenId The ERC-721 token id
    function approve(address to, uint256 tokenId) external {
        address owner = owners[tokenId];

        if (msg.sender != owner && !operatorApprovals[owner][msg.sender]) revert INVALID_APPROVAL();

        tokenApprovals[tokenId] = to;

        emit Approval(owner, to, tokenId);
    }

    /// @notice Authorizes an account to manage all tokens
    /// @param operator The account address
    /// @param approved If permission is being given or removed
    function setApprovalForAll(address operator, bool approved) external {
        operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Transfers a token from sender to recipient
    /// @param from The sender address
    /// @param to The recipient address
    /// @param tokenId The ERC-721 token id
    function transferFrom(address from, address to, uint256 tokenId) public {
        if (from != owners[tokenId]) revert INVALID_OWNER();

        if (to == address(0)) revert ADDRESS_ZERO();

        if (msg.sender != from && !operatorApprovals[from][msg.sender] && msg.sender != tokenApprovals[tokenId])
            revert INVALID_APPROVAL();

        _beforeTokenTransfer(from, to, tokenId);

        unchecked {
            --balances[from];

            ++balances[to];
        }

        owners[tokenId] = to;

        delete tokenApprovals[tokenId];

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /// @notice Safe transfers a token from sender to recipient
    /// @param from The sender address
    /// @param to The recipient address
    /// @param tokenId The ERC-721 token id
    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        transferFrom(from, to, tokenId);

        if (
            Address.isContract(to) &&
            ERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, '') !=
            ERC721TokenReceiver.onERC721Received.selector
        ) revert INVALID_RECIPIENT();
    }

    /// @notice Safe transfers a token from sender to recipient with additional data
    /// @param from The sender address
    /// @param to The recipient address
    /// @param tokenId The ERC-721 token id
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external {
        transferFrom(from, to, tokenId);

        if (
            Address.isContract(to) &&
            ERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, data) !=
            ERC721TokenReceiver.onERC721Received.selector
        ) revert INVALID_RECIPIENT();
    }

    /// @dev Updates the contract URI
    /// @param _contractURI The new contract URI
    function _setContractURI(string memory _contractURI) internal {
        contractURI = _contractURI;

        emit ContractURIUpdated(_contractURI);
    }

    /// @dev Mints a token to a recipient
    /// @param to The recipient address
    /// @param tokenId The ERC-721 token id
    function _mint(address to, uint256 tokenId) internal virtual {
        if (to == address(0)) revert ADDRESS_ZERO();

        if (owners[tokenId] != address(0)) revert ALREADY_MINTED();

        _beforeTokenTransfer(address(0), to, tokenId);

        unchecked {
            ++balances[to];
        }

        owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /// @dev Burns a token to a recipient
    /// @param tokenId The ERC-721 token id
    function _burn(uint256 tokenId) internal virtual {
        address owner = owners[tokenId];

        if (owner == address(0)) revert NOT_MINTED();

        _beforeTokenTransfer(owner, address(0), tokenId);

        unchecked {
            --balances[owner];
        }

        delete owners[tokenId];

        delete tokenApprovals[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /// @dev Hook called before a token transfer
    /// @param from The sender address
    /// @param to The recipient address
    /// @param tokenId The ERC-721 token id
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}

    /// @dev Hook called after a token transfer
    /// @param from The sender address
    /// @param to The recipient address
    /// @param tokenId The ERC-721 token id
    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

/// @notice Supported asset types
enum AssetType {
    Native,
    ERC20,
    ERC721,
    ERC1155
}

/// @notice Common struct for all supported asset types
struct Asset {
    AssetType assetType;
    address token;
    uint256 identifier;
    uint256 amount;
}

/// @notice Packed asset information, which consists of an asset ID and amount
struct PackedAsset {
    uint256 assetId;
    uint256 amount;
}

/// @notice Merkle proof information for an incremental tree
struct IncrementalTreeProof {
    bytes32[] siblings;
    uint8[] pathIndices;
}

/// @notice A meta-transaction relayer address and deposit amount
struct MetaTransaction {
    address relayer;
    uint256 deposit;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

/// @title Address
/// @notice Modified from Rohan Kulkarni's work for Nouns Builder
/// Originally modified from OpenZeppelin Contracts v4.7.3 (utils/Address.sol)
/// - Uses custom errors
/// - Adds util converting address to bytes32
library Address {
    /// @dev Thrown when the target of a delegatecall is not a contract
    error INVALID_TARGET();

    /// @dev Thrown when a delegatecall has failed
    error DELEGATE_CALL_FAILED();

    /// @dev If an address is a contract
    function isContract(address _account) internal view returns (bool rv) {
        assembly {
            rv := gt(extcodesize(_account), 0)
        }
    }

    /// @dev Performs a delegatecall on an address
    function functionDelegateCall(address _target, bytes memory _data) internal returns (bytes memory) {
        if (!isContract(_target)) revert INVALID_TARGET();

        (bool success, bytes memory returndata) = _target.delegatecall(_data);

        return verifyCallResult(success, returndata);
    }

    /// @dev Verifies a delegatecall was successful
    function verifyCallResult(bool _success, bytes memory _returndata) internal pure returns (bytes memory) {
        if (_success) {
            return _returndata;
        } else {
            if (_returndata.length > 0) {
                assembly {
                    let returndata_size := mload(_returndata)

                    revert(add(32, _returndata), returndata_size)
                }
            } else {
                revert DELEGATE_CALL_FAILED();
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import { IERC1155 } from '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import { SafeERC20 } from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import { AssetType, Asset } from '../types/Common.sol';

abstract contract AssetController {
    using SafeERC20 for IERC20;

    /// @notice Thrown when unused asset parameters are populated
    error UNUSED_ASSET_PARAMETERS();

    /// @notice Thrown when an ether transfer does not succeed
    error ETHER_TRANSFER_FAILED();

    /// @notice Thrown when the ERC721 transfer amount is not equal to one
    error INVALID_ERC721_TRANSFER_AMOUNT();

    /// @notice Thrown when an unknown asset type is provided
    error INVALID_ASSET_TYPE();

    /// @notice Thrown when no asset amount is provided
    error MISSING_ASSET_AMOUNT();

    /// @dev Returns the balance of `asset` for `account`
    /// @param asset The asset to fetch the balance of
    /// @param account The account to fetch the balance for
    function _balanceOf(Asset memory asset, address account) internal view returns (uint256) {
        if (asset.assetType == AssetType.Native) {
            return account.balance;
        }
        if (asset.assetType == AssetType.ERC20) {
            return IERC20(asset.token).balanceOf(account);
        }
        if (asset.assetType == AssetType.ERC721) {
            return IERC721(asset.token).ownerOf(asset.identifier) == account ? 1 : 0;
        }
        if (asset.assetType == AssetType.ERC1155) {
            return IERC1155(asset.token).balanceOf(account, asset.identifier);
        }
        revert INVALID_ASSET_TYPE();
    }

    /// @dev Transfer a given asset from the provided `from` address to the `to` address
    /// @param asset The asset to transfer, including the asset amount
    /// @param source The account supplying the asset
    /// @param recipient The asset recipient
    function _transfer(Asset memory asset, address source, address payable recipient) internal {
        if (asset.assetType == AssetType.Native) {
            // Ensure neither the token nor the identifier parameters are set
            if ((uint160(asset.token) | asset.identifier) != 0) {
                revert UNUSED_ASSET_PARAMETERS();
            }

            _transferETH(recipient, asset.amount);
        } else if (asset.assetType == AssetType.ERC20) {
            // Ensure that no identifier is supplied
            if (asset.identifier != 0) {
                revert UNUSED_ASSET_PARAMETERS();
            }

            _transferERC20(asset.token, source, recipient, asset.amount);
        } else if (asset.assetType == AssetType.ERC721) {
            _transferERC721(asset.token, asset.identifier, source, recipient, asset.amount);
        } else if (asset.assetType == AssetType.ERC1155) {
            _transferERC1155(asset.token, asset.identifier, source, recipient, asset.amount);
        } else {
            revert INVALID_ASSET_TYPE();
        }
    }

    /// @notice Transfers one or more assets from the provided `from` address to the `to` address
    /// @param assets The assets to transfer, including the asset amounts
    /// @param source The account supplying the assets
    /// @param recipient The asset recipient
    function _transferMany(Asset[] memory assets, address source, address payable recipient) internal {
        uint256 assetCount = assets.length;
        for (uint256 i = 0; i < assetCount; ) {
            _transfer(assets[i], source, recipient);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Transfers ETH to a recipient address
    /// @param recipient The transfer recipient
    /// @param amount The amount of ETH to transfer
    function _transferETH(address payable recipient, uint256 amount) internal {
        _assertNonZeroAmount(amount);

        bool success;
        assembly {
            success := call(10000, recipient, amount, 0, 0, 0, 0)
        }
        if (!success) {
            revert ETHER_TRANSFER_FAILED();
        }
    }

    /// @notice Transfers ERC20 tokens from a provided account to a recipient address
    /// @param token The token to transfer
    /// @param source The transfer source
    /// @param recipient The transfer recipient
    /// @param amount The amount to transfer
    function _transferERC20(address token, address source, address recipient, uint256 amount) internal {
        _assertNonZeroAmount(amount);

        // Use `transfer` if the source is this contract
        if (source == address(this)) {
            IERC20(token).safeTransfer(recipient, amount);
        } else {
            IERC20(token).safeTransferFrom(source, recipient, amount);
        }
    }

    /// @notice Transfers an ERC721 token to a recipient address
    /// @param token The token to transfer
    /// @param identifier The ID of the token to transfer
    /// @param source The transfer source
    /// @param recipient The transfer recipient
    /// @param amount The token amount (Must be 1)
    function _transferERC721(
        address token,
        uint256 identifier,
        address source,
        address recipient,
        uint256 amount
    ) internal {
        if (amount != 1) {
            revert INVALID_ERC721_TRANSFER_AMOUNT();
        }
        IERC721(token).transferFrom(source, recipient, identifier);
    }

    /// @notice Transfers ERC1155 tokens to a recipient address
    /// @param token The token to transfer
    /// @param identifier The ID of the token to transfer
    /// @param source The transfer source
    /// @param recipient The transfer recipient
    /// @param amount The amount to transfer
    function _transferERC1155(
        address token,
        uint256 identifier,
        address source,
        address recipient,
        uint256 amount
    ) internal {
        _assertNonZeroAmount(amount);

        IERC1155(token).safeTransferFrom(source, recipient, identifier, amount, new bytes(0));
    }

    /// @dev Ensure that a given asset amount is not zero
    /// @param amount The amount to check
    function _assertNonZeroAmount(uint256 amount) internal pure {
        // Revert if the supplied amount is equal to zero
        if (amount == 0) {
            revert MISSING_ASSET_AMOUNT();
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { Asset, AssetType, PackedAsset } from '../types/Common.sol';

library AssetHelper {
    /// @notice Returns the packed asset information for a single asset
    /// @param asset The asset information
    function pack(Asset memory asset) internal pure returns (PackedAsset memory packed) {
        unchecked {
            packed = PackedAsset({ assetId: toID(asset), amount: asset.amount });
        }
    }

    /// @notice Returns the packed asset information for the provided assets
    /// @param assets The asset information
    function packMany(Asset[] memory assets) internal pure returns (PackedAsset[] memory packed) {
        unchecked {
            uint256 assetCount = assets.length;
            packed = new PackedAsset[](assetCount);

            for (uint256 i = 0; i < assetCount; ++i) {
                packed[i] = pack(assets[i]);
            }
        }
    }

    /// @notice Calculates the asset IDs for the provided assets
    /// @param assets The asset information
    function toIDs(Asset[] memory assets) internal pure returns (uint256[] memory ids) {
        unchecked {
            uint256 assetCount = assets.length;
            ids = new uint256[](assetCount);

            for (uint256 i = 0; i < assetCount; ++i) {
                ids[i] = toID(assets[i]);
            }
        }
    }

    /// @dev Calculates the asset ID for the provided asset
    /// @param asset The asset information
    function toID(Asset memory asset) internal pure returns (uint256) {
        if (asset.assetType == AssetType.Native) {
            return uint256(asset.assetType);
        }
        if (asset.assetType == AssetType.ERC20) {
            return uint256(bytes32(abi.encodePacked(asset.assetType, asset.token)));
        }
        // prettier-ignore
        return uint256(
            bytes32(abi.encodePacked(asset.assetType, keccak256(abi.encodePacked(asset.token, asset.identifier))))
        );
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

library ImmutableStrings {
    type ImmutableString is uint256;

    /// @notice Thrown when the input length is greater than or equal to 32
    error LENGTH_GTE_32();

    /// @dev Converts a standard string to an immutable string
    /// @param input The standard string
    function toImmutableString(string memory input) internal pure returns (ImmutableString) {
        if (bytes(input).length >= 32) {
            revert LENGTH_GTE_32();
        }
        return ImmutableString.wrap(uint256(bytes32(bytes(input)) | bytes32(bytes(input).length)));
    }

    /// @dev Converts an immutable string to a standard string
    /// @param input The immutable string
    function toString(ImmutableString input) internal pure returns (string memory) {
        uint256 unwrapped = ImmutableString.unwrap(input);
        uint256 len = unwrapped & 255;
        uint256 readNoLength = (unwrapped >> 8) << 8;
        string memory res = string(abi.encode(readNoLength));
        assembly {
            mstore(res, len) // "res" points to the length, not the offset.
        }
        return res;
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { IERC165 } from '../../interfaces/IERC165.sol';

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
abstract contract ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata) external virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

/// @notice A generic interface for a contract which properly accepts ERC1155 tokens.
abstract contract ERC1155TokenReceiver is IERC165 {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external view virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external view virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import { MAX_250_BIT_UNSIGNED } from '../../Constants.sol';

library Uint256 {
    /// @notice Split a uint256 into a high and low value
    /// @param value The uint256 value to split
    /// @dev This is useful for passing uint256 values to Starknet, whose felt
    /// type only supports 251 bits.
    function split(uint256 value) internal pure returns (uint256, uint256) {
        uint256 low = value & ((1 << 128) - 1);
        uint256 high = value >> 128;
        return (low, high);
    }

    /// Mask the passed `value` to 250 bits
    /// @param value The value to mask
    function mask250(bytes32 value) internal pure returns (uint256) {
        return uint256(value) & MAX_250_BIT_UNSIGNED;
    }

    /// @notice Convert an address to a uint256
    /// @param addr The address to convert
    function toUint256(address addr) internal pure returns (uint256) {
        return uint256(uint160(addr));
    }
}