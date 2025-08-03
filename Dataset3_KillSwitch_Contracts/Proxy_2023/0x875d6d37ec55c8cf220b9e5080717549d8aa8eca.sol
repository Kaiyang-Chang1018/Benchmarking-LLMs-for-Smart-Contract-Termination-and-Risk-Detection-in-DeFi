// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./libs/BytesLib.sol";
import "./interfaces/CCTP/IReceiver.sol";
import "./interfaces/CCTP/ITokenMessenger.sol";
import "./interfaces/IWormhole.sol";
import "./interfaces/IFeeManager.sol";

contract MayanCircle is ReentrancyGuard {
	using SafeERC20 for IERC20;
	using BytesLib for bytes;

	IWormhole public immutable wormhole;
	ITokenMessenger public immutable cctpTokenMessenger;
	IFeeManager public feeManager;

	uint32 public immutable localDomain;
	uint16 public immutable auctionChainId;
	bytes32 public immutable auctionAddr;

	uint8 public consistencyLevel;
	address public guardian;
	address nextGuardian;
	bool public paused;

	mapping(uint64 => FeeLock) public feeStorage;

	mapping(uint16 => bytes32) public chainIdToEmitter;
	mapping(uint32 => bytes32) public domainToCaller;
	mapping(bytes32 => bytes32) public keyToMintRecipient; // key is domain + local token address
	mapping(uint16 => uint32) private chainIdToDomain;

	uint8 constant ETH_DECIMALS = 18;

	uint32 constant SOLANA_DOMAIN = 5;
	uint16 constant SOLANA_CHAIN_ID = 1;

	uint32 constant SUI_DOMAIN = 8;

	uint256 constant CCTP_DOMAIN_INDEX = 4;
	uint256 constant CCTP_NONCE_INDEX = 12;
	uint256 constant CCTP_TOKEN_INDEX = 120;
	uint256 constant CCTP_RECIPIENT_INDEX = 152;
	uint256 constant CCTP_AMOUNT_INDEX = 208;

	event OrderFulfilled(uint32 sourceDomain, uint64 sourceNonce, uint256 amount);
	event OrderRefunded(uint32 sourceDomain, uint64 sourceNonce, uint256 amount);

	error Paused();
	error Unauthorized();
	error InvalidDomain();
	error InvalidNonce();
	error InvalidOrder();
	error CctpReceiveFailed();
	error InvalidGasDrop();
	error InvalidAction();
	error InvalidEmitter();
	error EmitterAlreadySet();
	error InvalidDestAddr();
	error InvalidMintRecipient();
	error InvalidRedeemFee();
	error InvalidPayload();
	error CallerNotSet();
	error MintRecipientNotSet();
	error InvalidCaller();
	error DeadlineViolation();
	error InvalidAddress();
	error InvalidReferrerFee();
	error InvalidProtocolFee();
	error EthTransferFailed();
	error InvalidAmountOut();
	error DomainNotSet();
	error AlreadySet();

	enum Action {
		NONE,
		SWAP,
		FULFILL,
		BRIDGE_WITH_FEE,
		UNLOCK_FEE,
		UNLOCK_FEE_REFINE
	}

	struct Order {
		uint8 action;
		uint8 payloadType;
		bytes32 trader;
		uint16 sourceChain;
		bytes32 tokenIn;
		uint64 amountIn;
		bytes32 destAddr;
		uint16 destChain;
		bytes32 tokenOut;
		uint64 minAmountOut;
		uint64 gasDrop;
		uint64 redeemFee;
		uint64 deadline;
		bytes32 referrerAddr;
	}

	struct OrderFields {
		uint8 referrerBps;
		uint8 protocolBps;
		uint64 cctpSourceNonce;
		uint32 cctpSourceDomain;
	}

	struct OrderParams {
		address tokenIn;
		uint256 amountIn;
		uint64 gasDrop;
		bytes32 destAddr;
		uint16 destChain;
		bytes32 tokenOut;
		uint64 minAmountOut;
		uint64 deadline;
		uint64 redeemFee;
		bytes32 referrerAddr;
		uint8 referrerBps;
	}

	struct ExtraParams {
		bytes32 trader;
		uint16 sourceChainId;
		uint8 protocolBps;
	}

	struct OrderMsg {
		uint8 action;
		uint8 payloadId;
		bytes32 orderHash;
	}

	struct FeeLock {
		bytes32 destAddr;
		uint64 gasDrop;
		address token;
		uint256 redeemFee;
	}

	struct BridgeWithFeeMsg {
		uint8 action;
		uint8 payloadType;
		uint64 cctpNonce;
		uint32 cctpDomain;
		bytes32 destAddr;
		uint64 gasDrop;
		uint64 redeemFee;
		uint64 burnAmount;
		bytes32 burnToken;
		bytes32 customPayload;
	}

	struct BridgeWithFeeParams {
		uint8 payloadType;
		bytes32 destAddr;
		uint64 gasDrop;
		uint64 redeemFee;
		uint64 burnAmount;
		bytes32 burnToken;
		bytes32 customPayload;		
	}

	struct UnlockFeeMsg {
		uint8 action;
		uint8 payloadType;
		uint64 cctpNonce;
		uint32 cctpDomain;
		bytes32 unlockerAddr;
		uint64 gasDrop;
	}

	struct UnlockParams {
		bytes32 unlockerAddr;
		uint64 gasDrop;
	}

	struct UnlockRefinedFeeMsg {
		uint8 action;
		uint8 payloadType;
		uint64 cctpNonce;
		uint32 cctpDomain;
		bytes32 unlockerAddr;
		uint64 gasDrop;
		bytes32 destAddr;
	}

	struct FulfillMsg {
		uint8 action;
		uint8 payloadType;
		bytes32 tokenIn;
		uint64 amountIn;
		bytes32 destAddr;
		uint16 destChainId;
		bytes32 tokenOut;
		uint64 promisedAmount;
		uint64 gasDrop;
		uint64 redeemFee;
		uint64 deadline;
		bytes32 referrerAddr;
		uint8 referrerBps;
		uint8 protocolBps;
		uint64 cctpSourceNonce;
		uint32 cctpSourceDomain;
		bytes32 driver;
	}

	struct FulfillParams {
		bytes32 destAddr;
		uint16 destChainId;
		bytes32 tokenOut;
		uint64 promisedAmount;
		uint64 gasDrop;
		uint64 redeemFee;
		uint64 deadline;
		bytes32 referrerAddr;
		uint8 referrerBps;
		uint8 protocolBps;
		bytes32 driver;
	}

	constructor(
		address _cctpTokenMessenger,
		address _wormhole,
		address _feeManager,
		uint16 _auctionChainId,
		bytes32 _auctionAddr,
		uint8 _consistencyLevel
	) {
		cctpTokenMessenger = ITokenMessenger(_cctpTokenMessenger);
		wormhole = IWormhole(_wormhole);
		feeManager = IFeeManager(_feeManager);
		auctionChainId = _auctionChainId;
		auctionAddr = _auctionAddr;
		consistencyLevel = _consistencyLevel;
		localDomain = ITokenMessenger(_cctpTokenMessenger).localMessageTransmitter().localDomain();
		guardian = msg.sender;
	}

	function bridgeWithFee(
		address tokenIn,
		uint256 amountIn,
		uint64 redeemFee,
		uint64 gasDrop,
		bytes32 destAddr,
		uint32 destDomain,
		uint8 payloadType,
		bytes memory customPayload
	) external payable nonReentrant returns (uint64 sequence) {
		if (paused) {
			revert Paused();
		}
		if (redeemFee >= amountIn) {
			revert InvalidRedeemFee();
		}

		IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
		approveIfNeeded(tokenIn, address(cctpTokenMessenger), amountIn, true);
		uint64 cctpNonce = sendCctp(tokenIn, amountIn, destDomain);

		bytes32 customPayloadHash;
		if (payloadType == 2) {
			customPayloadHash = keccak256(customPayload);
		}

		BridgeWithFeeMsg memory	bridgeMsg = BridgeWithFeeMsg({
			action: uint8(Action.BRIDGE_WITH_FEE),
			payloadType: payloadType,
			cctpNonce: cctpNonce,
			cctpDomain: localDomain,
			destAddr: destAddr,
			gasDrop: gasDrop,
			redeemFee: redeemFee,
			burnAmount: uint64(amountIn),
			burnToken: bytes32(uint256(uint160(tokenIn))),
			customPayload: customPayloadHash
		});

		bytes memory payload = abi.encodePacked(keccak256(encodeBridgeWithFee(bridgeMsg)));

		sequence = wormhole.publishMessage{
			value : msg.value
		}(0, payload, consistencyLevel);
	}

	function bridgeWithLockedFee(
		address tokenIn,
		uint256 amountIn,
		uint64 gasDrop,
		uint256 redeemFee,
		uint32 destDomain,
		bytes32 destAddr
	) external nonReentrant returns (uint64 cctpNonce) {
		if (paused) {
			revert Paused();
		}
		if (bytes12(destAddr) != 0) {
			revert InvalidDomain();
		}
		if (redeemFee == 0) {
			revert InvalidRedeemFee();
		}

		IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
		approveIfNeeded(tokenIn, address(cctpTokenMessenger), amountIn - redeemFee, true);
		cctpNonce = cctpTokenMessenger.depositForBurnWithCaller(
			amountIn - redeemFee,
			destDomain,
			destAddr,
			tokenIn,
			getCaller(destDomain)
		);

		feeStorage[cctpNonce] = FeeLock({
			destAddr: destAddr,
			gasDrop: gasDrop,
			token: tokenIn,
			redeemFee: redeemFee
		});
	}

	function createOrder(
		OrderParams memory params
	) external payable nonReentrant returns (uint64 sequence) {
		if (paused) {
			revert Paused();
		}
		if (params.redeemFee >= params.amountIn) {
			revert InvalidRedeemFee();
		}
		if (params.tokenOut == bytes32(0) && params.gasDrop > 0) {
			revert InvalidGasDrop();
		}

		IERC20(params.tokenIn).safeTransferFrom(msg.sender, address(this), params.amountIn);
		approveIfNeeded(params.tokenIn, address(cctpTokenMessenger), params.amountIn, true);
		uint64 cctpNonce = sendCctp(params.tokenIn, params.amountIn, getDomain(params.destChain));

		if (params.referrerBps > 100) {
			revert InvalidReferrerFee();
		}
		uint8 protocolBps = feeManager.calcProtocolBps(uint64(params.amountIn), params.tokenIn, params.tokenOut, params.destChain, params.referrerBps);
		if (protocolBps > 100) {
			revert InvalidProtocolFee();
		}

		Order memory order = Order({
			action: uint8(Action.SWAP),
			payloadType: 1,
			trader: bytes32(uint256(uint160(msg.sender))),
			sourceChain: wormhole.chainId(),
			tokenIn: bytes32(uint256(uint160(params.tokenIn))),
			amountIn: uint64(params.amountIn),
			destAddr: params.destAddr,
			destChain: params.destChain,
			tokenOut: params.tokenOut,
			minAmountOut: params.minAmountOut,
			gasDrop: params.gasDrop,
			redeemFee: params.redeemFee,
			deadline: params.deadline,
			referrerAddr: params.referrerAddr
		});

		bytes memory encodedOrder = encodeOrder(order);

		OrderFields memory orderFields = OrderFields({
			referrerBps: params.referrerBps,
			protocolBps: protocolBps,
			cctpSourceNonce: cctpNonce,
			cctpSourceDomain: cctpTokenMessenger.localMessageTransmitter().localDomain()
		});

		encodedOrder = encodedOrder.concat(encodeOrderFields(orderFields));
		bytes memory payload = abi.encodePacked(keccak256(encodedOrder));

		sequence = wormhole.publishMessage{
			value : msg.value
		}(0, payload, consistencyLevel);
	}

	function redeemWithFee(
		bytes memory cctpMsg,
		bytes memory cctpSigs,
		bytes memory encodedVm,
		BridgeWithFeeParams memory bridgeParams
	) external nonReentrant payable {
		(IWormhole.VM memory vm, bool valid, string memory reason) = wormhole.parseAndVerifyVM(encodedVm);
		require(valid, reason);

		validateEmitter(vm.emitterAddress, vm.emitterChainId);

		if (truncateAddress(cctpMsg.toBytes32(CCTP_RECIPIENT_INDEX)) != address(this)) {
			revert InvalidMintRecipient();
		}

		BridgeWithFeeMsg memory bridgeMsg = recreateBridgeWithFee(bridgeParams, cctpMsg);

		bytes32 calculatedPayload = keccak256(encodeBridgeWithFee(bridgeMsg));
		if (vm.payload.length != 32 || calculatedPayload != vm.payload.toBytes32(0)) {
			revert InvalidPayload();
		}

		if (bridgeMsg.payloadType == 2 && msg.sender != truncateAddress(bridgeMsg.destAddr)) {
			revert Unauthorized();
		}

		(address localToken, uint256 amount) = receiveCctp(cctpMsg, cctpSigs);

		if (bridgeMsg.redeemFee > amount) {
			revert InvalidRedeemFee();
		}
		depositRelayerFee(msg.sender, localToken, uint256(bridgeMsg.redeemFee));
		address recipient = truncateAddress(bridgeMsg.destAddr);
		IERC20(localToken).safeTransfer(recipient, amount - uint256(bridgeMsg.redeemFee));

		if (bridgeMsg.gasDrop > 0) {
			uint256 denormalizedGasDrop = deNormalizeAmount(bridgeMsg.gasDrop, ETH_DECIMALS);
			if (msg.value != denormalizedGasDrop) {
				revert InvalidGasDrop();
			}
			payEth(recipient, denormalizedGasDrop, false);
		}
	}

	function redeemWithLockedFee(bytes memory cctpMsg, bytes memory cctpSigs, bytes32 unlockerAddr) external nonReentrant payable returns (uint64 sequence) {
		uint32 cctpSourceDomain = cctpMsg.toUint32(CCTP_DOMAIN_INDEX);
		uint64 cctpNonce = cctpMsg.toUint64(CCTP_NONCE_INDEX);
		address mintRecipient = truncateAddress(cctpMsg.toBytes32(CCTP_RECIPIENT_INDEX));
		if (mintRecipient == address(this)) {
			revert InvalidMintRecipient();
		}

		bool success = cctpTokenMessenger.localMessageTransmitter().receiveMessage(cctpMsg, cctpSigs);
		if (!success) {
			revert CctpReceiveFailed();
		}

		uint256 wormholeFee = wormhole.messageFee();
		if (msg.value > wormholeFee) {
			payEth(mintRecipient, msg.value - wormholeFee, false);
		}

		UnlockFeeMsg memory unlockMsg = UnlockFeeMsg({
			action: uint8(Action.UNLOCK_FEE),
			payloadType: 1,
			cctpDomain: cctpSourceDomain,
			cctpNonce: cctpNonce,
			unlockerAddr: unlockerAddr,
			gasDrop: uint64(normalizeAmount(msg.value - wormholeFee, ETH_DECIMALS))
		});

		bytes memory encodedMsg = encodeUnlockFeeMsg(unlockMsg);
		bytes memory payload = abi.encodePacked(keccak256(encodedMsg));

		sequence = wormhole.publishMessage{
			value : wormholeFee
		}(0, payload, consistencyLevel);
	}

	function refineFee(uint32 cctpNonce, uint32 cctpDomain, bytes32 destAddr, bytes32 unlockerAddr) external nonReentrant payable returns (uint64 sequence) {
		uint256 wormholeFee = wormhole.messageFee();
		if (msg.value > wormholeFee) {
			payEth(truncateAddress(destAddr), msg.value - wormholeFee, false);
		}

		UnlockRefinedFeeMsg memory unlockMsg = UnlockRefinedFeeMsg({
			action: uint8(Action.UNLOCK_FEE_REFINE),
			payloadType: 1,
			cctpDomain: cctpDomain,
			cctpNonce: cctpNonce,
			unlockerAddr: unlockerAddr,
			gasDrop: uint64(normalizeAmount(msg.value - wormholeFee, ETH_DECIMALS)),
			destAddr: destAddr
		});

		bytes memory encodedMsg = encodeUnlockRefinedFeeMsg(unlockMsg);
		bytes memory payload = abi.encodePacked(keccak256(encodedMsg));

		sequence = wormhole.publishMessage{
			value : wormholeFee
		}(0, payload, consistencyLevel);
	}

	function unlockFee(
		bytes memory encodedVm,
		UnlockFeeMsg memory unlockMsg
	) external nonReentrant {
		(IWormhole.VM memory vm, bool valid, string memory reason) = wormhole.parseAndVerifyVM(encodedVm);
		require(valid, reason);

		validateEmitter(vm.emitterAddress, vm.emitterChainId);

		unlockMsg.action = uint8(Action.UNLOCK_FEE);
		bytes32 calculatedPayload = keccak256(encodeUnlockFeeMsg(unlockMsg));
		if (vm.payload.length != 32 || calculatedPayload != vm.payload.toBytes32(0)) {
			revert InvalidPayload();
		}

		if (unlockMsg.cctpDomain != localDomain) {
			revert InvalidDomain();
		}

		FeeLock memory feeLock = feeStorage[unlockMsg.cctpNonce];
		if (feeLock.redeemFee == 0) {
			revert InvalidOrder();
		}

		if (unlockMsg.gasDrop < feeLock.gasDrop) {
			revert InvalidGasDrop();
		}
		IERC20(feeLock.token).safeTransfer(truncateAddress(unlockMsg.unlockerAddr), feeLock.redeemFee);
		delete feeStorage[unlockMsg.cctpNonce];
	}

	function unlockFeeRefined(
		bytes memory encodedVm1,
		bytes memory encodedVm2,
		UnlockFeeMsg memory unlockMsg,
		UnlockRefinedFeeMsg memory refinedMsg
	) external nonReentrant {
		(IWormhole.VM memory vm1, bool valid1, string memory reason1) = wormhole.parseAndVerifyVM(encodedVm1);
		require(valid1, reason1);

		validateEmitter(vm1.emitterAddress, vm1.emitterChainId);

		unlockMsg.action = uint8(Action.UNLOCK_FEE);
		bytes32 calculatedPayload1 = keccak256(encodeUnlockFeeMsg(unlockMsg));
		if (vm1.payload.length != 32 || calculatedPayload1 != vm1.payload.toBytes32(0)) {
			revert InvalidPayload();
		}
		if (unlockMsg.cctpDomain != localDomain) {
			revert InvalidDomain();
		}

		FeeLock memory feeLock = feeStorage[unlockMsg.cctpNonce];
		if (feeLock.redeemFee == 0) {
			revert InvalidOrder();
		}
		if (unlockMsg.gasDrop >= feeLock.gasDrop) {
			revert InvalidAction();
		}

		(IWormhole.VM memory vm2, bool valid2, string memory reason2) = wormhole.parseAndVerifyVM(encodedVm2);
		require(valid2, reason2);

		validateEmitter(vm2.emitterAddress, vm2.emitterChainId);

		refinedMsg.action = uint8(Action.UNLOCK_FEE_REFINE);
		bytes32 calculatedPayload2 = keccak256(encodeUnlockRefinedFeeMsg(refinedMsg));
		if (vm2.payload.length != 32 || calculatedPayload2 != vm2.payload.toBytes32(0)) {
			revert InvalidPayload();
		}

		if (refinedMsg.destAddr != feeLock.destAddr) {
			revert InvalidDestAddr();
		}
		if (refinedMsg.cctpNonce != unlockMsg.cctpNonce) {
			revert InvalidNonce();
		}
		if (refinedMsg.cctpDomain != unlockMsg.cctpDomain) {
			revert InvalidDomain();
		}
		if (refinedMsg.gasDrop + unlockMsg.gasDrop < feeLock.gasDrop) {
			revert InvalidGasDrop();
		}

		IERC20(feeLock.token).safeTransfer(truncateAddress(refinedMsg.unlockerAddr), feeLock.redeemFee);
		delete feeStorage[unlockMsg.cctpNonce];
	}

	function fulfillOrder(
		bytes memory cctpMsg,
		bytes memory cctpSigs,
		bytes memory encodedVm,
		FulfillParams memory params,
		address swapProtocol,
		bytes memory swapData
	) external nonReentrant payable {
		(IWormhole.VM memory vm, bool valid, string memory reason) = wormhole.parseAndVerifyVM(encodedVm);
		require(valid, reason);

		if (vm.emitterChainId != SOLANA_CHAIN_ID || vm.emitterAddress != auctionAddr) {
			revert InvalidEmitter();
		}

		FulfillMsg memory fulfillMsg = recreateFulfillMsg(params, cctpMsg);
		if (fulfillMsg.deadline < block.timestamp) {
			revert DeadlineViolation();
		}
		if (msg.sender != truncateAddress(fulfillMsg.driver)) {
			revert Unauthorized();
		}
		
		bytes32 calculatedPayload = calcFulfillPayload(fulfillMsg);
		if (vm.payload.length != 32 || calculatedPayload != vm.payload.toBytes32(0)) {
			revert InvalidPayload();
		}

		(address localToken, uint256 cctpAmount) = receiveCctp(cctpMsg, cctpSigs);

		if (fulfillMsg.redeemFee > 0) {
			IERC20(localToken).safeTransfer(msg.sender, fulfillMsg.redeemFee);
		}

		address tokenOut = truncateAddress(fulfillMsg.tokenOut);
		approveIfNeeded(localToken, swapProtocol, cctpAmount - uint256(fulfillMsg.redeemFee), false);

		uint256 amountOut;
		if (tokenOut == address(0)) {
			amountOut = address(this).balance;
		} else {
			amountOut = IERC20(tokenOut).balanceOf(address(this));
		}

		(bool swapSuccess, bytes memory swapReturn) = swapProtocol.call{value: 0}(swapData);
		require(swapSuccess, string(swapReturn));

		if (tokenOut == address(0)) {
			amountOut = address(this).balance - amountOut;
		} else {
			amountOut = IERC20(tokenOut).balanceOf(address(this)) - amountOut;
		}

		uint8 decimals;
		if (tokenOut == address(0)) {
			decimals = ETH_DECIMALS;
		} else {
			decimals = decimalsOf(tokenOut);
		}

		uint256 promisedAmount = deNormalizeAmount(fulfillMsg.promisedAmount, decimals);
		if (amountOut < promisedAmount) {
			revert InvalidAmountOut();
		}

		makePayments(
			fulfillMsg,
			tokenOut,
			amountOut
		);

		emit OrderFulfilled(fulfillMsg.cctpSourceDomain, fulfillMsg.cctpSourceNonce, amountOut);
	}

	function refund(
		bytes memory encodedVm,
		bytes memory cctpMsg,
		bytes memory cctpSigs,
		OrderParams memory orderParams,
		ExtraParams memory extraParams
	) external nonReentrant payable {
		(IWormhole.VM memory vm, bool valid, string memory reason) = wormhole.parseAndVerifyVM(encodedVm);
		require(valid, reason);

		validateEmitter(vm.emitterAddress, vm.emitterChainId);

		(address localToken, uint256 amount) = receiveCctp(cctpMsg, cctpSigs);

		Order memory order = recreateOrder(orderParams, cctpMsg, extraParams);
		bytes memory encodedOrder = encodeOrder(order);
		OrderFields memory orderFields = OrderFields({
			referrerBps: orderParams.referrerBps,
			protocolBps: extraParams.protocolBps,
			cctpSourceNonce: cctpMsg.toUint64(CCTP_NONCE_INDEX),
			cctpSourceDomain: cctpMsg.toUint32(CCTP_DOMAIN_INDEX)
		});
		encodedOrder = encodedOrder.concat(encodeOrderFields(orderFields));
		if (vm.payload.length != 32 || keccak256(encodedOrder) != vm.payload.toBytes32(0)) {
			revert InvalidPayload();
		}

		if (order.deadline >= block.timestamp) {
			revert DeadlineViolation();
		}

		uint256 gasDrop = deNormalizeAmount(order.gasDrop, ETH_DECIMALS);
		if (msg.value != gasDrop) {
			revert InvalidGasDrop();
		}

		address destAddr = truncateAddress(order.destAddr);
		if (gasDrop > 0) {
			payEth(destAddr, gasDrop, false);
		}

		IERC20(localToken).safeTransfer(msg.sender, order.redeemFee);
		IERC20(localToken).safeTransfer(destAddr, amount - order.redeemFee);

		logRefund(cctpMsg, amount);
	}

	function sendCctp(
		address tokenIn,
		uint256 amountIn,
		uint32 destDomain
	) internal returns (uint64 cctpNonce) {
		if (destDomain == SUI_DOMAIN) {
			cctpNonce = cctpTokenMessenger.depositForBurn(amountIn, destDomain, getMintRecipient(destDomain, tokenIn), tokenIn);
		} else {
			cctpNonce = cctpTokenMessenger.depositForBurnWithCaller(
				amountIn,
				destDomain,
				getMintRecipient(destDomain, tokenIn),
				tokenIn,
				getCaller(destDomain)
			);
		}
	}

	function receiveCctp(bytes memory cctpMsg, bytes memory cctpSigs) internal returns (address, uint256) {
		uint32 cctpDomain = cctpMsg.toUint32(CCTP_DOMAIN_INDEX);
		bytes32 cctpSourceToken = cctpMsg.toBytes32(CCTP_TOKEN_INDEX);
		address localToken = cctpTokenMessenger.localMinter().getLocalToken(cctpDomain, cctpSourceToken);

		uint256 amount = IERC20(localToken).balanceOf(address(this));
		bool success = cctpTokenMessenger.localMessageTransmitter().receiveMessage(cctpMsg, cctpSigs);
		if (!success) {
			revert CctpReceiveFailed();
		}
		amount = IERC20(localToken).balanceOf(address(this)) - amount;
		return (localToken, amount);
	}

	function getMintRecipient(uint32 destDomain, address tokenIn) internal view returns (bytes32) {
		bytes32 mintRecepient = keyToMintRecipient[keccak256(abi.encodePacked(destDomain, tokenIn))];
		if (mintRecepient == bytes32(0)) {
			revert MintRecipientNotSet();
		}
		return mintRecepient;
	}

	function getCaller(uint32 destDomain) internal view returns (bytes32 caller) {
		caller = domainToCaller[destDomain];
		if (caller == bytes32(0)) {
			revert CallerNotSet();
		}
		return caller;
	}

	function makePayments(
		FulfillMsg memory fulfillMsg,
		address tokenOut,
		uint256 amount
	) internal {
		address referrerAddr = truncateAddress(fulfillMsg.referrerAddr);
		uint256 referrerAmount = 0;
		if (referrerAddr != address(0) && fulfillMsg.referrerBps != 0) {
			referrerAmount = amount * fulfillMsg.referrerBps / 10000;
		}

		uint256 protocolAmount = 0;
		if (fulfillMsg.protocolBps != 0) {
			protocolAmount = amount * fulfillMsg.protocolBps / 10000;
		}

		address destAddr = truncateAddress(fulfillMsg.destAddr);
		if (tokenOut == address(0)) {
			if (referrerAmount > 0) {
				payEth(referrerAddr, referrerAmount, false);
			}
			if (protocolAmount > 0) {
				payEth(feeManager.feeCollector(), protocolAmount, false);
			}
			payEth(destAddr, amount - referrerAmount - protocolAmount, true);
		} else {
			if (fulfillMsg.gasDrop > 0) {
				uint256 gasDrop = deNormalizeAmount(fulfillMsg.gasDrop, ETH_DECIMALS);
				if (msg.value != gasDrop) {
					revert InvalidGasDrop();
				}
				payEth(destAddr, gasDrop, false);
			}
			if (referrerAmount > 0) {
				IERC20(tokenOut).safeTransfer(referrerAddr, referrerAmount);
			}
			if (protocolAmount > 0) {
				IERC20(tokenOut).safeTransfer(feeManager.feeCollector(), protocolAmount);
			}
			IERC20(tokenOut).safeTransfer(destAddr, amount - referrerAmount - protocolAmount);
		}
	}

	function encodeBridgeWithFee(BridgeWithFeeMsg memory bridgeMsg) internal pure returns (bytes memory) {
		return abi.encodePacked(
			bridgeMsg.action,
			bridgeMsg.payloadType,
			bridgeMsg.cctpNonce,
			bridgeMsg.cctpDomain,
			bridgeMsg.destAddr,
			bridgeMsg.gasDrop,
			bridgeMsg.redeemFee,
			bridgeMsg.burnAmount,
			bridgeMsg.burnToken,
			bridgeMsg.customPayload
		);
	}

	function recreateBridgeWithFee(
			BridgeWithFeeParams memory bridgeParams,
			bytes memory cctpMsg
	) internal pure returns (BridgeWithFeeMsg memory) {
		return BridgeWithFeeMsg({
			action: uint8(Action.BRIDGE_WITH_FEE),
			payloadType: bridgeParams.payloadType,
			cctpNonce: cctpMsg.toUint64(CCTP_NONCE_INDEX),
			cctpDomain: cctpMsg.toUint32(CCTP_DOMAIN_INDEX),
			destAddr: bridgeParams.destAddr,
			gasDrop: bridgeParams.gasDrop,
			redeemFee: bridgeParams.redeemFee,
			burnAmount: cctpMsg.toUint64(CCTP_AMOUNT_INDEX),
			burnToken: cctpMsg.toBytes32(CCTP_TOKEN_INDEX),
			customPayload: bridgeParams.customPayload
		});
	}

	function encodeUnlockFeeMsg(UnlockFeeMsg memory unlockMsg) internal pure returns (bytes memory) {
		return abi.encodePacked(
			unlockMsg.action,
			unlockMsg.payloadType,
			unlockMsg.cctpNonce,
			unlockMsg.cctpDomain,
			unlockMsg.unlockerAddr,
			unlockMsg.gasDrop
		);
	}

	function encodeUnlockRefinedFeeMsg(UnlockRefinedFeeMsg memory unlockMsg) internal pure returns (bytes memory) {
		return abi.encodePacked(
			unlockMsg.action,
			unlockMsg.payloadType,
			unlockMsg.cctpNonce,
			unlockMsg.cctpDomain,
			unlockMsg.unlockerAddr,
			unlockMsg.gasDrop,
			unlockMsg.destAddr
		);
	}

	function parseUnlockFeeMsg(bytes memory payload) internal pure returns (UnlockFeeMsg memory) {
		return UnlockFeeMsg({
			action: payload.toUint8(0),
			payloadType: payload.toUint8(1),
			cctpNonce: payload.toUint64(2),
			cctpDomain: payload.toUint32(10),
			unlockerAddr: payload.toBytes32(14),
			gasDrop: payload.toUint64(46)
		});
	}

	function parseUnlockRefinedFee(bytes memory payload) internal pure returns (UnlockRefinedFeeMsg memory) {
		return UnlockRefinedFeeMsg({
			action: payload.toUint8(0),
			payloadType: payload.toUint8(1),
			cctpNonce: payload.toUint64(2),
			cctpDomain: payload.toUint32(10),
			unlockerAddr: payload.toBytes32(14),
			gasDrop: payload.toUint64(46),
			destAddr: payload.toBytes32(54)
		});
	}

	function encodeOrder(Order memory order) internal pure returns (bytes memory) {
		return abi.encodePacked(
			order.action,
			order.payloadType,
			order.trader,
			order.sourceChain,
			order.tokenIn,
			order.amountIn,
			order.destAddr,
			order.destChain,
			order.tokenOut,
			order.minAmountOut,
			order.gasDrop,
			order.redeemFee,
			order.deadline,
			order.referrerAddr
		);
	}

	function encodeOrderFields(OrderFields memory orderFields) internal pure returns (bytes memory) {
		return abi.encodePacked(
			orderFields.referrerBps,
			orderFields.protocolBps,
			orderFields.cctpSourceNonce,
			orderFields.cctpSourceDomain
		);
	}

	function calcFulfillPayload(FulfillMsg memory fulfillMsg) internal pure returns (bytes32) {
		bytes memory partialPayload = encodeFulfillMsg(fulfillMsg);
		bytes memory completePayload = partialPayload.concat(abi.encodePacked(fulfillMsg.cctpSourceNonce, fulfillMsg.cctpSourceDomain, fulfillMsg.driver));
		return keccak256(completePayload);
	}

	function recreateOrder(
		OrderParams memory params,
		bytes memory cctpMsg,
		ExtraParams memory extraParams
	) internal pure returns (Order memory) {
		return Order({
			action: uint8(Action.SWAP),
			payloadType: 1,
			trader: extraParams.trader,
			sourceChain: extraParams.sourceChainId,
			tokenIn: cctpMsg.toBytes32(CCTP_TOKEN_INDEX),
			amountIn: cctpMsg.toUint64(CCTP_AMOUNT_INDEX),
			destAddr: params.destAddr,
			destChain: params.destChain,
			tokenOut: params.tokenOut,
			minAmountOut: params.minAmountOut,
			gasDrop: params.gasDrop,
			redeemFee: params.redeemFee,
			deadline: params.deadline,
			referrerAddr: params.referrerAddr
		});
	}	

	function encodeFulfillMsg(FulfillMsg memory fulfillMsg) internal pure returns (bytes memory) {
		return abi.encodePacked(
			fulfillMsg.action,
			fulfillMsg.payloadType,
			fulfillMsg.tokenIn,
			fulfillMsg.amountIn,
			fulfillMsg.destAddr,
			fulfillMsg.destChainId,
			fulfillMsg.tokenOut,
			fulfillMsg.promisedAmount,
			fulfillMsg.gasDrop,
			fulfillMsg.redeemFee,
			fulfillMsg.deadline,
			fulfillMsg.referrerAddr,
			fulfillMsg.referrerBps,
			fulfillMsg.protocolBps
		);
	}

	function recreateFulfillMsg(
		FulfillParams memory params,
		bytes memory cctpMsg
	) internal pure returns (FulfillMsg memory) {
		return FulfillMsg({
			action: uint8(Action.FULFILL),
			payloadType: 1,
			tokenIn: cctpMsg.toBytes32(CCTP_TOKEN_INDEX),
			amountIn: cctpMsg.toUint64(CCTP_AMOUNT_INDEX),
			destAddr: params.destAddr,
			destChainId: params.destChainId,
			tokenOut: params.tokenOut,
			promisedAmount: params.promisedAmount,
			gasDrop: params.gasDrop,
			redeemFee: params.redeemFee,
			deadline: params.deadline,
			referrerAddr: params.referrerAddr,
			referrerBps: params.referrerBps,
			protocolBps: params.protocolBps,
			cctpSourceNonce: cctpMsg.toUint64(CCTP_NONCE_INDEX),
			cctpSourceDomain: cctpMsg.toUint32(CCTP_DOMAIN_INDEX),
			driver: params.driver
		});
	}

	function validateEmitter(bytes32 emitter, uint16 chainId) view internal {
		if (emitter != chainIdToEmitter[chainId]) {
			revert InvalidEmitter();
		}
	}

	function approveIfNeeded(address tokenAddr, address spender, uint256 amount, bool max) internal {
		IERC20 token = IERC20(tokenAddr);
		uint256 currentAllowance = token.allowance(address(this), spender);

		if (currentAllowance < amount) {
			if (currentAllowance > 0) {
				token.safeApprove(spender, 0);
			}
			token.safeApprove(spender, max ? type(uint256).max : amount);
		}
	}

	function payEth(address to, uint256 amount, bool revertOnFailure) internal {
		(bool success, ) = payable(to).call{value: amount}('');
		if (revertOnFailure) {
			if (success != true) {
				revert EthTransferFailed();
			}
		}
	}

	function depositRelayerFee(address relayer, address token, uint256 amount) internal {
		IERC20(token).transfer(address(feeManager), amount);
		try feeManager.depositFee(relayer, token, amount) {} catch {}
	}

	function decimalsOf(address token) internal view returns(uint8) {
		(,bytes memory queriedDecimals) = token.staticcall(abi.encodeWithSignature('decimals()'));
		return abi.decode(queriedDecimals, (uint8));
	}

	function normalizeAmount(uint256 amount, uint8 decimals) internal pure returns(uint256) {
		if (decimals > 8) {
			amount /= 10 ** (decimals - 8);
		}
		return amount;
	}

	function deNormalizeAmount(uint256 amount, uint8 decimals) internal pure returns(uint256) {
		if (decimals > 8) {
			amount *= 10 ** (decimals - 8);
		}
		return amount;
	}

	function logRefund(bytes memory cctpMsg, uint256 amount) internal {
		emit OrderRefunded(cctpMsg.toUint32(CCTP_DOMAIN_INDEX), cctpMsg.toUint64(CCTP_NONCE_INDEX), amount);
	}

	function truncateAddress(bytes32 b) internal pure returns (address) {
		if (bytes12(b) != 0) {
			revert InvalidAddress();
		}
		return address(uint160(uint256(b)));
	}

	function setFeeManager(address _feeManager) public {
		if (msg.sender != guardian) {
			revert Unauthorized();
		}
		feeManager = IFeeManager(_feeManager);
	}	

	function setConsistencyLevel(uint8 _consistencyLevel) public {
		if (msg.sender != guardian) {
			revert Unauthorized();
		}
		consistencyLevel = _consistencyLevel;
	}

	function setPause(bool _pause) public {
		if (msg.sender != guardian) {
			revert Unauthorized();
		}
		paused = _pause;
	}

	function rescueToken(address token, uint256 amount, address to) public {
		if (msg.sender != guardian) {
			revert Unauthorized();
		}
		IERC20(token).safeTransfer(to, amount);
	}

	function rescueEth(uint256 amount, address payable to) public {
		if (msg.sender != guardian) {
			revert Unauthorized();
		}
		payEth(to, amount, true);
	}

	function setDomainCallers(uint32 domain, bytes32 caller) public {
		if (msg.sender != guardian) {
			revert Unauthorized();
		}
		if (domainToCaller[domain] != bytes32(0)) {
			revert AlreadySet();
		}
		domainToCaller[domain] = caller;
	}

	function setMintRecipient(uint32 destDomain, address tokenIn, bytes32 mintRecipient) public {
		if (msg.sender != guardian) {
			revert Unauthorized();
		}
		bytes32 key = keccak256(abi.encodePacked(destDomain, tokenIn));
		if (keyToMintRecipient[key] != bytes32(0)) {
			revert AlreadySet();
		}
		keyToMintRecipient[key] = mintRecipient;
	}

	function setEmitter(uint16 chainId, bytes32 emitter) public {
		if (msg.sender != guardian) {
			revert Unauthorized();
		}
		if (chainIdToEmitter[chainId] != bytes32(0)) {
			revert AlreadySet();
		}
		chainIdToEmitter[chainId] = emitter;
	}

	function setDomains(uint16[] memory chainIds, uint32[] memory domains) public {
		if (msg.sender != guardian) {
			revert Unauthorized();
		}
		for (uint i = 0; i < chainIds.length; i++) {
			if (chainIdToDomain[chainIds[i]] != 0) {
				revert AlreadySet();
			}
			chainIdToDomain[chainIds[i]] = domains[i] + 1; // to distinguish between unset and 0
		}
	}

	function getDomain(uint16 chainId) public view returns (uint32 domain) {
		domain = chainIdToDomain[chainId];
		if (domain == 0) {
			revert DomainNotSet();
		}
		return domain - 1;
	}

	function changeGuardian(address newGuardian) public {
		if (msg.sender != guardian) {
			revert Unauthorized();
		}
		nextGuardian = newGuardian;
	}

	function claimGuardian() public {
		if (msg.sender != nextGuardian) {
			revert Unauthorized();
		}
		guardian = nextGuardian;
	}

	receive() external payable {}
}
/*
 * Copyright (c) 2022, Circle Internet Financial Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
pragma solidity ^0.8.0;

import "./IRelayer.sol";
import "./IReceiver.sol";

/**
 * @title IMessageTransmitter
 * @notice Interface for message transmitters, which both relay and receive messages.
 */
