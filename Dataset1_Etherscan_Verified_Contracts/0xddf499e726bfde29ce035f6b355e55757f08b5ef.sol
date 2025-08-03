// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

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
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (amo/Ramos.sol)

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";

import { IRamos } from "contracts/interfaces/amo/IRamos.sol";
import { IRamosTokenVault } from "contracts/interfaces/amo/helpers/IRamosTokenVault.sol";
import { ITreasuryPriceIndexOracle } from "contracts/interfaces/v2/ITreasuryPriceIndexOracle.sol";
import { IBalancerPoolHelper } from "contracts/interfaces/amo/helpers/IBalancerPoolHelper.sol";
import { IBalancerVault } from "contracts/interfaces/external/balancer/IBalancerVault.sol";
import { IAuraStaking } from "contracts/interfaces/amo/IAuraStaking.sol";
import { IBalancerBptToken } from "contracts/interfaces/external/balancer/IBalancerBptToken.sol";
import { CommonEventsAndErrors } from "contracts/common/CommonEventsAndErrors.sol";

import { TempleElevatedAccess } from "contracts/v2/access/TempleElevatedAccess.sol";
import { AMOCommon } from "contracts/amo/helpers/AMOCommon.sol";

/* solhint-disable not-rely-on-time */

/**
 * @title AMO built for a 50/50 balancer pool
 *
 * @notice RAMOS rebalances the pool to trend towards the Treasury Price Index (TPI).
 * In order to accomplish this:
 *   1. When the price is BELOW the TPI it will either:
 *      - Single side withdraw `protocolToken`
 *      - Single side add `quoteToken`
 *   2. When the price is ABOVE the TPI it will either:
 *      - Single side add `protocolToken`
 *      - Single side withdraw `quoteToken`
 * Any idle BPTs (Balancer LP tokens) are deposited into Aura to earn yield.
 * `protocolToken` can be sourced/disposed of by either having direct mint & burn rights or by
 * pulling and sending tokens to an address.
 */
