// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title $CHUNGUS Sale

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)


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

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Permit.sol)

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

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

contract BigChungusSale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    using Address for address payable;

    IERC20 public tokenContract; // token contract

    enum ContractState {
        OFF,
        SEED,
        FARMERS,
        PUBLIC,
        CLAIM
    }
    ContractState public contractState = ContractState.OFF;

    mapping(uint256 => uint256) public totalTokensBought;

    uint256 public totalTokensSeed = 1500000000 * 10 ** 18;
    uint256 public totalTokensFarmers=  2999999999 * 10 ** 18;
    uint256 public totalTokensPublic =  1000000000 * 10 ** 18;


    mapping(address => mapping(uint256 => uint256)) public tokensBought; // tokensBought[address] = number of tokens bought by address
    mapping(address => uint256) public claimedTokens; // claimedTokens[address] = number of tokens claimed by address

    uint256 public tokenPrice = 100000000 ether; //USD price has 8 decimals (5$ = 500000000), we also need to add ether (18 decimals)

    AggregatorV3Interface public priceFeed;
    // Supported payment methods
    mapping(address => bool) public supportedPaymentMethods;

    bytes32 public merkleRootSeed;
    bytes32 public merkleRootFarmers;

    uint256 public seedTGE = 20;
    uint256 public farmersTGE = 25;
    uint256 public publicTGE = 30;

    uint256 public vestingDurationSeed = 8 weeks; // Total duration of vesting
    uint256 public vestingDurationFarmers = 7 weeks;
    uint256 public vestingDurationPublic = 6 weeks;

    uint256 public claimStartTimestamp;

    // Define min and max buy amounts as global variables
    uint256 public minBuyAmount;
    uint256 public maxBuyAmount;

    address public treasury;

    // Events
    event TokensBought(address indexed buyer, address indexed paymentToken, uint256 numberOfTokens);

    event TokensClaimed(address indexed claimer, uint256 numberOfTokens);

    constructor() {

        // tokenContract = ;
        // treasury = ;

        // supportedPaymentMethods[] = true; // USDT
        // supportedPaymentMethods[] = true; // USDC


    }

    /**
     * Ensure current state is correct for this method.
     */
    modifier isContractState(ContractState contractState_) {
        require(contractState == contractState_, "Invalid state");
        _;
    }

    // Modifiers to check if the mint amount is within the allowed range for each stage
    // modifier withinLimit(uint256 numberOfTokens) {
    //     if (contractState == ContractState.SEED) {
    //         require(totalTokensBought + numberOfTokens <= totalTokensSeed, "Exceeds Seed stage limit");
    //     }
    //     else if (contractState == ContractState.FARMERS) {
    //         require(totalTokensBought + numberOfTokens <= totalTokensFarmers, "Exceeds Seed stage limit");
    //     }
    //     else {
    //         require(totalTokensBought + numberOfTokens <= totalTokensPublic, "Exceeds Seed stage limit");
    //     }
    //     _;
    // }

    /**
     *
     * @notice Throws if called when presale is not active
     * @param paymentToken the method of payment
     * @param numberOfTokens the number of tokens to buy
     */
    function buyTokensSeed(uint256 numberOfTokens, address paymentToken, bytes32[] calldata proof) external payable nonReentrant isContractState(ContractState.SEED) {
        require((tokensBought[msg.sender][1] + numberOfTokens) >= minBuyAmount && (tokensBought[msg.sender][1] + numberOfTokens) <= maxBuyAmount, "Purchase amount outside allowed range");

        /// Check if user is on the allow list
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        // Check the merkle proof
        require(MerkleProof.verify(proof, merkleRootSeed, leaf), "Invalid proof");
        

        if (numberOfTokens + totalTokensBought[1] > totalTokensSeed) {
            numberOfTokens = totalTokensSeed - totalTokensBought[1];
        }
        
        if (msg.value > 0) {
            require(address(paymentToken) == address(0), "Cannot Have Both ETH & ERC20 Payment Methodd!");

            uint256 cost = getCost(paymentToken, numberOfTokens);
            require(msg.value >= cost, "Insufficient Funds Sent!");
            tokensBought[msg.sender][1] += numberOfTokens;
            totalTokensBought[1] += numberOfTokens;

            (bool sent, ) = payable(treasury).call{value: cost}("");
            require(sent, "Failed To Send!");
            uint256 remainder = msg.value - cost;
            if (remainder > 0) {
                (sent, ) = payable(msg.sender).call{value: remainder}("");
                require(sent, "Failed To Refund Extra!");
            }
        } else {
            uint256 cost = getCost(paymentToken, numberOfTokens);
            require(IERC20(paymentToken).allowance(msg.sender, address(this)) >= cost, "Not Enough Allowance!");
            tokensBought[msg.sender][1] += numberOfTokens;
            totalTokensBought[1] += numberOfTokens;

            IERC20(paymentToken).safeTransferFrom(msg.sender, treasury, cost);
        }

        // Emit event
        emit TokensBought(
            msg.sender,
            paymentToken,
            numberOfTokens
        );
    }

    /**
     *
     * @notice Throws if called when presale is not active
     * @param paymentToken the method of payment
     * @param numberOfTokens the number of tokens to buy
     */
    function buyTokensFarmers(uint256 numberOfTokens, address paymentToken, bytes32[] calldata proof) external payable nonReentrant isContractState(ContractState.FARMERS) {
        require((tokensBought[msg.sender][2] + numberOfTokens) >= minBuyAmount && (tokensBought[msg.sender][2] + numberOfTokens) <= maxBuyAmount, "Purchase amount outside allowed range");

        /// Check if user is on the allow list
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        // Check the merkle proof
        require(MerkleProof.verify(proof, merkleRootFarmers, leaf), "Invalid proof");
        

        if (numberOfTokens + totalTokensBought[2] > totalTokensFarmers) {
            numberOfTokens = totalTokensFarmers - totalTokensBought[2];
        }
        
        if (msg.value > 0) {
            require(address(paymentToken) == address(0), "Cannot Have Both ETH & ERC20 Payment Methodd!");

            uint256 cost = getCost(paymentToken, numberOfTokens);
            require(msg.value >= cost, "Insufficient Funds Sent!");
            tokensBought[msg.sender][2] += numberOfTokens;
            totalTokensBought[2] += numberOfTokens;

            (bool sent, ) = payable(treasury).call{value: cost}("");
            require(sent, "Failed To Send!");
            uint256 remainder = msg.value - cost;
            if (remainder > 0) {
                (sent, ) = payable(msg.sender).call{value: remainder}("");
                require(sent, "Failed To Refund Extra!");
            }
        } else {
            uint256 cost = getCost(paymentToken, numberOfTokens);
            require(IERC20(paymentToken).allowance(msg.sender, address(this)) >= cost, "Not Enough Allowance!");
            tokensBought[msg.sender][2] += numberOfTokens;
            totalTokensBought[2] += numberOfTokens;

            IERC20(paymentToken).safeTransferFrom(msg.sender, treasury, cost);
        }

        // Emit event
        emit TokensBought(
            msg.sender,
            paymentToken,
            numberOfTokens
        );
    }

        /**
     *
     * @notice Throws if called when presale is not active
     * @param paymentToken the method of payment
     * @param numberOfTokens the number of tokens to buy
     */
    function buyTokensPublic(uint256 numberOfTokens, address paymentToken) external payable nonReentrant isContractState(ContractState.PUBLIC) {
        require((tokensBought[msg.sender][3] + numberOfTokens) >= minBuyAmount && (tokensBought[msg.sender][3] + numberOfTokens) <= maxBuyAmount, "Purchase amount outside allowed range");

        if (numberOfTokens + totalTokensBought[3] > totalTokensPublic) {
            numberOfTokens = totalTokensPublic - totalTokensBought[3];
        }
        
        if (msg.value > 0) {
            require(address(paymentToken) == address(0), "Cannot Have Both ETH & ERC20 Payment Methodd!");

            uint256 cost = getCost(paymentToken, numberOfTokens);
            require(msg.value >= cost, "Insufficient Funds Sent!");
            tokensBought[msg.sender][3] += numberOfTokens;
            totalTokensBought[3] += numberOfTokens;

            (bool sent, ) = payable(treasury).call{value: cost}("");
            require(sent, "Failed To Send!");
            uint256 remainder = msg.value - cost;
            if (remainder > 0) {
                (sent, ) = payable(msg.sender).call{value: remainder}("");
                require(sent, "Failed To Refund Extra!");
            }
        } else {
            uint256 cost = getCost(paymentToken, numberOfTokens);
            require(IERC20(paymentToken).allowance(msg.sender, address(this)) >= cost, "Not Enough Allowance!");
            tokensBought[msg.sender][3] += numberOfTokens;
            totalTokensBought[3] += numberOfTokens;

            IERC20(paymentToken).safeTransferFrom(msg.sender, treasury, cost);
        }

        // Check if we exceeded total amount
        if (totalTokensBought[3] == totalTokensPublic) {
            contractState = ContractState.OFF;
        }

        // Emit event
        emit TokensBought(
            msg.sender,
            paymentToken,
            numberOfTokens
        );
    }

    /**
     * @notice Transfer the number of tokens that can currently be claimed by the user (if any)
     */
    function claimTokens() external nonReentrant isContractState(ContractState.CLAIM) {
        require(block.timestamp > claimStartTimestamp, "Vesting Has Not Started Yet");

        uint256 tokensToClaim = calculateVestedTokens(msg.sender);

        require(tokensToClaim > 0, "No Tokens available for claim yet");

        claimedTokens[msg.sender] += tokensToClaim;
        tokenContract.safeTransfer(msg.sender, tokensToClaim);

        // Emit event
        emit TokensClaimed(msg.sender, tokensToClaim);
    }

    /**
     * @notice Calculates the amount of tokens that have vested for a user based on the global claimStartTimestamp.
     * @param user The address of the user.
     * @return The amount of vested tokens.
     */
    function calculateVestedTokens(address user) public view returns (uint256) {
        
        uint256 totalTokens;
        uint256 vestedTokens;
        for (uint i = 1; i < 4; i++) {
            uint256 timeElapsed = block.timestamp - claimStartTimestamp;
            if (i == 1) {
                if (timeElapsed >= vestingDurationSeed) {
                    vestedTokens = tokensBought[user][i];
                }
                else {
                    vestedTokens = (tokensBought[user][i] * seedTGE / 100) + (((tokensBought[user][i] * (100 - seedTGE)) / 100) * timeElapsed) / vestingDurationSeed;

                }
            }
            else if (i == 2) {
                if (timeElapsed >= vestingDurationFarmers) {
                    vestedTokens = tokensBought[user][i];
                }
                else {
                    vestedTokens = (tokensBought[user][i] * farmersTGE / 100) + (((tokensBought[user][i] * (100 - farmersTGE)) / 100) * timeElapsed) / vestingDurationFarmers;
                }
            }
            else {
                if (timeElapsed >= vestingDurationPublic) {
                    vestedTokens = tokensBought[user][i];
                }
                else {
                    vestedTokens = (tokensBought[user][i] * publicTGE / 100) + (((tokensBought[user][i] * (100 - publicTGE)) / 100) * timeElapsed) / vestingDurationPublic;
                }
            }

            totalTokens += vestedTokens;
        }

        return totalTokens - claimedTokens[user];
    }

    function getTokentoUSD() public view returns(int) {
          (,int price,,,) = priceFeed.latestRoundData();
          return price;
    }

    function getPriceEth() public view returns(uint256) {
          int price = getTokentoUSD();
          return tokenPrice / uint256(price);
    }

    /**
     * Calculate the cost of buying a number of tokens
     * @param paymentToken method of payment
     * @param numberOfTokens number of tokens to buy
     */
    function getCost(
        address paymentToken,
        uint256 numberOfTokens
    ) public view returns (uint256) {
        uint256 cost;
        if (paymentToken == address(0)) {
            cost = (numberOfTokens * getPriceEth()) / 10 ** 18;
        }
        else {
            require(supportedPaymentMethods[paymentToken], "Unsupported Payment Method!");
            cost = (numberOfTokens * tokenPrice * 10 ** IERC20Metadata(paymentToken).decimals()) / 10 ** 44;
        }

        return cost;
    }

    /**
    * @dev Function to retrieve the tokens avialable for purchase in a specific round
    * @param _buyer Address of the buyer
    * @param _round Active State (1 - SEED, 2 - FARMERS, 3 - PUBLIC)
    * @dev Make sure to input the correct active state of the contract. You can queue it by calling contractState(). 
    * Otherwise calculations within the function are irrelevant
    */
    function getTokensAvailable(address _buyer, uint256 _round) public view returns(uint256) {
        uint256 amount = maxBuyAmount - tokensBought[_buyer][_round];
        return amount;
    }

    /**
     * @notice Set price
     * @param _tokenPrice token price
     */
    function setTokenPrice(
        uint256 _tokenPrice
    ) external onlyOwner {
        tokenPrice = _tokenPrice;
    }

    /**
     * @dev Sets the price feed contract address.
     * Can only be called by the contract owner.
     *
     * @param _priceFeedAddress The address of the new price feed contract.
     */
    function setPriceFeed(address _priceFeedAddress) external onlyOwner {
        require(_priceFeedAddress != address(0), "Invalid address"); // Ensuring the provided address is not the zero address.
        priceFeed = AggregatorV3Interface(_priceFeedAddress); // Setting the new price feed address.
    }

    /**
     * @dev Sets the token contract address.
     * Can only be called by the contract owner.
     *
     * @param _tokenContractAddress The address of the new token contract.
     */
    function setTokenContract(address _tokenContractAddress) external onlyOwner {
        require(_tokenContractAddress != address(0), "Invalid address"); // Ensuring the provided address is not the zero address.
        tokenContract = IERC20(_tokenContractAddress); // Setting the new token contract address.
    }

    /**
     * @dev Sets the treasury address.
     * Can only be called by the contract owner.
     *
     * @param _treasuryAddress The address of the new treasury.
     */
    function setTreasury(address _treasuryAddress) external onlyOwner {
        require(_treasuryAddress != address(0), "Invalid address"); // Ensuring the provided address is not the zero address.
        treasury = _treasuryAddress; // Setting the new treasury address.
    }

    /**
     * @dev Sets the TGE percentage for Seed stage.
     * Can only be called when claimStartTimestamp is 0 and by the contract owner.
     *
     * @param _seedTGE The new TGE percentage for Seed stage.
     */
    function setSeedTGE(uint256 _seedTGE) external onlyOwner {
        require(claimStartTimestamp == 0, "Cannot change TGE after claims have started");
        require(_seedTGE <= 100, "TGE percentage cannot exceed 100");
        seedTGE = _seedTGE;
    }

    /**
     * @dev Sets the TGE percentage for Farmers stage.
     * Can only be called when claimStartTimestamp is 0 and by the contract owner.
     *
     * @param _farmersTGE The new TGE percentage for Farmers stage.
     */
    function setFarmersTGE(uint256 _farmersTGE) external onlyOwner {
        require(claimStartTimestamp == 0, "Cannot change TGE after claims have started");
        require(_farmersTGE <= 100, "TGE percentage cannot exceed 100");
        farmersTGE = _farmersTGE;
    }

    /**
     * @dev Sets the TGE percentage for Public stage.
     * Can only be called when claimStartTimestamp is 0 and by the contract owner.
     *
     * @param _publicTGE The new TGE percentage for Public stage.
     */
    function setPublicTGE(uint256 _publicTGE) external onlyOwner {
        require(claimStartTimestamp == 0, "Cannot change TGE after claims have started");
        require(_publicTGE <= 100, "TGE percentage cannot exceed 100");
        publicTGE = _publicTGE;
    }

    /**
     * @dev Sets the vesting duration for the Seed stage.
     * Can only be called by the contract owner before claiming starts.
     *
     * @param _duration The new vesting duration for the Seed stage in seconds.
     */
    function setVestingDurationSeed(uint256 _duration) external onlyOwner {
        require(claimStartTimestamp == 0, "Cannot change duration after claims have started");
        vestingDurationSeed = _duration;
    }

    /**
     * @dev Sets the vesting duration for the Farmers stage.
     * Can only be called by the contract owner before claiming starts.
     *
     * @param _duration The new vesting duration for the Farmers stage in seconds.
     */
    function setVestingDurationFarmers(uint256 _duration) external onlyOwner {
        require(claimStartTimestamp == 0, "Cannot change duration after claims have started");
        vestingDurationFarmers = _duration;
    }

    /**
     * @dev Sets the vesting duration for the Public stage.
     * Can only be called by the contract owner before claiming starts.
     *
     * @param _duration The new vesting duration for the Public stage in seconds.
     */
    function setVestingDurationPublic(uint256 _duration) external onlyOwner {
        require(claimStartTimestamp == 0, "Cannot change duration after claims have started");
        vestingDurationPublic = _duration;
    }

    /**
     * @dev Sets the minimum buy amount.
     * Can only be called by the contract owner.
     *
     * @param _minBuyAmount The new minimum buy amount.
     */
    function setMinBuyAmount(uint256 _minBuyAmount) external onlyOwner {
        require(_minBuyAmount <= maxBuyAmount, "Min buy amount cannot exceed max buy amount");
        minBuyAmount = _minBuyAmount;
    }

    /**
     * @dev Sets the maximum buy amount.
     * Can only be called by the contract owner.
     *
     * @param _maxBuyAmount The new maximum buy amount.
     */
    function setMaxBuyAmount(uint256 _maxBuyAmount) external onlyOwner {
        require(_maxBuyAmount >= minBuyAmount, "Max buy amount cannot be less than min buy amount");
        maxBuyAmount = _maxBuyAmount;
    }

    /**
     * @dev Sets the contract's operational state.
     * @param newState The new state to set the contract to
     */
    function setContractState(uint256 newState) external onlyOwner {
        require(newState < 5, "Invalid state.");
        contractState = ContractState(newState);

        if (newState == 4) {
            claimStartTimestamp = block.timestamp;
        }
    }

    /**
    * @dev Sets the Token Seed amount
    */
    function setTokensSeed(uint256 _amount) external onlyOwner {
        totalTokensSeed = _amount;
    }

    /** 
    * @dev Sets the TokensFarmers amount
    */
    function setTokensFarmers(uint256 _amount) external onlyOwner {
        totalTokensFarmers = _amount;
    }

    /** 
    * @dev Sets the TokensPublic amount
    */
    function setTokensPublic(uint256 _amount) external onlyOwner {
        totalTokensPublic = _amount;
    }

    /**
     * @param merkleRoot_ The new merkle root
     */
    function setMerkleRootSeed(bytes32 merkleRoot_) external onlyOwner {
        merkleRootSeed = merkleRoot_;
    }

    /**
     * @param merkleRoot_ The new merkle root
     */
    function setMerkleRootFarmers(bytes32 merkleRoot_) external onlyOwner {
        merkleRootFarmers = merkleRoot_;
    }

    /**
     * @notice Set a price feed for a given payment method
     * @param paymentToken IERC20 token to set price feed for
     */
    function setPaymentMethod(address paymentToken) external onlyOwner {
        require(paymentToken != address(0), "Invalid Address!");
        supportedPaymentMethods[paymentToken] = true;
    }

    /**
     * @notice Transfer ownership of the contract to a new owner after the presale ends
     * @param newOwner new owner of the contract
     */
    function transferOwnership(address newOwner) public override onlyOwner {
        Ownable.transferOwnership(newOwner);
    }

    /**
     * Revert any funds sent to the contract directly
     */
    receive() external payable {
        revert();
    }
}