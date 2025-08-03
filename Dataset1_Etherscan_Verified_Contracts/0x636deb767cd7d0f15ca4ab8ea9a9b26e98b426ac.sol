// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/Clones.sol)

pragma solidity ^0.8.20;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 */
library Clones {
    /**
     * @dev A clone instance deployment failed.
     */
    error ERC1167FailedCreateClone();

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        if (instance == address(0)) {
            revert ERC1167FailedCreateClone();
        }
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        if (instance == address(0)) {
            revert ERC1167FailedCreateClone();
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
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
pragma solidity 0.8.24;

import {IERC20} from "openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IGovernance, UNREGISTERED_INITIATIVE} from "./interfaces/IGovernance.sol";
import {IInitiative} from "./interfaces/IInitiative.sol";
import {ILQTYStaking} from "./interfaces/ILQTYStaking.sol";

import {UserProxy} from "./UserProxy.sol";
import {UserProxyFactory} from "./UserProxyFactory.sol";

import {add, sub, max} from "./utils/Math.sol";
import {_requireNoDuplicates, _requireNoNegatives} from "./utils/UniqueArray.sol";
import {MultiDelegateCall} from "./utils/MultiDelegateCall.sol";
import {WAD, PermitParams} from "./utils/Types.sol";
import {safeCallWithMinGas} from "./utils/SafeCallMinGas.sol";
import {Ownable} from "./utils/Ownable.sol";
import {_lqtyToVotes} from "./utils/VotingPower.sol";

/// @title Governance: Modular Initiative based Governance
contract Governance is MultiDelegateCall, UserProxyFactory, ReentrancyGuard, Ownable, IGovernance {
    using SafeERC20 for IERC20;

    uint256 constant MIN_GAS_TO_HOOK = 350_000;

    /// Replace this to ensure hooks have sufficient gas

    /// @inheritdoc IGovernance
    ILQTYStaking public immutable stakingV1;
    /// @inheritdoc IGovernance
    IERC20 public immutable lqty;
    /// @inheritdoc IGovernance
    IERC20 public immutable bold;
    /// @inheritdoc IGovernance
    uint256 public immutable EPOCH_START;
    /// @inheritdoc IGovernance
    uint256 public immutable EPOCH_DURATION;
    /// @inheritdoc IGovernance
    uint256 public immutable EPOCH_VOTING_CUTOFF;
    /// @inheritdoc IGovernance
    uint256 public immutable MIN_CLAIM;
    /// @inheritdoc IGovernance
    uint256 public immutable MIN_ACCRUAL;
    /// @inheritdoc IGovernance
    uint256 public immutable REGISTRATION_FEE;
    /// @inheritdoc IGovernance
    uint256 public immutable REGISTRATION_THRESHOLD_FACTOR;
    /// @inheritdoc IGovernance
    uint256 public immutable UNREGISTRATION_THRESHOLD_FACTOR;
    /// @inheritdoc IGovernance
    uint256 public immutable UNREGISTRATION_AFTER_EPOCHS;
    /// @inheritdoc IGovernance
    uint256 public immutable VOTING_THRESHOLD_FACTOR;

    /// @inheritdoc IGovernance
    uint256 public boldAccrued;

    /// @inheritdoc IGovernance
    VoteSnapshot public votesSnapshot;
    /// @inheritdoc IGovernance
    mapping(address => InitiativeVoteSnapshot) public votesForInitiativeSnapshot;

    /// @inheritdoc IGovernance
    GlobalState public globalState;
    /// @inheritdoc IGovernance
    mapping(address => UserState) public userStates;
    /// @inheritdoc IGovernance
    mapping(address => InitiativeState) public initiativeStates;
    /// @inheritdoc IGovernance
    mapping(address => mapping(address => Allocation)) public lqtyAllocatedByUserToInitiative;
    /// @inheritdoc IGovernance
    mapping(address => uint256) public override registeredInitiatives;

    constructor(
        address _lqty,
        address _lusd,
        address _stakingV1,
        address _bold,
        Configuration memory _config,
        address _owner,
        address[] memory _initiatives
    ) UserProxyFactory(_lqty, _lusd, _stakingV1) Ownable(_owner) {
        stakingV1 = ILQTYStaking(_stakingV1);
        lqty = IERC20(_lqty);
        bold = IERC20(_bold);
        require(_config.minClaim <= _config.minAccrual, "Gov: min-claim-gt-min-accrual");
        REGISTRATION_FEE = _config.registrationFee;

        // Registration threshold must be below 100% of votes
        require(_config.registrationThresholdFactor < WAD, "Gov: registration-config");
        REGISTRATION_THRESHOLD_FACTOR = _config.registrationThresholdFactor;

        // Unregistration must be X times above the `votingThreshold`
        require(_config.unregistrationThresholdFactor > WAD, "Gov: unregistration-config");
        UNREGISTRATION_THRESHOLD_FACTOR = _config.unregistrationThresholdFactor;
        UNREGISTRATION_AFTER_EPOCHS = _config.unregistrationAfterEpochs;

        // Voting threshold must be below 100% of votes
        require(_config.votingThresholdFactor < WAD, "Gov: voting-config");
        VOTING_THRESHOLD_FACTOR = _config.votingThresholdFactor;

        MIN_CLAIM = _config.minClaim;
        MIN_ACCRUAL = _config.minAccrual;
        require(_config.epochStart <= block.timestamp, "Gov: cannot-start-in-future");
        EPOCH_START = _config.epochStart;
        require(_config.epochDuration > 0, "Gov: epoch-duration-zero");
        EPOCH_DURATION = _config.epochDuration;
        require(_config.epochVotingCutoff < _config.epochDuration, "Gov: epoch-voting-cutoff-gt-epoch-duration");
        EPOCH_VOTING_CUTOFF = _config.epochVotingCutoff;

        if (_initiatives.length > 0) {
            registerInitialInitiatives(_initiatives);
        }
    }

    function registerInitialInitiatives(address[] memory _initiatives) public onlyOwner {
        for (uint256 i = 0; i < _initiatives.length; i++) {
            // Register initial initiatives in the earliest possible epoch, which lets us make them votable immediately
            // post-deployment if we so choose, by backdating the first epoch at least EPOCH_DURATION in the past.
            registeredInitiatives[_initiatives[i]] = 1;

            bool success = safeCallWithMinGas(
                _initiatives[i], MIN_GAS_TO_HOOK, 0, abi.encodeCall(IInitiative.onRegisterInitiative, (1))
            );

            emit RegisterInitiative(_initiatives[i], msg.sender, 1, success ? HookStatus.Succeeded : HookStatus.Failed);
        }

        _renounceOwnership();
    }

    /*//////////////////////////////////////////////////////////////
                                STAKING
    //////////////////////////////////////////////////////////////*/

    function _increaseUserVoteTrackers(uint256 _lqtyAmount) private returns (UserProxy) {
        require(_lqtyAmount > 0, "Governance: zero-lqty-amount");

        address userProxyAddress = deriveUserProxyAddress(msg.sender);

        if (userProxyAddress.code.length == 0) {
            deployUserProxy();
        }

        UserProxy userProxy = UserProxy(payable(userProxyAddress));

        // update the vote power trackers
        userStates[msg.sender].unallocatedLQTY += _lqtyAmount;
        userStates[msg.sender].unallocatedOffset += block.timestamp * _lqtyAmount;

        return userProxy;
    }

    /// @inheritdoc IGovernance
    function depositLQTY(uint256 _lqtyAmount) external {
        depositLQTY(_lqtyAmount, false, msg.sender);
    }

    function depositLQTY(uint256 _lqtyAmount, bool _doSendRewards, address _recipient) public nonReentrant {
        UserProxy userProxy = _increaseUserVoteTrackers(_lqtyAmount);

        (uint256 lusdReceived, uint256 lusdSent, uint256 ethReceived, uint256 ethSent) =
            userProxy.stake(_lqtyAmount, msg.sender, _doSendRewards, _recipient);

        emit DepositLQTY(msg.sender, _recipient, _lqtyAmount, lusdReceived, lusdSent, ethReceived, ethSent);
    }

    /// @inheritdoc IGovernance
    function depositLQTYViaPermit(uint256 _lqtyAmount, PermitParams calldata _permitParams) external {
        depositLQTYViaPermit(_lqtyAmount, _permitParams, false, msg.sender);
    }

    function depositLQTYViaPermit(
        uint256 _lqtyAmount,
        PermitParams calldata _permitParams,
        bool _doSendRewards,
        address _recipient
    ) public nonReentrant {
        UserProxy userProxy = _increaseUserVoteTrackers(_lqtyAmount);

        (uint256 lusdReceived, uint256 lusdSent, uint256 ethReceived, uint256 ethSent) =
            userProxy.stakeViaPermit(_lqtyAmount, msg.sender, _permitParams, _doSendRewards, _recipient);

        emit DepositLQTY(msg.sender, _recipient, _lqtyAmount, lusdReceived, lusdSent, ethReceived, ethSent);
    }

    /// @inheritdoc IGovernance
    function withdrawLQTY(uint256 _lqtyAmount) external {
        withdrawLQTY(_lqtyAmount, true, msg.sender);
    }

    function withdrawLQTY(uint256 _lqtyAmount, bool _doSendRewards, address _recipient) public nonReentrant {
        UserState storage userState = userStates[msg.sender];

        UserProxy userProxy = UserProxy(payable(deriveUserProxyAddress(msg.sender)));
        require(address(userProxy).code.length != 0, "Governance: user-proxy-not-deployed");

        // check if user has enough unallocated lqty
        require(_lqtyAmount <= userState.unallocatedLQTY, "Governance: insufficient-unallocated-lqty");

        // Update the offset tracker
        if (_lqtyAmount < userState.unallocatedLQTY) {
            // The offset decrease is proportional to the partial lqty decrease
            uint256 offsetDecrease = _lqtyAmount * userState.unallocatedOffset / userState.unallocatedLQTY;
            userState.unallocatedOffset -= offsetDecrease;
        } else {
            // if _lqtyAmount == userState.unallocatedLqty, zero the offset tracker
            userState.unallocatedOffset = 0;
        }

        // Update the user's LQTY tracker
        userState.unallocatedLQTY -= _lqtyAmount;

        (
            uint256 lqtyReceived,
            uint256 lqtySent,
            uint256 lusdReceived,
            uint256 lusdSent,
            uint256 ethReceived,
            uint256 ethSent
        ) = userProxy.unstake(_lqtyAmount, _doSendRewards, _recipient);

        emit WithdrawLQTY(msg.sender, _recipient, lqtyReceived, lqtySent, lusdReceived, lusdSent, ethReceived, ethSent);
    }

    /// @inheritdoc IGovernance
    function claimFromStakingV1(address _rewardRecipient) external returns (uint256 lusdSent, uint256 ethSent) {
        address payable userProxyAddress = payable(deriveUserProxyAddress(msg.sender));
        require(userProxyAddress.code.length != 0, "Governance: user-proxy-not-deployed");

        uint256 lqtyReceived;
        uint256 lqtySent;
        uint256 lusdReceived;
        uint256 ethReceived;

        (lqtyReceived, lqtySent, lusdReceived, lusdSent, ethReceived, ethSent) =
            UserProxy(userProxyAddress).unstake(0, true, _rewardRecipient);

        emit WithdrawLQTY(
            msg.sender, _rewardRecipient, lqtyReceived, lqtySent, lusdReceived, lusdSent, ethReceived, ethSent
        );
    }

    /*//////////////////////////////////////////////////////////////
                                 VOTING
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IGovernance
    function epoch() public view returns (uint256) {
        return ((block.timestamp - EPOCH_START) / EPOCH_DURATION) + 1;
    }

    /// @inheritdoc IGovernance
    function epochStart() public view returns (uint256) {
        return EPOCH_START + (epoch() - 1) * EPOCH_DURATION;
    }

    /// @inheritdoc IGovernance
    function secondsWithinEpoch() public view returns (uint256) {
        return (block.timestamp - EPOCH_START) % EPOCH_DURATION;
    }

    /// @inheritdoc IGovernance
    function lqtyToVotes(uint256 _lqtyAmount, uint256 _timestamp, uint256 _offset) public pure returns (uint256) {
        return _lqtyToVotes(_lqtyAmount, _timestamp, _offset);
    }

    /*//////////////////////////////////////////////////////////////
                                 SNAPSHOTS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IGovernance
    function getLatestVotingThreshold() public view returns (uint256) {
        uint256 snapshotVotes = votesSnapshot.votes;

        return calculateVotingThreshold(snapshotVotes);
    }

    /// @inheritdoc IGovernance
    function calculateVotingThreshold() public returns (uint256) {
        (VoteSnapshot memory snapshot,) = _snapshotVotes();

        return calculateVotingThreshold(snapshot.votes);
    }

    /// @inheritdoc IGovernance
    function calculateVotingThreshold(uint256 _votes) public view returns (uint256) {
        if (_votes == 0) return 0;

        uint256 minVotes; // to reach MIN_CLAIM: snapshotVotes * MIN_CLAIM / boldAccrued
        uint256 payoutPerVote = boldAccrued * WAD / _votes;
        if (payoutPerVote != 0) {
            minVotes = MIN_CLAIM * WAD / payoutPerVote;
        }
        return max(_votes * VOTING_THRESHOLD_FACTOR / WAD, minVotes);
    }

    // Snapshots votes at the end of the previous epoch
    // Accrues funds until the first activity of the current epoch, which are valid throughout all of the current epoch
    function _snapshotVotes() internal returns (VoteSnapshot memory snapshot, GlobalState memory state) {
        bool shouldUpdate;
        (snapshot, state, shouldUpdate) = getTotalVotesAndState();

        if (shouldUpdate) {
            votesSnapshot = snapshot;
            uint256 boldBalance = bold.balanceOf(address(this));
            boldAccrued = (boldBalance < MIN_ACCRUAL) ? 0 : boldBalance;
            emit SnapshotVotes(snapshot.votes, snapshot.forEpoch, boldAccrued);
        }
    }

    /// @inheritdoc IGovernance
    function getTotalVotesAndState()
        public
        view
        returns (VoteSnapshot memory snapshot, GlobalState memory state, bool shouldUpdate)
    {
        uint256 currentEpoch = epoch();
        snapshot = votesSnapshot;
        state = globalState;

        if (snapshot.forEpoch < currentEpoch - 1) {
            shouldUpdate = true;

            snapshot.votes = lqtyToVotes(state.countedVoteLQTY, epochStart(), state.countedVoteOffset);
            snapshot.forEpoch = currentEpoch - 1;
        }
    }

    // Snapshots votes for an initiative for the previous epoch
    function _snapshotVotesForInitiative(address _initiative)
        internal
        returns (InitiativeVoteSnapshot memory initiativeSnapshot, InitiativeState memory initiativeState)
    {
        bool shouldUpdate;
        (initiativeSnapshot, initiativeState, shouldUpdate) = getInitiativeSnapshotAndState(_initiative);

        if (shouldUpdate) {
            votesForInitiativeSnapshot[_initiative] = initiativeSnapshot;
            emit SnapshotVotesForInitiative(
                _initiative, initiativeSnapshot.votes, initiativeSnapshot.vetos, initiativeSnapshot.forEpoch
            );
        }
    }

    /// @inheritdoc IGovernance
    function getInitiativeSnapshotAndState(address _initiative)
        public
        view
        returns (
            InitiativeVoteSnapshot memory initiativeSnapshot,
            InitiativeState memory initiativeState,
            bool shouldUpdate
        )
    {
        // Get the storage data
        uint256 currentEpoch = epoch();
        initiativeSnapshot = votesForInitiativeSnapshot[_initiative];
        initiativeState = initiativeStates[_initiative];

        if (initiativeSnapshot.forEpoch < currentEpoch - 1) {
            shouldUpdate = true;

            uint256 start = epochStart();
            uint256 votes = lqtyToVotes(initiativeState.voteLQTY, start, initiativeState.voteOffset);
            uint256 vetos = lqtyToVotes(initiativeState.vetoLQTY, start, initiativeState.vetoOffset);
            initiativeSnapshot.votes = votes;
            initiativeSnapshot.vetos = vetos;

            initiativeSnapshot.forEpoch = currentEpoch - 1;
        }
    }

    /// @inheritdoc IGovernance
    function snapshotVotesForInitiative(address _initiative)
        external
        nonReentrant
        returns (VoteSnapshot memory voteSnapshot, InitiativeVoteSnapshot memory initiativeVoteSnapshot)
    {
        (voteSnapshot,) = _snapshotVotes();
        (initiativeVoteSnapshot,) = _snapshotVotesForInitiative(_initiative);
    }

    /*//////////////////////////////////////////////////////////////
                                 FSM
    //////////////////////////////////////////////////////////////*/

    /// @notice Given an inititive address, updates all snapshots and return the initiative state
    ///     See the view version of `getInitiativeState` for the underlying logic on Initatives FSM
    function getInitiativeState(address _initiative)
        public
        returns (InitiativeStatus status, uint256 lastEpochClaim, uint256 claimableAmount)
    {
        (VoteSnapshot memory votesSnapshot_,) = _snapshotVotes();
        (InitiativeVoteSnapshot memory votesForInitiativeSnapshot_, InitiativeState memory initiativeState) =
            _snapshotVotesForInitiative(_initiative);

        return getInitiativeState(_initiative, votesSnapshot_, votesForInitiativeSnapshot_, initiativeState);
    }

    /// @dev Given an initiative address and its snapshot, determines the current state for an initiative
    function getInitiativeState(
        address _initiative,
        VoteSnapshot memory _votesSnapshot,
        InitiativeVoteSnapshot memory _votesForInitiativeSnapshot,
        InitiativeState memory _initiativeState
    ) public view returns (InitiativeStatus status, uint256 lastEpochClaim, uint256 claimableAmount) {
        uint256 initiativeRegistrationEpoch = registeredInitiatives[_initiative];

        // == Non existent Condition == //
        if (initiativeRegistrationEpoch == 0) {
            return (InitiativeStatus.NONEXISTENT, 0, 0);
            /// By definition it has zero rewards
        }

        uint256 currentEpoch = epoch();

        // == Just Registered Condition == //
        if (initiativeRegistrationEpoch == currentEpoch) {
            return (InitiativeStatus.WARM_UP, 0, 0);
            /// Was registered this week, cannot have rewards
        }

        // Fetch last epoch at which we claimed
        lastEpochClaim = initiativeStates[_initiative].lastEpochClaim;

        // == Disabled Condition == //
        if (initiativeRegistrationEpoch == UNREGISTERED_INITIATIVE) {
            return (InitiativeStatus.DISABLED, lastEpochClaim, 0);
            /// By definition it has zero rewards
        }

        // == Already Claimed Condition == //
        if (lastEpochClaim >= currentEpoch - 1) {
            // early return, we have already claimed
            return (InitiativeStatus.CLAIMED, lastEpochClaim, claimableAmount);
        }

        // NOTE: Pass the snapshot value so we get accurate result
        uint256 votingTheshold = calculateVotingThreshold(_votesSnapshot.votes);

        // If it's voted and can get rewards
        // Votes > calculateVotingThreshold
        // == Rewards Conditions (votes can be zero, logic is the same) == //

        // By definition if _votesForInitiativeSnapshot.votes > 0 then _votesSnapshot.votes > 0
        if (
            _votesForInitiativeSnapshot.votes > votingTheshold
                && _votesForInitiativeSnapshot.votes > _votesForInitiativeSnapshot.vetos
        ) {
            uint256 claim = _votesForInitiativeSnapshot.votes * boldAccrued / _votesSnapshot.votes;

            return (InitiativeStatus.CLAIMABLE, lastEpochClaim, claim);
        }

        // == Unregister Condition == //
        // e.g. if `UNREGISTRATION_AFTER_EPOCHS` is 4, the initiative will become unregisterable after spending 4 epochs
        // while being in one of the following conditions:
        //  - in `SKIP` state (not having received enough votes to cross the voting threshold)
        //  - in `CLAIMABLE` state (having received enough votes to cross the voting threshold) but never being claimed
        if (
            (_initiativeState.lastEpochClaim + UNREGISTRATION_AFTER_EPOCHS < currentEpoch - 1)
                || _votesForInitiativeSnapshot.vetos > _votesForInitiativeSnapshot.votes
                    && _votesForInitiativeSnapshot.vetos > votingTheshold * UNREGISTRATION_THRESHOLD_FACTOR / WAD
        ) {
            return (InitiativeStatus.UNREGISTERABLE, lastEpochClaim, 0);
        }

        // == Not meeting threshold Condition == //
        return (InitiativeStatus.SKIP, lastEpochClaim, 0);
    }

    /// @inheritdoc IGovernance
    function registerInitiative(address _initiative) external nonReentrant {
        uint256 currentEpoch = epoch();
        require(currentEpoch > 2, "Governance: registration-not-yet-enabled");

        require(_initiative != address(0), "Governance: zero-address");
        (InitiativeStatus status,,) = getInitiativeState(_initiative);
        require(status == InitiativeStatus.NONEXISTENT, "Governance: initiative-already-registered");

        address userProxyAddress = deriveUserProxyAddress(msg.sender);
        (VoteSnapshot memory snapshot,) = _snapshotVotes();
        UserState memory userState = userStates[msg.sender];

        bold.safeTransferFrom(msg.sender, address(this), REGISTRATION_FEE);

        // an initiative can be registered if the registrant has more voting power (LQTY * age)
        // than the registration threshold derived from the previous epoch's total global votes

        uint256 upscaledSnapshotVotes = snapshot.votes;

        uint256 totalUserOffset = userState.allocatedOffset + userState.unallocatedOffset;
        require(
            // Check against the user's total voting power, so include both allocated and unallocated LQTY
            lqtyToVotes(stakingV1.stakes(userProxyAddress), epochStart(), totalUserOffset)
                >= upscaledSnapshotVotes * REGISTRATION_THRESHOLD_FACTOR / WAD,
            "Governance: insufficient-lqty"
        );

        registeredInitiatives[_initiative] = currentEpoch;

        /// This ensures that the initiatives has UNREGISTRATION_AFTER_EPOCHS even after the first epoch
        initiativeStates[_initiative].lastEpochClaim = currentEpoch - 1;

        // Replaces try / catch | Enforces sufficient gas is passed
        bool success = safeCallWithMinGas(
            _initiative, MIN_GAS_TO_HOOK, 0, abi.encodeCall(IInitiative.onRegisterInitiative, (currentEpoch))
        );

        emit RegisterInitiative(
            _initiative, msg.sender, currentEpoch, success ? HookStatus.Succeeded : HookStatus.Failed
        );
    }

    struct ResetInitiativeData {
        address initiative;
        int256 LQTYVotes;
        int256 LQTYVetos;
        int256 OffsetVotes;
        int256 OffsetVetos;
    }

    /// @dev Resets an initiative and return the previous votes
    /// NOTE: Technically we don't need vetos
    /// NOTE: Technically we want to populate the `ResetInitiativeData` only when `secondsWithinEpoch() > EPOCH_VOTING_CUTOFF`
    function _resetInitiatives(address[] calldata _initiativesToReset)
        internal
        returns (ResetInitiativeData[] memory)
    {
        ResetInitiativeData[] memory cachedData = new ResetInitiativeData[](_initiativesToReset.length);

        int256[] memory deltaLQTYVotes = new int256[](_initiativesToReset.length);
        int256[] memory deltaLQTYVetos = new int256[](_initiativesToReset.length);
        int256[] memory deltaOffsetVotes = new int256[](_initiativesToReset.length);
        int256[] memory deltaOffsetVetos = new int256[](_initiativesToReset.length);

        // Prepare reset data
        for (uint256 i; i < _initiativesToReset.length; i++) {
            Allocation memory alloc = lqtyAllocatedByUserToInitiative[msg.sender][_initiativesToReset[i]];
            require(alloc.voteLQTY > 0 || alloc.vetoLQTY > 0, "Governance: nothing to reset");

            // Cache, used to enforce limits later
            cachedData[i] = ResetInitiativeData({
                initiative: _initiativesToReset[i],
                LQTYVotes: int256(alloc.voteLQTY),
                LQTYVetos: int256(alloc.vetoLQTY),
                OffsetVotes: int256(alloc.voteOffset),
                OffsetVetos: int256(alloc.vetoOffset)
            });

            // -0 is still 0, so its fine to flip both
            deltaLQTYVotes[i] = -(cachedData[i].LQTYVotes);
            deltaLQTYVetos[i] = -(cachedData[i].LQTYVetos);
            deltaOffsetVotes[i] = -(cachedData[i].OffsetVotes);
            deltaOffsetVetos[i] = -(cachedData[i].OffsetVetos);
        }

        // RESET HERE || All initiatives will receive most updated data and 0 votes / vetos
        _allocateLQTY(_initiativesToReset, deltaLQTYVotes, deltaLQTYVetos, deltaOffsetVotes, deltaOffsetVetos);

        return cachedData;
    }

    /// @inheritdoc IGovernance
    function resetAllocations(address[] calldata _initiativesToReset, bool checkAll) external nonReentrant {
        _requireNoDuplicates(_initiativesToReset);
        _resetInitiatives(_initiativesToReset);

        // NOTE: In most cases, the check will pass
        // But if you allocate too many initiatives, we may run OOG
        // As such the check is optional here
        // All other calls to the system enforce this
        // So it's recommended that your last call to `resetAllocations` passes the check
        if (checkAll) {
            require(userStates[msg.sender].allocatedLQTY == 0, "Governance: must be a reset");
        }
    }

    /// @inheritdoc IGovernance
    function allocateLQTY(
        address[] calldata _initiativesToReset,
        address[] calldata _initiatives,
        int256[] calldata _absoluteLQTYVotes,
        int256[] calldata _absoluteLQTYVetos
    ) external nonReentrant {
        require(
            _initiatives.length == _absoluteLQTYVotes.length && _absoluteLQTYVotes.length == _absoluteLQTYVetos.length,
            "Governance: array-length-mismatch"
        );

        // To ensure the change is safe, enforce uniqueness
        _requireNoDuplicates(_initiativesToReset);
        _requireNoDuplicates(_initiatives);

        // Explicit >= 0 checks for all values since we reset values below
        _requireNoNegatives(_absoluteLQTYVotes);
        _requireNoNegatives(_absoluteLQTYVetos);
        // If the goal is to remove all votes from an initiative, including in _initiativesToReset is enough
        _requireNoNOP(_absoluteLQTYVotes, _absoluteLQTYVetos);
        _requireNoSimultaneousVoteAndVeto(_absoluteLQTYVotes, _absoluteLQTYVetos);

        // You MUST always reset
        ResetInitiativeData[] memory cachedData = _resetInitiatives(_initiativesToReset);

        /// Invariant, 0 allocated = 0 votes
        UserState memory userState = userStates[msg.sender];
        require(userState.allocatedLQTY == 0, "must be a reset");
        require(userState.unallocatedLQTY != 0, "Governance: insufficient-or-allocated-lqty"); // avoid div-by-zero

        // After cutoff you can only re-apply the same vote
        // Or vote less
        // Or abstain
        // You can always add a veto, hence we only validate the addition of Votes
        // And ignore the addition of vetos
        // Validate the data here to ensure that the voting is capped at the amount in the other case
        if (secondsWithinEpoch() > EPOCH_VOTING_CUTOFF) {
            // Cap the max votes to the previous cache value
            // This means that no new votes can happen here

            // Removing and VETOING is always accepted
            for (uint256 x; x < _initiatives.length; x++) {
                // If we find it, we ensure it cannot be an increase
                bool found;
                for (uint256 y; y < cachedData.length; y++) {
                    if (cachedData[y].initiative == _initiatives[x]) {
                        found = true;
                        require(_absoluteLQTYVotes[x] <= cachedData[y].LQTYVotes, "Cannot increase");
                        break;
                    }
                }

                // Else we assert that the change is a veto, because by definition the initiatives will have received zero votes past this line
                if (!found) {
                    require(_absoluteLQTYVotes[x] == 0, "Must be zero for new initiatives");
                }
            }
        }

        int256[] memory absoluteOffsetVotes = new int256[](_initiatives.length);
        int256[] memory absoluteOffsetVetos = new int256[](_initiatives.length);

        // Calculate the offset portions that correspond to each LQTY vote and veto portion
        // By recalculating `unallocatedLQTY` & `unallocatedOffset` after each step, we ensure that rounding error
        // doesn't accumulate in `unallocatedOffset`.
        // However, it should be noted that this makes the exact offset allocations dependent on the ordering of the
        // `_initiatives` array.
        for (uint256 x; x < _initiatives.length; x++) {
            // Either _absoluteLQTYVotes[x] or _absoluteLQTYVetos[x] is guaranteed to be zero
            (int256[] calldata lqtyAmounts, int256[] memory offsets) = _absoluteLQTYVotes[x] > 0
                ? (_absoluteLQTYVotes, absoluteOffsetVotes)
                : (_absoluteLQTYVetos, absoluteOffsetVetos);

            uint256 lqtyAmount = uint256(lqtyAmounts[x]);
            uint256 offset = userState.unallocatedOffset * lqtyAmount / userState.unallocatedLQTY;

            userState.unallocatedLQTY -= lqtyAmount;
            userState.unallocatedOffset -= offset;

            offsets[x] = int256(offset);
        }

        // Vote here, all values are now absolute changes
        _allocateLQTY(_initiatives, _absoluteLQTYVotes, _absoluteLQTYVetos, absoluteOffsetVotes, absoluteOffsetVetos);
    }

    // Avoid "stack too deep" by placing these variables in memory
    struct AllocateLQTYMemory {
        VoteSnapshot votesSnapshot_;
        GlobalState state;
        UserState userState;
        InitiativeVoteSnapshot votesForInitiativeSnapshot_;
        InitiativeState initiativeState;
        InitiativeState prevInitiativeState;
        Allocation allocation;
        uint256 currentEpoch;
        int256 deltaLQTYVotes;
        int256 deltaLQTYVetos;
        int256 deltaOffsetVotes;
        int256 deltaOffsetVetos;
    }

    /// @dev For each given initiative applies relative changes to the allocation
    /// @dev Assumes that all the input arrays are of equal length
    /// @dev NOTE: Given the current usage the function either: Resets the value to 0, or sets the value to a new value
    ///      Review the flows as the function could be used in many ways, but it ends up being used in just those 2 ways
    function _allocateLQTY(
        address[] memory _initiatives,
        int256[] memory _deltaLQTYVotes,
        int256[] memory _deltaLQTYVetos,
        int256[] memory _deltaOffsetVotes,
        int256[] memory _deltaOffsetVetos
    ) internal {
        AllocateLQTYMemory memory vars;
        (vars.votesSnapshot_, vars.state) = _snapshotVotes();
        vars.currentEpoch = epoch();
        vars.userState = userStates[msg.sender];

        for (uint256 i = 0; i < _initiatives.length; i++) {
            address initiative = _initiatives[i];
            vars.deltaLQTYVotes = _deltaLQTYVotes[i];
            vars.deltaLQTYVetos = _deltaLQTYVetos[i];
            assert(vars.deltaLQTYVotes != 0 || vars.deltaLQTYVetos != 0);

            vars.deltaOffsetVotes = _deltaOffsetVotes[i];
            vars.deltaOffsetVetos = _deltaOffsetVetos[i];

            /// === Check FSM === ///
            // Can vote positively in SKIP, CLAIMABLE and CLAIMED states
            // Force to remove votes if disabled
            // Can remove votes and vetos in every stage
            (vars.votesForInitiativeSnapshot_, vars.initiativeState) = _snapshotVotesForInitiative(initiative);

            (InitiativeStatus status,,) = getInitiativeState(
                initiative, vars.votesSnapshot_, vars.votesForInitiativeSnapshot_, vars.initiativeState
            );

            if (vars.deltaLQTYVotes > 0 || vars.deltaLQTYVetos > 0) {
                /// You cannot vote on `unregisterable` but a vote may have been there
                require(
                    status == InitiativeStatus.SKIP || status == InitiativeStatus.CLAIMABLE
                        || status == InitiativeStatus.CLAIMED,
                    "Governance: active-vote-fsm"
                );
            }

            if (status == InitiativeStatus.DISABLED) {
                require(vars.deltaLQTYVotes <= 0 && vars.deltaLQTYVetos <= 0, "Must be a withdrawal");
            }

            /// === UPDATE ACCOUNTING === ///
            // == INITIATIVE STATE == //

            // deep copy of the initiative's state before the allocation
            vars.prevInitiativeState = InitiativeState(
                vars.initiativeState.voteLQTY,
                vars.initiativeState.voteOffset,
                vars.initiativeState.vetoLQTY,
                vars.initiativeState.vetoOffset,
                vars.initiativeState.lastEpochClaim
            );

            // allocate the voting and vetoing LQTY to the initiative
            vars.initiativeState.voteLQTY = add(vars.initiativeState.voteLQTY, vars.deltaLQTYVotes);
            vars.initiativeState.vetoLQTY = add(vars.initiativeState.vetoLQTY, vars.deltaLQTYVetos);

            // Update the initiative's vote and veto offsets
            vars.initiativeState.voteOffset = add(vars.initiativeState.voteOffset, vars.deltaOffsetVotes);
            vars.initiativeState.vetoOffset = add(vars.initiativeState.vetoOffset, vars.deltaOffsetVetos);

            // update the initiative's state
            initiativeStates[initiative] = vars.initiativeState;

            // == GLOBAL STATE == //

            /// We update the state only for non-disabled initiatives
            /// Disabled initiatves have had their totals subtracted already
            if (status != InitiativeStatus.DISABLED) {
                assert(vars.state.countedVoteLQTY >= vars.prevInitiativeState.voteLQTY);

                // Remove old initative LQTY and offset from global count
                vars.state.countedVoteLQTY -= vars.prevInitiativeState.voteLQTY;
                vars.state.countedVoteOffset -= vars.prevInitiativeState.voteOffset;

                // Add new initative LQTY and offset to global count
                vars.state.countedVoteLQTY += vars.initiativeState.voteLQTY;
                vars.state.countedVoteOffset += vars.initiativeState.voteOffset;
            }

            // == USER ALLOCATION TO INITIATIVE == //

            // Record the vote and veto LQTY and offsets by user to initative
            vars.allocation = lqtyAllocatedByUserToInitiative[msg.sender][initiative];
            // Update offsets
            vars.allocation.voteOffset = add(vars.allocation.voteOffset, vars.deltaOffsetVotes);
            vars.allocation.vetoOffset = add(vars.allocation.vetoOffset, vars.deltaOffsetVetos);

            // Update votes and vetos
            vars.allocation.voteLQTY = add(vars.allocation.voteLQTY, vars.deltaLQTYVotes);
            vars.allocation.vetoLQTY = add(vars.allocation.vetoLQTY, vars.deltaLQTYVetos);

            vars.allocation.atEpoch = vars.currentEpoch;

            // Voting power allocated to initiatives should never be negative, else it might break reward allocation
            // schemes such as `BribeInitiative` which distribute rewards in proportion to voting power allocated.
            assert(vars.allocation.voteLQTY * block.timestamp >= vars.allocation.voteOffset);
            assert(vars.allocation.vetoLQTY * block.timestamp >= vars.allocation.vetoOffset);

            lqtyAllocatedByUserToInitiative[msg.sender][initiative] = vars.allocation;

            // == USER STATE == //

            // Remove from the user's unallocated LQTY and offset
            vars.userState.unallocatedLQTY =
                sub(vars.userState.unallocatedLQTY, (vars.deltaLQTYVotes + vars.deltaLQTYVetos));
            vars.userState.unallocatedOffset =
                sub(vars.userState.unallocatedOffset, (vars.deltaOffsetVotes + vars.deltaOffsetVetos));

            // Add to the user's allocated LQTY and offset
            vars.userState.allocatedLQTY =
                add(vars.userState.allocatedLQTY, (vars.deltaLQTYVotes + vars.deltaLQTYVetos));
            vars.userState.allocatedOffset =
                add(vars.userState.allocatedOffset, (vars.deltaOffsetVotes + vars.deltaOffsetVetos));

            HookStatus hookStatus;

            // See https://github.com/liquity/V2-gov/issues/125
            // A malicious initiative could try to dissuade voters from casting vetos by consuming as much gas as
            // possible in the `onAfterAllocateLQTY` hook when detecting vetos.
            // We deem that the risks of calling into malicous initiatives upon veto allocation far outweigh the
            // benefits of notifying benevolent initiatives of vetos.
            if (vars.allocation.vetoLQTY == 0) {
                // Replaces try / catch | Enforces sufficient gas is passed
                hookStatus = safeCallWithMinGas(
                    initiative,
                    MIN_GAS_TO_HOOK,
                    0,
                    abi.encodeCall(
                        IInitiative.onAfterAllocateLQTY,
                        (vars.currentEpoch, msg.sender, vars.userState, vars.allocation, vars.initiativeState)
                    )
                ) ? HookStatus.Succeeded : HookStatus.Failed;
            } else {
                hookStatus = HookStatus.NotCalled;
            }

            emit AllocateLQTY(
                msg.sender, initiative, vars.deltaLQTYVotes, vars.deltaLQTYVetos, vars.currentEpoch, hookStatus
            );
        }

        require(
            vars.userState.allocatedLQTY <= stakingV1.stakes(deriveUserProxyAddress(msg.sender)),
            "Governance: insufficient-or-allocated-lqty"
        );

        globalState = vars.state;
        userStates[msg.sender] = vars.userState;
    }

    /// @inheritdoc IGovernance
    function unregisterInitiative(address _initiative) external nonReentrant {
        /// Enforce FSM
        (VoteSnapshot memory votesSnapshot_, GlobalState memory state) = _snapshotVotes();
        (InitiativeVoteSnapshot memory votesForInitiativeSnapshot_, InitiativeState memory initiativeState) =
            _snapshotVotesForInitiative(_initiative);

        (InitiativeStatus status,,) =
            getInitiativeState(_initiative, votesSnapshot_, votesForInitiativeSnapshot_, initiativeState);
        require(status == InitiativeStatus.UNREGISTERABLE, "Governance: cannot-unregister-initiative");

        // Remove weight from current state
        uint256 currentEpoch = epoch();

        // NOTE: Safe to remove | See `check_claim_soundness`
        assert(initiativeState.lastEpochClaim < currentEpoch - 1);

        assert(state.countedVoteLQTY >= initiativeState.voteLQTY);
        assert(state.countedVoteOffset >= initiativeState.voteOffset);

        state.countedVoteLQTY -= initiativeState.voteLQTY;
        state.countedVoteOffset -= initiativeState.voteOffset;

        globalState = state;

        /// Epoch will never reach 2^256 - 1
        registeredInitiatives[_initiative] = UNREGISTERED_INITIATIVE;

        // Replaces try / catch | Enforces sufficient gas is passed
        bool success = safeCallWithMinGas(
            _initiative, MIN_GAS_TO_HOOK, 0, abi.encodeCall(IInitiative.onUnregisterInitiative, (currentEpoch))
        );

        emit UnregisterInitiative(_initiative, currentEpoch, success ? HookStatus.Succeeded : HookStatus.Failed);
    }

    /// @inheritdoc IGovernance
    function claimForInitiative(address _initiative) external nonReentrant returns (uint256) {
        // Accrue and update state
        (VoteSnapshot memory votesSnapshot_,) = _snapshotVotes();
        (InitiativeVoteSnapshot memory votesForInitiativeSnapshot_, InitiativeState memory initiativeState) =
            _snapshotVotesForInitiative(_initiative);

        // Compute values on accrued state
        (InitiativeStatus status,, uint256 claimableAmount) =
            getInitiativeState(_initiative, votesSnapshot_, votesForInitiativeSnapshot_, initiativeState);

        if (status != InitiativeStatus.CLAIMABLE) {
            return 0;
        }

        /// INVARIANT: You can only claim for previous epoch
        assert(votesSnapshot_.forEpoch == epoch() - 1);

        /// All unclaimed rewards are always recycled
        /// Invariant `lastEpochClaim` is < epoch() - 1; |
        /// If `lastEpochClaim` is older than epoch() - 1 it means the initiative couldn't claim any rewards this epoch
        initiativeStates[_initiative].lastEpochClaim = epoch() - 1;

        /// INVARIANT, because of rounding errors the system can overpay
        /// We upscale the timestamp to reduce the impact of the loss
        /// However this is still possible
        uint256 available = bold.balanceOf(address(this));
        if (claimableAmount > available) {
            claimableAmount = available;
        }

        bold.safeTransfer(_initiative, claimableAmount);

        // Replaces try / catch | Enforces sufficient gas is passed
        bool success = safeCallWithMinGas(
            _initiative,
            MIN_GAS_TO_HOOK,
            0,
            abi.encodeCall(IInitiative.onClaimForInitiative, (votesSnapshot_.forEpoch, claimableAmount))
        );

        emit ClaimForInitiative(
            _initiative, claimableAmount, votesSnapshot_.forEpoch, success ? HookStatus.Succeeded : HookStatus.Failed
        );

        return claimableAmount;
    }

    function _requireNoNOP(int256[] memory _absoluteLQTYVotes, int256[] memory _absoluteLQTYVetos) internal pure {
        for (uint256 i; i < _absoluteLQTYVotes.length; i++) {
            require(_absoluteLQTYVotes[i] > 0 || _absoluteLQTYVetos[i] > 0, "Governance: voting nothing");
        }
    }

    function _requireNoSimultaneousVoteAndVeto(int256[] memory _absoluteLQTYVotes, int256[] memory _absoluteLQTYVetos)
        internal
        pure
    {
        for (uint256 i; i < _absoluteLQTYVotes.length; i++) {
            require(_absoluteLQTYVotes[i] == 0 || _absoluteLQTYVetos[i] == 0, "Governance: vote-and-veto");
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "openzeppelin/contracts/interfaces/IERC20.sol";
import {IERC20Permit} from "openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

import {IUserProxy} from "./interfaces/IUserProxy.sol";
import {ILQTYStaking} from "./interfaces/ILQTYStaking.sol";
import {PermitParams} from "./utils/Types.sol";

contract UserProxy is IUserProxy {
    /// @inheritdoc IUserProxy
    IERC20 public immutable lqty;
    /// @inheritdoc IUserProxy
    IERC20 public immutable lusd;

    /// @inheritdoc IUserProxy
    ILQTYStaking public immutable stakingV1;
    /// @inheritdoc IUserProxy
    address public immutable stakingV2;

    constructor(address _lqty, address _lusd, address _stakingV1) {
        lqty = IERC20(_lqty);
        lusd = IERC20(_lusd);
        stakingV1 = ILQTYStaking(_stakingV1);
        stakingV2 = msg.sender;
    }

    modifier onlyStakingV2() {
        require(msg.sender == stakingV2, "UserProxy: caller-not-stakingV2");
        _;
    }

    /// @inheritdoc IUserProxy
    function stake(uint256 _amount, address _lqtyFrom, bool _doSendRewards, address _recipient)
        public
        onlyStakingV2
        returns (uint256 lusdReceived, uint256 lusdSent, uint256 ethReceived, uint256 ethSent)
    {
        uint256 initialLUSDAmount = lusd.balanceOf(address(this));
        uint256 initialETHAmount = address(this).balance;

        lqty.transferFrom(_lqtyFrom, address(this), _amount);
        stakingV1.stake(_amount);

        uint256 lusdAmount = lusd.balanceOf(address(this));
        uint256 ethAmount = address(this).balance;

        lusdReceived = lusdAmount - initialLUSDAmount;
        ethReceived = ethAmount - initialETHAmount;

        if (_doSendRewards) (lusdSent, ethSent) = _sendRewards(_recipient, lusdAmount, ethAmount);
    }

    /// @inheritdoc IUserProxy
    function stakeViaPermit(
        uint256 _amount,
        address _lqtyFrom,
        PermitParams calldata _permitParams,
        bool _doSendRewards,
        address _recipient
    ) external onlyStakingV2 returns (uint256 lusdReceived, uint256 lusdSent, uint256 ethReceived, uint256 ethSent) {
        require(_lqtyFrom == _permitParams.owner, "UserProxy: owner-not-sender");

        try IERC20Permit(address(lqty)).permit(
            _permitParams.owner,
            _permitParams.spender,
            _permitParams.value,
            _permitParams.deadline,
            _permitParams.v,
            _permitParams.r,
            _permitParams.s
        ) {} catch {}

        return stake(_amount, _lqtyFrom, _doSendRewards, _recipient);
    }

    /// @inheritdoc IUserProxy
    function unstake(uint256 _amount, bool _doSendRewards, address _recipient)
        external
        onlyStakingV2
        returns (
            uint256 lqtyReceived,
            uint256 lqtySent,
            uint256 lusdReceived,
            uint256 lusdSent,
            uint256 ethReceived,
            uint256 ethSent
        )
    {
        uint256 initialLQTYAmount = lqty.balanceOf(address(this));
        uint256 initialLUSDAmount = lusd.balanceOf(address(this));
        uint256 initialETHAmount = address(this).balance;

        stakingV1.unstake(_amount);

        lqtySent = lqty.balanceOf(address(this));
        uint256 lusdAmount = lusd.balanceOf(address(this));
        uint256 ethAmount = address(this).balance;

        lqtyReceived = lqtySent - initialLQTYAmount;
        lusdReceived = lusdAmount - initialLUSDAmount;
        ethReceived = ethAmount - initialETHAmount;

        if (lqtySent > 0) lqty.transfer(_recipient, lqtySent);
        if (_doSendRewards) (lusdSent, ethSent) = _sendRewards(_recipient, lusdAmount, ethAmount);
    }

    function _sendRewards(address _recipient, uint256 _lusdAmount, uint256 _ethAmount)
        internal
        returns (uint256 lusdSent, uint256 ethSent)
    {
        if (_lusdAmount > 0) lusd.transfer(_recipient, _lusdAmount);
        if (_ethAmount > 0) {
            (bool success,) = payable(_recipient).call{value: _ethAmount}("");
            require(success, "UserProxy: eth-fail");
        }

        return (_lusdAmount, _ethAmount);
    }

    /// @inheritdoc IUserProxy
    function staked() external view returns (uint256) {
        return stakingV1.stakes(address(this));
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Clones} from "openzeppelin/contracts/proxy/Clones.sol";

import {IUserProxyFactory} from "./interfaces/IUserProxyFactory.sol";
import {UserProxy} from "./UserProxy.sol";

contract UserProxyFactory is IUserProxyFactory {
    /// @inheritdoc IUserProxyFactory
    address public immutable userProxyImplementation;

    constructor(address _lqty, address _lusd, address _stakingV1) {
        userProxyImplementation = address(new UserProxy(_lqty, _lusd, _stakingV1));
    }

    /// @inheritdoc IUserProxyFactory
    function deriveUserProxyAddress(address _user) public view returns (address) {
        return Clones.predictDeterministicAddress(userProxyImplementation, bytes32(uint256(uint160(_user))));
    }

    /// @inheritdoc IUserProxyFactory
    function deployUserProxy() public returns (address) {
        // reverts if the user already has a proxy
        address userProxy = Clones.cloneDeterministic(userProxyImplementation, bytes32(uint256(uint160(msg.sender))));

        emit DeployUserProxy(msg.sender, userProxy);

        return userProxy;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "openzeppelin/contracts/interfaces/IERC20.sol";

import {ILQTYStaking} from "./ILQTYStaking.sol";

import {PermitParams} from "../utils/Types.sol";

uint256 constant UNREGISTERED_INITIATIVE = type(uint256).max;

interface IGovernance {
    enum HookStatus {
        Failed,
        Succeeded,
        NotCalled
    }

    /// @notice Emitted when a user deposits LQTY
    /// @param user The account depositing LQTY
    /// @param rewardRecipient The account receiving the LUSD/ETH rewards earned from staking in V1, if claimed
    /// @param lqtyAmount The amount of LQTY being deposited
    /// @return lusdReceived Amount of LUSD tokens received as a side-effect of staking new LQTY
    /// @return lusdSent Amount of LUSD tokens sent to `rewardRecipient` (may include previously received LUSD)
    /// @return ethReceived Amount of ETH received as a side-effect of staking new LQTY
    /// @return ethSent Amount of ETH sent to `rewardRecipient` (may include previously received ETH)
    event DepositLQTY(
        address indexed user,
        address rewardRecipient,
        uint256 lqtyAmount,
        uint256 lusdReceived,
        uint256 lusdSent,
        uint256 ethReceived,
        uint256 ethSent
    );

    /// @notice Emitted when a user withdraws LQTY or claims V1 staking rewards
    /// @param user The account withdrawing LQTY or claiming V1 staking rewards
    /// @param recipient The account receiving the LQTY withdrawn, and if claimed, the LUSD/ETH rewards earned from staking in V1
    /// @return lqtyReceived Amount of LQTY tokens actually withdrawn (may be lower than the `_lqtyAmount` passed to `withdrawLQTY`)
    /// @return lqtySent Amount of LQTY tokens sent to `recipient` (may include LQTY sent to the user's proxy from sources other than V1 staking)
    /// @return lusdReceived Amount of LUSD tokens received as a side-effect of staking new LQTY
    /// @return lusdSent Amount of LUSD tokens sent to `recipient` (may include previously received LUSD)
    /// @return ethReceived Amount of ETH received as a side-effect of staking new LQTY
    /// @return ethSent Amount of ETH sent to `recipient` (may include previously received ETH)
    event WithdrawLQTY(
        address indexed user,
        address recipient,
        uint256 lqtyReceived,
        uint256 lqtySent,
        uint256 lusdReceived,
        uint256 lusdSent,
        uint256 ethReceived,
        uint256 ethSent
    );

    event SnapshotVotes(uint256 votes, uint256 forEpoch, uint256 boldAccrued);
    event SnapshotVotesForInitiative(address indexed initiative, uint256 votes, uint256 vetos, uint256 forEpoch);

    event RegisterInitiative(address initiative, address registrant, uint256 atEpoch, HookStatus hookStatus);
    event UnregisterInitiative(address initiative, uint256 atEpoch, HookStatus hookStatus);

    event AllocateLQTY(
        address indexed user,
        address indexed initiative,
        int256 deltaVoteLQTY,
        int256 deltaVetoLQTY,
        uint256 atEpoch,
        HookStatus hookStatus
    );
    event ClaimForInitiative(address indexed initiative, uint256 bold, uint256 forEpoch, HookStatus hookStatus);

    struct Configuration {
        uint256 registrationFee;
        uint256 registrationThresholdFactor;
        uint256 unregistrationThresholdFactor;
        uint256 unregistrationAfterEpochs;
        uint256 votingThresholdFactor;
        uint256 minClaim;
        uint256 minAccrual;
        uint256 epochStart;
        uint256 epochDuration;
        uint256 epochVotingCutoff;
    }

    function registerInitialInitiatives(address[] memory _initiatives) external;

    /// @notice Address of the LQTY StakingV1 contract
    /// @return stakingV1 Address of the LQTY StakingV1 contract
    function stakingV1() external view returns (ILQTYStaking stakingV1);
    /// @notice Address of the LQTY token
    /// @return lqty Address of the LQTY token
    function lqty() external view returns (IERC20 lqty);
    /// @notice Address of the BOLD token
    /// @return bold Address of the BOLD token
    function bold() external view returns (IERC20 bold);
    /// @notice Timestamp at which the first epoch starts
    /// @return epochStart Timestamp at which the first epoch starts
    function EPOCH_START() external view returns (uint256 epochStart);
    /// @notice Duration of an epoch in seconds (e.g. 1 week)
    /// @return epochDuration Epoch duration
    function EPOCH_DURATION() external view returns (uint256 epochDuration);
    /// @notice Voting period of an epoch in seconds (e.g. 6 days)
    /// @return epochVotingCutoff Epoch voting cutoff
    function EPOCH_VOTING_CUTOFF() external view returns (uint256 epochVotingCutoff);
    /// @notice Minimum BOLD amount that has to be claimed, if an initiative doesn't have enough votes to meet the
    /// criteria then it's votes a excluded from the vote count and distribution
    /// @return minClaim Minimum claim amount
    function MIN_CLAIM() external view returns (uint256 minClaim);
    /// @notice Minimum amount of BOLD that have to be accrued for an epoch, otherwise accrual will be skipped for
    /// that epoch
    /// @return minAccrual Minimum amount of BOLD
    function MIN_ACCRUAL() external view returns (uint256 minAccrual);
    /// @notice Amount of BOLD to be paid in order to register a new initiative
    /// @return registrationFee Registration fee
    function REGISTRATION_FEE() external view returns (uint256 registrationFee);
    /// @notice Share of all votes that are necessary to register a new initiative
    /// @return registrationThresholdFactor Threshold factor
    function REGISTRATION_THRESHOLD_FACTOR() external view returns (uint256 registrationThresholdFactor);
    /// @notice Multiple of the voting threshold in vetos that are necessary to unregister an initiative
    /// @return unregistrationThresholdFactor Unregistration threshold factor
    function UNREGISTRATION_THRESHOLD_FACTOR() external view returns (uint256 unregistrationThresholdFactor);
    /// @notice Number of epochs an initiative has to be inactive before it can be unregistered
    /// @return unregistrationAfterEpochs Number of epochs
    function UNREGISTRATION_AFTER_EPOCHS() external view returns (uint256 unregistrationAfterEpochs);
    /// @notice Share of all votes that are necessary for an initiative to be included in the vote count
    /// @return votingThresholdFactor Voting threshold factor
    function VOTING_THRESHOLD_FACTOR() external view returns (uint256 votingThresholdFactor);

    /// @notice Returns the amount of BOLD accrued since last epoch (last snapshot)
    /// @return boldAccrued BOLD accrued
    function boldAccrued() external view returns (uint256 boldAccrued);

    struct VoteSnapshot {
        uint256 votes; // Votes at epoch transition
        uint256 forEpoch; // Epoch for which the votes are counted
    }

    struct InitiativeVoteSnapshot {
        uint256 votes; // Votes at epoch transition
        uint256 forEpoch; // Epoch for which the votes are counted
        uint256 lastCountedEpoch; // Epoch at which which the votes where counted last in the global snapshot
        uint256 vetos; // Vetos at epoch transition
    }

    /// @notice Returns the vote count snapshot of the previous epoch
    /// @return votes Number of votes
    /// @return forEpoch Epoch for which the votes are counted
    function votesSnapshot() external view returns (uint256 votes, uint256 forEpoch);
    /// @notice Returns the vote count snapshot for an initiative of the previous epoch
    /// @param _initiative Address of the initiative
    /// @return votes Number of votes
    /// @return forEpoch Epoch for which the votes are counted
    /// @return lastCountedEpoch Epoch at which which the votes where counted last in the global snapshot
    function votesForInitiativeSnapshot(address _initiative)
        external
        view
        returns (uint256 votes, uint256 forEpoch, uint256 lastCountedEpoch, uint256 vetos);

    struct Allocation {
        uint256 voteLQTY; // LQTY allocated vouching for the initiative
        uint256 voteOffset; // Offset associated with LQTY vouching for the initiative
        uint256 vetoLQTY; // LQTY vetoing the initiative
        uint256 vetoOffset; // Offset associated with LQTY vetoing the initiative
        uint256 atEpoch; // Epoch at which the allocation was last updated
    }

    struct UserState {
        uint256 unallocatedLQTY; // LQTY deposited and unallocated
        uint256 unallocatedOffset; // The offset sum corresponding to the unallocated LQTY
        uint256 allocatedLQTY; // LQTY allocated by the user to initatives
        uint256 allocatedOffset; // The offset sum corresponding to the allocated LQTY
    }

    struct InitiativeState {
        uint256 voteLQTY; // LQTY allocated vouching for the initiative
        uint256 voteOffset; // Offset associated with LQTY vouching for to the initative
        uint256 vetoLQTY; // LQTY allocated vetoing the initiative
        uint256 vetoOffset; // Offset associated with LQTY veoting the initative
        uint256 lastEpochClaim;
    }

    struct GlobalState {
        uint256 countedVoteLQTY; // Total LQTY that is included in vote counting
        uint256 countedVoteOffset; // Offset associated with the counted vote LQTY
    }

    /// @notice Returns the user's state
    /// @return unallocatedLQTY LQTY deposited and unallocated
    /// @return unallocatedOffset Offset associated with unallocated LQTY
    /// @return allocatedLQTY allocated by the user to initatives
    /// @return allocatedOffset Offset associated with allocated LQTY
    function userStates(address _user)
        external
        view
        returns (uint256 unallocatedLQTY, uint256 unallocatedOffset, uint256 allocatedLQTY, uint256 allocatedOffset);
    /// @notice Returns the initiative's state
    /// @param _initiative Address of the initiative
    /// @return voteLQTY LQTY allocated vouching for the initiative
    /// @return voteOffset Offset associated with voteLQTY
    /// @return vetoLQTY LQTY allocated vetoing the initiative
    /// @return vetoOffset Offset associated with vetoLQTY
    /// @return lastEpochClaim // Last epoch at which rewards were claimed
    function initiativeStates(address _initiative)
        external
        view
        returns (uint256 voteLQTY, uint256 voteOffset, uint256 vetoLQTY, uint256 vetoOffset, uint256 lastEpochClaim);
    /// @notice Returns the global state
    /// @return countedVoteLQTY Total LQTY that is included in vote counting
    /// @return countedVoteOffset Offset associated with countedVoteLQTY
    function globalState() external view returns (uint256 countedVoteLQTY, uint256 countedVoteOffset);
    /// @notice Returns the amount of voting and vetoing LQTY a user allocated to an initiative
    /// @param _user Address of the user
    /// @param _initiative Address of the initiative
    /// @return voteLQTY LQTY allocated vouching for the initiative
    /// @return voteOffset The offset associated with voteLQTY
    /// @return vetoLQTY allocated vetoing the initiative
    /// @return vetoOffset the offset associated with vetoLQTY
    /// @return atEpoch Epoch at which the allocation was last updated
    function lqtyAllocatedByUserToInitiative(address _user, address _initiative)
        external
        view
        returns (uint256 voteLQTY, uint256 voteOffset, uint256 vetoLQTY, uint256 vetoOffset, uint256 atEpoch);

    /// @notice Returns when an initiative was registered
    /// @param _initiative Address of the initiative
    /// @return atEpoch If `_initiative` is an active initiative, returns the epoch at which it was registered.
    ///                 If `_initiative` hasn't been registered, returns 0.
    ///                 If `_initiative` has been unregistered, returns `UNREGISTERED_INITIATIVE`.
    function registeredInitiatives(address _initiative) external view returns (uint256 atEpoch);

    /*//////////////////////////////////////////////////////////////
                                STAKING
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposits LQTY
    /// @dev The caller has to approve their `UserProxy` address to spend the LQTY tokens
    /// @param _lqtyAmount Amount of LQTY to deposit
    function depositLQTY(uint256 _lqtyAmount) external;

    /// @notice Deposits LQTY
    /// @dev The caller has to approve their `UserProxy` address to spend the LQTY tokens
    /// @param _lqtyAmount Amount of LQTY to deposit
    /// @param _doSendRewards If true, send rewards claimed from LQTY staking
    /// @param _recipient Address to which the tokens should be sent
    function depositLQTY(uint256 _lqtyAmount, bool _doSendRewards, address _recipient) external;

    /// @notice Deposits LQTY via Permit
    /// @param _lqtyAmount Amount of LQTY to deposit
    /// @param _permitParams Permit parameters
    function depositLQTYViaPermit(uint256 _lqtyAmount, PermitParams calldata _permitParams) external;

    /// @notice Deposits LQTY via Permit
    /// @param _lqtyAmount Amount of LQTY to deposit
    /// @param _permitParams Permit parameters
    /// @param _doSendRewards If true, send rewards claimed from LQTY staking
    /// @param _recipient Address to which the tokens should be sent
    function depositLQTYViaPermit(
        uint256 _lqtyAmount,
        PermitParams calldata _permitParams,
        bool _doSendRewards,
        address _recipient
    ) external;

    /// @notice Withdraws LQTY and claims any accrued LUSD and ETH rewards from StakingV1
    /// @param _lqtyAmount Amount of LQTY to withdraw
    function withdrawLQTY(uint256 _lqtyAmount) external;

    /// @notice Withdraws LQTY and claims any accrued LUSD and ETH rewards from StakingV1
    /// @param _lqtyAmount Amount of LQTY to withdraw
    /// @param _doSendRewards If true, send rewards claimed from LQTY staking
    /// @param _recipient Address to which the tokens should be sent
    function withdrawLQTY(uint256 _lqtyAmount, bool _doSendRewards, address _recipient) external;

    /// @notice Claims staking rewards from StakingV1 without unstaking
    /// @dev Note: in the unlikely event that the caller's `UserProxy` holds any LQTY tokens, they will also be sent to `_rewardRecipient`
    /// @param _rewardRecipient Address that will receive the rewards
    /// @return lusdSent Amount of LUSD tokens sent to `_rewardRecipient` (may include previously received LUSD)
    /// @return ethSent Amount of ETH sent to `_rewardRecipient` (may include previously received ETH)
    function claimFromStakingV1(address _rewardRecipient) external returns (uint256 lusdSent, uint256 ethSent);

    /*//////////////////////////////////////////////////////////////
                                 VOTING
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the current epoch number
    /// @return epoch Current epoch
    function epoch() external view returns (uint256 epoch);
    /// @notice Returns the timestamp at which the current epoch started
    /// @return epochStart Epoch start of the current epoch
    function epochStart() external view returns (uint256 epochStart);
    /// @notice Returns the number of seconds that have gone by since the current epoch started
    /// @return secondsWithinEpoch Seconds within the current epoch
    function secondsWithinEpoch() external view returns (uint256 secondsWithinEpoch);

    /// @notice Returns the voting power for an entity (i.e. user or initiative) at a given timestamp
    /// @param _lqtyAmount Amount of LQTY associated with the entity
    /// @param _timestamp Timestamp at which to calculate voting power
    /// @param _offset The entity's offset sum
    /// @return votes Number of votes
    function lqtyToVotes(uint256 _lqtyAmount, uint256 _timestamp, uint256 _offset) external pure returns (uint256);

    /// @dev Returns the most up to date voting threshold
    /// In contrast to `getLatestVotingThreshold` this function updates the snapshot
    /// This ensures that the value returned is always the latest
    function calculateVotingThreshold() external returns (uint256);

    /// @dev Utility function to compute the threshold votes without recomputing the snapshot
    /// Note that `boldAccrued` is a cached value, this function works correctly only when called after an accrual
    function calculateVotingThreshold(uint256 _votes) external view returns (uint256);

    /// @notice Return the most up to date global snapshot and state as well as a flag to notify whether the state can be updated
    /// This is a convenience function to always retrieve the most up to date state values
    function getTotalVotesAndState()
        external
        view
        returns (VoteSnapshot memory snapshot, GlobalState memory state, bool shouldUpdate);

    /// @dev Given an initiative address, return it's most up to date snapshot and state as well as a flag to notify whether the state can be updated
    /// This is a convenience function to always retrieve the most up to date state values
    function getInitiativeSnapshotAndState(address _initiative)
        external
        view
        returns (
            InitiativeVoteSnapshot memory initiativeSnapshot,
            InitiativeState memory initiativeState,
            bool shouldUpdate
        );

    /// @notice Voting threshold is the max. of either:
    ///   - 4% of the total voting LQTY in the previous epoch
    ///   - or the minimum number of votes necessary to claim at least MIN_CLAIM BOLD
    /// This value can be offsynch, use the non view `calculateVotingThreshold` to always retrieve the most up to date value
    /// @return votingThreshold Voting threshold
    function getLatestVotingThreshold() external view returns (uint256 votingThreshold);

    /// @notice Snapshots votes for the previous epoch and accrues funds for the current epoch
    /// @param _initiative Address of the initiative
    /// @return voteSnapshot Vote snapshot
    /// @return initiativeVoteSnapshot Vote snapshot of the initiative
    function snapshotVotesForInitiative(address _initiative)
        external
        returns (VoteSnapshot memory voteSnapshot, InitiativeVoteSnapshot memory initiativeVoteSnapshot);

    /*//////////////////////////////////////////////////////////////
                                 FSM
    //////////////////////////////////////////////////////////////*/

    enum InitiativeStatus {
        NONEXISTENT,
        /// This Initiative Doesn't exist | This is never returned
        WARM_UP,
        /// This epoch was just registered
        SKIP,
        /// This epoch will result in no rewards and no unregistering
        CLAIMABLE,
        /// This epoch will result in claiming rewards
        CLAIMED,
        /// The rewards for this epoch have been claimed
        UNREGISTERABLE,
        /// Can be unregistered
        DISABLED // It was already Unregistered

    }

    function getInitiativeState(address _initiative)
        external
        returns (InitiativeStatus status, uint256 lastEpochClaim, uint256 claimableAmount);

    function getInitiativeState(
        address _initiative,
        VoteSnapshot memory _votesSnapshot,
        InitiativeVoteSnapshot memory _votesForInitiativeSnapshot,
        InitiativeState memory _initiativeState
    ) external view returns (InitiativeStatus status, uint256 lastEpochClaim, uint256 claimableAmount);

    /// @notice Registers a new initiative
    /// @param _initiative Address of the initiative
    function registerInitiative(address _initiative) external;
    // /// @notice Unregisters an initiative if it didn't receive enough votes in the last 4 epochs
    // /// or if it received more vetos than votes and the number of vetos are greater than 3 times the voting threshold
    // /// @param _initiative Address of the initiative
    function unregisterInitiative(address _initiative) external;

    /// @notice Allocates the user's LQTY to initiatives
    /// @dev The user can only allocate to active initiatives (older than 1 epoch) and has to have enough unallocated
    /// LQTY available, the initiatives listed must be unique, and towards the end of the epoch a user can only maintain or reduce their votes
    /// @param _initiativesToReset Addresses of the initiatives the caller was previously allocated to, must be reset to prevent desynch of voting power
    /// @param _initiatives Addresses of the initiatives to allocate to, can match or be different from `_resetInitiatives`
    /// @param _absoluteLQTYVotes LQTY to allocate to the initiatives as votes
    /// @param _absoluteLQTYVetos LQTY to allocate to the initiatives as vetos
    function allocateLQTY(
        address[] calldata _initiativesToReset,
        address[] memory _initiatives,
        int256[] memory _absoluteLQTYVotes,
        int256[] memory _absoluteLQTYVetos
    ) external;
    /// @notice Deallocates the user's LQTY from initiatives
    /// @param _initiativesToReset Addresses of initiatives to deallocate LQTY from
    /// @param _checkAll When true, the call will revert if there is still some allocated LQTY left after deallocating
    ///                  from all the addresses in `_initiativesToReset`
    function resetAllocations(address[] calldata _initiativesToReset, bool _checkAll) external;

    /// @notice Splits accrued funds according to votes received between all initiatives
    /// @param _initiative Addresse of the initiative
    /// @return claimed Amount of BOLD claimed
    function claimForInitiative(address _initiative) external returns (uint256 claimed);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IGovernance} from "./IGovernance.sol";

interface IInitiative {
    /// @notice Callback hook that is called by Governance after the initiative was successfully registered
    /// @param _atEpoch Epoch at which the initiative is registered
    function onRegisterInitiative(uint256 _atEpoch) external;

    /// @notice Callback hook that is called by Governance after the initiative was unregistered
    /// @param _atEpoch Epoch at which the initiative is unregistered
    function onUnregisterInitiative(uint256 _atEpoch) external;

    /// @notice Callback hook that is called by Governance after the LQTY allocation is updated by a user
    /// @param _currentEpoch Epoch at which the LQTY allocation is updated
    /// @param _user Address of the user that updated their LQTY allocation
    /// @param _userState User state
    /// @param _allocation Allocation state from user to initiative
    /// @param _initiativeState Initiative state
    function onAfterAllocateLQTY(
        uint256 _currentEpoch,
        address _user,
        IGovernance.UserState calldata _userState,
        IGovernance.Allocation calldata _allocation,
        IGovernance.InitiativeState calldata _initiativeState
    ) external;

    /// @notice Callback hook that is called by Governance after the claim for the last epoch was distributed
    /// to the initiative
    /// @param _claimEpoch Epoch at which the claim was distributed
    /// @param _bold Amount of BOLD that was distributed
    function onClaimForInitiative(uint256 _claimEpoch, uint256 _bold) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ILQTYStaking {
    // --- Events --

    event LQTYTokenAddressSet(address _lqtyTokenAddress);
    event LUSDTokenAddressSet(address _lusdTokenAddress);
    event TroveManagerAddressSet(address _troveManager);
    event BorrowerOperationsAddressSet(address _borrowerOperationsAddress);
    event ActivePoolAddressSet(address _activePoolAddress);

    event StakeChanged(address indexed staker, uint256 newStake);
    event StakingGainsWithdrawn(address indexed staker, uint256 LUSDGain, uint256 ETHGain);
    event F_ETHUpdated(uint256 _F_ETH);
    event F_LUSDUpdated(uint256 _F_LUSD);
    event TotalLQTYStakedUpdated(uint256 _totalLQTYStaked);
    event EtherSent(address _account, uint256 _amount);
    event StakerSnapshotsUpdated(address _staker, uint256 _F_ETH, uint256 _F_LUSD);

    // --- Functions ---

    function setAddresses(
        address _lqtyTokenAddress,
        address _lusdTokenAddress,
        address _troveManagerAddress,
        address _borrowerOperationsAddress,
        address _activePoolAddress
    ) external;

    function stake(uint256 _LQTYamount) external;

    function unstake(uint256 _LQTYamount) external;

    function increaseF_ETH(uint256 _ETHFee) external;

    function increaseF_LUSD(uint256 _LQTYFee) external;

    function getPendingETHGain(address _user) external view returns (uint256);

    function getPendingLUSDGain(address _user) external view returns (uint256);

    function stakes(address _user) external view returns (uint256);

    function totalLQTYStaked() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMultiDelegateCall {
    /// @notice Call multiple functions of the contract while preserving `msg.sender`
    /// @param inputs Function calls to perform, encoded using `abi.encodeCall()` or equivalent
    /// @return returnValues Raw data returned by each call
    function multiDelegateCall(bytes[] calldata inputs) external returns (bytes[] memory returnValues);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "openzeppelin/contracts/interfaces/IERC20.sol";

import {ILQTYStaking} from "../interfaces/ILQTYStaking.sol";

import {PermitParams} from "../utils/Types.sol";

interface IUserProxy {
    /// @notice Address of the LQTY token
    /// @return lqty Address of the LQTY token
    function lqty() external view returns (IERC20 lqty);
    /// @notice Address of the LUSD token
    /// @return lusd Address of the LUSD token
    function lusd() external view returns (IERC20 lusd);
    /// @notice Address of the V1 LQTY staking contract
    /// @return stakingV1 Address of the V1 LQTY staking contract
    function stakingV1() external view returns (ILQTYStaking stakingV1);
    /// @notice Address of the V2 LQTY staking contract
    /// @return stakingV2 Address of the V2 LQTY staking contract
    function stakingV2() external view returns (address stakingV2);

    /// @notice Stakes a given amount of LQTY tokens in the V1 staking contract
    /// @dev The LQTY tokens must be approved for transfer by the user
    /// @param _amount Amount of LQTY tokens to stake
    /// @param _lqtyFrom Address from which to transfer the LQTY tokens
    /// @param _doSendRewards If true, send rewards claimed from LQTY staking
    /// @param _recipient Address to which the tokens should be sent
    /// @return lusdReceived Amount of LUSD tokens received as a side-effect of staking new LQTY
    /// @return lusdSent Amount of LUSD tokens sent to `_recipient` (may include previously received LUSD)
    /// @return ethReceived Amount of ETH received as a side-effect of staking new LQTY
    /// @return ethSent Amount of ETH sent to `_recipient` (may include previously received ETH)
    function stake(uint256 _amount, address _lqtyFrom, bool _doSendRewards, address _recipient)
        external
        returns (uint256 lusdReceived, uint256 lusdSent, uint256 ethReceived, uint256 ethSent);

    /// @notice Stakes a given amount of LQTY tokens in the V1 staking contract using a permit
    /// @param _amount Amount of LQTY tokens to stake
    /// @param _lqtyFrom Address from which to transfer the LQTY tokens
    /// @param _permitParams Parameters for the permit data
    /// @param _doSendRewards If true, send rewards claimed from LQTY staking
    /// @param _recipient Address to which the tokens should be sent
    /// @return lusdReceived Amount of LUSD tokens received as a side-effect of staking new LQTY
    /// @return lusdSent Amount of LUSD tokens sent to `_recipient` (may include previously received LUSD)
    /// @return ethReceived Amount of ETH received as a side-effect of staking new LQTY
    /// @return ethSent Amount of ETH sent to `_recipient` (may include previously received ETH)
    function stakeViaPermit(
        uint256 _amount,
        address _lqtyFrom,
        PermitParams calldata _permitParams,
        bool _doSendRewards,
        address _recipient
    ) external returns (uint256 lusdReceived, uint256 lusdSent, uint256 ethReceived, uint256 ethSent);

    /// @notice Unstakes a given amount of LQTY tokens from the V1 staking contract and claims the accrued rewards
    /// @param _amount Amount of LQTY tokens to unstake
    /// @param _doSendRewards If true, send rewards claimed from LQTY staking
    /// @param _recipient Address to which the tokens should be sent
    /// @return lqtyReceived Amount of LQTY tokens actually unstaked (may be lower than `_amount`)
    /// @return lqtySent Amount of LQTY tokens sent to `_recipient` (may include LQTY sent to the proxy from sources other than V1 staking)
    /// @return lusdReceived Amount of LUSD tokens received as a side-effect of staking new LQTY
    /// @return lusdSent Amount of LUSD tokens claimed (may include previously received LUSD)
    /// @return ethReceived Amount of ETH received as a side-effect of staking new LQTY
    /// @return ethSent Amount of ETH claimed (may include previously received ETH)
    function unstake(uint256 _amount, bool _doSendRewards, address _recipient)
        external
        returns (
            uint256 lqtyReceived,
            uint256 lqtySent,
            uint256 lusdReceived,
            uint256 lusdSent,
            uint256 ethReceived,
            uint256 ethSent
        );

    /// @notice Returns the current amount LQTY staked by a user in the V1 staking contract
    /// @return staked Amount of LQTY tokens staked
    function staked() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IUserProxyFactory {
    event DeployUserProxy(address indexed user, address indexed userProxy);

    /// @notice Address of the UserProxy implementation contract
    /// @return implementation Address of the UserProxy implementation contract
    function userProxyImplementation() external view returns (address implementation);

    /// @notice Derive the address of a user's proxy contract
    /// @param _user Address of the user
    /// @return userProxyAddress Address of the user's proxy contract
    function deriveUserProxyAddress(address _user) external view returns (address userProxyAddress);

    /// @notice Deploy a new UserProxy contract for the sender
    /// @return userProxyAddress Address of the deployed UserProxy contract
    function deployUserProxy() external returns (address userProxyAddress);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

function add(uint256 a, int256 b) pure returns (uint256) {
    if (b < 0) {
        return a - abs(b);
    }
    return a + uint256(b);
}

function sub(uint256 a, int256 b) pure returns (uint256) {
    if (b < 0) {
        return a + abs(b);
    }
    return a - uint256(b);
}

function max(uint256 a, uint256 b) pure returns (uint256) {
    return a > b ? a : b;
}

function abs(int256 a) pure returns (uint256) {
    return a < 0 ? uint256(-int256(a)) : uint256(a);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IMultiDelegateCall} from "../interfaces/IMultiDelegateCall.sol";

contract MultiDelegateCall is IMultiDelegateCall {
    /// @inheritdoc IMultiDelegateCall
    function multiDelegateCall(bytes[] calldata inputs) external returns (bytes[] memory returnValues) {
        returnValues = new bytes[](inputs.length);

        for (uint256 i; i < inputs.length; ++i) {
            (bool success, bytes memory returnData) = address(this).delegatecall(inputs[i]);

            if (!success) {
                // Bubble up the revert
                assembly {
                    revert(
                        add(32, returnData), // offset (skip first 32 bytes, where the size of the array is stored)
                        mload(returnData) // size
                    )
                }
            }

            returnValues[i] = returnData;
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

/**
 * Based on OpenZeppelin's Ownable contract:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
 *
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting `initialOwner` as the initial owner.
     */
    constructor(address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     *
     * NOTE: This function is not safe, as it doesn’t check owner is calling it.
     * Make sure you check it before calling it.
     */
    function _renounceOwnership() internal {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Given the gas requirement, ensures that the current context has sufficient gas to perform a call + a fixed buffer
/// @dev Credits: https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/libraries/SafeCall.sol#L100-L107
function hasMinGas(uint256 _minGas, uint256 _reservedGas) view returns (bool) {
    bool _hasMinGas;
    assembly {
        // Equation: gas × 63 ≥ minGas × 64 + 63(40_000 + reservedGas)
        _hasMinGas := iszero(lt(mul(gas(), 63), add(mul(_minGas, 64), mul(add(40000, _reservedGas), 63))))
    }
    return _hasMinGas;
}

/// @dev Performs a call ignoring the recipient existing or not, passing the exact gas value, ignoring any return value
function safeCallWithMinGas(address _target, uint256 _gas, uint256 _value, bytes memory _calldata)
    returns (bool success)
{
    /// This is not necessary
    /// But this is basically a worst case estimate of mem exp cost + operations before the call
    require(hasMinGas(_gas, 1_000), "Must have minGas");

    // dispatch message to recipient
    // by assembly calling "handle" function
    // we call via assembly to avoid memcopying a very large returndata
    // returned by a malicious contract
    assembly {
        success :=
            call(
                _gas, // gas
                _target, // recipient
                _value, // ether value
                add(_calldata, 0x20), // inloc
                mload(_calldata), // inlen
                0, // outloc
                0 // outlen
            )

        // Ignore all return values
    }
    return (success);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

struct PermitParams {
    address owner;
    address spender;
    uint256 value;
    uint256 deadline;
    uint8 v;
    bytes32 r;
    bytes32 s;
}

uint256 constant WAD = 1e18;
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @dev Checks that there's no duplicate addresses
/// @param arr - List to check for dups
function _requireNoDuplicates(address[] calldata arr) pure {
    uint256 arrLength = arr.length;
    if (arrLength == 0) return;

    // only up to len - 1 (no j to check if i == len - 1)
    for (uint i; i < arrLength - 1;) {
        for (uint j = i + 1; j < arrLength;) {
            require(arr[i] != arr[j], "dup");

            unchecked {
                ++j;
            }
        }

        unchecked {
            ++i;
        }
    }
}

function _requireNoNegatives(int256[] memory vals) pure {
    uint256 arrLength = vals.length;

    for (uint i; i < arrLength; i++) {
        require(vals[i] >= 0, "Cannot be negative");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

function _lqtyToVotes(uint256 _lqtyAmount, uint256 _timestamp, uint256 _offset) pure returns (uint256) {
    uint256 prod = _lqtyAmount * _timestamp;
    return prod > _offset ? prod - _offset : 0;
}