contract Ramos is IRamos, TempleElevatedAccess, Pausable {
    using SafeERC20 for IERC20;
    using SafeERC20 for IBalancerBptToken;

    /// @notice The Balancer vault singleton
    IBalancerVault public immutable override balancerVault;

    /// @notice BPT token address for this LP
    IBalancerBptToken public immutable override bptToken;

    /// @notice Balancer pool helper contract
    IBalancerPoolHelper public override poolHelper;
    
    /// @notice AMO contract for staking into aura 
    IAuraStaking public immutable override amoStaking;

    /// @notice The Protocol token
    IERC20 public immutable override protocolToken;

    /// @notice The Quoted token this is paired with in the LP. It may be a stable, 
    /// or another Balancer linear token like BB-A-USD
    IERC20 public immutable override quoteToken;

    /// @notice The time when the last rebalance occured
    uint64 public override lastRebalanceTimeSecs;

    /// @notice The minimum amount of time which must pass since `lastRebalanceTimeSecs` before another rebalance
    /// can occur
    uint64 public override cooldownSecs;

    /// @notice The balancer 50/50 pool ID.
    bytes32 public immutable override balancerPoolId;

    /// @notice Precision for BPS calculations. 1% == 100
    uint256 public constant override BPS_PRECISION = 10_000;

    /// @notice The Treasury Price Index (TPI) Oracle
    ITreasuryPriceIndexOracle public override tpiOracle;

    /// @notice The vault from where to borrow and repay the Protocol & Quote Tokens
    IRamosTokenVault public override tokenVault;

    /// @notice The percentage bounds (in bps) beyond which to rebalance up or down
    uint64 public override rebalancePercentageBoundLow;
    uint64 public override rebalancePercentageBoundUp;

    /// @notice Maximum amount of tokens that can be rebalanced on each run
    MaxRebalanceAmounts public override maxRebalanceAmounts;

    /// @notice A limit on how much the price can be impacted by a rebalance. 
    /// A price change over this limit will revert. Specified in bps
    uint64 public override postRebalanceDelta;

    /// @notice `protocolToken` index in balancer pool. to avoid recalculation or external calls
    uint64 public immutable override protocolTokenBalancerPoolIndex;

    /// @notice The address to send proportion of rebalance as fees to
    address public override feeCollector;

    // @notice The maximum rebalance fee which can be set
    uint256 public override immutable maxRebalanceFee;

    /// @notice The fees (in basis points) taken on a rebalance
    RebalanceFees public override rebalanceFees;

    constructor(
        address _initialRescuer,
        address _initialExecutor,
        address _balancerVault,
        address _protocolToken,
        address _quoteToken,
        address _bptToken,
        address _amoStaking,
        uint64 _protocolTokenIndexInPool,
        bytes32 _balancerPoolId,
        address _feeCollector,
        uint256 _maxRebalanceFee
    ) TempleElevatedAccess(_initialRescuer, _initialExecutor) {
        balancerVault = IBalancerVault(_balancerVault);
        protocolToken = IERC20(_protocolToken);
        quoteToken = IERC20(_quoteToken);
        bptToken = IBalancerBptToken(_bptToken);
        amoStaking = IAuraStaking(_amoStaking);
        protocolTokenBalancerPoolIndex = _protocolTokenIndexInPool;
        balancerPoolId = _balancerPoolId;
        feeCollector = _feeCollector;

        if (_maxRebalanceFee > BPS_PRECISION) {
            revert AMOCommon.InvalidBPSValue(_maxRebalanceFee);
        }
        maxRebalanceFee = _maxRebalanceFee;
    }

    /**
     * @notice Set the pool helper contract
     */
    function setPoolHelper(address _poolHelper) external onlyElevatedAccess {
        poolHelper = IBalancerPoolHelper(_poolHelper);

        emit SetPoolHelper(_poolHelper);
    }

    /**
     * @notice Set the acceptable amount of price impact allowed due to a rebalance
     */
    function setPostRebalanceDelta(uint64 deltaBps) external onlyElevatedAccess {
        if (deltaBps > BPS_PRECISION || deltaBps == 0) {
            revert AMOCommon.InvalidBPSValue(deltaBps);
        }
        postRebalanceDelta = deltaBps;
        emit SetPostRebalanceDelta(deltaBps);
    }

    /**
     * @notice Set maximum amount used by bot to rebalance
     * @param bptMaxAmount Maximum bpt amount per rebalance
     * @param quoteTokenMaxAmount Maximum `quoteToken` amount per rebalance
     * @param protocolTokenMaxAmount Maximum protocolToken amount per rebalance
     */
    function setMaxRebalanceAmounts(uint256 bptMaxAmount, uint256 quoteTokenMaxAmount, uint256 protocolTokenMaxAmount) external onlyElevatedAccess {
        if (bptMaxAmount == 0 || quoteTokenMaxAmount == 0 || protocolTokenMaxAmount == 0) {
            revert AMOCommon.InvalidMaxAmounts(bptMaxAmount, quoteTokenMaxAmount, protocolTokenMaxAmount);
        }
        maxRebalanceAmounts.bpt = bptMaxAmount;
        maxRebalanceAmounts.quoteToken = quoteTokenMaxAmount;
        maxRebalanceAmounts.protocolToken = protocolTokenMaxAmount;
        emit SetMaxRebalanceAmounts(bptMaxAmount, quoteTokenMaxAmount, protocolTokenMaxAmount);
    }

    /// @notice Set maximum percentage bounds (in bps) beyond which to rebalance up or down
    function setRebalancePercentageBounds(uint64 belowTpi, uint64 aboveTpi) external onlyElevatedAccess {
        if (belowTpi > BPS_PRECISION || aboveTpi > BPS_PRECISION) {
            revert AMOCommon.InvalidBPSValue(belowTpi);
        }
        rebalancePercentageBoundLow = belowTpi;
        rebalancePercentageBoundUp = aboveTpi;

        emit SetRebalancePercentageBounds(belowTpi, aboveTpi);
    }

    /**
     * @notice Set the Treasury Price Index (TPI) Oracle
     */
    function setTpiOracle(address newTpiOracle) external override onlyElevatedAccess {
        emit TpiOracleSet(newTpiOracle);
        tpiOracle = ITreasuryPriceIndexOracle(newTpiOracle);
    }

    /**
     * @notice Set the token vault - where to borrow and repay the Protocol & Quote Tokens
     */
    function setTokenVault(address vault) external override onlyElevatedAccess {
        emit TokenVaultSet(vault);

        // Remove allowance from the old vault
        address previousVault = address(tokenVault);
        if (previousVault != address(0)) {
            protocolToken.safeApprove(previousVault, 0);
            quoteToken.safeApprove(previousVault, 0);
        }

        tokenVault = IRamosTokenVault(vault);

        // Set max allowance on the new TRV
        {
            protocolToken.safeApprove(vault, 0);
            protocolToken.safeIncreaseAllowance(vault, type(uint256).max);
            
            quoteToken.safeApprove(vault, 0);
            quoteToken.safeIncreaseAllowance(vault, type(uint256).max);
        }
    }

    /**
     * @notice Update the fee collector address - only callable by the existing feeCollector
     */
    function setFeeCollector(address _feeCollector) external {
        if (msg.sender != feeCollector) revert CommonEventsAndErrors.InvalidAccess();
        if (_feeCollector == address(0)) revert CommonEventsAndErrors.InvalidAddress();
        feeCollector = _feeCollector;
        emit FeeCollectorSet(_feeCollector);
    }

    /**
     * @notice Set the rebalance fees, in basis points
     * @param rebalanceJoinFeeBps The fee for when a `rebalanceUpJoin` or `rebalanceDownJoin` is performed
     * @param rebalanceExitFeeBps The fee for when a `rebalanceUpExit` or `rebalanceDownExit` is performed
     */
    function setRebalanceFees(uint256 rebalanceJoinFeeBps, uint256 rebalanceExitFeeBps) external override {
        if (msg.sender != feeCollector) revert CommonEventsAndErrors.InvalidAccess();
        if (rebalanceJoinFeeBps > maxRebalanceFee) revert CommonEventsAndErrors.InvalidParam();
        if (rebalanceExitFeeBps > maxRebalanceFee) revert CommonEventsAndErrors.InvalidParam();

        emit RebalanceFeesSet(rebalanceJoinFeeBps, rebalanceExitFeeBps);

        // Downcast is safe since it can't be set greater than the max.
        rebalanceFees = RebalanceFees(uint128(rebalanceJoinFeeBps), uint128(rebalanceExitFeeBps));
    }

    /**
     * @notice The Treasury Price Index - the target price of the Treasury, in `quoteToken` terms.
     */
    function treasuryPriceIndex() public view override returns (uint96) {
        return tpiOracle.treasuryPriceIndex();
    }

    /**
     * @notice Set cooldown time to throttle rebalances
     * @param _seconds Time in seconds between calls
     */
    function setCoolDown(uint64 _seconds) external onlyElevatedAccess {
        cooldownSecs = _seconds;

        emit SetCooldown(_seconds);
    }
    
    /**
     * @notice Pause AMO
     * */
    function pause() external onlyElevatedAccess {
        _pause();
    }

    /**
     * @notice Unpause AMO
     * */
    function unpause() external onlyElevatedAccess {
        _unpause();
    }

    /**
     * @notice Recover any token from AMO
     * @param token Token to recover
     * @param to Recipient address
     * @param amount Amount to recover
     */
    function recoverToken(address token, address to, uint256 amount) external onlyElevatedAccess {
        IERC20(token).safeTransfer(to, amount);

        emit RecoveredToken(token, to, amount);
    }

    /**
     * @notice Rebalance up when `protocolToken` spot price is below TPI.
     * Single-side WITHDRAW `protocolToken` from balancer liquidity pool to raise price.
     * BPT tokens are withdrawn from Aura rewards staking contract and used for balancer
     * pool exit. 
     * Ramos rebalance fees are deducted from the amount of `protocolToken` returned from the balancer pool
     * The remainder `protocolToken` are repaid to the `tokenVault`
     * @param bptAmountIn amount of BPT tokens going in balancer pool for exit
     * @param minProtocolTokenOut amount of `protocolToken` expected out of balancer pool
     */
    function rebalanceUpExit(
        uint256 bptAmountIn,
        uint256 minProtocolTokenOut
    ) external override onlyElevatedAccess whenNotPaused enoughCooldown {
        _validateParams(minProtocolTokenOut, bptAmountIn, maxRebalanceAmounts.bpt);
        lastRebalanceTimeSecs = uint64(block.timestamp);

        // Unstake and send the BPT to the poolHelper
        IBalancerPoolHelper _poolHelper = poolHelper;
        amoStaking.withdrawAndUnwrap(bptAmountIn, false, address(_poolHelper));
    
        // protocolToken single side exit
        uint256 protocolTokenAmountOut = _poolHelper.exitPool(
            bptAmountIn, minProtocolTokenOut, rebalancePercentageBoundLow,
            rebalancePercentageBoundUp, postRebalanceDelta,
            protocolTokenBalancerPoolIndex, treasuryPriceIndex(), protocolToken
        );

        // Collect the fees on the output protocol token
        uint256 feeAmt = protocolTokenAmountOut * rebalanceFees.rebalanceExitFeeBps / BPS_PRECISION;
        if (feeAmt > 0) {
            protocolToken.safeTransfer(feeCollector, feeAmt);
        }

        // Repay the remaining protocol tokens withdrawn from the pool
        unchecked {
            protocolTokenAmountOut -= feeAmt;
        }
        emit RebalanceUpExit(bptAmountIn, protocolTokenAmountOut, feeAmt);
        if (protocolTokenAmountOut > 0) {
            tokenVault.repayProtocolToken(protocolTokenAmountOut);
        }
    }

    /**
     * @notice Rebalance down when `protocolToken` spot price is above TPI.
     * Single-side WITHDRAW `quoteToken` from balancer liquidity pool to lower price.
     * BPT tokens are withdrawn from Aura rewards staking contract and used for balancer
     * pool exit. 
     * Ramos rebalance fees are deducted from the amount of `quoteToken` returned from the exit
     * The remainder `quoteToken` are repaid via the token vault
     * @param bptAmountIn Amount of BPT tokens to deposit into balancer pool
     * @param minQuoteTokenAmountOut Minimum amount of `quoteToken` expected to receive
     */
    function rebalanceDownExit(
        uint256 bptAmountIn,
        uint256 minQuoteTokenAmountOut
    ) external override onlyElevatedAccess whenNotPaused enoughCooldown {
        _validateParams(minQuoteTokenAmountOut, bptAmountIn, maxRebalanceAmounts.bpt);
        lastRebalanceTimeSecs = uint64(block.timestamp);

        // Unstake and send the BPT to the poolHelper
        IBalancerPoolHelper _poolHelper = poolHelper;
        amoStaking.withdrawAndUnwrap(bptAmountIn, false, address(_poolHelper));

        // QuoteToken single side exit
        uint256 quoteTokenAmountOut = _poolHelper.exitPool(
            bptAmountIn, minQuoteTokenAmountOut, rebalancePercentageBoundLow, rebalancePercentageBoundUp,
            postRebalanceDelta, 1-protocolTokenBalancerPoolIndex, treasuryPriceIndex(), quoteToken
        );

        // Collect the fees on the output quote token
        uint256 feeAmt = quoteTokenAmountOut * rebalanceFees.rebalanceExitFeeBps / BPS_PRECISION;
        if (feeAmt > 0) {
            quoteToken.safeTransfer(feeCollector, feeAmt);
        }

        unchecked {
            quoteTokenAmountOut -= feeAmt;
        }
        emit RebalanceDownExit(bptAmountIn, quoteTokenAmountOut, feeAmt);
        if (quoteTokenAmountOut > 0) {
            tokenVault.repayQuoteToken(quoteTokenAmountOut);
        }
    }

    /**
     * @notice Rebalance up when `protocolToken` spot price is below TPI.
     * Single-side ADD `quoteToken` into the balancer liquidity pool to raise price.
     * Returned BPT tokens are deposited and staked into Aura for rewards using the staking contract.
     * Ramos rebalance fees are deducted from the amount of `quoteToken` input
     * The remainder `quoteToken` are added into the balancer pool
     * @dev The `quoteToken` amount must be deposited into this contract first
     * @param quoteTokenAmountIn Amount of `quoteToken` to deposit into balancer pool
     * @param minBptOut Minimum amount of BPT tokens expected to receive
     */
    function rebalanceUpJoin(
        uint256 quoteTokenAmountIn,
        uint256 minBptOut
    ) external override onlyElevatedAccess whenNotPaused enoughCooldown {
        _validateParams(minBptOut, quoteTokenAmountIn, maxRebalanceAmounts.quoteToken);
        lastRebalanceTimeSecs = uint64(block.timestamp);

        // Borrow the quote token
        tokenVault.borrowQuoteToken(quoteTokenAmountIn, address(this));

        // Collect the fees from the input quote token
        uint256 feeAmt = quoteTokenAmountIn * rebalanceFees.rebalanceJoinFeeBps / BPS_PRECISION;
        if (feeAmt > 0) {
            quoteToken.safeTransfer(feeCollector, feeAmt);
        }

        // Send the remaining quote tokens to the poolHelper
        uint256 joinAmountIn = quoteTokenAmountIn - feeAmt;
        IBalancerPoolHelper _poolHelper = poolHelper;
        quoteToken.safeTransfer(address(_poolHelper), joinAmountIn);

        // quoteToken single side join
        uint256 bptTokensStaked = _poolHelper.joinPool(
            joinAmountIn, minBptOut, rebalancePercentageBoundUp, rebalancePercentageBoundLow,
            treasuryPriceIndex(), postRebalanceDelta, 1-protocolTokenBalancerPoolIndex, quoteToken
        );
        emit RebalanceUpJoin(quoteTokenAmountIn, bptTokensStaked, feeAmt);

        // deposit and stake BPT
        if (bptTokensStaked > 0) {
            bptToken.safeTransfer(address(amoStaking), bptTokensStaked);
            amoStaking.depositAndStake(bptTokensStaked);
        }
    }

    /**
     * @notice Rebalance down when `protocolToken` spot price is above TPI.
     * Single-side ADD `protocolToken` into the balancer liquidity pool to lower price.
     * Returned BPT tokens are deposited and staked into Aura for rewards using the staking contract.
     * Ramos rebalance fees are deducted from the amount of `protocolToken` input
     * The remainder `protocolToken` are added into the balancer pool
     * @dev The `protocolToken` are borrowed from the `tokenVault`
     * @param protocolTokenAmountIn Amount of `protocolToken` tokens to deposit into balancer pool
     * @param minBptOut Minimum amount of BPT tokens expected to receive
     */
    function rebalanceDownJoin(
        uint256 protocolTokenAmountIn,
        uint256 minBptOut
    ) external override onlyElevatedAccess whenNotPaused enoughCooldown {
        _validateParams(minBptOut, protocolTokenAmountIn, maxRebalanceAmounts.protocolToken);
        lastRebalanceTimeSecs = uint64(block.timestamp);

        // Borrow the protocol token
        tokenVault.borrowProtocolToken(protocolTokenAmountIn, address(this));

        // Collect the fees from the input protocol token amount
        uint256 feeAmt = protocolTokenAmountIn * rebalanceFees.rebalanceJoinFeeBps / BPS_PRECISION;
        if (feeAmt > 0) {
            protocolToken.safeTransfer(feeCollector, feeAmt);
        }

        // Send the balance to the poolHelper
        uint256 joinAmountIn = protocolTokenAmountIn - feeAmt;
        IBalancerPoolHelper _poolHelper = poolHelper;
        protocolToken.safeTransfer(address(_poolHelper), joinAmountIn);

        // protocolToken single side join
        uint256 bptTokensStaked = _poolHelper.joinPool(
            joinAmountIn, minBptOut, rebalancePercentageBoundUp,
            rebalancePercentageBoundLow, treasuryPriceIndex(), 
            postRebalanceDelta, protocolTokenBalancerPoolIndex, protocolToken
        );
        emit RebalanceDownJoin(protocolTokenAmountIn, bptTokensStaked, feeAmt);

        // deposit and stake BPT
        if (bptTokensStaked > 0) {
            bptToken.safeTransfer(address(amoStaking), bptTokensStaked);
            amoStaking.depositAndStake(bptTokensStaked);
        }
    }

    /**
     * @notice Add liquidity with both `protocolToken` and `quoteToken` into balancer pool. 
     * TPI is expected to be within bounds of multisig set range.
     * BPT tokens are then deposited and staked in Aura.
     * @param request Request data for joining balancer pool. Assumes userdata of request is
     * encoded with EXACT_TOKENS_IN_FOR_BPT_OUT type
     */
    function addLiquidity(
        IBalancerVault.JoinPoolRequest memory request
    ) external override onlyElevatedAccess returns (
        uint256 quoteTokenAmount,
        uint256 protocolTokenAmount,
        uint256 bptTokensStaked
    ) {
        // validate request
        if (request.assets.length != request.maxAmountsIn.length || 
            request.assets.length != 2 || 
            request.fromInternalBalance) {
                revert AMOCommon.InvalidBalancerVaultRequest();
        }

        (protocolTokenAmount, quoteTokenAmount) = protocolTokenBalancerPoolIndex == 0
            ? (request.maxAmountsIn[0], request.maxAmountsIn[1])
            : (request.maxAmountsIn[1], request.maxAmountsIn[0]);

        IRamosTokenVault _tokenVault = tokenVault;
        _tokenVault.borrowProtocolToken(protocolTokenAmount, address(this));
        _tokenVault.borrowQuoteToken(quoteTokenAmount, address(this));

        // safe allowance quoteToken and protocolToken
        {
            protocolToken.safeIncreaseAllowance(address(balancerVault), protocolTokenAmount);
            uint256 quoteTokenAllowance = quoteToken.allowance(address(this), address(balancerVault));
            if (quoteTokenAllowance < quoteTokenAmount) {
                quoteToken.safeApprove(address(balancerVault), 0);
                quoteToken.safeIncreaseAllowance(address(balancerVault), quoteTokenAmount);
            }
        }

        // join pool
        {
            uint256 bptAmountBefore = bptToken.balanceOf(address(this));
            balancerVault.joinPool(balancerPoolId, address(this), address(this), request);
            uint256 bptAmountAfter = bptToken.balanceOf(address(this));
            unchecked {
                bptTokensStaked = bptAmountAfter - bptAmountBefore;
            }
        }

        emit LiquidityAdded(quoteTokenAmount, protocolTokenAmount, bptTokensStaked);

        // stake BPT
        if (bptTokensStaked > 0) {
            bptToken.safeTransfer(address(amoStaking), bptTokensStaked);
            amoStaking.depositAndStake(bptTokensStaked);
        }
    }

    /**
     * @notice Remove liquidity from balancer pool receiving both `protocolToken` and `quoteToken` from balancer pool. 
     * TPI is expected to be within bounds of multisig set range.
     * Withdraw and unwrap BPT tokens from Aura staking and send to balancer pool to receive both tokens.
     * @param request Request for use in balancer pool exit
     * @param bptIn Amount of BPT tokens to send into balancer pool
     */
    function removeLiquidity(
        IBalancerVault.ExitPoolRequest memory request,
        uint256 bptIn
    ) external override onlyElevatedAccess returns (
        uint256 quoteTokenAmount, 
        uint256 protocolTokenAmount
    ) {
        // validate request
        if (
            request.assets.length != request.minAmountsOut.length || 
            request.assets.length != 2 || 
            request.toInternalBalance
        ) {
            revert AMOCommon.InvalidBalancerVaultRequest();
        }

        uint256 protocolTokenAmountBefore = protocolToken.balanceOf(address(this));
        uint256 quoteTokenAmountBefore = quoteToken.balanceOf(address(this));

        amoStaking.withdrawAndUnwrap(bptIn, false, address(this));
        balancerVault.exitPool(balancerPoolId, address(this), address(this), request);

        unchecked {
            protocolTokenAmount = protocolToken.balanceOf(address(this)) - protocolTokenAmountBefore;
            quoteTokenAmount = quoteToken.balanceOf(address(this)) - quoteTokenAmountBefore;
        }

        IRamosTokenVault _tokenVault = tokenVault;
        if (protocolTokenAmount > 0) {
            _tokenVault.repayProtocolToken(protocolTokenAmount);
        }

        if (quoteTokenAmount > 0) {
            _tokenVault.repayQuoteToken(quoteTokenAmount);
        }

        emit LiquidityRemoved(quoteTokenAmount, protocolTokenAmount, bptIn);
    }

    /**
     * @notice Allow owner to deposit and stake bpt tokens directly
     * @param amount Amount of Bpt tokens to depositt
     * @param useContractBalance If to use bpt tokens in contract
     */
    function depositAndStakeBptTokens(
        uint256 amount,
        bool useContractBalance
    ) external override onlyElevatedAccess {
        if (!useContractBalance) {
            bptToken.safeTransferFrom(msg.sender, address(this), amount);
        }
        bptToken.safeTransfer(address(amoStaking), amount);
        amoStaking.depositAndStake(amount);
        emit DepositAndStakeBptTokens(amount);
    }

    /**
     * @notice The total amount of `protocolToken` and `quoteToken` that Ramos holds via it's 
     * staked and unstaked BPT.
     * @dev Calculated by pulling the total balances of each token in the pool
     * and getting RAMOS proportion of the owned BPT's
     */
    function positions() external override view returns (
        uint256 bptBalance, 
        uint256 protocolTokenBalance, 
        uint256 quoteTokenBalance
    ) {
        // Use `bpt.getActualSupply()` instead of `bpt.totalSupply()`
        // https://docs.balancer.fi/reference/lp-tokens/underlying.html#overview
        // https://docs.balancer.fi/concepts/advanced/valuing-bpt/valuing-bpt.html#on-chain
        uint256 bptTotalSupply = bptToken.getActualSupply();
        if (bptTotalSupply > 0) {
            bptBalance = amoStaking.totalBalance();
            (uint256 totalProtocolTokenInLp, uint256 totalQuoteTokenInLp) = poolHelper.getPairBalances();
            protocolTokenBalance = totalProtocolTokenInLp * bptBalance /bptTotalSupply;
            quoteTokenBalance = totalQuoteTokenInLp * bptBalance /bptTotalSupply;
        }
    }

    function _validateParams(
        uint256 minAmountOut,
        uint256 amountIn,
        uint256 maxRebalanceAmount
    ) internal pure {
        if (minAmountOut == 0) {
            revert AMOCommon.ZeroSwapLimit();
        }
        if (amountIn > maxRebalanceAmount) {
            revert AMOCommon.AboveCappedAmount(amountIn);
        }
    }

    modifier enoughCooldown() {
        if (lastRebalanceTimeSecs + cooldownSecs > block.timestamp) {
            revert AMOCommon.NotEnoughCooldown();
        }
        _;
    }
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (amo/helpers/AMOCommon.sol)

library AMOCommon {
    error NotOperator();
    error NotOperatorOrOwner();
    error ZeroSwapLimit();
    error OnlyAMO();
    error AboveCappedAmount(uint256 amountIn);
    error InsufficientBPTAmount(uint256 amount);
    error InvalidBPSValue(uint256 value);
    error InvalidMaxAmounts(uint256 bptMaxAmount, uint256 stableMaxAmount, uint256 templeMaxAmount);
    error InvalidBalancerVaultRequest();
    error NotEnoughCooldown();
    error NoRebalanceUp();
    error NoRebalanceDown();
    error HighSlippage();
    error Paused();
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (common/CommonEventsAndErrors.sol)

/// @notice A collection of common errors thrown within the Temple contracts
library CommonEventsAndErrors {
    error InsufficientBalance(address token, uint256 required, uint256 balance);
    error InvalidParam();
    error InvalidAddress();
    error InvalidAccess();
    error InvalidAmount(address token, uint256 amount);
    error ExpectedNonZero();
    error Unimplemented();
    event TokenRecovered(address indexed to, address indexed token, uint256 amount);
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (interfaces/external/aura/IAuraStaking.sol)

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IAuraBooster } from "contracts/interfaces/external/aura/IAuraBooster.sol";

interface IAuraStaking {
    struct AuraPoolInfo {
        address token;
        address rewards;
        uint32 pId;
    }

    struct Position {
        uint256 staked;
        uint256 earned;
    }

    event SetAuraPoolInfo(uint32 indexed pId, address token, address rewards);
    event RecoveredToken(address token, address to, uint256 amount);
    event SetRewardsRecipient(address recipient);
    event RewardTokensSet(address[] rewardTokens);

    function bptToken() external view returns (IERC20);
    function auraPoolInfo() external view returns (
        address token,
        address rewards,
        uint32 pId
    );
    function booster() external view returns (IAuraBooster);

    function rewardsRecipient() external view returns (address);
    function rewardTokens(uint256 index) external view returns (address);
    
    function setAuraPoolInfo(uint32 _pId, address _token, address _rewards) external;

    function setRewardsRecipient(address _recipeint) external;

    function setRewardTokens(address[] memory _rewardTokens) external;

    function recoverToken(address token, address to, uint256 amount) external;
    function isAuraShutdown() external view returns (bool);

    function depositAndStake(uint256 amount) external;

    function withdrawAndUnwrap(uint256 amount, bool claim, address recipient) external;

    function withdrawAllAndUnwrap(bool claim, address recipient) external;

    function getReward(bool claimExtras) external;

    function stakedBalance() external view returns (uint256);

    /**
     * @notice The total balance of BPT owned by this contract - either staked in Aura 
     * or unstaked
     */
    function totalBalance() external view returns (uint256);

    function earned() external view returns (uint256);

    function showPositions() external view returns (Position memory position);
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (interfaces/amo/IRamos.sol)

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IBalancerVault } from "contracts/interfaces/external/balancer/IBalancerVault.sol";
import { IBalancerBptToken } from "contracts/interfaces/external/balancer/IBalancerBptToken.sol";
import { IBalancerPoolHelper } from "contracts/interfaces/amo/helpers/IBalancerPoolHelper.sol";
import { IAuraStaking } from "contracts/interfaces/amo/IAuraStaking.sol";
import { ITreasuryPriceIndexOracle } from "contracts/interfaces/v2/ITreasuryPriceIndexOracle.sol";
import { IRamosTokenVault } from "contracts/interfaces/amo/helpers/IRamosTokenVault.sol";

/**
 * @title AMO built for a 50/50 balancer pool
 *
 * @notice RAMOS rebalances the pool to trend towards the Treasury Price Index (TPI).
 * In order to accomplish this:
 *   1. When the price is BELOW the TPI it will either:
 *      - Single side withdraw `protocolToken`
 *      - Single side add `quoteToken`
 *   2. When the price is ABOVE the TPI it will either:
 *      - Single side add `protocolToken`
 *      - Single side withdraw `quoteToken`
 * Any idle BPTs (Balancer LP tokens) are deposited into Aura to earn yield.
 * `protocolToken` can be sourced/disposed of by either having direct mint & burn rights or by
 * pulling and sending tokens to an address.
 */
interface IRamos {
    struct MaxRebalanceAmounts {
        uint256 bpt;
        uint256 quoteToken;
        uint256 protocolToken;
    }

    struct RebalanceFees {
        uint128 rebalanceJoinFeeBps;
        uint128 rebalanceExitFeeBps;
    }

    // Admin events
    event RecoveredToken(address token, address to, uint256 amount);
    event SetPostRebalanceDelta(uint64 deltaBps);
    event SetCooldown(uint64 cooldownSecs);
    event SetRebalancePercentageBounds(uint64 belowTpi, uint64 aboveTpi);
    event TpiOracleSet(address indexed tpiOracle);
    event TokenVaultSet(address indexed vault);
    event SetPoolHelper(address poolHelper);
    event SetMaxRebalanceAmounts(uint256 bptMaxAmount, uint256 quoteTokenMaxAmount, uint256 protocolTokenMaxAmount);
    event RebalanceFeesSet(uint256 rebalanceJoinFeeBps, uint256 rebalanceExitFeeBps);
    event FeeCollectorSet(address indexed feeCollector);

    // Rebalance events
    event RebalanceUpExit(uint256 bptAmountIn, uint256 protocolTokenRepaid, uint256 protocolTokenFee);
    event RebalanceDownExit(uint256 bptAmountIn, uint256 quoteTokenRepaid, uint256 quoteTokenFee);
    event RebalanceUpJoin(uint256 quoteTokenAmountIn, uint256 bptTokensStaked, uint256 quoteTokenFee);
    event RebalanceDownJoin(uint256 protocolTokenAmountIn, uint256 bptTokensStaked, uint256 protocolTokenFee);

    // Add/remove liquidity events
    event LiquidityAdded(uint256 quoteTokenAdded, uint256 protocolTokenAdded, uint256 bptReceived);
    event LiquidityRemoved(uint256 quoteTokenReceived, uint256 protocolTokenReceived, uint256 bptRemoved);
    event DepositAndStakeBptTokens(uint256 bptAmount);
    
    /// @notice The Balancer vault singleton
    function balancerVault() external view returns (IBalancerVault);

    /// @notice BPT token address for this LP
    function bptToken() external view returns (IBalancerBptToken);

    /// @notice Balancer pool helper contract
    function poolHelper() external view returns (IBalancerPoolHelper);

    /// @notice AMO contract for staking into aura 
    function amoStaking() external view returns (IAuraStaking);
  
    /// @notice The Protocol token  
    function protocolToken() external view returns (IERC20);

    /// @notice The quoteToken this is paired with in the LP. It may be a stable, 
    /// or another Balancer linear token like BB-A-USD
    function quoteToken() external view returns (IERC20);

    /// @notice The time when the last rebalance occured
    function lastRebalanceTimeSecs() external view returns (uint64);

    /// @notice The minimum amount of time which must pass since `lastRebalanceTimeSecs` before another rebalance
    /// can occur
    function cooldownSecs() external view returns (uint64);

    /// @notice The balancer 50/50 pool ID.
    function balancerPoolId() external view returns (bytes32);

    /// @notice Precision for BPS calculations. 1% == 100
    // solhint-disable-next-line func-name-mixedcase
    function BPS_PRECISION() external view returns (uint256);

    /// @notice The percentage bounds (in bps) beyond which to rebalance up or down
    function rebalancePercentageBoundLow() external view returns (uint64);
    function rebalancePercentageBoundUp() external view returns (uint64);

    /// @notice Maximum amount of tokens that can be rebalanced on each run
    function maxRebalanceAmounts() external view returns (
        uint256 bpt,
        uint256 quoteToken,
        uint256 protocolToken
    );

    /// @notice A limit on how much the price can be impacted by a rebalance. 
    /// A price change over this limit will revert. Specified in bps
    function postRebalanceDelta() external view returns (uint64);

    /// @notice protocolToken index in balancer pool. to avoid recalculation or external calls
    function protocolTokenBalancerPoolIndex() external view returns (uint64);

    /**
     * @notice The address to send proportion of rebalance as fees to
     */
    function feeCollector() external view returns (address);

    /**
     * @notice The maximum rebalance fee which can be set
     */
    function maxRebalanceFee() external view returns (uint256);

    /**
     * @notice The fees (in basis points) taken on a rebalance
     */
    function rebalanceFees() external view returns (
        uint128 rebalanceJoinFeeBps, 
        uint128 rebalanceExitFeeBps
    );

    /**
     * @notice Set the rebalance fees, in basis points
     * @param rebalanceJoinFeeBps The fee for when a `rebalanceUpJoin` or `rebalanceDownJoin` is performed
     * @param rebalanceExitFeeBps The fee for when a `rebalanceUpExit` or `rebalanceDownExit` is performed
     */
    function setRebalanceFees(uint256 rebalanceJoinFeeBps, uint256 rebalanceExitFeeBps) external;

    /**
     * @notice The Treasury Price Index (TPI) Oracle
     */
    function tpiOracle() external view returns (ITreasuryPriceIndexOracle);

    /**
     * @notice Set the Treasury Price Index (TPI) Oracle
     */
    function setTpiOracle(address tpiOracleAddress) external;

    /**
     * @notice The vault from where to borrow and repay the Protocol Token
     */
    function tokenVault() external view returns (IRamosTokenVault);

    /**
     * @notice Set the Treasury Price Index (TPI) Oracle
     */
    function setTokenVault(address vault) external;

    /**
     * @notice The Treasury Price Index - the target price of the Treasury, in `quoteTokenToken` terms.
     */
    function treasuryPriceIndex() external view returns (uint96);

    /**
     * @notice Rebalance up when `protocolToken` spot price is below TPI.
     * Single-side WITHDRAW `protocolToken` from balancer liquidity pool to raise price.
     * BPT tokens are withdrawn from Aura rewards staking contract and used for balancer
     * pool exit. 
     * Ramos rebalance fees are deducted from the amount of `protocolToken` returned from the exit
     * The remainder `protocolToken` are repaid to the `TokenVault`
     * @param bptAmountIn amount of BPT tokens going in balancer pool for exit
     * @param minProtocolTokenOut amount of `protocolToken` expected out of balancer pool
     */
    function rebalanceUpExit(
        uint256 bptAmountIn,
        uint256 minProtocolTokenOut
    ) external;

    /**
     * @notice Rebalance down when `protocolToken` spot price is above TPI.
     * Single-side WITHDRAW `quoteToken` from balancer liquidity pool to lower price.
     * BPT tokens are withdrawn from Aura rewards staking contract and used for balancer
     * pool exit. 
     * Ramos rebalance fees are deducted from the amount of `quoteToken` returned from the exit
     * The remainder `quoteToken` are repaid via the token vault
     * @param bptAmountIn Amount of BPT tokens to deposit into balancer pool
     * @param minQuoteTokenAmountOut Minimum amount of `quoteToken` expected to receive
     */
    function rebalanceDownExit(
        uint256 bptAmountIn,
        uint256 minQuoteTokenAmountOut
    ) external;

    /**
     * @notice Rebalance up when `protocolToken` spot price is below TPI.
     * Single-side ADD `quoteToken` into the balancer liquidity pool to raise price.
     * Returned BPT tokens are deposited and staked into Aura for rewards using the staking contract.
     * Ramos rebalance fees are deducted from the amount of `quoteToken` input
     * The remainder `quoteToken` are added into the balancer pool
     * @dev The `quoteToken` amount must be deposited into this contract first
     * @param quoteTokenAmountIn Amount of `quoteToken` to deposit into balancer pool
     * @param minBptOut Minimum amount of BPT tokens expected to receive
     */
    function rebalanceUpJoin(
        uint256 quoteTokenAmountIn,
        uint256 minBptOut
    ) external;

    /**
     * @notice Rebalance down when `protocolToken` spot price is above TPI.
     * Single-side ADD `protocolToken` into the balancer liquidity pool to lower price.
     * Returned BPT tokens are deposited and staked into Aura for rewards using the staking contract.
     * Ramos rebalance fees are deducted from the amount of `protocolToken` input
     * The remainder `protocolToken` are added into the balancer pool
     * @dev The `protocolToken` are borrowed from the `TokenVault`
     * @param protocolTokenAmountIn Amount of `protocolToken` tokens to deposit into balancer pool
     * @param minBptOut Minimum amount of BPT tokens expected to receive
     */
    function rebalanceDownJoin(
        uint256 protocolTokenAmountIn,
        uint256 minBptOut
    ) external;

    /**
     * @notice Add liquidity with both `protocolToken` and `quoteToken` into balancer pool. 
     * TPI is expected to be within bounds of multisig set range.
     * BPT tokens are then deposited and staked in Aura.
     * @param request Request data for joining balancer pool. Assumes userdata of request is
     * encoded with EXACT_TOKENS_IN_FOR_BPT_OUT type
     */
    function addLiquidity(
        IBalancerVault.JoinPoolRequest memory request
    ) external returns (
        uint256 quoteTokenAmount,
        uint256 protocolTokenAmount,
        uint256 bptTokensStaked
    );
    
    /**
     * @notice Remove liquidity from balancer pool receiving both `protocolToken` and `quoteToken` from balancer pool. 
     * TPI is expected to be within bounds of multisig set range.
     * Withdraw and unwrap BPT tokens from Aura staking and send to balancer pool to receive both tokens.
     * @param request Request for use in balancer pool exit
     * @param bptIn Amount of BPT tokens to send into balancer pool
     */
    function removeLiquidity(
        IBalancerVault.ExitPoolRequest memory request, 
        uint256 bptIn
    ) external returns (
        uint256 quoteTokenAmount,
        uint256 protocolTokenAmount
    );

    /**
     * @notice Allow owner to deposit and stake bpt tokens directly
     * @param amount Amount of Bpt tokens to depositt
     * @param useContractBalance If to use bpt tokens in contract
     */
    function depositAndStakeBptTokens(
        uint256 amount,
        bool useContractBalance
    ) external;

    /**
     * @notice The total amount of `protocolToken` and `quoteToken` that Ramos holds via it's 
     * staked and unstaked BPT.
     * @dev Calculated by pulling the total balances of each token in the pool
     * and getting RAMOS proportion of the owned BPT's
     */
    function positions() external view returns (
        uint256 bptBalance, 
        uint256 protoclTokenBalance, 
        uint256 quoteTokenBalance
    );
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (interfaces/amo/helpers/IBalancerPoolHelper.sol)

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IBalancerVault } from "contracts/interfaces/external/balancer/IBalancerVault.sol";
import { IBalancerHelpers } from "contracts/interfaces/external/balancer/IBalancerHelpers.sol";

interface IBalancerPoolHelper {

    function balancerVault() external view returns (IBalancerVault);
    function balancerHelpers() external view returns (IBalancerHelpers);
    function bptToken() external view returns (IERC20);
    function protocolToken() external view returns (IERC20);
    function quoteToken() external view returns (IERC20);
    function amo() external view returns (address);
    
    function BPS_PRECISION() external view returns (uint256);
    function PRICE_PRECISION() external view returns (uint256);

    // @notice protocolToken index in balancer pool
    function protocolTokenIndexInBalancerPool() external view returns (uint64);
    function balancerPoolId() external view returns (bytes32);

    function getBalances() external view returns (uint256[] memory balances);

    function getPairBalances() external view returns (uint256 protocolTokenBalance, uint256 quoteTokenBalance);

    function getSpotPrice() external view returns (uint256 spotPriceScaled);

    function isSpotPriceBelowTpi(uint256 treasuryPriceIndex) external view returns (bool);

    function isSpotPriceBelowTpi(uint256 slippage, uint256 treasuryPriceIndex) external view returns (bool);

    function isSpotPriceBelowTpiLowerBound(uint256 rebalancePercentageBoundLow, uint256 treasuryPriceIndex) external view returns (bool);

    function isSpotPriceAboveTpiUpperBound(uint256 rebalancePercentageBoundUp, uint256 treasuryPriceIndex) external view returns (bool);
    
    function isSpotPriceAboveTpi(uint256 slippage, uint256 treasuryPriceIndex) external view returns (bool);

    function isSpotPriceAboveTpi(uint256 treasuryPriceIndex) external view returns (bool);

    // @notice will exit take price above TPI by a percentage
    // percentage in bps
    // tokensOut: expected min amounts out. for rebalance this is expected `ProtocolToken` tokens out
    function willExitTakePriceAboveTpiUpperBound(
        uint256 tokensOut,
        uint256 rebalancePercentageBoundUp,
        uint256 treasuryPriceIndex
    ) external view returns (bool);

    function willQuoteTokenJoinTakePriceAboveTpiUpperBound(
        uint256 tokensIn,
        uint256 rebalancePercentageBoundUp,
        uint256 treasuryPriceIndex
    ) external view returns (bool);

    function willQuoteTokenExitTakePriceBelowTpiLowerBound(
        uint256 tokensOut,
        uint256 rebalancePercentageBoundLow,
        uint256 treasuryPriceIndex
    ) external view returns (bool);

    function willJoinTakePriceBelowTpiLowerBound(
        uint256 tokensIn,
        uint256 rebalancePercentageBoundLow,
        uint256 treasuryPriceIndex
    ) external view returns (bool);

    function getSlippage(uint256 spotPriceBeforeScaled) external view returns (uint256);

    function exitPool(
        uint256 bptAmountIn,
        uint256 minAmountOut,
        uint256 rebalancePercentageBoundLow,
        uint256 rebalancePercentageBoundUp,
        uint256 postRebalanceDelta,
        uint256 exitTokenIndex,
        uint256 treasuryPriceIndex,
        IERC20 exitPoolToken
    ) external returns (uint256 amountOut);

    function joinPool(
        uint256 amountIn,
        uint256 minBptOut,
        uint256 rebalancePercentageBoundUp,
        uint256 rebalancePercentageBoundLow,
        uint256 treasuryPriceIndex,
        uint256 postRebalanceDelta,
        uint256 joinTokenIndex,
        IERC20 joinPoolToken
    ) external returns (uint256 bptIn);

    /// @notice Get the quote used to add liquidity proportionally
    /// @dev Since this is not the view function, this should be called with `callStatic`
    function proportionalAddLiquidityQuote(
        uint256 quoteTokenAmount,
        uint256 slippageBps
    ) external returns (
        uint256 protocolTokenAmount,
        uint256 expectedBptAmount,
        uint256 minBptAmount,
        IBalancerVault.JoinPoolRequest memory requestData
    );

    /// @notice Get the quote used to remove liquidity
    /// @dev Since this is not the view function, this should be called with `callStatic`
    function proportionalRemoveLiquidityQuote(
        uint256 bptAmount,
        uint256 slippageBps
    ) external returns (
        uint256 expectedProtocolTokenAmount,
        uint256 expectedQuoteTokenAmount,
        uint256 minProtocolTokenAmount,
        uint256 minQuoteTokenAmount,
        IBalancerVault.ExitPoolRequest memory requestData
    );

    function applySlippage(uint256 amountIn, uint256 slippageBps) external view returns (uint256 amountOut);

}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (interfaces/amo/helpers/IRamosTokenVault.sol)

/**
 * @title Ramos Token Vault
 *
 * @notice A vault to provide protocol and quote tokens to Ramos as it rebalances or updates liquidity.
 * These two tokens are the pair of tokens in a liquidity pool, eg:
 *   protocolToken = TEMPLE
 *   quoteToken = DAI
 */
interface IRamosTokenVault {
    /**
     * @notice Send `protocolToken` to recipient
     * @param amount The requested amount to borrow
     * @param recipient The recipient to send the `protocolToken` tokens to
     */
    function borrowProtocolToken(uint256 amount, address recipient) external;    

    /**
     * @notice Send `quoteToken` to recipient
     * @param amount The requested amount to borrow
     * @param recipient The recipient to send the `quoteToken` tokens to
     */
    function borrowQuoteToken(uint256 amount, address recipient) external;

    /**
     * @notice Pull `protocolToken` from the caller
     * @param amount The requested amount to repay
     */
    function repayProtocolToken(uint256 amount) external;

    /**
     * @notice Pull `quoteToken` from the caller
     * @param amount The requested amount to repay
     */
    function repayQuoteToken(uint256 amount) external;
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (interfaces/external/aura/IAuraBooster.sol)

interface IAuraBooster {

    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }
    function poolInfo(uint256 _pid) external view returns (PoolInfo memory);
    function isShutdown() external view returns (bool);

    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns (bool);
    function depositAll(uint256 _pid, bool _stake) external returns(bool);
    function earmarkRewards(uint256 _pid) external returns(bool);
    function claimRewards(uint256 _pid, address _gauge) external returns(bool);
    function earmarkFees(address _feeToken) external returns(bool);
    function minter() external view returns (address);

    event Deposited(address indexed user, uint256 indexed poolid, uint256 amount);
    event Withdrawn(address indexed user, uint256 indexed poolid, uint256 amount);
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (interfaces/external/balancer/IBalancerBptToken.sol)

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBalancerBptToken is IERC20 {
    function getActualSupply() external view returns (uint256);
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (interfaces/external/balancer/IBalancerHelpers.sol)

import { IBalancerVault } from "contracts/interfaces/external/balancer/IBalancerVault.sol";

interface IBalancerHelpers {
    function queryJoin(
        bytes32 poolId,
        address sender,
        address recipient,
        IBalancerVault.JoinPoolRequest memory request
    ) external returns (uint256 bptOut, uint256[] memory amountsIn);

    function queryExit(
        bytes32 poolId,
        address sender,
        address recipient,
        IBalancerVault.ExitPoolRequest memory request
    ) external returns (uint256 bptIn, uint256[] memory amountsOut);
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (interfaces/external/balancer/IBalancerVault.sol)

interface IBalancerVault {

  struct JoinPoolRequest {
    address[] assets;
    uint256[] maxAmountsIn;
    bytes userData;
    bool fromInternalBalance;
  }

  struct ExitPoolRequest {
    address[] assets;
    uint256[] minAmountsOut;
    bytes userData;
    bool toInternalBalance;
  }

  struct BatchSwapStep {
    bytes32 poolId;
    uint256 assetInIndex;
    uint256 assetOutIndex;
    uint256 amount;
    bytes userData;
  }

  struct FundManagement {
    address sender;
    bool fromInternalBalance;
    address payable recipient;
    bool toInternalBalance;
  }

  enum JoinKind { 
    INIT, 
    EXACT_TOKENS_IN_FOR_BPT_OUT, 
    TOKEN_IN_FOR_EXACT_BPT_OUT, 
    ALL_TOKENS_IN_FOR_EXACT_BPT_OUT 
  }

  enum SwapKind {
    GIVEN_IN,
    GIVEN_OUT
  }

  function batchSwap(
    SwapKind kind,
    BatchSwapStep[] memory swaps,
    address[] memory assets,
    FundManagement memory funds,
    int256[] memory limits,
    uint256 deadline
  ) external returns (int256[] memory assetDeltas);

  function joinPool(
    bytes32 poolId,
    address sender,
    address recipient,
    JoinPoolRequest memory request
  ) external payable;

  function exitPool( 
    bytes32 poolId, 
    address sender, 
    address recipient, 
    ExitPoolRequest memory request 
  ) external;

  function getPoolTokens(
    bytes32 poolId
  ) external view
    returns (
      address[] memory tokens,
      uint256[] memory balances,
      uint256 lastChangeBlock
  );
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (interfaces/v2/ITreasuryPriceIndexOracle.sol)

import { ITempleElevatedAccess } from "contracts/interfaces/v2/access/ITempleElevatedAccess.sol";

/**
 * @title Treasury Price Index Oracle
 * @notice The custom oracle (not dependant on external markets/AMMs/dependencies) to give the
 * Treasury Price Index, representing the target Treasury Value per token.
 * This rate is updated manually with elevated permissions. The new TPI doesn't take effect until after a cooldown.
 */
interface ITreasuryPriceIndexOracle is ITempleElevatedAccess {
    event TreasuryPriceIndexSet(uint96 oldTpi, uint96 newTpi);
    event TpiCooldownSet(uint32 cooldownSecs);
    event MaxTreasuryPriceIndexDeltaSet(uint256 maxDelta);

    error BreachedMaxTpiDelta(uint96 oldTpi, uint96 newTpi, uint256 maxDelta);

    /**
     * @notice The current Treasury Price Index (TPI) value
     * @dev If the TPI has just been updated, the old TPI will be used until `cooldownSecs` has elapsed
     */
    function treasuryPriceIndex() external view returns (uint96);

    /**
     * @notice The maximum allowed TPI change on any single `setTreasuryPriceIndex()`, in absolute terms.
     * @dev Used as a bound to avoid unintended/fat fingering when updating TPI
     */
    function maxTreasuryPriceIndexDelta() external view returns (uint256);

    /**
     * @notice The current internal TPI data along with when it was last reset, and the prior value
     */
    function tpiData() external view returns (
        uint96 currentTpi,
        uint96 previousTpi,
        uint32 lastUpdatedAt,
        uint32 cooldownSecs
    );

    /**
     * @notice Set the Treasury Price Index (TPI)
     */
    function setTreasuryPriceIndex(uint96 value) external;

    /**
     * @notice Set the number of seconds to elapse before a new TPI will take effect.
     */
    function setTpiCooldown(uint32 cooldownSecs) external;

    /**
     * @notice Set the maximum allowed TPI change on any single `setTreasuryPriceIndex()`, in absolute terms.
     * @dev 18 decimal places, 0.20e18 == $0.20
     */
    function setMaxTreasuryPriceIndexDelta(uint256 maxDelta) external;

    /**
     * @notice The decimal precision of Temple Price Index (TPI)
     * @dev 18 decimals, so 1.02e18 == $1.02
     */
    // solhint-disable-next-line func-name-mixedcase
    function TPI_DECIMALS() external view returns (uint256);
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (interfaces/v2/access/ITempleElevatedAccess.sol)

/**
 * @notice Inherit to add Executor and Rescuer roles for DAO elevated access.
 */ 
interface ITempleElevatedAccess {
    event ExplicitAccessSet(address indexed account, bytes4 indexed fnSelector, bool indexed value);
    event RescueModeSet(bool indexed value);

    event NewRescuerProposed(address indexed oldRescuer, address indexed oldProposedRescuer, address indexed newProposedRescuer);
    event NewRescuerAccepted(address indexed oldRescuer, address indexed newRescuer);

    event NewExecutorProposed(address indexed oldExecutor, address indexed oldProposedExecutor, address indexed newProposedExecutor);
    event NewExecutorAccepted(address indexed oldExecutor, address indexed newExecutor);

    struct ExplicitAccess {
        bytes4 fnSelector;
        bool allowed;
    }

    /**
     * @notice A set of addresses which are approved to execute emergency operations.
     */ 
    function rescuer() external returns (address);

    /**
     * @notice A set of addresses which are approved to execute normal operations on behalf of the DAO.
     */ 
    function executor() external returns (address);

    /**
     * @notice Explicit approval for an address to execute a function.
     * allowedCaller => function selector => true/false
     */
    function explicitFunctionAccess(address contractAddr, bytes4 functionSelector) external returns (bool);

    /**
     * @notice Under normal circumstances, rescuers don't have access to admin/operational functions.
     * However when rescue mode is enabled (by rescuers or executors), they claim the access rights.
     */
    function inRescueMode() external returns (bool);
    
    /**
     * @notice Set the contract into or out of rescue mode.
     * Only the rescuers or executors are allowed to set.
     */
    function setRescueMode(bool value) external;

    /**
     * @notice Proposes a new Rescuer.
     * Can only be called by the current rescuer.
     */
    function proposeNewRescuer(address account) external;

    /**
     * @notice Caller accepts the role as new Rescuer.
     * Can only be called by the proposed rescuer
     */
    function acceptRescuer() external;

    /**
     * @notice Proposes a new Executor.
     * Can only be called by the current executor or resucer (if in resuce mode)
     */
    function proposeNewExecutor(address account) external;

    /**
     * @notice Caller accepts the role as new Executor.
     * Can only be called by the proposed executor
     */
    function acceptExecutor() external;

    /**
     * @notice Grant `allowedCaller` the rights to call the function selectors in the access list.
     * @dev fnSelector == bytes4(keccak256("fn(argType1,argType2,...)"))
     */
    function setExplicitAccess(address allowedCaller, ExplicitAccess[] calldata access) external;
}
pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Temple (v2/access/TempleElevatedAccess.sol)

import { ITempleElevatedAccess } from "contracts/interfaces/v2/access/ITempleElevatedAccess.sol";
import { CommonEventsAndErrors } from "contracts/common/CommonEventsAndErrors.sol";

/**
 * @notice Inherit to add Executor and Rescuer roles for DAO elevated access.
 */ 
abstract contract TempleElevatedAccess is ITempleElevatedAccess {
    /**
     * @notice The address which is approved to execute emergency operations.
     */ 
    address public override rescuer;

    /**
     * @notice The address which is approved to execute normal operations on behalf of the DAO.
     */ 
    address public override executor;

    /**
     * @notice Explicit approval for an address to execute a function.
     * allowedCaller => function selector => true/false
     */
    mapping(address => mapping(bytes4 => bool)) public override explicitFunctionAccess;

    /**
     * @notice Under normal circumstances, rescuers don't have access to admin/operational functions.
     * However when rescue mode is enabled (by rescuers or executors), they claim the access rights.
     */
    bool public override inRescueMode;

    /// @dev Track proposed rescuer/executor
    address private _proposedNewRescuer;
    address private _proposedNewExecutor;

    constructor(address initialRescuer, address initialExecutor) {
        if (initialRescuer == address(0)) revert CommonEventsAndErrors.InvalidAddress();
        if (initialExecutor == address(0)) revert CommonEventsAndErrors.InvalidAddress();
        if (initialExecutor == initialRescuer) revert CommonEventsAndErrors.InvalidAddress();

        rescuer = initialRescuer;
        executor = initialExecutor;
    }

    /**
     * @notice Set the contract into or out of rescue mode.
     * Only the rescuers are allowed to set.
     */
    function setRescueMode(bool value) external override {
        if (msg.sender != rescuer) revert CommonEventsAndErrors.InvalidAccess();
        emit RescueModeSet(value);
        inRescueMode = value;
    }

    /**
     * @notice Proposes a new Rescuer.
     * Can only be called by the current rescuer.
     */
    function proposeNewRescuer(address account) external override {
        if (msg.sender != rescuer) revert CommonEventsAndErrors.InvalidAccess();
        if (account == address(0)) revert CommonEventsAndErrors.InvalidAddress();
        emit NewRescuerProposed(msg.sender, _proposedNewRescuer, account);
        _proposedNewRescuer = account;
    }

    /**
     * @notice Caller accepts the role as new Rescuer.
     * Can only be called by the proposed rescuer
     */
    function acceptRescuer() external override {
        if (msg.sender != _proposedNewRescuer) revert CommonEventsAndErrors.InvalidAccess();
        if (msg.sender == executor) revert CommonEventsAndErrors.InvalidAddress();

        emit NewRescuerAccepted(rescuer, msg.sender);
        rescuer = msg.sender;
        delete _proposedNewRescuer;
    }

    /**
     * @notice Proposes a new Executor.
     * Can only be called by the current executor or rescuer (if in resuce mode)
     */
    function proposeNewExecutor(address account) external override onlyElevatedAccess {
        if (account == address(0)) revert CommonEventsAndErrors.InvalidAddress();
        emit NewExecutorProposed(executor, _proposedNewExecutor, account);
        _proposedNewExecutor = account;
    }

    /**
     * @notice Caller accepts the role as new Executor.
     * Can only be called by the proposed executor
     */
    function acceptExecutor() external override {
        if (msg.sender != _proposedNewExecutor) revert CommonEventsAndErrors.InvalidAccess();
        if (msg.sender == rescuer) revert CommonEventsAndErrors.InvalidAddress();

        emit NewExecutorAccepted(executor, msg.sender);
        executor = msg.sender;
        delete _proposedNewExecutor;
    }

    /**
     * @notice Grant `allowedCaller` the rights to call the function selectors in the access list.
     * @dev fnSelector == bytes4(keccak256("fn(argType1,argType2,...)"))
     */
    function setExplicitAccess(address allowedCaller, ExplicitAccess[] calldata access) external override onlyElevatedAccess {
        if (allowedCaller == address(0)) revert CommonEventsAndErrors.InvalidAddress();
        uint256 _length = access.length;
        ExplicitAccess memory _access;
        for (uint256 i; i < _length; ++i) {
            _access = access[i];
            emit ExplicitAccessSet(allowedCaller, _access.fnSelector, _access.allowed);
            explicitFunctionAccess[allowedCaller][_access.fnSelector] = _access.allowed;
        }
    }

    function isElevatedAccess(address caller, bytes4 fnSelector) internal view returns (bool) {
        if (inRescueMode) {
            // If we're in rescue mode, then only the rescuers can call
            return caller == rescuer;
        } else if (caller == executor || explicitFunctionAccess[caller][fnSelector]) {
            // If we're not in rescue mode, the executor can call all functions
            // or the caller has been given explicit access on this function
            return true;
        }
        return false;
    }

    /**
     * @notice Under normal operations, only the executors are allowed to call.
     * If 'rescue mode' has been enabled, then only the rescuers are allowed to call.
     * @dev Important: Only for use when called from an *external* contract. 
     * If a function with this modifier is called internally then the `msg.sig` 
     * will still refer to the top level externally called function.
     */
    modifier onlyElevatedAccess() {
        if (!isElevatedAccess(msg.sender, msg.sig)) revert CommonEventsAndErrors.InvalidAccess();
        _;
    }

    /**
     * @notice Only the executors or rescuers can call.
     */
    modifier onlyInRescueMode() {
        if (!(inRescueMode && msg.sender == rescuer)) revert CommonEventsAndErrors.InvalidAccess();
        _;
    }

    modifier notInRescueMode() {
        if (inRescueMode) revert CommonEventsAndErrors.InvalidAccess();
        _;
    }
}