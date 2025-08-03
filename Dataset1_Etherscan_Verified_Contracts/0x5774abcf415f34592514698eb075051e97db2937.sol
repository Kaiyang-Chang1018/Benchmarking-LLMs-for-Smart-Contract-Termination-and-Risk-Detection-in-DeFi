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
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {ISafe} from "./interfaces/external/ISafe.sol";
import {Enum} from "./interfaces/external/ISafe.sol";
import {RumpelGuard} from "./RumpelGuard.sol";

/// @notice Delegatecall script to initialize Safes.
contract InitializationScript {
    error InitializationFailed();

    event InitialCall(address to, bytes data);

    struct InitCall {
        address to;
        bytes data;
    }

    /// @notice This function is called via delegatecall by newly created Safes.
    function initialize(address module, address guard, InitCall[] memory initCalls) external {
        ISafe safe = ISafe(address(this));
        safe.enableModule(module);
        safe.setGuard(guard);

        // Arbitrary initial calls.
        for (uint256 i = 0; i < initCalls.length; i++) {
            address to = initCalls[i].to;
            bytes memory data = initCalls[i].data;

            // Check each tx with the guard.
            RumpelGuard(guard).checkTransaction(
                to, 0, data, Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), bytes(""), address(0)
            );

            bool success;
            assembly {
                success := call(sub(gas(), 500), to, 0, add(data, 0x20), mload(data), 0, 0)
            }

            if (!success) revert InitializationFailed();

            emit InitialCall(to, data);
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Enum} from "./interfaces/external/ISafe.sol";
import {IGuard} from "./interfaces/external/IGuard.sol";

/// @notice Rumpel Safe Guard with a blocklist for the Rumpel Wallet.
/// @dev Compatible with Safe v1.3.0-libs.0, the last Safe Ethereum mainnet release, so it can't use module execution hooks.
contract RumpelGuard is Ownable, IGuard {
    mapping(address => mapping(bytes4 => AllowListState)) public allowedCalls; // target => functionSelector => allowListState

    address public immutable signMessageLib;

    enum AllowListState {
        OFF,
        ON,
        PERMANENTLY_ON
    }

    event SetCallAllowed(address indexed target, bytes4 indexed functionSelector, AllowListState allowListState);

    error CallNotAllowed(address target, bytes4 functionSelector);
    error PermanentlyOn();

    constructor(address _signMessageLib) Ownable(msg.sender) {
        signMessageLib = _signMessageLib;
    }

    /// @notice Called by the Safe contract before a transaction is executed.
    /// @dev Safe user execution hook that blocks all calls by default, including delegatecalls, unless explicitly added to the allowlist.
    function checkTransaction(
        address to,
        uint256,
        bytes memory data,
        Enum.Operation operation,
        uint256,
        uint256,
        uint256,
        address,
        address payable,
        bytes memory,
        address
    ) external view {
        // Disallow calls with function selectors that will be padded with 0s.
        // Allow calls with data length 0 for ETH transfers.
        if (data.length > 0 && data.length < 4) {
            revert CallNotAllowed(to, bytes4(data));
        }

        bytes4 functionSelector = bytes4(data);

        // Only allow delegatecalls to the signMessageLib.
        if (operation == Enum.Operation.DelegateCall) {
            if (to == signMessageLib) {
                return;
            } else {
                revert CallNotAllowed(to, functionSelector);
            }
        }

        bool toSafe = msg.sender == to;

        if (toSafe) {
            // If this transaction is to a Safe itself, to e.g. update config, we check the zero address for allowed calls.
            if (allowedCalls[address(0)][functionSelector] == AllowListState.OFF) {
                revert CallNotAllowed(to, functionSelector);
            }
        } else if (data.length == 0) {
            // If this transaction is a simple ETH transfer, we check the zero address with the zero function selector to see if it's allowed.
            if (allowedCalls[address(0)][bytes4(0)] == AllowListState.OFF) {
                revert CallNotAllowed(address(0), bytes4(0));
            }
        } else {
            // For all other calls, we check the allowedCalls mapping normally.
            if (allowedCalls[to][functionSelector] == AllowListState.OFF) {
                revert CallNotAllowed(to, functionSelector);
            }
        }
    }

    /// @notice Called by the Safe contract after a transaction is executed.
    /// @dev No-op.
    function checkAfterExecution(bytes32, bool) external view {}

    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return interfaceId == type(IGuard).interfaceId;
    }

    // Admin ----

    /// @notice Enable or disable Safes from calling a function.
    /// @dev Scoped to <address>.<selector>, so all calls to added address <> selector pairs are allowed.
    /// @dev Function arguments aren't checked, so any arguments are allowed for the enabled functions.
    /// @dev Calls can be enabled, disabled, or permanently enabled, that last of which guarantees the call can't be rugged.
    function setCallAllowed(address target, bytes4 functionSelector, AllowListState allowListState)
        external
        onlyOwner
    {
        if (allowedCalls[target][functionSelector] == AllowListState.PERMANENTLY_ON) {
            revert PermanentlyOn();
        }

        allowedCalls[target][functionSelector] = allowListState;
        emit SetCallAllowed(target, functionSelector, allowListState);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ISafe} from "./interfaces/external/ISafe.sol";
import {ISafeProxyFactory} from "./interfaces/external/ISafeProxyFactory.sol";
import {InitializationScript} from "./InitializationScript.sol";

/// @notice Factory to create Rumpel Wallets; Safes with the Rumpel Guard and Rumpel Module added on.
contract RumpelWalletFactory is Ownable, Pausable {
    mapping(address => uint256) public saltNonce;

    ISafeProxyFactory public proxyFactory;
    address public compatibilityFallback;
    address public safeSingleton;
    address public rumpelModule;
    address public rumpelGuard;
    address public initializationScript;

    event SafeCreated(address indexed safe, address[] indexed owners, uint256 threshold);
    event ParamChanged(bytes32 what, address data);

    error UnrecognizedParam(bytes32 what);

    constructor(
        ISafeProxyFactory _proxyFactory,
        address _compatibilityFallback,
        address _safeSingleton,
        address _rumpelModule,
        address _rumpelGuard,
        address _initializationScript
    ) Ownable(msg.sender) {
        proxyFactory = _proxyFactory;
        compatibilityFallback = _compatibilityFallback;
        safeSingleton = _safeSingleton;
        rumpelModule = _rumpelModule;
        rumpelGuard = _rumpelGuard;
        initializationScript = _initializationScript;
    }

    /// @notice Create a Safe with the Rumpel Module and Rumpel Guard added.
    function createWallet(
        address[] calldata owners,
        uint256 threshold,
        InitializationScript.InitCall[] calldata initCalls
    ) external whenNotPaused returns (address) {
        // Calculate a unique salt based on the sender's address and nonce.
        uint256 salt = uint256(keccak256(abi.encodePacked(msg.sender, saltNonce[msg.sender]++)));

        address safe = proxyFactory.createProxyWithNonce(
            safeSingleton,
            abi.encodeWithSelector(
                ISafe.setup.selector,
                owners,
                threshold,
                initializationScript, // Contract with initialization logic
                abi.encodeWithSelector(InitializationScript.initialize.selector, rumpelModule, rumpelGuard, initCalls), // Add module and guard + initial calls
                compatibilityFallback, // fallbackHandler
                address(0), // paymentToken
                0, // payment
                address(0) // paymentReceiver
            ),
            salt // For deterministic address generation
        );

        emit SafeCreated(safe, owners, threshold);

        return safe;
    }

    function precomputeAddress(bytes memory _initializer, address _sender, uint256 _saltNonce)
        external
        view
        returns (address)
    {
        bytes32 salt = keccak256(
            abi.encodePacked(keccak256(_initializer), uint256(keccak256(abi.encodePacked(_sender, _saltNonce))))
        );

        bytes memory deploymentData =
            abi.encodePacked(proxyFactory.proxyCreationCode(), uint256(uint160(safeSingleton)));

        bytes32 deploymentHash =
            keccak256(abi.encodePacked(bytes1(0xff), address(proxyFactory), salt, keccak256(deploymentData)));

        return address(uint160(uint256(deploymentHash)));
    }

    // Admin ----

    /// @notice Set admin params, only callable by the owner.
    /// @dev These changes will only apply to future Safes deployed with this factory.
    function setParam(bytes32 what, address data) external onlyOwner {
        if (what == "PROXY_FACTORY") proxyFactory = ISafeProxyFactory(data);
        else if (what == "SAFE_SINGLETON") safeSingleton = data;
        else if (what == "RUMPEL_MODULE") rumpelModule = data;
        else if (what == "RUMPEL_GUARD") rumpelGuard = data;
        else if (what == "INITIALIZATION_SCRIPT") initializationScript = data;
        else if (what == "COMPATIBILITY_FALLBACK") compatibilityFallback = data;
        else revert UnrecognizedParam(what);
        emit ParamChanged(what, data);
    }

    function pauseWalletCreation() external onlyOwner {
        _pause();
    }

    function unpauseWalletCreation() external onlyOwner {
        _unpause();
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Enum} from "./ISafe.sol";

interface IGuard {
    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external;

    function checkAfterExecution(bytes32 txHash, bool success) external;
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

library Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

interface ISafe {
    function getTransactionHash(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    ) external view returns (bytes32);

    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures
    ) external payable returns (bool success);

    function execTransactionFromModule(address to, uint256 value, bytes memory data, Enum.Operation operation)
        external
        returns (bool success);

    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external;

    function enableModule(address module) external;

    function disableModule(address prevModule, address module) external;

    function setGuard(address guard) external;

    function getGuard() external view returns (address);

    function getOwners() external view returns (address[] memory);

    function getThreshold() external view returns (uint256);

    function isModuleEnabled(address module) external view returns (bool);

    function nonce() external view returns (uint256);

    function execute(address to, uint256 value, bytes memory data, Enum.Operation operation, uint256 txGas)
        external
        returns (bool success);

    function domainSeparator() external view returns (bytes32);

    function signedMessages(bytes32 messageHash) external returns (uint256);

    function addOwnerWithThreshold(address owner, uint256 _threshold) external;

    // Fallback handler functions

    function isValidSignature(bytes32 _dataHash, bytes calldata _signature) external view returns (bytes4);

    function isValidSignature(bytes calldata _data, bytes calldata _signature) external view returns (bytes4);
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

interface ISafeProxyFactory {
    function createProxyWithNonce(address _singleton, bytes memory _initializer, uint256 _saltNonce)
        external
        returns (address);
    function proxyCreationCode() external pure returns (bytes memory);
}