// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "../utils/ContextUpgradeable.sol";
import {Initializable} from "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
    struct OwnableStorage {
        address _owner;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Ownable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OwnableStorageLocation = 0x9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300;

    function _getOwnableStorage() private pure returns (OwnableStorage storage $) {
        assembly {
            $.slot := OwnableStorageLocation
        }
    }

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
    function __Ownable_init(address initialOwner) internal onlyInitializing {
        __Ownable_init_unchained(initialOwner);
    }

    function __Ownable_init_unchained(address initialOwner) internal onlyInitializing {
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
        OwnableStorage storage $ = _getOwnableStorage();
        return $._owner;
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
        OwnableStorage storage $ = _getOwnableStorage();
        address oldOwner = $._owner;
        $._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

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
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
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
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
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
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;
import {Initializable} from "../proxy/utils/Initializable.sol";

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;
import {Initializable} from "../proxy/utils/Initializable.sol";

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    /// @custom:storage-location erc7201:openzeppelin.storage.ReentrancyGuard
    struct ReentrancyGuardStorage {
        uint256 _status;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ReentrancyGuardStorageLocation = 0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    function _getReentrancyGuardStorage() private pure returns (ReentrancyGuardStorage storage $) {
        assembly {
            $.slot := ReentrancyGuardStorageLocation
        }
    }

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        $._status = NOT_ENTERED;
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
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if ($._status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        $._status = ENTERED;
    }

    function _nonReentrantAfter() private {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        $._status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        return $._status == ENTERED;
    }
}
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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC1271.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^0.8.20;

import {ECDSA} from "./ECDSA.sol";
import {IERC1271} from "../../interfaces/IERC1271.sol";

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Safe Wallet (previously Gnosis Safe).
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error, ) = ECDSA.tryRecover(hash, signature);
        return
            (error == ECDSA.RecoverError.NoError && recovered == signer) ||
            isValidERC1271SignatureNow(signer, hash, signature);
    }

    /**
     * @dev Checks if a signature is valid for a given signer and data hash. The signature is validated
     * against the signer smart contract using ERC1271.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeCall(IERC1271.isValidSignature, (hash, signature))
        );
        return (success &&
            result.length >= 32 &&
            abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector));
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.27;

import {IMoonThatUniswapV3Utility} from "../lib/IMoonThatUniswapV3Utility.sol";

interface IMoonThatCommunityLaunch {
  // Structs
  struct Contribution {
    address participant;
    uint256 etherContributed;
    uint256 tokensClaimed;
  }

  struct InitializeParams {
    address deployerAddress;
    bytes32 deployerUserId;
    address creator;
    string name;
    string symbol;
    uint160 initialSqrtPriceX96AsToken0;
    uint160 initialSqrtPriceX96AsToken1;
    IMoonThatUniswapV3Utility.UniswapV3LiquidityRange[] liquidityRangesAsToken0;
    IMoonThatUniswapV3Utility.UniswapV3LiquidityRange[] liquidityRangesAsToken1;
  }

  // Errors
  error StartTimeInPast();
  error InvalidContributionAmount();
  error ContributionPeriodEnded();
  error AlreadyContributed();
  error InitialBuyNotExecuted();
  error NotContributed();
  error NoEtherContributed();
  error AlreadyClaimed();
  error TransferFailed();
  error ContributionPeriodNotEnded();
  error InitialBuyAlreadyExecuted();
  error AlreadyInitialized();
  error ReceiveNotAllowed();
  error FallbackNotAllowed();
  error ContributionPeriodNotStarted();
  error CannotBeZeroAddress();
  error TooFewLiquidityRanges();
  error LiquidityRangesDoNotSumToTotalSupply();
  error OwnableExpired();
  error CannotBeZeroBytes32();

  // Events
  event InitialBuyExecuted(uint256 etherUsed, uint256 tokenProceeds);
  event UserContributed(
    bytes32 indexed userId,
    address indexed participant,
    uint256 etherAmount
  );
  event UserClaimed(
    bytes32 indexed userId,
    address indexed participant,
    uint256 tokenAmount
  );
  event TokenCreated(address tokenAddress);

  // Interface functions corresponding to public variables
  function CONTRIBUTION_AMOUNT() external view returns (uint256);
  function MAX_DURATION() external view returns (uint256);
  function ETHER_CONTRIBUTION_CAP() external view returns (uint256);
  function PLATFORM_TREASURY() external view returns (address);
  function PLATFORM_SHARE_OF_CONTRIBUTED_ETHER_BASIS_POINTS()
    external
    view
    returns (uint256);
  function MOONTHAT_TOKEN_SINGLETON() external view returns (address);
  function MOONTHAT_UNISWAP_V3_UTILITY() external view returns (address);

  function totalEtherContributed() external view returns (uint256);
  function totalParticipants() external view returns (uint256);
  function startTime() external view returns (uint256);
  function tokenAddress() external view returns (address);
  function tokenProceedsFromInitialBuy() external view returns (uint256);

  // Other functions
  function initialize(InitializeParams memory params_) external;
  function endTime() external view returns (uint256);
  function hasStarted() external view returns (bool);
  function hasEnded() external view returns (bool);
  function contribute(
    bytes32 userId_,
    uint256 messageTimestamp_,
    bytes32 messageHash_,
    bytes calldata messageSignature_
  ) external payable;
  function claim(bytes32 participantId_) external;
  function addLiquidityAndExecuteInitialBuy() external;
  // function rescueERC20(address token_, address to_, uint256 amount_) external;
  // function rescueETH(address to_, uint256 amount_) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.27;

// OpenZeppelin
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// OpenZeppelin Upgradeable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// Uniswap
import {ISwapRouter02} from "../vendor/uniswap/swap-router/ISwapRouter02.sol";

// MoonThat
import {IMoonThatUniswapV3Utility} from "../lib/IMoonThatUniswapV3Utility.sol";
import {IMoonThatToken} from "../token/IMoonThatToken.sol";
import {IMoonThatCommunityLaunch} from "./IMoonThatCommunityLaunch.sol";
import {ImmutableOracleSigned} from "../lib/ImmutableOracleSigned.sol";

contract MoonThatCommunityLaunch is
  IMoonThatCommunityLaunch,
  Initializable,
  OwnableUpgradeable,
  ImmutableOracleSigned,
  ReentrancyGuardUpgradeable
{
  using SafeERC20 for IERC20;

  uint256 private constant _BP_DENOM = 10_000;
  uint24 private constant _UNISWAP_V3_FEE_TIER = 10_000; // 1% fee tier

  uint256 public immutable CONTRIBUTION_AMOUNT;
  uint256 public immutable MAX_DURATION;
  uint256 public immutable ETHER_CONTRIBUTION_CAP;
  uint256 public immutable PLATFORM_SHARE_OF_CONTRIBUTED_ETHER_BASIS_POINTS;
  // Will receive the platform's share of the contributed ether.
  address public immutable PLATFORM_TREASURY;
  address public immutable MOONTHAT_TOKEN_SINGLETON;
  address public immutable MOONTHAT_UNISWAP_V3_UTILITY;
  uint256 public immutable OWNABLE_EXPIRY;
  address public immutable INITIAL_OWNER;

  mapping(bytes32 => Contribution) public contributions;
  uint256 public totalEtherContributed;
  uint256 public totalParticipants;
  uint256 public startTime;
  address public tokenAddress;
  // Creator is an extremely important address as it will be the owner of the liquidity locks and the default fee recipient.
  address public creator;

  IMoonThatUniswapV3Utility.UniswapV3LiquidityRange[] internal _liquidityRanges;

  // Used to record the amount of the target ERC-20 purchased from the initial buy.
  uint256 public tokenProceedsFromInitialBuy;

  constructor(
    address oracleAddress_,
    uint256 oracleMessageValidity_,
    address moonThatTokenSingleton_,
    address platformTreasury_,
    uint256 platformShareOfContributedEtherBasisPoints_,
    address moonThatUniswapV3Utility_,
    uint256 etherContributionCap_,
    uint256 contributionAmount_,
    uint256 maxDuration_,
    uint256 ownableExpiry_,
    address initialOwner_
  ) ImmutableOracleSigned(oracleAddress_, oracleMessageValidity_) {
    // This will be the singleton so we disable the ability to initialize it.
    _disableInitializers();

    MOONTHAT_TOKEN_SINGLETON = moonThatTokenSingleton_;
    PLATFORM_TREASURY = platformTreasury_;
    PLATFORM_SHARE_OF_CONTRIBUTED_ETHER_BASIS_POINTS = platformShareOfContributedEtherBasisPoints_;
    MOONTHAT_UNISWAP_V3_UTILITY = moonThatUniswapV3Utility_;
    ETHER_CONTRIBUTION_CAP = etherContributionCap_;
    CONTRIBUTION_AMOUNT = contributionAmount_;
    MAX_DURATION = maxDuration_;
    OWNABLE_EXPIRY = ownableExpiry_;
    INITIAL_OWNER = initialOwner_;
  }

  function initialize(InitializeParams memory params_) external initializer {
    // Initialize OwnableUpgradeable.
    __Ownable_init(INITIAL_OWNER);

    // Initialize ReentrancyGuardUpgradeable.
    __ReentrancyGuard_init();

    // Check that the creator is not the zero address.
    if (params_.creator == address(0)) {
      revert CannotBeZeroAddress();
    }

    creator = params_.creator;

    // Start immediately.
    startTime = block.timestamp;

    // Create the token and store its address.
    tokenAddress = Clones.clone(MOONTHAT_TOKEN_SINGLETON);

    emit TokenCreated(tokenAddress);

    // Determine which token is token0 when paired with WETH.
    bool tokenIsToken0 = IMoonThatToken(tokenAddress).tokenIsToken0();

    // Determine the proper sqrtPriceX96 depending on the sort order of the token address.
    uint160 initialSqrtPriceX96 = tokenIsToken0
      ? params_.initialSqrtPriceX96AsToken0
      : params_.initialSqrtPriceX96AsToken1;

    // Initialize the token.
    IMoonThatToken(tokenAddress).initialize(
      address(this), // the community launch proxy owns the token
      params_.name,
      params_.symbol,
      initialSqrtPriceX96,
      true // isCommunityLaunch
    );

    // Determine which liquidity ranges to use based on the sort order of the token address.
    if (tokenIsToken0) {
      // Copy new elements from memory to storage for token0
      for (uint256 i = 0; i < params_.liquidityRangesAsToken0.length; ) {
        _liquidityRanges.push(params_.liquidityRangesAsToken0[i]);
        unchecked {
          ++i;
        }
      }
    } else {
      // Copy new elements from memory to storage for token1
      for (uint256 i = 0; i < params_.liquidityRangesAsToken1.length; ) {
        _liquidityRanges.push(params_.liquidityRangesAsToken1[i]);
        unchecked {
          ++i;
        }
      }
    }

    // There must be at least two liquidity ranges. This is required to adjust the first range liquidity based on the amount of ether contributed.
    if (_liquidityRanges.length < 2) {
      revert TooFewLiquidityRanges();
    }

    // The sum of the tokenAmounts in the liquidity ranges must be equal to the total supply of the token.
    uint256 totalLiquidity = 0;
    for (uint256 i = 0; i < _liquidityRanges.length; ) {
      totalLiquidity += _liquidityRanges[i].tokenAmount;
      unchecked {
        ++i;
      }
    }

    if (totalLiquidity != IMoonThatToken(tokenAddress).totalSupply()) {
      revert LiquidityRangesDoNotSumToTotalSupply();
    }

    // Give the deployer a free allocation.
    // Record the contribution and update the total.
    // This is ok to do because the launch starts immediately. If that ever changes, this will need to be done separately.
    // The deployer address cannot be the zero address.
    if (params_.deployerAddress == address(0)) {
      revert CannotBeZeroAddress();
    }

    // The deployer's user id cannot be the zero bytes32 value.
    if (params_.deployerUserId == bytes32(0)) {
      revert CannotBeZeroBytes32();
    }

    contributions[params_.deployerUserId].participant = params_.deployerAddress;
    totalParticipants++;

    emit UserContributed(params_.deployerUserId, params_.deployerAddress, 0);
  }

  function endTime() public view returns (uint256) {
    return startTime + MAX_DURATION;
  }

  function hasStarted() public view returns (bool) {
    return block.timestamp >= startTime;
  }

  function hasEnded() public view returns (bool) {
    return
      block.timestamp >= endTime() ||
      totalEtherContributed >= ETHER_CONTRIBUTION_CAP;
  }

  function contribute(
    bytes32 userId_,
    uint256 messageTimestamp_,
    bytes32 messageHash_,
    bytes calldata messageSignature_
  ) external payable nonReentrant {
    // Check the signature of the passed in message hash and the integrity of the message hash to ensure it is from the oracle.
    bytes32 derivedMessageHash = _deriveMessageHash(userId_, messageTimestamp_);
    checkValidSignedMessage(
      derivedMessageHash,
      messageHash_,
      messageSignature_,
      messageTimestamp_
    );

    // Check that the contribution amount is correct.
    if (msg.value != CONTRIBUTION_AMOUNT) {
      revert InvalidContributionAmount();
    }

    // Check that the contribution period has started.
    if (!hasStarted()) {
      revert ContributionPeriodNotStarted();
    }

    // Check that the contribution period has not ended.
    if (hasEnded()) {
      revert ContributionPeriodEnded();
    }

    // Check that the user id is not the zero bytes32 value.
    if (userId_ == bytes32(0)) {
      revert CannotBeZeroBytes32();
    }

    // Look up the contribution
    Contribution storage contribution = contributions[userId_];

    // Check whether this participant has already contributed.
    // We could use contribution.etherContributed > 0, but this does not work for the deployer's allocation since they did not contribute any ether.
    if (contribution.participant != address(0)) {
      revert AlreadyContributed();
    }

    // Record the contribution and update the total.
    contribution.participant = msg.sender;
    contribution.etherContributed += msg.value;
    totalEtherContributed += msg.value;
    totalParticipants++;

    emit UserContributed(userId_, msg.sender, msg.value);
  }

  function claim(bytes32 userId_) external nonReentrant {
    // Check that the contribution period has ended.
    if (!hasEnded()) {
      revert ContributionPeriodNotEnded();
    }

    // Check that the initial buy has been executed.
    if (tokenProceedsFromInitialBuy == 0) {
      revert InitialBuyNotExecuted();
    }

    // Look up the contribution
    Contribution storage contribution = contributions[userId_];

    // Make sure it exists and that msg.sender is the participant.
    if (contribution.participant != msg.sender) {
      revert NotContributed();
    }

    // Check that the participant has contributed.
    // We could use contribution.etherContributed > 0, but this does not work for the deployer's allocation since they did not contribute any ether.
    if (contribution.participant == address(0)) {
      revert NotContributed();
    }

    // Check that the participant has not already claimed.
    if (contribution.tokensClaimed > 0) {
      revert AlreadyClaimed();
    }

    // Calculate the amount of tokens to claim.
    uint256 tokenAmount = tokenProceedsFromInitialBuy / totalParticipants;

    // Record the claim.
    contribution.tokensClaimed = tokenAmount;

    // Transfer the tokens.
    IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);

    emit UserClaimed(userId_, msg.sender, tokenAmount);
  }

  // Anyone can call this function to create the token and execute the initial buy once the contribution period has ended.
  function addLiquidityAndExecuteInitialBuy() external nonReentrant {
    // Check that the contribution period has ended.
    if (!hasEnded()) {
      revert ContributionPeriodNotEnded();
    }

    // If there was no ether contributed, the community launch is abandoned as nobody participated.
    if (totalEtherContributed == 0) {
      revert NoEtherContributed();
    }

    // Check that the initial buy has not been executed.
    if (tokenProceedsFromInitialBuy > 0) {
      revert InitialBuyAlreadyExecuted();
    }

    // Calculate the platform's share of the contributed ether.
    uint256 platformShareOfContributedEther = (totalEtherContributed *
      PLATFORM_SHARE_OF_CONTRIBUTED_ETHER_BASIS_POINTS) / _BP_DENOM;

    // Transfer the platform's share of the contributed ether.
    (bool success, ) = PLATFORM_TREASURY.call{
      value: platformShareOfContributedEther
    }("");
    if (!success) {
      revert TransferFailed();
    }

    // The creator of the token idea is the liquidity owner and default fee recipient.
    IMoonThatToken(tokenAddress).addAndLockLiquidity(
      creator, // liquidityOwner_
      creator, // defaultFeeRecipient_
      adjustedLiquidityRanges() // The original liquidity ranges are adjusted based on the amount of ether contributed.
    );

    // Calculate the ether for the initial buy.
    uint256 etherForInitialBuy = totalEtherContributed -
      platformShareOfContributedEther;

    // Execute the initial buy.
    _executeInitialBuy(etherForInitialBuy);

    // Renounce ownership of the token as there's nothing left to do for it.
    Ownable(tokenAddress).renounceOwnership();
  }

  function liquidityRanges()
    public
    view
    returns (IMoonThatUniswapV3Utility.UniswapV3LiquidityRange[] memory)
  {
    return _liquidityRanges;
  }

  // Setup custom liquidity profile based on the success of the token.
  // Based on the ratio (in basis points) of ether contributed to the ether cap, the liquidity ranges will be scaled.
  function adjustedLiquidityRanges()
    public
    view
    returns (IMoonThatUniswapV3Utility.UniswapV3LiquidityRange[] memory)
  {
    // Must use totalEtherContributed here, not etherForInitialBuy, because this calculation is based on the full amount contributed, not the amount that will be used for the initial buy.
    uint256 contributionRatio = (totalEtherContributed * _BP_DENOM) /
      ETHER_CONTRIBUTION_CAP;

    // Get a memory copy of the liquidityRanges using the liquidityRanges() function
    IMoonThatUniswapV3Utility.UniswapV3LiquidityRange[]
      memory adjustedRanges = _liquidityRanges;

    // Record the original liquidity of the first range.
    uint256 originalFirstRangeLiquidity = adjustedRanges[0].tokenAmount;

    // Scale the first range liquidity based on the contribution ratio.
    adjustedRanges[0].tokenAmount =
      (adjustedRanges[0].tokenAmount * contributionRatio) /
      _BP_DENOM;

    // There may now be some unused liquidity in the first range.
    uint256 availableLiquidityFromFirstRange = originalFirstRangeLiquidity -
      adjustedRanges[0].tokenAmount;

    // Apply the unused liquidity to the last range.
    adjustedRanges[_liquidityRanges.length - 1]
      .tokenAmount += availableLiquidityFromFirstRange;

    return adjustedRanges;
  }

  ////////////
  // Rescue //
  ////////////

  // Emergency rescue of ERC-20s.
  function rescueERC20(
    address token_,
    address to_,
    uint256 amount_
  ) external onlyOwner {
    // Check that the ownable expiry time has not been reached.
    if (block.timestamp > startTime + OWNABLE_EXPIRY) {
      revert OwnableExpired();
    }

    IERC20(token_).safeTransfer(to_, amount_);
  }

  // Emergency rescue of ETH.
  function rescueETH(address to_, uint256 amount_) external onlyOwner {
    // Check that the ownable expiry time has not been reached.
    if (block.timestamp > startTime + OWNABLE_EXPIRY) {
      revert OwnableExpired();
    }

    (bool success, ) = to_.call{value: amount_}("");
    if (!success) {
      revert TransferFailed();
    }
  }

  /**
   * @dev Reverts any ETH sent to this contract.
   *
   * This function is called when ETH is sent to the contract and no other
   * function matches the data payload, and there is no data in the transaction.
   */
  receive() external payable {
    revert ReceiveNotAllowed();
  }

  /**
   * @dev Reverts any call to the contract that does not match any function signature.
   *
   * This function is called when ETH is sent with data that doesn't match any function
   * signatures or when non-ETH data payloads are sent.
   */
  fallback() external payable {
    revert FallbackNotAllowed();
  }

  //////////////
  // Internal //
  //////////////

  function _executeInitialBuy(uint256 etherForInitialBuy_) internal {
    // Buy from Uniswap.
    ISwapRouter02.ExactInputSingleParams
      memory exactInputSingleParams = ISwapRouter02.ExactInputSingleParams({
        tokenIn: IMoonThatUniswapV3Utility(MOONTHAT_UNISWAP_V3_UTILITY).WETH(),
        tokenOut: tokenAddress,
        fee: _UNISWAP_V3_FEE_TIER,
        recipient: address(this),
        amountIn: etherForInitialBuy_,
        amountOutMinimum: 0,
        sqrtPriceLimitX96: 0
      });

    tokenProceedsFromInitialBuy = ISwapRouter02(
      IMoonThatUniswapV3Utility(MOONTHAT_UNISWAP_V3_UTILITY)
        .uniswapSwapRouter02()
    ).exactInputSingle{value: etherForInitialBuy_}(exactInputSingleParams);

    // Emit an event.
    emit InitialBuyExecuted(etherForInitialBuy_, tokenProceedsFromInitialBuy);
  }

  // Create the hash of the passed data for signature verification.
  // The hash is created by hashing the userId, the address of this contract, and the message timestamp.
  // The contract address is included to prevent hash collisions in the case that two community launches are operating at the same time.
  function _deriveMessageHash(
    bytes32 userId_,
    uint256 messageTimestamp_
  ) internal view returns (bytes32) {
    return keccak256(abi.encode(userId_, address(this), messageTimestamp_));
  }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.27;

