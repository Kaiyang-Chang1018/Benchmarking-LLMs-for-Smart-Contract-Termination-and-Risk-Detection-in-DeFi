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
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.18;

uint256 constant MIN_INPUT_AMOUNT = 1e14; // 0.0001
uint256 constant MAX_INPUT_AMOUNT = 1e33;
uint256 constant MIN_RESERVE_DEDUCTION = 1e3;
uint256 constant INITIAL_RESERVE_DEDUCTION_DIVIDER = 1e4;
uint256 constant DEFAULT_DECIMALS = 18;
uint256 constant UINT_ONE = 1e18;
uint256 constant UINT_TWO = 2e18;
uint256 constant UINT_FOUR = 4e18;
uint256 constant LP_FEE_PERCENT = 25e14;
uint256 constant STAKE_FEE_PERCENT = 25e14;
uint256 constant PROTOCOL_FEE_PERCENT = 5e15;
uint256 constant MAX_FEE_PERCENT = 1e17;
uint256 constant MAX_INVARIANT_CHANGE = 1e12; //Max allowed change percent: 0.000001 -> 0.0001%
uint256 constant MAX_UTIL_CHANGE = 1e12; //Max allowed change percent: 0.000001 -> 0.0001%

uint256 constant SECONDS_PER_DAY = 864e20;

uint8 constant MAX_ACTION_COUNT = 4;
uint8 constant MAX_FEE_TYPE_COUNT = 3;
uint8 constant MAX_FEE_STATE_FOR_USER_COUNT = 2;
uint8 constant MAX_FEE_STATE_COUNT = 3;
uint8 constant MAX_EMA_STATE_COUNT = 2;

uint8 constant PREVIOUS_EMA_INDEX = 0;
uint8 constant CURRENT_EMA_INDEX = 1;

uint256 constant UTILIZATION = 5e17; // 0.5
uint256 constant UTILIZATION_RECIPROCAL = 2e18;

address constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

//Value map to enum RewardType
uint256 constant REWARD_LP = 0;
uint256 constant REWARD_STAKE = 1;
uint256 constant REWARD_PROTOCOL = 2;

// Value map to enum FeeType
uint256 constant FEE_IBC_FROM_TRADE = 0;
uint256 constant FEE_IBC_FROM_LP = 1;
uint256 constant FEE_RESERVE = 2;
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.18;

