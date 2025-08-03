// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
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
pragma solidity 0.8.17;

import {VaultProxy} from "../vault/VaultProxy.sol";
import {BaseVault} from "../vault/BaseVault.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Factory
 * @notice Contract to deploy Proxy Vaults.
 */
contract Factory is Ownable {

    // deployed instance of the base vault.
    address private baseVaultImpl;

    // Emitted for every new deployment of a proxy vault contract.
    event NewVaultDeployed(address indexed newProxy, address indexed owner, address[] modules, bytes[] initData);

    // Emitted when base vault implementation address is changed.
    event BaseVaultImplChanged(address indexed _newBaseVaultImpl);

    /**
     * @param _baseVaultImpl - deployed instance of the implementation base vault.
     */
    constructor(address _baseVaultImpl) {
        require(
            _baseVaultImpl != address(0),
            "F: Invalid address"
        );
        baseVaultImpl = _baseVaultImpl;
    }

    /**
     * Function to be executed by Kresus deployer to deploy a new instance of {Proxy}.
     * @param _owner - address of the owner of base vault contract.
     * @param _modules - Modules to be authorized to make changes to the state of vault contract.
     */
    function deployVault(
        address _owner,
        address[] calldata _modules,
        bytes[] calldata _initData
    ) 
        external
        onlyOwner()
    {
        address payable newProxy = payable(new VaultProxy(baseVaultImpl));
        BaseVault(newProxy).init(_owner, _modules, _initData);
        emit NewVaultDeployed(newProxy, _owner, _modules, _initData);
    }

    /**
     * Function to change base vault implrmrntation address.
     * @param _newBaseVaultImpl - implementation address of new base vault.
     */
    function changeBaseVaultImpl(address _newBaseVaultImpl) external onlyOwner() {
        baseVaultImpl =  _newBaseVaultImpl;
        emit BaseVaultImplChanged(_newBaseVaultImpl);
    }

    /**
     * Function to get current base vault implementation contract address.
     */
    function getBaseVaultImpl() external view returns(address) {
        return baseVaultImpl;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title IModule
 * @notice Interface for a Module.
 */
interface IModule {

    /**	
     * @notice Adds a module to a vault. Cannot execute when vault is locked (or under recovery)	
     * @param _vault The target vault.	
     * @param _module The modules to authorise.	
     */	
    function addModule(address _vault, address _module, bytes memory _initData) external;

    /**
     * @notice Inits a Module for a vault by e.g. setting some vault specific parameters in storage.
     * @param _vault The target vault.
     * @param _initData - Data to be initialised specific to a module when it is authorized.
     */
    function init(address _vault, bytes calldata _initData) external;


    /**
     * @notice Returns whether the module implements a callback for a given static call method.
     * @param _methodId The method id.
     */
    function supportsStaticCall(bytes4 _methodId) external view returns (bool _isSupported);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../modules/common/IModule.sol";
import "./IVault.sol";
// import "hardhat/console.sol";

/**
 * @title BaseVault
 * @notice Simple modular vault that authorises modules to call its invoke() method.
 */
contract BaseVault is IVault {

    // Zero address
    address constant internal ZERO_ADDRESS = address(0);
    // The owner
    address public owner;
    // The authorised modules
    mapping (address => bool) public authorised;
    // module executing static calls
    address public staticCallExecutor;
    // The number of modules
    uint256 public modules;

    event AuthorisedModule(address indexed module, bool value);
    event Invoked(address indexed module, address indexed target, uint256 indexed value, bytes data);
    event Received(uint256 indexed value, address indexed sender, bytes data);
    event StaticCallEnabled(address indexed module);

    /**
     * @notice Throws if the sender is not an authorised module.
     */
    modifier moduleOnly {
        require(authorised[msg.sender], "BV: sender not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Inits the vault by setting the owner and authorising a list of modules.
     * @param _owner The owner.
     * @param _initData bytes32 initialization data specific to the module.
     * @param _modules The modules to authorise.
     */
    function init(address _owner, address[] calldata _modules, bytes[] calldata _initData) external {
        uint256 len = _modules.length;
        require(owner == ZERO_ADDRESS, "BV: vault already initialised");
        require(_owner != ZERO_ADDRESS, "BV: Invalid address");
        require(len > 0, "BV: empty modules");
        require(_initData.length == len, "BV: inconsistent lengths");
        owner = _owner;
        modules = len;
        for (uint256 i = 0; i < len; i++) {
            require(_modules[i] != ZERO_ADDRESS, "BV: Invalid address");
            require(!authorised[_modules[i]], "BV: Invalid module");
            authorised[_modules[i]] = true;
            IModule(_modules[i]).init(address(this), _initData[i]);
            emit AuthorisedModule(_modules[i], true);
        }
    }

    /**
     * @inheritdoc IVault
     */
    function authoriseModule(
        address _module,
        bool _value,
        bytes memory _initData
    ) 
        external
        moduleOnly
    {
        if (authorised[_module] != _value) {
            emit AuthorisedModule(_module, _value);
            if (_value) {
                modules += 1;
                authorised[_module] = true;
                IModule(_module).init(address(this), _initData);
            } else {
                modules -= 1;
                require(modules > 0, "BV: cannot remove last module");
                delete authorised[_module];
            }
        }
    }

    /**
    * @inheritdoc IVault
    */
    function enabled(bytes4 _sig) public view returns (address) {
        address executor = staticCallExecutor;
        if(executor != ZERO_ADDRESS && IModule(executor).supportsStaticCall(_sig)) {
            return executor;
        }
        return ZERO_ADDRESS;
    }

    /**
    * @inheritdoc IVault
    */
    function enableStaticCall(address _module) external moduleOnly {
        if(staticCallExecutor != _module) {
            require(authorised[_module], "BV: unauthorized executor");
            staticCallExecutor = _module;
            emit StaticCallEnabled(_module);
        }
    }

    /**
     * @inheritdoc IVault
     */
    function setOwner(address _newOwner) external moduleOnly {
        require(_newOwner != ZERO_ADDRESS, "BV: address cannot be null");
        owner = _newOwner;
    }

    /**
     * @notice Performs a generic transaction.
     * @param _target The address for the transaction.
     * @param _value The value of the transaction.
     * @param _data The data of the transaction.
     * @return _result The bytes result after call.
     */
    function invoke(
        address _target,
        uint256 _value,
        bytes calldata _data
    ) 
        external 
        moduleOnly 
        returns(bytes memory _result) 
    {
        bool success;
        require(address(this).balance >= _value, "BV: Insufficient balance");
        emit Invoked(msg.sender, _target, _value, _data);
        (success, _result) = _target.call{value: _value}(_data);
        if (!success) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    /**
     * @notice This method delegates the static call to a target contract if the data corresponds
     * to an enabled module, or logs the call otherwise.
     */
    fallback() external payable {
        address module = enabled(msg.sig);
        if (module == ZERO_ADDRESS) {
            emit Received(msg.value, msg.sender, msg.data);
        } else {
            require(authorised[module], "BV: unauthorised module");

            // solhint-disable-next-line no-inline-assembly
            assembly {
                calldatacopy(0, 0, calldatasize())
                let result := staticcall(gas(), module, 0, calldatasize(), 0, 0)
                returndatacopy(0, 0, returndatasize())
                switch result
                case 0 {revert(0, returndatasize())}
                default {return (0, returndatasize())}
            }
        }
    }

    receive() external payable {
        emit Received(msg.value, msg.sender, "");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title IVault
 * @notice Interface for the BaseVault
 */
interface IVault {

    /**
     * @notice Enables/Disables a module.
     * @param _module The target module.
     * @param _value Set to `true` to authorise the module.
     */
    function authoriseModule(address _module, bool _value, bytes memory _initData) external;

    /**
     * @notice Enables a static method by specifying the target module to which the call must be delegated.
     * @param _module The target module.
     */
    function enableStaticCall(address _module) external;


    /**
     * @notice Inits the vault by setting the owner and authorising a list of modules.
     * @param _owner The owner.
     * @param _initData bytes32 initialization data specific to the module.
     * @param _modules The modules to authorise.
     */
    function init(address _owner, address[] calldata _modules, bytes[] calldata _initData) external;

    /**
     * @notice Sets a new owner for the vault.
     * @param _newOwner The new owner.
     */
    function setOwner(address _newOwner) external;

    /**
     * @notice Returns the vault owner.
     * @return The vault owner address.
     */
    function owner() external view returns (address);

    /**
     * @notice Returns the number of authorised modules.
     * @return The number of authorised modules.
     */
    function modules() external view returns (uint256);

    /**
     * @notice Checks if a module is authorised on the vault.
     * @param _module The module address to check.
     * @return `true` if the module is authorised, otherwise `false`.
     */
    function authorised(address _module) external view returns (bool);

    /**
     * @notice Returns the module responsible, if static call is enabled for `_sig`, otherwise return zero address.
     * @param _sig The signature of the static call.
     * @return the module doing the redirection or zero address
     */
    function enabled(bytes4 _sig) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";

/**
 * @title VaultProxy
 * @notice Basic proxy that delegates all calls to a fixed implementing contract.
 * The implementing contract cannot be upgraded.
 */
contract VaultProxy is Proxy{

    address public immutable implementation;

    /**
     * @param _impl deployed instance of base vault.
     */
    constructor(address _impl) {
        implementation = _impl;
    }

    /**
     * @inheritdoc Proxy
     */
    function _implementation() internal view override returns(address) {
        return implementation;
    }
}