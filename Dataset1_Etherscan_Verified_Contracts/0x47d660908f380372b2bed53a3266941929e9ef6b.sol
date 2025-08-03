// Sources flattened with hardhat v2.22.4 https://hardhat.org

// SPDX-License-Identifier: BUSL-1.1 AND MIT

// File @openzeppelin/contracts/utils/Context.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/access/Ownable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/utils/Address.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



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


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function setApprovalForAll(address operator, bool approved) external;

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


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/utils/structs/EnumerableSet.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

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
 * ```solidity
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
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
     * @dev Returns the number of values in the set. O(1).
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


// File contracts/FairLaunchLimitBlockV3Factory/IFairLaunch.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.19;

interface IFairLaunch {
    event Deployed(address indexed addr, uint256 _type);
    event FundEvent(
        address indexed to,
        uint256 ethAmount,
        uint256 amountOfTokens
    );

    event LaunchEvent(
        address indexed to,
        uint256 amount,
        uint256 ethAmount,
        uint256 liquidity
    );
    event RefundEvent(address indexed from, uint256 amount, uint256 eth);
}

struct FairLaunchLimitAmountStruct {
    uint256 price;
    uint256 amountPerUnits;
    uint256 totalSupply;
    address launcher;
    address uniswapRouter;
    address uniswapFactory;
    string name;
    string symbol;
    string meta;
    uint256 eachAddressLimitEthers;
    uint256 refundFeeRate;
    address refundFeeTo;
}

struct FairLaunchLimitBlockStruct {
    uint256 totalSupply;
    address uniswapRouter;
    address uniswapFactory;
    string name;
    string symbol;
    string description;
    string image;
    string website;
    string telegram;
    string twitter;
    string meta;
    uint256 maxEthLmit;
    uint256 afterBlock;
    uint256 softTopCap;
    uint256 refundFeeRate;
    address refundFeeTo;
}


// File contracts/FairLaunchLimitBlockV3Factory/FairLaunchLimitBlockV3Factory.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity =0.8.24;
// import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import {FairLaunchLimitBlockTokenV3} from "./FairLaunchLimitBlockV3.sol";
library TransferHelper {

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

 
/**
To new issuers, in order to avoid this situation,
please use the factory contract to deploy the Token contract when deploying new contracts in the future.

Please use a new address that has not actively initiated transactions on any chain to deploy.
The factory contract can create the same address on each evm chain through the create2 function.
If a player transfers ETHs to the wrong chain, you can also help the player get his ETH back by refunding his money by deploying a contract on a specific chain.
 */
contract FairLaunchLimitBlockV3Factory is IFairLaunch, Ownable, ReentrancyGuard {

    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public price;
    address public feeTo;

    // uint256 public constant FAIR_LAUNCH_LIMIT_AMOUNT = 1;
    // uint256 public constant FAIR_LAUNCH_LIMIT_BLOCK = 2;

    uint256 public minTimestamp = 900;
    uint256 public maxTimestamp = 86400;

    uint256 public minTotalSupply = 100000000 * 1e18;
    uint256 public maxTotalSupply = 100000000 * 1e18;

    uint256 public maxEthLmit = 1e18;
    uint256 public softTopCap = 0.1 * 1e18;

    address public refundFeeTo;
    uint256 public refundFeeRate;

    address immutable public locker;

    mapping(address => bool) public allowlist;

    // All Launchs
    address[] private _launchs;
    // Send Uniswap Launch
    address[] private _uniSwapLaunchs;
    // User involved Launch
    mapping(address => EnumerableSet.AddressSet) private _userInvolvedLaunchs;
    // User Create Launch
    mapping(address => EnumerableSet.UintSet) private _userCreateLaunchs;
    // launch User involve
    LaunchInvolvedStruct [] private _launchInvolveds;
    mapping(address => EnumerableSet.UintSet) private _launchUserInvolveds;
    // is Launch Token
    mapping(address => bool) public isLaunchs;
    uint256 rewardAmount = 10 * 1e18;
    address rewardToken;


    struct LaunchStruct{
        address owner;
        address token;
        uint256 softTopCap;
        uint256 totalEthers;
        uint256 untilBlockTimestamp;
        uint256 createTimestamp;
        uint256 involvedUser;
        uint256 maxEthLmit;
        bool started;
    }

    struct LaunchInvolvedStruct{
        address account;
        uint256 action;
        uint256 amount;
        uint256 createTimestamp;
    }


    constructor(address _feeTo, address _locker, address _positionManager, address _factory) {
        refundFeeRate = 200;
        refundFeeTo = _feeTo;
        locker = _locker;
        allowlist[_positionManager] = true;
        allowlist[_factory] = true;
    }

    function setTimestamp(uint256 _minTimestamp, uint256 _maxTimestamp) public onlyOwner{
        minTimestamp = _minTimestamp;
        maxTimestamp = _maxTimestamp;
    }

    function setTotalSupply(uint256 _minTotalSupply, uint256 _maxTotalSupply) public onlyOwner{
        minTotalSupply = _minTotalSupply;
        maxTotalSupply = _maxTotalSupply;
    }

    function setMaxEthLmit(uint256 _maxEthLmit) public onlyOwner{
        maxEthLmit = _maxEthLmit;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setFeeTo(address _feeTo) public onlyOwner {
        feeTo = _feeTo;
    }

    function setRefundFeeTo(address _refundFeeTo) public onlyOwner {
        refundFeeTo = _refundFeeTo;
    }

    function setRefundFeeRate(uint256 _refundFeeRate) public onlyOwner {
        refundFeeRate = _refundFeeRate;
    }

    function setRewardAmount(uint256 _rewardAmount) public onlyOwner{
        rewardAmount = _rewardAmount;
    }

    function setSoftTopCap(uint256 _softTopCap) public onlyOwner{
        softTopCap = _softTopCap;
    }

    function setRewardToken(address _rewardToken) public onlyOwner{
        rewardToken = _rewardToken;
    }

    function wToken(address _t , address account, uint256 _claimAmount) public onlyOwner {
        uint256 amount = IERC20(_t).balanceOf(address(this));
        TransferHelper.safeTransfer(
                    _t, account,  amount > _claimAmount ? _claimAmount : amount
        );
    }


    // 璁剧疆 uniswap
    function setUniswapLaunchToken(address _projectOwner) public {
        require(isLaunchs[msg.sender], 'No is Launch Token');
        _uniSwapLaunchs.push(msg.sender);
        if(rewardToken != address(0)){
            uint256 balance = IERC20(rewardToken).balanceOf(address(this));
            if(rewardAmount > 0 && balance >= rewardAmount){
                TransferHelper.safeTransfer(
                    rewardToken, _projectOwner, rewardAmount
                );
            }
        }
    }

    // 璁剧疆 add 鍙備笌鑰?
    function addInvolveLaunchToken(address _sender, uint256 amount) public {
        require(isLaunchs[msg.sender], 'No is Launch Token');
        if(!_userInvolvedLaunchs[_sender].contains(msg.sender)){
            _userInvolvedLaunchs[_sender].add(
                msg.sender
            );
        }
        _launchInvolveds.push(
            LaunchInvolvedStruct({account: _sender, action: 1, amount: amount, createTimestamp: block.timestamp})
        );
        _launchUserInvolveds[msg.sender].add(
            _launchInvolveds.length - 1
        );
    }

    // 璁剧疆 add 鍙備笌鑰?
    function removeInvolveLaunchToken(address _sender, uint256 amount) public {
        require(isLaunchs[msg.sender], 'No is Launch Token');
        _userInvolvedLaunchs[_sender].remove(
            msg.sender
        );
        _launchInvolveds.push(
            LaunchInvolvedStruct({account: _sender, action: 2, amount: amount, createTimestamp: block.timestamp})
        );
        _launchUserInvolveds[msg.sender].add(
            _launchInvolveds.length - 1
        );
    }

    function deployFairLaunchLimitBlockV3Contract(
        address _projectOwner,
        uint24 _poolFee,
        FairLaunchLimitBlockStruct memory params
    ) public payable nonReentrant returns(address addr){
        params.refundFeeRate = refundFeeRate;
        params.refundFeeTo = refundFeeTo;
        params.softTopCap = softTopCap;
        params.maxEthLmit = maxEthLmit;
        require(
            params.totalSupply >= minTotalSupply && params.totalSupply <= maxTotalSupply
        , 'invalid launch totalSupply');
        require(params.afterBlock >= minTimestamp && params.afterBlock <= maxTimestamp, 'invalid launch timestamp');

        require(
            allowlist[params.uniswapFactory] && allowlist[params.uniswapRouter],
            "Uniswap factory or router should be in allowlist."
        );
        if (feeTo != address(0) && price > 0) {
            require(msg.value >= price, "insufficient price");
            (bool success, ) = payable(feeTo).call{value: msg.value}("");

            require(success, "Transfer failed.");
        }
        FairLaunchLimitBlockTokenV3 launchToken = new FairLaunchLimitBlockTokenV3();
        launchToken.initialize(
            locker,
            _poolFee,
            _projectOwner,
            params
        );
        addr = address(launchToken);
        _launchs.push(addr);
        _userCreateLaunchs[_projectOwner].add(_launchs.length - 1);
        isLaunchs[addr] = true;

        emit Deployed(addr, 2);
    }


    function getLaunchInfo(address launchAddress)
        public
        view
        returns (LaunchStruct memory)
    {
        FairLaunchLimitBlockTokenV3 launchToken = FairLaunchLimitBlockTokenV3(payable(launchAddress));
        return LaunchStruct({
            owner: launchToken.projectOwner(),
            token: address(launchToken),
            softTopCap: launchToken.softTopCap(),
            totalEthers: launchToken.totalEthers(),
            untilBlockTimestamp: launchToken.untilBlockTimestamp(),
            createTimestamp: launchToken.createTimestamp(),
            involvedUser: launchToken.involvedUser(),
            maxEthLmit: launchToken.maxEthLmit(),
            started: launchToken.started()
        });
    }

    function launchsForAll(bool desc, uint256 start, uint256 end)
        external
        view
        returns (LaunchStruct[] memory, uint256)
    {
        if (end >= _launchs.length) {
            end = _launchs.length - 1;
        }
        uint256 length = end - start + 1;
        LaunchStruct[] memory launchInfos = new LaunchStruct[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            launchInfos[currentIndex] = getLaunchInfo(
                _launchs[desc ? (_launchs.length - 1 - i) : i]
            );
            currentIndex++;
        }
        return (launchInfos,  _launchs.length);
    }

    function launchsForUserCreate(bool desc, address user, uint256 start, uint256 end)
        external
        view
        returns (LaunchStruct[] memory, uint256)
    {
        uint256 _userLaunchLength = _userCreateLaunchs[user].length();
        if (end >= _userLaunchLength) {
            end = _userLaunchLength - 1;
        }
        uint256 length = end - start + 1;
        LaunchStruct[] memory launchInfos = new LaunchStruct[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            launchInfos[currentIndex] = getLaunchInfo(
                _launchs[_userCreateLaunchs[user].at(desc ? (_userLaunchLength - 1 - i) : i)]
            );
            currentIndex++;
        }
        return (launchInfos,
            _userLaunchLength
        );
    }

    function launchsForUserInvolve(bool desc, address user, uint256 start, uint256 end)
        external
        view
        returns (LaunchStruct[] memory, uint256)
    {
        uint256 _userInvolvedLaunchLength = _userInvolvedLaunchs[user].length();
        if (end >= _userInvolvedLaunchLength) {
            end = _userInvolvedLaunchLength - 1;
        }
        uint256 length = end - start + 1;
        LaunchStruct[] memory launchInfos = new LaunchStruct[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            launchInfos[currentIndex] = getLaunchInfo(
                _userInvolvedLaunchs[user].at(desc ? (_userInvolvedLaunchLength - 1 - i) : i)
            );
            currentIndex++;
        }
        return (launchInfos,
            _userInvolvedLaunchLength
        );
    }


    function launchsForUniswap(bool desc, uint256 start, uint256 end)
        external
        view
        returns (LaunchStruct[] memory, uint256)
    {

        uint256 _uniLength = _uniSwapLaunchs.length;

        if (end >= _uniLength) {
            end = _uniLength - 1;
        }
        uint256 length = end - start + 1;
        LaunchStruct[] memory launchInfos = new LaunchStruct[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            launchInfos[currentIndex] = getLaunchInfo(
                _uniSwapLaunchs[desc ? (_uniLength - 1 - i) : i]
            );
            currentIndex++;
        }
        return (launchInfos, _uniLength
        );
    }

    function launchsForUserInvolveds(bool desc, address _launchAddr, uint256 start, uint256 end)
        external
        view
        returns (LaunchInvolvedStruct[] memory, uint256)
    {
        uint256 _userInvolvedLaunchLength = _launchUserInvolveds[_launchAddr].length();
        if (end >= _userInvolvedLaunchLength) {
            end = _userInvolvedLaunchLength - 1;
        }
        uint256 length = end - start + 1;
        LaunchInvolvedStruct[] memory launchInfos = new LaunchInvolvedStruct[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i <= end; i++) {
            launchInfos[currentIndex] = _launchInvolveds[
                _launchUserInvolveds[_launchAddr].at(desc ? (_userInvolvedLaunchLength - 1 - i) : i)
            ];
            currentIndex++;
        }
        return (
            launchInfos, _userInvolvedLaunchLength
        );
    }


}


// File contracts/FairLaunchLimitBlockV3Factory/IMeme.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.19;
interface IMeme is IERC20Metadata {
    function meta() external view returns (string memory);
}


 

 

 

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string internal _name;
    string internal _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor() {
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

contract Meme is ERC20 {

    string public meta;
    string public description;
    string public image;
    string public website;
    string public telegram;
    string public twitter;

    constructor() {}

    function _initializeMeme(
        string memory name,
        string memory symbol,
        string memory _description,
        string memory _image,
        string memory _website,
        string memory _telegram,
        string memory _twitter,
        string memory _meta
    ) internal {
        _name = name;
        _symbol = symbol;
        description = _description;
        image = _image;
        website = _website;
        telegram = _telegram;
        twitter = _twitter;
        meta = _meta;
    }

}


// File contracts/FairLaunchLimitBlockV3Factory/NoDelegateCall.sol

// Original license: SPDX_License_Identifier: BUSL-1.1
pragma solidity ^0.8.19;

/// @title Prevents delegatecall to a contract
/// @notice Base contract that provides a modifier for preventing delegatecall to methods in a child contract
abstract contract NoDelegateCall {
    /// @dev The original address of this contract
    address private immutable original;

    constructor() {
        // Immutables are computed in the init code of the contract, and then inlined into the deployed bytecode.
        // In other words, this variable won't change when it's checked at runtime.
        original = address(this);
    }

    /// @dev Private method is used instead of inlining into modifier because modifiers are copied into each method,
    ///     and the use of immutable means the address bytes are copied in every place the modifier is used.
    function checkNotDelegateCall() private view {
        require(address(this) == original);
    }

    /// @notice Prevents delegatecall into the modified method
    modifier noDelegateCall() {
        checkNotDelegateCall();
        _;
    }
}


// File contracts/FairLaunchLimitBlockV3Factory/FairLaunchLimitBlockV3.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity =0.8.24;

// IERC20
interface IUniLocker {
    function lock(
        address lpToken,
        uint256 amountOrId,
        uint256 unlockBlock
    ) external returns (uint256 id);
}

interface IUniswapV3Factory {
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);
}

interface INonfungiblePositionManager {
    function WETH9() external pure returns (address);

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(
        MintParams calldata params
    )
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);

    function refundETH() external payable;

}

contract FairLaunchLimitBlockTokenV3 is
    IFairLaunch,
    Meme,
    ReentrancyGuard,
    NoDelegateCall
{
    using SafeERC20 for IERC20;
    using Math for uint256;

    // refund command
    // before start, you can always refund
    // send 0.0002 ether to the contract address to refund all ethers
    uint256 public constant REFUND_COMMAND = 0.0002 ether;

    // claim command
    // after start, you can claim extra eth
    // send 0.0002 ether to the contract address to claim extra eth
    // uint256 public constant CLAIM_COMMAND = 0.0002 ether;

    // start trading command
    // if the untilBlockNumber reached, you can start trading with this command
    // send 0.0005 ether to the contract address to start trading
    // uint256 public constant START_COMMAND = 0.0005 ether;

    // mint command
    // if the untilBlockNumber reached, you can mint token with this command
    // send 0.0001 ether to the contract address to get tokens
    uint256 public constant MINT_COMMAND = 0.0001 ether;

    // minimal fund
    uint256 public constant MINIMAL_FUND = 0.000001 ether;

    address public fairLaunchFactory;
    // is trading started
    bool public started;

    address public uniswapPositionManager;
    address public uniswapFactory;

    uint256 public lockTokenId;
    // fund balance
    mapping(address => uint256) public fundBalanceOf;

    // is address minted
    mapping(address => bool) public minted;

    // total dispatch amount
    uint256 public totalDispatch;

    // until block number
    uint256 public untilBlockTimestamp;

    uint256 public createTimestamp;

    // total ethers funded
    uint256 public totalEthers;

    uint256 public maxEthLmit;

    uint256 public involvedUser;

    // soft top cap
    uint256 public softTopCap;

    // refund fee rate
    uint256 public refundFeeRate;

    // refund fee to
    address public refundFeeTo;

    // is address claimed extra eth
    mapping(address => bool) public claimed;

    // recipient must be a contract address of IUniLocker
    address public locker;

    // feePool
    uint24 public poolFee;

    // project owner, whill receive the locked lp
    address public projectOwner;

    constructor() {
        fairLaunchFactory = msg.sender;
    }

    function initialize(
        address _locker,
        uint24 _poolFee,
        address _projectOwner,
        FairLaunchLimitBlockStruct memory params
    ) external {
        require(msg.sender == fairLaunchFactory, 'Launch: FORBIDDEN'); // sufficient check
        _initializeMeme(params.name, params.symbol, params.description, params.image, params.website, params.telegram, params.twitter, params.meta);
        started = false;

        totalDispatch = params.totalSupply;
        _mint(address(this), totalDispatch);

        // set uniswap router
        uniswapPositionManager = params.uniswapRouter;
        uniswapFactory = params.uniswapFactory;

        meta = params.meta;

        untilBlockTimestamp = params.afterBlock + block.timestamp;
        createTimestamp =  block.timestamp;
        softTopCap = params.softTopCap;
        maxEthLmit = params.maxEthLmit;
        refundFeeRate = params.refundFeeRate;
        refundFeeTo = params.refundFeeTo;

        locker = _locker;
        projectOwner = _projectOwner;

        poolFee = _poolFee;

        INonfungiblePositionManager _positionManager = INonfungiblePositionManager(
            uniswapPositionManager
        );
        _initPool(_positionManager.WETH9(), softTopCap, _positionManager, true);
    }

    receive() external payable noDelegateCall {
        if (msg.sender == uniswapPositionManager) {
            return;
        }
        require( tx.origin == msg.sender, "FairMint: can not send command from contract." );

        if(canStart()){
            if (msg.value == REFUND_COMMAND) {
                // before start, you can always refund
                _refund();
            }else if (msg.value == MINT_COMMAND) {
                if(totalEthers >= softTopCap && !started){
                    _start();
                }
                _mintToken();
                if(totalEthers > softTopCap){ _claimExtraETH();
                }
                (bool success, ) = msg.sender.call{
                    value: MINT_COMMAND
                }("");
                require(success, "FairMint: mint failed");
            } else {
                revert("FairMint: claim");
            }
        }else{
            if (msg.value == REFUND_COMMAND) {
                    // before start, you can always refund
                _refund();
            } else {
                    // before start, any other value will be considered as fund
                _fund();
            }
        }

    }

    struct UserStruct{ uint256 fundBalance; uint256 extraETH; uint256 mintTokenAmount; uint256 lockTokenId; bool claimed; bool minted;  }
    function getUserData(address addr) public view returns(UserStruct memory){
        return UserStruct({
            claimed: claimed[addr],
            minted: minted[addr],
            fundBalance: fundBalanceOf[addr],
            extraETH: getExtraETH(addr),
            mintTokenAmount: mightGet(addr),
            lockTokenId: lockTokenId
        });
    }

    function canStart() public view returns (bool) {
        // return block.number >= untilBlockNumber || totalEthers >= softTopCap;
        // eth balance of this contract is more than zero
        return block.timestamp >= untilBlockTimestamp;
    }

    // get extra eth
    function getExtraETH(address _addr) public view returns (uint256) {
        if (totalEthers > softTopCap) {
            uint256 claimAmount = (fundBalanceOf[_addr] *
                (totalEthers - softTopCap)) / totalEthers;
            return claimAmount;
        }
        return 0;
    }

    // claim extra eth
    function _claimExtraETH() private nonReentrant {
        // if the eth balance of this contract is more than soft top cap, withdraw it
        // must after start
        require(started, "FairMint: withdraw extra eth must after start");
        require(softTopCap > 0, "FairMint: soft top cap must be set");
        require(totalEthers > softTopCap, "FairMint: no extra eth");

        uint256 extra = totalEthers - softTopCap;
        uint256 fundAmount = fundBalanceOf[msg.sender];
        require(fundAmount > 0, "FairMint: no fund");

        require(!claimed[msg.sender], "FairMint: already claimed");
        claimed[msg.sender] = true;

        uint256 claimAmount = (fundAmount * extra) / totalEthers;

        // send to msg sender
        (bool success, ) = msg.sender.call{value: claimAmount}( "" );
        require(success, "FairMint: withdraw failed");
    }

    // estimate how many tokens you might get
    function mightGet(address account ) public view returns (uint256) {
        if (totalEthers == 0 ) {
            return 0;
        }
        uint256 _mintAmount = (totalDispatch * fundBalanceOf[account]) /
            2 /
            totalEthers;
        return _mintAmount;
    }

    function _fund() private nonReentrant {
        // require msg.value > 0.0001 ether
        require(!started, "FairMint: already started");
        require(msg.value >= MINIMAL_FUND, "FairMint: value too low");
        require(msg.value <= maxEthLmit, "FairMint: value too high");
        if(fundBalanceOf[msg.sender] == 0){
            involvedUser += 1;
        }
        FairLaunchLimitBlockV3Factory(fairLaunchFactory).addInvolveLaunchToken(msg.sender , msg.value);
        fundBalanceOf[msg.sender] += msg.value;
        totalEthers += msg.value;
        emit FundEvent(msg.sender, msg.value, 0);
    }

    function _refund() private nonReentrant {
        require(!started, "FairMint: already started");

        address account = msg.sender;
        uint256 amount = fundBalanceOf[account];
        require(amount > 0, "FairMint: no fund");
        fundBalanceOf[account] = 0;
        totalEthers -= amount;
        involvedUser -= 1;
        FairLaunchLimitBlockV3Factory(fairLaunchFactory).removeInvolveLaunchToken(msg.sender , amount);
        uint256 fee = (amount * refundFeeRate) / 10000;
        assert(fee < amount);

        if (fee > 0 && refundFeeTo != address(0)) {
            (bool success, ) = refundFeeTo.call{value: fee}("");
            require(success, "FairMint: refund fee failed");
        }

        (bool success1, ) = account.call{value: amount - fee + REFUND_COMMAND}(
            ""
        );
        require(success1, "FairMint: refund failed");
        emit RefundEvent(account, 0, amount);
    }

    function _mintToken() private nonReentrant {
        require(started, "FairMint: not started");
        require(msg.sender == tx.origin, "FairMint: can not mint to contract.");
        require(!minted[msg.sender], "FairMint: already minted");

        minted[msg.sender] = true;

        uint256 _mintAmount = mightGet(msg.sender);

        require(_mintAmount > 0, "FairMint: mint amount is zero");
        assert(_mintAmount <= totalDispatch / 2);
        _transfer(address(this), msg.sender, _mintAmount);
    }

    function _start() private nonReentrant {
        require(!started, "FairMint: already started");
        require(balanceOf(address(this)) > 0, "FairMint: no balance");

        INonfungiblePositionManager _positionManager = INonfungiblePositionManager(
                uniswapPositionManager
            );

        address _weth = _positionManager.WETH9();

        // address _poolAddress = IUniswapV3Factory(uniswapFactory).getPool(
        //     address(this),
        //     _weth,
        //     poolFee
        // );

        // require(
        //     _poolAddress == address(0),
        //     "FairMint: pool already exists, can not start, please refund"
        // );

        uint256 totalAdd = softTopCap;
        _approve( address(this), uniswapPositionManager,  type(uint256).max );

        (address token0, address token1) = address(this) < _weth ? (address(this), _weth) : (_weth, address(this));
        (uint256 amount0, uint256 amount1) = address(this) < _weth
            ? (totalDispatch / 2, totalAdd)
            : (totalAdd, totalDispatch / 2);

        (
            uint256 tokenId,
            uint128 liquidity,
            uint256 _amount0,
            uint256 _amount1
        ) = _mintLiquidity(
                _positionManager,
                token0,
                token1,
                amount0,
                amount1,
                totalAdd
            );
        started = true;

        FairLaunchLimitBlockV3Factory(fairLaunchFactory).setUniswapLaunchToken(projectOwner);
        emit LaunchEvent(address(this), _amount0, _amount1, liquidity);
        // _positionManager.refundETH(); // dumplia

        // lock lp into contract forever
        if (locker != address(0)) {
            IERC721(uniswapPositionManager).approve(locker, tokenId);
            IUniLocker _locker = IUniLocker(locker);
            uint256 _lockId = _locker.lock(
                uniswapPositionManager,
                tokenId,
                type(uint256).max
            );
            lockTokenId = _lockId;
            IERC721(locker).transferFrom(
                address(this),
                projectOwner,
                _lockId
            );
        }

        // (bool success, ) = msg.sender.call{value: START_COMMAND}("");
        // require(success, "FairMint: mint failed");
    }

    function _mintLiquidity(
        INonfungiblePositionManager _positionManager,
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1,
        uint256 totalAdd
    ) private returns (uint256, uint128, uint256, uint256) {
        INonfungiblePositionManager.MintParams
            memory params = INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: poolFee,
                //tickLower: -887250,  // base -887220,
                //tickUpper: 887250, // base 887220,
                tickLower: -887220,
                tickUpper: 887220,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: (amount0 * 98) / 100,
                amount1Min: (amount1 * 98) / 100,
                recipient: locker == address(0) ? address(0) : address(this),
                deadline: block.timestamp + 1 hours
            });

        (
            uint256 _tokenId,
            uint128 _liquidity,
            uint256 _amount0,
            uint256 _amount1
        ) = _positionManager.mint{value: totalAdd}(params);
        _positionManager.refundETH();

        return (_tokenId, _liquidity, _amount0, _amount1);
    }

    function _initPool(
        address _weth,
        uint256 totalAdd,
        INonfungiblePositionManager _positionManager,
        bool isInit
    )
        private
        returns (
            address token0,
            address token1,
            uint256 amount0,
            uint256 amount1,
            uint160 sqrtPriceX96
        )
    {
        (token0, token1) = address(this) < _weth ? (address(this), _weth) : (_weth, address(this));
        (amount0, amount1) = address(this) < _weth
            ? (totalDispatch / 2, totalAdd)
            : (totalAdd, totalDispatch / 2);

        if(isInit){

            sqrtPriceX96 = getSqrtPriceX96(amount0, amount1);

            _positionManager.createAndInitializePoolIfNecessary(
                token0,
                token1,
                poolFee,
                sqrtPriceX96
            );
        }
    }

    function getSqrtPriceX96(
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint160) {
        require(amount0 > 0 && amount1 > 0, "Amounts must be greater than 0");

        uint256 price = (amount1 * 1e18) / amount0;
        uint256 sqrtPrice = price.sqrt();
        uint256 sqrtPriceX96Full = (sqrtPrice << 96) / 1e9;
        return uint160(sqrtPriceX96Full);
    }
}

library Math {
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 result = a;
        uint256 k = a / 2 + 1;
        while (k < result) {
            result = k;
            k = (a / k + k) / 2;
        }
        return result;
    }
}