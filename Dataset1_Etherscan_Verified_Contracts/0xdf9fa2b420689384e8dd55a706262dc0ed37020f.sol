pragma solidity 0.8.13;

import {IMintableERC20} from "../interfaces/IMintableERC20.sol";
import {IConnector} from "../interfaces/IConnector.sol";
import "lib/solmate/src/utils/SafeTransferLib.sol";
import "../interfaces/IHook.sol";
import "../common/Errors.sol";
import "lib/solmate/src/utils/ReentrancyGuard.sol";
import "../interfaces/IBridge.sol";
import "../utils/RescueBase.sol";
import "../common/Constants.sol";

abstract contract Base is ReentrancyGuard, IBridge, RescueBase {
    address public immutable token;
    bytes32 public bridgeType;
    IHook public hook__;
    // message identifier => cache
    mapping(bytes32 => bytes) public identifierCache;

    // connector => cache
    mapping(address => bytes) public connectorCache;

    mapping(address => bool) public validConnectors;

    event ConnectorStatusUpdated(address connector, bool status);

    event HookUpdated(address newHook);

    event BridgingTokens(
        address connector,
        address sender,
        address receiver,
        uint256 amount,
        bytes32 messageId
    );
    event TokensBridged(
        address connecter,
        address receiver,
        uint256 amount,
        bytes32 messageId
    );
    constructor(address token_) AccessControl(msg.sender) {
        if (token_ != ETH_ADDRESS && token_.code.length == 0)
            revert InvalidTokenContract();
        token = token_;
        _grantRole(RESCUE_ROLE, msg.sender);
    }

    /**
     * @notice this function is used to update hook
     * @dev it can only be updated by owner
     * @dev should be carefully migrated as it can risk user funds
     * @param hook_ new hook address
     */
    function updateHook(
        address hook_,
        bool approve_
    ) external virtual onlyOwner {
        // remove the approval from the old hook
        if (token != ETH_ADDRESS) {
            if (ERC20(token).allowance(address(this), address(hook__)) > 0) {
                SafeTransferLib.safeApprove(ERC20(token), address(hook__), 0);
            }
            if (approve_) {
                SafeTransferLib.safeApprove(
                    ERC20(token),
                    hook_,
                    type(uint256).max
                );
            }
        }
        hook__ = IHook(hook_);

        emit HookUpdated(hook_);
    }

    function updateConnectorStatus(
        address[] calldata connectors,
        bool[] calldata statuses
    ) external onlyOwner {
        uint256 length = connectors.length;
        for (uint256 i; i < length; i++) {
            validConnectors[connectors[i]] = statuses[i];
            emit ConnectorStatusUpdated(connectors[i], statuses[i]);
        }
    }

    /**
     * @notice Executes pre-bridge operations before initiating a token bridge transfer.
     * @dev This internal function is called before initiating a token bridge transfer.
     * It validates the receiver address and the connector, and if a pre-hook contract is defined,
     * it executes the source pre-hook call.
     * @param connector_ The address of the connector responsible for the transfer.
     * @param transferInfo_ Information about the transfer.
     * @return transferInfo Information about the transfer after pre-bridge operations.
     * @return postHookData Data returned from the pre-hook call.
     * @dev Reverts with `ZeroAddressReceiver` if the receiver address is zero.
     * Reverts with `InvalidConnector` if the connector address is not valid.
     */
    function _beforeBridge(
        address connector_,
        TransferInfo memory transferInfo_
    )
        internal
        returns (TransferInfo memory transferInfo, bytes memory postHookData)
    {
        if (transferInfo_.receiver == address(0)) revert ZeroAddressReceiver();
        if (!validConnectors[connector_]) revert InvalidConnector();
        if (token == ETH_ADDRESS && msg.value < transferInfo_.amount)
            revert InsufficientMsgValue();

        if (address(hook__) != address(0)) {
            (transferInfo, postHookData) = hook__.srcPreHookCall(
                SrcPreHookCallParams(connector_, msg.sender, transferInfo_)
            );
        }
    }

    /**
     * @notice Executes post-bridge operations after completing a token bridge transfer.
     * @dev This internal function is called after completing a token bridge transfer.
     * It executes the source post-hook call if a hook contract is defined, calculates fees,
     * calls the outbound function of the connector, and emits an event for tokens withdrawn.
     * @param msgGasLimit_ The gas limit for the outbound call.
     * @param connector_ The address of the connector responsible for the transfer.
     * @param options_ Additional options for the outbound call.
     * @param postSrcHookData_ Data returned from the source post-hook call.
     * @param transferInfo_ Information about the transfer.
     * @dev Reverts with `MessageIdMisMatched` if the returned message ID does not match the expected message ID.
     */
    function _afterBridge(
        uint256 msgGasLimit_,
        address connector_,
        bytes memory options_,
        bytes memory postSrcHookData_,
        TransferInfo memory transferInfo_
    ) internal {
        TransferInfo memory transferInfo = transferInfo_;
        if (address(hook__) != address(0)) {
            transferInfo = hook__.srcPostHookCall(
                SrcPostHookCallParams(
                    connector_,
                    options_,
                    postSrcHookData_,
                    transferInfo_
                )
            );
        }

        uint256 fees = token == ETH_ADDRESS
            ? msg.value - transferInfo.amount
            : msg.value;

        bytes32 messageId = IConnector(connector_).getMessageId();
        bytes32 returnedMessageId = IConnector(connector_).outbound{
            value: fees
        }(
            msgGasLimit_,
            abi.encode(
                transferInfo.receiver,
                transferInfo.amount,
                messageId,
                transferInfo.data
            ),
            options_
        );
        if (returnedMessageId != messageId) revert MessageIdMisMatched();

        emit BridgingTokens(
            connector_,
            msg.sender,
            transferInfo.receiver,
            transferInfo.amount,
            messageId
        );
    }

    /**
     * @notice Executes pre-mint operations before minting tokens.
     * @dev This internal function is called before minting tokens.
     * It validates the caller as a valid connector, checks if the receiver is not this contract, the bridge contract,
     * or the token contract, and executes the destination pre-hook call if a hook contract is defined.
     * @param transferInfo_ Information about the transfer.
     * @return postHookData Data returned from the destination pre-hook call.
     * @return transferInfo Information about the transfer after pre-mint operations.
     * @dev Reverts with `InvalidConnector` if the caller is not a valid connector.
     * Reverts with `CannotTransferOrExecuteOnBridgeContracts` if the receiver is this contract, the bridge contract,
     * or the token contract.
     */
    function _beforeMint(
        uint32,
        TransferInfo memory transferInfo_
    )
        internal
        returns (bytes memory postHookData, TransferInfo memory transferInfo)
    {
        if (!validConnectors[msg.sender]) revert InvalidConnector();

        // no need of source check here, as if invalid caller, will revert with InvalidPoolId
        if (
            transferInfo_.receiver == address(this) ||
            // transferInfo_.receiver == address(bridge__) ||
            transferInfo_.receiver == token
        ) revert CannotTransferOrExecuteOnBridgeContracts();

        if (address(hook__) != address(0)) {
            (postHookData, transferInfo) = hook__.dstPreHookCall(
                DstPreHookCallParams(
                    msg.sender,
                    connectorCache[msg.sender],
                    transferInfo_
                )
            );
        }
    }

    /**
     * @notice Executes post-mint operations after minting tokens.
     * @dev This internal function is called after minting tokens.
     * It executes the destination post-hook call if a hook contract is defined and updates cache data.
     * @param messageId_ The unique identifier for the mint transaction.
     * @param postHookData_ Data returned from the destination pre-hook call.
     * @param transferInfo_ Information about the mint transaction.
     */
    function _afterMint(
        uint256,
        bytes32 messageId_,
        bytes memory postHookData_,
        TransferInfo memory transferInfo_
    ) internal {
        if (address(hook__) != address(0)) {
            CacheData memory cacheData = hook__.dstPostHookCall(
                DstPostHookCallParams(
                    msg.sender,
                    messageId_,
                    connectorCache[msg.sender],
                    postHookData_,
                    transferInfo_
                )
            );

            identifierCache[messageId_] = cacheData.identifierCache;
            connectorCache[msg.sender] = cacheData.connectorCache;
        }

        emit TokensBridged(
            msg.sender,
            transferInfo_.receiver,
            transferInfo_.amount,
            messageId_
        );
    }

    /**
     * @notice Executes pre-retry operations before retrying a failed transaction.
     * @dev This internal function is called before retrying a failed transaction.
     * It validates the connector, retrieves cache data for the given message ID,
     * and executes the pre-retry hook if defined.
     * @param connector_ The address of the connector responsible for the failed transaction.
     * @param messageId_ The unique identifier for the failed transaction.
     * @return postRetryHookData Data returned from the pre-retry hook call.
     * @return transferInfo Information about the transfer.
     * @dev Reverts with `InvalidConnector` if the connector is not valid.
     * Reverts with `NoPendingData` if there is no pending data for the given message ID.
     */
    function _beforeRetry(
        address connector_,
        bytes32 messageId_
    )
        internal
        returns (
            bytes memory postRetryHookData,
            TransferInfo memory transferInfo
        )
    {
        if (!validConnectors[connector_]) revert InvalidConnector();

        CacheData memory cacheData = CacheData(
            identifierCache[messageId_],
            connectorCache[connector_]
        );

        if (cacheData.identifierCache.length == 0) revert NoPendingData();
        (postRetryHookData, transferInfo) = hook__.preRetryHook(
            PreRetryHookCallParams(connector_, cacheData)
        );
    }

    /**
     * @notice Executes post-retry operations after retrying a failed transaction.
     * @dev This internal function is called after retrying a failed transaction.
     * It retrieves cache data for the given message ID, executes the post-retry hook if defined,
     * and updates cache data.
     * @param connector_ The address of the connector responsible for the failed transaction.
     * @param messageId_ The unique identifier for the failed transaction.
     * @param postRetryHookData Data returned from the pre-retry hook call.
     */
    function _afterRetry(
        address connector_,
        bytes32 messageId_,
        bytes memory postRetryHookData
    ) internal {
        CacheData memory cacheData = CacheData(
            identifierCache[messageId_],
            connectorCache[connector_]
        );

        (cacheData) = hook__.postRetryHook(
            PostRetryHookCallParams(
                connector_,
                messageId_,
                postRetryHookData,
                cacheData
            )
        );
        identifierCache[messageId_] = cacheData.identifierCache;
        connectorCache[connector_] = cacheData.connectorCache;
    }

    /**
     * @notice Retrieves the minimum fees required for a transaction from a connector.
     * @dev This function returns the minimum fees required for a transaction from the specified connector,
     * based on the provided message gas limit and payload size.
     * @param connector_ The address of the connector.
     * @param msgGasLimit_ The gas limit for the transaction.
     * @param payloadSize_ The size of the payload for the transaction.
     * @return totalFees The total minimum fees required for the transaction.
     */
    function getMinFees(
        address connector_,
        uint256 msgGasLimit_,
        uint256 payloadSize_
    ) external view returns (uint256 totalFees) {
        return IConnector(connector_).getMinFees(msgGasLimit_, payloadSize_);
    }
}
pragma solidity 0.8.13;