interface IMoonThatUniswapV3Utility {
  error InvalidSqrtPriceX96();
  error ReceiveNotAllowed();
  error FallbackNotAllowed();

  struct UniswapV3LiquidityRange {
    int24 tickLower;
    int24 tickUpper;
    uint256 tokenAmount;
  }

  function uniswapSwapRouter() external view returns (address);
  function uniswapSwapRouter02() external view returns (address);
  function uniswapUniversalRouter() external view returns (address);
  function uniswapV3NonfungiblePositionManager()
    external
    view
    returns (address);
  function moonThatUniswapV3Vault() external view returns (address);

  function WETH() external view returns (address);
  function uniswapV3Factory() external view returns (address);
  function sortedTokens(
    address token_
  ) external view returns (address token0, address token1);
  function createUniswapV3Pool(
    address token_,
    uint24 feeTier_,
    uint160 sqrtPriceX96_
  ) external returns (address uniswapV3Pool);
  function getPool(
    address token_,
    uint24 feeTier_
  ) external view returns (address);
  function calculateUniswapV3PoolAddress(
    address token_,
    uint24 feeTier_
  ) external view returns (address);
  function feeTiers() external view returns (uint24[] memory);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.27;

interface IOracleSigned {
  error InvalidOracleSignature();
  error MessageHashIntegrityCheckFailed();
  error OracleSignatureHasExpired();
  error OracleCannotBeZeroAddress();
  error OracleMessageValidityCannotBeZero();

