// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

/// @dev `keccak256("")`
bytes32 constant EMPTY_STRING_KECCAK = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

/// @dev Bytes in raw L2 log
/// @dev Equal to the bytes size of the tuple - (uint8 ShardId, bool isService, uint16 txNumberInBatch, address sender,
/// bytes32 key, bytes32 value)
uint256 constant L2_TO_L1_LOG_SERIALIZE_SIZE = 88;

/// @dev The maximum length of the bytes array with L2 -> L1 logs
uint256 constant MAX_L2_TO_L1_LOGS_COMMITMENT_BYTES = 4 + L2_TO_L1_LOG_SERIALIZE_SIZE * 512;

/// @dev The value of default leaf hash for L2 -> L1 logs Merkle tree
/// @dev An incomplete fixed-size tree is filled with this value to be a full binary tree
/// @dev Actually equal to the `keccak256(new bytes(L2_TO_L1_LOG_SERIALIZE_SIZE))`
bytes32 constant L2_L1_LOGS_TREE_DEFAULT_LEAF_HASH = 0x72abee45b59e344af8a6e520241c4744aff26ed411f4c4b00f8af09adada43ba;

bytes32 constant DEFAULT_L2_LOGS_TREE_ROOT_HASH = bytes32(0);

/// @dev Denotes the type of the ZKsync transaction that came from L1.
uint256 constant PRIORITY_OPERATION_L2_TX_TYPE = 255;

/// @dev Denotes the type of the ZKsync transaction that is used for system upgrades.
uint256 constant SYSTEM_UPGRADE_L2_TX_TYPE = 254;

/// @dev The maximal allowed difference between protocol minor versions in an upgrade. The 100 gap is needed
/// in case a protocol version has been tested on testnet, but then not launched on mainnet, e.g.
/// due to a bug found.
/// We are allowed to jump at most 100 minor versions at a time. The major version is always expected to be 0.
uint256 constant MAX_ALLOWED_MINOR_VERSION_DELTA = 100;

/// @dev The amount of time in seconds the validator has to process the priority transaction
/// NOTE: The constant is set to zero for the Alpha release period
uint256 constant PRIORITY_EXPIRATION = 0 days;

/// @dev Timestamp - seconds since unix epoch.
uint256 constant COMMIT_TIMESTAMP_NOT_OLDER = 3 days;

/// @dev Maximum available error between real commit batch timestamp and analog used in the verifier (in seconds)
/// @dev Must be used cause miner's `block.timestamp` value can differ on some small value (as we know - 12 seconds)
uint256 constant COMMIT_TIMESTAMP_APPROXIMATION_DELTA = 1 hours;

/// @dev Shift to apply to verify public input before verifying.
uint256 constant PUBLIC_INPUT_SHIFT = 32;

/// @dev The maximum number of L2 gas that a user can request for an L2 transaction
uint256 constant MAX_GAS_PER_TRANSACTION = 80_000_000;

/// @dev Even though the price for 1 byte of pubdata is 16 L1 gas, we have a slightly increased
/// value.
uint256 constant L1_GAS_PER_PUBDATA_BYTE = 17;

/// @dev The intrinsic cost of the L1->l2 transaction in computational L2 gas
uint256 constant L1_TX_INTRINSIC_L2_GAS = 167_157;

/// @dev The intrinsic cost of the L1->l2 transaction in pubdata
uint256 constant L1_TX_INTRINSIC_PUBDATA = 88;

/// @dev The minimal base price for L1 transaction
uint256 constant L1_TX_MIN_L2_GAS_BASE = 173_484;

/// @dev The number of L2 gas the transaction starts costing more with each 544 bytes of encoding
uint256 constant L1_TX_DELTA_544_ENCODING_BYTES = 1656;

/// @dev The number of L2 gas an L1->L2 transaction gains with each new factory dependency
uint256 constant L1_TX_DELTA_FACTORY_DEPS_L2_GAS = 2473;

/// @dev The number of L2 gas an L1->L2 transaction gains with each new factory dependency
uint256 constant L1_TX_DELTA_FACTORY_DEPS_PUBDATA = 64;

/// @dev The number of pubdata an L1->L2 transaction requires with each new factory dependency
uint256 constant MAX_NEW_FACTORY_DEPS = 64;

/// @dev The L2 gasPricePerPubdata required to be used in bridges.
uint256 constant REQUIRED_L2_GAS_PRICE_PER_PUBDATA = 800;

/// @dev The mask which should be applied to the packed batch and L2 block timestamp in order
/// to obtain the L2 block timestamp. Applying this mask is equivalent to calculating modulo 2**128
uint256 constant PACKED_L2_BLOCK_TIMESTAMP_MASK = 0xffffffffffffffffffffffffffffffff;

/// @dev Address of the point evaluation precompile used for EIP-4844 blob verification.
address constant POINT_EVALUATION_PRECOMPILE_ADDR = address(0x0A);

/// @dev The overhead for a transaction slot in L2 gas.
/// It is roughly equal to 80kk/MAX_TRANSACTIONS_IN_BATCH, i.e. how many gas would an L1->L2 transaction
/// need to pay to compensate for the batch being closed.
/// @dev It is expected that the L1 contracts will enforce that the L2 gas price will be high enough to compensate
/// the operator in case the batch is closed because of tx slots filling up.
uint256 constant TX_SLOT_OVERHEAD_L2_GAS = 10000;

/// @dev The overhead for each byte of the bootloader memory that the encoding of the transaction.
/// It is roughly equal to 80kk/BOOTLOADER_MEMORY_FOR_TXS, i.e. how many gas would an L1->L2 transaction
/// need to pay to compensate for the batch being closed.
/// @dev It is expected that the L1 contracts will enforce that the L2 gas price will be high enough to compensate
/// the operator in case the batch is closed because of the memory for transactions being filled up.
uint256 constant MEMORY_OVERHEAD_GAS = 10;

/// @dev The maximum gas limit for a priority transaction in L2.
uint256 constant PRIORITY_TX_MAX_GAS_LIMIT = 72_000_000;

/// @dev the address used to identify eth as the base token for chains.
address constant ETH_TOKEN_ADDRESS = address(1);

/// @dev the value returned in bridgehubDeposit in the TwoBridges function.
bytes32 constant TWO_BRIDGES_MAGIC_VALUE = bytes32(uint256(keccak256("TWO_BRIDGES_MAGIC_VALUE")) - 1);

/// @dev https://eips.ethereum.org/EIPS/eip-1352
address constant BRIDGEHUB_MIN_SECOND_BRIDGE_ADDRESS = address(uint160(type(uint16).max));

/// @dev the maximum number of supported chains, this is an arbitrary limit.
/// @dev Note, that in case of a malicious Bridgehub admin, the total number of chains
/// can be up to 2 times higher. This may be possible, in case the old ChainTypeManager
/// had `100` chains and these were migrated to the Bridgehub only after `MAX_NUMBER_OF_ZK_CHAINS`
/// were added to the bridgehub via creation of new chains.
uint256 constant MAX_NUMBER_OF_ZK_CHAINS = 100;

/// @dev Used as the `msg.sender` for transactions that relayed via a settlement layer.
address constant SETTLEMENT_LAYER_RELAY_SENDER = address(uint160(0x1111111111111111111111111111111111111111));

/// @dev The metadata version that is supported by the ZK Chains to prove that an L2->L1 log was included in a batch.
uint256 constant SUPPORTED_PROOF_METADATA_VERSION = 1;

/// @dev The virtual address of the L1 settlement layer.
address constant L1_SETTLEMENT_LAYER_VIRTUAL_ADDRESS = address(
    uint160(uint256(keccak256("L1_SETTLEMENT_LAYER_VIRTUAL_ADDRESS")) - 1)
);

struct PriorityTreeCommitment {
    uint256 nextLeafIndex;
    uint256 startIndex;
    uint256 unprocessedIndex;
    bytes32[] sides;
}

