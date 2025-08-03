// SPDX-License-Identifier: MIT
pragma solidity >=0.6.11 <0.9.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.11;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.11;

import "./Context.sol";
import "./SafeMath.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.11;

// https://docs.synthetix.io/contracts/Owned
contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor (address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.11;

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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.11;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

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
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.11;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.11;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import "communal/ReentrancyGuard.sol";
import "communal/Owned.sol";
import "communal/SafeERC20.sol";
import "communal/TransferHelper.sol";

//import "forge-std/console.sol";

/*
 * VDAMM Contract:
 *
 */

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

interface ILSDVault {
    function darknetAddress() external view returns (address);
    function redeemFee() external view returns (uint256);
    function exit(uint256 amount) external;
    function isEnabled(address lsd) external view returns (bool);
    function remainingRoomToCap(address lsd, uint256 marginalDeposit) external view returns (uint256);
    function getTargetAmount(address lsd, uint256 marginalDeposit) external view returns (uint256);
}

interface IDarknet {
    function checkPrice(address lsd) external view returns (uint256);
}

interface IunshETH {
    function timelock_address() external view returns (address);
}

/*
 * Fee Collector Contract:
 * This contract is responsible for managing fee curves and calculations
 * vdAMM swap and unshETH redemption fees are collected here after fee switch is turned on
 */

contract VDAMM is Owned, ReentrancyGuard {
    using SafeERC20 for IERC20;
    /*
    ============================================================================
    State Variables
    ============================================================================
    */
    address public constant wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant unshethAddress = 0x0Ae38f7E10A43B5b2fB064B42a2f4514cbA909ef;
    address public immutable vaultAddress;
    address public darknetAddress;

    address[] public lsds;

    ILSDVault public vault;

    bool public ammPaused;

    struct AmmFee {
        uint256 baseFee;
        uint256 dynamicFee;
        uint256 instantRedemptionFee;
    }

    struct AMMFeeConfig {
        uint256 baseFeeBps;
        uint256 instantRedemptionFeeBps;
        uint256 unshethFeeShareBps;
        uint256 dynamicFeeSlope_x;
        uint256 dynamicFeeSlope_x2;
    }

    //Mutable parameters, can be changed by governance
    AMMFeeConfig ammFeeConfig = AMMFeeConfig(1, 20, 10000, 50, 1000);

    bool public depositFeeEnabled = true;

    //Immutable parameters, cannot be changed after deployment
    uint256 public constant maxBaseFeeBps = 10;
    uint256 public constant maxDynamicFeeBps = 200;
    uint256 public constant minUnshethFeeShareBps = 5000; //At least half swap fees go to unshETH

    /*
    ============================================================================
    Events
    ============================================================================
    */

    //Fee curve parameters
    event BaseFeeUpdated(uint256 _baseFeeBps);
    event UnshethFeeShareUpdated(uint256 _unshethFeeShareBps);
    event InstantRedemptionFeeUpdated(uint256 _instantRedemptionFeeBps);
    event FeeSlopesUpdated(uint256 _dynamicFeeSlope_x, uint256 _dynamicFeeSlope_x2);
    event DepositFeeToggled(bool depositFeeEnabled);

    //Admin functions
    event PauseToggled(bool ammPaused);
    event TokensWithdrawn(address tokenAddress, uint256 amount);
    event EthWithdrawn(uint256 amount);
    event DarknetAddressUpdated(address darknetAddress);
    event NewLsdApproved(address lsd);

    //Swap
    event SwapLsdToLsd(uint256 amountIn, address lsdIn, address lsdOut, uint256 lsdAmountOut, uint256 baseFee, uint256 dynamicFee, uint256 protocolFee);

    /*
    ============================================================================
    Constructor
    ============================================================================
    */
    constructor(address _owner, address[] memory _lsds) Owned(_owner) {
        vaultAddress = IunshETH(unshethAddress).timelock_address();
        vault = ILSDVault(vaultAddress);
        darknetAddress = vault.darknetAddress();
        lsds = _lsds;
        ammPaused = true;

        //set approvals
        for (uint256 i = 0; i < _lsds.length; i = unchkIncr(i)) {
            TransferHelper.safeApprove(_lsds[i], vaultAddress, type(uint256).max);
        }

        TransferHelper.safeApprove(unshethAddress, vaultAddress, type(uint256).max);
    }

    /*
    ============================================================================
    Function Modifiers
    ============================================================================
    */
    modifier onlyWhenUnpaused() {
        require(ammPaused == false, "AMM is paused");
        _;
    }

    modifier onlyWhenPaused() {
        require(ammPaused == true, "AMM must be paused");
        _;
    }

    /*
    ============================================================================
    vdAMM configuration functions (multisig only)
    ============================================================================
    */

    function setBaseFee(uint256 _baseFeeBps) external onlyOwner {
        require(_baseFeeBps <= maxBaseFeeBps, "Base fee cannot be greater than max fee");
        ammFeeConfig.baseFeeBps = _baseFeeBps;
        emit BaseFeeUpdated(_baseFeeBps);
    }

    function setDynamicFeeSlopes(uint256 _dynamicFeeSlope_x, uint256 _dynamicFeeSlope_x2) external onlyOwner {
        ammFeeConfig.dynamicFeeSlope_x = _dynamicFeeSlope_x;
        ammFeeConfig.dynamicFeeSlope_x2 = _dynamicFeeSlope_x2;
        emit FeeSlopesUpdated(_dynamicFeeSlope_x, _dynamicFeeSlope_x2);
    }

    function setUnshethFeeShare(uint256 _unshethFeeShareBps) external onlyOwner {
        require(_unshethFeeShareBps <= 10000, "unshETH fee share cannot be greater than 100%");
        require(_unshethFeeShareBps >= minUnshethFeeShareBps, "unshETH fee share must be greater than min");
        ammFeeConfig.unshethFeeShareBps = _unshethFeeShareBps;
        emit UnshethFeeShareUpdated(_unshethFeeShareBps);
    }

    function setInstantRedemptionFee(uint256 _instantRedemptionFeeBps) external onlyOwner {
        require(
            _instantRedemptionFeeBps <= maxDynamicFeeBps,
            "Instant redemption fee cannot be greater than max fee"
        );
        ammFeeConfig.instantRedemptionFeeBps = _instantRedemptionFeeBps;
        emit InstantRedemptionFeeUpdated(_instantRedemptionFeeBps);
    }

    function toggleDepositFee() external onlyOwner {
        depositFeeEnabled = !depositFeeEnabled;
        emit DepositFeeToggled(depositFeeEnabled);
    }

    /*
    ============================================================================
    Admin functions (multisig only)
    ============================================================================
    */

    function togglePaused() external onlyOwner {
        ammPaused = !ammPaused;
        emit PauseToggled(ammPaused);
    }

    function withdrawTokens(address tokenAddress) external onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        TransferHelper.safeTransfer(tokenAddress, msg.sender, balance);
        emit TokensWithdrawn(tokenAddress, balance);
    }

    function withdrawStuckEth() external onlyOwner {
        uint256 ethBal = address(this).balance;
        Address.sendValue(payable(owner), ethBal);
        emit EthWithdrawn(ethBal);
    }

    function updateDarknetAddress() external onlyOwner {
        darknetAddress = ILSDVault(vaultAddress).darknetAddress();
        emit DarknetAddressUpdated(darknetAddress);
    }

    //Technically, full timelock proposal is needed to add a new LSD.  This function just ensures new vdAMM doesn't need to be re-deployed
    function approveNewLsd(address lsdAddress) external onlyOwner {
        lsds.push(lsdAddress);
        TransferHelper.safeApprove(lsdAddress, vaultAddress, type(uint256).max);
        emit NewLsdApproved(lsdAddress);
    }

    /*
    ============================================================================
    Fee curve logic
    ============================================================================
    */

    function unshethFeeShareBps() public view returns (uint256) {
        return ammFeeConfig.unshethFeeShareBps;
    }

    function getEthConversionRate(address lsd) public view returns (uint256) {
        return IDarknet(darknetAddress).checkPrice(lsd);
    }

    //View function to get lsdAmountOut and fees for a swap. Does not deal with require checks if the swap is valid
    function swapLsdToLsdCalcs(
        uint256 amountIn,
        address lsdIn,
        address lsdOut
    ) public view returns (uint256, uint256, uint256, uint256) {
        //Sanity checks
        require(lsdIn != lsdOut, "Cannot swap same lsd");
        require(vault.isEnabled(lsdIn), "lsdIn not enabled");
        require(vault.isEnabled(lsdOut), "lsdOut is not enabled");
        require(amountIn > 0, "Cannot swap 0 lsd");

        //In a swap, total amount of ETH in the vault is constant we're swapping on a 1:1 ETH basis
        //To simplify and do a conservative first order approximation, we assume marginal deposit amount is 0
        uint256 distanceToCap = vault.remainingRoomToCap(lsdIn, 0);
        require(amountIn <= distanceToCap, "Trade would exceed cap");

        uint256 ethAmountIn = (amountIn * getEthConversionRate(lsdIn)) / 1e18;
        uint256 ethAmountOutBeforeFees = ethAmountIn;

        //Calculate fees
        (uint256 baseFee, uint256 dynamicFee, ) = getAmmFee(ethAmountIn, lsdIn, lsdOut); //in lsdOut terms

        //Fees are paid in lsdOut terms
        uint256 totalFee = baseFee + dynamicFee;
        uint256 protocolFee = (totalFee * (10000 - ammFeeConfig.unshethFeeShareBps)) / 10000;

        uint256 lsdAmountOutBeforeFees = (ethAmountOutBeforeFees * 1e18) / getEthConversionRate(lsdOut);
        uint256 lsdAmountOut = lsdAmountOutBeforeFees - totalFee;

        return (lsdAmountOut, baseFee, dynamicFee, protocolFee);
    }

    //returns amm fees in lsdOut terms
    function getAmmFee(
        uint256 ethAmountIn,
        address lsdIn,
        address lsdOut
    ) public view returns (uint256, uint256, uint256) {
        uint256 baseFeeInEthTerms = (ethAmountIn * ammFeeConfig.baseFeeBps) / 10000;

        uint256 lsdInDynamicFeeBps = getLsdDynamicFeeBps(ethAmountIn, lsdIn, true);
        uint256 lsdOutDynamicFeeBps = getLsdDynamicFeeBps(ethAmountIn, lsdOut, false);

        if (lsdOut == wethAddress) {
            lsdOutDynamicFeeBps = _min(maxDynamicFeeBps, lsdOutDynamicFeeBps + ammFeeConfig.instantRedemptionFeeBps);
        }

        //Take the higher of two and cap at maxDynamicFeeBps
        uint256 dynamicFeeBps = _max(lsdInDynamicFeeBps, lsdOutDynamicFeeBps);
        uint256 dynamicFeeInEthTerms = (ethAmountIn * dynamicFeeBps) / 10000;

        uint256 baseFee = (baseFeeInEthTerms * 1e18) / getEthConversionRate(lsdOut);
        uint256 dynamicFee = (dynamicFeeInEthTerms * 1e18) / getEthConversionRate(lsdOut);

        return (baseFee, dynamicFee, dynamicFeeBps);
    }

    // Dynamic fee (inspired by GLP, with unshETH twist)
    // Fees are 0 when swaps help rebalance the vault (i.e. when difference to target is reduced post-swap)
    // When swaps worsen the distance to target, fees are applied
    // Fees are proportional to the square of the % distance to target (taking the average before and after the swap)
    // Small deviations are generally low fee
    // Large deviations are quadratically higher penalty (since co-variance of unshETH is quadratically increasing)
    // All deviations to target and normalized by the target weight (otherwise small LSDs won't be penalized at all)
    // Fees are capped at maxDynamicFeeBps
    function getLsdDynamicFeeBps(
        uint256 ethDelta,
        address lsd,
        bool increment
    ) public view returns (uint256) {
        uint256 lsdBalance = IERC20(lsd).balanceOf(vaultAddress);
        uint256 initialAmount = (lsdBalance * getEthConversionRate(lsd)) / 1e18; //lsd balance in ETH terms
        uint256 nextAmount;

        if (increment) {
            nextAmount = initialAmount + ethDelta;
        } else {
            nextAmount = initialAmount - _min(initialAmount, ethDelta);
        }

        uint256 targetAmount = (vault.getTargetAmount(lsd, 0) * getEthConversionRate(lsd)) / 1e18;
        uint256 initialDiff = _absDiff(initialAmount, targetAmount);
        uint256 nextDiff = _absDiff(nextAmount, targetAmount);

        //If action improves the distance to target, zero fee
        if (nextDiff < initialDiff) {
            return 0; //no fee
        }

        //If target is zero and we are moving away from it, charge max fee
        if (targetAmount == 0) {
            return maxDynamicFeeBps;
        }

        //Otherwise Fee = a*x + b*x^2, where x = averageDiff / targetAmount
        uint256 averageDiff = (initialDiff + nextDiff) / 2;
        uint256 x = (averageDiff * 1e18) / targetAmount;
        uint256 x2 = (x * x) / 1e18;

        uint256 dynamicFeeBps_x = (ammFeeConfig.dynamicFeeSlope_x * x) / 1e18;
        uint256 dynamicFeeBps_x2 = (ammFeeConfig.dynamicFeeSlope_x2 * x2) / 1e18;

        return _min(maxDynamicFeeBps, dynamicFeeBps_x + dynamicFeeBps_x2);
    }

    function getDepositFee(uint256 lsdAmountIn, address lsd) public view returns (uint256, uint256) {
        if (!depositFeeEnabled) {
            return (0, 0);
        }
        uint256 ethAmountIn = (lsdAmountIn * getEthConversionRate(lsd)) / 1e18;
        uint256 dynamicFeeBps = getLsdDynamicFeeBps(ethAmountIn, lsd, true);
        uint256 redeemFeeBps = vault.redeemFee();

        //If dynamic fee < redeem fee, then deposit fee = 0, otherwise deposit fee = dynamic fee - redeem fee
        uint256 depositFeeBps = dynamicFeeBps - _min(dynamicFeeBps, redeemFeeBps);

        uint256 depositFee = (lsdAmountIn * depositFeeBps) / 10000;
        uint256 protocolFee = (depositFee * (10000 - ammFeeConfig.unshethFeeShareBps)) / 10000;
        return (depositFee, protocolFee);
    }

    /*
   ============================================================================
   Swapping
   ============================================================================
   */

    function swapLsdToEth(
        uint256 amountIn,
        address lsdIn,
        uint256 minAmountOut
    ) external nonReentrant onlyWhenUnpaused returns (uint256, uint256, uint256) {
        //Transfer lsdIn from user to vault
        TransferHelper.safeTransferFrom(lsdIn, msg.sender, address(this), amountIn);
        (uint256 wethAmountOut, uint256 baseFee, uint256 dynamicFee) = _swapLsdToLsd(
            amountIn,
            lsdIn,
            wethAddress,
            minAmountOut
        );
        //Convert weth to ETH and send to user
        IWETH(wethAddress).withdraw(wethAmountOut);
        Address.sendValue(payable(msg.sender), wethAmountOut);
        return (wethAmountOut, baseFee, dynamicFee);
    }

    function swapEthToLsd(
        address lsdOut,
        uint256 minAmountOut
    ) external payable nonReentrant onlyWhenUnpaused returns (uint256, uint256, uint256) {
        //Convert ETH to weth and swap
        IWETH(wethAddress).deposit{ value: msg.value }();
        (uint256 lsdAmountOut, uint256 baseFee, uint256 dynamicFee) = _swapLsdToLsd(
            msg.value,
            wethAddress,
            lsdOut,
            minAmountOut
        );
        //Send lsdOut to user
        TransferHelper.safeTransfer(lsdOut, msg.sender, lsdAmountOut);
        return (lsdAmountOut, baseFee, dynamicFee);
    }

    function swapLsdToLsd(
        uint256 amountIn,
        address lsdIn,
        address lsdOut,
        uint256 minAmountOut
    ) external nonReentrant onlyWhenUnpaused returns (uint256, uint256, uint256) {
        //Transfer lsdIn from user to vdamm and swap
        TransferHelper.safeTransferFrom(lsdIn, msg.sender, address(this), amountIn);
        (uint256 lsdAmountOut, uint256 baseFee, uint256 dynamicFee) = _swapLsdToLsd(
            amountIn,
            lsdIn,
            lsdOut,
            minAmountOut
        );
        //Send lsdOut to user
        TransferHelper.safeTransfer(lsdOut, msg.sender, lsdAmountOut);
        return (lsdAmountOut, baseFee, dynamicFee);
    }

    // Converts lsd to another lsd.
    // Collects protocol fees in vdAMM contract, and keeps unshETH share of fees for unshETH holders.
    // Assumes lsdIn is already in vdamm contract, lsdAmountOut + protocol fees is kept in vdAMM contract
    // Returns lsdAmountOut.
    function _swapLsdToLsd(
        uint256 amountIn,
        address lsdIn,
        address lsdOut,
        uint256 minAmountOut
    ) internal returns (uint256, uint256, uint256) {
        (uint256 lsdAmountOut, uint256 baseFee, uint256 dynamicFee, uint256 protocolFee) = swapLsdToLsdCalcs(
            amountIn,
            lsdIn,
            lsdOut
        );
        require(lsdAmountOut >= minAmountOut, "Slippage limit reached");

        //Amount to take out from vault = amountOut + protocolFee from vault. unshETH share of fees are kept in the vault
        uint256 lsdAmountOutFromVault = lsdAmountOut + protocolFee;
        require(
            lsdAmountOutFromVault <= IERC20(lsdOut).balanceOf(vaultAddress),
            "Not enough lsdOut in vault"
        );

        //Transfer amountIn from vdAMM to the vault
        TransferHelper.safeTransfer(lsdIn, vaultAddress, amountIn);

        //Transfer lsdOut from vault to vdAMM
        TransferHelper.safeTransferFrom(lsdOut, vaultAddress, address(this), lsdAmountOutFromVault);

        emit SwapLsdToLsd(amountIn, lsdIn, lsdOut, lsdAmountOut, baseFee, dynamicFee, protocolFee);

        //Return the lsdAmountOut (which subtracts protocolFee).  ProtocolFee is kept in vdAMM contract
        return (lsdAmountOut, baseFee, dynamicFee);
    }

    /*
    ============================================================================
    Other functions
    ============================================================================
    */

    function unchkIncr(uint256 i) private pure returns (uint256) {
        unchecked {
            return i + 1;
        }
    }

    function _min(uint256 _a, uint256 _b) private pure returns (uint256) {
        if (_a < _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function _max(uint256 _a, uint256 _b) private pure returns (uint256) {
        if (_a > _b) {
            return _a;
        } else {
            return _b;
        }
    }

    function _absDiff(uint256 _a, uint256 _b) private pure returns (uint256) {
        if (_a > _b) {
            return _a - _b;
        } else {
            return _b - _a;
        }
    }

    //Allow receiving eth to the contract
    receive() external payable {}
}