  event OracleUpdated(address previousOracle, address newOracle);
  event OracleMessageValidityUpdated(
    uint256 previousOracleMessageValidity,
    uint256 newOracleMessageValidity
  );

  struct SignedMessage {
    uint256 messageTimestamp;
    bytes32 messageHash;
    bytes messageSignature;
  }

  function oracle() external view returns (address);
  function oracleMessageValidity() external view returns (uint256);
  function checkValidSignedMessage(
    bytes32 derivedMessageHash,
    bytes32 messageHash,
    bytes calldata messageSignature,
    uint256 messageTimestamp
  ) external view;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.27;

// OpenZeppelin
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

// MoonThat
import {IOracleSigned} from "./IOracleSigned.sol";

// To use, implement a _deriveMessageHash function in your implementing contract that takes the same arguments as the function you are trying to verify. You MUST include the message timestamp in your message hash or the signature is vulnerable to timing attacks.

abstract contract ImmutableOracleSigned is IOracleSigned {
  address private immutable _ORACLE;
  uint256 private immutable _ORACLE_MESSAGE_VALIDITY;

  constructor(address oracle_, uint256 oracleMessageValidity_) {
    if (oracle_ == address(0)) {
      revert OracleCannotBeZeroAddress();
    }

    _ORACLE = oracle_;

    if (oracleMessageValidity_ == 0) {
      revert OracleMessageValidityCannotBeZero();
    }

    _ORACLE_MESSAGE_VALIDITY = oracleMessageValidity_;
  }

  /**
   * @dev function {checkValidSignedMessage}
   *
   * Check the signature of the passed in message hash and the integrity of the message hash to ensure it is from the oracle.
   * This is a convenience function that combines the three checks into one and is the only check function exposed to implementing contracts.
   *
   */
  function checkValidSignedMessage(
    bytes32 derivedMessageHash_,
    bytes32 providedMessageHash_,
    bytes memory messageSignature_,
    uint256 messageTimestamp_
  ) public view {
    _checkValidSignature(derivedMessageHash_, messageSignature_);
    _checkSignatureExpiry(messageTimestamp_);
    _checkMessageHashIntegrity(derivedMessageHash_, providedMessageHash_);
  }

  function oracle() public view returns (address) {
    return _ORACLE;
  }

  function oracleMessageValidity() public view returns (uint256) {
    return _ORACLE_MESSAGE_VALIDITY;
  }

  /////////////
  // Private //
  /////////////

  /**
   * @dev function {_isValidSignature}
   *
   * Check the signature of the passed in message hash to ensure it is from the oracle.
   *
   */
  function _isValidSignature(
    bytes32 messageHash_,
    bytes memory messageSignature_
  ) private view returns (bool) {
    bytes32 signedMessageHash = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash_)
    );

