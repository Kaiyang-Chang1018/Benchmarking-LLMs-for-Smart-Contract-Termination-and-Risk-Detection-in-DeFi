// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
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
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
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
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;


struct ImplementationStruct {
	address implementation;
	uint256 nonce;
}

interface IImplementationRegistry {
	/**
	 * @notice Adds a new implementation after verifying the provided signatures.
	 * @param _implementation The address of the implementation to be added.
	 * @param signatures An array of bytes representing the signatures required to validate the addition.
	 */
	function addImplementation(address _implementation, bytes[] memory signatures) external;

	/**
	 * @notice Removes the specificed implementation after verifying the provided signatures.
	 * @param _implementation The address of the implementation to be removed.
	 * @param signatures An array of bytes representing the signatures required to validate the addition.
	 */
	function removeImplementation(address _implementation, bytes[] memory signatures) external;

	/**
	 * @notice Verifies if the target address is a valid contract according to the stored proxy bytecode hash and checks if its implementation is valid.
	 * @param target The address of the target contract to be verified.
	 */
	function verifyIsValidContractAndImplementation(address target) external view;

	event ImplementationAdded(address indexed implementation);
	event ImplementationRemoved(address indexed implementation);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "./UserOperation.sol";

/**
 * Aggregated Signatures validator.
 */
interface IAggregator {
	/**
	 * validate aggregated signature.
	 * revert if the aggregated signature does not match the given list of operations.
	 */
	function validateSignatures(UserOperation[] calldata userOps, bytes calldata signature) external view;

	/**
	 * validate signature of a single userOp
	 * This method is should be called by bundler after EntryPoint.simulateValidation() returns (reverts) with ValidationResultWithAggregation
	 * First it validates the signature over the userOp. Then it returns data to be used when creating the handleOps.
	 * @param userOp the userOperation received from the user.
	 * @return sigForUserOp the value to put into the signature field of the userOp when calling handleOps.
	 *    (usually empty, unless account and aggregator support some kind of "multisig"
	 */
	function validateUserOpSignature(UserOperation calldata userOp) external view returns (bytes memory sigForUserOp);

	/**
	 * aggregate multiple signatures into a single value.
	 * This method is called off-chain to calculate the signature to pass with handleOps()
	 * bundler MAY use optimized custom code perform this aggregation
	 * @param userOps array of UserOperations to collect the signatures from.
	 * @return aggregatedSignature the aggregated signature
	 */
	function aggregateSignatures(UserOperation[] calldata userOps) external view returns (bytes memory aggregatedSignature);
}
/**
 ** Account-Abstraction (EIP-4337) singleton EntryPoint implementation.
 ** Only one instance required on each chain.
 **/
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/* solhint-disable avoid-low-level-calls */
/* solhint-disable no-inline-assembly */
/* solhint-disable reason-string */

import "./UserOperation.sol";
import "./IStakeManager.sol";
import "./IAggregator.sol";
import "./INonceManager.sol";

interface IEntryPoint is IStakeManager, INonceManager {
	/***
	 * An event emitted after each successful request
	 * @param userOpHash - unique identifier for the request (hash its entire content, except signature).
	 * @param sender - the account that generates this request.
	 * @param paymaster - if non-null, the paymaster that pays for this request.
	 * @param nonce - the nonce value from the request.
	 * @param success - true if the sender transaction succeeded, false if reverted.
	 * @param actualGasCost - actual amount paid (by account or paymaster) for this UserOperation.
	 * @param actualGasUsed - total gas used by this UserOperation (including preVerification, creation, validation and execution).
	 */
	event UserOperationEvent(
		bytes32 indexed userOpHash,
		address indexed sender,
		address indexed paymaster,
		uint256 nonce,
		bool success,
		uint256 actualGasCost,
		uint256 actualGasUsed
	);

	/**
	 * account "sender" was deployed.
	 * @param userOpHash the userOp that deployed this account. UserOperationEvent will follow.
	 * @param sender the account that is deployed
	 * @param factory the factory used to deploy this account (in the initCode)
	 * @param paymaster the paymaster used by this UserOp
	 */
	event AccountDeployed(bytes32 indexed userOpHash, address indexed sender, address factory, address paymaster);

	/**
	 * An event emitted if the UserOperation "callData" reverted with non-zero length
	 * @param userOpHash the request unique identifier.
	 * @param sender the sender of this request
	 * @param nonce the nonce used in the request
	 * @param revertReason - the return bytes from the (reverted) call to "callData".
	 */
	event UserOperationRevertReason(bytes32 indexed userOpHash, address indexed sender, uint256 nonce, bytes revertReason);

	/**
	 * an event emitted by handleOps(), before starting the execution loop.
	 * any event emitted before this event, is part of the validation.
	 */
	event BeforeExecution();

	/**
	 * signature aggregator used by the following UserOperationEvents within this bundle.
	 */
	event SignatureAggregatorChanged(address indexed aggregator);

	/**
	 * a custom revert error of handleOps, to identify the offending op.
	 *  NOTE: if simulateValidation passes successfully, there should be no reason for handleOps to fail on it.
	 *  @param opIndex - index into the array of ops to the failed one (in simulateValidation, this is always zero)
	 *  @param reason - revert reason
	 *      The string starts with a unique code "AAmn", where "m" is "1" for factory, "2" for account and "3" for paymaster issues,
	 *      so a failure can be attributed to the correct entity.
	 *   Should be caught in off-chain handleOps simulation and not happen on-chain.
	 *   Useful for mitigating DoS attempts against batchers or for troubleshooting of factory/account/paymaster reverts.
	 */
	error FailedOp(uint256 opIndex, string reason);

	/**
	 * error case when a signature aggregator fails to verify the aggregated signature it had created.
	 */
	error SignatureValidationFailed(address aggregator);

	/**
	 * Successful result from simulateValidation.
	 * @param returnInfo gas and time-range returned values
	 * @param senderInfo stake information about the sender
	 * @param factoryInfo stake information about the factory (if any)
	 * @param paymasterInfo stake information about the paymaster (if any)
	 */
	error ValidationResult(ReturnInfo returnInfo, StakeInfo senderInfo, StakeInfo factoryInfo, StakeInfo paymasterInfo);

	/**
	 * Successful result from simulateValidation, if the account returns a signature aggregator
	 * @param returnInfo gas and time-range returned values
	 * @param senderInfo stake information about the sender
	 * @param factoryInfo stake information about the factory (if any)
	 * @param paymasterInfo stake information about the paymaster (if any)
	 * @param aggregatorInfo signature aggregation info (if the account requires signature aggregator)
	 *      bundler MUST use it to verify the signature, or reject the UserOperation
	 */
	error ValidationResultWithAggregation(
		ReturnInfo returnInfo,
		StakeInfo senderInfo,
		StakeInfo factoryInfo,
		StakeInfo paymasterInfo,
		AggregatorStakeInfo aggregatorInfo
	);

	/**
	 * return value of getSenderAddress
	 */
	error SenderAddressResult(address sender);

	/**
	 * return value of simulateHandleOp
	 */
	error ExecutionResult(uint256 preOpGas, uint256 paid, uint48 validAfter, uint48 validUntil, bool targetSuccess, bytes targetResult);

	//UserOps handled, per aggregator
	struct UserOpsPerAggregator {
		UserOperation[] userOps;
		// aggregator address
		IAggregator aggregator;
		// aggregated signature
		bytes signature;
	}

	/**
	 * Execute a batch of UserOperation.
	 * no signature aggregator is used.
	 * if any account requires an aggregator (that is, it returned an aggregator when
	 * performing simulateValidation), then handleAggregatedOps() must be used instead.
	 * @param ops the operations to execute
	 * @param beneficiary the address to receive the fees
	 */
	function handleOps(UserOperation[] calldata ops, address payable beneficiary) external;

	/**
	 * Execute a batch of UserOperation with Aggregators
	 * @param opsPerAggregator the operations to execute, grouped by aggregator (or address(0) for no-aggregator accounts)
	 * @param beneficiary the address to receive the fees
	 */
	function handleAggregatedOps(UserOpsPerAggregator[] calldata opsPerAggregator, address payable beneficiary) external;

	/**
	 * generate a request Id - unique identifier for this request.
	 * the request ID is a hash over the content of the userOp (except the signature), the entrypoint and the chainid.
	 */
	function getUserOpHash(UserOperation calldata userOp) external view returns (bytes32);

	/**
	 * Simulate a call to account.validateUserOp and paymaster.validatePaymasterUserOp.
	 * @dev this method always revert. Successful result is ValidationResult error. other errors are failures.
	 * @dev The node must also verify it doesn't use banned opcodes, and that it doesn't reference storage outside the account's data.
	 * @param userOp the user operation to validate.
	 */
	function simulateValidation(UserOperation calldata userOp) external;