interface IMessageTransmitter is IRelayer, IReceiver {
	function localDomain() external view returns (uint32);
}
/*
 * Copyright (c) 2022, Circle Internet Financial Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
pragma solidity ^0.8.0;

/**
 * @title IReceiver
 * @notice Receives messages on destination chain and forwards them to IMessageDestinationHandler
 */
interface IReceiver {
	/**
	 * @notice Receives an incoming message, validating the header and passing
	 * the body to application-specific handler.
	 * @param message The message raw bytes
	 * @param signature The message signature
	 * @return success bool, true if successful
	 */
	function receiveMessage(bytes calldata message, bytes calldata signature)
		external
		returns (bool success);
}
/*
 * Copyright (c) 2022, Circle Internet Financial Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
pragma solidity ^0.8.0;

/**
 * @title IRelayer
 * @notice Sends messages from source domain to destination domain
 */
interface IRelayer {
	/**
	 * @notice Sends an outgoing message from the source domain.
	 * @dev Increment nonce, format the message, and emit `MessageSent` event with message information.
	 * @param destinationDomain Domain of destination chain
	 * @param recipient Address of message recipient on destination domain as bytes32
	 * @param messageBody Raw bytes content of message
	 * @return nonce reserved by message
	 */
	function sendMessage(
		uint32 destinationDomain,
		bytes32 recipient,
		bytes calldata messageBody
	) external returns (uint64);

