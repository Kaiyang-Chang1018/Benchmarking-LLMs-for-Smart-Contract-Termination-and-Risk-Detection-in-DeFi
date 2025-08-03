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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./libraries/Errors.sol";

/**
 * @title Manager
 * @author Naturelab
 * @dev This contract is used to manage KMS addresses for batch operations.
 */
contract Manager is Ownable {
    mapping(address => bool) public operators;

    /**
     * @dev Initializes the contract by setting the admin and adding the initial operator to the whitelist.
     * @param _admin The address of the contract owner, it will be a multisignature address.
     * @param _initialOperator The address of the initial operator.
     */
    constructor(address _admin, address _initialOperator) Ownable(_admin) {
        operators[_initialOperator] = true;
    }

    // Event emitted when an operator is added to the whitelist
    event OperatorAdded(address operator);

    // Event emitted when an operator is removed from the whitelist
    event OperatorRemoved(address operator);

    // Modifier to restrict function access to the operators in the whitelist
    modifier onlyOperator() {
        if (!operators[msg.sender]) revert Errors.CallerNotOperator();
        _;
    }

    /**
     * @dev Allows the owner to add a new operator to the whitelist.
     * Emits an OperatorAdded event.
     * @param _operator The address of the operator to add.
     */
    function addOperator(address _operator) external onlyOwner {
        if (_operator == address(0)) revert Errors.InvalidOperator();
        operators[_operator] = true;
        emit OperatorAdded(_operator);
    }

    /**
     * @dev Allows the owner to remove an operator from the whitelist.
     * Emits an OperatorRemoved event.
     * @param _operator The address of the operator to remove.
     */
    function removeOperator(address _operator) external onlyOwner {
        if (!operators[_operator]) revert Errors.InvalidOperator();
        operators[_operator] = false;
        emit OperatorRemoved(_operator);
    }

    /**
     * @dev Allows operators to make multiple calls to different addresses in a single transaction.
     * @param _addresses An array of addresses to call.
     * @param _callBytes An array of call data bytes, each corresponding to a call to be made to the addresses.
     */
    function multiCall(address[] calldata _addresses, bytes[] calldata _callBytes) external onlyOperator {
        if (_callBytes.length != _addresses.length || _addresses.length == 0) revert Errors.InvalidLength();

        for (uint256 i = 0; i < _callBytes.length; ++i) {
            Address.functionCall(_addresses[i], _callBytes[i]);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

library Errors {
    // Revert Errors:
    error CallerNotOperator(); // 0xa5523ee5
    error CallerNotRebalancer(); // 0xbd72e291
    error CallerNotVault(); // 0xedd7338f
    error ExitFeeRateTooHigh(); // 0xf4d1caab
    error FlashloanInProgress(); // 0x772ac4e8
    error IncorrectState(); // 0x508c9390
    error InfoExpired(); // 0x4ddf4a65
    error InvalidAccount(); // 0x6d187b28
    error InvalidAdapter(); // 0xfbf66df1
    error InvalidAdmin(); // 0xb5eba9f0
    error InvalidAsset(); // 0xc891add2
    error InvalidCaller(); // 0x48f5c3ed
    error InvalidClaimTime(); // 0x1221b97b
    error InvalidFeeReceiver(); // 0xd200485c
    error InvalidFlashloanCall(); // 0xd2208d52
    error InvalidFlashloanHelper(); // 0x8690f016
    error InvalidFlashloanProvider(); // 0xb6b48551
    error InvalidGasLimit(); // 0x98bdb2e0
    error InvalidInitiator(); // 0xbfda1f28
    error InvalidLength(); // 0x947d5a84
    error InvalidLimit(); // 0xe55fb509
    error InvalidManagementFeeClaimPeriod(); // 0x4022e4f6
    error InvalidManagementFeeRate(); // 0x09aa66eb
    error InvalidMarketCapacity(); // 0xc9034604
    error InvalidNetAssets(); // 0x6da79d69
    error InvalidNewOperator(); // 0xba0cdec5
    error InvalidOperator(); // 0xccea9e6f
    error InvalidRebalancer(); // 0xff288a8e
    error InvalidRedeemOperator(); // 0xd214a597
    error InvalidSafeProtocolRatio(); // 0x7c6b23d6
    error InvalidShares(); // 0x6edcc523
    error InvalidTarget(); // 0x82d5d76a
    error InvalidToken(); // 0xc1ab6dc1
    error InvalidTokenId(); // 0x3f6cc768
    error InvalidUnderlyingToken(); // 0x2fb86f96
    error InvalidVault(); // 0xd03a6320
    error InvalidWithdrawalUser(); // 0x36c17319
    error ManagementFeeRateTooHigh(); // 0x09aa66eb
    error ManagementFeeClaimPeriodTooShort(); // 0x4022e4f6
    error MarketCapacityTooLow(); // 0xc9034604
    error NotSupportedYet(); // 0xfb89ba2a
    error PriceNotUpdated(); // 0x1f4bcb2b
    error PriceUpdatePeriodTooLong(); // 0xe88d3ecb
    error RatioOutOfRange(); // 0x9179cbfa
    error RevenueFeeRateTooHigh(); // 0x0674143f
    error UnSupportedOperation(); // 0xe9ec8129
    error UnsupportedToken(); // 0x6a172882
    error WithdrawZero(); // 0x7ea773a9

    // for 1inch swap
    error OneInchInvalidReceiver(); // 0xd540519e
    error OneInchInvalidToken(); // 0x8e7ad912
    error OneInchInvalidInputAmount(); // 0x672b500f
    error OneInchInvalidFunctionSignature(); // 0x247f51aa
    error OneInchUnexpectedSpentAmount(); // 0x295ada05
    error OneInchUnexpectedReturnAmount(); // 0x05e64ca8
    error OneInchNotSupported(); // 0x04b2de78
}