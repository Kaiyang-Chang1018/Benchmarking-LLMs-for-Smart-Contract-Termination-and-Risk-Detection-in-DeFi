// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IHyperdrive } from "../interfaces/IHyperdrive.sol";
import { IHyperdriveDeployerCoordinator } from "../interfaces/IHyperdriveDeployerCoordinator.sol";
import { IHyperdriveFactory } from "../interfaces/IHyperdriveFactory.sol";
import { FixedPointMath, ONE } from "../libraries/FixedPointMath.sol";
import { HYPERDRIVE_FACTORY_KIND, VERSION } from "../libraries/Constants.sol";
import { HyperdriveMath } from "../libraries/HyperdriveMath.sol";

/// @author DELV
/// @title HyperdriveFactory
/// @notice Deploys hyperdrive instances and initializes them. It also holds a
///         registry of all deployed hyperdrive instances.
/// @custom:disclaimer The language used in this code is for coding convenience
///                    only, and is not intended to, and does not, have any
///                    particular legal or regulatory significance.
contract HyperdriveFactory is IHyperdriveFactory {
    using FixedPointMath for uint256;

    /// @notice The factory's name.
    string public name;

    /// @notice The factory's kind.
    string public constant kind = HYPERDRIVE_FACTORY_KIND;

    /// @notice The factory's version.
    string public constant version = VERSION;

    /// @dev Signifies an unlocked receive function, used by isReceiveLocked
    uint256 private constant RECEIVE_UNLOCKED = 1;

    /// @dev Signifies a locked receive function, used by isReceiveLocked
    uint256 private constant RECEIVE_LOCKED = 2;

    /// @dev Locks the receive function. This can be used to prevent stuck ether
    ///      from ending up in the contract but still allowing refunds to be
    ///      received. Defaults to `RECEIVE_LOCKED`
    uint256 private receiveLockState = RECEIVE_LOCKED;

    /// @notice The governance address that updates the factory's configuration
    ///         and can add or remove deployer coordinators.
    address public governance;

    /// @notice The deployer coordinator manager that can add or remove deployer
    ///         coordinators.
    address public deployerCoordinatorManager;

    /// @notice The governance address used when new instances are deployed.
    address public hyperdriveGovernance;

    /// @notice The linker factory used when new instances are deployed.
    address public linkerFactory;

    /// @notice The linker code hash used when new instances are deployed.
    bytes32 public linkerCodeHash;

    /// @notice The fee collector used when new instances are deployed.
    address public feeCollector;

    /// @notice The sweep collector used when new instances are deployed.
    address public sweepCollector;

    /// @dev The address that will reward checkpoint minters.
    address public checkpointRewarder;

    /// @notice The resolution for the checkpoint duration. Every checkpoint
    ///         duration must be a multiple of this resolution.
    uint256 public checkpointDurationResolution;

    /// @notice The minimum checkpoint duration that can be used by new
    ///         deployments.
    uint256 public minCheckpointDuration;

    /// @notice The maximum checkpoint duration that can be used by new
    ///         deployments.
    uint256 public maxCheckpointDuration;

    /// @notice The minimum position duration that can be used by new
    ///         deployments.
    uint256 public minPositionDuration;

    /// @notice The maximum position duration that can be used by new
    ///         deployments.
    uint256 public maxPositionDuration;

    /// @notice The minimum circuit breaker delta that can be used by
    ///         new deployments.
    uint256 public minCircuitBreakerDelta;

    /// @notice The maximum circuit breaker delta that can be used by
    ///         new deployments.
    uint256 public maxCircuitBreakerDelta;

    /// @notice The minimum fixed APR that can be used by new deployments.
    uint256 public minFixedAPR;

    /// @notice The maximum fixed APR that can be used by new deployments.
    uint256 public maxFixedAPR;

    /// @notice The minimum time stretch APR that can be used by new deployments.
    uint256 public minTimeStretchAPR;

    /// @notice The maximum time stretch APR that can be used by new deployments.
    uint256 public maxTimeStretchAPR;

    /// @notice The minimum fee parameters that can be used by new deployments.
    IHyperdrive.Fees internal _minFees;

    /// @notice The maximum fee parameters that can be used by new deployments.
    IHyperdrive.Fees internal _maxFees;

    /// @notice The defaultPausers used when new instances are deployed.
    address[] internal _defaultPausers;

    struct FactoryConfig {
        /// @dev The address which can update a factory.
        address governance;
        /// @dev The address which can add and remove deployer coordinators.
        address deployerCoordinatorManager;
        /// @dev The address which is set as the governor of hyperdrive.
        address hyperdriveGovernance;
        /// @dev The default addresses which will be set to have the pauser role.
        address[] defaultPausers;
        /// @dev The recipient of governance fees from new deployments.
        address feeCollector;
        /// @dev The recipient of swept tokens from new deployments.
        address sweepCollector;
        /// @dev The address that will reward checkpoint minters.
        address checkpointRewarder;
        /// @dev The resolution for the checkpoint duration.
        uint256 checkpointDurationResolution;
        /// @dev The minimum checkpoint duration that can be used in new
        ///      deployments.
        uint256 minCheckpointDuration;
        /// @dev The maximum checkpoint duration that can be used in new
        ///      deployments.
        uint256 maxCheckpointDuration;
        /// @dev The minimum position duration that can be used in new
        ///      deployments.
        uint256 minPositionDuration;
        /// @dev The maximum position duration that can be used in new
        ///      deployments.
        uint256 maxPositionDuration;
        /// @dev The minimum circuit breaker delta that can be used in new
        ///      deployments.
        uint256 minCircuitBreakerDelta;
        /// @dev The maximum circuit breaker delta that can be used in new
        ///      deployments.
        uint256 maxCircuitBreakerDelta;
        /// @dev The minimum fixed APR that can be used in new deployments.
        uint256 minFixedAPR;
        /// @dev The maximum fixed APR that can be used in new deployments.
        uint256 maxFixedAPR;
        /// @dev The minimum time stretch APR that can be used in new
        ///      deployments.
        uint256 minTimeStretchAPR;
        /// @dev The maximum time stretch APR that can be used in new
        ///      deployments.
        uint256 maxTimeStretchAPR;
        /// @dev The lower bound on the fees that can be used in new deployments.
        /// @dev Most of the fee parameters are used unmodified; however, the
        ///      flat fee parameter is interpreted as the minimum annualized
        ///      flat fee. This allows deployers to specify a smaller flat fee
        ///      than the minimum for terms shorter than a year and ensures that
        ///      they specify a larger flat fee than the minimum for terms
        ///      longer than a year.
        IHyperdrive.Fees minFees;
        /// @dev The upper bound on the fees that can be used in new deployments.
        /// @dev Most of the fee parameters are used unmodified; however, the
        ///      flat fee parameter is interpreted as the maximum annualized
        ///      flat fee. This ensures that deployers specify a smaller flat
        ///      fee than the maximum for terms shorter than a year and allows
        ///      deployers to specify a larger flat fee than the maximum for
        ///      terms longer than a year.
        IHyperdrive.Fees maxFees;
        /// @dev The address of the linker factory.
        address linkerFactory;
        /// @dev The hash of the linker contract's constructor code.
        bytes32 linkerCodeHash;
    }

    /// @dev List of all deployer coordinators registered by governance.
    address[] internal _deployerCoordinators;

    /// @notice Mapping to check if a deployer coordinator has been registered
    ///         by governance.
    mapping(address => bool) public isDeployerCoordinator;

    /// @dev A mapping from deployed Hyperdrive instances to the deployer
    ///      coordinator that deployed them. This is useful for verifying the
    ///      bytecode that was used to deploy the instance.
    mapping(address instance => address deployCoordinator)
        public _instancesToDeployerCoordinators;

    /// @dev Array of all instances deployed by this factory.
    address[] internal _instances;

    /// @dev Mapping to check if an instance is in the _instances array.
    mapping(address => bool) public isInstance;

    /// @notice Initializes the factory.
    /// @param _factoryConfig Configuration of the Hyperdrive Factory.
    /// @param _name The factory's name.
    constructor(FactoryConfig memory _factoryConfig, string memory _name) {
        // Set the factory's name.
        name = _name;

        // Ensure that the minimum checkpoint duration is greater than or equal
        // to the checkpoint duration resolution and is a multiple of the
        // checkpoint duration resolution.
        if (
            _factoryConfig.minCheckpointDuration <
            _factoryConfig.checkpointDurationResolution ||
            _factoryConfig.minCheckpointDuration %
                _factoryConfig.checkpointDurationResolution !=
            0
        ) {
            revert IHyperdriveFactory.InvalidMinCheckpointDuration();
        }
        minCheckpointDuration = _factoryConfig.minCheckpointDuration;

        // Ensure that the maximum checkpoint duration is greater than or equal
        // to the minimum checkpoint duration and is a multiple of the
        // checkpoint duration resolution.
        if (
            _factoryConfig.maxCheckpointDuration <
            _factoryConfig.minCheckpointDuration ||
            _factoryConfig.maxCheckpointDuration %
                _factoryConfig.checkpointDurationResolution !=
            0
        ) {
            revert IHyperdriveFactory.InvalidMaxCheckpointDuration();
        }
        maxCheckpointDuration = _factoryConfig.maxCheckpointDuration;

        // Ensure that the minimum position duration is greater than or equal
        // to the maximum checkpoint duration and is a multiple of the
        // checkpoint duration resolution.
        if (
            _factoryConfig.minPositionDuration <
            _factoryConfig.maxCheckpointDuration ||
            _factoryConfig.minPositionDuration %
                _factoryConfig.checkpointDurationResolution !=
            0
        ) {
            revert IHyperdriveFactory.InvalidMinPositionDuration();
        }
        minPositionDuration = _factoryConfig.minPositionDuration;

        // Ensure that the maximum position duration is greater than or equal
        // to the minimum position duration and is a multiple of the checkpoint
        // duration resolution.
        if (
            _factoryConfig.maxPositionDuration <
            _factoryConfig.minPositionDuration ||
            _factoryConfig.maxPositionDuration %
                _factoryConfig.checkpointDurationResolution !=
            0
        ) {
            revert IHyperdriveFactory.InvalidMaxPositionDuration();
        }
        maxPositionDuration = _factoryConfig.maxPositionDuration;

        // Ensure that the minimum circuit breaker delta is greater than or
        // equal to the maximum circuit breaker delta.
        if (
            _factoryConfig.minCircuitBreakerDelta >
            _factoryConfig.maxCircuitBreakerDelta
        ) {
            revert IHyperdriveFactory.InvalidCircuitBreakerDelta();
        }
        minCircuitBreakerDelta = _factoryConfig.minCircuitBreakerDelta;
        maxCircuitBreakerDelta = _factoryConfig.maxCircuitBreakerDelta;

        // Ensure that the minimum fixed APR is less than or equal to the
        // maximum fixed APR.
        if (_factoryConfig.minFixedAPR > _factoryConfig.maxFixedAPR) {
            revert IHyperdriveFactory.InvalidFixedAPR();
        }
        minFixedAPR = _factoryConfig.minFixedAPR;
        maxFixedAPR = _factoryConfig.maxFixedAPR;

        // Ensure that the minimum time stretch APR is less than or equal to the
        // maximum time stretch APR.
        if (
            _factoryConfig.minTimeStretchAPR > _factoryConfig.maxTimeStretchAPR
        ) {
            revert IHyperdriveFactory.InvalidTimeStretchAPR();
        }
        minTimeStretchAPR = _factoryConfig.minTimeStretchAPR;
        maxTimeStretchAPR = _factoryConfig.maxTimeStretchAPR;

        // Ensure that the max fees are each less than or equal to 100% and set
        // the fees.
        if (
            _factoryConfig.maxFees.curve > ONE ||
            _factoryConfig.maxFees.flat > ONE ||
            _factoryConfig.maxFees.governanceLP > ONE ||
            _factoryConfig.maxFees.governanceZombie > ONE
        ) {
            revert IHyperdriveFactory.InvalidMaxFees();
        }
        _maxFees = _factoryConfig.maxFees;

        // Ensure that the min fees are each less than or equal to the
        // corresponding and parameter in the max fees and set the fees.
        if (
            _factoryConfig.minFees.curve > _factoryConfig.maxFees.curve ||
            _factoryConfig.minFees.flat > _factoryConfig.maxFees.flat ||
            _factoryConfig.minFees.governanceLP >
            _factoryConfig.maxFees.governanceLP ||
            _factoryConfig.minFees.governanceZombie >
            _factoryConfig.maxFees.governanceZombie
        ) {
            revert IHyperdriveFactory.InvalidMinFees();
        }
        _minFees = _factoryConfig.minFees;

        // Initialize the other parameters.
        governance = _factoryConfig.governance;
        deployerCoordinatorManager = _factoryConfig.deployerCoordinatorManager;
        hyperdriveGovernance = _factoryConfig.hyperdriveGovernance;
        feeCollector = _factoryConfig.feeCollector;
        sweepCollector = _factoryConfig.sweepCollector;
        checkpointRewarder = _factoryConfig.checkpointRewarder;
        _defaultPausers = _factoryConfig.defaultPausers;
        linkerFactory = _factoryConfig.linkerFactory;
        linkerCodeHash = _factoryConfig.linkerCodeHash;
        checkpointDurationResolution = _factoryConfig
            .checkpointDurationResolution;
    }

    /// @dev Ensure that the sender is the governance address.
    modifier onlyGovernance() {
        if (msg.sender != governance) {
            revert IHyperdriveFactory.Unauthorized();
        }
        _;
    }

    /// @dev Ensure that the sender is either the governance address or the
    ///      deployer coordinator manager.
    modifier onlyDeployerCoordinatorManager() {
        if (
            msg.sender != governance && msg.sender != deployerCoordinatorManager
        ) {
            revert IHyperdriveFactory.Unauthorized();
        }
        _;
    }

    /// @notice Allows ether to be sent to the contract. This is gated by a lock
    ///         to prevent ether from becoming stuck in the contract.
    receive() external payable {
        if (receiveLockState == RECEIVE_LOCKED) {
            revert IHyperdriveFactory.ReceiveLocked();
        }
    }

    /// @notice Allows governance to transfer the governance role.
    /// @param _governance The new governance address.
    function updateGovernance(address _governance) external onlyGovernance {
        governance = _governance;
        emit GovernanceUpdated(_governance);
    }

    /// @notice Allows governance to change the deployer coordinator manager
    ///         address.
    /// @param _deployerCoordinatorManager The new deployer coordinator manager
    ///        address.
    function updateDeployerCoordinatorManager(
        address _deployerCoordinatorManager
    ) external onlyGovernance {
        deployerCoordinatorManager = _deployerCoordinatorManager;
        emit DeployerCoordinatorManagerUpdated(_deployerCoordinatorManager);
    }

    /// @notice Allows governance to change the hyperdrive governance address.
    /// @param _hyperdriveGovernance The new hyperdrive governance address.
    function updateHyperdriveGovernance(
        address _hyperdriveGovernance
    ) external onlyGovernance {
        hyperdriveGovernance = _hyperdriveGovernance;
        emit HyperdriveGovernanceUpdated(_hyperdriveGovernance);
    }

    /// @notice Allows governance to change the linker factory.
    /// @param _linkerFactory The new linker factory.
    function updateLinkerFactory(
        address _linkerFactory
    ) external onlyGovernance {
        linkerFactory = _linkerFactory;
        emit LinkerFactoryUpdated(_linkerFactory);
    }

    /// @notice Allows governance to change the linker code hash. This allows
    ///         governance to update the implementation of the ERC20Forwarder.
    /// @param _linkerCodeHash The new linker code hash.
    function updateLinkerCodeHash(
        bytes32 _linkerCodeHash
    ) external onlyGovernance {
        linkerCodeHash = _linkerCodeHash;
        emit LinkerCodeHashUpdated(_linkerCodeHash);
    }

    /// @notice Allows governance to change the fee collector address.
    /// @param _feeCollector The new fee collector address.
    function updateFeeCollector(address _feeCollector) external onlyGovernance {
        feeCollector = _feeCollector;
        emit FeeCollectorUpdated(_feeCollector);
    }

    /// @notice Allows governance to change the sweep collector address.
    /// @param _sweepCollector The new sweep collector address.
    function updateSweepCollector(
        address _sweepCollector
    ) external onlyGovernance {
        sweepCollector = _sweepCollector;
        emit SweepCollectorUpdated(_sweepCollector);
    }

    /// @notice Allows governance to change the checkpoint rewarder address.
    /// @param _checkpointRewarder The new checkpoint rewarder address.
    function updateCheckpointRewarder(
        address _checkpointRewarder
    ) external onlyGovernance {
        checkpointRewarder = _checkpointRewarder;
        emit CheckpointRewarderUpdated(_checkpointRewarder);
    }

    /// @notice Allows governance to change the checkpoint duration resolution.
    /// @param _checkpointDurationResolution The new checkpoint duration
    ///        resolution.
    function updateCheckpointDurationResolution(
        uint256 _checkpointDurationResolution
    ) external onlyGovernance {
        // Ensure that the minimum checkpoint duration, maximum checkpoint
        // duration, minimum position duration, and maximum position duration
        // are all multiples of the checkpoint duration resolution.
        if (
            minCheckpointDuration % _checkpointDurationResolution != 0 ||
            maxCheckpointDuration % _checkpointDurationResolution != 0 ||
            minPositionDuration % _checkpointDurationResolution != 0 ||
            maxPositionDuration % _checkpointDurationResolution != 0
        ) {
            revert IHyperdriveFactory.InvalidCheckpointDurationResolution();
        }

        // Update the checkpoint duration resolution and emit an event.
        checkpointDurationResolution = _checkpointDurationResolution;
        emit CheckpointDurationResolutionUpdated(_checkpointDurationResolution);
    }

    /// @notice Allows governance to update the maximum checkpoint duration.
    /// @param _maxCheckpointDuration The new maximum checkpoint duration.
    function updateMaxCheckpointDuration(
        uint256 _maxCheckpointDuration
    ) external onlyGovernance {
        // Ensure that the maximum checkpoint duration is greater than or equal
        // to the minimum checkpoint duration and is a multiple of the
        // checkpoint duration resolution. Also ensure that the maximum
        // checkpoint duration is less than or equal to the minimum position
        // duration.
        if (
            _maxCheckpointDuration < minCheckpointDuration ||
            _maxCheckpointDuration % checkpointDurationResolution != 0 ||
            _maxCheckpointDuration > minPositionDuration
        ) {
            revert IHyperdriveFactory.InvalidMaxCheckpointDuration();
        }

        // Update the maximum checkpoint duration and emit an event.
        maxCheckpointDuration = _maxCheckpointDuration;
        emit MaxCheckpointDurationUpdated(_maxCheckpointDuration);
    }

    /// @notice Allows governance to update the minimum checkpoint duration.
    /// @param _minCheckpointDuration The new minimum checkpoint duration.
    function updateMinCheckpointDuration(
        uint256 _minCheckpointDuration
    ) external onlyGovernance {
        // Ensure that the minimum checkpoint duration is greater than or equal
        // to the checkpoint duration resolution and is a multiple of the
        // checkpoint duration resolution. Also ensure that the minimum
        // checkpoint duration is less than or equal to the maximum checkpoint
        // duration.
        if (
            _minCheckpointDuration < checkpointDurationResolution ||
            _minCheckpointDuration % checkpointDurationResolution != 0 ||
            _minCheckpointDuration > maxCheckpointDuration
        ) {
            revert IHyperdriveFactory.InvalidMinCheckpointDuration();
        }

        // Update the minimum checkpoint duration and emit an event.
        minCheckpointDuration = _minCheckpointDuration;
        emit MinCheckpointDurationUpdated(_minCheckpointDuration);
    }

    /// @notice Allows governance to update the maximum position duration.
    /// @param _maxPositionDuration The new maximum position duration.
    function updateMaxPositionDuration(
        uint256 _maxPositionDuration
    ) external onlyGovernance {
        // Ensure that the maximum position duration is greater than or equal
        // to the minimum position duration and is a multiple of the checkpoint
        // duration resolution.
        if (
            _maxPositionDuration < minPositionDuration ||
            _maxPositionDuration % checkpointDurationResolution != 0
        ) {
            revert IHyperdriveFactory.InvalidMaxPositionDuration();
        }

        // Update the maximum position duration and emit an event.
        maxPositionDuration = _maxPositionDuration;
        emit MaxPositionDurationUpdated(_maxPositionDuration);
    }

    /// @notice Allows governance to update the minimum position duration.
    /// @param _minPositionDuration The new minimum position duration.
    function updateMinPositionDuration(
        uint256 _minPositionDuration
    ) external onlyGovernance {
        // Ensure that the minimum position duration is greater than or equal
        // to the maximum checkpoint duration and is a multiple of the
        // checkpoint duration resolution. Also ensure that the minimum position
        // duration is less than or equal to the maximum position duration.
        if (
            _minPositionDuration < maxCheckpointDuration ||
            _minPositionDuration % checkpointDurationResolution != 0 ||
            _minPositionDuration > maxPositionDuration
        ) {
            revert IHyperdriveFactory.InvalidMinPositionDuration();
        }

        // Update the minimum position duration and emit an event.
        minPositionDuration = _minPositionDuration;
        emit MinPositionDurationUpdated(_minPositionDuration);
    }

    /// @notice Allows governance to update the maximum circuit breaker delta.
    /// @param _maxCircuitBreakerDelta The new maximum circuit breaker delta.
    function updateMaxCircuitBreakerDelta(
        uint256 _maxCircuitBreakerDelta
    ) external onlyGovernance {
        // Ensure that the maximum circuit breaker delta is greater than or
        // equal to the minimum circuit breaker delta.
        if (_maxCircuitBreakerDelta < minCircuitBreakerDelta) {
            revert IHyperdriveFactory.InvalidMaxCircuitBreakerDelta();
        }

        // Update the maximum circuit breaker delta and emit an event.
        maxCircuitBreakerDelta = _maxCircuitBreakerDelta;
        emit MaxCircuitBreakerDeltaUpdated(_maxCircuitBreakerDelta);
    }

    /// @notice Allows governance to update the minimum circuit breaker delta.
    /// @param _minCircuitBreakerDelta The new minimum circuit breaker delta.
    function updateMinCircuitBreakerDelta(
        uint256 _minCircuitBreakerDelta
    ) external onlyGovernance {
        // Ensure that the minimum position duration is greater than or equal
        // to the maximum checkpoint duration and is a multiple of the
        // checkpoint duration resolution. Also ensure that the minimum position
        // duration is less than or equal to the maximum position duration.
        if (_minCircuitBreakerDelta > maxCircuitBreakerDelta) {
            revert IHyperdriveFactory.InvalidMinCircuitBreakerDelta();
        }

        // Update the minimum circuit breaker delta and emit an event.
        minCircuitBreakerDelta = _minCircuitBreakerDelta;
        emit MinCircuitBreakerDeltaUpdated(_minCircuitBreakerDelta);
    }

    /// @notice Allows governance to update the maximum fixed APR.
    /// @param _maxFixedAPR The new maximum fixed APR.
    function updateMaxFixedAPR(uint256 _maxFixedAPR) external onlyGovernance {
        // Ensure that the maximum fixed APR is greater than or equal to the
        // minimum fixed APR.
        if (_maxFixedAPR < minFixedAPR) {
            revert IHyperdriveFactory.InvalidMaxFixedAPR();
        }

        // Update the maximum fixed APR and emit an event.
        maxFixedAPR = _maxFixedAPR;
        emit MaxFixedAPRUpdated(_maxFixedAPR);
    }

    /// @notice Allows governance to update the minimum fixed APR.
    /// @param _minFixedAPR The new minimum fixed APR.
    function updateMinFixedAPR(uint256 _minFixedAPR) external onlyGovernance {
        // Ensure that the minimum fixed APR is less than or equal to the
        // maximum fixed APR.
        if (_minFixedAPR > maxFixedAPR) {
            revert IHyperdriveFactory.InvalidMinFixedAPR();
        }

        // Update the minimum fixed APR and emit an event.
        minFixedAPR = _minFixedAPR;
        emit MinFixedAPRUpdated(_minFixedAPR);
    }

    /// @notice Allows governance to update the maximum time stretch APR.
    /// @param _maxTimeStretchAPR The new maximum time stretch APR.
    function updateMaxTimeStretchAPR(
        uint256 _maxTimeStretchAPR
    ) external onlyGovernance {
        // Ensure that the maximum time stretch APR is greater than or equal
        // to the minimum time stretch APR.
        if (_maxTimeStretchAPR < minTimeStretchAPR) {
            revert IHyperdriveFactory.InvalidMaxTimeStretchAPR();
        }

        // Update the maximum time stretch APR and emit an event.
        maxTimeStretchAPR = _maxTimeStretchAPR;
        emit MaxTimeStretchAPRUpdated(_maxTimeStretchAPR);
    }

    /// @notice Allows governance to update the minimum time stretch APR.
    /// @param _minTimeStretchAPR The new minimum time stretch APR.
    function updateMinTimeStretchAPR(
        uint256 _minTimeStretchAPR
    ) external onlyGovernance {
        // Ensure that the minimum time stretch APR is less than or equal
        // to the maximum time stretch APR.
        if (_minTimeStretchAPR > maxTimeStretchAPR) {
            revert IHyperdriveFactory.InvalidMinTimeStretchAPR();
        }

        // Update the minimum time stretch APR and emit an event.
        minTimeStretchAPR = _minTimeStretchAPR;
        emit MinTimeStretchAPRUpdated(_minTimeStretchAPR);
    }

    /// @notice Allows governance to update the maximum fee parameters.
    /// @param __maxFees The new maximum fee parameters.
    function updateMaxFees(
        IHyperdrive.Fees calldata __maxFees
    ) external onlyGovernance {
        // Ensure that the max fees are each less than or equal to 100% and that
        // the max fees are each greater than or equal to the corresponding min
        // fee.
        IHyperdrive.Fees memory minFees_ = _minFees;
        if (
            __maxFees.curve > ONE ||
            __maxFees.flat > ONE ||
            __maxFees.governanceLP > ONE ||
            __maxFees.governanceZombie > ONE ||
            __maxFees.curve < minFees_.curve ||
            __maxFees.flat < minFees_.flat ||
            __maxFees.governanceLP < minFees_.governanceLP ||
            __maxFees.governanceZombie < minFees_.governanceZombie
        ) {
            revert IHyperdriveFactory.InvalidMaxFees();
        }

        // Update the max fees and emit an event.
        _maxFees = __maxFees;
        emit MaxFeesUpdated(__maxFees);
    }

    /// @notice Allows governance to update the minimum fee parameters.
    /// @param __minFees The new minimum fee parameters.
    function updateMinFees(
        IHyperdrive.Fees calldata __minFees
    ) external onlyGovernance {
        // Ensure that the min fees are each less than or the corresponding max
        // fee.
        IHyperdrive.Fees memory maxFees_ = _maxFees;
        if (
            __minFees.curve > maxFees_.curve ||
            __minFees.flat > maxFees_.flat ||
            __minFees.governanceLP > maxFees_.governanceLP ||
            __minFees.governanceZombie > maxFees_.governanceZombie
        ) {
            revert IHyperdriveFactory.InvalidMinFees();
        }

        // Update the max fees and emit an event.
        _minFees = __minFees;
        emit MinFeesUpdated(__minFees);
    }

    /// @notice Allows governance to change the default pausers.
    /// @param _defaultPausers_ The new list of default pausers.
    function updateDefaultPausers(
        address[] calldata _defaultPausers_
    ) external onlyGovernance {
        _defaultPausers = _defaultPausers_;
        emit DefaultPausersUpdated(_defaultPausers_);
    }

    /// @notice Allows governance to add a new deployer coordinator.
    /// @param _deployerCoordinator The new deployer coordinator.
    function addDeployerCoordinator(
        address _deployerCoordinator
    ) external onlyDeployerCoordinatorManager {
        if (isDeployerCoordinator[_deployerCoordinator]) {
            revert IHyperdriveFactory.DeployerCoordinatorAlreadyAdded();
        }
        isDeployerCoordinator[_deployerCoordinator] = true;
        _deployerCoordinators.push(_deployerCoordinator);
        emit DeployerCoordinatorAdded(_deployerCoordinator);
    }

    /// @notice Allows governance to remove an existing deployer coordinator.
    /// @param _deployerCoordinator The deployer coordinator to remove.
    /// @param _index The index of the deployer coordinator to remove.
    function removeDeployerCoordinator(
        address _deployerCoordinator,
        uint256 _index
    ) external onlyDeployerCoordinatorManager {
        if (!isDeployerCoordinator[_deployerCoordinator]) {
            revert IHyperdriveFactory.DeployerCoordinatorNotAdded();
        }
        if (_deployerCoordinators[_index] != _deployerCoordinator) {
            revert IHyperdriveFactory.DeployerCoordinatorIndexMismatch();
        }
        isDeployerCoordinator[_deployerCoordinator] = false;
        _deployerCoordinators[_index] = _deployerCoordinators[
            _deployerCoordinators.length - 1
        ];
        _deployerCoordinators.pop();
        emit DeployerCoordinatorRemoved(_deployerCoordinator);
    }

    /// @notice Deploys a Hyperdrive instance with the factory's configuration.
    /// @dev This function is declared as payable to allow payable overrides
    ///      to accept ether on initialization, but payability is not supported
    ///      by default.
    /// @param _deploymentId The deployment ID to use when deploying the pool.
    /// @param _deployerCoordinator The deployer coordinator to use in this
    ///        deployment.
    /// @param __name The name of the Hyperdrive pool.
    /// @param _config The configuration of the Hyperdrive pool.
    /// @param _extraData The extra data that contains data necessary for the
    ///        specific deployer.
    /// @param _contribution The contribution amount in base to the pool.
    /// @param _fixedAPR The fixed APR used to initialize the pool.
    /// @param _timeStretchAPR The time stretch APR used to initialize the pool.
    /// @param _options The options for the `initialize` call.
    /// @param _salt The create2 salt to use for the deployment.
    /// @return The hyperdrive address deployed.
    function deployAndInitialize(
        bytes32 _deploymentId,
        address _deployerCoordinator,
        string memory __name,
        IHyperdrive.PoolDeployConfig memory _config,
        bytes memory _extraData,
        uint256 _contribution,
        uint256 _fixedAPR,
        uint256 _timeStretchAPR,
        IHyperdrive.Options memory _options,
        bytes32 _salt
    ) external payable returns (IHyperdrive) {
        // Ensure that the deployer coordinator has been registered.
        if (!isDeployerCoordinator[_deployerCoordinator]) {
            revert IHyperdriveFactory.InvalidDeployerCoordinator();
        }

        // Override the config values to the default values set by governance
        // and ensure that the config is valid.
        _overrideConfig(_config, _fixedAPR, _timeStretchAPR);

        // Deploy the Hyperdrive instance with the specified deployer
        // coordinator.
        IHyperdrive hyperdrive = IHyperdrive(
            IHyperdriveDeployerCoordinator(_deployerCoordinator)
                .deployHyperdrive(
                    // NOTE: We hash the deployer's address into the deployment ID
                    // to prevent their deployment from being front-run.
                    keccak256(abi.encode(msg.sender, _deploymentId)),
                    __name,
                    _config,
                    _extraData,
                    _salt
                )
        );

        // Add this instance to the registry and emit an event with the
        // deployment configuration.
        _instancesToDeployerCoordinators[
            address(hyperdrive)
        ] = _deployerCoordinator;
        _config.governance = hyperdriveGovernance;
        emit Deployed(
            _deployerCoordinator,
            address(hyperdrive),
            __name,
            _config,
            _extraData
        );

        // Add the newly deployed Hyperdrive instance to the registry.
        _instances.push(address(hyperdrive));
        isInstance[address(hyperdrive)] = true;

        // Initialize the Hyperdrive instance.
        receiveLockState = RECEIVE_UNLOCKED;
        IHyperdriveDeployerCoordinator(_deployerCoordinator).initialize{
            value: msg.value
        }(
            // NOTE: We hash the deployer's address into the deployment ID
            // to prevent their deployment from being front-run.
            keccak256(abi.encode(msg.sender, _deploymentId)),
            msg.sender,
            _contribution,
            _fixedAPR,
            _options
        );
        receiveLockState = RECEIVE_LOCKED;

        // Set the default pausers and transfer the governance status to the
        // hyperdrive governance address.
        for (uint256 i = 0; i < _defaultPausers.length; ) {
            hyperdrive.setPauser(_defaultPausers[i], true);
            unchecked {
                ++i;
            }
        }
        hyperdrive.setGovernance(hyperdriveGovernance);

        // Refund any excess ether that was sent to this contract.
        uint256 refund = address(this).balance;
        if (refund > 0) {
            (bool success, ) = payable(msg.sender).call{ value: refund }("");
            if (!success) {
                revert IHyperdriveFactory.TransferFailed();
            }
        }

        return hyperdrive;
    }

    /// @notice Deploys a Hyperdrive target with the factory's configuration.
    /// @param _deploymentId The deployment ID to use when deploying the pool.
    /// @param _deployerCoordinator The deployer coordinator to use in this
    ///        deployment.
    /// @param _config The configuration of the Hyperdrive pool.
    /// @param _extraData The extra data that contains data necessary for the
    ///        specific deployer.
    /// @param _fixedAPR The fixed APR used to initialize the pool.
    /// @param _timeStretchAPR The time stretch APR used to initialize the pool.
    /// @param _targetIndex The index of the target to deploy.
    /// @param _salt The create2 salt to use for the deployment.
    /// @return The target address deployed.
    function deployTarget(
        bytes32 _deploymentId,
        address _deployerCoordinator,
        IHyperdrive.PoolDeployConfig memory _config,
        bytes memory _extraData,
        uint256 _fixedAPR,
        uint256 _timeStretchAPR,
        uint256 _targetIndex,
        bytes32 _salt
    ) external returns (address) {
        // Ensure that the deployer coordinator has been registered.
        if (!isDeployerCoordinator[_deployerCoordinator]) {
            revert IHyperdriveFactory.InvalidDeployerCoordinator();
        }

        // Override the config values to the default values set by governance
        // and ensure that the config is valid.
        _overrideConfig(_config, _fixedAPR, _timeStretchAPR);

        // Deploy the target instance with the specified deployer coordinator.
        address target = IHyperdriveDeployerCoordinator(_deployerCoordinator)
            .deployTarget(
                // NOTE: We hash the deployer's address into the deployment ID
                // to prevent their deployment from being front-run.
                keccak256(abi.encode(msg.sender, _deploymentId)),
                _config,
                _extraData,
                _targetIndex,
                _salt
            );

        return target;
    }

    /// @notice Gets the max fees.
    /// @return The max fees.
    function maxFees() external view returns (IHyperdrive.Fees memory) {
        return _maxFees;
    }

    /// @notice Gets the min fees.
    /// @return The min fees.
    function minFees() external view returns (IHyperdrive.Fees memory) {
        return _minFees;
    }

    /// @notice Gets the default pausers.
    /// @return The default pausers.
    function defaultPausers() external view returns (address[] memory) {
        return _defaultPausers;
    }

    /// @notice Gets the number of instances deployed by this factory.
    /// @return The number of instances deployed by this factory.
    function getNumberOfInstances() external view returns (uint256) {
        return _instances.length;
    }

    /// @notice Gets the instance at the specified index.
    /// @param _index The index of the instance to get.
    /// @return The instance at the specified index.
    function getInstanceAtIndex(
        uint256 _index
    ) external view returns (address) {
        return _instances[_index];
    }

    /// @notice Returns the _instances array according to specified indices.
    /// @param _startIndex The starting index of the instances to get (inclusive).
    /// @param _endIndex The ending index of the instances to get (exclusive).
    /// @return range The resulting custom portion of the _instances array.
    function getInstancesInRange(
        uint256 _startIndex,
        uint256 _endIndex
    ) external view returns (address[] memory range) {
        // If the indexes are malformed, revert.
        if (_startIndex >= _endIndex) {
            revert IHyperdriveFactory.InvalidIndexes();
        }
        if (_endIndex > _instances.length) {
            revert IHyperdriveFactory.EndIndexTooLarge();
        }

        // Return the range of instances.
        range = new address[](_endIndex - _startIndex);
        for (uint256 i = _startIndex; i < _endIndex; i++) {
            unchecked {
                range[i - _startIndex] = _instances[i];
            }
        }
    }

    /// @notice Gets the number of deployer coordinators registered in this
    ///         factory.
    /// @return The number of deployer coordinators deployed by this factory.
    function getNumberOfDeployerCoordinators() external view returns (uint256) {
        return _deployerCoordinators.length;
    }

    /// @notice Gets the deployer coordinator at the specified index.
    /// @param _index The index of the deployer coordinator to get.
    /// @return The deployer coordinator at the specified index.
    function getDeployerCoordinatorAtIndex(
        uint256 _index
    ) external view returns (address) {
        return _deployerCoordinators[_index];
    }

    /// @notice Returns the deployer coordinators with an index between the
    ///         starting and ending indexes.
    /// @param _startIndex The starting index (inclusive).
    /// @param _endIndex The ending index (exclusive).
    /// @return range The deployer coordinators within the specified range.
    function getDeployerCoordinatorsInRange(
        uint256 _startIndex,
        uint256 _endIndex
    ) external view returns (address[] memory range) {
        // If the indexes are malformed, revert.
        if (_startIndex >= _endIndex) {
            revert IHyperdriveFactory.InvalidIndexes();
        }
        if (_endIndex > _deployerCoordinators.length) {
            revert IHyperdriveFactory.EndIndexTooLarge();
        }

        // Return the range of instances.
        range = new address[](_endIndex - _startIndex);
        for (uint256 i = _startIndex; i < _endIndex; i++) {
            unchecked {
                range[i - _startIndex] = _deployerCoordinators[i];
            }
        }
    }

    /// @notice Gets the deployer coordinators that deployed a list of instances.
    /// @param __instances The instances.
    /// @return coordinators The deployer coordinators.
    function getDeployerCoordinatorByInstances(
        address[] calldata __instances
    ) external view returns (address[] memory coordinators) {
        coordinators = new address[](_instances.length);
        for (uint256 i = 0; i < __instances.length; i++) {
            coordinators[i] = _instancesToDeployerCoordinators[__instances[i]];
        }
        return coordinators;
    }

    /// @dev Overrides the config values to the default values set by
    ///      governance. In the process of overriding these parameters, this
    ///      verifies that the specified config is valid.
    /// @param _config The config to override.
    /// @param _fixedAPR The fixed APR to use in the override.
    /// @param _timeStretchAPR The time stretch APR to use in the override.
    function _overrideConfig(
        IHyperdrive.PoolDeployConfig memory _config,
        uint256 _fixedAPR,
        uint256 _timeStretchAPR
    ) internal view {
        // Ensure that the specified checkpoint duration is within the minimum
        // and maximum checkpoint durations and is a multiple of the checkpoint
        // duration resolution.
        if (
            _config.checkpointDuration < minCheckpointDuration ||
            _config.checkpointDuration > maxCheckpointDuration ||
            _config.checkpointDuration % checkpointDurationResolution != 0
        ) {
            revert IHyperdriveFactory.InvalidCheckpointDuration();
        }

        // Ensure that the specified checkpoint duration is within the minimum
        // and maximum position durations and is a multiple of the specified
        // checkpoint duration.
        if (
            _config.positionDuration < minPositionDuration ||
            _config.positionDuration > maxPositionDuration ||
            _config.positionDuration % _config.checkpointDuration != 0
        ) {
            revert IHyperdriveFactory.InvalidPositionDuration();
        }

        // Ensure that the specified circuit breaker delta is within the minimum
        // and maximum circuit breaker deltas.
        if (
            _config.circuitBreakerDelta < minCircuitBreakerDelta ||
            _config.circuitBreakerDelta > maxCircuitBreakerDelta
        ) {
            revert IHyperdriveFactory.InvalidCircuitBreakerDelta();
        }

        // Ensure that the specified fees are within the minimum and maximum
        // fees. The flat fee is annualized so that it is consistent across all
        // term lengths.
        if (
            _config.fees.curve > _maxFees.curve ||
            // NOTE: Round up here to make the check stricter
            ///      since truthy values causes revert.
            _config.fees.flat.mulDivUp(365 days, _config.positionDuration) >
            _maxFees.flat ||
            _config.fees.governanceLP > _maxFees.governanceLP ||
            _config.fees.governanceZombie > _maxFees.governanceZombie ||
            _config.fees.curve < _minFees.curve ||
            // NOTE: Round down here to make the check stricter
            ///      since truthy values causes revert.
            _config.fees.flat.mulDivDown(365 days, _config.positionDuration) <
            _minFees.flat ||
            _config.fees.governanceLP < _minFees.governanceLP ||
            _config.fees.governanceZombie < _minFees.governanceZombie
        ) {
            revert IHyperdriveFactory.InvalidFees();
        }

        // Ensure that specified fixed APR is within the minimum and maximum
        // fixed APRs.
        if (_fixedAPR < minFixedAPR || _fixedAPR > maxFixedAPR) {
            revert IHyperdriveFactory.InvalidFixedAPR();
        }

        // Calculate the time stretch using the provided APR and ensure that
        // the time stretch falls within a safe range and the guards specified
        // by governance.
        uint256 lowerBound = _fixedAPR.divDown(2e18).max(0.005e18);
        if (
            _timeStretchAPR < minTimeStretchAPR.max(lowerBound) ||
            _timeStretchAPR >
            maxTimeStretchAPR.min(_fixedAPR.max(lowerBound).mulDown(2e18))
        ) {
            revert IHyperdriveFactory.InvalidTimeStretchAPR();
        }
        uint256 timeStretch = HyperdriveMath.calculateTimeStretch(
            _timeStretchAPR,
            _config.positionDuration
        );

        // Ensure that the linker factory, linker code hash, fee collector, and
        // governance addresses are set to the expected values. This ensures
        // that the deployer is aware of the correct values. The time stretch
        // should be set to zero to signal that the deployer is aware that it
        // will be overwritten.
        if (
            _config.linkerFactory != linkerFactory ||
            _config.linkerCodeHash != linkerCodeHash ||
            _config.feeCollector != feeCollector ||
            _config.sweepCollector != sweepCollector ||
            _config.checkpointRewarder != checkpointRewarder ||
            _config.governance != hyperdriveGovernance ||
            _config.timeStretch != 0
        ) {
            revert IHyperdriveFactory.InvalidDeployConfig();
        }

        // Override the config values to the default values set by governance.
        // The factory assumes the governance role during deployment so that it
        // can set up some initial values; however the governance role will
        // ultimately be transferred to the hyperdrive governance address.
        _config.governance = address(this);
        _config.timeStretch = timeStretch;
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

interface IERC20 {
    /// @notice Emitted when tokens are transferred from one account to another.
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when an owner changes the approval for a spender.
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /// @notice Updates the allowance of a spender on behalf of the sender.
    /// @param spender The account with the allowance.
    /// @param amount The new allowance of the spender.
    /// @return A flag indicating whether or not the approval succeeded.
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Transfers tokens from the sender's account to another account.
    /// @param to The recipient of the tokens.
    /// @param amount The amount of tokens that will be transferred.
    /// @return A flag indicating whether or not the transfer succeeded.
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice Transfers tokens from an owner to a recipient. This draws from
    ///         the sender's allowance.
    /// @param from The owner of the tokens.
    /// @param to The recipient of the tokens.
    /// @param amount The amount of tokens that will be transferred.
    /// @return A flag indicating whether or not the transfer succeeded.
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /// @notice Gets the token's name.
    /// @return The token's name.
    function name() external view returns (string memory);

    /// @notice Gets the token's symbol.
    /// @return The token's symbol.
    function symbol() external view returns (string memory);

    /// @notice Gets the token's decimals.
    /// @return The token's decimals.
    function decimals() external view returns (uint8);

    /// @notice Gets the token's total supply.
    /// @return The token's total supply.
    function totalSupply() external view returns (uint256);

    /// @notice Gets the allowance of a spender for an owner.
    /// @param owner The owner of the tokens.
    /// @param spender The spender of the tokens.
    /// @return The allowance of the spender for the owner.
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /// @notice Gets the balance of an account.
    /// @param account The owner of the tokens.
    /// @return The account's balance.
    function balanceOf(address account) external view returns (uint256);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IERC20 } from "./IERC20.sol";
import { IHyperdriveCore } from "./IHyperdriveCore.sol";
import { IHyperdriveEvents } from "./IHyperdriveEvents.sol";
import { IHyperdriveRead } from "./IHyperdriveRead.sol";
import { IMultiToken } from "./IMultiToken.sol";

interface IHyperdrive is
    IHyperdriveEvents,
    IHyperdriveRead,
    IHyperdriveCore,
    IMultiToken
{
    /// Structs ///

    struct MarketState {
        /// @dev The pool's share reserves.
        uint128 shareReserves;
        /// @dev The pool's bond reserves.
        uint128 bondReserves;
        /// @dev The global exposure of the pool due to open longs
        uint128 longExposure;
        /// @dev The amount of longs that are still open.
        uint128 longsOutstanding;
        /// @dev The net amount of shares that have been added and removed from
        ///      the share reserves due to flat updates.
        int128 shareAdjustment;
        /// @dev The amount of shorts that are still open.
        uint128 shortsOutstanding;
        /// @dev The average maturity time of outstanding long positions.
        uint128 longAverageMaturityTime;
        /// @dev The average maturity time of outstanding short positions.
        uint128 shortAverageMaturityTime;
        /// @dev A flag indicating whether or not the pool has been initialized.
        bool isInitialized;
        /// @dev A flag indicating whether or not the pool is paused.
        bool isPaused;
        /// @dev The proceeds in base of the unredeemed matured positions.
        uint112 zombieBaseProceeds;
        /// @dev The shares reserved for unredeemed matured positions.
        uint128 zombieShareReserves;
    }

    struct Checkpoint {
        /// @dev The time-weighted average spot price of the checkpoint. This is
        ///      used to implement circuit-breakers that prevents liquidity from
        ///      being added when the pool's rate moves too quickly.
        uint128 weightedSpotPrice;
        /// @dev The last time the weighted spot price was updated.
        uint128 lastWeightedSpotPriceUpdateTime;
        /// @dev The vault share price during the first transaction in the
        ///      checkpoint. This is used to track the amount of interest
        ///      accrued by shorts as well as the vault share price at closing
        ///      of matured longs and shorts.
        uint128 vaultSharePrice;
    }

    struct WithdrawPool {
        /// @dev The amount of withdrawal shares that are ready to be redeemed.
        uint128 readyToWithdraw;
        /// @dev The proceeds recovered by the withdrawal pool.
        uint128 proceeds;
    }

    struct Fees {
        /// @dev The LP fee applied to the curve portion of a trade.
        uint256 curve;
        /// @dev The LP fee applied to the flat portion of a trade.
        uint256 flat;
        /// @dev The portion of the LP fee that goes to governance.
        uint256 governanceLP;
        /// @dev The portion of the zombie interest that goes to governance.
        uint256 governanceZombie;
    }

    struct PoolDeployConfig {
        /// @dev The address of the base token.
        IERC20 baseToken;
        /// @dev The address of the vault shares token.
        IERC20 vaultSharesToken;
        /// @dev The linker factory used by this Hyperdrive instance.
        address linkerFactory;
        /// @dev The hash of the ERC20 linker's code. This is used to derive the
        ///      create2 addresses of the ERC20 linkers used by this instance.
        bytes32 linkerCodeHash;
        /// @dev The minimum share reserves.
        uint256 minimumShareReserves;
        /// @dev The minimum amount of tokens that a position can be opened or
        ///      closed with.
        uint256 minimumTransactionAmount;
        /// @dev The maximum delta between the last checkpoint's weighted spot
        ///      APR and the current spot APR for an LP to add liquidity. This
        ///      protects LPs from sandwich attacks.
        uint256 circuitBreakerDelta;
        /// @dev The duration of a position prior to maturity.
        uint256 positionDuration;
        /// @dev The duration of a checkpoint.
        uint256 checkpointDuration;
        /// @dev A parameter which decreases slippage around a target rate.
        uint256 timeStretch;
        /// @dev The address of the governance contract.
        address governance;
        /// @dev The address which collects governance fees
        address feeCollector;
        /// @dev The address which collects swept tokens.
        address sweepCollector;
        /// @dev The address that will reward checkpoint minters.
        address checkpointRewarder;
        /// @dev The fees applied to trades.
        IHyperdrive.Fees fees;
    }

    struct PoolConfig {
        /// @dev The address of the base token.
        IERC20 baseToken;
        /// @dev The address of the vault shares token.
        IERC20 vaultSharesToken;
        /// @dev The linker factory used by this Hyperdrive instance.
        address linkerFactory;
        /// @dev The hash of the ERC20 linker's code. This is used to derive the
        ///      create2 addresses of the ERC20 linkers used by this instance.
        bytes32 linkerCodeHash;
        /// @dev The initial vault share price.
        uint256 initialVaultSharePrice;
        /// @dev The minimum share reserves.
        uint256 minimumShareReserves;
        /// @dev The minimum amount of tokens that a position can be opened or
        ///      closed with.
        uint256 minimumTransactionAmount;
        /// @dev The maximum delta between the last checkpoint's weighted spot
        ///      APR and the current spot APR for an LP to add liquidity. This
        ///      protects LPs from sandwich attacks.
        uint256 circuitBreakerDelta;
        /// @dev The duration of a position prior to maturity.
        uint256 positionDuration;
        /// @dev The duration of a checkpoint.
        uint256 checkpointDuration;
        /// @dev A parameter which decreases slippage around a target rate.
        uint256 timeStretch;
        /// @dev The address of the governance contract.
        address governance;
        /// @dev The address which collects governance fees
        address feeCollector;
        /// @dev The address which collects swept tokens.
        address sweepCollector;
        /// @dev The address that will reward checkpoint minters.
        address checkpointRewarder;
        /// @dev The fees applied to trades.
        IHyperdrive.Fees fees;
    }

    struct PoolInfo {
        /// @dev The reserves of shares held by the pool.
        uint256 shareReserves;
        /// @dev The adjustment applied to the share reserves when pricing
        ///      bonds. This is used to ensure that the pricing mechanism is
        ///      held invariant under flat updates for security reasons.
        int256 shareAdjustment;
        /// @dev The proceeds in base of the unredeemed matured positions.
        uint256 zombieBaseProceeds;
        /// @dev The shares reserved for unredeemed matured positions.
        uint256 zombieShareReserves;
        /// @dev The reserves of bonds held by the pool.
        uint256 bondReserves;
        /// @dev The total supply of LP shares.
        uint256 lpTotalSupply;
        /// @dev The current vault share price.
        uint256 vaultSharePrice;
        /// @dev An amount of bonds representing outstanding unmatured longs.
        uint256 longsOutstanding;
        /// @dev The average maturity time of the outstanding longs.
        uint256 longAverageMaturityTime;
        /// @dev An amount of bonds representing outstanding unmatured shorts.
        uint256 shortsOutstanding;
        /// @dev The average maturity time of the outstanding shorts.
        uint256 shortAverageMaturityTime;
        /// @dev The amount of withdrawal shares that are ready to be redeemed.
        uint256 withdrawalSharesReadyToWithdraw;
        /// @dev The proceeds recovered by the withdrawal pool.
        uint256 withdrawalSharesProceeds;
        /// @dev The share price of LP shares. This can be used to mark LP
        ///      shares to market.
        uint256 lpSharePrice;
        /// @dev The global exposure of the pool due to open positions
        uint256 longExposure;
    }

    struct Options {
        /// @dev The address that receives the proceeds of a trade or LP action.
        address destination;
        /// @dev A boolean indicating that the trade or LP action should be
        ///      settled in base if true and in the yield source shares if false.
        bool asBase;
        /// @dev Additional data that can be used to implement custom logic in
        ///      implementation contracts.
        bytes extraData;
    }

    /// Errors ///

    /// @notice Thrown when the inputs to a batch transfer don't match in
    ///         length.
    error BatchInputLengthMismatch();

    /// @notice Thrown when the initializer doesn't provide sufficient liquidity
    ///         to cover the minimum share reserves and the LP shares that are
    ///         burned on initialization.
    error BelowMinimumContribution();

    /// @notice Thrown when the add liquidity circuit breaker is triggered.
    error CircuitBreakerTriggered();

    /// @notice Thrown when the exponent to `FixedPointMath.exp` would cause the
    ///         the result to be larger than the representable scale.
    error ExpInvalidExponent();

    /// @notice Thrown when a permit signature is expired.
    error ExpiredDeadline();

    /// @notice Thrown when a user doesn't have a sufficient balance to perform
    ///         an action.
    error InsufficientBalance();

    /// @notice Thrown when the pool doesn't have sufficient liquidity to
    ///         complete the trade.
    error InsufficientLiquidity();

    /// @notice Thrown when the pool's APR is outside the bounds specified by
    ///         a LP when they are adding liquidity.
    error InvalidApr();

    /// @notice Thrown when the checkpoint time provided to `checkpoint` is
    ///         larger than the current checkpoint or isn't divisible by the
    ///         checkpoint duration.
    error InvalidCheckpointTime();

    /// @notice Thrown when the effective share reserves don't exceed the
    ///         minimum share reserves when the pool is initialized.
    error InvalidEffectiveShareReserves();

    /// @notice Thrown when the caller of one of MultiToken's bridge-only
    ///         functions is not the corresponding bridge.
    error InvalidERC20Bridge();

    /// @notice Thrown when a destination other than the fee collector is
    ///         specified in `collectGovernanceFee`.
    error InvalidFeeDestination();

    /// @notice Thrown when the initial share price doesn't match the share
    ///         price of the underlying yield source on deployment.
    error InvalidInitialVaultSharePrice();

    /// @notice Thrown when the LP share price couldn't be calculated in a
    ///         critical situation.
    error InvalidLPSharePrice();

    /// @notice Thrown when the present value calculation fails.
    error InvalidPresentValue();

    /// @notice Thrown when an invalid signature is used provide permit access
    ///         to the MultiToken. A signature is considered to be invalid if
    ///         it fails to recover to the owner's address.
    error InvalidSignature();

    /// @notice Thrown when the timestamp used to construct an asset ID exceeds
    ///         the uint248 scale.
    error InvalidTimestamp();

    /// @notice Thrown when the input to `FixedPointMath.ln` is less than or
    ///         equal to zero.
    error LnInvalidInput();

    /// @notice Thrown when vault share price is smaller than the minimum share
    ///         price. This protects traders from unknowingly opening a long or
    ///         short after negative interest has accrued.
    error MinimumSharePrice();

    /// @notice Thrown when the input or output amount of a trade is smaller
    ///         than the minimum transaction amount. This protects traders and
    ///         LPs from losses of precision that can occur at small scales.
    error MinimumTransactionAmount();

    /// @notice Thrown when the present value prior to adding liquidity results in a
    ///         decrease in present value after liquidity. This is caused by a
    ///         shortage in liquidity that prevents all the open positions being
    ///         closed on the curve and therefore marked to 1.
    error DecreasedPresentValueWhenAddingLiquidity();

    /// @notice Thrown when ether is sent to an instance that doesn't accept
    ///         ether as a deposit asset.
    error NotPayable();

    /// @notice Thrown when a slippage guard is violated.
    error OutputLimit();

    /// @notice Thrown when the pool is already initialized and a trader calls
    ///         `initialize`. This prevents the pool from being reinitialized
    ///         after it has been initialized.
    error PoolAlreadyInitialized();

    /// @notice Thrown when the pool is paused and a trader tries to add
    ///         liquidity, open a long, or open a short. Traders can still
    ///         close their existing positions while the pool is paused.
    error PoolIsPaused();

    /// @notice Thrown when the owner passed to permit is the zero address. This
    ///         prevents users from spending the funds in address zero by
    ///         sending an invalid signature to ecrecover.
    error RestrictedZeroAddress();

    /// @notice Thrown by a read-only function called by the proxy. Unlike a
    ///         normal error, this error actually indicates that a read-only
    ///         call succeeded. The data that it wraps is the return data from
    ///         the read-only call.
    error ReturnData(bytes data);

    /// @notice Thrown when an asset is swept from the pool and one of the
    ///         pool's depository assets changes.
    error SweepFailed();

    /// @notice Thrown when the distribute excess idle calculation fails due
    ///         to the starting present value calculation failing.
    error DistributeExcessIdleFailed();

    /// @notice Thrown when an ether transfer fails.
    error TransferFailed();

    /// @notice Thrown when an unauthorized user attempts to access admin
    ///         functionality.
    error Unauthorized();

    /// @notice Thrown when a read-only call succeeds. The proxy architecture
    ///         uses a force-revert delegatecall pattern to ensure that calls
    ///         that are intended to be read-only are actually read-only.
    error UnexpectedSuccess();

    /// @notice Thrown when casting a value to a uint112 that is outside of the
    ///         uint128 scale.
    error UnsafeCastToUint112();

    /// @notice Thrown when casting a value to a uint128 that is outside of the
    ///         uint128 scale.
    error UnsafeCastToUint128();

    /// @notice Thrown when casting a value to a int128 that is outside of the
    ///         int128 scale.
    error UnsafeCastToInt128();

    /// @notice Thrown when casting a value to a int256 that is outside of the
    ///         int256 scale.
    error UnsafeCastToInt256();

    /// @notice Thrown when an unsupported option is passed to a function or
    ///         a user attempts to sweep an invalid token. The options and sweep
    ///         targets that are supported vary between instances.
    error UnsupportedToken();

    /// @notice Thrown when `LPMath.calculateUpdateLiquidity` fails.
    error UpdateLiquidityFailed();

    /// Getters ///

    /// @notice Gets the target0 address.
    /// @return The target0 address.
    function target0() external view returns (address);

    /// @notice Gets the target1 address.
    /// @return The target1 address.
    function target1() external view returns (address);

    /// @notice Gets the target2 address.
    /// @return The target2 address.
    function target2() external view returns (address);

    /// @notice Gets the target3 address.
    /// @return The target3 address.
    function target3() external view returns (address);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IERC20 } from "./IERC20.sol";
import { IHyperdrive } from "./IHyperdrive.sol";
import { IMultiTokenCore } from "./IMultiTokenCore.sol";

interface IHyperdriveCore is IMultiTokenCore {
    /// Longs ///

    /// @notice Opens a long position.
    /// @param _amount The amount of capital provided to open the long. The
    ///        units of this quantity are either base or vault shares, depending
    ///        on the value of `_options.asBase`.
    /// @param _minOutput The minimum number of bonds to receive.
    /// @param _minVaultSharePrice The minimum vault share price at which to
    ///        open the long. This allows traders to protect themselves from
    ///        opening a long in a checkpoint where negative interest has
    ///        accrued.
    /// @param _options The options that configure how the trade is settled.
    /// @return maturityTime The maturity time of the bonds.
    /// @return bondProceeds The amount of bonds the user received.
    function openLong(
        uint256 _amount,
        uint256 _minOutput,
        uint256 _minVaultSharePrice,
        IHyperdrive.Options calldata _options
    ) external payable returns (uint256 maturityTime, uint256 bondProceeds);

    /// @notice Closes a long position with a specified maturity time.
    /// @param _maturityTime The maturity time of the long.
    /// @param _bondAmount The amount of longs to close.
    /// @param _minOutput The minimum proceeds the trader will accept. The units
    ///        of this quantity are either base or vault shares, depending on
    ///        the value of `_options.asBase`.
    /// @param _options The options that configure how the trade is settled.
    /// @return proceeds The proceeds the user receives. The units of this
    ///         quantity are either base or vault shares, depending on the value
    ///         of `_options.asBase`.
    function closeLong(
        uint256 _maturityTime,
        uint256 _bondAmount,
        uint256 _minOutput,
        IHyperdrive.Options calldata _options
    ) external returns (uint256 proceeds);

    /// Shorts ///

    /// @notice Opens a short position.
    /// @param _bondAmount The amount of bonds to short.
    /// @param _maxDeposit The most the user expects to deposit for this trade.
    ///        The units of this quantity are either base or vault shares,
    ///        depending on the value of `_options.asBase`.
    /// @param _minVaultSharePrice The minimum vault share price at which to open
    ///        the short. This allows traders to protect themselves from opening
    ///        a short in a checkpoint where negative interest has accrued.
    /// @param _options The options that configure how the trade is settled.
    /// @return maturityTime The maturity time of the short.
    /// @return deposit The amount the user deposited for this trade. The units
    ///         of this quantity are either base or vault shares, depending on
    ///         the value of `_options.asBase`.
    function openShort(
        uint256 _bondAmount,
        uint256 _maxDeposit,
        uint256 _minVaultSharePrice,
        IHyperdrive.Options calldata _options
    ) external payable returns (uint256 maturityTime, uint256 deposit);

    /// @notice Closes a short position with a specified maturity time.
    /// @param _maturityTime The maturity time of the short.
    /// @param _bondAmount The amount of shorts to close.
    /// @param _minOutput The minimum output of this trade. The units of this
    ///        quantity are either base or vault shares, depending on the value
    ///        of `_options.asBase`.
    /// @param _options The options that configure how the trade is settled.
    /// @return proceeds The proceeds of closing this short. The units of this
    ///         quantity are either base or vault shares, depending on the value
    ///         of `_options.asBase`.
    function closeShort(
        uint256 _maturityTime,
        uint256 _bondAmount,
        uint256 _minOutput,
        IHyperdrive.Options calldata _options
    ) external returns (uint256 proceeds);

    /// LPs ///

    /// @notice Allows the first LP to initialize the market with a target APR.
    /// @param _contribution The amount of capital to supply. The units of this
    ///        quantity are either base or vault shares, depending on the value
    ///        of `_options.asBase`.
    /// @param _apr The target APR.
    /// @param _options The options that configure how the operation is settled.
    /// @return lpShares The initial number of LP shares created.
    function initialize(
        uint256 _contribution,
        uint256 _apr,
        IHyperdrive.Options calldata _options
    ) external payable returns (uint256 lpShares);

    /// @notice Allows LPs to supply liquidity for LP shares.
    /// @param _contribution The amount of capital to supply. The units of this
    ///        quantity are either base or vault shares, depending on the value
    ///        of `_options.asBase`.
    /// @param _minLpSharePrice The minimum LP share price the LP is willing
    ///        to accept for their shares. LPs incur negative slippage when
    ///        adding liquidity if there is a net curve position in the market,
    ///        so this allows LPs to protect themselves from high levels of
    ///        slippage. The units of this quantity are either base or vault
    ///        shares, depending on the value of `_options.asBase`.
    /// @param _minApr The minimum APR at which the LP is willing to supply.
    /// @param _maxApr The maximum APR at which the LP is willing to supply.
    /// @param _options The options that configure how the operation is settled.
    /// @return lpShares The LP shares received by the LP.
    function addLiquidity(
        uint256 _contribution,
        uint256 _minLpSharePrice,
        uint256 _minApr,
        uint256 _maxApr,
        IHyperdrive.Options calldata _options
    ) external payable returns (uint256 lpShares);

    /// @notice Allows an LP to burn shares and withdraw from the pool.
    /// @param _lpShares The LP shares to burn.
    /// @param _minOutputPerShare The minimum amount the LP expects to receive
    ///        for each withdrawal share that is burned. The units of this
    ///        quantity are either base or vault shares, depending on the value
    ///        of `_options.asBase`.
    /// @param _options The options that configure how the operation is settled.
    /// @return proceeds The amount the LP removing liquidity receives. The
    ///         units of this quantity are either base or vault shares,
    ///         depending on the value of `_options.asBase`.
    /// @return withdrawalShares The base that the LP receives buys out some of
    ///         their LP shares, but it may not be sufficient to fully buy the
    ///         LP out. In this case, the LP receives withdrawal shares equal in
    ///         value to the present value they are owed. As idle capital
    ///         becomes available, the pool will buy back these shares.
    function removeLiquidity(
        uint256 _lpShares,
        uint256 _minOutputPerShare,
        IHyperdrive.Options calldata _options
    ) external returns (uint256 proceeds, uint256 withdrawalShares);

    /// @notice Redeems withdrawal shares by giving the LP a pro-rata amount of
    ///         the withdrawal pool's proceeds. This function redeems the
    ///         maximum amount of the specified withdrawal shares given the
    ///         amount of withdrawal shares ready to withdraw.
    /// @param _withdrawalShares The withdrawal shares to redeem.
    /// @param _minOutputPerShare The minimum amount the LP expects to
    ///        receive for each withdrawal share that is burned. The units of
    ///        this quantity are either base or vault shares, depending on the
    ///        value of `_options.asBase`.
    /// @param _options The options that configure how the operation is settled.
    /// @return proceeds The amount the LP received. The units of this quantity
    ///         are either base or vault shares, depending on the value of
    ///         `_options.asBase`.
    /// @return withdrawalSharesRedeemed The amount of withdrawal shares that
    ///         were redeemed.
    function redeemWithdrawalShares(
        uint256 _withdrawalShares,
        uint256 _minOutputPerShare,
        IHyperdrive.Options calldata _options
    ) external returns (uint256 proceeds, uint256 withdrawalSharesRedeemed);

    /// Checkpoints ///

    /// @notice Attempts to mint a checkpoint with the specified checkpoint time.
    /// @param _checkpointTime The time of the checkpoint to create.
    /// @param _maxIterations The number of iterations to use in the Newton's
    ///        method component of `_distributeExcessIdleSafe`. This defaults to
    ///        `LPMath.SHARE_PROCEEDS_MAX_ITERATIONS` if the specified value is
    ///        smaller than the constant.
    function checkpoint(
        uint256 _checkpointTime,
        uint256 _maxIterations
    ) external;

    /// Admin ///

    /// @notice This function collects the governance fees accrued by the pool.
    /// @param _options The options that configure how the fees are settled.
    /// @return proceeds The governance fees collected. The units of this
    ///         quantity are either base or vault shares, depending on the value
    ///         of `_options.asBase`.
    function collectGovernanceFee(
        IHyperdrive.Options calldata _options
    ) external returns (uint256 proceeds);

    /// @notice Allows an authorized address to pause this contract.
    /// @param _status True to pause all deposits and false to unpause them.
    function pause(bool _status) external;

    /// @notice Allows governance to transfer the fee collector role.
    /// @param _who The new fee collector address.
    function setFeeCollector(address _who) external;

    /// @notice Allows governance to transfer the sweep collector role.
    /// @param _who The new sweep collector address.
    function setSweepCollector(address _who) external;

    /// @dev Allows governance to transfer the checkpoint rewarder.
    /// @param _checkpointRewarder The new checkpoint rewarder.
    function setCheckpointRewarder(address _checkpointRewarder) external;

    /// @notice Allows governance to transfer the governance role.
    /// @param _who The new governance address.
    function setGovernance(address _who) external;

    /// @notice Allows governance to change the pauser status of an address.
    /// @param who The address to change.
    /// @param status The new pauser status.
    function setPauser(address who, bool status) external;

    /// @notice Transfers the contract's balance of a target token to the fee
    ///         collector address.
    /// @dev WARN: It is unlikely but possible that there is a selector overlap
    ///      with 'transferFrom'. Any integrating contracts should be checked
    ///      for that, as it may result in an unexpected call from this address.
    /// @param _target The target token to sweep.
    function sweep(IERC20 _target) external;
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IHyperdrive } from "./IHyperdrive.sol";

interface IHyperdriveDeployerCoordinator {
    /// Errors ///

    /// @notice Thrown when a user attempts to deploy target0 the deployment has
    ///         already been created.
    error DeploymentAlreadyExists();

    /// @notice Thrown when a user attempts to deploy a contract that requires
    ///         the deployment to be created and the deployment doesn't exist.
    error DeploymentDoesNotExist();

    /// @notice Thrown when a user attempts to deploy a Hyperdrive entrypoint
    ///         without first deploying the required targets.
    error IncompleteDeployment();

    /// @notice Thrown when a user attempts to deploy a hyperdrive contract
    ///         after it has already been deployed.
    error HyperdriveAlreadyDeployed();

    /// @notice Thrown when a user attempts to initialize a hyperdrive contract
    ///         before is has been deployed.
    error HyperdriveIsNotDeployed();

    /// @notice Thrown when a deployer provides an insufficient amount of base
    ///         to initialize a payable Hyperdrive instance.
    error InsufficientValue();

    /// @notice Thrown when the base token isn't valid. Each instance will have
    ///         different criteria for what constitutes a valid base token.
    error InvalidBaseToken();

    /// @notice Thrown when the vault shares token isn't valid. Each instance
    ///         will have different criteria for what constitutes a valid base
    ///         token.
    error InvalidVaultSharesToken();

    /// @notice Thrown when the checkpoint duration specified is zero.
    error InvalidCheckpointDuration();

    /// @notice Thrown when the curve fee, flat fee, governance LP fee, or
    ///         governance zombie fee is greater than 100%.
    error InvalidFeeAmounts();

    /// @notice Thrown when the minimum share reserves is too small. The
    ///         absolute smallest allowable minimum share reserves is 1e3;
    ///         however, yield sources may require a larger minimum share
    ///         reserves.
    error InvalidMinimumShareReserves();

    /// @notice Thrown when the minimum transaction amount is too small.
    error InvalidMinimumTransactionAmount();

    /// @notice Thrown when the position duration is smaller than the checkpoint
    ///         duration or is not a multiple of the checkpoint duration.
    error InvalidPositionDuration();

    /// @notice Thrown when a user attempts to deploy a target using a target
    ///         index that is outside of the accepted range.
    error InvalidTargetIndex();

    /// @notice Thrown when a user attempts to deploy a contract in an existing
    ///         deployment with a config that doesn't match the deployment's
    ///         config hash.
    error MismatchedConfig();

    /// @notice Thrown when a user attempts to deploy a contract in an existing
    ///         deployment with extra data that doesn't match the deployment's
    ///         extra data hash.
    error MismatchedExtraData();

    /// @notice Thrown when ether is sent to an instance that doesn't accept
    ///         ether as a deposit asset.
    error NotPayable();

    /// @notice Thrown when the sender of a `deploy`, `deployTarget`, or
    ///         `initialize` transaction isn't the associated factory.
    error SenderIsNotFactory();

    /// @notice Thrown when a user attempts to deploy a target contract after
    ///         it has already been deployed.
    error TargetAlreadyDeployed();

    /// @notice Thrown when an ether transfer fails.
    error TransferFailed();

    /// Functions ///

    /// @notice Returns the deployer coordinator's name.
    /// @return The deployer coordinator's name.
    function name() external view returns (string memory);

    /// @notice Returns the deployer coordinator's kind.
    /// @return The deployer coordinator's kind.
    function kind() external pure returns (string memory);

    /// @notice Returns the deployer coordinator's version.
    /// @return The deployer coordinator's version.
    function version() external pure returns (string memory);

    /// @notice Deploys a Hyperdrive instance with the given parameters.
    /// @param _deploymentId The ID of the deployment.
    /// @param __name The name of the Hyperdrive pool.
    /// @param _deployConfig The deploy configuration of the Hyperdrive pool.
    /// @param _extraData The extra data that contains the pool and sweep targets.
    /// @param _salt The create2 salt used to deploy Hyperdrive.
    /// @return The address of the newly deployed Hyperdrive instance.
    function deployHyperdrive(
        bytes32 _deploymentId,
        string memory __name,
        IHyperdrive.PoolDeployConfig memory _deployConfig,
        bytes memory _extraData,
        bytes32 _salt
    ) external returns (address);

    /// @notice Deploys a Hyperdrive target instance with the given parameters.
    /// @dev As a convention, target0 must be deployed first. After this, the
    ///      targets can be deployed in any order.
    /// @param _deploymentId The ID of the deployment.
    /// @param _deployConfig The deploy configuration of the Hyperdrive pool.
    /// @param _extraData The extra data that contains the pool and sweep targets.
    /// @param _targetIndex The index of the target to deploy.
    /// @param _salt The create2 salt used to deploy the target.
    /// @return target The address of the newly deployed target instance.
    function deployTarget(
        bytes32 _deploymentId,
        IHyperdrive.PoolDeployConfig memory _deployConfig,
        bytes memory _extraData,
        uint256 _targetIndex,
        bytes32 _salt
    ) external returns (address);

    /// @notice Initializes a pool that was deployed by this coordinator.
    /// @dev This function utilizes several helper functions that provide
    ///      flexibility to implementations.
    /// @param _deploymentId The ID of the deployment.
    /// @param _lp The LP that is initializing the pool.
    /// @param _contribution The amount of capital to supply. The units of this
    ///        quantity are either base or vault shares, depending on the value
    ///        of `_options.asBase`.
    /// @param _apr The target APR.
    /// @param _options The options that configure how the initialization is
    ///        settled.
    /// @return lpShares The initial number of LP shares created.
    function initialize(
        bytes32 _deploymentId,
        address _lp,
        uint256 _contribution,
        uint256 _apr,
        IHyperdrive.Options memory _options
    ) external payable returns (uint256 lpShares);

    /// @notice Gets the number of targets that need to be deployed for a full
    ///         deployment.
    /// @return numTargets The number of targets that need to be deployed for a
    ///         full deployment.
    function getNumberOfTargets() external pure returns (uint256 numTargets);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IMultiTokenEvents } from "./IMultiTokenEvents.sol";

interface IHyperdriveEvents is IMultiTokenEvents {
    /// @notice Emitted when the Hyperdrive pool is initialized.
    event Initialize(
        address indexed provider,
        uint256 lpAmount,
        uint256 amount,
        uint256 vaultSharePrice,
        bool asBase,
        uint256 apr,
        bytes extraData
    );

    /// @notice Emitted when an LP adds liquidity to the Hyperdrive pool.
    event AddLiquidity(
        address indexed provider,
        uint256 lpAmount,
        uint256 amount,
        uint256 vaultSharePrice,
        bool asBase,
        uint256 lpSharePrice,
        bytes extraData
    );

    /// @notice Emitted when an LP removes liquidity from the Hyperdrive pool.
    event RemoveLiquidity(
        address indexed provider,
        address indexed destination,
        uint256 lpAmount,
        uint256 amount,
        uint256 vaultSharePrice,
        bool asBase,
        uint256 withdrawalShareAmount,
        uint256 lpSharePrice,
        bytes extraData
    );

    /// @notice Emitted when an LP redeems withdrawal shares.
    event RedeemWithdrawalShares(
        address indexed provider,
        address indexed destination,
        uint256 withdrawalShareAmount,
        uint256 amount,
        uint256 vaultSharePrice,
        bool asBase,
        bytes extraData
    );

    /// @notice Emitted when a long position is opened.
    event OpenLong(
        address indexed trader,
        uint256 indexed assetId,
        uint256 maturityTime,
        uint256 amount,
        uint256 vaultSharePrice,
        bool asBase,
        uint256 bondAmount,
        bytes extraData
    );

    /// @notice Emitted when a short position is opened.
    event OpenShort(
        address indexed trader,
        uint256 indexed assetId,
        uint256 maturityTime,
        uint256 amount,
        uint256 vaultSharePrice,
        bool asBase,
        uint256 baseProceeds,
        uint256 bondAmount,
        bytes extraData
    );

    /// @notice Emitted when a long position is closed.
    event CloseLong(
        address indexed trader,
        address indexed destination,
        uint256 indexed assetId,
        uint256 maturityTime,
        uint256 amount,
        uint256 vaultSharePrice,
        bool asBase,
        uint256 bondAmount,
        bytes extraData
    );

    /// @notice Emitted when a short position is closed.
    event CloseShort(
        address indexed trader,
        address indexed destination,
        uint256 indexed assetId,
        uint256 maturityTime,
        uint256 amount,
        uint256 vaultSharePrice,
        bool asBase,
        uint256 basePayment,
        uint256 bondAmount,
        bytes extraData
    );

    /// @notice Emitted when a checkpoint is created.
    event CreateCheckpoint(
        uint256 indexed checkpointTime,
        uint256 checkpointVaultSharePrice,
        uint256 vaultSharePrice,
        uint256 maturedShorts,
        uint256 maturedLongs,
        uint256 lpSharePrice
    );

    /// @notice Emitted when governance fees are collected.
    event CollectGovernanceFee(
        address indexed collector,
        uint256 amount,
        uint256 vaultSharePrice,
        bool asBase
    );

    /// @notice Emitted when the fee collector address is updated.
    event FeeCollectorUpdated(address indexed newFeeCollector);

    /// @notice Emitted when the sweep collector address is updated.
    event SweepCollectorUpdated(address indexed newSweepCollector);

    /// @notice Emitted when the checkpoint rewarder address is updated.
    event CheckpointRewarderUpdated(address indexed newCheckpointRewarder);

    /// @notice Emitted when the governance address is updated.
    event GovernanceUpdated(address indexed newGovernance);

    /// @notice Emitted when a pauser is updated.
    event PauserUpdated(address indexed newPauser, bool status);

    /// @notice Emitted when the pause status is updated.
    event PauseStatusUpdated(bool isPaused);

    /// @notice Emitted when tokens are swept.
    event Sweep(address indexed collector, address indexed target);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IHyperdrive } from "./IHyperdrive.sol";

interface IHyperdriveFactory {
    /// Events ///

    /// @notice Emitted when a Hyperdrive pool is deployed.
    event Deployed(
        address indexed deployerCoordinator,
        address hyperdrive,
        string name,
        IHyperdrive.PoolDeployConfig config,
        bytes extraData
    );

    /// @notice Emitted when a deployer coordinator is added.
    event DeployerCoordinatorAdded(address indexed deployerCoordinator);

    /// @notice Emitted when a deployer coordinator is removed.
    event DeployerCoordinatorRemoved(address indexed deployerCoordinator);

    /// @notice Emitted when the list of default pausers is updated.
    event DefaultPausersUpdated(address[] newDefaultPausers);

    /// @notice Emitted when the fee collector used in new deployments is updated.
    event FeeCollectorUpdated(address indexed newFeeCollector);

    /// @notice Emitted when the sweep collector used in new deployments is
    ///         updated.
    event SweepCollectorUpdated(address indexed newSweepCollector);

    /// @notice Emitted when the checkpoint rewarder used in new deployments is
    ///         updated.
    event CheckpointRewarderUpdated(address indexed newCheckpointRewarder);

    /// @notice Emitted when the factory's governance is updated.
    event GovernanceUpdated(address indexed governance);

    /// @notice Emitted when the deployer coordinator manager is updated.
    event DeployerCoordinatorManagerUpdated(
        address indexed deployerCoordinatorManager
    );

    /// @notice Emitted when the governance address used in new deployments is
    ///         updated.
    event HyperdriveGovernanceUpdated(address indexed hyperdriveGovernance);

    /// @notice Emitted when the linker factory used in new deployments is
    ///         updated.
    event LinkerFactoryUpdated(address indexed newLinkerFactory);

    /// @notice Emitted when the linker code hash used in new deployments is
    ///         updated.
    event LinkerCodeHashUpdated(bytes32 indexed newLinkerCodeHash);

    /// @notice Emitted when the checkpoint duration resolution is updated.
    event CheckpointDurationResolutionUpdated(
        uint256 newCheckpointDurationResolution
    );

    /// @notice Emitted when the maximum checkpoint duration is updated.
    event MaxCheckpointDurationUpdated(uint256 newMaxCheckpointDuration);

    /// @notice Emitted when the minimum checkpoint duration is updated.
    event MinCheckpointDurationUpdated(uint256 newMinCheckpointDuration);

    /// @notice Emitted when the maximum position duration is updated.
    event MaxPositionDurationUpdated(uint256 newMaxPositionDuration);

    /// @notice Emitted when the minimum position duration is updated.
    event MinPositionDurationUpdated(uint256 newMinPositionDuration);

    /// @notice Emitted when the maximum circuit breaker delta is updated.
    event MaxCircuitBreakerDeltaUpdated(uint256 newMaxCircuitBreakerDelta);

    /// @notice Emitted when the minimum circuit breaker delta is updated.
    event MinCircuitBreakerDeltaUpdated(uint256 newMinCircuitBreakerDelta);

    /// @notice Emitted when the maximum fixed APR is updated.
    event MaxFixedAPRUpdated(uint256 newMaxFixedAPR);

    /// @notice Emitted when the minimum fixed APR is updated.
    event MinFixedAPRUpdated(uint256 newMinFixedAPR);

    /// @notice Emitted when the maximum time stretch APR is updated.
    event MaxTimeStretchAPRUpdated(uint256 newMaxTimeStretchAPR);

    /// @notice Emitted when the minimum time stretch APR is updated.
    event MinTimeStretchAPRUpdated(uint256 newMinTimeStretchAPR);

    /// @notice Emitted when the maximum fees are updated.
    event MaxFeesUpdated(IHyperdrive.Fees newMaxFees);

    /// @notice Emitted when the minimum fees are updated.
    event MinFeesUpdated(IHyperdrive.Fees newMinFees);

    /// Errors ///

    /// @notice Thrown when governance attempts to add a deployer coordinator
    ///         that has already been added.
    error DeployerCoordinatorAlreadyAdded();

    /// @notice Thrown when governance attempts to remove a deployer coordinator
    ///         that was never added.
    error DeployerCoordinatorNotAdded();

    /// @notice Thrown when governance attempts to remove a deployer coordinator
    ///         but specifies the wrong index within the list of deployer
    ///         coordinators.
    error DeployerCoordinatorIndexMismatch();

    /// @notice Thrown when the ending index of a range is larger than the
    ///         underlying list.
    error EndIndexTooLarge();

    /// @notice Thrown when the checkpoint duration supplied to `deployTarget`
    ///         or `deployAndInitialize` isn't a multiple of the checkpoint
    ///         duration resolution or isn't within the range specified by the
    ///         minimum and maximum checkpoint durations.
    error InvalidCheckpointDuration();

    /// @notice Thrown when governance attempts to set the checkpoint duration
    ///         resolution to a value that doesn't evenly divide the minimum
    ///         checkpoint duration, maximum checkpoint duration, minimum
    ///         position duration, or maximum position duration.
    error InvalidCheckpointDurationResolution();

    /// @notice Thrown when the deploy configuration passed to
    ///         `deployAndInitialize` has fields set that will be overridden by
    ///         governance.
    error InvalidDeployConfig();

    /// @notice Thrown when the deployer coordinator passed to
    ///         `deployAndInitialize` hasn't been added to the factory.
    error InvalidDeployerCoordinator();

    /// @notice Thrown when the fee parameters passed to `deployAndInitialize`
    ///         aren't within the range specified by the minimum and maximum
    ///         fees.
    error InvalidFees();

    /// @notice Thrown when the starting index of a range is larger than the
    ///         ending index.
    error InvalidIndexes();

    /// @notice Thrown when governance attempts to set one of the maximum fee
    ///         parameters to a smaller value than the corresponding minimum fee
    ///         parameter.
    error InvalidMaxFees();

    /// @notice Thrown when governance attempts to set one of the minimum fee
    ///         parameters to a larger value than the corresponding maximum fee
    ///         parameter.
    error InvalidMinFees();

    /// @notice Thrown when governance attempts to set the maximum checkpoint
    ///         duration to a value that isn't a multiple of the checkpoint
    ///         duration resolution or is smaller than the minimum checkpoint
    ///         duration.
    error InvalidMaxCheckpointDuration();

    /// @notice Thrown when governance attempts to set the minimum checkpoint
    ///         duration to a value that isn't a multiple of the checkpoint
    ///         duration resolution or is larger than the maximum checkpoint
    ///         duration.
    error InvalidMinCheckpointDuration();

    /// @notice Thrown when governance attempts to set the maximum position
    ///         duration to a value that isn't a multiple of the checkpoint
    ///         duration resolution or is smaller than the minimum position
    ///         duration.
    error InvalidMaxPositionDuration();

    /// @notice Thrown when governance attempts to set the minimum position
    ///         duration to a value that isn't a multiple of the checkpoint
    ///         duration resolution or is larger than the maximum position
    ///         duration.
    error InvalidMinPositionDuration();

    /// @notice Thrown when the position duration passed to `deployAndInitialize`
    ///         doesn't fall within the range specified by the minimum and
    ///         maximum position durations.
    error InvalidPositionDuration();

    /// @notice Thrown when governance attempts to set the maximum circuit
    ///         breaker delta to a value that is less than the minimum
    ///         circuit breaker delta.
    error InvalidMaxCircuitBreakerDelta();

    /// @notice Thrown when governance attempts to set the minimum circuit
    ///         breaker delta to a value that is greater than the maximum
    ///         circuit breaker delta.
    error InvalidMinCircuitBreakerDelta();

    /// @notice Thrown when the circuit breaker delta passed to
    ///         `deployAndInitialize` doesn't fall within the range specified by
    ///         the minimum and maximum circuit breaker delta.
    error InvalidCircuitBreakerDelta();

    /// @notice Thrown when governance attempts to set the maximum fixed APR to
    ///         a value that is smaller than the minimum fixed APR.
    error InvalidMaxFixedAPR();

    /// @notice Thrown when governance attempts to set the minimum fixed APR to
    ///         a value that is larger than the maximum fixed APR.
    error InvalidMinFixedAPR();

    /// @notice Thrown when the fixed APR passed to `deployAndInitialize` isn't
    ///         within the range specified by the minimum and maximum fixed
    ///         APRs.
    error InvalidFixedAPR();

    /// @notice Thrown when governance attempts to set the maximum time stretch
    ///         APR to a value that is smaller than the minimum time stretch
    ///         APR.
    error InvalidMaxTimeStretchAPR();

    /// @notice Thrown when governance attempts to set the minimum time stretch
    ///         APR to a value that is larger than the maximum time stretch
    ///         APR.
    error InvalidMinTimeStretchAPR();

    /// @notice Thrown when a time stretch APR is passed to `deployAndInitialize`
    ///         that isn't within the range specified by the minimum and maximum
    ///         time stretch APRs or doesn't satisfy the lower and upper safe
    ///         bounds implied by the fixed APR.
    error InvalidTimeStretchAPR();

    /// @notice Thrown when ether is sent to the factory when `receive` is
    ///         locked.
    error ReceiveLocked();

    /// @notice Thrown when an ether transfer fails.
    error TransferFailed();

    /// @notice Thrown when an unauthorized caller attempts to update one of the
    ///         governance administered parameters.
    error Unauthorized();

    /// Functions ///

    /// @notice Allows governance to transfer the governance role.
    /// @param _governance The new governance address.
    function updateGovernance(address _governance) external;

    /// @notice Allows governance to change the hyperdrive governance address.
    /// @param _hyperdriveGovernance The new hyperdrive governance address.
    function updateHyperdriveGovernance(address _hyperdriveGovernance) external;

    /// @notice Allows governance to change the linker factory.
    /// @param _linkerFactory The new linker factory.
    function updateLinkerFactory(address _linkerFactory) external;

    /// @notice Allows governance to change the linker code hash. This allows
    ///         governance to update the implementation of the ERC20Forwarder.
    /// @param _linkerCodeHash The new linker code hash.
    function updateLinkerCodeHash(bytes32 _linkerCodeHash) external;

    /// @notice Allows governance to change the fee collector address.
    /// @param _feeCollector The new fee collector address.
    function updateFeeCollector(address _feeCollector) external;

    /// @notice Allows governance to change the sweep collector address.
    /// @param _sweepCollector The new sweep collector address.
    function updateSweepCollector(address _sweepCollector) external;

    /// @notice Allows governance to change the checkpoint rewarder address.
    /// @param _checkpointRewarder The new checkpoint rewarder address.
    function updateCheckpointRewarder(address _checkpointRewarder) external;

    /// @notice Allows governance to change the checkpoint duration resolution.
    /// @param _checkpointDurationResolution The new checkpoint duration
    ///        resolution.
    function updateCheckpointDurationResolution(
        uint256 _checkpointDurationResolution
    ) external;

    /// @notice Allows governance to update the maximum checkpoint duration.
    /// @param _maxCheckpointDuration The new maximum checkpoint duration.
    function updateMaxCheckpointDuration(
        uint256 _maxCheckpointDuration
    ) external;

    /// @notice Allows governance to update the minimum checkpoint duration.
    /// @param _minCheckpointDuration The new minimum checkpoint duration.
    function updateMinCheckpointDuration(
        uint256 _minCheckpointDuration
    ) external;

    /// @notice Allows governance to update the maximum position duration.
    /// @param _maxPositionDuration The new maximum position duration.
    function updateMaxPositionDuration(uint256 _maxPositionDuration) external;

    /// @notice Allows governance to update the minimum position duration.
    /// @param _minPositionDuration The new minimum position duration.
    function updateMinPositionDuration(uint256 _minPositionDuration) external;

    /// @notice Allows governance to update the maximum fixed APR.
    /// @param _maxFixedAPR The new maximum fixed APR.
    function updateMaxFixedAPR(uint256 _maxFixedAPR) external;

    /// @notice Allows governance to update the minimum fixed APR.
    /// @param _minFixedAPR The new minimum fixed APR.
    function updateMinFixedAPR(uint256 _minFixedAPR) external;

    /// @notice Allows governance to update the maximum time stretch APR.
    /// @param _maxTimeStretchAPR The new maximum time stretch APR.
    function updateMaxTimeStretchAPR(uint256 _maxTimeStretchAPR) external;

    /// @notice Allows governance to update the minimum time stretch APR.
    /// @param _minTimeStretchAPR The new minimum time stretch APR.
    function updateMinTimeStretchAPR(uint256 _minTimeStretchAPR) external;

    /// @notice Allows governance to update the maximum fee parameters.
    /// @param __maxFees The new maximum fee parameters.
    function updateMaxFees(IHyperdrive.Fees calldata __maxFees) external;

    /// @notice Allows governance to update the minimum fee parameters.
    /// @param __minFees The new minimum fee parameters.
    function updateMinFees(IHyperdrive.Fees calldata __minFees) external;

    /// @notice Allows governance to change the default pausers.
    /// @param _defaultPausers_ The new list of default pausers.
    function updateDefaultPausers(address[] calldata _defaultPausers_) external;

    /// @notice Allows governance to add a new deployer coordinator.
    /// @param _deployerCoordinator The new deployer coordinator.
    function addDeployerCoordinator(address _deployerCoordinator) external;

    /// @notice Allows governance to remove an existing deployer coordinator.
    /// @param _deployerCoordinator The deployer coordinator to remove.
    /// @param _index The index of the deployer coordinator to remove.
    function removeDeployerCoordinator(
        address _deployerCoordinator,
        uint256 _index
    ) external;

    /// @notice Deploys a Hyperdrive instance with the factory's configuration.
    /// @dev This function is declared as payable to allow payable overrides
    ///      to accept ether on initialization, but payability is not supported
    ///      by default.
    /// @param _deploymentId The deployment ID to use when deploying the pool.
    /// @param _deployerCoordinator The deployer coordinator to use in this
    ///        deployment.
    /// @param __name The name of the Hyperdrive pool.
    /// @param _config The configuration of the Hyperdrive pool.
    /// @param _extraData The extra data that contains data necessary for the
    ///        specific deployer.
    /// @param _contribution The contribution amount in base to the pool.
    /// @param _fixedAPR The fixed APR used to initialize the pool.
    /// @param _timeStretchAPR The time stretch APR used to initialize the pool.
    /// @param _options The options for the `initialize` call.
    /// @param _salt The create2 salt to use for the deployment.
    /// @return The hyperdrive address deployed.
    function deployAndInitialize(
        bytes32 _deploymentId,
        address _deployerCoordinator,
        string memory __name,
        IHyperdrive.PoolDeployConfig memory _config,
        bytes memory _extraData,
        uint256 _contribution,
        uint256 _fixedAPR,
        uint256 _timeStretchAPR,
        IHyperdrive.Options memory _options,
        bytes32 _salt
    ) external payable returns (IHyperdrive);

    /// @notice Deploys a Hyperdrive target with the factory's configuration.
    /// @param _deploymentId The deployment ID to use when deploying the pool.
    /// @param _deployerCoordinator The deployer coordinator to use in this
    ///        deployment.
    /// @param _config The configuration of the Hyperdrive pool.
    /// @param _extraData The extra data that contains data necessary for the
    ///        specific deployer.
    /// @param _fixedAPR The fixed APR used to initialize the pool.
    /// @param _timeStretchAPR The time stretch APR used to initialize the pool.
    /// @param _targetIndex The index of the target to deploy.
    /// @param _salt The create2 salt to use for the deployment.
    /// @return The target address deployed.
    function deployTarget(
        bytes32 _deploymentId,
        address _deployerCoordinator,
        IHyperdrive.PoolDeployConfig memory _config,
        bytes memory _extraData,
        uint256 _fixedAPR,
        uint256 _timeStretchAPR,
        uint256 _targetIndex,
        bytes32 _salt
    ) external returns (address);

    /// Getters ///

    /// @notice Gets the factory's name.
    /// @return The factory's name.
    function name() external view returns (string memory);

    /// @notice Gets the factory's kind.
    /// @return The factory's kind.
    function kind() external pure returns (string memory);

    /// @notice Gets the factory's version.
    /// @return The factory's version.
    function version() external pure returns (string memory);

    /// @notice Returns the governance address that updates the factory's
    ///         configuration.
    /// @return The factory's governance address.
    function governance() external view returns (address);

    /// @notice Returns the deployer coordinator manager address that can add or
    ///         remove deployer coordinators.
    /// @return The factory's deployer coordinator manager address.
    function deployerCoordinatorManager() external view returns (address);

    /// @notice Returns the governance address used when new instances are
    ///         deployed.
    /// @return The factory's hyperdrive governance address.
    function hyperdriveGovernance() external view returns (address);

    /// @notice Returns the linker factory used when new instances are deployed.
    /// @return The factory's linker factory.
    function linkerFactory() external view returns (address);

    /// @notice Returns the linker code hash used when new instances are
    ///         deployed.
    /// @return The factory's linker code hash.
    function linkerCodeHash() external view returns (bytes32);

    /// @notice Returns the fee collector used when new instances are deployed.
    /// @return The factory's fee collector.
    function feeCollector() external view returns (address);

    /// @notice Returns the sweep collector used when new instances are deployed.
    /// @return The factory's sweep collector.
    function sweepCollector() external view returns (address);

    /// @notice Returns the checkpoint rewarder used when new instances are
    ///         deployed.
    /// @return The factory's checkpoint rewarder.
    function checkpointRewarder() external view returns (address);

    /// @notice Returns the resolution for the checkpoint duration. Every
    ///         checkpoint duration must be a multiple of this resolution.
    /// @return The factory's checkpoint duration resolution.
    function checkpointDurationResolution() external view returns (uint256);

    /// @notice Returns the minimum checkpoint duration that can be used by new
    ///         deployments.
    /// @return The factory's minimum checkpoint duration.
    function minCheckpointDuration() external view returns (uint256);

    /// @notice Returns the maximum checkpoint duration that can be used by new
    ///         deployments.
    /// @return The factory's maximum checkpoint duration.
    function maxCheckpointDuration() external view returns (uint256);

    /// @notice Returns the minimum position duration that can be used by new
    ///         deployments.
    /// @return The factory's minimum position duration.
    function minPositionDuration() external view returns (uint256);

    /// @notice Returns the maximum position duration that can be used by new
    ///         deployments.
    /// @return The factory's maximum position duration.
    function maxPositionDuration() external view returns (uint256);

    /// @notice Returns the minimum fixed APR that can be used by new
    ///         deployments.
    /// @return The factory's minimum fixed APR.
    function minFixedAPR() external view returns (uint256);

    /// @notice Returns the maximum fixed APR that can be used by new
    ///         deployments.
    /// @return The factory's maximum fixed APR.
    function maxFixedAPR() external view returns (uint256);

    /// @notice Returns the minimum time stretch APR that can be used by new
    ///         deployments.
    /// @return The factory's minimum time stretch APR.
    function minTimeStretchAPR() external view returns (uint256);

    /// @notice Returns the maximum time stretch APR that can be used by new
    ///         deployments.
    /// @return The factory's maximum time stretch APR.
    function maxTimeStretchAPR() external view returns (uint256);

    /// @notice Gets the max fees.
    /// @return The max fees.
    function maxFees() external view returns (IHyperdrive.Fees memory);

    /// @notice Gets the min fees.
    /// @return The min fees.
    function minFees() external view returns (IHyperdrive.Fees memory);

    /// @notice Gets the default pausers.
    /// @return The default pausers.
    function defaultPausers() external view returns (address[] memory);

    /// @notice Gets the number of instances deployed by this factory.
    /// @return The number of instances deployed by this factory.
    function getNumberOfInstances() external view returns (uint256);

    /// @notice Gets the instance at the specified index.
    /// @param _index The index of the instance to get.
    /// @return The instance at the specified index.
    function getInstanceAtIndex(uint256 _index) external view returns (address);

    /// @notice Returns the _instances array according to specified indices.
    /// @param _startIndex The starting index of the instances to get.
    /// @param _endIndex The ending index of the instances to get.
    /// @return range The resulting custom portion of the _instances array.
    function getInstancesInRange(
        uint256 _startIndex,
        uint256 _endIndex
    ) external view returns (address[] memory range);

    /// @notice Returns a flag indicating whether or not an instance was
    ///         deployed by this factory.
    /// @param _instance The instance to check.
    /// @return The flag indicating whether or not the instance was deployed by
    ///         this factory.
    function isInstance(address _instance) external view returns (bool);

    /// @notice Gets the number of deployer coordinators registered in this
    ///         factory.
    /// @return The number of deployer coordinators deployed by this factory.
    function getNumberOfDeployerCoordinators() external view returns (uint256);

    /// @notice Gets the deployer coordinator at the specified index.
    /// @param _index The index of the deployer coordinator to get.
    /// @return The deployer coordinator at the specified index.
    function getDeployerCoordinatorAtIndex(
        uint256 _index
    ) external view returns (address);

    /// @notice Returns the deployer coordinators with an index between the
    ///         starting and ending indexes (inclusive).
    /// @param _startIndex The starting index (inclusive).
    /// @param _endIndex The ending index (inclusive).
    /// @return range The deployer coordinators within the specified range.
    function getDeployerCoordinatorsInRange(
        uint256 _startIndex,
        uint256 _endIndex
    ) external view returns (address[] memory range);

    /// @notice Returns a flag indicating whether or not a deployer coordinator
    ///         is registered in this factory.
    /// @param _deployerCoordinator The deployer coordinator to check.
    /// @return The flag indicating whether or not a deployer coordinator
    ///         is registered in this factory.
    function isDeployerCoordinator(
        address _deployerCoordinator
    ) external view returns (bool);

    /// @notice Gets the deployer coordinators that deployed a list of instances.
    /// @param __instances The instances.
    /// @return coordinators The deployer coordinators.
    function getDeployerCoordinatorByInstances(
        address[] calldata __instances
    ) external view returns (address[] memory coordinators);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IHyperdrive } from "./IHyperdrive.sol";
import { IMultiTokenRead } from "./IMultiTokenRead.sol";

interface IHyperdriveRead is IMultiTokenRead {
    /// @notice Gets the instance's name.
    /// @return The instance's name.
    function name() external view returns (string memory);

    /// @notice Gets the instance's kind.
    /// @return The instance's kind.
    function kind() external pure returns (string memory);

    /// @notice Gets the instance's version.
    /// @return The instance's version.
    function version() external pure returns (string memory);

    /// @notice Gets the Hyperdrive pool's base token.
    /// @return The base token.
    function baseToken() external view returns (address);

    /// @notice Gets the Hyperdrive pool's vault shares token.
    /// @return The vault shares token.
    function vaultSharesToken() external view returns (address);

    /// @notice Gets one of the pool's checkpoints.
    /// @param _checkpointTime The checkpoint time.
    /// @return The checkpoint.
    function getCheckpoint(
        uint256 _checkpointTime
    ) external view returns (IHyperdrive.Checkpoint memory);

    /// @notice Gets the pool's exposure from a checkpoint. This is the number
    ///         of non-netted longs in the checkpoint.
    /// @param _checkpointTime The checkpoint time.
    /// @return The checkpoint exposure.
    function getCheckpointExposure(
        uint256 _checkpointTime
    ) external view returns (int256);

    /// @notice Gets the pool's state relating to the Hyperdrive market.
    /// @return The market state.
    function getMarketState()
        external
        view
        returns (IHyperdrive.MarketState memory);

    /// @notice Gets the pool's configuration parameters.
    /// @return The pool configuration.
    function getPoolConfig()
        external
        view
        returns (IHyperdrive.PoolConfig memory);

    /// @notice Gets info about the pool's reserves and other state that is
    ///         important to evaluate potential trades.
    /// @return The pool info.
    function getPoolInfo() external view returns (IHyperdrive.PoolInfo memory);

    /// @notice Gets the amount of governance fees that haven't been collected.
    /// @return The amount of uncollected governance fees.
    function getUncollectedGovernanceFees() external view returns (uint256);

    /// @notice Gets information relating to the pool's withdrawal pool. This
    ///         includes the total proceeds underlying the withdrawal pool and
    ///         the number of withdrawal shares ready to be redeemed.
    /// @return The withdrawal pool information.
    function getWithdrawPool()
        external
        view
        returns (IHyperdrive.WithdrawPool memory);

    /// @notice Gets an account's pauser status within the Hyperdrive pool.
    /// @param _account The account to check.
    /// @return The account's pauser status.
    function isPauser(address _account) external view returns (bool);

    /// @notice Gets the storage values at the specified slots.
    /// @dev This serves as a generalized getter that allows consumers to create
    ///      custom getters to suit their purposes.
    /// @param _slots The storage slots to load.
    /// @return The values at the specified slots.
    function load(
        uint256[] calldata _slots
    ) external view returns (bytes32[] memory);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IMultiTokenCore } from "./IMultiTokenCore.sol";
import { IMultiTokenEvents } from "./IMultiTokenEvents.sol";
import { IMultiTokenMetadata } from "./IMultiTokenMetadata.sol";
import { IMultiTokenRead } from "./IMultiTokenRead.sol";

interface IMultiToken is
    IMultiTokenEvents,
    IMultiTokenRead,
    IMultiTokenCore,
    IMultiTokenMetadata
{}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

interface IMultiTokenCore {
    /// @notice Transfers an amount of assets from the source to the destination.
    /// @param tokenID The token identifier.
    /// @param from The address whose balance will be reduced.
    /// @param to The address whose balance will be increased.
    /// @param amount The amount of token to move.
    function transferFrom(
        uint256 tokenID,
        address from,
        address to,
        uint256 amount
    ) external;

    /// @notice Permissioned transfer for the bridge to access, only callable by
    ///         the ERC20 linking bridge.
    /// @param tokenID The token identifier.
    /// @param from The address whose balance will be reduced.
    /// @param to The address whose balance will be increased.
    /// @param amount The amount of token to move.
    /// @param caller The msg.sender or the caller of the ERC20Forwarder.
    function transferFromBridge(
        uint256 tokenID,
        address from,
        address to,
        uint256 amount,
        address caller
    ) external;

    /// @notice Allows a user to set an approval for an individual asset with
    ///         specific amount.
    /// @param tokenID The asset to approve the use of.
    /// @param operator The address who will be able to use the tokens.
    /// @param amount The max tokens the approved person can use, setting to
    ///        uint256.max will cause the value to never decrement (saving gas
    ///        on transfer).
    function setApproval(
        uint256 tokenID,
        address operator,
        uint256 amount
    ) external;

    /// @notice Allows the compatibility linking contract to forward calls to
    ///         set asset approvals.
    /// @param tokenID The asset to approve the use of.
    /// @param operator The address who will be able to use the tokens.
    /// @param amount The max tokens the approved person can use, setting to
    ///        uint256.max will cause the value to never decrement [saving gas
    ///        on transfer].
    /// @param caller The eth address which called the linking contract.
    function setApprovalBridge(
        uint256 tokenID,
        address operator,
        uint256 amount,
        address caller
    ) external;

    /// @notice Allows a user to approve an operator to use all of their assets.
    /// @param operator The eth address which can access the caller's assets.
    /// @param approved True to approve, false to remove approval.
    function setApprovalForAll(address operator, bool approved) external;

    /// @notice Transfers several assets from one account to another.
    /// @param from The source account.
    /// @param to The destination account.
    /// @param ids The array of token ids of the asset to transfer.
    /// @param values The amount of each token to transfer.
    function batchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values
    ) external;

    /// @notice Allows a caller who is not the owner of an account to execute the
    ///         functionality of 'approve' for all assets with the owner's
    ///         signature.
    /// @param owner The owner of the account which is having the new approval set.
    /// @param spender The address which will be allowed to spend owner's tokens.
    /// @param _approved A boolean of the approval status to set to.
    /// @param deadline The timestamp which the signature must be submitted by
    ///        to be valid.
    /// @param v Extra ECDSA data which allows public key recovery from
    ///        signature assumed to be 27 or 28.
    /// @param r The r component of the ECDSA signature.
    /// @param s The s component of the ECDSA signature.
    /// @dev The signature for this function follows EIP 712 standard and should
    ///      be generated with the eth_signTypedData JSON RPC call instead of
    ///      the eth_sign JSON RPC call. If using out of date parity signing
    ///      libraries the v component may need to be adjusted. Also it is very
    ///      rare but possible for v to be other values, those values are not
    ///      supported.
    function permitForAll(
        address owner,
        address spender,
        bool _approved,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

interface IMultiTokenEvents {
    /// @notice Emitted when tokens are transferred from one account to another.
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    /// @notice Emitted when an account changes the allowance for another
    ///         account.
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /// @notice Emitted when an account changes the approval for all of its
    ///         tokens.
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

interface IMultiTokenMetadata {
    /// @notice Gets the EIP712 permit typehash of the MultiToken.
    /// @return The EIP712 permit typehash of the MultiToken.
    // solhint-disable func-name-mixedcase
    function PERMIT_TYPEHASH() external view returns (bytes32);

    /// @notice Gets the EIP712 domain separator of the MultiToken.
    /// @return The EIP712 domain separator of the MultiToken.
    function domainSeparator() external view returns (bytes32);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

interface IMultiTokenRead {
    /// @notice Gets the decimals of the MultiToken.
    /// @return The decimals of the MultiToken.
    function decimals() external view returns (uint8);

    /// @notice Gets the name of the MultiToken.
    /// @param tokenId The sub-token ID.
    /// @return The name of the MultiToken.
    function name(uint256 tokenId) external view returns (string memory);

    /// @notice Gets the symbol of the MultiToken.
    /// @param tokenId The sub-token ID.
    /// @return The symbol of the MultiToken.
    function symbol(uint256 tokenId) external view returns (string memory);

    /// @notice Gets the total supply of the MultiToken.
    /// @param tokenId The sub-token ID.
    /// @return The total supply of the MultiToken.
    function totalSupply(uint256 tokenId) external view returns (uint256);

    /// @notice Gets the approval-for-all status of a spender on behalf of an
    ///         owner.
    /// @param owner The owner of the tokens.
    /// @param spender The spender of the tokens.
    /// @return The approval-for-all status of the spender for the owner.
    function isApprovedForAll(
        address owner,
        address spender
    ) external view returns (bool);

    /// @notice Gets the allowance of a spender for a sub-token.
    /// @param tokenId The sub-token ID.
    /// @param owner The owner of the tokens.
    /// @param spender The spender of the tokens.
    /// @return The allowance of the spender for the owner.
    function perTokenApprovals(
        uint256 tokenId,
        address owner,
        address spender
    ) external view returns (uint256);

    /// @notice Gets the balance of a spender for a sub-token.
    /// @param tokenId The sub-token ID.
    /// @param owner The owner of the tokens.
    /// @return The balance of the owner.
    function balanceOf(
        uint256 tokenId,
        address owner
    ) external view returns (uint256);

    /// @notice Gets the permit nonce for an account.
    /// @param owner The owner of the tokens.
    /// @return The permit nonce of the owner.
    function nonces(address owner) external view returns (uint256);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

/// @dev The placeholder address for ETH.
address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

/// @dev The version of the contracts.
string constant VERSION = "v1.0.13";

/// @dev The number of targets that must be deployed for a full deployment.
uint256 constant NUM_TARGETS = 4;

/// @dev The kind of the ERC20 Forwarder.
string constant ERC20_FORWARDER_KIND = "ERC20Forwarder";

/// @dev The kind of the ERC20 Forwarder Factory.
string constant ERC20_FORWARDER_FACTORY_KIND = "ERC20ForwarderFactory";

/// @dev The kind of the Hyperdrive checkpoint rewarder.
string constant HYPERDRIVE_CHECKPOINT_REWARDER_KIND = "HyperdriveCheckpointRewarder";

/// @dev The kind of the Hyperdrive checkpoint subrewarder.
string constant HYPERDRIVE_CHECKPOINT_SUBREWARDER_KIND = "HyperdriveCheckpointSubrewarder";

/// @dev The kind of the Hyperdrive factory.
string constant HYPERDRIVE_FACTORY_KIND = "HyperdriveFactory";

/// @dev The kind of the Hyperdrive registry.
string constant HYPERDRIVE_REGISTRY_KIND = "HyperdriveRegistry";

/// @dev The kind of the ERC4626Hyperdrive deployer coordinator factory.
string constant ERC4626_HYPERDRIVE_DEPLOYER_COORDINATOR_KIND = "ERC4626HyperdriveDeployerCoordinator";

/// @dev The kind of the EzETHHyperdrive deployer coordinator factory.
string constant EZETH_HYPERDRIVE_DEPLOYER_COORDINATOR_KIND = "EzETHHyperdriveDeployerCoordinator";

/// @dev The kind of the LsETHHyperdrive deployer coordinator factory.
string constant LSETH_HYPERDRIVE_DEPLOYER_COORDINATOR_KIND = "LsETHHyperdriveDeployerCoordinator";

/// @dev The kind of the RETHHyperdrive deployer coordinator factory.
string constant RETH_HYPERDRIVE_DEPLOYER_COORDINATOR_KIND = "RETHHyperdriveDeployerCoordinator";

/// @dev The kind of the StETHHyperdrive deployer coordinator factory.
string constant STETH_HYPERDRIVE_DEPLOYER_COORDINATOR_KIND = "StETHHyperdriveDeployerCoordinator";

/// @dev The kind of ERC4626Hyperdrive.
string constant ERC4626_HYPERDRIVE_KIND = "ERC4626Hyperdrive";

/// @dev The kind of EzETHHyperdrive.
string constant EZETH_HYPERDRIVE_KIND = "EzETHHyperdrive";

/// @dev The kind of LsETHHyperdrive.
string constant LSETH_HYPERDRIVE_KIND = "LsETHHyperdrive";

/// @dev The kind of RETHHyperdrive.
string constant RETH_HYPERDRIVE_KIND = "RETHHyperdrive";

/// @dev The kind of StETHHyperdrive.
string constant STETH_HYPERDRIVE_KIND = "StETHHyperdrive";
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IHyperdrive } from "../interfaces/IHyperdrive.sol";

library Errors {
    /// @dev Throws an InsufficientLiquidity error. We do this in a helper
    ///      function to reduce the code size.
    function throwInsufficientLiquidityError() internal pure {
        revert IHyperdrive.InsufficientLiquidity();
    }
}
/// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IHyperdrive } from "../interfaces/IHyperdrive.sol";
import { SafeCast } from "./SafeCast.sol";

uint256 constant ONE = 1e18;

/// @author DELV
/// @title FixedPointMath
/// @notice A fixed-point math library.
/// @custom:disclaimer The language used in this code is for coding convenience
///                    only, and is not intended to, and does not, have any
///                    particular legal or regulatory significance.
library FixedPointMath {
    using FixedPointMath for uint256;
    using SafeCast for uint256;

    uint256 internal constant MAX_UINT256 = 2 ** 256 - 1;

    /// @param x Fixed point number in 1e18 format.
    /// @param y Fixed point number in 1e18 format.
    /// @param denominator Fixed point number in 1e18 format.
    /// @return z The result of x * y / denominator rounded down.
    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(
                mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))
            ) {
                revert(0, 0)
            }

            // Divide x * y by the denominator.
            z := div(mul(x, y), denominator)
        }
    }

    /// @param a Fixed point number in 1e18 format.
    /// @param b Fixed point number in 1e18 format.
    /// @return Result of a * b rounded down.
    function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {
        return (mulDivDown(a, b, ONE));
    }

    /// @param a Fixed point number in 1e18 format.
    /// @param b Fixed point number in 1e18 format.
    /// @return Result of a / b rounded down.
    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {
        return (mulDivDown(a, ONE, b)); // Equivalent to (a * 1e18) / b rounded down.
    }

    /// @param x Fixed point number in 1e18 format.
    /// @param y Fixed point number in 1e18 format.
    /// @param denominator Fixed point number in 1e18 format.
    /// @return z The result of x * y / denominator rounded up.
    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(
                mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))
            ) {
                revert(0, 0)
            }

            // If x * y modulo the denominator is strictly greater than 0,
            // 1 is added to round up the division of x * y by the denominator.
            z := add(
                gt(mod(mul(x, y), denominator), 0),
                div(mul(x, y), denominator)
            )
        }
    }

    /// @param a Fixed point number in 1e18 format.
    /// @param b Fixed point number in 1e18 format.
    /// @return The result of a * b rounded up.
    function mulUp(uint256 a, uint256 b) internal pure returns (uint256) {
        return (mulDivUp(a, b, ONE));
    }

    /// @param a Fixed point number in 1e18 format.
    /// @param b Fixed point number in 1e18 format.
    /// @return The result of a / b rounded up.
    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {
        return (mulDivUp(a, ONE, b));
    }

    /// @dev Exponentiation (x^y) with unsigned 18 decimal fixed point base and exponent.
    /// @param x Fixed point number in 1e18 format.
    /// @param y Fixed point number in 1e18 format.
    /// @return The result of x^y.
    function pow(uint256 x, uint256 y) internal pure returns (uint256) {
        // If the exponent is 0, return 1.
        if (y == 0) {
            return ONE;
        }

        // If the base is 0, return 0.
        if (x == 0) {
            return 0;
        }

        // Using properties of logarithms we calculate x^y:
        // -> ln(x^y) = y * ln(x)
        // -> e^(y * ln(x)) = x^y
        int256 y_int256 = y.toInt256(); // solhint-disable-line var-name-mixedcase

        // Compute y*ln(x)
        // Any overflow for x will be caught in ln() in the initial bounds check
        int256 lnx = ln(x.toInt256());
        int256 ylnx;
        assembly ("memory-safe") {
            ylnx := mul(y_int256, lnx)
        }
        ylnx /= int256(ONE);

        // Calculate exp(y * ln(x)) to get x^y
        return uint256(exp(ylnx));
    }

    /// @dev Computes e^x in 1e18 fixed point.
    /// @dev Credit to Remco (https://github.com/recmo/experiment-solexp/blob/main/src/FixedPointMathLib.sol)
    /// @param x Fixed point number in 1e18 format.
    /// @return r The result of e^x.
    function exp(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is < 0.5 we return zero. This happens when
            // x <= floor(log(0.5e18) * 1e18) ~ -42e18
            if (x <= -42139678854452767551) return 0;

            // When the result is > (2**255 - 1) / 1e18 we can not represent it as an
            // int. This happens when x >= floor(log((2**255 - 1) / 1e18) * 1e18) ~ 135.
            if (x >= 135305999368893231589)
                revert IHyperdrive.ExpInvalidExponent();

            // x is now in the range (-42, 136) * 1e18. Convert to (-42, 136) * 2**96
            // for more intermediate precision and a binary basis. This base conversion
            // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
            x = (x << 78) / 5 ** 18;

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            // Note: 54916777467707473351141471128 = 2^96 ln(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >>
                96;
            x = x - k * 54916777467707473351141471128;

            // k is in the range [-61, 195].

            // Evaluate using a (6, 7)-term rational approximation.
            // p is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave p in 2**192 basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            /// @solidity memory-safe-assembly
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already 2**96 too large.
                r := sdiv(p, q)
            }

            // r should be in the range (0.09, 0.25) * 2**96.

            // We now need to multiply r by:
            // * the scale factor s = ~6.031367120.
            // * the 2**k factor from the range reduction.
            // * the 1e18 / 2**96 factor for base conversion.
            // We do this all at once, with an intermediate result in 2**213
            // basis, so the final right shift is always by a positive amount.
            r = ((uint256(r) *
                3822833074963236453042738258902158003155416615667) >>
                uint256(195 - k)).toInt256();
        }
    }

    /// @dev Computes ln(x) in 1e18 fixed point.
    /// @dev Credit to Remco (https://github.com/recmo/experiment-solexp/blob/main/src/FixedPointMathLib.sol)
    /// @dev Reverts if x is negative or zero.
    /// @param x Fixed point number in 1e18 format.
    /// @return r Result of ln(x).
    function ln(int256 x) internal pure returns (int256 r) {
        unchecked {
            if (x <= 0) {
                revert IHyperdrive.LnInvalidInput();
            }

            // We want to convert x from 10**18 fixed point to 2**96 fixed point.
            // We do this by multiplying by 2**96 / 10**18. But since
            // ln(x * C) = ln(x) + ln(C), we can simply do nothing here
            // and add ln(2**96 / 10**18) at the end.

            // This step inlines the `ilog2` call in Remco's implementation:
            // https://github.com/recmo/experiment-solexp/blob/bbc164fb5ec078cfccf3c71b521605106bfae00b/src/FixedPointMathLib.sol#L57-L68
            //
            /// @solidity memory-safe-assembly
            assembly {
                r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
                r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
                r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
                r := or(r, shl(4, lt(0xffff, shr(r, x))))
                r := or(r, shl(3, lt(0xff, shr(r, x))))
                r := or(r, shl(2, lt(0xf, shr(r, x))))
                r := or(r, shl(1, lt(0x3, shr(r, x))))
                r := or(r, lt(0x1, shr(r, x)))
            }

            // Reduce range of x to [1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            int256 k = r - 96;
            x <<= uint256(159 - k);
            x = (uint256(x) >> 159).toInt256();

            // Evaluate using a (8, 8)-term rational approximation.
            // p is made monic, we will multiply by a scale factor later.
            int256 p = x + 3273285459638523848632254066296;
            p = ((p * x) >> 96) + 24828157081833163892658089445524;
            p = ((p * x) >> 96) + 43456485725739037958740375743393;
            p = ((p * x) >> 96) - 11111509109440967052023855526967;
            p = ((p * x) >> 96) - 45023709667254063763336534515857;
            p = ((p * x) >> 96) - 14706773417378608786704636184526;
            p = p * x - (795164235651350426258249787498 << 96);

            // We leave p in 2**192 basis so we don't need to scale it back up for the division.
            // q is monic by convention.
            int256 q = x + 5573035233440673466300451813936;
            q = ((q * x) >> 96) + 71694874799317883764090561454958;
            q = ((q * x) >> 96) + 283447036172924575727196451306956;
            q = ((q * x) >> 96) + 401686690394027663651624208769553;
            q = ((q * x) >> 96) + 204048457590392012362485061816622;
            q = ((q * x) >> 96) + 31853899698501571402653359427138;
            q = ((q * x) >> 96) + 909429971244387300277376558375;
            /// @solidity memory-safe-assembly
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial is known not to have zeros in the domain.
                // No scaling required because p is already 2**96 too large.
                r := sdiv(p, q)
            }

            // r is in the range (0, 0.125) * 2**96

            // Finalization, we need to:
            // * multiply by the scale factor s = 5.549…
            // * add ln(2**96 / 10**18)
            // * add k * ln(2)
            // * multiply by 10**18 / 2**96 = 5**18 >> 78

            // mul s * 5e18 * 2**96, base is now 5**18 * 2**192
            r *= 1677202110996718588342820967067443963516166;
            // add ln(2) * k * 5e18 * 2**192
            r +=
                16597577552685614221487285958193947469193820559219878177908093499208371 *
                k;
            // add ln(2**96 / 10**18) * 5e18 * 2**192
            r += 600920179829731861736702779321621459595472258049074101567377883020018308;
            // base conversion: mul 2**18 / 2**192
            r >>= 174;
        }
    }

    /// @dev Updates a weighted average by adding or removing a weighted delta.
    /// @param _totalWeight The total weight before the update.
    /// @param _deltaWeight The weight of the new value.
    /// @param _average The weighted average before the update.
    /// @param _delta The new value.
    /// @return average The new weighted average.
    function updateWeightedAverage(
        uint256 _average,
        uint256 _totalWeight,
        uint256 _delta,
        uint256 _deltaWeight,
        bool _isAdding
    ) internal pure returns (uint256 average) {
        // If the delta weight is zero, the average does not change.
        if (_deltaWeight == 0) {
            return _average;
        }

        // If the delta weight should be added to the total weight, we compute
        // the weighted average as:
        //
        // average = (totalWeight * average + deltaWeight * delta) /
        //           (totalWeight + deltaWeight)
        if (_isAdding) {
            // NOTE: Round down to underestimate the average.
            average = (_totalWeight.mulDown(_average) +
                _deltaWeight.mulDown(_delta)).divDown(
                    _totalWeight + _deltaWeight
                );

            // An important property that should always hold when we are adding
            // to the average is:
            //
            // min(_delta, _average) <= average <= max(_delta, _average)
            //
            // To ensure that this is always the case, we clamp the weighted
            // average to this range. We don't have to worry about the
            // case where average > _delta.max(average) because rounding down when
            // computing this average makes this case infeasible.
            uint256 minAverage = _delta.min(_average);
            if (average < minAverage) {
                average = minAverage;
            }
        }
        // If the delta weight should be subtracted from the total weight, we
        // compute the weighted average as:
        //
        // average = (totalWeight * average - deltaWeight * delta) /
        //           (totalWeight - deltaWeight)
        else {
            if (_totalWeight == _deltaWeight) {
                return 0;
            }

            // NOTE: Round down to underestimate the average.
            average = (_totalWeight.mulDown(_average) -
                _deltaWeight.mulUp(_delta)).divDown(
                    _totalWeight - _deltaWeight
                );
        }
    }

    /// @dev Calculates the minimum of two values.
    /// @param a The first value.
    /// @param b The second value.
    /// @return The minimum of the two values.
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? b : a;
    }

    /// @dev Calculates the maximum of two values.
    /// @param a The first value.
    /// @param b The second value.
    /// @return The maximum of the two values.
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /// @dev Calculates the minimum of two values.
    /// @param a The first value.
    /// @param b The second value.
    /// @return The minimum of the two values.
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? b : a;
    }

    /// @dev Calculates the maximum of two values.
    /// @param a The first value.
    /// @param b The second value.
    /// @return The maximum of the two values.
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }
}
/// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { Errors } from "./Errors.sol";
import { FixedPointMath, ONE } from "./FixedPointMath.sol";
import { SafeCast } from "./SafeCast.sol";
import { YieldSpaceMath } from "./YieldSpaceMath.sol";