	/**
	 * @notice Sends an outgoing message from the source domain, with a specified caller on the
	 * destination domain.
	 * @dev Increment nonce, format the message, and emit `MessageSent` event with message information.
	 * WARNING: if the `destinationCaller` does not represent a valid address as bytes32, then it will not be possible
	 * to broadcast the message on the destination domain. This is an advanced feature, and the standard
	 * sendMessage() should be preferred for use cases where a specific destination caller is not required.
	 * @param destinationDomain Domain of destination chain
	 * @param recipient Address of message recipient on destination domain as bytes32
	 * @param destinationCaller caller on the destination domain, as bytes32
	 * @param messageBody Raw bytes content of message
	 * @return nonce reserved by message
	 */
	function sendMessageWithCaller(
		uint32 destinationDomain,
		bytes32 recipient,
		bytes32 destinationCaller,
		bytes calldata messageBody
	) external returns (uint64);

	/**
	 * @notice Replace a message with a new message body and/or destination caller.
	 * @dev The `originalAttestation` must be a valid attestation of `originalMessage`.
	 * @param originalMessage original message to replace
	 * @param originalAttestation attestation of `originalMessage`
	 * @param newMessageBody new message body of replaced message
	 * @param newDestinationCaller the new destination caller
	 */
	function replaceMessage(
		bytes calldata originalMessage,
		bytes calldata originalAttestation,
		bytes calldata newMessageBody,
		bytes32 newDestinationCaller
	) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IMessageTransmitter.sol";
import "./ITokenMinter.sol";

interface ITokenMessenger {
	function localMessageTransmitter() external view returns (IMessageTransmitter);
	function localMinter() external view returns (ITokenMinter);

