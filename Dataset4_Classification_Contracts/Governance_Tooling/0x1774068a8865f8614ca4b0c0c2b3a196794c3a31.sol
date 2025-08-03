// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";
import "./math/SignedMathUpgradeable.sol";

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMathUpgradeable.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
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
            require(denominator > prod1, "Math: mulDiv overflow");

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
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

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMathUpgradeable {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC1967.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.
 *
 * _Available since v4.8.3._
 */
interface IERC1967 {
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

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
 *
 * _Available since v3.4._
 */
library Clones {
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
        require(instance != address(0), "ERC1167: create failed");
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
        require(instance != address(0), "ERC1167: create2 failed");
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
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/IERC1967.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 */
abstract contract ERC1967Upgrade is IERC1967 {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822.sol";
import "../ERC1967/ERC1967Upgrade.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is IERC1822Proxiable, ERC1967Upgrade {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     *
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function upgradeTo(address newImplementation) public virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     *
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._
 * _Available since v4.9 for `string`, `bytes`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { IMinimalForwarder } from "./IMinimalForwarder.sol";

/**
 * @title Interface for AuctionManager
 * @notice Defines behaviour encapsulated in AuctionManager
 * @author highlight.xyz
 */
interface IAuctionManager {
    /**
     * @notice The state an auction is in
     * @param NON_EXISTENT Default state of auction pre-creation
     * @param LIVE_ON_CHAIN State of auction after creation but before the auction ends or is cancelled
     * @param CANCELLED_ON_CHAIN State of auction after auction is cancelled
     * @param FULFILLED State of auction after winning bid has been dispersed and NFT has left escrow
     */
    enum AuctionState {
        NON_EXISTENT,
        LIVE_ON_CHAIN,
        CANCELLED_ON_CHAIN,
        FULFILLED
    }

    /**
     * @notice The data structure containing all fields on an English Auction that need to be on-chain
     * @param collection The collection hosting the auctioned NFT
     * @param currency The currency bids must be made in
     * @param owner The auction owner
     * @param paymentRecipient The recipient account of the winning bid
     * @param endTime When the auction will tentatively end. Is 0 if first bid hasn't been made
     * @param tokenId The ID of the NFT being auctioned
     * @param mintWhenReserveMet If true, new NFT will be minted when reserve crossing bid is made
     * @param state Auction state
     */
    struct EnglishAuction {
        address collection;
        address currency;
        address owner;
        address payable paymentRecipient;
        uint256 endTime;
        uint256 tokenId; // if nft already exists
        bool mintWhenReserveMet;
        AuctionState state;
    }

    /**
     * @notice Used for information about auctions on editions
     * @param used True if the auction is for an auction on an edition
     * @param editionId ID of the edition used for this auction
     */
    struct EditionAuction {
        bool used;
        uint256 editionId;
    }

    /**
     * @notice Data required for a bidder to make a bid. Claims are signed, hashed and validated, acting as bid keys
     * @param auctionId ID of auction
     * @param bidPrice Price that bidder is bidding
     * @param reservePrice Price that bidder must bid greater than. Only relevant for the first bid on an auction
     * @param maxClaimsPerAccount Max bids that an account can make on an auction. Unlimited if 0
     * @param claimExpiryTimestamp Time when claim expires
     * @param buffer Minimum time that must be left in an auction after a bid is made
     * @param minimumIncrementPerBidPctBPS Minimum % that a bid must be higher than the previous highest bid by,
     *                                     in basis points
     * @param claimer Account that can use the claim
     */
    struct Claim {
        bytes32 auctionId;
        uint256 bidPrice;
        uint256 reservePrice;
        uint256 maxClaimsPerAccount;
        uint256 claimExpiryTimestamp;
        uint256 buffer;
        uint256 minimumIncrementPerBidPctBPS;
        address payable claimer;
    }

    /**
     * @notice Structure hosting highest bidder info
     * @param bidder Bidder with current highest bid
     * @param preferredNFTRecipient The account that the current highest bidder wants the NFT to go to if they win.
     *                              Useful for non-transferable NFTs being auctioned.
     * @param amount Amount of current highest bid
     */
    struct HighestBidderData {
        address payable bidder;
        address preferredNFTRecipient;
        uint256 amount;
    }

    /**
     * @notice Emitted when an english auction is created
     * @param auctionId ID of auction
     * @param owner Auction owner
     * @param collection Collection that NFT being auctioned is on
     * @param tokenId ID of NFT being auctioned
     * @param currency The currency bids must be made in
     * @param paymentRecipient The recipient account of the winning bid
     * @param endTime Auction end time
     */
    event EnglishAuctionCreated(
        bytes32 indexed auctionId,
        address indexed owner,
        address indexed collection,
        uint256 tokenId,
        address currency,
        address paymentRecipient,
        uint256 endTime
    );

    /**
     * @notice Emitted when a valid bid is made on an auction
     * @param auctionId ID of auction
     * @param bidder Bidder with new highest bid
     * @param firstBid True if this is the first bid, ie. first bid greater than reserve price
     * @param collection Collection that NFT being auctioned is on
     * @param tokenId ID of NFT being auctioned
     * @param value Value of bid
     * @param timeLengthened True if this bid extended the end time of the auction (by being bid >= endTime - buffer)
     * @param preferredNFTRecipient The account that the current highest bidder wants the NFT to go to if they win.
     *                              Useful for non-transferable NFTs being auctioned.
     * @param endTime The current end time of the auction
     */
    event Bid(
        bytes32 indexed auctionId,
        address indexed bidder,
        bool indexed firstBid,
        address collection,
        uint256 tokenId,
        uint256 value,
        bool timeLengthened,
        address preferredNFTRecipient,
        uint256 endTime
    );

    /**
     * @notice Emitted when an auction's end time is extended
     * @param auctionId ID of auction
     * @param tokenId ID of NFT being auctioned
     * @param collection Collection that NFT being auctioned is on
     * @param buffer Minimum time that must be left in an auction after a bid is made
     * @param newEndTime New end time of auction
     */
    event TimeLengthened(
        bytes32 indexed auctionId,
        uint256 indexed tokenId,
        address indexed collection,
        uint256 buffer,
        uint256 newEndTime
    );

    /**
     * @notice Emitted when an auction is won, and its terms are fulfilled
     * @param auctionId ID of auction
     * @param tokenId ID of NFT being auctioned
     * @param collection Collection that NFT being auctioned is on
     * @param owner Auction owner
     * @param winner Winning bidder
     * @param paymentRecipient The recipient account of the winning bid
     * @param nftRecipient The account receiving the auctioned NFT
     * @param currency The currency bids were made in
     * @param amount Winning bid value
     * @param paymentRecipientPctBPS The percentage of the winning bid going to the paymentRecipient, in basis points
     */
    event AuctionWon(
        bytes32 indexed auctionId,
        uint256 indexed tokenId,
        address indexed collection,
        address owner,
        address winner,
        address paymentRecipient,
        address nftRecipient,
        address currency,
        uint256 amount,
        uint256 paymentRecipientPctBPS
    );

    /**
     * @notice Emitted when an auction is cancelled on-chain (before any valid bids have been made).
     * @param auctionId ID of auction
     * @param owner Auction owner
     * @param collection Collection that NFT was being auctioned on
     * @param tokenId ID of NFT that was being auctioned
     */
    event AuctionCanceledOnChain(
        bytes32 indexed auctionId,
        address indexed owner,
        address indexed collection,
        uint256 tokenId
    );

    /**
     * @notice Emitted when the payment recipient of an auction is updated
     * @param auctionId ID of auction
     * @param owner Auction owner
     * @param newPaymentRecipient New payment recipient of auction
     */
    event PaymentRecipientUpdated(
        bytes32 indexed auctionId,
        address indexed owner,
        address indexed newPaymentRecipient
    );

    /**
     * @notice Emitted when the preferred NFT recipient of an auctionbid  is updated
     * @param auctionId ID of auction
     * @param owner Auction owner
     * @param newPreferredNFTRecipient New preferred nft recipient of auction
     */
    event PreferredNFTRecipientUpdated(
        bytes32 indexed auctionId,
        address indexed owner,
        address indexed newPreferredNFTRecipient
    );

    /**
     * @notice Emitted when the end time of an auction is updated
     * @param auctionId ID of auction
     * @param owner Auction owner
     * @param newEndTime New end time
     */
    event EndTimeUpdated(bytes32 indexed auctionId, address indexed owner, uint256 indexed newEndTime);

    /**
     * @notice Emitted when the platform is updated
     * @param newPlatform New platform
     */
    event PlatformUpdated(address newPlatform);

    /**
     * @notice Create an auction that mints the NFT being auctioned into escrow (mints the next NFT on the collection)
     * @param auctionId ID of auction
     * @param auction The auction details
     */
    function createAuctionForNewToken(bytes32 auctionId, EnglishAuction memory auction) external;

    /**
     * @notice Create an auction that mints an edition being auctioned into escrow (mints the next NFT on the edition)
     * @param auctionId ID of auction
     * @param auction The auction details
     */
    function createAuctionForNewEdition(
        bytes32 auctionId,
        IAuctionManager.EnglishAuction memory auction,
        uint256 editionId
    ) external;

    /**
     * @notice Create an auction for an existing NFT
     * @param auctionId ID of auction
     * @param auction The auction details
     */
    function createAuctionForExistingToken(bytes32 auctionId, EnglishAuction memory auction) external;

    /**
     * @notice Create an auction for an existing NFT, with atomic transfer approval meta-tx packets
     * @param auctionId ID of auction
     * @param auction The auction details
     * @param req The request containing the call to transfer the auctioned NFT into escrow
     * @param requestSignature The signed request
     */
    function createAuctionForExistingTokenWithMetaTxPacket(
        bytes32 auctionId,
        IAuctionManager.EnglishAuction memory auction,
        IMinimalForwarder.ForwardRequest calldata req,
        bytes calldata requestSignature
    ) external;

    /**
     * @notice Update the payment recipient for an auction
     * @param auctionId ID of auction being updated
     * @param newPaymentRecipient New payment recipient on the auction
     */
    function updatePaymentRecipient(bytes32 auctionId, address payable newPaymentRecipient) external;

    /**
     * @notice Update the preferred nft recipient of a bid
     * @param auctionId ID of auction being updated
     * @param newPreferredNFTRecipient New nft recipient on the auction bid
     */
    function updatePreferredNFTRecipient(bytes32 auctionId, address newPreferredNFTRecipient) external;

    /**
     * @notice Makes a bid on an auction
     * @param claim Claim needed to make the bid
     * @param claimSignature Claim signature to be unwrapped and validated
     * @param preferredNftRecipient Bidder's preferred recipient of NFT if they win auction
     */
    function bid(
        IAuctionManager.Claim calldata claim,
        bytes calldata claimSignature,
        address preferredNftRecipient
    ) external payable;

    /**
     * @notice Fulfill auction and disperse winning bid / auctioned NFT.
     * @dev Anyone can call this function
     * @param auctionId ID of auction to fulfill
     */
    function fulfillAuction(bytes32 auctionId) external;

    /**
     * @notice "Cancels" an auction on-chain, if a valid bid hasn't been made yet. Transfers NFT back to auction owner
     * @param auctionId ID of auction being "cancelled"
     */
    function cancelAuctionOnChain(bytes32 auctionId) external;

    /**
     * @notice Updates the platform account receiving a portion of winning bids
     * @param newPlatform New account to receive portion
     */
    function updatePlatform(address payable newPlatform) external;

    /**
     * @notice Updates the platform cut
     * @param newCutBPS New account to receive portion
     */
    function updatePlatformCut(uint256 newCutBPS) external;

    /**
     * @notice Update an auction's end time before first valid bid is made on auction
     * @param auctionId Auction ID
     * @param newEndTime New end time
     */
    function updateEndTime(bytes32 auctionId, uint256 newEndTime) external;

    /**
     * @notice Verifies the validity of a claim, simulating call to bid()
     * @param claim Claim needed to make the bid
     * @param claimSignature Claim signature to be unwrapped and validated
     * @param expectedMsgSender Expected msg.sender when bid() is called, that is being simulated
     */
    function verifyClaim(
        Claim calldata claim,
        bytes calldata claimSignature,
        address expectedMsgSender
    ) external view returns (bool);

    /**
     * @notice Get all data about an auction except for number of bids made per user
     * @param auctionId ID of auction
     */
    function getFullAuctionData(
        bytes32 auctionId
    ) external view returns (EnglishAuction memory, HighestBidderData memory, EditionAuction memory);

    /**
     * @notice Get all data about a set of auctions except for number of bids made per user
     * @param auctionIds IDs of auctions
     */
    function getFullAuctionsData(
        bytes32[] calldata auctionIds
    ) external view returns (EnglishAuction[] memory, HighestBidderData[] memory, EditionAuction[] memory);
}
// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

/**
 * @title Minimal forwarder interface
 * @author highlight.xyz
 */
interface IMinimalForwarder {
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
    }

    function execute(
        ForwardRequest calldata req,
        bytes calldata signature
    ) external payable returns (bool, bytes memory);

    function getNonce(address from) external view returns (uint256);

    function verify(ForwardRequest calldata req, bytes calldata signature) external view returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../royaltyManager/interfaces/IRoyaltyManager.sol";
import "../tokenManager/interfaces/ITokenManager.sol";
import "../utils/Ownable.sol";
import "../utils/ERC2981/IERC2981Upgradeable.sol";
import "../utils/ERC165/ERC165CheckerUpgradeable.sol";
import "../metatx/ERC2771ContextUpgradeable.sol";
import "../observability/IObservabilityV2.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/**
 * @title Base ERC1155
 * @author highlight.xyz
 * @notice Core piece of Highlight NFT contracts (v2)
 */
abstract contract ERC1155Base is
    OwnableUpgradeable,
    IERC2981Upgradeable,
    ERC2771ContextUpgradeable,
    ReentrancyGuardUpgradeable
{
    using EnumerableSet for EnumerableSet.AddressSet;
    using ERC165CheckerUpgradeable for address;

    /**
     * @notice Throw when token or royalty manager is invalid
     */
    error InvalidManager();

    /**
     * @notice Throw when token or royalty manager does not exist
     */
    error ManagerDoesNotExist();

    /**
     * @notice Throw when sender is unauthorized to perform action
     */
    error Unauthorized();

    /**
     * @notice Throw when sender is not a minter
     */
    error NotMinter();

    /**
     * @notice Throw when token manager or royalty manager swap is blocked
     */
    error ManagerSwapBlocked();

    /**
     * @notice Throw when token manager or royalty manager remove is blocked
     */
    error ManagerRemoveBlocked();

    /**
     * @notice Throw when setting default or granular royalty is blocked
     */
    error RoyaltySetBlocked();

    /**
     * @notice Throw when royalty BPS is invalid
     */
    error RoyaltyBPSInvalid();

    /**
     * @notice Throw when minter registration is invalid
     */
    error MinterRegistrationInvalid();

    /**
     * @notice Set of minters allowed to mint on contract
     */
    EnumerableSet.AddressSet internal _minters;

    /**
     * @notice Global token/edition manager default
     */
    address public defaultManager;

    /**
     * @notice Token managers per token. 1155 token id.
     */
    mapping(uint256 => address) internal _managers;

    /**
     * @notice Default royalty for entire contract
     */
    IRoyaltyManager.Royalty internal _defaultRoyalty;

    /**
     * @notice Royalty per token. 1155 token id.
     */
    mapping(uint256 => IRoyaltyManager.Royalty) internal _royalties;

    /**
     * @notice Royalty manager - optional contract that defines the conditions around setting royalties
     */
    address public royaltyManager;

    /**
     * @notice Freezes minting on smart contract forever
     */
    uint8 internal _mintFrozen;

    /**
     * @notice Observability contract
     */
    IObservabilityV2 public observability;

    /**
     * @notice Emitted when minter is registered or unregistered
     * @param minter Minter that was changed
     * @param registered True if the minter was registered, false if unregistered
     */
    event MinterRegistrationChanged(address indexed minter, bool indexed registered);

    /**
     * @notice Emitted when token managers are set for token/edition ids
     * @param _ids token ids
     * @param _tokenManagers Token managers to set for tokens / editions
     */
    event GranularTokenManagersSet(uint256[] _ids, address[] _tokenManagers);

    /**
     * @notice Emitted when token managers are removed for token/edition ids
     * @param _ids token ids to remove token managers for
     */
    event GranularTokenManagersRemoved(uint256[] _ids);

    /**
     * @notice Emitted when default token manager changed
     * @param newDefaultTokenManager New default token manager. Zero address if old one was removed
     */
    event DefaultTokenManagerChanged(address indexed newDefaultTokenManager);

    /**
     * @notice Emitted when default royalty is set
     * @param recipientAddress Royalty recipient
     * @param royaltyPercentageBPS Percentage of sale (in basis points) owed to royalty recipient
     */
    event DefaultRoyaltySet(address indexed recipientAddress, uint16 indexed royaltyPercentageBPS);

    /**
     * @notice Emitted when royalties are set for token ids
     * @param ids Token ids
     * @param _newRoyalties New royalties for each token
     */
    event GranularRoyaltiesSet(uint256[] ids, IRoyaltyManager.Royalty[] _newRoyalties);

    /**
     * @notice Emitted when royalty manager is updated
     * @param newRoyaltyManager New royalty manager. Zero address if old one was removed
     */
    event RoyaltyManagerChanged(address indexed newRoyaltyManager);

    /**
     * @notice Emitted when mints are frozen permanently
     */
    event MintsFrozen();

    /**
     * @notice Restricts calls to minters
     */
    modifier onlyMinter() {
        if (!_minters.contains(_msgSender())) {
            _revert(NotMinter.selector);
        }
        _;
    }

    /**
     * @notice Restricts calls if input royalty bps is over 10000
     */
    modifier royaltyValid(uint16 _royaltyBPS) {
        if (!_royaltyBPSValid(_royaltyBPS)) {
            _revert(RoyaltyBPSInvalid.selector);
        }
        _;
    }

    /**
     * @notice Registers a minter
     * @param minter New minter
     */
    function registerMinter(address minter) external onlyOwner {
        if (!_minters.add(minter)) {
            _revert(MinterRegistrationInvalid.selector);
        }

        emit MinterRegistrationChanged(minter, true);
        observability.emitMinterRegistrationChanged(minter, true);
    }

    /**
     * @notice Unregisters a minter
     * @param minter Minter to unregister
     */
    function unregisterMinter(address minter) external onlyOwner {
        if (!_minters.remove(minter)) {
            _revert(MinterRegistrationInvalid.selector);
        }

        emit MinterRegistrationChanged(minter, false);
        observability.emitMinterRegistrationChanged(minter, false);
    }

    /**
     * @notice Sets granular token managers if current token manager(s) allow it
     * @param _ids Token ids
     * @param _tokenManagers Token managers to set for tokens / editions
     */
    function setGranularTokenManagers(
        uint256[] calldata _ids,
        address[] calldata _tokenManagers
    ) external nonReentrant {
        address msgSender = _msgSender();
        address tempOwner = owner();

        uint256 idsLength = _ids.length;
        for (uint256 i = 0; i < idsLength; i++) {
            if (!_isValidTokenManager(_tokenManagers[i])) {
                _revert(InvalidManager.selector);
            }
            address currentTokenManager = tokenManager(_ids[i]);
            if (currentTokenManager == address(0)) {
                if (msgSender != tempOwner) {
                    _revert(Unauthorized.selector);
                }
            } else {
                if (!ITokenManager(currentTokenManager).canSwap(msgSender, _ids[i], _managers[i])) {
                    _revert(ManagerSwapBlocked.selector);
                }
            }

            _managers[_ids[i]] = _tokenManagers[i];
        }

        emit GranularTokenManagersSet(_ids, _tokenManagers);
        observability.emitGranularTokenManagersSet(_ids, _tokenManagers);
    }

    /**
     * @notice Remove granular token managers
     * @param _ids Token ids to remove token managers for
     */
    function removeGranularTokenManagers(uint256[] calldata _ids) external nonReentrant {
        address msgSender = _msgSender();

        uint256 idsLength = _ids.length;
        for (uint256 i = 0; i < idsLength; i++) {
            address currentTokenManager = _managers[_ids[i]];
            if (currentTokenManager == address(0)) {
                _revert(ManagerDoesNotExist.selector);
            }
            if (!ITokenManager(currentTokenManager).canRemoveItself(msgSender, _ids[i])) {
                _revert(ManagerRemoveBlocked.selector);
            }

            _managers[_ids[i]] = address(0);
        }

        emit GranularTokenManagersRemoved(_ids);
        observability.emitGranularTokenManagersRemoved(_ids);
    }

    /**
     * @notice Set default token manager if current token manager allows it
     * @param _defaultTokenManager New default token manager
     */
    function setDefaultTokenManager(address _defaultTokenManager) external nonReentrant {
        if (!_isValidTokenManager(_defaultTokenManager)) {
            _revert(InvalidManager.selector);
        }
        address msgSender = _msgSender();

        address currentTokenManager = defaultManager;
        if (currentTokenManager == address(0)) {
            if (msgSender != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!ITokenManager(currentTokenManager).canSwap(msgSender, 0, _defaultTokenManager)) {
                _revert(ManagerSwapBlocked.selector);
            }
        }

        defaultManager = _defaultTokenManager;

        emit DefaultTokenManagerChanged(_defaultTokenManager);
        observability.emitDefaultTokenManagerChanged(_defaultTokenManager);
    }

    /**
     * @notice Removes default token manager if current token manager allows it
     */
    function removeDefaultTokenManager() external nonReentrant {
        address msgSender = _msgSender();

        address currentTokenManager = defaultManager;
        if (currentTokenManager == address(0)) {
            _revert(ManagerDoesNotExist.selector);
        }
        if (!ITokenManager(currentTokenManager).canRemoveItself(msgSender, 0)) {
            _revert(ManagerRemoveBlocked.selector);
        }

        defaultManager = address(0);

        emit DefaultTokenManagerChanged(address(0));
        observability.emitDefaultTokenManagerChanged(address(0));
    }

    /**
     * @notice Sets default royalty if royalty manager allows it
     * @param _royalty New default royalty
     */
    function setDefaultRoyalty(
        IRoyaltyManager.Royalty calldata _royalty
    ) external nonReentrant royaltyValid(_royalty.royaltyPercentageBPS) {
        address msgSender = _msgSender();

        address _royaltyManager = royaltyManager;
        if (_royaltyManager == address(0)) {
            if (msgSender != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!IRoyaltyManager(_royaltyManager).canSetDefaultRoyalty(_royalty, msgSender)) {
                _revert(RoyaltySetBlocked.selector);
            }
        }

        _defaultRoyalty = _royalty;

        emit DefaultRoyaltySet(_royalty.recipientAddress, _royalty.royaltyPercentageBPS);
        observability.emitDefaultRoyaltySet(_royalty.recipientAddress, _royalty.royaltyPercentageBPS);
    }

    /**
     * @notice Sets granular royalties (per token) if royalty manager allows it
     * @param ids Token ids
     * @param _newRoyalties New royalties for each token
     */
    function setGranularRoyalties(
        uint256[] calldata ids,
        IRoyaltyManager.Royalty[] calldata _newRoyalties
    ) external nonReentrant {
        address msgSender = _msgSender();
        address tempOwner = owner();

        address _royaltyManager = royaltyManager;
        uint256 idsLength = ids.length;
        if (_royaltyManager == address(0)) {
            if (msgSender != tempOwner) {
                _revert(Unauthorized.selector);
            }

            for (uint256 i = 0; i < idsLength; i++) {
                if (!_royaltyBPSValid(_newRoyalties[i].royaltyPercentageBPS)) {
                    _revert(RoyaltyBPSInvalid.selector);
                }
                _royalties[ids[i]] = _newRoyalties[i];
            }
        } else {
            for (uint256 i = 0; i < idsLength; i++) {
                if (!_royaltyBPSValid(_newRoyalties[i].royaltyPercentageBPS)) {
                    _revert(RoyaltyBPSInvalid.selector);
                }
                if (!IRoyaltyManager(_royaltyManager).canSetGranularRoyalty(ids[i], _newRoyalties[i], msgSender)) {
                    _revert(RoyaltySetBlocked.selector);
                }
                _royalties[ids[i]] = _newRoyalties[i];
            }
        }

        emit GranularRoyaltiesSet(ids, _newRoyalties);
        observability.emitGranularRoyaltiesSet(ids, _newRoyalties);
    }

    /**
     * @notice Sets royalty manager if current one allows it
     * @param _royaltyManager New royalty manager
     */
    function setRoyaltyManager(address _royaltyManager) external nonReentrant {
        if (!_isValidRoyaltyManager(_royaltyManager)) {
            _revert(InvalidManager.selector);
        }
        address msgSender = _msgSender();

        address currentRoyaltyManager = royaltyManager;
        if (currentRoyaltyManager == address(0)) {
            if (msgSender != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!IRoyaltyManager(currentRoyaltyManager).canSwap(_royaltyManager, msgSender)) {
                _revert(ManagerSwapBlocked.selector);
            }
        }

        royaltyManager = _royaltyManager;

        emit RoyaltyManagerChanged(_royaltyManager);
        observability.emitRoyaltyManagerChanged(_royaltyManager);
    }

    /**
     * @notice Removes royalty manager if current one allows it
     */
    function removeRoyaltyManager() external nonReentrant {
        address msgSender = _msgSender();

        address currentRoyaltyManager = royaltyManager;
        if (currentRoyaltyManager == address(0)) {
            _revert(ManagerDoesNotExist.selector);
        }
        if (!IRoyaltyManager(currentRoyaltyManager).canRemoveItself(msgSender)) {
            _revert(ManagerRemoveBlocked.selector);
        }

        royaltyManager = address(0);

        emit RoyaltyManagerChanged(address(0));
        observability.emitRoyaltyManagerChanged(address(0));
    }

    /**
     * @notice Freeze mints on contract forever
     */
    function freezeMints() external onlyOwner nonReentrant {
        _mintFrozen = 1;

        emit MintsFrozen();
        observability.emitMintsFrozen();
    }

    /**
     * @notice Return allowed minters on contract
     */
    function minters() external view returns (address[] memory) {
        return _minters.values();
    }

    /**
     * @notice Conforms to ERC-2981. Editions should overwrite to return royalty for entire edition
     * @param _tokenId Token id
     * @param _salePrice Sale price of token
     */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) public view virtual override returns (address receiver, uint256 royaltyAmount) {
        IRoyaltyManager.Royalty memory royalty = _royalties[_tokenId];
        if (royalty.recipientAddress == address(0)) {
            royalty = _defaultRoyalty;
        }

        receiver = royalty.recipientAddress;
        royaltyAmount = (_salePrice * uint256(royalty.royaltyPercentageBPS)) / 10000;
    }

    /**
     * @notice Returns the token manager for the id passed in.
     * @param id Token ID
     */
    function tokenManager(uint256 id) public view returns (address manager) {
        manager = defaultManager;
        address granularManager = _managers[id];

        if (granularManager != address(0)) {
            manager = granularManager;
        }
    }

    /**
     * @notice Initializes the contract, setting the creator as the initial owner.
     * @param _creator Contract creator
     * @param defaultRoyalty Default royalty for the contract
     * @param _defaultTokenManager Default token manager for the contract
     */
    function __ERC1155Base_initialize(
        address _creator,
        IRoyaltyManager.Royalty memory defaultRoyalty,
        address _defaultTokenManager
    ) internal onlyInitializing royaltyValid(defaultRoyalty.royaltyPercentageBPS) {
        __Ownable_init();
        __ReentrancyGuard_init();
        _transferOwnership(_creator);

        if (defaultRoyalty.recipientAddress != address(0)) {
            _defaultRoyalty = defaultRoyalty;
        }

        if (_defaultTokenManager != address(0)) {
            defaultManager = _defaultTokenManager;
        }
    }

    /**
     * @notice Returns true if address is a valid tokenManager
     * @param _tokenManager Token manager being checked
     */
    function _isValidTokenManager(address _tokenManager) internal view returns (bool) {
        return _tokenManager.supportsInterface(type(ITokenManager).interfaceId);
    }

    /**
     * @notice Returns true if address is a valid royaltyManager
     * @param _royaltyManager Royalty manager being checked
     */
    function _isValidRoyaltyManager(address _royaltyManager) internal view returns (bool) {
        return _royaltyManager.supportsInterface(type(IRoyaltyManager).interfaceId);
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgSender()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure virtual {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgData()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }

    /**
     * @notice Returns true if royalty bps passed in is valid (<= 10000)
     * @param _royaltyBPS Royalty basis points
     */
    function _royaltyBPSValid(uint16 _royaltyBPS) private pure returns (bool) {
        return _royaltyBPS <= 10000;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "./interfaces/IERC1155EditionsDFS.sol";
import "./ERC1155Base.sol";
import "../utils/Ownable.sol";
import "../metadata/interfaces/IMetadataRenderer.sol";
import "../metadata/interfaces/IEditionsMetadataRenderer.sol";
import "../auction/interfaces/IAuctionManager.sol";
import "../erc721/interfaces/IEditionCollection.sol";

import "../tokenManager/interfaces/IPostTransfer.sol";
import "../tokenManager/interfaces/IPostBurn.sol";
import "../tokenManager/interfaces/ITokenManagerEditions.sol";
import "../erc721/interfaces/IERC721EditionMint.sol";
import "../utils/ERC1155/ERC1155Upgradeable.sol";
import "../mint/interfaces/IAbridgedMintVector.sol";
import "../mint/mechanics/interfaces/IMechanicMintManager.sol";
import "./interfaces/IERC1155Standard.sol";

/**
 * @title ERC1155 Editions
 * @author highlight.xyz
 * @notice Multiple Editions Per Collection
 * @dev Using Decentralized File Storage
 */
contract ERC1155EditionsDFS is
    IEditionCollection,
    IERC1155EditionsDFS,
    IERC721EditionMint,
    ERC1155Base,
    ERC1155Upgradeable,
    IERC1155Standard
{
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Throw when edition doesn't exist
     */
    error EditionDoesNotExist();

    /**
     * @notice Throw when token doesn't exist
     */
    error TokenDoesNotExist();

    /**
     * @notice Throw when attempting to mint, while mint is frozen
     */
    error MintFrozen();

    /**
     * @notice Throw when tokens on edition are sold out
     */
    error SoldOut();

    /**
     * @notice Throw when edition size is invalid
     */
    error InvalidSize();

    /**
     * @notice Throw when edition burn is invalid
     */
    error InvalidBurn();

    /**
     * @notice Throw when edition metadata update is blocked
     */
    error MetadataUpdateBlocked();

    /**
     * @notice Track each token's current supply and max supply
     */
    struct EditionSupply {
        uint128 currentSupply;
        uint128 maxSupply;
    }

    /**
     * @notice Contract metadata
     */
    string public contractURI;
    string public name;
    string public symbol;

    /**
     * @notice Keeps track of next token ID
     */
    uint256 public nextTokenId;

    /**
     * @notice Tracks each edition/token's supply
     */
    mapping(uint256 => EditionSupply) public editionSupply;

    /**
     * @notice Track metadata per edition
     */
    mapping(uint256 => string) private _editionURI;

    /**
     * @notice Emitted when edition is created
     * @param editionId Edition/token ID
     * @param size Edition size
     * @param editionTokenManager Token manager for edition
     */
    event EditionCreated(uint256 indexed editionId, uint256 indexed size, address indexed editionTokenManager);

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param data Contract initialization data
     * @ param _contractURI Contract metadata
     * @ param _name Name of token edition
     * @ param _symbol Symbol of the token edition
     * @ param trustedForwarder Trusted minimal forwarder
     * @ param initialMinters Initial minters to register
     * @ param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @ param _observability Observability contract address
     */
    function initialize(address creator, bytes memory data) external initializer {
        (
            string memory _contractURI,
            string memory _name,
            string memory _symbol,
            address trustedForwarder,
            address[] memory initialMinters,
            bool useMarketplaceFiltererRegistry,
            address _observability
        ) = abi.decode(data, (string, string, string, address, address[], bool, address));

        IRoyaltyManager.Royalty memory _defaultRoyalty = IRoyaltyManager.Royalty(address(0), 0);
        _initialize(
            creator,
            _defaultRoyalty,
            address(0),
            _contractURI,
            _name,
            _symbol,
            trustedForwarder,
            initialMinters,
            useMarketplaceFiltererRegistry,
            _observability
        );
    }

    /**
     * @notice Create edition
     * @param _editionUri Edition uri (metadata)
     * @param _editionSize Size of the Edition
     * @param _editionTokenManager Edition's token manager
     * @param editionRoyalty Edition royalty object for contract (optional)
     * @param mintVectorData Direct mint vector data
     * @notice Used to create a new Edition within the Collection
     */
    function createEdition(
        string memory _editionUri,
        uint256 _editionSize,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty,
        bytes calldata mintVectorData
    ) external onlyOwner nonReentrant returns (uint256) {
        uint256 editionId = _createEdition(_editionUri, _editionSize, _editionTokenManager);
        if (editionRoyalty.recipientAddress != address(0)) {
            _royalties[editionId] = editionRoyalty;
        }

        if (mintVectorData.length > 0) {
            (
                address mintManager,
                address paymentRecipient,
                uint48 startTimestamp,
                uint48 endTimestamp,
                uint192 pricePerToken,
                uint48 tokenLimitPerTx,
                uint48 maxTotalClaimableViaVector,
                uint48 maxUserClaimableViaVector,
                address currency
            ) = abi.decode(
                    mintVectorData,
                    (address, address, uint48, uint48, uint192, uint48, uint48, uint48, address)
                );

            IAbridgedMintVector(mintManager).createAbridgedVector(
                IAbridgedMintVector.AbridgedVectorData(
                    uint160(address(this)),
                    startTimestamp,
                    endTimestamp,
                    uint160(paymentRecipient),
                    maxTotalClaimableViaVector,
                    0,
                    uint160(currency),
                    tokenLimitPerTx,
                    maxUserClaimableViaVector,
                    pricePerToken,
                    uint48(editionId), // cast down
                    true,
                    false,
                    0
                )
            );
        }

        return editionId;
    }

    /**
     * @notice Used to create a new Edition within the Collection
     * @param _editionUri Edition uri (metadata)
     * @param _editionSize Size of the Edition
     * @param _editionTokenManager Edition's token manager
     * @param editionRoyalty Edition royalty object for contract (optional)
     * @param mechanicVectorData Mechanic mint vector data
     * @ param mechanicVectorId Global mechanic vector ID
     * @ param mechanic Mechanic address
     * @ param mintManager Mint manager address
     * @ param vectorData Vector data
     */
    function createEditionWithMechanicVector(
        string memory _editionUri,
        uint256 _editionSize,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty,
        bytes calldata mechanicVectorData
    ) external onlyOwner nonReentrant returns (uint256) {
        uint256 editionId = _createEdition(_editionUri, _editionSize, _editionTokenManager);
        if (editionRoyalty.recipientAddress != address(0)) {
            _royalties[editionId] = editionRoyalty;
        }

        if (mechanicVectorData.length > 0) {
            (uint96 seed, address mechanic, address mintManager, bytes memory vectorData) = abi.decode(
                mechanicVectorData,
                (uint96, address, address, bytes)
            );

            IMechanicMintManager(mintManager).registerMechanicVector(
                IMechanicData.MechanicVectorMetadata(address(this), uint96(editionId), mechanic, true, false, false),
                seed,
                vectorData
            );
        }

        return editionId;
    }

    /**
     * @notice Used to create a new Edition within the Collection
     * @param _editionUri Edition uri (metadata)
     * @param _editionSize Size of the Edition
     * @param _editionTokenManager Edition's token manager
     * @param editionRoyalty Edition royalty object for contract (optional)
     * @param mintVectorData Direct mint vector data
     * @param mechanicVectorData Mechanic mint vector data
     * @ param mechanicVectorId Global mechanic vector ID
     * @ param mechanic Mechanic address
     * @ param mintManager Mint manager address
     * @ param vectorData Vector data
     */
    function createEditionWithMechanicVectorAndPublicFixedPriceVector(
        string memory _editionUri,
        uint256 _editionSize,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty,
        bytes calldata mintVectorData,
        bytes calldata mechanicVectorData
    ) external onlyOwner nonReentrant returns (uint256) {
        uint256 editionId = _createEdition(_editionUri, _editionSize, _editionTokenManager);
        if (editionRoyalty.recipientAddress != address(0)) {
            _royalties[editionId] = editionRoyalty;
        }

        if (mintVectorData.length > 0) {
            (
                address mintManager,
                address paymentRecipient,
                uint48 startTimestamp,
                uint48 endTimestamp,
                uint192 pricePerToken,
                uint48 tokenLimitPerTx,
                uint48 maxTotalClaimableViaVector,
                uint48 maxUserClaimableViaVector,
                address currency
            ) = abi.decode(
                    mintVectorData,
                    (address, address, uint48, uint48, uint192, uint48, uint48, uint48, address)
                );

            IAbridgedMintVector(mintManager).createAbridgedVector(
                IAbridgedMintVector.AbridgedVectorData(
                    uint160(address(this)),
                    startTimestamp,
                    endTimestamp,
                    uint160(paymentRecipient),
                    maxTotalClaimableViaVector,
                    0,
                    uint160(currency),
                    tokenLimitPerTx,
                    maxUserClaimableViaVector,
                    pricePerToken,
                    uint48(editionId), // cast down
                    true,
                    false,
                    0
                )
            );
        }

        if (mechanicVectorData.length > 0) {
            (uint96 seed, address mechanic, address mintManager, bytes memory vectorData) = abi.decode(
                mechanicVectorData,
                (uint96, address, address, bytes)
            );

            IMechanicMintManager(mintManager).registerMechanicVector(
                IMechanicData.MechanicVectorMetadata(address(this), uint96(editionId), mechanic, true, false, false),
                seed,
                vectorData
            );
        }

        return editionId;
    }

    /**
     * @notice See {IERC721EditionMint-mintOneToRecipient}
     */
    function mintOneToRecipient(
        uint256 editionId,
        address recipient
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }

        return _mintEditionsToOne(editionId, recipient, 1);
    }

    /**
     * @notice See {IERC721EditionMint-mintAmountToRecipient}
     */
    function mintAmountToRecipient(
        uint256 editionId,
        address recipient,
        uint256 amount
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }

        return _mintEditionsToOne(editionId, recipient, amount);
    }

    /**
     * @notice See {IERC721EditionMint-mintOneToRecipients}
     */
    function mintOneToRecipients(
        uint256 editionId,
        address[] memory recipients
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }

        return _mintEditions(editionId, recipients, 1);
    }

    /**
     * @notice See {IERC721EditionMint-mintAmountToRecipients}
     */
    function mintAmountToRecipients(
        uint256 editionId,
        address[] memory recipients,
        uint256 amount
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }

        return _mintEditions(editionId, recipients, amount);
    }

    /**
     * @notice Set contract name
     * @param newName New name
     * @param newSymbol New symbol
     * @param newContractUri New contractURI
     */
    function setContractMetadata(
        string calldata newName,
        string calldata newSymbol,
        string calldata newContractUri
    ) external onlyOwner {
        _setContractMetadata(newName, newSymbol);
        contractURI = newContractUri;

        observability.emitContractMetadataSet(newName, newSymbol, newContractUri);
    }

    /**
     * @notice Set an Edition's uri
     * @param editionId Edition to set uri for
     * @param _uri Uri to set on editions
     */
    function setEditionURI(uint256 editionId, string calldata _uri) external {
        address _manager = tokenManager(editionId);
        address msgSender = _msgSender();

        if (_manager == address(0)) {
            address tempOwner = owner();
            if (msgSender != tempOwner) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (
                !ITokenManagerEditions(_manager).canUpdateEditionsMetadata(
                    address(this),
                    msgSender,
                    editionId,
                    bytes(_uri),
                    ITokenManagerEditions.FieldUpdated.other
                )
            ) {
                _revert(MetadataUpdateBlocked.selector);
            }
        }

        _editionURI[editionId] = _uri;

        uint256[] memory _ids = new uint256[](1);
        _ids[0] = editionId;
        string[] memory _uris = new string[](1);
        _uris[0] = _uri;
        observability.emitTokenURIsSet(_ids, _uris);
    }

    /**
     * @notice See {IERC1155Standard-highlightContractStandardHash}
     */
    function highlightContractStandardHash() external view returns (bytes32) {
        return 0x3a9654d81ac4dafbb9a2fb1cd3efa3de2783ae40b06b17a456bf5922ed02a3a7;
    }

    /**
     * @notice See {IEditionCollection-getEditionDetails}
     */
    function getEditionDetails(uint256 editionId) external view returns (EditionDetails memory) {
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }
        return _getEditionDetails(editionId);
    }

    /**
     * @notice See {IEditionCollection-getEditionsDetailsAndUri}
     */
    function getEditionsDetailsAndUri(
        uint256[] calldata editionIds
    ) external view returns (EditionDetails[] memory, string[] memory) {
        uint256 editionIdsLength = editionIds.length;
        EditionDetails[] memory editionsDetails = new EditionDetails[](editionIdsLength);
        string[] memory uris = new string[](editionIdsLength);

        for (uint256 i = 0; i < editionIdsLength; i++) {
            uris[i] = editionURI(editionIds[i]);
            editionsDetails[i] = _getEditionDetails(editionIds[i]);
        }

        return (editionsDetails, uris);
    }

    /**
     * @notice Total supply of NFTs on the Editions
     */
    function totalSupply() external view returns (uint256) {
        return nextTokenId - 1;
    }

    /**
     * @notice See {IERC1155-burn}. Overrides default behaviour to check associated tokenManager.
     */
    function burn(address from, uint256 tokenId, uint256 amount) public nonReentrant {
        address _manager = tokenManager(tokenId);
        address msgSender = _msgSender();
        uint128 _currentSupply = editionSupply[tokenId].currentSupply;
        if (amount > _currentSupply) {
            _revert(InvalidBurn.selector);
        }

        if (_manager != address(0) && IERC165Upgradeable(_manager).supportsInterface(type(IPostBurn).interfaceId)) {
            IPostBurn(_manager).postBurn(msgSender, from, tokenId);
        } else {
            // default to restricting burn to owner or operator if a valid TM isn't present
            if (!(isApprovedForAll(from, msgSender) || msgSender == from)) {
                _revert(Unauthorized.selector);
            }
        }

        _burn(from, tokenId, amount);
        editionSupply[tokenId].currentSupply = _currentSupply - uint128(amount);

        observability.emitTransferSingle(msgSender, from, address(0), tokenId, amount);
    }

    /**
     * @notice Conforms to ERC-2981.
     * @param _tokenId Token id
     * @param _salePrice Sale price of token
     */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) public view virtual override returns (address receiver, uint256 royaltyAmount) {
        return ERC1155Base.royaltyInfo(_tokenId, _salePrice);
    }

    /**
     * @notice See {IEditionCollection-getEditionId}
     */
    function getEditionId(uint256 tokenId) public view returns (uint256) {
        if (!_editionExists(tokenId)) {
            _revert(TokenDoesNotExist.selector);
        }
        return tokenId;
    }

    /**
     * @notice Used to get token manager of token id
     * @param tokenId ID of the token
     */
    function tokenManagerByTokenId(uint256 tokenId) public view returns (address) {
        return tokenManager(tokenId);
    }

    /**
     * @notice Get URI for given edition id
     * @param editionId edition id to get uri for
     */
    function editionURI(uint256 editionId) public view returns (string memory) {
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }
        return _editionURI[editionId];
    }

    /**
     * @notice Get URI for given token id
     * @param tokenId token id to get uri for
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        if (!_editionExists(tokenId)) {
            _revert(TokenDoesNotExist.selector);
        }
        return _editionURI[tokenId];
    }

    /**
     * @notice Get URI for given token id
     * @param tokenId token id to get uri for
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        return tokenURI(tokenId);
    }

    /**
     * @notice See {IERC1155Upgradeable-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165Upgradeable, ERC1155Upgradeable) returns (bool) {
        return ERC1155Upgradeable.supportsInterface(interfaceId);
    }

    /**
     * @notice Private function to mint without any access checks. Called by the public edition minting functions.
     * @param editionId Edition being minted on
     * @param recipients Recipients of newly minted tokens
     * @param _amount Amount minted to each recipient
     */
    function _mintEditions(uint256 editionId, address[] memory recipients, uint256 _amount) internal returns (uint256) {
        uint256 recipientsLength = recipients.length;
        EditionSupply memory _editionSupply = editionSupply[editionId];
        uint256 newSupply = _editionSupply.currentSupply + (recipientsLength * _amount);

        if (_editionSupply.maxSupply > 0 && newSupply > _editionSupply.maxSupply) {
            _revert(SoldOut.selector);
        }

        for (uint256 i = 0; i < recipientsLength; i++) {
            _mint(recipients[i], editionId, _amount, "");
        }

        editionSupply[editionId].currentSupply = uint128(newSupply);

        return newSupply;
    }

    /**
     * @notice Private function to mint without any access checks. Called by the public edition minting functions.
     * @param editionId Edition being minted on
     * @param recipient Recipient of newly minted token
     * @param _amount Amount minted to recipient
     */
    function _mintEditionsToOne(uint256 editionId, address recipient, uint256 _amount) internal returns (uint256) {
        EditionSupply memory _editionSupply = editionSupply[editionId];
        uint256 newSupply = _editionSupply.currentSupply + _amount;

        if (_editionSupply.maxSupply > 0 && newSupply > _editionSupply.maxSupply) {
            _revert(SoldOut.selector);
        }

        _mint(recipient, editionId, _amount, "");

        editionSupply[editionId].currentSupply = uint128(newSupply);

        return newSupply;
    }

    /**
     * @notice Hook called after transfers
     * @param from Account token is being transferred from
     * @param to Account token is being transferred to
     * @param ids IDs of tokens being transferred
     * @param amounts Amounts of tokens being transferred
     * @ param data Data associated with transfer
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory /* data */
    ) internal override {
        address msgSender = operator;
        uint256 idsLength = ids.length;

        for (uint256 i = 0; i < idsLength; i++) {
            address _manager = tokenManagerByTokenId(ids[i]);
            if (
                _manager != address(0) &&
                IERC165Upgradeable(_manager).supportsInterface(type(IPostTransfer).interfaceId)
            ) {
                IPostTransfer(_manager).postTransferFrom(msgSender, from, to, ids[i]);
            }
        }

        if (idsLength == 1) {
            observability.emitTransferSingle(msgSender, from, to, ids[0], amounts[0]);
        } else {
            observability.emitTransferBatch(msgSender, from, to, ids, amounts);
        }
    }

    /**
     * @notice Returns whether `editionId` exists.
     * @param editionId Id of edition being checked
     */
    function _editionExists(uint256 editionId) internal view returns (bool) {
        return editionId < nextTokenId;
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgSender() internal view override(ERC1155Base, ContextUpgradeable) returns (address sender) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgData() internal view override(ERC1155Base, ContextUpgradeable) returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure override(ERC1155Base, ERC1155Upgradeable) {
        ERC1155Base._revert(errorSelector);
    }

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param defaultRoyalty Default royalty object for contract (optional)
     * @param _defaultTokenManager Default token manager for contract (optional)
     * @param _contractURI Contract metadata
     * @param _name Name of token edition
     * @param _symbol Symbol of the token edition
     * @param trustedForwarder Trusted minimal forwarder
     * @param initialMinters Initial minters to register
     * @param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @param _observability Observability contract address
     */
    function _initialize(
        address creator,
        IRoyaltyManager.Royalty memory defaultRoyalty,
        address _defaultTokenManager,
        string memory _contractURI,
        string memory _name,
        string memory _symbol,
        address trustedForwarder,
        address[] memory initialMinters,
        bool useMarketplaceFiltererRegistry,
        address _observability
    ) private {
        __ERC1155Base_initialize(creator, defaultRoyalty, _defaultTokenManager);
        _setContractMetadata(_name, _symbol);
        __ERC2771ContextUpgradeable__init__(trustedForwarder);
        // deprecate but keep input for backwards-compatibility:
        // __MarketplaceFilterer__init__(useMarketplaceFiltererRegistry);
        uint256 initialMintersLength = initialMinters.length;
        for (uint256 i = 0; i < initialMintersLength; i++) {
            _minters.add(initialMinters[i]);
        }
        nextTokenId = 1;
        contractURI = _contractURI;
        IObservabilityV2(_observability).emitEditions1155Deployed(address(this));
        observability = IObservabilityV2(_observability);
    }

    /**
     * @notice Create edition
     * @param _editionUri Edition uri (metadata)
     * @param _editionSize Size of the Edition
     * @param _editionTokenManager Edition's token manager
     * @notice Used to create a new Edition within the Collection
     */
    function _createEdition(
        string memory _editionUri,
        uint256 _editionSize,
        address _editionTokenManager
    ) private returns (uint256) {
        uint256 editionId = nextTokenId;
        nextTokenId = editionId + 1;
        editionSupply[editionId] = EditionSupply(0, uint128(_editionSize));
        _editionURI[editionId] = _editionUri;

        if (_editionTokenManager != address(0)) {
            if (!_isValidTokenManager(_editionTokenManager)) {
                _revert(InvalidManager.selector);
            }
            _managers[editionId] = _editionTokenManager;
        }

        emit EditionCreated(editionId, _editionSize, _editionTokenManager);

        return editionId;
    }

    /**
     * @dev Set name / symbol
     */
    function _setContractMetadata(string memory newName, string memory newSymbol) private {
        name = newName;
        symbol = newSymbol;
    }

    /**
     * @notice Get edition details
     * @param editionId Id of edition to get details for
     */
    function _getEditionDetails(uint256 editionId) private view returns (EditionDetails memory) {
        return
            EditionDetails("", editionSupply[editionId].maxSupply, editionSupply[editionId].currentSupply, editionId);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../../royaltyManager/interfaces/IRoyaltyManager.sol";

/**
 * @notice Core creation interface (1155s)
 * @author highlight.xyz
 */
interface IERC1155EditionsDFS {
    /**
     * @notice Create an edition
     * @param _editionUri Edition uri (metadata)
     * @param _editionSize Edition size
     * @param _editionTokenManager Token manager for edition
     * @param editionRoyalty Edition's royalty
     */
    function createEdition(
        string memory _editionUri,
        uint256 _editionSize,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty,
        bytes calldata mintVectorData
    ) external returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface IERC1155Standard {
    /**
     * @notice Return Highlight contract standard hash
     */
    function highlightContractStandardHash() external view returns (bytes32);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../royaltyManager/interfaces/IRoyaltyManager.sol";
import "../tokenManager/interfaces/ITokenManager.sol";
import "../utils/Ownable.sol";
import "../utils/ERC2981/IERC2981Upgradeable.sol";
import "../utils/ERC165/ERC165CheckerUpgradeable.sol";
import "../metatx/ERC2771ContextUpgradeable.sol";
import "../observability/IObservability.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/**
 * @title Base ERC721
 * @author highlight.xyz
 * @notice Core piece of Highlight NFT contracts (v2)
 */
abstract contract ERC721Base is
    OwnableUpgradeable,
    IERC2981Upgradeable,
    ERC2771ContextUpgradeable,
    ReentrancyGuardUpgradeable
{
    using EnumerableSet for EnumerableSet.AddressSet;
    using ERC165CheckerUpgradeable for address;

    /**
     * @notice Throw when token or royalty manager is invalid
     */
    error InvalidManager();

    /**
     * @notice Throw when token or royalty manager does not exist
     */
    error ManagerDoesNotExist();

    /**
     * @notice Throw when sender is unauthorized to perform action
     */
    error Unauthorized();

    /**
     * @notice Throw when sender is not a minter
     */
    error NotMinter();

    /**
     * @notice Throw when token manager or royalty manager swap is blocked
     */
    error ManagerSwapBlocked();

    /**
     * @notice Throw when token manager or royalty manager remove is blocked
     */
    error ManagerRemoveBlocked();

    /**
     * @notice Throw when setting default or granular royalty is blocked
     */
    error RoyaltySetBlocked();

    /**
     * @notice Throw when royalty BPS is invalid
     */
    error RoyaltyBPSInvalid();

    /**
     * @notice Throw when minter registration is invalid
     */
    error MinterRegistrationInvalid();

    /**
     * @notice Set of minters allowed to mint on contract
     */
    EnumerableSet.AddressSet internal _minters;

    /**
     * @notice Global token/edition manager default
     */
    address public defaultManager;

    /**
     * @notice Token/edition managers per token grouping.
     *      Edition ID if implemented by Editions contract, and token ID if implemented by General contract.
     */
    mapping(uint256 => address) internal _managers;

    /**
     * @notice Default royalty for entire contract
     */
    IRoyaltyManager.Royalty internal _defaultRoyalty;

    /**
     * @notice Royalty per token grouping.
     *      Edition ID if implemented by Editions contract, and token ID if implemented by General contract.
     */
    mapping(uint256 => IRoyaltyManager.Royalty) internal _royalties;

    /**
     * @notice Royalty manager - optional contract that defines the conditions around setting royalties
     */
    address public royaltyManager;

    /**
     * @notice Freezes minting on smart contract forever
     */
    uint8 internal _mintFrozen;

    /**
     * @notice Observability contract
     */
    IObservability public observability;

    /**
     * @notice Emitted when minter is registered or unregistered
     * @param minter Minter that was changed
     * @param registered True if the minter was registered, false if unregistered
     */
    event MinterRegistrationChanged(address indexed minter, bool indexed registered);

    /**
     * @notice Emitted when token managers are set for token/edition ids
     * @param _ids Edition / token ids
     * @param _tokenManagers Token managers to set for tokens / editions
     */
    event GranularTokenManagersSet(uint256[] _ids, address[] _tokenManagers);

    /**
     * @notice Emitted when token managers are removed for token/edition ids
     * @param _ids Edition / token ids to remove token managers for
     */
    event GranularTokenManagersRemoved(uint256[] _ids);

    /**
     * @notice Emitted when default token manager changed
     * @param newDefaultTokenManager New default token manager. Zero address if old one was removed
     */
    event DefaultTokenManagerChanged(address indexed newDefaultTokenManager);

    /**
     * @notice Emitted when default royalty is set
     * @param recipientAddress Royalty recipient
     * @param royaltyPercentageBPS Percentage of sale (in basis points) owed to royalty recipient
     */
    event DefaultRoyaltySet(address indexed recipientAddress, uint16 indexed royaltyPercentageBPS);

    /**
     * @notice Emitted when royalties are set for edition / token ids
     * @param ids Token / edition ids
     * @param _newRoyalties New royalties for each token / edition
     */
    event GranularRoyaltiesSet(uint256[] ids, IRoyaltyManager.Royalty[] _newRoyalties);

    /**
     * @notice Emitted when royalty manager is updated
     * @param newRoyaltyManager New royalty manager. Zero address if old one was removed
     */
    event RoyaltyManagerChanged(address indexed newRoyaltyManager);

    /**
     * @notice Emitted when mints are frozen permanently
     */
    event MintsFrozen();

    /**
     * @notice Restricts calls to minters
     */
    modifier onlyMinter() {
        if (!_minters.contains(_msgSender())) {
            _revert(NotMinter.selector);
        }
        _;
    }

    /**
     * @notice Restricts calls if input royalty bps is over 10000
     */
    modifier royaltyValid(uint16 _royaltyBPS) {
        if (!_royaltyBPSValid(_royaltyBPS)) {
            _revert(RoyaltyBPSInvalid.selector);
        }
        _;
    }

    /**
     * @notice Registers a minter
     * @param minter New minter
     */
    function registerMinter(address minter) external onlyOwner {
        if (!_minters.add(minter)) {
            _revert(MinterRegistrationInvalid.selector);
        }

        emit MinterRegistrationChanged(minter, true);
        observability.emitMinterRegistrationChanged(minter, true);
    }

    /**
     * @notice Unregisters a minter
     * @param minter Minter to unregister
     */
    function unregisterMinter(address minter) external onlyOwner {
        if (!_minters.remove(minter)) {
            _revert(MinterRegistrationInvalid.selector);
        }

        emit MinterRegistrationChanged(minter, false);
        observability.emitMinterRegistrationChanged(minter, false);
    }

    /**
     * @notice Sets granular token managers if current token manager(s) allow it
     * @param _ids Edition / token ids
     * @param _tokenManagers Token managers to set for tokens / editions
     */
    function setGranularTokenManagers(
        uint256[] calldata _ids,
        address[] calldata _tokenManagers
    ) external nonReentrant {
        address msgSender = _msgSender();
        address tempOwner = owner();

        uint256 idsLength = _ids.length;
        for (uint256 i = 0; i < idsLength; i++) {
            if (!_isValidTokenManager(_tokenManagers[i])) {
                _revert(InvalidManager.selector);
            }
            address currentTokenManager = tokenManager(_ids[i]);
            if (currentTokenManager == address(0)) {
                if (msgSender != tempOwner) {
                    _revert(Unauthorized.selector);
                }
            } else {
                if (!ITokenManager(currentTokenManager).canSwap(msgSender, _ids[i], _managers[i])) {
                    _revert(ManagerSwapBlocked.selector);
                }
            }

            _managers[_ids[i]] = _tokenManagers[i];
        }

        emit GranularTokenManagersSet(_ids, _tokenManagers);
        observability.emitGranularTokenManagersSet(_ids, _tokenManagers);
    }

    /**
     * @notice Remove granular token managers
     * @param _ids Edition / token ids to remove token managers for
     */
    function removeGranularTokenManagers(uint256[] calldata _ids) external nonReentrant {
        address msgSender = _msgSender();

        uint256 idsLength = _ids.length;
        for (uint256 i = 0; i < idsLength; i++) {
            address currentTokenManager = _managers[_ids[i]];
            if (currentTokenManager == address(0)) {
                _revert(ManagerDoesNotExist.selector);
            }
            if (!ITokenManager(currentTokenManager).canRemoveItself(msgSender, _ids[i])) {
                _revert(ManagerRemoveBlocked.selector);
            }

            _managers[_ids[i]] = address(0);
        }

        emit GranularTokenManagersRemoved(_ids);
        observability.emitGranularTokenManagersRemoved(_ids);
    }

    /**
     * @notice Set default token manager if current token manager allows it
     * @param _defaultTokenManager New default token manager
     */
    function setDefaultTokenManager(address _defaultTokenManager) external nonReentrant {
        if (!_isValidTokenManager(_defaultTokenManager)) {
            _revert(InvalidManager.selector);
        }
        address msgSender = _msgSender();

        address currentTokenManager = defaultManager;
        if (currentTokenManager == address(0)) {
            if (msgSender != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!ITokenManager(currentTokenManager).canSwap(msgSender, 0, _defaultTokenManager)) {
                _revert(ManagerSwapBlocked.selector);
            }
        }

        defaultManager = _defaultTokenManager;

        emit DefaultTokenManagerChanged(_defaultTokenManager);
        observability.emitDefaultTokenManagerChanged(_defaultTokenManager);
    }

    /**
     * @notice Removes default token manager if current token manager allows it
     */
    function removeDefaultTokenManager() external nonReentrant {
        address msgSender = _msgSender();

        address currentTokenManager = defaultManager;
        if (currentTokenManager == address(0)) {
            _revert(ManagerDoesNotExist.selector);
        }
        if (!ITokenManager(currentTokenManager).canRemoveItself(msgSender, 0)) {
            _revert(ManagerRemoveBlocked.selector);
        }

        defaultManager = address(0);

        emit DefaultTokenManagerChanged(address(0));
        observability.emitDefaultTokenManagerChanged(address(0));
    }

    /**
     * @notice Sets default royalty if royalty manager allows it
     * @param _royalty New default royalty
     */
    function setDefaultRoyalty(
        IRoyaltyManager.Royalty calldata _royalty
    ) external nonReentrant royaltyValid(_royalty.royaltyPercentageBPS) {
        address msgSender = _msgSender();

        address _royaltyManager = royaltyManager;
        if (_royaltyManager == address(0)) {
            if (msgSender != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!IRoyaltyManager(_royaltyManager).canSetDefaultRoyalty(_royalty, msgSender)) {
                _revert(RoyaltySetBlocked.selector);
            }
        }

        _defaultRoyalty = _royalty;

        emit DefaultRoyaltySet(_royalty.recipientAddress, _royalty.royaltyPercentageBPS);
        observability.emitDefaultRoyaltySet(_royalty.recipientAddress, _royalty.royaltyPercentageBPS);
    }

    /**
     * @notice Sets granular royalties (per token-grouping) if royalty manager allows it
     * @param ids Token / edition ids
     * @param _newRoyalties New royalties for each token / edition
     */
    function setGranularRoyalties(
        uint256[] calldata ids,
        IRoyaltyManager.Royalty[] calldata _newRoyalties
    ) external nonReentrant {
        address msgSender = _msgSender();
        address tempOwner = owner();

        address _royaltyManager = royaltyManager;
        uint256 idsLength = ids.length;
        if (_royaltyManager == address(0)) {
            if (msgSender != tempOwner) {
                _revert(Unauthorized.selector);
            }

            for (uint256 i = 0; i < idsLength; i++) {
                if (!_royaltyBPSValid(_newRoyalties[i].royaltyPercentageBPS)) {
                    _revert(RoyaltyBPSInvalid.selector);
                }
                _royalties[ids[i]] = _newRoyalties[i];
            }
        } else {
            for (uint256 i = 0; i < idsLength; i++) {
                if (!_royaltyBPSValid(_newRoyalties[i].royaltyPercentageBPS)) {
                    _revert(RoyaltyBPSInvalid.selector);
                }
                if (!IRoyaltyManager(_royaltyManager).canSetGranularRoyalty(ids[i], _newRoyalties[i], msgSender)) {
                    _revert(RoyaltySetBlocked.selector);
                }
                _royalties[ids[i]] = _newRoyalties[i];
            }
        }

        emit GranularRoyaltiesSet(ids, _newRoyalties);
        observability.emitGranularRoyaltiesSet(ids, _newRoyalties);
    }

    /**
     * @notice Sets royalty manager if current one allows it
     * @param _royaltyManager New royalty manager
     */
    function setRoyaltyManager(address _royaltyManager) external nonReentrant {
        if (!_isValidRoyaltyManager(_royaltyManager)) {
            _revert(InvalidManager.selector);
        }
        address msgSender = _msgSender();

        address currentRoyaltyManager = royaltyManager;
        if (currentRoyaltyManager == address(0)) {
            if (msgSender != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!IRoyaltyManager(currentRoyaltyManager).canSwap(_royaltyManager, msgSender)) {
                _revert(ManagerSwapBlocked.selector);
            }
        }

        royaltyManager = _royaltyManager;

        emit RoyaltyManagerChanged(_royaltyManager);
        observability.emitRoyaltyManagerChanged(_royaltyManager);
    }

    /**
     * @notice Removes royalty manager if current one allows it
     */
    function removeRoyaltyManager() external nonReentrant {
        address msgSender = _msgSender();

        address currentRoyaltyManager = royaltyManager;
        if (currentRoyaltyManager == address(0)) {
            _revert(ManagerDoesNotExist.selector);
        }
        if (!IRoyaltyManager(currentRoyaltyManager).canRemoveItself(msgSender)) {
            _revert(ManagerRemoveBlocked.selector);
        }

        royaltyManager = address(0);

        emit RoyaltyManagerChanged(address(0));
        observability.emitRoyaltyManagerChanged(address(0));
    }

    /**
     * @notice Freeze mints on contract forever
     */
    function freezeMints() external onlyOwner nonReentrant {
        _mintFrozen = 1;

        emit MintsFrozen();
        observability.emitMintsFrozen();
    }

    /**
     * @notice Return allowed minters on contract
     */
    function minters() external view returns (address[] memory) {
        return _minters.values();
    }

    /**
     * @notice Conforms to ERC-2981. Editions should overwrite to return royalty for entire edition
     * @param _tokenGroupingId Token id if on general, and edition id if on editions
     * @param _salePrice Sale price of token
     */
    function royaltyInfo(
        uint256 _tokenGroupingId,
        uint256 _salePrice
    ) public view virtual override returns (address receiver, uint256 royaltyAmount) {
        IRoyaltyManager.Royalty memory royalty = _royalties[_tokenGroupingId];
        if (royalty.recipientAddress == address(0)) {
            royalty = _defaultRoyalty;
        }

        receiver = royalty.recipientAddress;
        royaltyAmount = (_salePrice * uint256(royalty.royaltyPercentageBPS)) / 10000;
    }

    /**
     * @notice Returns the token manager for the id passed in.
     * @param id Token ID or Edition ID for Editions implementing contracts
     */
    function tokenManager(uint256 id) public view returns (address manager) {
        manager = defaultManager;
        address granularManager = _managers[id];

        if (granularManager != address(0)) {
            manager = granularManager;
        }
    }

    /**
     * @notice Initializes the contract, setting the creator as the initial owner.
     * @param _creator Contract creator
     * @param defaultRoyalty Default royalty for the contract
     * @param _defaultTokenManager Default token manager for the contract
     */
    function __ERC721Base_initialize(
        address _creator,
        IRoyaltyManager.Royalty memory defaultRoyalty,
        address _defaultTokenManager
    ) internal onlyInitializing royaltyValid(defaultRoyalty.royaltyPercentageBPS) {
        __Ownable_init();
        __ReentrancyGuard_init();
        _transferOwnership(_creator);

        if (defaultRoyalty.recipientAddress != address(0)) {
            _defaultRoyalty = defaultRoyalty;
        }

        if (_defaultTokenManager != address(0)) {
            defaultManager = _defaultTokenManager;
        }
    }

    /**
     * @notice Returns true if address is a valid tokenManager
     * @param _tokenManager Token manager being checked
     */
    function _isValidTokenManager(address _tokenManager) internal view returns (bool) {
        return _tokenManager.supportsInterface(type(ITokenManager).interfaceId);
    }

    /**
     * @notice Returns true if address is a valid royaltyManager
     * @param _royaltyManager Royalty manager being checked
     */
    function _isValidRoyaltyManager(address _royaltyManager) internal view returns (bool) {
        return _royaltyManager.supportsInterface(type(IRoyaltyManager).interfaceId);
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgSender()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure virtual {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgData()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }

    /**
     * @notice Returns true if royalty bps passed in is valid (<= 10000)
     * @param _royaltyBPS Royalty basis points
     */
    function _royaltyBPSValid(uint16 _royaltyBPS) private pure returns (bool) {
        return _royaltyBPS <= 10000;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "./interfaces/IERC721EditionsDFS.sol";
import "./ERC721Base.sol";
import "../utils/Ownable.sol";
import "../metadata/interfaces/IMetadataRenderer.sol";
import "../metadata/interfaces/IEditionsMetadataRenderer.sol";
import "../auction/interfaces/IAuctionManager.sol";
import "./interfaces/IEditionCollection.sol";

import "../tokenManager/interfaces/IPostTransfer.sol";
import "../tokenManager/interfaces/IPostBurn.sol";
import "../tokenManager/interfaces/ITokenManagerEditions.sol";
import "./interfaces/IERC721EditionMint.sol";
import "./MarketplaceFilterer/MarketplaceFiltererAbridged.sol";
import "../utils/ERC721/ERC721Upgradeable.sol";
import "../mint/interfaces/IAbridgedMintVector.sol";
import "../mint/mechanics/interfaces/IMechanicMintManager.sol";

/**
 * @title ERC721 Editions
 * @author highlight.xyz
 * @notice Multiple Editions Per Collection
 * @dev Using Decentralized File Storage
 */
contract ERC721EditionsDFS is
    IEditionCollection,
    IERC721EditionsDFS,
    IERC721EditionMint,
    ERC721Base,
    ERC721Upgradeable
{
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Throw when edition doesn't exist
     */
    error EditionDoesNotExist();

    /**
     * @notice Throw when token doesn't exist
     */
    error TokenDoesNotExist();

    /**
     * @notice Throw when attempting to mint, while mint is frozen
     */
    error MintFrozen();

    /**
     * @notice Throw when tokens on edition are sold out
     */
    error SoldOut();

    /**
     * @notice Throw when edition size is invalid
     */
    error InvalidSize();

    /**
     * @notice Throw when edition metadata update is blocked
     */
    error MetadataUpdateBlocked();

    /**
     * @notice Contract metadata
     */
    string public contractURI;

    /**
     * @notice Keeps track of next token ID
     */
    uint256 public nextTokenId;

    /**
     * @notice Tracks current supply of each edition, edition indexed
     */
    uint256[] public editionCurrentSupply;

    /**
     * @notice Tracks size of each edition, edition indexed
     */
    uint256[] public editionMaxSupply;

    /**
     * @notice Tracks start token id each edition, edition indexed
     */
    uint256[] public editionStartId;

    /**
     * @notice Track metadata per edition
     */
    mapping(uint256 => string) private _editionURI;

    /**
     * @notice Emitted when edition is created
     * @param editionId Edition ID
     * @param size Edition size
     * @param editionTokenManager Token manager for edition
     */
    event EditionCreated(uint256 indexed editionId, uint256 indexed size, address indexed editionTokenManager);

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param data Contract initialization data
     * @ param _contractURI Contract metadata
     * @ param _name Name of token edition
     * @ param _symbol Symbol of the token edition
     * @ param trustedForwarder Trusted minimal forwarder
     * @ param initialMinters Initial minters to register
     * @ param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @ param _observability Observability contract address
     */
    function initialize(address creator, bytes memory data) external initializer {
        (
            string memory _contractURI,
            string memory _name,
            string memory _symbol,
            address trustedForwarder,
            address[] memory initialMinters,
            bool useMarketplaceFiltererRegistry,
            address _observability
        ) = abi.decode(data, (string, string, string, address, address[], bool, address));

        IRoyaltyManager.Royalty memory _defaultRoyalty = IRoyaltyManager.Royalty(address(0), 0);
        _initialize(
            creator,
            _defaultRoyalty,
            address(0),
            _contractURI,
            _name,
            _symbol,
            trustedForwarder,
            initialMinters,
            useMarketplaceFiltererRegistry,
            _observability
        );
    }

    /**
     * @notice Create edition
     * @param _editionUri Edition uri (metadata)
     * @param _editionSize Size of the Edition
     * @param _editionTokenManager Edition's token manager
     * @param editionRoyalty Edition royalty object for contract (optional)
     * @param mintVectorData Direct mint vector data
     * @notice Used to create a new Edition within the Collection
     */
    function createEdition(
        string memory _editionUri,
        uint256 _editionSize,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty,
        bytes calldata mintVectorData
    ) external onlyOwner nonReentrant returns (uint256) {
        uint256 editionId = _createEdition(_editionUri, _editionSize, _editionTokenManager);
        if (editionRoyalty.recipientAddress != address(0)) {
            _royalties[editionId] = editionRoyalty;
        }

        if (mintVectorData.length > 0) {
            (
                address mintManager,
                address paymentRecipient,
                uint48 startTimestamp,
                uint48 endTimestamp,
                uint192 pricePerToken,
                uint48 tokenLimitPerTx,
                uint48 maxTotalClaimableViaVector,
                uint48 maxUserClaimableViaVector,
                address currency
            ) = abi.decode(
                    mintVectorData,
                    (address, address, uint48, uint48, uint192, uint48, uint48, uint48, address)
                );

            IAbridgedMintVector(mintManager).createAbridgedVector(
                IAbridgedMintVector.AbridgedVectorData(
                    uint160(address(this)),
                    startTimestamp,
                    endTimestamp,
                    uint160(paymentRecipient),
                    maxTotalClaimableViaVector,
                    0,
                    uint160(currency),
                    tokenLimitPerTx,
                    maxUserClaimableViaVector,
                    pricePerToken,
                    uint48(editionId), // cast down
                    true,
                    false,
                    0
                )
            );
        }

        return editionId;
    }

    /**
     * @notice Used to create a new Edition within the Collection
     * @param _editionUri Edition uri (metadata)
     * @param _editionSize Size of the Edition
     * @param _editionTokenManager Edition's token manager
     * @param editionRoyalty Edition royalty object for contract (optional)
     * @param mechanicVectorData Mechanic mint vector data
     * @ param mechanicVectorId Global mechanic vector ID
     * @ param mechanic Mechanic address
     * @ param mintManager Mint manager address
     * @ param vectorData Vector data
     */
    function createEditionWithMechanicVector(
        string memory _editionUri,
        uint256 _editionSize,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty,
        bytes calldata mechanicVectorData
    ) external onlyOwner nonReentrant returns (uint256) {
        uint256 editionId = _createEdition(_editionUri, _editionSize, _editionTokenManager);
        if (editionRoyalty.recipientAddress != address(0)) {
            _royalties[editionId] = editionRoyalty;
        }

        if (mechanicVectorData.length > 0) {
            (uint96 seed, address mechanic, address mintManager, bytes memory vectorData) = abi.decode(
                mechanicVectorData,
                (uint96, address, address, bytes)
            );

            IMechanicMintManager(mintManager).registerMechanicVector(
                IMechanicData.MechanicVectorMetadata(address(this), uint96(editionId), mechanic, true, false, false),
                seed,
                vectorData
            );
        }

        return editionId;
    }

    /**
     * @notice Used to create a new Edition within the Collection
     * @param _editionUri Edition uri (metadata)
     * @param _editionSize Size of the Edition
     * @param _editionTokenManager Edition's token manager
     * @param editionRoyalty Edition royalty object for contract (optional)
     * @param mintVectorData Direct mint vector data
     * @param mechanicVectorData Mechanic mint vector data
     * @ param mechanicVectorId Global mechanic vector ID
     * @ param mechanic Mechanic address
     * @ param mintManager Mint manager address
     * @ param vectorData Vector data
     */
    function createEditionWithMechanicVectorAndPublicFixedPriceVector(
        string memory _editionUri,
        uint256 _editionSize,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty,
        bytes calldata mintVectorData,
        bytes calldata mechanicVectorData
    ) external onlyOwner nonReentrant returns (uint256) {
        uint256 editionId = _createEdition(_editionUri, _editionSize, _editionTokenManager);
        if (editionRoyalty.recipientAddress != address(0)) {
            _royalties[editionId] = editionRoyalty;
        }

        if (mintVectorData.length > 0) {
            (
                address mintManager,
                address paymentRecipient,
                uint48 startTimestamp,
                uint48 endTimestamp,
                uint192 pricePerToken,
                uint48 tokenLimitPerTx,
                uint48 maxTotalClaimableViaVector,
                uint48 maxUserClaimableViaVector,
                address currency
            ) = abi.decode(
                    mintVectorData,
                    (address, address, uint48, uint48, uint192, uint48, uint48, uint48, address)
                );

            IAbridgedMintVector(mintManager).createAbridgedVector(
                IAbridgedMintVector.AbridgedVectorData(
                    uint160(address(this)),
                    startTimestamp,
                    endTimestamp,
                    uint160(paymentRecipient),
                    maxTotalClaimableViaVector,
                    0,
                    uint160(currency),
                    tokenLimitPerTx,
                    maxUserClaimableViaVector,
                    pricePerToken,
                    uint48(editionId), // cast down
                    true,
                    false,
                    0
                )
            );
        }

        if (mechanicVectorData.length > 0) {
            (uint96 seed, address mechanic, address mintManager, bytes memory vectorData) = abi.decode(
                mechanicVectorData,
                (uint96, address, address, bytes)
            );

            IMechanicMintManager(mintManager).registerMechanicVector(
                IMechanicData.MechanicVectorMetadata(address(this), uint96(editionId), mechanic, true, false, false),
                seed,
                vectorData
            );
        }

        return editionId;
    }

    /**
     * @notice Create edition with auction
     * @param _editionUri Edition uri (metadata)
     * @param auctionData Auction data
     * @param _editionTokenManager Edition's token manager
     * @param editionRoyalty Edition royalty object for contract (optional)
     * @notice Used to create a new 1/1 Edition Collection within the contract, and an auction for it
     */
    function createEditionWithAuction(
        string memory _editionUri,
        bytes memory auctionData,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty
    ) external onlyOwner nonReentrant returns (uint256) {
        uint256 editionId = _createEdition(_editionUri, 1, _editionTokenManager);
        if (editionRoyalty.recipientAddress != address(0)) {
            _royalties[editionId] = editionRoyalty;
        }

        (
            address auctionManagerAddress,
            bytes32 auctionId,
            address auctionCurrency,
            address payable auctionPaymentRecipient,
            uint256 auctionEndTime
        ) = abi.decode(auctionData, (address, bytes32, address, address, uint256));

        IAuctionManager.EnglishAuction memory auction = IAuctionManager.EnglishAuction(
            address(this),
            auctionCurrency,
            msg.sender,
            auctionPaymentRecipient,
            auctionEndTime,
            0,
            true,
            IAuctionManager.AuctionState.LIVE_ON_CHAIN
        );

        IAuctionManager(auctionManagerAddress).createAuctionForNewEdition(auctionId, auction, editionId);

        return editionId;
    }

    /**
     * @notice See {IERC721EditionMint-mintOneToRecipient}
     */
    function mintOneToRecipient(
        uint256 editionId,
        address recipient
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }

        return _mintEditionsToOne(editionId, recipient, 1);
    }

    /**
     * @notice See {IERC721EditionMint-mintAmountToRecipient}
     */
    function mintAmountToRecipient(
        uint256 editionId,
        address recipient,
        uint256 amount
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }

        return _mintEditionsToOne(editionId, recipient, amount);
    }

    /**
     * @notice See {IERC721EditionMint-mintOneToRecipients}
     */
    function mintOneToRecipients(
        uint256 editionId,
        address[] memory recipients
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }

        return _mintEditions(editionId, recipients, 1);
    }

    /**
     * @notice See {IERC721EditionMint-mintAmountToRecipients}
     */
    function mintAmountToRecipients(
        uint256 editionId,
        address[] memory recipients,
        uint256 amount
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }

        return _mintEditions(editionId, recipients, amount);
    }

    /**
     * @notice Set contract name
     * @param newName New name
     * @param newSymbol New symbol
     * @param newContractUri New contractURI
     */
    function setContractMetadata(
        string calldata newName,
        string calldata newSymbol,
        string calldata newContractUri
    ) external onlyOwner {
        _setContractMetadata(newName, newSymbol);
        contractURI = newContractUri;

        observability.emitContractMetadataSet(newName, newSymbol, newContractUri);
    }

    /**
     * @notice Set an Edition's uri
     * @param editionId Edition to set uri for
     * @param _uri Uri to set on editions
     */
    function setEditionURI(uint256 editionId, string calldata _uri) external {
        address _manager = tokenManager(editionId);
        address msgSender = _msgSender();

        if (_manager == address(0)) {
            address tempOwner = owner();
            if (msgSender != tempOwner) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (
                !ITokenManagerEditions(_manager).canUpdateEditionsMetadata(
                    address(this),
                    msgSender,
                    editionId,
                    bytes(_uri),
                    ITokenManagerEditions.FieldUpdated.other
                )
            ) {
                _revert(MetadataUpdateBlocked.selector);
            }
        }

        _editionURI[editionId] = _uri;

        uint256[] memory _ids = new uint256[](1);
        _ids[0] = editionId;
        string[] memory _uris = new string[](1);
        _uris[0] = _uri;
        observability.emitTokenURIsSet(_ids, _uris);
    }

    /**
     * @notice See {IEditionCollection-getEditionDetails}
     */
    function getEditionDetails(uint256 editionId) external view returns (EditionDetails memory) {
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }
        return _getEditionDetails(editionId);
    }

    /**
     * @notice See {IEditionCollection-getEditionsDetailsAndUri}
     */
    function getEditionsDetailsAndUri(
        uint256[] calldata editionIds
    ) external view returns (EditionDetails[] memory, string[] memory) {
        uint256 editionIdsLength = editionIds.length;
        EditionDetails[] memory editionsDetails = new EditionDetails[](editionIdsLength);
        string[] memory uris = new string[](editionIdsLength);

        for (uint256 i = 0; i < editionIdsLength; i++) {
            uris[i] = editionURI(editionIds[i]);
            editionsDetails[i] = _getEditionDetails(editionIds[i]);
        }

        return (editionsDetails, uris);
    }

    /**
     * @notice See {IEditionCollection-getEditionStartIds}
     */
    function getEditionStartIds() external view returns (uint256[] memory) {
        return editionStartId;
    }

    /**
     * @notice Total supply of NFTs on the Editions
     * @dev Won't handle burned (temporary)
     */
    function totalSupply() external view returns (uint256) {
        uint256 supply = 0;
        for (uint256 i = 0; i < editionCurrentSupply.length; i++) {
            supply += editionCurrentSupply[i];
        }
        return supply;
    }

    /**
     * @notice See {IERC721-burn}. Overrides default behaviour to check associated tokenManager.
     */
    function burn(uint256 tokenId) public nonReentrant {
        uint256 editionId = getEditionId(tokenId);
        address _manager = tokenManager(editionId);
        address msgSender = _msgSender();

        if (_manager != address(0) && IERC165Upgradeable(_manager).supportsInterface(type(IPostBurn).interfaceId)) {
            IPostBurn(_manager).postBurn(msgSender, ownerOf(tokenId), editionId);
        } else {
            // default to restricting burn to owner or operator if a valid TM isn't present
            if (!_isApprovedOrOwner(msgSender, tokenId)) {
                _revert(Unauthorized.selector);
            }
        }

        _burn(tokenId);

        observability.emitTransfer(msgSender, address(0), tokenId);
    }

    /**
     * @notice Conforms to ERC-2981.
     * @param _tokenId Token id
     * @param _salePrice Sale price of token
     */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) public view virtual override returns (address receiver, uint256 royaltyAmount) {
        return ERC721Base.royaltyInfo(_getEditionId(_tokenId), _salePrice);
    }

    /**
     * @notice See {IEditionCollection-getEditionId}
     */
    function getEditionId(uint256 tokenId) public view returns (uint256) {
        if (!_exists(tokenId)) {
            _revert(TokenDoesNotExist.selector);
        }
        return _getEditionId(tokenId);
    }

    /**
     * @notice Used to get token manager of token id
     * @param tokenId ID of the token
     */
    function tokenManagerByTokenId(uint256 tokenId) public view returns (address) {
        return tokenManager(getEditionId(tokenId));
    }

    /**
     * @notice Get URI for given edition id
     * @param editionId edition id to get uri for
     */
    function editionURI(uint256 editionId) public view returns (string memory) {
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }
        return _editionURI[editionId];
    }

    /**
     * @notice Get URI for given token id
     * @param tokenId token id to get uri for
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) {
            _revert(TokenDoesNotExist.selector);
        }
        uint256 editionId = getEditionId(tokenId);
        return _editionURI[editionId];
    }

    /**
     * @notice See {IERC721Upgradeable-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return ERC721Upgradeable.supportsInterface(interfaceId);
    }

    /**
     * @notice Private function to mint without any access checks. Called by the public edition minting functions.
     * @param editionId Edition being minted on
     * @param recipients Recipients of newly minted tokens
     * @param _amount Amount minted to each recipient
     */
    function _mintEditions(uint256 editionId, address[] memory recipients, uint256 _amount) internal returns (uint256) {
        uint256 recipientsLength = recipients.length;

        uint256 maxSupply = editionMaxSupply[editionId];
        uint256 currentSupply = editionCurrentSupply[editionId];
        uint256 startId = editionStartId[editionId];
        uint256 endAt = currentSupply + (recipientsLength * _amount);

        if (endAt > maxSupply) {
            _revert(SoldOut.selector);
        }

        for (uint256 i = 0; i < recipientsLength; i++) {
            for (uint256 j = 0; j < _amount; j++) {
                _mint(recipients[i], startId + currentSupply);
                currentSupply += 1;
            }
        }

        editionCurrentSupply[editionId] = currentSupply;

        return endAt;
    }

    /**
     * @notice Private function to mint without any access checks. Called by the public edition minting functions.
     * @param editionId Edition being minted on
     * @param recipient Recipient of newly minted token
     * @param _amount Amount minted to recipient
     */
    function _mintEditionsToOne(uint256 editionId, address recipient, uint256 _amount) internal returns (uint256) {
        uint256 maxSupply = editionMaxSupply[editionId];
        uint256 currentSupply = editionCurrentSupply[editionId];
        uint256 startId = editionStartId[editionId];
        uint256 endAt = currentSupply + _amount;

        if (endAt > maxSupply) {
            _revert(SoldOut.selector);
        }

        for (uint256 j = 0; j < _amount; j++) {
            _mint(recipient, startId + currentSupply);
            currentSupply += 1;
        }

        editionCurrentSupply[editionId] = endAt;

        return endAt;
    }

    /**
     * @notice Hook called after transfers
     * @param from Account token is being transferred from
     * @param to Account token is being transferred to
     * @param tokenId ID of token being transferred
     */
    function _afterTokenTransfers(address from, address to, uint256 tokenId) internal override {
        address msgSender = _msgSender();

        address _manager = tokenManagerByTokenId(tokenId);
        if (_manager != address(0) && IERC165Upgradeable(_manager).supportsInterface(type(IPostTransfer).interfaceId)) {
            IPostTransfer(_manager).postTransferFrom(msgSender, from, to, tokenId);
        }

        observability.emitTransfer(from, to, tokenId);
    }

    /**
     * @notice Get ID of a token's edition
     */
    function _getEditionId(uint256 tokenId) internal view returns (uint256) {
        uint256 editionId = 0;
        uint256[] memory tempEditionStartId = editionStartId; // cache
        uint256 tempEditionStartIdLength = tempEditionStartId.length; // cache
        for (uint256 i = 0; i < tempEditionStartIdLength; i += 1) {
            if (tokenId >= tempEditionStartId[i]) {
                editionId = i;
            }
        }
        return editionId;
    }

    /**
     * @notice Returns whether `editionId` exists.
     * @param editionId Id of edition being checked
     */
    function _editionExists(uint256 editionId) internal view returns (bool) {
        return editionId < editionCurrentSupply.length;
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgSender() internal view override(ERC721Base, ContextUpgradeable) returns (address sender) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgData() internal view override(ERC721Base, ContextUpgradeable) returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure override(ERC721Upgradeable, ERC721Base) {
        ERC721Upgradeable._revert(errorSelector);
    }

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param defaultRoyalty Default royalty object for contract (optional)
     * @param _defaultTokenManager Default token manager for contract (optional)
     * @param _contractURI Contract metadata
     * @param _name Name of token edition
     * @param _symbol Symbol of the token edition
     * @param trustedForwarder Trusted minimal forwarder
     * @param initialMinters Initial minters to register
     * @param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @param _observability Observability contract address
     */
    function _initialize(
        address creator,
        IRoyaltyManager.Royalty memory defaultRoyalty,
        address _defaultTokenManager,
        string memory _contractURI,
        string memory _name,
        string memory _symbol,
        address trustedForwarder,
        address[] memory initialMinters,
        bool useMarketplaceFiltererRegistry,
        address _observability
    ) private {
        __ERC721Base_initialize(creator, defaultRoyalty, _defaultTokenManager);
        __ERC721_init(_name, _symbol);
        __ERC2771ContextUpgradeable__init__(trustedForwarder);
        // deprecate but keep input for backwards-compatibility:
        // __MarketplaceFilterer__init__(useMarketplaceFiltererRegistry);
        uint256 initialMintersLength = initialMinters.length;
        for (uint256 i = 0; i < initialMintersLength; i++) {
            _minters.add(initialMinters[i]);
        }
        nextTokenId = 1;
        contractURI = _contractURI;
        IObservability(_observability).emitMultipleEditionsDeployed(address(this));
        observability = IObservability(_observability);
    }

    /**
     * @notice Create edition
     * @param _editionUri Edition uri (metadata)
     * @param _editionSize Size of the Edition
     * @param _editionTokenManager Edition's token manager
     * @notice Used to create a new Edition within the Collection
     */
    function _createEdition(
        string memory _editionUri,
        uint256 _editionSize,
        address _editionTokenManager
    ) private returns (uint256) {
        if (_editionSize == 0) {
            _revert(InvalidSize.selector);
        }

        uint256 editionId = editionStartId.length;

        editionStartId.push(nextTokenId);
        editionMaxSupply.push(_editionSize);
        editionCurrentSupply.push(0);

        nextTokenId += _editionSize;

        _editionURI[editionId] = _editionUri;

        if (_editionTokenManager != address(0)) {
            if (!_isValidTokenManager(_editionTokenManager)) {
                _revert(InvalidManager.selector);
            }
            _managers[editionId] = _editionTokenManager;
        }

        emit EditionCreated(editionId, _editionSize, _editionTokenManager);

        return editionId;
    }

    /**
     * @notice Get edition details
     * @param editionId Id of edition to get details for
     */
    function _getEditionDetails(uint256 editionId) private view returns (EditionDetails memory) {
        return
            EditionDetails("", editionMaxSupply[editionId], editionCurrentSupply[editionId], editionStartId[editionId]);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "./ERC721Base.sol";
import "../metadata/MetadataEncryption.sol";
import "../tokenManager/interfaces/IPostTransfer.sol";
import "../tokenManager/interfaces/IPostBurn.sol";
import "./interfaces/IERC721GeneralMint.sol";
import "./ERC721GeneralBase.sol";

/**
 * @title Generalized ERC721
 * @author highlight.xyz
 * @notice Generalized NFT smart contract
 */
contract ERC721General is ERC721GeneralBase {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param _contractURI Contract metadata
     * @param defaultRoyalty Default royalty object for contract (optional)
     * @param _defaultTokenManager Default token manager for contract (optional)
     * @param _name Name of token edition
     * @param _symbol Symbol of the token edition
     * @param trustedForwarder Trusted minimal forwarder
     * @param initialMinter Initial minter to register
     * @param newBaseURI Base URI for contract
     * @param _limitSupply Initial limit supply
     * @param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @param _observability Observability contract address
     */
    function initialize(
        address creator,
        string memory _contractURI,
        IRoyaltyManager.Royalty memory defaultRoyalty,
        address _defaultTokenManager,
        string memory _name,
        string memory _symbol,
        address trustedForwarder,
        address initialMinter,
        string memory newBaseURI,
        uint256 _limitSupply,
        bool useMarketplaceFiltererRegistry,
        address _observability
    ) external initializer {
        _initialize(
            creator,
            _contractURI,
            defaultRoyalty,
            _defaultTokenManager,
            _name,
            _symbol,
            trustedForwarder,
            initialMinter,
            newBaseURI,
            _limitSupply,
            useMarketplaceFiltererRegistry,
            _observability
        );
    }

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param data Data to initialize the contract
     * @ param _contractURI Contract metadata
     * @ param defaultRoyalty Default royalty object for contract (optional)
     * @ param _defaultTokenManager Default token manager for contract (optional)
     * @ param _name Name of token edition
     * @ param _symbol Symbol of the token edition
     * @ param trustedForwarder Trusted minimal forwarder
     * @ param initialMinter Initial minter to register
     * @ param newBaseURI Base URI for contract
     * @ param _limitSupply Initial limit supply
     * @ param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @ param _observability Observability contract address
     */
    function initialize(address creator, bytes memory data) external initializer {
        (
            string memory _contractURI,
            IRoyaltyManager.Royalty memory defaultRoyalty,
            address _defaultTokenManager,
            string memory _name,
            string memory _symbol,
            address trustedForwarder,
            address initialMinter,
            string memory newBaseURI,
            uint256 _limitSupply,
            bool useMarketplaceFiltererRegistry,
            address _observability
        ) = abi.decode(
                data,
                (
                    string,
                    IRoyaltyManager.Royalty,
                    address,
                    string,
                    string,
                    address,
                    address,
                    string,
                    uint256,
                    bool,
                    address
                )
            );

        _initialize(
            creator,
            _contractURI,
            defaultRoyalty,
            _defaultTokenManager,
            _name,
            _symbol,
            trustedForwarder,
            initialMinter,
            newBaseURI,
            _limitSupply,
            useMarketplaceFiltererRegistry,
            _observability
        );
    }

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param _contractURI Contract metadata
     * @param defaultRoyalty Default royalty object for contract (optional)
     * @param _defaultTokenManager Default token manager for contract (optional)
     * @param _name Name of token edition
     * @param _symbol Symbol of the token edition
     * @param trustedForwarder Trusted minimal forwarder
     * @param initialMinter Initial minter to register
     * @param newBaseURI Base URI for contract
     * @param _limitSupply Initial limit supply
     * @param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @param _observability Observability contract address
     */
    function _initialize(
        address creator,
        string memory _contractURI,
        IRoyaltyManager.Royalty memory defaultRoyalty,
        address _defaultTokenManager,
        string memory _name,
        string memory _symbol,
        address trustedForwarder,
        address initialMinter,
        string memory newBaseURI,
        uint256 _limitSupply,
        bool useMarketplaceFiltererRegistry,
        address _observability
    ) private {
        __ERC721URIStorage_init();
        __ERC721Base_initialize(creator, defaultRoyalty, _defaultTokenManager);
        __ERC2771ContextUpgradeable__init__(trustedForwarder);
        __ERC721_init(_name, _symbol);
        // deprecate but keep input for backwards-compatibility:
        // __MarketplaceFilterer__init__(useMarketplaceFiltererRegistry);
        _minters.add(initialMinter);
        contractURI = _contractURI;
        IObservability(_observability).emitSeriesDeployed(address(this));
        observability = IObservability(_observability);

        if (bytes(newBaseURI).length > 0) {
            _setBaseURI(newBaseURI);
            // don't emit on observability contract here
        }

        if (_limitSupply > 0) {
            limitSupply = _limitSupply;
            // don't emit on observability contract here
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "./ERC721Base.sol";
import "../metadata/MetadataEncryption.sol";
import "../tokenManager/interfaces/IPostTransfer.sol";
import "../tokenManager/interfaces/IPostBurn.sol";
import "./interfaces/IERC721GeneralMint.sol";
import "../utils/ERC721/ERC721URIStorageUpgradeable.sol";
import "./MarketplaceFilterer/MarketplaceFiltererAbridged.sol";

/**
 * @title Generalized Base ERC721
 * @author highlight.xyz
 * @notice Generalized Base NFT smart contract
 */
abstract contract ERC721GeneralBase is
    ERC721Base,
    ERC721URIStorageUpgradeable,
    IERC721GeneralMint,
    MarketplaceFiltererAbridged
{
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Throw when attempting to mint, while mint is frozen
     */
    error MintFrozen();

    /**
     * @notice Throw when requested token is not in range within bounds of limit supply
     */
    error TokenNotInRange();

    /**
     * @notice Throw when new supply is over limit supply
     */
    error OverLimitSupply();

    /**
     * @notice Throw when array lengths are mismatched
     */
    error MismatchedArrayLengths();

    /**
     * @notice Throw when string is empty
     */
    error EmptyString();

    /**
     * @notice Contract metadata
     */
    string public contractURI;

    /**
     * @notice Total tokens minted
     */
    uint256 public supply;

    /**
     * @notice Limit the supply to take advantage of over-promising in summation with multiple mint vectors
     */
    uint256 public limitSupply;

    /**
     * @notice Emitted when uris are set for tokens
     * @param ids IDs of tokens to set uris for
     * @param uris Uris to set on tokens
     */
    event TokenURIsSet(uint256[] ids, string[] uris);

    /**
     * @notice Emitted when limit supply is set
     * @param newLimitSupply Limit supply to set
     */
    event LimitSupplySet(uint256 indexed newLimitSupply);

    /**
     * @notice See {IERC721GeneralMint-mintOneToOneRecipient}
     */
    function mintOneToOneRecipient(address recipient) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }

        uint256 tempSupply = supply;
        tempSupply++;
        _requireLimitSupply(tempSupply);

        _mint(recipient, tempSupply);
        supply = tempSupply;

        return tempSupply;
    }

    /**
     * @notice See {IERC721GeneralMint-mintAmountToOneRecipient}
     */
    function mintAmountToOneRecipient(address recipient, uint256 amount) external onlyMinter nonReentrant {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        uint256 tempSupply = supply; // cache

        for (uint256 i = 0; i < amount; i++) {
            tempSupply++;
            _mint(recipient, tempSupply);
        }

        _requireLimitSupply(tempSupply);
        supply = tempSupply;
    }

    /**
     * @notice See {IERC721GeneralMint-mintOneToMultipleRecipients}
     */
    function mintOneToMultipleRecipients(address[] calldata recipients) external onlyMinter nonReentrant {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        uint256 recipientsLength = recipients.length;
        uint256 tempSupply = supply; // cache

        for (uint256 i = 0; i < recipientsLength; i++) {
            tempSupply++;
            _mint(recipients[i], tempSupply);
        }

        _requireLimitSupply(tempSupply);
        supply = tempSupply;
    }

    /**
     * @notice See {IERC721GeneralMint-mintSameAmountToMultipleRecipients}
     */
    function mintSameAmountToMultipleRecipients(
        address[] calldata recipients,
        uint256 amount
    ) external onlyMinter nonReentrant {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        uint256 recipientsLength = recipients.length;
        uint256 tempSupply = supply; // cache

        for (uint256 i = 0; i < recipientsLength; i++) {
            for (uint256 j = 0; j < amount; j++) {
                tempSupply++;
                _mint(recipients[i], tempSupply);
            }
        }

        _requireLimitSupply(tempSupply);
        supply = tempSupply;
    }

    /**
     * @notice See {IERC721GeneralMint-mintSpecificTokenToOneRecipient}
     */
    function mintSpecificTokenToOneRecipient(address recipient, uint256 tokenId) external onlyMinter nonReentrant {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }

        uint256 tempSupply = supply;
        tempSupply++;

        uint256 _limitSupply = limitSupply;
        if (_limitSupply != 0) {
            if (tokenId > _limitSupply) {
                _revert(TokenNotInRange.selector);
            }
        }

        _mint(recipient, tokenId);
        supply = tempSupply;
    }

    /**
     * @notice See {IERC721GeneralMint-mintSpecificTokensToOneRecipient}
     */
    function mintSpecificTokensToOneRecipient(
        address recipient,
        uint256[] calldata tokenIds
    ) external onlyMinter nonReentrant {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }

        uint256 tempSupply = supply;

        uint256 tokenIdsLength = tokenIds.length;
        uint256 _limitSupply = limitSupply;
        if (_limitSupply == 0) {
            // don't check that token id is within range, since _limitSupply being 0 implies unlimited range
            for (uint256 i = 0; i < tokenIdsLength; i++) {
                _mint(recipient, tokenIds[i]);
                tempSupply++;
            }
        } else {
            // check that token id is within range
            for (uint256 i = 0; i < tokenIdsLength; i++) {
                if (tokenIds[i] > _limitSupply) {
                    _revert(TokenNotInRange.selector);
                }
                _mint(recipient, tokenIds[i]);
                tempSupply++;
            }
        }
    }

    /**
     * @notice Override base URI system for select tokens, with custom per-token metadata
     * @param ids IDs of tokens to override base uri system for with custom uris
     * @param uris Custom uris
     */
    function setTokenURIs(uint256[] calldata ids, string[] calldata uris) external nonReentrant {
        uint256 idsLength = ids.length;
        if (idsLength != uris.length) {
            _revert(MismatchedArrayLengths.selector);
        }

        for (uint256 i = 0; i < idsLength; i++) {
            _setTokenURI(ids[i], uris[i]);
        }

        emit TokenURIsSet(ids, uris);
        observability.emitTokenURIsSet(ids, uris);
    }

    /**
     * @notice Set base uri
     * @param newBaseURI New base uri to set
     */
    function setBaseURI(string calldata newBaseURI) external nonReentrant {
        if (bytes(newBaseURI).length == 0) {
            _revert(EmptyString.selector);
        }

        address _manager = defaultManager;

        if (_manager == address(0)) {
            if (_msgSender() != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!ITokenManager(_manager).canUpdateMetadata(_msgSender(), 0, bytes(newBaseURI))) {
                _revert(Unauthorized.selector);
            }
        }

        _setBaseURI(newBaseURI);
        observability.emitBaseUriSet(newBaseURI);
    }

    /**
     * @notice Set limit supply
     * @param _limitSupply Limit supply to set
     */
    function setLimitSupply(uint256 _limitSupply) external onlyOwner nonReentrant {
        // allow it to be 0, for post-mint
        limitSupply = _limitSupply;

        emit LimitSupplySet(_limitSupply);
        observability.emitLimitSupplySet(_limitSupply);
    }

    /**
     * @notice Set contract name
     * @param newName New name
     * @param newSymbol New symbol
     * @param newContractUri New contractURI
     */
    function setContractMetadata(
        string calldata newName,
        string calldata newSymbol,
        string calldata newContractUri
    ) external onlyOwner {
        _setContractMetadata(newName, newSymbol);
        contractURI = newContractUri;

        observability.emitContractMetadataSet(newName, newSymbol, newContractUri);
    }

    /**
     * @notice Total supply of NFTs on the contract
     * @dev Won't handle burned (temporary)
     */
    function totalSupply() external view returns (uint256) {
        return supply;
    }

    /**
     * @notice See {IERC721-setApprovalForAll}.
     *         Overrides default behaviour to check MarketplaceFilterer allowed operators.
     */
    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    /**
     * @notice See {IERC721-approve}.
     *         Overrides default behaviour to check MarketplaceFilterer allowed operators.
     */
    function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    /**
     * @notice See {IERC721-burn}. Overrides default behaviour to check associated tokenManager.
     */
    function burn(uint256 tokenId) public nonReentrant {
        address _manager = tokenManager(tokenId);
        address msgSender = _msgSender();

        if (_manager != address(0) && IERC165Upgradeable(_manager).supportsInterface(type(IPostBurn).interfaceId)) {
            address owner = ownerOf(tokenId);
            IPostBurn(_manager).postBurn(msgSender, owner, tokenId);
        } else {
            // default to restricting burn to owner or operator if a valid TM isn't present
            if (!_isApprovedOrOwner(msgSender, tokenId)) {
                _revert(Unauthorized.selector);
            }
        }

        _burn(tokenId);

        observability.emitTransfer(msgSender, address(0), tokenId);
    }

    /**
     * @notice Overrides tokenURI to first rotate the token id
     * @param tokenId ID of token to get uri for
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return ERC721URIStorageUpgradeable.tokenURI(tokenId);
    }

    /**
     * @notice See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return ERC721Upgradeable.supportsInterface(interfaceId);
    }

    /**
     * @notice Hook called after transfers
     * @param from Account token is being transferred from
     * @param to Account token is being transferred to
     * @param tokenId ID of token being transferred
     */
    function _afterTokenTransfers(address from, address to, uint256 tokenId) internal override {
        address msgSender = _msgSender();
        if (from != msgSender) {
            _checkFilterOperator(msgSender);
        }

        address _manager = tokenManager(tokenId);
        if (_manager != address(0) && IERC165Upgradeable(_manager).supportsInterface(type(IPostTransfer).interfaceId)) {
            IPostTransfer(_manager).postSafeTransferFrom(msgSender, from, to, tokenId, "");
        }

        observability.emitTransfer(from, to, tokenId);
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgSender() internal view virtual override(ERC721Base, ContextUpgradeable) returns (address sender) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgData() internal view virtual override(ERC721Base, ContextUpgradeable) returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(
        bytes4 errorSelector
    ) internal pure virtual override(ERC721Upgradeable, ERC721Base, MarketplaceFiltererAbridged) {
        ERC721Upgradeable._revert(errorSelector);
    }

    /**
     * @notice Override base URI system for select tokens, with custom per-token metadata
     * @param tokenId Token to set uri for
     * @param _uri Uri to set on token
     */
    function _setTokenURI(uint256 tokenId, string calldata _uri) private {
        address _manager = tokenManager(tokenId);
        address msgSender = _msgSender();

        address tempOwner = owner();
        if (_manager == address(0)) {
            if (msgSender != tempOwner) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!ITokenManager(_manager).canUpdateMetadata(msgSender, tokenId, bytes(_uri))) {
                _revert(Unauthorized.selector);
            }
        }

        _tokenURIs[tokenId] = _uri;
    }

    /**
     * @notice Require the new supply of tokens after mint to be less than limit supply
     * @param newSupply New supply
     */
    function _requireLimitSupply(uint256 newSupply) private view {
        uint256 _limitSupply = limitSupply;
        if (_limitSupply != 0 && newSupply > _limitSupply) {
            _revert(OverLimitSupply.selector);
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "./ERC721Base.sol";
import "../metadata/MetadataEncryption.sol";
import "../tokenManager/interfaces/IPostTransfer.sol";
import "../tokenManager/interfaces/IPostBurn.sol";
import "./interfaces/IERC721GeneralMint.sol";
import "./ERC721GeneralSequenceBase.sol";
import "./onchain/OnchainFileStorage.sol";

/**
 * @title Generalized ERC721 that expects tokenIds to increment in a monotonically increasing sequence
 * @author highlight.xyz
 * @notice Generalized NFT smart contract
 */
contract ERC721GeneralSequence is ERC721GeneralSequenceBase, OnchainFileStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param _contractURI Contract metadata
     * @param defaultRoyalty Default royalty object for contract (optional)
     * @param _defaultTokenManager Default token manager for contract (optional)
     * @param _name Name of token edition
     * @param _symbol Symbol of the token edition
     * @param trustedForwarder Trusted minimal forwarder
     * @param initialMinter Initial minter to register
     * @param newBaseURI Base URI for contract
     * @param _limitSupply Initial limit supply
     * @param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @param _observability Observability contract address
     */
    function initialize(
        address creator,
        string memory _contractURI,
        IRoyaltyManager.Royalty memory defaultRoyalty,
        address _defaultTokenManager,
        string memory _name,
        string memory _symbol,
        address trustedForwarder,
        address initialMinter,
        string memory newBaseURI,
        uint256 _limitSupply,
        bool useMarketplaceFiltererRegistry,
        address _observability
    ) external initializer {
        _initialize(
            creator,
            _contractURI,
            defaultRoyalty,
            _defaultTokenManager,
            _name,
            _symbol,
            trustedForwarder,
            initialMinter,
            newBaseURI,
            _limitSupply,
            useMarketplaceFiltererRegistry,
            _observability
        );
    }

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param data Data to initialize the contract
     * @ param _contractURI Contract metadata
     * @ param defaultRoyalty Default royalty object for contract (optional)
     * @ param _defaultTokenManager Default token manager for contract (optional)
     * @ param _name Name of token edition
     * @ param _symbol Symbol of the token edition
     * @ param trustedForwarder Trusted minimal forwarder
     * @ param initialMinter Initial minter to register
     * @ param newBaseURI Base URI for contract
     * @ param _limitSupply Initial limit supply
     * @ param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @ param _observability Observability contract address
     */
    function initialize(address creator, bytes memory data) external initializer {
        (
            string memory _contractURI,
            IRoyaltyManager.Royalty memory defaultRoyalty,
            address _defaultTokenManager,
            string memory _name,
            string memory _symbol,
            address trustedForwarder,
            address initialMinter,
            string memory newBaseURI,
            uint256 _limitSupply,
            bool useMarketplaceFiltererRegistry,
            address _observability
        ) = abi.decode(
                data,
                (
                    string,
                    IRoyaltyManager.Royalty,
                    address,
                    string,
                    string,
                    address,
                    address,
                    string,
                    uint256,
                    bool,
                    address
                )
            );

        _initialize(
            creator,
            _contractURI,
            defaultRoyalty,
            _defaultTokenManager,
            _name,
            _symbol,
            trustedForwarder,
            initialMinter,
            newBaseURI,
            _limitSupply,
            useMarketplaceFiltererRegistry,
            _observability
        );
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgSender()
        internal
        view
        virtual
        override(ERC721GeneralSequenceBase, ContextUpgradeable)
        returns (address sender)
    {
        return ERC721GeneralSequenceBase._msgSender();
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgData()
        internal
        view
        virtual
        override(ERC721GeneralSequenceBase, ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC721GeneralSequenceBase._msgData();
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure override(ERC721GeneralSequenceBase, OnchainFileStorage) {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param _contractURI Contract metadata
     * @param defaultRoyalty Default royalty object for contract (optional)
     * @param _defaultTokenManager Default token manager for contract (optional)
     * @param _name Name of token edition
     * @param _symbol Symbol of the token edition
     * @param trustedForwarder Trusted minimal forwarder
     * @param initialMinter Initial minter to register
     * @param newBaseURI Base URI for contract
     * @param _limitSupply Initial limit supply
     * @param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @param _observability Observability contract address
     */
    function _initialize(
        address creator,
        string memory _contractURI,
        IRoyaltyManager.Royalty memory defaultRoyalty,
        address _defaultTokenManager,
        string memory _name,
        string memory _symbol,
        address trustedForwarder,
        address initialMinter,
        string memory newBaseURI,
        uint256 _limitSupply,
        bool useMarketplaceFiltererRegistry,
        address _observability
    ) private {
        __ERC721URIStorage_init();
        __ERC721Base_initialize(creator, defaultRoyalty, _defaultTokenManager);
        __ERC2771ContextUpgradeable__init__(trustedForwarder);
        __ERC721A_init(_name, _symbol);
        // deprecate but keep input for backwards-compatibility:
        // __MarketplaceFilterer__init__(useMarketplaceFiltererRegistry);
        _minters.add(initialMinter);
        contractURI = _contractURI;
        IObservability(_observability).emitSeriesDeployed(address(this));
        observability = IObservability(_observability);

        if (bytes(newBaseURI).length > 0) {
            _setBaseURI(newBaseURI);
            // don't emit on observability contract here
        }

        if (_limitSupply > 0) {
            limitSupply = _limitSupply;
            // don't emit on observability contract here
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "./ERC721Base.sol";
import "../metadata/MetadataEncryption.sol";
import "../tokenManager/interfaces/IPostTransfer.sol";
import "../tokenManager/interfaces/IPostBurn.sol";
import "./interfaces/IERC721GeneralSequenceMint.sol";
import "./erc721a/ERC721AURIStorageUpgradeable.sol";
import "./inchain-rendering/interfaces/IHLRenderer.sol";

/**
 * @title Generalized Base ERC721
 * @author highlight.xyz
 * @notice Generalized Base NFT smart contract
 */
abstract contract ERC721GeneralSequenceBase is ERC721Base, ERC721AURIStorageUpgradeable, IERC721GeneralSequenceMint {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Throw when attempting to mint, while mint is frozen
     */
    error MintFrozen();

    /**
     * @notice Throw when requested token is not in range within bounds of limit supply
     */
    error TokenNotInRange();

    /**
     * @notice Throw when new supply is over limit supply
     */
    error OverLimitSupply();

    /**
     * @notice Throw when array lengths are mismatched
     */
    error MismatchedArrayLengths();

    /**
     * @notice Throw when string is empty
     */
    error EmptyString();

    /**
     * @notice Custom renderer config, used for collections where metadata is rendered "in-chain"
     * @param renderer Renderer address
     * @param processMintDataOnRenderer If true, process mint data on renderer
     */
    struct CustomRendererConfig {
        address renderer;
        bool processMintDataOnRenderer;
    }

    /**
     * @notice Contract metadata
     */
    string public contractURI;

    /**
     * @notice Limit the supply to take advantage of over-promising in summation with multiple mint vectors
     */
    uint256 public limitSupply;

    /**
     * @notice Custom renderer config
     */
    CustomRendererConfig public customRendererConfig;

    /**
     * @notice Emitted when uris are set for tokens
     * @param ids IDs of tokens to set uris for
     * @param uris Uris to set on tokens
     */
    event TokenURIsSet(uint256[] ids, string[] uris);

    /**
     * @notice Emitted when limit supply is set
     * @param newLimitSupply Limit supply to set
     */
    event LimitSupplySet(uint256 indexed newLimitSupply);

    /**
     * @notice See {IERC721GeneralMint-mintOneToOneRecipient}
     */
    function mintOneToOneRecipient(address recipient) external virtual onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }

        uint256 tempSupply = _nextTokenId();
        _requireLimitSupply(tempSupply);

        _mint(recipient, 1);

        // process mint on custom renderer if present
        CustomRendererConfig memory _customRendererConfig = customRendererConfig;
        if (_customRendererConfig.processMintDataOnRenderer) {
            IHLRenderer(_customRendererConfig.renderer).processOneRecipientMint(tempSupply, 1, recipient);
        }

        return tempSupply;
    }

    /**
     * @notice See {IERC721GeneralMint-mintAmountToOneRecipient}
     */
    function mintAmountToOneRecipient(address recipient, uint256 amount) external virtual onlyMinter nonReentrant {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        uint256 tempSupply = _nextTokenId() - 1; // cache

        _mint(recipient, amount);

        _requireLimitSupply(tempSupply + amount);

        // process mint on custom renderer if present
        CustomRendererConfig memory _customRendererConfig = customRendererConfig;
        if (_customRendererConfig.processMintDataOnRenderer) {
            IHLRenderer(_customRendererConfig.renderer).processOneRecipientMint(tempSupply + 1, amount, recipient);
        }
    }

    /**
     * @notice See {IERC721GeneralMint-mintOneToMultipleRecipients}
     */
    function mintOneToMultipleRecipients(address[] calldata recipients) external onlyMinter nonReentrant {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        uint256 recipientsLength = recipients.length;
        uint256 tempSupply = _nextTokenId() - 1; // cache

        for (uint256 i = 0; i < recipientsLength; i++) {
            _mint(recipients[i], 1);
        }

        _requireLimitSupply(tempSupply + recipientsLength);

        // process mint on custom renderer if present
        CustomRendererConfig memory _customRendererConfig = customRendererConfig;
        if (_customRendererConfig.processMintDataOnRenderer) {
            IHLRenderer(_customRendererConfig.renderer).processMultipleRecipientMint(tempSupply + 1, 1, recipients);
        }
    }

    /**
     * @notice See {IERC721GeneralMint-mintSameAmountToMultipleRecipients}
     */
    function mintSameAmountToMultipleRecipients(
        address[] calldata recipients,
        uint256 amount
    ) external onlyMinter nonReentrant {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        uint256 recipientsLength = recipients.length;
        uint256 tempSupply = _nextTokenId() - 1; // cache

        for (uint256 i = 0; i < recipientsLength; i++) {
            _mint(recipients[i], amount);
        }

        _requireLimitSupply(tempSupply + recipientsLength * amount);

        // process mint on custom renderer if present
        CustomRendererConfig memory _customRendererConfig = customRendererConfig;
        if (_customRendererConfig.processMintDataOnRenderer) {
            IHLRenderer(_customRendererConfig.renderer).processMultipleRecipientMint(
                tempSupply + 1,
                amount,
                recipients
            );
        }
    }

    /**
     * @notice Set custom renderer and processing config
     * @param _customRendererConfig New custom renderer config
     */
    function setCustomRenderer(CustomRendererConfig calldata _customRendererConfig) external onlyOwner {
        require(_customRendererConfig.renderer != address(0), "Invalid input");
        customRendererConfig = _customRendererConfig;
    }

    /**
     * @notice Override base URI system for select tokens, with custom per-token metadata
     * @param ids IDs of tokens to override base uri system for with custom uris
     * @param uris Custom uris
     */
    function setTokenURIs(uint256[] calldata ids, string[] calldata uris) external nonReentrant {
        uint256 idsLength = ids.length;
        if (idsLength != uris.length) {
            _revert(MismatchedArrayLengths.selector);
        }

        for (uint256 i = 0; i < idsLength; i++) {
            _setTokenURI(ids[i], uris[i]);
        }

        emit TokenURIsSet(ids, uris);
        observability.emitTokenURIsSet(ids, uris);
    }

    /**
     * @notice Set base uri
     * @param newBaseURI New base uri to set
     */
    function setBaseURI(string calldata newBaseURI) external nonReentrant {
        if (bytes(newBaseURI).length == 0) {
            _revert(EmptyString.selector);
        }

        address _manager = defaultManager;

        if (_manager == address(0)) {
            if (_msgSender() != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!ITokenManager(_manager).canUpdateMetadata(_msgSender(), 0, bytes(newBaseURI))) {
                _revert(Unauthorized.selector);
            }
        }

        _setBaseURI(newBaseURI);
        observability.emitBaseUriSet(newBaseURI);
    }

    /**
     * @notice Set limit supply
     * @param _limitSupply Limit supply to set
     */
    function setLimitSupply(uint256 _limitSupply) external onlyOwner nonReentrant {
        // allow it to be 0, for post-mint
        limitSupply = _limitSupply;

        emit LimitSupplySet(_limitSupply);
        observability.emitLimitSupplySet(_limitSupply);
    }

    /**
     * @notice Set contract name
     * @param newName New name
     * @param newSymbol New symbol
     * @param newContractUri New contractURI
     */
    function setContractMetadata(
        string calldata newName,
        string calldata newSymbol,
        string calldata newContractUri
    ) external onlyOwner {
        _setContractMetadata(newName, newSymbol);
        contractURI = newContractUri;

        observability.emitContractMetadataSet(newName, newSymbol, newContractUri);
    }

    /**
     * @notice Return the total number of minted tokens on the collection
     */
    function supply() external view returns (uint256) {
        return ERC721AUpgradeable._totalMinted();
    }

    /**
     * @notice See {IERC721-burn}. Overrides default behaviour to check associated tokenManager.
     */
    function burn(uint256 tokenId) public nonReentrant {
        address _manager = tokenManager(tokenId);
        address msgSender = _msgSender();

        if (_manager != address(0) && IERC165Upgradeable(_manager).supportsInterface(type(IPostBurn).interfaceId)) {
            address owner = ownerOf(tokenId);
            IPostBurn(_manager).postBurn(msgSender, owner, tokenId);
        } else {
            // default to restricting burn to owner or operator if a valid TM isn't present
            if (!_isApprovedOrOwner(msgSender, tokenId)) {
                _revert(Unauthorized.selector);
            }
        }

        _burn(tokenId);

        observability.emitTransfer(msgSender, address(0), tokenId);
    }

    /**
     * @notice Overrides tokenURI to first rotate the token id
     * @param tokenId ID of token to get uri for
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (customRendererConfig.renderer != address(0)) {
            return IHLRenderer(customRendererConfig.renderer).tokenURI(tokenId);
        }
        return ERC721AURIStorageUpgradeable.tokenURI(tokenId);
    }

    /**
     * @notice See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165Upgradeable, ERC721AUpgradeable) returns (bool) {
        return ERC721AUpgradeable.supportsInterface(interfaceId);
    }

    /**
     * @notice Hook called after transfers
     * @param from Account token is being transferred from
     * @param to Account token is being transferred to
     * @param tokenId ID of token being transferred
     */
    function _afterTokenTransfers(address from, address to, uint256 tokenId) internal override {
        address _manager = tokenManager(tokenId);
        if (_manager != address(0) && IERC165Upgradeable(_manager).supportsInterface(type(IPostTransfer).interfaceId)) {
            IPostTransfer(_manager).postSafeTransferFrom(_msgSender(), from, to, tokenId, "");
        }

        observability.emitTransfer(from, to, tokenId);
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgSender() internal view virtual override(ERC721Base, ContextUpgradeable) returns (address sender) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgData() internal view virtual override(ERC721Base, ContextUpgradeable) returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure virtual override(ERC721AUpgradeable, ERC721Base) {
        ERC721AUpgradeable._revert(errorSelector);
    }

    /**
     * @notice Override base URI system for select tokens, with custom per-token metadata
     * @param tokenId Token to set uri for
     * @param _uri Uri to set on token
     */
    function _setTokenURI(uint256 tokenId, string calldata _uri) private {
        address _manager = tokenManager(tokenId);
        address msgSender = _msgSender();

        address tempOwner = owner();
        if (_manager == address(0)) {
            if (msgSender != tempOwner) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!ITokenManager(_manager).canUpdateMetadata(msgSender, tokenId, bytes(_uri))) {
                _revert(Unauthorized.selector);
            }
        }

        _tokenURIs[tokenId] = _uri;
    }

    /**
     * @notice Require the new supply of tokens after mint to be less than limit supply
     * @param newSupply New supply
     */
    function _requireLimitSupply(uint256 newSupply) internal view {
        uint256 _limitSupply = limitSupply;
        if (_limitSupply != 0 && newSupply > _limitSupply) {
            _revert(OverLimitSupply.selector);
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../royaltyManager/interfaces/IRoyaltyManager.sol";
import "../tokenManager/interfaces/ITokenManager.sol";
import "../utils/Ownable.sol";
import "../utils/ERC2981/IERC2981Upgradeable.sol";
import "../metatx/ERC2771ContextUpgradeable.sol";
import "../observability/IObservability.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../utils/ERC165/ERC165CheckerUpgradeable.sol";

/**
 * @title Minimized Base ERC721
 * @author highlight.xyz
 * @notice Core piece of Highlight NFT contracts (V2), branch for ERC721SingleEdition
 */
abstract contract ERC721MinimizedBase is
    OwnableUpgradeable,
    IERC2981Upgradeable,
    ERC2771ContextUpgradeable,
    ReentrancyGuardUpgradeable
{
    using EnumerableSet for EnumerableSet.AddressSet;
    using ERC165CheckerUpgradeable for address;

    /**
     * @notice Throw when token or royalty manager is invalid
     */
    error InvalidManager();

    /**
     * @notice Throw when token or royalty manager does not exist
     */
    error ManagerDoesNotExist();

    /**
     * @notice Throw when sender is unauthorized to perform action
     */
    error Unauthorized();

    /**
     * @notice Throw when sender is not a minter
     */
    error NotMinter();

    /**
     * @notice Throw when token manager or royalty manager swap is blocked
     */
    error ManagerSwapBlocked();

    /**
     * @notice Throw when token manager or royalty manager remove is blocked
     */
    error ManagerRemoveBlocked();

    /**
     * @notice Throw when setting default or granular royalty is blocked
     */
    error RoyaltySetBlocked();

    /**
     * @notice Throw when royalty BPS is invalid
     */
    error RoyaltyBPSInvalid();

    /**
     * @notice Throw when minter registration is invalid
     */
    error MinterRegistrationInvalid();

    /**
     * @notice Set of minters allowed to mint on contract
     */
    EnumerableSet.AddressSet internal _minters;

    /**
     * @notice Global token/edition manager default
     */
    address public defaultManager;

    /**
     * @notice Default royalty for entire contract
     */
    IRoyaltyManager.Royalty internal _defaultRoyalty;

    /**
     * @notice Royalty manager - optional contract that defines the conditions around setting royalties
     */
    address public royaltyManager;

    /**
     * @notice Freezes minting on smart contract forever
     */
    uint8 internal _mintFrozen;

    /**
     * @notice Observability contract
     */
    IObservability public observability;

    /**
     * @notice Emitted when minter is registered or unregistered
     * @param minter Minter that was changed
     * @param registered True if the minter was registered, false if unregistered
     */
    event MinterRegistrationChanged(address indexed minter, bool indexed registered);

    /**
     * @notice Emitted when default token manager changed
     * @param newDefaultTokenManager New default token manager. Zero address if old one was removed
     */
    event DefaultTokenManagerChanged(address indexed newDefaultTokenManager);

    /**
     * @notice Emitted when default royalty is set
     * @param recipientAddress Royalty recipient
     * @param royaltyPercentageBPS Percentage of sale (in basis points) owed to royalty recipient
     */
    event DefaultRoyaltySet(address indexed recipientAddress, uint16 indexed royaltyPercentageBPS);

    /**
     * @notice Emitted when royalty manager is updated
     * @param newRoyaltyManager New royalty manager. Zero address if old one was removed
     */
    event RoyaltyManagerChanged(address indexed newRoyaltyManager);

    /**
     * @notice Emitted when mints are frozen permanently
     */
    event MintsFrozen();

    /**
     * @notice Restricts calls to minters
     */
    modifier onlyMinter() {
        if (!_minters.contains(_msgSender())) {
            _revert(NotMinter.selector);
        }
        _;
    }

    /**
     * @notice Restricts calls if input royalty bps is over 10000
     */
    modifier royaltyValid(uint16 _royaltyBPS) {
        if (_royaltyBPS > 10000) {
            _revert(RoyaltyBPSInvalid.selector);
        }
        _;
    }

    /**
     * @notice Registers a minter
     * @param minter New minter
     */
    function registerMinter(address minter) external onlyOwner nonReentrant {
        if (!_minters.add(minter)) {
            _revert(MinterRegistrationInvalid.selector);
        }

        emit MinterRegistrationChanged(minter, true);
        observability.emitMinterRegistrationChanged(minter, true);
    }

    /**
     * @notice Unregisters a minter
     * @param minter Minter to unregister
     */
    function unregisterMinter(address minter) external onlyOwner nonReentrant {
        if (!_minters.remove(minter)) {
            _revert(MinterRegistrationInvalid.selector);
        }

        emit MinterRegistrationChanged(minter, false);
        observability.emitMinterRegistrationChanged(minter, false);
    }

    /**
     * @notice Set default token manager if current token manager allows it
     * @param _defaultTokenManager New default token manager
     */
    function setDefaultTokenManager(address _defaultTokenManager) external nonReentrant {
        if (!_isValidTokenManager(_defaultTokenManager)) {
            _revert(InvalidManager.selector);
        }
        address msgSender = _msgSender();

        address currentTokenManager = defaultManager;
        if (currentTokenManager == address(0)) {
            if (msgSender != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!ITokenManager(currentTokenManager).canSwap(msgSender, 0, _defaultTokenManager)) {
                _revert(ManagerSwapBlocked.selector);
            }
        }

        defaultManager = _defaultTokenManager;

        emit DefaultTokenManagerChanged(_defaultTokenManager);
        observability.emitDefaultTokenManagerChanged(_defaultTokenManager);
    }

    /**
     * @notice Removes default token manager if current token manager allows it
     */
    function removeDefaultTokenManager() external nonReentrant {
        address msgSender = _msgSender();

        address currentTokenManager = defaultManager;
        if (currentTokenManager == address(0)) {
            _revert(ManagerDoesNotExist.selector);
        }
        if (!ITokenManager(currentTokenManager).canRemoveItself(msgSender, 0)) {
            _revert(ManagerRemoveBlocked.selector);
        }

        defaultManager = address(0);

        emit DefaultTokenManagerChanged(address(0));
        observability.emitDefaultTokenManagerChanged(address(0));
    }

    /**
     * @notice Sets default royalty if royalty manager allows it
     * @param _royalty New default royalty
     */
    function setDefaultRoyalty(
        IRoyaltyManager.Royalty calldata _royalty
    ) external nonReentrant royaltyValid(_royalty.royaltyPercentageBPS) {
        address msgSender = _msgSender();

        address _royaltyManager = royaltyManager;
        if (_royaltyManager == address(0)) {
            if (msgSender != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!IRoyaltyManager(_royaltyManager).canSetDefaultRoyalty(_royalty, msgSender)) {
                _revert(RoyaltySetBlocked.selector);
            }
        }

        _defaultRoyalty = _royalty;

        emit DefaultRoyaltySet(_royalty.recipientAddress, _royalty.royaltyPercentageBPS);
        observability.emitDefaultRoyaltySet(_royalty.recipientAddress, _royalty.royaltyPercentageBPS);
    }

    /**
     * @notice Sets royalty manager if current one allows it
     * @param _royaltyManager New royalty manager
     */
    function setRoyaltyManager(address _royaltyManager) external nonReentrant {
        if (!_isValidRoyaltyManager(_royaltyManager)) {
            _revert(InvalidManager.selector);
        }
        address msgSender = _msgSender();

        address currentRoyaltyManager = royaltyManager;
        if (currentRoyaltyManager == address(0)) {
            if (msgSender != owner()) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (!IRoyaltyManager(currentRoyaltyManager).canSwap(_royaltyManager, msgSender)) {
                _revert(ManagerSwapBlocked.selector);
            }
        }

        royaltyManager = _royaltyManager;

        emit RoyaltyManagerChanged(_royaltyManager);
        observability.emitRoyaltyManagerChanged(_royaltyManager);
    }

    /**
     * @notice Removes royalty manager if current one allows it
     */
    function removeRoyaltyManager() external nonReentrant {
        address msgSender = _msgSender();

        address currentRoyaltyManager = royaltyManager;
        if (currentRoyaltyManager == address(0)) {
            _revert(ManagerDoesNotExist.selector);
        }
        if (!IRoyaltyManager(currentRoyaltyManager).canRemoveItself(msgSender)) {
            _revert(ManagerRemoveBlocked.selector);
        }

        royaltyManager = address(0);

        emit RoyaltyManagerChanged(address(0));
        observability.emitRoyaltyManagerChanged(address(0));
    }

    /**
     * @notice Freeze mints on contract forever
     */
    function freezeMints() external onlyOwner nonReentrant {
        _mintFrozen = 1;

        emit MintsFrozen();
        observability.emitMintsFrozen();
    }

    /**
     * @notice Return allowed minters on contract
     */
    function minters() external view returns (address[] memory) {
        return _minters.values();
    }

    /**
     * @notice Conforms to ERC-2981. Editions should overwrite to return royalty for entire edition
     * @param // Edition id
     * @param _salePrice Sale price of token
     */
    function royaltyInfo(
        uint256 /* _tokenGroupingId */,
        uint256 _salePrice
    ) public view virtual override returns (address receiver, uint256 royaltyAmount) {
        IRoyaltyManager.Royalty memory royalty = _defaultRoyalty;

        receiver = royalty.recipientAddress;
        royaltyAmount = (_salePrice * uint256(royalty.royaltyPercentageBPS)) / 10000;
    }

    /**
     * @notice Returns the token manager for the id passed in.
     * @param // Token ID or Edition ID for Editions implementing contracts
     */
    function tokenManager(uint256 /* id */) public view returns (address manager) {
        return defaultManager;
    }

    /**
     * @notice Initializes the contract, setting the creator as the initial owner.
     * @param creator Contract creator
     * @param defaultRoyalty Default royalty for the contract
     * @param _defaultTokenManager Default token manager for the contract
     */
    function __ERC721MinimizedBase_initialize(
        address creator,
        IRoyaltyManager.Royalty memory defaultRoyalty,
        address _defaultTokenManager
    ) internal onlyInitializing royaltyValid(defaultRoyalty.royaltyPercentageBPS) {
        __Ownable_init();
        __ReentrancyGuard_init();
        _transferOwnership(creator);

        _defaultRoyalty = defaultRoyalty;

        defaultManager = _defaultTokenManager;
    }

    /**
     * @notice Returns true if address is a valid tokenManager
     * @param _tokenManager Token manager being checked
     */
    function _isValidTokenManager(address _tokenManager) internal view returns (bool) {
        return _tokenManager.supportsInterface(type(ITokenManager).interfaceId);
    }

    /**
     * @notice Returns true if address is a valid royaltyManager
     * @param _royaltyManager Royalty manager being checked
     */
    function _isValidRoyaltyManager(address _royaltyManager) internal view returns (bool) {
        return _royaltyManager.supportsInterface(type(IRoyaltyManager).interfaceId);
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgSender()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgData()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure virtual {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../utils/Ownable.sol";
import "../metadata/interfaces/IMetadataRenderer.sol";
import "../metadata/interfaces/IEditionsMetadataRenderer.sol";
import "./interfaces/IEditionCollection.sol";
import "./ERC721MinimizedBase.sol";
import "../tokenManager/interfaces/IPostTransfer.sol";
import "../tokenManager/interfaces/IPostBurn.sol";
import "./interfaces/IERC721EditionMint.sol";
import "./MarketplaceFilterer/MarketplaceFilterer.sol";
import "../tokenManager/interfaces/ITokenManagerEditions.sol";
import "./erc721a/ERC721AUpgradeable.sol";

/**
 * @title ERC721 Single Edition
 * @author highlight.xyz
 * @notice Single Edition Per Collection
 * @dev Using Decentralized File Storage
 */
contract ERC721SingleEditionDFS is
    IERC721EditionMint,
    IEditionCollection,
    ERC721MinimizedBase,
    ERC721AUpgradeable,
    MarketplaceFilterer
{
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Throw when edition doesn't exist
     */
    error EditionDoesNotExist();

    /**
     * @notice Throw when token doesn't exist
     */
    error TokenDoesNotExist();

    /**
     * @notice Throw when attempting to mint, while mint is frozen
     */
    error MintFrozen();

    /**
     * @notice Throw when tokens on edition are sold out
     */
    error SoldOut();

    /**
     * @notice Throw when editionIds length is invalid
     */
    error InvalidEditionIdsLength();

    /**
     * @notice Throw when editionId is invalid
     */
    error InvalidEditionId();

    /**
     * @notice Contract metadata
     */
    string public contractURI;

    /**
     * @notice Total size of edition that can be minted
     */
    uint256 public size;

    /**
     * @notice Stores the edition's metadata
     */
    string public editionUri;

    /**
     * @notice Emitted when edition is created
     * @param size Edition size
     * @param editionTokenManager Token manager for edition
     */
    event EditionCreated(uint256 indexed size, address indexed editionTokenManager);

    /**
     * @notice Initializes the contract
     * @param creator Creator/owner of contract
     * @param data Data to initialize contract, in current format:
     * @ param defaultRoyalty Default royalty object for contract (optional)
     * @ param _defaultTokenManager Default token manager for contract (optional)
     * @ param _contractURI Contract metadata
     * @ param _name Name of token edition
     * @ param _symbol Symbol of the token edition
     * @ param _size Edition size
     * @ param trustedForwarder Trusted minimal forwarder
     * @ param initialMinter Initial minter to register
     * @ param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @ param _editionUri Edition uri
     * @param _observability Observability contract address
     */
    function initialize(address creator, bytes memory data, address _observability) external initializer {
        (
            IRoyaltyManager.Royalty memory defaultRoyalty,
            address _defaultTokenManager,
            string memory _contractURI,
            string memory _name,
            string memory _symbol,
            uint256 _size,
            address trustedForwarder,
            address initialMinter,
            bool useMarketplaceFiltererRegistry,
            string memory _editionUri
        ) = abi.decode(
                data,
                (IRoyaltyManager.Royalty, address, string, string, string, uint256, address, address, bool, string)
            );

        _initialize(
            creator,
            defaultRoyalty,
            _defaultTokenManager,
            _contractURI,
            _name,
            _symbol,
            _editionUri,
            _size,
            trustedForwarder,
            initialMinter,
            useMarketplaceFiltererRegistry
        );

        IObservability(_observability).emitSingleEditionDeployed(address(this));
        observability = IObservability(_observability);
    }

    /**
     * @notice See {IERC721EditionMint-mintOneToRecipient}
     */
    function mintOneToRecipient(
        uint256 editionId,
        address recipient
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }

        return _mintEditionsToOne(recipient, 1);
    }

    /**
     * @notice See {IERC721EditionMint-mintAmountToRecipient}
     */
    function mintAmountToRecipient(
        uint256 editionId,
        address recipient,
        uint256 amount
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }

        return _mintEditionsToOne(recipient, amount);
    }

    /**
     * @notice See {IERC721EditionMint-mintOneToRecipients}
     */
    function mintOneToRecipients(
        uint256 editionId,
        address[] memory recipients
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }
        return _mintEditions(recipients, 1);
    }

    /**
     * @notice See {IERC721EditionMint-mintAmountToRecipients}
     */
    function mintAmountToRecipients(
        uint256 editionId,
        address[] memory recipients,
        uint256 amount
    ) external onlyMinter nonReentrant returns (uint256) {
        if (_mintFrozen == 1) {
            _revert(MintFrozen.selector);
        }
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }
        return _mintEditions(recipients, amount);
    }

    /**
     * @notice Set contract name
     * @param newName New name
     * @param newSymbol New symbol
     * @param newContractUri New contractURI
     */
    function setContractMetadata(
        string calldata newName,
        string calldata newSymbol,
        string calldata newContractUri
    ) external onlyOwner {
        _setContractMetadata(newName, newSymbol);
        contractURI = newContractUri;

        observability.emitContractMetadataSet(newName, newSymbol, newContractUri);
    }

    /**
     * @notice See {IEditionCollection-getEditionId}
     */
    function getEditionId(uint256 tokenId) external view returns (uint256) {
        if (!_exists(tokenId)) {
            _revert(TokenDoesNotExist.selector);
        }
        return 0;
    }

    /**
     * @notice See {IEditionCollection-getEditionDetails}
     */
    function getEditionDetails(uint256 editionId) external view returns (EditionDetails memory) {
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }
        return _getEditionDetails();
    }

    /**
     * @notice See {IEditionCollection-getEditionsDetailsAndUri}
     */
    function getEditionsDetailsAndUri(
        uint256[] calldata editionIds
    ) external view returns (EditionDetails[] memory, string[] memory) {
        if (editionIds.length != 1) {
            _revert(InvalidEditionIdsLength.selector);
        }
        EditionDetails[] memory editionsDetails = new EditionDetails[](1);
        string[] memory uris = new string[](1);

        // expected to be 0, validated in editionURI call
        uint256 editionId = editionIds[0];

        uris[0] = editionURI(editionId);
        editionsDetails[0] = _getEditionDetails();

        return (editionsDetails, uris);
    }

    /**
     * @notice See {IERC721-transferFrom}. Overrides default behaviour to check associated tokenManager.
     */
    function transferFrom(address from, address to, uint256 tokenId) public payable override {
        ERC721AUpgradeable.transferFrom(from, to, tokenId);

        address _manager = defaultManager;
        if (_manager != address(0) && IERC165Upgradeable(_manager).supportsInterface(type(IPostTransfer).interfaceId)) {
            IPostTransfer(_manager).postTransferFrom(_msgSender(), from, to, tokenId);
        }

        observability.emitTransfer(from, to, tokenId);
    }

    /**
     * @notice See {IERC721-safeTransferFrom}. Overrides default behaviour to check associated tokenManager.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public payable override {
        ERC721AUpgradeable.safeTransferFrom(from, to, tokenId, data);

        address _manager = defaultManager;
        if (_manager != address(0) && IERC165Upgradeable(_manager).supportsInterface(type(IPostTransfer).interfaceId)) {
            IPostTransfer(_manager).postSafeTransferFrom(_msgSender(), from, to, tokenId, data);
        }

        observability.emitTransfer(from, to, tokenId);
    }

    /**
     * @notice See {IERC721-burn}. Overrides default behaviour to check associated tokenManager.
     */
    function burn(uint256 tokenId) public nonReentrant {
        address _manager = defaultManager;
        address msgSender = _msgSender();

        if (_manager != address(0) && IERC165Upgradeable(_manager).supportsInterface(type(IPostBurn).interfaceId)) {
            address owner = ownerOf(tokenId);
            IPostBurn(_manager).postBurn(msgSender, owner, 0);
        } else {
            // default to restricting burn to owner or operator if a valid TM isn't present
            if (!_isApprovedOrOwner(msgSender, tokenId)) {
                _revert(Unauthorized.selector);
            }
        }

        _burn(tokenId);

        observability.emitTransfer(msgSender, address(0), tokenId);
    }

    /**
     * @notice Conforms to ERC-2981.
     * @param // Token id
     * @param _salePrice Sale price of token
     */
    function royaltyInfo(
        uint256 /* _tokenId */,
        uint256 _salePrice
    ) public view virtual override returns (address receiver, uint256 royaltyAmount) {
        return ERC721MinimizedBase.royaltyInfo(0, _salePrice);
    }

    /**
     * @notice Get URI for given edition id
     * @param editionId edition id to get uri for
     */
    function editionURI(uint256 editionId) public view returns (string memory) {
        if (!_editionExists(editionId)) {
            _revert(EditionDoesNotExist.selector);
        }
        return editionUri;
    }

    /**
     * @notice Get URI for given token id
     * @param tokenId token id to get uri for
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) {
            _revert(TokenDoesNotExist.selector);
        }
        return editionUri;
    }

    /**
     * @notice Used to get token manager of token id
     * @param tokenId ID of the token
     */
    function tokenManagerByTokenId(uint256 tokenId) public view returns (address) {
        return tokenManager(tokenId);
    }

    /**
     * @notice Set an Edition's uri
     * @param editionId Edition to set uri for
     * @param _uri Uri to set on editions
     */
    function setEditionURI(uint256 editionId, string calldata _uri) external {
        if (editionId != 0) {
            _revert(InvalidEditionId.selector);
        }
        address _manager = defaultManager;
        address msgSender = _msgSender();

        if (_manager == address(0)) {
            address tempOwner = owner();
            if (msgSender != tempOwner) {
                _revert(Unauthorized.selector);
            }
        } else {
            if (
                !ITokenManagerEditions(_manager).canUpdateEditionsMetadata(
                    address(this),
                    msgSender,
                    0,
                    bytes(_uri),
                    ITokenManagerEditions.FieldUpdated.other
                )
            ) {
                _revert(Unauthorized.selector);
            }
        }

        editionUri = _uri;

        uint256[] memory _ids = new uint256[](1);
        _ids[0] = 0;
        string[] memory _uris = new string[](1);
        _uris[0] = _uri;
        observability.emitTokenURIsSet(_ids, _uris);
    }

    /**
     * @notice See {IERC721AUpgradeable-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165Upgradeable, ERC721AUpgradeable) returns (bool) {
        return ERC721AUpgradeable.supportsInterface(interfaceId);
    }

    /**
     * @notice Private function to mint without any access checks. Called by the public edition minting functions.
     * @param recipients Recipients of newly minted tokens
     * @param _amount Amount minted to each recipient
     */
    function _mintEditions(address[] memory recipients, uint256 _amount) internal returns (uint256) {
        uint256 recipientsLength = recipients.length;

        uint256 tempCurrent = _nextTokenId();
        uint256 endAt = tempCurrent + (recipientsLength * _amount) - 1;

        if (size != 0 && endAt > size) {
            _revert(SoldOut.selector);
        }

        for (uint256 i = 0; i < recipientsLength; i++) {
            _mint(recipients[i], _amount);
        }

        return endAt;
    }

    /**
     * @notice Private function to mint without any access checks. Called by the public edition minting functions.
     * @param recipient Recipient of newly minted token
     * @param _amount Amount minted to recipient
     */
    function _mintEditionsToOne(address recipient, uint256 _amount) internal returns (uint256) {
        uint256 tempCurrent = _nextTokenId();
        uint256 endAt = tempCurrent + _amount - 1;

        if (size != 0 && endAt > size) {
            _revert(SoldOut.selector);
        }

        _mint(recipient, _amount);

        return endAt;
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgSender() internal view override(ERC721MinimizedBase, ContextUpgradeable) returns (address sender) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgData() internal view override(ERC721MinimizedBase, ContextUpgradeable) returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(
        bytes4 errorSelector
    ) internal pure override(ERC721AUpgradeable, ERC721MinimizedBase, MarketplaceFilterer) {
        ERC721AUpgradeable._revert(errorSelector);
    }

    /**
     * @notice Used to initialize contract
     * @param creator Creator/owner of contract
     * @param defaultRoyalty Default royalty object for contract (optional)
     * @param _defaultTokenManager Default token manager for contract (optional)
     * @param _contractURI Contract metadata
     * @param _name Name of token edition
     * @param _symbol Symbol of the token edition
     * @param _editionUri Edition uri (metadata)
     * @param _size Edition size
     * @param trustedForwarder Trusted minimal forwarder
     * @param initialMinter Initial minter to register
     * @param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     */
    function _initialize(
        address creator,
        IRoyaltyManager.Royalty memory defaultRoyalty,
        address _defaultTokenManager,
        string memory _contractURI,
        string memory _name,
        string memory _symbol,
        string memory _editionUri,
        uint256 _size,
        address trustedForwarder,
        address initialMinter,
        bool useMarketplaceFiltererRegistry
    ) private {
        __ERC721MinimizedBase_initialize(creator, defaultRoyalty, _defaultTokenManager);
        __ERC721A_init(_name, _symbol);
        __ERC2771ContextUpgradeable__init__(trustedForwarder);
        // deprecate but keep input for backwards-compatibility:
        // __MarketplaceFilterer__init__(useMarketplaceFiltererRegistry);
        size = _size;
        editionUri = _editionUri;
        _minters.add(initialMinter);
        contractURI = _contractURI;

        emit EditionCreated(_size, _defaultTokenManager);
    }

    /**
     * @notice Get edition details
     */
    function _getEditionDetails() private view returns (EditionDetails memory) {
        return EditionDetails(this.name(), size, _nextTokenId() - 1, 1);
    }

    /**
     * @notice Returns whether `editionId` exists.
     */
    function _editionExists(uint256 editionId) private pure returns (bool) {
        return editionId == 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { IOperatorFilterRegistry } from "./interfaces/IOperatorFilterRegistry.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title  MarketplaceFilterer
 * @notice Abstract contract whose constructor automatically registers and subscribes to default
           subscription from OpenSea, if a valid registry is passed in. 
           Slightly modified from `OperatorFilterer` contract by ishan@ highlight.xyz.
 * @dev    This smart contract is meant to be inherited by token contracts so they can use the following:
 *         - `onlyAllowedOperator` modifier for `transferFrom` and `safeTransferFrom` methods.
 *         - `onlyAllowedOperatorApproval` modifier for `approve` and `setApprovalForAll` methods.
 */
abstract contract MarketplaceFilterer is OwnableUpgradeable {
    error NotAContract();

    error OperatorNotAllowed(address operator);

    /**
     * @notice MarketplaceFilterer Registry (CORI)
     */
    address public constant MARKETPLACE_FILTERER_REGISTRY = address(0x000000000000AAeB6D7670E522A718067333cd4E);

    /**
     * @notice Default subscription to register collection with on CORI Marketplace filterer registry
     */
    address public constant DEFAULT_SUBSCRIPTION = address(0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6);

    /**
     * @notice CORI Marketplace filterer registry. Set to address(0) when not used to avoid extra inter-contract calls.
     */
    address public operatorFiltererRegistry;

    /**
     * @notice Update the address that the contract will make MarketplaceFilterer checks against.
     *         Also register this contract with that registry.
     */
    function setMarketplaceFiltererRegistryAndRegisterDefaultSubscription() public onlyOwner {
        _setMarketplaceFiltererRegistryAndRegisterDefaultSubscription(MARKETPLACE_FILTERER_REGISTRY);
    }

    /**
     * @notice Update the address that the contract will make MarketplaceFilterer checks against.
     *         Also register this contract with that registry.
     */
    function setCustomMarketplaceFiltererRegistryAndRegisterDefaultSubscription(address newRegistry) public onlyOwner {
        if (newRegistry.code.length == 0) {
            _revert(NotAContract.selector);
        }
        _setMarketplaceFiltererRegistryAndRegisterDefaultSubscription(newRegistry);
    }

    /**
     * @notice Remove the address that the contract will make MarketplaceFilterer checks against.
     *         Also unregister this contract from that registry.
     */
    function removeMarketplaceFiltererRegistryAndUnregister() public onlyOwner {
        if (operatorFiltererRegistry.code.length > 0) {
            IOperatorFilterRegistry(operatorFiltererRegistry).unregister(address(this));
        }
        operatorFiltererRegistry = address(0);
    }

    function __MarketplaceFilterer__init__(bool useFilterer) internal onlyInitializing {
        // If an inheriting token contract is deployed to a network without the registry deployed, the modifier
        // will not revert, but the contract will need to be registered with the registry once it is deployed in
        // order for the modifier to filter addresses.
        if (useFilterer) {
            _setMarketplaceFiltererRegistryAndRegisterDefaultSubscription(MARKETPLACE_FILTERER_REGISTRY);
        }
    }

    function _setMarketplaceFiltererRegistryAndRegisterDefaultSubscription(address newRegistry) private {
        operatorFiltererRegistry = newRegistry;
        if (newRegistry.code.length > 0) {
            IOperatorFilterRegistry(newRegistry).registerAndSubscribe(address(this), DEFAULT_SUBSCRIPTION);
        }
    }

    modifier onlyAllowedOperator(address from) virtual {
        // Allow spending tokens from addresses with balance
        // Note that this still allows listings and marketplaces with escrow to transfer tokens if transferred
        // from an EOA.
        if (from != _msgSender()) {
            _checkFilterOperator(_msgSender());
        }
        _;
    }

    modifier onlyAllowedOperatorApproval(address operator) virtual {
        _checkFilterOperator(operator);
        _;
    }

    function _checkFilterOperator(address operator) internal view virtual {
        // Check registry code length to facilitate testing in environments without a deployed registry.
        if (operatorFiltererRegistry != address(0)) {
            if (!IOperatorFilterRegistry(operatorFiltererRegistry).isOperatorAllowed(address(this), operator)) {
                revert OperatorNotAllowed(operator);
            }
        }
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure virtual {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { IOperatorFilterRegistry } from "./interfaces/IOperatorFilterRegistry.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title  MarketplaceFiltererAbridged
 * @notice Abstract contract whose constructor automatically registers and subscribes to default
           subscription from OpenSea, if a valid registry is passed in. 
           Modified from `OperatorFilterer` contract by ishan@ highlight.xyz.
 * @dev    This smart contract is meant to be inherited by token contracts so they can use the following:
 *         - `onlyAllowedOperator` modifier for `transferFrom` and `safeTransferFrom` methods.
 *         - `onlyAllowedOperatorApproval` modifier for `approve` and `setApprovalForAll` methods.
 */
abstract contract MarketplaceFiltererAbridged is OwnableUpgradeable {
    error NotAContract();

    error OperatorNotAllowed();

    /**
     * @notice MarketplaceFilterer Registry (CORI)
     */
    address private constant _MARKETPLACE_FILTERER_REGISTRY = address(0x000000000000AAeB6D7670E522A718067333cd4E);

    /**
     * @notice Default subscription to register collection with on CORI Marketplace filterer registry
     */
    address private constant _DEFAULT_SUBSCRIPTION = address(0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6);

    /**
     * @notice CORI Marketplace filterer registry. Set to address(0) when not used to avoid extra inter-contract calls.
     */
    address public operatorFiltererRegistry;

    function __MarketplaceFilterer__init__(bool useFilterer) internal onlyInitializing {
        // If an inheriting token contract is deployed to a network without the registry deployed, the modifier
        // will not revert, but the contract will need to be registered with the registry once it is deployed in
        // order for the modifier to filter addresses.
        if (useFilterer) {
            _setRegistryAndSubscription(_MARKETPLACE_FILTERER_REGISTRY, _DEFAULT_SUBSCRIPTION);
        }
    }

    /**
     * @notice Update the address that the contract will make MarketplaceFilterer checks against.
     *         Also register this contract with that registry.
     */
    function setRegistryAndSubscription(address newRegistry, address subscription) external onlyOwner {
        _setRegistryAndSubscription(newRegistry, subscription);
    }

    modifier onlyAllowedOperatorApproval(address operator) {
        _checkFilterOperator(operator);
        _;
    }

    function _checkFilterOperator(address operator) internal view {
        // Check registry code length to facilitate testing in environments without a deployed registry.
        if (operatorFiltererRegistry != address(0)) {
            if (!IOperatorFilterRegistry(operatorFiltererRegistry).isOperatorAllowed(address(this), operator)) {
                _revert(OperatorNotAllowed.selector);
            }
        }
    }

    function _setRegistryAndSubscription(address newRegistry, address subscription) private {
        operatorFiltererRegistry = newRegistry;
        if (newRegistry != address(0)) {
            if (newRegistry.code.length == 0) {
                _revert(NotAContract.selector);
            }
            IOperatorFilterRegistry(newRegistry).registerAndSubscribe(address(this), subscription);
        }
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure virtual {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IOperatorFilterRegistry {
    function isOperatorAllowed(address registrant, address operator) external view returns (bool);

    function register(address registrant) external;

    function registerAndSubscribe(address registrant, address subscription) external;

    function registerAndCopyEntries(address registrant, address registrantToCopy) external;

    function unregister(address addr) external;

    function updateOperator(address registrant, address operator, bool filtered) external;

    function updateOperators(address registrant, address[] calldata operators, bool filtered) external;

    function updateCodeHash(address registrant, bytes32 codehash, bool filtered) external;

    function updateCodeHashes(address registrant, bytes32[] calldata codeHashes, bool filtered) external;

    function subscribe(address registrant, address registrantToSubscribe) external;

    function unsubscribe(address registrant, bool copyExistingEntries) external;

    function subscriptionOf(address addr) external returns (address registrant);

    function subscribers(address registrant) external returns (address[] memory);

    function subscriberAt(address registrant, uint256 index) external returns (address);

    function copyEntriesOf(address registrant, address registrantToCopy) external;

    function isOperatorFiltered(address registrant, address operator) external returns (bool);

    function isCodeHashOfFiltered(address registrant, address operatorWithCode) external returns (bool);

    function isCodeHashFiltered(address registrant, bytes32 codeHash) external returns (bool);

    function filteredOperators(address addr) external returns (address[] memory);

    function filteredCodeHashes(address addr) external returns (bytes32[] memory);

    function filteredOperatorAt(address registrant, uint256 index) external returns (address);

    function filteredCodeHashAt(address registrant, uint256 index) external returns (bytes32);

    function isRegistered(address addr) external returns (bool);

    function codeHashOf(address addr) external returns (bytes32);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/* solhint-disable */

library ERC721AStorage {
    // Bypass for a `--via-ir` bug (https://github.com/chiru-labs/ERC721A/pull/364).
    struct TokenApprovalRef {
        address value;
    }

    struct Layout {
        // =============================================================
        //                            STORAGE
        // =============================================================

        // The next token ID to be minted.
        uint256 _currentIndex;
        // The number of tokens burned.
        uint256 _burnCounter;
        // Token name
        string _name;
        // Token symbol
        string _symbol;
        // Mapping from token ID to ownership details
        // An empty struct value does not necessarily mean the token is unowned.
        // See {_packedOwnershipOf} implementation for details.
        //
        // Bits Layout:
        // - [0..159]   `addr`
        // - [160..223] `startTimestamp`
        // - [224]      `burned`
        // - [225]      `nextInitialized`
        // - [232..255] `extraData`
        mapping(uint256 => uint256) _packedOwnerships;
        // Mapping owner address to address data.
        //
        // Bits Layout:
        // - [0..63]    `balance`
        // - [64..127]  `numberMinted`
        // - [128..191] `numberBurned`
        // - [192..255] `aux`
        mapping(address => uint256) _packedAddressData;
        // Mapping from token ID to approved address.
        mapping(uint256 => ERC721AStorage.TokenApprovalRef) _tokenApprovals;
        // Mapping from owner to operator approvals
        mapping(address => mapping(address => bool)) _operatorApprovals;
    }

    bytes32 internal constant STORAGE_SLOT = keccak256("ERC721A.contracts.storage.ERC721A");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity 0.8.10;

import "./ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

/**
 * @title Appending URI storage utilities onto template ERC721A contract
 * @author highlight.xyz, OpenZeppelin
 * @dev ERC721 token with storage based token URI management. OpenZeppelin template edited by Highlight
 */
/* solhint-disable */
abstract contract ERC721AURIStorageUpgradeable is Initializable, ERC721AUpgradeable {
    /**
     * @notice Throw when token doesn't exist
     */
    error TokenDoesNotExist();

    function __ERC721URIStorage_init() internal onlyInitializing {}

    function __ERC721URIStorage_init_unchained() internal onlyInitializing {}

    using StringsUpgradeable for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) internal _tokenURIs;

    /**
     * @dev Hashed rotation key data
     */
    bytes internal _hashedRotationKeyData;

    /**
     * @dev Hashed base uri data
     */
    bytes internal _hashedBaseURIData;

    /**
     * @dev Rotation key
     */
    uint256 internal _rotationKey;

    /**
     * @dev Contract baseURI
     */
    string public baseURI;

    /**
     * @notice Emitted when base uri is set
     * @param oldBaseUri Old base uri
     * @param newBaseURI New base uri
     */
    event BaseURISet(string oldBaseUri, string newBaseURI);

    /**
     * @dev Set contract baseURI
     */
    function _setBaseURI(string memory newBaseURI) internal {
        emit BaseURISet(baseURI, newBaseURI);

        baseURI = newBaseURI;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            _revert(TokenDoesNotExist.selector);
        }

        string memory _tokenURI = _tokenURIs[tokenId];

        // If there is no token URI, return the base URI.
        if (bytes(_tokenURI).length == 0) {
            return super.tokenURI(tokenId);
        }

        return _tokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity 0.8.10;

import "./IERC721AUpgradeable.sol";
import { ERC721AStorage } from "./ERC721AStorage.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

/* solhint-disable */

/**
 * @dev Interface of ERC721 token receiver.
 */
interface ERC721A__IERC721ReceiverUpgradeable {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @title ERC721A
 * @author Chiru Labs, modified by ishan@highlight.xyz
 *
 * @dev Implementation of the [ERC721](https://eips.ethereum.org/EIPS/eip-721)
 * Non-Fungible Token Standard, including the Metadata extension.
 * Optimized for lower gas during batch mints.
 *
 * Token IDs are minted in sequential order (e.g. 0, 1, 2, 3, ...)
 * starting from `_startTokenId()`.
 *
 * Assumptions:
 *
 * - An owner cannot have more than 2**64 - 1 (max value of uint64) of supply.
 * - The maximum token ID cannot exceed 2**256 - 1 (max value of uint256).
 */
contract ERC721AUpgradeable is Initializable, IERC721AUpgradeable, ContextUpgradeable {
    using ERC721AStorage for ERC721AStorage.Layout;

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    // Mask of an entry in packed address data.
    uint256 private constant _BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;

    // The bit position of `numberMinted` in packed address data.
    uint256 private constant _BITPOS_NUMBER_MINTED = 64;

    // The bit position of `numberBurned` in packed address data.
    uint256 private constant _BITPOS_NUMBER_BURNED = 128;

    // The bit position of `aux` in packed address data.
    uint256 private constant _BITPOS_AUX = 192;

    // Mask of all 256 bits in packed address data except the 64 bits for `aux`.
    uint256 private constant _BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;

    // The bit position of `startTimestamp` in packed ownership.
    uint256 private constant _BITPOS_START_TIMESTAMP = 160;

    // The bit mask of the `burned` bit in packed ownership.
    uint256 private constant _BITMASK_BURNED = 1 << 224;

    // The bit position of the `nextInitialized` bit in packed ownership.
    uint256 private constant _BITPOS_NEXT_INITIALIZED = 225;

    // The bit mask of the `nextInitialized` bit in packed ownership.
    uint256 private constant _BITMASK_NEXT_INITIALIZED = 1 << 225;

    // The bit position of `extraData` in packed ownership.
    uint256 private constant _BITPOS_EXTRA_DATA = 232;

    // Mask of all 256 bits in a packed ownership except the 24 bits for `extraData`.
    uint256 private constant _BITMASK_EXTRA_DATA_COMPLEMENT = (1 << 232) - 1;

    // The mask of the lower 160 bits for addresses.
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;

    // The maximum `quantity` that can be minted with {_mintERC2309}.
    // This limit is to prevent overflows on the address data entries.
    // For a limit of 5000, a total of 3.689e15 calls to {_mintERC2309}
    // is required to cause an overflow, which is unrealistic.
    uint256 private constant _MAX_MINT_ERC2309_QUANTITY_LIMIT = 5000;

    // The `Transfer` event signature is given by:
    // `keccak256(bytes("Transfer(address,address,uint256)"))`.
    bytes32 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    function __ERC721A_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721A_init_unchained(name_, symbol_);
    }

    function __ERC721A_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        ERC721AStorage.layout()._name = name_;
        ERC721AStorage.layout()._symbol = symbol_;
        ERC721AStorage.layout()._currentIndex = _startTokenId();
    }

    // =============================================================
    //                   TOKEN COUNTING OPERATIONS
    // =============================================================

    /**
     * @dev Returns the starting token ID.
     * To change the starting token ID, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 1;
    }

    /**
     * @dev Returns the next token ID to be minted.
     */
    function _nextTokenId() internal view virtual returns (uint256) {
        return ERC721AStorage.layout()._currentIndex;
    }

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than `_currentIndex - _startTokenId()` times.
        unchecked {
            return ERC721AStorage.layout()._currentIndex - ERC721AStorage.layout()._burnCounter - _startTokenId();
        }
    }

    /**
     * @dev Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view virtual returns (uint256) {
        // Counter underflow is impossible as `_currentIndex` does not decrement,
        // and it is initialized to `_startTokenId()`.
        unchecked {
            return ERC721AStorage.layout()._currentIndex - _startTokenId();
        }
    }

    /**
     * @dev Returns the total number of tokens burned.
     */
    function _totalBurned() internal view virtual returns (uint256) {
        return ERC721AStorage.layout()._burnCounter;
    }

    // =============================================================
    //                    ADDRESS DATA OPERATIONS
    // =============================================================

    /**
     * @dev Returns the number of tokens in `owner`'s account.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) _revert(BalanceQueryForZeroAddress.selector);
        return ERC721AStorage.layout()._packedAddressData[owner] & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return
            (ERC721AStorage.layout()._packedAddressData[owner] >> _BITPOS_NUMBER_MINTED) & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return
            (ERC721AStorage.layout()._packedAddressData[owner] >> _BITPOS_NUMBER_BURNED) & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the auxiliary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint64) {
        return uint64(ERC721AStorage.layout()._packedAddressData[owner] >> _BITPOS_AUX);
    }

    /**
     * Sets the auxiliary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint64 aux) internal virtual {
        uint256 packed = ERC721AStorage.layout()._packedAddressData[owner];
        uint256 auxCasted;
        // Cast `aux` with assembly to avoid redundant masking.
        assembly {
            auxCasted := aux
        }
        packed = (packed & _BITMASK_AUX_COMPLEMENT) | (auxCasted << _BITPOS_AUX);
        ERC721AStorage.layout()._packedAddressData[owner] = packed;
    }

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        // The interface IDs are constants representing the first 4 bytes
        // of the XOR of all function selectors in the interface.
        // See: [ERC165](https://eips.ethereum.org/EIPS/eip-165)
        // (e.g. `bytes4(i.functionA.selector ^ i.functionB.selector ^ ...)`)
        return
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
            interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
    }

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() public view virtual override returns (string memory) {
        return ERC721AStorage.layout()._name;
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() public view virtual override returns (string memory) {
        return ERC721AStorage.layout()._symbol;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) _revert(URIQueryForNonexistentToken.selector);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, "/", _toString(tokenId))) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, it can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    // =============================================================
    //                     OWNERSHIPS OPERATIONS
    // =============================================================

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }

    /**
     * @dev Added by Highlight to facilitate updating of name and symbol
     */
    function _setContractMetadata(string calldata newName, string calldata newSymbol) internal {
        ERC721AStorage.layout()._name = newName;
        ERC721AStorage.layout()._symbol = newSymbol;
    }

    /**
     * @dev Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around over time.
     */
    function _ownershipOf(uint256 tokenId) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnershipOf(tokenId));
    }

    /**
     * @dev Returns the unpacked `TokenOwnership` struct at `index`.
     */
    function _ownershipAt(uint256 index) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(ERC721AStorage.layout()._packedOwnerships[index]);
    }

    /**
     * @dev Returns whether the ownership slot at `index` is initialized.
     * An uninitialized slot does not necessarily mean that the slot has no owner.
     */
    function _ownershipIsInitialized(uint256 index) internal view virtual returns (bool) {
        return ERC721AStorage.layout()._packedOwnerships[index] != 0;
    }

    /**
     * @dev Initializes the ownership slot minted at `index` for efficiency purposes.
     */
    function _initializeOwnershipAt(uint256 index) internal virtual {
        if (ERC721AStorage.layout()._packedOwnerships[index] == 0) {
            ERC721AStorage.layout()._packedOwnerships[index] = _packedOwnershipOf(index);
        }
    }

    /**
     * Returns the packed ownership data of `tokenId`.
     */
    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256 packed) {
        if (_startTokenId() <= tokenId) {
            packed = ERC721AStorage.layout()._packedOwnerships[tokenId];
            // If the data at the starting slot does not exist, start the scan.
            if (packed == 0) {
                if (tokenId >= ERC721AStorage.layout()._currentIndex) _revert(OwnerQueryForNonexistentToken.selector);
                // Invariant:
                // There will always be an initialized ownership slot
                // (i.e. `ownership.addr != address(0) && ownership.burned == false`)
                // before an unintialized ownership slot
                // (i.e. `ownership.addr == address(0) && ownership.burned == false`)
                // Hence, `tokenId` will not underflow.
                //
                // We can directly compare the packed value.
                // If the address is zero, packed will be zero.
                for (;;) {
                    unchecked {
                        packed = ERC721AStorage.layout()._packedOwnerships[--tokenId];
                    }
                    if (packed == 0) continue;
                    if (packed & _BITMASK_BURNED == 0) return packed;
                    // Otherwise, the token is burned, and we must revert.
                    // This handles the case of batch burned tokens, where only the burned bit
                    // of the starting slot is set, and remaining slots are left uninitialized.
                    _revert(OwnerQueryForNonexistentToken.selector);
                }
            }
            // Otherwise, the data exists and we can skip the scan.
            // This is possible because we have already achieved the target condition.
            // This saves 2143 gas on transfers of initialized tokens.
            // If the token is not burned, return `packed`. Otherwise, revert.
            if (packed & _BITMASK_BURNED == 0) return packed;
        }
        _revert(OwnerQueryForNonexistentToken.selector);
    }

    /**
     * @dev Returns the unpacked `TokenOwnership` struct from `packed`.
     */
    function _unpackedOwnership(uint256 packed) private pure returns (TokenOwnership memory ownership) {
        ownership.addr = address(uint160(packed));
        ownership.startTimestamp = uint64(packed >> _BITPOS_START_TIMESTAMP);
        ownership.burned = packed & _BITMASK_BURNED != 0;
        ownership.extraData = uint24(packed >> _BITPOS_EXTRA_DATA);
    }

    /**
     * @dev Packs ownership data into a single uint256.
     */
    function _packOwnershipData(address owner, uint256 flags) private view returns (uint256 result) {
        assembly {
            // Mask `owner` to the lower 160 bits, in case the upper bits somehow aren't clean.
            owner := and(owner, _BITMASK_ADDRESS)
            // `owner | (block.timestamp << _BITPOS_START_TIMESTAMP) | flags`.
            result := or(owner, or(shl(_BITPOS_START_TIMESTAMP, timestamp()), flags))
        }
    }

    /**
     * @dev Returns the `nextInitialized` flag set if `quantity` equals 1.
     */
    function _nextInitializedFlag(uint256 quantity) private pure returns (uint256 result) {
        // For branchless setting of the `nextInitialized` flag.
        assembly {
            // `(quantity == 1) << _BITPOS_NEXT_INITIALIZED`.
            result := shl(_BITPOS_NEXT_INITIALIZED, eq(quantity, 1))
        }
    }

    // =============================================================
    //                      APPROVAL OPERATIONS
    // =============================================================

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account. See {ERC721A-_approve}.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     */
    function approve(address to, uint256 tokenId) public payable virtual override {
        _approve(to, tokenId, true);
    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        if (!_exists(tokenId)) _revert(ApprovalQueryForNonexistentToken.selector);

        return ERC721AStorage.layout()._tokenApprovals[tokenId].value;
    }

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        ERC721AStorage.layout()._operatorApprovals[_msgSenderERC721A()][operator] = approved;
        emit ApprovalForAll(_msgSenderERC721A(), operator, approved);
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return ERC721AStorage.layout()._operatorApprovals[owner][operator];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted. See {_mint}.
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool result) {
        if (_startTokenId() <= tokenId) {
            if (tokenId < ERC721AStorage.layout()._currentIndex) {
                uint256 packed;
                while ((packed = ERC721AStorage.layout()._packedOwnerships[tokenId]) == 0) --tokenId;
                result = packed & _BITMASK_BURNED == 0;
            }
        }
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ownerOf(tokenId);
        return (isApprovedForAll(owner, spender) || _isSenderApprovedOrOwner(getApproved(tokenId), owner, spender));
    }

    /**
     * @dev Returns whether `msgSender` is equal to `approvedAddress` or `owner`.
     */
    function _isSenderApprovedOrOwner(
        address approvedAddress,
        address owner,
        address msgSender
    ) private pure returns (bool result) {
        assembly {
            // Mask `owner` to the lower 160 bits, in case the upper bits somehow aren't clean.
            owner := and(owner, _BITMASK_ADDRESS)
            // Mask `msgSender` to the lower 160 bits, in case the upper bits somehow aren't clean.
            msgSender := and(msgSender, _BITMASK_ADDRESS)
            // `msgSender == owner || msgSender == approvedAddress`.
            result := or(eq(msgSender, owner), eq(msgSender, approvedAddress))
        }
    }

    /**
     * @dev Returns the storage slot and value for the approved address of `tokenId`.
     */
    function _getApprovedSlotAndAddress(
        uint256 tokenId
    ) private view returns (uint256 approvedAddressSlot, address approvedAddress) {
        ERC721AStorage.TokenApprovalRef storage tokenApproval = ERC721AStorage.layout()._tokenApprovals[tokenId];
        // The following is equivalent to `approvedAddress = _tokenApprovals[tokenId].value`.
        assembly {
            approvedAddressSlot := tokenApproval.slot
            approvedAddress := sload(approvedAddressSlot)
        }
    }

    // =============================================================
    //                      TRANSFER OPERATIONS
    // =============================================================

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) public payable virtual override {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        // Mask `from` to the lower 160 bits, in case the upper bits somehow aren't clean.
        from = address(uint160(uint256(uint160(from)) & _BITMASK_ADDRESS));

        if (address(uint160(prevOwnershipPacked)) != from) _revert(TransferFromIncorrectOwner.selector);

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        // The nested ifs save around 20+ gas over a compound boolean condition.
        if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A()))
            if (!isApprovedForAll(from, _msgSenderERC721A())) _revert(TransferCallerNotOwnerNorApproved.selector);

        // Clear approvals from the previous owner.
        assembly {
            if approvedAddress {
                // This is equivalent to `delete _tokenApprovals[tokenId]`.
                sstore(approvedAddressSlot, 0)
            }
        }

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as `tokenId` would have to be 2**256.
        unchecked {
            // We can directly increment and decrement the balances.
            --ERC721AStorage.layout()._packedAddressData[from]; // Updates: `balance -= 1`.
            ++ERC721AStorage.layout()._packedAddressData[to]; // Updates: `balance += 1`.

            // Updates:
            // - `address` to the next owner.
            // - `startTimestamp` to the timestamp of transfering.
            // - `burned` to `false`.
            // - `nextInitialized` to `true`.
            ERC721AStorage.layout()._packedOwnerships[tokenId] = _packOwnershipData(
                to,
                _BITMASK_NEXT_INITIALIZED | _nextExtraData(from, to, prevOwnershipPacked)
            );

            // If the next slot may not have been initialized (i.e. `nextInitialized == false`) .
            if (prevOwnershipPacked & _BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                // If the next slot's address is zero and not burned (i.e. packed value is zero).
                if (ERC721AStorage.layout()._packedOwnerships[nextTokenId] == 0) {
                    // If the next slot is within bounds.
                    if (nextTokenId != ERC721AStorage.layout()._currentIndex) {
                        // Initialize the next slot to maintain correctness for `ownerOf(tokenId + 1)`.
                        ERC721AStorage.layout()._packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
        uint256 toMasked = uint256(uint160(to)) & _BITMASK_ADDRESS;
        assembly {
            // Emit the `Transfer` event.
            log4(
                0, // Start of data (0, since no data).
                0, // End of data (0, since no data).
                _TRANSFER_EVENT_SIGNATURE, // Signature.
                from, // `from`.
                toMasked, // `to`.
                tokenId // `tokenId`.
            )
        }
        if (toMasked == 0) _revert(TransferToZeroAddress.selector);

        _afterTokenTransfers(from, to, tokenId);
    }

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public payable virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable virtual override {
        transferFrom(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                _revert(TransferToNonERC721ReceiverImplementer.selector);
            }
    }

    /**
     * @dev Hook that is called after a set of serially-ordered token IDs
     * have been transferred. This includes minting.
     * And also called after one token has been burned.
     *
     * `startTokenId` - the first token ID to be transferred.
     * `quantity` - the amount to be transferred.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(address from, address to, uint256 startTokenId) internal virtual {}

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * `from` - Previous owner of the given token ID.
     * `to` - Target address that will receive the token.
     * `tokenId` - Token ID to be transferred.
     * `_data` - Optional data to send along with the call.
     *
     * Returns whether the call correctly returned the expected magic value.
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try
            ERC721A__IERC721ReceiverUpgradeable(to).onERC721Received(_msgSenderERC721A(), from, tokenId, _data)
        returns (bytes4 retval) {
            return retval == ERC721A__IERC721ReceiverUpgradeable(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                _revert(TransferToNonERC721ReceiverImplementer.selector);
            }
            assembly {
                revert(add(32, reason), mload(reason))
            }
        }
    }

    // =============================================================
    //                        MINT OPERATIONS
    // =============================================================

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event for each mint.
     */
    function _mint(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = ERC721AStorage.layout()._currentIndex;
        if (quantity == 0) _revert(MintZeroQuantity.selector);

        // Overflows are incredibly unrealistic.
        // `balance` and `numberMinted` have a maximum limit of 2**64.
        // `tokenId` has a maximum limit of 2**256.
        unchecked {
            // Updates:
            // - `address` to the owner.
            // - `startTimestamp` to the timestamp of minting.
            // - `burned` to `false`.
            // - `nextInitialized` to `quantity == 1`.
            ERC721AStorage.layout()._packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

            // Updates:
            // - `balance += quantity`.
            // - `numberMinted += quantity`.
            //
            // We can directly add to the `balance` and `numberMinted`.
            ERC721AStorage.layout()._packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

            // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
            uint256 toMasked = uint256(uint160(to)) & _BITMASK_ADDRESS;

            if (toMasked == 0) _revert(MintToZeroAddress.selector);

            uint256 end = startTokenId + quantity;
            uint256 tokenId = startTokenId;

            do {
                assembly {
                    // Emit the `Transfer` event.
                    log4(
                        0, // Start of data (0, since no data).
                        0, // End of data (0, since no data).
                        _TRANSFER_EVENT_SIGNATURE, // Signature.
                        0, // `address(0)`.
                        toMasked, // `to`.
                        tokenId // `tokenId`.
                    )
                }
                // The `!=` check ensures that large values of `quantity`
                // that overflows uint256 will make the loop run out of gas.
            } while (++tokenId != end);

            ERC721AStorage.layout()._currentIndex = end;
        }
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * See {_mint}.
     *
     * Emits a {Transfer} event for each mint.
     */
    function _safeMint(address to, uint256 quantity, bytes memory _data) internal virtual {
        _mint(to, quantity);

        unchecked {
            if (to.code.length != 0) {
                uint256 end = ERC721AStorage.layout()._currentIndex;
                uint256 index = end - quantity;
                do {
                    if (!_checkContractOnERC721Received(address(0), to, index++, _data)) {
                        _revert(TransferToNonERC721ReceiverImplementer.selector);
                    }
                } while (index < end);
                // Reentrancy protection.
                if (ERC721AStorage.layout()._currentIndex != end) _revert(bytes4(0));
            }
        }
    }

    /**
     * @dev Equivalent to `_safeMint(to, quantity, '')`.
     */
    function _safeMint(address to, uint256 quantity) internal virtual {
        _safeMint(to, quantity, "");
    }

    // =============================================================
    //                       APPROVAL OPERATIONS
    // =============================================================

    /**
     * @dev Equivalent to `_approve(to, tokenId, false)`.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _approve(to, tokenId, false);
    }

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId, bool approvalCheck) internal virtual {
        address owner = ownerOf(tokenId);

        if (approvalCheck && _msgSenderERC721A() != owner)
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                _revert(ApprovalCallerNotOwnerNorApproved.selector);
            }

        ERC721AStorage.layout()._tokenApprovals[tokenId].value = to;
        emit Approval(owner, to, tokenId);
    }

    // =============================================================
    //                        BURN OPERATIONS
    // =============================================================

    /**
     * @dev Equivalent to `_burn(tokenId, false)`.
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        address from = address(uint160(prevOwnershipPacked));

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        if (approvalCheck) {
            // The nested ifs save around 20+ gas over a compound boolean condition.
            if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A()))
                if (!isApprovedForAll(from, _msgSenderERC721A())) _revert(TransferCallerNotOwnerNorApproved.selector);
        }

        // Clear approvals from the previous owner.
        assembly {
            if approvedAddress {
                // This is equivalent to `delete _tokenApprovals[tokenId]`.
                sstore(approvedAddressSlot, 0)
            }
        }

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as `tokenId` would have to be 2**256.
        unchecked {
            // Updates:
            // - `balance -= 1`.
            // - `numberBurned += 1`.
            //
            // We can directly decrement the balance, and increment the number burned.
            // This is equivalent to `packed -= 1; packed += 1 << _BITPOS_NUMBER_BURNED;`.
            ERC721AStorage.layout()._packedAddressData[from] += (1 << _BITPOS_NUMBER_BURNED) - 1;

            // Updates:
            // - `address` to the last owner.
            // - `startTimestamp` to the timestamp of burning.
            // - `burned` to `true`.
            // - `nextInitialized` to `true`.
            ERC721AStorage.layout()._packedOwnerships[tokenId] = _packOwnershipData(
                from,
                (_BITMASK_BURNED | _BITMASK_NEXT_INITIALIZED) | _nextExtraData(from, address(0), prevOwnershipPacked)
            );

            // If the next slot may not have been initialized (i.e. `nextInitialized == false`) .
            if (prevOwnershipPacked & _BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                // If the next slot's address is zero and not burned (i.e. packed value is zero).
                if (ERC721AStorage.layout()._packedOwnerships[nextTokenId] == 0) {
                    // If the next slot is within bounds.
                    if (nextTokenId != ERC721AStorage.layout()._currentIndex) {
                        // Initialize the next slot to maintain correctness for `ownerOf(tokenId + 1)`.
                        ERC721AStorage.layout()._packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, address(0), tokenId);

        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
        unchecked {
            ERC721AStorage.layout()._burnCounter++;
        }
    }

    // =============================================================
    //                     EXTRA DATA OPERATIONS
    // =============================================================

    /**
     * @dev Directly sets the extra data for the ownership data `index`.
     */
    function _setExtraDataAt(uint256 index, uint24 extraData) internal virtual {
        uint256 packed = ERC721AStorage.layout()._packedOwnerships[index];
        if (packed == 0) _revert(OwnershipNotInitializedForExtraData.selector);
        uint256 extraDataCasted;
        // Cast `extraData` with assembly to avoid redundant masking.
        assembly {
            extraDataCasted := extraData
        }
        packed = (packed & _BITMASK_EXTRA_DATA_COMPLEMENT) | (extraDataCasted << _BITPOS_EXTRA_DATA);
        ERC721AStorage.layout()._packedOwnerships[index] = packed;
    }

    /**
     * @dev Called during each token transfer to set the 24bit `extraData` field.
     * Intended to be overridden by the cosumer contract.
     *
     * `previousExtraData` - the value of `extraData` before transfer.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _extraData(address from, address to, uint24 previousExtraData) internal view virtual returns (uint24) {}

    /**
     * @dev Returns the next extra data for the packed ownership data.
     * The returned result is shifted into position.
     */
    function _nextExtraData(address from, address to, uint256 prevOwnershipPacked) private view returns (uint256) {
        uint24 extraData = uint24(prevOwnershipPacked >> _BITPOS_EXTRA_DATA);
        return uint256(_extraData(from, to, extraData)) << _BITPOS_EXTRA_DATA;
    }

    // =============================================================
    //                       OTHER OPERATIONS
    // =============================================================

    /**
     * @dev Returns the message sender (defaults to `msg.sender`).
     *
     * If you are writing GSN compatible contracts, you need to override this function.
     */
    function _msgSenderERC721A() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Converts a uint256 to its ASCII string decimal representation.
     */
    function _toString(uint256 value) internal pure virtual returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
            let m := add(mload(0x40), 0xa0)
            // Update the free memory pointer to allocate.
            mstore(0x40, m)
            // Assign the `str` to the end.
            str := sub(m, 0x20)
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure virtual {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity 0.8.10;

/* solhint-disable */

/**
 * @dev Interface of ERC721A.
 */
interface IERC721AUpgradeable {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the
     * ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    /**
     * The `quantity` minted with ERC2309 exceeds the safety limit.
     */
    error MintERC2309QuantityExceedsLimit();

    /**
     * The `extraData` cannot be set on an unintialized ownership slot.
     */
    error OwnershipNotInitializedForExtraData();

    // =============================================================
    //                            STRUCTS
    // =============================================================

    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Stores the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
        // Arbitrary data similar to `startTimestamp` that can be set via {_extraData}.
        uint24 extraData;
    }

    // =============================================================
    //                         TOKEN COUNTERS
    // =============================================================

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function totalSupply() external view returns (uint256);

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // =============================================================
    //                            IERC721
    // =============================================================

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables
     * (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in `owner`'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`,
     * checking first that contract recipients are aware of the ERC721 protocol
     * to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move
     * this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external payable;

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external payable;

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom}
     * whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external payable;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external payable;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @notice Highlight's custom renderer interface for collections
 */
interface IHLRenderer {
    /**
     * @notice Process a mint to multiple recipients (likely store mint details)
     * @dev Implementations should assume msg.sender to be the NFT contract
     * @param firstTokenId ID of first token to be minted (next ones are minted sequentially)
     * @param numTokensPerRecipient Number of tokens minted to each recipient
     * @param orderedRecipients Recipients to mint tokens to, sequentially
     */
    function processMultipleRecipientMint(
        uint256 firstTokenId,
        uint256 numTokensPerRecipient,
        address[] calldata orderedRecipients
    ) external;

    /**
     * @notice Process a mint to one recipient (likely store mint details)
     * @dev Implementations should assume msg.sender to be the NFT contract
     * @param firstTokenId ID of first token to be minted (next ones are minted sequentially)
     * @param numTokens Number of tokens minted
     * @param recipient Recipient to mint to
     */
    function processOneRecipientMint(uint256 firstTokenId, uint256 numTokens, address recipient) external;

    /**
     * @notice Return token metadata for a token
     * @dev Implementations should assume msg.sender to be the NFT contract
     * @param tokenId ID of token to return metadata for
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @notice Mint interface on editions contracts
 * @author highlight.xyz
 */
interface IERC721EditionMint {
    /**
     * @notice Mints one NFT to one recipient
     * @param editionId Edition to mint the NFT on
     * @param recipient Recipient of minted NFT
     */
    function mintOneToRecipient(uint256 editionId, address recipient) external returns (uint256);

    /**
     * @notice Mints an amount of NFTs to one recipient
     * @param editionId Edition to mint the NFTs on
     * @param recipient Recipient of minted NFTs
     * @param amount Amount of NFTs minted
     */
    function mintAmountToRecipient(uint256 editionId, address recipient, uint256 amount) external returns (uint256);

    /**
     * @notice Mints one NFT each to a number of recipients
     * @param editionId Edition to mint the NFTs on
     * @param recipients Recipients of minted NFTs
     */
    function mintOneToRecipients(uint256 editionId, address[] memory recipients) external returns (uint256);

    /**
     * @notice Mints an amount of NFTs each to a number of recipients
     * @param editionId Edition to mint the NFTs on
     * @param recipients Recipients of minted NFTs
     * @param amount Amount of NFTs minted per recipient
     */
    function mintAmountToRecipients(
        uint256 editionId,
        address[] memory recipients,
        uint256 amount
    ) external returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../../royaltyManager/interfaces/IRoyaltyManager.sol";

/**
 * @notice Core creation interface
 * @author highlight.xyz
 */
interface IERC721EditionsDFS {
    /**
     * @notice Create an edition
     * @param _editionUri Edition uri (metadata)
     * @param _editionSize Edition size
     * @param _editionTokenManager Token manager for edition
     * @param editionRoyalty Edition's royalty
     */
    function createEdition(
        string memory _editionUri,
        uint256 _editionSize,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty,
        bytes calldata mintVectorData
    ) external returns (uint256);

    /**
     * @notice Get the first token minted for each edition passed in
     */
    function getEditionStartIds() external view returns (uint256[] memory);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @notice General721 mint interface
 * @author highlight.xyz
 */
interface IERC721GeneralMint {
    /**
     * @notice Mint one token to one recipient
     * @param recipient Recipient of minted NFT
     */
    function mintOneToOneRecipient(address recipient) external returns (uint256);

    /**
     * @notice Mint an amount of tokens to one recipient
     * @param recipient Recipient of minted NFTs
     * @param amount Amount of NFTs minted
     */
    function mintAmountToOneRecipient(address recipient, uint256 amount) external;

    /**
     * @notice Mint one token to multiple recipients. Useful for use-cases like airdrops
     * @param recipients Recipients of minted NFTs
     */
    function mintOneToMultipleRecipients(address[] calldata recipients) external;

    /**
     * @notice Mint the same amount of tokens to multiple recipients
     * @param recipients Recipients of minted NFTs
     * @param amount Amount of NFTs minted to each recipient
     */
    function mintSameAmountToMultipleRecipients(address[] calldata recipients, uint256 amount) external;

    /**
     * @notice Mint a chosen token id to a single recipient
     * @param recipient Recipient of chosen NFT
     * @param tokenId ID of NFT to mint
     */
    function mintSpecificTokenToOneRecipient(address recipient, uint256 tokenId) external;

    /**
     * @notice Mint chosen token ids to a single recipient
     * @param recipient Recipient of chosen NFT
     * @param tokenIds IDs of NFTs to mint
     */
    function mintSpecificTokensToOneRecipient(address recipient, uint256[] calldata tokenIds) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @notice General721 mint interface for sequentially minted collections
 * @author highlight.xyz
 */
interface IERC721GeneralSequenceMint {
    /**
     * @notice Mint one token to one recipient
     * @param recipient Recipient of minted NFT
     */
    function mintOneToOneRecipient(address recipient) external returns (uint256);

    /**
     * @notice Mint an amount of tokens to one recipient
     * @param recipient Recipient of minted NFTs
     * @param amount Amount of NFTs minted
     */
    function mintAmountToOneRecipient(address recipient, uint256 amount) external;

    /**
     * @notice Mint one token to multiple recipients. Useful for use-cases like airdrops
     * @param recipients Recipients of minted NFTs
     */
    function mintOneToMultipleRecipients(address[] calldata recipients) external;

    /**
     * @notice Mint the same amount of tokens to multiple recipients
     * @param recipients Recipients of minted NFTs
     * @param amount Amount of NFTs minted to each recipient
     */
    function mintSameAmountToMultipleRecipients(address[] calldata recipients, uint256 amount) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @notice Interfaces with the details of editions on collections
 * @author highlight.xyz
 */
interface IEditionCollection {
    /**
     * @notice Edition details
     * @param name Edition name
     * @param size Edition size
     * @param supply Total number of tokens minted on edition
     * @param initialTokenId Token id of first token minted in edition
     */
    struct EditionDetails {
        string name;
        uint256 size;
        uint256 supply;
        uint256 initialTokenId;
    }

    /**
     * @notice Get the edition a token belongs to
     * @param tokenId The token id of the token
     */
    function getEditionId(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Get an edition's details
     * @param editionId Edition id
     */
    function getEditionDetails(uint256 editionId) external view returns (EditionDetails memory);

    /**
     * @notice Get the details and uris of a number of editions
     * @param editionIds List of editions to get info for
     */
    function getEditionsDetailsAndUri(
        uint256[] calldata editionIds
    ) external view returns (EditionDetails[] memory, string[] memory uris);
}
//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @notice From MathCastles deployment
 */
library Bytecode {
    error InvalidCodeAtRange(uint256 _size, uint256 _start, uint256 _end);

    /**
    @notice Generate a creation code that results on a contract with `_code` as bytecode
    @param _code The returning value of the resulting `creationCode`
    @return creationCode (constructor) for new contract
  */
    function creationCodeFor(bytes memory _code) internal pure returns (bytes memory) {
        /*
      0x00    0x63         0x63XXXXXX  PUSH4 _code.length  size
      0x01    0x80         0x80        DUP1                size size
      0x02    0x60         0x600e      PUSH1 14            14 size size
      0x03    0x60         0x6000      PUSH1 00            0 14 size size
      0x04    0x39         0x39        CODECOPY            size
      0x05    0x60         0x6000      PUSH1 00            0 size
      0x06    0xf3         0xf3        RETURN
      <CODE>
    */

        return abi.encodePacked(hex"63", uint32(_code.length), hex"80_60_0E_60_00_39_60_00_F3", _code);
    }

    /**
    @notice Returns the size of the code on a given address
    @param _addr Address that may or may not contain code
    @return size of the code on the given `_addr`
  */
    function codeSize(address _addr) internal view returns (uint256 size) {
        assembly {
            size := extcodesize(_addr)
        }
    }

    /**
    @notice Returns the code of a given address
    @dev It will fail if `_end < _start`
    @param _addr Address that may or may not contain code
    @param _start number of bytes of code to skip on read
    @param _end index before which to end extraction
    @return oCode read from `_addr` deployed bytecode

    Forked from: https://gist.github.com/KardanovIR/fe98661df9338c842b4a30306d507fbd
  */
    function codeAt(address _addr, uint256 _start, uint256 _end) internal view returns (bytes memory oCode) {
        uint256 csize = codeSize(_addr);
        if (csize == 0) return bytes("");

        if (_start > csize) return bytes("");
        if (_end < _start) revert InvalidCodeAtRange(csize, _start, _end);

        unchecked {
            uint256 reqSize = _end - _start;
            uint256 maxSize = csize - _start;

            uint256 size = maxSize < reqSize ? maxSize : reqSize;

            assembly {
                // allocate output byte array - this could also be done without assembly
                // by using o_code = new bytes(size)
                oCode := mload(0x40)
                // new "memory end" including padding
                mstore(0x40, add(oCode, and(add(add(size, 0x20), 0x1f), not(0x1f))))
                // store length in memory
                mstore(oCode, size)
                // actually retrieve the code, this needs assembly
                extcodecopy(_addr, add(oCode, 0x20), _start, size)
            }
        }
    }
}
//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../ERC721Base.sol";
import "../../tokenManager/interfaces/IPostTransfer.sol";
import "../../tokenManager/interfaces/IPostBurn.sol";
import "../interfaces/IERC721GeneralMint.sol";
import "../ERC721GeneralSequenceBase.sol";
import "./OnchainFileStorage.sol";

/**
 * @title Generative ERC721
 * @dev Inherits from OnchainFileStorage for file handling
 * @author highlight.xyz
 * @notice Generative NFT smart contract
 */
contract ERC721GenerativeOnchain is ERC721GeneralSequenceBase, OnchainFileStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Generative Code URI
     */
    string private _generativeCodeURI;

    /**
     * @notice Initialize the contract
     * @param creator Creator/owner of contract
     * @param data Data to initialize the contract
     * @ param _contractURI Contract metadata
     * @ param defaultRoyalty Default royalty object for contract (optional)
     * @ param _defaultTokenManager Default token manager for contract (optional)
     * @ param _name Name of token edition
     * @ param _symbol Symbol of the token edition
     * @ param trustedForwarder Trusted minimal forwarder
     * @ param initialMinter Initial minter to register
     * @ param _generativeCodeURI Generative code URI
     * @ param newBaseURI Base URI for contract
     * @ param _limitSupply Initial limit supply
     * @ param useMarketplaceFiltererRegistry Denotes whether to use marketplace filterer registry
     * @param _observability Observability contract address
     */
    function initialize(address creator, bytes memory data, address _observability) external initializer {
        (
            string memory _contractURI,
            IRoyaltyManager.Royalty memory defaultRoyalty,
            address _defaultTokenManager,
            string memory _name,
            string memory _symbol,
            address trustedForwarder,
            address initialMinter,
            string memory _codeURI,
            string memory newBaseURI,
            uint256 _limitSupply,
            bool useMarketplaceFiltererRegistry
        ) = abi.decode(
                data,
                (
                    string,
                    IRoyaltyManager.Royalty,
                    address,
                    string,
                    string,
                    address,
                    address,
                    string,
                    string,
                    uint256,
                    bool
                )
            );

        __ERC721URIStorage_init();
        __ERC721Base_initialize(creator, defaultRoyalty, _defaultTokenManager);
        __ERC2771ContextUpgradeable__init__(trustedForwarder);
        __ERC721A_init(_name, _symbol);
        // deprecate but keep input for backwards-compatibility:
        // __MarketplaceFilterer__init__(useMarketplaceFiltererRegistry);
        _minters.add(initialMinter);
        contractURI = _contractURI;
        _generativeCodeURI = _codeURI;
        IObservability(_observability).emitGenerativeSeriesDeployed(address(this));
        observability = IObservability(_observability);

        if (bytes(newBaseURI).length > 0) {
            _setBaseURI(newBaseURI);
            // don't emit on observability contract here
        }

        if (_limitSupply > 0) {
            limitSupply = _limitSupply;
            // don't emit on observability contract here
        }
    }

    function generativeCodeUri() external view returns (string memory) {
        return _generativeCodeURI;
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgSender()
        internal
        view
        override(ERC721GeneralSequenceBase, ContextUpgradeable)
        returns (address sender)
    {
        return ERC721GeneralSequenceBase._msgSender();
    }

    /**
     * @notice Used for meta-transactions
     */
    function _msgData() internal view override(ERC721GeneralSequenceBase, ContextUpgradeable) returns (bytes calldata) {
        return ERC721GeneralSequenceBase._msgData();
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(
        bytes4 errorSelector
    ) internal pure virtual override(ERC721GeneralSequenceBase, OnchainFileStorage) {
        ERC721GeneralSequenceBase._revert(errorSelector);
    }
}
//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "./Bytecode.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title Onchain File Storage
 * @notice Introduces file handling to place utilities onchain
 * @author highlight.xyz
 */
abstract contract OnchainFileStorage is OwnableUpgradeable {
    /**
     * @notice File existence errors
     */
    error FileAlreadyRegistered();
    error FileNotRegistered();

    /**
     * @notice File storage
     * @dev File-scoped bytecode addresses (pointers) holding contents
     */
    mapping(bytes => address[]) private _fileStorage;

    /**
     * @notice File storage path names
     * @dev Store registered file names (all will be present as keys in `fileStorage`)
     */
    bytes[] private _files;

    /**
     * @notice Add a file via its name and associated storage bytecode addresses
     */
    function addFile(string calldata fileName, address[] calldata fileStorageAddresses) external onlyOwner {
        bytes memory _fileName = bytes(fileName);
        if (_fileStorage[_fileName].length != 0) {
            _revert(FileAlreadyRegistered.selector);
        }

        _files.push(_fileName);
        _fileStorage[_fileName] = fileStorageAddresses;
    }

    /**
     * @notice Remove a file from registered list of file names, and its associated storage bytecode addresses
     */
    function removeFile(string calldata fileName) external onlyOwner {
        bytes memory _fileName = bytes(fileName);
        if (_fileStorage[_fileName].length == 0) {
            _revert(FileNotRegistered.selector);
        }

        bytes[] memory oldFiles = _files;
        bytes[] memory newFiles = new bytes[](oldFiles.length - 1);
        uint256 fileIndexOffset = 0;
        uint256 oldFilesLength = oldFiles.length;

        for (uint256 i = 0; i < oldFilesLength; i++) {
            if (keccak256(oldFiles[i]) == keccak256(_fileName)) {
                fileIndexOffset = 1;
            } else {
                newFiles[i - fileIndexOffset] = oldFiles[i];
            }
        }

        _files = newFiles;
        delete _fileStorage[_fileName];
    }

    /**
     * @notice Return registered file names
     */
    function files() external view returns (string[] memory) {
        bytes[] memory fileNames = _files;
        string[] memory fileNamesHumanReadable = new string[](fileNames.length);

        for (uint256 i = 0; i < fileNames.length; i++) {
            fileNamesHumanReadable[i] = string(fileNames[i]);
        }

        return fileNamesHumanReadable;
    }

    /**
     * @notice Return storage bytecode addresses for a file
     */
    function fileStorage(string calldata fileName) external view returns (address[] memory) {
        bytes memory _fileName = bytes(fileName);
        if (_fileStorage[_fileName].length == 0) {
            _revert(FileNotRegistered.selector);
        }

        return _fileStorage[bytes(fileName)];
    }

    /**
     * @notice Return file contents
     */
    function fileContents(string calldata fileName) external view returns (string memory) {
        bytes memory _fileName = bytes(fileName);
        if (_fileStorage[_fileName].length == 0) {
            _revert(FileNotRegistered.selector);
        }

        address[] memory fileStorageAddresses = _fileStorage[bytes(fileName)];
        uint256 fileStorageAddressesLength = fileStorageAddresses.length;
        string memory contents = "";

        // @author of the following section: @xaltgeist (0x16cc845d144a283d1b0687fbac8b0601cc47a6c3 on Ethereum mainnet)
        // edited with HL FS -like variable names
        uint256 size;
        uint ptr = 0x20;
        address currentChunk;
        unchecked {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                contents := mload(0x40)
            }

            for (uint i = 0; i < fileStorageAddressesLength; i++) {
                currentChunk = fileStorageAddresses[i];
                size = Bytecode.codeSize(currentChunk) - 1;

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    extcodecopy(currentChunk, add(contents, ptr), 1, size)
                }
                ptr += size;
            }

            // solhint-disable-next-line no-inline-assembly
            assembly {
                // allocate output byte array - this could also be done without assembly
                // by using o_code = new bytes(size)
                // new "memory end" including padding
                mstore(0x40, add(contents, and(add(ptr, 0x1f), not(0x1f))))
                // store length in memory
                mstore(contents, sub(ptr, 0x20))
            }
        }
        return contents;
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure virtual {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "../erc721/onchain/ERC721GenerativeOnchain.sol";
import "../erc721/ERC721General.sol";
import "../erc721/ERC721GeneralSequence.sol";
import "../erc721/ERC721SingleEditionDFS.sol";
import "../erc721/ERC721EditionsDFS.sol";
import "../erc1155/ERC1155EditionsDFS.sol";
import "../royaltyManager/interfaces/IRoyaltyManager.sol";
import "../auction/interfaces/IAuctionManager.sol";
import "../mint/interfaces/IAbridgedMintVector.sol";

/**
 * @notice Highlight Factory for NFT contracts
 * @author highlight.xyz
 */
contract HighlightFactory {
    /**
     * @notice Deploy Generative Series nft contract (ERC721)
     */
    function deployGenerativeSeries721(
        bytes32 salt,
        address creator,
        address generativeSeriesImplementation,
        bytes memory initializeData,
        bytes memory mintVectorData,
        bytes memory mechanicVectorData,
        address observability
    ) external returns (address) {
        address clone = Clones.cloneDeterministic(generativeSeriesImplementation, salt);
        ERC721GenerativeOnchain(clone).initialize(address(this), initializeData, observability);

        if (mintVectorData.length > 0) {
            (
                address mintManager,
                address paymentRecipient,
                uint48 startTimestamp,
                uint48 endTimestamp,
                uint192 pricePerToken,
                uint48 tokenLimitPerTx,
                uint48 maxTotalClaimableViaVector,
                uint48 maxUserClaimableViaVector,
                address currency
            ) = abi.decode(
                    mintVectorData,
                    (address, address, uint48, uint48, uint192, uint48, uint48, uint48, address)
                );

            IAbridgedMintVector(mintManager).createAbridgedVector(
                IAbridgedMintVector.AbridgedVectorData(
                    uint160(clone),
                    startTimestamp,
                    endTimestamp,
                    uint160(paymentRecipient),
                    maxTotalClaimableViaVector,
                    0,
                    uint160(currency),
                    tokenLimitPerTx,
                    maxUserClaimableViaVector,
                    pricePerToken,
                    0,
                    false,
                    false,
                    0
                )
            );
        }

        if (mechanicVectorData.length != 0) {
            (uint96 seed, address mechanic, address mintManager, bytes memory vectorData) = abi.decode(
                mechanicVectorData,
                (uint96, address, address, bytes)
            );

            IMechanicMintManager(mintManager).registerMechanicVector(
                IMechanicData.MechanicVectorMetadata(clone, 0, mechanic, false, false, false),
                seed,
                vectorData
            );
        }

        Ownable(clone).transferOwnership(creator);
    }

    /**
     * @notice Deploy Series nft contract (ERC721)
     */
    function deploySeries721(
        bytes32 salt,
        address creator,
        address seriesImplementation,
        bytes memory initializeData,
        bytes memory mintVectorData,
        bytes memory mechanicVectorData,
        bool isCollectorsChoice
    ) external returns (address) {
        address clone = Clones.cloneDeterministic(seriesImplementation, salt);
        if (isCollectorsChoice) {
            ERC721General(clone).initialize(address(this), initializeData);
        } else {
            ERC721GeneralSequence(clone).initialize(address(this), initializeData);
        }

        if (mintVectorData.length > 0) {
            (
                address mintManager,
                address paymentRecipient,
                uint48 startTimestamp,
                uint48 endTimestamp,
                uint192 pricePerToken,
                uint48 tokenLimitPerTx,
                uint48 maxTotalClaimableViaVector,
                uint48 maxUserClaimableViaVector,
                address currency
            ) = abi.decode(
                    mintVectorData,
                    (address, address, uint48, uint48, uint192, uint48, uint48, uint48, address)
                );

            IAbridgedMintVector(mintManager).createAbridgedVector(
                IAbridgedMintVector.AbridgedVectorData(
                    uint160(clone),
                    startTimestamp,
                    endTimestamp,
                    uint160(paymentRecipient),
                    maxTotalClaimableViaVector,
                    0,
                    uint160(currency),
                    tokenLimitPerTx,
                    maxUserClaimableViaVector,
                    pricePerToken,
                    0,
                    false,
                    false,
                    0
                )
            );
        }

        if (mechanicVectorData.length != 0) {
            (uint96 seed, address mechanic, address mintManager, bytes memory vectorData) = abi.decode(
                mechanicVectorData,
                (uint96, address, address, bytes)
            );

            IMechanicMintManager(mintManager).registerMechanicVector(
                IMechanicData.MechanicVectorMetadata(clone, 0, mechanic, false, isCollectorsChoice, false),
                seed,
                vectorData
            );
        }

        Ownable(clone).transferOwnership(creator);
    }

    /**
     * @notice Deploy Single Edition nft contract (ERC721)
     */
    function deploySingleEdition721(
        bytes32 salt,
        address creator,
        address singleEditionImplementation,
        bytes memory initializeData,
        bytes memory mintVectorData,
        bytes memory mechanicVectorData,
        address _observability
    ) external returns (address) {
        address clone = Clones.cloneDeterministic(singleEditionImplementation, salt);
        ERC721SingleEditionDFS(clone).initialize(address(this), initializeData, _observability);

        if (mintVectorData.length > 0) {
            (
                address mintManager,
                address paymentRecipient,
                uint48 startTimestamp,
                uint48 endTimestamp,
                uint192 pricePerToken,
                uint48 tokenLimitPerTx,
                uint48 maxTotalClaimableViaVector,
                uint48 maxUserClaimableViaVector,
                address currency
            ) = abi.decode(
                    mintVectorData,
                    (address, address, uint48, uint48, uint192, uint48, uint48, uint48, address)
                );

            IAbridgedMintVector(mintManager).createAbridgedVector(
                IAbridgedMintVector.AbridgedVectorData(
                    uint160(clone),
                    startTimestamp,
                    endTimestamp,
                    uint160(paymentRecipient),
                    maxTotalClaimableViaVector,
                    0,
                    uint160(currency),
                    tokenLimitPerTx,
                    maxUserClaimableViaVector,
                    pricePerToken,
                    0,
                    true,
                    false,
                    0
                )
            );
        }

        if (mechanicVectorData.length != 0) {
            (uint96 seed, address mechanic, address mintManager, bytes memory vectorData) = abi.decode(
                mechanicVectorData,
                (uint96, address, address, bytes)
            );

            IMechanicMintManager(mintManager).registerMechanicVector(
                IMechanicData.MechanicVectorMetadata(clone, 0, mechanic, true, false, false),
                seed,
                vectorData
            );
        }

        Ownable(clone).transferOwnership(creator);
    }

    /**
     * @notice Deploy Multiple Editions nft contract (ERC721)
     */
    function deployMultipleEditions721(
        bytes32 salt,
        address creator,
        address multipleEditionsImplementation,
        bytes memory initializeData,
        string memory _editionUri,
        uint256 editionSize,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty,
        bytes memory auctionData,
        bytes memory mintVectorData,
        bytes memory mechanicVectorData
    ) external returns (address) {
        address clone = Clones.cloneDeterministic(multipleEditionsImplementation, salt);
        ERC721EditionsDFS(clone).initialize(address(this), initializeData);

        // create edition
        /* solhint-disable max-line-length */
        if (bytes(_editionUri).length > 0) {
            if (mintVectorData.length > 0 && mechanicVectorData.length > 0) {
                ERC721EditionsDFS(clone).createEditionWithMechanicVectorAndPublicFixedPriceVector(
                    _editionUri,
                    editionSize,
                    _editionTokenManager,
                    editionRoyalty,
                    mintVectorData,
                    mechanicVectorData
                );
            } else if (mechanicVectorData.length > 0) {
                ERC721EditionsDFS(clone).createEditionWithMechanicVector(
                    _editionUri,
                    editionSize,
                    _editionTokenManager,
                    editionRoyalty,
                    mechanicVectorData
                );
            } else {
                ERC721EditionsDFS(clone).createEdition(
                    _editionUri,
                    editionSize,
                    _editionTokenManager,
                    editionRoyalty,
                    mintVectorData
                );
            }
        }

        if (auctionData.length > 0) {
            // if creating auction for this edition, validate that edition size was 1
            require(editionSize == 1, "Invalid edition size for auction");

            (
                address auctionManagerAddress,
                bytes32 auctionId,
                address auctionCurrency,
                address payable auctionPaymentRecipient,
                uint256 auctionEndTime
            ) = abi.decode(auctionData, (address, bytes32, address, address, uint256));

            // edition id guaranteed to be = 0
            IAuctionManager(auctionManagerAddress).createAuctionForNewEdition(
                auctionId,
                IAuctionManager.EnglishAuction(
                    clone,
                    auctionCurrency,
                    msg.sender,
                    auctionPaymentRecipient,
                    auctionEndTime,
                    0,
                    true,
                    IAuctionManager.AuctionState.LIVE_ON_CHAIN
                ),
                0
            );
        }

        Ownable(clone).transferOwnership(creator);
    }

    /**
     * @notice Deploy Editions nft contract (ERC1155)
     */
    function deployEditions1155(
        bytes32 salt,
        address creator,
        address editions1155Implementation,
        bytes memory initializeData,
        string memory _editionUri,
        uint256 editionSize,
        address _editionTokenManager,
        IRoyaltyManager.Royalty memory editionRoyalty,
        bytes memory mintVectorData,
        bytes memory mechanicVectorData
    ) external returns (address) {
        address clone = Clones.cloneDeterministic(editions1155Implementation, salt);
        ERC1155EditionsDFS(clone).initialize(address(this), initializeData);

        // create edition
        /* solhint-disable max-line-length */
        if (bytes(_editionUri).length > 0) {
            if (mintVectorData.length > 0 && mechanicVectorData.length > 0) {
                ERC1155EditionsDFS(clone).createEditionWithMechanicVectorAndPublicFixedPriceVector(
                    _editionUri,
                    editionSize,
                    _editionTokenManager,
                    editionRoyalty,
                    mintVectorData,
                    mechanicVectorData
                );
            } else if (mechanicVectorData.length > 0) {
                ERC1155EditionsDFS(clone).createEditionWithMechanicVector(
                    _editionUri,
                    editionSize,
                    _editionTokenManager,
                    editionRoyalty,
                    mechanicVectorData
                );
            } else {
                ERC1155EditionsDFS(clone).createEdition(
                    _editionUri,
                    editionSize,
                    _editionTokenManager,
                    editionRoyalty,
                    mintVectorData
                );
            }
        }

        Ownable(clone).transferOwnership(creator);
    }

    /**
     * @notice Predict CREATE2-deployed nft contract address
     */
    function predictContractAddress(address nftContractImplementation, bytes32 salt) external view returns (address) {
        return Clones.predictDeterministicAddress(nftContractImplementation, salt);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @dev Utilities for metadata encryption and decryption
 * @author highlight.xyz
 */
abstract contract MetadataEncryption {
    /// @dev See: https://ethereum.stackexchange.com/questions/69825/decrypt-message-on-chain
    function encryptDecrypt(bytes memory data, bytes calldata key) public pure returns (bytes memory result) {
        // Store data length on stack for later use
        uint256 length = data.length;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Set result to free memory pointer
            result := mload(0x40)
            // Increase free memory pointer by lenght + 32
            mstore(0x40, add(add(result, length), 32))
            // Set result length
            mstore(result, length)
        }

        // Iterate over the data stepping by 32 bytes
        for (uint256 i = 0; i < length; i += 32) {
            // Generate hash of the key and offset
            bytes32 hash = keccak256(abi.encodePacked(key, i));

            bytes32 chunk;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                // Read 32-bytes data chunk
                chunk := mload(add(data, add(i, 32)))
            }
            // XOR the chunk with hash
            chunk ^= hash;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                // Write 32-byte encrypted chunk
                mstore(add(result, add(i, 32)), chunk)
            }
        }
    }

    function _sliceUint(bytes memory bs, uint256 start) internal pure returns (uint256) {
        require(bs.length >= start + 32, "slicing out of range");
        uint256 x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }
        return x;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @notice Used to interface with EditionsMetadataRenderer
 * @author highlight.xyz
 */
interface IEditionsMetadataRenderer {
    /**
     * @notice Token edition info
     * @param name Edition name
     * @param description Edition description
     * @param imageUrl Edition image url
     * @param animationUrl Edition animation url
     * @param externalUrl Edition external url
     * @param attributes Edition attributes
     */
    struct TokenEditionInfo {
        string name;
        string description;
        string imageUrl;
        string animationUrl;
        string externalUrl;
        string attributes;
    }

    /**
     * @notice Updates name on edition. Managed by token manager if existent
     * @param editionsAddress Address of collection that edition is on
     * @param editionId ID of edition to update
     * @param name New name of edition
     */
    function updateName(address editionsAddress, uint256 editionId, string calldata name) external;

    /**
     * @notice Updates description on edition. Managed by token manager if existent
     * @param editionsAddress Address of collection that edition is on
     * @param editionId ID of edition to update
     * @param description New description of edition
     */
    function updateDescription(address editionsAddress, uint256 editionId, string calldata description) external;

    /**
     * @notice Updates imageUrl on edition. Managed by token manager if existent
     * @param editionsAddress Address of collection that edition is on
     * @param editionId ID of edition to update
     * @param imageUrl New imageUrl of edition
     */
    function updateImageUrl(address editionsAddress, uint256 editionId, string calldata imageUrl) external;

    /**
     * @notice Updates animationUrl on edition. Managed by token manager if existent
     * @param editionsAddress Address of collection that edition is on
     * @param editionId ID of edition to update
     * @param animationUrl New animationUrl of edition
     */
    function updateAnimationUrl(address editionsAddress, uint256 editionId, string calldata animationUrl) external;

    /**
     * @notice Updates externalUrl on edition. Managed by token manager if existent
     * @param editionsAddress Address of collection that edition is on
     * @param editionId ID of edition to update
     * @param externalUrl New externalUrl of edition
     */
    function updateExternalUrl(address editionsAddress, uint256 editionId, string calldata externalUrl) external;

    /**
     * @notice Updates attributes on edition. Managed by token manager if existent
     * @param editionsAddress Address of collection that edition is on
     * @param editionId ID of edition to update
     * @param attributes New attributes of edition
     */
    function updateAttributes(address editionsAddress, uint256 editionId, string calldata attributes) external;

    /**
     * @notice Updates any set of metadata fields
     * @param editionsAddress Address of collection that edition is on
     * @param editionId ID of edition to update
     * @param tokenEditionInfo New metadata fields
     * @param updateIds Encoded what metadata fields to update
     */
    function updateMetadata(
        address editionsAddress,
        uint256 editionId,
        TokenEditionInfo calldata tokenEditionInfo,
        uint256[] calldata updateIds
    ) external;

    /**
     * @notice Get an edition's uri. HAS to be called by collection
     * @param editionId Edition's id to get uri for
     */
    function editionURI(uint256 editionId) external view returns (string memory);

    /**
     * @notice Get an edition's info.
     * @param editionsAddress Address of collection that edition is on
     * @param editionsId Edition's id to get info for
     */
    function editionInfo(address editionsAddress, uint256 editionsId) external view returns (TokenEditionInfo memory);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @notice Used to interface with core of EditionsMetadataRenderer
 * @author Zora, sarib@highlight.xyz
 */
interface IMetadataRenderer {
    /**
     * @notice Store metadata for an edition
     * @param data Metadata
     */
    function initializeMetadata(bytes memory data) external;

    /**
     * @notice Get uri for token
     * @param tokenId ID of token to get uri for
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (metatx/ERC2771Context.sol)

pragma solidity 0.8.10;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Context variant with ERC2771 support.
 *      Openzeppelin contract slightly modified by ishan@ highlight.xyz to be upgradeable.
 */
abstract contract ERC2771ContextUpgradeable is Initializable {
    address private _trustedForwarder;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function __ERC2771ContextUpgradeable__init__(address trustedForwarder) internal onlyInitializing {
        _trustedForwarder = trustedForwarder;
    }

    function _msgSender() internal view virtual returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            /* solhint-disable no-inline-assembly */
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
            /* solhint-enable no-inline-assembly */
        } else {
            return msg.sender;
        }
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return msg.data;
        }
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

/**
 * @title MintManager interface for onchain abridged mint vectors
 * @author highlight.xyz
 */
interface IAbridgedMintVector {
    /**
     * @notice On-chain mint vector (stored data)
     * @param contractAddress NFT smart contract address
     * @param startTimestamp When minting opens on vector
     * @param endTimestamp When minting ends on vector
     * @param paymentRecipient Payment recipient
     * @param maxTotalClaimableViaVector Max number of tokens that can be minted via vector
     * @param totalClaimedViaVector Total number of tokens minted via vector
     * @param currency Currency used for payment. Native gas token, if zero address
     * @param tokenLimitPerTx Max number of tokens that can be minted in one transaction
     * @param maxUserClaimableViaVector Max number of tokens that can be minted by user via vector
     * @param pricePerToken Price that has to be paid per minted token
     * @param editionId Edition ID, if vector is for edition based collection
     * @param editionBasedCollection If vector is for an edition based collection
     * @param requireDirectEOA Require minters to directly be EOAs
     * @param allowlistRoot Root of merkle tree with allowlist
     */
    struct AbridgedVectorData {
        uint160 contractAddress;
        uint48 startTimestamp;
        uint48 endTimestamp;
        uint160 paymentRecipient;
        uint48 maxTotalClaimableViaVector;
        uint48 totalClaimedViaVector;
        uint160 currency;
        uint48 tokenLimitPerTx;
        uint48 maxUserClaimableViaVector;
        uint192 pricePerToken;
        uint48 editionId;
        bool editionBasedCollection;
        bool requireDirectEOA;
        bytes32 allowlistRoot;
    }

    /**
     * @notice On-chain mint vector (public) - See {AbridgedVectorData}
     */
    struct AbridgedVector {
        address contractAddress;
        uint48 startTimestamp;
        uint48 endTimestamp;
        address paymentRecipient;
        uint48 maxTotalClaimableViaVector;
        uint48 totalClaimedViaVector;
        address currency;
        uint48 tokenLimitPerTx;
        uint48 maxUserClaimableViaVector;
        uint192 pricePerToken;
        uint48 editionId;
        bool editionBasedCollection;
        bool requireDirectEOA;
        bytes32 allowlistRoot;
    }

    /**
     * @notice Config defining what fields to update
     * @param updateStartTimestamp If 1, update startTimestamp
     * @param updateEndTimestamp If 1, update endTimestamp
     * @param updatePaymentRecipient If 1, update paymentRecipient
     * @param updateMaxTotalClaimableViaVector If 1, update maxTotalClaimableViaVector
     * @param updateTokenLimitPerTx If 1, update tokenLimitPerTx
     * @param updateMaxUserClaimableViaVector If 1, update maxUserClaimableViaVector
     * @param updatePricePerToken If 1, update pricePerToken
     * @param updateCurrency If 1, update currency
     * @param updateRequireDirectEOA If 1, update requireDirectEOA
     * @param updateMetadata If 1, update MintVector metadata
     */
    struct UpdateAbridgedVectorConfig {
        uint16 updateStartTimestamp;
        uint16 updateEndTimestamp;
        uint16 updatePaymentRecipient;
        uint16 updateMaxTotalClaimableViaVector;
        uint16 updateTokenLimitPerTx;
        uint16 updateMaxUserClaimableViaVector;
        uint8 updatePricePerToken;
        uint8 updateCurrency;
        uint8 updateRequireDirectEOA;
        uint8 updateMetadata;
    }

    /**
     * @notice Creates on-chain vector
     * @param _vector Vector to create
     */
    function createAbridgedVector(AbridgedVectorData memory _vector) external;

    /**
     * @notice Updates on-chain vector
     * @param vectorId ID of vector to update
     * @param _newVector New vector details
     * @param updateConfig Number encoding what fields to update
     * @param pause Pause / unpause vector
     * @param flexibleData Flexible data in vector metadata
     */
    function updateAbridgedVector(
        uint256 vectorId,
        AbridgedVector calldata _newVector,
        UpdateAbridgedVectorConfig calldata updateConfig,
        bool pause,
        uint128 flexibleData
    ) external;

    /**
     * @notice Pauses or unpauses an on-chain mint vector
     * @param vectorId ID of abridged vector to pause
     * @param pause True to pause, False to unpause
     * @param flexibleData Flexible data that can be interpreted differently
     */
    function setAbridgedVectorMetadata(uint256 vectorId, bool pause, uint128 flexibleData) external;

    /**
     * @notice Get on-chain abridged vector
     * @param vectorId ID of abridged vector to get
     */
    function getAbridgedVector(uint256 vectorId) external view returns (AbridgedVector memory);

    /**
     * @notice Get on-chain abridged vector metadata
     * @param vectorId ID of abridged vector to get
     */
    function getAbridgedVectorMetadata(uint256 vectorId) external view returns (bool, uint128);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @notice Defines a mechanic's metadata on the MintManager
 */
interface IMechanicData {
    /**
     * @notice A mechanic's metadata
     * @param contractAddress Collection contract address
     * @param editionId Edition ID if the collection is edition based
     * @param mechanic Address of mint mechanic contract
     * @param isEditionBased True if collection is edition based
     * @param isChoose True if collection uses a collector's choice mint paradigm
     * @param paused True if mechanic vector is paused
     */
    struct MechanicVectorMetadata {
        address contractAddress;
        uint96 editionId;
        address mechanic;
        bool isEditionBased;
        bool isChoose;
        bool paused;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "./IMechanicData.sol";

/**
 * @notice Capabilities on MintManager pertaining to mechanics
 */
interface IMechanicMintManager is IMechanicData {
    /**
     * @notice Register a new mechanic vector
     * @param _mechanicVectorMetadata Mechanic vector metadata
     * @param seed Used to seed uniqueness into mechanic vector ID generation
     * @param vectorData Vector data to store on mechanic (optional)
     */
    function registerMechanicVector(
        MechanicVectorMetadata calldata _mechanicVectorMetadata,
        uint96 seed,
        bytes calldata vectorData
    ) external;

    /**
     * @notice Pause or unpause a mechanic vector
     * @param mechanicVectorId Global mechanic ID
     * @param pause If true, pause the mechanic mint vector. If false, unpause
     */
    function setPauseOnMechanicMintVector(bytes32 mechanicVectorId, bool pause) external;

    /**
     * @notice Mint a number of tokens sequentially via a mechanic vector
     * @param mechanicVectorId Global mechanic ID
     * @param recipient Mint recipient
     * @param numToMint Number of tokens to mint
     * @param data Custom data to be processed by mechanic
     */
    function mechanicMintNum(
        bytes32 mechanicVectorId,
        address recipient,
        uint32 numToMint,
        bytes calldata data
    ) external payable;

    /**
     * @notice Mint a specific set of token ids via a mechanic vector
     * @param mechanicVectorId Global mechanic ID
     * @param recipient Mint recipient
     * @param tokenIds IDs of tokens to mint
     * @param data Custom data to be processed by mechanic
     */
    function mechanicMintChoose(
        bytes32 mechanicVectorId,
        address recipient,
        uint256[] calldata tokenIds,
        bytes calldata data
    ) external payable;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../royaltyManager/interfaces/IRoyaltyManager.sol";

/**
 * @title IObservability
 * @author highlight.xyz
 * @notice Interface to interact with the Highlight observability singleton
 * @dev Singleton to coalesce select Highlight protocol events
 */
interface IObservability {
    /**************************
      ERC721Base / ERC721MinimizedBase events
     **************************/

    /**
     * @notice Emitted when minter is registered or unregistered
     * @param contractAddress Initial contract that emitted event
     * @param minter Minter that was changed
     * @param registered True if the minter was registered, false if unregistered
     */
    event MinterRegistrationChanged(address indexed contractAddress, address indexed minter, bool indexed registered);

    /**
     * @notice Emitted when token managers are set for token/edition ids
     * @param contractAddress Initial contract that emitted event
     * @param _ids Edition / token ids
     * @param _tokenManagers Token managers to set for tokens / editions
     */
    event GranularTokenManagersSet(address indexed contractAddress, uint256[] _ids, address[] _tokenManagers);

    /**
     * @notice Emitted when token managers are removed for token/edition ids
     * @param contractAddress Initial contract that emitted event
     * @param _ids Edition / token ids to remove token managers for
     */
    event GranularTokenManagersRemoved(address indexed contractAddress, uint256[] _ids);

    /**
     * @notice Emitted when default token manager changed
     * @param contractAddress Initial contract that emitted event
     * @param newDefaultTokenManager New default token manager. Zero address if old one was removed
     */
    event DefaultTokenManagerChanged(address indexed contractAddress, address indexed newDefaultTokenManager);

    /**
     * @notice Emitted when default royalty is set
     * @param contractAddress Initial contract that emitted event
     * @param recipientAddress Royalty recipient
     * @param royaltyPercentageBPS Percentage of sale (in basis points) owed to royalty recipient
     */
    event DefaultRoyaltySet(
        address indexed contractAddress,
        address indexed recipientAddress,
        uint16 indexed royaltyPercentageBPS
    );

    /**
     * @notice Emitted when royalties are set for edition / token ids
     * @param contractAddress Initial contract that emitted event
     * @param ids Token / edition ids
     * @param _newRoyalties New royalties for each token / edition
     */
    event GranularRoyaltiesSet(address indexed contractAddress, uint256[] ids, IRoyaltyManager.Royalty[] _newRoyalties);

    /**
     * @notice Emitted when royalty manager is updated
     * @param contractAddress Initial contract that emitted event
     * @param newRoyaltyManager New royalty manager. Zero address if old one was removed
     */
    event RoyaltyManagerChanged(address indexed contractAddress, address indexed newRoyaltyManager);

    /**
     * @notice Emitted when mints are frozen permanently
     * @param contractAddress Initial contract that emitted event
     */
    event MintsFrozen(address indexed contractAddress);

    /**
     * @notice Emitted when contract metadata is set
     * @param contractAddress Initial contract that emitted event
     * @param name New name
     * @param symbol New symbol
     * @param contractURI New contract uri
     */
    event ContractMetadataSet(address indexed contractAddress, string name, string symbol, string contractURI);

    /**************************
      ERC721General events
     **************************/

    /**
     * @notice Emitted when hashed metadata config is set
     * @param contractAddress Initial contract that emitted event
     * @param hashedURIData Hashed uri data
     * @param hashedRotationData Hashed rotation key
     * @param _supply Supply of tokens to mint w/ reveal
     */
    event HashedMetadataConfigSet(
        address indexed contractAddress,
        bytes hashedURIData,
        bytes hashedRotationData,
        uint256 indexed _supply
    );

    /**
     * @notice Emitted when metadata is revealed
     * @param contractAddress Initial contract that emitted event
     * @param key Key used to decode hashed data
     * @param newRotationKey Actual rotation key to be used
     */
    event Revealed(address indexed contractAddress, bytes key, uint256 newRotationKey);

    /**************************
      ERC721GeneralBase events
     **************************/

    /**
     * @notice Emitted when uris are set for tokens
     * @param contractAddress Initial contract that emitted event
     * @param ids IDs of tokens to set uris for
     * @param uris Uris to set on tokens
     */
    event TokenURIsSet(address indexed contractAddress, uint256[] ids, string[] uris);

    /**
     * @notice Emitted when limit supply is set
     * @param contractAddress Initial contract that emitted event
     * @param newLimitSupply Limit supply to set
     */
    event LimitSupplySet(address indexed contractAddress, uint256 indexed newLimitSupply);

    /**************************
      ERC721StorageUri events
     **************************/

    /**
     * @notice Emits when a series collection has its base uri set
     * @param contractAddress Contract with updated base uri
     * @param newBaseUri New base uri
     */
    event BaseUriSet(address indexed contractAddress, string newBaseUri);

    /**************************
      ERC721Editions / ERC721SingleEdition events
     **************************/

    // Not adding EditionCreated, EditionMintedToOneRecipient, EditionMintedToRecipients
    // EditionCreated - handled by MetadataInitialized
    // EditionMintedToOneRecipient / EditionMintedToRecipients - handled via mint module events

    /**************************
      Deployment events
     **************************/

    /**
     * @notice Emitted when Generative Series contract is deployed
     * @param deployer Contract deployer
     * @param contractAddress Address of contract that was deployed
     */
    event GenerativeSeriesDeployed(address indexed deployer, address indexed contractAddress);

    /**
     * @notice Emitted when Series contract is deployed
     * @param deployer Contract deployer
     * @param contractAddress Address of contract that was deployed
     */
    event SeriesDeployed(address indexed deployer, address indexed contractAddress);

    /**
     * @notice Emitted when MultipleEditions contract is deployed
     * @param deployer Contract deployer
     * @param contractAddress Address of contract that was deployed
     */
    event MultipleEditionsDeployed(address indexed deployer, address indexed contractAddress);

    /**
     * @notice Emitted when SingleEdition contract is deployed
     * @param deployer Contract deployer
     * @param contractAddress Address of contract that was deployed
     */
    event SingleEditionDeployed(address indexed deployer, address indexed contractAddress);

    /**************************
      ERC721 events
     **************************/

    /**
     * @notice Emitted when `tokenId` token is transferred from `from` to `to` on contractAddress
     * @param contractAddress NFT contract token resides on
     * @param from Token sender
     * @param to Token receiver
     * @param tokenId Token being sent
     */
    event Transfer(address indexed contractAddress, address indexed from, address to, uint256 indexed tokenId);

    /**
     * @notice Emit MinterRegistrationChanged
     */
    function emitMinterRegistrationChanged(address minter, bool registered) external;

    /**
     * @notice Emit GranularTokenManagersSet
     */
    function emitGranularTokenManagersSet(uint256[] calldata _ids, address[] calldata _tokenManagers) external;

    /**
     * @notice Emit GranularTokenManagersRemoved
     */
    function emitGranularTokenManagersRemoved(uint256[] calldata _ids) external;

    /**
     * @notice Emit DefaultTokenManagerChanged
     */
    function emitDefaultTokenManagerChanged(address newDefaultTokenManager) external;

    /**
     * @notice Emit DefaultRoyaltySet
     */
    function emitDefaultRoyaltySet(address recipientAddress, uint16 royaltyPercentageBPS) external;

    /**
     * @notice Emit GranularRoyaltiesSet
     */
    function emitGranularRoyaltiesSet(
        uint256[] calldata ids,
        IRoyaltyManager.Royalty[] calldata _newRoyalties
    ) external;

    /**
     * @notice Emit RoyaltyManagerChanged
     */
    function emitRoyaltyManagerChanged(address newRoyaltyManager) external;

    /**
     * @notice Emit MintsFrozen
     */
    function emitMintsFrozen() external;

    /**
     * @notice Emit ContractMetadataSet
     */
    function emitContractMetadataSet(
        string calldata name,
        string calldata symbol,
        string calldata contractURI
    ) external;

    /**
     * @notice Emit HashedMetadataConfigSet
     */
    function emitHashedMetadataConfigSet(
        bytes calldata hashedURIData,
        bytes calldata hashedRotationData,
        uint256 _supply
    ) external;

    /**
     * @notice Emit Revealed
     */
    function emitRevealed(bytes calldata key, uint256 newRotationKey) external;

    /**
     * @notice Emit TokenURIsSet
     */
    function emitTokenURIsSet(uint256[] calldata ids, string[] calldata uris) external;

    /**
     * @notice Emit LimitSupplySet
     */
    function emitLimitSupplySet(uint256 newLimitSupply) external;

    /**
     * @notice Emit BaseUriSet
     */
    function emitBaseUriSet(string calldata newBaseUri) external;

    /**
     * @notice Emit GenerativeSeriesDeployed
     */
    function emitGenerativeSeriesDeployed(address contractAddress) external;

    /**
     * @notice Emit SeriesDeployed
     */
    function emitSeriesDeployed(address contractAddress) external;

    /**
     * @notice Emit MultipleEditionsDeployed
     */
    function emitMultipleEditionsDeployed(address contractAddress) external;

    /**
     * @notice Emit SingleEditionDeployed
     */
    function emitSingleEditionDeployed(address contractAddress) external;

    /**
     * @notice Emit Transfer
     */
    function emitTransfer(address from, address to, uint256 tokenId) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "./IObservability.sol";

/**
 * @title IObservabilityV2
 * @author highlight.xyz
 * @notice Interface to interact with the Highlight observabilityV2 singleton
 * @dev Singleton to coalesce select Highlight protocol events
 */
interface IObservabilityV2 is IObservability {
    /**************************
        Deployment events
    **************************/

    /**
     * @notice Emitted when Editions1155 contract is deployed
     * @param deployer Contract deployer
     * @param contractAddress Address of contract that was deployed
     */
    event Editions1155Deployed(address indexed deployer, address indexed contractAddress);

    /**************************
        ERC1155 events
    **************************/

    /**
     * @notice Emitted when an amount `value` of `tokenId` token is transferred from `from` to `to` on contractAddress
     * @param contractAddress NFT contract token resides on
     * @param operator Transaction executor
     * @param from Token sender
     * @param to Token receiver
     * @param id ID of token being sent
     * @param value Amount of token ssent
     */
    event TransferSingle(
        address indexed contractAddress,
        address operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    /**
     * @notice Emitted when amount `values` of `tokenId` token is transferred from `from` to `to` on contractAddress
     * @param contractAddress NFT contract token resides on
     * @param operator Transaction executor
     * @param from Token sender
     * @param to Token receiver
     * @param ids Token ids being sent
     * @param values Amounts of tokens sent
     */
    event TransferBatch(
        address indexed contractAddress,
        address operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @notice Emit Editions1155Deployed
     */
    function emitEditions1155Deployed(address contractAddress) external;

    /**
     * @notice Emit 1155 TransferSingle
     */
    function emitTransferSingle(address operator, address from, address to, uint256 tokenId, uint256 amount) external;

    /**
     * @notice Emit 1155 TransferBatch
     */
    function emitTransferBatch(
        address operator,
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @title IRoyaltyManager
 * @author highlight.xyz
 * @notice Enables interfacing with custom royalty managers that define conditions on setting royalties for
 *         NFT contracts
 */
interface IRoyaltyManager {
    /**
     * @notice Struct containing values required to adhere to ERC-2981
     * @param recipientAddress Royalty recipient - can be EOA, royalty splitter contract, etc.
     * @param royaltyPercentageBPS Royalty cut, in basis points
     */
    struct Royalty {
        address recipientAddress;
        uint16 royaltyPercentageBPS;
    }

    /**
     * @notice Defines conditions around being able to swap royalty manager for another one
     * @param newRoyaltyManager New royalty manager being swapped in
     * @param sender msg sender
     */
    function canSwap(address newRoyaltyManager, address sender) external view returns (bool);

    /**
     * @notice Defines conditions around being able to remove current royalty manager
     * @param sender msg sender
     */
    function canRemoveItself(address sender) external view returns (bool);

    /**
     * @notice Defines conditions around being able to set granular royalty (per token or per edition)
     * @param id Edition / token ID whose royalty is being set
     * @param royalty Royalty being set
     * @param sender msg sender
     */
    function canSetGranularRoyalty(uint256 id, Royalty calldata royalty, address sender) external view returns (bool);

    /**
     * @notice Defines conditions around being able to set default royalty
     * @param royalty Royalty being set
     * @param sender msg sender
     */
    function canSetDefaultRoyalty(Royalty calldata royalty, address sender) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/**
 * @author highlight.xyz
 * @notice If token managers implement this, transfer actions will call
 *      postBurn on the token manager.
 */
interface IPostBurn {
    /**
     * @notice Hook called by contract after burn, if token manager of burned token implements this
     *      interface.
     * @param operator Operator burning tokens
     * @param sender Msg sender
     * @param id Burned token's id or id of edition of token that is burned
     */
    function postBurn(address operator, address sender, uint256 id) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/**
 * @author highlight.xyz
 * @notice If token managers implement this, transfer actions will call
 *      postSafeTransferFrom or postTransferFrom on the token manager.
 */
interface IPostTransfer {
    /**
     * @notice Hook called by community after safe transfers, if token manager of transferred token implements this
     *      interface.
     * @param operator Operator transferring tokens
     * @param from Token(s) sender
     * @param to Token(s) recipient
     * @param id Transferred token's id
     * @param data Arbitrary data
     */
    function postSafeTransferFrom(address operator, address from, address to, uint256 id, bytes memory data) external;

    /**
     * @notice Hook called by community after transfers, if token manager of transferred token implements
     *         this interface.
     * @param operator Operator transferring tokens
     * @param from Token(s) sender
     * @param to Token(s) recipient
     * @param id Transferred token's id
     */
    function postTransferFrom(address operator, address from, address to, uint256 id) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

/**
 * @title ITokenManager
 * @author highlight.xyz
 * @notice Enables interfacing with custom token managers
 */
interface ITokenManager {
    /**
     * @notice Returns whether metadata updater is allowed to update
     * @param sender Updater
     * @param id Token/edition who's uri is being updated
     *           If id is 0, implementation should decide behaviour for base uri update
     * @param newData Token's new uri if called by general contract, and any metadata field if called by editions
     * @return If invocation can update metadata
     */
    function canUpdateMetadata(address sender, uint256 id, bytes calldata newData) external returns (bool);

    /**
     * @notice Returns whether token manager can be swapped for another one by invocator
     * @notice Default token manager implementations should ignore id
     * @param sender Swapper
     * @param id Token grouping id (token id or edition id)
     * @param newTokenManager New token manager being swapped to
     * @return If invocation can swap token managers
     */
    function canSwap(address sender, uint256 id, address newTokenManager) external returns (bool);

    /**
     * @notice Returns whether token manager can be removed
     * @notice Default token manager implementations should ignore id
     * @param sender Swapper
     * @param id Token grouping id (token id or edition id)
     * @return If invocation can remove token manager
     */
    function canRemoveItself(address sender, uint256 id) external returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "./ITokenManager.sol";

/**
 * @title ITokenManager
 * @author highlight.xyz
 * @notice Enables interfacing with custom token managers for editions contracts
 */
interface ITokenManagerEditions is ITokenManager {
    /**
     * @notice The updated field in metadata updates
     */
    enum FieldUpdated {
        name,
        description,
        imageUrl,
        animationUrl,
        externalUrl,
        attributes,
        other
    }

    /**
     * @notice Returns whether metadata updater is allowed to update
     * @param editionsAddress Address of editions contract
     * @param sender Updater
     * @param editionId Token/edition who's uri is being updated
     *           If id is 0, implementation should decide behaviour for base uri update
     * @param newData Token's new uri if called by general contract, and any metadata field if called by editions
     * @param fieldUpdated Which metadata field was updated
     * @return If invocation can update metadata
     */
    function canUpdateEditionsMetadata(
        address editionsAddress,
        address sender,
        uint256 editionId,
        bytes calldata newData,
        FieldUpdated fieldUpdated
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/ERC1155.sol)

pragma solidity 0.8.10;

import "./IERC1155Upgradeable.sol";
import "./IERC1155ReceiverUpgradeable.sol";
import "./IERC1155MetadataURIUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "../ERC165/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is
    Initializable,
    ContextUpgradeable,
    ERC165Upgradeable,
    IERC1155Upgradeable,
    IERC1155MetadataURIUpgradeable
{
    using AddressUpgradeable for address;

    /**
     * @notice ERC1155 errors
     */
    error InvalidOwner();
    error InvalidInput();
    error NotTokenOwnerOrApproved();
    error TransferToZeroAddress();
    error TransferFromZeroAddress();
    error InsufficientBalance();
    error InvalidOperator();
    error ReceiverRejectedTokens();
    error ReceiverNonImplementer();

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        if (account == address(0)) {
            _revert(InvalidOwner.selector);
        }
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) public view virtual override returns (uint256[] memory) {
        if (accounts.length != ids.length) {
            _revert(InvalidInput.selector);
        }

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        if (!(from == _msgSender() || isApprovedForAll(from, _msgSender()))) {
            _revert(NotTokenOwnerOrApproved.selector);
        }
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        if (!(from == _msgSender() || isApprovedForAll(from, _msgSender()))) {
            _revert(NotTokenOwnerOrApproved.selector);
        }
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        if (to == address(0)) {
            _revert(TransferToZeroAddress.selector);
        }

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        uint256 fromBalance = _balances[id][from];
        if (fromBalance < amount) {
            _revert(InsufficientBalance.selector);
        }
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        if (ids.length != amounts.length) {
            _revert(InvalidInput.selector);
        }
        if (to == address(0)) {
            _revert(TransferToZeroAddress.selector);
        }

        address operator = _msgSender();

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            if (fromBalance < amount) {
                _revert(InsufficientBalance.selector);
            }
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        if (to == address(0)) {
            _revert(TransferToZeroAddress.selector);
        }

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        if (to == address(0)) {
            _revert(TransferToZeroAddress.selector);
        }
        if (ids.length != amounts.length) {
            _revert(InvalidInput.selector);
        }

        address operator = _msgSender();

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        if (from == address(0)) {
            _revert(TransferFromZeroAddress.selector);
        }

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        uint256 fromBalance = _balances[id][from];
        if (fromBalance < amount) {
            _revert(InsufficientBalance.selector);
        }
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        if (from == address(0)) {
            _revert(TransferFromZeroAddress.selector);
        }
        if (ids.length != amounts.length) {
            _revert(InvalidInput.selector);
        }

        address operator = _msgSender();

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            if (fromBalance < amount) {
                _revert(InsufficientBalance.selector);
            }
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        if (owner == operator) {
            _revert(InvalidOperator.selector);
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure virtual {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    _revert(ReceiverRejectedTokens.selector);
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                _revert(ReceiverNonImplementer.selector);
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    _revert(ReceiverRejectedTokens.selector);
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                _revert(ReceiverNonImplementer.selector);
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[47] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity 0.8.10;

import "./IERC1155Upgradeable.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity 0.8.10;

import "../ERC165/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/IERC1155.sol)

pragma solidity 0.8.10;

import "../ERC165/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity 0.8.10;

import "./IERC165Upgradeable.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
/* solhint-disable */
library ERC165CheckerUpgradeable {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165Upgradeable).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && supportsERC165InterfaceUnchecked(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(
        address account,
        bytes4[] memory interfaceIds
    ) internal view returns (bool[] memory) {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = supportsERC165InterfaceUnchecked(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!supportsERC165InterfaceUnchecked(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165Upgradeable.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity 0.8.10;

import "./IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
/* solhint-disable */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {}

    function __ERC165_init_unchained() internal onlyInitializing {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity 0.8.10;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
/* solhint-disable */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981Upgradeable.sol)

pragma solidity 0.8.10;

import "../ERC165/IERC165Upgradeable.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981Upgradeable is IERC165Upgradeable {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity 0.8.10;

import "./ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

/**
 * @title Appending URI storage utilities onto template ERC721 contract
 * @author highlight.xyz and OpenZeppelin
 * @dev ERC721 token with storage based token URI management. OpenZeppelin template edited by Highlight
 */
/* solhint-disable */
abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    /**
     * @notice Throw when token doesn't exist
     */
    error TokenDoesNotExist();

    function __ERC721URIStorage_init() internal onlyInitializing {}

    function __ERC721URIStorage_init_unchained() internal onlyInitializing {}

    using StringsUpgradeable for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) internal _tokenURIs;

    /**
     * @dev Hashed rotation key data
     */
    bytes internal _hashedRotationKeyData;

    /**
     * @dev Hashed base uri data
     */
    bytes internal _hashedBaseURIData;

    /**
     * @dev Rotation key
     */
    uint256 internal _rotationKey;

    /**
     * @dev Contract baseURI
     */
    string public baseURI;

    /**
     @notice Emitted when base uri is set
     * @param oldBaseUri Old base uri
     * @param newBaseURI New base uri
     */
    event BaseURISet(string oldBaseUri, string newBaseURI);

    /**
     * @dev Set contract baseURI
     */
    function _setBaseURI(string memory newBaseURI) internal {
        emit BaseURISet(baseURI, newBaseURI);

        baseURI = newBaseURI;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            _revert(TokenDoesNotExist.selector);
        }

        string memory _tokenURI = _tokenURIs[tokenId];

        // If there is no token URI, return the base URI.
        if (bytes(_tokenURI).length == 0) {
            return super.tokenURI(tokenId);
        }

        return _tokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity 0.8.10;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "../ERC165/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
/* solhint-disable */
contract ERC721Upgradeable is
    Initializable,
    ContextUpgradeable,
    ERC165Upgradeable,
    IERC721Upgradeable,
    IERC721MetadataUpgradeable
{
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: Invalid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, "/", tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: already owns");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller unauthorized");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller unauthorized");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: invalid receiver");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data), "ERC721: invalid receiver");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: zero address");
        require(!_exists(tokenId), "ERC721: token minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: from not owner");
        require(to != address(0), "ERC721: to the zero address");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfers(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Hook that is called after a set of serially-ordered token IDs
     * have been transferred.
     *
     * `startTokenId` - the first token ID to be transferred.
     *
     * Calling conditions:
     *
     * - `from` and `to` are both non-zero, since this is only invoked ont transfers
     */
    function _afterTokenTransfers(address from, address to, uint256 tokenId) internal virtual {}

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Added by Highlight to facilitate updating of name and symbol
     */
    function _setContractMetadata(string calldata newName, string calldata newSymbol) internal {
        _name = newName;
        _symbol = newSymbol;
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, data) returns (
                bytes4 retval
            ) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: invalid receiver");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure virtual {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity 0.8.10;

import "./IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
/* solhint-disable */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity 0.8.10;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
/* solhint-disable */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity 0.8.10;

import "../ERC165/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
/* solhint-disable */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
/* solhint-disable */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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