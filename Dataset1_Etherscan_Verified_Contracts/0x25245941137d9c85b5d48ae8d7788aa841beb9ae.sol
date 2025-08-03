// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 * ```
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
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
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
        return _values(set._inner);
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
     * @dev Returns the number of values on the set. O(1).
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
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMasterBids {
    function getAssetPid(address asset) external view returns (uint256 pid);

    function poolLength() external view returns (uint256);

    function pendingTokens(
        uint256 _pid,
        address _user
    ) external view returns (uint256 pendingRewards, uint256[] memory pendingRewarderRewards);

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount) external returns (uint256, uint256[] memory);

    function multiClaim(
        uint256[] memory _pids
    ) external returns (uint256 transferred, uint256[] memory amounts, uint256[][] memory additionalRewards);

    function withdraw(uint256 _pid, uint256 _amount) external returns (uint256, uint256[] memory);

    function emergencyWithdraw(uint256 _pid) external;

    function migrate(uint256[] calldata _pids) external;

    function depositFor(uint256 _pid, uint256 _amount, address _user) external;

    function updateFactor(address _user, uint256 _newVeWomBalance) external;

    function notifyRewardAmount(address _lpToken, uint256 _amount, uint256 _rewardDuration) external;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewarder {
    function onReward(address _user) external returns (uint256[] memory rewards);

    function pendingTokens(address _user) external view returns (uint256[] memory rewards);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

/**
 * @dev Interface of the VeBids
 */
interface IVeBids {
    
    struct Breeding {
        uint48 unlockTime;
        uint104 bidsAmount;
        uint104 veBIDSAmount;
    }

    struct UserInfo {
        Breeding[] breedings;
        uint256 userTotalBidsLocked;
    }

    function totalSupply() external view returns (uint256);

    function balanceOf(address _addr) external view returns (uint256);

    function isUser(address _addr) external view returns (bool);

    function getUserOverview(address _addr) external view returns (uint256 womLocked, uint256 veWomBalance);

    function getUserInfo(address addr) external view returns (UserInfo memory);

    function mint(uint256 amount, uint256 lockDays) external returns (uint256 veWomAmount);

    function burn(uint256 slot) external;

    function update(uint256 slot, uint256 lockDays) external returns (uint256 newVeWomAmount);
}
// SPDX-License-Identifier: GPL-3.0

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.8.5;

library DSMath {
    uint256 public constant WAD = 10 ** 18;

    // Babylonian Method
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    // Babylonian Method with initial guess
    function sqrt(uint256 y, uint256 guess) internal pure returns (uint256 z) {
        if (y > 3) {
            if (guess > y || guess == 0) {
                z = y;
            } else {
                z = guess;
            }
            uint256 x = (y / z + z) / 2;
            while (x != z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * y) + (WAD / 2)) / WAD;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * WAD) + (y / 2)) / y;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../library/DSMath.sol";
import "../interfaces/IVeBids.sol";
import "../interfaces/IMasterBids.sol";
import "../interfaces/IRewarder.sol";

interface IVoter {
    function distribute(address _lpToken) external;
}

/// @title MasterBids
/// @notice MasterBids is a boss. He is not afraid of any snakes. In fact, he drinks their venoms. So, veBids holders boost
/// their (boosted) emissions. This contract rewards users in function of their amount of lp staked (base pool) factor (boosted pool)
/// Factor and sumOfFactors are updated by contract VeBids.sol after any veBids minting/burning (veERC20Upgradeable hook).
/// Note that it's ownable and the owner wields tremendous power. The ownership
/// will be safeTransferred to a governance smart contract once Bids is sufficiently
/// distributed and the community can show to govern itself.
/// @dev Updates:
/// - Compatible with gauge voting
contract MasterBids is Ownable, ReentrancyGuard, Pausable, IMasterBids {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        // storage slot 1
        uint128 amount; // 20.18 fixed point. How many LP tokens the user has provided.
        uint128 factor; // 20.18 fixed point. boosted factor = sqrt (lpAmount * veBids.balanceOf())
        // storage slot 2
        uint128 rewardDebt; // 20.18 fixed point. Reward debt. See explanation below.
        uint128 pendingBids; // 20.18 fixed point. Amount of pending Bids
        //
        // We do some fancy math here. Basically, any point in time, the amount of Bids
        // entitled to a user but is pending to be distributed is:
        //
        //   ((user.amount * pool.accBidsPerShare + user.factor * pool.accBidsPerFactorShare) / 1e12) -
        //        user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accBidsPerShare`, `accBidsPerFactorShare` (and `lastRewardTimestamp`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfoV3 {
        IERC20 lpToken; // Address of LP token contract.
        IRewarder rewarder;
        uint40 periodFinish;
        ////
        uint128 sumOfFactors; // 20.18 fixed point. the sum of all boosted factors by all of the users in the pool
        uint128 rewardRate; // 20.18 fixed point.
        ////
        uint104 accBidsPerShare; // 19.12 fixed point. Accumulated Bids per share, times 1e12.
        uint104 accBidsPerFactorShare; // 19.12 fixed point. Accumulated Bids per factor share
        uint40 lastRewardTimestamp;
    }

    uint256 public constant ACC_TOKEN_PRECISION = 1e12;

    // Bids token
    IERC20 public Bids;
    // Venom does not seem to hurt the Bids, it only makes it stronger.
    IVeBids public veBids;
    // New Master Bids address for future migrations
    IMasterBids public newMasterBids;
    // Address of Voter
    address public voter;
    //Dictates if voter has distribute function
    bool public voterIsCallable;
    // Base partition emissions (e.g. 300 for 30%).
    // BasePartition and boostedPartition add up to 1000 for 100%
    uint16 public basePartition;
    // Set of all LP tokens that have been added as pools
    EnumerableSet.AddressSet private lpTokens;
    // Info of each pool.
    PoolInfoV3[] public poolInfoV3;
    // userInfo[pid][user], Info of each user that stakes LP tokens
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Mapping of asset to pid. Offset by +1 to distinguish with default value
    mapping(address => uint256) internal assetPid;

    event Add(uint256 indexed pid, IERC20 indexed lpToken);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event DepositFor(address indexed user, uint256 indexed pid, uint256 amount);
    event SetRewarder(uint256 indexed pid, IRewarder rewarder);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event UpdateEmissionPartition(address indexed user, uint256 basePartition, uint256 boostedPartition);
    event UpdateVeBids(address indexed user, address oldVeBids, address newVeBids);
    event UpdateVoter(address indexed user, address oldVoter, address newVoter, bool callable);
    event EmergencyBidsWithdraw(address owner, uint256 balance);
    event NewMaster(address _newMaster);

    /// @dev Modifier ensuring that certain function can only be called by VeBids
    modifier onlyVeBids() {
        require(address(veBids) == msg.sender, "MasterBids: caller is not VeBids");
        _;
    }

    /// @dev Modifier ensuring that certain function can only be called by Voter
    modifier onlyVoter() {
        require(address(voter) == msg.sender, "MasterBids: caller is not Voter");
        _;
    }

    constructor(IERC20 _Bids, IVeBids _veBids, address _voter, uint16 _basePartition) {
        require(address(_Bids) != address(0), "Bids address cannot be zero");
        require(address(_veBids) != address(0), "VeBids address cannot be zero");
        require(_voter != address(0), "Voter address cannot be zero");
        require(_basePartition <= 1000, "base partition must be in range 0, 1000");

        Bids = _Bids;
        veBids = _veBids;
        voter = _voter;
        basePartition = _basePartition;
    }

    /**
     * @dev pause pool, restricting certain operations
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev unpause pool, enabling certain operations
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    function setNewMasterBids(IMasterBids _newMasterBids) external onlyOwner {
        newMasterBids = _newMasterBids;
        emit NewMaster(address(_newMasterBids));
    }

    /// @notice Add a new lp to the pool. Can only be called by the owner.
    /// @dev Reverts if the same LP token is added more than once.
    /// @param _lpToken the corresponding lp token
    /// @param _rewarder the contract that implements "onReward(user)" that is called on user operation
    function add(IERC20 _lpToken, IRewarder _rewarder) external onlyOwner {
        require(Address.isContract(address(_lpToken)), "add: LP token must be a valid contract");
        require(!lpTokens.contains(address(_lpToken)), "add: LP already added");

        // update PoolInfoV3 with the new LP
        poolInfoV3.push(
            PoolInfoV3({
                lpToken: _lpToken,
                rewarder: _rewarder,
                lastRewardTimestamp: uint40(block.timestamp),
                accBidsPerShare: 0,
                accBidsPerFactorShare: 0,
                sumOfFactors: 0,
                periodFinish: uint40(block.timestamp),
                rewardRate: 0
            })
        );
        assetPid[address(_lpToken)] = poolInfoV3.length;

        // add lpToken to the lpTokens enumerable set
        lpTokens.add(address(_lpToken));
        emit Add(poolInfoV3.length - 1, _lpToken);
    }

    /// @notice Update reward variables for all pools.
    /// @dev Be careful of gas spending!
    function massUpdatePools() public override {
        uint256 length = poolInfoV3.length;
        for (uint256 pid; pid < length; ++pid) {
            _updatePool(pid);
        }
    }

    /// @notice Update reward variables of the given pool
    /// @param _pid the pool id
    function updatePool(uint256 _pid) external override {
        _updatePool(_pid);
    }

    function _updatePool(uint256 _pid) private {
        PoolInfoV3 storage pool = poolInfoV3[_pid];

        if (block.timestamp > pool.lastRewardTimestamp) {
            (uint256 accBidsPerShare, uint256 accBidsPerFactorShare) = calRewardPerUnit(_pid);
            pool.accBidsPerShare = to104(accBidsPerShare);
            pool.accBidsPerFactorShare = to104(accBidsPerFactorShare);
            pool.lastRewardTimestamp = uint40(lastTimeRewardApplicable(pool.periodFinish));
        }

        // We can consider to skip this function to minimize gas
        if (voterIsCallable) {
            IVoter(voter).distribute(address(pool.lpToken));
        }
    }

    /// @dev Refer to synthetix/StakingRewards.sol notifyRewardAmount
    /// Note: This looks safe from reentrancy.
    function notifyRewardAmount(address _lpToken, uint256 _amount, uint256 _rewardDuration) external override onlyVoter {
        require(_amount > 0, "notifyRewardAmount: zero amount");

        // this line reverts if asset is not in the list
        uint256 pid = assetPid[_lpToken] - 1;
        PoolInfoV3 storage pool = poolInfoV3[pid];
        if (pool.lastRewardTimestamp >= pool.periodFinish) {
            pool.rewardRate = to128(_amount / _rewardDuration);
        } else {
            uint256 remainingTime = pool.periodFinish - pool.lastRewardTimestamp;
            uint256 leftoverReward = remainingTime * pool.rewardRate;
            pool.rewardRate = to128((_amount + leftoverReward) / _rewardDuration);
        }

        pool.lastRewardTimestamp = uint40(block.timestamp);
        pool.periodFinish = uint40(block.timestamp + _rewardDuration);

        // Event is not emitted as Voter should have already emitted it
    }

    /// @notice Helper function to migrate fund from multiple pools to the new MasterBids.
    /// @notice user must initiate transaction from masterbids
    /// @dev Assume the original MasterBids has stopped emissions
    /// hence we skip IVoter(voter).distribute() to save gas cost
    function migrate(uint256[] calldata _pids) external override nonReentrant {
        require(address(newMasterBids) != (address(0)), "to where?");

        _multiClaim(_pids);
        for (uint256 i; i < _pids.length; ++i) {
            uint256 pid = _pids[i];
            UserInfo storage user = userInfo[pid][msg.sender];

            if (user.amount > 0) {
                PoolInfoV3 storage pool = poolInfoV3[pid];
                pool.lpToken.approve(address(newMasterBids), user.amount);
                uint256 newPid = newMasterBids.getAssetPid(address(pool.lpToken));
                newMasterBids.depositFor(newPid, user.amount, msg.sender);

                pool.sumOfFactors -= user.factor;
                // remove user
                delete userInfo[pid][msg.sender];
            }
        }
    }

    /// @notice Deposit LP tokens to masterbids for Bids allocation on behalf of user
    /// @dev user must initiate transaction from masterbids
    /// @param _pid the pool id
    /// @param _amount amount to deposit
    /// @param _user the user being represented
    function depositFor(uint256 _pid, uint256 _amount, address _user) external override nonReentrant whenNotPaused {
        PoolInfoV3 storage pool = poolInfoV3[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        // update pool in case user has deposited
        _updatePool(_pid);

        _updateUserAmount(_pid, _user, user.amount + _amount);

        pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit DepositFor(_user, _pid, _amount);
    }

    /// @notice Deposit LP tokens to masterbids for Bids allocation.
    /// @dev it is possible to call this function with _amount == 0 to claim current rewards
    /// @param _pid the pool id
    /// @param _amount amount to deposit
    function deposit(
        uint256 _pid,
        uint256 _amount
    ) external override nonReentrant whenNotPaused returns (uint256 reward, uint256[] memory additionalRewards) {
        PoolInfoV3 storage pool = poolInfoV3[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        // update pool in case user has deposited
        _updatePool(_pid);

        (reward, additionalRewards) = _updateUserAmount(_pid, msg.sender, user.amount + _amount);


        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    /// @notice claims rewards for multiple pids
    /// @param _pids array pids, pools to claim
    function multiClaim(
        uint256[] calldata _pids
    )
        external
        override
        nonReentrant
        whenNotPaused
        returns (uint256 reward, uint256[] memory amounts, uint256[][] memory additionalRewards)
    {
        return _multiClaim(_pids);
    }

    /// @notice private function to claim rewards for multiple pids
    /// @param _pids array pids, pools to claim
    function _multiClaim(
        uint256[] memory _pids
    ) private returns (uint256 reward, uint256[] memory amounts, uint256[][] memory additionalRewards) {
        // accumulate rewards for each one of the pids in pending
        amounts = new uint256[](_pids.length);
        additionalRewards = new uint256[][](_pids.length);
        for (uint256 i; i < _pids.length; ++i) {
            UserInfo storage user = userInfo[_pids[i]][msg.sender];
            _updatePool(_pids[i]);

            if (user.amount > 0) {
                PoolInfoV3 storage pool = poolInfoV3[_pids[i]];
                // increase pending to send all rewards once
                uint256 poolRewards = ((uint256(user.amount) *
                    pool.accBidsPerShare +
                    uint256(user.factor) *
                    pool.accBidsPerFactorShare) / ACC_TOKEN_PRECISION) +
                    user.pendingBids -
                    user.rewardDebt;

                user.pendingBids = 0;

                // update reward debt
                user.rewardDebt = to128(
                    (uint256(user.amount) * pool.accBidsPerShare + uint256(user.factor) * pool.accBidsPerFactorShare) /
                        ACC_TOKEN_PRECISION
                );

                // increase reward
                reward += poolRewards;

                amounts[i] = poolRewards;
                emit Harvest(msg.sender, _pids[i], amounts[i]);

                // if exist, update external rewarder
                IRewarder rewarder = pool.rewarder;
                if (address(rewarder) != address(0)) {
                    additionalRewards[i] = rewarder.onReward(msg.sender);
                }
            }
        }

        // safeTransfer all rewards
        Bids.safeTransfer(payable(msg.sender), reward);
    }

    /// @notice Withdraw LP tokens from MasterBids.
    /// @notice Automatically harvest pending rewards and sends to user
    /// @param _pid the pool id
    /// @param _amount the amount to withdraw
    function withdraw(
        uint256 _pid,
        uint256 _amount
    ) external override nonReentrant whenNotPaused returns (uint256 reward, uint256[] memory additionalRewards) {
        PoolInfoV3 storage pool = poolInfoV3[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not enough balance");

        _updatePool(_pid);

        (reward, additionalRewards) = _updateUserAmount(_pid, msg.sender, user.amount - _amount);

        pool.lpToken.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    /// @notice Update user balance and distribute Bids rewards
    function _updateUserAmount(
        uint256 _pid,
        address _user,
        uint256 _amount
    ) internal returns (uint256 reward, uint256[] memory additionalRewards) {
        PoolInfoV3 storage pool = poolInfoV3[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        // Harvest Bids
        if (user.amount > 0 || user.pendingBids > 0) {
            reward =
                ((uint256(user.amount) * pool.accBidsPerShare + uint256(user.factor) * pool.accBidsPerFactorShare) /
                    ACC_TOKEN_PRECISION) +
                user.pendingBids -
                user.rewardDebt;
            user.pendingBids = 0;

            Bids.safeTransfer(payable(_user), reward);
            emit Harvest(_user, _pid, reward);
        }

        // update amount of lp staked
        user.amount = to128(_amount);

        // update sumOfFactors
        uint128 oldFactor = user.factor;
        user.factor = to128(DSMath.sqrt(user.amount * veBids.balanceOf(_user), user.amount));

        // update reward debt
        user.rewardDebt = to128(
            (uint256(user.amount) * pool.accBidsPerShare + uint256(user.factor) * pool.accBidsPerFactorShare) / ACC_TOKEN_PRECISION
        );

        // claim reward before we update factors (Due to rewarder ratios being based on masters rewards)
        IRewarder rewarder = pool.rewarder;
        if (address(rewarder) != address(0)) {
            additionalRewards = rewarder.onReward(_user);
        }

        pool.sumOfFactors = to128(pool.sumOfFactors + user.factor - oldFactor);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param _pid the pool id
    function emergencyWithdraw(uint256 _pid) external override nonReentrant {
        PoolInfoV3 storage pool = poolInfoV3[_pid];

        UserInfo storage user = userInfo[_pid][msg.sender];

        pool.lpToken.safeTransfer(address(msg.sender), user.amount);

        pool.sumOfFactors = pool.sumOfFactors - user.factor;

        user.amount = 0;
        user.factor = 0;
        user.rewardDebt = 0;

        IRewarder rewarder = pool.rewarder;
        if (address(rewarder) != address(0)) {
            rewarder.onReward(msg.sender);
        }

        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
    }

    /// @notice updates emission partition
    /// @param _basePartition the future base partition
    function updateEmissionPartition(uint16 _basePartition) external onlyOwner {
        require(_basePartition <= 1000);
        massUpdatePools();
        basePartition = _basePartition;
        emit UpdateEmissionPartition(msg.sender, _basePartition, 1000 - _basePartition);
    }

    /// @notice updates veBids address
    /// @param _newVeBids the new VeBids address
    function setVeBids(IVeBids _newVeBids) external onlyOwner {
        require(address(_newVeBids) != address(0));
        IVeBids oldVeBids = veBids;
        veBids = _newVeBids;
        emit UpdateVeBids(msg.sender, address(oldVeBids), address(_newVeBids));
    }

    /// @notice updates voter address
    /// @param _newVoter the new Voter address
    function setVoter(address _newVoter, bool _voterIsCallable) external onlyOwner {
        // voter address can be zero during a migration. This is done to avoid
        // the scenario where both old and new MasterBids claims in migrate,
        // which calls voter.distribute. But only one can succeed as voter.distribute
        // is only callable from gauge manager.
        require(_newVoter != address(0), "Voter address cannot be zero");
        address oldVoter = voter;
        voter = _newVoter;
        voterIsCallable = _voterIsCallable;
        emit UpdateVoter(msg.sender, oldVoter, _newVoter, _voterIsCallable);
    }

    /// @notice updates factor after any veBids token operation (minting/burning)
    /// @param _user the user to update
    /// @param _newVeBidsBalance the amount of veBids
    /// @dev can only be called by veBids
    function updateFactor(address _user, uint256 _newVeBidsBalance) external override onlyVeBids {
        // loop over each pool : beware gas cost!
        uint256 length = poolInfoV3.length;

        for (uint256 pid = 0; pid < length; ++pid) {
            UserInfo storage user = userInfo[pid][_user];

            // skip if user doesn't have any deposit in the pool
            if (user.amount == 0) {
                continue;
            }

            // first, update pool
            _updatePool(pid);
            PoolInfoV3 storage pool = poolInfoV3[pid];

            // calculate pending
            uint256 pending = ((uint256(user.amount) * pool.accBidsPerShare + uint256(user.factor) * pool.accBidsPerFactorShare) /
                ACC_TOKEN_PRECISION) - user.rewardDebt;
            // increase pendingBids
            user.pendingBids += to128(pending);

            // update boosted partition factor
            uint256 oldFactor = user.factor;
            uint256 newFactor = DSMath.sqrt(user.amount * _newVeBidsBalance, user.amount);
            user.factor = to128(newFactor);
            // update reward debt, take into account newFactor
            user.rewardDebt = to128(
                (uint256(user.amount) * pool.accBidsPerShare + newFactor * pool.accBidsPerFactorShare) / ACC_TOKEN_PRECISION
            );
            // also, update sumOfFactors
            pool.sumOfFactors = to128(pool.sumOfFactors + newFactor - oldFactor);
        }
    }

    /// @notice In case we need to manually migrate Bids funds from masterbids
    /// Sends all remaining Bids from the contract to the owner
    function emergencyBidsWithdraw() external onlyOwner {

        Bids.safeTransfer(address(msg.sender), Bids.balanceOf(address(this)));
        emit EmergencyBidsWithdraw(address(msg.sender), Bids.balanceOf(address(this)));
    }

    function boostedPartition() external view returns (uint256) {
        return 1000 - basePartition;
    }

    /// @notice returns pool length
    function poolLength() external view override returns (uint256) {
        return poolInfoV3.length;
    }

    function getAssetPid(address asset) external view override returns (uint256) {
        // revert if asset not exist
        return assetPid[asset] - 1;
    }

    function lastTimeRewardApplicable(uint256 _periodFinish) public view returns (uint256) {
        return block.timestamp < _periodFinish ? block.timestamp : _periodFinish;
    }

    function calRewardPerUnit(uint256 _pid) public view returns (uint256 accBidsPerShare, uint256 accBidsPerFactorShare) {
        PoolInfoV3 storage pool = poolInfoV3[_pid];
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        accBidsPerShare = pool.accBidsPerShare;
        accBidsPerFactorShare = pool.accBidsPerFactorShare;

        if (lpSupply == 0 || block.timestamp <= pool.lastRewardTimestamp) {
            // update only if now > lastRewardTimestamp
            return (accBidsPerShare, accBidsPerFactorShare);
        }

        uint256 secondsElapsed = lastTimeRewardApplicable(pool.periodFinish) - pool.lastRewardTimestamp;
        uint256 BidsReward = secondsElapsed * pool.rewardRate;
        accBidsPerShare += (BidsReward * ACC_TOKEN_PRECISION * basePartition) / (lpSupply * 1000);

        if (pool.sumOfFactors != 0) {
            accBidsPerFactorShare += (BidsReward * ACC_TOKEN_PRECISION * (1000 - basePartition)) / (pool.sumOfFactors * 1000);
        }
    }

    /// @notice View function to see pending Bids on frontend.
    /// @param _pid the pool id
    /// @param _user the user address
    function pendingTokens(
        uint256 _pid,
        address _user
    ) external view override returns (uint256 pendingRewards, uint256[] memory pendingRewarderRewards) {
        PoolInfoV3 memory pool = poolInfoV3[_pid];

        // calculate accBidsPerShare and accBidsPerFactorShare
        (uint256 accBidsPerShare, uint256 accBidsPerFactorShare) = calRewardPerUnit(_pid);

        UserInfo memory user = userInfo[_pid][_user];
        pendingRewards =
            ((user.amount * accBidsPerShare + user.factor * accBidsPerFactorShare) / ACC_TOKEN_PRECISION) +
            user.pendingBids -
            user.rewardDebt;

        // Rewarder tokens
        if (address(pool.rewarder) != address(0)) {
            pendingRewarderRewards = pool.rewarder.pendingTokens(_user);
        }
    }

    //For accurate pending Bids use pendingTokens instead.
    /// @notice View function to see pending Bids with factor and base separated.
    /// @param _pid the pool id
    /// @param _user the user address
    function pendingTokensSplit(
        uint256 _pid,
        address _user
    ) external view returns (uint256 pendingBaseRewards, uint256 pendingFactorRewards, uint256[] memory pendingRewarderRewards) {
        PoolInfoV3 memory pool = poolInfoV3[_pid];

        // calculate accBidsPerShare and accBidsPerFactorShare
        (uint256 accBidsPerShare, uint256 accBidsPerFactorShare) = calRewardPerUnit(_pid);

        UserInfo memory user = userInfo[_pid][_user];
        // Rewarder tokens
        if (address(pool.rewarder) != address(0)) {
            pendingRewarderRewards = pool.rewarder.pendingTokens(_user);
        }
        if (user.amount == 0) {
            return (0, 0, pendingRewarderRewards);
        }

        ////Working
        uint256 pendingBaseRewardsHigh = user.amount * accBidsPerShare;
        uint256 pendingFactorRewardsHigh = user.factor * accBidsPerFactorShare;
        uint256 pendingRewards = ((pendingBaseRewardsHigh + pendingFactorRewardsHigh) / ACC_TOKEN_PRECISION) +
            user.pendingBids -
            user.rewardDebt;

        pendingFactorRewards = (pendingRewards * pendingFactorRewardsHigh / (pendingBaseRewardsHigh + pendingFactorRewardsHigh));
        pendingBaseRewards = pendingRewards - pendingFactorRewards;
    }

    function to128(uint256 val) internal pure returns (uint128) {
        if (val > type(uint128).max) revert("uint128 overflow");
        return uint128(val);
    }

    function to104(uint256 val) internal pure returns (uint104) {
        if (val > type(uint104).max) revert("uint104 overflow");
        return uint104(val);
    }

    /// @notice Update the given pool's rewarder
    /// @param _pid the pool id
    /// @param _rewarder the rewarder
    function setRewarder(uint256 _pid, IRewarder _rewarder) external onlyOwner {
        require(Address.isContract(address(_rewarder)) || address(_rewarder) == address(0), "set: rewarder must be contract or zero");

        PoolInfoV3 storage pool = poolInfoV3[_pid];

        pool.rewarder = _rewarder;
        emit SetRewarder(_pid, _rewarder);
    }
}