	function depositForBurn(
		uint256 amount,
		uint32 destinationDomain,
		bytes32 mintRecipient,
		address burnToken
	) external returns (uint64 nonce);

	function depositForBurnWithCaller(
		uint256 amount,
		uint32 destinationDomain,
		bytes32 mintRecipient,
		address burnToken,
		bytes32 destinationCaller
	) external returns (uint64 nonce);
}
/*
 * Copyright (c) 2022, Circle Internet Financial Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
pragma solidity ^0.8.0;

/**
 * @title ITokenMinter
 * @notice interface for minter of tokens that are mintable, burnable, and interchangeable
 * across domains.
 */
interface ITokenMinter {
	/**
	 * @notice Mints `amount` of local tokens corresponding to the
	 * given (`sourceDomain`, `burnToken`) pair, to `to` address.
	 * @dev reverts if the (`sourceDomain`, `burnToken`) pair does not
	 * map to a nonzero local token address. This mapping can be queried using
	 * getLocalToken().
	 * @param sourceDomain Source domain where `burnToken` was burned.
	 * @param burnToken Burned token address as bytes32.
	 * @param to Address to receive minted tokens, corresponding to `burnToken`,
	 * on this domain.
	 * @param amount Amount of tokens to mint. Must be less than or equal
	 * to the minterAllowance of this TokenMinter for given `_mintToken`.
	 * @return mintToken token minted.
	 */
	function mint(
		uint32 sourceDomain,
		bytes32 burnToken,
		address to,
		uint256 amount
	) external returns (address mintToken);

