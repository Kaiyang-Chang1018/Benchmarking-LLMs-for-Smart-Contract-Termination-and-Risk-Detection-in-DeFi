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
pragma solidity ^0.8.0;

import { Types } from "../../src/libraries/Types.sol";
import { GameType, Timestamp } from "../../src/dispute/lib/LibUDT.sol";
import { IDisputeGame } from "../../interfaces/dispute/IDisputeGame.sol";
import { IDisputeGameFactory } from "../../interfaces/dispute/IDisputeGameFactory.sol";
import { ISystemConfig } from "../../interfaces/L1/ISystemConfig.sol";
import { ISuperchainConfig } from "../../interfaces/L1/ISuperchainConfig.sol";

interface IOptimismPortal2 {
    error AlreadyFinalized();
    error BadTarget();
    error Blacklisted();
    error CallPaused();
    error ContentLengthMismatch();
    error EmptyItem();
    error GasEstimation();
    error InvalidDataRemainder();
    error InvalidDisputeGame();
    error InvalidGameType();
    error InvalidHeader();
    error InvalidMerkleProof();
    error InvalidProof();
    error LargeCalldata();
    error NoValue();
    error NonReentrant();
    error OnlyCustomGasToken();
    error OutOfGas();
    error ProposalNotValidated();
    error SmallGasLimit();
    error TransferFailed();
    error Unauthorized();
    error UnexpectedList();
    error UnexpectedString();
    error Unproven();

    event DisputeGameBlacklisted(IDisputeGame indexed disputeGame);
    event Initialized(uint8 version);
    event RespectedGameTypeSet(GameType indexed newGameType, Timestamp indexed updatedAt);
    event TransactionDeposited(address indexed from, address indexed to, uint256 indexed version, bytes opaqueData);
    event WithdrawalFinalized(bytes32 indexed withdrawalHash, bool success);
    event WithdrawalProven(bytes32 indexed withdrawalHash, address indexed from, address indexed to);
    event WithdrawalProvenExtension1(bytes32 indexed withdrawalHash, address indexed proofSubmitter);

    receive() external payable;

    function balance() external view returns (uint256);
    function blacklistDisputeGame(IDisputeGame _disputeGame) external;
    function checkWithdrawal(bytes32 _withdrawalHash, address _proofSubmitter) external view;
    function depositERC20Transaction(
        address _to,
        uint256 _mint,
        uint256 _value,
        uint64 _gasLimit,
        bool _isCreation,
        bytes memory _data
    )
        external;
    function depositTransaction(
        address _to,
        uint256 _value,
        uint64 _gasLimit,
        bool _isCreation,
        bytes memory _data
    )
        external
        payable;
    function disputeGameBlacklist(IDisputeGame) external view returns (bool);
    function disputeGameFactory() external view returns (IDisputeGameFactory);
    function disputeGameFinalityDelaySeconds() external view returns (uint256);
    function donateETH() external payable;
    function finalizeWithdrawalTransaction(Types.WithdrawalTransaction memory _tx) external;
    function finalizeWithdrawalTransactionExternalProof(
        Types.WithdrawalTransaction memory _tx,
        address _proofSubmitter
    )
        external;
    function finalizedWithdrawals(bytes32) external view returns (bool);
    function guardian() external view returns (address);
    function initialize(
        IDisputeGameFactory _disputeGameFactory,
        ISystemConfig _systemConfig,
        ISuperchainConfig _superchainConfig,
        GameType _initialRespectedGameType
    )
        external;
    function l2Sender() external view returns (address);
    function minimumGasLimit(uint64 _byteCount) external pure returns (uint64);
    function numProofSubmitters(bytes32 _withdrawalHash) external view returns (uint256);
    function params() external view returns (uint128 prevBaseFee, uint64 prevBoughtGas, uint64 prevBlockNum); // nosemgrep
    function paused() external view returns (bool);
    function proofMaturityDelaySeconds() external view returns (uint256);
    function proofSubmitters(bytes32, uint256) external view returns (address);
    function proveWithdrawalTransaction(
        Types.WithdrawalTransaction memory _tx,
        uint256 _disputeGameIndex,
        Types.OutputRootProof memory _outputRootProof,
        bytes[] memory _withdrawalProof
    )
        external;
    function provenWithdrawals(
        bytes32,
        address
    )
        external
        view
        returns (IDisputeGame disputeGameProxy, uint64 timestamp); // nosemgrep
    function respectedGameType() external view returns (GameType);
    function respectedGameTypeUpdatedAt() external view returns (uint64);
    function setGasPayingToken(address _token, uint8 _decimals, bytes32 _name, bytes32 _symbol) external;
    function setRespectedGameType(GameType _gameType) external;
    function superchainConfig() external view returns (ISuperchainConfig);
    function systemConfig() external view returns (ISystemConfig);
    function version() external pure returns (string memory);

