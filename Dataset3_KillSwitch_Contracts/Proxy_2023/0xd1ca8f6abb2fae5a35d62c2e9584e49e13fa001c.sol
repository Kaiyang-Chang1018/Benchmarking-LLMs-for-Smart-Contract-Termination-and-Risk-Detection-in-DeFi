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
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/**
 * @dev Interface for contract that has accounts.
 */
interface IAccountInfo {
  /**
   * @dev Returns the value of account count.
   */
  function getAccountCount() external view returns (uint32);

  /**
   * @dev Returns the account by index.
   */
  function getAccountByIndex(uint32 index) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

/**
 * @dev Interface of the contract information.
 */
interface IContractInfo {
  /**
   * @dev Returns the contract name
   */
  function getContractName() external view returns (string memory);

  /**
   * @dev Returns the contract version
   */
  function getContractVersion() external view returns (string memory);
}
//SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IContractInfo} from "./IContractInfo.sol";
import {IAccountInfo} from "./IAccountInfo.sol";

// import "hardhat/console.sol";

contract SQRVesting is Ownable, ReentrancyGuard, IContractInfo, IAccountInfo {
  using SafeERC20 for IERC20;

  //Variables, structs, errors, modifiers, events------------------------

  string public constant VERSION = "2.6";

  IERC20 public erc20Token;
  uint32 public startDate;
  uint32 public cliffPeriod;
  uint256 public firstUnlockPercent;
  uint32 public unlockPeriod;
  uint256 public unlockPeriodPercent;
  bool public availableRefund;
  uint32 public refundStartDate;
  uint32 public refundCloseDate;

  mapping(address account => Allocation allocation) public allocations;
  address[] private _accountAddresses;

  uint256 public constant PERCENT_DIVIDER = 1e18 * 100;

  constructor(ContractParams memory contractParams) Ownable(contractParams.newOwner) {
    if (contractParams.erc20Token == address(0)) {
      revert ERC20TokenNotZeroAddress();
    }

    if (contractParams.firstUnlockPercent > PERCENT_DIVIDER) {
      revert FirstUnlockPercentMustBeLessThanPercentDivider();
    }

    if (contractParams.startDate < uint32(block.timestamp)) {
      revert StartDateMustBeGreaterThanCurrentTime();
    }

    if (contractParams.unlockPeriod == 0) {
      revert UnlockPeriodNotZero();
    }

    if (contractParams.unlockPeriodPercent == 0) {
      revert UnlockPeriodPercentNotZero();
    }

    if (contractParams.availableRefund) {
      if (contractParams.refundStartDate < uint32(block.timestamp)) {
        revert RefundStartDateMustBeGreaterThanCurrentTime();
      }

      if (contractParams.refundStartDate > contractParams.refundCloseDate) {
        revert RefundCloseDateMustBeGreaterThanRefundStartDate();
      }
    }

    erc20Token = IERC20(contractParams.erc20Token);
    startDate = contractParams.startDate;
    cliffPeriod = contractParams.cliffPeriod;
    firstUnlockPercent = contractParams.firstUnlockPercent;
    unlockPeriod = contractParams.unlockPeriod;
    unlockPeriodPercent = contractParams.unlockPeriodPercent;
    availableRefund = contractParams.availableRefund;
    refundStartDate = contractParams.refundStartDate;
    refundCloseDate = contractParams.refundCloseDate;
  }

  uint256 public totalReserved;
  uint256 public totalAllocated;
  uint256 public totalClaimed;
  uint32 public allocationCount;
  uint32 public refundCount;

  modifier accountExist() {
    if (!allocations[_msgSender()].exist) {
      revert AccountNotExist();
    }
    _;
  }

  modifier alreadyRefunded() {
    if (allocations[_msgSender()].refunded) {
      revert AlreadyRefunded();
    }
    _;
  }

  struct ContractParams {
    address newOwner;
    address erc20Token;
    uint32 startDate;
    uint32 cliffPeriod;
    uint256 firstUnlockPercent;
    uint32 unlockPeriod;
    uint256 unlockPeriodPercent;
    bool availableRefund;
    uint32 refundStartDate;
    uint32 refundCloseDate;
  }

  struct Allocation {
    uint256 amount;
    uint256 claimed;
    uint32 claimCount;
    uint32 claimedAt;
    bool exist;
    bool refunded;
  }

  struct ClaimInfo {
    uint256 amount;
    bool canClaim;
    uint256 claimed;
    uint32 claimCount;
    uint32 claimedAt;
    bool exist;
    uint256 available;
    uint256 remain;
    uint256 nextAvailable;
    uint32 nextClaimAt;
    bool canRefund;
    bool refunded;
  }

  event Claim(address indexed account, uint256 amount);
  event Refund(address indexed account);
  event SetAllocation(address indexed account, uint256 amount);
  event WithdrawExcessAmount(address indexed to, uint256 amount);
  event ForceWithdraw(address indexed token, address indexed to, uint256 amount);
  event SetAvailableRefund(address indexed account, bool value);
  event SetRefundStartDate(address indexed account, uint32 value);
  event SetRefundCloseDate(address indexed account, uint32 value);

  error ERC20TokenNotZeroAddress();
  error FirstUnlockPercentMustBeLessThanPercentDivider();
  error UnlockPeriodNotZero();
  error UnlockPeriodPercentNotZero();
  error StartDateMustBeGreaterThanCurrentTime();
  error ArrayLengthsNotEqual();
  error AccountNotZeroAddress();
  error ContractMustHaveSufficientFunds();
  error AccountNotExist();
  error NothingToClaim();
  error CantChangeOngoingVesting();
  error AlreadyRefunded();
  error AlreadyClaimed();
  error RefundStartDateMustBeGreaterThanCurrentTime();
  error RefundStartDateMustBeLessThanRefundCloseDate();
  error RefundCloseDateMustBeGreaterThanCurrentTime();
  error RefundCloseDateMustBeGreaterThanRefundStartDate();
  error RefundUnavailable();
  error TooEarlyToRefund();
  error TooLateToRefund();

  //Read methods-------------------------------------------
  //IContractInfo implementation
  function getContractName() external pure returns (string memory) {
    return "Vesting";
  }

  function getContractVersion() external pure returns (string memory) {
    return VERSION;
  }

  //IAccountInfo implementation
  function getAccountCount() public view returns (uint32) {
    return (uint32)(_accountAddresses.length);
  }

  function getAccountByIndex(uint32 index) public view returns (address) {
    return _accountAddresses[index];
  }

  //Custom
  function getBalance() public view returns (uint256) {
    return erc20Token.balanceOf(address(this));
  }

  function canClaim(address account) public view returns (bool) {
    return (calculateClaimAmount(account, 0) > 0);
  }

  function calculatePassedPeriod() public view returns (uint32) {
    uint32 timestamp = (uint32)(block.timestamp);
    if (timestamp > startDate + cliffPeriod) {
      return (timestamp - startDate - cliffPeriod) / unlockPeriod;
    }
    return 0;
  }

  function calculateMaxPeriod() public view returns (uint256) {
    return PERCENT_DIVIDER / unlockPeriodPercent;
  }

  function calculateFinishDate() public view returns (uint32) {
    return startDate + cliffPeriod + (uint32)(calculateMaxPeriod()) * unlockPeriod;
  }

  function calculateClaimAmount(
    address account,
    uint32 periodOffset
  ) public view returns (uint256) {
    // Before startDate
    if (block.timestamp < startDate && periodOffset == 0) {
      return 0;
    }

    Allocation memory allocation = allocations[account];

    uint256 firstUnlockAmount = (allocation.amount * firstUnlockPercent) / PERCENT_DIVIDER;
    uint256 claimed = allocation.claimed;
    uint256 amount = allocation.amount;

    // Before cliff and claim
    if (block.timestamp < startDate + cliffPeriod && claimed == 0) {
      return firstUnlockAmount;
    } else {
      uint256 claimAmount = ((calculatePassedPeriod() + periodOffset) *
        (amount * unlockPeriodPercent)) /
        PERCENT_DIVIDER +
        firstUnlockAmount -
        claimed;

      if (claimAmount > amount - claimed) {
        return amount - claimed;
      }

      return claimAmount;
    }
  }

  function isAllocationFinished(address account) public view returns (bool) {
    return (allocations[account].claimed == allocations[account].amount);
  }

  function isAfterRefundCloseDate() public view returns (bool) {
    return block.timestamp > refundCloseDate;
  }

  function calculateClaimAt(address account, uint32 periodOffset) public view returns (uint32) {
    if (isAllocationFinished(account)) {
      return 0;
    }

    if (allocations[account].claimed == 0) {
      return startDate;
    } else {
      if (block.timestamp - startDate < cliffPeriod) {
        return startDate + cliffPeriod + unlockPeriod;
      }

      uint32 passedPeriod = calculatePassedPeriod();
      return (uint32)(startDate + cliffPeriod + (passedPeriod + periodOffset) * unlockPeriod);
    }
  }

  function calculateRemainAmount(address account) public view returns (uint256) {
    return allocations[account].amount - allocations[account].claimed;
  }

  function canRefund(address account) public view returns (bool) {
    return
      availableRefund &&
      refundStartDate <= (uint32)(block.timestamp) &&
      (uint32)(block.timestamp) <= refundCloseDate &&
      allocations[account].claimed == 0 &&
      !allocations[account].refunded;
  }

  function fetchClaimInfo(address account) external view returns (ClaimInfo memory) {
    Allocation memory allocation = allocations[account];
    bool canClaim_ = canClaim(account);
    uint256 available = calculateClaimAmount(account, 0);
    uint256 remain = calculateRemainAmount(account);
    uint256 nextAvailable = calculateClaimAmount(account, 1);
    uint32 nextClaimAt = calculateClaimAt(account, 1);
    bool canRefund_ = canRefund(account);

    return
      ClaimInfo(
        allocation.amount,
        canClaim_,
        allocation.claimed,
        allocation.claimCount,
        allocation.claimedAt,
        allocation.exist,
        available,
        remain,
        nextAvailable,
        nextClaimAt,
        canRefund_,
        allocation.refunded
      );
  }

  function calculatedRequiredAmount() public view returns (uint256) {
    uint256 contractBalance = getBalance();
    if (totalReserved > contractBalance) {
      return totalReserved - contractBalance;
    }
    return 0;
  }

  function calculateExcessAmount() public view returns (uint256) {
    uint256 contractBalance = getBalance();
    if (contractBalance > totalReserved) {
      return contractBalance - totalReserved;
    }
    return 0;
  }

  //Write methods-------------------------------------------

  function _setAllocation(address account, uint256 amount) private nonReentrant {
    if (account == address(0)) {
      revert AccountNotZeroAddress();
    }

    Allocation storage allocation = allocations[account];

    if (!allocation.exist) {
      allocationCount++;
      _accountAddresses.push(account);
    }

    totalAllocated -= allocation.amount;
    totalReserved -= allocation.amount;

    allocation.amount = amount;
    allocation.exist = true;

    totalAllocated += amount;
    totalReserved += amount;

    emit SetAllocation(account, amount);
  }

  function setAllocation(address account, uint256 amount) public onlyOwner {
    if (block.timestamp > startDate) {
      revert CantChangeOngoingVesting();
    }

    _setAllocation(account, amount);
  }

  function setAllocations(
    address[] calldata recipients,
    uint256[] calldata amounts
  ) external onlyOwner {
    if (recipients.length != amounts.length) {
      revert ArrayLengthsNotEqual();
    }

    for (uint32 i = 0; i < recipients.length; i++) {
      setAllocation(recipients[i], amounts[i]);
    }
  }

  function claim() external nonReentrant accountExist alreadyRefunded {
    address sender = _msgSender();
    uint256 claimAmount = calculateClaimAmount(sender, 0);

    if (claimAmount == 0) {
      revert NothingToClaim();
    }

    if (getBalance() < claimAmount) {
      revert ContractMustHaveSufficientFunds();
    }

    Allocation storage allocation = allocations[sender];

    allocation.claimed += claimAmount;
    allocation.claimCount += 1;
    allocation.claimedAt = (uint32)(block.timestamp);

    totalReserved -= claimAmount;

    totalClaimed += claimAmount;

    erc20Token.safeTransfer(sender, claimAmount);

    emit Claim(sender, claimAmount);
  }

  function refund() external alreadyRefunded {
    if (!availableRefund) {
      revert RefundUnavailable();
    }

    if ((uint32)(block.timestamp) < refundStartDate) {
      revert TooEarlyToRefund();
    }

    if ((uint32)(block.timestamp) > refundCloseDate) {
      revert TooLateToRefund();
    }

    address sender = _msgSender();
    Allocation storage allocation = allocations[sender];

    if (allocation.claimed > 0) {
      revert AlreadyClaimed();
    }

    allocation.refunded = true;

    _setAllocation(sender, 0);

    refundCount++;

    emit Refund(sender);
  }

  function setAvailableRefund(bool value) external onlyOwner {
    availableRefund = value;
    emit SetAvailableRefund(_msgSender(), value);
  }

  function setRefundStartDate(uint32 value) external onlyOwner {
    if (value < uint32(block.timestamp)) {
      revert RefundStartDateMustBeGreaterThanCurrentTime();
    }

    if (value > refundCloseDate) {
      revert RefundStartDateMustBeLessThanRefundCloseDate();
    }

    refundStartDate = value;
    emit SetRefundStartDate(_msgSender(), value);
  }

  function setRefundCloseDate(uint32 value) external onlyOwner {
    if (value < uint32(block.timestamp)) {
      revert RefundCloseDateMustBeGreaterThanCurrentTime();
    }

    if (value < refundStartDate) {
      revert RefundCloseDateMustBeGreaterThanRefundStartDate();
    }

    refundCloseDate = value;
    emit SetRefundCloseDate(_msgSender(), value);
  }

  function withdrawExcessAmount() external onlyOwner {
    uint256 amount = calculateExcessAmount();
    address to = owner();
    erc20Token.safeTransfer(to, amount);
    emit WithdrawExcessAmount(to, amount);
  }

  function forceWithdraw(address token, address to, uint256 amount) external onlyOwner {
    IERC20 _token = IERC20(token);
    _token.safeTransfer(to, amount);
    emit ForceWithdraw(token, to, amount);
  }
}