	/**
	 * @notice Burn tokens owned by this ITokenMinter.
	 * @param burnToken burnable token.
	 * @param amount amount of tokens to burn. Must be less than or equal to this ITokenMinter's
	 * account balance of the given `_burnToken`.
	 */
	function burn(address burnToken, uint256 amount) external;

	/**
	 * @notice Get the local token associated with the given remote domain and token.
	 * @param remoteDomain Remote domain
	 * @param remoteToken Remote token
	 * @return local token address
	 */
	function getLocalToken(uint32 remoteDomain, bytes32 remoteToken)
		external
		view
		returns (address);

	/**
	 * @notice Set the token controller of this ITokenMinter. Token controller
	 * is responsible for mapping local tokens to remote tokens, and managing
	 * token-specific limits
	 * @param newTokenController new token controller address
	 */
	function setTokenController(address newTokenController) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFeeManager {
    event ProtocolFeeCalced(uint8 bps);
    event FeeDeposited(address relayer, address token, uint256 amount);
    event FeeWithdrawn(address token, uint256 amount);

    function calcProtocolBps(
        uint64 amountIn,
        address tokenIn,
        bytes32 tokenOut,
        uint16 destChain,
        uint8 referrerBps
    ) external returns (uint8);

	function feeCollector() external view returns (address);

    function depositFee(address owner, address token, uint256 amount) payable external;
    function withdrawFee(address token, uint256 amount) external;
}
// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8.0;

interface IWormhole {
    struct GuardianSet {
        address[] keys;
        uint32 expirationTime;
    }

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
        uint8 guardianIndex;
    }