    // Check the signature is valid.
    return (
      SignatureChecker.isValidSignatureNow(
        _ORACLE,
        signedMessageHash,
        messageSignature_
      )
    );
  }

  function _checkValidSignature(
    bytes32 messageHash_,
    bytes memory messageSignature_
  ) private view {
    if (!_isValidSignature(messageHash_, messageSignature_)) {
      revert InvalidOracleSignature();
    }
  }

  function _checkSignatureExpiry(uint256 messageTimestamp_) private view {
    if (messageTimestamp_ + _ORACLE_MESSAGE_VALIDITY < block.timestamp) {
      revert OracleSignatureHasExpired();
    }
  }

  /**
   * @dev function {_checkMessageHashIntegrity}
   *
   * Check the integrity of the message hash.
   *
   */
  function _checkMessageHashIntegrity(
    bytes32 generatedMessageHash_,
    bytes32 expectedMessageHash_
  ) private pure {
    // The hash generated from the passed in values must match the given signed hash.
    if (generatedMessageHash_ != expectedMessageHash_) {
      revert MessageHashIntegrityCheckFailed();
    }
  }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.27;

// OpenZeppelin
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// MoonThat
import {IMoonThatUniswapV3Utility} from "../lib/IMoonThatUniswapV3Utility.sol";

interface IMoonThatToken is IERC20, IERC20Metadata {
  // Errors
  error ReceiveNotAllowed();
  error FallbackNotAllowed();
  error NoBuysInFirstBlock();
  error InitialLiquidityAlreadyAdded();
  error MaxTokensPerTransactionExceeded(
    uint256 amount,
    uint256 maxTokensPerTransaction
  );
  error MaxTokensPerWalletExceeded(uint256 amount, uint256 maxTokensPerWallet);
  error MaxBuysPerBlockPerOriginExceeded();
  error BPOverflow(uint256 amount);

