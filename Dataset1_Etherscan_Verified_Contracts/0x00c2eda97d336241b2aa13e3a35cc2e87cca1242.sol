// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Presale is Ownable, Pausable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address public DEV;                                                           // dev address.
  IERC20 public HORNY = IERC20(0x3d939F3aAB9aF971a9eDA1bC63A768D0DF386f66);

  uint256 public rate = 5072463768000000000000000000;                           // token per eth.

  uint256 public maxCap = 69000000000000000000;                                 //the maximum amount of eth to be raised during the presale.
  uint256 public startTime = 1684166400;                                        //the start time of the presale.
  uint256 public endTime = 1684252800;                                          //the end time of the presale.

  uint public minPurchase = 69000000000000000;                                  //the minimum amount of token that a user can purchase.
  uint public maxPurchase = 360000000000000000;                                 //the maximum amount of token that a user can purchase.

  // Mapping addresses claims amount.
  mapping(address => bool) public RefundsClaimed;
  // Mapping addresses claims amount.
  mapping(address => uint256) public TokenClaimed;
  // Mapping eth amount user participated.
  mapping(address => uint256) public ParticipatedAmount;
  // Mapping to keep track of how many tokens each user has bought.
  mapping(address => uint256) public TokenBought;
  // Mapping for whitelisted addresses.
  mapping(address => bool) public WhitelistedAddresses;

  uint8[11] claimPercentages = [50,5,5,5,5,5,5,5,5,5,5];
  uint32[11] claimTimestamps = [1684252800, 1684339200, 1684425600, 1684512000, 1684598400, 1684684800, 1684771200, 1684857600, 1684944000, 1685030400, 1685116800];

  bool public openRefund = false;

  modifier presaleOnGoing() {
    require(block.timestamp >= startTime, "Presale not started yet");
    require(block.timestamp <= endTime, "Presale ended");
    _;
  }

  modifier onlyWhitelisted() {
    require(WhitelistedAddresses[msg.sender] == true, "Address is not whitelisted");
    _;
  }

  constructor() {
    DEV = msg.sender;

    WhitelistedAddresses[address(0xa6e3Bf8A020Aa0d2C6598134Aa2d1345fb7B0c3f)] = true;
    WhitelistedAddresses[address(0x96236DF78A02e53FA9C4ac8043E8D6E2D997a2DF)] = true;
    WhitelistedAddresses[address(0xE1F53b52f441629F9B99b6c4625547fBA528DcDC)] = true;
    WhitelistedAddresses[address(0xac18BAD4072a8dd2F5F6ac3dcA06d0f4BEC43e6B)] = true;
    WhitelistedAddresses[address(0x93518625d9786476ca71eF98424FE90E2Df31a66)] = true;
    WhitelistedAddresses[address(0xF3F04181b89a8EBbdA2d950419AaF26aDd709D5f)] = true;
    WhitelistedAddresses[address(0x1bFE5847Af93370A2684d63a9DF7B81CF1F78053)] = true;
    WhitelistedAddresses[address(0x25569ecB5a421bD57F5CFA11f665b7795C9854Bb)] = true;
    WhitelistedAddresses[address(0x735D8A1DD0b3fb3e0F394A738ec5262E48032E92)] = true;
    WhitelistedAddresses[address(0x653625f4DdcD9B99da7CE9aCa4CA8236a056c419)] = true;
    WhitelistedAddresses[address(0x60dC00767CcBD25Ab5c029a88d49Ccb40Cd25468)] = true;
    WhitelistedAddresses[address(0x3dFFb6E87756e86D127Ef06c348d2bbD5a0a592C)] = true;
    WhitelistedAddresses[address(0x92cb3811BDaa4b477d07121b301B56351e0Dae3c)] = true;
    WhitelistedAddresses[address(0x7CaB7B18396d3Fe40946C0fD9399332ef474C113)] = true;
    WhitelistedAddresses[address(0x91757aaA0863b894865E5701a9a9c49E2e54e52D)] = true;
    WhitelistedAddresses[address(0x7777777E71De38333ffF9Dde08FF64c602b8A56D)] = true;
    WhitelistedAddresses[address(0x3d869084c46d39de7cE06DdC4a96b86ec606dBBb)] = true;
    WhitelistedAddresses[address(0x3F478ee2B4d9BF72B5b3b2469ac12A17a9e60d57)] = true;
    WhitelistedAddresses[address(0x90288121Aeb294eD88bd709BF6De58a476ad7808)] = true;
    WhitelistedAddresses[address(0x54a6523F22B31A90E7b1FF179F36D609f40ff931)] = true;
    WhitelistedAddresses[address(0x44A959aD7f7C84CeBdF67938af0d47A6481b90Ae)] = true;
    WhitelistedAddresses[address(0x543Cd03e1F38FB2f6F78Cf8e3f4283e48fAE61e8)] = true;
    WhitelistedAddresses[address(0xd843FE4E858D2281055aBEE0d652f9249E11ee6D)] = true;
    WhitelistedAddresses[address(0x39E121297240Ac7F72E7487D799a0fC06422e216)] = true;
    WhitelistedAddresses[address(0x0Aa4639a381b9C28dC9c896fb3284E04Ebb91801)] = true;
    WhitelistedAddresses[address(0x9570fbD500d3591A19C8e3b07E5656249FBDe200)] = true;
    WhitelistedAddresses[address(0x4BDC3308d002Dd88C833496b2a2E06414fffcDbf)] = true;
    WhitelistedAddresses[address(0x8aB11C12C3beD4fd47C22FC7F5C00D754e260F86)] = true;
    WhitelistedAddresses[address(0x7E19Ff5cC01A540804cf4b449DBffdE48b81C0D6)] = true;
    WhitelistedAddresses[address(0x99fDb1aF7389c345c6Ef06D527157a47638b879E)] = true;
    WhitelistedAddresses[address(0xB22e1868840E22B17c98DCa8Dc1154CEe00BEF8d)] = true;
    WhitelistedAddresses[address(0xa3E4cE21f91Ae21eFF25FFb783d6CB0671044888)] = true;
    WhitelistedAddresses[address(0xbDAf6CC19801d692964F56430270248A01B638db)] = true;
    WhitelistedAddresses[address(0xd3898129d4acb0F8039b1B9D6367B236F1E6100f)] = true;
    WhitelistedAddresses[address(0x55414c27833b96F7792D668c4Eb1A48A4e404076)] = true;
    WhitelistedAddresses[address(0x900D9Dc725f4468941948Ff3B6E717aD4ED3C4cC)] = true;
    WhitelistedAddresses[address(0x70eA9E56A4BCb1e560AC1c4f7c0787c0a0f91058)] = true;
    WhitelistedAddresses[address(0xC6411ca5A80dEB7ABc0827DA82E2DDB9C906614a)] = true;
    WhitelistedAddresses[address(0x08F5AE9f9f102D8C4ED20cBCff11F6d32cF82cb1)] = true;
    WhitelistedAddresses[address(0x3DEF7260739e963f79E236e99f0E24C4f2E08B69)] = true;
    WhitelistedAddresses[address(0x5c7fcE16Aef068CC7d35CB8D9a880dd36809bf72)] = true;
    WhitelistedAddresses[address(0xA4ed808e51A3Ae54712BfD39512C9c8B009cf332)] = true;
    WhitelistedAddresses[address(0x6A5529D7BD136A934c3A5d8Ec06D92BD46db5603)] = true;
    WhitelistedAddresses[address(0x5281Ff3Fa12221799782B7a40046f392C83F7BCD)] = true;
    WhitelistedAddresses[address(0xD34604aCc4e6cA8F99287251B7b6f78BF9BFEEc5)] = true;
    WhitelistedAddresses[address(0x4c026CfAF8273ebC48e481F6Ea84AD85c2c15423)] = true;
    WhitelistedAddresses[address(0xaB1AF81c86A7d624e806FF486d7F6D7162C448Ab)] = true;
    WhitelistedAddresses[address(0x4305B1864AFD62a64924F737ED7C11642c0e9b1a)] = true;
    WhitelistedAddresses[address(0x58b5503C7c246611851C70c3bD59b4838EF4e9a0)] = true;
    WhitelistedAddresses[address(0xF01B3Cc10834F075fb62E37E3b6ed36CFEB1c88F)] = true;
    WhitelistedAddresses[address(0xA64847981123446a53E38a812DE89E0451fE898D)] = true;
    WhitelistedAddresses[address(0xB7F71520bA9CF419Bdfd616554F0B0C6472D26E9)] = true;
    WhitelistedAddresses[address(0x5603cc70a3Cb72F3b6162688AC275e806a87E7e6)] = true;
    WhitelistedAddresses[address(0xDB4882F596E403Aad1DF6efAed9A1CAd39aEfcCA)] = true;
    WhitelistedAddresses[address(0xD2f5C2a5cD1379fA902A48dec787c8aebEDF6DE6)] = true;
    WhitelistedAddresses[address(0x048345376109ff3Cb7732A00f33F7c59aaa6B282)] = true;
    WhitelistedAddresses[address(0x4b28e4C3192cca4A87433758ee7CDaFDbe8E6336)] = true;
    WhitelistedAddresses[address(0xFE9e83D496E07a548493426337b73c53F592468B)] = true;
    WhitelistedAddresses[address(0x3333ae2c9D62289e8591DA64655e0894193B7886)] = true;
    WhitelistedAddresses[address(0x77F00a4676844AF2C576aB240a423DCd81664c8E)] = true;
    WhitelistedAddresses[address(0x9Fe2aB08d8A63b1D6dD6C9E55561149BDED65FD9)] = true;
    WhitelistedAddresses[address(0xe173Dd0BB2B006A914639B32998752cDa7960084)] = true;
    WhitelistedAddresses[address(0xA9213872c33ab857C432eae9f0a375026f0c0949)] = true;
    WhitelistedAddresses[address(0x2D8dBc864264d041EB11D074223cc2FDbBfC41f1)] = true;
    WhitelistedAddresses[address(0x5ab17F0dF3b08191F510b8806BAf2d835dd50671)] = true;
    WhitelistedAddresses[address(0x151b8c6E66BA9Da24720BD95fb5C1420C0fa6236)] = true;
    WhitelistedAddresses[address(0xFb7FCF76C84DE5c2687Af28583ad1b69B7f25c9d)] = true;
    WhitelistedAddresses[address(0xe82040e2f6788c7207E4dF90A3A878d25224F49C)] = true;
    WhitelistedAddresses[address(0x7Eab3236fb6A5DEe88af23D48eB36F74e3245ee5)] = true;
    WhitelistedAddresses[address(0xA0B4339B50aa3fbF514b7173e6b9667D7558f9AA)] = true;
    WhitelistedAddresses[address(0x6eF4E9D4a1976547E36e48fb97CF722b4fD47953)] = true;
    WhitelistedAddresses[address(0x9D5165f3BADde028d717365c852F90eB7e2f9971)] = true;
    WhitelistedAddresses[address(0xeBf87396267A4829B3a1a3EDb400246A9BE07723)] = true;
    WhitelistedAddresses[address(0xD08cB9f1D35f232fD9e7F3802Fa3B01f01777670)] = true;
    WhitelistedAddresses[address(0x5Ae7D3Fa7b2DfF39ECa420d38412d9Af9fc799C8)] = true;
    WhitelistedAddresses[address(0x7f04c4387423c5460f0a797b79B7De2A4769567A)] = true;
    WhitelistedAddresses[address(0x2898f6cC2C3b2B0d5A8a2e579912323A1ACA9686)] = true;
    WhitelistedAddresses[address(0x5Df36B9516084066e6877188128bFcD5946da8AE)] = true;
    WhitelistedAddresses[address(0x305Ad938a16DcdCAb5C8b8B4684258ad69d5B3f2)] = true;
    WhitelistedAddresses[address(0xfB50611d81aA763B0A94Cd06c906FD54734F1bE1)] = true;
    WhitelistedAddresses[address(0x689cFB50807b38beF965F90D97965F2c0dCD396a)] = true;
    WhitelistedAddresses[address(0x2a030fF3a0a001834eAc35B2fE4bEF3478ED04Bb)] = true;
    WhitelistedAddresses[address(0x4155D3462059650DC1227853e16131De98449d1F)] = true;
    WhitelistedAddresses[address(0x8916Caa43e7bcf7A4B9A482563D96e4E5c07F713)] = true;
    WhitelistedAddresses[address(0x830077D75c03eCD994c744Ef4D2DCA5ff4b8D52C)] = true;
    WhitelistedAddresses[address(0x451d34f1d0c5aD9bAc1cc186b1b513A2abeFc93d)] = true;
    WhitelistedAddresses[address(0x11d51D91751969f7e4A3B71E3d9F8E0c2027Ced7)] = true;
    WhitelistedAddresses[address(0x06Db70CC9bBa81436C6dFD5249A3f3d8bE362F29)] = true;
    WhitelistedAddresses[address(0xbe9253fbA3c2e71d7255102a50574ECaA93128bE)] = true;
    WhitelistedAddresses[address(0x744e4c1fFAf3295e3f52bf6AeE309b8A520a2b7f)] = true;
    WhitelistedAddresses[address(0x782BFf5A6074148b1f8c4E81B41F9297eFee2f8d)] = true;
    WhitelistedAddresses[address(0x7CE8998D936EA5427260e9B73121B959b7bDAcc9)] = true;
    WhitelistedAddresses[address(0xB8adc10EC1277feF7f04d49A7687745A5f4eDdc5)] = true;
    WhitelistedAddresses[address(0xdB912FAb7AB5FD40F17fD470573b3B999c62232c)] = true;
    WhitelistedAddresses[address(0xF805dD75AFCea9AC000Ae4713b9662a9b1703F89)] = true;
    WhitelistedAddresses[address(0xc7BCa70ce407b484550a0142d756b5a10a990e4D)] = true;
    WhitelistedAddresses[address(0x2B03aAB6227a2B2fd18564033Bc7eC2a633D49f7)] = true;
    WhitelistedAddresses[address(0xe7802D58698e0F69219b82E140208fC2108FBfBB)] = true;
    WhitelistedAddresses[address(0xeaA88EfDb766934F138ABE9E8Db6390bF440Dcad)] = true;
    WhitelistedAddresses[address(0x60271172103596d9f22496a7b391c4d361e4907C)] = true;
    WhitelistedAddresses[address(0xFc17690341AE1d85CFf8D747578C0c0DF58A0970)] = true;
    WhitelistedAddresses[address(0xE093540dBe149aab0376F0F2Bd07111E6723b769)] = true;
    WhitelistedAddresses[address(0xf6CaD61ed398289B480c916A54cAc99b3575309F)] = true;
    WhitelistedAddresses[address(0x1a444C51ED230b289eF6a2164B6Dc64a090bf9d7)] = true;
    WhitelistedAddresses[address(0x3079a30EC75471a58dF4ecF0E559007B2F014AFC)] = true;
    WhitelistedAddresses[address(0x7B4085b43962f02846660AE0646E0533409c1df1)] = true;
    WhitelistedAddresses[address(0x18F3058b940C987Dc3Eaa9c219f9186109AA83fD)] = true;
    WhitelistedAddresses[address(0x5D0011e952B9653DD96b260700e5aca4A59f1696)] = true;
    WhitelistedAddresses[address(0x61451cdf1b0Fc61074579ABF6B540FFA3274a542)] = true;
    WhitelistedAddresses[address(0x8185498685E9fd8996D0b1995A88FdBB6b80759d)] = true;
    WhitelistedAddresses[address(0x146fca56b701D33E607c5223849076eaf2e00eec)] = true;
    WhitelistedAddresses[address(0xE9c590Af334cB7075104a9158845A1c1FFa3e8C5)] = true;
    WhitelistedAddresses[address(0xD27Ab905b888f3FAfC0FB79FB00D7b5153285c18)] = true;
    WhitelistedAddresses[address(0x93cCFdF78900A38Aa0Be8bE3935534249D9BAB07)] = true;
    WhitelistedAddresses[address(0x6eA999bCAF20Ca151d5F01cc4A08151Bb8aBe67E)] = true;
    WhitelistedAddresses[address(0x424896B31CA5cCFE8F3b8E0595F5cB2A0AeE158E)] = true;
    WhitelistedAddresses[address(0x0279582676AffC46622AdD562A35bc9042FB425d)] = true;
    WhitelistedAddresses[address(0xdf09092bAe5C265e404e0a8Ce01eBF341481F531)] = true;
    WhitelistedAddresses[address(0xa2F8f118e2C301A9e8eD54fE14767e3d58122F3f)] = true;
    WhitelistedAddresses[address(0x7E3Ed68a06845ED4565ae3134671dfDB89083358)] = true;
    WhitelistedAddresses[address(0x898AAd455336577D0f5864cb4287bEF4bC895849)] = true;
    WhitelistedAddresses[address(0x1F38ee2730E9169013b35DC8a538Dd438aDE505d)] = true;
    WhitelistedAddresses[address(0x642CAd320AEEf2FF7Ce1d3355e34153F647E4D5e)] = true;
    WhitelistedAddresses[address(0x9fb0F455C760eC034b498880d80504f5327767B9)] = true;
    WhitelistedAddresses[address(0x1A31A79c2FdCd8234438e232d91f30ee81040a74)] = true;
    WhitelistedAddresses[address(0xb7BD83023cdc550b1da2E4C19eC6eBb6fC371A98)] = true;
    WhitelistedAddresses[address(0xEc7BC683149717B3FBd57A3e2C44d49b35B156Dc)] = true;
    WhitelistedAddresses[address(0x8333150E6462716f7307760A6C46b258f144004F)] = true;
    WhitelistedAddresses[address(0x7aC2A33Bb5c612DB5814f169c0d033b0A4CB3056)] = true;
    WhitelistedAddresses[address(0x6Aac14753cCC62053e2fbC7AF9bE15F93603143F)] = true;
    WhitelistedAddresses[address(0xe9262Ae15c8d3AA76fEC2Ef4C79b2A2B3158Ac0a)] = true;
    WhitelistedAddresses[address(0x6C8Ee01F1f8B62E987b3D18F6F28b22a0Ada755f)] = true;
    WhitelistedAddresses[address(0xBF24D26B534A19E4F09c0B698b2CBffF820a452E)] = true;
    WhitelistedAddresses[address(0xa394e5A73117a50eDCB7C6440D44638Cf854b92c)] = true;
    WhitelistedAddresses[address(0xdcC54e8E093Ba4eb69d9A5A2933044C3cc22B9F1)] = true;
    WhitelistedAddresses[address(0x6Ef6265b3A2866aAb07aaAD3338cd034481f9cf7)] = true;
    WhitelistedAddresses[address(0x3dA60b72c9eFCDAAdB70D9ceA3a99FFd5d0FC9D0)] = true;
    WhitelistedAddresses[address(0xa5CdaA29D9CDE0D6C8bb68AEe31A0B779e6AC6B5)] = true;
    WhitelistedAddresses[address(0x89212212326727b3a836C54353F92f21f9A71614)] = true;
    WhitelistedAddresses[address(0xb0071eF1aD12A0218Ab5f4ef95c63C0743F01cB9)] = true;
    WhitelistedAddresses[address(0x1dDCe419C9FA95613B55A60Ea0f9f5136d2865A8)] = true;
    WhitelistedAddresses[address(0x3162947986982E70B2FAC2A90bA49d8657F34334)] = true;
    WhitelistedAddresses[address(0x9E29A34dFd3Cb99798E8D88515FEe01f2e4cD5a8)] = true;
    WhitelistedAddresses[address(0x9654dFC4D328d94cecB4152BE4B2865Ffd9eDFdB)] = true;
    WhitelistedAddresses[address(0x5E988A7A71296A07FAa77DE91615864BCf60931E)] = true;
    WhitelistedAddresses[address(0xc888C19A101979E0C29274895A86f0C3BaB6Cf7b)] = true;
    WhitelistedAddresses[address(0xFbeC2c5cbB8bf4179E605520c6Be48D75ED5dF81)] = true;
    WhitelistedAddresses[address(0x43657142e17cafc6F894724DfA5e381eD838CdB8)] = true;
    WhitelistedAddresses[address(0x6406e3EaCC064BB6C5D4D9379E413017bFeBABc5)] = true;
    WhitelistedAddresses[address(0xeE20b1A6F93882303ef00D9fA517130d9Aa6175D)] = true;
    WhitelistedAddresses[address(0x910915b4EF4B48737b786E5f279124ba2D088f4A)] = true;
    WhitelistedAddresses[address(0x4eE9F84FB578F392a80191ffE5F937B66Eef5699)] = true;
    WhitelistedAddresses[address(0x8b45539774574B6d6BFcc12846273617C1986967)] = true;
    WhitelistedAddresses[address(0xd4aCad6D89DcC601bA239826e7F052a20a6976f4)] = true;
    WhitelistedAddresses[address(0x78CE582399e5DFc46AbC38e10D38a21Cd1b1E444)] = true;
    WhitelistedAddresses[address(0xD3E906e94150bD2B32fccF092Db3b82a65853EE2)] = true;
    WhitelistedAddresses[address(0x58d334e6ea0dF5a5C200d19007371215C9550bcf)] = true;
    WhitelistedAddresses[address(0xcefBc24f9725516BDC329EDf5a300a5c03949b42)] = true;
    WhitelistedAddresses[address(0x43d5AE611AE02084487C73De38b2f2053292A1E1)] = true;
    WhitelistedAddresses[address(0xC9ED609fF81853950B0605282870bAC975863042)] = true;
    WhitelistedAddresses[address(0xeb740de6Aa5041A9CB0B8347A898e173f2a0234F)] = true;
    WhitelistedAddresses[address(0x4227666183beA7D8F064dC1179d333E7dA2A3828)] = true;
    WhitelistedAddresses[address(0xA1342B27953a25e4C87FCee629841284BA7a1BCC)] = true;
    WhitelistedAddresses[address(0xdDb6eF6c62a13e43cdf7C95Aa9Fc030924DcDcBC)] = true;
    WhitelistedAddresses[address(0x829C0F59FF906fd617F84f6790AF18f440D0C108)] = true;
    WhitelistedAddresses[address(0x0C308c7d3D85e57bC9b07c811dc7267dcF440549)] = true;
    WhitelistedAddresses[address(0x3F50b1278488c0409E47fb7352db4381ef63A271)] = true;
    WhitelistedAddresses[address(0xdd614DB103f998Ff9d63E255fc3B1588882d5e11)] = true;
    WhitelistedAddresses[address(0x53cb975548deFAdaCCb3183473B49db65D44065b)] = true;
    WhitelistedAddresses[address(0xEa548ae95BE4f5f3fd864c4F65e8c0780b508e79)] = true;
    WhitelistedAddresses[address(0xaD50ce8546cFEBCc60eB8359041bBA52b80363FF)] = true;
    WhitelistedAddresses[address(0x5aA84D8B823B033601E79a5dE2d083FDA5866238)] = true;
    WhitelistedAddresses[address(0x56C03f4e9Eb2B5764908fB2C42c90783E670Af3C)] = true;
    WhitelistedAddresses[address(0x8f15720176ECF89a034509985B7C7Ea886C7775B)] = true;
    WhitelistedAddresses[address(0xde26eCF4bd74bb7cA4c9c08C30Fd8638b369e579)] = true;
    WhitelistedAddresses[address(0x422dfBB161b364B21A33Cf04d1251168c49B0603)] = true;
    WhitelistedAddresses[address(0x10caAA4936592CAbc556ba82Cb940bb44eC5f879)] = true;
    WhitelistedAddresses[address(0x329e7A5b57E877Da469C38B7bB885b2DB7ACdDFA)] = true;
    WhitelistedAddresses[address(0x8802cF6b248a4136b1C8172375245a85108cDc30)] = true;
    WhitelistedAddresses[address(0xBAD5039e9F917b2A3650e15Bcb51C87c579F3124)] = true;
    WhitelistedAddresses[address(0xdF1ED4C64a77D80E380Bb5D3190e67ACc5C0FFea)] = true;
    WhitelistedAddresses[address(0xC76215a376c2B979567B114634AC5f95cc4eceba)] = true;
    WhitelistedAddresses[address(0xA56E7000C09d6b6E54B6998D0E70456244af9A4C)] = true;
    WhitelistedAddresses[address(0x7B8c1C44ED2B4A725aAac11CdadA1B13E54A9E1e)] = true;
    WhitelistedAddresses[address(0xf44D3ddCE7D5aa95757a9f6F0f78A8bAdBb39631)] = true;
    WhitelistedAddresses[address(0xe30185b81bCC9Ce290325A68c3F3748497D8A46C)] = true;
    WhitelistedAddresses[address(0x5C9e8eec2002001E3C7fD59A947C24B979410ABD)] = true;
    WhitelistedAddresses[address(0x9b445092e94CB14Af24CF8f0350F483ADE6AdFE2)] = true;
    WhitelistedAddresses[address(0x1805Bf187022DD7402539EfACB195A46D74bF0AF)] = true;
    WhitelistedAddresses[address(0xc858Db9Fd379d21B49B2216e8bFC6588bE3354D7)] = true;
    WhitelistedAddresses[address(0x6253C923127D4b77FB9A581B398cb7E63C602c09)] = true;
    WhitelistedAddresses[address(0xf4D1a203b3A79385BCbf66960051522402ac917E)] = true;
    WhitelistedAddresses[address(0xD51Ce9bE4a1cb6185B76Ba825C59236a6Cf5ca2A)] = true;
    WhitelistedAddresses[address(0xf382c59e22fBf49C56619A5f799b03ed52392E9d)] = true;
    WhitelistedAddresses[address(0x2F80f930aF7aE24905e1dfC153d11d3AB0b0BE5A)] = true;
    WhitelistedAddresses[address(0x964824A9fAbC60Ba2A8e70A910c113A8C98b1512)] = true;
    WhitelistedAddresses[address(0x57971e13e42594bDcb2caD2460af84e25f40217C)] = true;
    WhitelistedAddresses[address(0x1FE61315E9400401aDd9e420BEB0f84Ca8A69f93)] = true;
    WhitelistedAddresses[address(0x5f52A88F55e6c1fBb965F77b4906397f25C997E4)] = true;
    WhitelistedAddresses[address(0xC9D33672e012352df7F868ec02D3bba213BD7518)] = true;
    WhitelistedAddresses[address(0xC261c472a5fea6f1002dA278d55D2D4463f000ef)] = true;
    WhitelistedAddresses[address(0x23079A3DD8acf2F1C174aB3e2a450Aa097ee1F4D)] = true;
    WhitelistedAddresses[address(0xa9560598DE9d53B9Ee305A090845027Ea55dc820)] = true;
    WhitelistedAddresses[address(0x0fA0DDEE288BEC1a47952318649FDF7F338f70E1)] = true;
    WhitelistedAddresses[address(0x3ca11205Cb331AEDe70d1Ece6E41836D9364DBe0)] = true;
    WhitelistedAddresses[address(0xe575e79F0d87904b2d74daaC45e283682fA20Bff)] = true;
    WhitelistedAddresses[address(0xb168954199f7B18267cE9CE760Ca3e5a20bE4D3b)] = true;
    WhitelistedAddresses[address(0xc35adDEFbCc7d3D6897Fcd17cEc4aA70B7bBED91)] = true;
    WhitelistedAddresses[address(0x17aeBcFEcbA94622A446F6BB66AA745928C196bB)] = true;
    WhitelistedAddresses[address(0xdE6c87BC55f0A9B2dBaE133Bf97aA9eFF5030E13)] = true;
    WhitelistedAddresses[address(0xF63E5a7E23747e5491272c5D992E13EB4438C178)] = true;
    WhitelistedAddresses[address(0xaa341368Fe3a5d1cc8314Dc07aF02334D9Aa1e1D)] = true;
    WhitelistedAddresses[address(0x27A30d2D5904f1B24fafB227D9252b6048b97e07)] = true;
    WhitelistedAddresses[address(0xEB5DFB7C51F711E9D6393b0dbBA89F75D339D15c)] = true;
    WhitelistedAddresses[address(0xEDB6b12898b2a7436389002559Cf2483FCB599Ef)] = true;
    WhitelistedAddresses[address(0x635C604d73fb5169b71d7D0046410Ec6C062AA6B)] = true;
    WhitelistedAddresses[address(0x12227084921E35eCc43fd611bE4D49F85BEa9b5d)] = true;
    WhitelistedAddresses[address(0xc704f68730ceca41aAefC9f3a9668d6498c99365)] = true;
    WhitelistedAddresses[address(0x38BfDAB41f5184AC866A319ae10c484210C42F7f)] = true;
    WhitelistedAddresses[address(0x38B8f8008cCE8A43EB223d7971dDC0800B940886)] = true;
    WhitelistedAddresses[address(0x4a4CaE1D41e483336e46FC017D7B629f36B08176)] = true;
    WhitelistedAddresses[address(0x5933aC67BDB1F13cE82b2E1d97f751114c08BCA6)] = true;
    WhitelistedAddresses[address(0xFC5BB19F79A410f0D47E2533339C698345389C92)] = true;
    WhitelistedAddresses[address(0x64C9a39113A9C0fDf96fc1F6E252952C029254A1)] = true;
    WhitelistedAddresses[address(0xea63F69E65064bBF3304a8F4CeD6887A2a48D848)] = true;
    WhitelistedAddresses[address(0x000000000000000000000000000000000000dEaD)] = true;
    WhitelistedAddresses[address(0xF6E3a5f0f87FE1f760F6c9082d03270C73570610)] = true;
    WhitelistedAddresses[address(0xBb93664780E5e4e22F5255c774bfc455eBFa789E)] = true;
    WhitelistedAddresses[address(0x0b5edBbc4bD2967fA72aF955447799499d6e96c0)] = true;
    WhitelistedAddresses[address(0x7ae3ee2D8293548A06DA0bcaC88994838C96b1c5)] = true;
    WhitelistedAddresses[address(0xF989828320966a5DBaBc6800d14b42DfD53F070f)] = true;
    WhitelistedAddresses[address(0x1F151FC620B031533C26b65A4c84baBF4B283bf5)] = true;
    WhitelistedAddresses[address(0x888C65C45923D565dEe48B6E98ae5ED9b668D635)] = true;
    WhitelistedAddresses[address(0x6A21F579e4C6da1eBD5570964bB883B41dB9Dab5)] = true;
    WhitelistedAddresses[address(0x428D34931Bb5F44cf914e099C05EbcaDE4c6B79A)] = true;
    WhitelistedAddresses[address(0x9745026E8D20EF4AC47337c3DFf6A38d846da5d2)] = true;
    WhitelistedAddresses[address(0xA3A56DD2Be92D2251F313a4387D111317a564080)] = true;
    WhitelistedAddresses[address(0x1Bd4f4ae1Ebc651168D02416D1814eAE6D2A352E)] = true;
    WhitelistedAddresses[address(0xC11e79DDaA2229252904d889cc97CC35FAB20d45)] = true;
    WhitelistedAddresses[address(0xF68b5aC56d88EC5B3d6Bba9492aE7Ba022950f35)] = true;
    WhitelistedAddresses[address(0x5f2dC6194EEf7a348a8cEf952573AF6723208003)] = true;
    WhitelistedAddresses[address(0x6af81C3BA58c9A22f7E6131fd00BbEA57c7381eD)] = true;
    WhitelistedAddresses[address(0x733609987B8a8D00D7b24f5B633dBBDeAa1E8740)] = true;
    WhitelistedAddresses[address(0x2E30Eb7af6E3119C2b8900D7E132a59C5e8257B0)] = true;
    WhitelistedAddresses[address(0x110167e632a62E88B0BC9f507EC197a15f9883DC)] = true;
    WhitelistedAddresses[address(0xe505a60e001fA64DfD7b0A95159f19EE0efEc336)] = true;
    WhitelistedAddresses[address(0x7c5Da3494087cBA0ae94f928482CA355653ad048)] = true;
    WhitelistedAddresses[address(0x426a5881454a853CE89540495Ae8479DB2d71db3)] = true;
    WhitelistedAddresses[address(0xE087A1A1c4208138D470bE1Fc9240a492D80bBE0)] = true;
    WhitelistedAddresses[address(0x660A5d24B36E4Ce4885653112Df2132F28483A62)] = true;
    WhitelistedAddresses[address(0xB087ee7f8188EDcc1cd075F5eF144E812717d1aE)] = true;
    WhitelistedAddresses[address(0x5E6f7603BAbed10f0aE29666CeC2aea445cA752f)] = true;
    WhitelistedAddresses[address(0xe317C793ebc9d4A3732cA66e5a8fC4ffc213B989)] = true;
    WhitelistedAddresses[address(0x8867c24D4727B7F3844375FBB4ACB1745A247d62)] = true;
    WhitelistedAddresses[address(0x522a1296072C64CE3486549FA0602F23F374fA5F)] = true;
    WhitelistedAddresses[address(0x0AFd25e81f126d87beE5347AAbBbDBF725f02AbD)] = true;
    WhitelistedAddresses[address(0x5Ba427bdE16DE265948f1e86dB0C7391E0C65C4F)] = true;
    WhitelistedAddresses[address(0xD69AfC50B0D5cB55F388b9453A36E520080B9923)] = true;
    WhitelistedAddresses[address(0xEdD1ca44b5A758656DF1ea03f58dB2c503426bb6)] = true;
    WhitelistedAddresses[address(0xC6C5a2C40a24371b7064b3dcfB98f83DB1313a8B)] = true;
    WhitelistedAddresses[address(0xF7BCd63e9cFbEC0AF4237457Bbc2976406DAd866)] = true;
    WhitelistedAddresses[address(0xd50226a48780D82a8537e8Feb1EC554cD6869be5)] = true;
    WhitelistedAddresses[address(0x5E0FDc5A4A74C962C0c96fD457bb494B10d84a50)] = true;
    WhitelistedAddresses[address(0xba7933402348A902064499ed883c49843Eeb7019)] = true;
    WhitelistedAddresses[address(0xf53ED94f5FB975a5BE7Eb26a3fe6912057ff225A)] = true;
    WhitelistedAddresses[address(0x9626ba74548BFEf0A976371Ad0804D429dE68e42)] = true;
    WhitelistedAddresses[address(0x58077Bc939e7D5464F022a483B53ffe3a0BEDcb1)] = true;
    WhitelistedAddresses[address(0x50C9De782444FcBf76b34E041865359F303904D1)] = true;
    WhitelistedAddresses[address(0x86BFB79503460A7b6a9c111AC5D8C6Ae28a1AcBB)] = true;
    WhitelistedAddresses[address(0xA57c19A01f5719b73738e7326a9c9C3e7E90F952)] = true;
    WhitelistedAddresses[address(0x62Cb34D29EC4877cA54fbDF206E4631e01493488)] = true;
    WhitelistedAddresses[address(0xc8B6341b7CB07E5D095B055FEA8490458dbD1125)] = true;
    WhitelistedAddresses[address(0xBF601689698CE90ba5224Cf5175FfC1C105BC274)] = true;
    WhitelistedAddresses[address(0x7c2Aca62D8fa5B044BA4Bfadd95c0fA174ca7bF2)] = true;
    WhitelistedAddresses[address(0x39b65f3083Ba5B6AE565dedFa030f9B16253A86F)] = true;
    WhitelistedAddresses[address(0x62BB6D5E99a73FEa24390A9825f89282eC4C908e)] = true;
    WhitelistedAddresses[address(0xe631006BB6c774FdE23cB213E5AbCDd2EFD51541)] = true;
    WhitelistedAddresses[address(0xFab74d244728a460552E44Cc1F8a33629bD3cDF9)] = true;
    WhitelistedAddresses[address(0x2B3EC2D5Ff9ada834FEf215fF30857920A33E022)] = true;
    WhitelistedAddresses[address(0xaf2BA95545a1Fd969c5246Af453A3c8DA91B874f)] = true;
    WhitelistedAddresses[address(0xDb560D8B24bf54313789Ea1717C3D6527db5C7b2)] = true;
    WhitelistedAddresses[address(0x40F4e230bBa803810eAe24EA3d4A674595F0183e)] = true;
    WhitelistedAddresses[address(0x228CAa4729677F5E8A30E8F088af9A9064dA5fad)] = true;
    WhitelistedAddresses[address(0xd1FaD074908E2E8C081660f7F002016b440B72BC)] = true;
    WhitelistedAddresses[address(0xe4e61C6278ccD15ea332676B5C71d2c9708A23EC)] = true;
    WhitelistedAddresses[address(0x9DE7aAD598BBB95833f5fb2007e0aB453CFA2A18)] = true;
    WhitelistedAddresses[address(0x2cAA646D4EA5d023E421F5BfbBcaC73090e2b98E)] = true;
    WhitelistedAddresses[address(0x6278c4eeFd0673b56f43B3A367e393Cdd60fe6c2)] = true;
    WhitelistedAddresses[address(0x2D080E9911FfB8AADFaa8FEa9068003dC0A8bC5E)] = true;
    WhitelistedAddresses[address(0x74a3A888aEdBF2608adbbC5aDBFF986a389De3A2)] = true;
    WhitelistedAddresses[address(0x6A9b4BD87AA49574e107556FDEb9c7eb1C5f03f5)] = true;
    WhitelistedAddresses[address(0x3568919B9d7A0483Ae9b375fe96F7df048f0Eff8)] = true;
    WhitelistedAddresses[address(0x21d5956f409ED6D0fef72396D198cE39cADD85D6)] = true;
    WhitelistedAddresses[address(0xaF8bC7936C7d841E9e326aF600418B7Cbf094E13)] = true;
    WhitelistedAddresses[address(0xa0501600eD268594c6710c7531D6093c0fAd29DD)] = true;
    WhitelistedAddresses[address(0x9661E1A71918Ce61AE7Cb7AFAafA7d66d28dceB4)] = true;
    WhitelistedAddresses[address(0x0E42D8fCF5166D332ce8df3b65c5e20468fb7359)] = true;
    WhitelistedAddresses[address(0xc62E76a6Bb03E76b3152413C2B018752f8BE7606)] = true;
    WhitelistedAddresses[address(0xB56F3EEe1190a4b9335b8565Cd41Ab765B2b9235)] = true;
    WhitelistedAddresses[address(0x0CDD65d3e6e80dA2e5A11F7C1cEdaCE730372D7E)] = true;
    WhitelistedAddresses[address(0xFD9f99F300899ce82DdAB44fD11569D7DC321Bfb)] = true;
    WhitelistedAddresses[address(0x3A47Dd3a326110b9FcEbEa4419349Dcc84F44BBF)] = true;
    WhitelistedAddresses[address(0xf85Dd649FB05Db66Fd2B706839519F27cb3E7128)] = true;
    WhitelistedAddresses[address(0x899FCf86e744d560ab35154Bb20737cCb3Abd550)] = true;
    WhitelistedAddresses[address(0x61EED746E4C4C04E8129d0a97555d85eDc27f506)] = true;
    WhitelistedAddresses[address(0x952E547cbe26BE59632B87B7F9286e5fD25A3899)] = true;
    WhitelistedAddresses[address(0x0002937C976286ede8BbC21D2bb35f2a80ac1af3)] = true;
    WhitelistedAddresses[address(0x6312327A69Aebd7a7BCcFC82C3566F4B8Cc963c0)] = true;
    WhitelistedAddresses[address(0x04A52A9E509e5C14f88F72744Fd8868Cdd6BcFd1)] = true;
    WhitelistedAddresses[address(0xd4562D7d62ceFeBada19449a0EbD4A8D2aFD0976)] = true;
    WhitelistedAddresses[address(0x5457307a38c3e36844BFAa2e1fD61d72f69b7439)] = true;
    WhitelistedAddresses[address(0xF8FD6b269ACd7aA144424140CBb26C5a4e5dC5bc)] = true;
    WhitelistedAddresses[address(0xa198F54b9D0e49b00Bfd322b787270AA16e81391)] = true;
    WhitelistedAddresses[address(0x3DA8C6A28A1B8AD5d084453Fb4c33059E4636db3)] = true;
    WhitelistedAddresses[address(0xd2D8Fa8128dF45E6Bf61B5E8173ded3535e9a6C2)] = true;
    WhitelistedAddresses[address(0xc5782c34bfE9e9Bb0933538973A8E2Dce9aa9f43)] = true;
    WhitelistedAddresses[address(0xdDa10cf025e1A3d5136DcBee2B64dbAbf666C980)] = true;
    WhitelistedAddresses[address(0x9E6FD664132522Ce3ae5dB73724d7cc5f0193e7e)] = true;
    WhitelistedAddresses[address(0x76dD15b5C77477904D43ed5fDA138A6F18A1d68A)] = true;
    WhitelistedAddresses[address(0xb89d308480f43F8b1c66a6810ae7A304281A0622)] = true;
    WhitelistedAddresses[address(0xFde70f76bdf27486a5db15fbC64Bc8AF7D972580)] = true;
    WhitelistedAddresses[address(0x8666F72C7939d48760E8D74b329386912BC6C9EE)] = true;
    WhitelistedAddresses[address(0xcf25A23D533F9156eAb5Dfb6c2520901b475214c)] = true;
    WhitelistedAddresses[address(0x8903614bd27bb982cac246c528f8c89bB865C14d)] = true;
    WhitelistedAddresses[address(0xB9560b8dd3Fd5C1cbc3E2BCf1460818C8392188F)] = true;
    WhitelistedAddresses[address(0x29c8C3ae4A3Ce83C6871109B7Ff1464A2b8ca7D0)] = true;
    WhitelistedAddresses[address(0x1f810fA25ab83E6ADBd155AC1c4881d0186499e9)] = true;
    WhitelistedAddresses[address(0xc74d830092053ed9Ec197eB3Fb9C272460fd32dC)] = true;
    WhitelistedAddresses[address(0xE9EA479FA669898Ab763f6b0d6b191E29939B65A)] = true;
    WhitelistedAddresses[address(0x795C98592026e6B53fc14D3082735379cF74741D)] = true;
    WhitelistedAddresses[address(0x9Ed2e5D640A2296E02990dcAA90B29E817924B55)] = true;
    WhitelistedAddresses[address(0x54Bcf4b079fCe4d95677c92A94EAa76cFCeBC15B)] = true;
    WhitelistedAddresses[address(0xaE09aCB7a2A31300218ae94eFf1ae2C7Dc1B8Ac0)] = true;
    WhitelistedAddresses[address(0x8669c51EeCE966cCAeA37e5304e29c672197E43F)] = true;
    WhitelistedAddresses[address(0xbEb1b983B856f9329A9A52142Bd0dd1364269eFC)] = true;
    WhitelistedAddresses[address(0x293b0972Ff93252Ea997E6a3B7466c325b4f8Db9)] = true;
    WhitelistedAddresses[address(0x0B95f218d9032eBcb9ea928c7621e2EC7d19E390)] = true;
    WhitelistedAddresses[address(0x0907Bb13fefC50e25B0bFBB7C1Af9C2e02dbDCE7)] = true;
    WhitelistedAddresses[address(0x14c354EB512354EEc0e3b9608d4a2DE413909Ad2)] = true;
    WhitelistedAddresses[address(0x0A566270B3659dcdBA017309006B63Cbd3f4f50f)] = true;
    WhitelistedAddresses[address(0xE7fe672AAC0AC7f452e8cFfB2774e1BBeF7cc97d)] = true;
    WhitelistedAddresses[address(0x0adfE9bB98aC3b7beF5E5174566435160503b400)] = true;
    WhitelistedAddresses[address(0xC21201247427E9Fa68868E75f7581B770F07129B)] = true;
    WhitelistedAddresses[address(0x2B9e18c39a66e6443A54e0CAfC8a056FB061D7c0)] = true;
    WhitelistedAddresses[address(0x1631a603c76EED72B698cfbeBC9C42162d6A43F1)] = true;
    WhitelistedAddresses[address(0xAd666FEF0004aA909C57750FB9477cb67AcFD367)] = true;
    WhitelistedAddresses[address(0x778dC8Be92c0Ebf460b2e196F646626A3B9182B0)] = true;
    WhitelistedAddresses[address(0x598E0C7F25C75ca94f44872b92487A827a479E06)] = true;
    WhitelistedAddresses[address(0xc5aa4294048BCFfA965E6B135573632BdaBfE4DF)] = true;
    WhitelistedAddresses[address(0x170fBB92a85981be86FF05101D11C033e9666Fbb)] = true;
    WhitelistedAddresses[address(0x2B3ccb55a404c0E99ADD7E3041F76883E22E5E72)] = true;
    WhitelistedAddresses[address(0xF10FF6c03c5f951C9A4d02cb0Dca51BA442B095E)] = true;
    WhitelistedAddresses[address(0x9fc8a0B2F015613ad9c741BB54F3e35826570921)] = true;
    WhitelistedAddresses[address(0xc579134B984DD3424d7d69f9860589CA10Fe4431)] = true;
    WhitelistedAddresses[address(0xe30a31358F17b6468500Abb5Cbc043561c4a710e)] = true;
    WhitelistedAddresses[address(0x2Ab5198940897d46aD9723b5603Cf137D7019b94)] = true;
    WhitelistedAddresses[address(0xE9448D94F5F7aC4aF563cf47Eb4A906f11632BC6)] = true;
    WhitelistedAddresses[address(0x2E09638b4428a88AEC4acA567bbF52a82D6AF069)] = true;
    WhitelistedAddresses[address(0xD28Cc322DEb8c140863a6f26dF664C8f5688DC8D)] = true;
    WhitelistedAddresses[address(0xC9652bb705C24eD933267c4cF0C66B92112b7dF2)] = true;
    WhitelistedAddresses[address(0x161ecba139c75C900106eb76eB4428E4bebb2979)] = true;
    WhitelistedAddresses[address(0x1C208DDbb3504D5a01cd2c7Eca75Bb0E1a7FeB45)] = true;
    WhitelistedAddresses[address(0x2aA775B5183090b604DB392841D1363E53B87D1C)] = true;
    WhitelistedAddresses[address(0x7BD1A11Ff0a334E48a1138125902cD7c8e3638f6)] = true;
    WhitelistedAddresses[address(0xaDC0A789F09f3A936B370DF8A1880527Ad86222f)] = true;
    WhitelistedAddresses[address(0x17Ff335E1B89CA48397A38fFE2Bb7013143d7DE6)] = true;
    WhitelistedAddresses[address(0xd8ddd4A77C646DEBFFe67Bfbf6EF5666b8599b82)] = true;
    WhitelistedAddresses[address(0xAb1b9521de0F0A30c43817c66C54C06A95548058)] = true;
    WhitelistedAddresses[address(0x8Ee13d38cDdfA16d9102C06f8C6cF12A1963CbDc)] = true;
    WhitelistedAddresses[address(0xA89f7b84FCC3Fb5d6422df5bAb038C353C1ca081)] = true;
    WhitelistedAddresses[address(0x71C228fE764DAd8AF5425b6E409498d0c296AcBa)] = true;
    WhitelistedAddresses[address(0x0586566A17125051792b66c9d3f1f8917db2DE87)] = true;
    WhitelistedAddresses[address(0x6Cfd46fD992E7E0D8D836c4101dBFf6aD7201d7C)] = true;
    WhitelistedAddresses[address(0xCC9d0c2B167E08791611c555fC6cFfd06c32CA3e)] = true;
    WhitelistedAddresses[address(0x00a969B5AF9C9ecBDED435C980923B088A108E02)] = true;
    WhitelistedAddresses[address(0x1e51eACe7F43cF52C7ac62e9368D6d5704f90CE8)] = true;
    WhitelistedAddresses[address(0xcbbbB6391F86D863144c769c283f01eE10583591)] = true;
    WhitelistedAddresses[address(0x477a4B0E6C0A032bCe1bBa17212C812283155203)] = true;
    WhitelistedAddresses[address(0x7Bf8ce50e493b7117230Fdc60AD9Aa229cfb5D27)] = true;
    WhitelistedAddresses[address(0x260e3eF2Cdf93E1bE2a1eEA90F8aE154165acF43)] = true;
    WhitelistedAddresses[address(0xedF85C7fae46Ab9961A9A93252a264d3F78241f1)] = true;
    WhitelistedAddresses[address(0xD7646114Bd2f5953391aBdA4e1439DC5D193961c)] = true;
    WhitelistedAddresses[address(0xf9E3C49ECE851fed3343FdfBDA8C21228D7F14D0)] = true;
    WhitelistedAddresses[address(0x69eeAfA89D44Fe07a0387e6e06f0343f77E4FbdE)] = true;
    WhitelistedAddresses[address(0xcF0F10F2e4641395A15A4688D60BF4F4E266230D)] = true;
    WhitelistedAddresses[address(0x500ac2E0670A1C6881a7bE290a5Df9bc119f9b91)] = true;
    WhitelistedAddresses[address(0x0eA61442e781Af56E5147Fb1761cfA1E60215bed)] = true;
    WhitelistedAddresses[address(0xA39d385628bd00438F8A9Ba4050a25A0210f84eb)] = true;
    WhitelistedAddresses[address(0xf35bcA2b10934D9D37bf10bDb94be3bb091F4224)] = true;
    WhitelistedAddresses[address(0x8C73E2538Af4e5161c286C04b49B4C9Fed89711b)] = true;
    WhitelistedAddresses[address(0xDEb9Ce243ae25449269760ea809bfF031a9F2c3b)] = true;
    WhitelistedAddresses[address(0xfABe2B0814E12072dfE5e28520BfEb8Eaf4BF88C)] = true;
    WhitelistedAddresses[address(0xE6eEeCc0E6df1ba46c6f5e00B74A920448d54A6a)] = true;
    WhitelistedAddresses[address(0x5F746D98B7c6585CB562e99cADdE7F2F259f1DD1)] = true;
    WhitelistedAddresses[address(0x32E4941C48AfBc0c6C1248f4E2B3A57702E6Cafa)] = true;
    WhitelistedAddresses[address(0xA699C70E8d840B0deD799Cb1e6650Dd988F7c503)] = true;
    WhitelistedAddresses[address(0x635D7202B058ca37c57b6748F57B78A47F6E857c)] = true;
    WhitelistedAddresses[address(0x651741aD4945bE1B8fEC753168DA613FC2060c01)] = true;
    WhitelistedAddresses[address(0x5418569002CDC5cB7290f6175682731E0824ca7F)] = true;
    WhitelistedAddresses[address(0x862Df13a2788Aba2da275cc54A9Fa5Fb13Ff06e6)] = true;
    WhitelistedAddresses[address(0x896caD7806db533b7b57CF64B63ac3280AAD86aD)] = true;
    WhitelistedAddresses[address(0xc55a4f326351627AF9c19982856B563fF926d412)] = true;
    WhitelistedAddresses[address(0x421f5701278Eb177E1C1301FD22a5d32fAfD051a)] = true;
    WhitelistedAddresses[address(0x38B06eb5a6b8B99930F4a95de0d31120d856fB76)] = true;
    WhitelistedAddresses[address(0x70F94eeB2A15Ce4C560D1151649766576078E47B)] = true;
    WhitelistedAddresses[address(0xfe02C02CA4cfF78EaD96BB8b2356EB5f0eB6FCc2)] = true;
    WhitelistedAddresses[address(0xE444b87b24dcA580335C8c68f17a9bAE23a9f343)] = true;
    WhitelistedAddresses[address(0x9fca8A43827D1b5eb5BCa6b4e06A63E690684727)] = true;
    WhitelistedAddresses[address(0x4EdA99B9cF9599ECC287A51607853Beef3622164)] = true;
    WhitelistedAddresses[address(0xB82C3E63A224Ff8AB687952EDc322df55EFB7248)] = true;
    WhitelistedAddresses[address(0x7E06923A4c7CB47612dF661E04551BDc986EEB51)] = true;
    WhitelistedAddresses[address(0xC3f97A825518404a2F303D7B057dd19B5B4ED63c)] = true;
    WhitelistedAddresses[address(0x7062ebD460C210FafDfa1DC501e8dFB1e397E4aD)] = true;
    WhitelistedAddresses[address(0x0eDA343D220bd110072e176A3225d5e9657F56f2)] = true;
    WhitelistedAddresses[address(0x0B60638D1D29A12F3Af013F508B2eB30664a94ce)] = true;
    WhitelistedAddresses[address(0xD7fE1FAc2F93740F72C94D1911b1b7773722126b)] = true;
    WhitelistedAddresses[address(0xF5D373E30f6dF250eCed2aF19cb2F55d39a7192E)] = true;
    WhitelistedAddresses[address(0x2A9CdFC0e068f84A33bBF9055756B2449705Cd68)] = true;
    WhitelistedAddresses[address(0xe1A647FFca8d7Df36f4b3039F285a44f65b08337)] = true;
    WhitelistedAddresses[address(0x77350B2e23c778b1bCcD0EDD97c6815cC9A27A17)] = true;
    WhitelistedAddresses[address(0x9448BD67937bDEe1A1980390582ca19aAA65CB0D)] = true;
    WhitelistedAddresses[address(0x369EEF3860061Fe441b8DB7BB9Ba1dD30A04CABa)] = true;
    WhitelistedAddresses[address(0xea32C85c60E7511f3a2D7E17514c56FCe650bbBB)] = true;
    WhitelistedAddresses[address(0xf6d52d338d7E8402cD3e18B2DDa90F2f0921343a)] = true;
    WhitelistedAddresses[address(0x3C077b60163D0388a18fff0e907E0dE41E06B930)] = true;
    WhitelistedAddresses[address(0xE75Fd4D5cf9E8033Ca4C74fb4BA0fF93579452B0)] = true;
    WhitelistedAddresses[address(0x39480bd4566496ea4F283AF164f8c3eEC563d70B)] = true;
    WhitelistedAddresses[address(0xA12EEeAad1D13f0938FEBd6a1B0e8b10AB31dbD6)] = true;
    WhitelistedAddresses[address(0xE3F9Cb6D797B335BCE842F65FDbcbba9cA1b0599)] = true;
    WhitelistedAddresses[address(0xD3dB31a56bCcdDEF6D2eD7F4e0eAC198d43A24bA)] = true;
    WhitelistedAddresses[address(0x89ca22fA4355D45CDD12E7218878b29208a90FC9)] = true;
    WhitelistedAddresses[address(0x87631B45877794f9cdd50a70c827403e3C36d072)] = true;
    WhitelistedAddresses[address(0x940ec37d3Cde99a67f1d0377dF36f8f543D895F9)] = true;
    WhitelistedAddresses[address(0x898E46843A25132904dDcf8Ad6744BE686C22Bbe)] = true;
    WhitelistedAddresses[address(0xe453BcDaf790577bEA592Dbc43E6768a5dEa72bA)] = true;
    WhitelistedAddresses[address(0x3A31c0200a7395d67b0e61514722D3cb0204C5b5)] = true;
    WhitelistedAddresses[address(0x5d5641FFc02c05391d2588e18167651E01abB22d)] = true;
    WhitelistedAddresses[address(0xc7743379Cd33B3Ab3DF361110fbb0C363CE77687)] = true;
    WhitelistedAddresses[address(0x5Fc7FCB1f482CE9E0BE586b0Da2cA6248ed37c87)] = true;
    WhitelistedAddresses[address(0xC434dEC64723C6A9115311189bC488c63bd3dFD5)] = true;
    WhitelistedAddresses[address(0x81461501b083bd132F0040d7d1a595A4dd7071a3)] = true;
    WhitelistedAddresses[address(0x31DC1c6D894F12F41B6854279C45847E96B4919d)] = true;
    WhitelistedAddresses[address(0xBf2eF63aEaDCAA0252b6489d24647E38Ab1CF240)] = true;
    WhitelistedAddresses[address(0xd566A0b8f90F783B96bCEc0785dCA9D14d7F505C)] = true;
    WhitelistedAddresses[address(0xaFCf52fd0F571C424aE18Ad0e2f99608D85404fb)] = true;
    WhitelistedAddresses[address(0xD1bEC7AF67bf556D4A4b98db679D873eec87c0c8)] = true;
    WhitelistedAddresses[address(0x2758B31c399baFF893C085F2b2Ba2bDd8772bb99)] = true;
    WhitelistedAddresses[address(0x1dbF00bc3f40F551d79422a96367A6F58Ae59412)] = true;
    WhitelistedAddresses[address(0x3242743Ce82DB40511bcb7FEE58464A8a7706F67)] = true;
    WhitelistedAddresses[address(0x2514462974be3CF51bB54F2A9fA55a2c4cC99b45)] = true;
    WhitelistedAddresses[address(0x7eB46351792D5Db2d4Df2096C642a7d75DD5286a)] = true;
    WhitelistedAddresses[address(0xd0E9380c26b3546c70588ff7Fc52CeC4Fd644e20)] = true;
    WhitelistedAddresses[address(0x880AbAfe460360268B18A205C2872829eD3527E0)] = true;
    WhitelistedAddresses[address(0xdab2567b352fB273E4F78249c0F4e36a46cC1B50)] = true;
    WhitelistedAddresses[address(0xCA48004c5cd2575916382E4b3fb0888b6B93Bc01)] = true;
    WhitelistedAddresses[address(0xE3eE2232cA8E9aa9F69445C000F987A6fB4358D9)] = true;
    WhitelistedAddresses[address(0xD1Ab4c2DF29277eEf2c1b3515d9AbdB2859e58DA)] = true;
    WhitelistedAddresses[address(0xe4155046d5AdE07FcD9683d6cB980ac8348B8B9F)] = true;
    WhitelistedAddresses[address(0x2081BC6F0ed2e31fa40064D5Bc4bAc008ce7E85e)] = true;
    WhitelistedAddresses[address(0x998280C00D90Fa742Ca24BecD6D897d26cd1539F)] = true;
    WhitelistedAddresses[address(0xb99FF2A5FEA40C621D264d6985C1960BbB206773)] = true;
    WhitelistedAddresses[address(0xB916887D50a9b044F8f953154fb1db2B6f02Ef55)] = true;
    WhitelistedAddresses[address(0x176f5931c1Ef2701559851894633d234aAee3B00)] = true;
    WhitelistedAddresses[address(0xCC63471F9821C4722b73F950E263aF3738c3B43e)] = true;
    WhitelistedAddresses[address(0x46A83F3C0448513c3379ddF1E502F1b807a06CA3)] = true;
    WhitelistedAddresses[address(0xEeE4EEbF8CB0D14eCC4c31B9a13F3a92eD81D113)] = true;
    WhitelistedAddresses[address(0x172458fF1b115ba5C2076465977Baf6152C5Ac72)] = true;
    WhitelistedAddresses[address(0xfEaD33f2D968b7AaCBb7a38b8014b1C7734f86bB)] = true;
    WhitelistedAddresses[address(0x1e1F2A05747be3A55e89aE0C90AA977BCB8A8676)] = true;
    WhitelistedAddresses[address(0xfEf946a53fa03067fec194CD9392b52066ddAbC3)] = true;
    WhitelistedAddresses[address(0x1e06FDB842256f9CCe789d7c12E3c2b51B8D9f8a)] = true;
    WhitelistedAddresses[address(0x3A7A45807891758826EbE07d332641a00B4bfb5e)] = true;
    WhitelistedAddresses[address(0xE453fC5f3Ea25C450d3F996e7708e93f4EAdD6d2)] = true;
    WhitelistedAddresses[address(0x2AbbdcAE6dCb79539Eec185eC0110b7F33B8c00c)] = true;
    WhitelistedAddresses[address(0xfAcAA39d50006E2AdF348144Ab9F3209a5fF9934)] = true;
    WhitelistedAddresses[address(0xA4afB515dc5FCB4d40949bE1c9520Ae71C0220D0)] = true;
    WhitelistedAddresses[address(0x58C008A4D1BD809D0F98914154Cc8399E44F42d0)] = true;
    WhitelistedAddresses[address(0xaf496250Dddb00a0B211ABb849460B69Ca5f27Dd)] = true;
    WhitelistedAddresses[address(0xcE6882dB19a8cEA8095de48dDC7acDa3D2a00E5F)] = true;
    WhitelistedAddresses[address(0x62313a505A91CF71448c0a05A2837346F157Eb8B)] = true;
    WhitelistedAddresses[address(0x755bFdA33888639F18dF0141E4aec86f0F6e537c)] = true;
    WhitelistedAddresses[address(0xd5F8E8205Ce848D987754600F08D53b728F92Ef6)] = true;
    WhitelistedAddresses[address(0xBeA2465920827e2484aF359cDDAE02527044aF58)] = true;
    WhitelistedAddresses[address(0x6D9aa3F92B284de9d800a7ad667857BDB22A1319)] = true;
    WhitelistedAddresses[address(0x250D6544d18e43fa807333Eb0A747A62F5b25aA0)] = true;
    WhitelistedAddresses[address(0x47FC4127FCd4EA8Ddd88059C3a1abE98Ea25c57D)] = true;
    WhitelistedAddresses[address(0x34Efd1420B0934655880c8608baf27FE1DD37107)] = true;
    WhitelistedAddresses[address(0xb390d28b28ae42093C6EF9cbb1fb55ad53C60aB0)] = true;
    WhitelistedAddresses[address(0x9Af4b9C2aDdd427Aea06b5a312966767877dA4DC)] = true;
    WhitelistedAddresses[address(0x4087aDd0db7180a41482A5717d5566E864FCabfb)] = true;
    WhitelistedAddresses[address(0xd83eEfad08C551698C92Ad9796595809Bd891d8c)] = true;
    WhitelistedAddresses[address(0x7CAbb73f5b840B245ec2528751445dA1F6DD7EEE)] = true;
    WhitelistedAddresses[address(0x55f475fEad2707E65216a8db78448d7060E4B3f5)] = true;
    WhitelistedAddresses[address(0x015B5e3eEAad31C1C710241D60F2BdE66B586D73)] = true;
    WhitelistedAddresses[address(0xCcE9863cFb538E367751EECFe8CFf0632D7191C5)] = true;
    WhitelistedAddresses[address(0xdFf79F883F927625678E4F10fbFCA8630F722CDC)] = true;
    WhitelistedAddresses[address(0x5195682F5642EAAf42777B1559545f9b6c1E4258)] = true;
    WhitelistedAddresses[address(0x9638056432b30206B4975ee8bdb3cE8F038Ed371)] = true;
    WhitelistedAddresses[address(0xbC84054f87208680e74F31a229492F2d02B14b25)] = true;
    WhitelistedAddresses[address(0x75b0C95b1188A0Ba43409FEC7b1f8A6363868DbB)] = true;
    WhitelistedAddresses[address(0x29Ba5bb692AbA266e5cbF4dE191FdF01c4Ca3C83)] = true;
    WhitelistedAddresses[address(0xB1B79644D5480672C2b4a202fFe67F3907633587)] = true;
    WhitelistedAddresses[address(0xaE1e59e41a008CbCC0DDEe7fF7C8a98827E2f596)] = true;
    WhitelistedAddresses[address(0x0927bA4B9E7176efDb6FF254f5Fdc84D5dF87f84)] = true;
    WhitelistedAddresses[address(0xeBc453E098EA5Ca81E216441891c84BC4fB6e8E6)] = true;
    WhitelistedAddresses[address(0x52eb77844BD497Aa3Fe5F09256b4bA27472a22d5)] = true;
    WhitelistedAddresses[address(0x52BA15A2efbbBeF74B259329D82585DaA170dafB)] = true;
    WhitelistedAddresses[address(0xfFE13b6A6DD56B218dA98C60a37b84144E858826)] = true;
    WhitelistedAddresses[address(0x09E67Ff60d15A6ee730F9aAC94C1139FcB954fb5)] = true;
    WhitelistedAddresses[address(0x66095A7BCb23A134bF97836CBCB2b933836a5ae8)] = true;
    WhitelistedAddresses[address(0xC6C978FE118661d824C43D9cecdACA6BC0f3Fe1B)] = true;
    WhitelistedAddresses[address(0xe8196f3C76c691249C8675ed1ee896De322B7AE7)] = true;
    WhitelistedAddresses[address(0x32f65a9F649846f00Fd160C959E435a9500B2229)] = true;
    WhitelistedAddresses[address(0x68d8c1dA927723132ebE6c708Febc4cf9D4d7438)] = true;
    WhitelistedAddresses[address(0x0Ff056A0E2837DdE3aCb0E50dCf555Df9C34FA63)] = true;
    WhitelistedAddresses[address(0xB54B06c0769F78eF88B4c0CbF73E7bD8bC26Ed31)] = true;
    WhitelistedAddresses[address(0xdBC543ADDd5d92A2eB734f59cd3B98ac1a5414a3)] = true;
    WhitelistedAddresses[address(0xAD606B0DF82FcE15D86925eF758F1951559b30d6)] = true;
    WhitelistedAddresses[address(0x17251c8adb6CB6B831B0523BB6Cb2D0088B9CF74)] = true;
    WhitelistedAddresses[address(0x3c94B8a65F23bFf83C78B59F3C30C12f2D25cA7B)] = true;
    WhitelistedAddresses[address(0x25dFE94F20d26b14b76A564C660F939282Ad5720)] = true;
    WhitelistedAddresses[address(0x7054ddbBc1A354220A9F5BdA3afae150303E643d)] = true;
    WhitelistedAddresses[address(0x4C93191f1CD837448603Bd9bC28d9b4Aa44660E8)] = true;
    WhitelistedAddresses[address(0x9D2e823d8854802e3CAC6162f3aDa71AC30C8673)] = true;
    WhitelistedAddresses[address(0xaF81d9c86269982368d014937a926c91F285DA8f)] = true;
    WhitelistedAddresses[address(0x82A4ae53F9883f7beA6d771A7d5B3ac6e93278Ba)] = true;
    WhitelistedAddresses[address(0x43cB5a38678a6D835Cb52D5C35AA2f8D16488ca7)] = true;
    WhitelistedAddresses[address(0x93465888859a75b31fc8378288d906B328b4126F)] = true;
    WhitelistedAddresses[address(0x029e13C1dCde8972361C9552Ced69b97596e0E86)] = true;
    WhitelistedAddresses[address(0x0C0c4ea708CaB9f2974c8856cB4a6fEA81ce15f9)] = true;
    WhitelistedAddresses[address(0x1D3E52C1217458697291A6839C8aA3669F60239E)] = true;
    WhitelistedAddresses[address(0x3f05A475Ce0697E3861a6CC1E03A1bb0e2A26Cbd)] = true;
    WhitelistedAddresses[address(0x7c3B2e04f2C07b67dF7466071ec6017d86310279)] = true;
    WhitelistedAddresses[address(0x7BF70C7095614339488B89c6AB84b1181995D323)] = true;
    WhitelistedAddresses[address(0x27146Cd533760E0867db2647dad531FdE92d80EF)] = true;
    WhitelistedAddresses[address(0x45665A9481f7b23db15D045AF62cbB7EF4F051ce)] = true;
    WhitelistedAddresses[address(0x0324764daD031822BAD49e3d6fA57c9868f00edB)] = true;
    WhitelistedAddresses[address(0xFD51e62220e3bF59F1aE246a85ee7e77bd4C5818)] = true;
    WhitelistedAddresses[address(0xdB585E03a84AFf068455dAE488F942f6c1006812)] = true;
    WhitelistedAddresses[address(0x17D3689587d72E189E9EB6309a1cb7D125498796)] = true;
    WhitelistedAddresses[address(0x2d7Fc97cb70Fcd534499bD898E703d93287d0cfb)] = true;
    WhitelistedAddresses[address(0xC5eEcA42De080A546554977A955288C5C298f141)] = true;
    WhitelistedAddresses[address(0x86DF24ed835B3C5831c29c5c9Ec2eE9C58E8E161)] = true;
    WhitelistedAddresses[address(0xB42ce66b5d548c3dfd343570878beB4a3f8a70C8)] = true;
    WhitelistedAddresses[address(0x30B68C450AE2e7C33b70fF092d44a8aFE0496316)] = true;
    WhitelistedAddresses[address(0x38a6A0da8C66467A3bE19e293FB6A7A10fA7b7d2)] = true;
    WhitelistedAddresses[address(0x6397a1a452137b06b5a8ade0D2BD2017B7D1e09D)] = true;
    WhitelistedAddresses[address(0xD4239c4528AfEd77ce902448db34225d3B48f5b0)] = true;
    WhitelistedAddresses[address(0xCd11770a3cc4c313d5844686F7aA5Ec4B29E7787)] = true;
    WhitelistedAddresses[address(0xCda6B9d1FA49F7AbB709E4A9B8206b1B1e03Cc53)] = true;
    WhitelistedAddresses[address(0xF832685f095b5c33ff6cFB84d36473bA7D5A31fE)] = true;
    WhitelistedAddresses[address(0x87Ddcee59a22920338DBFf068670395854d73645)] = true;
    WhitelistedAddresses[address(0xAED970Dcd7BDF7966a2a660aC6d78B79F8AE0FdE)] = true;
    WhitelistedAddresses[address(0x17bAD89Bc66b238495A84a793Ae527a0e993F02c)] = true;
    WhitelistedAddresses[address(0x215bC454dA079d610abDf1619D1B29C7795A7996)] = true;
    WhitelistedAddresses[address(0xa49A4Dd47963445Ed838E58A44722d675827567b)] = true;
    WhitelistedAddresses[address(0xF191666E5696840D87f13BDCE5A6666090D06A2F)] = true;
    WhitelistedAddresses[address(0x716096659dd0b82D1A7fF07b02a9Eb743907017B)] = true;
    WhitelistedAddresses[address(0xA8879c580A54f190eD53b43d30dE269097aD7543)] = true;
    WhitelistedAddresses[address(0x400BCb08aedA22862577Ca2BD23c91aF78a1ee6B)] = true;
    WhitelistedAddresses[address(0x45d017a9Dc30c4baccC0CEfd2a52FafeAeFbC374)] = true;
    WhitelistedAddresses[address(0x4a7ca2770e38416A0F6752cB7c0362b262d50C89)] = true;
    WhitelistedAddresses[address(0x090E6dfF018F6f2C90Cdf28D517aDF056Fd826Fb)] = true;
    WhitelistedAddresses[address(0x03aC3B14Ac989671e2CeaB10A9D24e71381ce562)] = true;
    WhitelistedAddresses[address(0xe8815d64Ddfb81d413af256c5d49A6Ffc3E47984)] = true;
    WhitelistedAddresses[address(0x9A4068018fCE659f613c7a6582d12c2750dE91bA)] = true;
    WhitelistedAddresses[address(0xdaEE824A0519E1EaDE2a6988c36db3f0a3f874ac)] = true;
    WhitelistedAddresses[address(0xB0FA5B7309184e617AF38ed308bFbB99544a6CFc)] = true;
    WhitelistedAddresses[address(0x5D6a8b2CC08708438Fc421b503a1df4BA87Eb1A1)] = true;
    WhitelistedAddresses[address(0x9B7f79e13768e4dAbA808492E59CAF16aaAc952E)] = true;
    WhitelistedAddresses[address(0x6e12bd46B4B62Cecfc14537E3Fe2a0Fe8cb78C1a)] = true;
    WhitelistedAddresses[address(0xdf98A47fDEd48e95E9C779c983F6949Cf8E41eE6)] = true;
    WhitelistedAddresses[address(0x0559FB44AbE3b55074593E22d7E8DFC73750038a)] = true;
    WhitelistedAddresses[address(0x87B618AbD3dbBba3416a5B88C2f2b84B2444CFf6)] = true;
    WhitelistedAddresses[address(0x059B89883C29Bf8AeD94822e21Af0cfDD7Fe4A29)] = true;
    WhitelistedAddresses[address(0x74921cc55F6Aa5d436F701790E7FbFc9829764ad)] = true;
    WhitelistedAddresses[address(0x450eFDaeF71E0b1B8E0dB04F2fcCBd66FC992a60)] = true;
    WhitelistedAddresses[address(0xf07Fb6B2CF121B59737801cC98aBcD84D9Ea2269)] = true;
    WhitelistedAddresses[address(0xdfEb50F97Bb6A660697849Ac13645E2E26cC4915)] = true;
    WhitelistedAddresses[address(0x9953DA7f2161866afAAD3c844CaaeE35A262a001)] = true;
    WhitelistedAddresses[address(0x6B268881e12BcB9e4d550B009bA39eBB9cBaf9D7)] = true;
    WhitelistedAddresses[address(0x349F53De125fA615c72D978e42EdDBdE216cB3aF)] = true;
    WhitelistedAddresses[address(0x88382ac0262515b9784699E72B6eC49AC709d212)] = true;
    WhitelistedAddresses[address(0x4A3cA69Bac2Ac82ebd855375b8775b4D392c18b3)] = true;
    WhitelistedAddresses[address(0x43803B21E7D8a78a0c8487b6E9C1AD159c721Bb4)] = true;
    WhitelistedAddresses[address(0xefeB34f3A790d44DCFA7dED3341d2e9888F7A294)] = true;
    WhitelistedAddresses[address(0x2E5153Da5A5eBC0De21F23692B7c5cCE879c470e)] = true;
    WhitelistedAddresses[address(0xAc04BD6f87ac7792B2746C6b7a897b38dC54Caeb)] = true;
    WhitelistedAddresses[address(0x17aCc0e039E6a741027F49D9B75c1C2679D16EB6)] = true;
    WhitelistedAddresses[address(0x23097b6abA22896E3c1E5e2e79D8efad0C4A011e)] = true;
    WhitelistedAddresses[address(0x5246A3D6f191B9D0a35243aaC58258c653dE6F05)] = true;
    WhitelistedAddresses[address(0x48D48E3b1fF8Fd0B65D989BFb7FB303ac28D03f5)] = true;
    WhitelistedAddresses[address(0x7ab011Fe257e48A72Af66c3C08c2BaE45E9A1175)] = true;
    WhitelistedAddresses[address(0x308eEa5B27EaD5f2111cF7c4e586cEec75083200)] = true;
    WhitelistedAddresses[address(0x20151c34D01D6785493F3416b3f82812a3dbB46F)] = true;
    WhitelistedAddresses[address(0x4576f30b8428a5C93d11849B74A654F982975445)] = true;
    WhitelistedAddresses[address(0x2Bf446cfb88e70f0931434c7ee70B73de8AD6A10)] = true;
    WhitelistedAddresses[address(0x2024134471B874fc6D35765Be66DA1e56f2e4be1)] = true;
    WhitelistedAddresses[address(0x39A1b324bd8F501f600757733c163c0C73675297)] = true;
    WhitelistedAddresses[address(0x1860CA387F185480b1b8A02a3D04b539aD13b16A)] = true;
    WhitelistedAddresses[address(0xA6bF1e24e49a21BC2Cb5bbbD5befd04306EAC990)] = true;
    WhitelistedAddresses[address(0x5F50fac657C1D2B402B1fd5358f145e5Ad6d0F73)] = true;
    WhitelistedAddresses[address(0xbEFfddcf2E84106f77c2B60445Dc257D65e19a26)] = true;
    WhitelistedAddresses[address(0x14cB9FD23ED06875F5534af4e90dA147D0A7FF4F)] = true;
    WhitelistedAddresses[address(0x2718AA38cb0C94ba5d22A920b97942F359381683)] = true;
    WhitelistedAddresses[address(0xccd660f2ED0A68d2bda3a41BD2eB67904fdc95C4)] = true;
    WhitelistedAddresses[address(0x080979D7376b8a274DBD7971F3B4b5Da4538B8A4)] = true;
    WhitelistedAddresses[address(0x2c2Cd43748fE1b82E83EF9b47eF9A1771DB1f907)] = true;
    WhitelistedAddresses[address(0x8378f16DAd92B8aDe9024A2FE692a1F08beA6A6F)] = true;
    WhitelistedAddresses[address(0x8247F1669a3d7f7F703484E1D1E80F1598236CC1)] = true;
    WhitelistedAddresses[address(0xda3BB6f56e35aE6C62835a659867D6A370F02e0b)] = true;
    WhitelistedAddresses[address(0x399E88209FD80579aec54c51160141817F84FFdE)] = true;
    WhitelistedAddresses[address(0x5FE785B2f589c79c89DBbaFa217BD7dEdd8c918b)] = true;
    WhitelistedAddresses[address(0xd41a08cfb00C671865C121B49a9FD72CB88730eb)] = true;
    WhitelistedAddresses[address(0xa812a58b8cFb6f3648fBd8cc00485Bbcc43E5816)] = true;
    WhitelistedAddresses[address(0xEA143346Bd8eCa087d33eE68C104Ee7e36928B65)] = true;
    WhitelistedAddresses[address(0x78d5C3C0d4E18EEc6639960075ebBAF59d28B616)] = true;
    WhitelistedAddresses[address(0x94bD4722E64786b3Becc30919F77562F00074cce)] = true;
    WhitelistedAddresses[address(0xeBe542149af8FC42De564120ab8ddEdf227df1BF)] = true;
    WhitelistedAddresses[address(0x55951b0d29056FC78806bCb9BBC9f62a79142eEc)] = true;
    WhitelistedAddresses[address(0xb019253dD990de6e2D5ED399078e207138101A9c)] = true;
    WhitelistedAddresses[address(0xd66F0288aB69ECaB9596EDBBe62884E790754938)] = true;
    WhitelistedAddresses[address(0x5D8D277Eb3D552edc661E5a8073E40eb128454fB)] = true;
    WhitelistedAddresses[address(0x9c38d48D2b364E5a4c7805C589BAAf93A3fdAebA)] = true;
    WhitelistedAddresses[address(0x1cD72d8c5955Af057A7Eb0c2bEb538fC89769305)] = true;
    WhitelistedAddresses[address(0x5b0e6c5595038538356C04b05bcCCde037E02850)] = true;
    WhitelistedAddresses[address(0x27b8d11206bb4b412dd4Ad5700b3B57107140548)] = true;
    WhitelistedAddresses[address(0x7d3e3834Ddf4a3852eF85DB39Ebaf50B415aD3ed)] = true;
    WhitelistedAddresses[address(0xE9ab48Accb5F36A6F554F0A4395607F7A0540bB5)] = true;
    WhitelistedAddresses[address(0xF0C15C42d12a66A64C18B7B3AAAbD301850c2B67)] = true;
    WhitelistedAddresses[address(0x5C45599120E597770B8B78E0d619219c7721F2BD)] = true;
    WhitelistedAddresses[address(0xf3e6639Ec6e0A22ad89351c92cF2C6f6bfd8c560)] = true;
    WhitelistedAddresses[address(0x1DC8A1653EcdD65771112ED6a88854EfF47b6BEc)] = true;
    WhitelistedAddresses[address(0x9af8b77Bb54c40142F195E28591a21199090F84a)] = true;
    WhitelistedAddresses[address(0xf99f80f41822e5417B0e57F46de85509Eb5eA1Ce)] = true;
    WhitelistedAddresses[address(0xF0835c9ae1D0BD0f783846692A8ceCd8991Ad28A)] = true;
    WhitelistedAddresses[address(0x7Fb9B873f19C5ed62e5C1819478b09F1b09495c4)] = true;
    WhitelistedAddresses[address(0x17E76bCAa747467021033992479D007175b5cc36)] = true;
    WhitelistedAddresses[address(0x8694CE0e61cA9ec134b63A79630d329FB8A4e759)] = true;
    WhitelistedAddresses[address(0x00E4Ae82316CDEd8103c64d9C6F083fD4393f35E)] = true;
    WhitelistedAddresses[address(0x738C9f6618191dEb17078281469Ded0524072119)] = true;
    WhitelistedAddresses[address(0xF4EbF1061d7Fb49D66F1c07c23D27a07234A8Eeb)] = true;
    WhitelistedAddresses[address(0x9c5aB27aB9D8365819B47C504b549eC7664b4ccA)] = true;
    WhitelistedAddresses[address(0xb0cacc76f031658438219d2EAa84B630A0879F83)] = true;
    WhitelistedAddresses[address(0x14e0fD6B639F3d13cDd83d233F26e7369C38B847)] = true;
    WhitelistedAddresses[address(0x6f9cFAccA63145c906fAE462433Aa1d1F147eec9)] = true;
    WhitelistedAddresses[address(0xC1CFA03BbD30d3048e580edeE774B514d82B0750)] = true;
    WhitelistedAddresses[address(0x1013604e012A917E33104Bb0c63Cc98E1b8D2bdc)] = true;
    WhitelistedAddresses[address(0x11957F0758426b74eFFF2BDacd4e6d659509E367)] = true;
    WhitelistedAddresses[address(0xAee33D473C68f9B4946020d79021416ff0587005)] = true;
    WhitelistedAddresses[address(0x0788C6B29E4951C853f1BD0BB55B3a1471fC8ad7)] = true;
    WhitelistedAddresses[address(0x7aC4a333E14a0d059aB8828fC309b7909fE61681)] = true;
    WhitelistedAddresses[address(0x1c9D540818B79c5C366757eb591E688272D8953b)] = true;
    WhitelistedAddresses[address(0x2007b11534986215fAd4e8e8f6FaD05D1f5aECCA)] = true;
    WhitelistedAddresses[address(0xFc3859FC165E17a3f292d474b861A204888997C0)] = true;
    WhitelistedAddresses[address(0xFF8448EB5fF167D137086Bc2c922da507eB5CbDD)] = true;
    WhitelistedAddresses[address(0x1f37b88c0f7569D12ae233a3c63D4578A2e0aF66)] = true;
    WhitelistedAddresses[address(0x238b7D3eBcD03f90b76197A945715b51C6687415)] = true;
    WhitelistedAddresses[address(0x2Ab97866D53Adc3350Eb83B5bCF0f3011E4E4E6f)] = true;
    WhitelistedAddresses[address(0xC32291Fd1Cd878E5edE51b9Ebe5bc130BCfB9A76)] = true;
    WhitelistedAddresses[address(0x94cDb79f25C0E33d48F739925950a2D58313E193)] = true;
    WhitelistedAddresses[address(0x71f23Eb967C34394c26948b7C5436021458bCdD7)] = true;
    WhitelistedAddresses[address(0x7264a31d580bc78582344A0437EC1dbe42a84148)] = true;
    WhitelistedAddresses[address(0x7615317643361B0Be9E3C1d64C223e773e0C7A20)] = true;
    WhitelistedAddresses[address(0x559c85b59E0E37Af3cb7E215a46aaD5e941C6e65)] = true;
    WhitelistedAddresses[address(0x15F7320adb990020956D29Edb6ba17f3D468001e)] = true;
    WhitelistedAddresses[address(0x15FaBD08ae2c4C18a4018f9e3B1ADC54F844F95B)] = true;
    WhitelistedAddresses[address(0x188028eA8B6B57BBD9C42f3E65EF2ccd42D9D033)] = true;
    WhitelistedAddresses[address(0xb226dD18ea4f6B36a3463921EFA83e15524c25f1)] = true;
    WhitelistedAddresses[address(0xB4498D64082326Ab009EcED9b8B64567B86E3a53)] = true;
    WhitelistedAddresses[address(0x0A0006bb21B0CEB08BD974695E26B9C6510BB114)] = true;
    WhitelistedAddresses[address(0xa7917aEcBB4126391aF1503a4a084ecE3D3aAa80)] = true;
    WhitelistedAddresses[address(0xa7ea3B0F677262EA896b9040c258D2E7fF3ffC66)] = true;
    WhitelistedAddresses[address(0x2901a7D681543B07E48dC64f0F513fB769B40E3c)] = true;
    WhitelistedAddresses[address(0x04380BCa994CeEa8eC239eda3DdC70E4bc4487cF)] = true;
    WhitelistedAddresses[address(0x3C02F24aF73d33B1749C62D9b201A629DAD93742)] = true;
    WhitelistedAddresses[address(0x979261E0C07D40DC4C991304b2Ab0249FD31c979)] = true;
    WhitelistedAddresses[address(0xe969Bf18fbC0Ed94fBeB0821d347d0525a2C880A)] = true;
    WhitelistedAddresses[address(0x05823327Ce8B43f0950529C8488b5dF644E3c2ef)] = true;
    WhitelistedAddresses[address(0x84096fE398298FDE57E15da5bcf7dB382abDE421)] = true;
    WhitelistedAddresses[address(0x5616079eE92306558b7c70E3019dDc633645517c)] = true;
    WhitelistedAddresses[address(0x3732C25003D413c054d85cbC6575c6B065BDb69A)] = true;
    WhitelistedAddresses[address(0xD4d1773900E8365cAA14594E534A625cA9EFF8fF)] = true;
    WhitelistedAddresses[address(0xE2C5EC986f7b48f70Fe4044B82294DC695260E54)] = true;
    WhitelistedAddresses[address(0x87431Ebb78B12E9ea133eCC77705d4fB96f54441)] = true;
    WhitelistedAddresses[address(0x8E9725B51832b671d3F43bDb5B4b75042fb6821f)] = true;
    WhitelistedAddresses[address(0x39fe36cAfa28d84455f1A263621e95F91139F884)] = true;
    WhitelistedAddresses[address(0x845911D40007DFB6Db4E5dB79b6C7A2F60ac1485)] = true;
    WhitelistedAddresses[address(0xA50D8F5AAb636799e84c5a97d4C21492c52618eF)] = true;
    WhitelistedAddresses[address(0x5334e05877093c4cC04Cf47Db9444fBC556FE60e)] = true;
    WhitelistedAddresses[address(0x4764E2D1f34406CBfCBB91759103db97d8327E36)] = true;
    WhitelistedAddresses[address(0x6Db1414BBf432054E33D367F4Cfc8617e8f46d55)] = true;
    WhitelistedAddresses[address(0x9d7e32A6c87bA52F7fB34133935E70c3ec0e1cE4)] = true;
    WhitelistedAddresses[address(0x60E95A5315961135Ce38f0f15178EeB60C1D4596)] = true;
    WhitelistedAddresses[address(0x49c641b20e577666a67102EFb8D9e3e0258C5263)] = true;
    WhitelistedAddresses[address(0xcda444de55ac909992f2213d0A1737D78236e167)] = true;
    WhitelistedAddresses[address(0xe239b3d8eE1906eD368a548be0E0911B6cB3Ab72)] = true;
    WhitelistedAddresses[address(0xeFd42F8d9090B6Fd4ec0dBC48DD031400546Ed5E)] = true;
    WhitelistedAddresses[address(0xB30aa186524eE72711B9a75D8A6a3feA9A4D1f47)] = true;
    WhitelistedAddresses[address(0xD77033a7F57EBbadfCe5ADf9Ab086BD4C4b6C509)] = true;
    WhitelistedAddresses[address(0x6F1A18E399F8Da8B4019c24fbE755f0C96af61fB)] = true;
    WhitelistedAddresses[address(0x25a915C43e2E9E5AA081f371A6679D01C011384a)] = true;
    WhitelistedAddresses[address(0xb200663fbEAE3C28D898453Fb4Fd9898cF0Bcbd8)] = true;
    WhitelistedAddresses[address(0x2330c220E5D722141ED1269f44173FC2D1d4703e)] = true;
    WhitelistedAddresses[address(0x0806CA8FF8114dbeC2f3265a59b4E942Ce09E9b7)] = true;
    WhitelistedAddresses[address(0xaA6c89F90078210ea92c4e449C00551F7254DCf6)] = true;
    WhitelistedAddresses[address(0x0eAc6A5758b19890B21515Ccf49DC80Cb79211dc)] = true;
    WhitelistedAddresses[address(0x4f960d763e2d153299F310432fD8e16F75cc9BCa)] = true;
    WhitelistedAddresses[address(0xE3D0Ca354320c7D0B87722664cb4C4dd98C3eD03)] = true;
    WhitelistedAddresses[address(0xb42D498c014Bd44A45aE0965a8C3E2E777fcf990)] = true;
    WhitelistedAddresses[address(0xDb4bAC8afB4C52d9ef0DeAd2891d2D8CF6adB72b)] = true;
    WhitelistedAddresses[address(0xdE1AAe3E605259ECfCe4f6165D70f161FEdCb721)] = true;
    WhitelistedAddresses[address(0x6c8F7D53760B0c819686A99AF709815fb0FED0Ca)] = true;
    WhitelistedAddresses[address(0x287D8A3db7a750a89DfFcB61792d0db91E3AD85f)] = true;
    WhitelistedAddresses[address(0x299C0d67FF73FDd5148b8d5947D819962eC16Ed2)] = true;
    WhitelistedAddresses[address(0x151FA4451121a83634aA70c9235C550E45EC1D58)] = true;
    WhitelistedAddresses[address(0xb97Ce8F7fa5864505a06777117dCE2b87337dF30)] = true;
    WhitelistedAddresses[address(0xd56180C5460cBC727B8dA09ec35713F5A04ab563)] = true;
    WhitelistedAddresses[address(0x2d345bA5714F6F87a14E1d1F079c5De8Ea920F42)] = true;
    WhitelistedAddresses[address(0xdBF4bAD6BF5450AFCAaAAd624834158fcCD4124e)] = true;
    WhitelistedAddresses[address(0x09A942556dD4465Fd5B94bF39864B52CD0B36f8F)] = true;
    WhitelistedAddresses[address(0x15a6C99A170EAf21A1d0D2a88979658AB75ae8e3)] = true;
    WhitelistedAddresses[address(0x9B8118Da271Fb74b520A64bfC216D950496FB8D8)] = true;
    WhitelistedAddresses[address(0x411479FEe0448D48308f617446D305845b556B6A)] = true;
    WhitelistedAddresses[address(0xc886dB8b8CD260f5ee38Ba3d8f8E9324EE27EA33)] = true;
    WhitelistedAddresses[address(0xdb9986bd0596B8a4873b09b4a10B81B13f2C9dDd)] = true;
    WhitelistedAddresses[address(0xB0Fd1E07b71Dc879189229250C189e24Db7f6979)] = true;
    WhitelistedAddresses[address(0x054Cf4271a865B61C34536B85c76de5DDb3508Db)] = true;
    WhitelistedAddresses[address(0xbD8F35865F196c97161F913eFC8F2e365E29DBbd)] = true;
    WhitelistedAddresses[address(0x3cE0276c0f9Ba62B4121287cA73898f068dfe775)] = true;
    WhitelistedAddresses[address(0xDf0c58b78aa30F906f59599352B8Aa4f92520beb)] = true;
    WhitelistedAddresses[address(0xb4383C2Ec9c28006D50e1c9954263C242177B932)] = true;
    WhitelistedAddresses[address(0x41CeEa536dff094410420A66D4Ca6956a6850ceE)] = true;
    WhitelistedAddresses[address(0x113FBce4BA8Ccf6dC98C79A40E8B02832d0F3258)] = true;
    WhitelistedAddresses[address(0x217ACda0590147A9E1015Aab869d3962fc21515c)] = true;
    WhitelistedAddresses[address(0xb0a5c14Bb5A7fb3d8591f57AA53423c9A9b1dCF6)] = true;
    WhitelistedAddresses[address(0x56ab10C2B0507cB9447Ae7cd4cfC1f86DED8a348)] = true;
    WhitelistedAddresses[address(0x7E86463e7C62c9EcA0CCdE14a06dAa4Eb4c689Bb)] = true;
    WhitelistedAddresses[address(0xF9917f48EEE692142F72d1D87D919e622350a260)] = true;
    WhitelistedAddresses[address(0xAF2965BDA9ca6A7148a20aaC46AbC722C8A06c3F)] = true;
    WhitelistedAddresses[address(0x6930353Ff70baA600Fd241BfC64A99d9C1b9E25A)] = true;
    WhitelistedAddresses[address(0xcD04d24128F52b08e1e7d71d3C46d1488fA1c66C)] = true;
    WhitelistedAddresses[address(0xEd0BEBed0A940731C5A5eEF2fcf7b837BDFd4bE2)] = true;
    WhitelistedAddresses[address(0xE2C986E423A6A1e77e865566A194851C95F57569)] = true;
    WhitelistedAddresses[address(0x19e5D4BaE3A1A10A914C4E0c22D5ac247a338772)] = true;
    WhitelistedAddresses[address(0x2a575E1547bB392DbE5A971Cbb9b05EA5DEc0d4f)] = true;
    WhitelistedAddresses[address(0x234dBfc9739598aBCD38e2072047BF2568930692)] = true;
    WhitelistedAddresses[address(0xADF6C68725918fab2E384e16bAf14F3dbB59258F)] = true;
    WhitelistedAddresses[address(0xE597D8a65604b109510A6bdF3730E23d22e61482)] = true;
    WhitelistedAddresses[address(0x39c6482dC57d33A6a30980aa31445348887380fB)] = true;
    WhitelistedAddresses[address(0x59178464f84A514b66092A35d2d01401f561F49D)] = true;
    WhitelistedAddresses[address(0xb7CA89cf6f7d21c6e898f57871351D0A951CFe70)] = true;
    WhitelistedAddresses[address(0xdc5c500ffEc9C7753a535D1EB7C3E1209818E726)] = true;
    WhitelistedAddresses[address(0xfFd4cb56191f80C80CA8Ba0C210ff39c01BA0226)] = true;
    WhitelistedAddresses[address(0xcd464768906Cb1DF8C69594CA4A72ea7D5C98f9b)] = true;
    WhitelistedAddresses[address(0x8bB79B61633A6614c25D823306FfC10993F41EC5)] = true;
    WhitelistedAddresses[address(0x50f6866be52085478DD2c7fE9c04443448293e5E)] = true;
    WhitelistedAddresses[address(0x25Dbb59402Ae4Fc9f047d5C0727a840EeD031208)] = true;
    WhitelistedAddresses[address(0x538682d8A255d5DB6ed93D903D0C80D4e0c474B8)] = true;
    WhitelistedAddresses[address(0x45909B8ACc1ace1Ba9910EA7023EEDa492ba058c)] = true;
    WhitelistedAddresses[address(0x2F850E3d5668D88178E06Bf7b4224Fa1b125c4C3)] = true;
    WhitelistedAddresses[address(0x22584aB547B0958Ce4363e6c47b93Da67AC1558a)] = true;
    WhitelistedAddresses[address(0x375d48cD18D06C4B580741FcBA729129425Ba8ee)] = true;
    WhitelistedAddresses[address(0x2245CE84f82D8d52DE1C4faF46c800077980834F)] = true;
    WhitelistedAddresses[address(0x823C8Ad1E4F3906A4ac9c178a4FfE79385c2ce5e)] = true;
    WhitelistedAddresses[address(0xB479bAdca9d5310ed0c04E3911436646e91FCd1F)] = true;
    WhitelistedAddresses[address(0x093e94741A8F96Bf44Ec92d5F0E464B109242138)] = true;
    WhitelistedAddresses[address(0x25f66cFC9b7954F658A551C93d29A4d40c65Ab22)] = true;
    WhitelistedAddresses[address(0x30bb881A96213b4dcA453564E9eEca366F4dB4d4)] = true;
    WhitelistedAddresses[address(0x27fE198859aC9b99BB36cFef99D94459dAd51Ad8)] = true;
    WhitelistedAddresses[address(0x604C4365Ec2F35F01Df0470CC1d92248d6186A5B)] = true;
    WhitelistedAddresses[address(0x78450D6179D8C564BfaF5Cf037e11404a43ab123)] = true;
    WhitelistedAddresses[address(0xED0BB2Cdf15324954f7612F419d71ABA2542a13C)] = true;
    WhitelistedAddresses[address(0x9D8bcaBD07139ce555cA6bDc574D9f42701f89A8)] = true;
    WhitelistedAddresses[address(0x66791b6dDc1FB01782e27E2614Ae5Dd47C7773bA)] = true;
    WhitelistedAddresses[address(0x05dCf2D321c894e1c53891B1A4A980f96DbA5F91)] = true;
  }

  function participate() public payable nonReentrant onlyWhitelisted presaleOnGoing {
    uint256 weiAmount = msg.value;
    address beneficiary = _msgSender();

    require(ParticipatedAmount[beneficiary] + weiAmount >= minPurchase, "Min purchase amount not reached");
    require(ParticipatedAmount[beneficiary] + weiAmount <= maxPurchase, "Amount exceeded max purchase");
    require(address(this).balance + weiAmount <= maxCap, "Amount exceeded max cap");

    TokenClaimed[beneficiary] = 0;
    ParticipatedAmount[beneficiary] += weiAmount;
    TokenBought[beneficiary] += weiAmount * rate / 1 ether;
  }

  function claimToken() public nonReentrant onlyWhitelisted {
    require(block.timestamp > endTime, "Presale is not ended yet");
    require(openRefund == false, "Presale is refunded");
    address beneficiary = _msgSender();
    require(TokenBought[beneficiary] > 0, "Not participated in presale");
    uint256 tokens = 0;

    for (uint8 i=0; i<11; i++) {
      if (block.timestamp >= claimTimestamps[i]) tokens += claimPercentages[i] * TokenBought[beneficiary] / 100;
    }

    uint256 eligibleToClaim = tokens - TokenClaimed[beneficiary];

    require(eligibleToClaim > 0, "No tokens to claim");

    TokenClaimed[beneficiary] += eligibleToClaim;
    // Transfer the tokens to the beneficiary
    HORNY.safeTransfer(beneficiary, eligibleToClaim);
  }

  /// @dev allows a user to claim a refund if the presale did not reach the minimum cap.
  function claimRefund() public {
    address beneficiary = _msgSender();
    require(openRefund == true, "Refund is not open");
    require(ParticipatedAmount[beneficiary] > 0, "Invalid address");
    require(RefundsClaimed[beneficiary] == false, "Refund already claimed");

    RefundsClaimed[beneficiary] = true;
    payable(beneficiary).transfer(ParticipatedAmount[beneficiary]);
  }

  /// @dev transfers tokens to the specified address.
  function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
    HORNY.transfer(beneficiary, tokenAmount);
  }

  /// @dev delivers tokens to the beneficiary after a purchase has been made.
  function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
    _deliverTokens(beneficiary, tokenAmount);
  }

  receive() external payable {
    participate();
  }

  function startRefund() public onlyOwner {
    openRefund = true;
  }

  function withdrawETH() external onlyOwner {
    require(address(this).balance > 0, "Contract has no ETH");
    payable(DEV).transfer(address(this).balance);
  }

  /// @dev in case max cap not reached, withdraw to be burn
  function withdrawHORNY() external onlyOwner {
    require(HORNY.balanceOf(address(this)) > 0, "Contract has no HORNY");
    HORNY.transfer(owner(), HORNY.balanceOf(address(this)));
  }

  function addToWhitelist(address[] memory _addresses) external onlyOwner {
    for (uint256 i = 0; i < _addresses.length; i++) {
      WhitelistedAddresses[_addresses[i]] = true;
    }
  }

  function removeFromWhitelist(address[] memory _addresses) external onlyOwner {
    for (uint256 i = 0; i < _addresses.length; i++) {
      WhitelistedAddresses[_addresses[i]] = false;
    }
  }

  function updatePresaleTime(uint256 _startTime, uint256 _endTime) public onlyOwner {
    require(endTime > startTime, "close time must be greater than open time");
    startTime = _startTime;
    endTime = _endTime;
  }

  /// @dev token balance
  function tokensAvailable() public view returns (uint256) {
    return HORNY.balanceOf(address(this));
  }
}