    struct VM {
        uint8 version;
        uint32 timestamp;
        uint32 nonce;
        uint16 emitterChainId;
        bytes32 emitterAddress;
        uint64 sequence;
        uint8 consistencyLevel;
        bytes payload;

        uint32 guardianSetIndex;
        Signature[] signatures;

        bytes32 hash;
    }

    struct ContractUpgrade {
        bytes32 module;
        uint8 action;
        uint16 chain;

        address newContract;
    }

    struct GuardianSetUpgrade {
        bytes32 module;
        uint8 action;
        uint16 chain;

        GuardianSet newGuardianSet;
        uint32 newGuardianSetIndex;
    }

    struct SetMessageFee {
        bytes32 module;
        uint8 action;
        uint16 chain;

        uint256 messageFee;
    }

    struct TransferFees {
        bytes32 module;
        uint8 action;
        uint16 chain;

        uint256 amount;
        bytes32 recipient;
    }

    struct RecoverChainId {
        bytes32 module;
        uint8 action;

        uint256 evmChainId;
        uint16 newChainId;
    }

    event LogMessagePublished(address indexed sender, uint64 sequence, uint32 nonce, bytes payload, uint8 consistencyLevel);
    event ContractUpgraded(address indexed oldContract, address indexed newContract);
    event GuardianSetAdded(uint32 indexed index);