/// @author DELV
/// @title Hyperdrive
/// @notice Math for the Hyperdrive pricing model.
/// @custom:disclaimer The language used in this code is for coding convenience
///                    only, and is not intended to, and does not, have any
///                    particular legal or regulatory significance.
library HyperdriveMath {
    using FixedPointMath for uint256;
    using FixedPointMath for int256;
    using SafeCast for uint256;

    /// @dev Calculates the checkpoint time of a given timestamp.
    /// @param _timestamp The timestamp to use to calculate the checkpoint time.
    /// @param _checkpointDuration The checkpoint duration.
    /// @return The checkpoint time.
    function calculateCheckpointTime(
        uint256 _timestamp,
        uint256 _checkpointDuration
    ) internal pure returns (uint256) {
        return _timestamp - (_timestamp % _checkpointDuration);
    }

    /// @dev Calculates the time stretch parameter for the YieldSpace curve.
    ///      This parameter modifies the curvature in order to support a larger
    ///      or smaller range of APRs. The lower the time stretch, the flatter
    ///      the curve will be and the narrower the range of feasible APRs. The
    ///      higher the time stretch, the higher the curvature will be and the
    ///      wider the range of feasible APRs.
    /// @param _apr The target APR to use when calculating the time stretch.
    /// @param _positionDuration The position duration in seconds.
    /// @return The time stretch parameter.
    function calculateTimeStretch(
        uint256 _apr,
        uint256 _positionDuration
    ) internal pure returns (uint256) {
        // Calculate the benchmark time stretch. This time stretch is tuned for
        // a position duration of 1 year.
        uint256 timeStretch = uint256(5.24592e18).divDown(
            uint256(0.04665e18).mulDown(_apr * 100)
        );
        timeStretch = ONE.divDown(timeStretch);

        // We know that the following simultaneous equations hold:
        //
        // (1 + apr) * A ** timeStretch = 1
        //
        // and
        //
        // (1 + apr * (positionDuration / 365 days)) * A ** targetTimeStretch = 1
        //
        // where A is the reserve ratio. We can solve these equations for the
        // target time stretch as follows:
        //
        // targetTimeStretch = (
        //     ln(1 + apr * (positionDuration / 365 days)) /
        //     ln(1 + apr)
        // ) * timeStretch
        //
        // NOTE: Round down so that the output is an underestimate.
        return
            (
                uint256(
                    (ONE + _apr.mulDivDown(_positionDuration, 365 days))
                        .toInt256()
                        .ln()
                ).divDown(uint256((ONE + _apr).toInt256().ln()))
            ).mulDown(timeStretch);
    }

    /// @dev Calculates the APR implied by a price.
    /// @param _price The price to convert to an APR.
    /// @param _duration The term duration.
    /// @return The APR implied by the price.
    function calculateAPRFromPrice(
        uint256 _price,
        uint256 _duration
    ) internal pure returns (uint256) {
        // NOTE: Round down to underestimate the spot APR.
        return
            (ONE - _price).divDown(
                // NOTE: Round up since this is in the denominator.
                _price.mulDivUp(_duration, 365 days)
            );
    }

    /// @dev Calculates the spot price of bonds in terms of base. This
    ///      calculation underestimates the pool's spot price.
    /// @param _effectiveShareReserves The pool's effective share reserves. The
    ///        effective share reserves are a modified version of the share
    ///        reserves used when pricing trades.
    /// @param _bondReserves The pool's bond reserves.
    /// @param _initialVaultSharePrice The initial vault share price.
    /// @param _timeStretch The time stretch parameter.
    /// @return spotPrice The spot price of bonds in terms of base.
    function calculateSpotPrice(
        uint256 _effectiveShareReserves,
        uint256 _bondReserves,
        uint256 _initialVaultSharePrice,
        uint256 _timeStretch
    ) internal pure returns (uint256 spotPrice) {
        // NOTE: Round down to underestimate the spot price.
        //
        // p = (y / (mu * (z - zeta))) ** -t_s
        //   = ((mu * (z - zeta)) / y) ** t_s
        spotPrice = _initialVaultSharePrice
            .mulDivDown(_effectiveShareReserves, _bondReserves)
            .pow(_timeStretch);
    }

    /// @dev Calculates the spot APR of the pool. This calculation
    ///      underestimates the pool's spot APR.
    /// @param _effectiveShareReserves The pool's effective share reserves. The
    ///        effective share reserves are a modified version of the share
    ///        reserves used when pricing trades.
    /// @param _bondReserves The pool's bond reserves.
    /// @param _initialVaultSharePrice The pool's initial vault share price.
    /// @param _positionDuration The amount of time until maturity in seconds.
    /// @param _timeStretch The time stretch parameter.
    /// @return apr The pool's spot APR.
    function calculateSpotAPR(
        uint256 _effectiveShareReserves,
        uint256 _bondReserves,
        uint256 _initialVaultSharePrice,
        uint256 _positionDuration,
        uint256 _timeStretch
    ) internal pure returns (uint256 apr) {
        // NOTE: Round down to underestimate the spot APR.
        //
        // We are interested calculating the fixed APR for the pool. The
        // annualized rate is given by the following formula:
        //
        // r = (1 - p) / (p * t)
        //
        // where t = _positionDuration / 365.
        uint256 spotPrice = calculateSpotPrice(
            _effectiveShareReserves,
            _bondReserves,
            _initialVaultSharePrice,
            _timeStretch
        );
        return calculateAPRFromPrice(spotPrice, _positionDuration);
    }

    /// @dev Calculates the effective share reserves. The effective share
    ///      reserves are the share reserves minus the share adjustment or
    ///      z - zeta. We use the effective share reserves as the z-parameter
    ///      to the YieldSpace pricing model. The share adjustment is used to
    ///      hold the pricing mechanism invariant under the flat component of
    ///      flat+curve trades.
    /// @param _shareReserves The pool's share reserves.
    /// @param _shareAdjustment The pool's share adjustment.
    /// @return effectiveShareReserves The effective share reserves.
    function calculateEffectiveShareReserves(
        uint256 _shareReserves,
        int256 _shareAdjustment
    ) internal pure returns (uint256 effectiveShareReserves) {
        bool success;
        (effectiveShareReserves, success) = calculateEffectiveShareReservesSafe(
            _shareReserves,
            _shareAdjustment
        );
        if (!success) {
            Errors.throwInsufficientLiquidityError();
        }
    }

    /// @dev Calculates the effective share reserves. The effective share
    ///      reserves are the share reserves minus the share adjustment or
    ///      z - zeta. We use the effective share reserves as the z-parameter
    ///      to the YieldSpace pricing model. The share adjustment is used to
    ///      hold the pricing mechanism invariant under the flat component of
    ///      flat+curve trades.
    /// @param _shareReserves The pool's share reserves.
    /// @param _shareAdjustment The pool's share adjustment.
    /// @return The effective share reserves.
    /// @return A flag indicating if the calculation succeeded.
    function calculateEffectiveShareReservesSafe(
        uint256 _shareReserves,
        int256 _shareAdjustment
    ) internal pure returns (uint256, bool) {
        int256 effectiveShareReserves = _shareReserves.toInt256() -
            _shareAdjustment;
        if (effectiveShareReserves < 0) {
            return (0, false);
        }
        return (uint256(effectiveShareReserves), true);
    }

    /// @dev Calculates the proceeds in shares of closing a short position. This
    ///      takes into account the trading profits, the interest that was
    ///      earned by the short, the flat fee the short pays, and the amount of
    ///      margin that was released by closing the short. The math for the
    ///      short's proceeds in base is given by:
    ///
    ///      proceeds = (1 + flat_fee) * dy - c * dz + (c1 - c0) * (dy / c0)
    ///               = (1 + flat_fee) * dy - c * dz + (c1 / c0) * dy - dy
    ///               = (c1 / c0 + flat_fee) * dy - c * dz
    ///
    ///      We convert the proceeds to shares by dividing by the current vault
    ///      share price. In the event that the interest is negative and
    ///      outweighs the trading profits and margin released, the short's
    ///      proceeds are marked to zero.
    ///
    ///      This variant of the calculation overestimates the short proceeds.
    /// @param _bondAmount The amount of bonds underlying the closed short.
    /// @param _shareAmount The amount of shares that it costs to close the
    ///                     short.
    /// @param _openVaultSharePrice The vault share price at the short's open.
    /// @param _closeVaultSharePrice The vault share price at the short's close.
    /// @param _vaultSharePrice The current vault share price.
    /// @param _flatFee The flat fee currently within the pool
    /// @return shareProceeds The short proceeds in shares.
    function calculateShortProceedsUp(
        uint256 _bondAmount,
        uint256 _shareAmount,
        uint256 _openVaultSharePrice,
        uint256 _closeVaultSharePrice,
        uint256 _vaultSharePrice,
        uint256 _flatFee
    ) internal pure returns (uint256 shareProceeds) {
        // NOTE: Round up to overestimate the short proceeds.
        //
        // The total value is the amount of shares that underlies the bonds that
        // were shorted. The bonds start by being backed 1:1 with base, and the
        // total value takes into account all of the interest that has accrued
        // since the short was opened.
        //
        // total_value = (c1 / (c0 * c)) * dy
        uint256 totalValue = _bondAmount
            .mulDivUp(_closeVaultSharePrice, _openVaultSharePrice)
            .divUp(_vaultSharePrice);

        // NOTE: Round up to overestimate the short proceeds.
        //
        // We increase the total value by the flat fee amount, because it is
        // included in the total amount of capital underlying the short.
        totalValue += _bondAmount.mulDivUp(_flatFee, _vaultSharePrice);

        // If the interest is more negative than the trading profits and margin
        // released, then the short proceeds are marked to zero. Otherwise, we
        // calculate the proceeds as the sum of the trading proceeds, the
        // interest proceeds, and the margin released.
        if (totalValue > _shareAmount) {
            // proceeds = (c1 / (c0 * c)) * dy - dz
            unchecked {
                shareProceeds = totalValue - _shareAmount;
            }
        }

        return shareProceeds;
    }

    /// @dev Calculates the proceeds in shares of closing a short position. This
    ///      takes into account the trading profits, the interest that was
    ///      earned by the short, the flat fee the short pays, and the amount of
    ///      margin that was released by closing the short. The math for the
    ///      short's proceeds in base is given by:
    ///
    ///      proceeds = (1 + flat_fee) * dy - c * dz + (c1 - c0) * (dy / c0)
    ///               = (1 + flat_fee) * dy - c * dz + (c1 / c0) * dy - dy
    ///               = (c1 / c0 + flat_fee) * dy - c * dz
    ///
    ///      We convert the proceeds to shares by dividing by the current vault
    ///      share price. In the event that the interest is negative and
    ///      outweighs the trading profits and margin released, the short's
    ///      proceeds are marked to zero.
    ///
    ///      This variant of the calculation underestimates the short proceeds.
    /// @param _bondAmount The amount of bonds underlying the closed short.
    /// @param _shareAmount The amount of shares that it costs to close the
    ///                     short.
    /// @param _openVaultSharePrice The vault share price at the short's open.
    /// @param _closeVaultSharePrice The vault share price at the short's close.
    /// @param _vaultSharePrice The current vault share price.
    /// @param _flatFee The flat fee currently within the pool
    /// @return shareProceeds The short proceeds in shares.
    function calculateShortProceedsDown(
        uint256 _bondAmount,
        uint256 _shareAmount,
        uint256 _openVaultSharePrice,
        uint256 _closeVaultSharePrice,
        uint256 _vaultSharePrice,
        uint256 _flatFee
    ) internal pure returns (uint256 shareProceeds) {
        // NOTE: Round down to underestimate the short proceeds.
        //
        // The total value is the amount of shares that underlies the bonds that
        // were shorted. The bonds start by being backed 1:1 with base, and the
        // total value takes into account all of the interest that has accrued
        // since the short was opened.
        //
        // total_value = (c1 / (c0 * c)) * dy
        uint256 totalValue = _bondAmount
            .mulDivDown(_closeVaultSharePrice, _openVaultSharePrice)
            .divDown(_vaultSharePrice);

        // NOTE: Round down to underestimate the short proceeds.
        //
        // We increase the total value by the flat fee amount, because it is
        // included in the total amount of capital underlying the short.
        totalValue += _bondAmount.mulDivDown(_flatFee, _vaultSharePrice);

        // If the interest is more negative than the trading profits and margin
        // released, then the short proceeds are marked to zero. Otherwise, we
        // calculate the proceeds as the sum of the trading proceeds, the
        // interest proceeds, and the margin released.
        if (totalValue > _shareAmount) {
            // proceeds = (c1 / (c0 * c)) * dy - dz
            unchecked {
                shareProceeds = totalValue - _shareAmount;
            }
        }

        return shareProceeds;
    }

    /// @dev Since traders pay a curve fee when they open longs on Hyperdrive,
    ///      it is possible for traders to receive a negative interest rate even
    ///      if curve's spot price is less than or equal to 1.
    ///
    ///      Given the curve fee `phi_c` and the starting spot price `p_0`, the
    ///      maximum spot price is given by:
    ///
    ///      p_max = (1 - phi_f) / (1 + phi_c * (1 / p_0 - 1) * (1 - phi_f))
    ///
    ///      We underestimate the maximum spot price to be conservative.
    /// @param _startingSpotPrice The spot price at the start of the trade.
    /// @param _curveFee The curve fee.
    /// @param _flatFee The flat fee.
    /// @return The maximum spot price.
    function calculateOpenLongMaxSpotPrice(
        uint256 _startingSpotPrice,
        uint256 _curveFee,
        uint256 _flatFee
    ) internal pure returns (uint256) {
        // NOTE: Round down to underestimate the maximum spot price.
        return
            (ONE - _flatFee).divDown(
                // NOTE: Round up since this is in the denominator.
                ONE +
                    _curveFee.mulUp(ONE.divUp(_startingSpotPrice) - ONE).mulUp(
                        ONE - _flatFee
                    )
            );
    }

    /// @dev Since traders pay a curve fee when they close shorts on Hyperdrive,
    ///      it is possible for traders to receive a negative interest rate even
    ///      if curve's spot price is less than or equal to 1.
    ///
    ///      Given the curve fee `phi_c` and the starting spot price `p_0`, the
    ///      maximum spot price is given by:
    ///
    ///      p_max = 1 - phi_c * (1 - p_0)
    ///
    ///      We underestimate the maximum spot price to be conservative.
    /// @param _startingSpotPrice The spot price at the start of the trade.
    /// @param _curveFee The curve fee.
    /// @return The maximum spot price.
    function calculateCloseShortMaxSpotPrice(
        uint256 _startingSpotPrice,
        uint256 _curveFee
    ) internal pure returns (uint256) {
        // Round the rhs down to underestimate the maximum spot price.
        return ONE - _curveFee.mulUp(ONE - _startingSpotPrice);
    }

    /// @dev Calculates the number of bonds a user will receive when opening a
    ///      long position.
    /// @param _effectiveShareReserves The pool's effective share reserves. The
    ///        effective share reserves are a modified version of the share
    ///        reserves used when pricing trades.
    /// @param _bondReserves The pool's bond reserves.
    /// @param _shareAmount The amount of shares the user is depositing.
    /// @param _timeStretch The time stretch parameter.
    /// @param _vaultSharePrice The vault share price.
    /// @param _initialVaultSharePrice The initial vault share price.
    /// @return bondReservesDelta The bonds paid by the reserves in the trade.
    function calculateOpenLong(
        uint256 _effectiveShareReserves,
        uint256 _bondReserves,
        uint256 _shareAmount,
        uint256 _timeStretch,
        uint256 _vaultSharePrice,
        uint256 _initialVaultSharePrice
    ) internal pure returns (uint256) {
        // NOTE: We underestimate the trader's bond proceeds to avoid sandwich
        // attacks.
        return
            YieldSpaceMath.calculateBondsOutGivenSharesInDown(
                _effectiveShareReserves,
                _bondReserves,
                _shareAmount,
                // NOTE: Since the bonds traded on the curve are newly minted,
                // we use a time remaining of 1. This means that we can use
                // `_timeStretch = t * _timeStretch`.
                ONE - _timeStretch,
                _vaultSharePrice,
                _initialVaultSharePrice
            );
    }

    /// @dev Calculates the amount of shares a user will receive when closing a
    ///      long position.
    /// @param _effectiveShareReserves The pool's effective share reserves. The
    ///        effective share reserves are a modified version of the share
    ///        reserves used when pricing trades.
    /// @param _bondReserves The pool's bond reserves.
    /// @param _amountIn The amount of bonds the user is closing.
    /// @param _normalizedTimeRemaining The normalized time remaining of the
    ///        position.
    /// @param _timeStretch The time stretch parameter.
    /// @param _vaultSharePrice The vault share price.
    /// @param _initialVaultSharePrice The vault share price when the pool was
    ///        deployed.
    /// @return shareCurveDelta The shares paid by the reserves in the trade.
    /// @return bondCurveDelta The bonds paid to the reserves in the trade.
    /// @return shareProceeds The shares that the user will receive.
    function calculateCloseLong(
        uint256 _effectiveShareReserves,
        uint256 _bondReserves,
        uint256 _amountIn,
        uint256 _normalizedTimeRemaining,
        uint256 _timeStretch,
        uint256 _vaultSharePrice,
        uint256 _initialVaultSharePrice
    )
        internal
        pure
        returns (
            uint256 shareCurveDelta,
            uint256 bondCurveDelta,
            uint256 shareProceeds
        )
    {
        // NOTE: We underestimate the trader's share proceeds to avoid sandwich
        // attacks.
        //
        // We consider `(1 - timeRemaining) * amountIn` of the bonds to be fully
        // matured and timeRemaining * amountIn of the bonds to be newly
        // minted. The fully matured bonds are redeemed one-to-one to base
        // (our result is given in shares, so we divide the one-to-one
        // redemption by the vault share price) and the newly minted bonds are
        // traded on a YieldSpace curve configured to `timeRemaining = 1`.
        shareProceeds = _amountIn.mulDivDown(
            ONE - _normalizedTimeRemaining,
            _vaultSharePrice
        );
        if (_normalizedTimeRemaining > 0) {
            // NOTE: Round the `bondCurveDelta` down to underestimate the share
            // proceeds.
            //
            // Calculate the curved part of the trade.
            bondCurveDelta = _amountIn.mulDown(_normalizedTimeRemaining);

            // NOTE: Round the `shareCurveDelta` down to underestimate the
            // share proceeds.
            shareCurveDelta = YieldSpaceMath.calculateSharesOutGivenBondsInDown(
                _effectiveShareReserves,
                _bondReserves,
                bondCurveDelta,
                // NOTE: Since the bonds traded on the curve are newly minted,
                // we use a time remaining of 1. This means that we can use
                // `_timeStretch = t * _timeStretch`.
                ONE - _timeStretch,
                _vaultSharePrice,
                _initialVaultSharePrice
            );
            shareProceeds += shareCurveDelta;
        }
    }

    /// @dev Calculates the amount of shares that will be received given a
    ///      specified amount of bonds.
    /// @param _effectiveShareReserves The pool's effective share reserves. The
    ///        effective share reserves are a modified version of the share
    ///        reserves used when pricing trades.
    /// @param _bondReserves The pool's bonds reserves.
    /// @param _amountIn The amount of bonds the user is providing.
    /// @param _timeStretch The time stretch parameter.
    /// @param _vaultSharePrice The vault share price.
    /// @param _initialVaultSharePrice The initial vault share price.
    /// @return The shares paid by the reserves in the trade.
    function calculateOpenShort(
        uint256 _effectiveShareReserves,
        uint256 _bondReserves,
        uint256 _amountIn,
        uint256 _timeStretch,
        uint256 _vaultSharePrice,
        uint256 _initialVaultSharePrice
    ) internal pure returns (uint256) {
        // NOTE: We underestimate the LP's share payment to avoid sandwiches.
        return
            YieldSpaceMath.calculateSharesOutGivenBondsInDown(
                _effectiveShareReserves,
                _bondReserves,
                _amountIn,
                // NOTE: Since the bonds traded on the curve are newly minted,
                // we use a time remaining of 1. This means that we can use
                // `_timeStretch = t * _timeStretch`.
                ONE - _timeStretch,
                _vaultSharePrice,
                _initialVaultSharePrice
            );
    }

    /// @dev Calculates the amount of base that a user will receive when closing
    ///      a short position.
    /// @param _effectiveShareReserves The pool's effective share reserves. The
    ///        effective share reserves are a modified version of the share
    ///        reserves used when pricing trades.
    /// @param _bondReserves The pool's bonds reserves.
    /// @param _amountOut The amount of the asset that is received.
    /// @param _normalizedTimeRemaining The amount of time remaining until
    ///        maturity in seconds.
    /// @param _timeStretch The time stretch parameter.
    /// @param _vaultSharePrice The vault share price.
    /// @param _initialVaultSharePrice The initial vault share price.
    /// @return shareCurveDelta The shares paid to the reserves in the trade.
    /// @return bondCurveDelta The bonds paid by the reserves in the trade.
    /// @return sharePayment The shares that the user must pay.
    function calculateCloseShort(
        uint256 _effectiveShareReserves,
        uint256 _bondReserves,
        uint256 _amountOut,
        uint256 _normalizedTimeRemaining,
        uint256 _timeStretch,
        uint256 _vaultSharePrice,
        uint256 _initialVaultSharePrice
    )
        internal
        pure
        returns (
            uint256 shareCurveDelta,
            uint256 bondCurveDelta,
            uint256 sharePayment
        )
    {
        // NOTE: We overestimate the trader's share payment to avoid sandwiches.
        //
        // Since we are buying bonds, it's possible that `timeRemaining < 1`.
        // We consider `(1 - timeRemaining) * amountOut` of the bonds being
        // purchased to be fully matured and `timeRemaining * amountOut of the
        // bonds to be newly minted. The fully matured bonds are redeemed
        // one-to-one to base (our result is given in shares, so we divide
        // the one-to-one redemption by the vault share price) and the newly
        // minted bonds are traded on a YieldSpace curve configured to
        // timeRemaining = 1.
        sharePayment = _amountOut.mulDivUp(
            ONE - _normalizedTimeRemaining,
            _vaultSharePrice
        );
        if (_normalizedTimeRemaining > 0) {
            // NOTE: Round the `bondCurveDelta` up to overestimate the share
            // payment.
            bondCurveDelta = _amountOut.mulUp(_normalizedTimeRemaining);

            // NOTE: Round the `shareCurveDelta` up to overestimate the share
            // payment.
            shareCurveDelta = YieldSpaceMath.calculateSharesInGivenBondsOutUp(
                _effectiveShareReserves,
                _bondReserves,
                bondCurveDelta,
                // NOTE: Since the bonds traded on the curve are newly minted,
                // we use a time remaining of 1. This means that we can use
                // `_timeStretch = t * _timeStretch`.
                ONE - _timeStretch,
                _vaultSharePrice,
                _initialVaultSharePrice
            );
            sharePayment += shareCurveDelta;
        }
    }

    /// @dev If negative interest accrued over the term, we scale the share
    ///      proceeds by the negative interest amount. Shorts should be
    ///      responsible for negative interest, but negative interest can exceed
    ///      the margin that shorts provide. This leaves us with no choice but
    ///      to attribute the negative interest to longs. Along with scaling the
    ///      share proceeds, we also scale the fee amounts.
    ///
    ///      In order for our AMM invariant to be maintained, the effective
    ///      share reserves need to be adjusted by the same amount as the share
    ///      reserves delta calculated with YieldSpace including fees. We reduce
    ///      the share reserves by `min(c_1 / c_0, 1) * shareReservesDelta` and
    ///      the share adjustment by the `shareAdjustmentDelta`. We can solve
    ///      these equations simultaneously to find the share adjustment delta
    ///      as:
    ///
    ///      shareAdjustmentDelta = min(c_1 / c_0, 1) * sharePayment -
    ///                             shareReservesDelta
    ///
    ///      We underestimate the share proceeds to avoid sandwiches, and we
    ///      round the share reserves delta and share adjustment in the same
    ///      direction for consistency.
    /// @param _shareProceeds The proceeds in shares from the trade.
    /// @param _shareReservesDelta The change in share reserves from the trade.
    /// @param _shareCurveDelta The curve portion of the change in share reserves.
    /// @param _totalGovernanceFee The total governance fee.
    /// @param _openVaultSharePrice The vault share price at the beginning of
    ///        the term.
    /// @param _closeVaultSharePrice The vault share price at the end of the term.
    /// @param _isLong A flag indicating whether or not the trade is a long.
    /// @return The adjusted share proceeds.
    /// @return The adjusted share reserves delta.
    /// @return The adjusted share close proceeds.
    /// @return The share adjustment delta.
    /// @return The adjusted total governance fee.
    function calculateNegativeInterestOnClose(
        uint256 _shareProceeds,
        uint256 _shareReservesDelta,
        uint256 _shareCurveDelta,
        uint256 _totalGovernanceFee,
        uint256 _openVaultSharePrice,
        uint256 _closeVaultSharePrice,
        bool _isLong
    ) internal pure returns (uint256, uint256, uint256, int256, uint256) {
        // The share reserves delta, share curve delta, and total governance fee
        // need to be scaled down in proportion to the negative interest. This
        // results in the pool receiving a lower payment, which reflects the
        // fact that negative interest is attributed to longs.
        //
        // In order for our AMM invariant to be maintained, the effective share
        // reserves need to be adjusted by the same amount as the share reserves
        // delta calculated with YieldSpace including fees. We increase the
        // share reserves by `min(c_1 / c_0, 1) * shareReservesDelta` and the
        // share adjustment by the `shareAdjustmentDelta`. We can solve these
        // equations simultaneously to find the share adjustment delta as:
        //
        // shareAdjustmentDelta = min(c_1 / c_0, 1) * shareReservesDelta -
        //                        shareCurveDelta
        int256 shareAdjustmentDelta;
        if (_closeVaultSharePrice < _openVaultSharePrice) {
            // NOTE: Round down to underestimate the share proceeds.
            //
            // We only need to scale the proceeds in the case that we're closing
            // a long since `calculateShortProceeds` accounts for negative
            // interest.
            if (_isLong) {
                _shareProceeds = _shareProceeds.mulDivDown(
                    _closeVaultSharePrice,
                    _openVaultSharePrice
                );
            }

            // NOTE: Round down to underestimate the quantities.
            //
            // Scale the other values.
            _shareReservesDelta = _shareReservesDelta.mulDivDown(
                _closeVaultSharePrice,
                _openVaultSharePrice
            );
            // NOTE: Using unscaled `shareCurveDelta`.
            shareAdjustmentDelta =
                _shareReservesDelta.toInt256() -
                _shareCurveDelta.toInt256();
            _shareCurveDelta = _shareCurveDelta.mulDivDown(
                _closeVaultSharePrice,
                _openVaultSharePrice
            );
            _totalGovernanceFee = _totalGovernanceFee.mulDivDown(
                _closeVaultSharePrice,
                _openVaultSharePrice
            );
        } else {
            shareAdjustmentDelta =
                _shareReservesDelta.toInt256() -
                _shareCurveDelta.toInt256();
        }

        return (
            _shareProceeds,
            _shareReservesDelta,
            _shareCurveDelta,
            shareAdjustmentDelta,
            _totalGovernanceFee
        );
    }
}
/// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { IHyperdrive } from "../interfaces/IHyperdrive.sol";

