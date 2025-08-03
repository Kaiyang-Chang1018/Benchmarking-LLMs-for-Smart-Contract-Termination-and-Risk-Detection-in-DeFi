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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "src/interfaces/IERC20.sol";

// Caution. We assume all failed transfers cause reverts and ignore the returned bool.
interface IOracle {
    function getPrice(address,uint) external returns (uint);
    function viewPrice(address,uint) external view returns (uint);
}

interface IEscrow {
    function initialize(IERC20 _token, address beneficiary) external;
    function onDeposit() external;
    function pay(address recipient, uint amount) external;
    function balance() external view returns (uint);
}

interface IDolaBorrowingRights {
    function onBorrow(address user, uint additionalDebt) external;
    function onRepay(address user, uint repaidDebt) external;
    function onForceReplenish(address user, address replenisher, uint amount, uint replenisherReward) external;
    function balanceOf(address user) external view returns (uint);
    function deficitOf(address user) external view returns (uint);
    function replenishmentPriceBps() external view returns (uint);
}

interface IBorrowController {
    function borrowAllowed(address msgSender, address borrower, uint amount) external returns (bool);
    function onRepay(uint amount) external;
}

contract Market {

    address public gov;
    address public lender;
    address public pauseGuardian;
    address public immutable escrowImplementation;
    IDolaBorrowingRights public immutable dbr;
    IBorrowController public borrowController;
    IERC20 public immutable dola = IERC20(0x865377367054516e17014CcdED1e7d814EDC9ce4);
    IERC20 public immutable collateral;
    IOracle public oracle;
    uint public collateralFactorBps;
    uint public replenishmentIncentiveBps;
    uint public liquidationIncentiveBps;
    uint public liquidationFeeBps;
    uint public liquidationFactorBps = 5000; // 50% by default
    bool immutable callOnDepositCallback;
    bool public borrowPaused;
    uint public totalDebt;
    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    mapping (address => IEscrow) public escrows; // user => escrow
    mapping (address => uint) public debts; // user => debt
    mapping(address => uint256) public nonces; // user => nonce

    constructor (
        address _gov,
        address _lender,
        address _pauseGuardian,
        address _escrowImplementation,
        IDolaBorrowingRights _dbr,
        IERC20 _collateral,
        IOracle _oracle,
        uint _collateralFactorBps,
        uint _replenishmentIncentiveBps,
        uint _liquidationIncentiveBps,
        bool _callOnDepositCallback
    ) {
        require(_collateralFactorBps < 10000, "Invalid collateral factor");
        require(_liquidationIncentiveBps > 0 && _liquidationIncentiveBps < 10000, "Invalid liquidation incentive");
        require(_replenishmentIncentiveBps < 10000, "Replenishment incentive must be less than 100%");
        gov = _gov;
        lender = _lender;
        pauseGuardian = _pauseGuardian;
        escrowImplementation = _escrowImplementation;
        dbr = _dbr;
        collateral = _collateral;
        oracle = _oracle;
        collateralFactorBps = _collateralFactorBps;
        replenishmentIncentiveBps = _replenishmentIncentiveBps;
        liquidationIncentiveBps = _liquidationIncentiveBps;
        callOnDepositCallback = _callOnDepositCallback;
        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
        if(collateralFactorBps > 0){
            uint unsafeLiquidationIncentive = (10000 - collateralFactorBps) * (liquidationFeeBps + 10000) / collateralFactorBps;
            require(liquidationIncentiveBps < unsafeLiquidationIncentive,  "Liquidation param allow profitable self liquidation");
        }
    }
    
    modifier onlyGov {
        require(msg.sender == gov, "Only gov can call this function");
        _;
    }

    modifier liquidationParamChecker {
        _;
        if(collateralFactorBps > 0){
            uint unsafeLiquidationIncentive = (10000 - collateralFactorBps) * (liquidationFeeBps + 10000) / collateralFactorBps;
            require(liquidationIncentiveBps < unsafeLiquidationIncentive,  "New liquidation param allow profitable self liquidation");
        }
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes("DBR MARKET")),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /**
    @notice sets the oracle to a new oracle. Only callable by governance.
    @param _oracle The new oracle conforming to the IOracle interface.
    */
    function setOracle(IOracle _oracle) public onlyGov { oracle = _oracle; }

    /**
    @notice sets the borrow controller to a new borrow controller. Only callable by governance.
    @param _borrowController The new borrow controller conforming to the IBorrowController interface.
    */
    function setBorrowController(IBorrowController _borrowController) public onlyGov { borrowController = _borrowController; }

    /**
    @notice sets the address of governance. Only callable by governance.
    @param _gov Address of the new governance.
    */
    function setGov(address _gov) public onlyGov { gov = _gov; }

    /**
    @notice sets the lender to a new lender. The lender is allowed to recall dola from the contract. Only callable by governance.
    @param _lender Address of the new lender.
    */
    function setLender(address _lender) public onlyGov { lender = _lender; }

    /**
    @notice sets the pause guardian. The pause guardian can pause borrowing. Only callable by governance.
    @param _pauseGuardian Address of the new pauseGuardian.
    */
    function setPauseGuardian(address _pauseGuardian) public onlyGov { pauseGuardian = _pauseGuardian; }
    
    /**
    @notice sets the Collateral Factor requirement of the market as measured in basis points. 1 = 0.01%. Only callable by governance.
    @dev Collateral factor mus be set below 100%
    @param _collateralFactorBps The new collateral factor as measured in basis points. 
    */
    function setCollateralFactorBps(uint _collateralFactorBps) public onlyGov liquidationParamChecker {
        require(_collateralFactorBps < 10000, "Invalid collateral factor");
        collateralFactorBps = _collateralFactorBps;
    }
    
    /**
    @notice sets the Liquidation Factor of the market as denoted in basis points.
     The liquidation Factor denotes the maximum amount of debt that can be liquidated in basis points.
     At 5000, 50% of of a borrower's underwater debt can be liquidated. Only callable by governance.
    @dev Must be set between 1 and 10000.
    @param _liquidationFactorBps The new liquidation factor in basis points. 1 = 0.01%/
    */
    function setLiquidationFactorBps(uint _liquidationFactorBps) public onlyGov {
        require(_liquidationFactorBps > 0 && _liquidationFactorBps <= 10000, "Invalid liquidation factor");
        liquidationFactorBps = _liquidationFactorBps;
    }

    /**
    @notice sets the Replenishment Incentive of the market as denoted in basis points.
     The Replenishment Incentive is the percentage paid out to replenishers on a successful forceReplenish call, denoted in basis points.
    @dev Must be set between 1 and 10000.
    @param _replenishmentIncentiveBps The new replenishment incentive set in basis points. 1 = 0.01%
    */
    function setReplenismentIncentiveBps(uint _replenishmentIncentiveBps) public onlyGov {
        require(_replenishmentIncentiveBps > 0 && _replenishmentIncentiveBps < 10000, "Invalid replenishment incentive");
        replenishmentIncentiveBps = _replenishmentIncentiveBps;
    }

    /**
    @notice sets the Liquidation Incentive of the market as denoted in basis points.
     The Liquidation Incentive is the percentage paid out to liquidators of a borrower's debt when successfully liquidated.
    @dev Must be set between 0 and 10000 - liquidation fee.
    @param _liquidationIncentiveBps The new liqudation incentive set in basis points. 1 = 0.01% 
    */
    function setLiquidationIncentiveBps(uint _liquidationIncentiveBps) public onlyGov liquidationParamChecker {
        require(_liquidationIncentiveBps > 0 && _liquidationIncentiveBps + liquidationFeeBps < 10000, "Invalid liquidation incentive");
        liquidationIncentiveBps = _liquidationIncentiveBps;
    }

    /**
    @notice sets the Liquidation Fee of the market as denoted in basis points.
     The Liquidation Fee is the percentage paid out to governance of a borrower's debt when successfully liquidated.
    @dev Must be set between 0 and 10000 - liquidation factor.
    @param _liquidationFeeBps The new liquidation fee set in basis points. 1 = 0.01%
    */
    function setLiquidationFeeBps(uint _liquidationFeeBps) public onlyGov liquidationParamChecker {
        require(_liquidationFeeBps > 0 && _liquidationFeeBps + liquidationIncentiveBps < 10000, "Invalid liquidation fee");
        liquidationFeeBps = _liquidationFeeBps;
    }

    /**
    @notice Recalls amount of DOLA to the lender.
    @param amount The amount od DOLA to recall to the the lender.
    */
    function recall(uint amount) public {
        require(msg.sender == lender, "Only lender can recall");
        dola.transfer(msg.sender, amount);
    }

    /**
    @notice Pauses or unpauses borrowing for the market. Only gov can unpause a market, while gov and pauseGuardian can pause it.
    @param _value Boolean representing the state pause state of borrows. true = paused, false = unpaused.
    */
    function pauseBorrows(bool _value) public {
        if(_value) {
            require(msg.sender == pauseGuardian || msg.sender == gov, "Only pause guardian or governance can pause");
        } else {
            require(msg.sender == gov, "Only governance can unpause");
        }
        borrowPaused = _value;
    }

    /**
    @notice Internal function for creating an escrow for users to deposit collateral in.
    @dev Uses create2 and minimal proxies to create the escrow at a deterministic address
    @param user The address of the user to create an escrow for.
    */
    function createEscrow(address user) internal returns (IEscrow instance) {
        address implementation = escrowImplementation;
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, user)
        }
        require(instance != IEscrow(address(0)), "ERC1167: create2 failed");
        emit CreateEscrow(user, address(instance));
    }

    /**
    @notice Internal function for getting the escrow of a user.
    @dev If the escrow doesn't exist, an escrow contract is deployed.
    @param user The address of the user owning the escrow.
    */
    function getEscrow(address user) internal returns (IEscrow) {
        if(escrows[user] != IEscrow(address(0))) return escrows[user];
        IEscrow escrow = createEscrow(user);
        escrow.initialize(collateral, user);
        escrows[user] = escrow;
        return escrow;
    }

    /**
    @notice Deposit amount of collateral into escrow
    @dev Will deposit the amount into the escrow contract.
    @param amount Amount of collateral token to deposit.
    */
    function deposit(uint amount) public {
        deposit(msg.sender, amount);
    }

    /**
    @notice Deposit and borrow in a single transaction.
    @param amountDeposit Amount of collateral token to deposit into escrow.
    @param amountBorrow Amount of DOLA to borrow.
    */
    function depositAndBorrow(uint amountDeposit, uint amountBorrow) public {
        deposit(amountDeposit);
        borrow(amountBorrow);
    }

    /**
    @notice Deposit amount of collateral into escrow on behalf of msg.sender
    @dev Will deposit the amount into the escrow contract.
    @param user User to deposit on behalf of.
    @param amount Amount of collateral token to deposit.
    */
    function deposit(address user, uint amount) public {
        IEscrow escrow = getEscrow(user);
        collateral.transferFrom(msg.sender, address(escrow), amount);
        if(callOnDepositCallback) {
            escrow.onDeposit();
        }
        emit Deposit(user, amount);
    }

    /**
    @notice View function for predicting the deterministic escrow address of a user.
    @dev Only use deposit() function for deposits and NOT the predicted escrow address unless you know what you're doing
    @param user Address of the user owning the escrow.
    */
    function predictEscrow(address user) public view returns (IEscrow predicted) {
        address implementation = escrowImplementation;
        address deployer = address(this);
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), user)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
    @notice View function for getting the dollar value of the user's collateral in escrow for the market.
    @param user Address of the user.
    */
    function getCollateralValue(address user) public view returns (uint) {
        IEscrow escrow = predictEscrow(user);
        uint collateralBalance = escrow.balance();
        return collateralBalance * oracle.viewPrice(address(collateral), collateralFactorBps) / 1 ether;
    }

    /**
    @notice Internal function for getting the dollar value of the user's collateral in escrow for the market.
    @dev Updates the lowest price comparisons of the pessimistic oracle
    @param user Address of the user.
    */
    function getCollateralValueInternal(address user) internal returns (uint) {
        IEscrow escrow = predictEscrow(user);
        uint collateralBalance = escrow.balance();
        return collateralBalance * oracle.getPrice(address(collateral), collateralFactorBps) / 1 ether;
    }

    /**
    @notice View function for getting the credit limit of a user.
    @dev To calculate the available credit, subtract user debt from credit limit.
    @param user Address of the user.
    */
    function getCreditLimit(address user) public view returns (uint) {
        uint collateralValue = getCollateralValue(user);
        return collateralValue * collateralFactorBps / 10000;
    }

    /**
    @notice Internal function for getting the credit limit of a user.
    @dev To calculate the available credit, subtract user debt from credit limit. Updates the pessimistic oracle.
    @param user Address of the user.
    */
    function getCreditLimitInternal(address user) internal returns (uint) {
        uint collateralValue = getCollateralValueInternal(user);
        return collateralValue * collateralFactorBps / 10000;
    }
    /**
    @notice Internal function for getting the withdrawal limit of a user.
     The withdrawal limit is how much collateral a user can withdraw before their loan would be underwater. Updates the pessimistic oracle.
    @param user Address of the user.
    */
    function getWithdrawalLimitInternal(address user) internal returns (uint) {
        IEscrow escrow = predictEscrow(user);
        uint collateralBalance = escrow.balance();
        if(collateralBalance == 0) return 0;
        uint debt = debts[user];
        if(debt == 0) return collateralBalance;
        if(collateralFactorBps == 0) return 0;
        uint minimumCollateral = debt * 1 ether / oracle.getPrice(address(collateral), collateralFactorBps) * 10000 / collateralFactorBps;
        if(collateralBalance <= minimumCollateral) return 0;
        return collateralBalance - minimumCollateral;
    }

    /**
    @notice View function for getting the withdrawal limit of a user.
     The withdrawal limit is how much collateral a user can withdraw before their loan would be underwater.
    @param user Address of the user.
    */
    function getWithdrawalLimit(address user) public view returns (uint) {
        IEscrow escrow = predictEscrow(user);
        uint collateralBalance = escrow.balance();
        if(collateralBalance == 0) return 0;
        uint debt = debts[user];
        if(debt == 0) return collateralBalance;
        if(collateralFactorBps == 0) return 0;
        uint minimumCollateral = debt * 1 ether / oracle.viewPrice(address(collateral), collateralFactorBps) * 10000 / collateralFactorBps;
        if(collateralBalance <= minimumCollateral) return 0;
        return collateralBalance - minimumCollateral;
    }

    /**
    @notice Internal function for borrowing DOLA against collateral.
    @dev This internal function is shared between the borrow and borrowOnBehalf function
    @param borrower The address of the borrower that debt will be accrued to.
    @param to The address that will receive the borrowed DOLA
    @param amount The amount of DOLA to be borrowed
    */
    function borrowInternal(address borrower, address to, uint amount) internal {
        require(!borrowPaused, "Borrowing is paused");
        if(borrowController != IBorrowController(address(0))) {
            require(borrowController.borrowAllowed(msg.sender, borrower, amount), "Denied by borrow controller");
        }
        uint credit = getCreditLimitInternal(borrower);
        debts[borrower] += amount;
        require(credit >= debts[borrower], "Exceeded credit limit");
        totalDebt += amount;
        dbr.onBorrow(borrower, amount);
        dola.transfer(to, amount);
        emit Borrow(borrower, amount);
    }

    /**
    @notice Function for borrowing DOLA.
    @dev Will borrow to msg.sender
    @param amount The amount of DOLA to be borrowed.
    */
    function borrow(uint amount) public {
        borrowInternal(msg.sender, msg.sender, amount);
    }

    /**
    @notice Function for using a signed message to borrow on behalf of an address owning an escrow with collateral.
    @dev Signed messaged can be invalidated by incrementing the nonce. Will always borrow to the msg.sender.
    @param from The address of the user being borrowed from
    @param amount The amount to be borrowed
    @param deadline Timestamp after which the signed message will be invalid
    @param v The v param of the ECDSA signature
    @param r The r param of the ECDSA signature
    @param s The s param of the ECDSA signature
    */
    function borrowOnBehalf(address from, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(deadline >= block.timestamp, "DEADLINE_EXPIRED");
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "BorrowOnBehalf(address caller,address from,uint256 amount,uint256 nonce,uint256 deadline)"
                                ),
                                msg.sender,
                                from,
                                amount,
                                nonces[from]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );
            require(recoveredAddress != address(0) && recoveredAddress == from, "INVALID_SIGNER");
            borrowInternal(from, msg.sender, amount);
        }
    }

    /**
    @notice Internal function for withdrawing from the escrow
    @dev The internal function is shared by the withdraw function and withdrawOnBehalf function
    @param from The address owning the escrow to withdraw from.
    @param to The address receiving the tokens
    @param amount The amount being withdrawn.
    */
    function withdrawInternal(address from, address to, uint amount) internal {
        uint limit = getWithdrawalLimitInternal(from);
        require(limit >= amount, "Insufficient withdrawal limit");
        require(dbr.deficitOf(from) == 0, "Can't withdraw with DBR deficit");
        IEscrow escrow = getEscrow(from);
        escrow.pay(to, amount);
        emit Withdraw(from, to, amount);
    }

    /**
    @notice Function for withdrawing to msg.sender.
    @param amount Amount to withdraw.
    */
    function withdraw(uint amount) public {
        withdrawInternal(msg.sender, msg.sender, amount);
    }

    /**
    @notice Function for withdrawing maximum allowed to msg.sender.
    @dev Useful for use with escrows that continously compound tokens, so there won't be dust amounts left
    @dev Dangerous to use when the user has any amount of debt!
    */
    function withdrawMax() public {
        withdrawInternal(msg.sender, msg.sender, getWithdrawalLimitInternal(msg.sender));
    }

    /**
    @notice Function for using a signed message to withdraw on behalf of an address owning an escrow with collateral.
    @dev Signed messaged can be invalidated by incrementing the nonce. Will always withdraw to the msg.sender.
    @param from The address of the user owning the escrow being withdrawn from
    @param amount The amount to be withdrawn
    @param deadline Timestamp after which the signed message will be invalid
    @param v The v param of the ECDSA signature
    @param r The r param of the ECDSA signature
    @param s The s param of the ECDSA signature
    */
    function withdrawOnBehalf(address from, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(deadline >= block.timestamp, "DEADLINE_EXPIRED");
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "WithdrawOnBehalf(address caller,address from,uint256 amount,uint256 nonce,uint256 deadline)"
                                ),
                                msg.sender,
                                from,
                                amount,
                                nonces[from]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );
            require(recoveredAddress != address(0) && recoveredAddress == from, "INVALID_SIGNER");
            withdrawInternal(from, msg.sender, amount);
        }
    }

    /**
    @notice Function for using a signed message to withdraw on behalf of an address owning an escrow with collateral.
    @dev Signed messaged can be invalidated by incrementing the nonce. Will always withdraw to the msg.sender.
    @dev Useful for use with escrows that continously compound tokens, so there won't be dust amounts left
    @dev Dangerous to use when the user has any amount of debt!
    @param from The address of the user owning the escrow being withdrawn from
    @param deadline Timestamp after which the signed message will be invalid
    @param v The v param of the ECDSA signature
    @param r The r param of the ECDSA signature
    @param s The s param of the ECDSA signature
    */
    function withdrawMaxOnBehalf(address from, uint deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(deadline >= block.timestamp, "DEADLINE_EXPIRED");
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "WithdrawMaxOnBehalf(address caller,address from,uint256 nonce,uint256 deadline)"
                                ),
                                msg.sender,
                                from,
                                nonces[from]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );
            require(recoveredAddress != address(0) && recoveredAddress == from, "INVALID_SIGNER");
            withdrawInternal(from, msg.sender, getWithdrawalLimitInternal(from));
        }
    }

    /**
    @notice Function for incrementing the nonce of the msg.sender, making their latest signed message unusable.
    */
    function invalidateNonce() public {
        nonces[msg.sender]++;
    }
    
    /**
    @notice Function for repaying debt on behalf of user. Debt must be repaid in DOLA.
    @dev If the user has a DBR deficit, they risk initial debt being accrued by forced replenishments.
    @param user Address of the user whose debt is being repaid
    @param amount DOLA amount to be repaid. If set to max uint debt will be repaid in full.
    */
    function repay(address user, uint amount) public {
        uint debt = debts[user];
        if(amount == type(uint).max){
            amount = debt;
        }
        require(debt >= amount, "Repayment greater than debt");
        debts[user] -= amount;
        totalDebt -= amount;
        dbr.onRepay(user, amount);
        if(address(borrowController) != address(0)){
            borrowController.onRepay(amount);
        }
        dola.transferFrom(msg.sender, address(this), amount);
        emit Repay(user, msg.sender, amount);
    }

    /**
    @notice Bundles repayment and withdrawal into a single function call.
    @param repayAmount Amount of DOLA to be repaid
    @param withdrawAmount Amount of underlying to be withdrawn from the escrow
    */
    function repayAndWithdraw(uint repayAmount, uint withdrawAmount) public {
        repay(msg.sender, repayAmount);
        withdraw(withdrawAmount);
    }

    /**
    @notice Function for forcing a user to replenish their DBR deficit at a pre-determined price.
     The replenishment will accrue additional DOLA debt.
     On a successful call, the caller will be paid a replenishment incentive.
    @dev The function will only top the user back up to 0, meaning that the user will have a DBR deficit again in the next block.
    @param user The address of the user being forced to replenish DBR
    @param amount The amount of DBR the user will be replenished.
    */
    function forceReplenish(address user, uint amount) public {
        uint deficit = dbr.deficitOf(user);
        require(deficit > 0, "No DBR deficit");
        require(deficit >= amount, "Amount > deficit");
        uint replenishmentCost = amount * dbr.replenishmentPriceBps() / 10000;
        uint replenisherReward = replenishmentCost * replenishmentIncentiveBps / 10000;
        debts[user] += replenishmentCost;
        uint collateralValue = getCollateralValueInternal(user) * (10000 - liquidationIncentiveBps - liquidationFeeBps) / 10000;
        require(collateralValue >= debts[user], "Exceeded collateral value");
        totalDebt += replenishmentCost;
        dbr.onForceReplenish(user, msg.sender, amount, replenisherReward);
        dola.transfer(msg.sender, replenisherReward);
    }
    /**
    @notice Function for forcing a user to replenish all of their DBR deficit at a pre-determined price.
     The replenishment will accrue additional DOLA debt.
     On a successful call, the caller will be paid a replenishment incentive.
    @dev The function will only top the user back up to 0, meaning that the user will have a DBR deficit again in the next block.
    @param user The address of the user being forced to replenish DBR
    */
    function forceReplenishAll(address user) public {
        uint deficit = dbr.deficitOf(user);
        forceReplenish(user, deficit);
    }

    /**
    @notice Function for liquidating a user's under water debt. Debt is under water when the value of a user's debt is above their collateral factor.
    @param user The user to be liquidated
    @param repaidDebt Th amount of user user debt to liquidate.
    */
    function liquidate(address user, uint repaidDebt) public {
        require(repaidDebt > 0, "Must repay positive debt");
        uint debt = debts[user];
        require(getCreditLimitInternal(user) < debt, "User debt is healthy");
        require(repaidDebt <= debt * liquidationFactorBps / 10000, "Exceeded liquidation factor");
        uint price = oracle.getPrice(address(collateral), collateralFactorBps);
        uint liquidatorReward = repaidDebt * 1 ether / price;
        liquidatorReward += liquidatorReward * liquidationIncentiveBps / 10000;
        debts[user] -= repaidDebt;
        totalDebt -= repaidDebt;
        dbr.onRepay(user, repaidDebt);
        if(address(borrowController) != address(0)){
            borrowController.onRepay(repaidDebt);
        }
        dola.transferFrom(msg.sender, address(this), repaidDebt);
        IEscrow escrow = predictEscrow(user);
        escrow.pay(msg.sender, liquidatorReward);
        if(liquidationFeeBps > 0) {
            uint liquidationFee = repaidDebt * 1 ether / price * liquidationFeeBps / 10000;
            uint balance = escrow.balance();
            if(balance >= liquidationFee) {
                escrow.pay(gov, liquidationFee);
            } else if(balance > 0) {
                escrow.pay(gov, balance);
            }
        }
        emit Liquidate(user, msg.sender, repaidDebt, liquidatorReward);
    }
    
    event Deposit(address indexed account, uint amount);
    event Borrow(address indexed account, uint amount);
    event Withdraw(address indexed account, address indexed to, uint amount);
    event Repay(address indexed account, address indexed repayer, uint amount);
    event Liquidate(address indexed account, address indexed liquidator, uint repaidDebt, uint liquidatorReward);
    event CreateEscrow(address indexed user, address escrow);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "src/interfaces/IERC20.sol";

