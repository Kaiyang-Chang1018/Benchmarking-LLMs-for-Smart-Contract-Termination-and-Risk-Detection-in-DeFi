// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IBurnableToken} from "./apps/interfaces/IBurnableToken.sol";
import {IMintableToken} from "./apps/interfaces/IMintableToken.sol";
import {LockDropEvents} from "./events/LockDropEvents.sol";
import {ILockDrop} from "./interfaces/ILockDrop.sol";
import {ILockDropFactory} from "./interfaces/ILockDropFactory.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LockDrop is LockDropEvents, Ownable2Step, ILockDrop {
    using SafeERC20 for IERC20;

    /// @dev Precision of the `dropRatio`.
    uint256 internal constant WAD = 10 ** 18;

    /// @notice Default duration of the locking period. Could be later modified by the contract owner.
    uint256 internal constant DEFAULT_LOCKING_DURATION = 365 days;

    /// @notice Buffer time when changing the lockEndTime is not allowed:
    /// - Not possible to change the lockEndTime if less than `LOCK_BUFFER_TIME` remains.
    /// - Not possible to set the new value that is less than `LOCK_BUFFER_TIME` away from now.
    uint256 public constant LOCK_BUFFER_TIME = 1 weeks;

    /// @notice Address of the locked token, set at construction.
    address public immutable LOCK_TOKEN;
    /// @notice Address of the drop token, set at construction.
    address public immutable DROP_TOKEN;
    /// @notice Ratio of the dropped tokens to the locked tokens, set at construction (expressed in 1e18 precision).
    /// Note: expressed in 1e18 precision, so 10 dropToken per 1 lockToken would be 10**19.
    uint256 public immutable DROP_RATIO;

    /// @notice Timestamp after which locking is no longer allowed
    uint256 public lockEndTime;

    /// @notice Total amount of `lockToken` locked by the address
    mapping(address account => uint256 amount) public lockedAmountOf;

    /// @notice Total amount of `lockToken` locked by all accounts.
    uint256 public totalLockedAmount;

    /// @dev The deployer of the LockDrop contract is supposed to be the LockDropFactory. Its owner is configured
    /// as the initial owner of the LockDrop contract.
    constructor(uint256 dropRatio) Ownable(ILockDropFactory(msg.sender).owner()) {
        (address lockToken, address dropToken) = ILockDropFactory(msg.sender).getLockDropParams();
        // owner address is checked to be non-zero in the Ownable constructor
        if (lockToken == address(0) || dropToken == address(0)) {
            revert LockDrop__ZeroAddress();
        }
        if (dropRatio == 0) {
            revert LockDrop__ZeroDropRatio();
        }
        LOCK_TOKEN = lockToken;
        DROP_TOKEN = dropToken;
        DROP_RATIO = dropRatio;
        _setLockEndTime(block.timestamp + DEFAULT_LOCKING_DURATION);
    }

    /// @notice Allows the owner of the contract to process the LockDrop after the locking period is over.
    /// This will burn all the previously locked `lockToken` tokens, without touching anything else.
    function processFinishedLockdrop() external onlyOwner {
        if (isLockingEnabled()) revert LockDrop__LockingNotFinished();
        uint256 burnAmount = totalLockedAmount;
        totalLockedAmount = 0;
        IBurnableToken(LOCK_TOKEN).burn(burnAmount);
    }

    /// @notice Allows the owner of the contract to set the lockEndTime.
    /// Note: lockEndTime can not be modified once less than `LOCK_BUFFER_TIME` remains until the current value.
    /// Note: lockEndTime can not be modified to a value that is less than `LOCK_BUFFER_TIME` away from now.
    function setLockEndTime(uint256 newLockEndTime) external onlyOwner {
        uint256 bufferThreshold = block.timestamp + LOCK_BUFFER_TIME;
        if (lockEndTime < bufferThreshold) {
            revert LockDrop__LockEndTimeFinalized();
        }
        if (newLockEndTime < bufferThreshold) {
            revert LockDrop__LockEndTimeBelowMin();
        }
        _setLockEndTime(newLockEndTime);
    }

    /// @notice Allows the owner of the contract to recover the given amount of `token` to the specified recipient
    /// Note: for `lockToken`, the owner can only recover the amount that is not locked by any account.
    /// @dev Pass address(0) as token to recover the native gas token.
    function recover(address token, address recipient, uint256 amount) external onlyOwner {
        // Can not recover more than the balance of the contract
        uint256 maxAmount = token == address(0) ? address(this).balance : IERC20(token).balanceOf(address(this));
        // Can not recover using funds that are explicitly locked
        if (token == LOCK_TOKEN) {
            maxAmount -= totalLockedAmount;
        }
        if (amount > maxAmount) {
            revert LockDrop__RecoverAmountAboveBalance();
        }
        // Can proceed with the recovery based on the token type (native token or ERC20)
        if (token == address(0)) {
            Address.sendValue(payable(recipient), amount);
        } else {
            IERC20(token).safeTransfer(recipient, amount);
        }
        emit Recovered(token, recipient, amount);
    }

    /// @notice Allows anyone to lock the given amount of `lockToken` in order to trigger the token drop
    /// to the specified recipient. The LockDrop's ratio will determine how much `dropToken` will be dropped:
    /// for every token locked, `dropRatio` tokens of `dropToken` will be dropped to the recipient.
    /// Note: the caller must have at least `lockTokenAmount` of `lockToken` (and approve LockDrop for spending).
    function lock(uint256 lockTokenAmount, address recipient) external {
        if (!isLockingEnabled()) {
            revert LockDrop__LockingFinished();
        }
        if (address(recipient) == address(0)) {
            revert LockDrop__ZeroAddress();
        }
        uint256 dropAmount = calculateDropAmount(lockTokenAmount);
        // No matter who recipient is, we increase the lockedAmountOf for the sender
        totalLockedAmount += lockTokenAmount;
        lockedAmountOf[msg.sender] += lockTokenAmount;
        IERC20(LOCK_TOKEN).safeTransferFrom(msg.sender, address(this), lockTokenAmount);
        IMintableToken(DROP_TOKEN).mint(recipient, dropAmount);
        emit Locked(recipient, lockTokenAmount, dropAmount);
    }

    /// @notice Allows anyone to unlock the given amount of `lockToken` to the specified recipient.
    /// The LockDrop's ratio will determine how much `dropToken` will be burnt for every `lockToken` unlocked.
    /// Note: the caller must have at least `calculateDropAmount(lockTokenAmount)` of `dropToken`, and approve
    /// LockDrop for spending.
    function unlock(uint256 lockTokenAmount, address recipient) external {
        if (!isLockingEnabled()) {
            revert LockDrop__LockingFinished();
        }
        if (address(recipient) == address(0)) {
            revert LockDrop__ZeroAddress();
        }
        uint256 burnAmount = calculateDropAmount(lockTokenAmount);
        // No matter who recipient is, we decrease the lockedAmountOf for the sender
        if (lockedAmountOf[msg.sender] < lockTokenAmount) {
            revert LockDrop__AmountAboveLocked();
        }
        totalLockedAmount -= lockTokenAmount;
        lockedAmountOf[msg.sender] -= lockTokenAmount;
        IMintableToken(DROP_TOKEN).burnFrom(msg.sender, burnAmount);
        IERC20(LOCK_TOKEN).safeTransfer(recipient, lockTokenAmount);
        emit Unlocked(recipient, lockTokenAmount, burnAmount);
    }

    // ═══════════════════════════════════════════════════ VIEWS ═══════════════════════════════════════════════════════

    /// @notice Checks if the locking feature of LockDrop is enabled.
    function isLockingEnabled() public view returns (bool) {
        return block.timestamp <= lockEndTime;
    }

    /// @notice Calculates the amount of `dropToken` that will be dropped for locking the amount of `lockToken`.
    function calculateDropAmount(uint256 lockTokenAmount) public view returns (uint256) {
        // Once the locking is finished, no more drop tokens will be dropped
        return isLockingEnabled() ? (lockTokenAmount * DROP_RATIO) / WAD : 0;
    }

    /// @notice Calculates the amount of `lockToken` that will be unlocked for burning the amount of `dropToken`.
    function calculateUnlockAmount(uint256 dropTokenAmount) public view returns (uint256) {
        // Once the locking is finished, no more lock tokens will be unlocked
        return isLockingEnabled() ? (dropTokenAmount * WAD) / DROP_RATIO : 0;
    }

    // ═════════════════════════════════════════════════ INTERNAL ══════════════════════════════════════════════════════

    /// @dev Internal function to set the lockEndTime. All necessary checks are done in the calling function.
    function _setLockEndTime(uint256 newLockEndTime) internal {
        lockEndTime = newLockEndTime;
        emit LockEndTimeSet(newLockEndTime);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBurnableToken {
    function burn(uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMintableToken {
    function mint(address to, uint256 amount) external;

    function burnFrom(address from, uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract LockDropEvents {
    event Locked(address indexed recipient, uint256 lockTokenAmount, uint256 dropAmount);
    event Unlocked(address indexed recipient, uint256 unlockAmount, uint256 dropTokenAmount);

    event LockEndTimeSet(uint256 newLockEndTime);
    event Recovered(address token, address recipient, uint256 amount);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILockDrop {
    error LockDrop__AmountAboveLocked();
    error LockDrop__LockEndTimeBelowMin();
    error LockDrop__LockEndTimeFinalized();
    error LockDrop__LockingFinished();
    error LockDrop__LockingNotFinished();
    error LockDrop__RecoverAmountAboveBalance();
    error LockDrop__ZeroAddress();
    error LockDrop__ZeroDropRatio();

    function processFinishedLockdrop() external;
    function setLockEndTime(uint256 newLockEndTime) external;
    function recover(address token, address recipient, uint256 amount) external;

    function lock(uint256 lockTokenAmount, address recipient) external;
    function unlock(uint256 lockTokenAmount, address recipient) external;

    function isLockingEnabled() external view returns (bool);
    function lockEndTime() external view returns (uint256);

    function calculateDropAmount(uint256 lockTokenAmount) external view returns (uint256);
    function calculateUnlockAmount(uint256 dropTokenAmount) external view returns (uint256);
    function lockedAmountOf(address account) external view returns (uint256);
    function totalLockedAmount() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILockDropFactory {
    function deployLockDrop(
        address lockToken,
        address dropToken,
        uint256 dropRatio,
        bytes32 lockDropSalt,
        bytes calldata lockDropCreationCode
    )
        external
        returns (address lockDrop);

    function getLockDropParams() external view returns (address lockToken, address dropToken);
    function owner() external view returns (address);

    function predictLockDropAddress(
        uint256 dropRatio,
        bytes32 lockDropSalt,
        bytes calldata lockDropCreationCode
    )
        external
        view
        returns (address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

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
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

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
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
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