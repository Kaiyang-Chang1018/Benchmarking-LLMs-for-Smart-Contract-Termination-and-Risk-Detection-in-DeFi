// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 ^0.8.20;

/**

Website: https://www.nonutnovember.club/

TG: @nonutnovemberethereum

X: @@NutNo44310

Blog: N/A

*/

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

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

// lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

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

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
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
}

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
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
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
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
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
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// Interface for interacting with liquidity pool pairs
interface ILpPair {
    function sync() external;
}

// Interface for interacting with a decentralized exchange (DEX) router
interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

// Interface for interacting with a decentralized exchange (DEX) factory
interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract NoNutNovember is ERC20, Ownable, ReentrancyGuard {
    using Math for uint256;

    // Variables for managing supply, liquidity, and trading
    uint256 public constant maxSupply = 1000000000000000000000000000;
    address public immutable uniswapV2Pair;
    address public immutable WETH;
    IDexRouter public immutable uniswapV2Router;

    // Mappings for fee exemptions and botlist
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedFromLimits;
    mapping(address => bool) private _botlist;
    mapping(address => bool) private _isAMMPair;

    // Anti-MEV protection
    mapping(address => uint256) private _holderLastTransferBlock;

    address public _devAddress;
    address public _taxAddress;
    uint256 private _startingLiquidity;
    uint256 private _launchBlock;
    uint256 private _lastSwapBackBlock;

    // Tax rates and limits
    Limits public limits;
    Taxes public taxes;

    uint32 private constant DIVISOR = 10000;

    // Trading and limit flags
    bool public tradingEnabled;
    bool public limited;
    bool public transferDelayEnabled;

    // Structs
    struct Taxes {
        uint32 buyTaxBps;
        uint32 sellTaxBps;
    }

    struct Limits {
        uint32 maxWalletSizeBps;
        uint32 minWalletSizeBps;
        uint32 maxBuyBps;
        uint32 maxSellBps;
    }

    // Events
    event EnableTrading();
    event RemoveLimits();
    event RemoveTransferDelay();

    // Constructor to initialize the meme token
    constructor(
        address[] memory additionalWallets,
        uint256[] memory walletPercentagesBps
    ) ERC20("No Nut November", "NNN") Ownable(msg.sender) {
        require(additionalWallets.length == walletPercentagesBps.length, "Array length mismatch");

        uniswapV2Router = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = uniswapV2Router.WETH();
        uniswapV2Pair = IDexFactory(uniswapV2Router.factory()).createPair(address(this), WETH);
        _isAMMPair[uniswapV2Pair] = true;

        _devAddress = 0x539DA43cBDCAEB8DFfDc62FF618aD9d6c4CFb53D;
        _taxAddress = 0x539DA43cBDCAEB8DFfDc62FF618aD9d6c4CFb53D;

        // Distribute tokens to additional wallets as per specified percentage bps
        bool ownerMinted = false;
        uint256 totalDistributed = 0;
        uint256 ownerAmount = 0;
        for (uint256 i = 0; i < additionalWallets.length; i++) {
            if (additionalWallets[i] == msg.sender) {
                ownerMinted = true;
            }
            uint256 walletAmount = maxSupply.mulDiv(walletPercentagesBps[i], DIVISOR);
            _mint(additionalWallets[i], walletAmount);
            totalDistributed += walletAmount;
        }

        // Mint the remaining tokens to the creator
        if (!ownerMinted) {
            ownerAmount = maxSupply.mulDiv(200, DIVISOR);
            _mint(msg.sender, ownerAmount); // 2% if not minted
        }

        uint256 startingLiquidity = maxSupply - totalDistributed - ownerAmount;
        _mint(address(this), startingLiquidity);
        _startingLiquidity = startingLiquidity - maxSupply.mulDiv(2200, DIVISOR);

        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        _approve(address(msg.sender), address(uniswapV2Router), totalSupply());

        // Exclude creator and contract from fees
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[uniswapV2Pair] = true;
        _isExcludedFromFees[address(uniswapV2Router)] = true;
        _isExcludedFromLimits[address(uniswapV2Router)] = true;
        _isExcludedFromLimits[uniswapV2Pair] = true;
        _isExcludedFromLimits[address(this)] = true;
        _isExcludedFromLimits[msg.sender] = true;
        _isExcludedFromLimits[_devAddress] = true;
        _isExcludedFromLimits[_taxAddress] = true;
        _isExcludedFromFees[_devAddress] = true;
        _isExcludedFromFees[_taxAddress] = true;

        // Set default limits and taxes
        limits.maxWalletSizeBps = 150;
        limits.minWalletSizeBps = 0;
        limits.maxBuyBps = 100; 
        limits.maxSellBps = 100; 
        taxes.buyTaxBps = 100; 
        taxes.sellTaxBps = 100; 
        limited = true;
        transferDelayEnabled = true;
    }

    /**
     * @dev Set the maximum amount of tokens that a wallet can hold.
     * @param _maxWalletSizeBps The maximum wallet size in bps (e.g., 100 for 1%).
     */
    function setMaxWalletSize(uint32 _maxWalletSizeBps) external onlyOwner {
        limits.maxWalletSizeBps = _maxWalletSizeBps;
    }

    /**
     * @dev Set the minimum amount of tokens that a wallet must hold.
     * @param _minWalletSizeBps The minimum holding amount in bps (e.g., 100 for 1%).
     */
    function setMinWalletSize(uint32 _minWalletSizeBps) external onlyOwner {
        limits.minWalletSizeBps = _minWalletSizeBps;
    }

    /**
     * @dev Set the maximum amount of tokens that a wallet can buy.
     * @param _maxBuyBps The maximum buy size in bps (e.g., 100 for 1%).
     */
    function setMaxBuy(uint32 _maxBuyBps) external onlyOwner {
        limits.maxBuyBps = _maxBuyBps;
    }

    /**
     * @dev Set the maximum amount of tokens that a wallet can sell.
     * @param _maxSellBps The maximum sell size in bps (e.g., 100 for 1%).
     */
    function setMaxSell(uint32 _maxSellBps) external onlyOwner {
        limits.maxSellBps = _maxSellBps;
    }

    /**
     * @dev Set the tax percentage bps for buying transactions.
     * @param buyTax The buy tax bps (e.g., 100 for 1%).
     */
    function setBuyTax(uint32 buyTax) external onlyOwner {
        require(buyTax <= 10000 || buyTax < taxes.buyTaxBps, "Tax too high"); // Max 100%
        _setBuyTax(buyTax);
    }

    /**
     * @dev Internal logic to set the tax percentages bps for buying transactions.
     * @param buyTax The sell tax bps (e.g., 100 for 1%).
     */
    function _setBuyTax(uint32 buyTax) internal {
        taxes.buyTaxBps = buyTax;
    }

    /**
     * @dev Set the tax percentage bps for selling transactions.
     * @param sellTax The sell tax bps (e.g., 100 for 1%).
     */
    function setSellTax(uint32 sellTax) external onlyOwner {
        require(sellTax <= 10000 || sellTax < taxes.sellTaxBps, "Tax too high"); // Max 100%
        _setSellTax(sellTax);
    }

    /**
     * @dev Internal logic to set the tax percentage bps for selling transactions.
     * @param sellTax The sell tax bps (e.g., 100 for 1%).
     */
    function _setSellTax(uint32 sellTax) internal {
        taxes.sellTaxBps = sellTax;
    }

    /**
     * @dev Add liquidity to the AMM.
     */
    function addLiquidity() external payable onlyOwner {
        uniswapV2Router.addLiquidityETH{ value: msg.value }(
            address(this),
            _startingLiquidity,
            0,
            0,
            _devAddress,
            block.timestamp + 60
        );
    }
    
    /**
     * @dev Transfer contract ownership
     * @param newOwner Address of new owner.
     */
    function transferOwnership(address newOwner) public override onlyOwner {
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromLimits[msg.sender] = true;
        
        _isExcludedFromFees[newOwner] = true;
        _isExcludedFromLimits[newOwner] = true;
        super.transferOwnership(newOwner);
    }

    /**
     * @dev Enable trading for the token.
     */
    function start() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled");
        tradingEnabled = true;
        _launchBlock = block.number;
        _lastSwapBackBlock = block.number;
        emit EnableTrading();
    }

    /**
     * @dev Remove limits on transactions and wallet holdings.
     */
    function removeLimits() external onlyOwner {
        require(limited, "Limits already disabled");
        _removeLimits();
    }

    /**
     * @dev Internal logic for removing limits on transactions and wallet holdings.
     */
    function _removeLimits() internal {
        limited = false;
        limits.maxWalletSizeBps = DIVISOR;
        limits.minWalletSizeBps = 0;
        limits.maxBuyBps = DIVISOR;
        limits.maxSellBps = DIVISOR;
        emit RemoveLimits();
    }

    /**
     * @dev Remove anti-MEV transfer delay.
     */
    function removeTransferDelay() external onlyOwner {
        require(transferDelayEnabled, "Transfer delay already disabled");
        _removeTransferDelay();
    }

    /**
     * @dev Internal logic for removing anti-MEV transfer delay.
     */
    function _removeTransferDelay() internal {
        transferDelayEnabled = false;
        emit RemoveTransferDelay();
    }

    /**
     * @dev Renounce ownership and remove limits and tax.
     */
    function renounceOwnership() public override onlyOwner {
        _setBuyTax(0);
        _setSellTax(0);
        _removeLimits();
        _removeTransferDelay();
        if (!tradingEnabled) {
            tradingEnabled = true;
            _launchBlock = block.number;
            _lastSwapBackBlock = block.number;
        }
        super.renounceOwnership();
    }

    /**
     * @dev Check if wallet address is in exempt from tax.
     * @param account The address to check.
     */
    function isExcludedFromFees(address account) external view returns (bool) {
        return _isExcludedFromFees[account];
    }

    /**
     * @dev Check if wallet address is in exempt from limits.
     * @param account The address to check.
     */
    function isExcludedFromLimits(address account) external view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    /**
     * @dev Check if wallet address is in botlist
     * @param account The address to check.
     */
    function isBot(address account) external view returns (bool) {
        return _botlist[account];
    }

    /**
     * @dev Sets developer account.
     * @param account The list of addresses to botlist.
     */
    function setDevAddress(address account) external onlyOwner {
        _devAddress = account;
    }

    /**
     * @dev Sets tac account.
     * @param account The list of addresses to botlist.
     */
    function setTaxAddress(address account) external onlyOwner {
        _taxAddress = account;
    }

    /**
     * @dev Add an address to the botlist.
     * @param account The list of addresses to botlist.
     */
    function addBots(address[] calldata account) external onlyOwner {
        for (uint256 i = 0; i < account.length; i++) {
            _botlist[account[i]] = true;
        }
    }

    /**
     * @dev Remove an address from the botlist.
     * @param account The list of addresses to remove from botlist.
     */
    function removeBots(address[] calldata account) external onlyOwner {
        for (uint256 i = 0; i < account.length; i++) {
            _botlist[account[i]] = false;
        }
    }

    /**
     * @dev Exclude or include an address from transaction fees.
     * @param account The list of addresses to update.
     * @param excluded True to exclude, false to include.
     */
    function setExemptTax(address[] calldata account, bool excluded) external onlyOwner {
        for (uint256 i = 0; i < account.length; i++) {
            _isExcludedFromFees[account[i]] = excluded;
        }
    }

    /**
     * @dev Exclude or include an address from transaction limits.
     * @param account The list of addresses to update.
     * @param excluded True to exclude, false to include.
     */
    function setExemptLimits(address[] calldata account, bool excluded) external onlyOwner {
        for (uint256 i = 0; i < account.length; i++) {
            _isExcludedFromLimits[account[i]] = excluded;
        }
    }

    /**
     * @dev Swap tokens collected as tax (clogged tokens) for ETH.
     * Note: This function is called internally during transfers.
     */
    function _swapTokensForETH(uint256 tokenAmount) private {
        // Generate the Uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        // Make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            _taxAddress, // ETH received will be sent to the tax address
            block.timestamp
        );
    }

    /**
     * @dev Check if the transfer is within limits.
     * @param from The sender address.
     * @param to The recipient address.
     * @param amount The amount to transfer.
     */
    function checkLimits(address from, address to, uint256 amount) internal {
        if (limited) {
            Limits memory _limits = limits;
            
            // buy
            if (_isAMMPair[from] && !_isExcludedFromLimits[to]) {
                require(amount <= maxSupply.mulDiv(_limits.maxBuyBps, DIVISOR), "Max buy exceeded");
                require(balanceOf(to) + amount <= maxSupply.mulDiv(limits.maxWalletSizeBps, DIVISOR), "Buyer max wallet size exceeded");
            } 
            // sell
            else if (_isAMMPair[to] && !_isExcludedFromLimits[from]) {
                require(amount <= maxSupply.mulDiv(_limits.maxSellBps, DIVISOR), "Max sell exceeded");
                require(balanceOf(from) - amount >= maxSupply.mulDiv(limits.minWalletSizeBps, DIVISOR), "Sender below min holding");
            }

            if (!_isExcludedFromLimits[from] &&  !_isExcludedFromLimits[to]) {
                require(balanceOf(to) + amount <= maxSupply.mulDiv(limits.maxWalletSizeBps, DIVISOR), "Receiver max wallet size exceeded");
                require(balanceOf(to) + amount >= maxSupply.mulDiv(limits.minWalletSizeBps, DIVISOR), "Receiver below min holding");
                require(balanceOf(from) - amount >= maxSupply.mulDiv(limits.minWalletSizeBps, DIVISOR), "Sender below min holding");
            }
            
            if (transferDelayEnabled) {
                if (!_isExcludedFromLimits[from] && from != address(uniswapV2Router) && to != address(this)) {
                    require(_holderLastTransferBlock[tx.origin] + 10 < block.number, "Transfer Delay");
                }
                if (from != address(this) && to != address(this)) {
                    _holderLastTransferBlock[to] = block.number;
                    _holderLastTransferBlock[tx.origin] = block.number;
                }
                if (_isAMMPair[from] && !_isExcludedFromLimits[tx.origin]) {
                    require(tx.origin == to, "no buying to external wallets yet");
                }
            }
        }
    }

    /**
     * @dev Override the transfer function to include tax handling and other checks.
     * @param from The sender address.
     * @param to The recipient address.
     * @param amount The amount to transfer.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        if (!_isExcludedFromFees[from] || !_isExcludedFromFees[to]) {
            require(!_botlist[from] && !_botlist[to], "Bot");
            require(tradingEnabled, "Trading not enabled");
            amount -= handleTax(from, to, amount);
        }
        // Enforce wallet limits
        if (limited) {
            checkLimits(from, to, amount);
        }

        super._transfer(from, to, amount);
    }

    /**
     * @dev Calculates tax (if any)
     * @param from The sender address.
     * @param to The recipient address.
     * @param amount The amount to transfer.
     */
    function handleTax(address from, address to, uint256 amount) internal returns(uint256) {
        if (balanceOf(address(this)) >= 0 && _isAMMPair[to] && _lastSwapBackBlock + 2 <= block.number) {
            unclog(amount);
        }
        
        uint32 taxRate;
        if (_isAMMPair[to]){
            taxRate = taxes.sellTaxBps;
        } else if(_isAMMPair[from]){
            taxRate = taxes.buyTaxBps;
        }

        uint256 tax = 0;
        if (taxRate > 0) { 
            // prevent snipers coming immediately after launch
            if (_launchBlock == block.number) {
                if (_isAMMPair[from]) {
                    tax = amount.mulDiv(1000, DIVISOR);
                } else if (_isAMMPair[to]) {
                    tax = amount.mulDiv(5000, DIVISOR);
                }
            } else {
                tax = amount.mulDiv(taxRate, DIVISOR);
            }
            super._transfer(from, address(this), tax);
        }
        return tax;
    }

    /**
     * @dev Handles unclogging of tokens for the initial trading period.
     * @param amount The amount to unclog.
     */
    function unclog(uint256 amount) internal {
        if (amount > balanceOf(address(this))) {
            amount = balanceOf(address(this));
        }
        _swapTokensForETH(amount);
        _lastSwapBackBlock = block.number;
    }

    /**
     * @dev Public function to transfer tokens.
     * @param to The recipient address.
     * @param amount The amount to transfer.
     * @return True if the transfer was successful.
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    /**
     * @dev Public function to transfer tokens from a specified address.
     * @param from The sender address.
     * @param to The recipient address.
     * @param amount The amount to transfer.
     * @return True if the transfer was successful.
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = allowance(from, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        _transfer(from, to, amount);

        _approve(from, _msgSender(), currentAllowance - amount);
        return true;
    }

    /**
     * @dev Withdraws stuck eth to team.
     */
    function withdrawStuckETH() external nonReentrant {
        bool success;
        (success,) = address(_devAddress).call{value: address(this).balance}("");
    }

    /**
     * @dev Withdraws stuck tokens to team.
     */
    function rescueTokens(address _token) external nonReentrant {
        require(_token != address(0), "_token address cannot be 0");
        require(msg.sender == _devAddress || msg.sender == _taxAddress, "Only team can rescue");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        SafeERC20.safeTransfer(IERC20(_token),address(_devAddress), _contractBalance);
    }

    receive() payable external {}
}