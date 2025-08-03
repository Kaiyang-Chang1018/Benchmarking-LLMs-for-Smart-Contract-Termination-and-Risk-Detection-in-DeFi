// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ITransferManager} from "@looksrare/contracts-transfer-manager/contracts/interfaces/ITransferManager.sol";
import {TokenType as TransferManager__TokenType} from "@looksrare/contracts-transfer-manager/contracts/enums/TokenType.sol";
import {IERC20} from "@looksrare/contracts-libs/contracts/interfaces/generic/IERC20.sol";
import {SignatureCheckerMemory} from "@looksrare/contracts-libs/contracts/SignatureCheckerMemory.sol";
import {ReentrancyGuard} from "@looksrare/contracts-libs/contracts/ReentrancyGuard.sol";
import {Pausable} from "@looksrare/contracts-libs/contracts/Pausable.sol";

import {LowLevelWETH} from "@looksrare/contracts-libs/contracts/lowLevelCallers/LowLevelWETH.sol";
import {LowLevelERC20Transfer} from "@looksrare/contracts-libs/contracts/lowLevelCallers/LowLevelERC20Transfer.sol";
import {LowLevelERC721Transfer} from "@looksrare/contracts-libs/contracts/lowLevelCallers/LowLevelERC721Transfer.sol";

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import {IYoloV2} from "./interfaces/IYoloV2.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {Arrays} from "./libraries/Arrays.sol";

import {AlreadyWithdrawn_error_selector, CutoffTimeNotReached_error_selector, DrawExpirationTimeNotReached_error_selector, InsufficientParticipants_error_selector, InvalidIndex_error_selector, InvalidLength_error_selector, InvalidSignatureTimestamp_error_selector, InvalidStatus_error_selector, InvalidToken_error_selector, InvalidTokenType_error_selector, InvalidValue_error_selector, LooksAlreadySet_error_selector, MaximumNumberOfDepositsReached_error_selector, MaximumNumberOfParticipantsReached_error_selector, MessageIdInvalid_error_selector, NotDepositor_error_selector, NotOperator_error_selector, NotOwner_error_selector, NotWinner_error_selector, OnePlayerCannotFillUpTheWholeRound_error_selector, OutflowNotAllowed_error_selector, ProtocolFeeNotPaid_error_selector, RandomnessRequestAlreadyExists_error_selector, RoundCannotBeClosed_error_selector, TooFewEntries_error_selector, ZeroDeposits_error_selector, ZeroEntries_error_selector, ZeroRounds_error_selector, Error_selector_offset, Error_standard_length} from "./constants/AssemblyConstants.sol";

//                                          @@@@@@@@@@@@@                                        @@@@@@@@@@@@@
// @@@@@@@@@@@@@@@       @@@@@@@@@@@@@@ @@@@%*+++++++++*%@@@@     @@@@@@@@@@@@@@             @@@@%+-:::::::-+%@@@@
//  @#:........=@@      @@*.........+@@@@*=================*@@@   @@=........=@@           @@@+.................+@@@
//  @@=........:#@@     @@.........:@@%+=====================+%@@ @@=........=@@         @@%-.....................-#@@
//  @@%:........=@@    @@=........:%@*=========================+%@@@=........=@@       @@%-.........................=@@@
//   @@+........:#@   @@#........:%%============================+#@@=........=@@      @@#:...........................:#@@
//    @@:........+@@  @@:.......:#%%@#*=======*%%@@@%%*==========+%@=........=@@      @#:.........:=*%%@%%#=..........:#@@
//    @@#........:%@ @@+........+%+==+#@@*==#@@@@   @@@@#=========+@#........=@@     @%-........:*@@@@   @@@@+:........-%@
//     @@=........=@@@#:.......-%*=======*@@@@         @@@=========*@:.......+@@    @@*.........@@@         @@%:........+@@
//      @%:.......:%@@=........=@+========*@@            @%=========@+.......+@@    @@-........%@@           @@*........=%@
//      @@+:.....:.-@#:.:......+@@@@@@@@@@@@             @@%%%%%%%%#@#::....:+@@    @@:.:.....:@@             @@::.:..:.-%@
//       @%-::::::::*-:::::::::@@*+++++++*@@             @@+++++++++@*:::::::+@@    @@:::::::::%@            @@%::::::::-%@
//       @@%********=:::::::::*@@*+*#%@@@##@@           @@*========+@=:::::::+@@    @@=::::::::=@@           @@=::::::::+@@
//        @@@@@@@@@@:::::::::=@@@@@#*++++++*@@        @@@+=========%@::::::::+@@     @%:::::::::=@@@       @@@=:::::::::#@@
//               @@=:::::::::%@ @@*++++++++++*@@@@@@@@@*+========+#@+::::::::+%@@@@@@@%+::::::::::+@@@@@@@@@+::::::::::+@@
//              @@#:::::::::*@@  @@*+++++++++*@#++++++==========+*@@+::::::::::::::::::::::::::::::::-===-::::::::::::=@@
//              @@-::::::::-%@    @@#++++++++%%+===============+#@@@+::::::::::::::::::::::::::::::::::::::::::::::::*@@
//             @@+:::::::::*@@     @@@*+++++%%+===============*%@@@@+:::::::::::::::::::::*=:::::::::::::::::::::::=%@@
//             @%-::::::::=@@        @@@#++#@*+============+*@@@  @@+:::::::::::::::::::::%@%+-::::::::::::::::::+%@@
//            @@%*********%@@          @@@@@*+==========+#@@@@    @@#*********************%@@@@@*-:::::::::::-*@@@@
//            @@@@@@@@@@@@@@              @@@@@@@%%%@@@@@@@       @@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@%%%@@@@@@@
//                                               @@@@                                                @@@@@

/**
 * @title YoloV2
 * @notice This contract permissionlessly hosts yolos on LooksRare.
 * @author LooksRare protocol team (?,?)
 */
