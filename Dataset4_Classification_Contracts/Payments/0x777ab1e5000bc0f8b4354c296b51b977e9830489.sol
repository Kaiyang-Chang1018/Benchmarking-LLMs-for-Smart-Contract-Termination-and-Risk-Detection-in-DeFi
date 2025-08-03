// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Client} from "../libraries/Client.sol";

/// @notice Application contracts that intend to receive messages from
/// the router should implement this interface.
interface IAny2EVMMessageReceiver {
  /// @notice Called by the Router to deliver a message.
  /// If this reverts, any token transfers also revert. The message
  /// will move to a FAILED state and become available for manual execution.
  /// @param message CCIP Message
  /// @dev Note ensure you check the msg.sender is the OffRampRouter
  function ccipReceive(Client.Any2EVMMessage calldata message) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Client} from "../libraries/Client.sol";

interface IRouterClient {
  error UnsupportedDestinationChain(uint64 destChainSelector);
  error InsufficientFeeTokenAmount();
  error InvalidMsgValue();

  /// @notice Checks if the given chain ID is supported for sending/receiving.
  /// @param chainSelector The chain to check.
  /// @return supported is true if it is supported, false if not.
  function isChainSupported(uint64 chainSelector) external view returns (bool supported);

  /// @notice Gets a list of all supported tokens which can be sent or received
  /// to/from a given chain id.
  /// @param chainSelector The chainSelector.
  /// @return tokens The addresses of all tokens that are supported.
  function getSupportedTokens(uint64 chainSelector) external view returns (address[] memory tokens);

  /// @param destinationChainSelector The destination chainSelector
  /// @param message The cross-chain CCIP message including data and/or tokens
  /// @return fee returns execution fee for the message
  /// delivery to destination chain, denominated in the feeToken specified in the message.
  /// @dev Reverts with appropriate reason upon invalid message.
  function getFee(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage memory message
  ) external view returns (uint256 fee);