import "./Base.sol";
import "../interfaces/IConnector.sol";
import "lib/solmate/src/tokens/ERC20.sol";

/**
 * @title SuperToken
 * @notice A contract which enables bridging a token to its sibling chains.
 * @dev This contract implements ISuperTokenOrVault to support message bridging through IMessageBridge compliant contracts.
 */
contract Vault is Base {
    using SafeTransferLib for ERC20;

    // /**
    //  * @notice constructor for creating a new SuperTokenVault.
    //  * @param token_ token contract address which is to be bridged.
    //  */

    constructor(address token_) Base(token_) {
        bridgeType = token_ == ETH_ADDRESS ? NATIVE_VAULT : ERC20_VAULT;
    }

    /**
     * @notice Bridges tokens between chains.
     * @dev This function allows bridging tokens between different chains.
     * @param receiver_ The address to receive the bridged tokens.
     * @param amount_ The amount of tokens to bridge.
     * @param msgGasLimit_ The gas limit for the execution of the bridging process.
     * @param connector_ The address of the connector contract responsible for the bridge.
     * @param execPayload_ The payload for executing the bridging process on the connector.
     * @param options_ Additional options for the bridging process.
     */
    function bridge(
        address receiver_,
        uint256 amount_,
        uint256 msgGasLimit_,
        address connector_,
        bytes calldata execPayload_,
        bytes calldata options_
    ) public payable nonReentrant {
        (
            TransferInfo memory transferInfo,
            bytes memory postHookData
        ) = _beforeBridge(
                connector_,
                TransferInfo(receiver_, amount_, execPayload_)
            );

        _receiveTokens(transferInfo.amount);

        _afterBridge(
            msgGasLimit_,
            connector_,
            options_,
            postHookData,
            transferInfo
        );
    }

    /**
     * @notice Bridges tokens between chains using permit.
     * @param receiver_  The address to receive the bridged tokens.
     * @param amount_  The amount of tokens to bridge.
     * @param msgGasLimit_  The gas limit for the execution of the bridging process.
     * @param connector_  The address of the connector contract responsible for the bridge.
     * @param execPayload_  The payload for executing the bridging process on the connector.
     * @param options_  Additional options for the bridging process.
     * @param deadline_  The deadline for the permit signature.
     * @param v_  The recovery id of the permit signature.
     * @param r_  The r value of the permit signature.
     * @param s_  The s value of the permit signature.
     */
    function bridgeWithPermit(
        address receiver_,
        uint256 amount_,
        uint256 msgGasLimit_,
        address connector_,
        bytes calldata execPayload_,
        bytes calldata options_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external payable {
        ERC20(token).permit(
            msg.sender,
            address(this),
            amount_,
            deadline_,
            v_,
            r_,
            s_
        );
        bridge(
            receiver_,
            amount_,
            msgGasLimit_,
            connector_,
            execPayload_,
            options_
        );
    }

    /**
     * @notice Receives inbound tokens from another chain.
     * @dev This function is used to receive tokens from another chain.
     * @param siblingChainSlug_ The identifier of the sibling chain.
     * @param payload_ The payload containing the inbound tokens.
     */
    function receiveInbound(
        uint32 siblingChainSlug_,
        bytes memory payload_
    ) external payable override nonReentrant {
        (
            address receiver,
            uint256 unlockAmount,
            bytes32 messageId,
            bytes memory extraData
        ) = abi.decode(payload_, (address, uint256, bytes32, bytes));

        TransferInfo memory transferInfo = TransferInfo(
            receiver,
            unlockAmount,
            extraData
        );

        bytes memory postHookData;
        (postHookData, transferInfo) = _beforeMint(
            siblingChainSlug_,
            transferInfo
        );

        _transferTokens(transferInfo.receiver, transferInfo.amount);

        _afterMint(unlockAmount, messageId, postHookData, transferInfo);
    }

    /**
     * @notice Retry a failed transaction.
     * @dev This function allows retrying a failed transaction sent through a connector.
     * @param connector_ The address of the connector contract responsible for the failed transaction.
     * @param messageId_ The unique identifier of the failed transaction.
     */
    function retry(
        address connector_,
        bytes32 messageId_
    ) external nonReentrant {
        (
            bytes memory postRetryHookData,
            TransferInfo memory transferInfo
        ) = _beforeRetry(connector_, messageId_);
        _transferTokens(transferInfo.receiver, transferInfo.amount);

        _afterRetry(connector_, messageId_, postRetryHookData);
    }

    function disperseRewards(
        address receiver_,
        uint256 amount_,
        address rewardToken_
    ) external onlyOwner {
        if (rewardToken_ == token)
            revert("Vault: reward token is same as token");
        ERC20(rewardToken_).safeTransfer(receiver_, amount_);
    }
    function _transferTokens(address receiver_, uint256 amount_) internal {
        if (amount_ == 0) return;
        if (address(token) == ETH_ADDRESS) {
            SafeTransferLib.safeTransferETH(receiver_, amount_);
        } else {
            ERC20(token).safeTransfer(receiver_, amount_);
        }
    }

    function _receiveTokens(uint256 amount_) internal {
        if (amount_ == 0 || address(token) == ETH_ADDRESS) return;
        ERC20(token).safeTransferFrom(msg.sender, address(this), amount_);
    }
}
pragma solidity 0.8.13;

address constant ETH_ADDRESS = address(
    0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
);

bytes32 constant NORMAL_CONTROLLER = keccak256("NORMAL_CONTROLLER");
bytes32 constant FIAT_TOKEN_CONTROLLER = keccak256("FIAT_TOKEN_CONTROLLER");

bytes32 constant LIMIT_HOOK = keccak256("LIMIT_HOOK");
bytes32 constant LIMIT_EXECUTION_HOOK = keccak256("LIMIT_EXECUTION_HOOK");
bytes32 constant LIMIT_EXECUTION_YIELD_HOOK = keccak256(
    "LIMIT_EXECUTION_YIELD_HOOK"
);
bytes32 constant LIMIT_EXECUTION_YIELD_TOKEN_HOOK = keccak256(
    "LIMIT_EXECUTION_YIELD_TOKEN_HOOK"
);

bytes32 constant ERC20_VAULT = keccak256("ERC20_VAULT");
bytes32 constant NATIVE_VAULT = keccak256("NATIVE_VAULT");
pragma solidity 0.8.13;

error SiblingNotSupported();
error NotAuthorized();
error NotBridge();
error NotSocket();
error ConnectorUnavailable();
error InvalidPoolId();
error CannotTransferOrExecuteOnBridgeContracts();
error NoPendingData();
error MessageIdMisMatched();
error NotMessageBridge();
error InvalidSiblingChainSlug();
error InvalidTokenContract();
error InvalidExchangeRateContract();
error InvalidConnector();
error InvalidConnectorPoolId();
error ZeroAddressReceiver();
error ZeroAddress();
error ZeroAmount();
error DebtRatioTooHigh();
error NotEnoughAssets();
error VaultShutdown();
error InsufficientFunds();
error PermitDeadlineExpired();
error InvalidSigner();
error InsufficientMsgValue();
pragma solidity 0.8.13;

struct UpdateLimitParams {
    bool isMint;
    address connector;
    uint256 maxLimit;
    uint256 ratePerSecond;
}

struct SrcPreHookCallParams {
    address connector;
    address msgSender;
    TransferInfo transferInfo;
}

struct SrcPostHookCallParams {
    address connector;
    bytes options;
    bytes postSrcHookData;
    TransferInfo transferInfo;
}

struct DstPreHookCallParams {
    address connector;
    bytes connectorCache;
    TransferInfo transferInfo;
}

struct DstPostHookCallParams {
    address connector;
    bytes32 messageId;
    bytes connectorCache;
    bytes postHookData;
    TransferInfo transferInfo;
}

struct PreRetryHookCallParams {
    address connector;
    CacheData cacheData;
}

struct PostRetryHookCallParams {
    address connector;
    bytes32 messageId;
    bytes postRetryHookData;
    CacheData cacheData;
}

struct TransferInfo {
    address receiver;
    uint256 amount;
    bytes data;
}

struct CacheData {
    bytes identifierCache;
    bytes connectorCache;
}

struct LimitParams {
    uint256 lastUpdateTimestamp;
    uint256 ratePerSecond;
    uint256 maxLimit;
    uint256 lastUpdateLimit;
}
pragma solidity ^0.8.3;

interface IBridge {
    function bridge(
        address receiver_,
        uint256 amount_,
        uint256 msgGasLimit_,
        address connector_,
        bytes calldata execPayload_,
        bytes calldata options_
    ) external payable;

    function receiveInbound(
        uint32 siblingChainSlug_,
        bytes memory payload_
    ) external payable;

    function retry(address connector_, bytes32 messageId_) external;
}
pragma solidity ^0.8.13;

interface IConnector {
    function outbound(
        uint256 msgGasLimit_,
        bytes memory payload_,
        bytes memory options_
    ) external payable returns (bytes32 messageId_);

    function siblingChainSlug() external view returns (uint32);

    function getMinFees(
        uint256 msgGasLimit_,
        uint256 payloadSize_
    ) external view returns (uint256 totalFees);

    function getMessageId() external view returns (bytes32);
}
pragma solidity ^0.8.3;
import "../common/Structs.sol";

interface IHook {
    /**
     * @notice Executes pre-hook call for source underlyingAsset.
     * @dev This function is used to execute a pre-hook call for the source underlyingAsset before initiating a transfer.
     * @param params_ Parameters for the pre-hook call.
     * @return transferInfo Information about the transfer.
     * @return postSrcHookData returned from the pre-hook call.
     */
    function srcPreHookCall(
        SrcPreHookCallParams calldata params_
    )
        external
        returns (
            TransferInfo memory transferInfo,
            bytes memory postSrcHookData
        );

    function srcPostHookCall(
        SrcPostHookCallParams calldata params_
    ) external returns (TransferInfo memory transferInfo);

    /**
     * @notice Executes pre-hook call for destination underlyingAsset.
     * @dev This function is used to execute a pre-hook call for the destination underlyingAsset before initiating a transfer.
     * @param params_ Parameters for the pre-hook call.
     */
    function dstPreHookCall(
        DstPreHookCallParams calldata params_
    )
        external
        returns (bytes memory postHookData, TransferInfo memory transferInfo);

    /**
     * @notice Executes post-hook call for destination underlyingAsset.
     * @dev This function is used to execute a post-hook call for the destination underlyingAsset after completing a transfer.
     * @param params_ Parameters for the post-hook call.
     * @return cacheData Cached data for the post-hook call.
     */
    function dstPostHookCall(
        DstPostHookCallParams calldata params_
    ) external returns (CacheData memory cacheData);

    /**
     * @notice Executes a pre-retry hook for a failed transaction.
     * @dev This function is used to execute a pre-retry hook for a failed transaction.
     * @param params_ Parameters for the pre-retry hook.
     * @return postRetryHookData Data from the post-retry hook.
     * @return transferInfo Information about the transfer.
     */
    function preRetryHook(
        PreRetryHookCallParams calldata params_
    )
        external
        returns (
            bytes memory postRetryHookData,
            TransferInfo memory transferInfo
        );

    /**
     * @notice Executes a post-retry hook for a failed transaction.
     * @dev This function is used to execute a post-retry hook for a failed transaction.
     * @param params_ Parameters for the post-retry hook.
     * @return cacheData Cached data for the post-retry hook.
     */
    function postRetryHook(
        PostRetryHookCallParams calldata params_
    ) external returns (CacheData memory cacheData);
}
pragma solidity 0.8.13;

interface IMintableERC20 {
    function mint(address receiver_, uint256 amount_) external;

    function burn(address burner_, uint256 amount_) external;
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.13;

import "lib/solmate/src/utils/SafeTransferLib.sol";
import "lib/solmate/src/tokens/ERC20.sol";

error ZeroAddress();

/**
 * @title RescueFundsLib
 * @dev A library that provides a function to rescue funds from a contract.
 */

library RescueFundsLib {
    /**
     * @dev The address used to identify ETH.
     */
    address public constant ETH_ADDRESS =
        address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /**
     * @dev thrown when the given token address don't have any code
     */
    error InvalidTokenAddress();

    /**
     * @dev Rescues funds from a contract.
     * @param token_ The address of the token contract.
     * @param rescueTo_ The address of the user.
     * @param amount_ The amount of tokens to be rescued.
     */
    function rescueFunds(
        address token_,
        address rescueTo_,
        uint256 amount_
    ) internal {
        if (rescueTo_ == address(0)) revert ZeroAddress();

        if (token_ == ETH_ADDRESS) {
            SafeTransferLib.safeTransferETH(rescueTo_, amount_);
        } else {
            if (token_.code.length == 0) revert InvalidTokenAddress();
            SafeTransferLib.safeTransfer(ERC20(token_), rescueTo_, amount_);
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.13;

import "./Ownable.sol";

/**
 * @title AccessControl
 * @dev This abstract contract implements access control mechanism based on roles.
 * Each role can have one or more addresses associated with it, which are granted
 * permission to execute functions with the onlyRole modifier.
 */
abstract contract AccessControl is Ownable {
    /**
     * @dev A mapping of roles to a mapping of addresses to boolean values indicating whether or not they have the role.
     */
    mapping(bytes32 => mapping(address => bool)) private _permits;

    /**
     * @dev Emitted when a role is granted to an address.
     */
    event RoleGranted(bytes32 indexed role, address indexed grantee);

    /**
     * @dev Emitted when a role is revoked from an address.
     */
    event RoleRevoked(bytes32 indexed role, address indexed revokee);

    /**
     * @dev Error message thrown when an address does not have permission to execute a function with onlyRole modifier.
     */
    error NoPermit(bytes32 role);

    /**
     * @dev Constructor that sets the owner of the contract.
     */
    constructor(address owner_) Ownable(owner_) {}

    /**
     * @dev Modifier that restricts access to addresses having roles
     * Throws an error if the caller do not have permit
     */
    modifier onlyRole(bytes32 role) {
        if (!_permits[role][msg.sender]) revert NoPermit(role);
        _;
    }

    /**
     * @dev Checks and reverts if an address do not have a specific role.
     * @param role_ The role to check.
     * @param address_ The address to check.
     */
    function _checkRole(bytes32 role_, address address_) internal virtual {
        if (!_hasRole(role_, address_)) revert NoPermit(role_);
    }

    /**
     * @dev Grants a role to a given address.
     * @param role_ The role to grant.
     * @param grantee_ The address to grant the role to.
     * Emits a RoleGranted event.
     * Can only be called by the owner of the contract.
     */
    function grantRole(
        bytes32 role_,
        address grantee_
    ) external virtual onlyOwner {
        _grantRole(role_, grantee_);
    }

    /**
     * @dev Revokes a role from a given address.
     * @param role_ The role to revoke.
     * @param revokee_ The address to revoke the role from.
     * Emits a RoleRevoked event.
     * Can only be called by the owner of the contract.
     */
    function revokeRole(
        bytes32 role_,
        address revokee_
    ) external virtual onlyOwner {
        _revokeRole(role_, revokee_);
    }

    /**
     * @dev Internal function to grant a role to a given address.
     * @param role_ The role to grant.
     * @param grantee_ The address to grant the role to.
     * Emits a RoleGranted event.
     */
    function _grantRole(bytes32 role_, address grantee_) internal {
        _permits[role_][grantee_] = true;
        emit RoleGranted(role_, grantee_);
    }

    /**
     * @dev Internal function to revoke a role from a given address.
     * @param role_ The role to revoke.
     * @param revokee_ The address to revoke the role from.
     * Emits a RoleRevoked event.
     */
    function _revokeRole(bytes32 role_, address revokee_) internal {
        _permits[role_][revokee_] = false;
        emit RoleRevoked(role_, revokee_);
    }

    /**
     * @dev Checks whether an address has a specific role.
     * @param role_ The role to check.
     * @param address_ The address to check.
     * @return A boolean value indicating whether or not the address has the role.
     */
    function hasRole(
        bytes32 role_,
        address address_
    ) external view returns (bool) {
        return _hasRole(role_, address_);
    }

    function _hasRole(
        bytes32 role_,
        address address_
    ) internal view returns (bool) {
        return _permits[role_][address_];
    }
}
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.13;

/**
 * @title Ownable
 * @dev The Ownable contract provides a simple way to manage ownership of a contract
 * and allows for ownership to be transferred to a nominated address.
 */
abstract contract Ownable {
    address private _owner;
    address private _nominee;

    event OwnerNominated(address indexed nominee);
    event OwnerClaimed(address indexed claimer);

    error OnlyOwner();
    error OnlyNominee();

    /**
     * @dev Sets the contract's owner to the address that is passed to the constructor.
     */
    constructor(address owner_) {
        _claimOwner(owner_);
    }

    /**
     * @dev Modifier that restricts access to only the contract's owner.
     * Throws an error if the caller is not the owner.
     */
    modifier onlyOwner() {
        if (msg.sender != _owner) revert OnlyOwner();
        _;
    }

    /**
     * @dev Returns the current owner of the contract.
     */
    function owner() external view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the current nominee for ownership of the contract.
     */
    function nominee() external view returns (address) {
        return _nominee;
    }

    /**
     * @dev Allows the current owner to nominate a new owner for the contract.
     * Throws an error if the caller is not the owner.
     * Emits an `OwnerNominated` event with the address of the nominee.
     */
    function nominateOwner(address nominee_) external {
        if (msg.sender != _owner) revert OnlyOwner();
        _nominee = nominee_;
        emit OwnerNominated(_nominee);
    }

    /**
     * @dev Allows the nominated owner to claim ownership of the contract.
     * Throws an error if the caller is not the nominee.
     * Sets the nominated owner as the new owner of the contract.
     * Emits an `OwnerClaimed` event with the address of the new owner.
     */
    function claimOwner() external {
        if (msg.sender != _nominee) revert OnlyNominee();
        _claimOwner(msg.sender);
    }

    /**
     * @dev Internal function that sets the owner of the contract to the specified address
     * and sets the nominee to address(0).
     */
    function _claimOwner(address claimer_) internal {
        _owner = claimer_;
        _nominee = address(0);
        emit OwnerClaimed(claimer_);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import {RescueFundsLib} from "../libraries/RescueFundsLib.sol";
import {AccessControl} from "./AccessControl.sol";

/**
 * @title Base contract for super token and vault
 * @notice It contains relevant execution payload storages.
 * @dev This contract implements Socket's IPlug to enable message bridging and IMessageBridge
 * to support any type of message bridge.
 */
abstract contract RescueBase is AccessControl {
    bytes32 constant RESCUE_ROLE = keccak256("RESCUE_ROLE");

    /**
     * @notice Rescues funds from the contract if they are locked by mistake.
     * @param token_ The address of the token contract.
     * @param rescueTo_ The address where rescued tokens need to be sent.
     * @param amount_ The amount of tokens to be rescued.
     */
    function rescueFunds(
        address token_,
        address rescueTo_,
        uint256 amount_
    ) external onlyRole(RESCUE_ROLE) {
        RescueFundsLib.rescueFunds(token_, rescueTo_, amount_);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}