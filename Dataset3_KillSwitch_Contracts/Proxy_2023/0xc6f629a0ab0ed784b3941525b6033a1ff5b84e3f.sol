// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

// File: @openzeppelin/contracts/utils/Pausable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

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
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

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
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// File: @chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol

pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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

// File: @openzeppelin/contracts/interfaces/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.20;

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

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

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

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
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata
    ) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(
        address spender,
        uint256 currentAllowance,
        uint256 requestedDecrease
    );

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeCall(token.transferFrom, (from, to, value))
        );
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 requestedDecrease
    ) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(
                    spender,
                    currentAllowance,
                    requestedDecrease
                );
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        bytes memory approvalCall = abi.encodeCall(
            token.approve,
            (spender, value)
        );

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(
                token,
                abi.encodeCall(token.approve, (spender, 0))
            );
            _callOptionalReturn(token, approvalCall);
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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(
        IERC20 token,
        bytes memory data
    ) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success &&
            (returndata.length == 0 || abi.decode(returndata, (bool))) &&
            address(token).code.length > 0;
    }
}

// File: @openzeppelin/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
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
     */
    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
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
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
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
    function sqrt(
        uint256 a,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return
                result +
                (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
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
    function log2(
        uint256 value,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return
                result +
                (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
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
    function log10(
        uint256 value,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return
                result +
                (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
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
    function log256(
        uint256 value,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return
                result +
                (
                    unsignedRoundsUp(rounding) && 1 << (result << 3) < value
                        ? 1
                        : 0
                );
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// File: contracts/MineAIETH.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

struct UserInfo {
    uint256 stackedAmount;
    uint256 referralCommissionClaimed;
    uint256 referralCount;
    uint256 referralCommission;
    bool enable;
}

struct VestingSchedule {
    uint256 tgePercentage;
    uint256 releaseInterval; // in seconds
    uint256 releasePercentage;
    bool initialized;
}

struct Beneficiary {
    uint256 amount;
    uint256 released;
    uint256 vestingType;
    uint256 startTime;
    bool tgeClaimed;
}

contract MineAIETH is Pausable, Ownable {
    using SafeERC20 for IERC20Metadata;
    uint256 private _priceInUSD;
    address[] private _supportedTokensList;
    address private _treasaryWallet;

    uint256 private _totalTokensSold;
    uint256 private _totalETHCollected;
    uint256 private _totalUSDCollected;
    uint256 private _totalReferral;
    uint256 private _totalBonus;

    uint256 private _minContributionInUSD;

    bool private _isTransacting;

    address private _priceOracleAddressNative;
    address private _presaleTokenContract;

    mapping(address => bool) private _mappingSupportedTokens;
    mapping(address => UserInfo) public _mappingUserInfo;

    uint256 public referralCount;
    uint256 public userCount;

    mapping(uint256 => address) public _mappingReferralIndex;
    mapping(uint256 => address) public _mappingUserIndex;

    uint256 vestingScheduleCount;

    uint256 currentRound;

    uint public referralPercentage;

    mapping(uint256 => VestingSchedule) public vestingSchedules;
    mapping(address => Beneficiary[]) public beneficiaries;

    event TokensReleased(address beneficiary, uint256 amount);

    event SupportedTokenAdded(address tokenContract);
    event SupportedTokenRemoved(address tokenContract);

    event ReferralPercentageUpdated(uint256 referralPercentage);

    event VestingScheduleAdded(
        uint256 vestingScheduleCount,
        uint256 tgePercentage,
        uint256 releaseInterval,
        uint256 releasePercentage
    );

    event TGETimeSet(uint256 tgeTime);

    event BeneficiaryAdded(
        address beneficiary,
        uint256 amount,
        uint256 vestingType,
        uint256 startTime
    );

    event ReferralCommissionEarned(
        address referralAddress,
        uint256 referralCommission
    );

    event ReferralCommissionClaimed(
        address referralAddress,
        uint256 referralCommissionClaimed
    );

    uint256 tgeTime;

    struct StakeInfo {
        uint256 amount; // Staked amount by the user
        uint256 timestamp; // Timestamp of when the user staked
    }

    mapping(address => StakeInfo) public stakes; // Mapping to store each user's stake info
    address[] public stakers; // Array to keep track of all stakers

    constructor(
        uint256 priceInUSD_,
        address treasaryWallet_,
        address nativePriceOracle_
    ) Ownable(msg.sender) {
        _priceInUSD = priceInUSD_;
        _treasaryWallet = treasaryWallet_;
        _minContributionInUSD = 1 * 1 ether;
        _priceOracleAddressNative = nativePriceOracle_;

        _addVestingSchedule(10, 1 days, 1);
        _addVestingSchedule(20, 1 days, 2);

        currentRound = 1;
        referralPercentage = 5;
    }

    receive() external payable {}

    event BuyWithNative(
        address userAddress,
        uint256 valueInWei,
        uint256 tokenSold,
        uint256 priceInUSD,
        uint256 bonus
    );
    event BuyWithToken(
        address userAddress,
        address tokenContract,
        uint256 valueInWei,
        uint256 tokenSold,
        uint256 priceInUSD,
        uint256 bonus
    );

    modifier noReetency() {
        require(!_isTransacting, "Transaction in progress");
        _isTransacting = true;
        _;
        _isTransacting = false;
    }

    function getPresaleAnalytics()
        external
        view
        returns (
            uint256 totalTokensSold,
            uint256 totalETHCollected,
            uint256 totalUSDValue,
            uint256 totalReferralAmount,
            uint256 totalBonus
        )
    {
        totalTokensSold = _totalTokensSold;
        totalETHCollected = _totalETHCollected;
        totalUSDValue = _totalUSDCollected;
        totalReferralAmount = _totalReferral;
        totalBonus = _totalBonus;
    }

    function getUserInfo(address user) external view returns (UserInfo memory) {
        return _mappingUserInfo[user];
    }

    function getPresaleTokenContract() external view returns (address) {
        return _presaleTokenContract;
    }

    function setPresaleTokenContract(
        address _contractAddress
    ) external onlyOwner {
        _presaleTokenContract = _contractAddress;
    }

    function getPriceOracleNative() external view returns (address) {
        return _priceOracleAddressNative;
    }

    function setPriceOracleNative(address _contractAddress) external onlyOwner {
        _priceOracleAddressNative = _contractAddress;
    }

    function getMinContributionUSD() external view returns (uint256) {
        return _minContributionInUSD;
    }

    function setMinContributionUSD(uint256 _valueInWei) external onlyOwner {
        _minContributionInUSD = _valueInWei;
    }

    function getPresalePricePerUSD() external view returns (uint256) {
        return _priceInUSD;
    }

    function setPricePerUSD(uint256 priceInUSD_) external onlyOwner {
        _priceInUSD = priceInUSD_;
    }

    function getTreasaryWallet() external view returns (address) {
        return _treasaryWallet;
    }

    function setTreasaryWallet(address treasaryWallet_) external onlyOwner {
        _treasaryWallet = treasaryWallet_;
    }

    function getSupportedTokensList()
        external
        view
        returns (address[] memory contractAddress)
    {
        contractAddress = _supportedTokensList;
    }

    function addSupportedToken(address tokenContract_) external onlyOwner {
        bool isTokenSupported = _mappingSupportedTokens[tokenContract_];
        require(
            !isTokenSupported,
            "Token already added in supported tokens list"
        );

        _mappingSupportedTokens[tokenContract_] = true;
        _supportedTokensList.push(tokenContract_);

        emit SupportedTokenAdded(tokenContract_);
    }

    function removeSupportedToken(address tokenContract_) external onlyOwner {
        bool isTokenSupported = _mappingSupportedTokens[tokenContract_];
        require(
            isTokenSupported,
            "Token already removed or not added in supported tokens list"
        );

        _mappingSupportedTokens[tokenContract_] = false;

        address[] memory supportedTokensList = _supportedTokensList;

        for (uint256 i; i < supportedTokensList.length; ++i) {
            if (_supportedTokensList[i] == tokenContract_) {
                _supportedTokensList[i] = _supportedTokensList[
                    _supportedTokensList.length - 1
                ];
                _supportedTokensList.pop();
                emit SupportedTokenRemoved(tokenContract_);
                break;
            }
        }
    }

    function _getPriceFromOracle(
        address oracleAddress_
    ) private view returns (uint256 valueInUSD) {
        (, int256 answer, , , ) = AggregatorV3Interface(oracleAddress_)
            .latestRoundData();

        valueInUSD = _toWeiFromDecimals(
            uint256(answer),
            AggregatorV3Interface(oracleAddress_).decimals()
        );
    }

    function getETHPrice() external view returns (uint256) {
        return _getPriceFromOracle(_priceOracleAddressNative);
    }

    function getTokenByETH(
        uint256 _msgValue
    ) external view returns (uint256 valueInTokens) {
        uint256 msgValueUSD = (_getPriceFromOracle(_priceOracleAddressNative) *
            _msgValue) / 1 ether;
        valueInTokens = (msgValueUSD / _priceInUSD) * 1 ether;
    }

    function isReferralAddress(address _user) public pure returns (bool) {
        return _user != address(0);
    }

    // Function to determine bonus percentage based on value in wei
    function getBonusPercentage(
        uint256 valueInWei
    ) internal pure returns (uint256) {
        if (valueInWei >= 20_000 * 1e18) return 15;
        if (valueInWei >= 15_000 * 1e18) return 13;
        if (valueInWei >= 10_000 * 1e18) return 10;
        if (valueInWei >= 5_000 * 1e18) return 8;
        if (valueInWei >= 1_500 * 1e18) return 5;
        return 0;
    }

    function buyWithToken(
        address tokenContract_,
        uint256 valueInWei_,
        address referralAddress,
        bool isStack
    ) external noReetency whenNotPaused {
        require(
            _mappingSupportedTokens[tokenContract_],
            "Token is not supported"
        );

        address msgSender = msg.sender;

        // Calculate once and use multiple times
        uint256 valueInUsd = valueInWei_;
        uint256 valueInTokens = (valueInUsd * 1 ether) / _priceInUSD;

        uint256 bonusPercentage = getBonusPercentage(valueInUsd);
        uint256 bonusTokens = (valueInTokens * bonusPercentage) / 100;
        uint256 totalTokens = bonusTokens + valueInTokens;

        uint256 referralAmount = 0;

        // Process referral only if applicable
        if (isReferralAddress(referralAddress)) {
            referralAmount = (valueInTokens * referralPercentage) / 100;

            UserInfo storage referralInfo = _mappingUserInfo[referralAddress];
            referralInfo.referralCommission += referralAmount;
            referralInfo.referralCount += 1;

            // Update only if not already enabled
            if (!referralInfo.enable) {
                referralInfo.enable = true;
                _mappingReferralIndex[referralCount++] = referralAddress;
            }

            emit ReferralCommissionEarned(
                referralAddress,
                referralInfo.referralCommission
            );
        }

        require(
            valueInUsd >= _minContributionInUSD,
            "Value less than min contribution"
        );

        // Use the calculated amount for transfer
        uint256 tokensToTransfer = _weiToTokens(tokenContract_, valueInWei_);
        IERC20Metadata(tokenContract_).safeTransferFrom(
            msgSender,
            _treasaryWallet,
            tokensToTransfer
        );

        UserInfo storage userInfo = _mappingUserInfo[msgSender];

        userInfo.stackedAmount += totalTokens;

        // Update only if not already enabled
        if (!userInfo.enable) {
            userInfo.enable = true;
            _mappingUserIndex[userCount++] = msgSender;
        }

        // Batch update of totals
        _totalTokensSold += totalTokens;
        _totalUSDCollected += valueInWei_;
        _totalReferral += referralAmount;
        _totalBonus += bonusTokens;

        emit BuyWithToken(
            msgSender,
            tokenContract_,
            valueInWei_,
            valueInTokens,
            _priceInUSD,
            bonusTokens
        );

        if (isStack) {
            stake(msgSender, totalTokens);
        } else {
            addBeneficiary(msgSender, totalTokens, currentRound);
        }
    }

    function buyWithNative(
        address referralAddress,
        bool isStack
    ) external payable noReetency whenNotPaused {
        address msgSender = msg.sender;
        uint256 msgValue = msg.value;
        uint256 msgValueUSD = (_getPriceFromOracle(_priceOracleAddressNative) *
            msgValue) / 1 ether;

        uint256 referralAmount = 0;
        uint256 valueInTokens = (msgValueUSD * 1 ether) / _priceInUSD;

        uint256 bonusPercentage = getBonusPercentage(msgValueUSD);
        uint256 bonusTokens = (valueInTokens * bonusPercentage) / 100;
        uint256 totalTokens = bonusTokens + valueInTokens;

        if (isReferralAddress(referralAddress)) {
            referralAmount = (valueInTokens * referralPercentage) / 100;

            UserInfo storage referralInfo = _mappingUserInfo[referralAddress];
            referralInfo.referralCommission += referralAmount;
            referralInfo.referralCount += 1;

            if (!referralInfo.enable) {
                referralInfo.enable = true;
                _mappingReferralIndex[referralCount++] = referralAddress;
            }

            emit ReferralCommissionEarned(
                referralAddress,
                referralInfo.referralCommission
            );
        }

        require(
            msgValueUSD >= _minContributionInUSD,
            "Value less then min contribution"
        );

        payable(_treasaryWallet).transfer(msgValue);

        UserInfo storage userInfo = _mappingUserInfo[msgSender];
        userInfo.stackedAmount += totalTokens;

        if (!userInfo.enable) {
            userInfo.enable = true;
            _mappingUserIndex[userCount++] = msgSender;
        }

        _totalTokensSold += totalTokens;
        _totalUSDCollected += msgValueUSD;
        _totalETHCollected += msgValue;
        _totalReferral += referralAmount;
        _totalBonus += bonusTokens;

        emit BuyWithNative(
            msgSender,
            msgValue,
            valueInTokens,
            _priceInUSD,
            bonusTokens
        );

        if (isStack) {
            stake(msgSender, totalTokens);
        } else {
            addBeneficiary(msgSender, totalTokens, currentRound);
        }
    }

    function _toWeiFromDecimals(
        uint256 valueInTokens_,
        uint256 from_
    ) private pure returns (uint256 valueInWei) {
        valueInWei = (valueInTokens_ * 1 ether) / 10 ** from_;
    }

    function _toWei(
        address tokenContract_,
        uint256 valueInTokens_
    ) private view returns (uint256 valueInWei) {
        valueInWei = ((valueInTokens_ * 1 ether) /
            10 ** IERC20Metadata(tokenContract_).decimals());
    }

    function _weiToTokens(
        address tokenContract_,
        uint256 valueInWei_
    ) private view returns (uint256 valueInToken) {
        valueInToken =
            (valueInWei_ * 10 ** IERC20Metadata(tokenContract_).decimals()) /
            1 ether;
    }

    function withdrawTokens(
        address _tokenContract,
        uint256 _valueInWei
    ) external noReetency onlyOwner {
        IERC20Metadata(_tokenContract).safeTransfer(owner(), _valueInWei);
    }

    function withdrawETH() external onlyOwner noReetency {
        payable(owner()).transfer(address(this).balance);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function addBeneficiary(
        address _beneficiary,
        uint256 _amount,
        uint256 _vestingType
    ) internal {
        beneficiaries[_beneficiary].push(
            Beneficiary({
                amount: _amount,
                released: 0,
                vestingType: _vestingType,
                startTime: block.timestamp,
                tgeClaimed: false
            })
        );

        emit BeneficiaryAdded(
            _beneficiary,
            _amount,
            _vestingType,
            block.timestamp
        );
    }

    function release(uint256 _id) external {
        require(tgeTime != 0, "TGE has not started yet");
        Beneficiary[] storage beneficiaryArray = beneficiaries[msg.sender];

        require(_id < beneficiaryArray.length, "Invalid vesting schedule ID");
        Beneficiary storage beneficiary = beneficiaryArray[_id];

        VestingSchedule storage schedule = vestingSchedules[
            beneficiary.vestingType
        ];
        uint256 elapsedTime = block.timestamp -
            Math.max(tgeTime, beneficiary.startTime);

        uint256 releasable;

        if (!beneficiary.tgeClaimed && schedule.tgePercentage != 0) {
            // Claim TGE tokens
            releasable = (beneficiary.amount * schedule.tgePercentage) / 100;
            beneficiary.tgeClaimed = true;
        } else {
            // Calculate vested tokens
            require(
                elapsedTime >= schedule.releaseInterval,
                "Vesting period has not started"
            );

            uint256 phases = elapsedTime / schedule.releaseInterval;
            uint256 totalReleasePercentage = schedule.tgePercentage +
                (phases * schedule.releasePercentage);

            totalReleasePercentage = Math.min(totalReleasePercentage, 100);
            uint256 totalReleasable = (beneficiary.amount *
                totalReleasePercentage) / 100;
            releasable = totalReleasable - beneficiary.released;
        }

        require(releasable > 0, "No releasable tokens");

        beneficiary.released += releasable;
        _releaseTokens(msg.sender, releasable);
    }

    function _releaseTokens(address _beneficiary, uint256 _amount) internal {
        IERC20Metadata(_presaleTokenContract).safeTransfer(
            _beneficiary,
            _toWei(_presaleTokenContract, _amount)
        );
        emit TokensReleased(_beneficiary, _amount);
    }

    function changeRound(uint256 vestingType) external onlyOwner {
        currentRound = vestingType;
    }

    function addBeneficiaries(
        address[] memory _beneficiaries,
        uint256[] memory _amounts,
        uint256 _vestingType
    ) external onlyOwner {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            beneficiaries[_beneficiaries[i]].push(
                Beneficiary({
                    amount: _amounts[i],
                    released: 0,
                    vestingType: _vestingType,
                    startTime: block.timestamp,
                    tgeClaimed: false
                })
            );
        }
    }

    function _addVestingSchedule(
        uint256 tgePercentage,
        uint256 releaseInterval,
        uint256 releasePercentage
    ) internal returns (uint256) {
        vestingSchedules[vestingScheduleCount++] = VestingSchedule({
            tgePercentage: tgePercentage,
            releaseInterval: releaseInterval,
            releasePercentage: releasePercentage,
            initialized: true
        });

        emit VestingScheduleAdded(
            vestingScheduleCount,
            tgePercentage,
            releaseInterval,
            releasePercentage
        );

        return vestingScheduleCount;
    }

    function addVestingSchedule(
        uint256 tgePercentage,
        uint256 releaseInterval,
        uint256 releasePercentage
    ) external onlyOwner returns (uint256) {
        return
            _addVestingSchedule(
                tgePercentage,
                releaseInterval,
                releasePercentage
            );
    }

    function setTGETime() external onlyOwner {
        tgeTime = block.timestamp;
        emit TGETimeSet(tgeTime);
    }

    function setReferralPercentage(
        uint256 _referralPercentage
    ) external onlyOwner {
        referralPercentage = _referralPercentage;
        emit ReferralPercentageUpdated(_referralPercentage);
    }

    function claimReferralCommission() external {
        UserInfo storage info = _mappingUserInfo[msg.sender];
        uint256 commissionAmount = _toWei(
            _presaleTokenContract,
            info.referralCommission
        );

        // Ensure that the amount to transfer is greater than zero
        require(commissionAmount > 0, "No commission to claim");

        // Transfer the commission to the sender
        IERC20Metadata(_presaleTokenContract).safeTransfer(
            msg.sender,
            commissionAmount
        );

        // Update the claimed commission
        info.referralCommissionClaimed += info.referralCommission;

        // Reset the referral commission to zero after claiming
        info.referralCommission = 0;

        emit ReferralCommissionClaimed(
            msg.sender,
            info.referralCommissionClaimed
        );
    }

    function updateReferralInfoBatch(
        address[] memory _referralAddresses,
        uint256[] memory _referralCounts,
        uint256[] memory _referralCommissions
    ) external onlyOwner {
        require(
            _referralAddresses.length == _referralCounts.length &&
                _referralAddresses.length == _referralCommissions.length,
            "Input arrays must have the same length"
        );

        for (uint256 i = 0; i < _referralAddresses.length; i++) {
            UserInfo storage referralInfo = _mappingUserInfo[
                _referralAddresses[i]
            ];
            referralInfo.referralCount = _referralCounts[i];
            referralInfo.referralCommission = _referralCommissions[i];
            referralInfo.enable = true;
        }
    }

    function getBuyInfo(
        address _user
    ) public view returns (Beneficiary[] memory) {
        return beneficiaries[_user];
    }

    function stake(address user, uint256 tokenAmount) internal {
        if (stakes[user].amount == 0) {
            stakers.push(user); // Add new staker if they are staking for the first time
        }

        stakes[user].amount += tokenAmount; // Update the staked amount
        stakes[user].timestamp = block.timestamp; // Record the timestamp of the stake
    }

    // Function to get all stakers and their staked amounts
    function getAllStakers()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256 stakerCount = stakers.length;
        uint256[] memory amounts = new uint256[](stakerCount);

        for (uint256 i = 0; i < stakerCount; i++) {
            amounts[i] = stakes[stakers[i]].amount;
        }

        return (stakers, amounts);
    }

    // Function to get the staking amount of a specific user
    function getStakeAmount(address user) external view returns (uint256) {
        return stakes[user].amount;
    }
}