  /// @notice Request a message to be sent to the destination chain
  /// @param destinationChainSelector The destination chain ID
  /// @param message The cross-chain CCIP message including data and/or tokens
  /// @return messageId The message ID
  /// @dev Note if msg.value is larger than the required fee (from getFee) we accept
  /// the overpayment with no refund.
  /// @dev Reverts with appropriate reason upon invalid message.
  function ccipSend(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage calldata message
  ) external payable returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// End consumer library.
library Client {
  /// @dev RMN depends on this struct, if changing, please notify the RMN maintainers.
  struct EVMTokenAmount {
    address token; // token address on the local chain.
    uint256 amount; // Amount of tokens.
  }

  struct Any2EVMMessage {
    bytes32 messageId; // MessageId corresponding to ccipSend on source.
    uint64 sourceChainSelector; // Source chain selector.
    bytes sender; // abi.decode(sender) if coming from an EVM chain.
    bytes data; // payload sent in original message.
    EVMTokenAmount[] destTokenAmounts; // Tokens and their amounts in their destination chain representation.
  }

  // If extraArgs is empty bytes, the default is 200k gas limit.
  struct EVM2AnyMessage {
    bytes receiver; // abi.encode(receiver address) for dest EVM chains
    bytes data; // Data payload
    EVMTokenAmount[] tokenAmounts; // Token transfers
    address feeToken; // Address of feeToken. address(0) means you will send msg.value.
    bytes extraArgs; // Populate this with _argsToBytes(EVMExtraArgsV1)
  }

  // bytes4(keccak256("CCIP EVMExtraArgsV1"));
  bytes4 public constant EVM_EXTRA_ARGS_V1_TAG = 0x97a657c9;
  struct EVMExtraArgsV1 {
    uint256 gasLimit;
  }

  function _argsToBytes(EVMExtraArgsV1 memory extraArgs) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EVM_EXTRA_ARGS_V1_TAG, extraArgs);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;


contract BaseCCIPContract {
    error InvalidRouter(address router);
    error UnauthorizedCCIPSender();

    address internal immutable CCIP_ROUTER;

    /// @dev Linked CCIP contracts
    /// The mapping key is a packed bytes32 with the following bit mapping
    /// [0..159]    address sourceContract
    /// [160..223]  uint64  sourceChainSelector
    mapping(bytes32 => bool) internal _ccipContracts;

    constructor(address router) {
        CCIP_ROUTER = router;
    }

    /// @notice Return the current router
    /// @return Current CCIP Router address
    function getCCIPRouter() external view returns (address) {
        return CCIP_ROUTER;
    }

    /// @notice Manage approved counterpart CCIP contracts
    /// @param contractAddress Address of counterpart contract on the remote chain
    /// @param chainSelector CCIP Chain selector of the remote chain
    /// @param enabled Boolean representing whether this counterpart should be allowed or denied
    function _setCCIPCounterpart(
        address contractAddress,
        uint64 chainSelector,
        bool enabled
    ) internal {
        bytes32 counterpart = _packCCIPContract(contractAddress, chainSelector);
        _ccipContracts[counterpart] = enabled;
    }

    function _packCCIPContract(address contractAddress, uint64 chainSelector) internal pure returns(bytes32) {
        return bytes32(
            uint256(uint160(contractAddress)) |
            uint256(chainSelector) << 160
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IAny2EVMMessageReceiver.sol";
import "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./BaseCCIPContract.sol";

/// @title CCIPReceiver - Base contract for CCIP applications that can receive messages.
abstract contract BaseCCIPReceiver is BaseCCIPContract, IAny2EVMMessageReceiver, IERC165 {

  /// @dev only calls from the set router are accepted.
  modifier onlyRouter() {
    if (msg.sender != CCIP_ROUTER) revert InvalidRouter(msg.sender);
    _;
  }

  /// @notice IERC165 supports an interfaceId
  /// @param interfaceId The interfaceId to check
  /// @return true if the interfaceId is supported
  /// @dev Should indicate whether the contract implements IAny2EVMMessageReceiver
  /// e.g. return interfaceId == type(IAny2EVMMessageReceiver).interfaceId || interfaceId == type(IERC165).interfaceId
  /// This allows CCIP to check if ccipReceive is available before calling it.
  /// If this returns false or reverts, only tokens are transferred to the receiver.
  /// If this returns true, tokens are transferred and ccipReceive is called atomically.
  /// Additionally, if the receiver address does not have code associated with
  /// it at the time of execution (EXTCODESIZE returns 0), only tokens will be transferred.
  function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool) {
    return interfaceId == type(IAny2EVMMessageReceiver).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  /// @inheritdoc IAny2EVMMessageReceiver
  function ccipReceive(Client.Any2EVMMessage calldata message) external virtual override onlyRouter {
    _ccipReceive(message);
  }

  /// @notice Override this function in your implementation.
  /// @param message Any2EVMMessage
  function _ccipReceive(Client.Any2EVMMessage memory message) internal virtual;

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

import "./BaseCCIPContract.sol";
import "./BaseLinkConsumer.sol";

abstract contract BaseCCIPSender is BaseCCIPContract, BaseLinkConsumer {
    error MissingCCIPParams();
    error InsufficientLinkBalance(uint256 balance, uint256 required);

    /// @dev extraArgs for ccip message
    bytes private _ccipExtraArgs;

    function _sendCCIPMessage(
        bytes32 packedCcipCounterpart,
        bytes memory data
    ) internal returns(bytes32) {
        address ccipDestAddress = address(uint160(uint256(packedCcipCounterpart)));
        uint64 chainSelector = uint64(uint256(packedCcipCounterpart) >> 160);
        return _sendCCIPMessage(ccipDestAddress, chainSelector, data);
    }

    function _sendCCIPMessage(
        address ccipDestAddress,
        uint64 ccipDestChainSelector,
        bytes memory data
    ) internal returns(bytes32 messageId) {
        if (ccipDestAddress == address(0) || ccipDestChainSelector == uint64(0)) {
            revert MissingCCIPParams();
        }

        // Send CCIP message to the desitnation contract
        IRouterClient router = IRouterClient(CCIP_ROUTER);
        LinkTokenInterface linkToken = LinkTokenInterface(LINK_TOKEN);

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(ccipDestAddress),
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: _ccipExtraArgs,
            feeToken: LINK_TOKEN
        });

        uint256 fee = router.getFee(
            ccipDestChainSelector,
            message
        );
        uint256 currentLinkBalance = linkToken.balanceOf(address(this));

        if (fee > currentLinkBalance) {
            revert InsufficientLinkBalance(currentLinkBalance, fee);
        }

        messageId = router.ccipSend(
            ccipDestChainSelector,
            message
        );
    }

    function _setCCIPExtraArgs(bytes calldata extraArgs) internal {
        _ccipExtraArgs = extraArgs;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;
import "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

abstract contract BaseLinkConsumer {
  address internal immutable LINK_TOKEN;

  error LinkApprovalFailed();

  constructor(address token, address approvedSpender) {
    bool approved = LinkTokenInterface(token).approve(approvedSpender, type(uint256).max);
    if (!approved) {
      revert LinkApprovalFailed();
    }
    LINK_TOKEN = token;
  }

  /// @notice Return the LINK Token address
  /// @return Address of the LINK token
  function getLinkToken() external view returns (address) {
    return LINK_TOKEN;
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "./libraries/Bits.sol";

contract Roles {
    using Bits for bytes32;

    error MissingRole(address user, uint256 role);
    event RoleUpdated(address indexed user, uint256 indexed role, bool indexed status);

    /**
     * @dev There is a maximum of 256 roles: each bit says if the role is on or off
     */
    mapping(address => bytes32) private _addressRoles;

    modifier onlyRole(uint8 role) {
        _checkRole(msg.sender, role);
        _;
    }

    constructor() {
        _setRole(msg.sender, 0, true);
    }

    function _hasRole(address user, uint8 role) internal view returns(bool) {
        return _addressRoles[user].getBool(role);
    }

    function _checkRole(address user, uint8 role) internal virtual view {
        if (!_hasRole(user, role)) {
            revert MissingRole(user, role);
        }
    }

    function _setRole(address user, uint8 role, bool status) internal virtual {
        _addressRoles[user] = _addressRoles[user].setBool(role, status);
        emit RoleUpdated(user, role, status);
    }

    function setRole(address user, uint8 role, bool status) external virtual onlyRole(0) {
        _setRole(user, role, status);
    }

    function getRoles(address user) external view returns(bytes32) {
        return _addressRoles[user];
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./Roles.sol";
import "./BaseCCIPSender.sol";
import "./BaseCCIPReceiver.sol";
import "./interfaces/IWinnablesPrizeManager.sol";

contract WinnablesPrizeManager is Roles, BaseCCIPSender, BaseCCIPReceiver, IWinnablesPrizeManager, IERC721Receiver {
    using SafeERC20 for IERC20;

    /// @dev Mapping from raffleId to raffleType
    mapping(uint256 => RafflePrize) private _rafflePrize;

    /// @dev Mapping from raffle ID to struct NFTInfo (only set when an NFT is locked in for a raffle)
    mapping(uint256 => NFTInfo) private _nftRaffles;

    /// @dev Mapping from raffle ID to prize amount (only set when ETH is locked in for a raffle)
    mapping(uint256 => uint256) private _ethRaffles;

    /// @dev Mapping from raffle ID to struct TokenInfo (only set for Tokens are locked in for a raffle)
    mapping(uint256 => TokenInfo) private _tokenRaffles;

    /// @dev Amount of ETH currently locked in an ETH Raffle
    uint256 private _ethLocked;

    /// @dev Mapping from token address to amount of tokens currently locked in a Token Raffle
    mapping(address => uint256) private _tokensLocked;

    /// @dev Mapping from NFT address to a mapping from tokenId to boolean
    ///      (true if locked in an NFT Raffle)
    mapping(address => mapping(uint256 => bool)) private _nftLocked;

    /// @dev Contract constructor
    /// @param _linkToken Address of the LINK ERC20 token on the chain you are deploying to
    /// @param _ccipRouter Address of the Chainlink RouterClient contract on the chain you are deploying to
    constructor(
        address _linkToken,
        address _ccipRouter
    ) BaseCCIPContract(_ccipRouter) BaseLinkConsumer(_linkToken, _ccipRouter) {}

    // =============================================================
    // -- Public functions
    // =============================================================

    /// @notice (Public) Get general information about a raffle prize
    ///         (type, status, winner)
    /// @param id ID of the Raffle
    /// @return Information about the raffle prize
    function getRaffle(uint256 id) external view returns(RafflePrize memory) {
        return _rafflePrize[id];
    }

    /// @notice (Public) Get information about the prize of an NFT raffle
    /// @param id ID of the Raffle
    /// @return Information about the prize of an NFT raffle
    function getNFTRaffle(uint256 id) external view returns(NFTInfo memory) {
        RaffleType raffleType = _rafflePrize[id].raffleType;
        if (raffleType != RaffleType.NFT) {
            revert InvalidRaffle();
        }
        return _nftRaffles[id];
    }

    /// @notice (Public) Get the prize amount of an ETH raffle
    /// @param id ID of the Raffle
    /// @return Prize amount of an ETH raffle
    function getETHRaffle(uint256 id) external view returns(uint256) {
        RaffleType raffleType = _rafflePrize[id].raffleType;
        if (raffleType != RaffleType.ETH) {
            revert InvalidRaffle();
        }
        return _ethRaffles[id];
    }

    /// @notice (Public) Get information about the prize of a Token raffle
    /// @param id ID of the Raffle
    /// @return Information about the prize of a Token raffle
    function getTokenRaffle(uint256 id) external view returns(TokenInfo memory) {
        RaffleType raffleType = _rafflePrize[id].raffleType;
        if (raffleType != RaffleType.TOKEN) {
            revert InvalidRaffle();
        }
        return _tokenRaffles[id];
    }

    /// @notice (Public) Get the winner of a raffle by ID
    /// @param id ID of the Raffle
    /// @return Address of the winner if any, or address(0) otherwise
    function getWinner(uint256 id) external view returns(address) {
        return _rafflePrize[id].winner;
    }

    /// @notice (Public) Send the prize for a Raffle to its rightful winner
    /// @param raffleId ID of the raffle
    function claimPrize(uint256 raffleId) external {
        RafflePrize storage rafflePrize = _rafflePrize[raffleId];
        RaffleType raffleType = rafflePrize.raffleType;
        if (raffleType == RaffleType.NFT) {
            NFTInfo storage raffle = _nftRaffles[raffleId];
            _nftLocked[raffle.contractAddress][raffle.tokenId] = false;
            _sendNFTPrize(raffle.contractAddress, raffle.tokenId, msg.sender);
        } else if (raffleType == RaffleType.TOKEN) {
            TokenInfo storage raffle = _tokenRaffles[raffleId];
            unchecked { _tokensLocked[raffle.tokenAddress] -= raffle.amount; }
            _sendTokenPrize(raffle.tokenAddress, raffle.amount, msg.sender);
        } else if (raffleType == RaffleType.ETH) {
            unchecked { _ethLocked -= _ethRaffles[raffleId]; }
            _sendETHPrize(_ethRaffles[raffleId], msg.sender);
        } else {
            revert InvalidRaffle();
        }
        if (msg.sender != rafflePrize.winner) {
            revert UnauthorizedToClaim();
        }
        if (rafflePrize.status == RafflePrizeStatus.CLAIMED) {
            revert AlreadyClaimed();
        }
        rafflePrize.status = RafflePrizeStatus.CLAIMED;
        emit PrizeClaimed(raffleId, msg.sender);
    }

    // =============================================================
    // -- Admin functions
    // =============================================================

    /// @notice (Admin) Send the prize for a Raffle to its rightful winner
    /// @param ticketManager Address of the Ticket Manager on the remote chain
    /// @param chainSelector CCIP Chain selector of the remote chain
    /// @param raffleId ID of the Raffle that will be associated
    /// @param nft NFT contract address
    /// @param tokenId NFT token id
    function lockNFT(
        address ticketManager,
        uint64 chainSelector,
        uint256 raffleId,
        address nft,
        uint256 tokenId
    ) external onlyRole(0) {
        RafflePrize storage rafflePrize = _checkValidRaffle(raffleId);
        rafflePrize.ccipCounterpart = _packCCIPContract(ticketManager, chainSelector);
        if (IERC721(nft).ownerOf(tokenId) != address(this)) {
            revert InvalidPrize();
        }
        if (_nftLocked[nft][tokenId]) {
            revert InvalidPrize();
        }
        rafflePrize.raffleType = RaffleType.NFT;
        _nftLocked[nft][tokenId] = true;
        _nftRaffles[raffleId].contractAddress = nft;
        _nftRaffles[raffleId].tokenId = tokenId;

        _sendCCIPMessage(ticketManager, chainSelector, abi.encodePacked(raffleId));
        emit NFTPrizeLocked(raffleId, nft, tokenId);
    }

    /// @notice (Admin) Send the prize for a Raffle to its rightful winner
    /// @param ticketManager Address of the Ticket Manager on the remote chain
    /// @param chainSelector CCIP Chain selector of the remote chain
    /// @param raffleId ID of the Raffle that will be associated
    /// @param amount Amount of ETH to lock as a prize
    function lockETH(
        address ticketManager,
        uint64 chainSelector,
        uint256 raffleId,
        uint256 amount
    ) external payable onlyRole(0) {
        RafflePrize storage rafflePrize = _checkValidRaffle(raffleId);
        rafflePrize.ccipCounterpart = _packCCIPContract(ticketManager, chainSelector);
        uint256 ethBalance = address(this).balance;

        if (ethBalance < amount + _ethLocked) {
            revert InvalidPrize();
        }
        rafflePrize.raffleType = RaffleType.ETH;
        _ethLocked += amount;
        _ethRaffles[raffleId] = amount;

        _sendCCIPMessage(ticketManager, chainSelector, abi.encodePacked(raffleId));
        emit ETHPrizeLocked(raffleId, amount);
    }

    /// @notice (Admin) Send the prize for a Raffle to its rightful winner
    /// @param ticketManager Address of the Ticket Manager on the remote chain
    /// @param chainSelector CCIP Chain selector of the remote chain
    /// @param raffleId ID of the Raffle that will be associated
    /// @param token Token contract address
    /// @param amount Amount of tokens to lock as a prize
    function lockTokens(
        address ticketManager,
        uint64 chainSelector,
        uint256 raffleId,
        address token,
        uint256 amount
    ) external onlyRole(0) {
        if (token == LINK_TOKEN) {
            revert LINKTokenNotPermitted();
        }

        RafflePrize storage rafflePrize = _checkValidRaffle(raffleId);
        rafflePrize.ccipCounterpart = _packCCIPContract(ticketManager, chainSelector);
        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        if (tokenBalance < amount + _tokensLocked[token]) {
            revert InvalidPrize();
        }
        rafflePrize.raffleType = RaffleType.TOKEN;
        unchecked { _tokensLocked[token] += amount; }
        _tokenRaffles[raffleId].tokenAddress = token;
        _tokenRaffles[raffleId].amount = amount;

        _sendCCIPMessage(ticketManager, chainSelector, abi.encodePacked(raffleId));
        emit TokenPrizeLocked(raffleId, token, amount);
    }

    /// @notice (Admin) Use this to withdraw any ERC20 from the contract that
    ///         is not locked in a raffle, or withdraw LINK
    /// @param token ERC20 address
    function withdrawToken(address token, uint256 amount) external onlyRole(0) {
        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        uint256 availableBalance;
        unchecked { availableBalance = tokenBalance - _tokensLocked[token]; }
        if (availableBalance < amount) {
            revert InsufficientBalance();
        }
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    /// @notice (Admin) Use this to withdraw any NFT from the contract that is
    ///         not locked in a raffle
    /// @param nft Address of the NFT contract
    /// @param tokenId ID of the NFT
    function withdrawNFT(address nft, uint256 tokenId) external onlyRole(0) {
        if (_nftLocked[nft][tokenId]) {
            revert NFTLocked();
        }

        try IERC721(nft).ownerOf(tokenId) returns (address) {} catch {
            revert NotAnNFT();
        }
        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);
    }

    /// @notice (Admin) Use this to withdraw ETH from the contract that is not
    ///         locked in a raffle
    /// @param amount Amount of ETH to withdraw
    function withdrawETH(uint256 amount) external onlyRole(0) {
        uint256 balance = address(this).balance;
        uint256 availableBalance;
        unchecked { availableBalance = balance - _ethLocked; }
        if (availableBalance < amount) {
            revert InsufficientBalance();
        }
        (bool success,) = msg.sender.call{ value: amount }("");
        if (!success) {
            revert ETHTransferFail();
        }
    }

    /// @notice (Admin) Set extraArgs for outgoing CCIP Messages
    /// @param extraArgs new value for ccipExtraArgs
    function setCCIPExtraArgs(bytes calldata extraArgs) external onlyRole(0) {
        _setCCIPExtraArgs(extraArgs);
    }

    // =============================================================
    // -- Internal functions
    // =============================================================

    function _checkValidRaffle(uint256 raffleId) internal view returns(RafflePrize storage) {
        if (raffleId == 0) {
            revert IllegalRaffleId();
        }
        RafflePrize storage rafflePrize = _rafflePrize[raffleId];
        if (rafflePrize.raffleType != RaffleType.NONE) {
            revert InvalidRaffleId();
        }
        return rafflePrize;
    }

    /// @notice Callback called by CCIP Router. Receives CCIP message and handles it
    /// @param message CCIP Message
    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        (address _senderAddress) = abi.decode(message.sender, (address));
        bytes32 counterpart = _packCCIPContract(_senderAddress, message.sourceChainSelector);

        CCIPMessageType messageType = CCIPMessageType(uint8(message.data[0]));
        uint256 raffleId;
        address winner;
        if (messageType == CCIPMessageType.RAFFLE_CANCELED) {
            raffleId = _decodeRaffleCanceledMessage(message.data);
            if (_rafflePrize[raffleId].ccipCounterpart != counterpart) {
                revert UnauthorizedCCIPSender();
            }
            _cancelRaffle(raffleId);
            return;
        }
        (raffleId, winner) = _decodeWinnerDrawnMessage(message.data);
        if (_rafflePrize[raffleId].ccipCounterpart != counterpart) {
            revert UnauthorizedCCIPSender();
        }
        _rafflePrize[raffleId].winner = winner;
        emit WinnerPropagated(raffleId, winner);
    }

    function _cancelRaffle(uint256 raffleId) internal {
        RaffleType raffleType = _rafflePrize[raffleId].raffleType;
        if (_rafflePrize[raffleId].status == RafflePrizeStatus.CANCELED) {
            revert InvalidRaffle();
        }
        if (raffleType == RaffleType.NFT) {
            NFTInfo storage nftInfo = _nftRaffles[raffleId];
            _nftLocked[nftInfo.contractAddress][nftInfo.tokenId] = false;
        } else if (raffleType == RaffleType.TOKEN) {
            TokenInfo storage tokenInfo = _tokenRaffles[raffleId];
            unchecked { _tokensLocked[tokenInfo.tokenAddress] -= tokenInfo.amount; }
        } else {
            unchecked { _ethLocked -= _ethRaffles[raffleId]; }
        }
        _rafflePrize[raffleId].status = RafflePrizeStatus.CANCELED;
        emit PrizeUnlocked(raffleId);
    }

    /// @dev Transfers the NFT prize to the winner
    /// @param nft NFT address
    /// @param tokenId NFT token id
    /// @param winner Address of the winner
    function _sendNFTPrize(address nft, uint256 tokenId, address winner) internal {
        IERC721(nft).transferFrom(address(this), winner, tokenId);
    }

    /// @dev Transfers the NFT prize to the winner
    /// @param token Token address
    /// @param amount Amount of tokens to send
    /// @param winner Address of the winner
    function _sendTokenPrize(address token, uint256 amount, address winner) internal {
        IERC20(token).safeTransfer(winner, amount);
    }
    /// @dev Transfers the NFT prize to the winner
    /// @param amount Amount of ETH to send
    /// @param winner Address of the winner
    function _sendETHPrize(uint256 amount, address winner) internal {
        (bool success, ) = winner.call{ value: amount }("");
        if (!success) {
            revert ETHTransferFail();
        }
    }

    function _decodeRaffleCanceledMessage(bytes memory b) internal pure returns(uint256 raffleId) {
        assembly { raffleId := mload(add(b, 0x21)) }
    }

    function _decodeWinnerDrawnMessage(bytes memory b) internal pure returns(uint256 raffleId, address winner) {
        assembly {
            raffleId := mload(add(b, 0x21))
            winner := and(
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                mload(add(b, 0x35))
            )
        }
    }

    /// @dev Allow `safeTransferFrom`
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface IWinnables {
    error InvalidPrize();
    error RaffleHasNotStarted();
    error RaffleHasEnded();
    error RaffleIsStillOpen();
    error TooManyTickets();
    error InvalidRaffle();
    error RaffleNotFulfilled();
    error NoParticipants();
    error RequestNotFound(uint256 requestId);
    error ExpiredCoupon();
    error PlayerAlreadyRefunded(address player);
    error NothingToSend();
    error Unauthorized();
    error TargetTicketsNotReached();
    error TargetTicketsReached();
    error RaffleClosingTooSoon();
    error InsufficientBalance();
    error ETHTransferFail();
    error RaffleRequiresTicketSupplyCap();
    error RaffleRequiresMaxHoldings();
    error NotAnNFT();

    event WinnerDrawn(uint256 indexed requestId);
    event RequestSent(uint256 indexed requestId, uint256 indexed raffleId);
    event NewRaffle(uint256 indexed id);
    event PrizeClaimed(uint256 indexed raffleId, address indexed winner);
    event PlayerRefund(uint256 indexed raffleId, address indexed player, bytes32 indexed participation);

    enum RaffleType { NONE, NFT, ETH, TOKEN }
    enum RaffleStatus { NONE, PRIZE_LOCKED, IDLE, REQUESTED, FULFILLED, PROPAGATED, CLAIMED, CANCELED }

    struct RequestStatus {
        uint256 raffleId;
        uint256 randomWord;
        uint256 blockLastRequested;
    }

    struct Raffle {
        RaffleStatus status;
        uint64 startsAt;
        uint64 endsAt;
        uint32 minTicketsThreshold;
        uint32 maxTicketSupply;
        uint32 maxHoldings;
        uint256 totalRaised;
        uint256 chainlinkRequestId;
        bytes32 ccipCounterpart;
        mapping(address => bytes32) participations;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "./IWinnables.sol";

interface IWinnablesPrizeManager is IWinnables {
    error InvalidRaffleId();
    error AlreadyClaimed();
    error NFTLocked();
    error IllegalRaffleId();
    error UnauthorizedToClaim();
    error InvalidAddress();
    error LINKTokenNotPermitted();

    event NFTPrizeLocked(uint256 indexed raffleId, address indexed contractAddress, uint256 indexed tokenId);
    event TokenPrizeLocked(uint256 indexed raffleId, address indexed contractAddress, uint256 indexed amount);
    event ETHPrizeLocked(uint256 indexed raffleId, uint256 indexed amount);
    event PrizeUnlocked(uint256 indexed raffleId);
    event TokenPrizeUnlocked(uint256 indexed raffleId);
    event ETHPrizeUnlocked(uint256 indexed raffleId);
    event WinnerPropagated(uint256 indexed raffleId, address indexed winner);

    enum CCIPMessageType {
        RAFFLE_CANCELED,
        WINNER_DRAWN
    }

    enum RafflePrizeStatus {
        NONE,
        CLAIMED,
        CANCELED
    }

    struct RafflePrize {
        RaffleType raffleType;
        RafflePrizeStatus status;
        bytes32 ccipCounterpart;
        address winner;
    }

    struct NFTInfo {
        address contractAddress;
        uint256 tokenId;
    }

    struct TokenInfo {
        address tokenAddress;
        uint256 amount;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library Bits {
    /**
     * @dev get bit at offset [offset]
     */
    function getBool(bytes32 p, uint8 offset) internal pure returns (bool r) {
        assembly {
            r := and(shr(offset, p), 1)
        }
    }

    /**
     * @dev set bit [offset] to {value}
     */
    function setBool(
        bytes32 p,
        uint8 offset,
        bool value
    ) internal pure returns (bytes32 np) {
        assembly {
            np := or(
                and(
                    p,
                    xor(
                        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
                        shl(offset, 1)
                    )
                ),
                shl(offset, value)
            )
        }
    }
}