interface IDola  is IERC20{
    function mint(address recipient, uint256 amount) external;
    function burn(uint256 amount) external;
    function addMinter(address minter) external;
    function totalSupply() external view returns (uint256);
}
pragma solidity ^0.8.13;

interface IERC20 {
    function approve(address,uint) external;
    function transfer(address,uint) external returns (bool);
    function transferFrom(address,address,uint) external returns (bool);
    function balanceOf(address) external view returns (uint);
    function allowance(address from, address to) external view returns (uint);
}

interface IMintable is IERC20 {
    function mint(address,uint) external;
    function burn(uint) external;
    function addMinter(address minter) external;
}

interface IDelegateableERC20 is IERC20 {
    function delegate(address delegatee) external;
    function delegates(address delegator) external view returns (address delegatee);
}
pragma solidity ^0.8.13;

import {IBorrowController, IEscrow, IOracle} from "src/Market.sol";

interface IMarket {

    function borrow(uint borrowAmount) external;

    function borrowOnBehalf(
        address msgSender,
        uint dolaAmount,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function withdraw(uint amount) external;

    function withdrawMax() external;

    function withdrawOnBehalf(
        address msgSender,
        uint amount,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function deposit(uint amount) external;

    function deposit(address msgSender, uint collateralAmount) external;

    function depositAndBorrow(
        uint collateralAmount,
        uint borrowAmount
    ) external;

    function repay(address msgSender, uint amount) external;

    function liquidate(address borrower, uint liquidationAmount) external;

    function forceReplenish(address borrower, uint deficitBefore) external;

    function collateral() external returns (address);

    function debts(address user) external returns (uint);

    function recall(uint amount) external;

    function invalidateNonce() external;

    function pauseBorrows(bool paused) external;

    function setBorrowController(IBorrowController borrowController) external;

    function escrows(address user) external view returns (IEscrow);

    function predictEscrow(address user) external view returns (IEscrow);

    function getCollateralValue(address user) external view returns (uint);

    function getWithdrawalLimit(address user) external view returns (uint);

    function getCreditLimit(address user) external view returns (uint);

    function lender() external view returns (address);

    function borrowController() external view returns (address);

    function escrowImplementation() external view returns (address);

    function totalDebt() external view returns (uint);

    function borrowPaused() external view returns (bool);

    function replenishmentIncentiveBps() external view returns (uint);

    function liquidationIncentiveBps() external view returns (uint);

    function collateralFactorBps() external view returns (uint);

    function setCollateralFactorBps(uint cfBps) external;

    function setOracle(IOracle oracle) external;

    function setGov(address newGov) external;

    function setLender(address newLender) external;

    function setPauseGuardian(address newPauseGuardian) external;

    function setReplenismentIncentiveBps(uint riBps) external;

    function setLiquidationIncentiveBps(uint liBps) external;

    function setLiquidationFactorBps(uint lfBps) external;

    function setLiquidationFeeBps(uint lfeeBps) external;

    function liquidationFeeBps() external view returns (uint);

    function DOMAIN_SEPARATOR() external view returns (uint);

    function oracle() external view returns (address);
}
//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

interface ITransformHelper {
    struct Permit {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function transformToCollateral(
        uint256 amount,
        bytes calldata data
    ) external returns (uint256 collateralAmount);

    function transformToCollateral(
        uint256 amount,
        address recipient,
        bytes calldata data
    ) external returns (uint256 collateralAmount);

    function transformToCollateralAndDeposit(
        uint256 amount,
        address recipient,
        bytes calldata data
    ) external returns (uint256 collateralAmount);

    function transformFromCollateral(
        uint256 amount,
        bytes calldata data
    ) external returns (uint256);

    function transformFromCollateral(
        uint256 amount,
        address recipient,
        bytes calldata data
    ) external returns (uint256);

    function withdrawAndTransformFromCollateral(
        uint256 amount,
        address recipient,
        Permit calldata permit,
        bytes calldata data
    ) external returns (uint256 underlyingAmount);

    function assetToCollateralRatio()
        external
        view
        returns (uint256 collateralAmount);

    function assetToCollateral(
        uint256 assetAmount
    ) external view returns (uint256 collateralAmount);

    function collateralToAsset(
        uint256 collateralAmount
    ) external view returns (uint256 assetAmount);
}
//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "src/interfaces/IMarket.sol";
import "src/interfaces/ITransformHelper.sol";
import {CurveDBRHelper} from "src/util/CurveDBRHelper.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

interface IDBR {
    function markets(address) external view returns (bool);
}

interface IERC3156FlashBorrower {
    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IERC3156FlashLender {
    /**
     * @dev Initiate a flash loan.
     * @param receiver The receiver of the tokens in the loan, and the receiver of the callback.
     * @param token The loan currency.
     * @param value The amount of tokens lent.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 value,
        bytes calldata data
    ) external returns (bool);
}

// Accelerated leverage engine
contract ALE is
    Ownable,
    ReentrancyGuard,
    CurveDBRHelper,
    IERC3156FlashBorrower
{
    using SafeERC20 for IERC20;
    error CollateralNotSet();
    error MarketNotSet(address market);
    error SwapFailed();
    error DOLAInvalidBorrow(uint256 expected, uint256 actual);
    error DOLAInvalidRepay(uint256 expected, uint256 actual);
    error InvalidProxyAddress();
    error InvalidHelperAddress();
    error InvalidAction(bytes32 action);
    error NotFlashMinter(address caller);
    error NotALE(address caller);
    error NothingToDeposit();
    error DepositFailed(uint256 expected, uint256 actual);
    error WithdrawFailed(uint256 expected, uint256 actual);
    error TotalSupplyChanged(uint256 expected, uint256 actual);
    error CollateralIsZero();
    error NoMarket(address market);
    error MarketSetupFailed(
        address market,
        address buySellToken,
        address collateral,
        address helper
    );

    // 1Inch ExchangeProxy address.
    address payable public exchangeProxy;

    IDBR public constant DBR = IDBR(0xAD038Eb671c44b853887A7E32528FaB35dC5D710);

    IERC3156FlashLender public constant flash =
        IERC3156FlashLender(0x6C5Fdc0c53b122Ae0f15a863C349f3A481DE8f1F);

    bytes32 public constant CALLBACK_SUCCESS =
        keccak256("ERC3156FlashBorrower.onFlashLoan");

    bytes32 public constant LEVERAGE = keccak256("LEVERAGE");
    bytes32 public constant DELEVERAGE = keccak256("DELEVERAGE");

    struct Market {
        IERC20 buySellToken;
        IERC20 collateral;
        ITransformHelper helper;
        bool useProxy;
    }

    struct Permit {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct DBRHelper {
        uint256 amountIn; // DOLA or DBR
        uint256 minOut; // DOLA or DBR
        uint256 dola; // DOLA to extra borrow or extra repay
    }

    event LeverageUp(
        address indexed market,
        address indexed account,
        uint256 dolaFlashMinted, // DOLA flash minted for buying collateral only
        uint256 dolaFee, // Flash minter fees paid
        uint256 collateralDeposited, // amount of collateral deposited into the escrow
        uint256 dolaBorrowed, // amount of DOLA borrowed on behalf of the user
        uint256 dolaForDBR // amount of DOLA used for buying DBR
    );

    event LeverageDown(
        address indexed market,
        address indexed account,
        uint256 dolaFlashMinted, // Flash minted DOLA for repaying leverage only
        uint256 dolaFee, // Flash minter fees paid
        uint256 collateralSold, // amount of collateral/underlying sold
        uint256 dolaUserRepaid, // amount of DOLA deposited by the user as part of the repay
        uint256 dbrSoldForDola // amount of DBR sold for DOLA
    );

    event Deposit(
        address indexed market,
        address indexed account,
        address indexed token, // token used for initial deposit (could be collateral or buySellToken)
        uint256 depositAmount
    );

    event NewMarket(
        address indexed market,
        address indexed buySellToken,
        address collateral,
        address indexed helper
    );

    event NewHelper(address indexed market, address indexed helper);

    // Mapping of market to Market structs
    // NOTE: in normal cases sellToken/buyToken is the collateral token,
    // in other cases it could be different (eg. st-yCRV is collateral, yCRV is the token to be swapped from/to DOLA)
    // or with DOLA curve LPs, LP token is the collateral and DOLA is the token to be swapped from/to
    mapping(address => Market) public markets;

    modifier dolaSupplyUnchanged() {
        uint256 totalSupply = dola.totalSupply();
        _;
        if (totalSupply != dola.totalSupply())
            revert TotalSupplyChanged(totalSupply, dola.totalSupply());
    }

    constructor(
        address _exchangeProxy,
        address _pool
    ) Ownable(msg.sender) CurveDBRHelper(_pool) {
        exchangeProxy = payable(address(_exchangeProxy));
        _approveDola(address(flash), type(uint).max);
    }

    function setExchangeProxy(address _exchangeProxy) external onlyOwner {
        if (_exchangeProxy == address(0)) revert InvalidProxyAddress();
        exchangeProxy = payable(_exchangeProxy);
    }

    /// @notice Set the market for a collateral token
    /// @param _buySellToken The token which will be bought/sold (usually the collateral token), probably underlying if there's a helper
    /// @param _market The market contract
    /// @param _helper Optional helper contract to transform collateral to buySelltoken and viceversa
    /// @param useProxy Whether to use the Exchange Proxy or not
    function setMarket(
        address _market,
        address _buySellToken,
        address _helper,
        bool useProxy
    ) external onlyOwner {
        if (!DBR.markets(_market)) revert NoMarket(_market);

        if (_helper == address(0)) {
            if (_buySellToken != IMarket(_market).collateral()) {
                revert MarketSetupFailed(
                    _market,
                    _buySellToken,
                    IMarket(_market).collateral(),
                    _helper
                );
            }
        }

        address collateral = IMarket(_market).collateral();
        markets[_market].buySellToken = IERC20(_buySellToken);
        markets[_market].collateral = IERC20(collateral);
        markets[_market].buySellToken.approve(_market, type(uint256).max);

        if (_buySellToken != collateral) {
            markets[_market].collateral.approve(_market, type(uint256).max);
        }

        if (_helper != address(0)) {
            markets[_market].helper = ITransformHelper(_helper);

            markets[_market].buySellToken.approve(_helper, type(uint256).max);
            markets[_market].collateral.approve(_helper, type(uint256).max);
        }

        markets[_market].useProxy = useProxy;
        emit NewMarket(_market, _buySellToken, collateral, _helper);
    }

    /// @notice Update the helper contract
    /// @param _market The market we want to update the helper contract for
    /// @param _helper The helper contract
    function updateMarketHelper(
        address _market,
        address _helper
    ) external onlyOwner {
        if (address(markets[_market].buySellToken) == address(0))
            revert MarketNotSet(_market);

        address oldHelper = address(markets[_market].helper);
        if (oldHelper != address(0)) {
            markets[_market].buySellToken.approve(oldHelper, 0);
            markets[_market].collateral.approve(oldHelper, 0);
        }

        markets[_market].helper = ITransformHelper(_helper);

        if (_helper != address(0)) {
            markets[_market].buySellToken.approve(_helper, type(uint256).max);
            markets[_market].collateral.approve(_helper, type(uint256).max);
        }

        emit NewHelper(_market, _helper);
    }

    /// @notice Leverage user position by minting DOLA, buying collateral, deposting into the user escrow and borrow DOLA on behalf to repay the minted DOLA
    /// @dev Requires user to sign message to permit the contract to borrow DOLA on behalf
    /// @param value Amount of DOLA to flash mint/burn
    /// @param market The market contract
    /// @param spender The `allowanceTarget` field from the API response.
    /// @param swapCallData The `data` field from the API response.
    /// @param permit Permit data
    /// @param helperData Optional helper data in case the collateral needs to be transformed
    /// @param dbrData Optional data in case the user wants to buy DBR and also withdraw some DOLA
    function leveragePosition(
        uint256 value,
        address market,
        address spender,
        bytes calldata swapCallData,
        Permit calldata permit,
        bytes calldata helperData,
        DBRHelper calldata dbrData
    ) public payable nonReentrant dolaSupplyUnchanged {
        if (address(markets[market].buySellToken) == address(0))
            revert MarketNotSet(market);

        bytes memory data = abi.encode(
            LEVERAGE,
            msg.sender,
            market,
            0, // unused
            spender,
            swapCallData,
            permit,
            helperData,
            dbrData
        );

        flash.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(dola),
            value,
            data
        );
    }

    /// @notice Deposit collateral and instantly leverage user position by minting DOLA, buying collateral, deposting into the user escrow and borrow DOLA on behalf to repay the minted DOLA
    /// @dev Requires user to sign message to permit the contract to borrow DOLA on behalf
    /// @param initialDeposit Amount of collateral or underlying (in case of helper) to deposit
    /// @param value Amount of DOLA to borrow
    /// @param market The market address
    /// @param spender The `allowanceTarget` field from the API response.
    /// @param swapCallData The `data` field from the API response.
    /// @param permit Permit data
    /// @param helperData Optional helper data in case the collateral needs to be transformed
    /// @param dbrData Optional data in case the user wants to buy DBR and also withdraw some DOLA
    /// @param depositCollateral Whether the initialDeposit is the collateral or the underlying entry asset
    function depositAndLeveragePosition(
        uint256 initialDeposit,
        uint256 value,
        address market,
        address spender,
        bytes calldata swapCallData,
        Permit calldata permit,
        bytes calldata helperData,
        DBRHelper calldata dbrData,
        bool depositCollateral
    ) external payable {
        if (initialDeposit == 0) revert NothingToDeposit();

        IERC20 depositToken;

        if (depositCollateral) {
            depositToken = markets[market].collateral;
        } else {
            depositToken = markets[market].buySellToken;
        }

        depositToken.safeTransferFrom(
            msg.sender,
            address(this),
            initialDeposit
        );
        emit Deposit(market, msg.sender, address(depositToken), initialDeposit);

        leveragePosition(
            value,
            market,
            spender,
            swapCallData,
            permit,
            helperData,
            dbrData
        );
    }

    /// @notice Repay a DOLA loan and withdraw collateral from the escrow
    /// @dev Requires user to sign message to permit the contract to withdraw collateral from the escrow
    /// @param value Amount of DOLA to repay
    /// @param market The market contract
    /// @param collateralAmount Collateral amount to withdraw from the escrow
    /// @param spender The `allowanceTarget` field from the API response.
    /// @param swapCallData The `data` field from the API response.
    /// @param permit Permit data
    /// @param helperData Optional helper data in case collateral needs to be transformed
    /// @param dbrData Optional data in case the user wants to sell DBR
    function deleveragePosition(
        uint256 value,
        address market,
        uint256 collateralAmount,
        address spender,
        bytes calldata swapCallData,
        Permit calldata permit,
        bytes calldata helperData,
        DBRHelper calldata dbrData
    ) external payable nonReentrant dolaSupplyUnchanged {
        if (address(markets[market].buySellToken) == address(0))
            revert MarketNotSet(market);

        bytes memory data = abi.encode(
            DELEVERAGE,
            msg.sender,
            market,
            collateralAmount,
            spender,
            swapCallData,
            permit,
            helperData,
            dbrData
        );

        flash.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(dola),
            value,
            data
        );
    }

    function onFlashLoan(
        address initiator,
        address,
        uint amount,
        uint fee,
        bytes calldata data
    ) external returns (bytes32) {
        if (initiator != address(this)) revert NotALE(initiator);
        if (msg.sender != address(flash)) revert NotFlashMinter(msg.sender);

        (bytes32 ACTION, , , , , , , , ) = abi.decode(
            data,
            (
                bytes32,
                address,
                address,
                uint256,
                address,
                bytes,
                Permit,
                bytes,
                DBRHelper
            )
        );

        if (ACTION == LEVERAGE) _onFlashLoanLeverage(amount, fee, data);
        else if (ACTION == DELEVERAGE)
            _onFlashLoanDeleverage(amount, fee, data);
        else revert InvalidAction(bytes32(ACTION));

        return CALLBACK_SUCCESS;
    }

    function _onFlashLoanLeverage(
        uint256 _value,
        uint256 _fee,
        bytes memory data
    ) internal {
        (
            ,
            address _user,
            address _market,
            ,
            address _spender,
            bytes memory _swapCallData,
            Permit memory _permit,
            bytes memory _helperData,
            DBRHelper memory _dbrData
        ) = abi.decode(
                data,
                (
                    bytes32,
                    address,
                    address,
                    uint256,
                    address,
                    bytes,
                    Permit,
                    bytes,
                    DBRHelper
                )
            );
        // Call the encoded swap function call on the contract at `swapTarget`,
        // passing along any ETH attached to this function call to cover protocol fees.
        if (markets[_market].useProxy) {
            _approveDola(_spender, _value);
            (bool success, ) = exchangeProxy.call{value: msg.value}(
                _swapCallData
            );
            if (!success) revert SwapFailed();
        }

        // Actual collateral/buyToken bought
        uint256 collateralAmount = markets[_market].buySellToken.balanceOf(
            address(this)
        );
        if (collateralAmount == 0) revert CollateralIsZero();

        // If there's a helper contract, the buyToken has to be transformed
        if (address(markets[_market].helper) != address(0)) {
            collateralAmount = _convertToCollateral(
                collateralAmount,
                _market,
                _helperData
            );
        }

        // Deposit and borrow on behalf
        IMarket(_market).deposit(
            _user,
            markets[_market].collateral.balanceOf(address(this))
        );
        uint256 valuePlusFee = _value + _fee;
        _borrowDola(_user, valuePlusFee, _permit, _dbrData, IMarket(_market));

        if (_dbrData.dola != 0) dola.transfer(_user, _dbrData.dola);

        if (_dbrData.amountIn != 0)
            _buyDbr(_dbrData.amountIn, _dbrData.minOut, _user);
        // Scope to avoid stack too deep error
        {
            uint256 balance = dola.balanceOf(address(this));

            if (balance > valuePlusFee)
                dola.transfer(_user, balance - valuePlusFee);
        }

        // Refund any possible unspent fees to the sender.
        if (address(this).balance > 0)
            payable(_user).transfer(address(this).balance);

        emit LeverageUp(
            _market,
            _user,
            _value,
            _fee,
            collateralAmount,
            _dbrData.dola,
            _dbrData.amountIn
        );
    }

    function _onFlashLoanDeleverage(
        uint256 _value,
        uint256 _fee,
        bytes memory data
    ) internal {
        (
            ,
            address _user,
            address _market,
            uint256 _collateralAmount,
            address _spender,
            bytes memory _swapCallData,
            Permit memory _permit,
            bytes memory _helperData,
            DBRHelper memory _dbrData
        ) = abi.decode(
                data,
                (
                    bytes32,
                    address,
                    address,
                    uint256,
                    address,
                    bytes,
                    Permit,
                    bytes,
                    DBRHelper
                )
            );

        _repayAndWithdraw(
            _user,
            _value,
            _collateralAmount,
            _permit,
            _dbrData,
            IMarket(_market)
        );

        IERC20 sellToken = markets[_market].buySellToken;

        // If there's a helper contract, the collateral has to be transformed
        if (address(markets[_market].helper) != address(0)) {
            _collateralAmount = _convertToAsset(
                _collateralAmount,
                _market,
                sellToken,
                _helperData
            );
            // Reimbourse leftover collateral from conversion if any
            uint256 collateralLeft = markets[_market].collateral.balanceOf(
                address(this)
            );

            if (collateralLeft != 0) {
                markets[_market].collateral.safeTransfer(_user, collateralLeft);
            }
        }

        // Call the encoded swap function call on the contract at `swapTarget`,
        // passing along any ETH attached to this function call to cover protocol fees.
        // NOTE: This will swap the collateral or helperCollateral for DOLA
        if (markets[_market].useProxy) {
            // Approve sellToken for spender
            sellToken.approve(_spender, 0);
            sellToken.approve(_spender, _collateralAmount);
            (bool success, ) = exchangeProxy.call{value: msg.value}(
                _swapCallData
            );
            if (!success) revert SwapFailed();
        }

        if (address(markets[_market].helper) == address(0)) {
            uint256 collateralAvailable = markets[_market].collateral.balanceOf(
                address(this)
            );

            if (collateralAvailable != 0) {
                markets[_market].collateral.safeTransfer(
                    _user,
                    collateralAvailable
                );
            }
        } else if (address(sellToken) != address(dola)) {
            uint256 sellTokenBal = sellToken.balanceOf(address(this));
            // Send any leftover sellToken to the sender
            if (sellTokenBal != 0) sellToken.safeTransfer(_user, sellTokenBal);
        }

        // Scope to avoid stack too deep error
        {
            uint256 balance = dola.balanceOf(address(this));
            if (balance < _value) revert DOLAInvalidRepay(_value, balance);
            uint256 valuePlusFee = _value + _fee;
            // Send any extra DOLA to the sender (in case the collateral withdrawn and swapped exceeds the value to burn)
            if (balance > valuePlusFee)
                dola.transfer(_user, balance - valuePlusFee);
        }

        if (_dbrData.amountIn != 0) {
            dbr.transferFrom(_user, address(this), _dbrData.amountIn);
            _sellDbr(_dbrData.amountIn, _dbrData.minOut, _user);
        }

        // Refund any unspent protocol fees to the sender.
        if (address(this).balance > 0)
            payable(_user).transfer(address(this).balance);

        emit LeverageDown(
            _market,
            _user,
            _value,
            _fee,
            _collateralAmount,
            _dbrData.dola,
            _dbrData.amountIn
        );
    }

    /// @notice Mint DOLA to this contract and approve the spender
    /// @param spender The spender address
    /// @param _value Amount of DOLA to mint and approve
    function _approveDola(address spender, uint256 _value) internal {
        dola.approve(spender, _value);
    }

    /// @notice Borrow DOLA on behalf of the user
    /// @param _value Amount of DOLA to borrow
    /// @param _permit Permit data
    /// @param _dbrData DBR data
    /// @param market The market contract
    function _borrowDola(
        address _user,
        uint256 _value,
        Permit memory _permit,
        DBRHelper memory _dbrData,
        IMarket market
    ) internal {
        uint256 dolaToBorrow = _value;

        if (_dbrData.dola != 0) {
            dolaToBorrow += _dbrData.dola;
        }

        if (_dbrData.amountIn != 0) {
            dolaToBorrow += _dbrData.amountIn;
        }
        // We borrow the amount of DOLA we minted before plus the amount for buying DBR if any
        market.borrowOnBehalf(
            _user,
            dolaToBorrow,
            _permit.deadline,
            _permit.v,
            _permit.r,
            _permit.s
        );

        if (dola.balanceOf(address(this)) < dolaToBorrow)
            revert DOLAInvalidBorrow(
                dolaToBorrow,
                dola.balanceOf(address(this))
            );
    }

    /// @notice Repay DOLA loan and withdraw collateral from the escrow
    /// @param _value Amount of DOLA to repay
    /// @param _collateralAmount Collateral amount to withdraw from the escrow
    /// @param _permit Permit data
    /// @param _dbrData DBR data
    /// @param market The market contract
    function _repayAndWithdraw(
        address _user,
        uint256 _value,
        uint256 _collateralAmount,
        Permit memory _permit,
        DBRHelper memory _dbrData,
        IMarket market
    ) internal {
        if (_dbrData.dola != 0) {
            dola.transferFrom(_user, address(this), _dbrData.dola);
            _approveDola(address(market), _value + _dbrData.dola);
            market.repay(_user, _value + _dbrData.dola);
        } else {
            _approveDola(address(market), _value);
            market.repay(_user, _value);
        }

        // withdraw amount from ZERO EX quote
        market.withdrawOnBehalf(
            _user,
            _collateralAmount,
            _permit.deadline,
            _permit.v,
            _permit.r,
            _permit.s
        );
    }

    /// @notice convert a collateral amount into the underlying asset
    /// @param _collateralAmount Collateral amount to convert
    /// @param _market The market contract
    /// @param sellToken The sell token (the underlying asset)
    /// @param _helperData Optional helper data
    /// @return assetAmount The amount of sellToken/underlying after the conversion
    function _convertToAsset(
        uint256 _collateralAmount,
        address _market,
        IERC20 sellToken,
        bytes memory _helperData
    ) internal returns (uint256) {
        // Collateral amount is now transformed into sellToken
        uint256 assetAmount = markets[_market].helper.transformFromCollateral(
            _collateralAmount,
            _helperData
        );
        uint256 actualAssetAmount = sellToken.balanceOf(address(this));

        if (actualAssetAmount < assetAmount)
            revert WithdrawFailed(assetAmount, actualAssetAmount);

        return actualAssetAmount;
    }

    /// @notice convert the underlying asset amount into the collateral
    /// @param _assetAmount The amount of sellToken/underlying to convert
    /// @param _market The market contract
    /// @param _helperData Optional helper data
    /// @return collateralAmount The amount of collateral after the conversion
    function _convertToCollateral(
        uint256 _assetAmount,
        address _market,
        bytes memory _helperData
    ) internal returns (uint256) {
        // Collateral amount is now transformed
        uint256 collateralAmount = markets[_market]
            .helper
            .transformToCollateral(_assetAmount, _helperData);

        uint256 actualCollateralAmount = markets[_market].collateral.balanceOf(
            address(this)
        );
        if (actualCollateralAmount < collateralAmount)
            revert DepositFailed(collateralAmount, actualCollateralAmount);

        return actualCollateralAmount;
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
pragma solidity ^0.8.13;
//import "src/util/OffchainAbstractHelper.sol";
import "src/interfaces/IERC20.sol";
import "src/interfaces/IDola.sol";

interface ICurvePool {
    function coins(uint index) external view returns (address);

    function get_dy(uint i, uint j, uint dx) external view returns (uint);

    function exchange(
        uint i,
        uint j,
        uint dx,
        uint min_dy,
        bool use_eth
    ) external payable returns (uint);

    function exchange(
        uint i,
        uint j,
        uint dx,
        uint min_dy,
        bool use_eth,
        address receiver
    ) external payable returns (uint);
}

contract CurveDBRHelper {
    ICurvePool public immutable curvePool;
    IDola constant dola = IDola(0x865377367054516e17014CcdED1e7d814EDC9ce4);
    IERC20 constant dbr = IERC20(0xAD038Eb671c44b853887A7E32528FaB35dC5D710);

    uint dbrIndex;
    uint dolaIndex;

    constructor(address _pool) {
        curvePool = ICurvePool(_pool);
        dola.approve(_pool, type(uint).max);
        dbr.approve(_pool, type(uint).max);
        if (ICurvePool(_pool).coins(0) == address(dola)) {
            dolaIndex = 0;
            dbrIndex = 1;
        } else {
            dolaIndex = 1;
            dbrIndex = 0;
        }
    }

    /**
    @notice Sells an exact amount of DBR for DOLA in a curve pool
    @param amount Amount of DBR to sell
    @param minOut minimum amount of DOLA to receive
    */
    function _sellDbr(uint amount, uint minOut, address receiver) internal {
        if (amount > 0) {
            curvePool.exchange(
                dbrIndex,
                dolaIndex,
                amount,
                minOut,
                false,
                receiver
            );
        }
    }

    /**
    @notice Buys an exact amount of DBR for DOLA in a curve pool
    @param amount Amount of DOLA to sell
    @param minOut minimum amount of DBR out
    */
    function _buyDbr(uint amount, uint minOut, address receiver) internal {
        if (amount > 0) {
            curvePool.exchange(
                dolaIndex,
                dbrIndex,
                amount,
                minOut,
                false,
                receiver
            );
        }
    }

    /**
    @notice Approximates the total amount of dola and dbr needed to borrow a dolaBorrowAmount while also borrowing enough to buy the DBR needed to cover for the borrowing period
    @dev Uses a binary search to approximate the amounts needed. Should only be called as part of generating transaction parameters.
    @param dolaBorrowAmount Amount of dola the user wishes to end up with
    @param period Amount of time in seconds the loan will last
    @param iterations Number of approximation iterations. The higher the more precise the result
    */
    function approximateDolaAndDbrNeeded(
        uint dolaBorrowAmount,
        uint period,
        uint iterations
    ) public view returns (uint dolaForDbr, uint dbrNeeded) {
        uint amountIn = dolaBorrowAmount;
        uint stepSize = amountIn / 2;
        uint dbrReceived = curvePool.get_dy(dolaIndex, dbrIndex, amountIn);
        uint dbrToBuy = ((amountIn + dolaBorrowAmount) * period) / 365 days;
        uint dist = dbrReceived > dbrToBuy
            ? dbrReceived - dbrToBuy
            : dbrToBuy - dbrReceived;
        for (uint i; i < iterations; ++i) {
            uint newAmountIn = amountIn;
            if (dbrReceived > dbrToBuy) {
                newAmountIn -= stepSize;
            } else {
                newAmountIn += stepSize;
            }
            uint newDbrReceived = curvePool.get_dy(
                dolaIndex,
                dbrIndex,
                newAmountIn
            );
            uint newDbrToBuy = ((newAmountIn + dolaBorrowAmount) * period) /
                365 days;
            uint newDist = newDbrReceived > newDbrToBuy
                ? newDbrReceived - newDbrToBuy
                : newDbrToBuy - newDbrReceived;
            if (newDist < dist) {
                dbrReceived = newDbrReceived;
                dbrToBuy = newDbrToBuy;
                dist = newDist;
                amountIn = newAmountIn;
            }
            stepSize /= 2;
        }
        return (amountIn, ((dolaBorrowAmount + amountIn) * period) / 365 days);
    }
}