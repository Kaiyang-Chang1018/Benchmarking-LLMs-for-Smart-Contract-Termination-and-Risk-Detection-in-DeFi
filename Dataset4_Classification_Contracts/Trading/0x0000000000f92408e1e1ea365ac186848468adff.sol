// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@looksrare/contracts-libs/contracts/interfaces/generic/IERC20.sol";
import {LowLevelWETH} from "@looksrare/contracts-libs/contracts/lowLevelCallers/LowLevelWETH.sol";
import {ITransferManager} from "@looksrare/contracts-transfer-manager/contracts/interfaces/ITransferManager.sol";
import {IInfiltration} from "./interfaces/IInfiltration.sol";
import {IV3SwapRouter} from "./interfaces/IV3SwapRouter.sol";
import {IQuoterV2} from "./interfaces/IQuoterV2.sol";

contract InfiltrationPeriphery is LowLevelWETH {
    ITransferManager public immutable TRANSFER_MANAGER;
    IInfiltration public immutable INFILTRATION;
    IV3SwapRouter public immutable SWAP_ROUTER;
    IQuoterV2 public immutable QUOTER;
    address public immutable WETH;
    address public immutable LOOKS;

    uint24 private constant POOL_FEE = 3_000;

    constructor(
        address _transferManager,
        address _infiltration,
        address _uniswapRouter,
        address _uniswapQuoter,
        address _weth,
        address _looks
    ) {
        TRANSFER_MANAGER = ITransferManager(_transferManager);
        INFILTRATION = IInfiltration(_infiltration);
        SWAP_ROUTER = IV3SwapRouter(_uniswapRouter);
        QUOTER = IQuoterV2(_uniswapQuoter);
        WETH = _weth;
        LOOKS = _looks;

        address[] memory operators = new address[](1);
        operators[0] = address(INFILTRATION);
        TRANSFER_MANAGER.grantApprovals(operators);
    }

    /**
     * @notice Submits a heal request for the specified agent IDs.
     * @param agentIds The agent IDs to heal.
     */
    function heal(uint256[] calldata agentIds) external payable {
        uint256 costToHealInLOOKS = INFILTRATION.costToHeal(agentIds);

        IV3SwapRouter.ExactOutputSingleParams memory params = IV3SwapRouter.ExactOutputSingleParams({
            tokenIn: WETH,
            tokenOut: LOOKS,
            fee: POOL_FEE,
            recipient: address(this),
            amountOut: costToHealInLOOKS,
            amountInMaximum: msg.value,
            sqrtPriceLimitX96: 0
        });

        uint256 amountIn = SWAP_ROUTER.exactOutputSingle{value: msg.value}(params);

        IERC20(LOOKS).approve(address(TRANSFER_MANAGER), costToHealInLOOKS);

        INFILTRATION.heal(agentIds);

        if (msg.value > amountIn) {
            SWAP_ROUTER.refundETH();
            unchecked {
                _transferETHAndWrapIfFailWithGasLimit(WETH, msg.sender, msg.value - amountIn, gasleft());
            }
        }
    }

    /**
     * @notice Returns the cost to heal the specified agents in ETH
     * @dev The cost doubles for each time the agent is healed.
     * @param agentIds The agent IDs to heal.
     * @return costToHealInETH The cost to heal the specified agents.
     */
    function costToHeal(uint256[] calldata agentIds) external returns (uint256 costToHealInETH) {
        uint256 costToHealInLOOKS = INFILTRATION.costToHeal(agentIds);

        IQuoterV2.QuoteExactOutputSingleParams memory params = IQuoterV2.QuoteExactOutputSingleParams({
            tokenIn: WETH,
            tokenOut: LOOKS,
            amount: costToHealInLOOKS,
            fee: POOL_FEE,
            sqrtPriceLimitX96: uint160(0)
        });

        (costToHealInETH, , , ) = QUOTER.quoteExactOutputSingle(params);
    }

    /**
     * @notice This function is used to receive ETH from the swap router.
     */
    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IInfiltration {
    /**
     * @notice Agent statuses.
     *         1. Active: The agent is active.
     *         2. Wounded: The agent is wounded. The agent can be healed for a number of blocks.
     *         3. Healing: The agent is healing. The outcome of the healing is not yet known.
     *         4. Escaped: The agent escaped from the game and took some rewards with him.
     *         5. Dead: The agent is dead. It can be due to the agent being wounded for too long or a failed healing.
     */
    enum AgentStatus {
        Active,
        Wounded,
        Healing,
        Escaped,
        Dead
    }

    /**
     * @notice Heal outcomes. The agent can either be healed or killed.
     */
    enum HealOutcome {
        Healed,
        Killed
    }

    /**
     * @notice Randomness request statuses.
     */
    enum RandomnessRequestStatus {
        None,
        Requested,
        Fulfilled
    }

    /**
     * @notice An agent.
     * @dev The storage layout of an agent is as follows:
     * |---------------------------------------------------------------------------------------------------|
     * | empty (176 bits) | healCount (16 bits) | woundedAt (40 bits) | status (8 bits) | agentId (16 bits)|
     * |---------------------------------------------------------------------------------------------------|
     * @param agentId The ID of the agent.
     * @param status The status of the agent.
     * @param woundedAt The round number when the agent was wounded.
     * @param healCount The number of times the agent has been successfully healed.
     */
    struct Agent {
        uint16 agentId;
        AgentStatus status;
        uint40 woundedAt;
        uint16 healCount;
    }

    /**
     * @notice The constructor calldata.
     * @param owner The owner of the contract.
     * @param name The name of the collection.
     * @param symbol The symbol of the collection.
     * @param price The mint price.
     * @param maxSupply The maximum supply of the collection.
     * @param maxMintPerAddress The maximum number of agents that can be minted per address.
     * @param blocksPerRound The number of blocks per round.
     * @param agentsToWoundPerRoundInBasisPoints The number of agents to wound per round in basis points.
     * @param roundsToBeWoundedBeforeDead The number of rounds for an agent to be wounded before getting killed.
     * @param looks The LOOKS token address.
     * @param vrfCoordinator The VRF coordinator address.
     * @param keyHash The VRF key hash.
     * @param subscriptionId The VRF subscription ID.
     * @param transferManager The transfer manager address.
     * @param healBaseCost The base cost to heal an agent.
     * @param protocolFeeRecipient The protocol fee recipient.
     * @param protocolFeeBp The protocol fee basis points.
     * @param weth The WETH address.
     * @param baseURI The base URI of the collection.
     */
    struct ConstructorCalldata {
        address owner;
        string name;
        string symbol;
        uint256 price;
        uint256 maxSupply;
        uint256 maxMintPerAddress;
        uint256 blocksPerRound;
        uint256 agentsToWoundPerRoundInBasisPoints;
        uint256 roundsToBeWoundedBeforeDead;
        address looks;
        address vrfCoordinator;
        bytes32 keyHash;
        uint64 subscriptionId;
        address transferManager;
        uint256 healBaseCost;
        address protocolFeeRecipient;
        uint16 protocolFeeBp;
        address weth;
        string baseURI;
    }

    /**
     * @notice Game info.
     * @dev The storage layout of game info is as follows:
     * |-------------------------------------------------------------------------------------------------------------------------------|
     * | empty (56 bits) | randomnessLastRequestedAt (40 bits) | currentRoundBlockNumber (40 bits) | currentRoundId (40 bits)          |
     * | escapedAgents (16 bits) | deadAgents (16 bits) | healingAgents (16 bits) | woundedAgents (16 bits) | activeAgents (16 bits)   |
     * |-------------------------------------------------------------------------------------------------------------------------------|
     * | prizePool (256 bits)                                                                                                          |
     * |-------------------------------------------------------------------------------------------------------------------------------|
     * | secondaryPrizePool (256 bits)                                                                                                 |
     * |-------------------------------------------------------------------------------------------------------------------------------|
     * | secondaryLooksPrizePool (256 bits)                                                                                            |
     * |-------------------------------------------------------------------------------------------------------------------------------|
     * @param activeAgents The number of active agents.
     * @param woundedAgents The number of wounded agents.
     * @param healingAgents The number of healing agents.
     * @param deadAgents The number of dead agents.
     * @param escapedAgents The number of escaped agents.
     * @param currentRoundId The current round ID.
     * @param currentRoundBlockNumber The current round block number.
     * @param randomnessLastRequestedAt The timestamp when the randomness was last requested.
     * @param prizePool The ETH prize pool for the final winner.
     * @param secondaryPrizePool The secondary ETH prize pool for the top X winners.
     * @param secondaryLooksPrizePool The secondary LOOKS prize pool for the top X winners.
     */
    struct GameInfo {
        uint16 activeAgents;
        uint16 woundedAgents;
        uint16 healingAgents;
        uint16 deadAgents;
        uint16 escapedAgents;
        uint40 currentRoundId;
        uint40 currentRoundBlockNumber;
        uint40 randomnessLastRequestedAt;
        uint256 prizePool;
        uint256 secondaryPrizePool;
        uint256 secondaryLooksPrizePool;
    }

    /**
     * @notice A Chainlink randomness request.
     * @param status The status of the randomness request.
     * @param roundId The round ID when the randomness request occurred.
     * @param randomWord The returned random word.
     */
    struct RandomnessRequest {
        RandomnessRequestStatus status;
        uint40 roundId;
        uint256 randomWord;
    }

    /**
     * @notice A heal result that is used to emit events.
     * @param agentId The agent ID.
     * @param outcome The outcome of the healing.
     */
    struct HealResult {
        uint256 agentId;
        HealOutcome outcome;
    }

    event EmergencyWithdrawal(uint256 ethAmount, uint256 looksAmount);
    event MintPeriodUpdated(uint256 mintStart, uint256 mintEnd);
    event HealRequestSubmitted(uint256 roundId, uint256[] agentIds, uint256[] costs);
    event HealRequestFulfilled(uint256 roundId, HealResult[] healResults);
    event RandomnessRequested(uint256 roundId, uint256 requestId);
    event RandomnessFulfilled(uint256 roundId, uint256 requestId);
    event InvalidRandomnessFulfillment(uint256 requestId, uint256 randomnessRequestRoundId, uint256 currentRoundId);
    event RoundStarted(uint256 roundId);
    event Escaped(uint256 roundId, uint256[] agentIds, uint256[] rewards);
    event PrizeClaimed(uint256 agentId, address currency, uint256 amount);
    event Wounded(uint256 roundId, uint256[] agentIds);
    event Killed(uint256 roundId, uint256[] agentIds);
    event Won(uint256 roundId, uint256 agentId);

    error ExceededTotalSupply();
    error FrontrunLockIsOn();
    error GameAlreadyBegun();
    error GameNotYetBegun();
    error GameIsStillRunning();
    error GameOver();
    error HealingDisabled();
    error InexactNativeTokensSupplied();
    error InvalidAgentStatus(uint256 agentId, AgentStatus expectedStatus);
    error InvalidHealingRoundsDelay();
    error InvalidMaxSupply();
    error InvalidMintPeriod();
    error InvalidPlacement();
    error MaximumHealingRequestPerRoundExceeded();
    error MintAlreadyStarted();
    error MintCanOnlyBeExtended();
    error MintStartIsInThePast();
    error NoAgentsLeft();
    error NoAgentsProvided();
    error NotEnoughMinted();
    error NothingToClaim();
    error NotInMintPeriod();
    error NotAgentOwner();
    error Immutable();
    error RandomnessRequestAlreadyExists();
    error InvalidRandomnessRequestId();
    error RoundsToBeWoundedBeforeDeadTooLow();
    error StillMinting();
    error TooEarlyToStartNewRound();
    error TooEarlyToRetryRandomnessRequest();
    error TooManyMinted();
    error WoundedAgentIdsPerRoundExceeded();

    /**
     * @notice Sets the mint period.
     * @dev If _mintStart is 0, the function call is just a mint end extension.
     * @param _mintStart The starting timestamp of the mint period.
     * @param _mintEnd The ending timestamp of the mint period.
     */
    function setMintPeriod(uint40 _mintStart, uint40 _mintEnd) external;

    /**
     * @notice Mints a number of agents.
     * @param to The recipient
     * @param quantity The number of agents to mint.
     */
    function premint(address to, uint256 quantity) external payable;

    /**
     * @notice Mints a number of agents.
     * @param quantity The number of agents to mint.
     */
    function mint(uint256 quantity) external payable;

    /**
     * @notice This function is here in case the game's invariant condition does not hold or the game is stuck.
     *         Only callable by the contract owner.
     */
    function emergencyWithdraw() external;

    /**
     * @notice Starts the game.
     * @dev Starting the game sets the current round ID to 1.
     */
    function startGame() external;

    /**
     * @notice Starts a new round.
     */
    function startNewRound() external;

    /**
     * @notice Close a round after randomness is fullfilled by Chainlink.
     * @param requestId The Chainlink request ID.
     */
    function closeRound(uint256 requestId) external;

    /**
     * @notice Claims the grand prize. Only callable by the winner.
     */
    function claimGrandPrize() external;

    /**
     * @notice Claims the secondary prizes. Only callable by top 50 agents.
     * @param agentId The agent ID.
     */
    function claimSecondaryPrizes(uint256 agentId) external;

    /**
     * @notice Escape from the game and take some rewards. 80% of the prize pool is distributed to
     *         the escaped agents and the rest to the secondary prize pool.
     * @param agentIds The agent IDs to escape.
     */
    function escape(uint256[] calldata agentIds) external;

    /**
     * @notice Submits a heal request for the specified agent IDs.
     * @param agentIds The agent IDs to heal.
     */
    function heal(uint256[] calldata agentIds) external;

    /**
     * @notice Get the agent at the specified index.
     * @return agent The agent at the specified index.
     */
    function getAgent(uint256 index) external view returns (Agent memory agent);

    /**
     * @notice Returns the cost to heal the specified agents
     * @dev The cost doubles for each time the agent is healed.
     * @param agentIds The agent IDs to heal.
     * @return cost The cost to heal the specified agents.
     */
    function costToHeal(uint256[] calldata agentIds) external view returns (uint256 cost);

    /**
     * @notice Returns the reward for escaping the game.
     * @param agentIds The agent IDs to escape.
     * @return reward The reward for escaping the game.
     */
    function escapeReward(uint256[] calldata agentIds) external view returns (uint256 reward);

    /**
     * @notice Returns the total number of agents alive.
     */
    function agentsAlive() external view returns (uint256);

    /**
     * @notice Returns the index of a specific agent ID inside the agents mapping.
     * @param agentId The agent ID.
     * @return index The index of the agent ID.
     */
    function agentIndex(uint256 agentId) external view returns (uint256 index);

    /**
     * @notice Returns a specific round's information.
     * @param roundId The round ID.
     * @return woundedAgentIds The agent IDs of the wounded agents in the specified round.
     * @return healingAgentIds The agent IDs of the healing agents in the specified round.
     */
    function getRoundInfo(
        uint256 roundId
    ) external view returns (uint256[] memory woundedAgentIds, uint256[] memory healingAgentIds);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title QuoterV2 Interface
/// @notice Supports quoting the calculated amounts from exact input or exact output swaps.
/// @notice For each pool also tells you the number of initialized ticks crossed and the sqrt price of the pool after the swap.
/// @dev These functions are not marked view because they rely on calling non-view functions and reverting
/// to compute the result. They are also not gas efficient and should not be called on-chain.
interface IQuoterV2 {
    struct QuoteExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amount;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Returns the amount in required to receive the given exact output amount but for a swap of a single pool
    /// @param params The params for the quote, encoded as `QuoteExactOutputSingleParams`
    /// tokenIn The token being swapped in
    /// tokenOut The token being swapped out
    /// fee The fee of the token pool to consider for the pair
    /// amountOut The desired output amount
    /// sqrtPriceLimitX96 The price limit of the pool that cannot be exceeded by the swap
    /// @return amountIn The amount required as the input for the swap in order to receive `amountOut`
    /// @return sqrtPriceX96After The sqrt price of the pool after the swap
    /// @return initializedTicksCrossed The number of initialized ticks that the swap crossed
    /// @return gasEstimate The estimate of the gas that the swap consumes
    function quoteExactOutputSingle(
        QuoteExactOutputSingleParams memory params
    )
        external
        returns (uint256 amountIn, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface IV3SwapRouter {
    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// that may remain in the router after the swap.
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    /// @notice Refunds any ETH balance held by this contract to the `msg.sender`
    /// @dev Useful for bundling with mint or increase liquidity that uses ether, or exact output swaps
    /// that use ether for the input amount
    function refundETH() external payable;
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
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address dst, uint256 wad) external returns (bool);

    function withdraw(uint256 wad) external;
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
pragma solidity 0.8.20;

enum TokenType {
    ERC20,
    ERC721,
    ERC1155
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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