	/**
	 * gas and return values during simulation
	 * @param preOpGas the gas used for validation (including preValidationGas)
	 * @param prefund the required prefund for this operation
	 * @param sigFailed validateUserOp's (or paymaster's) signature check failed
	 * @param validAfter - first timestamp this UserOp is valid (merging account and paymaster time-range)
	 * @param validUntil - last timestamp this UserOp is valid (merging account and paymaster time-range)
	 * @param paymasterContext returned by validatePaymasterUserOp (to be passed into postOp)
	 */
	struct ReturnInfo {
		uint256 preOpGas;
		uint256 prefund;
		bool sigFailed;
		uint48 validAfter;
		uint48 validUntil;
		bytes paymasterContext;
	}

	/**
	 * returned aggregated signature info.
	 * the aggregator returned by the account, and its current stake.
	 */
	struct AggregatorStakeInfo {
		address aggregator;
		StakeInfo stakeInfo;
	}

	/**
	 * Get counterfactual sender address.
	 *  Calculate the sender contract address that will be generated by the initCode and salt in the UserOperation.
	 * this method always revert, and returns the address in SenderAddressResult error
	 * @param initCode the constructor code to be passed into the UserOperation.
	 */
	function getSenderAddress(bytes memory initCode) external;

	/**
	 * simulate full execution of a UserOperation (including both validation and target execution)
	 * this method will always revert with "ExecutionResult".
	 * it performs full validation of the UserOperation, but ignores signature error.
	 * an optional target address is called after the userop succeeds, and its value is returned
	 * (before the entire call is reverted)
	 * Note that in order to collect the the success/failure of the target call, it must be executed
	 * with trace enabled to track the emitted events.
	 * @param op the UserOperation to simulate
	 * @param target if nonzero, a target address to call after userop simulation. If called, the targetSuccess and targetResult
	 *        are set to the return from that call.
	 * @param targetCallData callData to pass to target address
	 */
	function simulateHandleOp(UserOperation calldata op, address target, bytes calldata targetCallData) external;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface INonceManager {
	/**
	 * Return the next nonce for this sender.
	 * Within a given key, the nonce values are sequenced (starting with zero, and incremented by one on each userop)
	 * But UserOp with different keys can come with arbitrary order.
	 *
	 * @param sender the account address
	 * @param key the high 192 bit of the nonce
	 * @return nonce a full nonce to pass for next UserOp with this sender.
	 */
	function getNonce(address sender, uint192 key) external view returns (uint256 nonce);

	/**
	 * Manually increment the nonce of the sender.
	 * This method is exposed just for completeness..
	 * Account does NOT need to call it, neither during validation, nor elsewhere,
	 * as the EntryPoint will update the nonce regardless.
	 * Possible use-case is call it with various keys to "initialize" their nonces to one, so that future
	 * UserOperations will not pay extra for the first transaction with a given key.
	 */
	function incrementNonce(uint192 key) external;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "./UserOperation.sol";

/**
 * the interface exposed by a paymaster contract, who agrees to pay the gas for user's operations.
 * a paymaster must hold a stake to cover the required entrypoint stake and also the gas for the transaction.
 */
interface IPaymaster {
	enum PostOpMode {
		opSucceeded, // user op succeeded
		opReverted, // user op reverted. still has to pay for gas.
		postOpReverted //user op succeeded, but caused postOp to revert. Now it's a 2nd call, after user's op was deliberately reverted.
	}

	/**
	 * payment validation: check if paymaster agrees to pay.
	 * Must verify sender is the entryPoint.
	 * Revert to reject this request.
	 * Note that bundlers will reject this method if it changes the state, unless the paymaster is trusted (whitelisted)
	 * The paymaster pre-pays using its deposit, and receive back a refund after the postOp method returns.
	 * @param userOp the user operation
	 * @param userOpHash hash of the user's request data.
	 * @param maxCost the maximum cost of this transaction (based on maximum gas and gas price from userOp)
	 * @return context value to send to a postOp
	 *      zero length to signify postOp is not required.
	 * @return validationData signature and time-range of this operation, encoded the same as the return value of validateUserOperation
	 *      <20-byte> sigAuthorizer - 0 for valid signature, 1 to mark signature failure,
	 *         otherwise, an address of an "authorizer" contract.
	 *      <6-byte> validUntil - last timestamp this operation is valid. 0 for "indefinite"
	 *      <6-byte> validAfter - first timestamp this operation is valid
	 *      Note that the validation code cannot use block.timestamp (or block.number) directly.
	 */
	function validatePaymasterUserOp(
		UserOperation calldata userOp,
		bytes32 userOpHash,
		uint256 maxCost
	) external returns (bytes memory context, uint256 validationData);

	/**
	 * post-operation handler.
	 * Must verify sender is the entryPoint
	 * @param mode enum with the following options:
	 *      opSucceeded - user operation succeeded.
	 *      opReverted  - user op reverted. still has to pay for gas.
	 *      postOpReverted - user op succeeded, but caused postOp (in mode=opSucceeded) to revert.
	 *                       Now this is the 2nd call, after user's op was deliberately reverted.
	 * @param context - the context value returned by validatePaymasterUserOp
	 * @param actualGasCost - actual gas used so far (without this postOp call).
	 */
	function postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) external;
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

/**
 * manage deposits and stakes.
 * deposit is just a balance used to pay for UserOperations (either by a paymaster or an account)
 * stake is value locked for at least "unstakeDelay" by the staked entity.
 */
interface IStakeManager {
	event Deposited(address indexed account, uint256 totalDeposit);

	event Withdrawn(address indexed account, address withdrawAddress, uint256 amount);

	/// Emitted when stake or unstake delay are modified
	event StakeLocked(address indexed account, uint256 totalStaked, uint256 unstakeDelaySec);

	/// Emitted once a stake is scheduled for withdrawal
	event StakeUnlocked(address indexed account, uint256 withdrawTime);

	event StakeWithdrawn(address indexed account, address withdrawAddress, uint256 amount);

	/**
	 * @param deposit the entity's deposit
	 * @param staked true if this entity is staked.
	 * @param stake actual amount of ether staked for this entity.
	 * @param unstakeDelaySec minimum delay to withdraw the stake.
	 * @param withdrawTime - first block timestamp where 'withdrawStake' will be callable, or zero if already locked
	 * @dev sizes were chosen so that (deposit,staked, stake) fit into one cell (used during handleOps)
	 *    and the rest fit into a 2nd cell.
	 *    112 bit allows for 10^15 eth
	 *    48 bit for full timestamp
	 *    32 bit allows 150 years for unstake delay
	 */
	struct DepositInfo {
		uint112 deposit;
		bool staked;
		uint112 stake;
		uint32 unstakeDelaySec;
		uint48 withdrawTime;
	}

	//API struct used by getStakeInfo and simulateValidation
	struct StakeInfo {
		uint256 stake;
		uint256 unstakeDelaySec;
	}

	/// @return info - full deposit information of given account
	function getDepositInfo(address account) external view returns (DepositInfo memory info);

	/// @return the deposit (for gas payment) of the account
	function balanceOf(address account) external view returns (uint256);

	/**
	 * add to the deposit of the given account
	 */
	function depositTo(address account) external payable;

	/**
	 * add to the account's stake - amount and delay
	 * any pending unstake is first cancelled.
	 * @param _unstakeDelaySec the new lock duration before the deposit can be withdrawn.
	 */
	function addStake(uint32 _unstakeDelaySec) external payable;

	/**
	 * attempt to unlock the stake.
	 * the value can be withdrawn (using withdrawStake) after the unstake delay.
	 */
	function unlockStake() external;

	/**
	 * withdraw from the (unlocked) stake.
	 * must first call unlockStake and wait for the unstakeDelay to pass
	 * @param withdrawAddress the address to send withdrawn value.
	 */
	function withdrawStake(address payable withdrawAddress) external;

	/**
	 * withdraw from the deposit.
	 * @param withdrawAddress the address to send withdrawn value.
	 * @param withdrawAmount the amount to withdraw.
	 */
	function withdrawTo(address payable withdrawAddress, uint256 withdrawAmount) external;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/* solhint-disable no-inline-assembly */

/**
 * User Operation struct
 * @param sender the sender account of this request.
 * @param nonce unique value the sender uses to verify it is not a replay.
 * @param initCode if set, the account contract will be created by this constructor/
 * @param callData the method call to execute on this account.
 * @param callGasLimit the gas limit passed to the callData method call.
 * @param verificationGasLimit gas used for validateUserOp and validatePaymasterUserOp.
 * @param preVerificationGas gas not calculated by the handleOps method, but added to the gas paid. Covers batch overhead.
 * @param maxFeePerGas same as EIP-1559 gas parameter.
 * @param maxPriorityFeePerGas same as EIP-1559 gas parameter.
 * @param paymasterAndData if set, this field holds the paymaster address and paymaster-specific data. the paymaster will pay for the transaction instead of the sender.
 * @param signature sender-verified signature over the entire request, the EntryPoint address and the chain ID.
 */
struct UserOperation {
	address sender;
	uint256 nonce;
	bytes initCode;
	bytes callData;
	uint256 callGasLimit;
	uint256 verificationGasLimit;
	uint256 preVerificationGas;
	uint256 maxFeePerGas;
	uint256 maxPriorityFeePerGas;
	bytes paymasterAndData;
	bytes signature;
}

/**
 * Utility functions helpful when working with UserOperation structs.
 */
library UserOperationLib {
	function getSender(UserOperation calldata userOp) internal pure returns (address) {
		address data;
		//read sender from userOp, which is first userOp member (saves 800 gas...)
		assembly {
			data := calldataload(userOp)
		}
		return address(uint160(data));
	}

	//relayer/block builder might submit the TX with higher priorityFee, but the user should not
	// pay above what he signed for.
	function gasPrice(UserOperation calldata userOp) internal view returns (uint256) {
		unchecked {
			uint256 maxFeePerGas = userOp.maxFeePerGas;
			uint256 maxPriorityFeePerGas = userOp.maxPriorityFeePerGas;
			if (maxFeePerGas == maxPriorityFeePerGas) {
				//legacy mode (for networks that don't support basefee opcode)
				return maxFeePerGas;
			}
			return min(maxFeePerGas, maxPriorityFeePerGas + block.basefee);
		}
	}

	function pack(UserOperation calldata userOp) internal pure returns (bytes memory ret) {
		//lighter signature scheme. must match UserOp.ts#packUserOp
		bytes calldata sig = userOp.signature;
		// copy directly the userOp from calldata up to (but not including) the signature.
		// this encoding depends on the ABI encoding of calldata, but is much lighter to copy
		// than referencing each field separately.
		assembly {
			let ofs := userOp
			let len := sub(sub(sig.offset, ofs), 32)
			ret := mload(0x40)
			mstore(0x40, add(ret, add(len, 32)))
			mstore(ret, len)
			calldatacopy(add(ret, 32), ofs, len)
		}
	}

	function hash(UserOperation calldata userOp) internal pure returns (bytes32) {
		return keccak256(pack(userOp));
	}

	function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a < b ? a : b;
	}
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface ITokenPriceOracle {
	/**
	 * @dev Returns the value of a given amount of ETH in the specified token using the provided price feed.
	 * @param aggregatorOrToken The address of the price feed contract. It must be a X/ETH price feed, ie this USDC/ETH price feed on mainnet
	 * https://etherscan.io/address/0x986b5E1e1755e3C2440e960477f25201B0a8bbD4#readContract
	 * @param ethAmount The amount of ETH to convert, denominated in WEI
	 * @param tokenDecimals The number of decimals used by the specified token.
	 * @return tokenValueOfEth value of the specified amount of ETH in the token.
	 * @return oracleValidUntil Latest date of accepted return.
	 */
	function getTokenValueOfEth(
		address aggregatorOrToken,
		uint256 ethAmount,
		uint8 tokenDecimals
	) external view returns (uint256 tokenValueOfEth, uint256 oracleValidUntil);
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

import "../eip-4337/IEntryPoint.sol";

struct UserOperationFee {
	address token;
	address payable recipient;
	uint256 amount;
}

interface IFunWallet {
	/**
	 * @notice deposit to entrypoint to prefund the execution.
	 * @dev This function can only be called by the owner of the contract.
	 * @param amount the amount to deposit.
	 */
	function depositToEntryPoint(uint256 amount) external;

	/**
	 * @notice Get the entry point for this contract
	 * @dev This function returns the contract's entry point interface.
	 * @return The contract's entry point interface.
	 */
	function entryPoint() external view returns (IEntryPoint);

	/**
	 * @notice Update the entry point for this contract
	 * @dev This function can only be called by the current entry point.
	 * @dev The new entry point address cannot be zero.
	 * @param _newEntryPoint The address of the new entry point.
	 */
	function updateEntryPoint(IEntryPoint _newEntryPoint) external;

	/**
	 * @notice withdraw deposit from entrypoint
	 * @dev This function can only be called by the owner of the contract.
	 * @param withdrawAddress the address to withdraw Eth to
	 * @param amount the amount to be withdrawn
	 */
	function withdrawFromEntryPoint(address payable withdrawAddress, uint256 amount) external;

	/**
	 * @notice Transfer ERC20 tokens from the wallet to a destination address.
	 * @param token ERC20 token address
	 * @param dest Destination address
	 * @param amount Amount of tokens to transfer
	 */
	function transferErc20(address token, address dest, uint256 amount) external;

	function isValidAction(address target, uint256 value, bytes memory data, bytes memory signature, bytes32 _hash) external view returns (uint256);

	event EntryPointChanged(address indexed newEntryPoint);
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

import "./IFunWallet.sol";

interface IWalletFee {
	function execFromEntryPoint(address dest, uint256 value, bytes calldata data) external;

	function execFromEntryPointWithFee(address dest, uint256 value, bytes calldata data, UserOperationFee memory feedata) external;
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

interface IWalletModules {
	/**
	 * @notice generates correct hash for signature.
	 * @param token token to transfer.
	 * @param to address to transfer tokens to.
	 * @param amount amount of tokens to transfer.
	 * @param nonce nonce to check against signature data with.
	 * @return _hash valid signature hash for permit.
	 */
	function getPermitHash(address token, address to, uint256 amount, uint256 nonce) external pure returns (bytes32 _hash);

	/**
	 * @notice gets nonce for a key.
	 * @param key base of nonce.
	 * @return out valid nonce for permit for key.

	 */
	function getNonce(uint32 key) external view returns (uint256 out);

	/**
	 * @notice Validates and executes permit based transfer.
	 * @param token token to transfer.
	 * @param to address to transfer tokens to.
	 * @param amount amount of tokens to transfer.
	 * @param nonce nonce to check against signature data with.
	 * @param sig signature of permit hash.
	 * @return validPermit successful transfer.
	 
	 */
	function permitTransfer(address token, address to, uint256 amount, uint256 nonce, bytes calldata sig) external returns (bool validPermit);

	/**
	 * @notice Validates permit based transfer.
	 * @param token token to transfer.
	 * @param to address to transfer tokens to.
	 * @param amount amount of tokens to transfer.
	 * @param nonce nonce to check against signature data with.
	 * @param sig signature of permit hash.
	 */
	function validatePermit(address token, address to, uint256 amount, uint256 nonce, bytes calldata sig) external view returns (uint256);
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

/* solhint-disable reason-string */


import "../utils/Ownable2StepNoRenounce.sol";
import "../interfaces/eip-4337/IPaymaster.sol";
import "../interfaces/eip-4337/IEntryPoint.sol";

/**
 * @title BasePaymaster
 * @author fun.xyz eth-infinitism
 * @notice Helper class for creating a paymaster.
 * provides helper methods for staking.
 * validates that the postOp is called only by the entryPoint
 */
abstract contract BasePaymaster is IPaymaster, Ownable2StepNoRenounce {
	IEntryPoint public immutable entryPoint;

	constructor(IEntryPoint _entryPoint) {
		require(address(_entryPoint) != address(0), "FW300");
		entryPoint = _entryPoint;
		emit PaymasterCreated(_entryPoint);
	}

	/**
	 * payment validation: check if paymaster agrees to pay.
	 * Must verify sender is the entryPoint.
	 * Revert to reject this request.
	 * Note that bundlers will reject this method if it changes the state, unless the paymaster is trusted (whitelisted)
	 * The paymaster pre-pays using its deposit, and receive back a refund after the postOp method returns.
	 * @param userOp the user operation
	 * @param userOpHash hash of the user's request data.
	 * @param maxCost the maximum cost of this transaction (based on maximum gas and gas price from userOp)
	 * @return context value to send to a postOp
	 *      zero length to signify postOp is not required.
	 * @return sigTimeRange Note: we do not currently support validUntil and validAfter
	 */
	function validatePaymasterUserOp(
		UserOperation calldata userOp,
		bytes32 userOpHash,
		uint256 maxCost
	) external override returns (bytes memory context, uint256 sigTimeRange) {
		_requireFromEntryPoint();
		return _validatePaymasterUserOp(userOp, userOpHash, maxCost);
	}

	/**
	 * payment validation: check if paymaster agrees to pay.
	 * Must verify sender is the entryPoint.
	 * Revert to reject this request.
	 * Note that bundlers will reject this method if it changes the state, unless the paymaster is trusted (whitelisted)
	 * The paymaster pre-pays using its deposit, and receive back a refund after the postOp method returns.
	 * @param userOp the user operation
	 * @param userOpHash hash of the user's request data.
	 * @param maxCost the maximum cost of this transaction (based on maximum gas and gas price from userOp)
	 * @return context value to send to a postOp
	 *      zero length to signify postOp is not required.
	 * @return sigTimeRange Note: we do not currently support validUntil and validAfter
	 */
	function _validatePaymasterUserOp(
		UserOperation calldata userOp,
		bytes32 userOpHash,
		uint256 maxCost
	) internal virtual returns (bytes memory context, uint256 sigTimeRange);

	/**
	 * post-operation handler.
	 * Must verify sender is the entryPoint
	 * @param mode enum with the following options:
	 *      opSucceeded - user operation succeeded.
	 *      opReverted  - user op reverted. still has to pay for gas.
	 *      postOpReverted - user op succeeded, but caused postOp (in mode=opSucceeded) to revert.
	 *                       Now this is the 2nd call, after user's op was deliberately reverted.
	 * @param context - the context value returned by validatePaymasterUserOp
	 * @param actualGasCost - actual gas used so far (without this postOp call).
	 */
	function postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) external override {
		_requireFromEntryPoint();
		_postOp(mode, context, actualGasCost);
	}

	/**
	 * post-operation handler.
	 * (verified to be called only through the entryPoint)
	 * @dev if subclass returns a non-empty context from validatePaymasterUserOp, it must also implement this method.
	 * @param mode enum with the following options:
	 *      opSucceeded - user operation succeeded.
	 *      opReverted  - user op reverted. still has to pay for gas.
	 *      postOpReverted - user op succeeded, but caused postOp (in mode=opSucceeded) to revert.
	 *                       Now this is the 2nd call, after user's op was deliberately reverted.
	 * @param context - the context value returned by validatePaymasterUserOp
	 * @param actualGasCost - actual gas used so far (without this postOp call).
	 */
	function _postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) internal virtual {
		(mode, context, actualGasCost); // unused params
		// subclass must override this method if validatePaymasterUserOp returns a context
		revert("must override");
	}

	/**
	 * add stake for this paymaster.
	 * This method can also carry eth value to add to the current stake.
	 * @param unstakeDelaySec - the unstake delay for this paymaster. Can only be increased.
	 */
	function addStakeToEntryPoint(uint32 unstakeDelaySec) external payable onlyOwner {
		entryPoint.addStake{value: msg.value}(unstakeDelaySec);
	}

	/**
	 * unlock the stake, in order to withdraw it.
	 * The paymaster can't serve requests once unlocked, until it calls addStake again
	 */
	function unlockStakeFromEntryPoint() external onlyOwner {
		entryPoint.unlockStake();
	}

	/**
	 * withdraw the entire paymaster's stake.
	 * stake must be unlocked first (and then wait for the unstakeDelay to be over)
	 * @param withdrawAddress the address to send withdrawn value.
	 */
	function withdrawStakeFromEntryPoint(address payable withdrawAddress) external onlyOwner {
		require(withdrawAddress != address(0), "FW351");
		entryPoint.withdrawStake(withdrawAddress);
	}

	/// validate the call is made from a valid entrypoint
	function _requireFromEntryPoint() internal virtual {
		require(msg.sender == address(entryPoint), "FW301");
	}

	event PaymasterCreated(IEntryPoint entryPoint);
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

/* solhint-disable reason-string */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./BasePaymaster.sol";
import "../interfaces/oracles/ITokenPriceOracle.sol";
import "../utils/HashLib.sol";
import "../utils/DataLib.sol";
import "../interfaces/wallet/IWalletModules.sol";
import "../interfaces/deploy/IImplementationRegistry.sol";

/**
 * A token-based paymaster that accepts token deposit
 * The deposit is only a safeguard: the spender pays with his token balance.
 *  only if the spender didn't approve() the paymaster, or if the token balance is not enough, the deposit will be used.
 *  thus the required deposit is to cover just one method call.
 * The deposit is locked for the current block: the spender must issue unlockTokenDeposit() to be allowed to withdraw
 *  (but can't use the deposit for this or further operations)
 *
 * paymasterAndData holds the paymaster address followed by the token address to use.
 * @notice This paymaster will be rejected by the standard rules of EIP4337, as it uses an external oracle.
 * (the standard rules ban accessing data of an external contract)
 * It can only be used if it is "whitelisted" by the bundler.
 * (technically, it can be used by an "oracle" which returns a static value, without accessing any storage)
 */

enum DataStoreType {
	UNLOCK_BLOCK,
	TOKEN,
	LISTMODE,
	TOKENLISTMODE,
	BLACKLIST,
	WHITELIST
}
struct TokenContext {
	address spender;
	address sponsor;
	address token;
	uint256 gasPrice;
	uint256 maxTokenCost;
	uint256 maxCost;
	bytes32 opHash;
	uint256 postCost;
}
struct TokenData {
	ITokenPriceOracle oracle;
	IERC20 token;
	uint8 decimals;
	address aggregator;
}

/**
 * @title Token paymaster Contract
 * @dev A contract that extends the BasePaymaster contract and uses the UserOperationLib and SafeERC20 libraries.
 */
contract TokenPaymaster is BasePaymaster {
	using UserOperationLib for UserOperation;
	using SafeERC20 for IERC20;

	//calculated cost of the postOp
	uint256 public constant COST_OF_SIG = 40_000;
	uint256 public constant COST_OF_TRANSFER = 180_000;

	address public constant ETH = address(0);
	uint256 public accumulatedEthDust = 0;
	/**
	 * @dev This constant is used to define the version of this contract.
	 */
	uint256 public constant VERSION = 1;

	IImplementationRegistry public immutable implementationRegistry;

	mapping(bytes32 => bool) private sponsorApprovals;
	mapping(bytes32 => uint256) private dataStore;
	mapping(address => TokenData) public tokens;

	address[] private tokenList;

	constructor(IEntryPoint _entryPoint, IImplementationRegistry _implementationRegistry) BasePaymaster(_entryPoint) {
		implementationRegistry = _implementationRegistry;
	}

	function withdrawEthDust() external onlyOwner {
		uint256 ethWithdrawn = entryPoint.getDepositInfo(address(this)).deposit - accumulatedEthDust;
		entryPoint.withdrawTo(payable(owner()), ethWithdrawn);
	}

	function calculatePostOpGas(bool usePermit, bytes memory signature) internal pure returns (uint256) {
		if (!usePermit) return COST_OF_SIG + COST_OF_TRANSFER;
		(uint8 authType, , , , bytes memory sig, ) = DataLib.getAuthData(signature);
		if (authType == 0) {
			return COST_OF_SIG + COST_OF_TRANSFER;
		} else if (authType == 1) {
			(uint8[] memory pos, ) = abi.decode(sig, (uint8[], bytes[]));
			return COST_OF_SIG * pos.length + COST_OF_TRANSFER;
		} else {
			revert("FW349");
		}
	}

	/**
	 * @notice batch call method
	 * @dev Executes a batch of transactions.
	 * @param data An array of transaction data to execute.
	 */
	function batchActions(bytes[] calldata data) public payable {
		uint256 value = 0;
		unchecked {
			for (uint256 i = 0; i < data.length; ++i) {
				if (bytes4(data[i][:4]) == this.batchActions.selector) {
					revert("FW345");
				} else if (bytes4(data[i][:4]) == this.addEthDepositTo.selector) {
					(address sponsor, uint256 amount) = abi.decode(data[i][4:], (address, uint256));
					value += amount;
					_addEthDepositTo(msg.sender, sponsor, amount);
				} else {
					(bool success, ) = address(this).delegatecall(data[i]);
					require(success, "FW312");
				}
			}
		}
		require(value == msg.value, "FW313");
		emit BatchActions(data);
	}

	// Key Hash Generators

	function _getDataStoreKey(address _token, address spender, DataStoreType dataType) internal pure returns (bytes32) {
		return HashLib.hash3(_token, spender, uint8(dataType));
	}

	function _getUnlockBlockKey(address _token, address spender) internal pure returns (bytes32) {
		return _getDataStoreKey(_token, spender, DataStoreType.UNLOCK_BLOCK);
	}

	function _getTokenBalanceKey(address _token, address spender) internal pure returns (bytes32) {
		return _getDataStoreKey(_token, spender, DataStoreType.TOKEN);
	}

	function _getListModeKey(address sponsor) internal pure returns (bytes32) {
		return HashLib.hash2(sponsor, uint8(DataStoreType.LISTMODE));
	}

	function _getSpenderBlacklistKey(address spender, address sponsor) internal pure returns (bytes32) {
		return HashLib.hash3(spender, sponsor, uint8(DataStoreType.BLACKLIST));
	}

	function _getSpenderWhitelistKey(address spender, address sponsor) internal pure returns (bytes32) {
		return HashLib.hash3(spender, sponsor, uint8(DataStoreType.WHITELIST));
	}

	function _getSponsorTokenKey(address _token, address sponsor) internal pure returns (bytes32) {
		return HashLib.hash2(_token, sponsor);
	}

	function _getTokenListModeKey(address sponsor) internal pure returns (bytes32) {
		return HashLib.hash2(sponsor, uint8(DataStoreType.TOKENLISTMODE));
	}

	function _getTokenBlacklistKey(address token, address sponsor) internal pure returns (bytes32) {
		return HashLib.hash3(token, sponsor, uint8(DataStoreType.BLACKLIST));
	}

	function _getTokenWhitelistKey(address token, address sponsor) internal pure returns (bytes32) {
		return HashLib.hash3(token, sponsor, uint8(DataStoreType.WHITELIST));
	}

	///////////////////////
	// START INTERNAL OPS//
	///////////////////////

	// Tokens Stake

	function _addTokenDepositTo(address _token, address sender, address spender, uint256 amount) internal {
		require(tokens[_token].decimals != 0, "FW314");
		IERC20 token = tokens[_token].token;

		uint256 beforeBalance = token.balanceOf(address(this));
		token.safeTransferFrom(sender, address(this), amount);
		uint256 afterBalance = token.balanceOf(address(this));
		dataStore[_getTokenBalanceKey(_token, spender)] += afterBalance - beforeBalance;
	}

	function _withdrawTokenDepositTo(address _token, address sender, address target, uint256 amount) internal {
		uint256 unlockBlockValue = getUnlockBlock(_token, sender);
		require(block.number > unlockBlockValue && unlockBlockValue != 0, "FW315");

		bytes32 tokenBalanceKey = _getTokenBalanceKey(_token, sender);
		require(dataStore[tokenBalanceKey] >= amount, "FW316");
		dataStore[tokenBalanceKey] -= amount;

		IERC20 token = tokens[_token].token;
		token.safeTransfer(target, amount);
	}

	function _addEthDepositTo(address sender, address spender, uint256 amount) internal {
		entryPoint.depositTo{value: amount}(address(this));
		dataStore[_getTokenBalanceKey(ETH, spender)] += amount;
		accumulatedEthDust += amount;
		if (sender == spender) {
			_setUnlockBlock(ETH, sender, 0);
		}
	}

	function _withdrawEthDepositTo(address sender, address payable target, uint256 amount) internal {
		uint256 unlockBlockValue = getUnlockBlock(ETH, sender);
		require(block.number > unlockBlockValue && unlockBlockValue != 0, "FW317");

		bytes32 ethBalanceKey = _getTokenBalanceKey(ETH, sender);
		require(dataStore[ethBalanceKey] >= amount, "FW318");

		dataStore[ethBalanceKey] -= amount;
		accumulatedEthDust -= amount;
		entryPoint.withdrawTo(target, amount);
	}

	// Access Control

	function _setUnlockBlock(address _token, address spender, uint256 num) internal {
		dataStore[_getUnlockBlockKey(_token, spender)] = num;
	}

	function _setListMode(address sponsor, bool mode) internal {
		sponsorApprovals[_getListModeKey(sponsor)] = mode;
	}

	function _setSpenderBlacklistMode(address spender, address sponsor, bool mode) internal {
		sponsorApprovals[_getSpenderBlacklistKey(spender, sponsor)] = mode;
	}

	function _setSpenderWhitelistMode(address spender, address sponsor, bool mode) internal {
		sponsorApprovals[_getSpenderWhitelistKey(spender, sponsor)] = mode;
	}

	function _setTokenListMode(address sponsor, bool mode) internal {
		sponsorApprovals[_getTokenListModeKey(sponsor)] = mode;
	}

	function _setTokenBlacklistMode(address token, address sponsor, bool mode) internal {
		sponsorApprovals[_getTokenBlacklistKey(token, sponsor)] = mode;
	}

	function _setTokenWhitelistMode(address token, address sponsor, bool mode) internal {
		sponsorApprovals[_getTokenWhitelistKey(token, sponsor)] = mode;
	}

	function _setTokensApproval(address[] calldata _tokens, address sponsor, bool mode) internal {
		for (uint256 i = 0; i < _tokens.length; ++i) {
			_setTokensApprovalMode(_tokens[i], sponsor, mode);
		}
	}

	function _setTokensApprovalMode(address token, address sponsor, bool mode) internal {
		bytes32 tokeApprovalKey = _getSponsorTokenKey(token, sponsor);
		sponsorApprovals[tokeApprovalKey] = mode;
	}

	/////////////////////
	// END INTERNAL OPS//
	/////////////////////

	// Approval Bool Generators

	function _getSponsorApproval(address spender, address sponsor) internal view returns (bool) {
		bool blackListMode = sponsorApprovals[_getListModeKey(sponsor)];
		if (blackListMode) {
			bool isSpenderBlacklisted = sponsorApprovals[_getSpenderBlacklistKey(spender, sponsor)];
			return !isSpenderBlacklisted;
		}
		return sponsorApprovals[_getSpenderWhitelistKey(spender, sponsor)];
	}

	function _getSponsorTokenApproval(address token, address sponsor) internal view returns (bool) {
		bool blackListMode = sponsorApprovals[_getTokenListModeKey(sponsor)];
		if (blackListMode) {
			bool isTokenBlacklisted = sponsorApprovals[_getTokenBlacklistKey(token, sponsor)];
			return !isTokenBlacklisted;
		}
		return sponsorApprovals[_getTokenWhitelistKey(token, sponsor)];
	}

	function getCanPayThroughApproval(address _token, address spender, uint256 tokenAmount) public view returns (bool) {
		IERC20 token = tokens[_token].token;
		uint256 paymasterAllownace = token.allowance(spender, address(this));
		return getHasBalance(token, spender, tokenAmount) && paymasterAllownace >= tokenAmount;
	}

	function getHasBalance(IERC20 token, address spender, uint256 tokenAmount) public view returns (bool) {
		uint256 userBalance = token.balanceOf(spender);
		return userBalance >= tokenAmount;
	}

	function _getHasEnoughDeposit(address _token, address spender, uint256 tokenAmount) internal view returns (bool) {
		return dataStore[_getTokenBalanceKey(_token, spender)] >= tokenAmount;
	}

	function _getTokenIsUsable(address _token, address sponsor) internal view returns (bool) {
		return sponsorApprovals[_getSponsorTokenKey(_token, sponsor)];
	}

	// EIP-4337

	function getTokenValueOfEth(address _token, uint256 ethBought) public view virtual returns (uint256, uint256) {
		TokenData memory token = tokens[_token];
		bytes memory tokenCallData = abi.encodeWithSelector(ITokenPriceOracle.getTokenValueOfEth.selector, token.aggregator, ethBought, token.decimals);
		(bool success, bytes memory returnData) = address(token.oracle).staticcall(tokenCallData);
		require(success && returnData.length > 0, "FW319");
		return abi.decode(returnData, (uint256, uint256));
	}

	/**
	 * @notice Reimburse the paymaster for the value of gas the UserOperation spent in this transaction with _token.
	 * @param _token The address of the token used for payment.
	 * @param spender The address that made the payment.
	 * @param actualTokenCost The actual token cost of the payment.
	 * @param permitData The permit data used for token approval (if applicable).
	 */
	function _reimbursePaymaster(address _token, address spender, uint256 actualTokenCost, bytes memory permitData) internal {
		// attempt to pay with tokens:
		IERC20 erc20Token = tokens[_token].token;
		if (permitData.length > 0) {
			_transferPermit(permitData, erc20Token, spender, actualTokenCost);
		} else if (getCanPayThroughApproval(_token, spender, actualTokenCost)) {
			uint256 beforeBalance = erc20Token.balanceOf(address(this));
			erc20Token.safeTransferFrom(spender, address(this), actualTokenCost);
			uint256 afterBalance = erc20Token.balanceOf(address(this));
			require(afterBalance - beforeBalance == actualTokenCost, "FW321");
		} else {
			bytes32 spenderTokenKey = _getTokenBalanceKey(_token, spender);
			require(dataStore[spenderTokenKey] >= actualTokenCost, "FW321");
			dataStore[spenderTokenKey] -= actualTokenCost;
		}
	}

	/**
	 * @notice Transfers tokens using permit data for approval.
	 * @param permitData The permit data containing the token transfer details.
	 * @param erc20Token The ERC20 token contract instance.
	 * @param spender The address performing the token transfer.
	 */
	function _transferPermit(bytes memory permitData, IERC20 erc20Token, address spender, uint256 actualTokenCost) internal {
		(address permitToken, address to, uint256 amount, uint256 nonce, bytes memory sig) = abi.decode(
			permitData,
			(address, address, uint256, uint256, bytes)
		);
		uint256 prePermitBalance = erc20Token.balanceOf(address(this));
		(bool success, bytes memory ret) = spender.call(
			abi.encodeWithSelector(IWalletModules.permitTransfer.selector, permitToken, to, amount, nonce, sig)
		);
		{
			if (success && abi.decode(ret, (bool))) {
				uint256 postPermitBalance = erc20Token.balanceOf(address(this));
				require(postPermitBalance - prePermitBalance == amount, "FW346");
				dataStore[_getTokenBalanceKey(permitToken, spender)] += amount - actualTokenCost;
			} else {
				assembly {
					mstore(add(ret, 4), sub(mload(ret), 4))
					ret := add(ret, 4)
				}
				revert(string.concat("FW320: ", string(ret)));
			}
		}
	}

	function _validatePaymasterUserOp(
		UserOperation calldata userOp,
		bytes32 opHash,
		uint256 maxCost
	) internal view override returns (bytes memory context, uint256 sigTimeRange) {
		uint256 postCost = calculatePostOpGas(false, userOp.signature);
		require(userOp.paymasterAndData.length >= 20 + 20 + 20, "FW322");

		implementationRegistry.verifyIsValidContractAndImplementation(userOp.sender);

		address sponsor;
		address token;

		if (userOp.paymasterAndData.length == 60) {
			sponsor = address(bytes20(userOp.paymasterAndData[20:40]));
			token = address(bytes20(userOp.paymasterAndData[40:]));
		} else {
			(bytes memory addrs, ) = abi.decode(userOp.paymasterAndData[20:], (bytes, bytes));
			(sponsor, token) = abi.decode(addrs, (address, address));
		}
		{
			uint256 sponsorUnlockBlock = dataStore[_getUnlockBlockKey(ETH, sponsor)];
			require(sponsorUnlockBlock == 0, "FW324");
		}

		address spender = userOp.getSender();
		{
			uint256 accountUnlockBlock = dataStore[_getUnlockBlockKey(token, spender)];
			uint256 sponsorEthBalance = dataStore[_getTokenBalanceKey(ETH, sponsor)];

			require(accountUnlockBlock == 0, "FW325");
			require(sponsorEthBalance >= maxCost, "FW326");
		}

		bytes memory permit = "";
		(uint256 maxTokenCost, uint256 oracleValidUntil) = getTokenValueOfEth(token, maxCost);
		require(_getSponsorApproval(spender, sponsor), "FW327");
		require(_getSponsorTokenApproval(token, sponsor), "FW328");
		if (userOp.paymasterAndData.length > 60) {
			(, bytes memory permitData) = abi.decode(userOp.paymasterAndData[20:], (bytes, bytes));
			(address _token, address to, uint256 amount, uint256 nonce, bytes memory sig) = abi.decode(
				permitData,
				(address, address, uint256, uint256, bytes)
			);
			postCost = calculatePostOpGas(true, sig);

			require(_token == token, "FW329");
			require(to == address(this), "FW330");
			require(amount >= maxTokenCost, "FW331");
			require(getHasBalance(tokens[_token].token, spender, amount), "FW350");
			sigTimeRange = IWalletModules(spender).validatePermit(token, to, amount, nonce, sig);
			permit = permitData;
		} else {
			require(getCanPayThroughApproval(token, spender, maxTokenCost) || _getHasEnoughDeposit(token, spender, maxTokenCost), "FW332");
		}
		require(userOp.verificationGasLimit > postCost, "FW323");

		uint256 gasPriceUserOp = userOp.gasPrice();
		ValidationData memory data = DataLib.parseValidationData(sigTimeRange);

		if (data.validUntil == 0 || (uint48(oracleValidUntil) < data.validUntil && oracleValidUntil != 0)) {
			data.validUntil = uint48(oracleValidUntil);
		}

		return (
			abi.encode(TokenContext(spender, sponsor, token, gasPriceUserOp, maxTokenCost, maxCost, opHash, postCost), permit),
			DataLib.getValidationData(data)
		);
	}

	function _postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) internal override {
		uint256 startingGas = gasleft();
		(TokenContext memory ctx, bytes memory permitData) = abi.decode(context, (TokenContext, bytes));
		uint256 actualTokenCost = ((actualGasCost + ctx.postCost * ctx.gasPrice) * ctx.maxTokenCost) / ctx.maxCost;

		_reimbursePaymaster(ctx.token, ctx.spender, actualTokenCost, permitData);

		dataStore[_getTokenBalanceKey(ctx.token, ctx.sponsor)] += actualTokenCost;
		dataStore[_getTokenBalanceKey(ETH, ctx.sponsor)] -= actualGasCost + ctx.postCost * ctx.gasPrice;
		accumulatedEthDust -= actualGasCost + ctx.postCost * ctx.gasPrice;

		emit PostOpGasPaid(ctx.opHash, ctx.spender, ctx.sponsor, actualTokenCost, actualGasCost + ctx.postCost * ctx.gasPrice);
		require(startingGas - gasleft() <= ctx.postCost, "FW514");
		if (mode == PostOpMode.postOpReverted) {
			emit PostOpReverted(context, actualGasCost);
			// Do nothing here to not revert the whole bundle and harm reputation - From ethInfinitism
			return;
		}
	}

	///////////////////////
	// START EXTERNAL OPS//
	///////////////////////

	// Tokens Stake

	/**
	 * @notice Allows a user to deposit ETH and assign the deposit to a sponsor.
	 * @param sponsor The address of the sponsor to assign the deposit to.
	 * @param amount The amount of ETH to deposit.
	 */
	function addEthDepositTo(address sponsor, uint256 amount) public payable {
		require(msg.value == amount, "FW333");
		require(sponsor != address(0), "FW334");
		_addEthDepositTo(msg.sender, sponsor, amount);
		emit AddEthDepositTo(msg.sender, sponsor, amount);
	}

	/**
	 * @notice Allows a user to withdraw their assigned ETH deposit to a specified target address.
	 * @param target The address to withdraw the ETH to.
	 * @param amount The amount of ETH to withdraw.
	 */
	function withdrawEthDepositTo(address payable target, uint256 amount) public payable {
		require(target != address(0), "FW335");
		_withdrawEthDepositTo(msg.sender, target, amount);
		emit WithdrawEthDepositTo(msg.sender, target, amount);
	}

	/**
	 * @notice Allows a user to deposit tokens and assign the deposit to a spender.
	 * @param token The address of the token to deposit.
	 * @param spender The address of the spender to assign the deposit to.
	 * @param amount The amount of tokens to deposit.
	 */
	function addTokenDepositTo(address token, address spender, uint256 amount) public payable {
		require(token != address(0), "FW336");
		require(spender != address(0), "FW337");
		_addTokenDepositTo(token, msg.sender, spender, amount);
		emit AddTokenDepositTo(token, msg.sender, spender, amount);
	}

	/**
	 * @notice Allows a user to withdraw their assigned tokens deposit to a specified target address.
	 * @param token The address of the token to withdraw.
	 * @param target The address to withdraw the tokens to.
	 * @param amount The amount of tokens to withdraw.
	 */
	function withdrawTokenDepositTo(address token, address target, uint256 amount) public payable {
		_withdrawTokenDepositTo(token, msg.sender, target, amount);
		emit WithdrawTokenDepositTo(token, msg.sender, target, amount);
	}

	// Access Control

	/**
	 * @notice Locks the token deposit of the caller for the specified token.
	 * @param token The address of the token to lock the deposit for
	 */
	function lockTokenDeposit(address token) public payable {
		_setUnlockBlock(token, msg.sender, 0);
		emit LockTokenDeposit(token, msg.sender);
	}

	/**
	 * @notice Unlocks the token deposit of the caller for the specified token after a specified number of blocks
	 * @param token The address of the token to unlock the deposit for
	 * @param num The number of blocks after which the deposit will be unlocked
	 */
	function unlockTokenDepositAfter(address token, uint256 num) public payable {
		_setUnlockBlock(token, msg.sender, block.number + num);
		emit UnlockTokenDepositAfter(token, msg.sender, block.number + num);
	}

	/**
	 * @notice Sets the list mode to either blacklist or whitelist
	 * @param mode Boolean value to set the list mode to blacklist (true) or whitelist (false)
	 */
	function setListMode(bool mode) public payable {
		_setListMode(msg.sender, mode);
		emit SetListMode(msg.sender, mode);
	}

	/**
	 * @notice Sets the spender blacklist mode for the specified spender
	 * @param spender The address of the spender to set the blacklist mode for
	 * @param mode Boolean value to set the spender blacklist mode to blacklist (true) or whitelist (false)
	 */
	function setSpenderBlacklistMode(address spender, bool mode) public payable {
		_setSpenderBlacklistMode(spender, msg.sender, mode);
		emit SetSpenderBlacklistMode(spender, msg.sender, mode);
	}

	/**
	 * @notice Sets the spender whitelist mode for the specified spender
	 * @param spender The address of the spender to set the whitelist mode for
	 * @param mode Boolean value to set the spender whitelist mode to whitelist (true) or blacklist (false)
	 */
	function setSpenderWhitelistMode(address spender, bool mode) public payable {
		_setSpenderWhitelistMode(spender, msg.sender, mode);
		emit SetSpenderWhitelistMode(spender, msg.sender, mode);
	}

	/**
	 * @notice Sets the list mode to either blacklist or whitelist
	 * @param mode Boolean value to set the list mode to blacklist (true) or whitelist (false)
	 */
	function setTokenListMode(bool mode) public payable {
		_setTokenListMode(msg.sender, mode);
		emit SetTokenListMode(msg.sender, mode);
	}

	/**
	 * @notice Sets the token blacklist mode for the specified token
	 * @param token The address of the token to set the blacklist mode for
	 * @param mode Boolean value to set the token blacklist mode to blacklist (true) or whitelist (false)
	 */
	function setTokenBlacklistMode(address token, bool mode) public payable {
		_setTokenBlacklistMode(token, msg.sender, mode);
		emit SetTokenBlacklistMode(token, msg.sender, mode);
	}

	/**
	 * @notice Sets the token whitelist mode for the specified token.
	 * @param token The address of the token to set the whitelist mode for
	 * @param mode Boolean value to set the token whitelist mode to whitelist (true) or blacklist (false)
	 */
	function setTokenWhitelistMode(address token, bool mode) public payable {
		_setTokenWhitelistMode(token, msg.sender, mode);
		emit SetTokenWhitelistMode(token, msg.sender, mode);
	}

	/**
	 * @notice Grants approval for the caller to use the specified tokens
	 * @param _tokens An array of token addresses to grant approval for
	 */
	function addTokens(address[] calldata _tokens) public payable {
		_setTokensApproval(_tokens, msg.sender, true);
		emit AddTokens(_tokens, msg.sender);
	}

	/**
	 * @notice Removes approval for the caller to use the specified tokens
	 * @param _tokens An array of token addresses to remove approval for
	 */
	function removeTokens(address[] calldata _tokens) public payable {
		_setTokensApproval(_tokens, msg.sender, false);
		emit RemoveTokens(_tokens, msg.sender);
	}

	// Owner Only

	/**
	 * @notice Sets the data for a token
	 * @param data A struct containing the required data for the token.
	 */
	function setTokenData(TokenData calldata data) public onlyOwner {
		address tokenAddress = address(data.token);
		require(address(data.oracle) != address(0), "FW338");
		require(tokenAddress != address(0), "FW339");
		require(data.decimals > 0, "FW340");
		require(data.aggregator != address(0), "FW341");

		if (address(tokens[tokenAddress].token) == address(0)) {
			tokenList.push(tokenAddress);
		}
		tokens[tokenAddress] = data;
		emit SetTokenData(data);
	}

	/**
	 * Remove a token from the paymaster for all sponsors.
	 * @param tokenAddress Address of the token to remove data for.
	 * @param tokenListIndex Index of tokenAddress in tokenList. This is meant to avoid having to iterate over tokenList onchain.
	 */
	function removeTokenData(address tokenAddress, uint256 tokenListIndex) public onlyOwner {
		require(address(tokens[tokenAddress].token) != address(0), "FW342");
		require(tokenList[tokenListIndex] == tokenAddress, "FW343");
		tokenList[tokenListIndex] = tokenList[tokenList.length - 1];
		tokenList.pop();
		delete tokens[tokenAddress];
		emit RemoveTokenData(tokenAddress);
	}

	// Data Getters
	/**
	 * @notice Returns the unlock block for the specified token and spender.
	 * @param token Address of the token.
	 * @param spender Address of the spender.
	 * @return unlockBlock The unlock block for the specified token and spender.
	 */
	function getUnlockBlock(address token, address spender) public view returns (uint256 unlockBlock) {
		unlockBlock = dataStore[_getUnlockBlockKey(token, spender)];
	}

	/**
	 * @notice Returns the token balance for the specified token and spender.
	 * @param token Address of the token.
	 * @param spender Address of the spender.
	 * @return tokenAmount The token balance for the specified token and spender.
	 */
	function getTokenBalance(address token, address spender) public view returns (uint256 tokenAmount) {
		tokenAmount = dataStore[_getTokenBalanceKey(token, spender)];
	}

	/**
	 * @notice Returns the unlock block and token balance for the specified token and spender.
	 * @param token Address of the token.
	 * @param spender Address of the spender.
	 * @return unlockBlock The unlock block for the specified token and spender.
	 * @return tokenAmount The token balance for the specified token and spender.
	 */
	function getAllTokenData(address token, address spender) public view returns (uint256 unlockBlock, uint256 tokenAmount) {
		unlockBlock = getUnlockBlock(token, spender);
		tokenAmount = getTokenBalance(token, spender);
	}

	/**
	 * @notice Returns the token data for the specified token.
	 * @param token Address of the token.
	 * @return The token data for the specified token.
	 */
	function getToken(address token) public view returns (TokenData memory) {
		return tokens[token];
	}

	/**
	 * @notice Returns an array of all supported tokens.
	 * @return An array of all supported tokens.
	 */
	function getAllTokens() public view returns (address[] memory) {
		return tokenList;
	}

	/**
	 * @notice Returns true if the specified sponsor has enabled token usage for the specified token.
	 * @param token Address of the token.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified sponsor has enabled token usage for the specified token.
	 */
	function getSponsorTokenUsage(address token, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getSponsorTokenKey(token, sponsor)];
	}

	/**
	 * @notice Returns true if the specified sponsor is in blacklist mode.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified sponsor is in blacklist mode.
	 */
	function getListMode(address sponsor) public view returns (bool) {
		return sponsorApprovals[_getListModeKey(sponsor)];
	}

	/**
	 * @notice Returns true if the specified spender is whitelisted for the specified sponsor.
	 * @param spender Address of the spender.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified spender is whitelisted for the specified sponsor.
	 */
	function getSpenderWhitelisted(address spender, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getSpenderWhitelistKey(spender, sponsor)];
	}

	/**
	 * @notice Returns true if the specified spender is blacklisted for the specified sponsor.
	 * @param spender Address of the spender.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified spender is blacklisted for the specified sponsor.
	 */
	function getSpenderBlacklisted(address spender, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getSpenderBlacklistKey(spender, sponsor)];
	}

	/**
	 * @notice Returns true if the specified token is in blacklist mode.
	 * @param sponsor Address of the sponsor who is changing list modes.
	 * @return True if the specified token is in blacklist mode.
	 */
	function getTokenListMode(address sponsor) public view returns (bool) {
		return sponsorApprovals[_getTokenListModeKey(sponsor)];
	}

	/**
	 * @notice Returns true if the specified token is whitelisted for the specified sponsor.
	 * @param token Address of the token.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified token is whitelisted for the specified sponsor.
	 */
	function getTokenWhitelisted(address token, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getTokenWhitelistKey(token, sponsor)];
	}

	/**
	 * @notice Returns true if the specified token is blacklisted for the specified sponsor.
	 * @param token Address of the token.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified token is blacklisted for the specified sponsor.
	 */
	function getTokenBlacklisted(address token, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getTokenBlacklistKey(token, sponsor)];
	}

