// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";
import { InitializableStorage } from "./InitializableStorage.sol";

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
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
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
        bool isTopLevelCall = !InitializableStorage.layout()._initializing;
        require(
            (isTopLevelCall && InitializableStorage.layout()._initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && InitializableStorage.layout()._initialized == 1),
            "Initializable: contract is already initialized"
        );
        InitializableStorage.layout()._initialized = 1;
        if (isTopLevelCall) {
            InitializableStorage.layout()._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            InitializableStorage.layout()._initializing = false;
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
        require(!InitializableStorage.layout()._initializing && InitializableStorage.layout()._initialized < version, "Initializable: contract is already initialized");
        InitializableStorage.layout()._initialized = version;
        InitializableStorage.layout()._initializing = true;
        _;
        InitializableStorage.layout()._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(InitializableStorage.layout()._initializing, "Initializable: contract is not initializing");
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
        require(!InitializableStorage.layout()._initializing, "Initializable: contract is initializing");
        if (InitializableStorage.layout()._initialized < type(uint8).max) {
            InitializableStorage.layout()._initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return InitializableStorage.layout()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return InitializableStorage.layout()._initializing;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import { Initializable } from "./Initializable.sol";

library InitializableStorage {

  struct Layout {
    /*
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 _initialized;

    /*
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool _initializing;
  
  }
  
  bytes32 internal constant STORAGE_SLOT = keccak256('openzeppelin.contracts.storage.Initializable');

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import { PausableUpgradeable } from "./PausableUpgradeable.sol";

library PausableStorage {

  struct Layout {

    bool _paused;
  
  }
  
  bytes32 internal constant STORAGE_SLOT = keccak256('openzeppelin.contracts.storage.Pausable');

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import { PausableStorage } from "./PausableStorage.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    using PausableStorage for PausableStorage.Layout;
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        PausableStorage.layout()._paused = false;
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
        return PausableStorage.layout()._paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        PausableStorage.layout()._paused = true;
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
        PausableStorage.layout()._paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import { ReentrancyGuardUpgradeable } from "./ReentrancyGuardUpgradeable.sol";

library ReentrancyGuardStorage {

  struct Layout {

    uint256 _status;
  
  }
  
  bytes32 internal constant STORAGE_SLOT = keccak256('openzeppelin.contracts.storage.ReentrancyGuard');

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import { ReentrancyGuardStorage } from "./ReentrancyGuardStorage.sol";
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
    using ReentrancyGuardStorage for ReentrancyGuardStorage.Layout;
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        ReentrancyGuardStorage.layout()._status = _NOT_ENTERED;
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
        require(ReentrancyGuardStorage.layout()._status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        ReentrancyGuardStorage.layout()._status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        ReentrancyGuardStorage.layout()._status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
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
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
/* ApeFathers.sol - ApeFathers NFT Contract
    * NFT OWNER AGREEMENT

    This “Owner Agreement” is between and by GSKNNFT Inc. (“Licensor”) and the individual or entity that owns a Digital Asset (as defined below) (the “Owner”), and is effective as of the date ownership of the Digital Asset is transferred to the Owner (the “Effective Date”).
    he Licensor shall retain all rights, including personal and commercial Intellectual Property rights not expressly granted herein, title, and interest in and to the following;    (i) GSKNNFT Inc. and all associated Digital Assets, including any Digital Objects directly associated with the Main Asset.
        (ii) The ApeFathers NFT Brand and any associated documentation, codebase, materials, products, events, contracts, agreements, smart contracts, Digital Asset(s), blockchain technology, or any and all products, services and associated items or methods created by, and released by GSKNNFT Inc. 
        (iii) "GSKNNFT BurnToClaim ERC721A Contract" and any associated documentation, materials, codebase, contracts, smart contract, 

    DEFINITIONS.
    For the purpose of this Owner Agreement, the following terms shall have the following meanings:
        "Digital Asset" refers to the non-fungible token (NFT) representing a unique digital object or artwork.
        "Digital Object" refers to the digital content associated with the Digital Asset.
        "Owner" refers to the individual or entity holding the Digital Asset.
        "Licensor" refers to GSKNNFT Inc., which grants the license to use the Digital Object.
        "Affiliate" refers to any entity that directly or indirectly controls, is controlled by, or is under common control with the Licensor.

    OWNER ACKNOWLEDGES RECEIPT AND UNDERSTANDING OF THIS OWNER AGREEMENT, AND AGREES TO BE BOUND BY ITS TERMS.
    OWNER’S ACCEPTANCE OF A DIGITAL ASSET SHALL BE DEEMED ACCEPTANCE OF THESE TERMS AND CONSENT TO BE GOVERNED THEREBY.
    IF THE OWNER DOES NOT AGREE TO BE BOUND BY THESE TERMS, THIS LICENSE AUTOMATICALLY TERMINATES.

    In consideration of the premises and the mutual covenants set forth herein and for other good and valuable consideration, the receipt and sufficiency of which is hereby acknowledged, and intending to be bound hereby, the parties agree as follows:

    1. LICENSES & RESTRICTIONS.
        1.1 NFT. These “NFTs” are defined as non-fungible tokens.
        Ownership of which this specific collection is registered on the ethereum blockchain as;
            Name: “The ApeFathers NFT” (the “Business”) - the NFT "project" operations, employees, agents, representatives and subcontractors,
            Token Tracker: “DAPES” (the “Token”) - the tracker ID for the Digital Assets on the ethereum blockchain,
            Smart-Contract: “ApeFathers.sol” (the “NFT Smart-Contract”) - this specific instance of the ApeFathers.sol smart contract deployed on the ethereum blockchain,
            Artist: "Tahliazr" (the "Artist") - designed and created the traits conceptualized by GSKNNFT Inc., and furthermore signed the contract ("NFT Licensing Agreement") to transfer the Licenses of the traits created by their ("The Artist's") own hand,
            Artist Contract: ("NFT Licensing Agreement") - Contract for the transfer of original Intellectual Property of the individual trait images created by The Artist and formally signed by both parties (The Artist and GSKNNFT Inc.),
            Created by: (“Licensor”) - Gordon Skinner of GSKNNFT Inc. ("@GSKNNFT", "gsknnft.eth", "gsknnft@gmail.com").

        For the case of this NFT Owner Agreement; any NFT within The ApeFathers NFT collection sold or otherwise transferred to Owner pursuant to this Agreement shall be a “Digital Asset.”
        The Digital Asset(s) are associated with digital objects (which may include images and/or other digital works) (“Digital Object(s)”).
        A copy of this contract can be found linked to the Digital Asset, available for Owner's review at any time, and enforceable unless voided by its terms.
        The Licensor guarantees that the IP for the Digital Objects created for The ApeFathers NFT collection has been agreed upon, signed in a separate contract ("NFT Licensing Agreement"), and is owned and paid in full by GSKNNFT Inc. This includes;    The IP Agreement formally signed by both parties ("The Artist") and Licensor, who created the traits for compiling the Digital Object(s) through random generation.
        A copy of the Artist Contract can be found on the Official The ApeFathers NFT website, which can be referenced and reviewed by Owner and Licensor for review at any time; and enforceable unless voided by the terms of either Agreement mentioned (.
        As detailed below, the Owner may own a Digital Asset, with a full commercial IP license to the Digital Object(s) subject to the terms and conditions set forth herein.
        Purchase of the ApeFathers NFT (the “Main Asset”) may entitle the purchaser to be declared the Owner, and to utilize their specific held asset(s) for their own personal use of the Intellectual Property (“IP”) of ONLY the associated media tied to the Digital Asset on the blockchain.
        For the avoidance of doubt, the term “Digital Asset(s),” as used herein, includes both the Main Asset and any Digital Objects directly associated with the Main Asset.

    1.2. Digital Asset(s).
        The Digital Asset(s) are subject to copyright and other intellectual property protections, which rights are and shall remain owned by solely the Owner of the individual NFT(s).

    1.3. Licenses.
        Main Asset.
            Upon a valid transfer of Main Asset to Owner, Licensor hereby grants Owner a limited, transferable, non-sublicensable, royalty free license to use, publish and display the Digital Object(s) associated with the Main Asset during the Term, subject to Owner’s compliance with the terms and conditions set forth herein, including without limitation, any restrictions in Section 1.4 below, solely for the following purposes: 
                (a) for their own personal, or commercial use; or 
                (ii) to display the Main Asset for resale.
        Upon expiration of the Term or breach of any conditions of this Owner Agreement by Owner, all license rights shall immediately terminate.

    1.4. License Restrictions.
        The Digital Asset(s) provided pursuant to this Owner Agreement are licensed, not sold, and Owner receives title to or ownership of the Digital Asset(s) or the intellectual property rights therein.
        Except for the license expressly set forth herein, no other rights (express or implied) to the Digital Assets(s) are granted. Licensor reserves all rights not expressly granted.
        Subject to the terms and conditions of this Agreement, the Licensor grants the Owner a non-exclusive, non-transferable license to use the full Commercial IP solely for the purpose of utilizing the Main Asset and any associated Digital Objects held by the Owner on the blockchain.
        Without limiting the generality of the foregoing, Owner shall have the license through this agreement to: 
            (a) copy, modify, or distribute the Digital Asset(s);
            (b) use the Digital Asset(s) to advertise, market or sell a product and/or service;
            (c) incorporate the Digital Asset(s) in videos or other media; or
            (d) sell merchandise incorporating the Digital Asset(s).
        Upon a permitted transfer of ownership of the Digital Asset(s) by Owner to a third party, the license to the Digital Assets(s) associated therewith shall be transferable solely subject to the terms and conditions set forth herein, including those in Section 6.3, and the Owner’s license to such Digital Assets(s) terminates immediately upon transfer to such third party.
        Upon transfer of the NFT to a new owner, all ownership and rights to the underlying IP associated with the NFT are also transferred to the new owner, and for the sake of this agreement, the transfer date will be considered the "Effective Date" of the individual, now representative as the "Owner", and subject to any limitations or restrictions explicitly stated in this agreement.
        Upon a non-permitted transfer of ownership of the Digital Asset(s) by Owner to a third party, the Owner’s license to the Digital Assets(s) associated therewith terminates immediately, and any purported transfer of the license to such Digital Assets(s) to such third party shall be void.
         Owner shall not, and shall not permit any third party to, do any of the following:
            (a) Use the Digital Asset in connection with any illegal activity or for any unlawful purpose;
            (b) use or publish any modification of the Digital Asset(s) in any way that would be immoral or goes against the standards of practice set out by “The ApeFathers NFT”, and/or GSKNNFT Inc, including without limitation, any link or other reference to license information.
            (c) Use the Digital Asset in a manner that infringes the rights of any third party, including but not limited to intellectual property rights;
            (d) Remove or alter any trademark, logo, copyright, other legal notices or proprietary notices, metadata legends, symbols, or labels associated with, in or on the Digital Asset(s) or Digital Object(s);
            (e) Transfer the Digital Asset in violation of any applicable law, including without limitation the securities laws of any jurisdiction;
            (f) Use the Digital Asset to compete with Licensor or the Business in any way.
        Failure to comply with the conditions set forth in Sections 1.3 and 1.4 constitutes a material breach.

    2. IP Rights in the Digital Asset.
        2.1. Ownership.
            All rights, title, and interest in and to the Digital Object(s), including all intellectual property rights therein, are and shall remain the exclusive property of the Licensor and its licensors, as applicable. Owner's rights to use the Digital Object(s) are limited to those expressly granted in this Owner Agreement. No other rights with respect to the Digital Object(s) or any related intellectual property rights are implied.
        2.2. Reservation of Rights.
            Except for the limited rights and licenses expressly granted under this Owner Agreement, nothing in this Owner Agreement grants, by implication, waiver, estoppel, or otherwise, to Owner or any third party any intellectual property rights or other right, title, or interest in or to the Digital Object(s) or any other content owned or licensed by the Licensor.
            The Owner shall not, and shall not permit the use of a third party to reproduce, distribute, display, or create derivative works based on the IP without the prior written consent of the Owner.
            All Intellectual Property rights of the material stated in this contract belong to the Owner, subject to the terms and conditions, except where otherwise stated or provided by the Licensor ("GSKNNFT Inc.").
            These rights will remain valid as explicitly stated herein, including; through any future Owner-invoked evolutions (changes as per the Owner's own decision with the proof of such logged as a transaction on the Ethereum blockchain), specifically and exclusively offered by the Licensor ("GSKNNFT Inc.") through any mechanism, platform, tool, or method used.

    3. Replica(s).
        The owner understands and agrees that the Licensor has no control over, and shall have no liability for, any Replicas.
        Owner understands and agrees that Platforms and/or Replica(s) may become unavailable or cease to exist at any time.

    4. Specific Disclaimer.
        LICENSOR MAKES NO WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTY OF NONINFRINGEMENT.
        OWNER ACKNOWLEDGES AND AGREES THAT THE DIGITAL ASSET IS PROVIDED “AS IS” AND WITHOUT WARRANTY OF ANY KIND, WHETHER EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.
        Owner agrees not to use the Permissable Work, Digital Asset(s) or Digital Object(s) to commit any criminal offense, nor to distribute any malicious, harmful, offensive or obscene material.
        Owner understands and accepts the risks of blockchain technology.
        Without limiting the generality of the foregoing, Licensor does not warrant that the Digital Asset(s) will perform without error.
        Further, Licensor provides no warranty regarding, and will have no responsibility for, any claim arising out of:
            (i) a modification of the Digital Asset(s) made by anyone other than Licensor and/or Owner, unless Licensor or Owner approves such modification in writing;
            (ii) Owner’s misuse of or misrepresentation regarding the Digital Asset(s); or 
            (iii) any technology, including without limitation, any Replica or Platform, that fails to perform or ceases to exist.
        Licensor shall not be obligated to provide any support to Owner or any subsequent owner of the Digital Asset(s).

    5. LIMITATION OF LIABILITY; INDEMNITY.
        5.1. Dollar Cap.
            LICENSOR’S CUMULATIVE LIABILITY FOR ALL CLAIMS ARISING OUT OF OR RELATED TO THIS OWNER AGREEMENT WILL NOT EXCEED THE AMOUNT OWNER(S) PAID THE LICENSOR FOR DIGITAL ASSET(S).
        5.2. Excluded Damages. 
            THE LICENSOR AND ITS AFFILIATES WILL NOT BE LIABLE FOR DAMAGES SUCH AS LOST PROFITS, LOSS OF BUSINESS, LOSS OF REVENUE, OR ANY OTHER SIMILAR DAMAGES.
        5.3. Clarifications & Disclaimers.
        This section contains important information about the limitations of liability. It is broken down into smaller subsections for ease of reading.
            The language has been simplified and made more accessible to non-legal professionals.
            The liabilities limited by this section apply:
                (a) to liability for negligence;
                (b) no matter what legal action is taken;
                (c) even if the owner is advised in advance of the possibility of the damages in question and even if such damages were foreseeable; and
                (d) even if licensor's remedies fail of their essential purpose.
            If applicable law limits the application of the provisions of this section, licensor’s liability will be limited to the maximum extent permissible.
            LICENSOR DOES NOT REPRESENT OR WARRANT THAT THE DIGITAL ASSET WILL BE SECURE, UNINTERRUPTED, ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED.
            OWNER ASSUMES ALL RISKS ASSOCIATED WITH THE USE OF THE DIGITAL ASSET.
            IN NO EVENT SHALL LICENSOR BE LIABLE TO OWNER OR ANY THIRD PARTY FOR ANY INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES OF ANY KIND, INCLUDING BUT NOT LIMITED TO LOST PROFITS, LOST REVENUE, LOST DATA, OR BUSINESS INTERRUPTION, ARISING OUT OF OR IN CONNECTION WITH THIS OWNER AGREEMENT OR THE USE OR INABILITY TO USE THE DIGITAL ASSET, WHETHER BASED ON CONTRACT, TORT, STRICT LIABILITY, OR ANY OTHER THEORY OF LIABILITY, EVEN IF LICENSOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
            For the avoidance of doubt, Licensor’s liability limits and other rights set forth in this section apply likewise to Licensor’s affiliates, licensors, suppliers, advertisers, agents, sponsors, directors, officers, employees, consultants, and other representatives.
           
        5.4. Indemnity.
            Owner will indemnify, defend and hold harmless Licensors and its affiliates, and any of their respective officers, directors, employees, representatives, contractors, and agents (“Licensor Indemnitees”) from and against any and all claims, causes of action, liabilities, damages, losses, costs and expenses (including reasonable attorneys' fees and legal costs, which shall be reimbursed as incurred) arising out of, related to, or alleging Owner’s breach of any provision in this agreement, including but not limited to Owner’s failure to comply with the licensing conditions set forth in Section 1.

    6. Term & Termination.
        6.1. Term.
            This Owner Agreement shall continue until terminated pursuant to Subsection 6.2 or 6.3 below (the “Term”).
        6.2. Termination for Transfer.
            The license granted in Section 1 only applies to the extent that the owner continues to possess the Digital Asset.
            If the owner transfers partial ownership of the Digital Asset(s) through fractionalized ownership, the owner with the majority fractionalized portion of the Digital Asset(s) retains the Intellectual Property and any rights and limitations as stated by this agreement shall be considered valid and in force.
            If at any time the Owner sells, trades, donates, gives away, transfers, or otherwise disposes of a Digital Asset for any reason, this Owner Agreement, including without limitation, the license rights granted to Owner in Section 1 will immediately terminate, with respect to such Digital Asset, without the requirement of notice, and Owner will have no further rights in or to such Digital Asset or Digital Object(s) associated therewith.
        6.3. Termination for Cause.
            Licensor may terminate this Owner Agreement for Owner’s material breach by written notice specifying in detail the nature of the breach, effective in thirty (30) days unless the Owner first cures such breach, or effective immediately if the breach is not subject to cure.
        6.4. Effects of Termination.
            Upon termination of this Owner Agreement, Owner shall cease all use of the Digital Object(s) and delete, destroy, or return all copies of the Digital Object(s) in its possession or control.
            In the event of termination, any amounts paid by the Owner to the Licensor for the Digital Asset(s) shall be deemed earned and non-refundable.
            Owner shall not be entitled to any refund or compensation in connection with the termination of this Owner Agreement.
        6.4. Effects of Termination.
            Upon termination of this Owner Agreement, Owner shall cease all use of the Digital Object(s) and delete, destroy, or return all copies of the Digital Object(s) in its possession or control.
            Any provision of this Owner Agreement that must survive to fulfill its essential purpose will survive termination or expiration.

    7. MISCELLANEOUS.
        7.1. Independent Contractors.
            The parties are independent contractors and shall so represent themselves in all regards.
            Neither party is the agent of the other, and neither may make commitments on the other’s behalf.
        7.2. Force Majeure.
            No delay, failure, or default, other than a failure to pay fees when due, will constitute a breach of this Owner Agreement to the extent caused by acts of;
                war, terrorism, hurricanes, earthquakes, epidemics, other acts of God or of nature, strikes or other labor disputes, riots or other acts of civil disorder, embargoes, government orders responding to any of the foregoing, or other causes beyond the performing party’s reasonable control.
        7.3. Counterparts.
             This Agreement may be executed in counterparts, each of which shall be deemed an original, but all of which together shall constitute one and the same instrument.
        7.4. Assignment & Successors. 
            Subject to the transfer restrictions set forth herein, including in Sections 1.4 and this Section 6.3, Owner may transfer ownership of the Digital Asset(s) to a third-party, provided that Owner:
                (i) has not breached this Owner Agreement prior to the transfer;
                (ii) notifies such third party that Licensor shall receive a royalty equal of up to 15% of the purchase price for any sale of a Digital Asset by such third-party; and
                (iii) Owner ensures that such third party is made aware of this Owner Agreement and agrees to be bound by the obligations and restrictions set forth herein.
            If the third party does not agree to be bound by the obligations and restrictions set forth herein, then the licenses granted herein shall terminate.
            In no case shall any of the license rights or other rights granted herein be transferrable apart from the transfer of ownership of the entire Digital Asset, proof of which will be logged on the ethereum blockchain.
            Except to the extent forbidden in this Owner Agreement, this agreement will be binding upon and inure to the benefit of the parties’ respective successors and assigns.
            Any purported assignment or transfer in violation of Section 7.4 herein, including the transfer restriction in Section 1.4, shall be void.
            Only a single entity may own each entire Digital Asset at any time, with the exclusion of fractionalization ownership, and only the entities previously named shall have a license to the Digital Object(s) associated therewith.
            Owner may fractionalize the use of Digital Asset, but ownership is never forfeited:        
                In the case of fractionalized ownership, the owner with the majority fractionalized portion of the Digital Asset(s) retains the Intellectual Property and any rights and limitations as stated by this agreement shall be considered valid and in force.
                While multiple Owners may consider themselves holders of the NFT through fractionalization, as per this agreement, the full commercial IP rights remain with the majority holder of the fractionalized Digital Asset.
                No claim shall be made by any fractionalized NFT Owner towards the Licensor (GSKNNFT Inc.) or it's affiliates or associates with regards to IP ownership and member benefits of The ApeFathers NFT brand.
                Upon retaining a fractionalized minority of the Digital Asset(s), the fractionalized owner will be considered excluded, as not the majority holder, from any and all terms and conditions set forth within this Owner Agreement.
            Upon transfer of a Digital Asset from a first Owner to a second Owner, the license to the first owner for the Digital Object(s) associated with such Digital Asset shall immediately terminate.
        7.5. Severability.
            To the extent permitted by applicable law, the parties hereby waive any provision of law that would render any clause of this Owner Agreement invalid or otherwise unenforceable in any respect.
            In the event that a provision of this Owner Agreement is held to be invalid or otherwise unenforceable, such provision will be interpreted to fulfill its intended purpose to the maximum extent permitted by applicable law, and the remaining provisions of this Owner Agreement will continue in full force and effect.
        7.6. No Waiver.
            Neither party will be deemed to have waived any of its rights under this Owner Agreement by lapse of time or by any statement or representation other than by an authorized representative in an explicit written waiver.
            No waiver of a breach of this Owner Agreement will constitute a waiver of any other breach of this Owner Agreement.
        7.7. Choice of Law & Jurisdiction:
            This Owner Agreement is governed by Canadian law, or any Federal, Provincial, Territorial, or State law where the Licensor (GSKNNFT INC.) is located and conducts their business in the future, and both parties submit to the exclusive jurisdiction of the Provincial and Federal courts located in Canada or any federal jurisdiction as per the location of the Licensor, and waive any right to challenge personal jurisdiction or venue.
        7.8. Entire Agreement.
            This Owner Agreement sets forth the entire agreement of the parties and supersedes all prior or contemporaneous writings, negotiations, and discussions with respect to its subject matter, exclusive of the NFT Licensing Agreement as stated herewithin..
            Neither party has relied upon any such prior or contemporaneous communications, exclusive of the NFT Licensing Agreement as stated herewithin.
        7.9. Amendment.
            This Owner Agreement may not be amended in any way except through a written agreement by authorized representatives of the Licensor and the current owner of the Digital Asset(s).

     8.0 Disclaimer.
        The ApeFathers NFT is not an investment business.
        GSKNNFT Inc. and The ApeFathers NFT brand offer a gamified NFT ecosystem and community membership access.
        All elements of the Digital Asset(s) are subject to change without notice.
        Any future token (on-chain or off-chain) that is released from or utilized by The ApeFathers NFT or GSKNNFT Inc. should only be used within the network of projects permitted by GSKNNFT Inc. and The ApeFathers NFT brand  */
// Copyright (c) 2023, GSKNNFT Inc

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity 0.8.20;

//ERC2535 DIAMOND & ERC721AUPGRADEABLE - GSKNNFT INC. - 2023
import {LibDiamond} from "./libraries/LibDiamond.sol";
import {ERC721AUpgradeable} from "./ERC721A-Upgradeable/ERC721AUpgradeable.sol";
import {LibDiamondDapes} from "./libraries/LibDiamondDapes.sol";
import {IDiamondCut} from "./interfaces/IDiamondCut.sol";
import {IERC165} from "./interfaces/IERC165.sol";
import {INFT} from "./interfaces/INFT.sol";
import {IApeFathers} from "./interfaces/IApeFathers.sol";
import {PausableUpgradeable} from "@gnus.ai/contracts-upgradeable-diamond/contracts/security/PausableUpgradeable.sol";
import {ReentrancyGuardUpgradeable as ReentrancyGuard} from "@gnus.ai/contracts-upgradeable-diamond/contracts/security/ReentrancyGuardUpgradeable.sol";
import {AddressUpgradeable as Address} from "@gnus.ai/contracts-upgradeable-diamond/contracts/utils/AddressUpgradeable.sol";
import {SafeMathUpgradeable as SafeMath} from "@gnus.ai/contracts-upgradeable-diamond/contracts/utils/math/SafeMathUpgradeable.sol";
import {StringsUpgradeable as Strings} from "@gnus.ai/contracts-upgradeable-diamond/contracts/utils/StringsUpgradeable.sol";

contract ApeFathers is ERC721AUpgradeable, ReentrancyGuard, PausableUpgradeable, IApeFathers {
  using Address for address;
  using SafeMath for uint256;
  using Strings for uint256;
  using Strings for string;
  using LibDiamond for LibDiamond.DiamondStorage;
  using LibDiamond for LibDiamond.FacetData;
  using LibDiamondDapes for LibDiamondDapes.AdminStorage;
  using LibDiamondDapes for LibDiamondDapes.DiamondDapesStruct;
  INFT internal nft; // Instantiate the INFT interface

  event Received(address indexed sender, uint256 indexed value);
  event DiamondLoupeFacetsChanged(address[] _facets);

  /**
   * @param _contractOwner "the owner of the contract. With default DiamondCutFacet, this is the sole address allowed to make further cuts."
   * @param _diamondCutFacet "the address of the DiamondCutFacet. This is the contract that performs the cuts."
   */
  constructor(address _contractOwner, address _diamondCutFacet) payable {
    LibDiamond.setContractOwner(_contractOwner);
    LibDiamond.diamondStorage().contractOwner = _contractOwner;
    LibDiamondDapes.adminStorage().admins.push(msg.sender);
    LibDiamondDapes.adminStorage().admins.push(_contractOwner);

    // Add the diamondCut external function from the diamondCutFacet
    IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
    bytes4[] memory functionSelectors = new bytes4[](1);
    functionSelectors[0] = IDiamondCut.diamondCut.selector;
    cut[0] = IDiamondCut.FacetCut({
      facetAddress: _diamondCutFacet,
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: functionSelectors
    });
    LibDiamond.diamondCut(cut, address(0), "");
    emit Stage1Initialized(address(this), _contractOwner, true);
    initialize(_contractOwner);
  }

  /**
   * @notice This function is used to initialize the contract state variables
   */
  function initialize(address _contractOwner) internal initializer initializerERC721A {
    require(!LibDiamondDapes.stagedInitStorage().diamondInitialized, "Contract ALREADY initialized");
    __ERC721A_init_unchained("ApeFathers", "DAPES"); // Initialize the ERC721AUpgradeable NFT contract
    __ReentrancyGuard_init_unchained(); // Initialize the ReentrancyGuardUpgradeable
    __Pausable_init_unchained(); // Initialize the PausableUpgradeable
    LibDiamond.diamondStorage().supportedInterfaces[0x80ac58cd] = true; // IERC721
    LibDiamond.diamondStorage().supportedInterfaces[0x5b5e139f] = true; // IERC721Metadata
    LibDiamond.diamondStorage().supportedInterfaces[0x2a55205a] = true; // IERC2981
    LibDiamond.diamondStorage().supportedInterfaces[0x94c9b41a] = true; // IERC2535
    LibDiamond.diamondStorage().supportedInterfaces[0x8e234801] = true; // ERC2981 Royalty Standard
    LibDiamondDapes.DiamondDapesStruct storage dds = LibDiamondDapes.diamondDapesStorage();
    dds.diamondAddress = payable(this); // The address of the diamond
    dds.nftAddress = 0x6468f4243Faa8C3330bAAa0a7a138E2e5628C6f5; // The address of the NFT contract for the INFT instance
    nft = INFT(dds.nftAddress); // The instantiation of the NFT contract instance        
    LibDiamondDapes.stagedInitStorage().diamondInitialized = true;
    _mintERC2309(_contractOwner, 403);
    emit DiamondInitialized(address(this), _contractOwner, true);
  }

  function _authorizeUpgrade(
    address newImplementation,
    string memory _version
  ) internal returns (bool success, address) {
    require(newImplementation != address(0), "NOT_ALLOWED");
    LibDiamond.enforceIsContractOwner();
    if (msg.sender == LibDiamond.contractOwner() || newImplementation != address(0)) {
      emit ContractUpgraded(msg.sender, newImplementation, true, _version);
      return (true, newImplementation);
    } else {
      emit ContractUpgradeRejected(msg.sender, newImplementation, false, LibDiamondDapes.diamondDapesStorage().version);
      revert("UPGRADE_REJECTED");
    }
  }

  modifier onlyAllowedFacet() {
    if (LibDiamondDapes.adminStorage().allowedFacets[msg.sender]) {
      _;
    } else {
      LibDiamond.enforceIsContractOwner();
      _;
    }
    revert TransferToNonERC721ReceiverImplementer();
  }

  modifier onlyOwner() {
    LibDiamond.enforceIsContractOwner();
    _;
  }

  function pause() external onlyOwner {
    _pause();
    LibDiamondDapes.diamondDapesStorage().isPaused = true;
  }

  function unpause() external onlyOwner {
    _unpause();
    LibDiamondDapes.diamondDapesStorage().isPaused = false;
  }

  /**
   * @notice unwraps total supply of tokens
   */
  function _totalSupply() external view virtual returns (uint256) {
    return totalSupply();
  }

  /**
   * @notice Allow owner to send gifts to multiple addresses
   * @param receivers - array of addresses to receive tokens
   * @param quantities - array of number of tokens to mint for each address
   */
  function gift(address[] calldata receivers, uint256[] calldata quantities) external nonReentrant onlyOwner {
      require(receivers.length == quantities.length, "RECEIVERS_AND_QUANTITIES_MUST_BE_SAME_LENGTH");
      uint256 totalMint = 0;
      for (uint256 i = 0; i < quantities.length; i++) {
          totalMint += quantities[i];
      }
      require(totalSupply() + totalMint <= LibDiamondDapes.MAX_SUPPLY, "MAX_SUPPLY_EXCEEDED");
      
      for (uint256 i = 0; i < receivers.length; i++) {
          _safeMint(receivers[i], quantities[i]);
      }
  }




  /**
   * @notice Returns the maximum token supply
   * @return uint256 representing the maximum token supply
   */
  function maxSupply() external pure returns (uint256) {
    return LibDiamondDapes.MAX_SUPPLY;
  }

  /**
   * @dev Sets the first tokenId to be minted to 1
   * @return uint256 representing the first tokenId to be minted in the collection
   */
  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function nextTokenId() external view virtual returns (uint256) {
    return _nextTokenId();
  }

  /**
   * @notice Returns the owner of the contract
   * @return address representing the owner of the contract
   */
  function getOwner() external view returns (address) {
    return LibDiamond.diamondStorage().contractOwner;
  }

  /**
   * @dev Returns the if token in exists.
   * @return bool representing if the token exists
   */
  function exists(uint256 tokenId) external view returns (bool) {
    if (!_exists(tokenId)) {
      return false;
    }
    return true;
  }

  /**
   * @dev Token Burn Function.
   * @param tokenId - the tokenId to burn
   * @notice Only the owner of the token can burn it.
   * The function must be activated by the contract owner.
   */
  function burn(uint256 tokenId) external virtual nonReentrant {
    if (!LibDiamondDapes.diamondDapesStorage().isTokenBurnActive) revert("TokenBurnNotActive");
    require(msg.sender == ownerOf(tokenId), "BurnCallerNotOwner");
    require(getApproved(tokenId) == address(this), "BurnCallerNotApproved");
    _burn(tokenId);
    emit Burned(msg.sender, tokenId);
  }

  event Minted(address indexed _to, uint256 indexed quantity);

  function mint(address _to, uint256 quantity) public payable nonReentrant {
    require(msg.sender != address(0), "MintToZeroAddress");
    require(msg.sender == tx.origin, "REVERT: Use a direct EOA to mint");
    require(quantity > 0, "MintZeroQuantity");
    require(quantity <= LibDiamondDapes.diamondDapesStorage().batchSizePerTx, "MAX_MINTS_PER_TX_EXCEEDED");
    if (
      LibDiamondDapes.diamondDapesStorage().isPublicSaleActive == true &&
      quantity + _nextTokenId() <= LibDiamondDapes.diamondDapesStorage().publicCloseTokenId
    ) {
     require(msg.value >= LibDiamondDapes.diamondDapesStorage().publicPrice * quantity, "InsufficientFunds_mint");
      _safeMint(_to, quantity);
      emit Minted(msg.sender, quantity);
      if (_nextTokenId() >= LibDiamondDapes.diamondDapesStorage().publicCloseTokenId) {
        LibDiamondDapes.diamondDapesStorage().isPublicSaleActive = false;
      }
    } else {
      if (totalSupply() >= LibDiamondDapes.MAX_SUPPLY) {
        LibDiamondDapes.diamondDapesStorage().isPublicSaleActive = false;
        LibDiamondDapes.diamondDapesStorage().isBurnClaimActive = false;
      } else {
        revert("MintNotAvailable");
      }
    }
  }

  /**
   * @notice Wraps and exposes publicly _totalMinted() from ERC721A
   */
  function totalMinted() external view returns (uint256) {
    return _totalMinted();
  }

  /**
   * @notice Wraps and exposes publicly _numberMinted() from ERC721A
   */
  function numberMinted(address owner) external view returns (uint256) {
    return _numberMinted(owner);
  }

  function setTokenURI(uint256 tokenId) external onlyOwner {
    _setTokenURI(tokenId);
  }

  /**
   * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
    * @param tokenId - the tokenId to set the URI for
    * @notice Only the owner of the constract can set it's URI.
   */
  function _setTokenURI(uint256 tokenId) internal virtual {
      LibDiamondDapes.DiamondDapesStruct storage dds = LibDiamondDapes.diamondDapesStorage();
      require(_exists(tokenId), "LibDiamondDapes: URI set of nonexistent token");
      
      bytes32 baseURIHash = keccak256(bytes(dds.baseURI));
      bytes32 emptyStringHash = keccak256(bytes(""));
      
      if (baseURIHash == emptyStringHash) {
          LibDiamondDapes.adminStorage()._tokenURIs[tokenId] = string(abi.encodePacked(dds.uriPrefix, dds.baseURI, _toString(tokenId), dds.uriSuffix));
      }
  }

  
  /** 
   * @dev Reveals the tokenURI of `tokenId`.
   * @param _tokenIds - the tokenId to reveal
    * @notice Only the owner of the constract can reveal it's URI.
  */
  function revealIndividualTokens(uint256[] calldata _tokenIds) external onlyOwner {
    LibDiamondDapes.DiamondDapesStruct storage dds = LibDiamondDapes.diamondDapesStorage();
    for (uint256 i; i < _tokenIds.length; i++) {
      uint256 _tokenId = _tokenIds[i];
      require(!LibDiamondDapes.adminStorage().revealedTokens[_tokenId], "Token already revealed");
      LibDiamondDapes.adminStorage().revealedTokens[_tokenId] = true;
      dds.totalRevealed += 1;

      // Update the tokenURI for the revealed token
      if (bytes(LibDiamondDapes.adminStorage()._tokenURIs[_tokenId]).length == 0) {
        _setTokenURI(_tokenId);
      }
    }
  }

    /**
    * @dev returns the tokenURI of `tokenId`.
    * @param _tokenId - the tokenId to return
    */
  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
      LibDiamondDapes.DiamondDapesStruct storage dds = LibDiamondDapes.diamondDapesStorage();
      LibDiamondDapes.AdminStorage storage aStore = LibDiamondDapes.adminStorage();
      if (!_exists(_tokenId)) revert("URIQueryForNonexistentToken");
      string memory base = dds.baseURI;
      if (dds.revealed == false) {
          if (aStore.revealedTokens[_tokenId] == true) {
              return aStore._tokenURIs[_tokenId];
          } else {
              return dds.hiddenMetadataUri;
          }
      } else if (aStore.revealedTokens[_tokenId] == true) {
          return aStore._tokenURIs[_tokenId];
    } else if (bytes(aStore._tokenURIs[_tokenId]).length == 0) {
        string memory fullURI;
        if (bytes(base).length > 0) {
            fullURI = string(abi.encodePacked(base, _toString(_tokenId), dds.uriSuffix));
        } else {
            fullURI = string(abi.encodePacked(dds.uriPrefix, _toString(_tokenId), dds.uriSuffix));
        }
        return fullURI;
      } else {
          return aStore._tokenURIs[_tokenId];
      }
  }


  function setIndividualTokenURI(uint256 _tokenId, string memory _setURI) external onlyOwner {
    LibDiamondDapes.DiamondDapesStruct storage dds = LibDiamondDapes.diamondDapesStorage();
    LibDiamondDapes.AdminStorage storage aStore = LibDiamondDapes.adminStorage();

    // Ensure that metadata is not frozen
    require(dds.metadataFrozen == false, "ApeFathers: metadata is frozen");

    // Check if the token exists
    require(_exists(_tokenId), "ApeFathers: token does not exist");

    string memory base = _baseURI();
    string memory fullURI;
    if (bytes(_setURI).length > 0) {
      fullURI = string(abi.encodePacked(_setURI, _toString(_tokenId), dds.uriSuffix));
    } else if (bytes(base).length > 0) {
      // If a base URI is provided, concatenate the base URI, tokenId, and URI suffix
      fullURI = string(abi.encodePacked(base, _toString(_tokenId), dds.uriSuffix));
    } else {
      // If no base URI is provided, concatenate the URI prefix, tokenId, and URI suffix
      fullURI = string(abi.encodePacked(dds.uriPrefix, _toString(_tokenId), dds.uriSuffix));
    }
    aStore._tokenURIs[_tokenId] = fullURI;
  }
 
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
      return a < b ? a : b;
    }

      /**
    * @dev Function to reveal tokens in batches.
    * @notice can only be called by the contract owner
    */
  function revealTokens() external onlyOwner {
      LibDiamondDapes.DiamondDapesStruct storage dds = LibDiamondDapes.diamondDapesStorage();
      require(this._totalSupply() > 0, "Token supply is 0");
      require(dds.tokensPerBatch > 0, "Tokens per batch must be greater than 0");

      uint256 tokensToReveal = min(dds.tokensPerBatch, this._totalSupply().sub(dds.totalRevealed));
      require(tokensToReveal > 0, "Tokens to reveal must be greater than 0");

      uint256[] memory unrevealedTokens = new uint256[](tokensToReveal);
      uint256 unrevealedCount = 0;

      // Collect unrevealed tokens starting from the last revealed token
      uint256 startTokenId = dds.totalRevealed;
      uint256 endTokenId = startTokenId.add(tokensToReveal).sub(1);
      if (endTokenId >= LibDiamondDapes.MAX_SUPPLY) {
          endTokenId = LibDiamondDapes.MAX_SUPPLY.sub(1);
          dds.collectionRevealed = true; // All tokens have been revealed
      }

      for (uint256 tokenId = startTokenId; tokenId <= endTokenId; tokenId++) {
          if (!LibDiamondDapes.adminStorage().revealedTokens[tokenId]) {
              unrevealedTokens[unrevealedCount] = tokenId;
              unrevealedCount++;
          }
      }

      // Update the tokenURI for the unrevealed tokens
      for (uint256 i = 0; i < unrevealedCount; i++) {
          uint256 tokenId = unrevealedTokens[i];
          LibDiamondDapes.adminStorage().revealedTokens[tokenId] = true;
          dds.totalRevealed += 1;
          _setTokenURI(tokenId);
      }
  }

  /**
   * @dev Returns the base URI set via {_setBaseURI}. This will be
   * the prefix for all tokenURIs post-full reveal. Internal Function that will be
   * called when using 'tokenURI(uint256)' or setting the base in storage.
   */
  function _baseURI() internal view virtual override returns (string memory) {
      return bytes(LibDiamondDapes.diamondDapesStorage().baseURI).length > 0
          ? LibDiamondDapes.diamondDapesStorage().baseURI
          : "";
    }

  /**
   * @dev Unwraps the base URI set via {_setBaseURI} publicly.
   */
  function baseURI() external view returns (string memory) {
    return _baseURI();
  }

 
  event TokenTransferFailed(address indexed from, address indexed to, uint256 indexed tokenId);

  /**
   * @notice Batch Transfer ApeFather NFTs EaStoreier and gaStore efficiently
   */
  function batchTransfer(uint256[] memory _tokenIds, address _to) public nonReentrant {
    uint256 len = _tokenIds.length;
    require(len >= 2, "Must provide at least 2 IDs");
    require(_to != address(0), "Cannot send to 0 address");
    require(_to != msg.sender, "Cannot send to self");
    for (uint256 i = 0; i < len; i++) {
      require(_exists(_tokenIds[i]), "Token does not exist");
      require(msg.sender == ownerOf(_tokenIds[i]) || msg.sender == getApproved(_tokenIds[i]), "Not approved to transfer");
    }
    uint256 i = 0;
    while (i < len) {
      uint256 end = i + LibDiamondDapes.diamondDapesStorage().batchSizePerTx;
      if (end > len) {
        end = len;
      }
      uint256[] memory batchIds = new uint256[](end - i);
      for (uint256 j = i; j < end; j++) {
        batchIds[j - i] = _tokenIds[j];
      }

      // Transfer tokens in a batch and skip over errors
      for (uint256 j = 0; j < batchIds.length; j++) {
        safeTransferFrom(msg.sender, _to, batchIds[j]);
        // Log successful transfer
        emit Transfer(msg.sender, _to, batchIds[j]);
      }
      i += LibDiamondDapes.diamondDapesStorage().batchSizePerTx;
    }
  }


  event BurnClaimComplete(address indexed user, uint256 numberMinted, uint256[] tokenIds);

  /**
   * @notice Error messages for burnClaim
   */
  error TokenCountVerificationFailed(string message);
  error BurnClaimIsNotActive(string message);
  error InvalidClaim(string message);
  error CannotClaimTokenYouDontHold(string message);

  /**
   * @dev Burn ApeDads Tokens and Receive ApeFathers tokens in return - WARNING: THIS ACTION IS IRREVERSABLE. ENSURE YOU ARE AWARE OF THE RISKS OF BURNING YOUR ASSETS.
   * @param _tokenIds - array of token IDs to burn
   * @param verifyNumberOfTokens - number of tokens to verify
   */
  function burnClaim(uint256[] calldata _tokenIds, uint256 verifyNumberOfTokens) public nonReentrant {
    if (!LibDiamondDapes.diamondDapesStorage().isBurnClaimActive) {
      revert BurnClaimIsNotActive("NOT_ACTIVE");
    }
    if (_tokenIds.length != verifyNumberOfTokens) {
      revert TokenCountVerificationFailed("WRONG_#_OF_TOKENS");
    }
    if (_tokenIds.length < 1) {
      revert InvalidClaim("NO_TOKEN_PROVIDED");
    }

    for (uint256 i = 0; i < _tokenIds.length; i++) {
      address owner = nft.ownerOf(_tokenIds[i]);
      if (owner != msg.sender) {
        revert CannotClaimTokenYouDontHold("NO_TOKEN_OWNED");
      }
      nft.burn(_tokenIds[i]);
    }
    if (_tokenIds.length >= 1) {
      for (uint256 i = 0; i < _tokenIds.length; i++) {
        _safeMint(msg.sender, i);
      }
    }
    emit Minted(msg.sender, _tokenIds.length);
    emit BurnClaimComplete(msg.sender, _tokenIds.length, _tokenIds);
  }

  /**
   * @dev Used to directly approve a token for transfers by the current msg.sender
   */
  function _directApproveMsgSenderFor(uint256 tokenId) internal virtual {
    assembly {
      mstore(0x00, tokenId)
      mstore(0x20, 6) // '_tokenApprovals' is at slot 6.
      sstore(keccak256(0x00, 0x40), caller())
    }
  }

  /**
   * @dev Hook before token transfers
   */
  function beforeTokenTransfers(address from, address to, uint256 tokenId, uint256 quantity) internal virtual nonReentrant {
    require(msg.sender == ownerOf(tokenId) || msg.sender == getApproved(tokenId), "Not approved to transfer");
    if (from == address(0) || to == address(0) || from != to) {
      _directApproveMsgSenderFor(tokenId);
    } 
  }
  /**
   * @notice Withdraws all funds held within contract
   */
  function withdraw() external nonReentrant {
    LibDiamond.enforceIsContractOwner();
    require(address(this).balance > 0, "NO_FUNDS");
    LibDiamondDapes.DiamondDapesStruct storage dds = LibDiamondDapes.diamondDapesStorage();
    uint256 balance = address(this).balance;
    for (uint256 i = 0; i < dds.payoutAddresses.length; i++) {
      require(payable(dds.payoutAddresses[i]).send((balance * dds.payoutBasisPoints[i]) / 10000));
    }
  }

  /**
  * @dev Uses multicall efficiently to execute multiple calls in a single transaction
  */
  function multicall(bytes[] calldata data, address diamond) external {
    diamond = diamond == address(0) ? address(this) : diamond;
    require(data.length > 0, "NO_DATA");

    for (uint256 i = 0; i < data.length; i++) {
      bytes memory callData = data[i];
      assembly {
        let result := delegatecall(gas(), diamond, add(callData, 0x20), mload(callData), 0, 0)
        if iszero(result) {
          revert(0, 0)
        }
      }
    }
  }

  /**
   * @dev Fallback function to allow for proxy delegation of calls to diamond.
   * @notice The receive function is called when ether is sent to the contract address.
   * @notice Any eth sent to this contract or any facet will be forwarded to the diamond
   */
  fallback() external payable {
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

    bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
    assembly {
      ds.slot := position
    }
    address facet = address(bytes20(ds.facets[msg.sig]));
    require(facet != address(0), "NO_FUNC");

    assembly {
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
      let size := returndatasize()
      returndatacopy(0, 0, returndatasize())

      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }

  receive() external payable {
    emit Received(msg.sender, msg.value);
  }
}

  /*  ERC721A Contract - BurnToClaim USE OF RIGHTS AGREEMENT
    
    This “USE OF RIGHTS AGREEMENT” is between and by ApeFathersNFT ("Owner") and the individual or entity (as defined below) (the "User"),that uses the ApeFathers NFT smart contract in any form, fashion, manner, including modifying any code, or using any of the code below wihin the contract without explicit written approval by GSKNNFT Inc.
    The "GSKNNFT Inc. BurnToClaim ERC721A Contract - USE OF RIGHTS AGREEMENT" ("GSKNNFT Inc. BurnToClaim Use Of Rights Agreement") is effective as of the first instance of use (the “Effective Date”) of which the User initiated any transaction or use of the code provided below of this specific contract "BurnToClaimNFT ERC721A Contract" (the "BurnMintContract").
    The contract does not require any transfer, event, or action to be successfully completed in order to prove it's existance and legitimacy.

     USER ACKNOWLEDGES RECEIPT AND UNDERSTANDING OF THIS USE OF RIGHTS AGREEMENT, AND AGREES TO BE BOUND BY ITS TERMS.
    USER'S ACCEPTANCE OF THE USE OF THE "GSKNNFT BurnToClaim ERC721A Contract" SHALL BE DEEMED IN ACCEPTANCE OF THESE TERMS AND CONSENT TO BE GOVERNED THEREBY.
    IF THE OWNER DOES NOT AGREE TO BE BOUND BY THESE TERMS, THIS LICENSE AUTOMATICALLY TERMINATES.

    In consideration of the premises and the mutual covenants set forth herein and for other good and valuable consideration, the receipt and sufficiency of which is hereby acknowledged, and intending to be bound hereby, the parties agree as follows:

    1. WARRANTIES, REPRESENTATIONS, USAGE & RESTRICTIONS.
         1.1 NFT.
    This "GSKNNFT BurnToClaim ERC721A Contract" is not an NFT minting contract itself, it interacts with the blockchain to approve and send any contract's token's (as pointed to by this contract) to a burn address in replacement for another contract's mint.
    The conditions of this ERC721A smart-contract include that the calling smart-contracts must fulfill certain conditions (described below).
    Any contract that attempts to interact with the "GSKNNFT BurnToClaim ERC721A Contract" that fails to implement standard ERC721A functions such as "mint", and "safetransferFrom", can not use this contract without consulting GSKNNFT Inc. for additional measures to accomplish the task.
    "NFTs" are defined as non-fungible tokens, assets that can be minted, owned, and destroyed on the blockchain.
    Ownership of which this specific contract is registered here on the ethereum blockchain as;
            Owner: “GSKNNFT Inc.” (the “Business”) - the NFT Project Management/Advisory/Development including any and all operations, employees, agents, representatives and subcontractors,
            Contract: "ApeFathers.sol” (this instance of the ApeFathers NFT smart contract deployed on the ethereum blockchain by GSKNNFT Inc.
            Code and Agreements: "Use of Rights Agreement" & "NFT Owner Agreement" (the "Agreements”) - this specific contract deployed on the ethereum blockchain,
            Created by: ("Owner") - Gordon Skinner of GSKNNFT Inc. ("at-GSKNNFT", "gsknnft.eth", "gsknnft-at-gmail.com").

    For the case of this USE OF RIGHTS AGREEMENT; the first instance of any interaction with this "GSKNNFT BurnToClaim ERC721A Contract" or use of otherwise pursuant to this Agreement shall be considered as (the “Effective Date”), a indicated and described above.
    Digital Asset(s) are associated with digital objects (which may include images and/or other digital works) (“Digital Object(s)”), together, they makeup the properties of a Non-Fungible Token "NFT".
    A copy of this contract can be found within the ethereum blockchain, on the "GSKNNFT BurnToClaim ERC721A Contract" itself, for review by Owner at any time; and enforceable unless voided by the terms therein.
    The Owner guarantees the IP to the"GSKNNFT BurnToClaim ERC721A Contract" was developed created and is owned by GSKNNFT Inc.

    As detailed below, the User may own a Digital Asset, and by their own action on the blockchain, commit to sending their owned Digital Object(s) to a burn address in replacement for any number of tokens to a new contract, subject to the terms and conditions mentioned in this agreement.
    The Owner understands that, as it could also be deflationary, the tokens may not always be returned in equivalence, should the burn require >= 2 or more tokens, in return for 1 based on the conditions of the project, subject to the terms and conditions set forth herein.
    Use of the "GSKNNFT BurnToClaim ERC721A Contract" (the “Main Asset”) entitles the user to be declared as the "User".
    For the avoidance of doubt, the term “Digital Asset(s),” as used herein, includes both the Main Asset and any Digital Objects directly associated with the Main Asset.
    For the avoidance of doubt, the term "Main Asset" as used herein, describes the code within the smart contract in this .sol file that is deployed on the ethereum blockchain for use by GSKNNFT Inc. and those permitted use of by the Owner.     
    For the avoidance of doubt, the term "NFT Asset" as used herein, describes the Digital Media(s) themselves which generally, where applicable, can have the IP rights owned by the "User", or in this instance, the "NFT Owner".
        
    1.2  WARRANTIES.
    OWNER GSKNNFT Inc. warrants and represents that it has the right and authority to enter into this agreement and to grant the licenses and rights granted herein.
    USER The User warrants and represents that it has the right and authority to enter into this agreement and to perform its obligations hereunder, and that its use of the code and interaction with the "GSKNNFT BurnToClaim ERC721A Contract" will not violate any applicable laws or regulations, or infringe upon or misappropriate any third-party rights.
    
    1.3. Main Asset.
            The Main Asset is subject to copyright and other intellectual property protections, which rights are and shall remain owned by solely the Owner ("GSKNNFT Inc.", "Gordon Skinner", "GSKNNFT", "gsknnft-at-gmail.com").

    1.4. Licenses.
        Main Asset.
            Upon a valid transfer any Asset, Owner is hereby the only individual who has the authority to use, or permit the use of;
            Subject to User's compliance with the terms and conditions set forth herein, including without limitation, any restrictions in Section 1.4 below, solely for the following purposes: 
                (i) for their own personal, or commercial use; or 
                (ii) to display the Main Asset for resale.
                (iii) to modify or otherwise use the code below for the individual's purpose without prior contact with GSKNNFT Inc. (contact information listed above).
            Upon expiration of the Term or breach of any conditions of this "GSKNNFT Inc. BurnToClaim Use Of Rights Agreement" by any individual or User, excluding the Owner, all license rights shall immediately terminate.

    1.5. Usage Restrictions.
        The Main Asset(s) provided pursuant to this Owner Agreement is not licensed, nor sold, and Owner receives title to and ownership of the Main Asset(s) including the commercial intellectual property rights therein.
        Except for the license expressly set forth herein, no other rights (express or implied) to the Main Assets(s) are granted.
        Owner reserves all rights not expressly granted.
        Without limiting the generality of the foregoing, Owner shall have the license through this agreement to: 
            (a) copy, modify, or distribute the Main Asset(s);
            (b) use the Main Asset(s) to advertise, market or sell a product and/or service;
            (c) incorporate the Main Asset(s) in videos or other media; or
            (d) sell merchandise incorporating the Main Asset(s).
        Upon a permitted transfer of ownership of the Main Asset(s) by Owner to any third party, the license and this agreement herewithin to the Main Assets(s) associated therewith shall be transferable solely subject to the terms and conditions set forth herein, including those in Section 6.3, and the previous Owner’s license to such Main Assets(s) terminates immediately upon transfer of the contract ownership to any such third party. 
        Upon a non-permitted transfer of ownership of the Main Asset(s) by Owner to any third party, the Owner’s license to the Digital Assets(s) associated therewith terminates immediately, and any purported transfer of the license to such Main Assets(s) to any such third party shall be void.
            Owner may have the power to:
                (a) remove any copyright or other legal notices associated with the Main Asset(s);
                (b) remove or alter, modify, update, or upgrade any code, image, or metadata of the Main Asset(s), including the functions within the smart-contract of which the Main Asset was intended to perform over it's lifetime.
            Owner will not:
                (a) use or publish any modification of the Main Asset(s) in any way that would be immoral or goes against the standards of practice set out by GSKNNFT Inc, including without limitation, any link or other reference to license information.
            Failure to comply with the conditions set forth in Sections 1.3 and 1.4 constitutes a material breach.

    2. IP Rights in the Main Asset.
        Except as expressly set forth herein, Owner retains all right, title, and interest in and to any claim to, or use of the full personal & commercial intellectual property rights in the Main Asset(s), and any future creation by GSKNNFT Inc. as per this contract, unless explicitly stated by GSKNNFT Inc.
        Any and all full Intellectual Property rights of the material stated in this contract, belong to the Owner ("GSKNNFT Inc.") subject to the terms and conditions,  excluding where otherwise stated or provided by the Owner ("GSKNNFT Inc."), will maintain validity as any and all explicitly named here, including through any future Owner-invoked evolutions(changes as per the Owner's action with the proof of such logged as a transaction on the Ethereum blockchain), specifically and exclusively offered by the Owner ("GSKNNFT Inc.") through any mechanism, platform, tool, or method used.

    3. Replica(s).
        The User understands and agrees that Owner has no control over, and shall have no liability for, any Replicas.
        The User understands and agrees that the Platforms and/or any Replica(s) may be unavailable or cease to exist at any time.

    4. Disclaimer.
        Owner MAKES NO WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTY OF NONINFRINGEMENT.
        Upon any interaction with the BurnToClaim Function, the User understands, and is to be considered to be in agreement to the terms and conditions stated within this agreement.
        The User, upon first interaction, understands that it is their responsibilty and legal obligations, where necessary and required by law, that the token owned by the User to be burned, is solely and exclusively the property of the individual or entity burning the token.
        As token burning may have specific tax implications regarding capital gains or losses, it is the responsibility of the User to understand the risks and implications for their associated jurisdiction in any form with regards to burning any Digital Assets(s).
        The user fully understands and agrees that upon burning the token, as this action is irreversable, GSKNNFT Inc. and The ApeFathers NFT brand will not be held responsible, whether financially, legally, or held liable for the User's decision to interact with, and use the "BurnToClaim" function.
        User agrees not to use this contract to commit any criminal offense, nor to distribute or associate this contract with any malicious, harmful, offensive or obscene material.
        User understands and accepts any and all risks of blockchain technology.
        Without limiting the generality of the foregoing, Owner does not warrant that the "BURNNFTTOMINT" ERC721A Contract will ever perform without error.
        Further, Owner provides no warranty regarding, and will have no responsibility for, any claim arising out of:
            (i) a modification of the "BURNNFTTOMINT" ERC721A Contract made by anyone other than Owner, unless Owner approve such modification in writing;
            (ii) User's misuse of or misrepresentation regarding the "BURNNFTTOMINT" ERC721A Contract; or 
            (iii) any technology, including without limitation, any Replica or Platform, that fails to perform or ceases to exist.
        Owner shall not be obligated to provide any support to User, user or any subsequent owner, or user of the "BURNNFTTOMINT" ERC721A Contract.

    5. LIMITATION OF LIABILITY; INDEMNITY.
        5.1. Dollar Cap.
            OWNER's CUMULATIVE LIABILITY FOR ALL CLAIMS ARISING OUT OF OR RELATED TO THIS AGREEMENT WILL NOT EXCEED THE AMOUNT EACH SPECIFIC INDIVIDUAL USER PAID THE OWNER FOR THE MAIN ASSET(S).
        5.2. THE AGGREGATE LIABILITY OF EITHER PARTY TO THE OTHER PARTY FOR ALL CLAIMS ARISING OUT OF OR RELATED TO THIS AGREEMENT, WHETHER IN CONTRACT, TORT OR OTHERWISE, SHALL NOT EXCEED THE AMOUNT PAID BY USER TO GSKNNFT INC. DURING THE SIX MONTH PERIOD PRECEDING THE EVENT GIVING RISE TO THE CLAIM.
        5.3. Excluded Damages. 
            IN NO EVENT WILL OWNER BE LIABLE FOR LOST PROFITS, FINANCIAL STABILITY, OR LOSS OF BUSINESS OR FOR ANY CONSEQUENTIAL, INDIRECT, SPECIAL, INCIDENTAL, OR PUNITIVE DAMAGES ARISING OUT OF OR RELATED TO THIS AGREEMENT AND THE USE OF THE BURNTOCLAIM FUNCTION.
        5.4. Clarifications & Disclaimers.
            THE LIABILITIES LIMITED BY THIS SECTION 4 APPLY:
                (a) TO LIABILITY FOR NEGLIGENCE;
                (b) REGARDLESS OF THE FORM OF ACTION, WHETHER IN CONTRACT, TORT, STRICT PRODUCT LIABILITY, OR OTHERWISE;
                (c) EVEN IF USER IS ADVISED IN ADVANCE OF THE POSSIBILITY OF THE DAMAGES IN QUESTION AND EVEN IF SUCH DAMAGES WERE FORESEEABLE; AND
                (d) EVEN IF OWNER'S REMEDIES FAIL OF THEIR ESSENTIAL PURPOSE.
            If applicable law limits the application of the provisions of this Section 4, Owner's liability will be limited to the maximum extent permissible.
            USER ACKNOWLEDGES AND AGREES THAT THE DIGITAL ASSET IS PROVIDED “AS IS” AND WITHOUT WARRANTY OF ANY KIND, WHETHER EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.
            OWNER DOES NOT REPRESENT OR WARRANT THAT THE DIGITAL ASSET WILL BE SECURE, UNINTERRUPTED, OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED.
            USER ASSUMES ALL RISKS ASSOCIATED WITH THE USE OF THE DIGITAL ASSET.
            IN NO EVENT SHALL OWNER BE LIABLE TO USER OR ANY THIRD PARTY FOR ANY INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES OF ANY KIND, INCLUDING BUT NOT LIMITED TO LOST PROFITS, LOST REVENUE, LOST DATA, OR BUSINESS INTERRUPTION, ARISING OUT OF OR IN CONNECTION WITH THIS OWNER AGREEMENT OR THE USE OR INABILITY TO USE THE DIGITAL ASSET, WHETHER BASED ON CONTRACT, TORT, STRICT LIABILITY, OR ANY OTHER THEORY OF LIABILITY, EVEN IF LICENSOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
            For the avoidance of doubt, Owner's liability limits and other rights set forth in this Section 4 apply likewise to Owner's affiliates, Owner's, suppliers, advertisers, agents, sponsors, directors, officers, employees, consultants, and other representatives.
        5.5. Indemnity.
            (a) INDEMNIFICATION BY USER.
                The User agrees to indemnify, defend, and hold harmless GSKNNFT Inc., and its officers, directors, employees, agents, successors, and assigns from and against any and all claims, damages, liabilities, costs, and expenses (including reasonable attorneys' fees) arising out of or in connection with any breach by the User of any warranty or representation made in this agreement, or any unauthorized use of the code or interaction with the "GSKNNFT BurnToClaim ERC721A Contract".
                User will indemnify, defend and hold harmless the Owner and its affiliates, and any of their respective officers, directors, employees, representatives, contractors, and agents (“Owner Indemnitees”) from and against any and all claims, causes of action, liabilities, damages, losses, costs and expenses (including reasonable attorneys' fees and legal costs, which shall be reimbursed as incurred) arising out of, related to, or alleging Owner’s breach of any provision in this agreement, including but not limited to User's own failure to comply with the usage conditions set forth in Section 1.
             (b) INDEMNIFICATION BY OWNER.
                 GSKNNFT Inc. agrees to indemnify, defend, and hold harmless the User, and its officers, directors, employees, agents, successors, and assigns from and against any and all claims, damages, liabilities, costs, and expenses (including reasonable attorneys' fees) arising out of or in connection with any breach by GSKNNFT Inc. of any warranty or representation made in this agreement.
        5.6. IN NO EVENT SHALL EITHER PARTY BE LIABLE TO THE OTHER PARTY FOR ANY INDIRECT, INCIDENTAL, CONSEQUENTIAL, SPECIAL OR EXEMPLARY DAMAGES, INCLUDING WITHOUT LIMITATION, LOST PROFITS, LOST BUSINESS OR LOST DATA, ARISING OUT OF OR IN CONNECTION WITH THIS AGREEMENT, WHETHER BASED ON BREACH OF CONTRACT, TORT (INCLUDING NEGLIGENCE), PRODUCT LIABILITY OR OTHERWISE, EVEN IF THE PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

    6. Term & Termination.
        6.1. Term.
            This agreement shall commence on the Effective Date and shall continue until terminated as provided herein.
            This Agreement shall continue until terminated pursuant to Subsection 6.2 or 6.3 below (the “Term”).
        6.2. Termination for Transfer.
            The license granted in Section 1 above applies only to the extent that User continues to use the applicable Main Asset in any fashion.
            If at any time the User disposes of any Digital Asset(s) through the use of this smart-contract by destroying/burning (disposing) of any Digital Asset(s) by sending them to a zero (0) address on the ethereum blockchain, this specific Agreement, including without limitation, any rights that have been granted to the User with regards to their Digital Asset(s) burned, and the usage of the Main Asset will immediately be enforced by this contract, with respect to use of the Main Asset, without the requirement of notice, and User will have no additional licenses or rights of such Main Asset(s) associated herewith.
        6.3. Termination for Cause.
            Owner may terminate this Agreement for User's material breach by written notice specifying in detail the nature of the breach, effective in thirty (30) days unless the User first cures such breach, or effective immediately if the breach is not subject to cure.
        6.4. Effects of Termination.
            Upon termination of this Agreement, User shall be forced to cease any and all interactions with the Main Asset indefinitely.
            Any provision of this Agreement that must survive to fulfill its essential purpose will survive termination or expiration.

    7. MISCELLANEOUS.
        7.1. Independent Contractors.
            The parties are independent contractors and shall so represent themselves in all regards.
            Neither party is the agent of the other, and neither may make commitments on the other’s behalf.
        7.2. Force Majeure.
            No delay, failure, or default, other than a failure to pay fees when due, will constitute a breach of this Owner Agreement to the extent caused by acts of;
                war, terrorism, hurricanes, earthquakes, epidemics, other acts of God or of nature, strikes or other labor disputes, riots or other acts of civil disorder, embargoes, government orders responding to any of the foregoing, or other causes beyond the performing party’s reasonable control.
        7.3. Assignment & Successors. 
            Subject to the transfer restrictions set forth herein, including in Sections 1.4 and this Section 6.3, User may, and will be required through the use of this contract, transfer ownership of any Digital Asset(s) to an ethereum zero (0) ("burn address"), provided that User:
                (i) has not breached this Agreement prior to the transfer;
                (ii) Agrees that Owner may receive payment for use of the Main Asset; and
                (iii) Owner ensures that such third party is made aware of this Usage Agreement and agrees to be bound by the obligations and restrictions set forth herein.
            If the third party does not agree to be bound by the obligations and restrictions set forth herein, then the licenses granted herein shall terminate.
            In no case shall any of the license rights or other rights granted herein be transferrable apart from ownership of the Digital Asset.
            Except to the extent forbidden in this Section 6.3, this Usage Agreement will be binding upon and inure to the benefit of the parties’ respective successors and assigns.
            Any purported assignment or transfer in violation of this Section 6.3, including the transfer restriction in Section 1.4, shall be void.
            Only a single entity may own each entire Digital Asset at any time, with the exclusion of fractionalization ownership, and only the entities previously named shall have a license to the Digital Object(s) associated therewith.
            Upon transfer of a Digital Asset from any User to the ethereum zero ("burn address"), any license provided to the User for the Digital Object(s) associated with such Digital Asset shall be forever and indefinitely theirs, where applicable and granted.
        7.4. Severability.
            To the extent permitted by applicable law, the parties hereby waive any provision of law that would render any clause of this Agreement invalid or otherwise unenforceable in any respect.
            In the event that a provision of this Agreement is held to be invalid or otherwise unenforceable, such provision will be interpreted to fulfill its intended purpose to the maximum extent permitted by applicable law, and the remaining provisions of this Usage Agreement will continue in full force and effect.
        7.5. No Waiver.
            Neither party will be deemed to have waived any of its rights under this Agreement by lapse of time or by any statement or representation other than by an authorized representative in an explicit written waiver.
            No waiver of a breach of this Agreement will constitute a waiver of any other breach of this Usage Agreement.
        7.6. Choice of Law & Jurisdiction:
            This Agreement is governed by Canadian law, or any federal, provincial, or state law where the Owner (GSKNNFT INC.) is located and conducts their business in the future, and both parties submit to the exclusive jurisdiction of the provincial and federal courts located in Canada or any federal jurisdiction as per the location of the Owner, and waive any right to challenge personal jurisdiction or venue.
        7.7. Entire Agreement.
            This Agreement sets forth the entire agreement of the parties and supersedes all prior or contemporaneous writings, negotiations, and discussions with respect to its subject matter, exclusive of the NFT Licensing Agreement as stated herewithin..
            Neither party has relied upon any such prior or contemporaneous communications, exclusive of agreements not yet signed by GSKNNFT Inc.
        7.8. Amendment.
            This Usage Agreement may not be amended in any way except through a written agreement by authorized representatives of the Owner and the current user of the Main Asset.

    8.0 General Disclaimer.
        GSKNNFT Inc. is not an investment business.
        GSKNNFT Inc. offers a deployed contract that can be used by only the token owner or those approved to transfer the token to burn tokens from one contract, in return for a token to be minted from this contract.
        Any and all elements of the Main Asset(s) are subject to change without notice.
        Any future token, smart contract, DApp, website, technology, or any physical, or digital creation (on-chain or off-chain) that is released from or utilized by GSKNNFT Inc. should only be used within the network of projects of which GSKNNFT Inc. has permitted through writing.
        Any future product, including any physical, or digital creation (on-chain or off-chain) that is released from or utilized by GSKNNFT Inc. shall and will be enforced by this contract.
        All legal and commercial IP rights regarding any product, material, merchandise, documentation, smart contracts, Digital Asset(s) or any other item or service provided, will immediately and indefinitely held by GSKNNFT Inc. where applicable.
        These rights will remain held by GSKNNFT Inc., notwithstanding any future contracts, or legal transfers of ownership made in writing by GSKNNFT Inc., that may be enforced regarding new projects not yet conceptualized or actualized.     */
// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

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
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity 0.8.20;

import "./IERC721AUpgradeable.sol";
import {ERC721AStorage} from "./ERC721AStorage.sol";
import "./ERC721A__Initializable.sol";

/**
 * @dev Interface of ERC721 token receiver.
 */
interface ERC721A__IERC721ReceiverUpgradeable {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

/**
 * @title ERC721A
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
contract ERC721AUpgradeable is ERC721A__Initializable, IERC721AUpgradeable {
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
    bytes32 private constant _TRANSFER_EVENT_SIGNATURE = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    function __ERC721A_init(string memory name_, string memory symbol_) internal onlyInitializingERC721A {
        __ERC721A_init_unchained(name_, symbol_);
    }

    function __ERC721A_init_unchained(string memory name_, string memory symbol_) internal onlyInitializingERC721A {
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
        return 0;
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
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return ERC721AStorage.layout()._packedAddressData[owner] & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return (ERC721AStorage.layout()._packedAddressData[owner] >> _BITPOS_NUMBER_MINTED) & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return (ERC721AStorage.layout()._packedAddressData[owner] >> _BITPOS_NUMBER_BURNED) & _BITMASK_ADDRESS_DATA_ENTRY;
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
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : "";
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
            // If not burned.
            if (packed & _BITMASK_BURNED == 0) {
                // If the data at the starting slot does not exist, start the scan.
                if (packed == 0) {
                    if (tokenId >= ERC721AStorage.layout()._currentIndex) revert OwnerQueryForNonexistentToken();
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
                        return packed;
                    }
                }
                // Otherwise, the data exists and is not burned. We can skip the scan.
                // This is possible because we have already achieved the target condition.
                // This saves 2143 gas on transfers of initialized tokens.
                return packed;
            }
        }
        revert OwnerQueryForNonexistentToken();
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
     * - The caller must own the token or be an safe operator.
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
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

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
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return
            _startTokenId() <= tokenId &&
            tokenId < ERC721AStorage.layout()._currentIndex && // If within bounds,
            ERC721AStorage.layout()._packedOwnerships[tokenId] & _BITMASK_BURNED == 0; // and not burned.
    }

    /**
     * @dev Returns whether `msgSender` is equal to `approvedAddress` or `owner`.
     */
    function _isSenderApprovedOrOwner(address approvedAddress, address owner, address msgSender) private pure returns (bool result) {
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
    function _getApprovedSlotAndAddress(uint256 tokenId) private view returns (uint256 approvedAddressSlot, address approvedAddress) {
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

        if (address(uint160(prevOwnershipPacked)) != from) revert TransferFromIncorrectOwner();

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        // The nested ifs save around 20+ gas over a compound boolean condition.
        if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A()))
            if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();

        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

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

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public payable virtual override {
        transferFrom(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                revert TransferToNonERC721ReceiverImplementer();
            }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token IDs
     * are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * `startTokenId` - the first token ID to be transferred.
     * `quantity` - the amount to be transferred.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal virtual {}

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
    function _afterTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal virtual {}

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
    function _checkContractOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        try ERC721A__IERC721ReceiverUpgradeable(to).onERC721Received(_msgSenderERC721A(), from, tokenId, _data) returns (bytes4 retval) {
            return retval == ERC721A__IERC721ReceiverUpgradeable(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
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
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // `balance` and `numberMinted` have a maximum limit of 2**64.
        // `tokenId` has a maximum limit of 2**256.
        unchecked {
            // Updates:
            // - `balance += quantity`.
            // - `numberMinted += quantity`.
            //
            // We can directly add to the `balance` and `numberMinted`.
            ERC721AStorage.layout()._packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

            // Updates:
            // - `address` to the owner.
            // - `startTimestamp` to the timestamp of minting.
            // - `burned` to `false`.
            // - `nextInitialized` to `quantity == 1`.
            ERC721AStorage.layout()._packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

            uint256 toMasked;
            uint256 end = startTokenId + quantity;

            // Use assembly to loop and emit the `Transfer` event for gas savings.
            // The duplicated `log4` removes an extra check and reduces stack juggling.
            // The assembly, together with the surrounding Solidity code, have been
            // delicately arranged to nudge the compiler into producing optimized opcodes.
            assembly {
                // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
                toMasked := and(to, _BITMASK_ADDRESS)
                // Emit the `Transfer` event.
                log4(
                    0, // Start of data (0, since no data).
                    0, // End of data (0, since no data).
                    _TRANSFER_EVENT_SIGNATURE, // Signature.
                    0, // `address(0)`.
                    toMasked, // `to`.
                    startTokenId // `tokenId`.
                )

                // The `iszero(eq(,))` check ensures that large values of `quantity`
                // that overflows uint256 will make the loop run out of gas.
                // The compiler will optimize the `iszero` away for performance.
                for {
                    let tokenId := add(startTokenId, 1)
                } iszero(eq(tokenId, end)) {
                    tokenId := add(tokenId, 1)
                } {
                    // Emit the `Transfer` event. Similar to above.
                    log4(0, 0, _TRANSFER_EVENT_SIGNATURE, 0, toMasked, tokenId)
                }
            }
            if (toMasked == 0) revert MintToZeroAddress();

            ERC721AStorage.layout()._currentIndex = end;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * This function is intended for efficient minting only during contract creation.
     *
     * It emits only one {ConsecutiveTransfer} as defined in
     * [ERC2309](https://eips.ethereum.org/EIPS/eip-2309),
     * instead of a sequence of {Transfer} event(s).
     *
     * Calling this function outside of contract creation WILL make your contract
     * non-compliant with the ERC721 standard.
     * For full ERC721 compliance, substituting ERC721 {Transfer} event(s) with the ERC2309
     * {ConsecutiveTransfer} event is only permissible during contract creation.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {ConsecutiveTransfer} event.
     */
    function _mintERC2309(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = ERC721AStorage.layout()._currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();
        if (quantity > _MAX_MINT_ERC2309_QUANTITY_LIMIT) revert MintERC2309QuantityExceedsLimit();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are unrealistic due to the above check for `quantity` to be below the limit.
        unchecked {
            // Updates:
            // - `balance += quantity`.
            // - `numberMinted += quantity`.
            //
            // We can directly add to the `balance` and `numberMinted`.
            ERC721AStorage.layout()._packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

            // Updates:
            // - `address` to the owner.
            // - `startTimestamp` to the timestamp of minting.
            // - `burned` to `false`.
            // - `nextInitialized` to `quantity == 1`.
            ERC721AStorage.layout()._packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

            emit ConsecutiveTransfer(startTokenId, startTokenId + quantity - 1, address(0), to);

            ERC721AStorage.layout()._currentIndex = startTokenId + quantity;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
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
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (index < end);
                // Reentrancy protection.
                if (ERC721AStorage.layout()._currentIndex != end) revert();
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

        if (approvalCheck)
            if (_msgSenderERC721A() != owner)
                if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                    revert ApprovalCallerNotOwnerNorApproved();
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
                if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

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
        _afterTokenTransfers(from, address(0), tokenId, 1);

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
        if (packed == 0) revert OwnershipNotInitializedForExtraData();
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
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable diamond facet contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a function initialize, it's common to move function initialize logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-function initialize}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */

import {ERC721A__InitializableStorage} from "./ERC721A__InitializableStorage.sol";

abstract contract ERC721A__Initializable {
    using ERC721A__InitializableStorage for ERC721A__InitializableStorage.Layout;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializerERC721A() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a function initialize, because in other contexts the
        // contract may have been reentered.
        require(
            ERC721A__InitializableStorage.layout()._initializing ? _isConstructor() : !ERC721A__InitializableStorage.layout()._initialized,
            "ERC721A__Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !ERC721A__InitializableStorage.layout()._initializing;
        if (isTopLevelCall) {
            ERC721A__InitializableStorage.layout()._initializing = true;
            ERC721A__InitializableStorage.layout()._initialized = true;
        }

        _;

        if (isTopLevelCall) {
            ERC721A__InitializableStorage.layout()._initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializingERC721A() {
        require(ERC721A__InitializableStorage.layout()._initializing, "ERC721A__Initializable: contract is not initializing");
        _;
    }

    /// @dev Returns true if and only if the function is running in the function initialize
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a function initialize, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @dev This is a base storage for the  initialization function for upgradeable diamond facet contracts
 **/

library ERC721A__InitializableStorage {
    struct Layout {
        /*
         * Indicates that the contract has been initialized.
         */
        bool _initialized;
        /*
         * Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    bytes32 internal constant STORAGE_SLOT = keccak256("ERC721A.contracts.storage.initializable.facet");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity 0.8.20;

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

    // =============================================================
    //                           IERC2309
    // =============================================================

    /**
     * @dev Emitted when tokens in `fromTokenId` to `toTokenId`
     * (inclusive) is transferred from `from` to `to`, as defined in the
     * [ERC2309](https://eips.ethereum.org/EIPS/eip-2309) standard.
     *
     * See {_mintERC2309} for more details.
     */
    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
}
// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2023, GSKNNFT Inc
pragma solidity 0.8.20;

interface IApeFathers {
  function getOwner() external view returns (address);

  function exists(uint256 tokenId) external view returns (bool);

  function _totalSupply() external view returns (uint256);

  function mint(address _to, uint256 quantity) external payable;

  function totalMinted() external view returns (uint256);

  function baseURI() external view returns (string memory);

  function numberMinted(address owner) external view returns (uint256);

  function nextTokenId() external view returns (uint256);

  function multicall(bytes[] calldata data, address diamond) external;

  function burnClaim(uint256[] calldata tokenId, uint256 quantity) external;

  event Burned(address indexed burner, uint256 indexed tokenId);
  event ContractUpgraded(address sender, address indexed contractAddress, bool indexed success, string);
  event ContractUpgradeRejected(address sender, address indexed contractAddress, bool indexed success, string);
  event Stage1Initialized(address indexed contractAddress, address indexed contractOwner, bool indexed initialized);
  event DiamondInitialized(address indexed contractAddress, address indexed contractOwner, bool indexed initialized);

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

interface IDiamondCut {
  enum FacetCutAction {
    Add,
    Replace,
    Remove
  }
  // Add=0, Replace=1, Remove=2

  struct FacetCut {
    address facetAddress;
    FacetCutAction action;
    bytes4[] functionSelectors;
  }

  /// @notice Add/replace/remove any number of functions and optionally execute
  ///         a function with delegatecall
  /// @param _diamondCut Contains the facet addresses and function selectors
  /// @param _init The address of the contract or facet to execute _calldata
  /// @param _calldata A function call, including function selector and arguments
  ///                  _calldata is executed with delegatecall on _init
  function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;

  event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC165 {
  /// @notice Query if a contract implements an interface
  /// @param interfaceId The interface identifier, as specified in ERC-165
  /// @dev Interface identification is specified in ERC-165. This function
  ///  uses less than 30,000 gas.
  /// @return `true` if the contract implements `interfaceID` and
  ///  `interfaceID` is not 0xffffffff, `false` otherwise
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2023, GSKNNFT Inc
pragma solidity 0.8.20;

interface INFT {
  // Events
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function burn(uint256 tokenId) external;

  function ownerOf(uint256 tokenId) external view returns (address);

  function walletOfOwner(address owner) external view returns (uint256[] calldata);

  function balanceOf(address owner) external view returns (uint256);

  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

  function isOwnerOf(uint256 tokenId) external view returns (address);

  function approve(address to, uint256 tokenId) external;

  function getApproved(uint256 tokenId) external view returns (address);

  function setApprovalForAll(address operator, bool approved) external;

  function isApprovedForAll(address owner, address operator) external view returns (bool);

  function transferFrom(address from, address to, uint256 tokenId) external;

  function safeTransferFrom(address from, address to, uint256 tokenId) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

error InitializationFunctionReverted(address _initializationContractAddress, bytes _calldata);

library LibDiamond {
  bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
  bytes32 constant FACETDATA_STORAGE_POSITION = keccak256("facetdata.standard.diamond.storage");

  struct DiamondStorage {
    // facet initialation data
    mapping(address => bytes) facetInitData;
    // maps function selectors to the facets that execute the functions.
    // and maps the selectors to their position in the selectorSlots array.
    // func selector => address facet, selector position
    mapping(bytes4 => bytes32) facets;
    // array of slots of function selectors.
    // each slot holds 8 function selectors.
    mapping(uint256 => bytes32) selectorSlots;
    // The number of function selectors in selectorSlots
    uint16 selectorCount;
    // Used to query if a contract implements an interface.
    // Used to implement ERC-165.
    mapping(bytes4 => bool) supportedInterfaces;
    // owner of the contract
    address contractOwner;
  }

  struct FacetData {
    bytes4[] functionSelectors;
    bytes callData;
  }

  function facetData() internal pure returns (FacetData storage fd) {
    bytes32 position = FACETDATA_STORAGE_POSITION;
    assembly {
      fd.slot := position
    }
  }

  function diamondStorage() internal pure returns (DiamondStorage storage ds) {
    bytes32 position = DIAMOND_STORAGE_POSITION;
    assembly {
      ds.slot := position
    }
  }

  event _OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function setContractOwner(address _newOwner) internal {
    DiamondStorage storage ds = diamondStorage();
    address previousOwner = ds.contractOwner;
    ds.contractOwner = _newOwner;
    emit _OwnershipTransferred(previousOwner, _newOwner);
  }

  function contractOwner() internal view returns (address contractOwner_) {
    contractOwner_ = diamondStorage().contractOwner;
  }

  function enforceIsContractOwner() internal view {
    require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
  }

  event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

  bytes32 constant CLEAR_ADDRESS_MASK = bytes32(uint256(0xffffffffffffffffffffffff));
  bytes32 constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));
  bytes32 constant CLEAR_SELECTOR = CLEAR_ADDRESS_MASK | CLEAR_SELECTOR_MASK;
  bytes32 constant SELECTOR_SIZE = bytes32(uint256(0xffffffff << 224));
  bytes32 constant SELECTOR_SHIFT =
    bytes32(uint256(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) << 224);
  bytes32 constant SELECTOR_MASK = CLEAR_ADDRESS_MASK | SELECTOR_SIZE;
  bytes32 constant SELECTOR_OFFSET = bytes32(uint256(0xffffffff << 224) >> 1);
  bytes32 constant DIAMOND_STORAGE_OFFSET = bytes32(uint256(0xffffffff << 224) >> 2);
  bytes32 constant DIAMOND_STORAGE_SIZE = bytes32(uint256(0xffffffff << 224) >> 3);
  bytes32 constant DIAMOND_STORAGE_MASK = CLEAR_ADDRESS_MASK | DIAMOND_STORAGE_SIZE;
  bytes32 constant DIAMOND_STORAGE_SHIFT =
    bytes32(uint256(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) << 224) >> 4;
  bytes32 constant DIAMOND_STORAGE = DIAMOND_STORAGE_OFFSET | DIAMOND_STORAGE_SIZE;

  // Internal function version of diamondCut
  // This code is almost the same as the external diamondCut,
  // except it is using 'Facet[] memory _diamondCut' instead of
  // 'Facet[] calldata _diamondCut'.
  // The code is duplicated to prevent copying calldata to memory which
  // causes an error for a two dimensional array.
  function diamondCut(IDiamondCut.FacetCut[] memory _diamondCut, address _init, bytes memory _calldata) internal {
    DiamondStorage storage ds = diamondStorage();
    uint256 originalSelectorCount = ds.selectorCount;
    uint256 selectorCount = originalSelectorCount;
    bytes32 selectorSlot;
    // Check if last selector slot is not full
    // "selectorCount & 7" is a gas efficient modulo by eight "selectorCount % 8"
    if (selectorCount & 7 > 0) {
      // get last selectorSlot
      // "selectorSlot >> 3" is a gas efficient division by 8 "selectorSlot / 8"
      selectorSlot = ds.selectorSlots[selectorCount >> 3];
    }
    // loop through diamond cut
    for (uint256 facetIndex; facetIndex < _diamondCut.length; ) {
      (selectorCount, selectorSlot) = addReplaceRemoveFacetSelectors(
        selectorCount,
        selectorSlot,
        _diamondCut[facetIndex].facetAddress,
        _diamondCut[facetIndex].action,
        _diamondCut[facetIndex].functionSelectors
      );

      unchecked {
        facetIndex++;
      }
    }
    if (selectorCount != originalSelectorCount) {
      ds.selectorCount = uint16(selectorCount);
    }
    // If last selector slot is not full
    // "selectorCount & 7" is a gas efficient modulo by eight "selectorCount % 8"
    if (selectorCount & 7 > 0) {
      // "selectorSlot >> 3" is a gas efficient division by 8 "selectorSlot / 8"
      ds.selectorSlots[selectorCount >> 3] = selectorSlot;
    }
    emit DiamondCut(_diamondCut, _init, _calldata);
    initializeDiamondCut(_init, _calldata);
  }

  function addReplaceRemoveFacetSelectors(
    uint256 _selectorCount,
    bytes32 _selectorSlot,
    address _newFacetAddress,
    IDiamondCut.FacetCutAction _action,
    bytes4[] memory _selectors
  ) internal returns (uint256, bytes32) {
    DiamondStorage storage ds = diamondStorage();
    require(_selectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
    if (_action == IDiamondCut.FacetCutAction.Add) {
      enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Add facet has no code");
      for (uint256 selectorIndex; selectorIndex < _selectors.length; ) {
        bytes4 selector = _selectors[selectorIndex];
        bytes32 oldFacet = ds.facets[selector];
        require(address(bytes20(oldFacet)) == address(0), "LibDiamondCut: Can't add function that already exists");
        // add facet for selector
        ds.facets[selector] = bytes20(_newFacetAddress) | bytes32(_selectorCount);
        // "_selectorCount & 7" is a gas efficient modulo by eight "_selectorCount % 8"
        // " << 5 is the same as multiplying by 32 ( * 32)
        uint256 selectorInSlotPosition = (_selectorCount & 7) << 5;
        // clear selector position in slot and add selector
        _selectorSlot =
          (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) |
          (bytes32(selector) >> selectorInSlotPosition);
        // if slot is full then write it to storage
        if (selectorInSlotPosition == 224) {
          // "_selectorSlot >> 3" is a gas efficient division by 8 "_selectorSlot / 8"
          ds.selectorSlots[_selectorCount >> 3] = _selectorSlot;
          _selectorSlot = 0;
        }
        _selectorCount++;

        unchecked {
          selectorIndex++;
        }
      }
    } else if (_action == IDiamondCut.FacetCutAction.Replace) {
      enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Replace facet has no code");
      for (uint256 selectorIndex; selectorIndex < _selectors.length; ) {
        bytes4 selector = _selectors[selectorIndex];
        bytes32 oldFacet = ds.facets[selector];
        address oldFacetAddress = address(bytes20(oldFacet));
        // only useful if immutable functions exist
        require(oldFacetAddress != address(this), "LibDiamondCut: Can't replace immutable function");
        require(oldFacetAddress != _newFacetAddress, "LibDiamondCut: Can't replace function with same function");
        require(oldFacetAddress != address(0), "LibDiamondCut: Can't replace function that doesn't exist");
        // replace old facet address
        ds.facets[selector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(_newFacetAddress);

        unchecked {
          selectorIndex++;
        }
      }
    } else if (_action == IDiamondCut.FacetCutAction.Remove) {
      require(_newFacetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
      // "_selectorCount >> 3" is a gas efficient division by 8 "_selectorCount / 8"
      uint256 selectorSlotCount = _selectorCount >> 3;
      // "_selectorCount & 7" is a gas efficient modulo by eight "_selectorCount % 8"
      uint256 selectorInSlotIndex = _selectorCount & 7;
      for (uint256 selectorIndex; selectorIndex < _selectors.length; ) {
        if (_selectorSlot == 0) {
          // get last selectorSlot
          selectorSlotCount--;
          _selectorSlot = ds.selectorSlots[selectorSlotCount];
          selectorInSlotIndex = 7;
        } else {
          selectorInSlotIndex--;
        }
        bytes4 lastSelector;
        uint256 oldSelectorsSlotCount;
        uint256 oldSelectorInSlotPosition;
        // adding a block here prevents stack too deep error
        {
          bytes4 selector = _selectors[selectorIndex];
          bytes32 oldFacet = ds.facets[selector];
          require(address(bytes20(oldFacet)) != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
          // only useful if immutable functions exist
          require(address(bytes20(oldFacet)) != address(this), "LibDiamondCut: Can't remove immutable function");
          // replace selector with last selector in ds.facets
          // gets the last selector
          // " << 5 is the same as multiplying by 32 ( * 32)
          lastSelector = bytes4(_selectorSlot << (selectorInSlotIndex << 5));
          if (lastSelector != selector) {
            // update last selector slot position info
            ds.facets[lastSelector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(ds.facets[lastSelector]);
          }
          delete ds.facets[selector];
          uint256 oldSelectorCount = uint16(uint256(oldFacet));
          // "oldSelectorCount >> 3" is a gas efficient division by 8 "oldSelectorCount / 8"
          oldSelectorsSlotCount = oldSelectorCount >> 3;
          // "oldSelectorCount & 7" is a gas efficient modulo by eight "oldSelectorCount % 8"
          // " << 5 is the same as multiplying by 32 ( * 32)
          oldSelectorInSlotPosition = (oldSelectorCount & 7) << 5;
        }
        if (oldSelectorsSlotCount != selectorSlotCount) {
          bytes32 oldSelectorSlot = ds.selectorSlots[oldSelectorsSlotCount];
          // clears the selector we are deleting and puts the last selector in its place.
          oldSelectorSlot =
            (oldSelectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
            (bytes32(lastSelector) >> oldSelectorInSlotPosition);
          // update storage with the modified slot
          ds.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;
        } else {
          // clears the selector we are deleting and puts the last selector in its place.
          _selectorSlot =
            (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
            (bytes32(lastSelector) >> oldSelectorInSlotPosition);
        }
        if (selectorInSlotIndex == 0) {
          delete ds.selectorSlots[selectorSlotCount];
          _selectorSlot = 0;
        }

        unchecked {
          selectorIndex++;
        }
      }
      _selectorCount = selectorSlotCount * 8 + selectorInSlotIndex;
    } else {
      revert("LibDiamondCut: Incorrect FacetCutAction");
    }
    return (_selectorCount, _selectorSlot);
  }

  function initializeDiamondCut(address _init, bytes memory _calldata) internal {
    if (_init == address(0)) {
      return;
    }
    enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
    (bool success, bytes memory error) = _init.delegatecall(_calldata);
    if (!success) {
      if (error.length > 0) {
        // bubble up error
        /// @solidity memory-safe-assembly
        assembly {
          let returndata_size := mload(error)
          revert(add(32, error), returndata_size)
        }
      } else {
        revert InitializationFunctionReverted(_init, _calldata);
      }
    }
  }

  function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
    uint256 contractSize;
    assembly {
      contractSize := extcodesize(_contract)
    }
    require(contractSize > 0, _errorMessage);
  }
}
// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2023, GSKNNFT Inc
pragma solidity ^0.8.20;

import {CountersUpgradeable} from "@gnus.ai/contracts-upgradeable-diamond/contracts/utils/CountersUpgradeable.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {LibDiamond} from "./LibDiamond.sol";

library LibDiamondDapes {
  using CountersUpgradeable for CountersUpgradeable.Counter;
  using LibDiamond for LibDiamond.DiamondStorage;
  bytes32 constant DIAMOND_DAPES_STORAGE_POSITION = keccak256("diamonddapes.standard.diamond.dapes.storage");
  bytes32 constant EXTRAAF_STORAGE_POSITION = keccak256("extraaf.standard.apefathers.storage");
  bytes32 constant AFADMIN_STORAGE_POSITION = keccak256("diamonddapes.standard.apefathers.storage");
  bytes32 constant STAGED_INIT_STORAGE_POSITION = keccak256("diamonddapes.stagedinit.standard.diamond.storage");
  uint256 constant MAX_SUPPLY = 4000;

  struct DiamondDapesStruct {
    // AdminFacet state variables
    // Mapping from token ID to metadata URI
    uint8 batchSizePerTx; // Number of tokens to mint per batch
    uint8 attributes;
    uint16 apeIndex;
    uint16 mintedCount;
    uint64 generation;
    uint96 royaltyFee;
    uint96 tokenCount;
    bool admininitialized;
    bool isActive;
    bool isTokenBurnActive;
    bool isPaused;
    bool isSpecial;
    bool isPublicSaleActive;
    bool isBurnClaimActive;
    bool isBatchMintActive;
    bool metadataFrozen; // Permanently freezes metadata so it can never be changed
    bool payoutAddressesFrozen; // If true, payout addresses and basis points are permanently frozen and can never be updated
    bool revealed;
    bool holderRoyaltiesActive;
    bool collectionRevealed;
    bool[50] __gapBool;
    uint256 _tokenIds;
    uint256 _totalSupply;
    uint256 publicPrice;
    uint256 tokensPerBatch; // Number of tokens to reveal per batch
    uint256 totalRevealed; // Keep track of total number of tokens already revealed
    uint256 holderPercents;
    uint256 publicCloseTokenId;
    uint16[] payoutBasisPoints; // The respective share of funds to be sent to each address in payoutAddresses in basis points
    uint256[50] __gapUint256;
    string baseURI;
    string fullURI;
    string hiddenMetadataUri;
    string name;
    string symbol;
    string uriPrefix;
    string uriSuffix;
    string version;
    bytes32 facetId;
    string[50] __gapString;
    address[] diamondDependencies;
    address[] payoutAddresses;
    address[50] __gapAddress;
    address nftAddress;
    address payable diamondAddress;
    address libAddress;
    address royaltyAddress;
    address tokenOwner;
  }

  struct AdminStorage {
    uint256 nonce;
    mapping(uint256 => bool) revealedTokens;
    // Supported interfaces
    mapping(bytes4 => bool) _supportedInterfaces;
    // Allowed facets
    mapping(address => bool) allowedFacets;
    // Admin addresses
    address[] admins;
    // Balances
    mapping(address => uint256) balances;
    // Token ownership
    mapping(uint256 => address) _owners;
    // Token approvals
    mapping(uint256 => mapping(address => bool)) tokenApprovals;
    // Extra NFT data storage
    mapping(uint256 => string[]) _tokenIPFSHashes;
    // Token URIs
    mapping(uint256 => string) _tokenURIs;
    // Owned token IDs
    mapping(address => uint256[]) _ownedTokens;
    // Index of owned token IDs
    mapping(uint256 => uint256) _ownedTokensIndex;
    // Proxy mapping for projects
    mapping(address => bool) projectProxy;
    // Proxy mapping
    mapping(address => bool) proxyAddress;
  }

  struct ExtraStorage {
    // Counters
    CountersUpgradeable.Counter _tokenIdTracker;
    CountersUpgradeable.Counter _supplyTracker;
  }

  struct StagedInit {
    bool stage1Initialized;
    bool diamondInitialized;
    bool adminInitialized;
    bool royaltiesInitialized;
    bool approvalsInitialized;
  }

  bytes32 constant CLEAR_ADDRESS_MASK = bytes32(uint256(0xffffffffffffffffffffffff));
  bytes32 constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));
  bytes32 constant CLEAR_SELECTOR = CLEAR_ADDRESS_MASK | CLEAR_SELECTOR_MASK;
  bytes32 constant SELECTOR_SIZE = bytes32(uint256(0xffffffff << 224));
  bytes32 constant SELECTOR_SHIFT =
    bytes32(uint256(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) << 224);
  bytes32 constant SELECTOR_MASK = CLEAR_ADDRESS_MASK | SELECTOR_SIZE;
  bytes32 constant SELECTOR_OFFSET = bytes32(uint256(0xffffffff << 224) >> 1);
  bytes32 constant DIAMOND_STORAGE_OFFSET = bytes32(uint256(0xffffffff << 224) >> 2);
  bytes32 constant DIAMOND_STORAGE_SIZE = bytes32(uint256(0xffffffff << 224) >> 3);
  bytes32 constant DIAMOND_STORAGE_MASK = CLEAR_ADDRESS_MASK | DIAMOND_STORAGE_SIZE;
  bytes32 constant DIAMOND_STORAGE_SHIFT =
    bytes32(uint256(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) << 224) >> 4;
  bytes32 constant DIAMOND_STORAGE = DIAMOND_STORAGE_OFFSET | DIAMOND_STORAGE_SIZE;

  function extraStorage() internal pure returns (ExtraStorage storage ex) {
    bytes32 position = EXTRAAF_STORAGE_POSITION;
    assembly {
      ex.slot := position
    }
  }

  function diamondDapesStorage() internal pure returns (DiamondDapesStruct storage dds) {
    bytes32 position = DIAMOND_DAPES_STORAGE_POSITION;
    assembly {
      dds.slot := position
    }
  }

  function adminStorage() internal pure returns (AdminStorage storage aStore) {
    bytes32 position = AFADMIN_STORAGE_POSITION;
    assembly {
      aStore.slot := position
    }
  }

  /*
    function enforceIsAdmin() internal view returns (AdminStorage storage aStore) {
        require(msg.sender == adminStorage().admin, "Must be admin");
    }
*/
  function stagedInitStorage() internal pure returns (StagedInit storage sInit) {
    bytes32 position = STAGED_INIT_STORAGE_POSITION;
    assembly {
      sInit.slot := position
    }
  }

  function setAddress(address _address) internal {
    DiamondDapesStruct storage diamondDapesStruct = diamondDapesStorage();
    diamondDapesStruct.libAddress = _address;
  }

  function getAddress() internal view returns (address) {
    DiamondDapesStruct storage diamondDapesStruct = diamondDapesStorage();
    return diamondDapesStruct.libAddress;
  }

  // Function to set a proxy address
  function setProxy(address _proxyAddress) internal {
    LibDiamond.enforceIsContractOwner();
    adminStorage().proxyAddress[_proxyAddress] = true;
  }

  // Function to remove a proxy address
  function removeProxy(address _proxyAddress) internal {
    LibDiamond.enforceIsContractOwner();
    delete adminStorage().proxyAddress[_proxyAddress];
  }

  // Function to activate a proxy
  function activateProxy(address _proxyAddress) internal {
    require(adminStorage().proxyAddress[_proxyAddress], "Proxy address not found");
    adminStorage().proxyAddress[_proxyAddress] = true;
  }

  // Function to deactivate a proxy
  function deactivateProxy(address _proxyAddress) internal {
    require(adminStorage().proxyAddress[_proxyAddress], "Proxy address not found");
    adminStorage().proxyAddress[_proxyAddress] = false;
  }
}