/// @notice Safe unsigned integer casting library that reverts on overflow.
/// @author Inspired by OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol)
library SafeCast {
    /// @notice This function safely casts a uint256 to a uint112.
    /// @param x The uint256 to cast to uint112.
    /// @return y The uint112 casted from x.
    function toUint112(uint256 x) internal pure returns (uint112 y) {
        if (x > type(uint112).max) {
            revert IHyperdrive.UnsafeCastToUint112();
        }
        y = uint112(x);
    }

    /// @notice This function safely casts a uint256 to a uint128.
    /// @param x The uint256 to cast to uint128.
    /// @return y The uint128 casted from x.
    function toUint128(uint256 x) internal pure returns (uint128 y) {
        if (x > type(uint128).max) {
            revert IHyperdrive.UnsafeCastToUint128();
        }
        y = uint128(x);
    }

    /// @notice This function safely casts an uint256 to an int128.
    /// @param x The uint256 to cast to int128.
    /// @return y The int128 casted from x.
    function toInt128(uint256 x) internal pure returns (int128 y) {
        if (x > uint128(type(int128).max)) {
            revert IHyperdrive.UnsafeCastToInt128();
        }
        y = int128(int256(x));
    }

    /// @notice This function safely casts an int256 to an int128.
    /// @param x The int256 to cast to int128.
    /// @return y The int128 casted from x.
    function toInt128(int256 x) internal pure returns (int128 y) {
        if (x < type(int128).min || x > type(int128).max) {
            revert IHyperdrive.UnsafeCastToInt128();
        }
        y = int128(x);
    }

    /// @notice This function safely casts an uint256 to an int256.
    /// @param x The uint256 to cast to int256.
    /// @return y The int256 casted from x.
    function toInt256(uint256 x) internal pure returns (int256 y) {
        if (x > uint256(type(int256).max)) {
            revert IHyperdrive.UnsafeCastToInt256();
        }
        y = int256(x);
    }
}
/// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import { Errors } from "./Errors.sol";
import { FixedPointMath, ONE } from "./FixedPointMath.sol";
import { HyperdriveMath } from "./HyperdriveMath.sol";

