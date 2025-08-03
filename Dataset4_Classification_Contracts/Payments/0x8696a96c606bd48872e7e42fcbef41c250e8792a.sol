// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";

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
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

pragma solidity >=0.6.0 <0.8.0;

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import { IBridgehub, L2TransactionRequestDirect } from './system/IBridgehub.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { ReentrancyGuard } from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import { Pausable } from '@openzeppelin/contracts/utils/Pausable.sol';

/// @title Abstract Bridge contract
/// @author Pudgy Labs
/// @notice This contract handles bridging of ETH to Layer 2
contract AbstractBridge is Ownable, ReentrancyGuard, Pausable {
  uint256 constant FEE_DECIMALS = 1e4;

  /// @notice Address of the bridge hub contract
  IBridgehub public bridgehub;

  /// @notice Fee percentage for the operator
  uint256 public operatorFee;

  /// @notice Address where the operator fee is sent
  address public feeTo;

  /// @notice Configuration for the ZkBridgeHub
  struct ZkBridgeHubConfig {
    uint256 chainId; // Chain ID of the target Layer 2
    bytes l2Calldata; // Calldata for the Layer 2 transaction
    uint256 l2GasLimit; // Gas limit for the Layer 2 transaction
    uint256 l2GasPrice; // Gas price for the Layer 2 transaction
    uint256 l2GasPerPubdataByteLimit; // Gas per pubdata byte limit for the Layer 2 transaction
    bytes[] factoryDeps; // Factory dependencies for the Layer 2 transaction
  }

  /// @notice Current bridge configuration
  ZkBridgeHubConfig public bridgeConfig;

  /// @param _bridgehub Address of the bridge hub contract
  constructor(address _bridgehub) public Ownable() {
    bridgehub = IBridgehub(_bridgehub);
  }

  /// @notice Sets the operator fee
  /// @param _fee New operator fee
  function setOperatorFee(uint256 _fee) public onlyOwner {
    operatorFee = _fee;
  }

  /// @notice Sets the address where the operator fee is sent
  /// @param _feeTo New fee recipient address
  function setFeeTo(address _feeTo) public onlyOwner {
    feeTo = _feeTo;
  }

  /// @notice Sets the bridge hub contract address
  /// @param _bridgehub New bridge hub contract address
  function setBridgehub(address _bridgehub) public onlyOwner {
    bridgehub = IBridgehub(_bridgehub);
  }

  /// @notice Sets the bridge configuration
  /// @param _bridgeConfig New bridge configuration
  function setBridgeConfig(ZkBridgeHubConfig memory _bridgeConfig) public onlyOwner {
    bridgeConfig = _bridgeConfig;
  }

  /// @notice Handles the deposit of ETH to the bridge
  /// @param _to Address of the recipient on Layer 2
  function _handleDepositEth(address _to) internal whenNotPaused {
    require(address(bridgehub) != address(0), 'Bridge address unset');

    uint256 operatorShare = (msg.value * operatorFee) / FEE_DECIMALS;
    uint256 l1Value = msg.value - operatorShare;

    uint256 gasFee = bridgehub.l2TransactionBaseCost(
      bridgeConfig.chainId,
      bridgeConfig.l2GasPrice,
      bridgeConfig.l2GasLimit,
      bridgeConfig.l2GasPerPubdataByteLimit
    );

    uint256 l2Value = l1Value - ((gasFee * 11000) / FEE_DECIMALS);

    bridgehub.requestL2TransactionDirect{ value: l1Value }(
      L2TransactionRequestDirect(
        bridgeConfig.chainId,
        l1Value,
        _to,
        l2Value,
        bridgeConfig.l2Calldata,
        bridgeConfig.l2GasLimit,
        bridgeConfig.l2GasPerPubdataByteLimit,
        bridgeConfig.factoryDeps,
        _to
      )
    );

    if (operatorShare > 0) {
      payable(feeTo).transfer(operatorShare);
    }
  }

  /// @notice Bridges ETH to Layer 2
  /// @param _to Address of the recipient on Layer 2
  function bridgeEth(address _to) external payable nonReentrant {
    _handleDepositEth(_to);
  }

  /// @notice Fallback function to handle direct ETH deposits
  receive() external payable nonReentrant {
    _handleDepositEth(msg.sender);
  }
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
import {IL1SharedBridge} from "./IL1SharedBridge.sol";
import {L2Message, L2Log, TxStatus} from "./Messaging.sol";

struct L2TransactionRequestDirect {
    uint256 chainId;
    uint256 mintValue;
    address l2Contract;
    uint256 l2Value;
    bytes l2Calldata;
    uint256 l2GasLimit;
    uint256 l2GasPerPubdataByteLimit;
    bytes[] factoryDeps;
    address refundRecipient;
}

struct L2TransactionRequestTwoBridgesOuter {
    uint256 chainId;
    uint256 mintValue;
    uint256 l2Value;
    uint256 l2GasLimit;
    uint256 l2GasPerPubdataByteLimit;
    address refundRecipient;
    address secondBridgeAddress;
    uint256 secondBridgeValue;
    bytes secondBridgeCalldata;
}

struct L2TransactionRequestTwoBridgesInner {
    bytes32 magicValue;
    address l2Contract;
    bytes l2Calldata;
    bytes[] factoryDeps;
    bytes32 txDataHash;
}

interface IBridgehub {
    /// @notice pendingAdmin is changed
    /// @dev Also emitted when new admin is accepted and in this case, `newPendingAdmin` would be zero address
    event NewPendingAdmin(address indexed oldPendingAdmin, address indexed newPendingAdmin);

    /// @notice Admin changed
    event NewAdmin(address indexed oldAdmin, address indexed newAdmin);

    /// @notice Starts the transfer of admin rights. Only the current admin can propose a new pending one.
    /// @notice New admin can accept admin rights by calling `acceptAdmin` function.
    /// @param _newPendingAdmin Address of the new admin
    function setPendingAdmin(address _newPendingAdmin) external;

    /// @notice Accepts transfer of admin rights. Only pending admin can accept the role.
    function acceptAdmin() external;

    /// Getters
    function stateTransitionManagerIsRegistered(address _stateTransitionManager) external view returns (bool);

    function stateTransitionManager(uint256 _chainId) external view returns (address);

    function tokenIsRegistered(address _baseToken) external view returns (bool);

    function baseToken(uint256 _chainId) external view returns (address);

    function sharedBridge() external view returns (IL1SharedBridge);

    function getHyperchain(uint256 _chainId) external view returns (address);

    /// Mailbox forwarder

    function proveL2MessageInclusion(
        uint256 _chainId,
        uint256 _batchNumber,
        uint256 _index,
        L2Message calldata _message,
        bytes32[] calldata _proof
    ) external view returns (bool);

    function proveL2LogInclusion(
        uint256 _chainId,
        uint256 _batchNumber,
        uint256 _index,
        L2Log memory _log,
        bytes32[] calldata _proof
    ) external view returns (bool);

    function proveL1ToL2TransactionStatus(
        uint256 _chainId,
        bytes32 _l2TxHash,
        uint256 _l2BatchNumber,
        uint256 _l2MessageIndex,
        uint16 _l2TxNumberInBatch,
        bytes32[] calldata _merkleProof,
        TxStatus _status
    ) external view returns (bool);

    function requestL2TransactionDirect(
        L2TransactionRequestDirect calldata _request
    ) external payable returns (bytes32 canonicalTxHash);

    function requestL2TransactionTwoBridges(
        L2TransactionRequestTwoBridgesOuter calldata _request
    ) external payable returns (bytes32 canonicalTxHash);

    function l2TransactionBaseCost(
        uint256 _chainId,
        uint256 _gasPrice,
        uint256 _l2GasLimit,
        uint256 _l2GasPerPubdataByteLimit
    ) external view returns (uint256);

    //// Registry

    function createNewChain(
        uint256 _chainId,
        address _stateTransitionManager,
        address _baseToken,
        uint256 _salt,
        address _admin,
        bytes calldata _initData
    ) external returns (uint256 chainId);

    function addStateTransitionManager(address _stateTransitionManager) external;

    function removeStateTransitionManager(address _stateTransitionManager) external;

    function addToken(address _token) external;

    function setSharedBridge(address _sharedBridge) external;

    event NewChain(uint256 indexed chainId, address stateTransitionManager, address indexed chainGovernance);
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.6.12;

import {IL1SharedBridge} from "./IL1SharedBridge.sol";


interface IL1ERC20Bridge {
    event DepositInitiated(
        bytes32 indexed l2DepositTxHash,
        address indexed from,
        address indexed to,
        address l1Token,
        uint256 amount
    );

    event WithdrawalFinalized(address indexed to, address indexed l1Token, uint256 amount);

    event ClaimedFailedDeposit(address indexed to, address indexed l1Token, uint256 amount);

    function isWithdrawalFinalized(uint256 _l2BatchNumber, uint256 _l2MessageIndex) external view returns (bool);

    function deposit(
        address _l2Receiver,
        address _l1Token,
        uint256 _amount,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte,
        address _refundRecipient
    ) external payable returns (bytes32 txHash);

    function deposit(
        address _l2Receiver,
        address _l1Token,
        uint256 _amount,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte
    ) external payable returns (bytes32 txHash);

    function claimFailedDeposit(
        address _depositSender,
        address _l1Token,
        bytes32 _l2TxHash,
        uint256 _l2BatchNumber,
        uint256 _l2MessageIndex,
        uint16 _l2TxNumberInBatch,
        bytes32[] calldata _merkleProof
    ) external;

    function finalizeWithdrawal(
        uint256 _l2BatchNumber,
        uint256 _l2MessageIndex,
        uint16 _l2TxNumberInBatch,
        bytes calldata _message,
        bytes32[] calldata _merkleProof
    ) external;

    function l2TokenAddress(address _l1Token) external view returns (address);

    function SHARED_BRIDGE() external view returns (IL1SharedBridge);

    function l2TokenBeacon() external view returns (address);

    function l2Bridge() external view returns (address);

    function depositAmount(
        address _account,
        address _l1Token,
        bytes32 _depositL2TxHash
    ) external returns (uint256 amount);

    function transferTokenToSharedBridge(address _token) external;
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
import {L2TransactionRequestTwoBridgesInner} from "./IBridgehub.sol";
import {IBridgehub} from "./IBridgehub.sol";
import {IL1ERC20Bridge} from "./IL1ERC20Bridge.sol";

interface IL1SharedBridge {
    /// @notice pendingAdmin is changed
    /// @dev Also emitted when new admin is accepted and in this case, `newPendingAdmin` would be zero address
    event NewPendingAdmin(address indexed oldPendingAdmin, address indexed newPendingAdmin);

    /// @notice Admin changed
    event NewAdmin(address indexed oldAdmin, address indexed newAdmin);

    event LegacyDepositInitiated(
        uint256 indexed chainId,
        bytes32 indexed l2DepositTxHash,
        address indexed from,
        address to,
        address l1Token,
        uint256 amount
    );

    event BridgehubDepositInitiated(
        uint256 indexed chainId,
        bytes32 indexed txDataHash,
        address indexed from,
        address to,
        address l1Token,
        uint256 amount
    );

    event BridgehubDepositBaseTokenInitiated(
        uint256 indexed chainId,
        address indexed from,
        address l1Token,
        uint256 amount
    );

    event BridgehubDepositFinalized(
        uint256 indexed chainId,
        bytes32 indexed txDataHash,
        bytes32 indexed l2DepositTxHash
    );

    event WithdrawalFinalizedSharedBridge(
        uint256 indexed chainId,
        address indexed to,
        address indexed l1Token,
        uint256 amount
    );

    event ClaimedFailedDepositSharedBridge(
        uint256 indexed chainId,
        address indexed to,
        address indexed l1Token,
        uint256 amount
    );

    function isWithdrawalFinalized(
        uint256 _chainId,
        uint256 _l2BatchNumber,
        uint256 _l2MessageIndex
    ) external view returns (bool);

    function depositLegacyErc20Bridge(
        address _msgSender,
        address _l2Receiver,
        address _l1Token,
        uint256 _amount,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte,
        address _refundRecipient
    ) external payable returns (bytes32 txHash);

    function claimFailedDepositLegacyErc20Bridge(
        address _depositSender,
        address _l1Token,
        uint256 _amount,
        bytes32 _l2TxHash,
        uint256 _l2BatchNumber,
        uint256 _l2MessageIndex,
        uint16 _l2TxNumberInBatch,
        bytes32[] calldata _merkleProof
    ) external;

    function claimFailedDeposit(
        uint256 _chainId,
        address _depositSender,
        address _l1Token,
        uint256 _amount,
        bytes32 _l2TxHash,
        uint256 _l2BatchNumber,
        uint256 _l2MessageIndex,
        uint16 _l2TxNumberInBatch,
        bytes32[] calldata _merkleProof
    ) external;

    function finalizeWithdrawalLegacyErc20Bridge(
        uint256 _l2BatchNumber,
        uint256 _l2MessageIndex,
        uint16 _l2TxNumberInBatch,
        bytes calldata _message,
        bytes32[] calldata _merkleProof
    ) external returns (address l1Receiver, address l1Token, uint256 amount);

    function finalizeWithdrawal(
        uint256 _chainId,
        uint256 _l2BatchNumber,
        uint256 _l2MessageIndex,
        uint16 _l2TxNumberInBatch,
        bytes calldata _message,
        bytes32[] calldata _merkleProof
    ) external;

    function setEraPostDiamondUpgradeFirstBatch(uint256 _eraPostDiamondUpgradeFirstBatch) external;

    function setEraPostLegacyBridgeUpgradeFirstBatch(uint256 _eraPostLegacyBridgeUpgradeFirstBatch) external;

    function setEraLegacyBridgeLastDepositTime(
        uint256 _eraLegacyBridgeLastDepositBatch,
        uint256 _eraLegacyBridgeLastDepositTxNumber
    ) external;

    function L1_WETH_TOKEN() external view returns (address);

    function BRIDGE_HUB() external view returns (IBridgehub);

    function legacyBridge() external view returns (IL1ERC20Bridge);

    function l2BridgeAddress(uint256 _chainId) external view returns (address);

    function depositHappened(uint256 _chainId, bytes32 _l2TxHash) external view returns (bytes32);

    /// data is abi encoded :
    /// address _l1Token,
    /// uint256 _amount,
    /// address _l2Receiver
    function bridgehubDeposit(
        uint256 _chainId,
        address _prevMsgSender,
        uint256 _l2Value,
        bytes calldata _data
    ) external payable returns (L2TransactionRequestTwoBridgesInner memory request);

    function bridgehubDepositBaseToken(
        uint256 _chainId,
        address _prevMsgSender,
        address _l1Token,
        uint256 _amount
    ) external payable;

    function bridgehubConfirmL2Transaction(uint256 _chainId, bytes32 _txDataHash, bytes32 _txHash) external;

    function receiveEth(uint256 _chainId) external payable;

    /// @notice Starts the transfer of admin rights. Only the current admin can propose a new pending one.
    /// @notice New admin can accept admin rights by calling `acceptAdmin` function.
    /// @param _newPendingAdmin Address of the new admin
    function setPendingAdmin(address _newPendingAdmin) external;

    /// @notice Accepts transfer of admin rights. Only pending admin can accept the role.
    function acceptAdmin() external;
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.6.12;

/// @dev The enum that represents the transaction execution status
/// @param Failure The transaction execution failed
/// @param Success The transaction execution succeeded
enum TxStatus {
    Failure,
    Success
}

/// @dev The log passed from L2
/// @param l2ShardId The shard identifier, 0 - rollup, 1 - porter
/// All other values are not used but are reserved for the future
/// @param isService A boolean flag that is part of the log along with `key`, `value`, and `sender` address.
/// This field is required formally but does not have any special meaning
/// @param txNumberInBatch The L2 transaction number in a Batch, in which the log was sent
/// @param sender The L2 address which sent the log
/// @param key The 32 bytes of information that was sent in the log
/// @param value The 32 bytes of information that was sent in the log
// Both `key` and `value` are arbitrary 32-bytes selected by the log sender
struct L2Log {
    uint8 l2ShardId;
    bool isService;
    uint16 txNumberInBatch;
    address sender;
    bytes32 key;
    bytes32 value;
}

/// @dev An arbitrary length message passed from L2
/// @notice Under the hood it is `L2Log` sent from the special system L2 contract
/// @param txNumberInBatch The L2 transaction number in a Batch, in which the message was sent
/// @param sender The address of the L2 account from which the message was passed
/// @param data An arbitrary length message
struct L2Message {
    uint16 txNumberInBatch;
    address sender;
    bytes data;
}

/// @dev Internal structure that contains the parameters for the writePriorityOp
/// internal function.
/// @param txId The id of the priority transaction.
/// @param l2GasPrice The gas price for the l2 priority operation.
/// @param expirationTimestamp The timestamp by which the priority operation must be processed by the operator.
/// @param request The external calldata request for the priority operation.
struct WritePriorityOpParams {
    uint256 txId;
    uint256 l2GasPrice;
    uint64 expirationTimestamp;
    BridgehubL2TransactionRequest request;
}

/// @dev Structure that includes all fields of the L2 transaction
/// @dev The hash of this structure is the "canonical L2 transaction hash" and can
/// be used as a unique identifier of a tx
/// @param txType The tx type number, depending on which the L2 transaction can be
/// interpreted differently
/// @param from The sender's address. `uint256` type for possible address format changes
/// and maintaining backward compatibility
/// @param to The recipient's address. `uint256` type for possible address format changes
/// and maintaining backward compatibility
/// @param gasLimit The L2 gas limit for L2 transaction. Analog to the `gasLimit` on an
/// L1 transactions
/// @param gasPerPubdataByteLimit Maximum number of L2 gas that will cost one byte of pubdata
/// (every piece of data that will be stored on L1 as calldata)
/// @param maxFeePerGas The absolute maximum sender willing to pay per unit of L2 gas to get
/// the transaction included in a Batch. Analog to the EIP-1559 `maxFeePerGas` on an L1 transactions
/// @param maxPriorityFeePerGas The additional fee that is paid directly to the validator
/// to incentivize them to include the transaction in a Batch. Analog to the EIP-1559
/// `maxPriorityFeePerGas` on an L1 transactions
/// @param paymaster The address of the EIP-4337 paymaster, that will pay fees for the
/// transaction. `uint256` type for possible address format changes and maintaining backward compatibility
/// @param nonce The nonce of the transaction. For L1->L2 transactions it is the priority
/// operation Id
/// @param value The value to pass with the transaction
/// @param reserved The fixed-length fields for usage in a future extension of transaction
/// formats
/// @param data The calldata that is transmitted for the transaction call
/// @param signature An abstract set of bytes that are used for transaction authorization
/// @param factoryDeps The set of L2 bytecode hashes whose preimages were shown on L1
/// @param paymasterInput The arbitrary-length data that is used as a calldata to the paymaster pre-call
/// @param reservedDynamic The arbitrary-length field for usage in a future extension of transaction formats
struct L2CanonicalTransaction {
    uint256 txType;
    uint256 from;
    uint256 to;
    uint256 gasLimit;
    uint256 gasPerPubdataByteLimit;
    uint256 maxFeePerGas;
    uint256 maxPriorityFeePerGas;
    uint256 paymaster;
    uint256 nonce;
    uint256 value;
    // In the future, we might want to add some
    // new fields to the struct. The `txData` struct
    // is to be passed to account and any changes to its structure
    // would mean a breaking change to these accounts. To prevent this,
    // we should keep some fields as "reserved"
    // It is also recommended that their length is fixed, since
    // it would allow easier proof integration (in case we will need
    // some special circuit for preprocessing transactions)
    uint256[4] reserved;
    bytes data;
    bytes signature;
    uint256[] factoryDeps;
    bytes paymasterInput;
    // Reserved dynamic type for the future use-case. Using it should be avoided,
    // But it is still here, just in case we want to enable some additional functionality
    bytes reservedDynamic;
}

/// @param sender The sender's address.
/// @param contractAddressL2 The address of the contract on L2 to call.
/// @param valueToMint The amount of base token that should be minted on L2 as the result of this transaction.
/// @param l2Value The msg.value of the L2 transaction.
/// @param l2Calldata The calldata for the L2 transaction.
/// @param l2GasLimit The limit of the L2 gas for the L2 transaction
/// @param l2GasPerPubdataByteLimit The price for a single pubdata byte in L2 gas.
/// @param factoryDeps The array of L2 bytecodes that the tx depends on.
/// @param refundRecipient The recipient of the refund for the transaction on L2. If the transaction fails, then
/// this address will receive the `l2Value`.
// solhint-disable-next-line gas-struct-packing
struct BridgehubL2TransactionRequest {
    address sender;
    address contractL2;
    uint256 mintValue;
    uint256 l2Value;
    bytes l2Calldata;
    uint256 l2GasLimit;
    uint256 l2GasPerPubdataByteLimit;
    bytes[] factoryDeps;
    address refundRecipient;
}