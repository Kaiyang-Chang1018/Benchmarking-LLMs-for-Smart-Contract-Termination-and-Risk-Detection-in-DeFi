// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

interface IGeojamStakingClubPool {
    struct UserDeposit {
        uint256 amount;
        uint256 timestamp;
        bool receivesReward;
    }

    function getPoolEndTime(uint256 _poolId) external view returns (uint256);

    function getUserDeposits(
        uint256 _poolId,
        address _address
    ) external view returns (UserDeposit[] memory);

    function getUserLastDepositTime(
        uint256 _poolId,
        address _address
    ) external view returns (uint256);
}

// File: contracts/GeojamClub/IGeojamStakingClubPoolDelegate.sol



pragma solidity ^0.8.24;

interface IGeojamStakingClubPoolDelegate {
    function didWithdraw(address _address) external;
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
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
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
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
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

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
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
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
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

// File: @openzeppelin/contracts/access/Ownable2Step.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
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
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}

// File: contracts/GeojamClub/GeojamStakingClubPool.sol



pragma solidity ^0.8.24;







contract GeojamStakingClubPool is
    IGeojamStakingClubPool,
    ReentrancyGuard,
    Ownable2Step
{
    using SafeERC20 for IERC20;

    struct StakingPool {
        string name;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 maxStakingAmountPerUser;
        uint256 maxPoolAmountWithProfit;
        uint256 totalAmountStaked;
        uint256 maxAllowedDepositsPerUser;
        address[] usersStaked;
    }

    struct UserInfo {
        address userAddress;
        uint256 poolId;
        uint256 percentageOfTokensStakedInPool;
        uint256 amountOfTokensStakedInPool;
    }

    IERC20 public stakingToken;

    uint256 public stakingPoolsCount;

    /// @notice Pool ID => User Address => deposits
    mapping(uint256 => mapping(address => UserDeposit[]))
        public userStakedDeposits;

    /// @notice Pool ID => StakingPool
    mapping(uint256 => StakingPool) public stakingPools;

    /// @notice Pool ID => Staking Pool Delegate Address
    mapping(uint256 => IGeojamStakingClubPoolDelegate)
        public stakingPoolDelegates;

    /// @notice Pool ID => User Address => boolean (included or not)
    mapping(uint256 => mapping(address => bool))
        public userIncludedInStakingPool;

    /// @notice PoolName => isPoolNameTaken
    mapping(string => bool) public isPoolNameTaken;

    /// @notice PoolName => PoolID
    mapping(string => uint256) public poolNameToPoolId;

    event Deposit(
        address indexed _user,
        uint256 indexed _poolId,
        uint256 _amount
    );
    event Withdraw(
        address indexed _user,
        uint256 indexed _poolId,
        uint256 _amount
    );
    event PoolAdded(uint256 indexed _poolId);
    event PoolDisabled(uint256 indexed _poolId);
    event PoolMaxDepositsUpdated(
        uint256 indexed _poolId,
        uint256 _maxAllowedDepositsPerUser
    );

    constructor(address _owner, IERC20 _stakingToken) Ownable(_owner) {
        require(
            address(_stakingToken) != address(0),
            "constructor: _stakingToken must not be zero address"
        );

        stakingToken = _stakingToken;
    }

    function deposit(uint256 _poolId, uint256 _amount) external nonReentrant {
        require(_amount > 0, "deposit: Amount not specified.");
        require(_poolId < stakingPoolsCount, "deposit: Invalid pool ID.");
        require(
            block.timestamp <= stakingPools[_poolId].endTimestamp,
            "deposit: Staking no longer permitted for this pool."
        );
        require(
            block.timestamp >= stakingPools[_poolId].startTimestamp,
            "deposit: Staking is not yet permitted for this pool."
        );

        uint256 _userStakedAmount = getAmountStakedByUserInPool(
            _poolId,
            msg.sender
        );
        if (stakingPools[_poolId].maxStakingAmountPerUser > 0) {
            require(
                _userStakedAmount + _amount <=
                    stakingPools[_poolId].maxStakingAmountPerUser,
                "deposit: Cannot exceed max staking amount per user."
            );
        }

        if (stakingPools[_poolId].maxAllowedDepositsPerUser > 0) {
            require(
                userStakedDeposits[_poolId][msg.sender].length <=
                    stakingPools[_poolId].maxAllowedDepositsPerUser,
                "deposit: Reached maximum number of deposits."
            );
        }

        if (!userIncludedInStakingPool[_poolId][msg.sender]) {
            stakingPools[_poolId].usersStaked.push(msg.sender);
            userIncludedInStakingPool[_poolId][msg.sender] = true;
        }

        UserDeposit memory userDeposit;
        userDeposit.amount = _amount;
        userDeposit.timestamp = block.timestamp;
        userDeposit.receivesReward = depositAmountReceivesReward(
            _poolId,
            _amount
        );
        userStakedDeposits[_poolId][msg.sender].push(userDeposit);

        stakingPools[_poolId].totalAmountStaked =
            stakingPools[_poolId].totalAmountStaked +
            _amount;

        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        emit Deposit(msg.sender, _poolId, _amount);
    }

    function withdraw(uint256 _poolId) external nonReentrant {
        require(_poolId < stakingPoolsCount, "withdraw: Invalid pool ID.");

        uint256 _userStakedAmount = getAmountStakedByUserInPool(
            _poolId,
            msg.sender
        );

        require(_userStakedAmount > 0, "withdraw: No stake to withdraw.");

        stakingPools[_poolId].totalAmountStaked =
            stakingPools[_poolId].totalAmountStaked -
            _userStakedAmount;

        delete userStakedDeposits[_poolId][msg.sender];

        IGeojamStakingClubPoolDelegate poolDelegate = stakingPoolDelegates[
            _poolId
        ];

        if (address(poolDelegate) != address(0)) {
            poolDelegate.didWithdraw(msg.sender);
        }

        stakingToken.safeTransfer(msg.sender, _userStakedAmount);

        emit Withdraw(msg.sender, _poolId, _userStakedAmount);
    }

    function numberOfPools() external view returns (uint256) {
        return stakingPoolsCount;
    }

    function getTotalAmountStakedInPool(
        uint256 _poolId
    ) external view returns (uint256) {
        require(
            _poolId < stakingPoolsCount,
            "getTotalAmountStakedInPool: Invalid pool ID."
        );

        return stakingPools[_poolId].totalAmountStaked;
    }

    function getAmountStakedByUserInPool(
        uint256 _poolId,
        address _address
    ) public view returns (uint256) {
        uint256 _amount = 0;

        for (
            uint256 i = 0;
            i < userStakedDeposits[_poolId][_address].length;
            i++
        ) {
            _amount = _amount + userStakedDeposits[_poolId][_address][i].amount;
        }

        return _amount;
    }

    function getPercentageAmountStakedByUserInPool(
        uint256 _poolId,
        address _address
    ) public view returns (uint256) {
        require(
            _poolId < stakingPoolsCount,
            "getPercentageAmountStakedByUserInPool: Invalid pool ID."
        );

        return
            (getAmountStakedByUserInPool(_poolId, _address) * 1e8) /
            stakingPools[_poolId].totalAmountStaked;
    }

    function getUsersStakedInPool(
        uint256 _poolId
    ) external view returns (address[] memory) {
        require(
            _poolId < stakingPoolsCount,
            "getUsersStakedInPool: Invalid pool ID."
        );

        return stakingPools[_poolId].usersStaked;
    }

    function getUserDeposits(
        uint256 _poolId,
        address _address
    ) external view returns (UserDeposit[] memory) {
        require(
            _poolId < stakingPoolsCount,
            "getUserDeposits: Invalid pool ID."
        );

        return userStakedDeposits[_poolId][_address];
    }

    function getUserLastDepositTime(
        uint256 _poolId,
        address _address
    ) external view returns (uint256) {
        require(
            _poolId < stakingPoolsCount,
            "getUserLastDepositTime: Invalid pool ID."
        );

        if (userStakedDeposits[_poolId][_address].length == 0) {
            return 0;
        }

        return
            userStakedDeposits[_poolId][_address][
                userStakedDeposits[_poolId][_address].length - 1
            ].timestamp;
    }

    function depositAmountReceivesReward(
        uint256 _poolId,
        uint256 _depositAmount
    ) public view returns (bool) {
        require(
            _poolId < stakingPoolsCount,
            "depositAmountReceivesReward: Invalid pool ID."
        );

        return
            stakingPools[_poolId].totalAmountStaked + _depositAmount <=
            stakingPools[_poolId].maxPoolAmountWithProfit;
    }

    function getPoolStartTime(uint256 _poolId) external view returns (uint256) {
        require(
            _poolId < stakingPoolsCount,
            "getPoolStartTime: Invalid pool ID."
        );

        return stakingPools[_poolId].startTimestamp;
    }

    function getPoolEndTime(uint256 _poolId) external view returns (uint256) {
        require(
            _poolId < stakingPoolsCount,
            "getPoolStartTime: Invalid pool ID."
        );

        return stakingPools[_poolId].endTimestamp;
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function addStakingPool(
        string memory _name,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _maxStakingAmountPerUser,
        uint256 _maxPoolAmountWithProfit,
        uint256 _maxAllowedDepositsPerUser
    ) external onlyOwner {
        require(
            bytes(_name).length > 0,
            "addStakingPool: Pool name cannot be empty string."
        );
        require(
            _startTimestamp >= block.timestamp,
            "addStakingPool: startTimestamp is less than the current block timestamp."
        );
        require(
            _startTimestamp < _endTimestamp,
            "addStakingPool: startTimestamp is greater than or equal to the endTimestamp."
        );
        require(
            !isPoolNameTaken[_name],
            "addStakingPool: pool name already taken."
        );
        require(
            _maxPoolAmountWithProfit > _maxStakingAmountPerUser,
            "addStakingPool: maxPoolAmountWithProfit should be greater than maxStakingAmountPerUser."
        );

        StakingPool memory stakingPool;
        stakingPool.name = _name;
        stakingPool.startTimestamp = _startTimestamp;
        stakingPool.endTimestamp = _endTimestamp;
        stakingPool.maxStakingAmountPerUser = _maxStakingAmountPerUser;
        stakingPool.maxPoolAmountWithProfit = _maxPoolAmountWithProfit;
        stakingPool.maxAllowedDepositsPerUser = _maxAllowedDepositsPerUser;
        stakingPool.totalAmountStaked = 0;

        uint256 _poolId = stakingPoolsCount;
        stakingPools[_poolId] = stakingPool;
        poolNameToPoolId[_name] = _poolId;
        isPoolNameTaken[_name] = true;
        stakingPoolsCount = stakingPoolsCount + 1;

        emit PoolAdded(_poolId);
    }

    function setStakingPoolDelegate(
        uint256 _poolId,
        IGeojamStakingClubPoolDelegate poolDelegate
    ) external onlyOwner {
        stakingPoolDelegates[_poolId] = poolDelegate;
    }

    function disablePool(uint256 _poolId) external onlyOwner {
        require(_poolId < stakingPoolsCount, "disablePool: Invalid pool ID.");

        stakingPools[_poolId].endTimestamp = block.timestamp;

        emit PoolDisabled(_poolId);
    }

    function updatePoolMaximumAllowedDeposits(
        uint256 _poolId,
        uint256 _maxAllowedDepositsPerUser
    ) external onlyOwner {
        require(
            _poolId < stakingPoolsCount,
            "updatePoolMaximumDeposits: Invalid pool ID."
        );

        stakingPools[_poolId]
            .maxAllowedDepositsPerUser = _maxAllowedDepositsPerUser;

        emit PoolMaxDepositsUpdated(_poolId, _maxAllowedDepositsPerUser);
    }

    function getTotalStakingInfoForProjectPerPool(
        uint256 _poolId,
        uint256 _pageNumber,
        uint256 _pageSize
    ) external view onlyOwner returns (UserInfo[] memory) {
        require(
            _poolId < stakingPoolsCount,
            "getTotalStakingInfoForProjectPerPool: Invalid pool ID."
        );
        uint256 _usersStakedInPool = stakingPools[_poolId].usersStaked.length;
        require(
            _usersStakedInPool > 0,
            "getTotalStakingInfoForProjectPerPool: Nobody staked in this pool."
        );
        require(
            _pageSize > 0,
            "getTotalStakingInfoForProjectPerPool: Invalid page size."
        );
        require(
            _pageNumber > 0,
            "getTotalStakingInfoForProjectPerPool: Invalid page number."
        );
        uint256 _startIndex = (_pageNumber - 1) * _pageSize;

        if (_pageNumber > 1) {
            require(
                _startIndex < _usersStakedInPool,
                "getTotalStakingInfoForProjectPerPool: Specified parameters exceed number of users in the pool."
            );
        }

        uint256 _endIndex = _pageNumber * _pageSize;
        if (_endIndex > _usersStakedInPool) {
            _endIndex = _usersStakedInPool;
        }

        UserInfo[] memory _result = new UserInfo[](_endIndex - _startIndex);
        uint256 _resultIndex = 0;

        for (uint256 i = _startIndex; i < _endIndex; i++) {
            UserInfo memory _userInfo;
            _userInfo.userAddress = stakingPools[_poolId].usersStaked[i];
            _userInfo.poolId = _poolId;
            _userInfo
                .percentageOfTokensStakedInPool = getPercentageAmountStakedByUserInPool(
                _poolId,
                _userInfo.userAddress
            );
            _userInfo.amountOfTokensStakedInPool = getAmountStakedByUserInPool(
                _poolId,
                _userInfo.userAddress
            );

            _result[_resultIndex] = _userInfo;
            _resultIndex = _resultIndex + 1;
        }

        return _result;
    }
}