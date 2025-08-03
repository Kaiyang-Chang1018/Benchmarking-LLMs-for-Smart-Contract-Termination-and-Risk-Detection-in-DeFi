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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
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
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;

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

        (bool success,) = recipient.call{value: amount}("");
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
    function verifyCallResultFromTarget(address target, bool success, bytes memory returndata)
        internal
        view
        returns (bytes memory)
    {
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
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./interfaces/IElementNFT.sol";
import "./interfaces/IElement280.sol";
import "./lib/constants.sol";

/// @title Element 280 Holder Vault Contract
contract ElementHolderVault is Ownable2Step {
    using SafeERC20 for IERC20;

    // --------------------------- STATE VARIABLES --------------------------- //

    struct Cycle {
        uint256 timestamp;
        uint256 tokensPerMultiplier;
    }

    address public immutable E280;
    address public immutable E280_NFT;
    address public treasury;
    address public devWallet;

    /// @notice The total amount of rewards accumulated.
    uint256 public totalRewardPool;
    /// @notice The minimum pool size required to trigger a new cycle.
    uint256 public minCyclePool;
    /// @notice The total amount of rewards paid out to users.
    uint256 public totalRewadsPaid;
    /// @notice The total amount of E280 tokens burned during.
    uint256 public totalE280Burned;
    /// @notice The current cycle ID.
    uint256 public currentCycle;

    /// @notice A mapping of cycle IDs to the corresponding cycle data.
    /// @return timestamp The timestamp when the cycle was created.
    /// @return tokensPerMultiplier The number of tokens allocated per multiplier in this cycle.
    mapping(uint256 id => Cycle) public cycles;

    /// @notice A mapping of token IDs to the last claimed cycle ID for each token.
    mapping(uint256 tokenId => uint256) public claimedCycles;
    /// @notice A mapping of user addresses to the total amount of Element 280 tokens claimed by each user.
    mapping(address user => uint256) public claimed;

    event CycleUpdated();

    // --------------------------- CONSTRUCTOR --------------------------- //

    constructor(
        address _E280,
        address _E280_NFT,
        address _owner,
        address _devWallet,
        address _treasury,
        uint256 _minCyclePool
    ) Ownable(_owner) {
        require(_E280 != address(0), "E280 token address not provided");
        require(_E280_NFT != address(0), "E280 NFT address not provided");
        require(_owner != address(0), "Owner wallet not provided");
        require(_devWallet != address(0), "Dev wallet address not provided");
        require(_treasury != address(0), "Treasury address not provided");
        require(_minCyclePool > 0, "Minimum cycle pool not provided");

        E280 = _E280;
        E280_NFT = _E280_NFT;
        devWallet = _devWallet;
        treasury = _treasury;
        minCyclePool = _minCyclePool;
    }

    // --------------------------- PUBLIC FUNCTIONS --------------------------- //

    /// @notice Creates the new cycle by distributing the cycle pool and calculating tokens per multiplier.
    function updateCycle() external {
        require(block.timestamp > getNextCycleTime(), "Cooldown in progress");
        uint256 cyclePool = getNextCyclePool();
        require(cyclePool > minCyclePool, "Not enough E280 available");
        unchecked {
            currentCycle++;
            uint256 rewardPool = _processCyclePool(cyclePool);
            uint256 multiplierPool = IElementNFT(E280_NFT).multiplierPool();
            cycles[currentCycle] = Cycle(block.timestamp, rewardPool / multiplierPool);
            totalRewardPool += cycles[currentCycle].tokensPerMultiplier * multiplierPool;
        }
        emit CycleUpdated();
    }

    /// @notice Claims the accumulated Element 280 rewards for a batch of NFT tokens.
    /// @param tokenIds An array of token IDs for which rewards are being claimed.
    function claimRewards(uint256[] calldata tokenIds) external {
        require(currentCycle != 0, "No cycle created");
        (uint256[] memory timestamps, uint16[] memory multipliers) =
            IElementNFT(E280_NFT).getBatchedTokensData(tokenIds, msg.sender);
        uint256 totalReward;
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                totalReward += _processTokenId(tokenIds[i], timestamps[i], multipliers[i]);
            }
            claimed[msg.sender] += totalReward;
            totalRewadsPaid += totalReward;
        }
        IERC20(E280).safeTransfer(msg.sender, totalReward);
    }

    // --------------------------- ADMINISTRATIVE FUNCTIONS --------------------------- //

    /// @notice Sets the minimum pool size required to trigger a new cycle.
    /// @param limit The new minimum pool size in WEI.
    function setMinCyclePool(uint256 limit) external onlyOwner {
        minCyclePool = limit;
    }

    /// @notice Sets the treasury wallet address.
    /// @param _address The new treasury wallet address.
    function setTreasury(address _address) external onlyOwner {
        require(_address != address(0), "Treasury address not provided");
        treasury = _address;
    }

    // --------------------------- VIEW FUNCTIONS --------------------------- //

    /// @notice Returns the reward availability and total reward for a batch of tokens.
    /// @param tokenIds An array of token IDs to query.
    /// @param account The address of the token owner.
    /// @return availability A boolean array indicating whether each token is eligible for rewards in the current cycle.
    /// @return totalReward The total amount of rewards the account can claim for the eligible provided tokens.
    function getRewards(uint256[] calldata tokenIds, address account)
        external
        view
        returns (bool[] memory availability, uint256 totalReward)
    {
        require(tokenIds.length > 0, "No tokenIds provided");
        require(currentCycle != 0, "No cycles created");
        availability = new bool[](tokenIds.length);
        (uint256[] memory timestamps, uint16[] memory multipliers) =
            IElementNFT(E280_NFT).getBatchedTokensData(tokenIds, account);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            for (uint256 j = i + 1; j < tokenIds.length; j++) {
                require(tokenId != tokenIds[j], "Duplicate token ID");
            }
            uint256 nftTimestamp = timestamps[i];
            uint256 nftClaimedCycle = claimedCycles[tokenId];
            uint256 totalTokensPerMultiplier;
            uint256 startCycle = nftClaimedCycle == 0 ? _getNFTFirstCycle(nftTimestamp) : nftClaimedCycle + 1;
            availability[i] = startCycle <= currentCycle;
            if (startCycle <= currentCycle) {
                uint256 endCycle = _applyMaxCycleProtection(startCycle);
                unchecked {
                    for (uint256 j = startCycle; j <= endCycle; j++) {
                        totalTokensPerMultiplier += cycles[j].tokensPerMultiplier;
                    }
                    totalReward += totalTokensPerMultiplier * multipliers[i];
                }
            }
        }
    }

    /// @notice Returns the timestamp for when the next cycle will be available for update.
    /// @return The timestamp for the next cycle update.
    function getNextCycleTime() public view returns (uint256) {
        return cycles[currentCycle].timestamp + CYCLE_INTERVAL;
    }

    /// @notice Returns the available pool of tokens for the next cycle update.
    /// @return The amount of E280 tokens available for the next cycle, excluding rewards already allocated and paid.
    function getNextCyclePool() public view returns (uint256) {
        return IERC20(E280).balanceOf(address(this)) + totalRewadsPaid - totalRewardPool;
    }

    // --------------------------- INTERNAL FUNCTIONS --------------------------- //

    function _processTokenId(uint256 tokenId, uint256 nftTimestamp, uint16 multiplier)
        internal
        returns (uint256 tokenReward)
    {
        uint256 nftClaimedCycle = claimedCycles[tokenId];
        uint256 totalTokensPerMultiplier;
        uint256 startCycle = nftClaimedCycle == 0 ? _getNFTFirstCycle(nftTimestamp) : nftClaimedCycle + 1;
        require(startCycle <= currentCycle, "Cycle not available");
        uint256 endCycle = _applyMaxCycleProtection(startCycle);
        unchecked {
            for (uint256 i = startCycle; i <= endCycle; i++) {
                totalTokensPerMultiplier += cycles[i].tokensPerMultiplier;
            }
        }
        claimedCycles[tokenId] = endCycle;
        unchecked {
            tokenReward = totalTokensPerMultiplier * multiplier;
        }
    }

    function _processCyclePool(uint256 pool) internal returns (uint256 rewardPool) {
        IElement280 e280 = IElement280(E280);
        uint256 burnPool;
        uint256 devFee;
        uint256 treasuryFee;
        unchecked {
            if (e280.presaleEnd() < block.timestamp) {
                burnPool = pool * 20 / 100;
                devFee = pool * 15 / 100;
                treasuryFee = pool * 5 / 100;
            } else {
                burnPool = pool * 100 / 1000;
                devFee = pool * 75 / 1000;
                treasuryFee = pool * 25 / 1000;
            }
            totalE280Burned += burnPool;
            rewardPool = pool - burnPool - devFee - treasuryFee;
        }
        e280.burn(burnPool);
        IERC20(E280).safeTransfer(devWallet, devFee);
        IERC20(E280).safeTransfer(treasury, treasuryFee);
    }

    function _applyMaxCycleProtection(uint256 startCycle) internal view returns (uint256) {
        return
            currentCycle - startCycle + 1 > MAX_CYCLES_PER_CLAIM ? startCycle + MAX_CYCLES_PER_CLAIM - 1 : currentCycle;
    }

    function _getNFTFirstCycle(uint256 nftTimestamp) internal view returns (uint256) {
        for (uint256 i = 1; i <= currentCycle; i++) {
            if (cycles[i].timestamp > nftTimestamp) return i;
        }
        return currentCycle + 1;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20Burnable {
    function burn(uint256 value) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20Burnable.sol";

interface IElement280 is IERC20Burnable {
    function presaleEnd() external returns (uint256);
    function handleRedeem(uint256 amount, address receiver) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IElementNFT {
    function startPresale(uint256 _presaleEnd) external;
    function multiplierPool() external returns (uint256);
    function getBatchedTokensData(uint256[] calldata tokenIds, address owner)
        external
        view
        returns (uint256[] memory timestamps, uint16[] memory multipliers);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ITitanOnBurn {
    function onBurn(address user, uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/ITitanOnBurn.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

// ===================== Contract Addresses =====================================
uint8 constant NUM_ECOSYSTEM_TOKENS = 14;

address constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant TITANX = 0xF19308F923582A6f7c465e5CE7a9Dc1BEC6665B1;
address constant HYPER_ADDRESS = 0xE2cfD7a01ec63875cd9Da6C7c1B7025166c2fA2F;
address constant HELIOS_ADDRESS = 0x2614f29C39dE46468A921Fd0b41fdd99A01f2EDf;
address constant DRAGONX_ADDRESS = 0x96a5399D07896f757Bd4c6eF56461F58DB951862;
address constant BDX_ADDRESS = 0x9f278Dc799BbC61ecB8e5Fb8035cbfA29803623B;
address constant BLAZE_ADDRESS = 0xfcd7cceE4071aA4ecFAC1683b7CC0aFeCAF42A36;
address constant INFERNO_ADDRESS = 0x00F116ac0c304C570daAA68FA6c30a86A04B5C5F;
address constant HYDRA_ADDRESS = 0xCC7ed2ab6c3396DdBc4316D2d7C1b59ff9d2091F;
address constant AWESOMEX_ADDRESS = 0xa99AFcC6Aa4530d01DFFF8E55ec66E4C424c048c;
address constant FLUX_ADDRESS = 0xBFDE5ac4f5Adb419A931a5bF64B0f3BB5a623d06;

address constant DRAGONX_BURN_ADDRESS = 0x1d59429571d8Fde785F45bf593E94F2Da6072Edb;

// ===================== Presale ================================================
uint256 constant PRESALE_LENGTH = 28 days;
uint256 constant COOLDOWN_PERIOD = 48 hours;
uint256 constant LP_POOL_SIZE = 200_000_000_000 ether;

// ===================== Fees ===================================================
uint256 constant DEV_PERCENT = 6;
uint256 constant TREASURY_PERCENT = 4;
uint256 constant BURN_PERCENT = 10;

// ===================== Sell Tax ===============================================
uint256 constant PRESALE_TRANSFER_TAX_PERCENTAGE = 16;
uint256 constant TRANSFER_TAX_PERCENTAGE = 4;
uint256 constant NFT_REDEEM_TAX_PERCENTAGE = 3;

// ===================== Holder Vault ===========================================
uint16 constant MAX_CYCLES_PER_CLAIM = 100;
uint32 constant CYCLE_INTERVAL = 7 days;

// ===================== UNISWAP Interface ======================================

address constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
address constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
address constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
uint24 constant POOL_FEE_1PERCENT = 10000;

// ===================== Interface IDs ==========================================
bytes4 constant INTERFACE_ID_ERC165 = 0x01ffc9a7;
bytes4 constant INTERFACE_ID_ERC20 = type(IERC20).interfaceId;
bytes4 constant INTERFACE_ID_ERC721 = 0x80ac58cd;
bytes4 constant INTERFACE_ID_ERC721Metadata = 0x5b5e139f;
bytes4 constant INTERFACE_ID_ITITANONBURN = type(ITitanOnBurn).interfaceId;