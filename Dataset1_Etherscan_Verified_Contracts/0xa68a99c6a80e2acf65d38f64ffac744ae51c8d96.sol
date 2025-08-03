// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IReceiver} from "./interfaces/IReceiver.sol";
import {IRouter} from "./interfaces/IRouter.sol";
import {ITypeAndVersion} from "../shared/interfaces/ITypeAndVersion.sol";

import {OwnerIsCreator} from "../shared/access/OwnerIsCreator.sol";

import {ERC165Checker} from "../vendor/openzeppelin-solidity/v4.8.3/contracts/utils/introspection/ERC165Checker.sol";

/// @notice This is an entry point for `write_${chain}` Target capability. It allows nodes to
/// determine if reports have been processed (successfully or not) in a decentralized and
/// product-agnostic way by recording processed reports.
contract KeystoneForwarder is OwnerIsCreator, ITypeAndVersion, IRouter {
  /// @notice This error is returned when the report is shorter than REPORT_METADATA_LENGTH,
  /// which is the minimum length of a report.
  error InvalidReport();

  /// @notice This error is thrown whenever trying to set a config with a fault tolerance of 0.
  error FaultToleranceMustBePositive();

  /// @notice This error is thrown whenever configuration provides more signers than the maximum allowed number.
  /// @param numSigners The number of signers who have signed the report
  /// @param maxSigners The maximum number of signers that can sign a report
  error ExcessSigners(uint256 numSigners, uint256 maxSigners);

  /// @notice This error is thrown whenever a configuration is provided with less than the minimum number of signers.
  /// @param numSigners The number of signers provided
  /// @param minSigners The minimum number of signers expected
  error InsufficientSigners(uint256 numSigners, uint256 minSigners);

  /// @notice This error is thrown whenever a duplicate signer address is provided in the configuration.
  /// @param signer The signer address that was duplicated.
  error DuplicateSigner(address signer);

  /// @notice This error is thrown whenever a report has an incorrect number of signatures.
  /// @param expected The number of signatures expected, F + 1
  /// @param received The number of signatures received
  error InvalidSignatureCount(uint256 expected, uint256 received);

  /// @notice This error is thrown whenever a report specifies a configuration that does not exist.
  /// @param configId (uint64(donId) << 32) | configVersion
  error InvalidConfig(uint64 configId);

  /// @notice This error is thrown whenever a signer address is not in the configuration or
  /// when trying to set a zero address as a signer.
  /// @param signer The signer address that was not in the configuration
  error InvalidSigner(address signer);

  /// @notice This error is thrown whenever a signature is invalid.
  /// @param signature The signature that was invalid
  error InvalidSignature(bytes signature);

  /// @notice Contains the signing address of each oracle
  struct OracleSet {
    uint8 f; // Number of faulty nodes allowed
    address[] signers;
    mapping(address signer => uint256 position) _positions; // 1-indexed to detect unset values
  }

  struct Transmission {
    address transmitter;
    // This is true if the receiver is not a contract or does not implement the `IReceiver` interface.
    bool invalidReceiver;
    // Whether the transmission attempt was successful. If `false`, the transmission can be retried
    // with an increased gas limit.
    bool success;
    // The amount of gas allocated for the `IReceiver.onReport` call. uint80 allows storing gas for known EVM block
    // gas limits. Ensures that the minimum gas requested by the user is available during the transmission attempt.
    // If the transmission fails (indicated by a `false` success state), it can be retried with an increased gas limit.
    uint80 gasLimit;
  }

  /// @notice Emitted when a report is processed
  /// @param result The result of the attempted delivery. True if successful.
  event ReportProcessed(
    address indexed receiver,
    bytes32 indexed workflowExecutionId,
    bytes2 indexed reportId,
    bool result
  );

  /// @notice Contains the configuration for each DON ID
  /// configId (uint64(donId) << 32) | configVersion
  mapping(uint64 configId => OracleSet oracleSet) internal s_configs;

  event ConfigSet(uint32 indexed donId, uint32 indexed configVersion, uint8 f, address[] signers);

  string public constant override typeAndVersion = "KeystoneForwarder 1.0.0";

  constructor() OwnerIsCreator() {
    s_forwarders[address(this)] = true;
  }

  uint256 internal constant MAX_ORACLES = 31;
  uint256 internal constant METADATA_LENGTH = 109;
  uint256 internal constant FORWARDER_METADATA_LENGTH = 45;
  uint256 internal constant SIGNATURE_LENGTH = 65;

  /// @dev This is the gas required to store `success` after the report is processed.
  /// It is a warm storage write because of the packed struct. In practice it will cost less.
  uint256 internal constant INTERNAL_GAS_REQUIREMENTS_AFTER_REPORT = 5_000;
  /// @dev This is the gas required to store the transmission struct and perform other checks.
  uint256 internal constant INTERNAL_GAS_REQUIREMENTS = 25_000 + INTERNAL_GAS_REQUIREMENTS_AFTER_REPORT;
  /// @dev This is the minimum gas required to route a report. This includes internal gas requirements
  /// as well as the minimum gas that the user contract will receive. 30k * 3 gas is to account for
  /// cases where consumers need close to the 30k limit provided in the supportsInterface check.
  uint256 internal constant MINIMUM_GAS_LIMIT = INTERNAL_GAS_REQUIREMENTS + 30_000 * 3 + 10_000;

  // ================================================================
  // │                          Router                              │
  // ================================================================

  mapping(address forwarder => bool isForwarder) internal s_forwarders;
  mapping(bytes32 transmissionId => Transmission transmission) internal s_transmissions;

  function addForwarder(address forwarder) external onlyOwner {
    s_forwarders[forwarder] = true;
    emit ForwarderAdded(forwarder);
  }

  function removeForwarder(address forwarder) external onlyOwner {
    s_forwarders[forwarder] = false;
    emit ForwarderRemoved(forwarder);
  }

  function route(
    bytes32 transmissionId,
    address transmitter,
    address receiver,
    bytes calldata metadata,
    bytes calldata validatedReport
  ) public returns (bool) {
    if (!s_forwarders[msg.sender]) revert UnauthorizedForwarder();

    uint256 gasLimit = gasleft() - INTERNAL_GAS_REQUIREMENTS;
    if (gasLimit < MINIMUM_GAS_LIMIT) revert InsufficientGasForRouting(transmissionId);

    Transmission memory transmission = s_transmissions[transmissionId];
    if (transmission.success || transmission.invalidReceiver) revert AlreadyAttempted(transmissionId);

    s_transmissions[transmissionId].transmitter = transmitter;
    s_transmissions[transmissionId].gasLimit = uint80(gasLimit);

    // This call can consume up to 90k gas.
    if (!ERC165Checker.supportsInterface(receiver, type(IReceiver).interfaceId)) {
      s_transmissions[transmissionId].invalidReceiver = true;
      return false;
    }

    bool success;
    bytes memory payload = abi.encodeCall(IReceiver.onReport, (metadata, validatedReport));

    uint256 remainingGas = gasleft() - INTERNAL_GAS_REQUIREMENTS_AFTER_REPORT;
    assembly {
      // call and return whether we succeeded. ignore return data
      // call(gas,addr,value,argsOffset,argsLength,retOffset,retLength)
      success := call(remainingGas, receiver, 0, add(payload, 0x20), mload(payload), 0x0, 0x0)
    }

    if (success) {
      s_transmissions[transmissionId].success = true;
    }
    return success;
  }

  function getTransmissionId(
    address receiver,
    bytes32 workflowExecutionId,
    bytes2 reportId
  ) public pure returns (bytes32) {
    // This is slightly cheaper compared to `keccak256(abi.encode(receiver, workflowExecutionId, reportId));`
    return keccak256(bytes.concat(bytes20(uint160(receiver)), workflowExecutionId, reportId));
  }

  function getTransmissionInfo(
    address receiver,
    bytes32 workflowExecutionId,
    bytes2 reportId
  ) external view returns (TransmissionInfo memory) {
    bytes32 transmissionId = getTransmissionId(receiver, workflowExecutionId, reportId);

    Transmission memory transmission = s_transmissions[transmissionId];

    TransmissionState state;

    if (transmission.transmitter == address(0)) {
      state = IRouter.TransmissionState.NOT_ATTEMPTED;
    } else if (transmission.invalidReceiver) {
      state = IRouter.TransmissionState.INVALID_RECEIVER;
    } else {
      state = transmission.success ? IRouter.TransmissionState.SUCCEEDED : IRouter.TransmissionState.FAILED;
    }

    return
      TransmissionInfo({
        gasLimit: transmission.gasLimit,
        invalidReceiver: transmission.invalidReceiver,
        state: state,
        success: transmission.success,
        transmissionId: transmissionId,
        transmitter: transmission.transmitter
      });
  }

  /// @notice Get transmitter of a given report or 0x0 if it wasn't transmitted yet
  function getTransmitter(
    address receiver,
    bytes32 workflowExecutionId,
    bytes2 reportId
  ) external view returns (address) {
    return s_transmissions[getTransmissionId(receiver, workflowExecutionId, reportId)].transmitter;
  }

  function isForwarder(address forwarder) external view returns (bool) {
    return s_forwarders[forwarder];
  }

  // ================================================================
  // │                          Forwarder                           │
  // ================================================================

  function setConfig(uint32 donId, uint32 configVersion, uint8 f, address[] calldata signers) external onlyOwner {
    if (f == 0) revert FaultToleranceMustBePositive();
    if (signers.length > MAX_ORACLES) revert ExcessSigners(signers.length, MAX_ORACLES);
    if (signers.length <= 3 * f) revert InsufficientSigners(signers.length, 3 * f + 1);

    uint64 configId = (uint64(donId) << 32) | configVersion;

    // remove any old signer addresses
    for (uint256 i = 0; i < s_configs[configId].signers.length; ++i) {
      delete s_configs[configId]._positions[s_configs[configId].signers[i]];
    }

    // add new signer addresses
    for (uint256 i = 0; i < signers.length; ++i) {
      // assign indices, detect duplicates
      address signer = signers[i];
      if (signer == address(0)) revert InvalidSigner(signer);
      if (s_configs[configId]._positions[signer] != 0) revert DuplicateSigner(signer);
      s_configs[configId]._positions[signer] = i + 1;
    }
    s_configs[configId].signers = signers;
    s_configs[configId].f = f;

    emit ConfigSet(donId, configVersion, f, signers);
  }

  function clearConfig(uint32 donId, uint32 configVersion) external onlyOwner {
    // We are not removing old signer positions, because it is sufficient to
    // clear the f value for `report` function. If we decide to restore
    // the configId in the future, the setConfig function clears the positions.
    s_configs[(uint64(donId) << 32) | configVersion].f = 0;

    emit ConfigSet(donId, configVersion, 0, new address[](0));
  }

  // send a report to receiver
  function report(
    address receiver,
    bytes calldata rawReport,
    bytes calldata reportContext,
    bytes[] calldata signatures
  ) external {
    if (rawReport.length < METADATA_LENGTH) {
      revert InvalidReport();
    }

    bytes32 workflowExecutionId;
    bytes2 reportId;
    {
      uint64 configId;
      (workflowExecutionId, configId, reportId) = _getMetadata(rawReport);
      OracleSet storage config = s_configs[configId];

      uint8 f = config.f;
      // f can never be 0, so this means the config doesn't actually exist
      if (f == 0) revert InvalidConfig(configId);
      if (f + 1 != signatures.length) revert InvalidSignatureCount(f + 1, signatures.length);

      // validate signatures
      bytes32 completeHash = keccak256(abi.encodePacked(keccak256(rawReport), reportContext));
      address[MAX_ORACLES + 1] memory signed;
      for (uint256 i = 0; i < signatures.length; ++i) {
        bytes calldata signature = signatures[i];
        if (signature.length != SIGNATURE_LENGTH) revert InvalidSignature(signature);
        address signer = ecrecover(
          completeHash,
          uint8(signature[64]) + 27,
          bytes32(signature[0:32]),
          bytes32(signature[32:64])
        );

        // validate signer is trusted and signature is unique
        uint256 index = config._positions[signer];
        if (index == 0) revert InvalidSigner(signer); // index is 1-indexed so we can detect unset signers
        if (signed[index] != address(0)) revert DuplicateSigner(signer);
        signed[index] = signer;
      }
    }

    bool success = this.route(
      getTransmissionId(receiver, workflowExecutionId, reportId),
      msg.sender,
      receiver,
      rawReport[FORWARDER_METADATA_LENGTH:METADATA_LENGTH],
      rawReport[METADATA_LENGTH:]
    );

    emit ReportProcessed(receiver, workflowExecutionId, reportId, success);
  }

  // solhint-disable-next-line chainlink-solidity/explicit-returns
  function _getMetadata(
    bytes memory rawReport
  ) internal pure returns (bytes32 workflowExecutionId, uint64 configId, bytes2 reportId) {
    // (first 32 bytes of memory contain length of the report)
    // version                offset  32, size  1
    // workflow_execution_id  offset  33, size 32
    // timestamp              offset  65, size  4
    // don_id                 offset  69, size  4
    // don_config_version,    offset  73, size  4
    // workflow_cid           offset  77, size 32
    // workflow_name          offset 109, size 10
    // workflow_owner         offset 119, size 20
    // report_id              offset 139, size  2
    assembly {
      workflowExecutionId := mload(add(rawReport, 33))
      // shift right by 24 bytes to get the combined don_id and don_config_version
      configId := shr(mul(24, 8), mload(add(rawReport, 69)))
      reportId := mload(add(rawReport, 139))
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC165} from "../../vendor/openzeppelin-solidity/v5.0.2/contracts/utils/introspection/IERC165.sol";

/// @title IReceiver - receives keystone reports
/// @notice Implementations must support the IReceiver interface through ERC165.
interface IReceiver is IERC165 {
  /// @notice Handles incoming keystone reports.
  /// @dev If this function call reverts, it can be retried with a higher gas
  /// limit. The receiver is responsible for discarding stale reports.
  /// @param metadata Report's metadata.
  /// @param report Workflow report.
  function onReport(bytes calldata metadata, bytes calldata report) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @title IRouter - delivers keystone reports to receiver
interface IRouter {
  error UnauthorizedForwarder();
  /// @dev Thrown when the gas limit is insufficient for handling state after
  /// calling the receiver function.
  error InsufficientGasForRouting(bytes32 transmissionId);
  error AlreadyAttempted(bytes32 transmissionId);

  event ForwarderAdded(address indexed forwarder);
  event ForwarderRemoved(address indexed forwarder);

  enum TransmissionState {
    NOT_ATTEMPTED,
    SUCCEEDED,
    INVALID_RECEIVER,
    FAILED
  }

  struct TransmissionInfo {
    bytes32 transmissionId;
    TransmissionState state;
    address transmitter;
    // This is true if the receiver is not a contract or does not implement the
    // `IReceiver` interface.
    bool invalidReceiver;
    // Whether the transmission attempt was successful. If `false`, the
    // transmission can be retried with an increased gas limit.
    bool success;
    // The amount of gas allocated for the `IReceiver.onReport` call. uint80
    // allows storing gas for known EVM block gas limits.
    // Ensures that the minimum gas requested by the user is available during
    // the transmission attempt. If the transmission fails (indicated by a
    // `false` success state), it can be retried with an increased gas limit.
    uint80 gasLimit;
  }

  function addForwarder(address forwarder) external;
  function removeForwarder(address forwarder) external;

  function route(
    bytes32 transmissionId,
    address transmitter,
    address receiver,
    bytes calldata metadata,
    bytes calldata report
  ) external returns (bool);

  function getTransmissionId(
    address receiver,
    bytes32 workflowExecutionId,
    bytes2 reportId
  ) external pure returns (bytes32);
  function getTransmissionInfo(
    address receiver,
    bytes32 workflowExecutionId,
    bytes2 reportId
  ) external view returns (TransmissionInfo memory);
  function getTransmitter(
    address receiver,
    bytes32 workflowExecutionId,
    bytes2 reportId
  ) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfirmedOwnerWithProposal} from "./ConfirmedOwnerWithProposal.sol";

/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IOwnable} from "../interfaces/IOwnable.sol";

/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    // solhint-disable-next-line gas-custom-errors
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /// @notice Allows an owner to begin transferring ownership to a new address.
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /// @notice Allows an ownership transfer to be completed by the recipient.
  function acceptOwnership() external override {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /// @notice Get the current owner
  function owner() public view override returns (address) {
    return s_owner;
  }

  /// @notice validate, transfer ownership, and emit relevant events
  function _transferOwnership(address to) private {
    // solhint-disable-next-line gas-custom-errors
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /// @notice validate access
  function _validateOwnership() internal view {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /// @notice Reverts if called by anyone other than the contract owner.
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfirmedOwner} from "./ConfirmedOwner.sol";

/// @title The OwnerIsCreator contract
/// @notice A contract with helpers for basic contract ownership.
contract OwnerIsCreator is ConfirmedOwner {
  constructor() ConfirmedOwner(msg.sender) {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITypeAndVersion {
  function typeAndVersion() external pure returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.2) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface.
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165).interfaceId) &&
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
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
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

        // query support of each interface in interfaceIds
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
     *
     * Some precompiled contracts will falsely indicate support for a given interface, so caution
     * should be exercised when using this function.
     *
     * Interface identification is specified in ERC-165.
     */
    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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