	event AddEthDepositTo(address indexed caller, address indexed sponsor, uint256 amount);
	event AddTokenDepositTo(address indexed token, address indexed recipient, address indexed spender, uint256 amount);
	event AddTokens(address[] indexed tokens, address indexed sponsor);
	event BatchActions(bytes[] data);
	event LockTokenDeposit(address indexed token, address indexed spender);
	event PostOpGasPaid(bytes32 indexed opHash, address indexed spender, address indexed sponsor, uint256 spenderCost, uint256 sponsorCost);
	event PostOpReverted(bytes context, uint256 actualGasCost);
	event RemoveTokens(address[] indexed tokens, address indexed sponsor);
	event RemoveTokenData(address indexed token);
	event SetListMode(address indexed sponsor, bool mode);
	event SetSpenderBlacklistMode(address indexed spender, address indexed sponsor, bool mode);
	event SetSpenderWhitelistMode(address indexed spender, address indexed sponsor, bool mode);
	event SetTokenData(TokenData indexed data);
	event SetTokenBlacklistMode(address indexed token, address indexed sponsor, bool mode);
	event SetTokenListMode(address indexed sponsor, bool mode);
	event SetTokenWhitelistMode(address indexed token, address indexed sponsor, bool mode);
	event UnlockTokenDepositAfter(address indexed token, address indexed spender, uint256 indexed unlockBlockNum);
	event WithdrawEthDepositTo(address indexed caller, address indexed target, uint256 amount);
	event WithdrawTokenDepositTo(address indexed token, address indexed recipient, address indexed target, uint256 amount);
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

import "./HashLib.sol";
import "../interfaces/wallet/IFunWallet.sol";
import "../interfaces/wallet/IWalletFee.sol";

struct ExtraParams {
	bytes32[] targetMerkleProof;
	bytes32[] selectorMerkleProof;
	bytes32[] recipientMerkleProof;
	bytes32[] tokenMerkleProof;
}

struct ValidationData {
	address aggregator;
	uint48 validAfter;
	uint48 validUntil;
}

library DataLib {
	/**
	 * @notice Extracts authType, userId, and signature from UserOperation.signature.
	 * @param signature The UserOperation of the user.
	 * @return authType Attempted authentication method of user.
	 * @return userId Attempted identifier of user.
	 * @return roleId Attempted identifier of user role.
	 * @return ruleId Attempted identifier of user rule.
	 * @return signature Attempted signature of user.
	 * @return simulate Attempted in simulate mode.
	 */
	function getAuthData(bytes memory signature) internal pure returns (uint8, bytes32, bytes32, bytes32, bytes memory, ExtraParams memory) {
		return abi.decode(signature, (uint8, bytes32, bytes32, bytes32, bytes, ExtraParams));
	}

	/**
	 * @notice Extracts the relevant data from the callData parameter.
	 * @param callData The calldata containing the user operation details.
	 * @return to The target address of the call.
	 * @return value The value being transferred in the call.
	 * @return data The data payload of the call.
	 * @return fee The fee details of the user operation (if present).
	 * @return feeExists Boolean indicating whether a fee exists in the user operation.
	 * @dev This function decodes the callData parameter and extracts the target address, value, data, and fee (if present) based on the function selector.
	 * @dev If the function selector matches `execFromEntryPoint`, the to, value, and data are decoded.
	 * @dev If the function selector matches `execFromEntryPointWithFee`, the to, value, data, and fee are decoded, and feeExists is set to true.
	 * @dev If the function selector doesn't match any supported functions, the function reverts with an error message "FW600".
	 */
	function getCallData(
		bytes calldata callData
	) internal pure returns (address to, uint256 value, bytes memory data, UserOperationFee memory fee, bool feeExists) {
		if (bytes4(callData[:4]) == IWalletFee.execFromEntryPoint.selector) {
			(to, value, data) = abi.decode(callData[4:], (address, uint256, bytes));
		} else if (bytes4(callData[:4]) == IWalletFee.execFromEntryPointWithFee.selector) {
			(to, value, data, fee) = abi.decode(callData[4:], (address, uint256, bytes, UserOperationFee));
			feeExists = true;
		} else {
			revert("FW600");
		}
	}

	/**
	 * @notice Validates the Merkle proof provided to verify the existence of a leaf in a Merkle tree. It doesn't validate the proof length or hash the leaf.
	 * @param root The root of the Merkle tree.
	 * @param leaf The leaf which existence in the Merkle tree is being verified.
	 * @param proof An array of bytes32 that represents the Merkle proof.
	 * @return Returns true if the computed hash equals the root, i.e., the leaf exists in the tree.
	 * @dev This function assumes that the leaf passed into it has already been hashed. 
	 		This is a safe assumption as all current invocations of this function adhere to this standard. 
			Future uses of this function should ensure that the leaf input is hashed to maintain safety. Avoid calling in unsafe contexts.
			Otherwise, a user could just pass in a leaf where leaf == merkleRoot and an empty bytes array for the merkle proof to successfully validate any merkle root
	 */
	function validateMerkleRoot(bytes32 root, bytes32 leaf, bytes32[] memory proof) internal pure returns (bool) {
		bytes32 computedHash = leaf;
		for (uint256 i = 0; i < proof.length; ++i) {
			bytes32 proofElement = proof[i];
			if (computedHash < proofElement) {
				computedHash = HashLib.hash2(computedHash, proofElement);
			} else {
				computedHash = HashLib.hash2(proofElement, computedHash);
			}
		}
		return computedHash == root;
	}

	/**
	 * @notice Parses the validation data and returns a ValidationData struct.
	 * @param validationData An unsigned integer from which the validation data is extracted.
	 * @return data Returns a ValidationData struct containing the aggregator address, validAfter, and validUntil timestamps.
	 */
	function parseValidationData(uint validationData) internal pure returns (ValidationData memory data) {
		address aggregator = address(uint160(validationData));
		uint48 validUntil = uint48(validationData >> 160);
		uint48 validAfter = uint48(validationData >> (48 + 160));
		return ValidationData(aggregator, validAfter, validUntil);
	}

	/**
	 * @notice Composes a ValidationData struct into an unsigned integer.
	 * @param data A ValidationData struct containing the aggregator address, validAfter, and validUntil timestamps.
	 * @return validationData Returns an unsigned integer representation of the ValidationData struct.
	 */
	function getValidationData(ValidationData memory data) internal pure returns (uint256 validationData) {
		return uint160(data.aggregator) | (uint256(data.validUntil) << 160) | (uint256(data.validAfter) << (160 + 48));
	}
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

library HashLib {
	/**
	 * Keccak256 all parameters together
	 * @param a bytes32
	 */
	function hash1(bytes32 a) internal pure returns (bytes32 _hash) {
		assembly {
			mstore(0x0, a)
			_hash := keccak256(0x00, 0x20)
		}
	}

	function hash1(address a) internal pure returns (bytes32 _hash) {
		assembly {
			mstore(0x0, a)
			_hash := keccak256(0x00, 0x20)
		}
	}

	function hash2(bytes32 a, bytes32 b) internal pure returns (bytes32 _hash) {
		assembly {
			mstore(0x0, a)
			mstore(0x20, b)
			_hash := keccak256(0x00, 0x40)
		}
	}

	function hash2(bytes32 a, address b) internal pure returns (bytes32 _hash) {
		bytes20 _b = bytes20(b);
		assembly {
			mstore(0x0, a)
			mstore(0x20, _b)
			_hash := keccak256(0x00, 0x34)
		}
	}

	function hash2(address a, address b) internal pure returns (bytes32 _hash) {
		bytes20 _a = bytes20(a);
		bytes20 _b = bytes20(b);
		assembly {
			mstore(0x0, _a)
			mstore(0x14, _b)
			_hash := keccak256(0x00, 0x28)
		}
	}

	function hash2(address a, uint8 b) internal pure returns (bytes32 _hash) {
		bytes20 _a = bytes20(a);
		bytes1 _b = bytes1(b);

		assembly {
			mstore(0x0, _b)
			mstore(0x1, _a)
			_hash := keccak256(0x00, 0x15)
		}
	}

	function hash2(bytes32 a, uint8 b) internal pure returns (bytes32 _hash) {
		bytes1 _b = bytes1(b);
		assembly {
			mstore(0x0, _b)
			mstore(0x1, a)
			_hash := keccak256(0x00, 0x21)
		}
	}

	function hash3(address a, address b, uint8 c) internal pure returns (bytes32 _hash) {
		bytes20 _a = bytes20(a);
		bytes20 _b = bytes20(b);
		bytes1 _c = bytes1(c);
		assembly {
			mstore(0x00, _c)
			mstore(0x01, _a)
			mstore(0x15, _b)
			_hash := keccak256(0x00, 0x29)
		}
	}
}
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract Ownable2StepNoRenounce is Ownable2Step {
	function renounceOwnership() public override onlyOwner {
		revert("FW601");
	}
}