// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {CXEvents} from "./events/CXEvents.sol";
import {InterchainToken} from "./apps/InterchainToken.sol";

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit, Nonces} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20, ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Time} from "@openzeppelin/contracts/utils/types/Time.sol";

contract CX is CXEvents, InterchainToken, ERC20Burnable, ERC20Permit, ERC20Votes {
    string internal constant _NAME = "Cortex";
    string internal constant _SYMBOL = "CX";

    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @dev Whether the transfers are enabled, could not be disabled once the transfers are enabled.
    bool internal _transfersEnabled;

    /// @notice Whether the account is allow-listed: transfers to and from such accounts are always enabled,
    /// regardless of the global transfersEnabled flag.
    mapping(address => bool) public isAllowListed;

    error CX__TransfersDisabled();
    error CX__TransfersEnabled();

    modifier whenTransfersDisabled() {
        if (_transfersEnabled) {
            revert CX__TransfersEnabled();
        }
        _;
    }

    /// @notice InterchainToken(name, symbol, decimals, admin)
    /// Note: no tokens are minted during construction, and the transfers are disabled.
    constructor(address admin_) InterchainToken(_NAME, _SYMBOL, 18, admin_) ERC20Permit(_NAME) {}

    /// @notice Allows the account with GOVERNANCE_ROLE to add or remove accounts from the allow-list. Transfers
    /// to and from allow-listed accounts are always enabled, regardless of the global transfersEnabled flag.
    function toggleAllowList(address account, bool isAllowed) external onlyRole(GOVERNANCE_ROLE) {
        isAllowListed[account] = isAllowed;
        emit AllowListToggled(account, isAllowed);
    }

    /// @notice Allows the account with GOVERNANCE_ROLE to enable the token transfers indefinitely.
    /// Note: this action is irreversible.
    function enableTransfers() external onlyRole(GOVERNANCE_ROLE) whenTransfersDisabled {
        _transfersEnabled = true;
        emit TransfersEnabled();
    }

    /// @notice Allows the account with GOVERNANCE_ROLE to burn a specific amount of tokens from an account.
    /// This is only possible if the transfers are disabled.
    function burnAllocation(address account, uint256 amount) external onlyRole(GOVERNANCE_ROLE) whenTransfersDisabled {
        _burn(account, amount);
    }

    /// @notice Allows the account with MINTER_ROLE to mint tokens.
    /// Note: works regardless of whether the transfers are enabled or not.
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @notice See Votes.clock. Overridden to use block timestamp instead of the block number.
    function clock() public view virtual override returns (uint48) {
        return Time.timestamp();
    }

    /// @notice See Votes.CLOCK_MODE. Overridden to signal that the clock is based on the block timestamp.
    /// See EIP-6372 for details.
    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public view virtual override returns (string memory) {
        return "mode=timestamp";
    }

    /// @notice See ERC20.decimals. This override is required by the Solidity compiler.
    function decimals() public view virtual override(ERC20, InterchainToken) returns (uint8) {
        return InterchainToken.decimals();
    }

    /// @notice See ERC20Permit.nonces. This override is required by the Solidity compiler.
    function nonces(address account) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
        return ERC20Permit.nonces(account);
    }

    /// @dev See ERC20._update. This function is called whenever transfer, mint or burn is being done.
    function _update(address from, address to, uint256 value) internal virtual override(ERC20, ERC20Votes) {
        // When the transfers are disabled, only the following balance updates are allowed:
        // - Burning
        // - Minting
        // - Transfers to or from allow-listed accounts
        // Note: we disable interchain-related burning and minting in _takeToken() and _giveToken(),
        // so effectively only regular burning and minting are allowed.
        if (!_transfersEnabled && to != address(0) && from != address(0) && !isAllowListed[to] && !isAllowListed[from])
        {
            revert CX__TransfersDisabled();
        }
        ERC20Votes._update(from, to, value);
    }

    /// @dev See InterchainToken._giveToken. This function is called whenever the token is received from another chain
    /// via an Interchain message to mint the token to the recipient.
    function _giveToken(address recipient, uint256 amount) internal virtual override returns (uint256 amountGiven) {
        // When the transfers are disabled, it should not be possible to mint the token
        // by receiving the token from the remote chain via an Interchain message.
        if (!_transfersEnabled) {
            revert CX__TransfersDisabled();
        }
        return InterchainToken._giveToken(recipient, amount);
    }

    /// @dev See InterchainToken._takeToken. This function is called whenever the token is transferred to another chain
    /// via an Interchain message to burn the token from the sender.
    function _takeToken(
        uint256 amount
    )
        internal
        virtual
        override
        returns (uint256 amountToSend, uint256 interchainFee)
    {
        // When the transfers are disabled, it should not be possible to transfer the token to another chain
        // by sending the token to the remote chain via an Interchain message.
        if (!_transfersEnabled) {
            revert CX__TransfersDisabled();
        }
        return InterchainToken._takeToken(amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AbstractICAppEvents} from "../events/AbstractICAppEvents.sol";

import {IInterchainApp} from "../interfaces/IInterchainApp.sol";
import {IInterchainClientV1} from "../interfaces/IInterchainClientV1.sol";

import {InterchainTxDescriptor} from "../libs/InterchainTransaction.sol";
import {TypeCasts} from "../libs/TypeCasts.sol";

abstract contract AbstractICApp is AbstractICAppEvents, IInterchainApp {
    using TypeCasts for address;

    error InterchainApp__BalanceBelowMin(uint256 balance, uint256 minRequired);
    error InterchainApp__ChainIdNotRemote(uint64 chainId);
    error InterchainApp__InterchainClientAlreadyAdded(address client);
    error InterchainApp__InterchainClientAlreadyLatest(address client);
    error InterchainApp__InterchainClientZeroAddress();
    error InterchainApp__NotInterchainClient(address account);
    error InterchainApp__ReceiverZeroAddress(uint64 chainId);
    error InterchainApp__SrcSenderNotAllowed(uint64 srcChainId, bytes32 sender);

    /// @notice Allows the Interchain Client to pass the message to the Interchain App.
    /// @dev App is responsible for keeping track of interchain clients, and must verify the message sender.
    /// @param srcChainId   Chain ID of the source chain, where the message was sent from.
    /// @param sender       Sender address on the source chain, as a bytes32 value.
    /// @param dbNonce      The Interchain DB nonce of the message entry.
    /// @param message      The message being sent.
    function appReceive(uint64 srcChainId, bytes32 sender, uint64 dbNonce, bytes calldata message) external payable {
        if (!_isInterchainClient(msg.sender)) {
            revert InterchainApp__NotInterchainClient(msg.sender);
        }
        if (srcChainId == block.chainid) {
            revert InterchainApp__ChainIdNotRemote(srcChainId);
        }
        if (!_isAllowedSender(srcChainId, sender)) {
            revert InterchainApp__SrcSenderNotAllowed(srcChainId, sender);
        }
        _receiveMessage(srcChainId, sender, dbNonce, message);
    }

    /// @notice Returns the verification configuration of the Interchain App.
    /// @dev This configuration is used by the Interchain Client to verify that message has been confirmed
    /// by the Interchain Modules on the destination chain.
    /// Note: V1 version of AppConfig includes the required responses count, and optimistic period after which
    /// the message is considered confirmed by the module. Following versions may include additional fields.
    /// @return appConfig    The versioned configuration of the Interchain App, encoded as bytes.
    /// @return modules      The list of Interchain Modules that app is trusting to confirm the messages.
    function getReceivingConfig() external view returns (bytes memory appConfig, address[] memory modules) {
        appConfig = _getAppConfig();
        modules = _getModules();
    }

    // ═══════════════════════════════════════════ INTERNAL: MANAGEMENT ════════════════════════════════════════════════

    /// @dev Performs necessary checks and adds an Interchain Client.
    /// Optionally sets the latest client to this one.
    /// Note: should be guarded with permission checks in the derived contracts.
    function _addClient(address client, bool updateLatest) internal {
        if (client == address(0)) {
            revert InterchainApp__InterchainClientZeroAddress();
        }
        if (_isInterchainClient(client)) {
            revert InterchainApp__InterchainClientAlreadyAdded(client);
        }
        _toggleClientState(client, true);
        emit InterchainClientAdded(client);
        if (updateLatest) {
            _setLatestClient(client);
        }
    }

    /// @dev Performs necessary checks and removes an Interchain Client. If this client is the latest one,
    /// the latest client is set to zero address (effectively pausing the app ability to send messages).
    /// Note: should be guarded with permission checks in the derived contracts.
    function _removeClient(address client) internal {
        if (!_isInterchainClient(client)) {
            revert InterchainApp__NotInterchainClient(client);
        }
        _toggleClientState(client, false);
        emit InterchainClientRemoved(client);
        if (client == _getLatestClient()) {
            _setLatestClient(address(0));
        }
    }

    /// @dev Sets the latest Interchain Client to one of the allowed clients. Setting the client to zero address
    /// is allowed and effectively pauses the app ability to send messages (but still allows to receive them).
    /// Note: should be guarded with permission checks in the derived contracts.
    function _setLatestClient(address client) internal {
        // New latest client must be an allowed client or zero address.
        if (!_isInterchainClient(client) && client != address(0)) {
            revert InterchainApp__NotInterchainClient(client);
        }
        if (client == _getLatestClient()) {
            revert InterchainApp__InterchainClientAlreadyLatest(client);
        }
        _storeLatestClient(client);
        emit LatestClientSet(client);
    }

    /// @dev Stores the address of the latest Interchain Client.
    /// - The exact storage location is up to the implementation.
    /// - Must NOT be called directly: use `_setLatestClient` instead.
    /// - Should not emit any events: this is done in the calling function.
    function _storeLatestClient(address client) internal virtual;

    /// @dev Toggle the state of the Interchain Client (allowed/disallowed to send messages to this app).
    /// - The client is checked to be in the opposite state before the change.
    /// - The exact storage location is up to the implementation.
    /// - Must NOT be called directly: use `_addClient` and `_removeClient` instead.
    /// - Should not emit any events: this is done in the calling functions.
    function _toggleClientState(address client, bool allowed) internal virtual;

    // ════════════════════════════════════════════ INTERNAL: MESSAGING ════════════════════════════════════════════════

    /// @dev Thin wrapper around _sendInterchainMessage to accept EVM address as a parameter.
    function _sendInterchainMessageEVM(
        uint64 dstChainId,
        address receiver,
        uint256 messageFee,
        bytes memory options,
        bytes memory message
    )
        internal
        returns (InterchainTxDescriptor memory desc)
    {
        return _sendInterchainMessage(dstChainId, receiver.addressToBytes32(), messageFee, options, message);
    }

    /// @dev Performs necessary checks and sends an interchain message.
    function _sendInterchainMessage(
        uint64 dstChainId,
        bytes32 receiver,
        uint256 messageFee,
        bytes memory options,
        bytes memory message
    )
        internal
        returns (InterchainTxDescriptor memory desc)
    {
        address client = _getLatestClient();
        if (client == address(0)) {
            revert InterchainApp__InterchainClientZeroAddress();
        }
        if (dstChainId == block.chainid) {
            revert InterchainApp__ChainIdNotRemote(dstChainId);
        }
        if (receiver == 0) {
            revert InterchainApp__ReceiverZeroAddress(dstChainId);
        }
        if (address(this).balance < messageFee) {
            revert InterchainApp__BalanceBelowMin({balance: address(this).balance, minRequired: messageFee});
        }
        return IInterchainClientV1(client).interchainSend{value: messageFee}(
            dstChainId, receiver, _getExecutionService(), _getModules(), options, message
        );
    }

    /// @dev Internal logic for receiving messages. At this point the validity of the message is already checked.
    function _receiveMessage(
        uint64 srcChainId,
        bytes32 sender,
        uint64 dbNonce,
        bytes calldata message
    )
        internal
        virtual;

    // ══════════════════════════════════════════════ INTERNAL VIEWS ═══════════════════════════════════════════════════

    /// @dev Returns the fee for sending an Interchain message.
    function _getInterchainFee(
        uint64 dstChainId,
        bytes memory options,
        uint256 messageLen
    )
        internal
        view
        returns (uint256)
    {
        address client = _getLatestClient();
        if (client == address(0)) {
            revert InterchainApp__InterchainClientZeroAddress();
        }
        return IInterchainClientV1(client).getInterchainFee(
            dstChainId, _getExecutionService(), _getModules(), options, messageLen
        );
    }

    /// @dev Returns the configuration of the app for validating the received messages.
    function _getAppConfig() internal view virtual returns (bytes memory);

    /// @dev Returns the address of the Execution Service to use for sending messages.
    function _getExecutionService() internal view virtual returns (address);

    /// @dev Returns the latest Interchain Client. This is the Client that is used for sending messages.
    function _getLatestClient() internal view virtual returns (address);

    /// @dev Returns the list of modules to use for sending messages, as well as validating the received messages.
    function _getModules() internal view virtual returns (address[] memory);

    /// @dev Checks if the sender is allowed to send messages to this app.
    function _isAllowedSender(uint64 srcChainId, bytes32 sender) internal view virtual returns (bool);

    /// @dev Checks if the caller is an Interchain Client.
    /// Both latest and legacy Interchain Clients are allowed to call `appReceive`.
    function _isInterchainClient(address caller) internal view virtual returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AbstractICApp, InterchainTxDescriptor} from "./AbstractICApp.sol";

import {InterchainAppV1Events} from "../events/InterchainAppV1Events.sol";
import {IInterchainAppV1} from "../interfaces/IInterchainAppV1.sol";
import {AppConfigV1, APP_CONFIG_GUARD_DISABLED, APP_CONFIG_GUARD_DEFAULT} from "../libs/AppConfig.sol";
import {Freezable} from "../libs/Freezable.sol";
import {OptionsV1} from "../libs/Options.sol";
import {TypeCasts} from "../libs/TypeCasts.sol";

import {AccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

abstract contract ICAppV1 is AbstractICApp, AccessControlEnumerable, InterchainAppV1Events, IInterchainAppV1 {
    using EnumerableSet for EnumerableSet.AddressSet;
    using TypeCasts for address;
    using TypeCasts for bytes32;

    /// @notice Role to manage the Interchain setup of the app.
    bytes32 public constant IC_GOVERNOR_ROLE = keccak256("IC_GOVERNOR_ROLE");

    /// @dev The enforced minimum gas limit for the interchain message.
    /// Note: could be overridden by the derived contract.
    uint256 private constant DEFAULT_MIN_GAS_LIMIT = 50_000;

    /// @dev The app config for the current app.
    AppConfigV1 private _appConfig;

    /// @dev Address of the linked app deployed on the remote chain.
    mapping(uint64 chainId => bytes32 remoteApp) private _linkedApp;

    /// @dev The linked apps frozen by the governor. Governor is no longer to change the linked app for the chain
    /// if it is frozen nor unfreeze it.
    Freezable private _frozenLinkedApps;

    /// @dev Set of Interchain Clients used for verification of messages received by the app.
    EnumerableSet.AddressSet private _interchainClients;
    /// @dev The latest version of Interchain Client.
    /// Note: this client will be used for sending all messages from this app.
    address private _latestClient;

    /// @dev Trusted Interchain modules.
    EnumerableSet.AddressSet private _trustedModules;

    /// @dev Execution Service to use for sending messages.
    address private _executionService;

    /// @dev The action frozen by the governor. Governor is no longer able to perform the action nor unfreeze it.
    Freezable private _frozenGovernorActions;

    /// @dev Modifier to check that the action has not been frozen.
    modifier whenGovernorActionNotFrozen(GovernorAction action) {
        if (_frozenGovernorActions.isFrozen(uint8(action))) {
            revert InterchainApp__GovernorActionFrozen();
        }
        _;
    }

    /// @dev Modifier to check that the linked app for the chain is not frozen.
    modifier whenLinkedAppNotFrozen(uint64 chainId) {
        if (_frozenLinkedApps.isFrozen(chainId)) {
            revert InterchainApp__LinkedAppFrozen();
        }
        _;
    }

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /// @notice Allows the governor to irreversibly freeze an action.
    /// Once the action is frozen, the governor is no longer able to perform the action nor unfreeze it.
    /// @dev Will revert if the action is already frozen.
    function freezeGovernorAction(GovernorAction action) external onlyRole(IC_GOVERNOR_ROLE) {
        _frozenGovernorActions.freeze(uint8(action));
        emit GovernorActionFrozen(uint8(action));
    }

    /// @notice Allows the governor to freeze the linked app for a specific chain.
    /// @dev Will revert if either of the following is true:
    /// - LinkRemoteApp action is frozen (hence no need to freeze any individual linked app)
    /// - The linked app for the chain is not configured
    /// - The linked app for the chain is already frozen
    function freezeLinkedApp(
        uint64 chainId
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.LinkRemoteApp)
    {
        if (_linkedApp[chainId] == 0) {
            revert InterchainApp__RemoteAppZeroAddress();
        }
        _frozenLinkedApps.freeze(chainId);
        emit LinkedAppFrozen(chainId);
    }

    /// @notice Allows the governor to add the interchain client to the allowed clients set,
    /// and optionally set the latest client to this one.
    /// Note: only the allowed clients can send messages to this app.
    /// Note: the latest client is used for sending messages from this app.
    /// @param client       The address of the interchain client to add.
    /// @param updateLatest Whether to set the latest client to this one.
    function addInterchainClient(
        address client,
        bool updateLatest
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.AddInterchainClient)
    {
        _addClient(client, updateLatest);
    }

    /// @notice Allows the governor to remove the interchain client from the allowed clients set.
    /// If the client is the latest client, the latest client is set to the zero address.
    /// @param client       The address of the interchain client to remove.
    function removeInterchainClient(
        address client
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.RemoveInterchainClient)
    {
        _removeClient(client);
    }

    /// @notice Allows the governor to set the address of the latest interchain client.
    /// @dev The new latest client must be an allowed client or zero address.
    /// Setting the client to zero address effectively pauses the app ability to send messages,
    /// while allowing to receive them.
    /// @param client       The address of the latest interchain client.
    function setLatestInterchainClient(
        address client
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.SetLatestInterchainClient)
    {
        _setLatestClient(client);
    }

    /// @notice Allows the governor to link the remote app for the given chain ID.
    /// - This address will be used as the receiver for the messages sent from this chain.
    /// - This address will be the only trusted sender for the messages sent to this chain.
    /// @param chainId      The remote chain ID.
    /// @param remoteApp    The address of the remote app to link.
    function linkRemoteApp(
        uint64 chainId,
        bytes32 remoteApp
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.LinkRemoteApp)
        whenLinkedAppNotFrozen(chainId)
    {
        _linkRemoteApp(chainId, remoteApp);
    }

    /// @notice Thin wrapper for `linkRemoteApp` to accept EVM address as a parameter.
    function linkRemoteAppEVM(
        uint64 chainId,
        address remoteApp
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.LinkRemoteApp)
        whenLinkedAppNotFrozen(chainId)
    {
        _linkRemoteApp(chainId, remoteApp.addressToBytes32());
    }

    /// @notice Allows the governor to add the module to the trusted modules set.
    /// - This set of modules will be used to verify both sent and received messages.
    function addTrustedModule(
        address module
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.AddTrustedModule)
    {
        if (module == address(0)) {
            revert InterchainApp__ModuleZeroAddress();
        }
        bool added = _trustedModules.add(module);
        if (!added) {
            revert InterchainApp__ModuleAlreadyAdded(module);
        }
        emit TrustedModuleAdded(module);
    }

    /// @notice Allows the governor to remove the module from the trusted modules set.
    function removeTrustedModule(
        address module
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.RemoveTrustedModule)
    {
        bool removed = _trustedModules.remove(module);
        if (!removed) {
            revert InterchainApp__ModuleNotAdded(module);
        }
        emit TrustedModuleRemoved(module);
    }

    /// @notice Allows the governor to set the guard config for the current app.
    /// @param guardFlag            The flag indicating the guard type (0 - none, 1 - client's default, 2 - custom)
    /// @param guard                The address of the guard (if the guardFlag is set to 2)
    /// @param optimisticSeconds    The time after which the module responses are optimistically considered correct
    function setGuardConfig(
        uint8 guardFlag,
        address guard,
        uint48 optimisticSeconds
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.SetGuardConfig)
    {
        bool isDisabledOrDefault = guardFlag == APP_CONFIG_GUARD_DISABLED || guardFlag == APP_CONFIG_GUARD_DEFAULT;
        // Guard address must be undefined WHEN AND ONLY WHEN Guard is disabled or default.
        if ((guard == address(0)) != isDisabledOrDefault) {
            revert InterchainApp__GuardConfigInvalid();
        }
        // For disabled Guard flag, the optimistic period must be 0.
        if (guardFlag == APP_CONFIG_GUARD_DISABLED && optimisticSeconds != 0) {
            revert InterchainApp__GuardConfigInvalid();
        }
        // For other Guard flags, the optimistic period is optional.
        AppConfigV1 memory newConfig = AppConfigV1({
            requiredResponses: _appConfig.requiredResponses,
            guardFlag: guardFlag,
            guard: guard,
            optimisticSeconds: optimisticSeconds
        });
        _appConfig = newConfig;
        emit GuardConfigSet(guardFlag, guard, optimisticSeconds);
    }

    /// @notice Allows the governor to set the required number of module responses for the current app.
    /// @dev The Interchain Client contract will use the amount of trusted modules as a fallback value,
    /// should the required number of responses be set to 0.
    /// @param requiredResponses    The number of module responses required for accepting the message
    function setRequiredResponses(
        uint8 requiredResponses
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.SetRequiredResponses)
    {
        _appConfig.requiredResponses = requiredResponses;
        emit RequiredResponsesSet(requiredResponses);
    }

    /// @notice Allows the governor to set the address of the Execution Service.
    /// This address will be used to request execution of the messages sent from this chain,
    /// by supplying the Service's execution fee.
    function setExecutionService(
        address executionService
    )
        external
        onlyRole(IC_GOVERNOR_ROLE)
        whenGovernorActionNotFrozen(GovernorAction.SetExecutionService)
    {
        _executionService = executionService;
        emit ExecutionServiceSet(executionService);
    }

    // ═══════════════════════════════════════════════════ VIEWS ═══════════════════════════════════════════════════════

    /// @notice Returns the app config for the current app:
    /// - requiredResponses: the number of module responses required for accepting the message
    /// - optimisticSeconds: the minimum time after which the module responses are considered final
    /// - guardFlag: the flag indicating the guard type (0 - none, 1 - client's default, 2 - custom)
    /// - guard: the address of the guard contract (if the guardFlag is set to 2)
    function getAppConfigV1() public view returns (AppConfigV1 memory) {
        return _appConfig;
    }

    /// @notice Returns the address of the Execution Service used by this app for sending messages.
    // solhint-disable-next-line ordering
    function getExecutionService() external view returns (address) {
        return _executionService;
    }

    /// @notice Returns the list of Interchain Clients allowed to send messages to this app.
    function getInterchainClients() external view returns (address[] memory) {
        return _interchainClients.values();
    }

    /// @notice Returns the address of the latest interchain client.
    /// This address is used for sending messages from this app.
    function getLatestInterchainClient() external view returns (address) {
        return _latestClient;
    }

    /// @notice Returns the linked app address (as bytes32) for the given chain ID.
    function getLinkedApp(uint64 chainId) external view returns (bytes32) {
        return _linkedApp[chainId];
    }

    /// @notice Thin wrapper for `getLinkedApp` to return the linked app address as EVM address.
    /// @dev Will revert if the linked app address is not an EVM address.
    function getLinkedAppEVM(uint64 chainId) external view returns (address linkedAppEVM) {
        bytes32 linkedApp = _linkedApp[chainId];
        linkedAppEVM = linkedApp.bytes32ToAddress();
        if (linkedAppEVM.addressToBytes32() != linkedApp) {
            revert InterchainApp__LinkedAppNotEVM(linkedApp);
        }
    }

    /// @notice Returns the list of Interchain Modules trusted by this app.
    /// This set of modules will be used to verify both sent and received messages.
    function getModules() external view returns (address[] memory) {
        return _trustedModules.values();
    }

    /// @notice Checks whether the given action has been frozen by the governor.
    /// @dev Governor is no longer able to perform any of the frozen actions nor unfreeze them.
    function isGovernorActionFrozen(GovernorAction action) external view returns (bool) {
        return _frozenGovernorActions.isFrozen(uint8(action));
    }

    /// @notice Checks whether the linked app for the given chain has been frozen by the governor.
    /// @dev Governor is no longer able to change the linked app for the chain nor unfreeze it.
    function isLinkedAppFrozen(uint64 chainId) external view returns (bool) {
        return _frozenLinkedApps.isFrozen(chainId);
    }

    /// @notice Returns the enforced minimum gas limit for sending an interchain message to the given chain.
    /// @dev Could be overridden by the derived contract.
    // solhint-disable-next-line no-unused-vars
    function getMinGasLimit(uint64 chainId) public view virtual returns (uint256) {
        return DEFAULT_MIN_GAS_LIMIT;
    }

    // ═══════════════════════════════════════════ INTERNAL: MANAGEMENT ════════════════════════════════════════════════

    /// @dev Links the remote app to the current app.
    /// Will revert if the chainId is the same as the chainId of the local app.
    /// Note: Should be guarded with permissions check.
    function _linkRemoteApp(uint64 chainId, bytes32 remoteApp) internal {
        if (chainId == block.chainid) {
            revert InterchainApp__ChainIdNotRemote(chainId);
        }
        if (remoteApp == 0) {
            revert InterchainApp__RemoteAppZeroAddress();
        }
        _linkedApp[chainId] = remoteApp;
        emit AppLinked(chainId, remoteApp);
    }

    /// @dev Stores the address of the latest Interchain Client.
    /// - The exact storage location is up to the implementation.
    /// - Must NOT be called directly: use `_setLatestClient` instead.
    /// - Should not emit any events: this is done in the calling function.
    function _storeLatestClient(address client) internal override {
        _latestClient = client;
    }

    /// @dev Toggle the state of the Interchain Client (allowed/disallowed to send messages to this app).
    /// - The client is checked to be in the opposite state before the change.
    /// - The exact storage location is up to the implementation.
    /// - Must NOT be called directly: use `_addClient` and `_removeClient` instead.
    /// - Should not emit any events: this is done in the calling functions.
    function _toggleClientState(address client, bool allowed) internal override {
        if (allowed) {
            _interchainClients.add(client);
        } else {
            _interchainClients.remove(client);
        }
    }

    // ════════════════════════════════════════════ INTERNAL: MESSAGING ════════════════════════════════════════════════

    /// @dev Thin wrapper around _sendInterchainMessage to send the message to the linked app.
    function _sendToLinkedApp(
        uint64 dstChainId,
        uint256 messageFee,
        OptionsV1 memory options,
        bytes memory message
    )
        internal
        returns (InterchainTxDescriptor memory)
    {
        if (options.gasLimit < getMinGasLimit(dstChainId)) {
            revert InterchainApp__RequestedGasLimitBelowMin();
        }
        bytes memory encodedOptions = options.encodeOptionsV1();
        return _sendInterchainMessage(dstChainId, _linkedApp[dstChainId], messageFee, encodedOptions, message);
    }

    // ══════════════════════════════════════════════ INTERNAL VIEWS ═══════════════════════════════════════════════════

    /// @dev Returns the fee to send a message to the linked app on the remote chain.
    function _getMessageFee(
        uint64 dstChainId,
        OptionsV1 memory options,
        uint256 messageLen
    )
        internal
        view
        returns (uint256)
    {
        if (options.gasLimit < getMinGasLimit(dstChainId)) {
            revert InterchainApp__RequestedGasLimitBelowMin();
        }
        bytes memory encodedOptions = options.encodeOptionsV1();
        return _getInterchainFee(dstChainId, encodedOptions, messageLen);
    }

    /// @dev Returns the configuration of the app for validating the received messages.
    function _getAppConfig() internal view override returns (bytes memory) {
        return getAppConfigV1().encodeAppConfigV1();
    }

    /// @dev Returns the address of the Execution Service to use for sending messages.
    function _getExecutionService() internal view override returns (address) {
        return _executionService;
    }

    /// @dev Returns the latest Interchain Client. This is the Client that is used for sending messages.
    function _getLatestClient() internal view override returns (address) {
        return _latestClient;
    }

    /// @dev Returns the list of modules to use for sending messages, as well as validating the received messages.
    function _getModules() internal view override returns (address[] memory) {
        return _trustedModules.values();
    }

    /// @dev Checks if the sender is allowed to send messages to this app.
    function _isAllowedSender(uint64 srcChainId, bytes32 sender) internal view override returns (bool) {
        return _linkedApp[srcChainId] == sender;
    }

    /// @dev Checks if the caller is an Interchain Client.
    /// Both latest and legacy Interchain Clients are allowed to call `appReceive`.
    function _isInterchainClient(address caller) internal view override returns (bool) {
        return _interchainClients.contains(caller);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {TokenController} from "./TokenController.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InterchainToken is ERC20, TokenController {
    uint8 internal immutable _DECIMALS;

    /// @notice Creates an InterchainToken: an ERC20 which is a TokenController for itself.
    /// @dev We pass address(0) as the token address to TokenController's constructor,
    /// as we override the `token()` function to return the address of the token itself.
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address admin_
    )
        ERC20(name_, symbol_)
        TokenController(address(0), admin_)
    {
        _DECIMALS = decimals_;
    }

    /// @inheritdoc ERC20
    function decimals() public view virtual override returns (uint8) {
        return _DECIMALS;
    }

    /// @notice Returns the address of the token that this controller is managing.
    /// @dev InterchainToken is both an InterchainApp and the underlying token, so it returns itself.
    function token() public view virtual override returns (address) {
        return address(this);
    }

    /// @dev Should give the `token` to the specified recipient.
    /// Returns the amount of tokens given to the recipient, in case it needs to be different from `amount` in the
    /// derived contract (e.g. fee is taken from the amount).
    function _giveToken(address recipient, uint256 amount) internal virtual override returns (uint256 amountGiven) {
        // This controller only deals with a mintable token without fees, so the amount given to the recipient is the
        // same as the amount requested.
        _mint(recipient, amount);
        return amount;
    }

    /// @dev Should take the `token` from msg.sender and prepare for the interchain transfer.
    /// Returns the amount of tokens that will be sent, in case it needs to be different from `amount` in the
    /// derived contract (e.g. fee is taken from the amount).
    /// Also returns the interchain fee that will be paid to the remote chain, in case the fee is different from
    /// `msg.value` (e.g. the token to send is a native token and the fee is in the same token).
    function _takeToken(
        uint256 amount
    )
        internal
        virtual
        override
        returns (uint256 amountToSend, uint256 interchainFee)
    {
        // This controller only deals with a mintable token without fees, so the amount to send is the same as the
        // amount requested.
        _burn(msg.sender, amount);
        // Additionally, full `msg.value` is treated as the interchain fee.
        return (amount, msg.value);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICAppV1, InterchainTxDescriptor, OptionsV1} from "./ICAppV1.sol";
import {ITokenRecipient} from "./interfaces/ITokenRecipient.sol";
import {TokenMessageLib} from "./libs/TokenMessage.sol";

import {TokenControllerEvents} from "../events/TokenControllerEvents.sol";
import {ITokenController} from "../interfaces/ITokenController.sol";
import {TypeCasts} from "../libs/TypeCasts.sol";

/// @notice A base contract for controlling the interchain issuance of a token.
/// The TokenController is utilizing the Interchain App V1 template for secure passing of messages between chains.
/// The credit and debit of the token is handled by the derived contract, the Controller is focusing on the interchain
/// communication protocol.
/// @dev It is strongly recommended to manage the tokens that have the same amount of decimals on different chains
/// in the derived contracts to avoid precision issues. Note that the TokenController does NOT imply that the amount
/// of tokens sent is the same as amount received, this is handled by the derived contract using the return values
/// of the `_giveToken` and `_takeToken` functions.
abstract contract TokenController is ICAppV1, TokenControllerEvents, ITokenController {
    /// @dev The default gas limit for the interchain message, which is used when
    /// the gas limit is not explicitly specified for the chain.
    /// Note: the derived contract can override `_getDefaultGasLimit` to provide a different default gas limit.`
    uint256 private constant DEFAULT_GAS_LIMIT = 150_000;

    /// @dev The address of the token that this controller is managing, set at construction time.
    address private immutable _TOKEN;

    /// @notice The gas limit to use when sending an interchain message related to sending a token to a remote chain.
    /// Note: if the gas limit is not specified for a chain, the default gas limit is used instead.
    mapping(uint64 chainId => uint256 gasLimit) public chainGasLimit;

    /// @notice Deploys a Controller for a token, and grants the default admin role to the given address.
    constructor(address token_, address admin) ICAppV1(admin) {
        _TOKEN = token_;
    }

    /// @notice Allows the governor to set the gas limit for sending an interchain message to a remote chain.
    /// @dev This gas limit will be used when an interchain message ise sent through `remoteSend`.
    function setGasLimit(uint64 chainId, uint256 gasLimit) external onlyRole(IC_GOVERNOR_ROLE) {
        chainGasLimit[chainId] = gasLimit;
        emit GasLimitSet(chainId, gasLimit);
    }

    /// @notice Send a token from the local chain to a recipient on a remote chain.
    /// @param dstChainId   The ID of the remote chain to send the token to.
    /// @param recipient    The address of the recipient on the remote chain, as a bytes32.
    /// @param amount       The amount of the token to send.
    function remoteSend(uint64 dstChainId, bytes32 recipient, uint256 amount) external payable {
        _remoteSend(dstChainId, recipient, amount);
    }

    /// @notice Send a token from the local chain to a recipient on a remote chain, then call a hook
    /// on the recipient contract to handle the token: ITokenRecipient.onICTokenReceived(token, amount, hookData)
    /// Note: to avoid bricked messages, the hook call will not be performed if the recipient contract is an EOA.
    /// @param dstChainId   The ID of the remote chain to send the token to.
    /// @param recipient    The address of the recipient on the remote chain, as a bytes32.
    /// @param amount       The amount of the token to send.
    /// @param hookGasLimit The additional gas limit to use for the hook call.
    /// @param hookData     The data to pass to the hook.
    function remoteSendWithHook(
        uint64 dstChainId,
        bytes32 recipient,
        uint256 amount,
        uint256 hookGasLimit,
        bytes memory hookData
    )
        external
        payable
    {
        _remoteSendWithHook(dstChainId, recipient, amount, hookGasLimit, hookData);
    }

    /// @notice Thin wrapper around `sendToken` that allows to specify the recipient address as an EVM address.
    function remoteSendEVM(uint64 dstChainId, address recipient, uint256 amount) external payable {
        _remoteSend(dstChainId, TypeCasts.addressToBytes32(recipient), amount);
    }

    /// @notice Thin wrapper around `remoteSendWithHook` that allows to specify the recipient address as an EVM address.
    function remoteSendEVMWithHook(
        uint64 dstChainId,
        address recipient,
        uint256 amount,
        uint256 hookGasLimit,
        bytes memory hookData
    )
        external
        payable
    {
        _remoteSendWithHook(dstChainId, TypeCasts.addressToBytes32(recipient), amount, hookGasLimit, hookData);
    }

    /// @notice Returns the Interchain fee to be paid, when a token is sent to a remote chain.
    /// @dev This needs to be fetched off-chain before doing the `remoteSend` call.
    function getRemoteSendFee(uint64 dstChainId) external view returns (uint256) {
        return _getMessageFee({
            dstChainId: dstChainId,
            options: OptionsV1({gasLimit: _getBasicGasLimit(dstChainId), gasAirdrop: 0}),
            messageLen: TokenMessageLib.getMessageLength({hookDataLength: 0})
        });
    }

    /// @notice Returns the Interchain fee to be paid, when a token is sent to a remote chain with a hook.
    /// @dev This needs to be fetched off-chain before doing the `remoteSendWithHook` call.
    function getRemoteSendWithHookFee(
        uint64 dstChainId,
        uint256 hookGasLimit,
        uint256 hookDataLength
    )
        external
        view
        returns (uint256)
    {
        return _getMessageFee({
            dstChainId: dstChainId,
            options: OptionsV1({gasLimit: _getBasicGasLimit(dstChainId) + hookGasLimit, gasAirdrop: 0}),
            messageLen: TokenMessageLib.getMessageLength({hookDataLength: hookDataLength})
        });
    }

    /// @notice Returns the address of the token that this controller is managing.
    function token() public view virtual returns (address) {
        return _TOKEN;
    }

    /// @dev Internal logic for receiving messages. At this point the validity of the message is already checked.
    function _receiveMessage(
        uint64 srcChainId,
        bytes32, // sender
        uint64 dbNonce,
        bytes calldata message
    )
        internal
        override
    {
        (uint16 version, bytes32 tokenRecipient, uint256 amount, bytes calldata hookData) =
            TokenMessageLib.decodeMessage(message);
        // Note: we discard the highest 12 bytes here! In the event that someone included the dirty bytes
        // (by mistake or not), the token will be sent to the corresponding EVM address without bricking
        // the execution of the message.
        address recipient = TypeCasts.bytes32ToAddress(tokenRecipient);
        // We give the token to the recipient regardless of the message version
        uint256 amountGiven = _giveToken(recipient, amount);
        emit TokenReceived(srcChainId, dbNonce, tokenRecipient, amountGiven);
        // Trigger the hook call if instructed AND the recipient is not an EOA.
        // Hook call will revert if the recipient is EOA, therefore we skip it to avoid bricked messages.
        if (version == TokenMessageLib.VERSION_HOOK && recipient.code.length != 0) {
            ITokenRecipient(recipient).onICTokenReceived(token(), amountGiven, hookData);
        }
    }

    /// @dev Takes token from the sender and sends it to the remote recipient by utilizing the InterchainClient.
    function _remoteSend(uint64 dstChainId, bytes32 recipient, uint256 amount) internal {
        (uint256 amountToSend, uint256 interchainFee) = _takeToken(amount);
        InterchainTxDescriptor memory desc = _sendToLinkedApp({
            dstChainId: dstChainId,
            messageFee: interchainFee,
            options: OptionsV1({gasLimit: _getBasicGasLimit(dstChainId), gasAirdrop: 0}),
            message: TokenMessageLib.encodeBasicMessage(recipient, amountToSend)
        });
        emit TokenSent(dstChainId, desc.dbNonce, recipient, amountToSend);
    }

    /// @dev Takes token from the sender and sends it to the remote recipient with a hook call
    /// by utilizing the InterchainClient.
    function _remoteSendWithHook(
        uint64 dstChainId,
        bytes32 recipient,
        uint256 amount,
        uint256 hookGasLimit,
        bytes memory hookData
    )
        internal
    {
        (uint256 amountToSend, uint256 interchainFee) = _takeToken(amount);
        InterchainTxDescriptor memory desc = _sendToLinkedApp({
            dstChainId: dstChainId,
            messageFee: interchainFee,
            options: OptionsV1({gasLimit: _getBasicGasLimit(dstChainId) + hookGasLimit, gasAirdrop: 0}),
            message: TokenMessageLib.encodeHookMessage(recipient, amountToSend, hookData)
        });
        emit TokenSent(dstChainId, desc.dbNonce, recipient, amountToSend);
    }

    /// @dev Should give the `token` to the specified recipient.
    /// Returns the amount of tokens given to the recipient, in case it needs to be different from `amount` in the
    /// derived contract (e.g. fee is taken from the amount).
    function _giveToken(address recipient, uint256 amount) internal virtual returns (uint256 amountGiven);

    /// @dev Should take the `token` from msg.sender and prepare for the interchain transfer.
    /// Returns the amount of tokens that will be sent, in case it needs to be different from `amount` in the
    /// derived contract (e.g. fee is taken from the amount).
    /// Also returns the interchain fee that will be paid to the remote chain, in case the fee is different from
    /// `msg.value` (e.g. the token to send is a native token and the fee is in the same token).
    function _takeToken(uint256 amount) internal virtual returns (uint256 amountToSend, uint256 interchainFee);

    /// @dev Returns the gas limit to use for the basic token message.
    /// Note: the hook gas limit should be added on top of the basic gas limit.
    function _getBasicGasLimit(uint64 dstChainId) internal view returns (uint256 gasLimit) {
        gasLimit = chainGasLimit[dstChainId];
        if (gasLimit == 0) {
            gasLimit = _getDefaultGasLimit();
        }
    }

    /// @dev Returns the default gas limit for the interchain message, which is used when
    /// the gas limit is not explicitly specified for the chain.
    /// Note: could be overridden in the derived contract to provide a different default gas limit.
    function _getDefaultGasLimit() internal pure virtual returns (uint256) {
        return DEFAULT_GAS_LIMIT;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenRecipient {
    /// @notice Hook function that is optionally called by `TokenController` after the
    /// token is received. This is only called if the token sender on the source chain provided
    /// the instructions with the `hookData`.
    /// @dev Recipient MUST check that the caller of this function is a `TokenController` for `token`
    /// to avoid security issues.
    function onICTokenReceived(address token, uint256 amount, bytes memory hookData) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {VersionedPayloadLib} from "../../libs/VersionedPayload.sol";

library TokenMessageLib {
    uint16 internal constant VERSION_BASIC = 0;
    uint16 internal constant VERSION_HOOK = 1;

    /// @dev Offset of the hook data within the non-versioned payload of the token message:
    /// - 32 bytes for the token recipient
    /// - 32 bytes for the amount
    uint256 internal constant HOOK_DATA_OFFSET = 64;

    /// @dev The size of the basic token message in bytes:
    /// - 2 bytes for the version
    /// - 32 bytes for the token recipient
    /// - 32 bytes for the amount
    uint256 internal constant BASIC_MESSAGE_LENGTH = VersionedPayloadLib.VERSION_LENGTH + HOOK_DATA_OFFSET;

    error TokenMessageLib__UnsupportedVersion(uint16 version);

    /// @notice Encodes a basic token message: the request for the recipient to receive
    /// the given amount of the token.
    /// @param tokenRecipient   The recipient of the token.
    /// @param amount           The amount of the token.
    /// @return                 The encoded token message.
    function encodeBasicMessage(bytes32 tokenRecipient, uint256 amount) internal pure returns (bytes memory) {
        return VersionedPayloadLib.encodeVersionedPayload({
            version: VERSION_BASIC,
            payload: abi.encode(tokenRecipient, amount)
        });
    }

    /// @notice Encodes a token message with a hook: the request for the recipient to receive
    /// the given amount of the token, then triggering the hook with the given data.
    /// @param tokenRecipient   The recipient of the token.
    /// @param amount           The amount of the token.
    /// @param hookData         The hook data.
    /// @return                 The encoded token message.
    function encodeHookMessage(
        bytes32 tokenRecipient,
        uint256 amount,
        bytes memory hookData
    )
        internal
        pure
        returns (bytes memory)
    {
        return VersionedPayloadLib.encodeVersionedPayload({
            version: VERSION_HOOK,
            payload: abi.encodePacked(tokenRecipient, amount, hookData)
        });
    }

    /// @notice Decodes a token message into the instructions for the recipient to receive
    /// the given amount of the token.
    /// @param message          The token message.
    /// @return version         The version of the token message.
    /// @return tokenRecipient  The recipient of the token.
    /// @return amount          The amount of the token.
    /// @return hookData        The hook data.
    function decodeMessage(
        bytes calldata message
    )
        internal
        pure
        returns (uint16 version, bytes32 tokenRecipient, uint256 amount, bytes calldata hookData)
    {
        version = VersionedPayloadLib.getVersion(message);
        if (version > VERSION_HOOK) {
            revert TokenMessageLib__UnsupportedVersion(version);
        }
        // Get the non-versioned payload of the token message:
        // - 32 bytes for the token recipient
        // - 32 bytes for the amount
        // - The remaining bytes for the hook data
        bytes calldata payload = VersionedPayloadLib.getPayload(message);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            tokenRecipient := calldataload(payload.offset)
            amount := calldataload(add(payload.offset, 32))
        }
        hookData = payload[HOOK_DATA_OFFSET:];
    }

    /// @notice Returns the length of the token message with the given hook data length.
    /// @dev Use hook data length of 0 for a basic message.
    function getMessageLength(uint256 hookDataLength) internal pure returns (uint256) {
        return BASIC_MESSAGE_LENGTH + hookDataLength;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract AbstractICAppEvents {
    /// @notice Emitted when a new interchain client is added.
    /// This client will be able to send messages to the app.
    /// @param client   The address of the client.
    event InterchainClientAdded(address client);

    /// @notice Emitted when an interchain client is removed.
    /// @param client   The address of the client.
    event InterchainClientRemoved(address client);

    /// @notice Emitted when the latest interchain client is set.
    /// This client will be used by the app to send messages.
    /// @param client   The address of the client.
    event LatestClientSet(address client);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract CXEvents {
    event AllowListToggled(address indexed account, bool isAllowed);
    event TransfersEnabled();
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract InterchainAppV1Events {
    /// @notice Emitted when an action is frozen. See IInterchainAppV1.GovernorAction enum for details.
    /// @param action               The action that was frozen.
    event GovernorActionFrozen(uint256 action);

    /// @notice Emitted when a linked app is frozen for a specific chain.
    /// @param chainId              The chain ID with the frozen linked app.
    event LinkedAppFrozen(uint64 chainId);

    /// @notice Emitted when the app configuration V1 is set.
    /// The V1 version of app config requests at least N confirmations that are at least T seconds old
    /// from trusted modules to execute a transaction.
    /// @param requiredResponses    The number of module responses required for a transaction to be executed.
    /// @param optimisticSeconds     The time period after which a module response is considered final.
    event AppConfigV1Set(uint256 requiredResponses, uint256 optimisticSeconds);

    /// @notice Emitted when a remote instance of the app is linked.
    /// This instance is the only one that can send messages to this app from the remote chain.
    /// @param chainId              The remote chain ID.
    /// @param remoteApp            The address of the remote app on that chain.
    event AppLinked(uint64 chainId, bytes32 remoteApp);

    /// @notice Emitted when the execution service is set.
    /// This service will be used for requesting the execution of transactions on the remote chain.
    /// @param executionService     The address of the execution service.
    event ExecutionServiceSet(address executionService);

    /// @notice Emitted when the guard config is set.
    /// @param guardFlag            The flag indicating the guard type (0 - none, 1 - client's default, 2 - custom)
    /// @param guard                The address of the guard contract (if the guardFlag is set to 2)
    /// @param optimisticSeconds    The minimum time after which the module responses are considered final
    event GuardConfigSet(uint8 guardFlag, address guard, uint48 optimisticSeconds);

    /// @notice Emitted when the required number of module responses is set.
    /// @param requiredResponses    The number of module responses required for accepting the message
    event RequiredResponsesSet(uint8 requiredResponses);

    /// @notice Emitted when a trusted module is added.
    /// The trusted modules will be used to verify the messages coming from the remote chains,
    /// as well as request the verification of the sent messages on the remote chains.
    /// @param module               The address of the trusted module that was added.
    event TrustedModuleAdded(address module);

    /// @notice Emitted when a trusted module is removed.
    /// @param module               The address of the trusted module that was removed.
    event TrustedModuleRemoved(address module);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract TokenControllerEvents {
    event GasLimitSet(uint64 chainId, uint256 gasLimit);

    /// @notice Emitted when a token is sent to a remote chain through the TokenController.
    /// @param dstChainId   The chain ID of the chain where the token is sent to.
    /// @param dbNonce      The nonce of the underlying interchain message.
    /// @param recipient    The address of the recipient on the remote chain, as bytes32.
    /// @param amount       The amount of the token sent.
    event TokenSent(uint64 indexed dstChainId, uint64 indexed dbNonce, bytes32 indexed recipient, uint256 amount);

    /// @notice Emitted when a token is received from a remote chain through the TokenController.
    /// @param srcChainId   The chain ID of the chain where the token is received from.
    /// @param dbNonce      The nonce of the underlying interchain message.
    /// @param recipient    The address of the recipient on local chain, as bytes32.
    /// @param amount       The amount of the token received.
    event TokenReceived(uint64 indexed srcChainId, uint64 indexed dbNonce, bytes32 indexed recipient, uint256 amount);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Minimal interface for the Interchain App to work with the Interchain Client.
interface IInterchainApp {
    function appReceive(uint64 srcChainId, bytes32 sender, uint64 dbNonce, bytes calldata message) external payable;

    // ═══════════════════════════════════════════════════ VIEWS ═══════════════════════════════════════════════════════

    function getReceivingConfig() external view returns (bytes memory appConfig, address[] memory modules);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AppConfigV1} from "../libs/AppConfig.sol";

import {IInterchainApp} from "./IInterchainApp.sol";

interface IInterchainAppV1 is IInterchainApp {
    enum GovernorAction {
        AddInterchainClient,
        RemoveInterchainClient,
        SetLatestInterchainClient,
        AddTrustedModule,
        RemoveTrustedModule,
        SetRequiredResponses,
        SetGuardConfig,
        LinkRemoteApp,
        SetExecutionService
    }

    error InterchainApp__AppConfigInvalid(uint256 requiredResponses, uint256 optimisticSeconds);
    error InterchainApp__GovernorActionFrozen();
    error InterchainApp__GuardConfigInvalid();
    error InterchainApp__LinkedAppFrozen();
    error InterchainApp__LinkedAppNotEVM(bytes32 linkedApp);
    error InterchainApp__ModuleAlreadyAdded(address module);
    error InterchainApp__ModuleNotAdded(address module);
    error InterchainApp__ModuleZeroAddress();
    error InterchainApp__RemoteAppZeroAddress();
    error InterchainApp__RequestedGasLimitBelowMin();

    function freezeGovernorAction(GovernorAction action) external;
    function freezeLinkedApp(uint64 chainId) external;

    function addInterchainClient(address client, bool updateLatest) external;
    function removeInterchainClient(address client) external;
    function setLatestInterchainClient(address client) external;

    function linkRemoteApp(uint64 chainId, bytes32 remoteApp) external;
    function linkRemoteAppEVM(uint64 chainId, address remoteApp) external;

    function addTrustedModule(address module) external;
    function removeTrustedModule(address module) external;
    function setGuardConfig(uint8 guardFlag, address guard, uint48 optimisticSeconds) external;
    function setRequiredResponses(uint8 requiredResponses) external;
    function setExecutionService(address executionService) external;

    // ═══════════════════════════════════════════════════ VIEWS ═══════════════════════════════════════════════════════

    function getAppConfigV1() external view returns (AppConfigV1 memory);
    function getExecutionService() external view returns (address);
    function getInterchainClients() external view returns (address[] memory);
    function getLatestInterchainClient() external view returns (address);
    function getLinkedApp(uint64 chainId) external view returns (bytes32);
    function getLinkedAppEVM(uint64 chainId) external view returns (address);
    function getModules() external view returns (address[] memory);

    function isGovernorActionFrozen(GovernorAction action) external view returns (bool);
    function isLinkedAppFrozen(uint64 chainId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {InterchainTransaction, InterchainTxDescriptor} from "../libs/InterchainTransaction.sol";

interface IInterchainClientV1 {
    enum TxReadiness {
        Ready,
        AlreadyExecuted,
        EntryAwaitingResponses,
        EntryConflict,
        ReceiverNotICApp,
        TxWrongDstChainId,
        UndeterminedRevert
    }

    error InterchainClientV1__ChainIdNotLinked(uint64 chainId);
    error InterchainClientV1__ChainIdNotRemote(uint64 chainId);
    error InterchainClientV1__DstChainIdNotLocal(uint64 chainId);
    error InterchainClientV1__EntryConflict(address module);
    error InterchainClientV1__ExecutionServiceZeroAddress();
    error InterchainClientV1__FeeAmountBelowMin(uint256 feeAmount, uint256 minRequired);
    error InterchainClientV1__GasLeftBelowMin();
    error InterchainClientV1__GuardZeroAddress();
    error InterchainClientV1__LinkedClientNotEVM(bytes32 client);
    error InterchainClientV1__ModuleZeroAddress();
    error InterchainClientV1__MsgValueMismatch(uint256 msgValue, uint256 required);
    error InterchainClientV1__ReceiverNotICApp(address receiver);
    error InterchainClientV1__ReceiverZeroAddress();
    error InterchainClientV1__ResponsesAmountBelowMin(uint256 responsesAmount, uint256 minRequired);
    error InterchainClientV1__RequestedGasLimitZero();
    error InterchainClientV1__TxAlreadyExecuted(bytes32 transactionId);
    error InterchainClientV1__TxNotExecuted(bytes32 transactionId);
    error InterchainClientV1__TxVersionMismatch(uint16 txVersion, uint16 required);

    function setDefaultGuard(address guard) external;
    function setDefaultModule(address module) external;
    function setLinkedClient(uint64 chainId, bytes32 client) external;

    function interchainSend(
        uint64 dstChainId,
        bytes32 receiver,
        address srcExecutionService,
        address[] calldata srcModules,
        bytes calldata options,
        bytes calldata message
    )
        external
        payable
        returns (InterchainTxDescriptor memory desc);

    function interchainSendEVM(
        uint64 dstChainId,
        address receiver,
        address srcExecutionService,
        address[] calldata srcModules,
        bytes calldata options,
        bytes calldata message
    )
        external
        payable
        returns (InterchainTxDescriptor memory desc);

    function interchainExecute(uint256 gasLimit, bytes calldata transaction) external payable;

    function writeExecutionProof(bytes32 transactionId) external returns (uint64 dbNonce);

    // ═══════════════════════════════════════════════════ VIEWS ═══════════════════════════════════════════════════════

    function isExecutable(bytes calldata transaction) external view returns (bool);
    function getTxReadinessV1(
        InterchainTransaction memory icTx
    )
        external
        view
        returns (TxReadiness status, bytes32 firstArg, bytes32 secondArg);

    function getInterchainFee(
        uint64 dstChainId,
        address srcExecutionService,
        address[] calldata srcModules,
        bytes calldata options,
        uint256 messageLen
    )
        external
        view
        returns (uint256);

    function getExecutor(bytes calldata transaction) external view returns (address);
    function getExecutorById(bytes32 transactionId) external view returns (address);
    function getLinkedClient(uint64 chainId) external view returns (bytes32);
    function getLinkedClientEVM(uint64 chainId) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenController {
    function remoteSend(uint64 dstChainId, bytes32 recipient, uint256 amount) external payable;

    function remoteSendWithHook(
        uint64 dstChainId,
        bytes32 recipient,
        uint256 amount,
        uint256 hookGasLimit,
        bytes memory hookData
    )
        external
        payable;

    function remoteSendEVM(uint64 dstChainId, address recipient, uint256 amount) external payable;

    function remoteSendEVMWithHook(
        uint64 dstChainId,
        address recipient,
        uint256 amount,
        uint256 hookGasLimit,
        bytes memory hookData
    )
        external
        payable;

    function getRemoteSendFee(uint64 dstChainId) external view returns (uint256);

    function getRemoteSendWithHookFee(
        uint64 dstChainId,
        uint256 hookGasLimit,
        uint256 hookDataLength
    )
        external
        view
        returns (uint256);

    function token() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {VersionedPayloadLib} from "./VersionedPayload.sol";

struct AppConfigV1 {
    uint8 requiredResponses;
    uint48 optimisticSeconds;
    uint8 guardFlag;
    address guard;
}

using AppConfigLib for AppConfigV1 global;

/// @dev Signals that the app opted out of using any Guard module.
uint8 constant APP_CONFIG_GUARD_DISABLED = 0;
/// @dev Signals that the app uses the default Guard module provided by InterchainClient contract.
uint8 constant APP_CONFIG_GUARD_DEFAULT = 1;
/// @dev Signals that the app uses a custom Guard module.
uint8 constant APP_CONFIG_GUARD_CUSTOM = 2;

library AppConfigLib {
    using VersionedPayloadLib for bytes;

    uint16 internal constant APP_CONFIG_V1 = 1;

    error AppConfigLib__VersionInvalid(uint16 version);

    /// @notice Decodes app config (V1 or higher) from a bytes format back into an AppConfigV1 struct.
    /// @param data         The app config data in bytes format.
    function decodeAppConfigV1(bytes memory data) internal view returns (AppConfigV1 memory) {
        uint16 version = data.getVersionFromMemory();
        if (version < APP_CONFIG_V1) {
            revert AppConfigLib__VersionInvalid(version);
        }
        // Structs of the same version will always be decoded correctly.
        // Following versions will be decoded correctly if they have the same fields as the previous version,
        // and new fields at the end: abi.decode ignores the extra bytes in the decoded payload.
        return abi.decode(data.getPayloadFromMemory(), (AppConfigV1));
    }

    /// @notice Encodes V1 app config into a bytes format.
    /// @param appConfig    The AppConfigV1 to encode.
    function encodeAppConfigV1(AppConfigV1 memory appConfig) internal pure returns (bytes memory) {
        return VersionedPayloadLib.encodeVersionedPayload(APP_CONFIG_V1, abi.encode(appConfig));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

/// @notice Stores freeze status for a set of uint256 ids.
/// Once the id is frozen, it cannot be unfrozen.
struct Freezable {
    BitMaps.BitMap _frozenIds;
}

using FreezableLib for Freezable global;

library FreezableLib {
    using BitMaps for BitMaps.BitMap;

    error Freezable__AlreadyFrozen();

    /// @notice Freezes the given id.
    /// @dev Will revert if the id is already frozen.
    function freeze(Freezable storage self, uint256 id) internal {
        if (isFrozen(self, id)) {
            revert Freezable__AlreadyFrozen();
        }
        self._frozenIds.set(id);
    }

    /// @notice Checks if the given id is frozen.
    function isFrozen(Freezable storage self, uint256 id) internal view returns (bool) {
        return self._frozenIds.get(id);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MathLib} from "./Math.sol";
import {TypeCasts} from "./TypeCasts.sol";
import {VersionedPayloadLib} from "./VersionedPayload.sol";

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

type ICTxHeader is uint256;

struct InterchainTransaction {
    uint64 srcChainId;
    uint64 dstChainId;
    uint64 dbNonce;
    bytes32 srcSender;
    bytes32 dstReceiver;
    bytes options;
    bytes message;
}

struct InterchainTxDescriptor {
    bytes32 transactionId;
    uint64 dbNonce;
}

using InterchainTransactionLib for InterchainTransaction global;

library InterchainTransactionLib {
    using MathLib for uint256;
    using VersionedPayloadLib for bytes;

    function constructLocalTransaction(
        address srcSender,
        uint64 dstChainId,
        bytes32 dstReceiver,
        uint64 dbNonce,
        bytes memory options,
        bytes memory message
    )
        internal
        view
        returns (InterchainTransaction memory transaction)
    {
        return InterchainTransaction({
            srcChainId: SafeCast.toUint64(block.chainid),
            srcSender: TypeCasts.addressToBytes32(srcSender),
            dstChainId: dstChainId,
            dstReceiver: dstReceiver,
            dbNonce: dbNonce,
            options: options,
            message: message
        });
    }

    function encodeTransaction(InterchainTransaction memory transaction) internal pure returns (bytes memory) {
        return abi.encode(
            encodeTxHeader(transaction.srcChainId, transaction.dstChainId, transaction.dbNonce),
            transaction.srcSender,
            transaction.dstReceiver,
            transaction.options,
            transaction.message
        );
    }

    function decodeTransaction(bytes calldata transaction) internal pure returns (InterchainTransaction memory icTx) {
        ICTxHeader header;
        (header, icTx.srcSender, icTx.dstReceiver, icTx.options, icTx.message) =
            abi.decode(transaction, (ICTxHeader, bytes32, bytes32, bytes, bytes));
        (icTx.srcChainId, icTx.dstChainId, icTx.dbNonce) = decodeTxHeader(header);
    }

    function payloadSize(uint256 optionsLen, uint256 messageLen) internal pure returns (uint256) {
        // 2 bytes are reserved for the transaction version
        // + 5 fields * 32 bytes (3 values for static, 2 offsets for dynamic) + 2 * 32 bytes (lengths for dynamic) = 226
        // (srcChainId, dstChainId, dbNonce) are merged into a single 32 bytes field
        // Both options and message are dynamic fields, which are padded up to 32 bytes
        return 226 + optionsLen.roundUpToWord() + messageLen.roundUpToWord();
    }

    function encodeTxHeader(uint64 srcChainId, uint64 dstChainId, uint64 dbNonce) internal pure returns (ICTxHeader) {
        return ICTxHeader.wrap((uint256(srcChainId) << 128) | (uint256(dstChainId) << 64) | (uint256(dbNonce)));
    }

    function decodeTxHeader(
        ICTxHeader header
    )
        internal
        pure
        returns (uint64 srcChainId, uint64 dstChainId, uint64 dbNonce)
    {
        srcChainId = uint64(ICTxHeader.unwrap(header) >> 128);
        dstChainId = uint64(ICTxHeader.unwrap(header) >> 64);
        dbNonce = uint64(ICTxHeader.unwrap(header));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library MathLib {
    /// @notice Rounds up to the nearest multiple of 32.
    /// Note: Returns zero on overflows instead of reverting. This is fine for practical
    /// use cases, as this is used for determining the size of the payload in memory.
    function roundUpToWord(uint256 x) internal pure returns (uint256) {
        unchecked {
            return (x + 31) & ~uint256(31);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {VersionedPayloadLib} from "./VersionedPayload.sol";

/// @notice Struct to hold V1 of options data.
/// @dev Next versions have to use the fields from the previous version and add new fields at the end.
/// @param gasLimit The gas limit for the transaction.
/// @param gasAirdrop The amount of gas to airdrop.
struct OptionsV1 {
    uint256 gasLimit;
    uint256 gasAirdrop;
}

using OptionsLib for OptionsV1 global;

/// @title OptionsLib
/// @notice A library for encoding and decoding Interchain options related to interchain messages.
library OptionsLib {
    using VersionedPayloadLib for bytes;

    uint16 internal constant OPTIONS_V1 = 1;

    error OptionsLib__VersionInvalid(uint16 version);

    /// @notice Decodes options (V1 or higher) from a bytes format back into an OptionsV1 struct.
    /// @param data         The options data in bytes format.
    function decodeOptionsV1(bytes memory data) internal view returns (OptionsV1 memory) {
        uint16 version = data.getVersionFromMemory();
        if (version < OPTIONS_V1) {
            revert OptionsLib__VersionInvalid(version);
        }
        // Structs of the same version will always be decoded correctly.
        // Following versions will be decoded correctly if they have the same fields as the previous version,
        // and new fields at the end: abi.decode ignores the extra bytes in the decoded payload.
        return abi.decode(data.getPayloadFromMemory(), (OptionsV1));
    }

    /// @notice Encodes V1 options into a bytes format.
    /// @param options      The OptionsV1 to encode.
    function encodeOptionsV1(OptionsV1 memory options) internal pure returns (bytes memory) {
        return VersionedPayloadLib.encodeVersionedPayload(OPTIONS_V1, abi.encode(options));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library TypeCasts {
    function addressToBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function bytes32ToAddress(bytes32 b) internal pure returns (address) {
        return address(uint160(uint256(b)));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// solhint-disable no-inline-assembly
// solhint-disable ordering
library VersionedPayloadLib {
    /// @notice Amount of bytes reserved for the version (uint16) in the versioned payload
    uint256 internal constant VERSION_LENGTH = 2;

    error VersionedPayload__PayloadTooShort(bytes versionedPayload);
    error VersionedPayload__PrecompileFailed();

    /// @notice Encodes the versioned payload into a single bytes array.
    /// @param version  The payload's version.
    /// @param payload  The payload to encode.
    function encodeVersionedPayload(uint16 version, bytes memory payload) internal pure returns (bytes memory) {
        return abi.encodePacked(version, payload);
    }

    /// @notice Extracts the version from the versioned payload (calldata reference).
    /// @param versionedPayload     The versioned payload (calldata reference).
    function getVersion(bytes calldata versionedPayload) internal pure returns (uint16 version) {
        if (versionedPayload.length < VERSION_LENGTH) {
            revert VersionedPayload__PayloadTooShort(versionedPayload);
        }
        assembly {
            // We are only interested in the highest 16 bits of the loaded full 32 bytes word.
            version := shr(240, calldataload(versionedPayload.offset))
        }
    }

    /// @notice Extracts the payload from the versioned payload (calldata reference).
    /// @dev The extracted payload is also returned as a calldata reference.
    /// @param versionedPayload     The versioned payload.
    function getPayload(bytes calldata versionedPayload) internal pure returns (bytes calldata) {
        if (versionedPayload.length < VERSION_LENGTH) {
            revert VersionedPayload__PayloadTooShort(versionedPayload);
        }
        return versionedPayload[VERSION_LENGTH:];
    }

    /// @notice Extracts the version from the versioned payload (memory reference).
    /// @param versionedPayload     The versioned payload (memory reference).
    function getVersionFromMemory(bytes memory versionedPayload) internal pure returns (uint16 version) {
        if (versionedPayload.length < VERSION_LENGTH) {
            revert VersionedPayload__PayloadTooShort(versionedPayload);
        }
        assembly {
            // We are only interested in the highest 16 bits of the loaded full 32 bytes word.
            // We add 0x20 to skip the length of the bytes array.
            version := shr(240, mload(add(versionedPayload, 0x20)))
        }
    }

    /// @notice Extracts the payload from the versioned payload (memory reference).
    /// @dev The extracted payload is copied into a new memory location. Use `getPayload` when possible
    /// to avoid extra memory allocation.
    /// @param versionedPayload     The versioned payload (memory reference).
    function getPayloadFromMemory(bytes memory versionedPayload) internal view returns (bytes memory payload) {
        if (versionedPayload.length < VERSION_LENGTH) {
            revert VersionedPayload__PayloadTooShort(versionedPayload);
        }
        // Figure how many bytes to copy and allocate the memory for the extracted payload.
        uint256 toCopy;
        unchecked {
            toCopy = versionedPayload.length - VERSION_LENGTH;
        }
        payload = new bytes(toCopy);
        // Use identity precompile (0x04) to copy the payload. Unlike MCOPY, this is available on all EVM chains.
        bool res;
        assembly {
            // We add 0x20 to skip the length of the bytes array.
            // We add 0x02 to skip the 2 bytes reserved for the version.
            // Copy the payload to the previously allocated memory.
            res := staticcall(gas(), 0x04, add(versionedPayload, 0x22), toCopy, add(payload, 0x20), toCopy)
        }
        if (!res) {
            revert VersionedPayload__PrecompileFailed();
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "./IAccessControl.sol";
import {Context} from "../utils/Context.sol";
import {ERC165} from "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/extensions/AccessControlEnumerable.sol)

pragma solidity ^0.8.20;

import {IAccessControlEnumerable} from "./IAccessControlEnumerable.sol";
import {AccessControl} from "../AccessControl.sol";
import {EnumerableSet} from "../../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 role => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {AccessControl-_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override returns (bool) {
        bool granted = super._grantRole(role, account);
        if (granted) {
            _roleMembers[role].add(account);
        }
        return granted;
    }

    /**
     * @dev Overload {AccessControl-_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override returns (bool) {
        bool revoked = super._revokeRole(role, account);
        if (revoked) {
            _roleMembers[role].remove(account);
        }
        return revoked;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/extensions/IAccessControlEnumerable.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "../IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (governance/utils/IVotes.sol)
pragma solidity ^0.8.20;

/**
 * @dev Common interface for {ERC20Votes}, {ERC721Votes}, and other {Votes}-enabled contracts.
 */
interface IVotes {
    /**
     * @dev The signature used has expired.
     */
    error VotesExpiredSignature(uint256 expiry);

    /**
     * @dev Emitted when an account changes their delegate.
     */
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /**
     * @dev Emitted when a token transfer or delegate change results in changes to a delegate's number of voting units.
     */
    event DelegateVotesChanged(address indexed delegate, uint256 previousVotes, uint256 newVotes);

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of votes that `account` had at a specific moment in the past. If the `clock()` is
     * configured to use block numbers, this will return the value at the end of the corresponding block.
     */
    function getPastVotes(address account, uint256 timepoint) external view returns (uint256);

    /**
     * @dev Returns the total supply of votes available at a specific moment in the past. If the `clock()` is
     * configured to use block numbers, this will return the value at the end of the corresponding block.
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     */
    function getPastTotalSupply(uint256 timepoint) external view returns (uint256);

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) external view returns (address);

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) external;

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (governance/utils/Votes.sol)
pragma solidity ^0.8.20;

import {IERC5805} from "../../interfaces/IERC5805.sol";
import {Context} from "../../utils/Context.sol";
import {Nonces} from "../../utils/Nonces.sol";
import {EIP712} from "../../utils/cryptography/EIP712.sol";
import {Checkpoints} from "../../utils/structs/Checkpoints.sol";
import {SafeCast} from "../../utils/math/SafeCast.sol";
import {ECDSA} from "../../utils/cryptography/ECDSA.sol";
import {Time} from "../../utils/types/Time.sol";

/**
 * @dev This is a base abstract contract that tracks voting units, which are a measure of voting power that can be
 * transferred, and provides a system of vote delegation, where an account can delegate its voting units to a sort of
 * "representative" that will pool delegated voting units from different accounts and can then use it to vote in
 * decisions. In fact, voting units _must_ be delegated in order to count as actual votes, and an account has to
 * delegate those votes to itself if it wishes to participate in decisions and does not have a trusted representative.
 *
 * This contract is often combined with a token contract such that voting units correspond to token units. For an
 * example, see {ERC721Votes}.
 *
 * The full history of delegate votes is tracked on-chain so that governance protocols can consider votes as distributed
 * at a particular block number to protect against flash loans and double voting. The opt-in delegate system makes the
 * cost of this history tracking optional.
 *
 * When using this module the derived contract must implement {_getVotingUnits} (for example, make it return
 * {ERC721-balanceOf}), and can use {_transferVotingUnits} to track a change in the distribution of those units (in the
 * previous example, it would be included in {ERC721-_update}).
 */
abstract contract Votes is Context, EIP712, Nonces, IERC5805 {
    using Checkpoints for Checkpoints.Trace208;

    bytes32 private constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address account => address) private _delegatee;

    mapping(address delegatee => Checkpoints.Trace208) private _delegateCheckpoints;

    Checkpoints.Trace208 private _totalCheckpoints;

    /**
     * @dev The clock was incorrectly modified.
     */
    error ERC6372InconsistentClock();

    /**
     * @dev Lookup to future votes is not available.
     */
    error ERC5805FutureLookup(uint256 timepoint, uint48 clock);

    /**
     * @dev Clock used for flagging checkpoints. Can be overridden to implement timestamp based
     * checkpoints (and voting), in which case {CLOCK_MODE} should be overridden as well to match.
     */
    function clock() public view virtual returns (uint48) {
        return Time.blockNumber();
    }

    /**
     * @dev Machine-readable description of the clock as specified in EIP-6372.
     */
    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public view virtual returns (string memory) {
        // Check that the clock was not modified
        if (clock() != Time.blockNumber()) {
            revert ERC6372InconsistentClock();
        }
        return "mode=blocknumber&from=default";
    }

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) public view virtual returns (uint256) {
        return _delegateCheckpoints[account].latest();
    }

    /**
     * @dev Returns the amount of votes that `account` had at a specific moment in the past. If the `clock()` is
     * configured to use block numbers, this will return the value at the end of the corresponding block.
     *
     * Requirements:
     *
     * - `timepoint` must be in the past. If operating using block numbers, the block must be already mined.
     */
    function getPastVotes(address account, uint256 timepoint) public view virtual returns (uint256) {
        uint48 currentTimepoint = clock();
        if (timepoint >= currentTimepoint) {
            revert ERC5805FutureLookup(timepoint, currentTimepoint);
        }
        return _delegateCheckpoints[account].upperLookupRecent(SafeCast.toUint48(timepoint));
    }

    /**
     * @dev Returns the total supply of votes available at a specific moment in the past. If the `clock()` is
     * configured to use block numbers, this will return the value at the end of the corresponding block.
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     *
     * Requirements:
     *
     * - `timepoint` must be in the past. If operating using block numbers, the block must be already mined.
     */
    function getPastTotalSupply(uint256 timepoint) public view virtual returns (uint256) {
        uint48 currentTimepoint = clock();
        if (timepoint >= currentTimepoint) {
            revert ERC5805FutureLookup(timepoint, currentTimepoint);
        }
        return _totalCheckpoints.upperLookupRecent(SafeCast.toUint48(timepoint));
    }

    /**
     * @dev Returns the current total supply of votes.
     */
    function _getTotalSupply() internal view virtual returns (uint256) {
        return _totalCheckpoints.latest();
    }

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) public view virtual returns (address) {
        return _delegatee[account];
    }

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) public virtual {
        address account = _msgSender();
        _delegate(account, delegatee);
    }

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > expiry) {
            revert VotesExpiredSignature(expiry);
        }
        address signer = ECDSA.recover(
            _hashTypedDataV4(keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry))),
            v,
            r,
            s
        );
        _useCheckedNonce(signer, nonce);
        _delegate(signer, delegatee);
    }

    /**
     * @dev Delegate all of `account`'s voting units to `delegatee`.
     *
     * Emits events {IVotes-DelegateChanged} and {IVotes-DelegateVotesChanged}.
     */
    function _delegate(address account, address delegatee) internal virtual {
        address oldDelegate = delegates(account);
        _delegatee[account] = delegatee;

        emit DelegateChanged(account, oldDelegate, delegatee);
        _moveDelegateVotes(oldDelegate, delegatee, _getVotingUnits(account));
    }

    /**
     * @dev Transfers, mints, or burns voting units. To register a mint, `from` should be zero. To register a burn, `to`
     * should be zero. Total supply of voting units will be adjusted with mints and burns.
     */
    function _transferVotingUnits(address from, address to, uint256 amount) internal virtual {
        if (from == address(0)) {
            _push(_totalCheckpoints, _add, SafeCast.toUint208(amount));
        }
        if (to == address(0)) {
            _push(_totalCheckpoints, _subtract, SafeCast.toUint208(amount));
        }
        _moveDelegateVotes(delegates(from), delegates(to), amount);
    }

    /**
     * @dev Moves delegated votes from one delegate to another.
     */
    function _moveDelegateVotes(address from, address to, uint256 amount) private {
        if (from != to && amount > 0) {
            if (from != address(0)) {
                (uint256 oldValue, uint256 newValue) = _push(
                    _delegateCheckpoints[from],
                    _subtract,
                    SafeCast.toUint208(amount)
                );
                emit DelegateVotesChanged(from, oldValue, newValue);
            }
            if (to != address(0)) {
                (uint256 oldValue, uint256 newValue) = _push(
                    _delegateCheckpoints[to],
                    _add,
                    SafeCast.toUint208(amount)
                );
                emit DelegateVotesChanged(to, oldValue, newValue);
            }
        }
    }

    /**
     * @dev Get number of checkpoints for `account`.
     */
    function _numCheckpoints(address account) internal view virtual returns (uint32) {
        return SafeCast.toUint32(_delegateCheckpoints[account].length());
    }

    /**
     * @dev Get the `pos`-th checkpoint for `account`.
     */
    function _checkpoints(
        address account,
        uint32 pos
    ) internal view virtual returns (Checkpoints.Checkpoint208 memory) {
        return _delegateCheckpoints[account].at(pos);
    }

    function _push(
        Checkpoints.Trace208 storage store,
        function(uint208, uint208) view returns (uint208) op,
        uint208 delta
    ) private returns (uint208, uint208) {
        return store.push(clock(), op(store.latest(), delta));
    }

    function _add(uint208 a, uint208 b) private pure returns (uint208) {
        return a + b;
    }

    function _subtract(uint208 a, uint208 b) private pure returns (uint208) {
        return a - b;
    }

    /**
     * @dev Must return the voting units held by an account.
     */
    function _getVotingUnits(address) internal view virtual returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.20;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5805.sol)

pragma solidity ^0.8.20;

import {IVotes} from "../governance/utils/IVotes.sol";
import {IERC6372} from "./IERC6372.sol";

interface IERC5805 is IERC6372, IVotes {}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC6372.sol)

pragma solidity ^0.8.20;

interface IERC6372 {
    /**
     * @dev Clock used for flagging checkpoints. Can be overridden to implement timestamp based checkpoints (and voting).
     */
    function clock() external view returns (uint48);

    /**
     * @dev Description of the clock
     */
    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.20;

import {ERC20} from "../ERC20.sol";
import {Context} from "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys a `value` amount of tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, deducting from
     * the caller's allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Permit.sol)

pragma solidity ^0.8.20;

import {IERC20Permit} from "./IERC20Permit.sol";
import {ERC20} from "../ERC20.sol";
import {ECDSA} from "../../../utils/cryptography/ECDSA.sol";
import {EIP712} from "../../../utils/cryptography/EIP712.sol";
import {Nonces} from "../../../utils/Nonces.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712, Nonces {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Permit deadline has expired.
     */
    error ERC2612ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @inheritdoc IERC20Permit
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    function nonces(address owner) public view virtual override(IERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Votes.sol)

pragma solidity ^0.8.20;

import {ERC20} from "../ERC20.sol";
import {Votes} from "../../../governance/utils/Votes.sol";
import {Checkpoints} from "../../../utils/structs/Checkpoints.sol";

/**
 * @dev Extension of ERC20 to support Compound-like voting and delegation. This version is more generic than Compound's,
 * and supports token supply up to 2^208^ - 1, while COMP is limited to 2^96^ - 1.
 *
 * NOTE: This contract does not provide interface compatibility with Compound's COMP token.
 *
 * This extension keeps a history (checkpoints) of each account's vote power. Vote power can be delegated either
 * by calling the {delegate} function directly, or by providing a signature to be used with {delegateBySig}. Voting
 * power can be queried through the public accessors {getVotes} and {getPastVotes}.
 *
 * By default, token balance does not account for voting power. This makes transfers cheaper. The downside is that it
 * requires users to delegate to themselves in order to activate checkpoints and have their voting power tracked.
 */
abstract contract ERC20Votes is ERC20, Votes {
    /**
     * @dev Total supply cap has been exceeded, introducing a risk of votes overflowing.
     */
    error ERC20ExceededSafeSupply(uint256 increasedSupply, uint256 cap);

    /**
     * @dev Maximum token supply. Defaults to `type(uint208).max` (2^208^ - 1).
     *
     * This maximum is enforced in {_update}. It limits the total supply of the token, which is otherwise a uint256,
     * so that checkpoints can be stored in the Trace208 structure used by {{Votes}}. Increasing this value will not
     * remove the underlying limitation, and will cause {_update} to fail because of a math overflow in
     * {_transferVotingUnits}. An override could be used to further restrict the total supply (to a lower value) if
     * additional logic requires it. When resolving override conflicts on this function, the minimum should be
     * returned.
     */
    function _maxSupply() internal view virtual returns (uint256) {
        return type(uint208).max;
    }

    /**
     * @dev Move voting power when tokens are transferred.
     *
     * Emits a {IVotes-DelegateVotesChanged} event.
     */
    function _update(address from, address to, uint256 value) internal virtual override {
        super._update(from, to, value);
        if (from == address(0)) {
            uint256 supply = totalSupply();
            uint256 cap = _maxSupply();
            if (supply > cap) {
                revert ERC20ExceededSafeSupply(supply, cap);
            }
        }
        _transferVotingUnits(from, to, value);
    }

    /**
     * @dev Returns the voting units of an `account`.
     *
     * WARNING: Overriding this function may compromise the internal vote accounting.
     * `ERC20Votes` assumes tokens map to voting units 1:1 and this is not easy to change.
     */
    function _getVotingUnits(address account) internal view virtual override returns (uint256) {
        return balanceOf(account);
    }

    /**
     * @dev Get number of checkpoints for `account`.
     */
    function numCheckpoints(address account) public view virtual returns (uint32) {
        return _numCheckpoints(account);
    }

    /**
     * @dev Get the `pos`-th checkpoint for `account`.
     */
    function checkpoints(address account, uint32 pos) public view virtual returns (Checkpoints.Checkpoint208 memory) {
        return _checkpoints(account, pos);
    }
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Nonces.sol)
pragma solidity ^0.8.20;

/**
 * @dev Provides tracking nonces for addresses. Nonces will only increment.
 */
abstract contract Nonces {
    /**
     * @dev The nonce used for an `account` is not the expected current nonce.
     */
    error InvalidAccountNonce(address account, uint256 currentNonce);

    mapping(address account => uint256) private _nonces;

    /**
     * @dev Returns the next unused nonce for an address.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner];
    }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address owner) internal virtual returns (uint256) {
        // For each account, the nonce has an initial value of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here.
            return _nonces[owner]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address owner, uint256 nonce) internal virtual {
        uint256 current = _useNonce(owner);
        if (nonce != current) {
            revert InvalidAccountNonce(owner, current);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.20;

import {StorageSlot} from "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using
     * {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.20;

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
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;

import {Math} from "./math/Math.sol";
import {SignedMath} from "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
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
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
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
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;

import {MessageHashUtils} from "./MessageHashUtils.sol";
import {ShortStrings, ShortString} from "../ShortStrings.sol";
import {IERC5267} from "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _name which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _name.toStringWithFallback(_nameFallback);
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _version which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _version.toStringWithFallback(_versionFallback);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.20;

import {Strings} from "../Strings.sol";

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[EIP 191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (EIP-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

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
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
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
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
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
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
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
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
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
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
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
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/BitMaps.sol)
pragma solidity ^0.8.20;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, provided the keys are sequential.
 * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 *
 * BitMaps pack 256 booleans across each bit of a single 256-bit slot of `uint256` type.
 * Hence booleans corresponding to 256 _sequential_ indices would only consume a single slot,
 * unlike the regular `bool` which would consume an entire slot for a single value.
 *
 * This results in gas savings in two ways:
 *
 * - Setting a zero value to non-zero only once every 256 times
 * - Accessing the same warm slot for every 256 _sequential_ indices
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 bucket => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(BitMap storage bitmap, uint256 index, bool value) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/Checkpoints.sol)
// This file was procedurally generated from scripts/generate/templates/Checkpoints.js.

pragma solidity ^0.8.20;

import {Math} from "../math/Math.sol";

/**
 * @dev This library defines the `Trace*` struct, for checkpointing values as they change at different points in
 * time, and later looking up past values by block number. See {Votes} as an example.
 *
 * To create a history of checkpoints define a variable type `Checkpoints.Trace*` in your contract, and store a new
 * checkpoint for the current transaction block using the {push} function.
 */
library Checkpoints {
    /**
     * @dev A value was attempted to be inserted on a past checkpoint.
     */
    error CheckpointUnorderedInsertion();

    struct Trace224 {
        Checkpoint224[] _checkpoints;
    }

    struct Checkpoint224 {
        uint32 _key;
        uint224 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace224 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     *
     * IMPORTANT: Never accept `key` as a user input, since an arbitrary `type(uint32).max` key set will disable the
     * library.
     */
    function push(Trace224 storage self, uint32 key, uint224 value) internal returns (uint224, uint224) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if
     * there is none.
     */
    function lowerLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     */
    function upperLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high
     * keys).
     */
    function upperLookupRecent(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace224 storage self) internal view returns (uint224) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace224 storage self) internal view returns (bool exists, uint32 _key, uint224 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint224 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace224 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace224 storage self, uint32 pos) internal view returns (Checkpoint224 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(Checkpoint224[] storage self, uint32 key, uint224 value) private returns (uint224, uint224) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is important here.
            Checkpoint224 memory last = _unsafeAccess(self, pos - 1);

            // Checkpoint keys must be non-decreasing.
            if (last._key > key) {
                revert CheckpointUnorderedInsertion();
            }

            // Update or push new checkpoint
            if (last._key == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint224({_key: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint224({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the last (most recent) checkpoint with key lower or equal than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key is greater or equal than the search key, or
     * `high` if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and
     * exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint224[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint224 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace208 {
        Checkpoint208[] _checkpoints;
    }

    struct Checkpoint208 {
        uint48 _key;
        uint208 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace208 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     *
     * IMPORTANT: Never accept `key` as a user input, since an arbitrary `type(uint48).max` key set will disable the
     * library.
     */
    function push(Trace208 storage self, uint48 key, uint208 value) internal returns (uint208, uint208) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if
     * there is none.
     */
    function lowerLookup(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     */
    function upperLookup(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high
     * keys).
     */
    function upperLookupRecent(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace208 storage self) internal view returns (uint208) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace208 storage self) internal view returns (bool exists, uint48 _key, uint208 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint208 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace208 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace208 storage self, uint32 pos) internal view returns (Checkpoint208 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(Checkpoint208[] storage self, uint48 key, uint208 value) private returns (uint208, uint208) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is important here.
            Checkpoint208 memory last = _unsafeAccess(self, pos - 1);

            // Checkpoint keys must be non-decreasing.
            if (last._key > key) {
                revert CheckpointUnorderedInsertion();
            }

            // Update or push new checkpoint
            if (last._key == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint208({_key: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint208({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the last (most recent) checkpoint with key lower or equal than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint208[] storage self,
        uint48 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key is greater or equal than the search key, or
     * `high` if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and
     * exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint208[] storage self,
        uint48 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint208[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint208 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace160 {
        Checkpoint160[] _checkpoints;
    }

    struct Checkpoint160 {
        uint96 _key;
        uint160 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace160 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     *
     * IMPORTANT: Never accept `key` as a user input, since an arbitrary `type(uint96).max` key set will disable the
     * library.
     */
    function push(Trace160 storage self, uint96 key, uint160 value) internal returns (uint160, uint160) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if
     * there is none.
     */
    function lowerLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     */
    function upperLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high
     * keys).
     */
    function upperLookupRecent(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace160 storage self) internal view returns (uint160) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace160 storage self) internal view returns (bool exists, uint96 _key, uint160 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint160 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace160 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace160 storage self, uint32 pos) internal view returns (Checkpoint160 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(Checkpoint160[] storage self, uint96 key, uint160 value) private returns (uint160, uint160) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is important here.
            Checkpoint160 memory last = _unsafeAccess(self, pos - 1);

            // Checkpoint keys must be non-decreasing.
            if (last._key > key) {
                revert CheckpointUnorderedInsertion();
            }

            // Update or push new checkpoint
            if (last._key == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint160({_key: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint160({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the last (most recent) checkpoint with key lower or equal than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key is greater or equal than the search key, or
     * `high` if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and
     * exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint160[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint160 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

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
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
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
            set._positions[value] = set._values.length;
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
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/types/Time.sol)

pragma solidity ^0.8.20;

import {Math} from "../math/Math.sol";
import {SafeCast} from "../math/SafeCast.sol";

/**
 * @dev This library provides helpers for manipulating time-related objects.
 *
 * It uses the following types:
 * - `uint48` for timepoints
 * - `uint32` for durations
 *
 * While the library doesn't provide specific types for timepoints and duration, it does provide:
 * - a `Delay` type to represent duration that can be programmed to change value automatically at a given point
 * - additional helper functions
 */
library Time {
    using Time for *;

    /**
     * @dev Get the block timestamp as a Timepoint.
     */
    function timestamp() internal view returns (uint48) {
        return SafeCast.toUint48(block.timestamp);
    }

    /**
     * @dev Get the block number as a Timepoint.
     */
    function blockNumber() internal view returns (uint48) {
        return SafeCast.toUint48(block.number);
    }

    // ==================================================== Delay =====================================================
    /**
     * @dev A `Delay` is a uint32 duration that can be programmed to change value automatically at a given point in the
     * future. The "effect" timepoint describes when the transitions happens from the "old" value to the "new" value.
     * This allows updating the delay applied to some operation while keeping some guarantees.
     *
     * In particular, the {update} function guarantees that if the delay is reduced, the old delay still applies for
     * some time. For example if the delay is currently 7 days to do an upgrade, the admin should not be able to set
     * the delay to 0 and upgrade immediately. If the admin wants to reduce the delay, the old delay (7 days) should
     * still apply for some time.
     *
     *
     * The `Delay` type is 112 bits long, and packs the following:
     *
     * ```
     *   | [uint48]: effect date (timepoint)
     *   |           | [uint32]: value before (duration)
     *   ↓           ↓       ↓ [uint32]: value after (duration)
     * 0xAAAAAAAAAAAABBBBBBBBCCCCCCCC
     * ```
     *
     * NOTE: The {get} and {withUpdate} functions operate using timestamps. Block number based delays are not currently
     * supported.
     */
    type Delay is uint112;

    /**
     * @dev Wrap a duration into a Delay to add the one-step "update in the future" feature
     */
    function toDelay(uint32 duration) internal pure returns (Delay) {
        return Delay.wrap(duration);
    }

    /**
     * @dev Get the value at a given timepoint plus the pending value and effect timepoint if there is a scheduled
     * change after this timepoint. If the effect timepoint is 0, then the pending value should not be considered.
     */
    function _getFullAt(Delay self, uint48 timepoint) private pure returns (uint32, uint32, uint48) {
        (uint32 valueBefore, uint32 valueAfter, uint48 effect) = self.unpack();
        return effect <= timepoint ? (valueAfter, 0, 0) : (valueBefore, valueAfter, effect);
    }

    /**
     * @dev Get the current value plus the pending value and effect timepoint if there is a scheduled change. If the
     * effect timepoint is 0, then the pending value should not be considered.
     */
    function getFull(Delay self) internal view returns (uint32, uint32, uint48) {
        return _getFullAt(self, timestamp());
    }

    /**
     * @dev Get the current value.
     */
    function get(Delay self) internal view returns (uint32) {
        (uint32 delay, , ) = self.getFull();
        return delay;
    }

    /**
     * @dev Update a Delay object so that it takes a new duration after a timepoint that is automatically computed to
     * enforce the old delay at the moment of the update. Returns the updated Delay object and the timestamp when the
     * new delay becomes effective.
     */
    function withUpdate(
        Delay self,
        uint32 newValue,
        uint32 minSetback
    ) internal view returns (Delay updatedDelay, uint48 effect) {
        uint32 value = self.get();
        uint32 setback = uint32(Math.max(minSetback, value > newValue ? value - newValue : 0));
        effect = timestamp() + setback;
        return (pack(value, newValue, effect), effect);
    }

    /**
     * @dev Split a delay into its components: valueBefore, valueAfter and effect (transition timepoint).
     */
    function unpack(Delay self) internal pure returns (uint32 valueBefore, uint32 valueAfter, uint48 effect) {
        uint112 raw = Delay.unwrap(self);

        valueAfter = uint32(raw);
        valueBefore = uint32(raw >> 32);
        effect = uint48(raw >> 64);

        return (valueBefore, valueAfter, effect);
    }

    /**
     * @dev pack the components into a Delay object.
     */
    function pack(uint32 valueBefore, uint32 valueAfter, uint48 effect) internal pure returns (Delay) {
        return Delay.wrap((uint112(effect) << 64) | (uint112(valueBefore) << 32) | uint112(valueAfter));
    }
}