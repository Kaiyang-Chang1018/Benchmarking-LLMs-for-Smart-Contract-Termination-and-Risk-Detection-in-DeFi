// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title IModuleRegistry
 * @notice Interface for the registry of authorised modules.
 */
interface IKresusRegistry {
    /**
     * @notice Registers a module.
     * @param _module The module.
     * @param _name The unique name of the module.
     */
    function registerModule(address _module, string calldata _name) external;

    /**
     * @notice Deregisters a module.
     * @param _module The module.
     */
    function deregisterModule(address _module) external;

    /**
     * @notice Registers contract addresses with their selectors.
     * @param _contracts Contract addresses to be whitelisted.
     * @param _selectors List of corresponding method ids to be whitelisted.
     */
    function registerContract(address[] memory _contracts, bytes4[] memory _selectors) external;
    
    /**
     * @notice Deregisters contract addresses with their selectors.
     * @param _contracts Contract addresses to be whitelisted.
     * @param _selectors List of corresponding method ids to be whitelisted.
     */
    function deregisterContract(address[] memory _contracts, bytes4[] memory _selectors) external;

    /**
     * @notice Function to set the time delay for remove guardian operation.
     * @param _td New time delay for removing guardian.
     */
    function setRemoveGuardianTd(uint256 _td) external;

    /**
     * @notice Function to set the time delay for unlock operation.
     * @param _td New time delay for unlocking a vault.
     */
    function setUnlockTd(uint256 _td) external;

    /**
     * @notice Gets the name of a module from its address.
     * @param _module The module address.
     * @return the name.
     */
    function moduleInfo(address _module) external view returns (string memory);

    /**
     * @notice Checks if a module is registered.
     * @param _module The module address.
     * @return true if the module is registered.
     */
    function isRegisteredModule(address _module) external view returns (bool);

    /**
     * @notice Checks if given modules are registered.
     * @param _modules The module addresses.
     * @return true if modules are registered.
     */
    function isRegisteredModule(address[] calldata _modules) external view returns (bool);

    /**
     * @notice Checks if given list of contracts addresses and corresponsing method ids are whitelisted.
     * @param _contracts List of contract addresses.
     * @param _sigs List of corresponding method ids.
     * @return true if all the contract addresses and method ids are whitelisted else false.
     */
    function isRegisteredCalls(address[] memory _contracts, bytes4[] memory _sigs) external view returns (bool);

    /**
     * @notice Function to get the time delay for unlock.
     * @return Time delay for unlocking a vault.
     */
    function getUnlockTd() external view returns(uint256); 


