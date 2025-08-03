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
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {ITokenPairs} from "./interfaces/ITokenPairs.sol";
import {IMintedBurnableERC20} from "./interfaces/IMintedBurnableERC20.sol";

/// Extension of the TokenDeposit contract adding transition support of bridged EURC to native EURC.
/// @custom:security-contact security@fantom.foundation
abstract contract EurcDepositExtension {

    address private constant EURC_ADDRESS_L1 = 0x1aBaEA1f7C830bD89Acc67eC4af516284b1bC33c;
    bytes32 public constant EURC_BURN_PREPARER_ROLE = keccak256("EURC_BURN_PREPARER_ROLE");

    ITokenPairs private immutable tokenPairs; // TokenPairs contract

    uint256 private eurcToBurn;
    address private eurcBurner;

    constructor(address _tokenPairs) {
        require(_tokenPairs != address(0), "TokenPairs not set");
        tokenPairs = ITokenPairs(_tokenPairs);
    }

    /// Burn EURC in the contract. To be called by Circle.
    /// Burning must be prepared first by calling prepareBurningEURC().
    /// See https://github.com/circlefin/stablecoin-evm/blob/release-2024-06-21T005221/doc/bridged_USDC_standard.md
    function burnLockedEURC() external {
        require(msg.sender == eurcBurner, "Not EURC burner");
        uint256 amount = eurcToBurn;
        eurcToBurn = 0;
        IMintedBurnableERC20(EURC_ADDRESS_L1).burn(amount);
    }

    /// Prepare burning EURC in the contract. To be called by Sonic team.
    /// The EURC pair must be terminated first on both networks and the caller needs to have appropriate role assigned.
    /// @param burner The address defined by Circle allowed to call burnLockedEURC()
    /// @param amount The total supply of bridged EURC on the Sonic network - to by burned by burnLockedEURC() call.
    function prepareBurningEURC(address burner, uint256 amount) external {
        require(tokenPairs.originalToMinted(EURC_ADDRESS_L1) != address(0), "EURC not registered yet");
        require(tokenPairs.originalToMintedTerminable(EURC_ADDRESS_L1) == address(0), "EURC not terminated");
        require(tokenPairs.hasRole(EURC_BURN_PREPARER_ROLE, msg.sender), "Not burn preparer");
        eurcBurner = burner;
        eurcToBurn = amount;
    }

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ITokenDeposit} from "./interfaces/ITokenDeposit.sol";
import {ITokenPairs} from "./interfaces/ITokenPairs.sol";
import {IProofVerifier} from "./interfaces/IProofVerifier.sol";
import {IStateOracle} from "./interfaces/IStateOracle.sol";
import {IProvingContract} from "./interfaces/IProvingContract.sol";
import {UsdcDepositExtension} from "./UsdcDepositExtension.sol";
import {EurcDepositExtension} from "./EurcDepositExtension.sol";
import {UsdtDepositExtension} from "./UsdtDepositExtension.sol";

using SafeERC20 for IERC20;

