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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { IERC20 } from "@openzeppelin-contracts-5.0.2/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin-contracts-5.0.2/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin-contracts-5.0.2/utils/ReentrancyGuard.sol";
import { SafeERC20 } from "@openzeppelin-contracts-5.0.2/token/ERC20/utils/SafeERC20.sol";

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract RISEPresale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    //----- variables
    IERC20 public iUSDT;
    IERC20 public riseToken;

    IUniswapV2Pair public ethPair;
    uint256 public presaleStartTime;
    bool public presaleStatus = false;
    bool public claimStatus = false;
    address payable public salesWallet;
    uint256 public actualNonce;

    uint256 public tokensSold;
    uint256 public actualStage;
    uint256 public usdtRaised;

    mapping(address => bool) isWERT;

    uint256[] public stageTokens =  [
        550_000_000*1e18,
        650_000_000*1e18,
        750_000_000*1e18,
        850_000_000*1e18,
        950_000_000*1e18,
        1_050_000_000*1e18,
        1_150_000_000*1e18,
        1_250_000_000*1e18,
        1_350_000_000*1e18,
        1_450_000_000*1e18,
        1_550_000_000*1e18,
        1_650_000_000*1e18,
        1_750_000_000*1e18,
        1_850_000_000*1e18,
        3_000_000_000*1e18
    ];

    uint256[] public stagePrices = [
        400,
        450,
        500,
        550,
        600,
        650,
        700,
        750,
        800,
        850,
        900,
        950,
        1000,
        1050,
        1100
    ];

    //----- bitmaps
    mapping(address => uint256) public mapClaimableTokenAmount;
    mapping(address => bool) public mapGotBonus;

    //----- structures
    struct UserBuys {
        uint256 boughtAmount;
    }

    //----- constants
    uint256 public constant stageStep = 5 days;

    //----- events
    event BoughtWithETH(uint256 _tokenAmount, address _buyer, uint256 _nonce);
    event BoughtWithUSDT(uint256 _tokenAmount, address _buyer, uint256 _nonce);
    event BoughtWithFIAT(uint256 _tokenAmount, address _buyer, uint256 _nonce);
    event SaleOpend(bool _opened);
    event ClaimOpend(bool _opened);
    event TokensClaimd(address _claimer, uint256 _amount);
    event ClaimTokenSet(address _token);

    /// contract constructor
    /// @param _salesWallet funds receiving wallet
    /// @param _tokenUSDT address of usdt token
    /// @param _wethPair address of token swaps weth/usdt pair token
    constructor(address _owner, address _salesWallet, address _tokenUSDT, address _wethPair) Ownable(msg.sender) {
        salesWallet = payable(_salesWallet);
        
        iUSDT = IERC20(_tokenUSDT);
        ethPair = IUniswapV2Pair(_wethPair);

        tokensSold = 0;
        actualStage = 0;

        isWERT[0x8CD81e14cD612FB5dAb211A837b6f9Ce191AD758] = true;
        isWERT[0x49B38424D3bef76c6B310305ffA0a6EC182b348B] = true;

        mapClaimableTokenAmount[0x909909C3471EAd3453E79caf43E9945E29a741cb] = 2500*1e18;
        mapClaimableTokenAmount[0x8A343C7e5D07B01C964fBC4D2f3632C08B0c3670] = 125575*1e18;
        mapClaimableTokenAmount[0x58103Aa766e10d8954c589728a9d9EF40953fe7C] = 9997500*1e18;
        mapClaimableTokenAmount[0xB58F23e81d63AeaBDbfB248B7a6b6C748d675B37] = 110617*1e18;
        mapClaimableTokenAmount[0x2Ad64519fA06FC13B13d8A66Bd6CC3dDd5210eaf] = 2498*1e18;
        mapClaimableTokenAmount[0x18dd53EB90Adc4a1291B076A267F3297261C149D] = 213031*1e18;
        mapClaimableTokenAmount[0xB321830FFe7d3F34972E5bF88Ea7c9C3A61EAE97] = 33495*1e18;
        mapClaimableTokenAmount[0x66AA683F7F601B5fA8C78F68C3b7a8B03C136958] = 419645*1e18;
        mapClaimableTokenAmount[0x3b5fC342538966d73e8967A9BdE653F40134cc57] = 7812*1e18;
        mapClaimableTokenAmount[0x60060BCcC5c3F3A5F3682Dd07AA186D8676aFD7e] = 1116*1e18;
        mapClaimableTokenAmount[0xE793e1418a1B629562fa9299D140104244D4FcDD] = 212500*1e18;
        mapClaimableTokenAmount[0x550f80973A03389B5fB447C1d9bd4392cA99b076] = 125000*1e18;

        openSale();

        transferOwnership(_owner);
    }

    modifier RaiseStage {
        _;

        uint256 tokensLeft = stageTokens[actualStage];
        if(tokensLeft <= 1000*1e8) setRaiseStage();
    }

    //----- public functions

    /// Function to buy with USDT needs approvale first
    /// @param _usdtValue     amount of tokens to be bought
    function buyWithUSDT(uint256 _usdtValue) public nonReentrant RaiseStage {
        iUSDT.safeTransferFrom(msg.sender, salesWallet, _usdtValue);
        (uint256 tokenAmount, uint256 tokenBonus, bool _bonus )  = getTokenAmountByValue(_usdtValue, msg.sender);

        require(tokenAmount <= stageTokens[actualStage], "RISEPresasle: Not enough tokens left in that stage!");

        addToLists(msg.sender, tokenAmount, tokenBonus, _bonus);

        emit BoughtWithUSDT(tokenAmount, msg.sender, actualNonce);
        usdtRaised = usdtRaised + _usdtValue;
    }

    /// Function to buy tokens with eth no approval needed
    function buyWithETH() public payable nonReentrant RaiseStage {
        require(msg.value >= 0, "RISEPresale: Not enough ETH sent");
        uint256 ethPrice = getETHPrice();
        uint256 _usdtValue = (msg.value * ethPrice) / 10 ** 18;
        
        (uint256 tokenAmount, uint256 tokenBonus, bool _bonus ) = getTokenAmountByValue(_usdtValue, msg.sender);

        require(tokenAmount <= stageTokens[actualStage], "RISEPresasle: Not enough tokens left in that stage!");

        salesWallet.transfer(msg.value);

        addToLists(msg.sender, tokenAmount, tokenBonus, _bonus);

        emit BoughtWithETH(tokenAmount, msg.sender, actualNonce);
        usdtRaised = usdtRaised + _usdtValue;
    }

    /// function to return the actual stage price
    function getActualStagePrice() public view returns (uint256) {
        uint256 priceRaise = 0;
        uint256 daysGone = (block.timestamp - presaleStartTime) / 60 / 60 / 24;
        uint256 periodsGone = daysGone / 5;

        if (periodsGone < 10) {
            priceRaise = periodsGone * 4;
        } else {
            priceRaise = 40;
        }

        return stagePrices[actualStage] + priceRaise;
    }

    /// Function to buy tokens with FIAT using wert.io
    /// @param _buyer            address of the buyer
    function buyWithWert(address _buyer, uint256 _usdtValue) public nonReentrant RaiseStage {
        require(isWERT[msg.sender] == true, "RISEEVM: Need to be a WERT Wallet.");
        (uint256 tokenAmount, uint256 tokenBonus, bool _bonus)  = getTokenAmountByValue(_usdtValue, _buyer);

        require(tokenAmount <= stageTokens[actualStage], "RISEPresasle: Not enough tokens left in that stage!");

        iUSDT.safeTransferFrom(msg.sender, salesWallet, _usdtValue);

        addToLists(_buyer, tokenAmount, tokenBonus, _bonus);

        emit BoughtWithFIAT(tokenAmount, _buyer, actualNonce);
        usdtRaised = usdtRaised + _usdtValue;
    }

    /// calculating ETH Value from usdtValue
    /// @param _usdtValue   usdtValue calculated from tokenamound and price
    function calculateETHValue(uint256 _usdtValue) public view returns (uint256) {
        uint256 ethPrice = getETHPrice();

        uint256 ethValue = _usdtValue / ethPrice;

        return ethValue;
    }

    /// Fetching ether price from UniswapV2Pair
    function getETHPrice() public view returns(uint256) {
        (uint256 res0, uint256 res1, ) = ethPair.getReserves();
        
        return ((res1 * 1e18) / res0);
    }

    function addToLists(address _buyer, uint256 _amount, uint256 _bonusToken, bool _bonus) internal {
        mapClaimableTokenAmount[_buyer] = mapClaimableTokenAmount[_buyer] + ((_amount + _bonusToken)*1e18);

        stageTokens[actualStage] = stageTokens[actualStage] - _amount*1e18;
        if(mapGotBonus[_buyer] == false) mapGotBonus[_buyer] = _bonus;
        tokensSold = tokensSold + (_amount * 1e18);
    }

    /// Returns the amount of token calculated by usdt value
    /// @param _usdtValue value of sent usdt
    function getTokenAmountByValue(uint256 _usdtValue, address _buyer) public view returns(uint256, uint256, bool) {
        uint256 tokenBonus = 0;

        uint256 tokenPrice = getActualStagePrice();

        uint256 firstTokenAmount = _usdtValue / tokenPrice;

        if(mapGotBonus[_buyer] == false){
            if(_usdtValue > 4_999_999_999) {
                tokenBonus = (firstTokenAmount * 25) / 100;
                return (firstTokenAmount, tokenBonus, true);
            } else if(_usdtValue > 2_499_999_999) {
                tokenBonus = (firstTokenAmount * 20) / 100;
                return (firstTokenAmount, tokenBonus, true);
            } else if(_usdtValue > 999_999_999) {
                tokenBonus = (firstTokenAmount * 15) / 100;
                return (firstTokenAmount, tokenBonus, true);
            } else if(_usdtValue > 249_999_999) {
                tokenBonus = (firstTokenAmount * 10) / 100;
                return (firstTokenAmount, tokenBonus, true);
            } else if(_usdtValue > 99999999) {
                tokenBonus = (firstTokenAmount * 5) / 100;
                return (firstTokenAmount, tokenBonus, true);
           }
        }

        return (firstTokenAmount, 0, false);
    }

    //----- owner functions

    function addManualTokens(address _buyer, uint256 _amount, uint256 _bonusToken, bool _bonus) public onlyOwner {
        addToLists(_buyer, _amount, _bonusToken, _bonus);
    }

    /// Function to force stage rise, if presale wents to slow
    function setRaiseStage() public onlyOwner {
        actualStage++;
        stageTokens[actualStage] = stageTokens[actualStage] + stageTokens[actualStage-1];
        presaleStartTime = block.timestamp;
    }

    /// Function to trigger the presale status (selling/not selling)
    function openSale() public onlyOwner() {
        require(presaleStatus != true && claimStatus != true, "RISEPresale: Sale already opened.");

        presaleStatus = true;
        presaleStartTime = block.timestamp;

        emit SaleOpend(true);
    }

    /// Function to close sale and open claim
    function closeSale() public onlyOwner() {
        require(presaleStatus == true && claimStatus != true && address(riseToken) != address(0), "RISEPresale: Sale is closed, claming started!");

        presaleStatus = false;
        claimStatus = true;

        emit ClaimOpend(true);
    }

    /// function to set the tokenaddress, only once runable
    /// @param _token address of the sold token
    function setTokenAddress(address _token) public onlyOwner {
        require(address(riseToken) == address(0), "RISEPresale: Token already set");

        riseToken = IERC20(_token);

        emit ClaimTokenSet(_token);
    }
}