/// @author DELV
/// @title YieldSpaceMath
/// @notice Math for the YieldSpace pricing model.
/// @custom:disclaimer The language used in this code is for coding convenience
///                    only, and is not intended to, and does not, have any
///                    particular legal or regulatory significance.
///
/// @dev It is advised for developers to attain the pre-requisite knowledge
///      of how this implementation works on the mathematical level. This
///      excerpt attempts to document this pre-requisite knowledge explaining
///      the underpinning mathematical concepts in an understandable manner and
///      relating it directly to the code implementation.
///      This implementation is based on a paper called "YieldSpace with Yield
///      Bearing Vaults" or more casually "Modified YieldSpace". It can be
///      found at the following link.
///
///      https://hackmd.io/lRZ4mgdrRgOpxZQXqKYlFw?view
///
///      That paper builds on the original YieldSpace paper, "YieldSpace:
///      An Automated Liquidity Provider for Fixed Yield Tokens". It can be
///      found at the following link:
///
///      https://yieldprotocol.com/YieldSpace.pdf
library YieldSpaceMath {
    using FixedPointMath for uint256;

    /// @dev Calculates the amount of bonds a user will receive from the pool by
    ///      providing a specified amount of shares. We underestimate the amount
    ///      of bonds out.
    /// @param ze The effective share reserves.
    /// @param y The bond reserves.
    /// @param dz The amount of shares paid to the pool.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return The amount of bonds the trader receives.
    function calculateBondsOutGivenSharesInDown(
        uint256 ze,
        uint256 y,
        uint256 dz,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256) {
        // NOTE: We round k up to make the rhs of the equation larger.
        //
        // k = (c / µ) * (µ * ze)^(1 - t) + y^(1 - t)
        uint256 k = kUp(ze, y, t, c, mu);

        // NOTE: We round ze down to make the rhs of the equation larger.
        //
        //  (µ * (ze + dz))^(1 - t)
        ze = mu.mulDown(ze + dz).pow(t);
        //  (c / µ) * (µ * (ze + dz))^(1 - t)
        ze = c.mulDivDown(ze, mu);

        // If k < ze, we have no choice but to revert.
        if (k < ze) {
            Errors.throwInsufficientLiquidityError();
        }

        // NOTE: We round _y up to make the rhs of the equation larger.
        //
        // (k - (c / µ) * (µ * (ze + dz))^(1 - t))^(1 / (1 - t))
        uint256 _y;
        unchecked {
            _y = k - ze;
        }
        if (_y >= ONE) {
            // Rounding up the exponent results in a larger result.
            _y = _y.pow(ONE.divUp(t));
        } else {
            // Rounding down the exponent results in a larger result.
            _y = _y.pow(ONE.divDown(t));
        }

        // If y < _y, we have no choice but to revert.
        if (y < _y) {
            Errors.throwInsufficientLiquidityError();
        }

        // Δy = y - (k - (c / µ) * (µ * (ze + dz))^(1 - t))^(1 / (1 - t))
        unchecked {
            return y - _y;
        }
    }

    /// @dev Calculates the amount of shares a user must provide the pool to
    ///      receive a specified amount of bonds. We overestimate the amount of
    ///      shares in.
    /// @param ze The effective share reserves.
    /// @param y The bond reserves.
    /// @param dy The amount of bonds paid to the trader.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return result The amount of shares the trader pays.
    function calculateSharesInGivenBondsOutUp(
        uint256 ze,
        uint256 y,
        uint256 dy,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256 result) {
        bool success;
        (result, success) = calculateSharesInGivenBondsOutUpSafe(
            ze,
            y,
            dy,
            t,
            c,
            mu
        );
        if (!success) {
            Errors.throwInsufficientLiquidityError();
        }
    }

    /// @dev Calculates the amount of shares a user must provide the pool to
    ///      receive a specified amount of bonds. This function returns a
    ///      success flag instead of reverting. We overestimate the amount of
    ///      shares in.
    /// @param ze The effective share reserves.
    /// @param y The bond reserves.
    /// @param dy The amount of bonds paid to the trader.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return The amount of shares the trader pays.
    /// @return A flag indicating if the calculation succeeded.
    function calculateSharesInGivenBondsOutUpSafe(
        uint256 ze,
        uint256 y,
        uint256 dy,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256, bool) {
        // NOTE: We round k up to make the lhs of the equation larger.
        //
        // k = (c / µ) * (µ * ze)^(1 - t) + y^(1 - t)
        uint256 k = kUp(ze, y, t, c, mu);

        // If y < dy, we return a failure flag since the calculation would have
        // underflowed.
        if (y < dy) {
            return (0, false);
        }

        // (y - dy)^(1 - t)
        unchecked {
            y -= dy;
        }
        y = y.pow(t);

        // If k < y, we return a failure flag since the calculation would have
        // underflowed.
        if (k < y) {
            return (0, false);
        }

        // NOTE: We round _z up to make the lhs of the equation larger.
        //
        // ((k - (y - dy)^(1 - t) ) / (c / µ))^(1 / (1 - t))
        uint256 _z;
        unchecked {
            _z = k - y;
        }
        _z = _z.mulDivUp(mu, c);
        if (_z >= ONE) {
            // Rounding up the exponent results in a larger result.
            _z = _z.pow(ONE.divUp(t));
        } else {
            // Rounding down the exponent results in a larger result.
            _z = _z.pow(ONE.divDown(t));
        }
        // ((k - (y - dy)^(1 - t) ) / (c / µ))^(1 / (1 - t))) / µ
        _z = _z.divUp(mu);

        // If _z < ze, we return a failure flag since the calculation would have
        // underflowed.
        if (_z < ze) {
            return (0, false);
        }

        // Δz = (((k - (y - dy)^(1 - t) ) / (c / µ))^(1 / (1 - t))) / µ - ze
        unchecked {
            return (_z - ze, true);
        }
    }

    /// @dev Calculates the amount of shares a user must provide the pool to
    ///      receive a specified amount of bonds. We underestimate the amount of
    ///      shares in.
    /// @param ze The effective share reserves.
    /// @param y The bond reserves.
    /// @param dy The amount of bonds paid to the trader.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return The amount of shares the user pays.
    function calculateSharesInGivenBondsOutDown(
        uint256 ze,
        uint256 y,
        uint256 dy,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256) {
        // NOTE: We round k down to make the lhs of the equation smaller.
        //
        // k = (c / µ) * (µ * ze)^(1 - t) + y^(1 - t)
        uint256 k = kDown(ze, y, t, c, mu);

        // If y < dy, we have no choice but to revert.
        if (y < dy) {
            Errors.throwInsufficientLiquidityError();
        }

        // (y - dy)^(1 - t)
        unchecked {
            y -= dy;
        }
        y = y.pow(t);

        // If k < y, we have no choice but to revert.
        if (k < y) {
            Errors.throwInsufficientLiquidityError();
        }

        // NOTE: We round _z down to make the lhs of the equation smaller.
        //
        // _z = ((k - (y - dy)^(1 - t) ) / (c / µ))^(1 / (1 - t))
        uint256 _z;
        unchecked {
            _z = k - y;
        }
        _z = _z.mulDivDown(mu, c);
        if (_z >= ONE) {
            // Rounding down the exponent results in a smaller result.
            _z = _z.pow(ONE.divDown(t));
        } else {
            // Rounding up the exponent results in a smaller result.
            _z = _z.pow(ONE.divUp(t));
        }
        // ((k - (y - dy)^(1 - t) ) / (c / µ))^(1 / (1 - t))) / µ
        _z = _z.divDown(mu);

        // If _z < ze, we have no choice but to revert.
        if (_z < ze) {
            Errors.throwInsufficientLiquidityError();
        }

        // Δz = (((k - (y - dy)^(1 - t) ) / (c / µ))^(1 / (1 - t))) / µ - ze
        unchecked {
            return _z - ze;
        }
    }

    /// @dev Calculates the amount of shares a user will receive from the pool
    ///      by providing a specified amount of bonds. This function reverts if
    ///      an integer overflow or underflow occurs. We underestimate the
    ///      amount of shares out.
    /// @param ze The effective share reserves.
    /// @param y The bond reserves.
    /// @param dy The amount of bonds paid to the pool.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return result The amount of shares the user receives.
    function calculateSharesOutGivenBondsInDown(
        uint256 ze,
        uint256 y,
        uint256 dy,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256 result) {
        bool success;
        (result, success) = calculateSharesOutGivenBondsInDownSafe(
            ze,
            y,
            dy,
            t,
            c,
            mu
        );
        if (!success) {
            Errors.throwInsufficientLiquidityError();
        }
    }

    /// @dev Calculates the amount of shares a user will receive from the pool
    ///      by providing a specified amount of bonds. This function returns a
    ///      success flag instead of reverting. We underestimate the amount of
    ///      shares out.
    /// @param ze The effective share reserves.
    /// @param y The bond reserves.
    /// @param dy The amount of bonds paid to the pool.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return The amount of shares the user receives
    /// @return A flag indicating if the calculation succeeded.
    function calculateSharesOutGivenBondsInDownSafe(
        uint256 ze,
        uint256 y,
        uint256 dy,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256, bool) {
        // NOTE: We round k up to make the rhs of the equation larger.
        //
        // k = (c / µ) * (µ * ze)^(1 - t) + y^(1 - t)
        uint256 k = kUp(ze, y, t, c, mu);

        // (y + dy)^(1 - t)
        y = (y + dy).pow(t);

        // If k is less than y, we return with a failure flag.
        if (k < y) {
            return (0, false);
        }

        // NOTE: We round _z up to make the rhs of the equation larger.
        //
        // ((k - (y + dy)^(1 - t)) / (c / µ))^(1 / (1 - t)))
        uint256 _z;
        unchecked {
            _z = k - y;
        }
        _z = _z.mulDivUp(mu, c);
        if (_z >= ONE) {
            // Rounding the exponent up results in a larger outcome.
            _z = _z.pow(ONE.divUp(t));
        } else {
            // Rounding the exponent down results in a larger outcome.
            _z = _z.pow(ONE.divDown(t));
        }
        // ((k - (y + dy)^(1 - t) ) / (c / µ))^(1 / (1 - t))) / µ
        _z = _z.divUp(mu);

        // If ze is less than _z, we return a failure flag since the calculation
        // underflowed.
        if (ze < _z) {
            return (0, false);
        }

        // Δz = ze - ((k - (y + dy)^(1 - t) ) / (c / µ))^(1 / (1 - t)) / µ
        unchecked {
            return (ze - _z, true);
        }
    }

    /// @dev Calculates the share payment required to purchase the maximum
    ///      amount of bonds from the pool. This function returns a success flag
    ///      instead of reverting. We round so that the max buy amount is
    ///      underestimated.
    /// @param ze The effective share reserves.
    /// @param y The bond reserves.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return The share payment to purchase the maximum amount of bonds.
    /// @return A flag indicating if the calculation succeeded.
    function calculateMaxBuySharesInSafe(
        uint256 ze,
        uint256 y,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256, bool) {
        // We solve for the maximum buy using the constraint that the pool's
        // spot price can never exceed 1. We do this by noting that a spot price
        // of 1, ((mu * ze) / y) ** tau = 1, implies that mu * ze = y. This
        // simplifies YieldSpace to:
        //
        // k = ((c / mu) + 1) * (mu * ze') ** (1 - tau),
        //
        // This gives us the maximum effective share reserves of:
        //
        // ze' = (1 / mu) * (k / ((c / mu) + 1)) ** (1 / (1 - tau)).
        uint256 k = kDown(ze, y, t, c, mu);
        uint256 optimalZe = k.divDown(c.divUp(mu) + ONE);
        if (optimalZe >= ONE) {
            // Rounding the exponent down results in a smaller outcome.
            optimalZe = optimalZe.pow(ONE.divDown(t));
        } else {
            // Rounding the exponent up results in a smaller outcome.
            optimalZe = optimalZe.pow(ONE.divUp(t));
        }
        optimalZe = optimalZe.divDown(mu);

        // The optimal trade size is given by dz = ze' - ze. If the calculation
        // underflows, we return a failure flag.
        if (optimalZe < ze) {
            return (0, false);
        }
        unchecked {
            return (optimalZe - ze, true);
        }
    }

    /// @dev Calculates the maximum amount of bonds that can be purchased with
    ///      the specified reserves. This function returns a success flag
    ///      instead of reverting. We round so that the max buy amount is
    ///      underestimated.
    /// @param ze The effective share reserves.
    /// @param y The bond reserves.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return The maximum amount of bonds that can be purchased.
    /// @return A flag indicating if the calculation succeeded.
    function calculateMaxBuyBondsOutSafe(
        uint256 ze,
        uint256 y,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256, bool) {
        // We can use the same derivation as in `calculateMaxBuySharesIn` to
        // calculate the minimum bond reserves as:
        //
        // y' = (k / ((c / mu) + 1)) ** (1 / (1 - tau)).
        uint256 k = kUp(ze, y, t, c, mu);
        uint256 optimalY = k.divUp(c.divDown(mu) + ONE);
        if (optimalY >= ONE) {
            // Rounding the exponent up results in a larger outcome.
            optimalY = optimalY.pow(ONE.divUp(t));
        } else {
            // Rounding the exponent down results in a larger outcome.
            optimalY = optimalY.pow(ONE.divDown(t));
        }

        // The optimal trade size is given by dy = y - y'. If the calculation
        // underflows, we return a failure flag.
        if (y < optimalY) {
            return (0, false);
        }
        unchecked {
            return (y - optimalY, true);
        }
    }

    /// @dev Calculates the maximum amount of bonds that can be sold with the
    ///      specified reserves. We round so that the max sell amount is
    ///      underestimated.
    /// @param z The share reserves.
    /// @param zeta The share adjustment.
    /// @param y The bond reserves.
    /// @param zMin The minimum share reserves.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return The maximum amount of bonds that can be sold.
    /// @return A flag indicating whether or not the calculation was successful.
    function calculateMaxSellBondsInSafe(
        uint256 z,
        int256 zeta,
        uint256 y,
        uint256 zMin,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256, bool) {
        // If the share adjustment is negative, the minimum share reserves is
        // given by `zMin - zeta`, which ensures that the share reserves never
        // fall below the minimum share reserves. Otherwise, the minimum share
        // reserves is just zMin.
        if (zeta < 0) {
            zMin = zMin + uint256(-zeta);
        }

        // We solve for the maximum bond amount using the constraint that the
        // pool's share reserves can never fall below the minimum share reserves
        // `zMin`. Substituting `ze = zMin` simplifies YieldSpace to:
        //
        // k = (c / mu) * (mu * zMin) ** (1 - tau) + y' ** (1 - tau)
        //
        // This gives us the maximum bonds that can be sold to the pool as:
        //
        // y' = (k - (c / mu) * (mu * zMin) ** (1 - tau)) ** (1 / (1 - tau)).
        (uint256 ze, bool success) = HyperdriveMath
            .calculateEffectiveShareReservesSafe(z, zeta);

        if (!success) {
            return (0, false);
        }
        uint256 k = kDown(ze, y, t, c, mu);
        uint256 rhs = c.mulDivUp(mu.mulUp(zMin).pow(t), mu);
        if (k < rhs) {
            return (0, false);
        }
        uint256 optimalY;
        unchecked {
            optimalY = k - rhs;
        }
        if (optimalY >= ONE) {
            // Rounding the exponent down results in a smaller outcome.
            optimalY = optimalY.pow(ONE.divDown(t));
        } else {
            // Rounding the exponent up results in a smaller outcome.
            optimalY = optimalY.pow(ONE.divUp(t));
        }

        // The optimal trade size is given by dy = y' - y. If this subtraction
        // will underflow, we return a failure flag.
        if (optimalY < y) {
            return (0, false);
        }
        unchecked {
            return (optimalY - y, true);
        }
    }

    /// @dev Calculates the YieldSpace invariant k. This invariant is given by:
    ///
    ///      k = (c / µ) * (µ * ze)^(1 - t) + y^(1 - t)
    ///
    ///      This variant of the calculation overestimates the result.
    /// @param ze The effective share reserves.
    /// @param y The bond reserves.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return The YieldSpace invariant, k.
    function kUp(
        uint256 ze,
        uint256 y,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256) {
        // NOTE: Rounding up to overestimate the result.
        //
        /// k = (c / µ) * (µ * ze)^(1 - t) + y^(1 - t)
        return c.mulDivUp(mu.mulUp(ze).pow(t), mu) + y.pow(t);
    }

    /// @dev Calculates the YieldSpace invariant k. This invariant is given by:
    ///
    ///      k = (c / µ) * (µ * ze)^(1 - t) + y^(1 - t)
    ///
    ///      This variant of the calculation underestimates the result.
    /// @param ze The effective share reserves.
    /// @param y The bond reserves.
    /// @param t The time elapsed since the term's start.
    /// @param c The vault share price.
    /// @param mu The initial vault share price.
    /// @return The modified YieldSpace Constant.
    function kDown(
        uint256 ze,
        uint256 y,
        uint256 t,
        uint256 c,
        uint256 mu
    ) internal pure returns (uint256) {
        // NOTE: Rounding down to underestimate the result.
        //
        /// k = (c / µ) * (µ * ze)^(1 - t) + y^(1 - t)
        return c.mulDivDown(mu.mulDown(ze).pow(t), mu) + y.pow(t);
    }
}