    function publishMessage(
        uint32 nonce,
        bytes memory payload,
        uint8 consistencyLevel
    ) external payable returns (uint64 sequence);

    function initialize() external;

    function parseAndVerifyVM(bytes calldata encodedVM) external view returns (VM memory vm, bool valid, string memory reason);

    function verifyVM(VM memory vm) external view returns (bool valid, string memory reason);

    function verifySignatures(bytes32 hash, Signature[] memory signatures, GuardianSet memory guardianSet) external pure returns (bool valid, string memory reason);

    function parseVM(bytes memory encodedVM) external pure returns (VM memory vm);

    function quorum(uint numGuardians) external pure returns (uint numSignaturesRequiredForQuorum);

    function getGuardianSet(uint32 index) external view returns (GuardianSet memory);

    function getCurrentGuardianSetIndex() external view returns (uint32);

    function getGuardianSetExpiry() external view returns (uint32);

    function governanceActionIsConsumed(bytes32 hash) external view returns (bool);

    function isInitialized(address impl) external view returns (bool);

    function chainId() external view returns (uint16);

    function isFork() external view returns (bool);

    function governanceChainId() external view returns (uint16);

    function governanceContract() external view returns (bytes32);

    function messageFee() external view returns (uint256);

    function evmChainId() external view returns (uint256);

    function nextSequence(address emitter) external view returns (uint64);

    function parseContractUpgrade(bytes memory encodedUpgrade) external pure returns (ContractUpgrade memory cu);

    function parseGuardianSetUpgrade(bytes memory encodedUpgrade) external pure returns (GuardianSetUpgrade memory gsu);

    function parseSetMessageFee(bytes memory encodedSetMessageFee) external pure returns (SetMessageFee memory smf);

    function parseTransferFees(bytes memory encodedTransferFees) external pure returns (TransferFees memory tf);

    function parseRecoverChainId(bytes memory encodedRecoverChainId) external pure returns (RecoverChainId memory rci);

    function submitContractUpgrade(bytes memory _vm) external;

    function submitSetMessageFee(bytes memory _vm) external;

    function submitNewGuardianSet(bytes memory _vm) external;

    function submitTransferFees(bytes memory _vm) external;

    function submitRecoverChainId(bytes memory _vm) external;
}
// SPDX-License-Identifier: Unlicense
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity >=0.8.0 <0.9.0;


library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes.slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes.slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}