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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Access Control
 * @dev Provides Admin and Ownership access control.
 */
abstract contract AccessProtected is Context, Ownable(msg.sender), Pausable {
    mapping(address user => bool _admins) internal _admins; // user address => admin? mapping

    event AdminAccessSet(address indexed _admin, bool _enabled);

    /* ========== ERRORS ========== */
    error LengthMismatch();
    error NotAdmin();

    /**
     * @dev Sets an address as Admin with the specified access status.
     * @param admin The address to set as Admin.
     * @param enabled Whether to enable or disable Admin access.
     */
    function setAdmin(address admin, bool enabled) public onlyOwner {
        _admins[admin] = enabled;
        emit AdminAccessSet(admin, enabled);
    }

    /**
     * @dev Sets multiple addresses as Admin with specified access statuses.
     * @param admins The addresses to set as Admin.
     * @param enabled The corresponding enable/disable statuses for each Admin.
     */
    function batchSetAdmin(address[] memory admins, bool[] memory enabled) external onlyOwner {
        if (admins.length != enabled.length) {
            revert LengthMismatch();
        }
        for (uint256 i = 0; i < admins.length; i++) {
            setAdmin(admins[i], enabled[i]);
        }
    }

    /**
     * @dev Checks if an address is an Admin.
     * @param admin The address to check.
     * @return Whether the address is an Admin or not.
     */
    function isAdmin(address admin) public view returns (bool) {
        return _admins[admin];
    }

    /**
     * @dev Pauses contract operations.
     *
     * See {Pausable-_pause}.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses contract operations.
     *
     * See {Pausable-_unpause}.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Modifier to check if the caller is an Admin or the contract Owner.
     * Throws an error if called by an account without Admin or Owner access.
     */
    modifier onlyAdmin() {
        if (!(_admins[_msgSender()])) revert NotAdmin();
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { AccessProtected } from "../utils/AccessProtected.sol";

/**
 * @dev Interface for staking contract
 */
interface IStaking {
    function stakeClaimableToken(uint256 amount, address userAddress) external;
}

/**
 * @title MaivVesting
 * @notice Vest and unlock tokens
 */
contract MaivVesting is AccessProtected, ReentrancyGuard {
    using Address for address;

    /* ========== STATE VARIABLES ========== */
    address public tokenAddress;
    bool public isStakeVestedToken;
    mapping(uint256 index => address stakingContractAddresses) public stakingContractAddresses;

    struct Claim {
        bool isActive;
        uint256 vestAmount;
        uint256 unlockAmount;
        uint256 unlockTime;
        uint256 startTime;
        uint256 endTime;
        uint256 amountClaimed;
    }

    mapping(address user => Claim claims) private claims;

    /* ========== EVENTS ========== */
    event ClaimCreated(
        address indexed creator,
        address indexed beneficiary,
        uint256 vestAmount,
        uint256 unlockAmount,
        uint256 unlockTime,
        uint256 startTime,
        uint256 endTime
    );
    event Claimed(address indexed beneficiary, uint256 amount);
    event Revoked(address indexed beneficiary);
    event Recovered(address token, uint256 amount);
    event IsStakeVestedTokenChanged(bool isStakeVestedToken);

    /* ========== ERRORS ========== */
    error ClaimAlreadyActive();
    error InvalidTime();
    error ZeroAddressNotAllowed();
    error InvalidAmount();
    error InvalidAllowance();
    error ClaimInactive();
    error NothingToWithdraw();
    error LengthMismatched();
    error StakeVestedTokenPaused();

    /* ========== CONSTRUCTOR ========== */
    /**
     * @dev Initializes the contract with the token address
     * @param _tokenAddress Address of the token to be vested
     */
    constructor(address _tokenAddress) {
        if (_tokenAddress == address(0)) revert ZeroAddressNotAllowed();
        tokenAddress = _tokenAddress;
        isStakeVestedToken = true; // this enable direct staking for vested token
    }

    /* ========== MODIFIERS ========== */
    /**
     * @dev Checks if the claim is active for the beneficiary
     * @param beneficiary Address of the beneficiary
     */
    modifier isActiveClaim(address beneficiary) {
        if (beneficiary == address(0)) revert ZeroAddressNotAllowed();
        if (!claims[beneficiary].isActive) revert ClaimInactive();
        _;
    }

    /* ========== VIEWS ========== */
    /**
     * @dev Returns the claim details for a beneficiary
     * @param beneficiary Address of the beneficiary
     * @return Claim details
     */
    function getClaim(address beneficiary) external view returns (Claim memory) {
        if (beneficiary == address(0)) revert ZeroAddressNotAllowed();
        return claims[beneficiary];
    }

    /**
     * @dev Calculates the claimable amount for a beneficiary
     * @param beneficiary Address of the beneficiary
     * @return Claimable amount
     */
    function claimableAmount(address beneficiary) public view returns (uint256) {
        if (beneficiary == address(0)) revert ZeroAddressNotAllowed();
        Claim memory _claim = claims[beneficiary];
        if (block.timestamp < _claim.startTime && block.timestamp < _claim.unlockTime) {
            return 0;
        }
        if (_claim.amountClaimed == _claim.vestAmount) {
            return 0;
        }
        uint256 currentTimestamp = block.timestamp > _claim.endTime ? _claim.endTime : block.timestamp;
        uint256 claimPercent;
        uint256 claimAmount;
        uint256 unclaimedAmount;
        if (_claim.unlockTime <= block.timestamp && _claim.startTime <= block.timestamp) {
            claimPercent = ((currentTimestamp - _claim.startTime) * 1e18) / (_claim.endTime - _claim.startTime);
            claimAmount = (_claim.vestAmount * claimPercent) / 1e18 + _claim.unlockAmount;
            unclaimedAmount = claimAmount - _claim.amountClaimed;
        } else if (_claim.unlockTime > block.timestamp && _claim.startTime <= block.timestamp) {
            claimPercent = ((currentTimestamp - _claim.startTime) * 1e18) / (_claim.endTime - _claim.startTime);
            claimAmount = (_claim.vestAmount * claimPercent) / 1e18;
            unclaimedAmount = claimAmount - _claim.amountClaimed;
        } else {
            claimAmount = _claim.unlockAmount;
            unclaimedAmount = claimAmount - _claim.amountClaimed;
        }
        return unclaimedAmount;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    /**
     * @dev Creates a new claim for a beneficiary
     * @param _beneficiary Address of the beneficiary
     * @param _vestAmount Amount to be vested
     * @param _unlockAmount Amount to be unlocked
     * @param _unlockTime Time when the unlock amount is available
     * @param _startTime Start time of the vesting period
     * @param _endTime End time of the vesting period
     */
    function createClaim(
        address _beneficiary,
        uint256 _vestAmount,
        uint256 _unlockAmount,
        uint256 _unlockTime,
        uint64 _startTime,
        uint64 _endTime
    ) public onlyAdmin {
        if (claims[_beneficiary].isActive) revert ClaimAlreadyActive();
        if (_endTime <= _startTime || _endTime == 0) revert InvalidTime();
        if (_beneficiary == address(0)) revert ZeroAddressNotAllowed();
        if (_vestAmount == 0) revert InvalidAmount();
        if (IERC20(tokenAddress).allowance(msg.sender, address(this)) < (_vestAmount + _unlockAmount)) {
            revert InvalidAllowance();
        }
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _vestAmount + _unlockAmount);
        Claim memory newClaim = Claim({
            isActive: true,
            vestAmount: _vestAmount,
            unlockAmount: _unlockAmount,
            unlockTime: _unlockTime,
            startTime: _startTime,
            endTime: _endTime,
            amountClaimed: 0
        });
        claims[_beneficiary] = newClaim;
        emit ClaimCreated(msg.sender, _beneficiary, _vestAmount, _unlockAmount, _unlockTime, _startTime, _endTime);
    }

    /**
     * @dev Creates batch claims for multiple beneficiaries
     * @param _beneficiaries Array of beneficiary addresses
     * @param _vestAmounts Array of vesting amounts
     * @param _unlockAmounts Array of unlocking amounts
     * @param _unlockTimes Array of unlocking times
     * @param _startTimes Array of start times
     * @param _endTimes Array of end times
     */
    function createBatchClaim(
        address[] memory _beneficiaries,
        uint256[] memory _vestAmounts,
        uint256[] memory _unlockAmounts,
        uint256[] memory _unlockTimes,
        uint64[] memory _startTimes,
        uint64[] memory _endTimes
    ) external onlyAdmin {
        uint256 length = _beneficiaries.length;

        if (
            !(_vestAmounts.length == length &&
                _unlockAmounts.length == length &&
                _unlockTimes.length == length &&
                _startTimes.length == length &&
                _endTimes.length == length)
        ) {
            revert LengthMismatched();
        }

        for (uint256 i = 0; i < length; i++) {
            createClaim(
                _beneficiaries[i],
                _vestAmounts[i],
                _unlockAmounts[i],
                _unlockTimes[i],
                _startTimes[i],
                _endTimes[i]
            );
        }
    }

    /**
     * @dev Allows the beneficiary to claim their vested tokens
     */
    function claim(uint256 claimAmount) external nonReentrant isActiveClaim(msg.sender) {
        if (isStakeVestedToken) {
            revert StakeVestedTokenPaused();
        }
        address beneficiary = msg.sender;
        Claim memory _claim = claims[beneficiary];
        uint256 unclaimedAmount = claimableAmount(beneficiary);

        if (claimAmount > unclaimedAmount || claimAmount == 0) {
            revert InvalidAmount();
        }
        unclaimedAmount = claimAmount;
        _claim.amountClaimed += unclaimedAmount;
        if (_claim.amountClaimed == _claim.vestAmount) {
            _claim.isActive = false;
        }
        claims[beneficiary] = _claim;
        IERC20(tokenAddress).transfer(beneficiary, unclaimedAmount);
        emit Claimed(beneficiary, unclaimedAmount);
    }
    /**
     * @dev Allows the beneficiary to claim their vested tokens
     * @param stakingIndex index to choose staking address
     */
    function stakeVestedToken(
        uint256 claimAmount,
        uint256 stakingIndex
    ) external nonReentrant isActiveClaim(msg.sender) {
        if (!(isStakeVestedToken)) {
            revert StakeVestedTokenPaused();
        }
        if (stakingContractAddresses[stakingIndex] == address(0)) revert ZeroAddressNotAllowed();
        address beneficiary = msg.sender;
        Claim memory _claim = claims[beneficiary];
        uint256 unclaimedAmount = claimableAmount(beneficiary);
        if (claimAmount > unclaimedAmount || claimAmount == 0) {
            revert InvalidAmount();
        }
        unclaimedAmount = claimAmount;
        address stakingContractAddress = stakingContractAddresses[stakingIndex];
        if (stakingContractAddress == address(0)) revert ZeroAddressNotAllowed();

        _claim.amountClaimed += unclaimedAmount;
        if (_claim.amountClaimed == _claim.vestAmount) {
            _claim.isActive = false;
        }
        claims[beneficiary] = _claim;
        IERC20(tokenAddress).approve(stakingContractAddress, unclaimedAmount);
        IStaking(stakingContractAddress).stakeClaimableToken(unclaimedAmount, beneficiary);
        emit Claimed(beneficiary, unclaimedAmount);
    }

    /**
     * @dev set staking contract addresses to stake vested token
     * @param index index of staking contract address
     * @param _stakingContractAddress staking contract address
     */

    function setStakingContractAddress(uint256 index, address _stakingContractAddress) external onlyOwner {
        if (_stakingContractAddress == address(0)) revert ZeroAddressNotAllowed();
        stakingContractAddresses[index] = _stakingContractAddress;
    }

    /**
     * @dev Updates isStakeVestedToken
     * @param _isStakeVestedToken value to update IsStakeClaimableAmount
     */
    function setIsStakeVestedToken(bool _isStakeVestedToken) external onlyOwner {
        isStakeVestedToken = _isStakeVestedToken;
        emit IsStakeVestedTokenChanged(isStakeVestedToken);
    }

    /**
     * @dev Revokes the claim of a beneficiary
     * @param beneficiary Address of the beneficiary
     */
    function revoke(address beneficiary) external onlyAdmin {
        if (beneficiary == address(0)) revert ZeroAddressNotAllowed();
        claims[beneficiary].isActive = false;
        emit Revoked(beneficiary);
    }

    /**
     * @dev Withdraws tokens from the contract
     * @param wallet Address to receive the tokens
     * @param amount Amount of tokens to withdraw
     */
    function withdrawTokens(address wallet, uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) revert NothingToWithdraw();
        if (wallet == address(0)) revert ZeroAddressNotAllowed();
        IERC20(tokenAddress).transfer(wallet, amount);
    }

    /**
     * @dev recover any token from this contract to caller account
     * @param _token address for recovering token
     * @param _amount number of tokens want to recover
     * Added to support recovering to stuck tokens, even reward token in case emergency. only owner
     */
    function recoverERC20(address _token, uint256 _amount) external onlyOwner {
        if (_token == address(0)) revert ZeroAddressNotAllowed();
        if (_amount == 0) revert NothingToWithdraw();
        IERC20(_token).transfer(msg.sender, _amount);
        emit Recovered(_token, _amount);
    }
}