contract YoloV2 is
    IYoloV2,
    AccessControl,
    VRFConsumerBaseV2,
    LowLevelWETH,
    LowLevelERC20Transfer,
    LowLevelERC721Transfer,
    ReentrancyGuard,
    Pausable
{
    using Arrays for uint256[];

    /**
     * @notice Operators are allowed to add/remove allowed ERC-20 and ERC-721 tokens.
     */
    bytes32 private constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /**
     * @notice The TWAP period in seconds to use.
     */
    uint256 private constant TWAP_DURATION = 3_600;

    /**
     * @notice The maximum protocol fee in basis points, which is 25%.
     */
    uint16 private constant MAXIMUM_PROTOCOL_FEE_BP = 2_500;

    /**
     * @notice The maximum number of deposits per round.
     */
    uint256 private constant MAXIMUM_NUMBER_OF_DEPOSITS_PER_ROUND = 100;

    /**
     * @notice Reservoir oracle's message typehash.
     * @dev It is used to compute the hash of the message using the (message) id, the payload, and the timestamp.
     */
    bytes32 private constant RESERVOIR_ORACLE_MESSAGE_TYPEHASH =
        keccak256("Message(bytes32 id,bytes payload,uint256 timestamp,uint256 chainId)");

    /**
     * @notice Reservoir oracle's ID typehash.
     * @dev It is used to compute the hash of the ID using price kind, TWAP seconds, and the contract address.
     */
    bytes32 private constant RESERVOIR_ORACLE_ID_TYPEHASH =
        keccak256(
            "ContractWideCollectionPrice(uint8 kind,uint256 twapSeconds,address contract,bool onlyNonFlaggedTokens)"
        );

    /**
     * @notice The bits offset of the round's maximum number of participants in a round slot.
     */
    uint256 private constant ROUND__MAXIMUM_NUMBER_OF_PARTICIPANTS_OFFSET = 8;

    /**
     * @notice The bits offset of the round's protocol fee basis points in a round slot.
     */
    uint256 private constant ROUND__PROTOCOL_FEE_BP_OFFSET = 48;

    /**
     * @notice The bits offset of the round's cutoff time in a round slot.
     */
    uint256 private constant ROUND__CUTOFF_TIME_OFFSET = 64;

    /**
     * @notice The bits offset of the round's value per entry in a round slot.
     */
    uint256 private constant ROUND__VALUE_PER_ENTRY_OFFSET = 160;

    /**
     * @notice The slot offset of the round's value per entry starting from the round's slot.
     */
    uint256 private constant ROUND__VALUE_PER_ENTRY_SLOT_OFFSET = 1;

    /**
     * @notice The bits offset of the randomness request's round ID in a randomness request slot.
     */
    uint256 private constant RANDOMNESS_REQUEST__ROUND_ID_OFFSET = 8;

    /**
     * @notice The slot offset of the round's deposits length starting from the round's slot.
     */
    uint256 private constant ROUND__DEPOSITS_LENGTH_SLOT_OFFSET = 3;

    /**
     * @notice The number of slots a round struct occupies.
     */
    uint256 private constant DEPOSIT__OCCUPIED_SLOTS = 4;

    /**
     * @notice The slot offset of the deposit's token ID starting from the deposit's slot.
     */
    uint256 private constant DEPOSIT__TOKEN_ID_SLOT_OFFSET = 1;

    /**
     * @notice The slot offset of the deposit's token amount starting from the deposit's slot.
     */
    uint256 private constant DEPOSIT__TOKEN_AMOUNT_SLOT_OFFSET = 2;

    /**
     * @notice The slot offset of the deposit's last slot starting from the deposit's slot.
     */
    uint256 private constant DEPOSIT__LAST_SLOT_OFFSET = 3;

    /**
     * @notice The bits offset of the deposit's token address in the deposit's slot 0.
     */
    uint256 private constant DEPOSIT__TOKEN_ADDRESS_OFFSET = 8;

    /**
     * @notice The bits offset of the deposit's current entry index in the deposit's slot 3.
     */
    uint256 private constant DEPOSIT__CURRENT_ENTRY_INDEX_OFFSET = 168;

    /**
     * @notice Wrapped Ether address.
     */
    address private immutable WETH;

    /**
     * @notice The key hash of the Chainlink VRF.
     */
    bytes32 private immutable KEY_HASH;

    /**
     * @notice The subscription ID of the Chainlink VRF.
     */
    uint64 private immutable SUBSCRIPTION_ID;

    /**
     * @notice The Chainlink VRF coordinator.
     */
    VRFCoordinatorV2Interface private immutable VRF_COORDINATOR;

    /**
     * @notice The minimum number of confirmation blocks on VRF requests before oracles respond.
     */
    uint16 private immutable MINIMUM_REQUEST_CONFIRMATIONS;

    /**
     * @notice Transfer manager faciliates token transfers.
     */
    ITransferManager private immutable transferManager;

    /**
     * @notice LOOKS token address.
     */
    address private LOOKS;

    /**
     * @notice The value of each entry in ETH.
     */
    uint96 public valuePerEntry;

    /**
     * @notice The duration of each round.
     */
    uint40 public roundDuration;

    /**
     * @notice The protocol fee basis points.
     */
    uint16 public protocolFeeBp;

    /**
     * @notice The discounted protocol fee basis points if paid with LOOKS.
     */
    uint16 public discountedProtocolFeeBp;

    /**
     * @notice Number of rounds that have been created.
     * @dev In this smart contract, roundId is an uint256 but its
     *      max value can only be 2^40 - 1. Realistically we will still
     *      not reach this number.
     */
    uint40 public roundsCount;

    /**
     * @notice The maximum number of participants per round.
     */
    uint40 public maximumNumberOfParticipantsPerRound;

    /**
     * @notice Whether token outflow is allowed.
     */
    bool public outflowAllowed = true;

    /**
     * @notice The address of the protocol fee recipient.
     */
    address private protocolFeeRecipient;

    /**
     * @notice ERC-20 oracle address.
     */
    IPriceOracle public erc20Oracle;

    /**
     * @notice Reservoir oracle address.
     */
    address public reservoirOracle;

    /**
     * @notice Reservoir oracle's signature validity period.
     */
    uint40 public signatureValidityPeriod;

    /**
     * @notice It checks whether the token is allowed.
     * @dev 0 is not allowed, 1 is allowed.
     *      token is the hash of the token address and the token type.
     */
    mapping(bytes32 token => uint256 isAllowed) private isTokenAllowed;

    mapping(uint256 roundId => Round) private rounds;

    /**
     * @notice The deposit count of a user in any given round.
     */
    mapping(uint256 roundId => mapping(address depositor => uint256 depositCount)) public depositCount;

    /**
     * @notice Chainlink randomness requests.
     */
    mapping(uint256 requestId => RandomnessRequest) public randomnessRequests;

    /**
     * @notice The price of an ERC-20/ERC-712 token or a collection in any given round.
     */
    mapping(address tokenOrCollection => mapping(uint256 roundId => uint256 price)) public prices;

    /**
     * @param params The constructor params.
     */
    constructor(ConstructorCalldata memory params) VRFConsumerBaseV2(params.vrfCoordinator) {
        _grantRole(DEFAULT_ADMIN_ROLE, params.owner);
        _grantRole(OPERATOR_ROLE, params.operator);
        _updateRoundDuration(params.roundDuration);
        _updateProtocolFeeRecipient(params.protocolFeeRecipient);
        _updateProtocolFeeBp(params.protocolFeeBp);
        _updateDiscountedProtocolFeeBp(params.discountedProtocolFeeBp);
        _updateValuePerEntry(params.valuePerEntry);
        _updateERC20Oracle(params.erc20Oracle);
        _updateMaximumNumberOfParticipantsPerRound(params.maximumNumberOfParticipantsPerRound);
        _updateReservoirOracle(params.reservoirOracle);
        _updateSignatureValidityPeriod(params.signatureValidityPeriod);

        WETH = params.weth;
        KEY_HASH = params.keyHash;
        VRF_COORDINATOR = VRFCoordinatorV2Interface(params.vrfCoordinator);
        SUBSCRIPTION_ID = params.subscriptionId;
        MINIMUM_REQUEST_CONFIRMATIONS = params.minimumRequestConfirmations;

        transferManager = ITransferManager(params.transferManager);

        _startRound({_roundsCount: 0});
    }

    /**
     * @param looks The LOOKS token address.
     */
    function setLOOKS(address looks) external {
        _validateIsOwner();
        if (LOOKS != address(0)) {
            _revertWith(LooksAlreadySet_error_selector);
        }
        LOOKS = looks;
    }

    /**
     * @inheritdoc IYoloV2
     */
    function deposit(uint256 roundId, DepositCalldata[] calldata deposits) external payable nonReentrant whenNotPaused {
        _deposit(roundId, deposits);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function depositETHIntoMultipleRounds(
        uint256 startingRoundId,
        uint256[] calldata amounts
    ) external payable nonReentrant whenNotPaused {
        uint256 numberOfRounds = amounts.length;
        if (numberOfRounds == 0) {
            _revertWith(ZeroDeposits_error_selector);
        }

        Round storage startingRound = rounds[startingRoundId];
        _validateRoundIsOpen(startingRound);

        _setCutoffTimeIfNotSet(startingRound);

        uint256 expectedValue;
        uint256[] memory entriesCounts = new uint256[](numberOfRounds);

        for (uint256 i; i < numberOfRounds; ++i) {
            uint256 roundId = _unsafeAdd(startingRoundId, i);
            Round storage round = rounds[roundId];
            uint256 roundValuePerEntry = round.valuePerEntry;
            if (roundValuePerEntry == 0) {
                roundValuePerEntry = _writeDataToRound({roundId: roundId, roundValue: 0});
            }

            _incrementUserDepositCount(roundId, round);

            uint256 depositAmount = amounts[i];
            if (depositAmount % roundValuePerEntry != 0) {
                _revertWithInvalidValue();
            }
            uint256 entriesCount = _depositETH(round, roundId, roundValuePerEntry, depositAmount);
            expectedValue += depositAmount;

            entriesCounts[i] = entriesCount;
        }

        if (expectedValue != msg.value) {
            _revertWithInvalidValue();
        }

        emit MultipleRoundsDeposited(msg.sender, startingRoundId, amounts, entriesCounts);

        if (
            _shouldDrawWinner(
                startingRound.numberOfParticipants,
                startingRound.maximumNumberOfParticipants,
                startingRound.deposits.length
            )
        ) {
            _drawWinner(startingRound, startingRoundId);
        }
    }

    /**
     * @inheritdoc IYoloV2
     */
    function getRound(
        uint256 roundId
    )
        external
        view
        returns (
            RoundStatus status,
            uint40 maximumNumberOfParticipants,
            uint16 roundProtocolFeeBp,
            uint40 cutoffTime,
            uint40 drawnAt,
            uint40 numberOfParticipants,
            address winner,
            uint96 roundValuePerEntry,
            uint256 protocolFeeOwed,
            Deposit[] memory deposits
        )
    {
        status = rounds[roundId].status;
        maximumNumberOfParticipants = rounds[roundId].maximumNumberOfParticipants;
        roundProtocolFeeBp = rounds[roundId].protocolFeeBp;
        cutoffTime = rounds[roundId].cutoffTime;
        drawnAt = rounds[roundId].drawnAt;
        numberOfParticipants = rounds[roundId].numberOfParticipants;
        winner = rounds[roundId].winner;
        roundValuePerEntry = rounds[roundId].valuePerEntry;
        protocolFeeOwed = rounds[roundId].protocolFeeOwed;
        deposits = rounds[roundId].deposits;
    }

    /**
     * @inheritdoc IYoloV2
     */
    function drawWinner() external nonReentrant whenNotPaused {
        uint256 roundId = roundsCount;
        Round storage round = rounds[roundId];

        _validateRoundStatus(round, RoundStatus.Open);

        uint256 numberOfParticipants = round.numberOfParticipants;

        if (!_shouldDrawWinner(numberOfParticipants, round.maximumNumberOfParticipants, round.deposits.length)) {
            if (block.timestamp < round.cutoffTime) {
                _revertWith(CutoffTimeNotReached_error_selector);
            }

            if (numberOfParticipants < 2) {
                _revertWith(InsufficientParticipants_error_selector);
            }
        }

        _drawWinner(round, roundId);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function cancel() external nonReentrant {
        _validateOutflowIsAllowed();
        _cancel({roundId: roundsCount});
    }

    /**
     * @inheritdoc IYoloV2
     */
    function cancel(uint256 numberOfRounds) external {
        _validateIsOwner();

        if (numberOfRounds == 0) {
            _revertWith(ZeroRounds_error_selector);
        }

        _cancelMultipleRounds(numberOfRounds);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function cancelAfterRandomnessRequest() external nonReentrant {
        _validateOutflowIsAllowed();

        uint256 roundId = roundsCount;
        Round storage round = rounds[roundId];

        _validateRoundStatus(round, RoundStatus.Drawing);

        if (block.timestamp < round.drawnAt + 25 hours) {
            _revertWith(DrawExpirationTimeNotReached_error_selector);
        }

        _setRoundStatus(round, roundId, RoundStatus.Cancelled);

        _startRound({_roundsCount: roundId});
    }

    /**
     * @inheritdoc IYoloV2
     */
    function claimPrizes(
        WithdrawalCalldata[] calldata withdrawalCalldata,
        bool payWithLOOKS
    ) external payable nonReentrant {
        _validateOutflowIsAllowed();

        TransferAccumulator memory transferAccumulator;
        uint256 ethAmount;
        uint256 protocolFeeOwed;

        _validateArrayLengthIsNotEmpty(withdrawalCalldata.length);

        if (payWithLOOKS) {
            if (msg.value != 0) {
                _revertWithInvalidValue();
            }
        }

        for (uint256 i; i < withdrawalCalldata.length; ++i) {
            WithdrawalCalldata calldata perRoundWithdrawalCalldata = withdrawalCalldata[i];

            Round storage round = rounds[perRoundWithdrawalCalldata.roundId];

            _validateRoundStatus(round, RoundStatus.Drawn);
            _validateMsgSenderIsWinner(round);

            uint256[] calldata depositIndices = perRoundWithdrawalCalldata.depositIndices;
            _validateArrayLengthIsNotEmpty(depositIndices.length);

            for (uint256 j; j < depositIndices.length; ++j) {
                uint256 index = depositIndices[j];
                _validateDepositsArrayIndex(index, round.deposits.length);
                ethAmount = _transferTokenOut(round.deposits[index], transferAccumulator, ethAmount);
            }

            protocolFeeOwed += round.protocolFeeOwed;
            round.protocolFeeOwed = 0;
        }

        if (protocolFeeOwed != 0) {
            if (payWithLOOKS) {
                _payForProtocolFeesInLOOKS(protocolFeeOwed);
            } else {
                _payForProtocolFeesInETH(protocolFeeOwed);

                protocolFeeOwed -= msg.value;
                if (protocolFeeOwed <= ethAmount) {
                    unchecked {
                        ethAmount -= protocolFeeOwed;
                    }
                } else {
                    _revertWith(ProtocolFeeNotPaid_error_selector);
                }
            }
        }

        if (transferAccumulator.amount != 0) {
            _executeERC20DirectTransfer(transferAccumulator.tokenAddress, msg.sender, transferAccumulator.amount);
        }

        if (ethAmount != 0) {
            _transferETHAndWrapIfFailWithGasLimit(WETH, msg.sender, ethAmount, gasleft());
        }

        emit PrizesClaimed(msg.sender, withdrawalCalldata);
    }

    /**
     * @inheritdoc IYoloV2
     * @dev This function does not validate withdrawalCalldata to not contain duplicate round IDs and prize indices.
     *      It is the responsibility of the caller to ensure that. Otherwise, the returned protocol fee owed will be incorrect.
     */
    function getClaimPrizesPaymentRequired(
        WithdrawalCalldata[] calldata withdrawalCalldata,
        bool payWithLOOKS
    ) external view returns (uint256 protocolFeeOwed) {
        uint256 ethAmount;

        for (uint256 i; i < withdrawalCalldata.length; ++i) {
            WithdrawalCalldata calldata perRoundWithdrawalCalldata = withdrawalCalldata[i];
            Round storage round = rounds[perRoundWithdrawalCalldata.roundId];

            _validateRoundStatus(round, RoundStatus.Drawn);

            uint256[] calldata depositIndices = perRoundWithdrawalCalldata.depositIndices;
            uint256 numberOfPrizes = depositIndices.length;
            uint256 prizesCount = round.deposits.length;

            for (uint256 j; j < numberOfPrizes; ++j) {
                uint256 index = depositIndices[j];
                if (index >= prizesCount) {
                    _revertWith(InvalidIndex_error_selector);
                }

                Deposit storage prize = round.deposits[index];
                if (prize.tokenType == YoloV2__TokenType.ETH) {
                    ethAmount += prize.tokenAmount;
                }
            }

            protocolFeeOwed += round.protocolFeeOwed;
        }

        if (payWithLOOKS) {
            protocolFeeOwed = _protocolFeeOwedInLOOKS(protocolFeeOwed);
        } else {
            if (protocolFeeOwed < ethAmount) {
                protocolFeeOwed = 0;
            } else {
                unchecked {
                    protocolFeeOwed -= ethAmount;
                }
            }
        }
    }

    /**
     * @inheritdoc IYoloV2
     */
    function estimatedERC20DepositEntriesCount(
        uint256 roundId,
        DepositCalldata calldata singleDeposit
    ) external view returns (uint256 entriesCount) {
        address tokenAddress = singleDeposit.tokenAddress;
        uint256 price = prices[tokenAddress][roundId];
        if (price == 0) {
            price = _getTWAP(tokenAddress);
        }

        entriesCount =
            ((price * singleDeposit.tokenIdsOrAmounts[0]) / (10 ** IERC20(tokenAddress).decimals())) /
            rounds[roundId].valuePerEntry;
    }

    /**
     * @inheritdoc IYoloV2
     */
    function withdrawDeposits(WithdrawalCalldata[] calldata withdrawalCalldata) external nonReentrant {
        _validateOutflowIsAllowed();

        TransferAccumulator memory transferAccumulator;
        uint256 ethAmount;

        _validateArrayLengthIsNotEmpty(withdrawalCalldata.length);

        for (uint256 i; i < withdrawalCalldata.length; ++i) {
            WithdrawalCalldata calldata perRoundWithdrawalCalldata = withdrawalCalldata[i];

            Round storage round = rounds[perRoundWithdrawalCalldata.roundId];

            _validateRoundStatus(round, RoundStatus.Cancelled);

            uint256[] calldata depositIndices = perRoundWithdrawalCalldata.depositIndices;
            uint256 depositIndicesLength = depositIndices.length;
            _validateArrayLengthIsNotEmpty(depositIndicesLength);

            for (uint256 j; j < depositIndicesLength; ++j) {
                uint256 index = depositIndices[j];
                _validateDepositsArrayIndex(index, round.deposits.length);

                Deposit storage singleDeposit = round.deposits[index];

                _validateMsgSenderIsDepositor(singleDeposit);

                ethAmount = _transferTokenOut(singleDeposit, transferAccumulator, ethAmount);
            }
        }

        if (transferAccumulator.amount != 0) {
            _executeERC20DirectTransfer(transferAccumulator.tokenAddress, msg.sender, transferAccumulator.amount);
        }

        if (ethAmount != 0) {
            _transferETHAndWrapIfFailWithGasLimit(WETH, msg.sender, ethAmount, gasleft());
        }

        emit DepositsWithdrawn(msg.sender, withdrawalCalldata);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function rolloverETH(
        uint256 roundId,
        WithdrawalCalldata[] calldata withdrawalCalldata,
        bool payWithLOOKS
    ) external nonReentrant whenNotPaused {
        uint256 rolloverAmount;
        uint256 protocolFeeOwed;

        uint256 withdrawalCalldataLength = withdrawalCalldata.length;
        _validateArrayLengthIsNotEmpty(withdrawalCalldataLength);

        for (uint256 i; i < withdrawalCalldataLength; ++i) {
            WithdrawalCalldata calldata perRoundWithdrawalCalldata = withdrawalCalldata[i];

            Round storage cancelledOrDrawnRound = rounds[perRoundWithdrawalCalldata.roundId];

            RoundStatus status = cancelledOrDrawnRound.status;
            if (status < RoundStatus.Drawn) {
                _revertWithInvalidStatus();
            }

            if (status == RoundStatus.Drawn) {
                _validateMsgSenderIsWinner(cancelledOrDrawnRound);
                protocolFeeOwed += cancelledOrDrawnRound.protocolFeeOwed;
                cancelledOrDrawnRound.protocolFeeOwed = 0;
            }

            uint256[] calldata depositIndices = perRoundWithdrawalCalldata.depositIndices;
            uint256 depositIndicesLength = depositIndices.length;
            _validateArrayLengthIsNotEmpty(depositIndicesLength);

            for (uint256 j; j < depositIndicesLength; ++j) {
                uint256 index = depositIndices[j];
                _validateDepositsArrayIndex(index, cancelledOrDrawnRound.deposits.length);

                Deposit storage singleDeposit = cancelledOrDrawnRound.deposits[index];

                _validateDepositNotWithdrawn(singleDeposit);

                if (singleDeposit.tokenType != YoloV2__TokenType.ETH) {
                    _revertWith(InvalidTokenType_error_selector);
                }

                if (status == RoundStatus.Cancelled) {
                    _validateMsgSenderIsDepositor(singleDeposit);
                }

                singleDeposit.withdrawn = true;

                rolloverAmount += singleDeposit.tokenAmount;
            }
        }

        if (protocolFeeOwed != 0) {
            if (payWithLOOKS) {
                _payForProtocolFeesInLOOKS(protocolFeeOwed);
            } else {
                if (rolloverAmount < protocolFeeOwed) {
                    _revertWith(ProtocolFeeNotPaid_error_selector);
                } else {
                    unchecked {
                        rolloverAmount -= protocolFeeOwed;
                    }
                }

                _payForProtocolFeesInETH(protocolFeeOwed);
            }
        }

        Round storage round = rounds[roundId];
        _validateRoundIsOpen(round);

        _incrementUserDepositCount(roundId, round);
        _setCutoffTimeIfNotSet(round);

        uint256 roundValuePerEntry = round.valuePerEntry;
        uint256 dust = rolloverAmount % roundValuePerEntry;
        if (dust != 0) {
            _validateOutflowIsAllowed();
            unchecked {
                rolloverAmount -= dust;
            }
            _transferETHAndWrapIfFailWithGasLimit(WETH, msg.sender, dust, gasleft());
        }

        if (rolloverAmount < roundValuePerEntry) {
            _revertWithInvalidValue();
        }

        uint256 entriesCount = _depositETH(round, roundId, roundValuePerEntry, rolloverAmount);

        if (_shouldDrawWinner(round.numberOfParticipants, round.maximumNumberOfParticipants, round.deposits.length)) {
            _drawWinner(round, roundId);
        }

        emit Rollover(msg.sender, withdrawalCalldata, roundId, entriesCount);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function togglePaused() external {
        _validateIsOwner();
        if (paused()) {
            _unpause();
            _cancelMultipleRounds({numberOfRounds: 1});
        } else {
            _pause();
        }
    }

    /**
     * @inheritdoc IYoloV2
     */
    function toggleOutflowAllowed() external {
        _validateIsOwner();
        bool _outflowAllowed = outflowAllowed;
        outflowAllowed = !_outflowAllowed;
        emit OutflowAllowedUpdated(!_outflowAllowed);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function updateTokensStatus(address[] calldata tokens, YoloV2__TokenType tokenType, bool isAllowed) external {
        _validateIsOperator();

        if (tokenType == YoloV2__TokenType.ETH) {
            _revertWithInvalidToken();
        }

        uint256 count = tokens.length;
        for (uint256 i; i < count; ++i) {
            isTokenAllowed[keccak256(abi.encodePacked(tokens[i], tokenType))] = (isAllowed ? 1 : 0);
        }
        emit TokensStatusUpdated(tokens, tokenType, isAllowed);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function updateRoundDuration(uint40 _roundDuration) external {
        _validateIsOwner();
        _updateRoundDuration(_roundDuration);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function updateSignatureValidityPeriod(uint40 _signatureValidityPeriod) external {
        _validateIsOwner();
        _updateSignatureValidityPeriod(_signatureValidityPeriod);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function updateValuePerEntry(uint96 _valuePerEntry) external {
        _validateIsOwner();
        _updateValuePerEntry(_valuePerEntry);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function updateProtocolFeeRecipient(address _protocolFeeRecipient) external {
        _validateIsOwner();
        _updateProtocolFeeRecipient(_protocolFeeRecipient);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function updateProtocolFeeBp(uint16 _protocolFeeBp) external {
        _validateIsOwner();
        _updateProtocolFeeBp(_protocolFeeBp);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function updateDiscountedProtocolFeeBp(uint16 _discountedProtocolFeeBp) external {
        _validateIsOwner();
        _updateDiscountedProtocolFeeBp(_discountedProtocolFeeBp);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function updateMaximumNumberOfParticipantsPerRound(uint40 _maximumNumberOfParticipantsPerRound) external {
        _validateIsOwner();
        _updateMaximumNumberOfParticipantsPerRound(_maximumNumberOfParticipantsPerRound);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function updateReservoirOracle(address _reservoirOracle) external {
        _validateIsOwner();
        _updateReservoirOracle(_reservoirOracle);
    }

    /**
     * @inheritdoc IYoloV2
     */
    function updateERC20Oracle(address _erc20Oracle) external {
        _validateIsOwner();
        _updateERC20Oracle(_erc20Oracle);
    }

    /**
     * @param round The round to update.
     * @param roundId The round's ID.
     * @param status The round's status.
     */
    function _setRoundStatus(Round storage round, uint256 roundId, RoundStatus status) private {
        round.status = status;
        emit RoundStatusUpdated(roundId, status);
    }

    /**
     * @param _roundDuration The duration of each round.
     */
    function _updateRoundDuration(uint40 _roundDuration) private {
        if (_roundDuration > 1 hours) {
            _revertWithInvalidValue();
        }

        roundDuration = _roundDuration;
        emit RoundDurationUpdated(_roundDuration);
    }

    /**
     * @param _signatureValidityPeriod The validity period of a Reservoir signature.
     */
    function _updateSignatureValidityPeriod(uint40 _signatureValidityPeriod) private {
        signatureValidityPeriod = _signatureValidityPeriod;
        emit SignatureValidityPeriodUpdated(_signatureValidityPeriod);
    }

    /**
     * @param _valuePerEntry The value of each entry in ETH.
     */
    function _updateValuePerEntry(uint96 _valuePerEntry) private {
        if (_valuePerEntry == 0) {
            _revertWithInvalidValue();
        }
        valuePerEntry = _valuePerEntry;
        emit ValuePerEntryUpdated(_valuePerEntry);
    }

    /**
     * @param _protocolFeeRecipient The new protocol fee recipient address
     */
    function _updateProtocolFeeRecipient(address _protocolFeeRecipient) private {
        if (_protocolFeeRecipient == address(0)) {
            _revertWithInvalidValue();
        }
        protocolFeeRecipient = _protocolFeeRecipient;
        emit ProtocolFeeRecipientUpdated(_protocolFeeRecipient);
    }

    /**
     * @param _protocolFeeBp The new protocol fee in basis points
     */
    function _updateProtocolFeeBp(uint16 _protocolFeeBp) private {
        if (_protocolFeeBp > MAXIMUM_PROTOCOL_FEE_BP) {
            _revertWithInvalidValue();
        }
        protocolFeeBp = _protocolFeeBp;
        emit ProtocolFeeBpUpdated(_protocolFeeBp);
    }

    /**
     * @param _discountedProtocolFeeBp The new discounted protocol fee in basis points
     */
    function _updateDiscountedProtocolFeeBp(uint16 _discountedProtocolFeeBp) private {
        if (_discountedProtocolFeeBp > 10_000) {
            _revertWithInvalidValue();
        }
        discountedProtocolFeeBp = _discountedProtocolFeeBp;
        emit DiscountedProtocolFeeBpUpdated(_discountedProtocolFeeBp);
    }

    /**
     * @param _maximumNumberOfParticipantsPerRound The new maximum number of participants per round
     */
    function _updateMaximumNumberOfParticipantsPerRound(uint40 _maximumNumberOfParticipantsPerRound) private {
        if (_maximumNumberOfParticipantsPerRound < 2) {
            _revertWithInvalidValue();
        }
        maximumNumberOfParticipantsPerRound = _maximumNumberOfParticipantsPerRound;
        emit MaximumNumberOfParticipantsPerRoundUpdated(_maximumNumberOfParticipantsPerRound);
    }

    /**
     * @param _reservoirOracle The new Reservoir oracle address
     */
    function _updateReservoirOracle(address _reservoirOracle) private {
        if (_reservoirOracle == address(0)) {
            _revertWithInvalidValue();
        }
        reservoirOracle = _reservoirOracle;
        emit ReservoirOracleUpdated(_reservoirOracle);
    }

    /**
     * @param _erc20Oracle The new ERC-20 oracle address
     */
    function _updateERC20Oracle(address _erc20Oracle) private {
        if (_erc20Oracle == address(0)) {
            _revertWithInvalidValue();
        }
        erc20Oracle = IPriceOracle(_erc20Oracle);
        emit ERC20OracleUpdated(_erc20Oracle);
    }

    /**
     * @param _roundsCount The current rounds count
     * @return roundId The started round ID
     */
    function _startRound(uint256 _roundsCount) private returns (uint256 roundId) {
        unchecked {
            roundId = _roundsCount + 1;
        }
        roundsCount = uint40(roundId);

        Round storage round = rounds[roundId];

        if (round.valuePerEntry == 0) {
            // On top of the 4 values covered by _writeDataToRound, this also writes the round's status to Open (1).
            _writeDataToRound({roundId: roundId, roundValue: 1});
        } else {
            uint256 numberOfParticipants = round.numberOfParticipants;
            uint40 _roundDuration = roundDuration;
            // This is equivalent to
            // round.status = RoundStatus.Open;
            // if (round.numberOfParticipants > 0) {
            //   round.cutoffTime = uint40(block.timestamp) + _roundDuration;
            // }
            uint256 roundSlot = _getRoundSlot(roundId);
            assembly {
                // RoundStatus.Open is equal to 1.
                let roundValue := or(sload(roundSlot), 1)

                if gt(numberOfParticipants, 0) {
                    roundValue := or(roundValue, shl(ROUND__CUTOFF_TIME_OFFSET, add(timestamp(), _roundDuration)))
                }

                sstore(roundSlot, roundValue)
            }
        }

        emit RoundStatusUpdated(roundId, RoundStatus.Open);
    }

    /**
     * @param round The open round.
     * @param roundId The open round ID.
     */
    function _drawWinner(Round storage round, uint256 roundId) private {
        _setRoundStatus(round, roundId, RoundStatus.Drawing);
        round.drawnAt = uint40(block.timestamp);

        uint256 requestId = VRF_COORDINATOR.requestRandomWords({
            keyHash: KEY_HASH,
            subId: SUBSCRIPTION_ID,
            minimumRequestConfirmations: MINIMUM_REQUEST_CONFIRMATIONS,
            callbackGasLimit: uint32(500_000),
            numWords: uint32(1)
        });

        if (randomnessRequests[requestId].exists) {
            _revertWith(RandomnessRequestAlreadyExists_error_selector);
        }

        // This is equivalent to
        // randomnessRequests[requestId].exists = true;
        // randomnessRequests[requestId].roundId = uint40(roundId);
        assembly {
            mstore(0x00, requestId)
            mstore(0x20, randomnessRequests.slot)
            let randomnessRequestSlot := keccak256(0x00, 0x40)

            // 1 is true
            sstore(randomnessRequestSlot, or(1, shl(RANDOMNESS_REQUEST__ROUND_ID_OFFSET, roundId)))
        }

        emit RandomnessRequested(roundId, requestId);
    }

    /**
     * @param roundId The open round ID.
     * @param deposits The ERC-20/ERC-721 deposits to be made.
     */
    function _deposit(uint256 roundId, DepositCalldata[] calldata deposits) private {
        Round storage round = rounds[roundId];
        _validateRoundIsOpen(round);

        _incrementUserDepositCount(roundId, round);
        _setCutoffTimeIfNotSet(round);

        uint256 roundDepositCount = round.deposits.length;
        uint40 currentEntryIndex;
        uint256 totalEntriesCount;

        uint256 roundDepositsLengthSlot = _getRoundSlot(roundId) + ROUND__DEPOSITS_LENGTH_SLOT_OFFSET;

        if (msg.value == 0) {
            if (deposits.length == 0) {
                _revertWith(ZeroDeposits_error_selector);
            }
        } else {
            uint256 roundValuePerEntry = round.valuePerEntry;
            if (msg.value % roundValuePerEntry != 0) {
                _revertWithInvalidValue();
            }
            uint256 entriesCount = msg.value / roundValuePerEntry;
            totalEntriesCount += entriesCount;

            currentEntryIndex = _getCurrentEntryIndexWithoutAccrual(round, roundDepositCount, entriesCount);

            // This is equivalent to
            // round.deposits.push(
            //     Deposit({
            //         tokenType: YoloV2__TokenType.ETH,
            //         tokenAddress: address(0),
            //         tokenId: 0,
            //         tokenAmount: msg.value,
            //         depositor: msg.sender,
            //         withdrawn: false,
            //         currentEntryIndex: currentEntryIndex
            //     })
            // );
            uint256 depositDataSlotWithCountOffset = _getDepositDataSlotWithCountOffset(
                roundDepositsLengthSlot,
                roundDepositCount
            );
            // We don't have to write tokenType, tokenAddress, tokenId, and withdrawn because they are 0.
            _writeDepositorAndCurrentEntryIndexToDeposit(depositDataSlotWithCountOffset, currentEntryIndex);
            _writeDepositAmountToDeposit(depositDataSlotWithCountOffset, msg.value);
            unchecked {
                ++roundDepositCount;
            }
        }

        if (deposits.length != 0) {
            ITransferManager.BatchTransferItem[] memory batchTransferItems = new ITransferManager.BatchTransferItem[](
                deposits.length
            );

            for (uint256 i; i < deposits.length; ++i) {
                DepositCalldata calldata singleDeposit = deposits[i];
                address tokenAddress = singleDeposit.tokenAddress;
                if (isTokenAllowed[keccak256(abi.encodePacked(tokenAddress, singleDeposit.tokenType))] != 1) {
                    _revertWithInvalidToken();
                }
                uint256 price = prices[tokenAddress][roundId];
                if (singleDeposit.tokenType == YoloV2__TokenType.ERC721) {
                    if (price == 0) {
                        price = _getReservoirPrice(singleDeposit);
                        prices[tokenAddress][roundId] = price;
                    }

                    uint256 entriesCount = price / round.valuePerEntry;
                    _validateNonZeroEntries(entriesCount);

                    uint256[] memory amounts = new uint256[](singleDeposit.tokenIdsOrAmounts.length);
                    for (uint256 j; j < singleDeposit.tokenIdsOrAmounts.length; ++j) {
                        totalEntriesCount += entriesCount;

                        currentEntryIndex = _incrementCurrentEntryIndex(
                            currentEntryIndex,
                            entriesCount,
                            round,
                            roundDepositCount
                        );

                        uint256 tokenId = singleDeposit.tokenIdsOrAmounts[j];

                        // tokenAmount is in reality 1, but we never use it and it is cheaper to set it as 0.
                        // This is equivalent to
                        // round.deposits.push(
                        //     Deposit({
                        //         tokenType: YoloV2__TokenType.ERC721,
                        //         tokenAddress: tokenAddress,
                        //         tokenId: tokenId,
                        //         tokenAmount: 0,
                        //         depositor: msg.sender,
                        //         withdrawn: false,
                        //         currentEntryIndex: currentEntryIndex
                        //     })
                        // );
                        // unchecked {
                        //     roundDepositCount += 1;
                        // }
                        uint256 depositDataSlotWithCountOffset = _getDepositDataSlotWithCountOffset(
                            roundDepositsLengthSlot,
                            roundDepositCount
                        );
                        _writeDepositorAndCurrentEntryIndexToDeposit(depositDataSlotWithCountOffset, currentEntryIndex);
                        _writeTokenAddressToDeposit(
                            depositDataSlotWithCountOffset,
                            YoloV2__TokenType.ERC721,
                            tokenAddress
                        );
                        assembly {
                            sstore(add(depositDataSlotWithCountOffset, DEPOSIT__TOKEN_ID_SLOT_OFFSET), tokenId)
                            roundDepositCount := add(roundDepositCount, 1)
                        }

                        amounts[j] = 1;
                    }

                    batchTransferItems[i].tokenAddress = tokenAddress;
                    batchTransferItems[i].tokenType = TransferManager__TokenType.ERC721;
                    batchTransferItems[i].itemIds = singleDeposit.tokenIdsOrAmounts;
                    batchTransferItems[i].amounts = amounts;
                } else if (singleDeposit.tokenType == YoloV2__TokenType.ERC20) {
                    if (price == 0) {
                        price = _getTWAP(tokenAddress);
                        prices[tokenAddress][roundId] = price;
                    }

                    uint256[] memory amounts = singleDeposit.tokenIdsOrAmounts;
                    if (amounts.length != 1) {
                        _revertWith(InvalidLength_error_selector);
                    }

                    uint256 amount = amounts[0];

                    uint256 entriesCount = ((price * amount) / (10 ** IERC20(tokenAddress).decimals())) /
                        round.valuePerEntry;
                    _validateNonZeroEntries(entriesCount);

                    if (entriesCount < singleDeposit.minimumEntries) {
                        _revertWith(TooFewEntries_error_selector);
                    }

                    batchTransferItems[i].tokenAddress = tokenAddress;
                    batchTransferItems[i].tokenType = TransferManager__TokenType.ERC20;
                    batchTransferItems[i].amounts = singleDeposit.tokenIdsOrAmounts;

                    totalEntriesCount += entriesCount;

                    currentEntryIndex = _incrementCurrentEntryIndex(
                        currentEntryIndex,
                        entriesCount,
                        round,
                        roundDepositCount
                    );

                    // round.deposits.push(
                    //     Deposit({
                    //         tokenType: YoloV2__TokenType.ERC20,
                    //         tokenAddress: tokenAddress,
                    //         tokenId: 0,
                    //         tokenAmount: amount,
                    //         depositor: msg.sender,
                    //         withdrawn: false,
                    //         currentEntryIndex: currentEntryIndex
                    //     })
                    // );
                    uint256 depositDataSlotWithCountOffset = _getDepositDataSlotWithCountOffset(
                        roundDepositsLengthSlot,
                        roundDepositCount
                    );
                    _writeDepositorAndCurrentEntryIndexToDeposit(depositDataSlotWithCountOffset, currentEntryIndex);
                    _writeDepositAmountToDeposit(depositDataSlotWithCountOffset, amount);
                    _writeTokenAddressToDeposit(depositDataSlotWithCountOffset, YoloV2__TokenType.ERC20, tokenAddress);
                    unchecked {
                        ++roundDepositCount;
                    }
                }
            }

            transferManager.transferBatchItemsAcrossCollections(batchTransferItems, msg.sender, address(this));
        }

        assembly {
            sstore(roundDepositsLengthSlot, roundDepositCount)
        }

        {
            uint256 numberOfParticipants = round.numberOfParticipants;

            _validateRoundDepositsAndPlayers(roundDepositCount, numberOfParticipants);

            if (_shouldDrawWinner(numberOfParticipants, round.maximumNumberOfParticipants, roundDepositCount)) {
                _drawWinner(round, roundId);
            }
        }

        emit Deposited(msg.sender, roundId, totalEntriesCount);
    }

    /**
     * @param roundId The ID of the round to be cancelled.
     */
    function _cancel(uint256 roundId) private {
        Round storage round = rounds[roundId];

        _validateRoundStatus(round, RoundStatus.Open);

        uint256 cutoffTime = round.cutoffTime;
        if (cutoffTime == 0 || block.timestamp < cutoffTime) {
            _revertWith(CutoffTimeNotReached_error_selector);
        }

        if (round.numberOfParticipants > 1) {
            _revertWith(RoundCannotBeClosed_error_selector);
        }

        _setRoundStatus(round, roundId, RoundStatus.Cancelled);

        _startRound({_roundsCount: roundId});
    }

    /**
     * @param numberOfRounds Number of rounds to cancel.
     */
    function _cancelMultipleRounds(uint256 numberOfRounds) private {
        uint256 startingRoundId = roundsCount;

        for (uint256 i; i < numberOfRounds; ++i) {
            rounds[_unsafeAdd(startingRoundId, i)].status = RoundStatus.Cancelled;
        }

        emit RoundsCancelled(startingRoundId, numberOfRounds);

        _startRound({_roundsCount: _unsafeSubtract(_unsafeAdd(startingRoundId, numberOfRounds), 1)});
    }

    /**
     * @param requestId The ID of the request
     * @param randomWords The random words returned by Chainlink
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        if (randomnessRequests[requestId].exists) {
            uint256 roundId = randomnessRequests[requestId].roundId;
            Round storage round = rounds[roundId];

            if (round.status == RoundStatus.Drawing) {
                _setRoundStatus(round, roundId, RoundStatus.Drawn);

                uint256 randomWord = randomWords[0];
                randomnessRequests[requestId].randomWord = randomWord;

                uint256 count = round.deposits.length;
                uint256[] memory currentEntryIndexArray = new uint256[](count);
                for (uint256 i; i < count; ++i) {
                    currentEntryIndexArray[i] = uint256(round.deposits[i].currentEntryIndex);
                }

                uint256 currentEntryIndex = currentEntryIndexArray[_unsafeSubtract(count, 1)];
                uint256 winningEntry = _unsafeAdd(randomWord % currentEntryIndex, 1);
                round.winner = round.deposits[currentEntryIndexArray.findUpperBound(winningEntry)].depositor;
                round.protocolFeeOwed = (round.valuePerEntry * currentEntryIndex * round.protocolFeeBp) / 10_000;

                _startRound({_roundsCount: roundId});
            }
        }
    }

    /**
     * @param roundId The round ID.
     * @param round The round.
     */
    function _incrementUserDepositCount(uint256 roundId, Round storage round) private {
        uint256 userDepositCount = depositCount[roundId][msg.sender];
        if (userDepositCount == 0) {
            uint256 numberOfParticipants = round.numberOfParticipants;
            if (numberOfParticipants == round.maximumNumberOfParticipants) {
                _revertWith(MaximumNumberOfParticipantsReached_error_selector);
            }
            unchecked {
                round.numberOfParticipants = uint40(numberOfParticipants + 1);
            }
        }
        unchecked {
            depositCount[roundId][msg.sender] = userDepositCount + 1;
        }
    }

    /**
     * @param round The round to check.
     */
    function _setCutoffTimeIfNotSet(Round storage round) private {
        if (round.cutoffTime == 0) {
            round.cutoffTime = uint40(block.timestamp + roundDuration);
        }
    }

    /**
     * @dev This function is used to write the following values to the round:
     *      - maximumNumberOfParticipants
     *      - valuePerEntry
     *      - protocolFeeBp
     *
     *      roundValue can be provided to write other to other fields in the round.
     * @param roundId The round ID.
     * @param roundValue The starting round slot value to write to the round.
     * @return _valuePerEntry The round's value per entry in ETH.
     */
    function _writeDataToRound(uint256 roundId, uint256 roundValue) private returns (uint256 _valuePerEntry) {
        // This is equivalent to
        // round.maximumNumberOfParticipants = maximumNumberOfParticipantsPerRound;
        // round.valuePerEntry = valuePerEntry;
        // round.protocolFeeBp = protocolFeeBp;

        uint256 _maximumNumberOfParticipantsPerRound = maximumNumberOfParticipantsPerRound;
        uint256 _protocolFeeBp = protocolFeeBp;
        _valuePerEntry = valuePerEntry;

        uint256 roundSlot = _getRoundSlot(roundId);
        assembly {
            roundValue := or(
                roundValue,
                shl(ROUND__MAXIMUM_NUMBER_OF_PARTICIPANTS_OFFSET, _maximumNumberOfParticipantsPerRound)
            )
            roundValue := or(roundValue, shl(ROUND__PROTOCOL_FEE_BP_OFFSET, _protocolFeeBp))

            sstore(roundSlot, roundValue)
            sstore(
                add(roundSlot, ROUND__VALUE_PER_ENTRY_SLOT_OFFSET),
                shl(ROUND__VALUE_PER_ENTRY_OFFSET, _valuePerEntry)
            )
        }
    }

    /**
     * @param depositDataSlotWithCountOffset The deposit data slot with count offset.
     * @param currentEntryIndex The current entry index at the current deposit.
     */
    function _writeDepositorAndCurrentEntryIndexToDeposit(
        uint256 depositDataSlotWithCountOffset,
        uint256 currentEntryIndex
    ) private {
        assembly {
            sstore(
                add(depositDataSlotWithCountOffset, DEPOSIT__LAST_SLOT_OFFSET),
                or(caller(), shl(DEPOSIT__CURRENT_ENTRY_INDEX_OFFSET, currentEntryIndex))
            )
        }
    }

    /**
     * @param depositDataSlotWithCountOffset The deposit data slot with count offset.
     * @param depositAmount The token amount to write to the deposit.
     */
    function _writeDepositAmountToDeposit(uint256 depositDataSlotWithCountOffset, uint256 depositAmount) private {
        assembly {
            sstore(add(depositDataSlotWithCountOffset, DEPOSIT__TOKEN_AMOUNT_SLOT_OFFSET), depositAmount)
        }
    }

    /**
     * @param depositDataSlotWithCountOffset The deposit data slot with count offset.
     * @param tokenType The token type to write to the deposit.
     * @param tokenAddress The token address to write to the deposit.
     */
    function _writeTokenAddressToDeposit(
        uint256 depositDataSlotWithCountOffset,
        YoloV2__TokenType tokenType,
        address tokenAddress
    ) private {
        assembly {
            sstore(depositDataSlotWithCountOffset, or(tokenType, shl(DEPOSIT__TOKEN_ADDRESS_OFFSET, tokenAddress)))
        }
    }

    /**
     * @param round The round to deposit ETH into.
     * @param roundId The round ID.
     * @param roundValuePerEntry The value of each entry in ETH.
     * @param depositAmount The amount of ETH to deposit.
     * @return entriesCount The number of entries for the deposit amount.
     */
    function _depositETH(
        Round storage round,
        uint256 roundId,
        uint256 roundValuePerEntry,
        uint256 depositAmount
    ) private returns (uint256 entriesCount) {
        entriesCount = depositAmount / roundValuePerEntry;
        uint256 roundDepositCount = round.deposits.length;
        uint256 roundDepositCountAfterDeposit = _unsafeAdd(roundDepositCount, 1);

        _validateRoundDepositsAndPlayers(roundDepositCountAfterDeposit, round.numberOfParticipants);

        uint40 currentEntryIndex = _getCurrentEntryIndexWithoutAccrual(round, roundDepositCount, entriesCount);
        // This is equivalent to
        // round.deposits.push(
        //     Deposit({
        //         tokenType: YoloV2__TokenType.ETH,
        //         tokenAddress: address(0),
        //         tokenId: 0,
        //         tokenAmount: msg.value,
        //         depositor: msg.sender,
        //         withdrawn: false,
        //         currentEntryIndex: currentEntryIndex
        //     })
        // );
        // unchecked {
        //     roundDepositCount += 1;
        // }
        uint256 roundDepositsLengthSlot = _getRoundSlot(roundId) + ROUND__DEPOSITS_LENGTH_SLOT_OFFSET;
        uint256 depositDataSlotWithCountOffset = _getDepositDataSlotWithCountOffset(
            roundDepositsLengthSlot,
            roundDepositCount
        );
        // We don't have to write tokenType, tokenAddress, tokenId, and withdrawn because they are 0.
        _writeDepositorAndCurrentEntryIndexToDeposit(depositDataSlotWithCountOffset, currentEntryIndex);
        _writeDepositAmountToDeposit(depositDataSlotWithCountOffset, depositAmount);
        assembly {
            sstore(roundDepositsLengthSlot, roundDepositCountAfterDeposit)
        }
    }

    /**
     * @param singleDeposit The deposit to withdraw from.
     * @param transferAccumulator The ERC-20 transfer accumulator so far.
     * @param ethAmount The ETH amount so far.
     * @return The new ETH amount.
     */
    function _transferTokenOut(
        Deposit storage singleDeposit,
        TransferAccumulator memory transferAccumulator,
        uint256 ethAmount
    ) private returns (uint256) {
        _validateDepositNotWithdrawn(singleDeposit);

        singleDeposit.withdrawn = true;

        YoloV2__TokenType tokenType = singleDeposit.tokenType;
        if (tokenType == YoloV2__TokenType.ETH) {
            ethAmount += singleDeposit.tokenAmount;
        } else if (tokenType == YoloV2__TokenType.ERC721) {
            _executeERC721TransferFrom(singleDeposit.tokenAddress, address(this), msg.sender, singleDeposit.tokenId);
        } else if (tokenType == YoloV2__TokenType.ERC20) {
            address tokenAddress = singleDeposit.tokenAddress;
            if (tokenAddress == transferAccumulator.tokenAddress) {
                transferAccumulator.amount += singleDeposit.tokenAmount;
            } else {
                if (transferAccumulator.amount != 0) {
                    _executeERC20DirectTransfer(
                        transferAccumulator.tokenAddress,
                        msg.sender,
                        transferAccumulator.amount
                    );
                }

                transferAccumulator.tokenAddress = tokenAddress;
                transferAccumulator.amount = singleDeposit.tokenAmount;
            }
        }

        return ethAmount;
    }

    /**
     * @param protocolFeeOwed Protocol fee owed in ETH.
     */
    function _payForProtocolFeesInLOOKS(uint256 protocolFeeOwed) private {
        protocolFeeOwed = _protocolFeeOwedInLOOKS(protocolFeeOwed);
        transferManager.transferERC20(LOOKS, msg.sender, protocolFeeRecipient, protocolFeeOwed);
        emit ProtocolFeePayment(protocolFeeOwed, LOOKS);
    }

    /**
     * @param protocolFeeOwed Protocol fee owed in ETH.
     */
    function _payForProtocolFeesInETH(uint256 protocolFeeOwed) private {
        _transferETHAndWrapIfFailWithGasLimit(WETH, protocolFeeRecipient, protocolFeeOwed, gasleft());
        emit ProtocolFeePayment(protocolFeeOwed, address(0));
    }

    function _validateIsOwner() private view {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            _revertWith(NotOwner_error_selector);
        }
    }

    function _validateIsOperator() private view {
        if (!hasRole(OPERATOR_ROLE, msg.sender)) {
            _revertWith(NotOperator_error_selector);
        }
    }

    /**
     * @param round The round to check the status of.
     * @param status The expected status of the round
     */
    function _validateRoundStatus(Round storage round, RoundStatus status) private view {
        if (round.status != status) {
            _revertWithInvalidStatus();
        }
    }

    /**
     * @param round The round to check the status and cutoffTime of.
     */
    function _validateRoundIsOpen(Round storage round) private view {
        if (round.status != RoundStatus.Open || (round.cutoffTime != 0 && block.timestamp >= round.cutoffTime)) {
            _revertWithInvalidStatus();
        }
    }

    /**
     * @param singleDeposit The deposit to withdraw from.
     */
    function _validateDepositNotWithdrawn(Deposit storage singleDeposit) private view {
        if (singleDeposit.withdrawn) {
            _revertWith(AlreadyWithdrawn_error_selector);
        }
    }

    /**
     * @param length The length of the array.
     */
    function _validateArrayLengthIsNotEmpty(uint256 length) private pure {
        if (length == 0) {
            _revertWith(InvalidLength_error_selector);
        }
    }

    function _validateOutflowIsAllowed() private view {
        if (!outflowAllowed) {
            _revertWith(OutflowNotAllowed_error_selector);
        }
    }

    /**
     * @param index The array index.
     * @param roundDepositsLength The round's number of deposits.
     */
    function _validateDepositsArrayIndex(uint256 index, uint256 roundDepositsLength) private pure {
        if (index >= roundDepositsLength) {
            _revertWith(InvalidIndex_error_selector);
        }
    }

    /**
     * @param singleDeposit The deposit to check the depositor of.
     */
    function _validateMsgSenderIsDepositor(Deposit storage singleDeposit) private view {
        if (msg.sender != singleDeposit.depositor) {
            _revertWith(NotDepositor_error_selector);
        }
    }

    /**
     * @param round The round to check the winner of.
     */
    function _validateMsgSenderIsWinner(Round storage round) private view {
        if (msg.sender != round.winner) {
            _revertWith(NotWinner_error_selector);
        }
    }

    /**
     * @param entriesCount The number of entries to be added.
     */
    function _validateNonZeroEntries(uint256 entriesCount) private pure {
        if (entriesCount == 0) {
            _revertWith(ZeroEntries_error_selector);
        }
    }

    /**
     * @param errorSelector The uint256 representation of the error's 4 bytes selector.
     */
    function _revertWith(uint256 errorSelector) private pure {
        assembly {
            mstore(0x00, errorSelector)
            revert(Error_selector_offset, Error_standard_length)
        }
    }

    function _revertWithInvalidStatus() private pure {
        _revertWith(InvalidStatus_error_selector);
    }

    function _revertWithInvalidToken() private pure {
        _revertWith(InvalidToken_error_selector);
    }

    function _revertWithInvalidValue() private pure {
        _revertWith(InvalidValue_error_selector);
    }

    /**
     * @param roundDepositCount The number of deposits in the round.
     * @param numberOfParticipants The number of participants in the round.
     */
    function _validateRoundDepositsAndPlayers(uint256 roundDepositCount, uint256 numberOfParticipants) private pure {
        if (roundDepositCount > MAXIMUM_NUMBER_OF_DEPOSITS_PER_ROUND) {
            _revertWith(MaximumNumberOfDepositsReached_error_selector);
        }

        if (roundDepositCount == MAXIMUM_NUMBER_OF_DEPOSITS_PER_ROUND) {
            if (numberOfParticipants == 1) {
                _revertWith(OnePlayerCannotFillUpTheWholeRound_error_selector);
            }
        }
    }

    /**
     * @param collection The collection address.
     * @param floorPrice The floor price response from Reservoir oracle.
     */
    function _verifyReservoirSignature(address collection, ReservoirOracleFloorPrice calldata floorPrice) private view {
        if (
            floorPrice.timestamp > block.timestamp ||
            block.timestamp > floorPrice.timestamp + uint256(signatureValidityPeriod)
        ) {
            _revertWith(InvalidSignatureTimestamp_error_selector);
        }

        bytes32 expectedMessageId = keccak256(
            abi.encode(RESERVOIR_ORACLE_ID_TYPEHASH, uint8(1), TWAP_DURATION, collection, false)
        );

        if (expectedMessageId != floorPrice.id) {
            _revertWith(MessageIdInvalid_error_selector);
        }

        bytes32 messageHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(
                    abi.encode(
                        RESERVOIR_ORACLE_MESSAGE_TYPEHASH,
                        expectedMessageId,
                        keccak256(floorPrice.payload),
                        floorPrice.timestamp,
                        block.chainid
                    )
                )
            )
        );

        SignatureCheckerMemory.verify(messageHash, reservoirOracle, floorPrice.signature);
    }

    /**
     * @param singleDeposit The ERC-721 deposit to get the price of.
     * @return price The price decoded from the Reservoir oracle payload.
     */
    function _getReservoirPrice(DepositCalldata calldata singleDeposit) private view returns (uint256 price) {
        address token;
        ReservoirOracleFloorPrice calldata reservoirOracleFloorPrice = singleDeposit.reservoirOracleFloorPrice;
        _verifyReservoirSignature(singleDeposit.tokenAddress, reservoirOracleFloorPrice);
        (token, price) = abi.decode(reservoirOracleFloorPrice.payload, (address, uint256));
        if (token != address(0)) {
            _revertWithInvalidToken();
        }
    }

    /**
     * @param currentEntryIndex The round's current entry index.
     * @param entriesCount The number of entries to be added.
     * @param round The open round.
     * @param roundDepositCount The number of deposits in the round.
     * @return The new current entry index.
     */
    function _incrementCurrentEntryIndex(
        uint40 currentEntryIndex,
        uint256 entriesCount,
        Round storage round,
        uint256 roundDepositCount
    ) private view returns (uint40) {
        if (currentEntryIndex != 0) {
            return currentEntryIndex + uint40(entriesCount);
        } else {
            return _getCurrentEntryIndexWithoutAccrual(round, roundDepositCount, entriesCount);
        }
    }

    /**
     * @param round The open round.
     * @param roundDepositCount The number of deposits in the round.
     * @param entriesCount The number of entries to be added.
     * @return currentEntryIndex The current entry index after adding entries count.
     */
    function _getCurrentEntryIndexWithoutAccrual(
        Round storage round,
        uint256 roundDepositCount,
        uint256 entriesCount
    ) private view returns (uint40 currentEntryIndex) {
        _validateNonZeroEntries(entriesCount);

        if (roundDepositCount == 0) {
            currentEntryIndex = uint40(entriesCount);
        } else {
            currentEntryIndex = uint40(
                round.deposits[_unsafeSubtract(roundDepositCount, 1)].currentEntryIndex + entriesCount
            );
        }
    }

    /**
     * @param protocolFeeOwedInETH The protocol fee owed in ETH.
     * @return protocolFeeOwedInLOOKS The protocol fee owed in LOOKS.
     */
    function _protocolFeeOwedInLOOKS(
        uint256 protocolFeeOwedInETH
    ) private view returns (uint256 protocolFeeOwedInLOOKS) {
        protocolFeeOwedInLOOKS = (1e18 * protocolFeeOwedInETH * discountedProtocolFeeBp) / _getTWAP(LOOKS) / 10_000;
    }

    /**
     * @param tokenAddress The token address to get the TWAP price in.
     */
    function _getTWAP(address tokenAddress) private view returns (uint256 price) {
        price = erc20Oracle.getTWAP(tokenAddress, uint32(TWAP_DURATION));
    }

    /**
     * @param roundId The round ID.
     * @return roundSlot The round's starting storage slot.
     */
    function _getRoundSlot(uint256 roundId) private pure returns (uint256 roundSlot) {
        assembly {
            mstore(0x00, roundId)
            mstore(0x20, rounds.slot)
            roundSlot := keccak256(0x00, 0x40)
        }
    }

    /**
     * @param roundDepositsLengthSlot The round's deposits length slot.
     * @param roundDepositCount The number of deposits in the round.
     * @return depositDataSlotWithCountOffset The round's next deposit's starting storage slot.
     */
    function _getDepositDataSlotWithCountOffset(
        uint256 roundDepositsLengthSlot,
        uint256 roundDepositCount
    ) private pure returns (uint256 depositDataSlotWithCountOffset) {
        assembly {
            mstore(0x00, roundDepositsLengthSlot)
            let depositsDataSlot := keccak256(0x00, 0x20)
            depositDataSlotWithCountOffset := add(depositsDataSlot, mul(DEPOSIT__OCCUPIED_SLOTS, roundDepositCount))
        }
    }

    /**
     * @param numberOfParticipants The number of participants in the round.
     * @param maximumNumberOfParticipants The maximum number of participants in the round.
     * @param roundDepositCount The number of deposits in the round.
     */
    function _shouldDrawWinner(
        uint256 numberOfParticipants,
        uint256 maximumNumberOfParticipants,
        uint256 roundDepositCount
    ) private pure returns (bool shouldDraw) {
        shouldDraw =
            numberOfParticipants >= maximumNumberOfParticipants ||
            (numberOfParticipants > 1 && roundDepositCount >= MAXIMUM_NUMBER_OF_DEPOSITS_PER_ROUND);
    }

    /**
     * Unsafe math functions.
     */

    function _unsafeAdd(uint256 a, uint256 b) private pure returns (uint256) {
        unchecked {
            return a + b;
        }
    }

    function _unsafeSubtract(uint256 a, uint256 b) private pure returns (uint256) {
        unchecked {
            return a - b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/*
 * @dev error AlreadyWithdrawn()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant AlreadyWithdrawn_error_selector = 0x6507689f;

/*
 * @dev error CutoffTimeNotReached()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant CutoffTimeNotReached_error_selector = 0xf9ad93f5;

/*
 * @dev error DrawExpirationTimeNotReached()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant DrawExpirationTimeNotReached_error_selector = 0xf4c0ca6e;

/*
 * @dev error InsufficientParticipants()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant InsufficientParticipants_error_selector = 0x7e439aed;

/*
 * @dev error InvalidIndex()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant InvalidIndex_error_selector = 0x63df8171;

/*
 * @dev error InvalidLength()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant InvalidLength_error_selector = 0x947d5a84;

/*
 * @dev error InvalidSignatureTimestamp()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant InvalidSignatureTimestamp_error_selector = 0xc11f5976;

/*
 * @dev error InvalidStatus()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant InvalidStatus_error_selector = 0xf525e320;

/*
 * @dev error InvalidToken()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant InvalidToken_error_selector = 0xc1ab6dc1;

/*
 * @dev error InvalidTokenType()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant InvalidTokenType_error_selector = 0xa1e9dd9d;

/*
 * @dev error InvalidValue()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant InvalidValue_error_selector = 0xaa7feadc;

/*
 * @dev error LooksAlreadySet()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant LooksAlreadySet_error_selector = 0xd6336f0d;

/*
 * @dev error MaximumNumberOfDepositsReached()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant MaximumNumberOfDepositsReached_error_selector = 0x27e6fcc7;

/*
 * @dev error MaximumNumberOfParticipantsReached()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant MaximumNumberOfParticipantsReached_error_selector = 0xb53a57db;

/*
 * @dev error MessageIdInvalid()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant MessageIdInvalid_error_selector = 0x0da5618b;

/*
 * @dev error NotDepositor()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant NotDepositor_error_selector = 0x3cc50b45;

/*
 * @dev error NotOwner()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant NotOwner_error_selector = 0x30cd7471;

/*
 * @dev error NotOperator()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant NotOperator_error_selector = 0x7c214f04;

/*
 * @dev error NotWinner()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant NotWinner_error_selector = 0x618c7242;

/*
 * @dev error OnePlayerCannotFillUpTheWholeRound()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant OnePlayerCannotFillUpTheWholeRound_error_selector = 0xae24220e;

/*
 * @dev error OutflowNotAllowed()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant OutflowNotAllowed_error_selector = 0x010a265a;

/*
 * @dev error ProtocolFeeNotPaid()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant ProtocolFeeNotPaid_error_selector = 0x0134f278;

/*
 * @dev error RandomnessRequestAlreadyExists()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant RandomnessRequestAlreadyExists_error_selector = 0xf9012132;

/*
 * @dev error RoundCannotBeClosed()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant RoundCannotBeClosed_error_selector = 0x7cd9dd6a;

/*
 * @dev error TooFewEntries()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant TooFewEntries_error_selector = 0xf48cb8a0;

/*
 * @dev error ZeroDeposits()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant ZeroDeposits_error_selector = 0xa95231d5;

/*
 * @dev error ZeroEntries()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant ZeroEntries_error_selector = 0xf9121438;

/*
 * @dev error ZeroRounds()
 *      Memory layout:
 *        - 0x00: Left-padded selector (data begins at 0x1c)
 *      Revert buffer is memory[0x1c:0x20]
 */
uint256 constant ZeroRounds_error_selector = 0xcbc4e060;

uint256 constant Error_selector_offset = 0x1c;

uint256 constant Error_standard_length = 0x04;
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IPriceOracle {
    error PoolNotAllowed();
    error PriceIsZero();

    event PoolAdded(address token, address pool);
    event PoolRemoved(address token);

    function getTWAP(address token, uint32 secondsAgo) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IYoloV2 {
    /**
     * @notice A round's status
     * @param None The round does not exist
     * @param Open The round is open for deposits
     * @param Drawing The round is being drawn
     * @param Drawn The round has been drawn
     * @param Cancelled The round has been cancelled
     */
    enum RoundStatus {
        None,
        Open,
        Drawing,
        Drawn,
        Cancelled
    }

    /**
     * @dev Giving TokenType a namespace to avoid name conflicts with TransferManager.
     */
    enum YoloV2__TokenType {
        ETH,
        ERC20,
        ERC721
    }

    event TokensStatusUpdated(address[] tokens, YoloV2__TokenType tokenType, bool isAllowed);
    event Deposited(address depositor, uint256 roundId, uint256 entriesCount);
    event ERC20OracleUpdated(address erc20Oracle);
    event MaximumNumberOfParticipantsPerRoundUpdated(uint40 maximumNumberOfParticipantsPerRound);
    event MultipleRoundsDeposited(
        address depositor,
        uint256 startingRoundId,
        uint256[] amounts,
        uint256[] entriesCounts
    );
    event PrizesClaimed(address winner, WithdrawalCalldata[] withdrawalCalldata);
    event DepositsWithdrawn(address depositor, WithdrawalCalldata[] withdrawalCalldata);
    event Rollover(
        address depositor,
        WithdrawalCalldata[] withdrawalCalldata,
        uint256 enteredRoundId,
        uint256 entriesCount
    );
    event ProtocolFeeBpUpdated(uint16 protocolFeeBp);
    event DiscountedProtocolFeeBpUpdated(uint16 discountedProtocolFeeBp);
    event ProtocolFeePayment(uint256 amount, address token);
    event ProtocolFeeRecipientUpdated(address protocolFeeRecipient);
    event RandomnessRequested(uint256 roundId, uint256 requestId);
    event ReservoirOracleUpdated(address reservoirOracle);
    event RoundDurationUpdated(uint40 roundDuration);
    event RoundsCancelled(uint256 startingRoundId, uint256 numberOfRounds);
    event RoundStatusUpdated(uint256 roundId, RoundStatus status);
    event SignatureValidityPeriodUpdated(uint40 signatureValidityPeriod);
    event ValuePerEntryUpdated(uint256 valuePerEntry);
    event OutflowAllowedUpdated(bool isAllowed);

    error AlreadyWithdrawn();
    error CutoffTimeNotReached();
    error DrawExpirationTimeNotReached();
    error InsufficientParticipants();
    error InvalidIndex();
    error InvalidLength();
    error InvalidSignatureTimestamp();
    error InvalidStatus();
    error InvalidToken();
    error InvalidTokenType();
    error InvalidValue();
    error LooksAlreadySet();
    error MaximumNumberOfDepositsReached();
    error MaximumNumberOfParticipantsReached();
    error MessageIdInvalid();
    error NotOperator();
    error NotOwner();
    error NotWinner();
    error NotDepositor();
    error OnePlayerCannotFillUpTheWholeRound();
    error OutflowNotAllowed();
    error ProtocolFeeNotPaid();
    error RandomnessRequestAlreadyExists();
    error RoundCannotBeClosed();
    error TooFewEntries();
    error ZeroDeposits();
    error ZeroEntries();
    error ZeroRounds();

    /**
     * @param owner The owner of the contract.
     * @param operator The operator of the contract.
     * @param roundDuration The duration of each round.
     * @param valuePerEntry The value of each entry in ETH.
     * @param protocolFeeRecipient The protocol fee recipient.
     * @param protocolFeeBp The protocol fee basis points.
     * @param discountedProtocolFeeBp The discounted protocol fee basis points.
     * @param keyHash Chainlink VRF key hash
     * @param subscriptionId Chainlink VRF subscription ID
     * @param vrfCoordinator Chainlink VRF coordinator address
     * @param reservoirOracle Reservoir off-chain oracle address
     * @param erc20Oracle ERC20 on-chain oracle address
     * @param transferManager Transfer manager
     * @param signatureValidityPeriod The validity period of a Reservoir signature.
     * @param minimumRequestConfirmations The minimum number of confirmation blocks on VRF requests before oracles respond.
     */
    struct ConstructorCalldata {
        address owner;
        address operator;
        uint40 maximumNumberOfParticipantsPerRound;
        uint40 roundDuration;
        uint96 valuePerEntry;
        address protocolFeeRecipient;
        uint16 protocolFeeBp;
        uint16 discountedProtocolFeeBp;
        bytes32 keyHash;
        uint64 subscriptionId;
        address vrfCoordinator;
        address reservoirOracle;
        address transferManager;
        address erc20Oracle;
        address weth;
        uint40 signatureValidityPeriod;
        uint16 minimumRequestConfirmations;
    }

    /**
     * @param id The id of the response.
     * @param payload The payload of the response.
     * @param timestamp The timestamp of the response.
     * @param signature The signature of the response.
     */
    struct ReservoirOracleFloorPrice {
        bytes32 id;
        bytes payload;
        uint256 timestamp;
        bytes signature;
    }

    /**
     * @param tokenType The type of the token.
     * @param tokenAddress The address of the token.
     * @param tokenIdsOrAmounts The ids (ERC-721) or amounts (ERC-20) of the tokens.
     * @param minimumEntries The minimum entries to receive if it's an ERC-20 deposit. Unused for ERC-721 deposits.
     * @param reservoirOracleFloorPrice The Reservoir oracle floor price. Required for ERC-721 deposits.
     */
    struct DepositCalldata {
        YoloV2__TokenType tokenType;
        address tokenAddress;
        uint256[] tokenIdsOrAmounts;
        uint256 minimumEntries;
        ReservoirOracleFloorPrice reservoirOracleFloorPrice;
    }

    /*
     * @notice A round
     * @dev The storage layout of a round is as follows:
     * |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
     * | empty (72 bits) | numberOfParticipants (40) bits) | drawnAt (40 bits) | cutoffTime (40 bits) | protcoolFeeBp (16 bits) | maximumNumberOfParticipants (40 bits) | status (8 bits)                                     |
     * |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
     * | valuePerEntry (96 bits) | winner (160 bits)                                                                                                                                                                          |
     * |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
     * | protocolFeeOwed (256 bits)                                                                                                                                                                                           |
     * |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
     * | deposits length (256 bits)                                                                                                                                                                                           |
     * |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
     *
     * @param status The status of the round.
     * @param maximumNumberOfParticipants The maximum number of participants.
     * @param protocolFeeBp The protocol fee basis points.
     * @param cutoffTime The cutoff time of the round.
     * @param drawnAt The time the round was drawn.
     * @param numberOfParticipants The current number of participants.
     * @param winner The winner of the round.
     * @param valuePerEntry The value of each entry in ETH.
     * @param protocolFeeOwed The protocol fee owed in ETH.
     * @param deposits The deposits in the round.
     */
    struct Round {
        RoundStatus status;
        uint40 maximumNumberOfParticipants;
        uint16 protocolFeeBp;
        uint40 cutoffTime;
        uint40 drawnAt;
        uint40 numberOfParticipants;
        address winner;
        uint96 valuePerEntry;
        uint256 protocolFeeOwed;
        Deposit[] deposits;
    }

    /**
     * @notice A deposit in a round.
     * @dev The storage layout of a deposit is as follows:
     * |-------------------------------------------------------------------------------------------|
     * | empty (88 bits) | tokenAddress (160 bits) | tokenType (8 bits)                            |
     * |-------------------------------------------------------------------------------------------|
     * | tokenId (256 bits)                                                                        |
     * |-------------------------------------------------------------------------------------------|
     * | tokenAmount (256 bits)                                                                    |
     * |-------------------------------------------------------------------------------------------|
     * | empty (48 bits) | currentEntryIndex (40 bits) | withdrawn (8 bits) | depositor (160 bits) |
     * |-------------------------------------------------------------------------------------------|
     *
     * @param tokenType The type of the token.
     * @param tokenAddress The address of the token.
     * @param tokenId The id of the token.
     * @param tokenAmount The amount of the token.
     * @param depositor The depositor of the token.
     * @param withdrawn Whether the token has been withdrawn.
     * @param currentEntryIndex The current entry index.
     */
    struct Deposit {
        YoloV2__TokenType tokenType;
        address tokenAddress;
        uint256 tokenId;
        uint256 tokenAmount;
        address depositor;
        bool withdrawn;
        uint40 currentEntryIndex;
    }

    /**
     * @param exists Whether the request exists.
     * @param roundId The id of the round.
     * @param randomWord The random words returned by Chainlink VRF.
     *                   If randomWord == 0, then the request is still pending.
     */
    struct RandomnessRequest {
        bool exists;
        uint40 roundId;
        uint256 randomWord;
    }

    /**
     * @param roundId The id of the round.
     * @param depositIndices The indices of the deposits to be claimed.
     */
    struct WithdrawalCalldata {
        uint256 roundId;
        uint256[] depositIndices;
    }

    /**
     * @notice This is used to accumulate the amount of tokens to be transferred.
     * @param tokenAddress The address of the token.
     * @param amount The amount of tokens accumulated.
     */
    struct TransferAccumulator {
        address tokenAddress;
        uint256 amount;
    }

    /**
     * @notice This function cancels an expired round that does not have at least 2 participants.
     */
    function cancel() external;

    /**
     * @notice This function cancels multiple rounds (current and future) without any validations (can be any state).
     *         Only callable by the contract owner.
     * @param numberOfRounds Number of rounds to cancel.
     */
    function cancel(uint256 numberOfRounds) external;

    /**
     * @notice Cancels a round after randomness request if the randomness request
     *         does not arrive after 25 hours. Chainlink VRF stops trying after 24 hours.
     *         Giving an extra hour should prevent any frontrun attempts.
     */
    function cancelAfterRandomnessRequest() external;

    /**
     * @notice This function allows the winner of a round to withdraw the prizes.
     * @param withdrawalCalldata The rounds and the indices for the rounds for the prizes to claim.
     * @param payWithLOOKS Whether to pay for the protocol fee with LOOKS.
     */
    function claimPrizes(WithdrawalCalldata[] calldata withdrawalCalldata, bool payWithLOOKS) external payable;

    /**
     * @notice This function calculates the ETH payment required to claim the prizes for multiple rounds.
     * @param withdrawalCalldata The rounds and the indices for the rounds for the prizes to claim.
     * @param payWithLOOKS Whether to pay for the protocol fee with LOOKS.
     * @return protocolFeeOwed The protocol fee owed in ETH or LOOKS.
     */
    function getClaimPrizesPaymentRequired(
        WithdrawalCalldata[] calldata withdrawalCalldata,
        bool payWithLOOKS
    ) external view returns (uint256 protocolFeeOwed);

    /**
     * @notice This function is used by the frontend to estimate the minimumEntries to be set for ERC-20 deposits.
     * @dev This function does 0 validations. It is the responsibility of the caller to ensure that the deposit is valid and the round is enterable.
     * @param roundId The round ID.
     * @param singleDeposit The ERC-20 deposit.
     * @return entriesCount The estimated number of entries for the deposit amount.
     */
    function estimatedERC20DepositEntriesCount(
        uint256 roundId,
        DepositCalldata calldata singleDeposit
    ) external view returns (uint256 entriesCount);

    /**
     * @notice This function allows withdrawal of deposits from a round if the round is cancelled
     * @param withdrawalCalldata The rounds and the indices for the rounds for the prizes to claim.
     */
    function withdrawDeposits(WithdrawalCalldata[] calldata withdrawalCalldata) external;

    /**
     * @notice This function allows players to deposit into a round.
     * @param roundId The open round ID.
     * @param deposits The ERC-20/ERC-721 deposits to be made.
     */
    function deposit(uint256 roundId, DepositCalldata[] calldata deposits) external payable;

    /**
     * @notice This function allows a player to deposit into multiple rounds at once. ETH only.
     * @param startingRoundId The starting round ID to deposit into. Round status must be Open.
     * @param amounts The amount of ETH to deposit into each round.
     */
    function depositETHIntoMultipleRounds(uint256 startingRoundId, uint256[] calldata amounts) external payable;

    /**
     * @notice This function draws a round.
     */
    function drawWinner() external;

    /**
     * @notice This function returns the given round's data.
     * @param roundId The round ID.
     * @return status The status of the round.
     * @return maximumNumberOfParticipants The round's maximum number of participants.
     * @return roundProtocolFeeBp The round's protocol fee in basis points.
     * @return cutoffTime The round's cutoff time.
     * @return drawnAt The time the round was drawn.
     * @return numberOfParticipants The round's current number of participants.
     * @return winner The round's winner.
     * @return roundValuePerEntry The round's value per entry.
     * @return protocolFeeOwed The round's protocol fee owed in ETH.
     * @return deposits The round's deposits.
     */
    function getRound(
        uint256 roundId
    )
        external
        view
        returns (
            IYoloV2.RoundStatus status,
            uint40 maximumNumberOfParticipants,
            uint16 roundProtocolFeeBp,
            uint40 cutoffTime,
            uint40 drawnAt,
            uint40 numberOfParticipants,
            address winner,
            uint96 roundValuePerEntry,
            uint256 protocolFeeOwed,
            Deposit[] memory deposits
        );

    /**
     * @notice This function allows a player to rollover prizes or deposits from a cancelled round to the current round.
     * @param roundId The round ID to rollover ETH into.
     * @param withdrawalCalldata The rounds and the indices for the rounds for the prizes to claim.
     * @param payWithLOOKS Whether to pay for the protocol fee with LOOKS.
     */
    function rolloverETH(uint256 roundId, WithdrawalCalldata[] calldata withdrawalCalldata, bool payWithLOOKS) external;

    /**
     * @notice This function allows the owner to pause/unpause the contract.
     */
    function togglePaused() external;

    /**
     * @notice This function allows the owner to allow/forbid token outflow.
     */
    function toggleOutflowAllowed() external;

    /**
     * @notice This function allows the owner to update token statuses (ERC-20 and ERC-721).
     * @param tokens Token addresses
     * @param tokenType Token type
     * @param isAllowed Whether the tokens should be allowed in the yolos
     * @dev Only callable by owner.
     */
    function updateTokensStatus(address[] calldata tokens, YoloV2__TokenType tokenType, bool isAllowed) external;

    /**
     * @notice This function allows the owner to update the duration of each round.
     * @param _roundDuration The duration of each round.
     */
    function updateRoundDuration(uint40 _roundDuration) external;

    /**
     * @notice This function allows the owner to update the signature validity period.
     * @param _signatureValidityPeriod The signature validity period.
     */
    function updateSignatureValidityPeriod(uint40 _signatureValidityPeriod) external;

    /**
     * @notice This function allows the owner to update the value of each entry in ETH.
     * @param _valuePerEntry The value of each entry in ETH.
     */
    function updateValuePerEntry(uint96 _valuePerEntry) external;

    /**
     * @notice This function allows the owner to update the discounted protocol fee in basis points if paid in LOOKS.
     * @param discountedProtocolFeeBp The discounted protocol fee in basis points.
     */
    function updateDiscountedProtocolFeeBp(uint16 discountedProtocolFeeBp) external;

    /**
     * @notice This function allows the owner to update the protocol fee in basis points.
     * @param protocolFeeBp The protocol fee in basis points.
     */
    function updateProtocolFeeBp(uint16 protocolFeeBp) external;

    /**
     * @notice This function allows the owner to update the protocol fee recipient.
     * @param protocolFeeRecipient The protocol fee recipient.
     */
    function updateProtocolFeeRecipient(address protocolFeeRecipient) external;

    /**
     * @notice This function allows the owner to update Reservoir oracle's address.
     * @param reservoirOracle Reservoir oracle address.
     */
    function updateReservoirOracle(address reservoirOracle) external;

    /**
     * @notice This function allows the owner to update the maximum number of participants per round.
     * @param _maximumNumberOfParticipantsPerRound The maximum number of participants per round.
     */
    function updateMaximumNumberOfParticipantsPerRound(uint40 _maximumNumberOfParticipantsPerRound) external;

    /**
     * @notice This function allows the owner to update ERC20 oracle's address.
     * @param erc20Oracle ERC20 oracle address.
     */
    function updateERC20Oracle(address erc20Oracle) external;

    /**
     * @notice This function allows the owner to set the LOOKS token address. Only callable once.
     * @param looks LOOKS token address.
     */
    function setLOOKS(address looks) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 *      Modified from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Arrays.sol
 */
library Arrays {
    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] memory array, uint256 element) internal pure returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                unchecked {
                    low = mid + 1;
                }
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            unchecked {
                return low - 1;
            }
        } else {
            return low;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Pausable
 * @notice This contract makes it possible to pause the contract.
 *         It is adjusted from OpenZeppelin.
 * @author LooksRare protocol team (?,?)
 */
abstract contract Pausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    error IsPaused();
    error NotPaused();

    bool private _paused;

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
            revert IsPaused();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert NotPaused();
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
        emit Paused(msg.sender);
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
        emit Unpaused(msg.sender);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interfaces
import {IReentrancyGuard} from "./interfaces/IReentrancyGuard.sol";

/**
 * @title ReentrancyGuard
 * @notice This contract protects against reentrancy attacks.
 *         It is adjusted from OpenZeppelin.
 * @author LooksRare protocol team (?,?)
 */
abstract contract ReentrancyGuard is IReentrancyGuard {
    uint256 private _status;

    /**
     * @notice Modifier to wrap functions to prevent reentrancy calls.
     */
    modifier nonReentrant() {
        if (_status == 2) {
            revert ReentrancyFail();
        }

        _status = 2;
        _;
        _status = 1;
    }

    constructor() {
        _status = 1;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interfaces
import {IERC1271} from "./interfaces/generic/IERC1271.sol";

// Constants
import {ERC1271_MAGIC_VALUE} from "./constants/StandardConstants.sol";

// Errors
import {SignatureParameterSInvalid, SignatureParameterVInvalid, SignatureERC1271Invalid, SignatureEOAInvalid, NullSignerAddress, SignatureLengthInvalid} from "./errors/SignatureCheckerErrors.sol";

/**
 * @title SignatureCheckerMemory
 * @notice This library is used to verify signatures for EOAs (with lengths of both 65 and 64 bytes)
 *         and contracts (ERC1271).
 * @author LooksRare protocol team (?,?)
 */
library SignatureCheckerMemory {
    /**
     * @notice This function verifies whether the signer is valid for a hash and raw signature.
     * @param hash Data hash
     * @param signer Signer address (to confirm message validity)
     * @param signature Signature parameters encoded (v, r, s)
     * @dev For EIP-712 signatures, the hash must be the digest (computed with signature hash and domain separator)
     */
    function verify(bytes32 hash, address signer, bytes memory signature) internal view {
        if (signer.code.length == 0) {
            if (_recoverEOASigner(hash, signature) == signer) return;
            revert SignatureEOAInvalid();
        } else {
            if (IERC1271(signer).isValidSignature(hash, signature) == ERC1271_MAGIC_VALUE) return;
            revert SignatureERC1271Invalid();
        }
    }

    /**
     * @notice This function is internal and splits a signature into r, s, v outputs.
     * @param signature A 64 or 65 bytes signature
     * @return r The r output of the signature
     * @return s The s output of the signature
     * @return v The recovery identifier, must be 27 or 28
     */
    function splitSignature(bytes memory signature) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        uint256 length = signature.length;

        if (length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (length == 64) {
            assembly {
                r := mload(add(signature, 0x20))
                let vs := mload(add(signature, 0x40))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert SignatureLengthInvalid(length);
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert SignatureParameterSInvalid();
        }

        if (v != 27 && v != 28) {
            revert SignatureParameterVInvalid(v);
        }
    }

    /**
     * @notice This function is private and recovers the signer of a signature (for EOA only).
     * @param hash Hash of the signed message
     * @param signature Bytes containing the signature (64 or 65 bytes)
     * @return signer The address that signed the signature
     */
    function _recoverEOASigner(bytes32 hash, bytes memory signature) private pure returns (address signer) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);

        // If the signature is valid (and not malleable), return the signer's address
        signer = ecrecover(hash, v, r, s);

        if (signer == address(0)) {
            revert NullSignerAddress();
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @dev ERC1271's magic value (bytes4(keccak256("isValidSignature(bytes32,bytes)"))
 */
bytes4 constant ERC1271_MAGIC_VALUE = 0x1626ba7e;
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @notice It is emitted if the call recipient is not a contract.
 */
error NotAContract();
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @notice It is emitted if the ETH transfer fails.
 */
error ETHTransferFail();

/**
 * @notice It is emitted if the ERC20 approval fails.
 */
error ERC20ApprovalFail();

/**
 * @notice It is emitted if the ERC20 transfer fails.
 */
error ERC20TransferFail();

/**
 * @notice It is emitted if the ERC20 transferFrom fails.
 */
error ERC20TransferFromFail();

/**
 * @notice It is emitted if the ERC721 transferFrom fails.
 */
error ERC721TransferFromFail();

/**
 * @notice It is emitted if the ERC1155 safeTransferFrom fails.
 */
error ERC1155SafeTransferFromFail();

/**
 * @notice It is emitted if the ERC1155 safeBatchTransferFrom fails.
 */
error ERC1155SafeBatchTransferFromFail();
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @notice It is emitted if the signer is null.
 */
error NullSignerAddress();

/**
 * @notice It is emitted if the signature is invalid for an EOA (the address recovered is not the expected one).
 */
error SignatureEOAInvalid();

/**
 * @notice It is emitted if the signature is invalid for a ERC1271 contract signer.
 */
error SignatureERC1271Invalid();

/**
 * @notice It is emitted if the signature's length is neither 64 nor 65 bytes.
 */
error SignatureLengthInvalid(uint256 length);

/**
 * @notice It is emitted if the signature is invalid due to S parameter.
 */
error SignatureParameterSInvalid();

/**
 * @notice It is emitted if the signature is invalid due to V parameter.
 */
error SignatureParameterVInvalid(uint8 v);
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title IReentrancyGuard
 * @author LooksRare protocol team (?,?)
 */
interface IReentrancyGuard {
    /**
     * @notice This is returned when there is a reentrant call.
     */
    error ReentrancyFail();
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC1271 {
    function isValidSignature(bytes32 hash, bytes calldata signature) external view returns (bytes4 magicValue);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address dst, uint256 wad) external returns (bool);

    function withdraw(uint256 wad) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interfaces
import {IERC20} from "../interfaces/generic/IERC20.sol";

// Errors
import {ERC20TransferFail, ERC20TransferFromFail} from "../errors/LowLevelErrors.sol";
import {NotAContract} from "../errors/GenericErrors.sol";

/**
 * @title LowLevelERC20Transfer
 * @notice This contract contains low-level calls to transfer ERC20 tokens.
 * @author LooksRare protocol team (?,?)
 */
contract LowLevelERC20Transfer {
    /**
     * @notice Execute ERC20 transferFrom
     * @param currency Currency address
     * @param from Sender address
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function _executeERC20TransferFrom(address currency, address from, address to, uint256 amount) internal {
        if (currency.code.length == 0) {
            revert NotAContract();
        }

        (bool status, bytes memory data) = currency.call(abi.encodeCall(IERC20.transferFrom, (from, to, amount)));

        if (!status) {
            revert ERC20TransferFromFail();
        }

        if (data.length > 0) {
            if (!abi.decode(data, (bool))) {
                revert ERC20TransferFromFail();
            }
        }
    }

    /**
     * @notice Execute ERC20 (direct) transfer
     * @param currency Currency address
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function _executeERC20DirectTransfer(address currency, address to, uint256 amount) internal {
        if (currency.code.length == 0) {
            revert NotAContract();
        }

        (bool status, bytes memory data) = currency.call(abi.encodeCall(IERC20.transfer, (to, amount)));

        if (!status) {
            revert ERC20TransferFail();
        }

        if (data.length > 0) {
            if (!abi.decode(data, (bool))) {
                revert ERC20TransferFail();
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interfaces
import {IERC721} from "../interfaces/generic/IERC721.sol";

// Errors
import {ERC721TransferFromFail} from "../errors/LowLevelErrors.sol";
import {NotAContract} from "../errors/GenericErrors.sol";

/**
 * @title LowLevelERC721Transfer
 * @notice This contract contains low-level calls to transfer ERC721 tokens.
 * @author LooksRare protocol team (?,?)
 */
contract LowLevelERC721Transfer {
    /**
     * @notice Execute ERC721 transferFrom
     * @param collection Address of the collection
     * @param from Address of the sender
     * @param to Address of the recipient
     * @param tokenId tokenId to transfer
     */
    function _executeERC721TransferFrom(address collection, address from, address to, uint256 tokenId) internal {
        if (collection.code.length == 0) {
            revert NotAContract();
        }

        (bool status, ) = collection.call(abi.encodeCall(IERC721.transferFrom, (from, to, tokenId)));

        if (!status) {
            revert ERC721TransferFromFail();
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interfaces
import {IWETH} from "../interfaces/generic/IWETH.sol";

/**
 * @title LowLevelWETH
 * @notice This contract contains a function to transfer ETH with an option to wrap to WETH.
 *         If the ETH transfer fails within a gas limit, the amount in ETH is wrapped to WETH and then transferred.
 * @author LooksRare protocol team (?,?)
 */
contract LowLevelWETH {
    /**
     * @notice It transfers ETH to a recipient with a specified gas limit.
     *         If the original transfers fails, it wraps to WETH and transfers the WETH to recipient.
     * @param _WETH WETH address
     * @param _to Recipient address
     * @param _amount Amount to transfer
     * @param _gasLimit Gas limit to perform the ETH transfer
     */
    function _transferETHAndWrapIfFailWithGasLimit(
        address _WETH,
        address _to,
        uint256 _amount,
        uint256 _gasLimit
    ) internal {
        bool status;

        assembly {
            status := call(_gasLimit, _to, _amount, 0, 0, 0, 0)
        }

        if (!status) {
            IWETH(_WETH).deposit{value: _amount}();
            IWETH(_WETH).transfer(_to, _amount);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

enum TokenType {
    ERC20,
    ERC721,
    ERC1155
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Enums
import {TokenType} from "../enums/TokenType.sol";

/**
 * @title ITransferManager
 * @author LooksRare protocol team (?,?)
 */
interface ITransferManager {
    /**
     * @notice This struct is only used for transferBatchItemsAcrossCollections.
     * @param tokenAddress Token address
     * @param tokenType 0 for ERC721, 1 for ERC1155
     * @param itemIds Array of item ids to transfer
     * @param amounts Array of amounts to transfer
     */
    struct BatchTransferItem {
        address tokenAddress;
        TokenType tokenType;
        uint256[] itemIds;
        uint256[] amounts;
    }

    /**
     * @notice It is emitted if operators' approvals to transfer NFTs are granted by a user.
     * @param user Address of the user
     * @param operators Array of operator addresses
     */
    event ApprovalsGranted(address user, address[] operators);

    /**
     * @notice It is emitted if operators' approvals to transfer NFTs are revoked by a user.
     * @param user Address of the user
     * @param operators Array of operator addresses
     */
    event ApprovalsRemoved(address user, address[] operators);

    /**
     * @notice It is emitted if a new operator is added to the global allowlist.
     * @param operator Operator address
     */
    event OperatorAllowed(address operator);

    /**
     * @notice It is emitted if an operator is removed from the global allowlist.
     * @param operator Operator address
     */
    event OperatorRemoved(address operator);

    /**
     * @notice It is returned if the operator to approve has already been approved by the user.
     */
    error OperatorAlreadyApprovedByUser();

    /**
     * @notice It is returned if the operator to revoke has not been previously approved by the user.
     */
    error OperatorNotApprovedByUser();

    /**
     * @notice It is returned if the transfer caller is already allowed by the owner.
     * @dev This error can only be returned for owner operations.
     */
    error OperatorAlreadyAllowed();

    /**
     * @notice It is returned if the operator to approve is not in the global allowlist defined by the owner.
     * @dev This error can be returned if the user tries to grant approval to an operator address not in the
     *      allowlist or if the owner tries to remove the operator from the global allowlist.
     */
    error OperatorNotAllowed();

    /**
     * @notice It is returned if the transfer caller is invalid.
     *         For a transfer called to be valid, the operator must be in the global allowlist and
     *         approved by the 'from' user.
     */
    error TransferCallerInvalid();

    /**
     * @notice This function transfers ERC20 tokens.
     * @param tokenAddress Token address
     * @param from Sender address
     * @param to Recipient address
     * @param amount amount
     */
    function transferERC20(
        address tokenAddress,
        address from,
        address to,
        uint256 amount
    ) external;

    /**
     * @notice This function transfers a single item for a single ERC721 collection.
     * @param tokenAddress Token address
     * @param from Sender address
     * @param to Recipient address
     * @param itemId Item ID
     */
    function transferItemERC721(
        address tokenAddress,
        address from,
        address to,
        uint256 itemId
    ) external;

    /**
     * @notice This function transfers items for a single ERC721 collection.
     * @param tokenAddress Token address
     * @param from Sender address
     * @param to Recipient address
     * @param itemIds Array of itemIds
     * @param amounts Array of amounts
     */
    function transferItemsERC721(
        address tokenAddress,
        address from,
        address to,
        uint256[] calldata itemIds,
        uint256[] calldata amounts
    ) external;

    /**
     * @notice This function transfers a single item for a single ERC1155 collection.
     * @param tokenAddress Token address
     * @param from Sender address
     * @param to Recipient address
     * @param itemId Item ID
     * @param amount Amount
     */
    function transferItemERC1155(
        address tokenAddress,
        address from,
        address to,
        uint256 itemId,
        uint256 amount
    ) external;

    /**
     * @notice This function transfers items for a single ERC1155 collection.
     * @param tokenAddress Token address
     * @param from Sender address
     * @param to Recipient address
     * @param itemIds Array of itemIds
     * @param amounts Array of amounts
     * @dev It does not allow batch transferring if from = msg.sender since native function should be used.
     */
    function transferItemsERC1155(
        address tokenAddress,
        address from,
        address to,
        uint256[] calldata itemIds,
        uint256[] calldata amounts
    ) external;

    /**
     * @notice This function transfers items across an array of tokens that can be ERC20, ERC721 and ERC1155.
     * @param items Array of BatchTransferItem
     * @param from Sender address
     * @param to Recipient address
     */
    function transferBatchItemsAcrossCollections(
        BatchTransferItem[] calldata items,
        address from,
        address to
    ) external;

    /**
     * @notice This function allows a user to grant approvals for an array of operators.
     *         Users cannot grant approvals if the operator is not allowed by this contract's owner.
     * @param operators Array of operator addresses
     * @dev Each operator address must be globally allowed to be approved.
     */
    function grantApprovals(address[] calldata operators) external;

    /**
     * @notice This function allows a user to revoke existing approvals for an array of operators.
     * @param operators Array of operator addresses
     * @dev Each operator address must be approved at the user level to be revoked.
     */
    function revokeApprovals(address[] calldata operators) external;

    /**
     * @notice This function allows an operator to be added for the shared transfer system.
     *         Once the operator is allowed, users can grant NFT approvals to this operator.
     * @param operator Operator address to allow
     * @dev Only callable by owner.
     */
    function allowOperator(address operator) external;

    /**
     * @notice This function allows the user to remove an operator for the shared transfer system.
     * @param operator Operator address to remove
     * @dev Only callable by owner.
     */
    function removeOperator(address operator) external;

    /**
     * @notice This returns whether the user has approved the operator address.
     * The first address is the user and the second address is the operator.
     */
    function hasUserApprovedOperator(address user, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
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
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
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
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
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
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
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
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
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
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

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