struct CurveParameter {
    uint256 reserve;
    uint256 supply;
    uint256 lpSupply;
    uint256 price;
    uint256 parameterInvariant;
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.18;

enum RewardType {
    LP, // 0
    STAKING, // 1
    PROTOCOL // 2
}

enum ActionType {
    BUY_TOKEN,
    SELL_TOKEN,
    ADD_LIQUIDITY,
    REMOVE_LIQUIDITY
}

enum FeeType {
    IBC_FROM_TRADE,
    IBC_FROM_LP, // Fee reward from LP removal(only when mint token to LP)
    RESERVE
}

enum CommandType {
    BUY_TOKEN,
    SELL_TOKEN,
    ADD_LIQUIDITY,
    REMOVE_LIQUIDITY,
    CLAIM_REWARD,
    STAKE,
    UNSTAKE
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.18;

error InputAmountTooSmall(uint256 amount);
error InputAmountTooLarge(uint256 amount);
error ParameterZeroNotAllowed();
error PriceOutOfLimit(uint256 price, uint256[2] priceLimit);
error ReserveOutOfLimit(uint256 reserve, uint256[2] reserveLimit);
error UtilizationInvalid(uint256 parameterUtilization);
error InsufficientBalance();
error EmptyAddress();
error FeePercentOutOfRange();
error FailToSend(address recipient);
error FailToExecute(address pool, bytes data);
error InvalidInput();
error Unauthorized();
error InvariantChanged(uint256 invariant, uint256 newInvariant);
error UtilizationChanged(uint256 newUtilization);
error LpAlreadyExist();
error LpNotExist();
error PoolAlreadyExist();
error CommandUnsupport();
error EtherNotAccept();
error DepositNotAllowed();
error InputBalanceNotMatch();
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.18;

import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/utils/Address.sol";
import "./Enums.sol";
import "./Errors.sol";
import "./interface/IWETH9.sol";
import "./interface/IInverseBondingCurve.sol";

contract InverseBondingCurveRouter {
    using SafeERC20 for IERC20;
    using Address for address;
    using Address for address payable;

    IWETH9 private _weth;

    constructor(address wethAddress) {
        _weth = IWETH9(wethAddress);
    }

    /**
     * @notice  Execute curve function with wrap/unwrap
     * @dev     
     * @param   recipient : Recipient to receive token
     * @param   curve : Curve contract to execute function
     * @param   useNative : Whether using native token(ETH)
     * @param   command : Action command to execute
     * @param   data : Call data of the function call
     */
    function execute(address recipient, address curve, bool useNative, CommandType command, bytes memory data) external payable {
        IInverseBondingCurve curveContract = IInverseBondingCurve(curve);
        IERC20 reserveToken = IERC20(curveContract.reserveTokenAddress());
        IERC20 inverseToken = IERC20(curveContract.inverseTokenAddress());
        // Send back ether if not using ETH for input token
        if (msg.value > 0) {
            if (useNative && address(reserveToken) == address(_weth)) {
                _weth.deposit{value: msg.value}();
                IERC20(_weth).safeTransfer(curve, msg.value);
            } else {
                revert EtherNotAccept();
            }
        }

        uint256 reserveBalanceBefore = reserveToken.balanceOf(address(this));
        uint256 inverseBalanceBefore = inverseToken.balanceOf(address(this));
        _payAndExecute(recipient, curve, useNative, command, reserveToken, inverseToken, data);
        uint256 reserveBalanceAfter = reserveToken.balanceOf(address(this));
        uint256 inverseBalanceAfter = inverseToken.balanceOf(address(this));

        if (inverseBalanceAfter > inverseBalanceBefore) {
            inverseToken.safeTransfer(recipient, inverseBalanceAfter - inverseBalanceBefore);
        }

        if (reserveBalanceAfter > reserveBalanceBefore) {
            uint256 amountToUser = reserveBalanceAfter - reserveBalanceBefore;
            if (useNative && address(reserveToken) == address(_weth)) {
                _weth.withdraw(amountToUser);
                payable(recipient).sendValue(amountToUser);
            } else {
                reserveToken.safeTransfer(recipient, amountToUser);
            }
        }
    }

    /**
     * @notice  Pay curve contract and execute action
     * @dev     
     * @param   recipient : Recipient to receive token
     * @param   curve : Curve contract to execute function
     * @param   useNative : Whether using native token(ETH)
     * @param   command : Action command to execute
     * @param   reserveToken : Reserve token contract address
     * @param   inverseToken : Inverse token contract address
     * @param   data : Call data of the function call
     */
    function _payAndExecute(
        address recipient,
        address curve,
        bool useNative,
        CommandType command,
        IERC20 reserveToken,
        IERC20 inverseToken,
        bytes memory data
    ) private {
        (uint256 reserveTokenAmount, uint256 inverseTokenAmount, bytes memory curveCallData) = _getInputAndCallData(command, data);

        if (reserveTokenAmount > 0) {
            if (!useNative) {
                reserveToken.safeTransferFrom(recipient, curve, reserveTokenAmount);
            }
        }
        if (inverseTokenAmount > 0) {
            inverseToken.safeTransferFrom(recipient, curve, inverseTokenAmount);
        }

        curve.functionCall(curveCallData);
    }

    /**
     * @notice  Get token input amount and calldata to curve contract
     * @dev     
     * @param   command : Action command to execute
     * @param   data : Function call data parameters
     * @return  reserveTokenAmount : Reserve token amount need to transfer to curve contract
     * @return  inverseTokenAmount : Inverse token amount need to transfer to curve contract
     * @return  curveCallData : Call data of the function call
     */
    function _getInputAndCallData(CommandType command, bytes memory data)
        private
        view
        returns (uint256 reserveTokenAmount, uint256 inverseTokenAmount, bytes memory curveCallData)
    {
        if (command == CommandType.ADD_LIQUIDITY) {
            (address recipient, uint256 reserveIn, uint256[2] memory priceLimits) =
                abi.decode(data, (address, uint256, uint256[2]));
            reserveTokenAmount = reserveIn;
            curveCallData = abi.encodeWithSignature("addLiquidity(address,uint256,uint256[2])", recipient, reserveIn, priceLimits);
        } else if (command == CommandType.REMOVE_LIQUIDITY) {
            (, uint256 inverseTokenIn, uint256[2] memory priceLimits) = abi.decode(data, (address, uint256, uint256[2]));
            inverseTokenAmount = inverseTokenIn;
            curveCallData =
                abi.encodeWithSignature("removeLiquidity(address,uint256,uint256[2])", msg.sender, inverseTokenIn, priceLimits);
        } else if (command == CommandType.BUY_TOKEN) {
            (, uint256 reserveIn, uint256 exactAmountOut, uint256[2] memory priceLimits, uint256[2] memory reserveLimits) =
                abi.decode(data, (address, uint256, uint256, uint256[2], uint256[2]));
            reserveTokenAmount = reserveIn;
            curveCallData = abi.encodeWithSignature("buyTokens(address,uint256,uint256,uint256[2],uint256[2])",
                msg.sender, reserveIn, exactAmountOut, priceLimits, reserveLimits);
        } else if (command == CommandType.SELL_TOKEN) {
            (, uint256 inverseTokenIn, uint256[2] memory priceLimits, uint256[2] memory reserveLimits) =
                abi.decode(data, (address, uint256, uint256[2], uint256[2]));
            inverseTokenAmount = inverseTokenIn;
            curveCallData = abi.encodeWithSignature(
                "sellTokens(address,uint256,uint256[2],uint256[2])", msg.sender, inverseTokenIn, priceLimits, reserveLimits
            );
        } else if (command == CommandType.CLAIM_REWARD) {
            curveCallData = abi.encodeWithSignature("claimReward(address)", msg.sender);
        } else if (command == CommandType.STAKE) {
            (, uint256 amount) = abi.decode(data, (address, uint256));
            inverseTokenAmount = amount;
            curveCallData = abi.encodeWithSignature("stake(address,uint256)", msg.sender, amount);
        } else if (command == CommandType.UNSTAKE) {
            (, uint256 amount) = abi.decode(data, (address, uint256));
            curveCallData = abi.encodeWithSignature("unstake(address,uint256)", msg.sender, amount);
        } else {
            revert CommandUnsupport();
        }
    }

    receive() external payable {
        if(msg.sender != address(_weth)){
            revert DepositNotAllowed();
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.18;

import "../CurveParameter.sol";
import "../Enums.sol";
import "../Constants.sol";

/**
 * @title   : Inverse bonding curve contract interface
 * @dev
 * @notice
 */

interface IInverseBondingCurve {
    /// EVENTS ///
    /**
     * @notice  Emitted when curve is initialized
     * @dev     Curve is initialized by deployer contract and initial parameters
     * @param   from : Which account initialized curve contract
     * @param   reserve : Initial reserve
     * @param   supply : Initial supply credit to fee owner
     * @param   initialPrice : Initial IBC token price
     * @param   parameterInvariant : Parameter invariant which won't change during buy/sell: Reserve/ (Supply ** utilization)
     */
    event CurveInitialized(
        address indexed from,
        address indexed reserveTokenAddress,
        uint256 reserve,
        uint256 supply,
        uint256 initialPrice,
        uint256 parameterInvariant
    );

    /**
     * @notice  Emitted when new LP position added
     * @dev     Virtual credited IBC token is assigned to LP
     * @param   from : Account to create LP position
     * @param   recipient : Account to receive LP position and LP reward
     * @param   amountIn : Reserve amount
     * @param   amountOut : LP token amount
     * @param   newParameterInvariant : New parameter invariant after LP added
     */
    event LiquidityAdded(
        address indexed from, address indexed recipient, uint256 amountIn, uint256 amountOut, uint256 newParameterInvariant
    );

    /**
     * @notice  Emitted when LP position removed
     * @dev     Mint IBC to LP if inverseTokenCredit > inverseTokenBurned, otherwise burn IBC from LP
     * @param   from : The account to burn LP
     * @param   recipient : The account to receive reserve
     * @param   amountIn : The LP token amount burned
     * @param   reserveAmountOut : Reserve send to recipient
     * @param   inverseTokenCredit : IBC token credit
     * @param   inverseTokenBurned : IBC token debt which need to burn
     * @param   newParameterInvariant : New parameter invariant after LP removed
     */
    event LiquidityRemoved(
        address indexed from,
        address indexed recipient,
        uint256 amountIn,
        uint256 reserveAmountOut,
        uint256 inverseTokenCredit,
        uint256 inverseTokenBurned,
        uint256 newParameterInvariant
    );

    /**
     * @notice  Emitted when token staked
     * @dev
     * @param   from : Staked from account
     * @param   recipient : Account to stake for, the staked token holder will be changed to recipient
     * @param   amount : Staked token amount
     */
    event TokenStaked(address indexed from, address indexed recipient, uint256 amount);

    /**
     * @notice  Emitted when token unstaked
     * @dev
     * @param   from : Unstaked from account
     * @param   recipient : Account to receive the unstaked IBC token
     * @param   amount : Unstaked token amount
     */
    event TokenUnstaked(address indexed from, address indexed recipient, uint256 amount);

    /**
     * @notice  Emitted when token bought by user
     * @dev
     * @param   from : Buy from account
     * @param   recipient : Account to receive IBC token
     * @param   amountIn : Reserve amount provided
     * @param   amountOut : IBC token bought
     */
    event TokenBought(address indexed from, address indexed recipient, uint256 amountIn, uint256 amountOut);

    /**
     * @notice  Emitted when token sold by user
     * @dev
     * @param   from : Sell from account
     * @param   recipient : Account to receive reserve
     * @param   amountIn : IBC amount provided
     * @param   amountOut : Reserve amount received
     */
    event TokenSold(address indexed from, address indexed recipient, uint256 amountIn, uint256 amountOut);

    /**
     * @notice  Emitted when reward claimed
     * @dev
     * @param   from : Claim from account
     * @param   recipient : Account to recieve reward
     * @param   inverseTokenAmount : IBC token amount of reward
     * @param   reserveAmount : Reserve amount of reward
     */
    event RewardClaimed(address indexed from, address indexed recipient, uint256 inverseTokenAmount, uint256 reserveAmount);

    /**
     * @notice  Add reserve liquidity to inverse bonding curve
     * @dev     LP will get virtual LP token(non-transferable), and one account can only hold one LP position(Need to close and reopen if user want to change)
     * @param   recipient : Account to receive LP token
     * @param   priceLimits : [minPriceLimit, maxPriceLimit], if maxPriceLimit = 0, then no limitation for max price
     */
    function addLiquidity(address recipient, uint256 reserveIn, uint256[2] memory priceLimits) external;

    /**
     * @notice  Remove reserve liquidity from inverse bonding curve
     * @dev     IBC token may needed to burn LP
     * @param   recipient : Account to receive reserve
     * @param   priceLimits :[minPriceLimit, maxPriceLimit], if maxPriceLimit = 0, then no limitation for max price
     */
    function removeLiquidity(address recipient, uint256 inverseTokenIn, uint256[2] memory priceLimits) external;

    /**
     * @notice  Buy IBC token with reserve
     * @dev     If exactAmountOut greater than zero, then it will mint exact token to recipient
     * @param   recipient : Account to receive IBC token
     * @param   exactAmountOut : Exact amount IBC token to mint to user
     * @param   priceLimits : [minPriceLimit, maxPriceLimit], if maxPriceLimit = 0, then no limitation for max price
     * @param   reserveLimits : [minReserveLimit, maxReserveLimit], if maxReserveLimit = 0, then no limitation for max reserve
     */
    function buyTokens(
        address recipient,
        uint256 reserveIn,
        uint256 exactAmountOut,
        uint256[2] memory priceLimits,
        uint256[2] memory reserveLimits
    ) external;

    /**
     * @notice  Sell IBC token to get reserve back
     * @dev
     * @param   recipient : Account to receive reserve
     * @param   inverseTokenIn : IBC token amount to sell
     * @param   priceLimits : [minPriceLimit, maxPriceLimit], if maxPriceLimit = 0, then no limitation for max price
     * @param   reserveLimits : [minReserveLimit, maxReserveLimit], if maxReserveLimit = 0, then no limitation for max reserve
     */
    function sellTokens(address recipient, uint256 inverseTokenIn, uint256[2] memory priceLimits, uint256[2] memory reserveLimits)
        external;

    /**
     * @notice  Stake IBC token to get fee reward
     * @dev
     * @param   amount : Token amount to stake
     */
    function stake(address recipient, uint256 amount) external;

    /**
     * @notice  Unstake staked IBC token
     * @dev
     * @param   amount : Token amount to unstake
     */
    function unstake(address recipient, uint256 amount) external;

    /**
     * @notice  Claim fee reward
     * @dev
     * @param   recipient : Account to receive fee reward
     */
    function claimReward(address recipient) external;

    /**
     * @notice  Query LP position
     * @dev
     * @param   account : Account to query position
     * @return  lpTokenAmount : LP virtual token amount
     * @return  inverseTokenCredit : IBC token credited(Virtual, not able to sell/stake/transfer)
     */
    function liquidityPositionOf(address account) external view returns (uint256 lpTokenAmount, uint256 inverseTokenCredit);

    /**
     * @notice  Query staking balance
     * @dev
     * @param   account : Account address to query
     * @return  uint256 : Staking balance
     */
    function stakingBalanceOf(address account) external view returns (uint256);

    /**
     * @notice  Get IBC token contract address
     * @dev
     * @return  address : IBC token contract address
     */
    function inverseTokenAddress() external view returns (address);

    /**
     * @notice  Query reserve token contract address
     * @dev     
     * @return  address : Reserve token address of curve
     */
    function reserveTokenAddress() external view returns (address);

    /**
     * @notice  Query current inverse bonding curve parameter
     * @dev
     * @return  parameters : See CurveParameter for detail
     */
    function curveParameters() external view returns (CurveParameter memory parameters);

    /**
     * @notice  Query reward of account
     * @dev
     * @param   recipient : Account to query
     * @return  inverseTokenForLp : IBC token reward for account as LP
     * @return  inverseTokenForStaking : IBC token reward for account as Staker
     * @return  reserveForLp : Reserve reward for account as LP
     * @return  reserveForStaking : Reserve reward for account as Staker
     */
    function rewardOf(address recipient)
        external
        view
        returns (uint256 inverseTokenForLp, uint256 inverseTokenForStaking, uint256 reserveForLp, uint256 reserveForStaking);

    /**
     * @notice  Query total staked IBC token amount
     * @dev
     * @return  uint256 : Total staked amount
     */
    function totalStaked() external view returns (uint256);

    /**
     * @notice  Query EMA(exponential moving average) reward per second
     * @dev
     * @param   rewardType : Reward type: LP or staking
     * @return  inverseTokenReward : EMA IBC token reward per second
     * @return  reserveReward : EMA reserve reward per second
     */
    function rewardEMAPerSecond(RewardType rewardType) external view returns (uint256 inverseTokenReward, uint256 reserveReward);

    /**
     * @notice  Query fee state
     * @dev     Each array contains value for IBC, IBC from LP removal, Reserve, and each sub array for LP/Staker/Protocol
     * @return  totalReward : Total IBC token reward
     * @return  totalPendingReward : IBC token reward not claimed
     */
    function rewardState()
        external
        view
        returns (
            uint256[MAX_FEE_TYPE_COUNT][MAX_FEE_STATE_COUNT] memory totalReward,
            uint256[MAX_FEE_TYPE_COUNT][MAX_FEE_STATE_COUNT] memory totalPendingReward
        );
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "openzeppelin/token/ERC20/IERC20.sol";

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}