    function __constructor__(uint256 _proofMaturityDelaySeconds, uint256 _disputeGameFinalityDelaySeconds) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IResourceMetering {
    struct ResourceParams {
        uint128 prevBaseFee;
        uint64 prevBoughtGas;
        uint64 prevBlockNum;
    }

    struct ResourceConfig {
        uint32 maxResourceLimit;
        uint8 elasticityMultiplier;
        uint8 baseFeeMaxChangeDenominator;
        uint32 minimumBaseFee;
        uint32 systemTxMaxGas;
        uint128 maximumBaseFee;
    }

    error OutOfGas();

    event Initialized(uint8 version);

    function params() external view returns (uint128 prevBaseFee, uint64 prevBoughtGas, uint64 prevBlockNum); // nosemgrep

    function __constructor__() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISuperchainConfig {
    enum UpdateType {
        GUARDIAN
    }

    event ConfigUpdate(UpdateType indexed updateType, bytes data);
    event Initialized(uint8 version);
    event Paused(string identifier);
    event Unpaused();

    function GUARDIAN_SLOT() external view returns (bytes32);
    function PAUSED_SLOT() external view returns (bytes32);
    function guardian() external view returns (address guardian_);
    function initialize(address _guardian, bool _paused) external;
    function pause(string memory _identifier) external;
    function paused() external view returns (bool paused_);
    function unpause() external;
    function version() external view returns (string memory);

    function __constructor__() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IResourceMetering } from "../../interfaces/L1/IResourceMetering.sol";

/// @notice This interface corresponds to the Custom Gas Token version of the SystemConfig contract.
interface ISystemConfig {
    enum UpdateType {
        BATCHER,
        FEE_SCALARS,
        GAS_LIMIT,
        UNSAFE_BLOCK_SIGNER,
        EIP_1559_PARAMS
    }

    struct Addresses {
        address l1CrossDomainMessenger;
        address l1ERC721Bridge;
        address l1StandardBridge;
        address disputeGameFactory;
        address optimismPortal;
        address optimismMintableERC20Factory;
        address gasPayingToken;
    }

    event ConfigUpdate(uint256 indexed version, UpdateType indexed updateType, bytes data);
    event Initialized(uint8 version);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function BATCH_INBOX_SLOT() external view returns (bytes32);
    function DISPUTE_GAME_FACTORY_SLOT() external view returns (bytes32);
    function L1_CROSS_DOMAIN_MESSENGER_SLOT() external view returns (bytes32);
    function L1_ERC_721_BRIDGE_SLOT() external view returns (bytes32);
    function L1_STANDARD_BRIDGE_SLOT() external view returns (bytes32);
    function OPTIMISM_MINTABLE_ERC20_FACTORY_SLOT() external view returns (bytes32);
    function OPTIMISM_PORTAL_SLOT() external view returns (bytes32);
    function START_BLOCK_SLOT() external view returns (bytes32);
    function UNSAFE_BLOCK_SIGNER_SLOT() external view returns (bytes32);
    function VERSION() external view returns (uint256);
    function basefeeScalar() external view returns (uint32);
    function batchInbox() external view returns (address addr_);
    function batcherHash() external view returns (bytes32);
    function blobbasefeeScalar() external view returns (uint32);
    function disputeGameFactory() external view returns (address addr_);
    function gasLimit() external view returns (uint64);
    function eip1559Denominator() external view returns (uint32);
    function eip1559Elasticity() external view returns (uint32);
    function gasPayingToken() external view returns (address addr_, uint8 decimals_);
    function gasPayingTokenName() external view returns (string memory name_);
    function gasPayingTokenSymbol() external view returns (string memory symbol_);
    function initialize(
        address _owner,
        uint32 _basefeeScalar,
        uint32 _blobbasefeeScalar,
        bytes32 _batcherHash,
        uint64 _gasLimit,
        address _unsafeBlockSigner,
        IResourceMetering.ResourceConfig memory _config,
        address _batchInbox,
        Addresses memory _addresses
    )
        external;
    function isCustomGasToken() external view returns (bool);
    function l1CrossDomainMessenger() external view returns (address addr_);
    function l1ERC721Bridge() external view returns (address addr_);
    function l1StandardBridge() external view returns (address addr_);
    function maximumGasLimit() external pure returns (uint64);
    function minimumGasLimit() external view returns (uint64);
    function optimismMintableERC20Factory() external view returns (address addr_);
    function optimismPortal() external view returns (address addr_);
    function overhead() external view returns (uint256);
    function owner() external view returns (address);
    function renounceOwnership() external;
    function resourceConfig() external view returns (IResourceMetering.ResourceConfig memory);
    function scalar() external view returns (uint256);
    function setBatcherHash(bytes32 _batcherHash) external;
    function setGasConfig(uint256 _overhead, uint256 _scalar) external;
    function setGasConfigEcotone(uint32 _basefeeScalar, uint32 _blobbasefeeScalar) external;
    function setGasLimit(uint64 _gasLimit) external;
    function setUnsafeBlockSigner(address _unsafeBlockSigner) external;
    function setEIP1559Params(uint32 _denominator, uint32 _elasticity) external;
    function startBlock() external view returns (uint256 startBlock_);
    function transferOwnership(address newOwner) external; // nosemgrep
    function unsafeBlockSigner() external view returns (address addr_);
    function version() external pure returns (string memory);

    function __constructor__() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IInitializable } from "../../interfaces/dispute/IInitializable.sol";
import { Timestamp, GameStatus, GameType, Claim, Hash } from "../../src/dispute/lib/Types.sol";

interface IDisputeGame is IInitializable {
    event Resolved(GameStatus indexed status);

    function createdAt() external view returns (Timestamp);
    function resolvedAt() external view returns (Timestamp);
    function status() external view returns (GameStatus);
    function gameType() external view returns (GameType gameType_);
    function gameCreator() external pure returns (address creator_);
    function rootClaim() external pure returns (Claim rootClaim_);
    function l1Head() external pure returns (Hash l1Head_);
    function extraData() external pure returns (bytes memory extraData_);
    function resolve() external returns (GameStatus status_);
    function gameData() external view returns (GameType gameType_, Claim rootClaim_, bytes memory extraData_);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IDisputeGame } from "../../interfaces/dispute/IDisputeGame.sol";
import { GameId, Timestamp, Claim, Hash, GameType } from "../../src/dispute/lib/Types.sol";

interface IDisputeGameFactory {
    struct GameSearchResult {
        uint256 index;
        GameId metadata;
        Timestamp timestamp;
        Claim rootClaim;
        bytes extraData;
    }

    error GameAlreadyExists(Hash uuid);
    error IncorrectBondAmount();
    error NoImplementation(GameType gameType);

    event DisputeGameCreated(address indexed disputeProxy, GameType indexed gameType, Claim indexed rootClaim);
    event ImplementationSet(address indexed impl, GameType indexed gameType);
    event InitBondUpdated(GameType indexed gameType, uint256 indexed newBond);
    event Initialized(uint8 version);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function create(
        GameType _gameType,
        Claim _rootClaim,
        bytes memory _extraData
    )
        external
        payable
        returns (IDisputeGame proxy_);
    function findLatestGames(
        GameType _gameType,
        uint256 _start,
        uint256 _n
    )
        external
        view
        returns (GameSearchResult[] memory games_);
    function gameAtIndex(uint256 _index)
        external
        view
        returns (GameType gameType_, Timestamp timestamp_, IDisputeGame proxy_);
    function gameCount() external view returns (uint256 gameCount_);
    function gameImpls(GameType) external view returns (IDisputeGame);
    function games(
        GameType _gameType,
        Claim _rootClaim,
        bytes memory _extraData
    )
        external
        view
        returns (IDisputeGame proxy_, Timestamp timestamp_);
    function getGameUUID(
        GameType _gameType,
        Claim _rootClaim,
        bytes memory _extraData
    )
        external
        pure
        returns (Hash uuid_);
    function initBonds(GameType) external view returns (uint256);
    function initialize(address _owner) external;
    function owner() external view returns (address);
    function renounceOwnership() external;
    function setImplementation(GameType _gameType, IDisputeGame _impl) external;
    function setInitBond(GameType _gameType, uint256 _initBond) external;
    function transferOwnership(address newOwner) external; // nosemgrep
    function version() external view returns (string memory);

    function __constructor__() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IInitializable {
    function initialize() external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

using LibPosition for Position global;

/// @notice A `Position` represents a position of a claim within the game tree.
/// @dev This is represented as a "generalized index" where the high-order bit
/// is the level in the tree and the remaining bits is a unique bit pattern, allowing
/// a unique identifier for each node in the tree. Mathematically, it is calculated
/// as 2^{depth} + indexAtDepth.
type Position is uint128;

/// @title LibPosition
/// @notice This library contains helper functions for working with the `Position` type.
library LibPosition {
    /// @notice the `MAX_POSITION_BITLEN` is the number of bits that the `Position` type, and the implementation of
    ///         its behavior within this library, can safely support.
    uint8 internal constant MAX_POSITION_BITLEN = 126;

    /// @notice Computes a generalized index (2^{depth} + indexAtDepth).
    /// @param _depth The depth of the position.
    /// @param _indexAtDepth The index at the depth of the position.
    /// @return position_ The computed generalized index.
    function wrap(uint8 _depth, uint128 _indexAtDepth) internal pure returns (Position position_) {
        assembly {
            // gindex = 2^{_depth} + _indexAtDepth
            position_ := add(shl(_depth, 1), _indexAtDepth)
        }
    }

    /// @notice Pulls the `depth` out of a `Position` type.
    /// @param _position The generalized index to get the `depth` of.
    /// @return depth_ The `depth` of the `position` gindex.
    /// @custom:attribution Solady <https://github.com/Vectorized/Solady>
    function depth(Position _position) internal pure returns (uint8 depth_) {
        // Return the most significant bit offset, which signifies the depth of the gindex.
        assembly {
            depth_ := or(depth_, shl(6, lt(0xffffffffffffffff, shr(depth_, _position))))
            depth_ := or(depth_, shl(5, lt(0xffffffff, shr(depth_, _position))))

            // For the remaining 32 bits, use a De Bruijn lookup.
            _position := shr(depth_, _position)
            _position := or(_position, shr(1, _position))
            _position := or(_position, shr(2, _position))
            _position := or(_position, shr(4, _position))
            _position := or(_position, shr(8, _position))
            _position := or(_position, shr(16, _position))

            depth_ :=
                or(
                    depth_,
                    byte(
                        shr(251, mul(_position, shl(224, 0x07c4acdd))),
                        0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f
                    )
                )
        }
    }

    /// @notice Pulls the `indexAtDepth` out of a `Position` type.
    ///         The `indexAtDepth` is the left/right index of a position at a specific depth within
    ///         the binary tree, starting from index 0. For example, at gindex 2, the `depth` = 1
    ///         and the `indexAtDepth` = 0.
    /// @param _position The generalized index to get the `indexAtDepth` of.
    /// @return indexAtDepth_ The `indexAtDepth` of the `position` gindex.
    function indexAtDepth(Position _position) internal pure returns (uint128 indexAtDepth_) {
        // Return bits p_{msb-1}...p_{0}. This effectively pulls the 2^{depth} out of the gindex,
        // leaving only the `indexAtDepth`.
        uint256 msb = depth(_position);
        assembly {
            indexAtDepth_ := sub(_position, shl(msb, 1))
        }
    }

    /// @notice Get the left child of `_position`.
    /// @param _position The position to get the left position of.
    /// @return left_ The position to the left of `position`.
    function left(Position _position) internal pure returns (Position left_) {
        assembly {
            left_ := shl(1, _position)
        }
    }

    /// @notice Get the right child of `_position`
    /// @param _position The position to get the right position of.
    /// @return right_ The position to the right of `position`.
    function right(Position _position) internal pure returns (Position right_) {
        assembly {
            right_ := or(1, shl(1, _position))
        }
    }

    /// @notice Get the parent position of `_position`.
    /// @param _position The position to get the parent position of.
    /// @return parent_ The parent position of `position`.
    function parent(Position _position) internal pure returns (Position parent_) {
        assembly {
            parent_ := shr(1, _position)
        }
    }

    /// @notice Get the deepest, right most gindex relative to the `position`. This is equivalent to
    ///         calling `right` on a position until the maximum depth is reached.
    /// @param _position The position to get the relative deepest, right most gindex of.
    /// @param _maxDepth The maximum depth of the game.
    /// @return rightIndex_ The deepest, right most gindex relative to the `position`.
    function rightIndex(Position _position, uint256 _maxDepth) internal pure returns (Position rightIndex_) {
        uint256 msb = depth(_position);
        assembly {
            let remaining := sub(_maxDepth, msb)
            rightIndex_ := or(shl(remaining, _position), sub(shl(remaining, 1), 1))
        }
    }

    /// @notice Get the deepest, right most trace index relative to the `position`. This is
    ///         equivalent to calling `right` on a position until the maximum depth is reached and
    ///         then finding its index at depth.
    /// @param _position The position to get the relative trace index of.
    /// @param _maxDepth The maximum depth of the game.
    /// @return traceIndex_ The trace index relative to the `position`.
    function traceIndex(Position _position, uint256 _maxDepth) internal pure returns (uint256 traceIndex_) {
        uint256 msb = depth(_position);
        assembly {
            let remaining := sub(_maxDepth, msb)
            traceIndex_ := sub(or(shl(remaining, _position), sub(shl(remaining, 1), 1)), shl(_maxDepth, 1))
        }
    }

    /// @notice Gets the position of the highest ancestor of `_position` that commits to the same
    ///         trace index.
    /// @param _position The position to get the highest ancestor of.
    /// @return ancestor_ The highest ancestor of `position` that commits to the same trace index.
    function traceAncestor(Position _position) internal pure returns (Position ancestor_) {
        // Create a field with only the lowest unset bit of `_position` set.
        Position lsb;
        assembly {
            lsb := and(not(_position), add(_position, 1))
        }
        // Find the index of the lowest unset bit within the field.
        uint256 msb = depth(lsb);
        // The highest ancestor that commits to the same trace index is the original position
        // shifted right by the index of the lowest unset bit.
        assembly {
            let a := shr(msb, _position)
            // Bound the ancestor to the minimum gindex, 1.
            ancestor_ := or(a, iszero(a))
        }
    }

    /// @notice Gets the position of the highest ancestor of `_position` that commits to the same
    ///         trace index, while still being below `_upperBoundExclusive`.
    /// @param _position The position to get the highest ancestor of.
    /// @param _upperBoundExclusive The exclusive upper depth bound, used to inform where to stop in order
    ///                             to not escape a sub-tree.
    /// @return ancestor_ The highest ancestor of `position` that commits to the same trace index.
    function traceAncestorBounded(
        Position _position,
        uint256 _upperBoundExclusive
    )
        internal
        pure
        returns (Position ancestor_)
    {
        // This function only works for positions that are below the upper bound.
        if (_position.depth() <= _upperBoundExclusive) {
            assembly {
                // Revert with `ClaimAboveSplit()`
                mstore(0x00, 0xb34b5c22)
                revert(0x1C, 0x04)
            }
        }

        // Grab the global trace ancestor.
        ancestor_ = traceAncestor(_position);

        // If the ancestor is above or at the upper bound, shift it to be below the upper bound.
        // This should be a special case that only covers positions that commit to the final leaf
        // in a sub-tree.
        if (ancestor_.depth() <= _upperBoundExclusive) {
            ancestor_ = ancestor_.rightIndex(_upperBoundExclusive + 1);
        }
    }

    /// @notice Get the move position of `_position`, which is the left child of:
    ///         1. `_position` if `_isAttack` is true.
    ///         2. `_position | 1` if `_isAttack` is false.
    /// @param _position The position to get the relative attack/defense position of.
    /// @param _isAttack Whether or not the move is an attack move.
    /// @return move_ The move position relative to `position`.
    function move(Position _position, bool _isAttack) internal pure returns (Position move_) {
        assembly {
            move_ := shl(1, or(iszero(_isAttack), _position))
        }
    }

    /// @notice Get the value of a `Position` type in the form of the underlying uint128.
    /// @param _position The position to get the value of.
    /// @return raw_ The value of the `position` as a uint128 type.
    function raw(Position _position) internal pure returns (uint128 raw_) {
        assembly {
            raw_ := _position
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// Libraries
import { Position } from "../../../src/dispute/lib/LibPosition.sol";

using LibClaim for Claim global;
using LibHash for Hash global;
using LibDuration for Duration global;
using LibClock for Clock global;
using LibGameId for GameId global;
using LibTimestamp for Timestamp global;
using LibVMStatus for VMStatus global;
using LibGameType for GameType global;

/// @notice A `Clock` represents a packed `Duration` and `Timestamp`
/// @dev The packed layout of this type is as follows:
/// ┌────────────┬────────────────┐
/// │    Bits    │     Value      │
/// ├────────────┼────────────────┤
/// │ [0, 64)    │ Duration       │
/// │ [64, 128)  │ Timestamp      │
/// └────────────┴────────────────┘
type Clock is uint128;

/// @title LibClock
/// @notice This library contains helper functions for working with the `Clock` type.
library LibClock {
    /// @notice Packs a `Duration` and `Timestamp` into a `Clock` type.
    /// @param _duration The `Duration` to pack into the `Clock` type.
    /// @param _timestamp The `Timestamp` to pack into the `Clock` type.
    /// @return clock_ The `Clock` containing the `_duration` and `_timestamp`.
    function wrap(Duration _duration, Timestamp _timestamp) internal pure returns (Clock clock_) {
        assembly {
            clock_ := or(shl(0x40, _duration), _timestamp)
        }
    }

    /// @notice Pull the `Duration` out of a `Clock` type.
    /// @param _clock The `Clock` type to pull the `Duration` out of.
    /// @return duration_ The `Duration` pulled out of `_clock`.
    function duration(Clock _clock) internal pure returns (Duration duration_) {
        // Shift the high-order 64 bits into the low-order 64 bits, leaving only the `duration`.
        assembly {
            duration_ := shr(0x40, _clock)
        }
    }

    /// @notice Pull the `Timestamp` out of a `Clock` type.
    /// @param _clock The `Clock` type to pull the `Timestamp` out of.
    /// @return timestamp_ The `Timestamp` pulled out of `_clock`.
    function timestamp(Clock _clock) internal pure returns (Timestamp timestamp_) {
        // Clean the high-order 192 bits by shifting the clock left and then right again, leaving
        // only the `timestamp`.
        assembly {
            timestamp_ := shr(0xC0, shl(0xC0, _clock))
        }
    }

    /// @notice Get the value of a `Clock` type in the form of the underlying uint128.
    /// @param _clock The `Clock` type to get the value of.
    /// @return clock_ The value of the `Clock` type as a uint128 type.
    function raw(Clock _clock) internal pure returns (uint128 clock_) {
        assembly {
            clock_ := _clock
        }
    }
}

/// @notice A `GameId` represents a packed 4 byte game ID, a 8 byte timestamp, and a 20 byte address.
/// @dev The packed layout of this type is as follows:
/// ┌───────────┬───────────┐
/// │   Bits    │   Value   │
/// ├───────────┼───────────┤
/// │ [0, 32)   │ Game Type │
/// │ [32, 96)  │ Timestamp │
/// │ [96, 256) │ Address   │
/// └───────────┴───────────┘
type GameId is bytes32;

/// @title LibGameId
/// @notice Utility functions for packing and unpacking GameIds.
library LibGameId {
    /// @notice Packs values into a 32 byte GameId type.
    /// @param _gameType The game type.
    /// @param _timestamp The timestamp of the game's creation.
    /// @param _gameProxy The game proxy address.
    /// @return gameId_ The packed GameId.
    function pack(
        GameType _gameType,
        Timestamp _timestamp,
        address _gameProxy
    )
        internal
        pure
        returns (GameId gameId_)
    {
        assembly {
            gameId_ := or(or(shl(224, _gameType), shl(160, _timestamp)), _gameProxy)
        }
    }

    /// @notice Unpacks values from a 32 byte GameId type.
    /// @param _gameId The packed GameId.
    /// @return gameType_ The game type.
    /// @return timestamp_ The timestamp of the game's creation.
    /// @return gameProxy_ The game proxy address.
    function unpack(GameId _gameId)
        internal
        pure
        returns (GameType gameType_, Timestamp timestamp_, address gameProxy_)
    {
        assembly {
            gameType_ := shr(224, _gameId)
            timestamp_ := and(shr(160, _gameId), 0xFFFFFFFFFFFFFFFF)
            gameProxy_ := and(_gameId, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        }
    }
}

/// @notice A claim represents an MPT root representing the state of the fault proof program.
type Claim is bytes32;

/// @title LibClaim
/// @notice This library contains helper functions for working with the `Claim` type.
library LibClaim {
    /// @notice Get the value of a `Claim` type in the form of the underlying bytes32.
    /// @param _claim The `Claim` type to get the value of.
    /// @return claim_ The value of the `Claim` type as a bytes32 type.
    function raw(Claim _claim) internal pure returns (bytes32 claim_) {
        assembly {
            claim_ := _claim
        }
    }

    /// @notice Hashes a claim and a position together.
    /// @param _claim A Claim type.
    /// @param _position The position of `claim`.
    /// @param _challengeIndex The index of the claim being moved against.
    /// @return claimHash_ A hash of abi.encodePacked(claim, position|challengeIndex);
    function hashClaimPos(
        Claim _claim,
        Position _position,
        uint256 _challengeIndex
    )
        internal
        pure
        returns (Hash claimHash_)
    {
        assembly {
            mstore(0x00, _claim)
            mstore(0x20, or(shl(128, _position), and(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, _challengeIndex)))
            claimHash_ := keccak256(0x00, 0x40)
        }
    }
}

/// @notice A dedicated duration type.
/// @dev Unit: seconds
type Duration is uint64;

/// @title LibDuration
/// @notice This library contains helper functions for working with the `Duration` type.
library LibDuration {
    /// @notice Get the value of a `Duration` type in the form of the underlying uint64.
    /// @param _duration The `Duration` type to get the value of.
    /// @return duration_ The value of the `Duration` type as a uint64 type.
    function raw(Duration _duration) internal pure returns (uint64 duration_) {
        assembly {
            duration_ := _duration
        }
    }
}

/// @notice A custom type for a generic hash.
type Hash is bytes32;

/// @title LibHash
/// @notice This library contains helper functions for working with the `Hash` type.
library LibHash {
    /// @notice Get the value of a `Hash` type in the form of the underlying bytes32.
    /// @param _hash The `Hash` type to get the value of.
    /// @return hash_ The value of the `Hash` type as a bytes32 type.
    function raw(Hash _hash) internal pure returns (bytes32 hash_) {
        assembly {
            hash_ := _hash
        }
    }
}

/// @notice A dedicated timestamp type.
type Timestamp is uint64;

/// @title LibTimestamp
/// @notice This library contains helper functions for working with the `Timestamp` type.
library LibTimestamp {
    /// @notice Get the value of a `Timestamp` type in the form of the underlying uint64.
    /// @param _timestamp The `Timestamp` type to get the value of.
    /// @return timestamp_ The value of the `Timestamp` type as a uint64 type.
    function raw(Timestamp _timestamp) internal pure returns (uint64 timestamp_) {
        assembly {
            timestamp_ := _timestamp
        }
    }
}

/// @notice A `VMStatus` represents the status of a VM execution.
type VMStatus is uint8;

/// @title LibVMStatus
/// @notice This library contains helper functions for working with the `VMStatus` type.
library LibVMStatus {
    /// @notice Get the value of a `VMStatus` type in the form of the underlying uint8.
    /// @param _vmstatus The `VMStatus` type to get the value of.
    /// @return vmstatus_ The value of the `VMStatus` type as a uint8 type.
    function raw(VMStatus _vmstatus) internal pure returns (uint8 vmstatus_) {
        assembly {
            vmstatus_ := _vmstatus
        }
    }
}

/// @notice A `GameType` represents the type of game being played.
type GameType is uint32;

/// @title LibGameType
/// @notice This library contains helper functions for working with the `GameType` type.
library LibGameType {
    /// @notice Get the value of a `GameType` type in the form of the underlying uint32.
    /// @param _gametype The `GameType` type to get the value of.
    /// @return gametype_ The value of the `GameType` type as a uint32 type.
    function raw(GameType _gametype) internal pure returns (uint32 gametype_) {
        assembly {
            gametype_ := _gametype
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// Libraries
import {
    Position,
    Hash,
    GameType,
    VMStatus,
    Timestamp,
    Duration,
    Clock,
    GameId,
    Claim,
    LibGameId,
    LibClock
} from "../../../src/dispute/lib/LibUDT.sol";

/// @notice The current status of the dispute game.
enum GameStatus {
    // The game is currently in progress, and has not been resolved.
    IN_PROGRESS,
    // The game has concluded, and the `rootClaim` was challenged successfully.
    CHALLENGER_WINS,
    // The game has concluded, and the `rootClaim` could not be contested.
    DEFENDER_WINS
}

/// @notice Represents an L2 output root and the L2 block number at which it was generated.
/// @custom:field root The output root.
/// @custom:field l2BlockNumber The L2 block number at which the output root was generated.
struct OutputRoot {
    Hash root;
    uint256 l2BlockNumber;
}

/// @title GameTypes
/// @notice A library that defines the IDs of games that can be played.
library GameTypes {
    /// @dev A dispute game type the uses the cannon vm.
    GameType internal constant CANNON = GameType.wrap(0);

    /// @dev A permissioned dispute game type the uses the cannon vm.
    GameType internal constant PERMISSIONED_CANNON = GameType.wrap(1);

    /// @notice A dispute game type the uses the asterisc VM
    GameType internal constant ASTERISC = GameType.wrap(2);

    /// @notice A dispute game type with short game duration for testing withdrawals.
    ///         Not intended for production use.
    GameType internal constant FAST = GameType.wrap(254);

    /// @notice A dispute game type that uses an alphabet vm.
    ///         Not intended for production use.
    GameType internal constant ALPHABET = GameType.wrap(255);
}

/// @title VMStatuses
/// @notice Named type aliases for the various valid VM status bytes.
library VMStatuses {
    /// @notice The VM has executed successfully and the outcome is valid.
    VMStatus internal constant VALID = VMStatus.wrap(0);

    /// @notice The VM has executed successfully and the outcome is invalid.
    VMStatus internal constant INVALID = VMStatus.wrap(1);

    /// @notice The VM has paniced.
    VMStatus internal constant PANIC = VMStatus.wrap(2);

    /// @notice The VM execution is still in progress.
    VMStatus internal constant UNFINISHED = VMStatus.wrap(3);
}

/// @title LocalPreimageKey
/// @notice Named type aliases for local `PreimageOracle` key identifiers.
library LocalPreimageKey {
    /// @notice The identifier for the L1 head hash.
    uint256 internal constant L1_HEAD_HASH = 0x01;

    /// @notice The identifier for the starting output root.
    uint256 internal constant STARTING_OUTPUT_ROOT = 0x02;

    /// @notice The identifier for the disputed output root.
    uint256 internal constant DISPUTED_OUTPUT_ROOT = 0x03;

    /// @notice The identifier for the disputed L2 block number.
    uint256 internal constant DISPUTED_L2_BLOCK_NUMBER = 0x04;

    /// @notice The identifier for the chain ID.
    uint256 internal constant CHAIN_ID = 0x05;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Types
/// @notice Contains various types used throughout the Optimism contract system.
library Types {
    /// @notice OutputProposal represents a commitment to the L2 state. The timestamp is the L1
    ///         timestamp that the output root is posted. This timestamp is used to verify that the
    ///         finalization period has passed since the output root was submitted.
    /// @custom:field outputRoot    Hash of the L2 output.
    /// @custom:field timestamp     Timestamp of the L1 block that the output root was submitted in.
    /// @custom:field l2BlockNumber L2 block number that the output corresponds to.
    struct OutputProposal {
        bytes32 outputRoot;
        uint128 timestamp;
        uint128 l2BlockNumber;
    }

    /// @notice Struct representing the elements that are hashed together to generate an output root
    ///         which itself represents a snapshot of the L2 state.
    /// @custom:field version                  Version of the output root.
    /// @custom:field stateRoot                Root of the state trie at the block of this output.
    /// @custom:field messagePasserStorageRoot Root of the message passer storage trie.
    /// @custom:field latestBlockhash          Hash of the block this output was generated from.
    struct OutputRootProof {
        bytes32 version;
        bytes32 stateRoot;
        bytes32 messagePasserStorageRoot;
        bytes32 latestBlockhash;
    }

    /// @notice Struct representing a deposit transaction (L1 => L2 transaction) created by an end
    ///         user (as opposed to a system deposit transaction generated by the system).
    /// @custom:field from        Address of the sender of the transaction.
    /// @custom:field to          Address of the recipient of the transaction.
    /// @custom:field isCreation  True if the transaction is a contract creation.
    /// @custom:field value       Value to send to the recipient.
    /// @custom:field mint        Amount of ETH to mint.
    /// @custom:field gasLimit    Gas limit of the transaction.
    /// @custom:field data        Data of the transaction.
    /// @custom:field l1BlockHash Hash of the block the transaction was submitted in.
    /// @custom:field logIndex    Index of the log in the block the transaction was submitted in.
    struct UserDepositTransaction {
        address from;
        address to;
        bool isCreation;
        uint256 value;
        uint256 mint;
        uint64 gasLimit;
        bytes data;
        bytes32 l1BlockHash;
        uint256 logIndex;
    }

    /// @notice Struct representing a withdrawal transaction.
    /// @custom:field nonce    Nonce of the withdrawal transaction
    /// @custom:field sender   Address of the sender of the transaction.
    /// @custom:field target   Address of the recipient of the transaction.
    /// @custom:field value    Value to send to the recipient.
    /// @custom:field gasLimit Gas limit of the transaction.
    /// @custom:field data     Data of the transaction.
    struct WithdrawalTransaction {
        uint256 nonce;
        address sender;
        address target;
        uint256 value;
        uint256 gasLimit;
        bytes data;
    }

    /// @notice Enum representing where the FeeVault withdraws funds to.
    /// @custom:value L1 FeeVault withdraws funds to L1.
    /// @custom:value L2 FeeVault withdraws funds to L2.
    enum WithdrawalNetwork {
        L1,
        L2
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// $BLOBZ tokens can be mined by any transaction that:
// - is sent from an EOA (not a contract)
// - calls the mint() function of this contract
// - contains *exactly one* blob (containing whatever you want!)
//
// The initial amount of tokens emitted per mint() call is 1M, but this amount decreases gradually
// over time. After 30 days, the mint() amount will have decreased to 1M/2, or 500K tokens.
// After 60 days, the amount will reach 1M/3, or 333K tokens. After 90 days, 1M/4, and so on.
// Emissions are reduced when demand for blobs is high by dividing by the blobbasefee in Gwei.
//
// The growth in supply of $BLOBZ is bounded by the logarithm in time elapsed since inception,
// ensuring scarcity.

import {IOptimismPortal2 as IOptimismPortal} from "@optimism/interfaces/L1/IOptimismPortal2.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

interface IBlobzToken {
    function mintTo(address to, uint256 amount) external;
}

contract BlobzMinter is Initializable {
    function initialize(address _tokenAddress, address payable _optimismPortalAddress) public initializer {
        TOKEN_ADDRESS = _tokenAddress;
        OPTIMISM_PORTAL_ADDRESS = _optimismPortalAddress;
    }

    // the address of the $BLOBZ token contract on the Base chain
    address internal TOKEN_ADDRESS;
    // the address of the Base OptimismPortal contract on Ethereum
    address payable internal OPTIMISM_PORTAL_ADDRESS;
    // the address to send any ETH sent to this contract
    address payable internal DONATION_ADDRESS = payable(0xb26169eE03Df574eCBA5ca6550462359B587537f);

    // block.timestamp must be greater than START_TIME before minting is allowed
    uint256 internal immutable START_TIME = 1735754400; // 2025-01-01 10:00:00 AM PST
    uint256 internal immutable HALVING_DURATION = 2592000; // 30 days in seconds
    uint256 internal immutable INITIAL_EMISSION_AMOUNT = 1_000_000 * 10 ** 18;

    function _amount() internal view returns (uint256) {
        unchecked {
            uint256 elapsed = block.timestamp - START_TIME;
            uint256 blobBaseFeeDivisor = block.blobbasefee / 1 gwei;
            if (blobBaseFeeDivisor == 0) {
                blobBaseFeeDivisor = 1;
            }
            uint256 mintAmount =
                (INITIAL_EMISSION_AMOUNT * HALVING_DURATION) / (HALVING_DURATION + elapsed) / blobBaseFeeDivisor;
            if (mintAmount == 0) {
                // allow for infinite tail emission after we run out of precision.
                mintAmount = 1;
            }
            return mintAmount;
        }
    }

    // returns the current amount of tokens that would be minted with a successfull mint()
    function amount() public view returns (uint256) {
        if (block.timestamp <= START_TIME) {
            return 0;
        }
        return _amount();
    }

    event Mint(address indexed _to, bytes32 indexed _blobhash, uint256 _value);

    // mints $BLOBZ tokens to the caller's address on Base L2 if the transaction meets the minting criteria
    function mint() public payable {
        mintTo(msg.sender);
    }

    // mints $BLOBZ tokens to the provided address on the Base L2 if the transaction meets the minting criteria
    function mintTo(address _to) public payable {
        require(tx.origin == msg.sender, "not an EOA, no tokens for you!");
        require(blobhash(0) != bytes32(0), "no blob, no tokens for you!");
        require(blobhash(1) == bytes32(0), "too many blobs, no tokens for you!");

        // revert if we haven't reached the start time yet
        require(block.timestamp > START_TIME, "minting not open yet, no tokens for you!");

        if (msg.value > 0) {
            DONATION_ADDRESS.transfer(msg.value); // don't strand ETH sent to this contract
        }

        uint256 mintAmount = _amount();
        _mint(_to, mintAmount);
        emit Mint(_to, blobhash(0), mintAmount);
    }

    function _mint(address to, uint256 amt) internal {
        IOptimismPortal portal = IOptimismPortal(OPTIMISM_PORTAL_ADDRESS);
        portal.depositTransaction({
            _to: TOKEN_ADDRESS,
            _value: 0,
            _gasLimit: 100000,
            _isCreation: false,
            _data: abi.encodeCall(IBlobzToken.mintTo, (to, amt))
        });
    }
}