/// The L1 part of the bridge. Allows to initiate depositing tokens to the L2.
/// Allows to claim withdrawal initiated on the L2 chain.
/// @custom:security-contact security@fantom.foundation
contract TokenDeposit is IProvingContract, ITokenDeposit, Ownable, UsdcDepositExtension, EurcDepositExtension, UsdtDepositExtension {
    mapping (uint256 depositId => bytes32 senderTokenAmount) public deposits; // slot index 7
    mapping (uint256 withdrawalId => bool isClaimed) public claims; // claimed withdraws, slot index 8

    address public override(ITokenDeposit, IProvingContract) proofVerifier; // for verification of proofs from L2 chain
    address public exitAdministrator; // for withdrawals while the bridge is dead
    address public immutable bridge; // Bridge contract on the L2 chain
    address public immutable tokenPairs; // TokenPairs contract
    address public immutable stateOracle; // StateOracle contract
    bytes32 public deadState; // Last state root when the bridge died

    uint256 private constant TIME_UNTIL_DEAD = 200 days;
    uint256 private constant TIME_UNTIL_OFFLINE = 24 hours;

    event Deposit(uint256 indexed id, address indexed owner, address token, uint256 amount);
    event Claim(uint256 id, address indexed owner, address token, uint256 amount);
    event WithdrawnWhileDead(address indexed owner, address token, uint256 amount);
    event CancelledWhileDead(uint256 id, address indexed owner, address token, uint256 amount);
    event ProofVerifierSet(address proofVerifier);
    event BridgeDied();

    constructor(address _proofVerifier, address _bridge, address _tokenPairs, address _stateOracle, address _ownedBy)
            Ownable(_ownedBy) UsdcDepositExtension(_tokenPairs) EurcDepositExtension(_tokenPairs) UsdtDepositExtension(_tokenPairs) {
        require(_proofVerifier != address(0), "ProofVerifier not set");
        require(_bridge != address(0), "Bridge address not set");
        require(_tokenPairs != address(0), "TokenPairs not set");
        require(_stateOracle != address(0), "StateOracle not set");
        proofVerifier = _proofVerifier;
        bridge = _bridge;
        tokenPairs = _tokenPairs;
        stateOracle = _stateOracle;
    }

    /// Deposits tokens on L1.
    function deposit(uint96 uid, address token, uint256 amount) external {
        uint256 id = userOperationId(msg.sender, uid);
        require(deposits[id] == 0, "Deposit id is already used");
        require(ITokenPairs(tokenPairs).originalToMintedTerminable(token) != address(0), "Not supported token");
        require(isOnline(), "Bridge is offline");

        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        uint256 realAmount = IERC20(token).balanceOf(address(this)) - balanceBefore;
        require(realAmount > 0, "No tokens were transferred");

        deposits[id] = hash(msg.sender, token, realAmount);
        emit Deposit(id, msg.sender, token, realAmount);
    }

    /// Claim deposited L1 tokens burned on L2.
    function claim(uint256 id, address token, uint256 amount, bytes calldata proof) external {
        require(claims[id] == false, "Already claimed");

        bytes32 expectedHash = hash(msg.sender, token, amount);
        IProofVerifier(proofVerifier).verifyProof(bridge, getWithdrawalSlotIndex(id), expectedHash, lastValidState(), proof);
        // the withdrawal exists on the L2

        claims[id] = true; // write before other contract call (reentrancy!)
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Claim(id, msg.sender, token, amount);
    }

    /// When the bridge is dead, ExitAdministrator can release tokens from the deposit to appropriate owners.
    function withdrawWhileDead(address recipient, address token, uint256 amount) external {
        require(recipient != address(0), "Recipient is zero");
        require(msg.sender == exitAdministrator, "Not exit administrator");
        require(fetchDeadStatus(), "Bridge is not dead");
        IERC20(token).safeTransfer(recipient, amount);
        emit WithdrawnWhileDead(recipient, token, amount);
    }

    /// When the bridge is dead, cancel not-claimed deposit.
    /// Use proof of not-claimed state of the deposit on L2.
    function cancelDepositWhileDead(uint256 id, address token, uint256 amount, bytes calldata proof) external {
        require(deposits[id] == hash(msg.sender, token, amount), "No deposit to cancel");
        require(fetchDeadStatus(), "Bridge is not dead");

        IProofVerifier(proofVerifier).verifyProof(bridge, getClaimSlotIndex(id), bytes32(0), lastValidState(), proof);
        // claimed state is false in the last state root

        delete deposits[id]; // write before other contract call (reentrancy!)
        IERC20(token).safeTransfer(msg.sender, amount);
        emit CancelledWhileDead(id, msg.sender, token, amount);
    }

    /// Calculate slotId for withdrawal in the Bridge L2 contract.
    function getWithdrawalSlotIndex(uint256 id) pure public returns (bytes32) {
        return keccak256(abi.encode(id, uint8(1))); // withdrawals mapping is at slot index 1
    }

    /// Get deposit/withdrawal hash.
    function hash(address sender, address token, uint256 amount) pure public returns (bytes32) {
        return keccak256(abi.encode(sender, token, amount));
    }

    /// Calculate mapping key for user operation.
    /// Combines calling user identity and user-chosen value into a single key.
    function userOperationId(address sender, uint96 uid) pure public returns (uint256) {
        return (uint256(uint160(sender)) << 96) + uint256(uid);
    }

    /// Calculate slotId for claim in the Bridge L2 contract.
    function getClaimSlotIndex(uint256 id) pure public returns (bytes32) {
        return keccak256(abi.encode(id, uint8(2))); // claims mapping is at slot index 2
    }

    /// Fetch the dead status of the bridge.
    function fetchDeadStatus() public returns (bool) {
        if (deadState != 0) {
            return true;
        }
        if (exitAdministrator == address(0)) {
            return false; // The dying mechanism is disabled if no exitAdministrator is set.
        }
        uint256 lastUpdateTime = IStateOracle(stateOracle).lastUpdateTime();
        if (lastUpdateTime != 0 && lastUpdateTime < block.timestamp - TIME_UNTIL_DEAD) {
            deadState = IStateOracle(stateOracle).lastState();
            emit BridgeDied();
            return true;
        }
        return false;
    }

    function isOnline() private view returns (bool) {
        if (deadState != 0) {
            return false;
        }
        return IStateOracle(stateOracle).lastUpdateTime() >= block.timestamp - TIME_UNTIL_OFFLINE;
    }

    /// Get the last state root that is valid for the token deposit.
    function lastValidState() private view returns (bytes32) {
        if (deadState != 0) {
            return deadState;
        }
        return IStateOracle(stateOracle).lastState();
    }

    /// Set new proof verifier (callable by UpdateManager)
    function setProofVerifier(address _proofVerifier) external onlyOwner {
        proofVerifier = _proofVerifier;
        emit ProofVerifierSet(_proofVerifier);
    }

    /// Set new exit administrator (callable by UpdateManager)
    function setExitAdministrator(address _exitAdministrator) external onlyOwner {
        exitAdministrator = _exitAdministrator;
    }

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {ITokenPairs} from "./interfaces/ITokenPairs.sol";
import {IMintedBurnableERC20} from "./interfaces/IMintedBurnableERC20.sol";

/// Extension of the TokenDeposit contract adding transition support of bridged USDC to native USDC.
/// @custom:security-contact security@fantom.foundation
abstract contract UsdcDepositExtension {

    address private constant USDC_ADDRESS_L1 = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    bytes32 public constant USDC_BURN_PREPARER_ROLE = keccak256("USDC_BURN_PREPARER_ROLE");

    ITokenPairs private immutable tokenPairs; // TokenPairs contract

    uint256 private usdcToBurn;
    address private usdcBurner;

    constructor(address _tokenPairs) {
        require(_tokenPairs != address(0), "TokenPairs not set");
        tokenPairs = ITokenPairs(_tokenPairs);
    }

    /// Burn USDC in the contract. To be called by Circle.
    /// Burning must be prepared first by calling prepareBurningUSDC().
    /// See https://github.com/circlefin/stablecoin-evm/blob/release-2024-06-21T005221/doc/bridged_USDC_standard.md
    function burnLockedUSDC() external {
        require(msg.sender == usdcBurner, "Not USDC burner");
        uint256 amount = usdcToBurn;
        usdcToBurn = 0;
        IMintedBurnableERC20(USDC_ADDRESS_L1).burn(amount);
    }

    /// Prepare burning USDC in the contract. To be called by Sonic team.
    /// The USDC pair must be terminated first on both networks and the caller needs to have appropriate role assigned.
    /// @param burner The address defined by Circle allowed to call burnLockedUSDC()
    /// @param amount The total supply of bridged USDC on the Sonic network - to by burned by burnLockedUSDC() call.
    function prepareBurningUSDC(address burner, uint256 amount) external {
        require(tokenPairs.originalToMinted(USDC_ADDRESS_L1) != address(0), "USDC not registered yet");
        require(tokenPairs.originalToMintedTerminable(USDC_ADDRESS_L1) == address(0), "USDC not terminated");
        require(tokenPairs.hasRole(USDC_BURN_PREPARER_ROLE, msg.sender), "Not burn preparer");
        usdcBurner = burner;
        usdcToBurn = amount;
    }

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {ITokenPairs} from "./interfaces/ITokenPairs.sol";
import {IMintedBurnableERC20} from "./interfaces/IMintedBurnableERC20.sol";

/// Extension of the TokenDeposit contract adding transition support of bridged USDT to native USDT.
/// @custom:security-contact security@fantom.foundation
abstract contract UsdtDepositExtension {

    address private constant USDT_ADDRESS_L1 = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    bytes32 public constant USDT_BURN_PREPARER_ROLE = keccak256("USDT_BURN_PREPARER_ROLE");

    ITokenPairs private immutable tokenPairs; // TokenPairs contract

    uint256 private usdtToBurn;
    address private usdtBurner;

    constructor(address _tokenPairs) {
        require(_tokenPairs != address(0), "TokenPairs not set");
        tokenPairs = ITokenPairs(_tokenPairs);
    }

    /// Burn USDT in the contract. To be called by Tether.
    /// Burning must be prepared first by calling prepareBurningUSDT().
    function burnLockedUSDT() external {
        require(msg.sender == usdtBurner, "Not USDT burner");
        uint256 amount = usdtToBurn;
        usdtToBurn = 0;
        IMintedBurnableERC20(USDT_ADDRESS_L1).burn(amount);
    }

    /// Prepare burning USDT in the contract. To be called by Sonic team.
    /// The USDT pair must be terminated first on both networks and the caller needs to have appropriate role assigned.
    /// @param burner The address defined by Tether allowed to call burnLockedUSDT()
    /// @param amount The total supply of bridged USDT on the Sonic network - to by burned by burnLockedUSDT() call.
    function prepareBurningUSDT(address burner, uint256 amount) external {
        require(tokenPairs.originalToMinted(USDT_ADDRESS_L1) != address(0), "USDT not registered yet");
        require(tokenPairs.originalToMintedTerminable(USDT_ADDRESS_L1) == address(0), "USDT not terminated");
        require(tokenPairs.hasRole(USDT_BURN_PREPARER_ROLE, msg.sender), "Not burn preparer");
        usdtBurner = burner;
        usdtToBurn = amount;
    }

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/// Minted ERC-20 tokens represents an Ethereum ERC-20 tokens on L2.
interface IMintedBurnableERC20 {
    function mint(address account, uint256 amount) external returns (bool);
    function burn(uint256 value) external;
    function burnFrom(address account, uint256 value) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/// Proof verifier allows to validate witness proof about a storage slot value on a different chain.
interface IProofVerifier {

    /// Verify witness proof - proof about storage slot value on a different chain.
    /// Reverts if the slot value does not match the expected value or if the proof is invalid.
    function verifyProof(address contractAddress, bytes32 slotIndex, bytes32 expectedValue, bytes32 stateRoot, bytes calldata proof) external view;

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/// Proving contract represents a contract which use the proof verifier.
/// Used for updating the proof verifier address.
interface IProvingContract {
    function proofVerifier() external view returns(address);
    function setProofVerifier(address proofVerifier) external;
    function setExitAdministrator(address exitAdministrator) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/// State oracle provides the hash of a different chain state.
interface IStateOracle {
    function lastState() external view returns (bytes32);
    function lastBlockNum() external view returns (uint256);
    function lastUpdateTime() external view returns (uint256);
    function chainId() external view returns (uint256);

    function update(uint256 blockNum, bytes32 stateRoot) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/// Interface of a token deposit manageable (in case of the bridge death) by ExitAdministrator.
interface ITokenDeposit {
    function withdrawWhileDead(address recipient, address token, uint256 amount) external;
    function fetchDeadStatus() external returns (bool);
    function deadState() external view returns (bytes32);
    function proofVerifier() external view returns (address);
    function tokenPairs() external view returns (address);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

// The token pairs registry maps Ethereum ERC-20 tokens to L2 tokens minted by the bridge.
interface ITokenPairs {
    /// Map Ethereum token to L2 token - pairs can be only added into this mapping.
    function originalToMinted(address) external view returns (address);

    /// Map Ethereum token to L2 token - pairs can be removed from here to block new transfers.
    function originalToMintedTerminable(address) external view returns (address);

    /// Map L2 token to Ethereum token - pairs can be only added into this mapping.
    function mintedToOriginal(address) external view returns (address);

    /// Check if the account has given role - allows to use TokenPairs as an AccessManager for USDC burning ops.
    function hasRole(bytes32 role, address account) external view returns (bool);
}