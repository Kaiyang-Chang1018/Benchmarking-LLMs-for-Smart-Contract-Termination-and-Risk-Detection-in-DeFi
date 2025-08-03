// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "src/interfaces/IWETH.sol";
import "src/interfaces/IPriceFeedAggregator.sol";
import "src/interfaces/IReserveHolderV2.sol";
import "src/interfaces/IArbitrageERC20.sol";
import "src/library/ExternalContractAddresses.sol";
import "src/library/uniswap/UniswapV2Library.sol";
import "src/interfaces/IArbitrageV5.sol";

/// @title Contract for performing arbitrage
/// @notice This contract is responsible for buying USC tokens and for keeping price of USC token pegged to target price
/// @dev This contract represent second version of arbitrage contract, arbitrage is now private and all profit from arbitrage is kept in this contract
contract ArbitrageV5 is IArbitrageV5, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using SafeERC20 for IArbitrageERC20;

    uint256 public constant BASE_PRICE = 1e8;
    uint256 public constant USC_TARGET_PRICE = 1e8;
    uint256 public constant POOL_FEE = 30;
    uint256 public constant MAX_FEE = 100_00;

    // F = (1 - pool_fee) on 18 decimals
    uint256 public constant F = ((MAX_FEE - POOL_FEE) * 1e18) / MAX_FEE;
    uint16 public constant MAX_PRICE_TOLERANCE = 100_00;
    address public constant WETH = ExternalContractAddresses.WETH;
    address public constant STETH = ExternalContractAddresses.stETH;
    IUniswapV2Router02 public constant swapRouter = IUniswapV2Router02(ExternalContractAddresses.UNI_V2_SWAP_ROUTER);
    IUniswapV2Factory public constant poolFactory = IUniswapV2Factory(ExternalContractAddresses.UNI_V2_POOL_FACTORY);

    IArbitrageERC20 public immutable USC;
    IArbitrageERC20 public immutable CHI;
    IPriceFeedAggregator public immutable priceFeedAggregator;
    IReserveHolderV2 public reserveHolder;

    uint256 public pegPriceToleranceAbs;
    uint256 public mintBurnFee;
    uint256 public maxMintBurnPriceDiff;
    uint16 public maxMintBurnReserveTolerance;
    uint16 public chiPriceTolerance;
    uint16 public priceTolerance;

    bool public mintPaused;
    bool public burnPaused;

    uint256 public totalMintedUsc; // total amount of minted USC tokens during arbitrage when stablecoin is pegged

    mapping(address => bool) public isArbitrager;
    mapping(address => bool) public isPrivileged;
    mapping(address => uint256) public reserveMintTxLimit;
    mapping(address => uint256) public reserveBurnTxLimit;

    modifier onlyArbitrager() {
        if (!isArbitrager[msg.sender]) {
            revert NotArbitrager(msg.sender);
        }

        _;
    }

    modifier whenMintNotPaused() {
        if (mintPaused) {
            revert ContractIsPaused();
        }

        _;
    }

    modifier whenBurnNotPaused() {
        if (burnPaused) {
            revert ContractIsPaused();
        }

        _;
    }

    modifier onlyWhenMintableOrBurnable() {
        uint256 ethPrice = priceFeedAggregator.peek(WETH);

        uint256 uscSpotPrice = _calculateUscSpotPrice(ethPrice);
        if (!_almostEqualAbs(uscSpotPrice, USC_TARGET_PRICE, maxMintBurnPriceDiff)) {
            revert PriceIsNotPegged();
        }

        (, uint256 reserveDiff, uint256 reserveValue) = _getReservesData();
        if (reserveDiff > Math.mulDiv(reserveValue, maxMintBurnReserveTolerance, MAX_PRICE_TOLERANCE)) {
            revert ReserveDiffTooBig();
        }

        _;
    }

    modifier onlyBellowMintLimit(address reserveAsset, uint256 amount) {
        if (reserveMintTxLimit[reserveAsset] < amount) {
            revert ReserveTxLimitExceeded();
        }

        _;
    }

    modifier onlyBellowBurnLimit(address reserveAsset, uint256 amount) {
        if (reserveBurnTxLimit[reserveAsset] < amount) {
            revert ReserveTxLimitExceeded();
        }

        _;
    }

    constructor(
        IArbitrageERC20 _USC,
        IArbitrageERC20 _CHI,
        IPriceFeedAggregator _priceFeedAggregator,
        IReserveHolderV2 _reserveHolder
    ) Ownable() {
        USC = _USC;
        CHI = _CHI;
        priceFeedAggregator = _priceFeedAggregator;
        reserveHolder = _reserveHolder;
        mintPaused = false;
        burnPaused = false;

        IERC20(STETH).approve(address(reserveHolder), type(uint256).max);
    }

    /// @inheritdoc IArbitrageV5
    function setReserveHolder(address _reserveHolder) external onlyOwner {
        reserveHolder = IReserveHolderV2(_reserveHolder);
    }

    /// @inheritdoc IArbitrageV5
    function setPegPriceToleranceAbs(uint256 _priceTolerance) external override onlyOwner {
        pegPriceToleranceAbs = _priceTolerance;
    }

    /// @inheritdoc IArbitrageV5
    function setMintPause(bool isPaused) external onlyOwner {
        mintPaused = isPaused;
    }

    /// @inheritdoc IArbitrageV5
    function setBurnPause(bool isPaused) external onlyOwner {
        burnPaused = isPaused;
    }

    /// @inheritdoc IArbitrageV5
    function setPriceTolerance(uint16 _priceTolerance) external onlyOwner {
        if (_priceTolerance > MAX_PRICE_TOLERANCE) {
            revert ToleranceTooBig(_priceTolerance);
        }
        priceTolerance = _priceTolerance;
        emit SetPriceTolerance(_priceTolerance);
    }

    /// @inheritdoc IArbitrageV5
    function setChiPriceTolerance(uint16 _chiPriceTolerance) external onlyOwner {
        if (_chiPriceTolerance > MAX_PRICE_TOLERANCE) {
            revert ToleranceTooBig(_chiPriceTolerance);
        }
        chiPriceTolerance = _chiPriceTolerance;
        emit SetChiPriceTolerance(_chiPriceTolerance);
    }

    /// @inheritdoc IArbitrageV5
    function setMaxMintBurnPriceDiff(uint256 _maxMintBurnPriceDiff) external onlyOwner {
        maxMintBurnPriceDiff = _maxMintBurnPriceDiff;
        emit SetMaxMintBurnPriceDiff(_maxMintBurnPriceDiff);
    }

    /// @inheritdoc IArbitrageV5
    function setMaxMintBurnReserveTolerance(uint16 _maxMintBurnReserveTolerance) external onlyOwner {
        if (_maxMintBurnReserveTolerance > MAX_PRICE_TOLERANCE) {
            revert ToleranceTooBig(_maxMintBurnReserveTolerance);
        }
        maxMintBurnReserveTolerance = _maxMintBurnReserveTolerance;
        emit SetMaxMintBurnReserveTolerance(_maxMintBurnReserveTolerance);
    }

    /// @inheritdoc IArbitrageV5
    function setMintBurnFee(uint16 _mintBurnFee) external onlyOwner {
        if (_mintBurnFee > MAX_FEE) {
            revert FeeTooBig(_mintBurnFee);
        }

        mintBurnFee = _mintBurnFee;
        emit SetMintBurnFee(_mintBurnFee);
    }

    /// @inheritdoc IArbitrageV5
    function setReserveMintTxLimit(address reserveAsset, uint256 limit) external onlyOwner {
        reserveMintTxLimit[reserveAsset] = limit;
        emit SetReserveMintTxLimit(reserveAsset, limit);
    }

    /// @inheritdoc IArbitrageV5
    function setReserveBurnTxLimit(address reserveAsset, uint256 limit) external onlyOwner {
        reserveBurnTxLimit[reserveAsset] = limit;
        emit SetReserveBurnTxLimit(reserveAsset, limit);
    }

    /// @inheritdoc IArbitrageV5
    function updateArbitrager(address arbitrager, bool status) external onlyOwner {
        isArbitrager[arbitrager] = status;
        emit UpdateArbitrager(arbitrager, status);
    }

    /// @inheritdoc IArbitrageV5
    function updatePrivileged(address account, bool status) external onlyOwner {
        isPrivileged[account] = status;
        emit UpdatePrivileged(account, status);
    }

    /// @inheritdoc IArbitrageV5
    function claimRewards(IERC20[] memory tokens, uint256[] memory amounts) external onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = tokens[i];
            uint256 amount = amounts[i];

            token.safeTransfer(msg.sender, amount);

            if (address(token) == address(USC)) {
                if (amount < totalMintedUsc) {
                    totalMintedUsc -= amount;
                } else {
                    totalMintedUsc = 0;
                }
            }
        }
    }

    function rewardUSC(uint256 amount) external onlyOwner {
        USC.safeTransferFrom(msg.sender, address(this), amount);
        totalMintedUsc += amount;

        emit RewardUSC(amount);
    }

    /// @inheritdoc IArbitrageV5
    function mint(address token, uint256 amount, address receiver)
        external
        whenMintNotPaused
        nonReentrant
        onlyWhenMintableOrBurnable
        onlyBellowMintLimit(token, amount)
        returns (uint256)
    {
        uint256 fee = Math.mulDiv(amount, mintBurnFee, MAX_FEE);
        uint256 amountAfterFee = amount - fee;

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(address(reserveHolder), amountAfterFee);
        reserveHolder.deposit(token, amountAfterFee);

        return _mint(amountAfterFee, token, receiver);
    }

    /// @inheritdoc IArbitrageV5
    function mint(address receiver)
        external
        payable
        whenMintNotPaused
        nonReentrant
        onlyWhenMintableOrBurnable
        onlyBellowMintLimit(address(WETH), msg.value)
        returns (uint256)
    {
        uint256 ethAmount = msg.value;
        uint256 fee = Math.mulDiv(ethAmount, mintBurnFee, MAX_FEE);
        uint256 ethAmountAfterFee = ethAmount - fee;

        IWETH(WETH).deposit{value: ethAmount}();
        IERC20(WETH).safeTransfer(address(reserveHolder), ethAmountAfterFee);
        return _mint(ethAmountAfterFee, WETH, receiver);
    }

    /// @inheritdoc IArbitrageV5
    function burn(uint256 amount, address reserveToReceive)
        external
        whenBurnNotPaused
        nonReentrant
        onlyWhenMintableOrBurnable
        onlyBellowBurnLimit(reserveToReceive, amount)
        returns (uint256)
    {
        uint256 reservePrice = priceFeedAggregator.peek(reserveToReceive);

        USC.safeTransferFrom(msg.sender, address(this), amount);
        amount -= (amount * mintBurnFee) / MAX_FEE;
        USC.burn(amount);

        uint256 reserveAmountToRedeem = Math.mulDiv(amount, USC_TARGET_PRICE, reservePrice);

        reserveHolder.redeem(reserveAmountToRedeem, reserveToReceive);
        IERC20(reserveToReceive).safeTransfer(msg.sender, reserveAmountToRedeem);

        emit Burn(msg.sender, amount, reserveAmountToRedeem, reserveToReceive);
        return reserveAmountToRedeem;
    }

    /// @inheritdoc IArbitrageV5
    function executeArbitrageWithReserveSell(uint256 maxChiSpotPrice, SwapParams[] calldata swapParams)
        external
        returns (uint256)
    {
        for (uint256 i = 0; i < swapParams.length; i++) {
            reserveHolder.swapReserveForEth(
                swapParams[i].reserveAsset, swapParams[i].amountIn, swapParams[i].minAmountOut
            );
        }

        return executeArbitrage(maxChiSpotPrice);
    }

    /// @inheritdoc IArbitrageV5
    function executeArbitrage(uint256 maxChiSpotPrice) public override nonReentrant onlyArbitrager returns (uint256) {
        _validateArbitrage(maxChiSpotPrice);
        return _executeArbitrage();
    }

    /// @inheritdoc IArbitrageV5
    function getArbitrageData()
        public
        view
        returns (bool isPriceAtPeg, bool isPriceAboveTarget, bool isExcessOfReserves, uint256 reserveDiff)
    {
        uint256 ethPrice = priceFeedAggregator.peek(WETH);
        uint256 uscPrice = _getAndValidateUscPrice(ethPrice);

        uint256 reserveValue;
        (isExcessOfReserves, reserveDiff, reserveValue) = _getReservesData();
        isPriceAboveTarget = uscPrice >= USC_TARGET_PRICE;

        return (
            _almostEqualAbs(uscPrice, USC_TARGET_PRICE, pegPriceToleranceAbs),
            isPriceAboveTarget,
            isExcessOfReserves,
            reserveDiff
        );
    }

    function _executeArbitrage() internal returns (uint256) {
        (bool isPriceAtPeg, bool isPriceAboveTarget, bool isExcessOfReserves, uint256 reserveDiff) = getArbitrageData();

        uint256 ethPrice = priceFeedAggregator.peek(WETH);

        if (isPriceAtPeg) {
            if (isExcessOfReserves) {
                return _arbitrageAtPegExcessOfReserves(reserveDiff, ethPrice);
            } else {
                return _arbitrageAtPegDeficitOfReserves(reserveDiff, ethPrice);
            }
        } else if (isPriceAboveTarget) {
            if (isExcessOfReserves) {
                return _arbitrageAbovePegExcessOfReserves(reserveDiff, ethPrice);
            } else {
                return _arbitrageAbovePegDeficitOfReserves(reserveDiff, ethPrice);
            }
        } else {
            if (isExcessOfReserves) {
                return _arbitrageBellowPegExcessOfReserves(reserveDiff, ethPrice);
            } else {
                return _arbitrageBellowPegDeficitOfReserves(reserveDiff, ethPrice);
            }
        }
    }

    function _mint(uint256 amount, address token, address receiver) private returns (uint256) {
        uint256 usdValue;
        if (token == WETH) {
            uint256 ethPrice = priceFeedAggregator.peek(WETH);
            usdValue = _convertTokenAmountToUsdValue(amount, ethPrice);
        } else {
            uint256 tokenPrice = priceFeedAggregator.peek(token);
            usdValue = _convertTokenAmountToUsdValue(amount, tokenPrice);
        }

        uint256 uscAmountToMint = _convertUsdValueToTokenAmount(usdValue, USC_TARGET_PRICE);
        USC.mint(receiver, uscAmountToMint);
        emit Mint(msg.sender, token, amount, uscAmountToMint);
        return uscAmountToMint;
    }

    function _arbitrageAbovePegExcessOfReserves(uint256 reserveDiff, uint256 ethPrice) private returns (uint256) {
        uint256 deltaUSC = _calculateDeltaUSC(ethPrice);

        USC.mint(address(this), deltaUSC);
        uint256 ethAmountReceived = _swap(address(USC), WETH, deltaUSC);

        uint256 deltaUsd = _convertTokenAmountToUsdValue(deltaUSC, USC_TARGET_PRICE);
        uint256 deltaInETH = _convertUsdValueToTokenAmount(deltaUsd, ethPrice);

        if (deltaInETH > ethAmountReceived) {
            revert DeltaBiggerThanAmountReceivedETH(deltaInETH, ethAmountReceived);
        }

        uint256 ethAmountToSwap;
        uint256 ethAmountForReserves;

        if (deltaUsd > reserveDiff) {
            ethAmountToSwap = _convertUsdValueToTokenAmount(reserveDiff, ethPrice);
            ethAmountForReserves = _convertUsdValueToTokenAmount(deltaUsd, ethPrice) - ethAmountToSwap;
            IERC20(WETH).safeTransfer(address(reserveHolder), ethAmountForReserves);
        } else {
            ethAmountToSwap = _convertUsdValueToTokenAmount(deltaUsd, ethPrice);
        }

        uint256 chiAmountReceived = _swap(WETH, address(CHI), ethAmountToSwap);
        CHI.burn(chiAmountReceived);

        uint256 rewardAmount = ethAmountReceived - ethAmountToSwap - ethAmountForReserves;

        uint256 rewardValue = _convertTokenAmountToUsdValue(rewardAmount, ethPrice);
        emit ExecuteArbitrage(msg.sender, 1, deltaUsd, reserveDiff, ethPrice, rewardValue);
        return rewardValue;
    }

    function _arbitrageAbovePegDeficitOfReserves(uint256 reserveDiff, uint256 ethPrice) private returns (uint256) {
        uint256 deltaUSC = _calculateDeltaUSC(ethPrice);

        USC.mint(address(this), deltaUSC);
        uint256 ethAmountReceived = _swap(address(USC), WETH, deltaUSC);

        uint256 deltaUsd = _convertTokenAmountToUsdValue(deltaUSC, USC_TARGET_PRICE);
        uint256 deltaInETH = _convertUsdValueToTokenAmount(deltaUsd, ethPrice);

        if (deltaInETH > ethAmountReceived) {
            revert DeltaBiggerThanAmountReceivedETH(deltaInETH, ethAmountReceived);
        }

        IERC20(WETH).safeTransfer(address(reserveHolder), deltaInETH);

        uint256 rewardAmount = ethAmountReceived - deltaInETH;

        uint256 rewardValue = _convertTokenAmountToUsdValue(rewardAmount, ethPrice);
        emit ExecuteArbitrage(msg.sender, 2, deltaUsd, reserveDiff, ethPrice, rewardValue);
        return rewardValue;
    }

    function _arbitrageBellowPegExcessOfReserves(uint256 reserveDiff, uint256 ethPrice) private returns (uint256) {
        uint256 uscAmountToFreeze;
        uint256 uscAmountToBurn;

        uint256 deltaETH = _calculateDeltaETH(ethPrice);
        uint256 deltaUsd = _convertTokenAmountToUsdValue(deltaETH, ethPrice);

        if (deltaUsd > reserveDiff) {
            uscAmountToFreeze = _convertUsdValueToTokenAmount(reserveDiff, USC_TARGET_PRICE);
            uscAmountToBurn = _convertUsdValueToTokenAmount(deltaUsd - reserveDiff, USC_TARGET_PRICE);
        } else {
            uscAmountToFreeze = _convertUsdValueToTokenAmount(deltaUsd, USC_TARGET_PRICE);
        }

        reserveHolder.redeem(deltaETH, address(WETH));
        uint256 uscAmountReceived = _swap(WETH, address(USC), deltaETH);

        if (uscAmountReceived < uscAmountToFreeze) {
            uscAmountToFreeze = uscAmountReceived;
        }

        if (uscAmountToBurn > 0) {
            USC.burn(uscAmountToBurn);
        }

        uint256 rewardAmount = uscAmountReceived - uscAmountToFreeze - uscAmountToBurn;
        uint256 rewardValue = _convertTokenAmountToUsdValue(rewardAmount, USC_TARGET_PRICE);
        emit ExecuteArbitrage(msg.sender, 3, deltaUsd, reserveDiff, ethPrice, rewardValue);
        return rewardValue;
    }

    function _arbitrageBellowPegDeficitOfReserves(uint256 reserveDiff, uint256 ethPrice) private returns (uint256) {
        uint256 ethAmountToRedeem;
        uint256 ethAmountFromChi;

        uint256 deltaETH = _calculateDeltaETH(ethPrice);
        uint256 deltaUsd = _convertTokenAmountToUsdValue(deltaETH, ethPrice);

        if (deltaUsd > reserveDiff) {
            ethAmountFromChi = _convertUsdValueToTokenAmount(reserveDiff, ethPrice);
            ethAmountToRedeem = deltaETH - ethAmountFromChi;
            reserveHolder.redeem(ethAmountToRedeem, address(WETH));
        } else {
            ethAmountFromChi = deltaETH;
        }

        uint256 uscAmountToBurn = _convertUsdValueToTokenAmount(deltaUsd, USC_TARGET_PRICE);

        uint256 uscAmountReceived;
        {
            if (ethAmountFromChi > 0) {
                uint256 chiAmountToMint = _getAmountInForAmountOut(address(CHI), WETH, ethAmountFromChi);
                CHI.mint(address(this), chiAmountToMint);
                _swap(address(CHI), WETH, chiAmountToMint);
            }

            uscAmountReceived = _swap(WETH, address(USC), ethAmountFromChi + ethAmountToRedeem);
        }

        if (uscAmountToBurn > 0) {
            USC.burn(uscAmountToBurn);
        }

        {
            uint256 rewardAmount = uscAmountReceived - uscAmountToBurn;
            uint256 rewardValue = _convertTokenAmountToUsdValue(rewardAmount, USC_TARGET_PRICE);
            emit ExecuteArbitrage(msg.sender, 4, deltaUsd, reserveDiff, ethPrice, rewardValue);
            return rewardValue;
        }
    }

    function _arbitrageAtPegExcessOfReserves(uint256 reserveDiff, uint256 ethPrice) private returns (uint256) {
        uint256 uscAmountToMint = _convertUsdValueToTokenAmount(reserveDiff, USC_TARGET_PRICE);

        USC.mint(address(this), uscAmountToMint);
        totalMintedUsc += uscAmountToMint;

        emit ExecuteArbitrage(msg.sender, 5, 0, reserveDiff, ethPrice, 0);
        return 0;
    }

    function _arbitrageAtPegDeficitOfReserves(uint256 reserveDiff, uint256 ethPrice) private returns (uint256) {
        uint256 reserveDiffInUsc = _convertUsdValueToTokenAmount(reserveDiff, USC_TARGET_PRICE);

        uint256 uscAmountToBurn;
        uint256 ethToGet;
        if (reserveDiffInUsc > totalMintedUsc) {
            uscAmountToBurn = totalMintedUsc;

            uint256 ethToGetInUsd = _convertTokenAmountToUsdValue(reserveDiffInUsc - totalMintedUsc, USC_TARGET_PRICE);
            ethToGet = _convertUsdValueToTokenAmount(ethToGetInUsd, ethPrice);
        } else {
            uscAmountToBurn = reserveDiffInUsc;
            ethToGet = 0;
        }

        uint256 chiToCoverEth;
        if (ethToGet > 0) {
            chiToCoverEth = _getAmountInForAmountOut(address(CHI), WETH, ethToGet);
        }

        CHI.mint(address(this), chiToCoverEth);

        if (ethToGet > 0) {
            uint256 ethReceived = _swap(address(CHI), WETH, chiToCoverEth);
            IERC20(WETH).safeTransfer(address(reserveHolder), ethReceived);
        }

        if (uscAmountToBurn > 0) {
            USC.burn(uscAmountToBurn);
            totalMintedUsc -= uscAmountToBurn;
        }

        emit ExecuteArbitrage(msg.sender, 6, 0, reserveDiff, ethPrice, 0);
        return 0;
    }

    function _getReservesData()
        public
        view
        returns (bool isExcessOfReserves, uint256 reserveDiff, uint256 reserveValue)
    {
        reserveValue = reserveHolder.getReserveValue();
        uint256 uscTotalSupplyValue = _convertTokenAmountToUsdValue(USC.totalSupply(), USC_TARGET_PRICE);

        if (reserveValue > uscTotalSupplyValue) {
            isExcessOfReserves = true;
            reserveDiff = (reserveValue - uscTotalSupplyValue);
        } else {
            isExcessOfReserves = false;
            reserveDiff = (uscTotalSupplyValue - reserveValue);
        }
    }

    function _getAndValidateUscPrice(uint256 ethPrice) private view returns (uint256) {
        uint256 uscPrice = priceFeedAggregator.peek(address(USC));
        uint256 uscSpotPrice = _calculateUscSpotPrice(ethPrice);
        uint256 priceDiff = _absDiff(uscSpotPrice, uscPrice);
        uint256 maxPriceDiff = Math.mulDiv(uscPrice, priceTolerance, MAX_PRICE_TOLERANCE);

        if (priceDiff > maxPriceDiff) {
            revert PriceSlippageTooBig();
        }

        return uscSpotPrice;
    }

    function _validateArbitrage(uint256 maxChiSpotPrice) private view {
        if (!isPrivileged[msg.sender]) {
            uint256 ethPrice = priceFeedAggregator.peek(WETH);
            uint256 chiSpotPrice = _calculateChiSpotPrice(ethPrice);

            if (maxChiSpotPrice != 0 && chiSpotPrice > maxChiSpotPrice) {
                revert ChiSpotPriceTooBig();
            }

            // If max chi spot price is not specified we need to check for twap difference
            if (maxChiSpotPrice == 0) {
                uint256 chiOraclePrice = priceFeedAggregator.peek(address(CHI));

                if (!_almostEqualRel(chiSpotPrice, chiOraclePrice, chiPriceTolerance)) {
                    revert ChiPriceNotPegged(chiSpotPrice, chiOraclePrice);
                }
            }
        }
    }

    // input ethPrice has 8 decimals
    // returns result with 8 decimals
    function _calculateUscSpotPrice(uint256 ethPrice) private view returns (uint256) {
        (uint256 reserveUSC, uint256 reserveWETH) =
            UniswapV2Library.getReserves(address(poolFactory), address(USC), address(WETH));
        uint256 uscFor1ETH = UniswapV2Library.quote(1 ether, reserveWETH, reserveUSC);
        return Math.mulDiv(ethPrice, 1 ether, uscFor1ETH);
    }

    // input ethPrice has 8 decimals
    // returns result with 8 decimals
    function _calculateChiSpotPrice(uint256 ethPrice) private view returns (uint256) {
        (uint256 reserveCHI, uint256 reserveWETH) =
            UniswapV2Library.getReserves(address(poolFactory), address(CHI), address(WETH));
        uint256 chiFor1ETH = UniswapV2Library.quote(1 ether, reserveWETH, reserveCHI);
        return Math.mulDiv(ethPrice, 1 ether, chiFor1ETH);
    }

    // what amount of In tokens to put in pool to make price:   1 tokenOut = (priceOut / priceIn) tokenIn
    // assuming reserves are on 18 decimals, prices are on 8 decimals
    function _calculateDelta(uint256 reserveIn, uint256 priceIn, uint256 reserveOut, uint256 priceOut)
        public
        pure
        returns (uint256)
    {
        // F = (1 - pool_fee) = 0.997 on 18 decimals,   in square root formula  a = F

        // parameter `b` in square root formula,  b = rIn * (1+f) ,  on 18 decimals
        uint256 b = Math.mulDiv(reserveIn, 1e18 + F, 1e18);
        uint256 b_sqr = Math.mulDiv(b, b, 1e18);

        // parameter `c` in square root formula,  c = rIn^2 - (rIn * rOut * priceOut) / priceIn
        uint256 c_1 = Math.mulDiv(reserveIn, reserveIn, 1e18);
        uint256 c_2 = Math.mulDiv(Math.mulDiv(reserveIn, reserveOut, 1e18), priceOut, priceIn);

        uint256 c;
        uint256 root;
        if (c_1 > c_2) {
            c = c_1 - c_2;
            // d = 4ac
            uint256 d = Math.mulDiv(4 * F, c, 1e18);

            // root = sqrt(b^2 - 4ac)
            // multiplying by 10^9 to get back to 18 decimals
            root = Math.sqrt(b_sqr - d) * 1e9;
        } else {
            c = c_2 - c_1;
            // d = 4ac
            uint256 d = Math.mulDiv(4 * F, c, 1e18);

            // root = sqrt(b^2 - 4ac)    -> in this case `c` is negative, so we add `d` to `b^2`
            // multiplying by 10^9 to get back to 18 decimals
            root = Math.sqrt(b_sqr + d) * 1e9;
        }
        // delta = (-b + root) / 2*f
        uint256 delta = Math.mulDiv(1e18, root - b, 2 * F);

        return delta;
    }

    // given ethPrice is on 8 decimals
    // how many USC to put in pool to make price:   1 ETH = ethPrice * USC
    function _calculateDeltaUSC(uint256 ethPrice) public view returns (uint256) {
        (uint256 reserveUSC, uint256 reserveWETH) =
            UniswapV2Library.getReserves(address(poolFactory), address(USC), address(WETH));
        return _calculateDelta(reserveUSC, USC_TARGET_PRICE, reserveWETH, ethPrice);
    }

    // how many ETH to put in pool to make price:   1 ETH = ethPrice * USC
    function _calculateDeltaETH(uint256 ethPrice) public view returns (uint256) {
        (uint256 reserveUSC, uint256 reserveWETH) =
            UniswapV2Library.getReserves(address(poolFactory), address(USC), address(WETH));
        return _calculateDelta(reserveWETH, ethPrice, reserveUSC, USC_TARGET_PRICE);
    }

    function _makePath(address t1, address t2) internal pure returns (address[] memory path) {
        path = new address[](2);
        path[0] = t1;
        path[1] = t2;
    }

    function _makePath(address t1, address t2, address t3) internal pure returns (address[] memory path) {
        path = new address[](3);
        path[0] = t1;
        path[1] = t2;
        path[2] = t3;
    }

    function _swap(address tokenIn, address tokenOut, uint256 amount) private returns (uint256) {
        address[] memory path;

        if (tokenIn != WETH && tokenOut != WETH) {
            path = _makePath(tokenIn, WETH, tokenOut);
        } else {
            path = _makePath(tokenIn, tokenOut);
        }

        IERC20(tokenIn).approve(address(swapRouter), amount);
        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp);

        uint256 amountReceived = amounts[path.length - 1];

        return amountReceived;
    }

    function _getAmountInForAmountOut(address tIn, address tOut, uint256 amountOut) internal view returns (uint256) {
        (uint256 rIn, uint256 rOut) = UniswapV2Library.getReserves(address(poolFactory), tIn, tOut);
        return UniswapV2Library.getAmountIn(amountOut, rIn, rOut);
    }

    function _convertUsdValueToTokenAmount(uint256 usdValue, uint256 price) internal pure returns (uint256) {
        return Math.mulDiv(usdValue, 1e18, price);
    }

    function _convertTokenAmountToUsdValue(uint256 amount, uint256 price) internal pure returns (uint256) {
        return Math.mulDiv(amount, price, 1e18);
    }

    function _absDiff(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a > b) ? a - b : b - a;
    }

    function _almostEqualAbs(uint256 price1, uint256 price2, uint256 delta) internal pure returns (bool) {
        return _absDiff(price1, price2) <= delta;
    }

    function _almostEqualRel(uint256 price1, uint256 price2, uint256 delta) internal pure returns (bool) {
        (uint256 highPrice, uint256 lowPrice) = price1 > price2 ? (price1, price2) : (price2, price1);
        uint256 priceDiff = highPrice - lowPrice;
        uint256 maxPriceDiff = Math.mulDiv(highPrice, delta, MAX_PRICE_TOLERANCE);

        return priceDiff <= maxPriceDiff;
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IArbitrageERC20 is IERC20 {
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IArbitrageV5 {
    struct SwapParams {
        address reserveAsset;
        uint256 amountIn;
        uint256 minAmountOut;
    }

    error DeltaBiggerThanAmountReceivedETH(uint256 deltaETH, uint256 receivedETH);
    error ToleranceTooBig(uint16 _tolerance);
    error PriceSlippageTooBig();
    error NotArbitrager(address account);
    error PriceIsNotPegged();
    error ReserveDiffTooBig();
    error ChiPriceNotPegged(uint256 spotPrice, uint256 twapPrice);
    error FeeTooBig(uint256 fee);
    error ChiSpotPriceTooBig();
    error ContractIsPaused();
    error ReserveTxLimitExceeded();

    event SetPriceTolerance(uint16 priceTolerance);
    event Mint(address indexed account, address token, uint256 amount, uint256 uscAmount);
    event ExecuteArbitrage(
        address indexed account,
        uint256 indexed arbNum,
        uint256 deltaUsd,
        uint256 reserveDiff,
        uint256 ethPrice,
        uint256 rewardValue
    );
    event UpdateArbitrager(address indexed account, bool status);
    event SetMaxMintBurnPriceDiff(uint256 maxMintBurnPriceDiff);
    event SetChiPriceTolerance(uint16 chiPriceTolerance);
    event SetMaxMintBurnReserveTolerance(uint16 maxBurnReserveTolerance);
    event SetMintBurnFee(uint256 mintFee);
    event UpdatePrivileged(address indexed privileged, bool isPrivileged);
    event Burn(address account, uint256 amount, uint256 reserveReceived, address reserve);
    event RewardUSC(uint256 amount);
    event SetReserveMintTxLimit(address reserveAsset, uint256 limit);
    event SetReserveBurnTxLimit(address reserveAsset, uint256 limit);

    /// @notice Sets reserve holder
    /// @param _reserveHolder Address of reserve holder
    /// @custom:usage This function should be called from owner in purpose of setting reserve holder
    function setReserveHolder(address _reserveHolder) external;

    /// @notice Sets absolute peg price tolerance
    /// @param _priceTolerance Absolute value of price tolerance
    /// @custom:usage This function should be called from owner in purpose of setting price tolerance
    function setPegPriceToleranceAbs(uint256 _priceTolerance) external;

    /// @notice Sets spot price tolerance from TWAP price
    /// @dev 100% = 10000
    /// @param _priceTolerance Price tolerance in percents
    /// @custom:usage This function should be called from owner in purpose of setting price tolerance
    function setPriceTolerance(uint16 _priceTolerance) external;

    /// @notice Sets reserve tx limit for minting
    /// @param reserveAsset Address of reserve asset
    /// @param limit Limit of reserve tx
    function setReserveMintTxLimit(address reserveAsset, uint256 limit) external;

    /// @notice Sets reserve tx limit for burn
    /// @param reserveAsset Address of reserve asset
    /// @param limit Limit of reserve tx
    function setReserveBurnTxLimit(address reserveAsset, uint256 limit) external;

    /// @notice Mint USC tokens for ETH
    /// @dev If USC price is different from target price for less then max mint price diff, then minting is allowed without performing arbitrage
    /// @param receiver Receiver of USC tokens
    /// @return uscAmount Amount of USC tokens minted
    function mint(address receiver) external payable returns (uint256 uscAmount);

    /// @notice Mint USC tokens for WETH
    /// @param token Address of a token that will be used to mint USC
    /// @param amount Amount of token to use for minting
    /// @param receiver Receiver of USC tokens
    /// @return uscAmount Amount of USC tokens minted
    function mint(address token, uint256 amount, address receiver) external returns (uint256 uscAmount);

    /// @notice Executes arbitrage with reserve rebalance
    /// @param chiSpotPrice CHI spot price
    /// @param swapParams Array of swap params for reserve holder in order to perform safe reserve sell and get ETH
    /// @return amountOut Amount out
    /// @dev This function should execute arbitrage with reserve rebalance when there is not enough ETH in reserve holder so some reserves need to be sold
    function executeArbitrageWithReserveSell(uint256 chiSpotPrice, SwapParams[] memory swapParams)
        external
        returns (uint256);

    /// @notice Executes arbitrage, profit sent to caller
    /// @notice Returns reward value in USD
    /// @param maxChiSpotPrice maximum spot price of CHI, if 0 TWAP check will be done
    /// @return rewardValue Reward value in USD
    /// @custom:usage This function should be called from external keeper in purpose of pegging USC price and getting reward
    /// @custom:usage This function has no restrictions, anyone can be arbitrager
    function executeArbitrage(uint256 maxChiSpotPrice) external returns (uint256 rewardValue);

    /// @notice Gets information for perfoming arbitrage such as price diff, reserve diff, discount
    /// @return isPriceAtPeg True if USC price is above target price
    /// @return isPriceAboveTarget True if USC price is above target price
    /// @return isExcessOfReserves True if there is excess of reserves
    /// @return reserveDiff Reserve diff, excess or deficit of reserves
    function getArbitrageData()
        external
        view
        returns (bool isPriceAtPeg, bool isPriceAboveTarget, bool isExcessOfReserves, uint256 reserveDiff);

    /// @notice Update arbitrager status
    /// @dev This function can be called only by owner of contract
    /// @param account Arbitrager account
    /// @param status Arbitrager status
    function updateArbitrager(address account, bool status) external;

    /// @notice Claim rewards from arbitrages
    /// @dev This function can be called only by owner of contract
    /// @param tokens Tokens to claim rewards for
    /// @param amounts Amounts of tokens to claim rewards for
    function claimRewards(IERC20[] memory tokens, uint256[] memory amounts) external;

    /// @notice Rewards USC
    /// @dev This function can be called only by owner of contract
    /// @param amount Amount of USC to reward
    function rewardUSC(uint256 amount) external;

    /// @notice Sets maximum mint and burn price difference
    /// @dev This function can be called only by owner of contract, value is absolute
    /// @param _maxMintBurnPriceDiff Maximum mint and burn price difference
    function setMaxMintBurnPriceDiff(uint256 _maxMintBurnPriceDiff) external;

    /// @notice Sets CHI price tolerance percentage when checking TWAP
    /// @dev This function can be called only by owner of contract, value is relative
    /// @param _chiPriceTolerance CHI price tolerance percentage
    function setChiPriceTolerance(uint16 _chiPriceTolerance) external;

    /// @notice Sets maximum mint and burn price difference
    /// @dev This function can be called only by owner of contract, value is relative
    /// @param _maxMintBurnReserveTolerance Maximum mint and burn reserve tolerance
    function setMaxMintBurnReserveTolerance(uint16 _maxMintBurnReserveTolerance) external;

    /// @notice Sets mint and burn fee
    /// @dev This function can be called only by owner of contract
    /// @param _mintBurnFee Mint and burn fee
    function setMintBurnFee(uint16 _mintBurnFee) external;

    /// @notice Update privilege status, only privileged accounts can call arbitrage and pass CHI TWAP check
    /// @dev This function can be called only by owner of contract
    /// @param account Arbitrager account
    /// @param status Privilege status
    function updatePrivileged(address account, bool status) external;

    /// @notice Burns USC tokens from msg.sender and sends him WETH from reserves
    /// @param amount Amount of USC tokens to burn
    /// @param reserveToReceive Address of reserve to receive
    /// @return ethAmount Amount of WETH received
    function burn(uint256 amount, address reserveToReceive) external returns (uint256 ethAmount);

    /// @notice Sets mint pause
    /// @param isPaused true of false
    function setMintPause(bool isPaused) external;

    /// @notice Sets burn pause
    /// @param isPaused true of false
    function setBurnPause(bool isPaused) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOracle {
    /// @notice Gets name of price adapter
    /// @return name Name of price adapter
    function name() external view returns (string memory name);

    /// @notice Gets decimals of price adapter
    /// @return decimals Decimals of price adapter
    function decimals() external view returns (uint8 decimals);

    /// @notice Gets price base token from Chainlink price feed
    /// @return price price in USD for the 1 baseToken
    function peek() external view returns (uint256 price);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/interfaces/IOracle.sol";

interface IPriceFeedAggregator {
    event SetPriceFeed(address indexed base, address indexed feed);

    error ZeroAddress();

    /// @notice Sets price feed adapter for given token
    /// @param base Token address
    /// @param feed Price feed adapter address
    function setPriceFeed(address base, address feed) external;

    /// @notice Gets price feed adapter for given token
    /// @param base Token address
    /// @return feed Price feed adapter address
    function priceFeeds(address base) external view returns (IOracle feed);

    /// @notice Gets price for given token
    /// @param base Token address
    /// @return price Price for given token
    function peek(address base) external view returns (uint256 price);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReserveHolderV2 {
    struct ReserveAssetInfo {
        /// @dev Amount of underlying ETH for this LST
        /// @dev For rebasing tokens it will be equal to amount of LST but for non-rebasing tokens it will depends on exchange rate
        uint256 totalDeposited;
        /// @dev Amount of LST claimed for this LST
        uint256 totalClaimed;
        /// @dev Address of underlying asset, if LST is rebasing then underlying asset is that LST but if LST is non-rebasing then underlying asset is WETH
        address underlyingAsset;
        /// @dev Address of swap adapter for this LST
        address swapAdapter;
        /// @dev Percentage of total reserve tokens that should be kept in this underlying asset
        uint256 percentage;
    }

    event SetArbitrager(address indexed arbitrager, bool enabled);
    event SetClaimer(address indexed claimer);
    event SetRebalancer(address indexed rebalancer, bool enabled);
    event SetSwapTolerance(uint256 swapTolerance);
    event AddReserveAsset(address indexed reserveAsset);
    event SetReserveAssetAdapter(address indexed reserveAsset, address adapter);
    event SetReserveAssetPercentage(address indexed reserveAsset, uint256 percentage);
    event Deposit(address indexed account, address indexed reserveAsset, uint256 amount);
    event Rebalance();
    event Redeem(address indexed account, address indexed reserve, uint256 amount);
    event ClaimRewards(address indexed account);
    event Claimed(address indexed account, address indexed reserveAsset, uint256 amount);

    error NotArbitrager();
    error NotClaimer();
    error NotRebalancer();
    error PercentageTooHigh();
    error AssetAlreadyAdded();
    error SlippageTooBig();

    /// @notice Gets reserve assets
    /// @return reserveAssets Reserve assets
    function getReserveAssets() external view returns (address[] memory reserveAssets);

    /// @notice Updates arbitrager status
    /// @param arbitrager Arbitrager address
    /// @param status Arbitrager status
    function setArbitrager(address arbitrager, bool status) external;

    /// @notice Sets claimer address
    /// @param claimer Claimer address
    /// @custom:usage Claimer should be rewardController contract
    function setClaimer(address claimer) external;

    /// @notice Sets rebalancer address
    /// @param rebalancer Rebalancer address
    /// @param status Rebalancer status
    function setRebalancer(address rebalancer, bool status) external;

    /// @notice Sets swap tolerance
    /// @param swapTolerance Swap tolerance
    /// @dev Only owner can call this function
    function setSwapTolerance(uint256 swapTolerance) external;

    /// @notice Adds reserve asset to reserves
    /// @param reserveAsset Reserve asset address
    /// @param reserveAdapter Adapter address
    /// @param reservePercentage Percentage of reserve asset in reserves
    /// @dev Only owner can call this function
    function addReserveAsset(address reserveAsset, address reserveAdapter, uint256 reservePercentage) external;

    /// @notice Sets adapter for new reserve asset
    /// @param reserveAsset Reserve asset address
    /// @param adapter Adapter address
    /// @dev Only owner can call this function
    function setReserveAssetAdapter(address reserveAsset, address adapter) external;

    /// @notice Sets percentage of reserve asset in reserves
    /// @param reserveAsset Reserve asset address
    /// @param percentage Percentage of reserve asset in reserves
    function setReserveAssetPercentage(address reserveAsset, uint256 percentage) external;

    /// @notice Gets reserve value in USD
    /// @return reserveValue Reserve value in USD
    function getReserveValue() external view returns (uint256 reserveValue);

    /// @notice Deposits reserve asset to reserves
    /// @param reserveAsset Reserve asset address
    /// @param amount Amount of reserve asset to deposit
    function deposit(address reserveAsset, uint256 amount) external;

    /// @notice Rebalance reserve in order to achieve balace
    /// @param spotPrices Spot prices of reserve assets. This is used for slippage protection
    /// @custom:usage This function should be called by external keeper
    function rebalance(uint256[] memory spotPrices) external;

    /// @notice Redeems stETH from reserves
    /// @param amount Amount of stETH to redeem
    /// @param reserve Reserve to redeem
    /// @return wethAmount Amount of WETH received
    /// @custom:usage This function should be called by arbitrage contract
    function redeem(uint256 amount, address reserve) external returns (uint256 wethAmount);

    /// @notice Claims stETH rewards in given amount for given account
    /// @notice Contract does not perform any check and is relying on rewardController contract to perform them
    /// @param account Account to claim stETH rewards for
    /// @custom:usage This function should be called by rewardController contract
    function claimRewards(address account) external;

    /// @notice Swap reserve asset for ETH
    /// @param reserve Reserve asset address
    /// @param amountIn Amount of reserve asset to swap
    /// @param minAmountOut Minimum amount of ETH to receive
    /// @custom:usage This function should be called by arbitrage contract in order to swap reserve asset for ETH and execute arbitrage with ETH
    function swapReserveForEth(address reserve, uint256 amountIn, uint256 minAmountOut) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice external contract addresses on Ethereum Mainnet
library ExternalContractAddresses {
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant stETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address public constant eETH = 0x35fA164735182de50811E8e2E824cFb9B6118ac2;
    address public constant weETH = 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee;
    address public constant eETH_POOL = 0x308861A430be4cce5502d0A12724771Fc6DaF216;
    address public constant UNI_V2_SWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant UNI_V3_SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public constant UNI_V2_POOL_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant ETH_USD_CHAINLINK_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address public constant STETH_USD_CHAINLINK_FEED = 0xCfE54B5cD566aB89272946F602D76Ea879CAb4a8;
    address public constant WEETH_ETH_CHAINLINK_FEED = 0x5c9C449BbC9a6075A2c061dF312a35fd1E05fF22;
    address public constant CURVE_ETH_STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
    address public constant ONE_INCH_ROUTER = 0x111111125421cA6dc452d289314280a0f8842A65;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// library copied from uniswap/v2-core/contracts/libraries/SafeMath.sol
// the only change is in pragma solidity version.
// this contract was the reason of incompatible solidity version error

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// library copied from uniswap/v2-core/contracts/libraries/UniswapV2Library.sol
// the only change is in pragma solidity version.

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

import "./SafeMath.sol";

library UniswapV2Library {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB)
        internal
        view
        returns (uint256 reserveA, uint256 reserveB)
    {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint256 amountIn, address[] memory path)
        internal
        view
        returns (uint256[] memory amounts)
    {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint256 amountOut, address[] memory path)
        internal
        view
        returns (uint256[] memory amounts)
    {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}