  function maxSupply() external view returns (uint256);
  function moonThatUniswapV3Utility() external view returns (address);

  function fundedDate() external view returns (uint256);
  function fundedBlock() external view returns (uint256);
  function isCommunityLaunch() external view returns (bool);
  function initialize(
    address owner_,
    string memory name,
    string memory symbol,
    uint160 initialSqrtPriceX96_,
    bool isCommunityLaunch_
  ) external;
  function addAndLockLiquidity(
    address liquidityOwner_,
    address defaultFeeRecipient_,
    IMoonThatUniswapV3Utility.UniswapV3LiquidityRange[]
      memory initialLiquidityRanges_
  ) external;
  function isLiquidityPool(address address_) external view returns (bool);
  function isUnlimited(address address_) external view returns (bool);
  function limitsEnforced() external view returns (bool);
  function initialLiquidityAdded() external view returns (bool);
  function maxTokensPerTransaction() external view returns (uint256);
  function maxTokensPerWallet() external view returns (uint256);
  function tokenIsToken0() external view returns (bool);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter02 {
  struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
  }

  struct ExactOutputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 amountOut;
    uint256 amountInMaximum;
    uint160 sqrtPriceLimitX96;
  }

  /// @notice Swaps `amountIn` of one token for as much as possible of another token
  /// @dev Setting `amountIn` to 0 will cause the contract to look up its own balance,
  /// and swap the entire amount, enabling contracts to send tokens before calling this function.
  /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
  /// @return amountOut The amount of the received token
  function exactInputSingle(
    ExactInputSingleParams calldata params
  ) external payable returns (uint256 amountOut);

  /// @notice Swaps as little as possible of one token for `amountOut` of another token
  /// that may remain in the router after the swap.
  /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
  /// @return amountIn The amount of the input token
  function exactOutputSingle(
    ExactOutputSingleParams calldata params
  ) external payable returns (uint256 amountIn);
}