// Info that allows to restore a chain.
struct ZKChainCommitment {
    /// @notice Total number of executed batches i.e. batches[totalBatchesExecuted] points at the latest executed batch
    /// (batch 0 is genesis)
    uint256 totalBatchesExecuted;
    /// @notice Total number of proved batches i.e. batches[totalBatchesProved] points at the latest proved batch
    uint256 totalBatchesVerified;
    /// @notice Total number of committed batches i.e. batches[totalBatchesCommitted] points at the latest committed
    /// batch
    uint256 totalBatchesCommitted;
    /// @notice The hash of the L2 system contracts ugpgrade transaction.
    /// @dev It is non zero if the migration happens while the upgrade is not yet finalized.
    bytes32 l2SystemContractsUpgradeTxHash;
    /// @notice The batch when the system contracts upgrade transaction was executed.
    /// @dev It is non-zero if the migration happens while the batch where the upgrade tx was present
    /// has not been finalized (executed) yet.
    uint256 l2SystemContractsUpgradeBatchNumber;
    /// @notice The hashes of the batches that are needed to keep the blockchain working.
    /// @dev The length of the array is equal to the `totalBatchesCommitted - totalBatchesExecuted + 1`, i.e. we need
    /// to store all the unexecuted batches' hashes + 1 latest executed one.
    bytes32[] batchHashes;
    /// @notice Commitment to the priority merkle tree.
    PriorityTreeCommitment priorityTree;
    /// @notice Whether a chain is a permanent rollup.
    bool isPermanentRollup;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 0x5ecf2d7a
error AccessToFallbackDenied(address target, address invoker);
// 0x3995f750
error AccessToFunctionDenied(address target, bytes4 selector, address invoker);
// 0x6c167909
error OnlySelfAllowed();
// 0x52e22c98
error RestrictionWasNotPresent(address restriction);
// 0xf126e113
error RestrictionWasAlreadyPresent(address restriction);
// 0x3331e9c0
error CallNotAllowed(bytes call);
// 0xf6fd7071
error RemovingPermanentRestriction();
// 0xfcb9b2e1
error UnallowedImplementation(bytes32 implementationHash);
// 0x1ff9d522
error AddressAlreadyUsed(address addr);
// 0x0dfb42bf
error AddressAlreadySet(address addr);
// 0x86bb51b8
error AddressHasNoCode(address);
// 0x1f73225f
error AddressMismatch(address expected, address supplied);
// 0x5e85ae73
error AmountMustBeGreaterThanZero();
// 0xfde974f4
error AssetHandlerDoesNotExist(bytes32 assetId);
// 0x1294e9e1
error AssetIdMismatch(bytes32 expected, bytes32 supplied);
// 0xfe919e28
error AssetIdAlreadyRegistered();
// 0x0bfcef28
error AlreadyWhitelisted(address);
// 0x04a0b7e9
error AssetIdNotSupported(bytes32 assetId);
// 0x6ef9a972
error BaseTokenGasPriceDenominatorNotSet();
// 0x55ad3fd3
error BatchHashMismatch(bytes32 expected, bytes32 actual);
// 0x2078a6a0
error BatchNotExecuted(uint256 batchNumber);
// 0xbd4455ff
error BatchNumberMismatch(uint256 expectedBatchNumber, uint256 providedBatchNumber);
// 0x6cf12312
error BridgeHubAlreadyRegistered();
// 0xdb538614
error BridgeMintNotImplemented();
// 0xe85392f9
error CanOnlyProcessOneBatch();
// 0x00c6ead2
error CantExecuteUnprovenBatches();
// 0xe18cb383
error CantRevertExecutedBatch();
// 0x24591d89
error ChainIdAlreadyExists();
// 0x717a1656
error ChainIdCantBeCurrentChain();
// 0xa179f8c9
error ChainIdMismatch();
// 0x23f3c357
error ChainIdNotRegistered(uint256 chainId);
// 0x8f620a06
error ChainIdTooBig();
// 0xf7a01e4d
error DelegateCallFailed(bytes returnData);
// 0x0a8ed92c
error DenominatorIsZero();
// 0xb4f54111
error DeployFailed();
// 0x138ee1a3
error DeployingBridgedTokenForNativeToken();
// 0xc7c9660f
error DepositDoesNotExist();
// 0xad2fa98e
error DepositExists();
// 0x0e7ee319
error DiamondAlreadyFrozen();
// 0xa7151b9a
error DiamondNotFrozen();
// 0x7138356f
error EmptyAddress();
// 0x2d4d012f
error EmptyAssetId();
// 0x1c25715b
error EmptyBytes32();
// 0x95b66fe9
error EmptyDeposit();
// 0x627e0872
error ETHDepositNotSupported();
// 0xac4a3f98
error FacetExists(bytes4 selector, address);
// 0xc91cf3b1
error GasPerPubdataMismatch();
// 0x6d4a7df8
error GenesisBatchCommitmentZero();
// 0x7940c83f
error GenesisBatchHashZero();
// 0xb4fc6835
error GenesisIndexStorageZero();
// 0x3a1a8589
error GenesisUpgradeZero();
// 0xd356e6ba
error HashedLogIsDefault();
// 0x0b08d5be
error HashMismatch(bytes32 expected, bytes32 actual);
// 0x601b6882
error ZKChainLimitReached();
// 0xdd381a4c
error IncorrectBridgeHubAddress(address bridgehub);
// 0x826fb11e
error InsufficientChainBalance();
// 0xcbd9d2e0
error InvalidCaller(address);
// 0x4fbe5dba
error InvalidDelay();
// 0xc1780bd6
error InvalidLogSender(address sender, uint256 logKey);
// 0xd8e9405c
error InvalidNumberOfBlobs(uint256 expected, uint256 numCommitments, uint256 numHashes);
// 0x09bde339
error InvalidProof();
// 0x5428eae7
error InvalidProtocolVersion();
// 0x5513177c
error InvalidPubdataHash(bytes32 expectedHash, bytes32 provided);
// 0x6f1cf752
error InvalidPubdataPricingMode();
// 0x12ba286f
error InvalidSelector(bytes4 func);
// 0x5cb29523
error InvalidTxType(uint256 txType);
// 0x0214acb6
error InvalidUpgradeTxn(UpgradeTxVerifyParam);
// 0xfb5c22e6
error L2TimestampTooBig();
// 0xd2c011d6
error L2UpgradeNonceNotEqualToNewProtocolVersion(uint256 nonce, uint256 protocolVersion);
// 0x97e1359e
error L2WithdrawalMessageWrongLength(uint256 messageLen);
// 0xe37d2c02
error LengthIsNotDivisibleBy32(uint256 length);
// 0x1b6825bb
error LogAlreadyProcessed(uint8);
// 0xcea34703
error MalformedBytecode(BytecodeError);
// 0x9bb54c35
error MerkleIndexOutOfBounds();
// 0x8e23ac1a
error MerklePathEmpty();
// 0x1c500385
error MerklePathOutOfBounds();
// 0x3312a450
error MigrationPaused();
// 0xfa44b527
error MissingSystemLogs(uint256 expected, uint256 actual);
// 0x4a094431
error MsgValueMismatch(uint256 expectedMsgValue, uint256 providedMsgValue);
// 0xb385a3da
error MsgValueTooLow(uint256 required, uint256 provided);
// 0x72ea85ad
error NewProtocolMajorVersionNotZero();
// 0x79cc2d22
error NoCallsProvided();
// 0xa6fef710
error NoFunctionsForDiamondCut();
// 0xcab098d8
error NoFundsTransferred();
// 0xc21b1ab7
error NonEmptyCalldata();
// 0x536ec84b
error NonEmptyMsgValue();
// 0xd018e08e
error NonIncreasingTimestamp();
// 0x0105f9c0
error NonSequentialBatch();
// 0x0ac76f01
error NonSequentialVersion();
// 0xdd629f86
error NotEnoughGas();
// 0xdd7e3621
error NotInitializedReentrancyGuard();
// 0xdf17e316
error NotWhitelisted(address);
// 0xf3ed9dfa
error OnlyEraSupported();
// 0x1a21feed
error OperationExists();
// 0xeda2fbb1
error OperationMustBePending();
// 0xe1c1ff37
error OperationMustBeReady();
// 0xb926450e
error OriginChainIdNotFound();
// 0xd7f50a9d
error PatchCantSetUpgradeTxn();
// 0x962fd7d0
error PatchUpgradeCantSetBootloader();
// 0x559cc34e
error PatchUpgradeCantSetDefaultAccount();
// 0x9b48e060
error PreviousOperationNotExecuted();
// 0x5c598b60
error PreviousProtocolMajorVersionNotZero();
// 0xa0f47245
error PreviousUpgradeNotCleaned();
// 0x101ba748
error PreviousUpgradeNotFinalized(bytes32 txHash);
// 0xd5a99014
error PriorityOperationsRollingHashMismatch();
// 0x1a4d284a
error PriorityTxPubdataExceedsMaxPubDataPerBatch();
// 0xa461f651
error ProtocolIdMismatch(uint256 expectedProtocolVersion, uint256 providedProtocolId);
// 0x64f94ec2
error ProtocolIdNotGreater();
// 0xd328c12a
error ProtocolVersionMinorDeltaTooBig(uint256 limit, uint256 proposed);
// 0x88d7b498
error ProtocolVersionTooSmall();
// 0x53dee67b
error PubdataCommitmentsEmpty();
// 0x959f26fb
error PubdataGreaterThanLimit(uint256 limit, uint256 length);
// 0x63c36549
error QueueIsEmpty();
// 0xab143c06
error Reentrancy();
// 0x667d17de
error RemoveFunctionFacetAddressNotZero(address facet);
// 0xa2d4b16c
error RemoveFunctionFacetAddressZero();
// 0x3580370c
error ReplaceFunctionFacetAddressZero();
// 0x9a67c1cb
error RevertedBatchNotAfterNewLastBatch();
// 0xd3b6535b
error SelectorsMustAllHaveSameFreezability();
// 0xd7a6b5e6
error SharedBridgeValueNotSet(SharedBridgeKey);
// 0x856d5b77
error SharedBridgeNotSet();
// 0xdf3a8fdd
error SlotOccupied();
// 0xec273439
error CTMAlreadyRegistered();
// 0xc630ef3c
error CTMNotRegistered();
// 0xae43b424
error SystemLogsSizeTooBig();
// 0x08753982
error TimeNotReached(uint256 expectedTimestamp, uint256 actualTimestamp);
// 0x2d50c33b
error TimestampError();
// 0x06439c6b
error TokenNotSupported(address token);
// 0x23830e28
error TokensWithFeesNotSupported();
// 0x76da24b9
error TooManyFactoryDeps();
// 0xf0b4e88f
error TooMuchGas();
// 0x00c5a6a9
error TransactionNotAllowed();
// 0x4c991078
error TxHashMismatch();
// 0x2e311df8
error TxnBodyGasLimitNotEnoughGas();
// 0x8e4a23d6
error Unauthorized(address caller);
// 0xe52478c7
error UndefinedDiamondCutAction();
// 0x6aa39880
error UnexpectedSystemLog(uint256 logKey);
// 0xf093c2e5
error UpgradeBatchNumberIsNotZero();
// 0x084a1449
error UnsupportedEncodingVersion();
// 0x47b3b145
error ValidateTxnNotEnoughGas();
// 0x626ade30
error ValueMismatch(uint256 expected, uint256 actual);
// 0xe1022469
error VerifiedBatchesExceedsCommittedBatches();
// 0xae899454
error WithdrawalAlreadyFinalized();
// 0x750b219c
error WithdrawFailed();
// 0x15e8e429
error WrongMagicValue(uint256 expectedMagicValue, uint256 providedMagicValue);
// 0xd92e233d
error ZeroAddress();
// 0xc84885d4
error ZeroChainId();
// 0x99d8fec9
error EmptyData();
// 0xf3dd1b9c
error UnsupportedCommitBatchEncoding(uint8 version);
// 0xf338f830
error UnsupportedProofBatchEncoding(uint8 version);
// 0x14d2ed8a
error UnsupportedExecuteBatchEncoding(uint8 version);
// 0xd7d93e1f
error IncorrectBatchBounds(
    uint256 processFromExpected,
    uint256 processToExpected,
    uint256 processFromProvided,
    uint256 processToProvided
);
// 0x64107968
error AssetHandlerNotRegistered(bytes32 assetId);
// 0x64846fe4
error NotARestriction(address addr);
// 0xfa5cd00f
error NotAllowed(address addr);
// 0xccdd18d2
error BytecodeAlreadyPublished(bytes32 bytecodeHash);
// 0x25d8333c
error CallerNotTimerAdmin();
// 0x907f8e51
error DeadlineNotYetPassed();
// 0x6eef58d1
error NewDeadlineNotGreaterThanCurrent();
// 0x8b7e144a
error NewDeadlineExceedsMaxDeadline();
// 0x2a5989a0
error AlreadyPermanentRollup();
// 0x92daded2
error InvalidDAForPermanentRollup();
// 0xd0266e26
error NotSettlementLayer();
// 0x7a4902ad
error TimerAlreadyStarted();

// 0x09aa9830
error MerklePathLengthMismatch(uint256 pathLength, uint256 expectedLength);

// 0xc33e6128
error MerkleNothingToProve();

// 0xafbb7a4e
error MerkleIndexOrHeightMismatch();

// 0x1b582fcf
error MerkleWrongIndex(uint256 index, uint256 maxNodeNumber);

// 0x485cfcaa
error MerkleWrongLength(uint256 newLeavesLength, uint256 leafNumber);

// 0xce63ce17
error NoCTMForAssetId(bytes32 assetId);
// 0x02181a13
error SettlementLayersMustSettleOnL1();
// 0x1850b46b
error TokenNotLegacy();
// 0x1929b7de
error IncorrectTokenAddressFromNTV(bytes32 assetId, address tokenAddress);
// 0x48c5fa28
error InvalidProofLengthForFinalNode();
// 0x7acd7817
error TokenIsNotLegacy();
// 0xfade089a
error LegacyEncodingUsedForNonL1Token();
// 0xa51fa558
error TokenIsLegacy();
// 0x29963361
error LegacyBridgeUsesNonNativeToken();
// 0x11832de8
error AssetRouterAllowanceNotZero();
// 0xaa5f6180
error BurningNativeWETHNotSupported();
// 0xb20b58ce
error NoLegacySharedBridge();
// 0x8e3ce3cb
error TooHighDeploymentNonce();
// 0x78d2ed02
error ChainAlreadyLive();
// 0x4e98b356
error MigrationsNotPaused();
// 0xf20c5c2a
error WrappedBaseTokenAlreadyRegistered();

// 0xde4c0b96
error InvalidNTVBurnData();
// 0xbe7193d4
error InvalidSystemLogsLength();
// 0x8efef97a
error LegacyBridgeNotSet();
// 0x767eed08
error LegacyMethodForNonL1Token();

enum SharedBridgeKey {
    PostUpgradeFirstBatch,
    LegacyBridgeFirstBatch,
    LegacyBridgeLastDepositBatch,
    LegacyBridgeLastDepositTxn
}

enum BytecodeError {
    Version,
    NumberOfWords,
    Length,
    WordsMustBeOdd
}

enum UpgradeTxVerifyParam {
    From,
    To,
    Paymaster,
    Value,
    MaxFeePerGas,
    MaxPriorityFeePerGas,
    Reserved0,
    Reserved1,
    Reserved2,
    Reserved3,
    Signature,
    PaymasterInput,
    ReservedDynamic
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

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
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Merkle} from "./Merkle.sol";
import {Arrays} from "@openzeppelin/contracts-v4/utils/Arrays.sol";

/**
 * @dev Library for managing https://wikipedia.org/wiki/Merkle_Tree[Merkle Tree] data structures.
 *
 * Each tree is a complete binary tree with the ability to sequentially insert leaves, changing them from a zero to a
 * non-zero value and updating its root. This structure allows inserting commitments (or other entries) that are not
 * stored, but can be proven to be part of the tree at a later time if the root is kept. See {MerkleProof}.
 *
 * A tree is defined by the following parameters:
 *
 * * Depth: The number of levels in the tree, it also defines the maximum number of leaves as 2**depth.
 * * Zero value: The value that represents an empty leaf. Used to avoid regular zero values to be part of the tree.
 * * Hashing function: A cryptographic hash function used to produce internal nodes.
 *
 * This is a fork of OpenZeppelin's [`MerkleTree`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9af280dc4b45ee5bda96ba47ff829b407eaab67e/contracts/utils/structs/MerkleTree.sol)
 * library, with the changes to support dynamic tree growth (doubling the size when full).
 */
library DynamicIncrementalMerkle {
    /**
     * @dev A complete `bytes32` Merkle tree.
     *
     * The `sides` and `zero` arrays are set to have a length equal to the depth of the tree during setup.
     *
     * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
     * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
     * lead to unexpected behavior.
     *
     * NOTE: The `root` and the updates history is not stored within the tree. Consider using a secondary structure to
     * store a list of historical roots from the values returned from {setup} and {push} (e.g. a mapping, {BitMaps} or
     * {Checkpoints}).
     *
     * WARNING: Updating any of the tree's parameters after the first insertion will result in a corrupted tree.
     */
    struct Bytes32PushTree {
        uint256 _nextLeafIndex;
        bytes32[] _sides;
        bytes32[] _zeros;
    }

    /**
     * @dev Initialize a {Bytes32PushTree} using {Hashes-Keccak256} to hash internal nodes.
     * The capacity of the tree (i.e. number of leaves) is set to `2**levels`.
     *
     * IMPORTANT: The zero value should be carefully chosen since it will be stored in the tree representing
     * empty leaves. It should be a value that is not expected to be part of the tree.
     */
    function setup(Bytes32PushTree storage self, bytes32 zero) internal returns (bytes32 initialRoot) {
        self._nextLeafIndex = 0;
        self._zeros.push(zero);
        self._sides.push(bytes32(0));
        return bytes32(0);
    }

    /**
     * @dev Resets the tree to a blank state.
     * Calling this function on MerkleTree that was already setup and used will reset it to a blank state.
     * @param zero The value that represents an empty leaf.
     * @return initialRoot The initial root of the tree.
     */
    function reset(Bytes32PushTree storage self, bytes32 zero) internal returns (bytes32 initialRoot) {
        self._nextLeafIndex = 0;
        uint256 length = self._zeros.length;
        for (uint256 i = length; 0 < i; --i) {
            self._zeros.pop();
        }
        length = self._sides.length;
        for (uint256 i = length; 0 < i; --i) {
            self._sides.pop();
        }
        self._zeros.push(zero);
        self._sides.push(bytes32(0));
        return bytes32(0);
    }

    /**
     * @dev Insert a new leaf in the tree, and compute the new root. Returns the position of the inserted leaf in the
     * tree, and the resulting root.
     *
     * Hashing the leaf before calling this function is recommended as a protection against
     * second pre-image attacks.
     */
    function push(Bytes32PushTree storage self, bytes32 leaf) internal returns (uint256 index, bytes32 newRoot) {
        // Cache read
        uint256 levels = self._zeros.length - 1;

        // Get leaf index
        // solhint-disable-next-line gas-increment-by-one
        index = self._nextLeafIndex++;

        // Check if tree is full.
        if (index == 1 << levels) {
            bytes32 zero = self._zeros[levels];
            bytes32 newZero = Merkle.efficientHash(zero, zero);
            self._zeros.push(newZero);
            self._sides.push(bytes32(0));
            ++levels;
        }

        // Rebuild branch from leaf to root
        uint256 currentIndex = index;
        bytes32 currentLevelHash = leaf;
        bool updatedSides = false;
        for (uint32 i = 0; i < levels; ++i) {
            // Reaching the parent node, is currentLevelHash the left child?
            bool isLeft = currentIndex % 2 == 0;

            // If so, next time we will come from the right, so we need to save it
            if (isLeft && !updatedSides) {
                Arrays.unsafeAccess(self._sides, i).value = currentLevelHash;
                updatedSides = true;
            }

            // Compute the current node hash by using the hash function
            // with either its sibling (side) or the zero value for that level.
            currentLevelHash = Merkle.efficientHash(
                isLeft ? currentLevelHash : Arrays.unsafeAccess(self._sides, i).value,
                isLeft ? Arrays.unsafeAccess(self._zeros, i).value : currentLevelHash
            );

            // Update node index
            currentIndex >>= 1;
        }

        Arrays.unsafeAccess(self._sides, levels).value = currentLevelHash;
        return (index, currentLevelHash);
    }

    /**
     * @dev Tree's root.
     */
    function root(Bytes32PushTree storage self) internal view returns (bytes32) {
        return Arrays.unsafeAccess(self._sides, self._sides.length - 1).value;
    }

    /**
     * @dev Tree's height (does not include the root node).
     */
    function height(Bytes32PushTree storage self) internal view returns (uint256) {
        return self._sides.length - 1;
    }
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

import {UncheckedMath} from "../../common/libraries/UncheckedMath.sol";
import {MerklePathEmpty, MerklePathOutOfBounds, MerkleIndexOutOfBounds, MerklePathLengthMismatch, MerkleNothingToProve, MerkleIndexOrHeightMismatch} from "../../common/L1ContractErrors.sol";

/// @author Matter Labs
/// @custom:security-contact security@matterlabs.dev
library Merkle {
    using UncheckedMath for uint256;

    /// @dev Calculate Merkle root by the provided Merkle proof.
    /// NOTE: When using this function, check that the _path length is equal to the tree height to prevent shorter/longer paths attack
    /// however, for chains settling on GW the proof includes the GW proof, so the path increases. See Mailbox for more details.
    /// @param _path Merkle path from the leaf to the root
    /// @param _index Leaf index in the tree
    /// @param _itemHash Hash of leaf content
    /// @return The Merkle root
    function calculateRoot(
        bytes32[] calldata _path,
        uint256 _index,
        bytes32 _itemHash
    ) internal pure returns (bytes32) {
        uint256 pathLength = _path.length;
        _validatePathLengthForSingleProof(_index, pathLength);

        bytes32 currentHash = _itemHash;
        for (uint256 i; i < pathLength; i = i.uncheckedInc()) {
            currentHash = (_index % 2 == 0)
                ? efficientHash(currentHash, _path[i])
                : efficientHash(_path[i], currentHash);
            _index /= 2;
        }

        return currentHash;
    }

    /// @dev Calculate Merkle root by the provided Merkle proof.
    /// NOTE: When using this function, check that the _path length is equal to the tree height to prevent shorter/longer paths attack
    /// @param _path Merkle path from the leaf to the root
    /// @param _index Leaf index in the tree
    /// @param _itemHash Hash of leaf content
    /// @return The Merkle root
    function calculateRootMemory(
        bytes32[] memory _path,
        uint256 _index,
        bytes32 _itemHash
    ) internal pure returns (bytes32) {
        uint256 pathLength = _path.length;
        _validatePathLengthForSingleProof(_index, pathLength);

        bytes32 currentHash = _itemHash;
        for (uint256 i; i < pathLength; i = i.uncheckedInc()) {
            currentHash = (_index % 2 == 0)
                ? efficientHash(currentHash, _path[i])
                : efficientHash(_path[i], currentHash);
            _index /= 2;
        }

        return currentHash;
    }

    /// @dev Calculate Merkle root by the provided Merkle proof for a range of elements
    /// NOTE: When using this function, check that the _startPath and _endPath lengths are equal to the tree height to prevent shorter/longer paths attack
    /// @param _startPath Merkle path from the first element of the range to the root
    /// @param _endPath Merkle path from the last element of the range to the root
    /// @param _startIndex Index of the first element of the range in the tree
    /// @param _itemHashes Hashes of the elements in the range
    /// @return The Merkle root
    function calculateRootPaths(
        bytes32[] memory _startPath,
        bytes32[] memory _endPath,
        uint256 _startIndex,
        bytes32[] memory _itemHashes
    ) internal pure returns (bytes32) {
        uint256 pathLength = _startPath.length;
        if (pathLength != _endPath.length) {
            revert MerklePathLengthMismatch(pathLength, _endPath.length);
        }
        if (pathLength >= 256) {
            revert MerklePathOutOfBounds();
        }
        uint256 levelLen = _itemHashes.length;
        // Edge case: we want to be able to prove an element in a single-node tree.
        if (pathLength == 0 && (_startIndex != 0 || levelLen != 1)) {
            revert MerklePathEmpty();
        }
        if (levelLen == 0) {
            revert MerkleNothingToProve();
        }
        if (_startIndex + levelLen > (1 << pathLength)) {
            revert MerkleIndexOrHeightMismatch();
        }
        bytes32[] memory itemHashes = _itemHashes;

        for (uint256 level; level < pathLength; level = level.uncheckedInc()) {
            uint256 parity = _startIndex % 2;
            // We get an extra element on the next level if on the current level elements either
            // start on an odd index (`parity == 1`) or end on an even index (`levelLen % 2 == 1`)
            uint256 nextLevelLen = levelLen / 2 + (parity | (levelLen % 2));
            for (uint256 i; i < nextLevelLen; i = i.uncheckedInc()) {
                bytes32 lhs = (i == 0 && parity == 1) ? _startPath[level] : itemHashes[2 * i - parity];
                bytes32 rhs = (i == nextLevelLen - 1 && (levelLen - parity) % 2 == 1)
                    ? _endPath[level]
                    : itemHashes[2 * i + 1 - parity];
                itemHashes[i] = efficientHash(lhs, rhs);
            }
            levelLen = nextLevelLen;
            _startIndex /= 2;
        }

        return itemHashes[0];
    }

    /// @dev Keccak hash of the concatenation of two 32-byte words
    function efficientHash(bytes32 _lhs, bytes32 _rhs) internal pure returns (bytes32 result) {
        assembly {
            mstore(0x00, _lhs)
            mstore(0x20, _rhs)
            result := keccak256(0x00, 0x40)
        }
    }

    function _validatePathLengthForSingleProof(uint256 _index, uint256 _pathLength) private pure {
        if (_pathLength >= 256) {
            revert MerklePathOutOfBounds();
        }
        if (_index >= (1 << _pathLength)) {
            revert MerkleIndexOutOfBounds();
        }
    }
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

/**
 * @author Matter Labs
 * @custom:security-contact security@matterlabs.dev
 * @notice The library for unchecked math.
 */
library UncheckedMath {
    function uncheckedInc(uint256 _number) internal pure returns (uint256) {
        unchecked {
            return _number + 1;
        }
    }

    function uncheckedAdd(uint256 _lhs, uint256 _rhs) internal pure returns (uint256) {
        unchecked {
            return _lhs + _rhs;
        }
    }
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

import {Diamond} from "./libraries/Diamond.sol";
import {L2CanonicalTransaction} from "../common/Messaging.sol";
import {FeeParams} from "./chain-deps/ZKChainStorage.sol";

// import {IBridgehub} from "../bridgehub/IBridgehub.sol";

/// @notice Struct that holds all data needed for initializing CTM Proxy.
/// @dev We use struct instead of raw parameters in `initialize` function to prevent "Stack too deep" error
/// @param owner The address who can manage non-critical updates in the contract
/// @param validatorTimelock The address that serves as consensus, i.e. can submit blocks to be processed
/// @param chainCreationParams The struct that contains the fields that define how a new chain should be created
/// @param protocolVersion The initial protocol version on the newly deployed chain
struct ChainTypeManagerInitializeData {
    address owner;
    address validatorTimelock;
    ChainCreationParams chainCreationParams;
    uint256 protocolVersion;
}

/// @notice The struct that contains the fields that define how a new chain should be created
/// within this CTM.
/// @param genesisUpgrade The address that is used in the diamond cut initialize address on chain creation
/// @param genesisBatchHash Batch hash of the genesis (initial) batch
/// @param genesisIndexRepeatedStorageChanges The serial number of the shortcut storage key for the genesis batch
/// @param genesisBatchCommitment The zk-proof commitment for the genesis batch
/// @param diamondCut The diamond cut for the first upgrade transaction on the newly deployed chain
// solhint-disable-next-line gas-struct-packing
struct ChainCreationParams {
    address genesisUpgrade;
    bytes32 genesisBatchHash;
    uint64 genesisIndexRepeatedStorageChanges;
    bytes32 genesisBatchCommitment;
    Diamond.DiamondCutData diamondCut;
    bytes forceDeploymentsData;
}

interface IChainTypeManager {
    /// @dev Emitted when a new ZKChain is added
    event NewZKChain(uint256 indexed _chainId, address indexed _zkChainContract);

    /// @dev emitted when an chain registers and a GenesisUpgrade happens
    event GenesisUpgrade(
        address indexed _zkChain,
        L2CanonicalTransaction _l2Transaction,
        uint256 indexed _protocolVersion
    );

    /// @notice pendingAdmin is changed
    /// @dev Also emitted when new admin is accepted and in this case, `newPendingAdmin` would be zero address
    event NewPendingAdmin(address indexed oldPendingAdmin, address indexed newPendingAdmin);

    /// @notice Admin changed
    event NewAdmin(address indexed oldAdmin, address indexed newAdmin);

    /// @notice ValidatorTimelock changed
    event NewValidatorTimelock(address indexed oldValidatorTimelock, address indexed newValidatorTimelock);

    /// @notice chain creation parameters changed
    event NewChainCreationParams(
        address genesisUpgrade,
        bytes32 genesisBatchHash,
        uint64 genesisIndexRepeatedStorageChanges,
        bytes32 genesisBatchCommitment,
        bytes32 newInitialCutHash,
        bytes32 forceDeploymentHash
    );

    /// @notice New UpgradeCutHash
    event NewUpgradeCutHash(uint256 indexed protocolVersion, bytes32 indexed upgradeCutHash);

    /// @notice New UpgradeCutData
    event NewUpgradeCutData(uint256 indexed protocolVersion, Diamond.DiamondCutData diamondCutData);

    /// @notice New ProtocolVersion
    event NewProtocolVersion(uint256 indexed oldProtocolVersion, uint256 indexed newProtocolVersion);

    /// @notice Updated ProtocolVersion deadline
    event UpdateProtocolVersionDeadline(uint256 indexed protocolVersion, uint256 deadline);

    function BRIDGE_HUB() external view returns (address);

    function setPendingAdmin(address _newPendingAdmin) external;

    function acceptAdmin() external;

    function getZKChain(uint256 _chainId) external view returns (address);

    function getHyperchain(uint256 _chainId) external view returns (address);

    function getZKChainLegacy(uint256 _chainId) external view returns (address);

    function storedBatchZero() external view returns (bytes32);

    function initialCutHash() external view returns (bytes32);

    function l1GenesisUpgrade() external view returns (address);

    function upgradeCutHash(uint256 _protocolVersion) external view returns (bytes32);

    function protocolVersion() external view returns (uint256);

    function protocolVersionDeadline(uint256 _protocolVersion) external view returns (uint256);

    function protocolVersionIsActive(uint256 _protocolVersion) external view returns (bool);

    function getProtocolVersion(uint256 _chainId) external view returns (uint256);

    function initialize(ChainTypeManagerInitializeData calldata _initializeData) external;

    function setValidatorTimelock(address _validatorTimelock) external;

    function setChainCreationParams(ChainCreationParams calldata _chainCreationParams) external;

    function getChainAdmin(uint256 _chainId) external view returns (address);

    function createNewChain(
        uint256 _chainId,
        bytes32 _baseTokenAssetId,
        address _admin,
        bytes calldata _initData,
        bytes[] calldata _factoryDeps
    ) external returns (address);

    function setNewVersionUpgrade(
        Diamond.DiamondCutData calldata _cutData,
        uint256 _oldProtocolVersion,
        uint256 _oldProtocolVersionDeadline,
        uint256 _newProtocolVersion
    ) external;

    function setUpgradeDiamondCut(Diamond.DiamondCutData calldata _cutData, uint256 _oldProtocolVersion) external;

    function executeUpgrade(uint256 _chainId, Diamond.DiamondCutData calldata _diamondCut) external;

    function setPriorityTxMaxGasLimit(uint256 _chainId, uint256 _maxGasLimit) external;

    function freezeChain(uint256 _chainId) external;

    function unfreezeChain(uint256 _chainId) external;

    function setTokenMultiplier(uint256 _chainId, uint128 _nominator, uint128 _denominator) external;

    function changeFeeParams(uint256 _chainId, FeeParams calldata _newFeeParams) external;

    function setValidator(uint256 _chainId, address _validator, bool _active) external;

    function setPorterAvailability(uint256 _chainId, bool _zkPorterIsAvailable) external;

    function upgradeChainFromVersion(
        uint256 _chainId,
        uint256 _oldProtocolVersion,
        Diamond.DiamondCutData calldata _diamondCut
    ) external;

    function getSemverProtocolVersion() external view returns (uint32, uint32, uint32);

    function forwardedBridgeBurn(
        uint256 _chainId,
        bytes calldata _data
    ) external returns (bytes memory _bridgeMintData);

    function forwardedBridgeMint(uint256 _chainId, bytes calldata _data) external returns (address);

    function forwardedBridgeRecoverFailedTransfer(
        uint256 _chainId,
        bytes32 _assetInfo,
        address _depositSender,
        bytes calldata _ctmData
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

// 0x2e89f517
error L1DAValidatorAddressIsZero();

// 0x944bc075
error L2DAValidatorAddressIsZero();

// 0xca1c3cbc
error AlreadyMigrated();

// 0xf05c64c6
error NotChainAdmin(address prevMsgSender, address admin);

// 0xc59d372c
error ProtocolVersionNotUpToDate(uint256 currentProtocolVersion, uint256 protocolVersion);

// 0xedae13f3
error ExecutedIsNotConsistentWithVerified(uint256 batchesExecuted, uint256 batchesVerified);

// 0x712d02d2
error VerifiedIsNotConsistentWithCommitted(uint256 batchesVerified, uint256 batchesCommitted);

// 0xfb1a3b59
error InvalidNumberOfBatchHashes(uint256 batchHashesLength, uint256 expected);

// 0xa840274f
error PriorityQueueNotReady();

// 0x79274f04
error UnsupportedProofMetadataVersion(uint256 metadataVersion);

// 0xa969e486
error LocalRootIsZero();

// 0xbdaf7d42
error LocalRootMustBeZero();

// 0xd0266e26
error NotSettlementLayer();

// 0x32ddf9a2
error NotHyperchain();

// 0x2237c426
error MismatchL2DAValidator();

// 0x2c01a4af
error MismatchNumberOfLayer1Txs(uint256 numberOfLayer1Txs, uint256 expectedLength);

// 0xfbd630b8
error InvalidBatchesDataLength(uint256 batchesDataLength, uint256 priorityOpsDataLength);

// 0x55008233
error PriorityOpsDataLeftPathLengthIsNotZero();

// 0x8be936a9
error PriorityOpsDataRightPathLengthIsNotZero();

// 0x99d44739
error PriorityOpsDataItemHashesLengthIsNotZero();

// 0x885ae069
error OperatorDAInputTooSmall(uint256 operatorDAInputLength, uint256 minAllowedLength);

// 0xbeb96791
error InvalidNumberOfBlobs(uint256 blobsProvided, uint256 maxBlobsSupported);

// 0xd2531c15
error InvalidL2DAOutputHash(bytes32 l2DAValidatorOutputHash);

// 0x04e05fd1
error OnlyOneBlobWithCalldataAllowed();

// 0x2dc9747d
error PubdataInputTooSmall(uint256 pubdataInputLength, uint256 totalBlobsCommitmentSize);

// 0x9044dff9
error PubdataLengthTooBig(uint256 pubdataLength, uint256 totalBlobSizeBytes);

// 0x5513177c
error InvalidPubdataHash(bytes32 fullPubdataHash, bytes32 providedPubdataHash);

// 0x5717f940
error InvalidPubdataSource(uint8 pubdataSource);

// 0x125d99b0
error BlobHashBlobCommitmentMismatchValue();

// 0x7fbff2dd
error L1DAValidatorInvalidSender(address msgSender);

// 0xc06789fa
error InvalidCommitment();

// 0xc866ff2c
error InitialForceDeploymentMismatch(bytes32 forceDeploymentHash, bytes32 initialForceDeploymentHash);

// 0xb325f767
error AdminZero();

// 0x681150be
error OutdatedProtocolVersion(uint256 protocolVersion, uint256 currentProtocolVersion);

// 0x87470e36
error NotL1(uint256 blockChainId);

// 0x90f67ecf
error InvalidStartIndex(uint256 treeStartIndex, uint256 commitmentStartIndex);

// 0x0f67bc0a
error InvalidUnprocessedIndex(uint256 treeUnprocessedIndex, uint256 commitmentUnprocessedIndex);

// 0x30043900
error InvalidNextLeafIndex(uint256 treeNextLeafIndex, uint256 commitmentNextLeafIndex);

// 0xf9ba09d6
error NotAllBatchesExecuted();

// 0x9b53b101
error NotHistoricalRoot();

// 0xc02d3ee3
error ContractNotDeployed();

// 0xd7b2559b
error NotMigrated();

// 0x52595598
error ValL1DAWrongInputLength(uint256 inputLength, uint256 expectedLength);
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Ownable2Step} from "@openzeppelin/contracts-v4/access/Ownable2Step.sol";
import {LibMap} from "./libraries/LibMap.sol";
import {IExecutor} from "./chain-interfaces/IExecutor.sol";
import {IChainTypeManager} from "./IChainTypeManager.sol";
import {Unauthorized, TimeNotReached, ZeroAddress} from "../common/L1ContractErrors.sol";

/// @author Matter Labs
/// @custom:security-contact security@matterlabs.dev
/// @notice Intermediate smart contract between the validator EOA account and the ZK chains state transition diamond smart contract.
/// @dev The primary purpose of this contract is to provide a trustless means of delaying batch execution without
/// modifying the main zkChain diamond contract. As such, even if this contract is compromised, it will not impact the main
/// contract.
/// @dev ZKsync actively monitors the chain activity and reacts to any suspicious activity by freezing the chain.
/// This allows time for investigation and mitigation before resuming normal operations.
/// @dev The contract overloads all of the 4 methods, that are used in state transition. When the batch is committed,
/// the timestamp is stored for it. Later, when the owner calls the batch execution, the contract checks that batch
/// was committed not earlier than X time ago.
contract ValidatorTimelock is IExecutor, Ownable2Step {
    using LibMap for LibMap.Uint32Map;

    /// @dev Part of the IBase interface. Not used in this contract.
    string public constant override getName = "ValidatorTimelock";

    /// @notice The delay between committing and executing batches is changed.
    event NewExecutionDelay(uint256 _newExecutionDelay);

    /// @notice A new validator has been added.
    event ValidatorAdded(uint256 indexed _chainId, address _addedValidator);

    /// @notice A validator has been removed.
    event ValidatorRemoved(uint256 indexed _chainId, address _removedValidator);

    /// @notice Error for when an address is already a validator.
    error AddressAlreadyValidator(uint256 _chainId);

    /// @notice Error for when an address is not a validator.
    error ValidatorDoesNotExist(uint256 _chainId);

    /// @dev The chainTypeManager smart contract.
    IChainTypeManager public chainTypeManager;

    /// @dev The mapping of L2 chainId => batch number => timestamp when it was committed.
    mapping(uint256 chainId => LibMap.Uint32Map batchNumberToTimestampMapping) internal committedBatchTimestamp;

    /// @dev The address that can commit/revert/validate/execute batches.
    mapping(uint256 _chainId => mapping(address _validator => bool)) public validators;

    /// @dev The delay between committing and executing batches.
    uint32 public executionDelay;

    constructor(address _initialOwner, uint32 _executionDelay) {
        _transferOwnership(_initialOwner);
        executionDelay = _executionDelay;
    }

    /// @notice Checks if the caller is the admin of the chain.
    modifier onlyChainAdmin(uint256 _chainId) {
        if (msg.sender != chainTypeManager.getChainAdmin(_chainId)) {
            revert Unauthorized(msg.sender);
        }
        _;
    }

    /// @notice Checks if the caller is a validator.
    modifier onlyValidator(uint256 _chainId) {
        if (!validators[_chainId][msg.sender]) {
            revert Unauthorized(msg.sender);
        }
        _;
    }

    /// @dev Sets a new state transition manager.
    function setChainTypeManager(IChainTypeManager _chainTypeManager) external onlyOwner {
        if (address(_chainTypeManager) == address(0)) {
            revert ZeroAddress();
        }
        chainTypeManager = _chainTypeManager;
    }

    /// @dev Sets an address as a validator.
    function addValidator(uint256 _chainId, address _newValidator) external onlyChainAdmin(_chainId) {
        if (validators[_chainId][_newValidator]) {
            revert AddressAlreadyValidator(_chainId);
        }
        validators[_chainId][_newValidator] = true;
        emit ValidatorAdded(_chainId, _newValidator);
    }

    /// @dev Removes an address as a validator.
    function removeValidator(uint256 _chainId, address _validator) external onlyChainAdmin(_chainId) {
        if (!validators[_chainId][_validator]) {
            revert ValidatorDoesNotExist(_chainId);
        }
        validators[_chainId][_validator] = false;
        emit ValidatorRemoved(_chainId, _validator);
    }

    /// @dev Set the delay between committing and executing batches.
    function setExecutionDelay(uint32 _executionDelay) external onlyOwner {
        executionDelay = _executionDelay;
        emit NewExecutionDelay(_executionDelay);
    }

    /// @dev Returns the timestamp when `_l2BatchNumber` was committed.
    function getCommittedBatchTimestamp(uint256 _chainId, uint256 _l2BatchNumber) external view returns (uint256) {
        return committedBatchTimestamp[_chainId].get(_l2BatchNumber);
    }

    /// @dev Records the timestamp for all provided committed batches and make
    /// a call to the zkChain diamond contract with the same calldata.
    function commitBatchesSharedBridge(
        uint256 _chainId,
        uint256 _processBatchFrom,
        uint256 _processBatchTo,
        bytes calldata
    ) external onlyValidator(_chainId) {
        unchecked {
            // This contract is only a temporary solution, that hopefully will be disabled until 2106 year, so...
            // It is safe to cast.
            uint32 timestamp = uint32(block.timestamp);
            // We disable this check because calldata array length is cheap.
            for (uint256 i = _processBatchFrom; i <= _processBatchTo; ++i) {
                committedBatchTimestamp[_chainId].set(i, timestamp);
            }
        }
        _propagateToZKChain(_chainId);
    }

    /// @dev Make a call to the zkChain diamond contract with the same calldata.
    /// Note: If the batch is reverted, it needs to be committed first before the execution.
    /// So it's safe to not override the committed batches.
    function revertBatchesSharedBridge(uint256 _chainId, uint256) external onlyValidator(_chainId) {
        _propagateToZKChain(_chainId);
    }

    /// @dev Make a call to the zkChain diamond contract with the same calldata.
    /// Note: We don't track the time when batches are proven, since all information about
    /// the batch is known on the commit stage and the proved is not finalized (may be reverted).
    function proveBatchesSharedBridge(
        uint256 _chainId,
        uint256, // _processBatchFrom
        uint256, // _processBatchTo
        bytes calldata
    ) external onlyValidator(_chainId) {
        _propagateToZKChain(_chainId);
    }

    /// @dev Check that batches were committed at least X time ago and
    /// make a call to the zkChain diamond contract with the same calldata.
    function executeBatchesSharedBridge(
        uint256 _chainId,
        uint256 _processBatchFrom,
        uint256 _processBatchTo,
        bytes calldata
    ) external onlyValidator(_chainId) {
        uint256 delay = executionDelay; // uint32
        unchecked {
            // We disable this check because calldata array length is cheap.
            for (uint256 i = _processBatchFrom; i <= _processBatchTo; ++i) {
                uint256 commitBatchTimestamp = committedBatchTimestamp[_chainId].get(i);

                // Note: if the `commitBatchTimestamp` is zero, that means either:
                // * The batch was committed, but not through this contract.
                // * The batch wasn't committed at all, so execution will fail in the ZKsync contract.
                // We allow executing such batches.

                if (block.timestamp < commitBatchTimestamp + delay) {
                    revert TimeNotReached(commitBatchTimestamp + delay, block.timestamp);
                }
            }
        }
        _propagateToZKChain(_chainId);
    }

    /// @dev Call the zkChain diamond contract with the same calldata as this contract was called.
    /// Note: it is called the zkChain diamond contract, not delegatecalled!
    function _propagateToZKChain(uint256 _chainId) internal {
        // Note, that it is important to use chain type manager and
        // the legacy method here for obtaining the chain id in order for
        // this contract to before the CTM upgrade is finalized.
        address contractAddress = chainTypeManager.getHyperchain(_chainId);
        if (contractAddress == address(0)) {
            revert ZeroAddress();
        }
        assembly {
            // Copy function signature and arguments from calldata at zero position into memory at pointer position
            calldatacopy(0, 0, calldatasize())
            // Call method of the ZK chain diamond contract returns 0 on error
            let result := call(gas(), contractAddress, 0, 0, calldatasize(), 0, 0)
            // Get the size of the last return data
            let size := returndatasize()
            // Copy the size length of bytes from return data at zero position to pointer position
            returndatacopy(0, 0, size)
            // Depending on the result value
            switch result
            case 0 {
                // End execution and revert state changes
                revert(0, size)
            }
            default {
                // Return data with length of size at pointers position
                return(0, size)
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IVerifier, VerifierParams} from "../chain-interfaces/IVerifier.sol";
// import {IChainTypeManager} from "../IChainTypeManager.sol";
import {PriorityQueue} from "../../state-transition/libraries/PriorityQueue.sol";
import {PriorityTree} from "../../state-transition/libraries/PriorityTree.sol";

/// @notice Indicates whether an upgrade is initiated and if yes what type
/// @param None Upgrade is NOT initiated
/// @param Transparent Fully transparent upgrade is initiated, upgrade data is publicly known
/// @param Shadow Shadow upgrade is initiated, upgrade data is hidden
enum UpgradeState {
    None,
    Transparent,
    Shadow
}

/// @dev Logically separated part of the storage structure, which is responsible for everything related to proxy
/// upgrades and diamond cuts
/// @param proposedUpgradeHash The hash of the current upgrade proposal, zero if there is no active proposal
/// @param state Indicates whether an upgrade is initiated and if yes what type
/// @param securityCouncil Address which has the permission to approve instant upgrades (expected to be a Gnosis
/// multisig)
/// @param approvedBySecurityCouncil Indicates whether the security council has approved the upgrade
/// @param proposedUpgradeTimestamp The timestamp when the upgrade was proposed, zero if there are no active proposals
/// @param currentProposalId The serial number of proposed upgrades, increments when proposing a new one
struct UpgradeStorage {
    bytes32 proposedUpgradeHash;
    UpgradeState state;
    address securityCouncil;
    bool approvedBySecurityCouncil;
    uint40 proposedUpgradeTimestamp;
    uint40 currentProposalId;
}

/// @notice The struct that describes whether users will be charged for pubdata for L1->L2 transactions.
/// @param Rollup The users are charged for pubdata & it is priced based on the gas price on Ethereum.
/// @param Validium The pubdata is considered free with regard to the L1 gas price.
enum PubdataPricingMode {
    Rollup,
    Validium
}

/// @notice The fee params for L1->L2 transactions for the network.
/// @param pubdataPricingMode How the users will charged for pubdata in L1->L2 transactions.
/// @param batchOverheadL1Gas The amount of L1 gas required to process the batch (except for the calldata).
/// @param maxPubdataPerBatch The maximal number of pubdata that can be emitted per batch.
/// @param priorityTxMaxPubdata The maximal amount of pubdata a priority transaction is allowed to publish.
/// It can be slightly less than maxPubdataPerBatch in order to have some margin for the bootloader execution.
/// @param minimalL2GasPrice The minimal L2 gas price to be used by L1->L2 transactions. It should represent
/// the price that a single unit of compute costs.
struct FeeParams {
    PubdataPricingMode pubdataPricingMode;
    uint32 batchOverheadL1Gas;
    uint32 maxPubdataPerBatch;
    uint32 maxL2GasPerBatch;
    uint32 priorityTxMaxPubdata;
    uint64 minimalL2GasPrice;
}

/// @dev storing all storage variables for ZK chain diamond facets
/// NOTE: It is used in a proxy, so it is possible to add new variables to the end
/// but NOT to modify already existing variables or change their order.
/// NOTE: variables prefixed with '__DEPRECATED_' are deprecated and shouldn't be used.
/// Their presence is maintained for compatibility and to prevent storage collision.
// solhint-disable-next-line gas-struct-packing
struct ZKChainStorage {
    /// @dev Storage of variables needed for deprecated diamond cut facet
    uint256[7] __DEPRECATED_diamondCutStorage;
    /// @notice Address which will exercise critical changes to the Diamond Proxy (upgrades, freezing & unfreezing). Replaced by CTM
    address __DEPRECATED_governor;
    /// @notice Address that the governor proposed as one that will replace it
    address __DEPRECATED_pendingGovernor;
    /// @notice List of permitted validators
    mapping(address validatorAddress => bool isValidator) validators;
    /// @dev Verifier contract. Used to verify aggregated proof for batches
    IVerifier verifier;
    /// @notice Total number of executed batches i.e. batches[totalBatchesExecuted] points at the latest executed batch
    /// (batch 0 is genesis)
    uint256 totalBatchesExecuted;
    /// @notice Total number of proved batches i.e. batches[totalBatchesProved] points at the latest proved batch
    uint256 totalBatchesVerified;
    /// @notice Total number of committed batches i.e. batches[totalBatchesCommitted] points at the latest committed
    /// batch
    uint256 totalBatchesCommitted;
    /// @dev Stored hashed StoredBatch for batch number
    mapping(uint256 batchNumber => bytes32 batchHash) storedBatchHashes;
    /// @dev Stored root hashes of L2 -> L1 logs
    mapping(uint256 batchNumber => bytes32 l2LogsRootHash) l2LogsRootHashes;
    /// @dev Container that stores transactions requested from L1
    PriorityQueue.Queue priorityQueue;
    /// @dev The smart contract that manages the list with permission to call contract functions
    address __DEPRECATED_allowList;
    VerifierParams __DEPRECATED_verifierParams;
    /// @notice Bytecode hash of bootloader program.
    /// @dev Used as an input to zkp-circuit.
    bytes32 l2BootloaderBytecodeHash;
    /// @notice Bytecode hash of default account (bytecode for EOA).
    /// @dev Used as an input to zkp-circuit.
    bytes32 l2DefaultAccountBytecodeHash;
    /// @dev Indicates that the porter may be touched on L2 transactions.
    /// @dev Used as an input to zkp-circuit.
    bool zkPorterIsAvailable;
    /// @dev The maximum number of the L2 gas that a user can request for L1 -> L2 transactions
    /// @dev This is the maximum number of L2 gas that is available for the "body" of the transaction, i.e.
    /// without overhead for proving the batch.
    uint256 priorityTxMaxGasLimit;
    /// @dev Storage of variables needed for upgrade facet
    UpgradeStorage __DEPRECATED_upgrades;
    /// @dev A mapping L2 batch number => message number => flag.
    /// @dev The L2 -> L1 log is sent for every withdrawal, so this mapping is serving as
    /// a flag to indicate that the message was already processed.
    /// @dev Used to indicate that eth withdrawal was already processed
    mapping(uint256 l2BatchNumber => mapping(uint256 l2ToL1MessageNumber => bool isFinalized)) isEthWithdrawalFinalized;
    /// @dev The most recent withdrawal time and amount reset
    uint256 __DEPRECATED_lastWithdrawalLimitReset;
    /// @dev The accumulated withdrawn amount during the withdrawal limit window
    uint256 __DEPRECATED_withdrawnAmountInWindow;
    /// @dev A mapping user address => the total deposited amount by the user
    mapping(address => uint256) __DEPRECATED_totalDepositedAmountPerUser;
    /// @dev Stores the protocol version. Note, that the protocol version may not only encompass changes to the
    /// smart contracts, but also to the node behavior.
    uint256 protocolVersion;
    /// @dev Hash of the system contract upgrade transaction. If 0, then no upgrade transaction needs to be done.
    bytes32 l2SystemContractsUpgradeTxHash;
    /// @dev Batch number where the upgrade transaction has happened. If 0, then no upgrade transaction has happened
    /// yet.
    uint256 l2SystemContractsUpgradeBatchNumber;
    /// @dev Address which will exercise non-critical changes to the Diamond Proxy (changing validator set & unfreezing)
    address admin;
    /// @notice Address that the admin proposed as one that will replace admin role
    address pendingAdmin;
    /// @dev Fee params used to derive gasPrice for the L1->L2 transactions. For L2 transactions,
    /// the bootloader gives enough freedom to the operator.
    /// @dev The value is only for the L1 deployment of the ZK Chain, since payment for all the priority transactions is
    /// charged at that level.
    FeeParams feeParams;
    /// @dev Address of the blob versioned hash getter smart contract used for EIP-4844 versioned hashes.
    /// @dev Used only for testing.
    address blobVersionedHashRetriever;
    /// @dev The chainId of the chain
    uint256 chainId;
    /// @dev The address of the bridgehub
    address bridgehub;
    /// @dev The address of the ChainTypeManager
    address chainTypeManager;
    /// @dev The address of the baseToken contract. Eth is address(1)
    address __DEPRECATED_baseToken;
    /// @dev The address of the baseTokenbridge. Eth also uses the shared bridge
    address __DEPRECATED_baseTokenBridge;
    /// @notice gasPriceMultiplier for each baseToken, so that each L1->L2 transaction pays for its transaction on the destination
    /// we multiply by the nominator, and divide by the denominator
    uint128 baseTokenGasPriceMultiplierNominator;
    uint128 baseTokenGasPriceMultiplierDenominator;
    /// @dev The optional address of the contract that has to be used for transaction filtering/whitelisting
    address transactionFilterer;
    /// @dev The address of the l1DAValidator contract.
    /// This contract is responsible for the verification of the correctness of the DA on L1.
    address l1DAValidator;
    /// @dev The address of the contract on L2 that is responsible for the data availability verification.
    /// This contract sends `l2DAValidatorOutputHash` to L1 via L2->L1 system log and it will routed to the `l1DAValidator` contract.
    address l2DAValidator;
    /// @dev the Asset Id of the baseToken
    bytes32 baseTokenAssetId;
    /// @dev If this ZKchain settles on this chain, then this is zero. Otherwise it is the address of the ZKchain that is a
    /// settlement layer for this ZKchain. (think about it as a 'forwarding' address for the chain that migrated away).
    address settlementLayer;
    /// @dev Priority tree, the new data structure for priority queue
    PriorityTree.Tree priorityTree;
    /// @dev Whether the chain is a permanent rollup. Note, that it only enforces the DA validator pair, but
    /// it does not enforce any other parameters, e.g. `pubdataPricingMode`
    bool isPermanentRollup;
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

import {IZKChainBase} from "./IZKChainBase.sol";

/// @dev Enum used by L2 System Contracts to differentiate logs.
enum SystemLogKey {
    L2_TO_L1_LOGS_TREE_ROOT_KEY,
    PACKED_BATCH_AND_L2_BLOCK_TIMESTAMP_KEY,
    CHAINED_PRIORITY_TXN_HASH_KEY,
    NUMBER_OF_LAYER_1_TXS_KEY,
    // Note, that it is important that `PREV_BATCH_HASH_KEY` has position
    // `4` since it is the same as it was in the previous protocol version and
    // it is the only one that is emitted before the system contracts are upgraded.
    PREV_BATCH_HASH_KEY,
    L2_DA_VALIDATOR_OUTPUT_HASH_KEY,
    USED_L2_DA_VALIDATOR_ADDRESS_KEY,
    EXPECTED_SYSTEM_CONTRACT_UPGRADE_TX_HASH_KEY
}

struct LogProcessingOutput {
    uint256 numberOfLayer1Txs;
    bytes32 chainedPriorityTxsHash;
    bytes32 previousBatchHash;
    bytes32 pubdataHash;
    bytes32 stateDiffHash;
    bytes32 l2LogsTreeRoot;
    uint256 packedBatchAndL2BlockTimestamp;
    bytes32 l2DAValidatorOutputHash;
}

/// @dev Offset used to pull Address From Log. Equal to 4 (bytes for isService)
uint256 constant L2_LOG_ADDRESS_OFFSET = 4;

/// @dev Offset used to pull Key From Log. Equal to 4 (bytes for isService) + 20 (bytes for address)
uint256 constant L2_LOG_KEY_OFFSET = 24;

/// @dev Offset used to pull Value From Log. Equal to 4 (bytes for isService) + 20 (bytes for address) + 32 (bytes for key)
uint256 constant L2_LOG_VALUE_OFFSET = 56;

/// @dev Max number of blobs currently supported
uint256 constant MAX_NUMBER_OF_BLOBS = 6;

/// @dev The number of blobs that must be present in the commitment to a batch.
/// It represents the maximal number of blobs that circuits can support and can be larger
/// than the maximal number of blobs supported by the contract (`MAX_NUMBER_OF_BLOBS`).
uint256 constant TOTAL_BLOBS_IN_COMMITMENT = 16;

/// @title The interface of the ZKsync Executor contract capable of processing events emitted in the ZKsync protocol.
/// @author Matter Labs
/// @custom:security-contact security@matterlabs.dev
interface IExecutor is IZKChainBase {
    /// @notice Rollup batch stored data
    /// @param batchNumber Rollup batch number
    /// @param batchHash Hash of L2 batch
    /// @param indexRepeatedStorageChanges The serial number of the shortcut index that's used as a unique identifier for storage keys that were used twice or more
    /// @param numberOfLayer1Txs Number of priority operations to be processed
    /// @param priorityOperationsHash Hash of all priority operations from this batch
    /// @param l2LogsTreeRoot Root hash of tree that contains L2 -> L1 messages from this batch
    /// @param timestamp Rollup batch timestamp, have the same format as Ethereum batch constant
    /// @param commitment Verified input for the ZKsync circuit
    // solhint-disable-next-line gas-struct-packing
    struct StoredBatchInfo {
        uint64 batchNumber;
        bytes32 batchHash;
        uint64 indexRepeatedStorageChanges;
        uint256 numberOfLayer1Txs;
        bytes32 priorityOperationsHash;
        bytes32 l2LogsTreeRoot;
        uint256 timestamp;
        bytes32 commitment;
    }

    /// @notice Data needed to commit new batch
    /// @param batchNumber Number of the committed batch
    /// @param timestamp Unix timestamp denoting the start of the batch execution
    /// @param indexRepeatedStorageChanges The serial number of the shortcut index that's used as a unique identifier for storage keys that were used twice or more
    /// @param newStateRoot The state root of the full state tree
    /// @param numberOfLayer1Txs Number of priority operations to be processed
    /// @param priorityOperationsHash Hash of all priority operations from this batch
    /// @param bootloaderHeapInitialContentsHash Hash of the initial contents of the bootloader heap. In practice it serves as the commitment to the transactions in the batch.
    /// @param eventsQueueStateHash Hash of the events queue state. In practice it serves as the commitment to the events in the batch.
    /// @param systemLogs concatenation of all L2 -> L1 system logs in the batch
    /// @param operatorDAInput Packed pubdata commitments/data.
    /// @dev pubdataCommitments format: This will always start with a 1 byte pubdataSource flag. Current allowed values are 0 (calldata) or 1 (blobs)
    ///                             kzg: list of: opening point (16 bytes) || claimed value (32 bytes) || commitment (48 bytes) || proof (48 bytes) = 144 bytes
    ///                             calldata: pubdataCommitments.length - 1 - 32 bytes of pubdata
    ///                                       and 32 bytes appended to serve as the blob commitment part for the aux output part of the batch commitment
    /// @dev For 2 blobs we will be sending 288 bytes of calldata instead of the full amount for pubdata.
    /// @dev When using calldata, we only need to send one blob commitment since the max number of bytes in calldata fits in a single blob and we can pull the
    ///     linear hash from the system logs
    struct CommitBatchInfo {
        uint64 batchNumber;
        uint64 timestamp;
        uint64 indexRepeatedStorageChanges;
        bytes32 newStateRoot;
        uint256 numberOfLayer1Txs;
        bytes32 priorityOperationsHash;
        bytes32 bootloaderHeapInitialContentsHash;
        bytes32 eventsQueueStateHash;
        bytes systemLogs;
        bytes operatorDAInput;
    }

    /// @notice Function called by the operator to commit new batches. It is responsible for:
    /// - Verifying the correctness of their timestamps.
    /// - Processing their L2->L1 logs.
    /// - Storing batch commitments.
    /// @param _chainId Chain ID of the chain.
    /// @param _processFrom The batch number from which the processing starts.
    /// @param _processTo The batch number at which the processing ends.
    /// @param _commitData The encoded data of the new batches to be committed.
    function commitBatchesSharedBridge(
        uint256 _chainId,
        uint256 _processFrom,
        uint256 _processTo,
        bytes calldata _commitData
    ) external;

    /// @notice Batches commitment verification.
    /// @dev Only verifies batch commitments without any other processing.
    /// @param _chainId Chain ID of the chain.
    /// @param _processBatchFrom The batch number from which the verification starts.
    /// @param _processBatchTo The batch number at which the verification ends.
    /// @param _proofData The encoded data of the new batches to be verified.
    function proveBatchesSharedBridge(
        uint256 _chainId,
        uint256 _processBatchFrom,
        uint256 _processBatchTo,
        bytes calldata _proofData
    ) external;

    /// @notice The function called by the operator to finalize (execute) batches. It is responsible for:
    /// - Processing all pending operations (commpleting priority requests).
    /// - Finalizing this batch (i.e. allowing to withdraw funds from the system)
    /// @param _chainId Chain ID of the chain.
    /// @param _processFrom The batch number from which the execution starts.
    /// @param _processTo The batch number at which the execution ends.
    /// @param _executeData The encoded data of the new batches to be executed.
    function executeBatchesSharedBridge(
        uint256 _chainId,
        uint256 _processFrom,
        uint256 _processTo,
        bytes calldata _executeData
    ) external;

    /// @notice Reverts unexecuted batches
    /// @param _chainId Chain ID of the chain
    /// @param _newLastBatch batch number after which batches should be reverted
    /// NOTE: Doesn't delete the stored data about batches, but only decreases
    /// counters that are responsible for the number of batches
    function revertBatchesSharedBridge(uint256 _chainId, uint256 _newLastBatch) external;

    /// @notice Event emitted when a batch is committed
    /// @param batchNumber Number of the batch committed
    /// @param batchHash Hash of the L2 batch
    /// @param commitment Calculated input for the ZKsync circuit
    /// @dev It has the name "BlockCommit" and not "BatchCommit" due to backward compatibility considerations
    event BlockCommit(uint256 indexed batchNumber, bytes32 indexed batchHash, bytes32 indexed commitment);

    /// @notice Event emitted when batches are verified
    /// @param previousLastVerifiedBatch Batch number of the previous last verified batch
    /// @param currentLastVerifiedBatch Batch number of the current last verified batch
    /// @dev It has the name "BlocksVerification" and not "BatchesVerification" due to backward compatibility considerations
    event BlocksVerification(uint256 indexed previousLastVerifiedBatch, uint256 indexed currentLastVerifiedBatch);

    /// @notice Event emitted when a batch is executed
    /// @param batchNumber Number of the batch executed
    /// @param batchHash Hash of the L2 batch
    /// @param commitment Verified input for the ZKsync circuit
    /// @dev It has the name "BlockExecution" and not "BatchExecution" due to backward compatibility considerations
    event BlockExecution(uint256 indexed batchNumber, bytes32 indexed batchHash, bytes32 indexed commitment);

    /// @notice Event emitted when batches are reverted
    /// @param totalBatchesCommitted Total number of committed batches after the revert
    /// @param totalBatchesVerified Total number of verified batches after the revert
    /// @param totalBatchesExecuted Total number of executed batches
    /// @dev It has the name "BlocksRevert" and not "BatchesRevert" due to backward compatibility considerations
    event BlocksRevert(uint256 totalBatchesCommitted, uint256 totalBatchesVerified, uint256 totalBatchesExecuted);
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

/// @notice Part of the configuration parameters of ZKP circuits
struct VerifierParams {
    bytes32 recursionNodeLevelVkHash;
    bytes32 recursionLeafLevelVkHash;
    bytes32 recursionCircuitsSetVksHash;
}

/// @title The interface of the Verifier contract, responsible for the zero knowledge proof verification.
/// @author Matter Labs
/// @custom:security-contact security@matterlabs.dev
interface IVerifier {
    /// @dev Verifies a zk-SNARK proof.
    /// @return A boolean value indicating whether the zk-SNARK proof is valid.
    /// Note: The function may revert execution instead of returning false in some cases.
    function verify(uint256[] calldata _publicInputs, uint256[] calldata _proof) external view returns (bool);

    /// @notice Calculates a keccak256 hash of the runtime loaded verification keys.
    /// @return vkHash The keccak256 hash of the loaded verification keys.
    function verificationKeyHash() external pure returns (bytes32);
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

/// @title The interface of the ZKsync contract, responsible for the main ZKsync logic.
/// @author Matter Labs
/// @custom:security-contact security@matterlabs.dev
interface IZKChainBase {
    /// @return Returns facet name.
    function getName() external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

import {SafeCast} from "@openzeppelin/contracts-v4/utils/math/SafeCast.sol";
import {UncheckedMath} from "../../common/libraries/UncheckedMath.sol";
import {NoFunctionsForDiamondCut, UndefinedDiamondCutAction, AddressHasNoCode, FacetExists, RemoveFunctionFacetAddressZero, SelectorsMustAllHaveSameFreezability, NonEmptyCalldata, ReplaceFunctionFacetAddressZero, RemoveFunctionFacetAddressNotZero, DelegateCallFailed} from "../../common/L1ContractErrors.sol";

/// @author Matter Labs
/// @custom:security-contact security@matterlabs.dev
/// @notice The helper library for managing the EIP-2535 diamond proxy.
library Diamond {
    using UncheckedMath for uint256;
    using SafeCast for uint256;

    /// @dev Magic value that should be returned by diamond cut initialize contracts.
    /// @dev Used to distinguish calls to contracts that were supposed to be used as diamond initializer from other contracts.
    bytes32 internal constant DIAMOND_INIT_SUCCESS_RETURN_VALUE =
        0x33774e659306e47509050e97cb651e731180a42d458212294d30751925c551a2; // keccak256("diamond.zksync.init") - 1

    /// @dev Storage position of `DiamondStorage` structure.
    bytes32 private constant DIAMOND_STORAGE_POSITION =
        0xc8fcad8db84d3cc18b4c41d551ea0ee66dd599cde068d998e57d5e09332c131b; // keccak256("diamond.standard.diamond.storage") - 1;

    event DiamondCut(FacetCut[] facetCuts, address initAddress, bytes initCalldata);

    /// @dev Utility struct that contains associated facet & meta information of selector
    /// @param facetAddress address of the facet which is connected with selector
    /// @param selectorPosition index in `FacetToSelectors.selectors` array, where is selector stored
    /// @param isFreezable denotes whether the selector can be frozen.
    struct SelectorToFacet {
        address facetAddress;
        uint16 selectorPosition;
        bool isFreezable;
    }

    /// @dev Utility struct that contains associated selectors & meta information of facet
    /// @param selectors list of all selectors that belong to the facet
    /// @param facetPosition index in `DiamondStorage.facets` array, where is facet stored
    struct FacetToSelectors {
        bytes4[] selectors;
        uint16 facetPosition;
    }

    /// @notice The structure that holds all diamond proxy associated parameters
    /// @dev According to the EIP-2535 should be stored on a special storage key - `DIAMOND_STORAGE_POSITION`
    /// @param selectorToFacet A mapping from the selector to the facet address and its meta information
    /// @param facetToSelectors A mapping from facet address to its selectors with meta information
    /// @param facets The array of all unique facet addresses that belong to the diamond proxy
    /// @param isFrozen Denotes whether the diamond proxy is frozen and all freezable facets are not accessible
    struct DiamondStorage {
        mapping(bytes4 selector => SelectorToFacet selectorInfo) selectorToFacet;
        mapping(address facetAddress => FacetToSelectors facetInfo) facetToSelectors;
        address[] facets;
        bool isFrozen;
    }

    /// @dev Parameters for diamond changes that touch one of the facets
    /// @param facet The address of facet that's affected by the cut
    /// @param action The action that is made on the facet
    /// @param isFreezable Denotes whether the facet & all their selectors can be frozen
    /// @param selectors An array of unique selectors that belongs to the facet address
    // solhint-disable-next-line gas-struct-packing
    struct FacetCut {
        address facet;
        Action action;
        bool isFreezable;
        bytes4[] selectors;
    }

    /// @dev Structure of the diamond proxy changes
    /// @param facetCuts The set of changes (adding/removing/replacement) of implementation contracts
    /// @param initAddress The address that's delegate called after setting up new facet changes
    /// @param initCalldata Calldata for the delegate call to `initAddress`
    struct DiamondCutData {
        FacetCut[] facetCuts;
        address initAddress;
        bytes initCalldata;
    }

    /// @dev Type of change over diamond: add/replace/remove facets
    enum Action {
        Add,
        Replace,
        Remove
    }

    /// @return diamondStorage The pointer to the storage where all specific diamond proxy parameters stored
    function getDiamondStorage() internal pure returns (DiamondStorage storage diamondStorage) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            diamondStorage.slot := position
        }
    }

    /// @dev Add/replace/remove any number of selectors and optionally execute a function with delegatecall
    /// @param _diamondCut Diamond's facet changes and the parameters to optional initialization delegatecall
    function diamondCut(DiamondCutData memory _diamondCut) internal {
        FacetCut[] memory facetCuts = _diamondCut.facetCuts;
        address initAddress = _diamondCut.initAddress;
        bytes memory initCalldata = _diamondCut.initCalldata;
        uint256 facetCutsLength = facetCuts.length;
        for (uint256 i = 0; i < facetCutsLength; i = i.uncheckedInc()) {
            Action action = facetCuts[i].action;
            address facet = facetCuts[i].facet;
            bool isFacetFreezable = facetCuts[i].isFreezable;
            bytes4[] memory selectors = facetCuts[i].selectors;

            if (selectors.length == 0) {
                revert NoFunctionsForDiamondCut();
            }

            if (action == Action.Add) {
                _addFunctions(facet, selectors, isFacetFreezable);
            } else if (action == Action.Replace) {
                _replaceFunctions(facet, selectors, isFacetFreezable);
            } else if (action == Action.Remove) {
                _removeFunctions(facet, selectors);
            } else {
                revert UndefinedDiamondCutAction();
            }
        }

        _initializeDiamondCut(initAddress, initCalldata);
        emit DiamondCut(facetCuts, initAddress, initCalldata);
    }

    /// @dev Add new functions to the diamond proxy
    /// NOTE: expect but NOT enforce that `_selectors` is NON-EMPTY array
    function _addFunctions(address _facet, bytes4[] memory _selectors, bool _isFacetFreezable) private {
        DiamondStorage storage ds = getDiamondStorage();

        // Facet with no code cannot be added.
        // This check also verifies that the facet does not have zero address, since it is the
        // address with which 0x00000000 selector is associated.
        if (_facet.code.length == 0) {
            revert AddressHasNoCode(_facet);
        }

        // Add facet to the list of facets if the facet address is new one
        _saveFacetIfNew(_facet);

        uint256 selectorsLength = _selectors.length;
        for (uint256 i = 0; i < selectorsLength; i = i.uncheckedInc()) {
            bytes4 selector = _selectors[i];
            SelectorToFacet memory oldFacet = ds.selectorToFacet[selector];
            if (oldFacet.facetAddress != address(0)) {
                revert FacetExists(selector, oldFacet.facetAddress);
            }

            _addOneFunction(_facet, selector, _isFacetFreezable);
        }
    }

    /// @dev Change associated facets to already known function selectors
    /// NOTE: expect but NOT enforce that `_selectors` is NON-EMPTY array
    function _replaceFunctions(address _facet, bytes4[] memory _selectors, bool _isFacetFreezable) private {
        DiamondStorage storage ds = getDiamondStorage();

        // Facet with no code cannot be added.
        // This check also verifies that the facet does not have zero address, since it is the
        // address with which 0x00000000 selector is associated.
        if (_facet.code.length == 0) {
            revert AddressHasNoCode(_facet);
        }

        uint256 selectorsLength = _selectors.length;
        for (uint256 i = 0; i < selectorsLength; i = i.uncheckedInc()) {
            bytes4 selector = _selectors[i];
            SelectorToFacet memory oldFacet = ds.selectorToFacet[selector];
            // it is impossible to replace the facet with zero address
            if (oldFacet.facetAddress == address(0)) {
                revert ReplaceFunctionFacetAddressZero();
            }

            _removeOneFunction(oldFacet.facetAddress, selector);
            // Add facet to the list of facets if the facet address is a new one
            _saveFacetIfNew(_facet);
            _addOneFunction(_facet, selector, _isFacetFreezable);
        }
    }

    /// @dev Remove association with function and facet
    /// NOTE: expect but NOT enforce that `_selectors` is NON-EMPTY array
    function _removeFunctions(address _facet, bytes4[] memory _selectors) private {
        DiamondStorage storage ds = getDiamondStorage();

        // facet address must be zero
        if (_facet != address(0)) {
            revert RemoveFunctionFacetAddressNotZero(_facet);
        }

        uint256 selectorsLength = _selectors.length;
        for (uint256 i = 0; i < selectorsLength; i = i.uncheckedInc()) {
            bytes4 selector = _selectors[i];
            SelectorToFacet memory oldFacet = ds.selectorToFacet[selector];
            // Can't delete a non-existent facet
            if (oldFacet.facetAddress == address(0)) {
                revert RemoveFunctionFacetAddressZero();
            }

            _removeOneFunction(oldFacet.facetAddress, selector);
        }
    }

    /// @dev Add address to the list of known facets if it is not on the list yet
    /// NOTE: should be called ONLY before adding a new selector associated with the address
    function _saveFacetIfNew(address _facet) private {
        DiamondStorage storage ds = getDiamondStorage();

        uint256 selectorsLength = ds.facetToSelectors[_facet].selectors.length;
        // If there are no selectors associated with facet then save facet as new one
        if (selectorsLength == 0) {
            ds.facetToSelectors[_facet].facetPosition = ds.facets.length.toUint16();
            ds.facets.push(_facet);
        }
    }

    /// @dev Add one function to the already known facet
    /// NOTE: It is expected but NOT enforced that:
    /// - `_facet` is NON-ZERO address
    /// - `_facet` is already stored address in `DiamondStorage.facets`
    /// - `_selector` is NOT associated by another facet
    function _addOneFunction(address _facet, bytes4 _selector, bool _isSelectorFreezable) private {
        DiamondStorage storage ds = getDiamondStorage();

        uint16 selectorPosition = (ds.facetToSelectors[_facet].selectors.length).toUint16();

        // if selectorPosition is nonzero, it means it is not a new facet
        // so the freezability of the first selector must be matched to _isSelectorFreezable
        // so all the selectors in a facet will have the same freezability
        if (selectorPosition != 0) {
            bytes4 selector0 = ds.facetToSelectors[_facet].selectors[0];
            if (_isSelectorFreezable != ds.selectorToFacet[selector0].isFreezable) {
                revert SelectorsMustAllHaveSameFreezability();
            }
        }

        ds.selectorToFacet[_selector] = SelectorToFacet({
            facetAddress: _facet,
            selectorPosition: selectorPosition,
            isFreezable: _isSelectorFreezable
        });
        ds.facetToSelectors[_facet].selectors.push(_selector);
    }

    /// @dev Remove one associated function with facet
    /// NOTE: It is expected but NOT enforced that `_facet` is NON-ZERO address
    function _removeOneFunction(address _facet, bytes4 _selector) private {
        DiamondStorage storage ds = getDiamondStorage();

        // Get index of `FacetToSelectors.selectors` of the selector and last element of array
        uint256 selectorPosition = ds.selectorToFacet[_selector].selectorPosition;
        uint256 lastSelectorPosition = ds.facetToSelectors[_facet].selectors.length - 1;

        // If the selector is not at the end of the array then move the last element to the selector position
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetToSelectors[_facet].selectors[lastSelectorPosition];

            ds.facetToSelectors[_facet].selectors[selectorPosition] = lastSelector;
            ds.selectorToFacet[lastSelector].selectorPosition = selectorPosition.toUint16();
        }

        // Remove last element from the selectors array
        ds.facetToSelectors[_facet].selectors.pop();

        // Finally, clean up the association with facet
        delete ds.selectorToFacet[_selector];

        // If there are no selectors for facet then remove the facet from the list of known facets
        if (lastSelectorPosition == 0) {
            _removeFacet(_facet);
        }
    }

    /// @dev remove facet from the list of known facets
    /// NOTE: It is expected but NOT enforced that there are no selectors associated with `_facet`
    function _removeFacet(address _facet) private {
        DiamondStorage storage ds = getDiamondStorage();

        // Get index of `DiamondStorage.facets` of the facet and last element of array
        uint256 facetPosition = ds.facetToSelectors[_facet].facetPosition;
        uint256 lastFacetPosition = ds.facets.length - 1;

        // If the facet is not at the end of the array then move the last element to the facet position
        if (facetPosition != lastFacetPosition) {
            address lastFacet = ds.facets[lastFacetPosition];

            ds.facets[facetPosition] = lastFacet;
            ds.facetToSelectors[lastFacet].facetPosition = facetPosition.toUint16();
        }

        // Remove last element from the facets array
        ds.facets.pop();
    }

    /// @dev Delegates call to the initialization address with provided calldata
    /// @dev Used as a final step of diamond cut to execute the logic of the initialization for changed facets
    function _initializeDiamondCut(address _init, bytes memory _calldata) private {
        if (_init == address(0)) {
            // Non-empty calldata for zero address
            if (_calldata.length != 0) {
                revert NonEmptyCalldata();
            }
        } else {
            // Do not check whether `_init` is a contract since later we check that it returns data.
            (bool success, bytes memory data) = _init.delegatecall(_calldata);
            if (!success) {
                // If the returndata is too small, we still want to produce some meaningful error

                if (data.length < 4) {
                    revert DelegateCallFailed(data);
                }

                assembly {
                    revert(add(data, 0x20), mload(data))
                }
            }

            // Check that called contract returns magic value to make sure that contract logic
            // supposed to be used as diamond cut initializer.
            if (data.length != 32) {
                revert DelegateCallFailed(data);
            }
            if (abi.decode(data, (bytes32)) != DIAMOND_INIT_SUCCESS_RETURN_VALUE) {
                revert DelegateCallFailed(data);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

/// @notice Library for storage of packed unsigned integers.
/// @author Matter Labs
/// @dev This library is an adaptation of the corresponding Solady library (https://github.com/vectorized/solady/blob/main/src/utils/LibMap.sol)
/// @custom:security-contact security@matterlabs.dev
library LibMap {
    /// @dev A uint32 map in storage.
    struct Uint32Map {
        mapping(uint256 packedIndex => uint256 eightPackedValues) map;
    }

    /// @dev Retrieves the uint32 value at a specific index from the Uint32Map.
    /// @param _map The Uint32Map instance containing the packed uint32 values.
    /// @param _index The index of the uint32 value to retrieve.
    /// @return result The uint32 value at the specified index.
    function get(Uint32Map storage _map, uint256 _index) internal view returns (uint32 result) {
        unchecked {
            // Each storage slot can store 256 bits of data.
            // As uint32 is 32 bits long, 8 uint32s can be packed into one storage slot.
            // Hence, `_index / 8` is done to find the storage slot that contains the required uint32.
            uint256 mapValue = _map.map[_index / 8];

            // First three bits of the original `_index` denotes the position of the uint32 in that slot.
            // So, '(_index & 7) * 32' is done to find the bit position of the uint32 in that storage slot.
            uint256 bitOffset = (_index & 7) * 32;

            // Shift the bits to the right and retrieve the uint32 value.
            result = uint32(mapValue >> bitOffset);
        }
    }

    /// @dev Updates the uint32 value at `_index` in `map`.
    /// @param _map The Uint32Map instance containing the packed uint32 values.
    /// @param _index The index of the uint32 value to set.
    /// @param _value The new value at the specified index.
    function set(Uint32Map storage _map, uint256 _index, uint32 _value) internal {
        unchecked {
            // Each storage slot can store 256 bits of data.
            // As uint32 is 32 bits long, 8 uint32s can be packed into one storage slot.
            // Hence, `_index / 8` is done to find the storage slot that contains the required uint32.
            uint256 mapIndex = _index / 8;
            uint256 mapValue = _map.map[mapIndex];

            // First three bits of the original `_index` denotes the position of the uint32 in that slot.
            // So, '(_index & 7) * 32' is done to find the bit position of the uint32 in that storage slot.
            uint256 bitOffset = (_index & 7) * 32;

            // XORing a value A with B, and then with A again, gives the original value B.
            // We will use this property to update the uint32 value in the slot.

            // Shift the bits to the right and retrieve the uint32 value.
            uint32 oldValue = uint32(mapValue >> bitOffset);

            // Calculate the XOR of the new value and the existing value.
            uint256 newValueXorOldValue = uint256(oldValue ^ _value);

            // Finally, we XOR the slot with the XOR of the new value and the existing value,
            // shifted to its proper position. The XOR operation will effectively replace the old value with the new value.
            _map.map[mapIndex] = (newValueXorOldValue << bitOffset) ^ mapValue;
        }
    }
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the ZKsync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

import {QueueIsEmpty} from "../../common/L1ContractErrors.sol";

/// @notice The structure that contains meta information of the L2 transaction that was requested from L1
/// @dev The weird size of fields was selected specifically to minimize the structure storage size
/// @param canonicalTxHash Hashed L2 transaction data that is needed to process it
/// @param expirationTimestamp Expiration timestamp for this request (must be satisfied before)
/// @param layer2Tip Additional payment to the validator as an incentive to perform the operation
struct PriorityOperation {
    bytes32 canonicalTxHash;
    uint64 expirationTimestamp;
    uint192 layer2Tip;
}

/// @author Matter Labs
/// @custom:security-contact security@matterlabs.dev
/// @dev The library provides the API to interact with the priority queue container
/// @dev Order of processing operations from queue - FIFO (Fist in - first out)
library PriorityQueue {
    using PriorityQueue for Queue;

    /// @notice Container that stores priority operations
    /// @param data The inner mapping that saves priority operation by its index
    /// @param head The pointer to the first unprocessed priority operation, equal to the tail if the queue is empty
    /// @param tail The pointer to the free slot
    struct Queue {
        mapping(uint256 priorityOpId => PriorityOperation priorityOp) data;
        uint256 tail;
        uint256 head;
    }

    /// @notice Returns zero if and only if no operations were processed from the queue
    /// @return Index of the oldest priority operation that wasn't processed yet
    function getFirstUnprocessedPriorityTx(Queue storage _queue) internal view returns (uint256) {
        return _queue.head;
    }

    /// @return The total number of priority operations that were added to the priority queue, including all processed ones
    function getTotalPriorityTxs(Queue storage _queue) internal view returns (uint256) {
        return _queue.tail;
    }

    /// @return The total number of unprocessed priority operations in a priority queue
    function getSize(Queue storage _queue) internal view returns (uint256) {
        return uint256(_queue.tail - _queue.head);
    }

    /// @return Whether the priority queue contains no operations
    function isEmpty(Queue storage _queue) internal view returns (bool) {
        return _queue.tail == _queue.head;
    }

    /// @notice Add the priority operation to the end of the priority queue
    function pushBack(Queue storage _queue, PriorityOperation memory _operation) internal {
        // Save value into the stack to avoid double reading from the storage
        uint256 tail = _queue.tail;

        _queue.data[tail] = _operation;
        _queue.tail = tail + 1;
    }

    /// @return The first unprocessed priority operation from the queue
    function front(Queue storage _queue) internal view returns (PriorityOperation memory) {
        // priority queue is empty
        if (_queue.isEmpty()) {
            revert QueueIsEmpty();
        }

        return _queue.data[_queue.head];
    }

    /// @notice Remove the first unprocessed priority operation from the queue
    /// @return priorityOperation that was popped from the priority queue
    function popFront(Queue storage _queue) internal returns (PriorityOperation memory priorityOperation) {
        // priority queue is empty
        if (_queue.isEmpty()) {
            revert QueueIsEmpty();
        }

        // Save value into the stack to avoid double reading from the storage
        uint256 head = _queue.head;

        priorityOperation = _queue.data[head];
        delete _queue.data[head];
        _queue.head = head + 1;
    }
}
// SPDX-License-Identifier: MIT
// We use a floating point pragma here so it can be used within other projects that interact with the zkSync ecosystem without using our exact pragma version.
pragma solidity ^0.8.21;

import {DynamicIncrementalMerkle} from "../../common/libraries/DynamicIncrementalMerkle.sol";
import {Merkle} from "../../common/libraries/Merkle.sol";
import {PriorityTreeCommitment} from "../../common/Config.sol";
import {NotHistoricalRoot, InvalidCommitment, InvalidStartIndex, InvalidUnprocessedIndex, InvalidNextLeafIndex} from "../L1StateTransitionErrors.sol";

struct PriorityOpsBatchInfo {
    bytes32[] leftPath;
    bytes32[] rightPath;
    bytes32[] itemHashes;
}

bytes32 constant ZERO_LEAF_HASH = keccak256("");

library PriorityTree {
    using PriorityTree for Tree;
    using DynamicIncrementalMerkle for DynamicIncrementalMerkle.Bytes32PushTree;

    struct Tree {
        uint256 startIndex; // priority tree started accepting priority ops from this index
        uint256 unprocessedIndex; // relative to `startIndex`
        mapping(bytes32 => bool) historicalRoots;
        DynamicIncrementalMerkle.Bytes32PushTree tree;
    }

    /// @notice Returns zero if and only if no operations were processed from the tree
    /// @return Index of the oldest priority operation that wasn't processed yet
    function getFirstUnprocessedPriorityTx(Tree storage _tree) internal view returns (uint256) {
        return _tree.startIndex + _tree.unprocessedIndex;
    }

    /// @return The total number of priority operations that were added to the priority queue, including all processed ones
    function getTotalPriorityTxs(Tree storage _tree) internal view returns (uint256) {
        return _tree.startIndex + _tree.tree._nextLeafIndex;
    }

    /// @return The total number of unprocessed priority operations in a priority queue
    function getSize(Tree storage _tree) internal view returns (uint256) {
        return _tree.tree._nextLeafIndex - _tree.unprocessedIndex;
    }

    /// @notice Add the priority operation to the end of the priority queue
    function push(Tree storage _tree, bytes32 _hash) internal {
        (, bytes32 newRoot) = _tree.tree.push(_hash);
        _tree.historicalRoots[newRoot] = true;
    }

    /// @notice Set up the tree
    function setup(Tree storage _tree, uint256 _startIndex) internal {
        bytes32 initialRoot = _tree.tree.setup(ZERO_LEAF_HASH);
        _tree.historicalRoots[initialRoot] = true;
        _tree.startIndex = _startIndex;
    }

    /// @return Returns the tree root.
    function getRoot(Tree storage _tree) internal view returns (bytes32) {
        return _tree.tree.root();
    }

    /// @param _root The root to check.
    /// @return Returns true if the root is a historical root.
    function isHistoricalRoot(Tree storage _tree, bytes32 _root) internal view returns (bool) {
        return _tree.historicalRoots[_root];
    }

    /// @notice Process the priority operations of a batch.
    /// @dev Note, that the function below only checks that a certain segment of items is present in the tree.
    /// It does not check that e.g. there are no zero items inside the provided `itemHashes`, so in theory proofs
    /// that include non-existing priority operations could be created. This function relies on the fact
    /// that the `itemHashes` of `_priorityOpsData` are hashes of valid priority transactions.
    /// This fact is ensures by the fact the rolling hash of those is sent to the Executor by the bootloader
    /// and so assuming that zero knowledge proofs are correct, so is the structure of the `itemHashes`.
    function processBatch(Tree storage _tree, PriorityOpsBatchInfo memory _priorityOpsData) internal {
        if (_priorityOpsData.itemHashes.length > 0) {
            bytes32 expectedRoot = Merkle.calculateRootPaths(
                _priorityOpsData.leftPath,
                _priorityOpsData.rightPath,
                _tree.unprocessedIndex,
                _priorityOpsData.itemHashes
            );
            if (!_tree.historicalRoots[expectedRoot]) {
                revert NotHistoricalRoot();
            }
            _tree.unprocessedIndex += _priorityOpsData.itemHashes.length;
        }
    }

    /// @notice Allows to skip a certain number of operations.
    /// @param _lastUnprocessed The new expected id of the unprocessed transaction.
    /// @dev It is used when the corresponding transactions have been processed by priority queue.
    function skipUntil(Tree storage _tree, uint256 _lastUnprocessed) internal {
        if (_tree.startIndex > _lastUnprocessed) {
            // Nothing to do, return
            return;
        }
        uint256 newUnprocessedIndex = _lastUnprocessed - _tree.startIndex;
        if (newUnprocessedIndex <= _tree.unprocessedIndex) {
            // These transactions were already processed, skip.
            return;
        }

        _tree.unprocessedIndex = newUnprocessedIndex;
    }

    /// @notice Initialize a chain from a commitment.
    function initFromCommitment(Tree storage _tree, PriorityTreeCommitment memory _commitment) internal {
        uint256 height = _commitment.sides.length; // Height, including the root node.
        if (height == 0) {
            revert InvalidCommitment();
        }
        _tree.startIndex = _commitment.startIndex;
        _tree.unprocessedIndex = _commitment.unprocessedIndex;
        _tree.tree._nextLeafIndex = _commitment.nextLeafIndex;
        _tree.tree._sides = _commitment.sides;
        bytes32 zero = ZERO_LEAF_HASH;
        _tree.tree._zeros = new bytes32[](height);
        for (uint256 i; i < height; ++i) {
            _tree.tree._zeros[i] = zero;
            zero = Merkle.efficientHash(zero, zero);
        }
        _tree.historicalRoots[_tree.tree.root()] = true;
    }

    /// @notice Reinitialize the tree from a commitment on L1.
    function l1Reinit(Tree storage _tree, PriorityTreeCommitment memory _commitment) internal {
        if (_tree.startIndex != _commitment.startIndex) {
            revert InvalidStartIndex(_tree.startIndex, _commitment.startIndex);
        }
        if (_tree.unprocessedIndex > _commitment.unprocessedIndex) {
            revert InvalidUnprocessedIndex(_tree.unprocessedIndex, _commitment.unprocessedIndex);
        }
        if (_tree.tree._nextLeafIndex < _commitment.nextLeafIndex) {
            revert InvalidNextLeafIndex(_tree.tree._nextLeafIndex, _commitment.nextLeafIndex);
        }

        _tree.unprocessedIndex = _commitment.unprocessedIndex;
    }

    /// @notice Reinitialize the tree from a commitment on GW.
    function checkGWReinit(Tree storage _tree, PriorityTreeCommitment memory _commitment) internal view {
        if (_tree.startIndex != _commitment.startIndex) {
            revert InvalidStartIndex(_tree.startIndex, _commitment.startIndex);
        }
        if (_tree.unprocessedIndex > _commitment.unprocessedIndex) {
            revert InvalidUnprocessedIndex(_tree.unprocessedIndex, _commitment.unprocessedIndex);
        }
        if (_tree.tree._nextLeafIndex > _commitment.nextLeafIndex) {
            revert InvalidNextLeafIndex(_tree.tree._nextLeafIndex, _commitment.nextLeafIndex);
        }
    }

    /// @notice Returns the commitment to the priority tree.
    function getCommitment(Tree storage _tree) internal view returns (PriorityTreeCommitment memory commitment) {
        commitment.nextLeafIndex = _tree.tree._nextLeafIndex;
        commitment.startIndex = _tree.startIndex;
        commitment.unprocessedIndex = _tree.unprocessedIndex;
        commitment.sides = _tree.tree._sides;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Arrays.sol)

pragma solidity ^0.8.0;

import "./StorageSlot.sol";
import "./math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    using StorageSlot for bytes32;

    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (unsafeAccess(array, mid).value > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && unsafeAccess(array, low - 1).value == element) {
            return low - 1;
        } else {
            return low;
        }
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(address[] storage arr, uint256 pos) internal pure returns (StorageSlot.AddressSlot storage) {
        bytes32 slot;
        // We use assembly to calculate the storage slot of the element at index `pos` of the dynamic array `arr`
        // following https://docs.soliditylang.org/en/v0.8.17/internals/layout_in_storage.html#mappings-and-dynamic-arrays.

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getAddressSlot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(bytes32[] storage arr, uint256 pos) internal pure returns (StorageSlot.Bytes32Slot storage) {
        bytes32 slot;
        // We use assembly to calculate the storage slot of the element at index `pos` of the dynamic array `arr`
        // following https://docs.soliditylang.org/en/v0.8.17/internals/layout_in_storage.html#mappings-and-dynamic-arrays.

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getBytes32Slot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(uint256[] storage arr, uint256 pos) internal pure returns (StorageSlot.Uint256Slot storage) {
        bytes32 slot;
        // We use assembly to calculate the storage slot of the element at index `pos` of the dynamic array `arr`
        // following https://docs.soliditylang.org/en/v0.8.17/internals/layout_in_storage.html#mappings-and-dynamic-arrays.

        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getUint256Slot();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.0;

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
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._
 * _Available since v4.9 for `string`, `bytes`._
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
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
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
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
            require(denominator > prod1, "Math: mulDiv overflow");

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
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
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
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
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

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
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
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
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
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
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
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
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}