    /**
     * @notice Function to get the time delay for remove guardian.
     * @return Time delay for remove guardian.
     */
    function getRemoveGuardianTd() external view returns(uint256); 
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./common/Utils.sol";
import "./common/BaseModule.sol";
import "./KresusRelayer.sol";
import "./SecurityManager.sol";
import "./TransactionManager.sol";
import {IKresusRegistry} from "../infrastructure/IKresusRegistry.sol";

/**
 * @title KresusModule
 * @notice Single module for Kresus vault.
 */
contract KresusModule is BaseModule, KresusRelayer, SecurityManager, TransactionManager {

    address public immutable kresusGuardian;

    /**
     * @param _storageAddr deployed instance of storage contract
     * @param _kresusRegistry deployed instance of Kresus registry
     * @param _kresusGuardian default guardian of kresus for recovery and unblocking
     */
    constructor (
        IStorage _storageAddr,
        IKresusRegistry _kresusRegistry,
        address _kresusGuardian
    )
        BaseModule(_storageAddr, _kresusRegistry)
    {
        require(_kresusGuardian != ZERO_ADDRESS, "KM: Invalid address");
        kresusGuardian = _kresusGuardian;
    }

    /**
     * @inheritdoc IModule
     */
    function init(
        address _vault,
        bytes calldata _initData
    )
        external
        override
        onlyVault(_vault)
    {
        (address newKbg, uint256 newTimeDelay) = abi.decode(_initData, (address, uint256));
        require(IVault(_vault).owner() != newKbg, "KM: Invalid KBG");
        IVault(_vault).enableStaticCall(address(this));
        _storage.setTimeDelay(_vault, newTimeDelay);
        _storage.setKbg(_vault, newKbg);
    }

    /**
     * @inheritdoc IModule
     */
    function addModule(
        address _vault,
        address _module,
        bytes memory _initData
    )
        external
        onlySelf()
    {
        require(kresusRegistry.isRegisteredModule(_module), "KM: module is not registered");
        IVault(_vault).authoriseModule(_module, true, _initData);
    }
    
    /**
     * @inheritdoc KresusRelayer
     */
    function getRequiredSignatures(
        address _vault,
        bytes calldata _data
    )
        public
        view
        override
        returns (uint256, Signature)
    {
        bytes4 methodId = Utils.functionPrefix(_data);

        if(_storage.isLocked(_vault)) {
            require(
                methodId == SecurityManager.unlock.selector ||
                methodId == SecurityManager.executeBequeathal.selector ||
                methodId == SecurityManager.disable.selector,
                "KM: method not allowed"
            );
            if(methodId == SecurityManager.unlock.selector) {
                return (kresusRegistry.getUnlockTd(), Signature.KBGAndKWG);
            }
        }

        if(_storage.isDisabled(_vault)) {
            require(
                methodId == SecurityManager.executeBequeathal.selector ||
                methodId == TransactionManager.multiCall.selector ||
                methodId == TransactionManager.multiCallToWhitelistedAddresses.selector ||
                methodId == SecurityManager.enable.selector,
                "KM: method not allowed"
            );
        }

        if (methodId == TransactionManager.multiCall.selector) {
            bool hasHumanGuardian = _storage.hasHumanGuardian(_vault);
            return hasHumanGuardian ? 
                (_storage.getTimeDelay(_vault), Signature.HG) :
                (_storage.getTimeDelay(_vault), Signature.KBG);
        }
        if(methodId == TransactionManager.multiCallToWhitelistedAddresses.selector) {
            bool hasHumanGuardian = _storage.hasHumanGuardian(_vault);
            return hasHumanGuardian ? (0, Signature.HG) : (0, Signature.KBG);
        }
        if(methodId == SecurityManager.lock.selector) {
            return (0, Signature.KWG);
        }
        if(
            methodId == SecurityManager.setHumanGuardian.selector ||
            methodId == SecurityManager.transferOwnership.selector ||
            methodId == SecurityManager.setTimeDelay.selector
        ) {
            return (_storage.getTimeDelay(_vault), Signature.KBG);
        }
        if(
            methodId == SecurityManager.removeHumanGuardian.selector ||
            methodId == SecurityManager.removeTrustee.selector
        ) {
            return (kresusRegistry.getRemoveGuardianTd(), Signature.KBG);
        }
        if(
            methodId == SecurityManager.addHumanGuardian.selector ||
            methodId == SecurityManager.addTrustee.selector ||
            methodId == KresusModule.addModule.selector
        ) {
            return (0, Signature.KBG);
        }
        if(
            methodId == SecurityManager.enable.selector ||
            methodId == SecurityManager.disable.selector ||
            methodId == SecurityManager.executeBequeathal.selector
        ) {
            return (0, Signature.KWG);
        }
        revert("KM: unknown method");
    }

    /**
     * @param _data _data The calldata for the required transaction.
     * @return Signature The required signature from {Signature} enum.
     */
    function getCancelRequiredSignatures(
        bytes calldata _data
    )
        public
        pure
        override
        returns(Signature)
    {
        bytes4 methodId = Utils.functionPrefix(_data);
        if(
            methodId == SecurityManager.setHumanGuardian.selector ||
            methodId == SecurityManager.removeHumanGuardian.selector ||
            methodId == SecurityManager.setTimeDelay.selector ||
            methodId == SecurityManager.transferOwnership.selector ||
            methodId == SecurityManager.removeTrustee.selector ||
            methodId == TransactionManager.multiCall.selector ||
            methodId == SecurityManager.unlock.selector
        ) {
            return Signature.Owner;
        }
        revert("KM: unknown method");
    }

    /**
    * @notice Validates the signatures provided with a relayed transaction.
    * @param _vault The target vault.
    * @param _signHash The signed hash representing the relayed transaction.
    * @param _signatures The signatures as a concatenated bytes array.
    * @param _option An Signature enum indicating whether the owner is required, optional or disallowed.
    * @return A boolean indicating whether the signatures are valid.
    */
    function validateSignatures(
        address _vault,
        bytes32 _signHash,
        bytes memory _signatures,
        Signature _option
    ) 
        public 
        view
        override
        returns (bool)
    {
        if(_signatures.length < 65) {
            return false;
        }

        address signer0 = Utils.recoverSigner(_signHash, _signatures, 0);

        if(_option == Signature.Owner) {
            return signer0 == IVault(_vault).owner();
        }
        if(_option == Signature.HG) {
            return _storage.isHumanGuardian(_vault, signer0);
        }
        if(_option == Signature.KBG || _option == Signature.KBGAndKWG) {
            if(_signatures.length > 65) {
                address signer1 = Utils.recoverSigner(_signHash, _signatures, 1);
                return _storage.isKbg(_vault, signer0) && signer1 == kresusGuardian;
            }
            return _storage.isKbg(_vault, signer0);
        }
        return signer0 == kresusGuardian;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./common/BaseModule.sol";
/**
 * @title KresusRelayer
 * @notice Abstract Module to execute transactions signed by ETH-less accounts and sent by a relayer.
 */
abstract contract KresusRelayer is BaseModule {

    struct RelayerConfig {
        uint256 nonce;
        mapping(bytes32 => uint256) queuedTransactions;
        mapping(bytes32 => uint256) arrayIndex;
        bytes32[] queue;
    }

    // Used to avoid stack too deep error
    struct StackExtension {
        Signature signatureRequirement;
        bytes32 signHash;
        bool success;
        bytes returnData;
    }

    uint256 internal constant BLOCKBOUND = 10000;

    mapping (address => RelayerConfig) internal relayer;


    event TransactionExecuted(address indexed vault, bool indexed success, bytes returnData, bytes32 signedHash);
    event TransactionQueued(address indexed vault, uint256 executionTime, bytes32 signedHash);
    event Refund(address indexed vault, uint256 refundAmount);
    event ActionCancelled(address indexed vault, bytes32 signedHash);
    event AllActionsCancelled(address indexed vault);
    
    /**
    * @notice Executes a relayed transaction.
    * @param _vault The target vault.
    * @param _data The data for the relayed transaction
    * @param _nonce The nonce used to prevent replay attacks.
    * @param _signatures The signatures as a concatenated byte array.
    * @return true if executed or queued successfully, else returns false.
    */
    function execute(
        address _vault,
        bytes calldata _data,
        uint256 _nonce,
        bytes calldata _signatures
    )
        external
        returns (bool)
    {
        require(verifyData(_vault, _data), "KR: Target of _data != _vault");

        StackExtension memory stack;
        uint256 td;
        (td, stack.signatureRequirement) = getRequiredSignatures(_vault, _data);

        stack.signHash = getSignHash(
            _vault,
            0,
            _data,
            _nonce
        );

        // Execute a queued tx
        if (isActionQueued(_vault, stack.signHash)){
            require(
                relayer[_vault].queuedTransactions[stack.signHash] < block.timestamp,
                "KR: Time not expired"
            );
            (stack.success, stack.returnData) = address(this).call(_data);
            require(stack.success, "KR: Internal call failed");
            if(relayer[_vault].queue.length > 0) {
                removeQueue(_vault, stack.signHash);
            }
            emit TransactionExecuted(_vault, stack.success, stack.returnData, stack.signHash);
            return stack.success;
        }
        
        
        require(validateSignatures(
                _vault, 
                stack.signHash,
                _signatures, 
                stack.signatureRequirement
            ),
            "KR: Invalid Signatures"
        );

        require(checkAndUpdateUniqueness(_vault, _nonce), "KR: Duplicate request");
        

        // Queue the Tx
        if(td > 0) {
            uint256 executionTime = block.timestamp + td;
            relayer[_vault].queuedTransactions[stack.signHash] = executionTime;
            relayer[_vault].queue.push(stack.signHash);
            relayer[_vault].arrayIndex[stack.signHash] = relayer[_vault].queue.length-1;
            emit TransactionQueued(_vault, executionTime, stack.signHash);
            return true;
        }
        // Execute the tx directly without queuing
        else {
            (stack.success, stack.returnData) = address(this).call(_data);
            require(stack.success, "KR: Internal call failed");
            emit TransactionExecuted(_vault, stack.success, stack.returnData, stack.signHash);
            return stack.success;
        }
    }  

    /**
     * @notice cancels a transaction which was queued.
     * @param _vault The target vault.
     * @param _data The data for the relayed transaction.
     * @param _nonce The nonce used to prevent replay attacks.
     * @param _signature The signature needed to validate cancel.
     */
    function cancel(
        address _vault,
        bytes calldata _data,
        uint256 _nonce,
        bytes memory _signature
    ) 
        external 
    {
        bytes32 _actionHash = getSignHash(_vault, 0, _data, _nonce);
        bytes32 _cancelHash = getSignHash(_vault, 0, "0x", _nonce);
        require(isActionQueued(_vault, _actionHash), "KR: Invalid hash");
        Signature _sig = getCancelRequiredSignatures(_data);
        require(
            validateSignatures(
                _vault,
                _cancelHash,
                _signature,
                _sig
            ), "KR: Invalid Signatures"
        );
        removeQueue(_vault, _actionHash);
        emit ActionCancelled(_vault, _actionHash);
    }

    /**
     * @notice to cancel all the queued operations for a `_vault` address.
     * @param _vault The target vault.
     */
    function cancelAll(
        address _vault
    ) external onlySelf {
        uint256 len = relayer[_vault].queue.length; 
        for(uint256 i=0;i<len;i++) {
            bytes32 _actionHash = relayer[_vault].queue[i];
            relayer[_vault].queuedTransactions[_actionHash] = 0;
            relayer[_vault].arrayIndex[_actionHash] = 0;
        }
        delete relayer[_vault].queue;
        emit AllActionsCancelled(_vault);
    }

    /**
    * @notice Gets the current nonce for a vault.
    * @param _vault The target vault.
    * @return nonce gets the last used nonce of the vault.
    */
    function getNonce(address _vault) external view returns (uint256 nonce) {
        return relayer[_vault].nonce;
    }

    /**
    * @notice Gets the number of valid signatures that must be provided to execute a
    * specific relayed transaction.
    * @param _vault The target vault.
    * @param _data The data of the relayed transaction.
    * @return The number of required signatures and the vault owner signature requirement.
    */
    function getRequiredSignatures(
        address _vault,
        bytes calldata _data
    ) public view virtual returns (uint256, Signature);

    /**
    * @notice checks validity of a signature depending on status of the vault.
    * @param _vault The target vault.
    * @param _actionHash signed hash of the request.
    * @param _data The data of the relayed transaction.
    * @param _option Type of signature.
    * @return true if it is a valid signature.
    */
    function validateSignatures(
        address _vault,
        bytes32 _actionHash,
        bytes memory _data,
        Signature _option
    ) public view virtual returns(bool);

    /**
    * @notice Gets the required signature from {Signature} enum to cancel the request.
    * @param _data The data of the relayed transaction.
    * @return The required signature from {Signature} enum .
    */ 
    function getCancelRequiredSignatures(
        bytes calldata _data
    ) public pure virtual returns(Signature);

    /**
    * @notice Generates the signed hash of a relayed transaction according to ERC 1077.
    * @param _from The starting address for the relayed transaction (should be the relayer module)
    * @param _value The value for the relayed transaction.
    * @param _data The data for the relayed transaction which includes the vault address.
    * @param _nonce The nonce used to prevent replay attacks.
    */
    function getSignHash(
        address _from,
        uint256 _value,
        bytes memory _data,
        uint256 _nonce
    )
        public
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(
                    bytes1(0x19),
                    bytes1(0),
                    _from,
                    _value,
                    _data,
                    block.chainid,
                    _nonce
                ))
            )
        );
    }

    /**
    * @notice Checks if the relayed transaction is unique. If yes the state is updated.
    * @param _vault The target vault.
    * @param _nonce The nonce.
    * @return true if the transaction is unique.
    */
    function checkAndUpdateUniqueness(
        address _vault,
        uint256 _nonce
    )
        internal
        returns (bool)
    {
        // use the incremental nonce
        if (_nonce <= relayer[_vault].nonce) {
            return false;
        }
        uint256 nonceBlock = (_nonce & 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000) >> 128;
        if (nonceBlock > block.number + BLOCKBOUND) {
            return false;
        }
        relayer[_vault].nonce = _nonce;
        return true;
    }

    /**
    * @notice Checks that the vault address provided as the first parameter of _data matches _vault
    * @return false if the addresses are different.
    */
    function verifyData(address _vault, bytes calldata _data) internal pure returns (bool) {
        require(_data.length >= 36, "KR: Invalid dataVault");
        require(_vault != ZERO_ADDRESS, "KR: Invalid vault");
        address dataVault = abi.decode(_data[4:], (address));
        return dataVault == _vault;
    }

    /**
    * @notice Check whether a given action is queued.
    * @param _vault The target vault.
    * @param  actionHash  Hash of the action to be checked. 
    * @return Boolean `true` if the underlying action of `actionHash` is queued, otherwise `false`.
    */
    function isActionQueued(
        address _vault,
        bytes32 actionHash
    )
        public
        view
        returns (bool)
    {
        return (relayer[_vault].queuedTransactions[actionHash] > 0);
    }

    /**
    * @notice Return execution time for a given queued action.
    * @param _vault The target vault.
    * @param  actionHash  Hash of the action to be checked.
    * @return uint256   execution time for a given queued action.
    */
    function queuedActionExecutionTime(
        address _vault,
        bytes32 actionHash
    )
        external
        view
        returns (uint256)
    {
        return relayer[_vault].queuedTransactions[actionHash];
    }
    
    /**
    * @notice Removes an element at index from the array queue of a user
    * @param _vault The target vault.
    * @param  _actionHash  Hash of the action to be checked.
    * @return false if the index is invalid.
    */
    function removeQueue(address _vault, bytes32 _actionHash) internal returns(bool) {
        RelayerConfig storage _relayer = relayer[_vault];
        _relayer.queuedTransactions[_actionHash] = 0;

        uint256 index = _relayer.arrayIndex[_actionHash];
        uint256 len = _relayer.queue.length;
        if(index != len - 1) {
            bytes32 lastHash = _relayer.queue[len - 1];
            _relayer.arrayIndex[lastHash] = index;
            _relayer.arrayIndex[_actionHash] = 0;
            _relayer.queue[index] = lastHash;
        }
        _relayer.queue.pop();
        
        return true;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./common/BaseModule.sol";
import "../vault/IVault.sol";

/**
 * @title SecurityManager
 * @notice Abstract module implementing the key security features of the vault: guardians, lock and recovery.
 */
abstract contract SecurityManager is BaseModule {

    event Bequeathed(address indexed vault, address indexed newOwner, address newKbg);
    event TransferedOwnership(address indexed vault, address newOwner, address newKbg);
    event Locked(address indexed vault);
    event Unlocked(address indexed vault);
    event HumanGuardianChanged(address indexed vault, address indexed guardian);
    event TrusteeChanged(address indexed vault, address indexed trustee);
    event TimeDelayChanged(address indexed vault, uint256 newTimeDelay);
    event Enabled(address indexed vault, address kbg);
    event Disabled(address indexed vault);

    /**
     * @notice Lets a guardian lock a vault.
     * @param _vault The target vault.
     */
    function lock(address _vault) external onlySelf() {
        _storage.lock(_vault);
        (bool success, ) = address(this).call(
            abi.encodeWithSignature("cancelAll(address)", _vault)
        );
        require(success, "SM: cancel all operation failed");
        emit Locked(_vault);
    }

    /**
     * @notice Updates the TimeDelay
     * @param _vault The target vault.
     * @param _newTimeDelay The new DelayTime to update.
     */
    function setTimeDelay(
        address _vault,
        uint256 _newTimeDelay
    )
        external
        onlySelf()
    {
        _storage.setTimeDelay(_vault, _newTimeDelay);
        emit TimeDelayChanged(_vault, _newTimeDelay);
    }

    /**
     * @notice Lets a guardian unlock a locked vault.
     * @param _vault The target vault.
     */
    function unlock(
        address _vault
    ) 
        external
        onlySelf()
    {
        _storage.unlock(_vault);
        emit Unlocked(_vault);
    }


    /**
     * @notice Lets the owner add a guardian to its vault.
     * @param _vault The target vault.
     * @param _guardian The guardian to add.
     */
    function setHumanGuardian(
        address _vault,
        address _guardian
    )
        external
        onlySelf()
    {
        require(_guardian != IVault(_vault).owner(), "SM: Invalid guardian");
        _storage.setHumanGuardian(_vault, _guardian);
        emit HumanGuardianChanged(_vault, _guardian);
    }

    /**
     * @notice Function to be used to remove human guardians.
     * @param _vault The target vault.
     */
    function removeHumanGuardian(
        address _vault
    )
        external
        onlySelf()
    {
        _storage.setHumanGuardian(_vault, ZERO_ADDRESS);
        emit HumanGuardianChanged(_vault, ZERO_ADDRESS);
    }

    /**
     * @notice Function to add a human guardian to vault.
     * @param _vault The target vault.
     * @param _guardian Address of the new guardian.
     */
    function addHumanGuardian(
        address _vault,
        address _guardian
    )
        external
        onlySelf()
    {
        require(
            _storage.getHumanGuardian(_vault) == ZERO_ADDRESS,
            "SM: Cannot add guardian"
        );
        _storage.setHumanGuardian(_vault, _guardian);
        emit HumanGuardianChanged(_vault, _guardian);
    }

    /**
     * @notice Changes trustee address for a vault.
     * @param _vault The target vault.
     * @param _newTrustee Address of the new trustee.
     */
    function addTrustee(
        address _vault,
        address _newTrustee
    ) 
        external
        onlySelf()
    {
        require(
            _storage.getTrustee(_vault) == ZERO_ADDRESS && _newTrustee != ZERO_ADDRESS,
            "SM: Cannot add trustee"
        );
        _storage.setTrustee(_vault, _newTrustee);
        emit TrusteeChanged(_vault, _newTrustee);
    }

    /**
     * @notice Resets the trustee address.
     * @param _vault The target vault.
     */
    function removeTrustee(
        address _vault
    )
        external
        onlySelf()
    {
        _storage.setTrustee(_vault, ZERO_ADDRESS);
        emit TrusteeChanged(_vault, ZERO_ADDRESS);
    }

    /**
     * @notice Sets the current trustee address as the new owner for the vault. 
     * After change in owner sets the current trustee address to 0x0.
     * @param _vault The target vault.
     * @param _newKbg The new KBG address.
     */
    function executeBequeathal(
        address _vault,
        address _newKbg
    )
        external
        onlySelf()
    {
        address trustee = _storage.getTrustee(_vault);
        resetVault(_vault, trustee, _newKbg);
        emit Bequeathed(_vault, trustee, _newKbg);
    }

    /**
     * @notice Enables target vault.
     * @param _vault The target vault.
     * @param _newKbg New KBG address.
     */
    function enable(
        address _vault,
        address _newKbg
    )
        external
        onlySelf()
    {
        _storage.enable(_vault, _newKbg);
        emit Enabled(_vault, _newKbg);
    }

    /**
     * @notice Disables target vault.
     * @param _vault The target vault.
     */
    function disable(
        address _vault
    )
        external
        onlySelf()
    {
        _storage.disable(_vault);
        emit Disabled(_vault);
    }

    /**
     * @notice Transfers ownership to different address and changes the kbg address.
     * @param _vault The target vault.
     * @param _newKbg The new kbg address.
     * @param _newOwner The new owner address.
     */
    function transferOwnership(
        address _vault,
        address _newOwner,
        address _newKbg
    )
        external
        onlySelf()
    {
        resetVault(_vault, _newOwner, _newKbg);
        emit TransferedOwnership(_vault, _newOwner, _newKbg);
    }

    /**
     * @notice Changes owner, and resets vault to default state.
     * @param _vault The target vault.
     * @param _newOwner The new owner address.
     * @param _newKbg The new kbg address.
     */
    function resetVault(
        address _vault,
        address _newOwner,
        address _newKbg
    )
        internal
    {
        changeOwner(_vault, _newOwner);
        _storage.reset(_vault);
        _storage.setKbg(_vault, _newKbg);
    }

    /**
     * @notice Changes the owner address for a vault.
     * @param _vault The target vault.
     * @param _newOwner Address of the new owner.
     */
    function changeOwner(address _vault, address _newOwner) internal {
        validateNewOwner(_vault, _newOwner);
        IVault(_vault).setOwner(_newOwner);
        (bool success, ) = address(this).call(
            abi.encodeWithSignature("cancelAll(address)", _vault)
        );
        require(success, "SM: cancel all operation failed");
    }

    /**
     * @notice Checks if the vault address is valid to be a new owner.
     * @param _vault The target vault.
     * @param _newOwner The target vault.
     */
    function validateNewOwner(
        address _vault,
        address _newOwner
    ) internal view {
        require(
            !_storage.isHumanGuardian(
                _vault,
                _newOwner
            ),
            "SM: new owner cannot be guardian"
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./common/Utils.sol";
import "./common/BaseModule.sol";

/**
 * @title TransactionManager
 * @notice Module to execute transactions in sequence to e.g. transfer tokens (ETH, ERC20, ERC721, ERC1155)
 * or call third-party contracts.
 */
abstract contract TransactionManager is BaseModule {

    struct Call {
        address to;      //the target address to which transaction to be sent
        uint256 value;   //native amount to be sent.
        bytes data;      //the data for the transaction.
    }

    // Static calls
    bytes4 private constant ERC1271_IS_VALID_SIGNATURE = bytes4(keccak256("isValidSignature(bytes32,bytes)"));
    bytes4 private constant ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    bytes4 private constant ERC1155_RECEIVED = bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    bytes4 private constant ERC1155_BATCH_RECEIVED = bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    bytes4 private constant ERC165_INTERFACE = bytes4(keccak256("supportsInterface(bytes4)"));

    /**
     * @notice Makes the target vault execute a sequence of transactions
     * The method reverts if any of the inner transactions reverts.
     * @param _vault The target vault.
     * @param _transactions The sequence of transactions.
     * @return bytes array of results for  all low level calls.
     */
    function multiCall(
        address _vault,
        Call[] calldata _transactions
    )
        external 
        onlySelf()
        returns (bytes[] memory)
    {
        return multiCallWithApproval(_vault, _transactions);
    }

    /**
     * @notice Makes the target vault execute a sequence of transactions to only whitelisted addresses.
     * The method reverts if there are any transactions to non whitelisted addresses.
     * The method reverts if any of the inner transactions reverts.
     * @param _vault The target vault.
     * @param _transactions The sequence of transactions.
     * @return bytes array of results for all low level calls.
     */
    function multiCallToWhitelistedAddresses(
        address _vault,
        Call[] calldata _transactions
    )
        external
        onlySelf()
        returns (bytes[] memory)
    {
        uint256 len = _transactions.length;
        address[] memory to = new address[](len);
        bytes4[] memory sigs = new bytes4[](len);
        for(uint256 i=0;i<len;i++) {
            to[i] = _transactions[i].to;
            sigs[i] = Utils.functionPrefix(_transactions[i].data);
        }
        require(kresusRegistry.isRegisteredCalls(to, sigs), "TM: Addresses or Sigs not registered");
        return multiCallWithApproval(_vault, _transactions);
    }

    /**
     * @inheritdoc IModule
     */
    function supportsStaticCall(
        bytes4 _methodId
    )
        external
        pure
        override
        returns (bool _isSupported)
    {
        return _methodId == ERC1271_IS_VALID_SIGNATURE ||
               _methodId == ERC721_RECEIVED ||
               _methodId == ERC165_INTERFACE ||
               _methodId == ERC1155_RECEIVED ||
               _methodId == ERC1155_BATCH_RECEIVED;
    }

    /**
     * @notice Returns true if this contract implements the interface defined by
     * `interfaceId` (see https://eips.ethereum.org/EIPS/eip-165).
     */
    function supportsInterface(
        bytes4 _interfaceID
    )
        external
        pure
        returns (bool)
    {
        return  _interfaceID == ERC165_INTERFACE || _interfaceID == (ERC1155_RECEIVED ^ ERC1155_BATCH_RECEIVED);          
    }

    /**
    * @notice Implementation of EIP 1271.
    * Should return whether the signature provided is valid for the provided data.
    * @param _msgHash Hash of a message signed on the behalf of address(this)
    * @param _signature Signature byte array associated with _msgHash
    */
    function isValidSignature(
        bytes32 _msgHash,
        bytes memory _signature
    )
        external
        view
        returns (bytes4)
    {
        require(_signature.length == 65, "TM: invalid signature length");
        address signer = Utils.recoverSigner(_msgHash, _signature, 0);
        require(_isOwner(msg.sender, signer), "TM: Invalid signer");
        return ERC1271_IS_VALID_SIGNATURE;
    }


    function multiCallWithApproval(
        address _vault,
        Call[] calldata _transactions
    ) 
        internal
        returns
        (bytes[] memory)
    {
        bytes[] memory results = new bytes[](_transactions.length);
        for(uint256 i = 0; i < _transactions.length; i++) {
            results[i] = invokeVault(
                _vault,
                _transactions[i].to,
                _transactions[i].value,
                _transactions[i].data
            );
        }
        return results;
    }


    fallback() external {
        bytes4 methodId = Utils.functionPrefix(msg.data);
        if(methodId == ERC721_RECEIVED || methodId == ERC1155_RECEIVED || methodId == ERC1155_BATCH_RECEIVED) {
            // solhint-disable-next-line no-inline-assembly
            assembly {                
                calldatacopy(0, 0, 0x04)
                return (0, 0x20)
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../vault/IVault.sol";
import "../..//storage/IStorage.sol";
import "./IModule.sol";
import {IKresusRegistry} from "../../infrastructure/IKresusRegistry.sol";
// import "hardhat/console.sol";

/**
 * @title BaseModule
 * @notice Base Module contract that contains methods common to all Modules.
 */
abstract contract BaseModule is IModule {

    // different types of signatures
    enum Signature {
        Owner,
        KBG,
        HG,
        KBGAndKWG,
        KWG
    }

    // Empty calldata
    bytes constant internal EMPTY_BYTES = "";

    // Zero address
    address constant internal ZERO_ADDRESS = address(0);

    // The guardians storage
    IStorage internal immutable _storage;

    // Module Registry address
    IKresusRegistry internal immutable kresusRegistry;

    /**
     * @notice Throws if the sender is not the module itself.
     */
    modifier onlySelf() {
        require(_isSelf(msg.sender), "BM: must be module");
        _;
    }

    /**
     * @dev Throws if the sender is not the target vault of the call.
     */
    modifier onlyVault(address _vault) {
        require(
            msg.sender == _vault,
            "BM: caller must be vault"
        );
        _;
    }

    /**
     * @param _storageAddr deployed instance of storage contract.
     * @param _kresusRegistry deployed instance of module registry contract.
     */
    constructor(
        IStorage _storageAddr,
        IKresusRegistry _kresusRegistry
    ) {
        _storage = _storageAddr;
        kresusRegistry = _kresusRegistry;
    }

    /**
     * @notice Helper method to check if an address is the module itself.
     * @param _addr - The target address.
     * @return true if locked.
     */
    function _isSelf(address _addr) internal view returns (bool) {
        return _addr == address(this);
    }

    /**
     * @notice Helper method to check if an address is the owner of a target vault.
     * @param _vault The target vault.
     * @param _addr The address.
     */
    function _isOwner(address _vault, address _addr) internal view returns (bool) {
        return IVault(_vault).owner() == _addr;
    }

    /**
     * @notice Helper method to invoke a vault.
     * @param _vault - The target vault.
     * @param _to - The target address for the transaction.
     * @param _value - The value of the transaction.
     * @param _data - The data of the transaction.
     * @return _res result of low level call from vault.
     */
    function invokeVault(
        address _vault,
        address _to,
        uint256 _value,
        bytes memory _data
    ) 
        internal
        returns
        (bytes memory _res)
    {
        bool success;
        (success, _res) = _vault.call(
            abi.encodeWithSignature(
                "invoke(address,uint256,bytes)",
                _to,
                _value,
                _data
            )
        );
        if (success && _res.length > 0) {
            (_res) = abi.decode(_res, (bytes));
        } else if (_res.length > 0) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        } else if (!success) {
            revert("BM: vault invoke reverted");
        }
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

/**
 * @title Utils
 * @notice Common utility methods used by modules.
 */
library Utils {

    /**
    * @notice Helper method to recover the signer at a given position from a list of concatenated signatures.
    * @param _signedHash The signed hash
    * @param _signatures The concatenated signatures.
    * @param _index The index of the signature to recover.
    * @return the signer public address.
    */
    function recoverSigner(bytes32 _signedHash, bytes memory _signatures, uint256 _index) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        // we jump 32 (0x20) as the first slot of bytes contains the length
        // we jump 65 (0x41) per signature
        // for v we load 32 bytes ending with v (the first 31 come from s) then apply a mask
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(_signatures, add(0x20,mul(0x41,_index))))
            s := mload(add(_signatures, add(0x40,mul(0x41,_index))))
            v := and(mload(add(_signatures, add(0x41,mul(0x41,_index)))), 0xff)
        }
        require(v == 27 || v == 28, "U: bad v value in signature");

        address recoveredAddress = ecrecover(_signedHash, v, r, s);
        require(recoveredAddress != address(0), "U: ecrecover returned 0");
        return recoveredAddress;
    }

    /**
    * @notice Helper method to parse data and extract the method signature.
    * @param _data The calldata.
    * @return prefix The methodID for the calldata.
    */
    function functionPrefix(bytes memory _data) internal pure returns (bytes4 prefix) {
        require(_data.length >= 4, "U: Invalid functionPrefix");
        // solhint-disable-next-line no-inline-assembly
        assembly {
            prefix := mload(add(_data, 0x20))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title IStorage
 * @notice Interface for Storage
 */
interface IStorage {

    /**
     * @notice Sets lock for a vault contract.
     * @param _vault - The target vault.
     */
    function lock(address _vault) external;

    /**
     * @notice Unlocks a vault contract.
     * @param _vault - The target vault.
     */
    function unlock(address _vault) external;

    /**
     * @notice Lets an authorised module add a guardian to a vault.
     * @param _vault - The target vault.
     * @param _guardian - The guardian to add.
     */
    function setHumanGuardian(address _vault, address _guardian) external;

    /**
     * @notice Sets a new time delay for a vault contract.
     * @param _vault - The target vault.
     * @param _newTimeDelay - The new time delay.
     */
    function setTimeDelay(address _vault, uint256 _newTimeDelay) external;

    /**
     * @notice Function to be used to add trustee address to bequeath vault ownership.
     * @param _vault - The target vault.
     * @param _newTrustee - New address for trustee.
     */
    function setTrustee(address _vault, address _newTrustee) external;

    /**
     * @notice Function to set the kbg for a vault.
     * @param _vault - The target vault.
     * @param _kbg - Address of kbg.
     */
    function setKbg(address _vault, address _kbg) external;

    /**
     * @notice Function to enable or disable a vault.
     * @param _vault - The target vault.
     */
    function enable(address _vault, address _kbg) external;

    /**
     * @notice Function to disable a vault.
     * @param _vault - The target vault.
     */
    function disable(address _vault) external;

    /**
     * @notice Function to reset the vault.
     * @param _vault - The target vault.
     */
    function reset(address _vault) external;

    /**
     * @notice Returns boolean indicating state of the vault.
     * @param _vault - The target vault.
     * @return true if the vault is locked, else returns false.
     */
    function isLocked(address _vault) external view returns(bool);

    /**
     * @notice Returns kbg address of the vault.
     * @param _vault - The target vault.
     * @return kbg address of the vault.
     */
    function getKbg(address _vault) external view returns(address);

    /**
     * @notice Returns human guardian address of the vault.
     * @param _vault - The target vault.
     */
    function getHumanGuardian(address _vault) external view returns(address);

    /**
     * @notice Returns the trustee address for a vault.
     * @param _vault - The target vault.
     */
    function getTrustee(address _vault) external view returns(address);

    /**
     * @notice Checks if an address is kbg for a vault.
     * @param _vault - The target vault.
     * @param _kbg - The account address to be checked.
     * @return true if `_kbg` is kbg for `_vault`.
     */
    function isKbg(address _vault, address _kbg) external view returns(bool);

    /**
     * @notice Checks if an address is a guardian for a vault.
     * @param _vault - The target vault.
     * @param _guardian - The account address to be checked.
     * @return true if `_guardian` is human guardian for `_vault`.
     */
    function isHumanGuardian(address _vault, address _guardian) external view returns(bool);

    /**
     * @notice Checks if an address is an trustee for a vault.
     * @param _vault - The target vault.
     * @param _trustee - The account address to be checked.
     * return true if `_trustee` is the trustee for `_vault`.
     */
    function isTrustee(address _vault, address _trustee) external view returns(bool);

    /**
     * @notice Returns if a vault is disabled.
     * @param _vault - The target vault.
     * return true if the vault is disabled else return false.
     */
    function isDisabled(address _vault) external view returns(bool);

    /**
     * @notice Returns uint256 time delay in seconds for a vault
     * @param _vault - The target vault.
     * @return uint256 time delay in seconds for a vault.
     */
    function getTimeDelay(address _vault) external view returns(uint256);

    /**
     * @notice Returns if a vault has human guardian.
     * @param _vault - The target vault.
     * @return true if `_vault` has human guardian else false.
     */
    function hasHumanGuardian(address _vault) external view returns(bool);
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