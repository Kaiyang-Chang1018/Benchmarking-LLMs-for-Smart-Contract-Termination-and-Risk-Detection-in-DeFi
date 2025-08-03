// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;
pragma abicoder v2;

import {IExecutorWithTimelock} from './IExecutorWithTimelock.sol';

interface IAaveGovernanceV2 {
  enum ProposalState {Pending, Canceled, Active, Failed, Succeeded, Queued, Expired, Executed}

  struct Vote {
    bool support;
    uint248 votingPower;
  }

  struct Proposal {
    uint256 id;
    address creator;
    IExecutorWithTimelock executor;
    address[] targets;
    uint256[] values;
    string[] signatures;
    bytes[] calldatas;
    bool[] withDelegatecalls;
    uint256 startBlock;
    uint256 endBlock;
    uint256 executionTime;
    uint256 forVotes;
    uint256 againstVotes;
    bool executed;
    bool canceled;
    address strategy;
    bytes32 ipfsHash;
    mapping(address => Vote) votes;
  }

  struct ProposalWithoutVotes {
    uint256 id;
    address creator;
    IExecutorWithTimelock executor;
    address[] targets;
    uint256[] values;
    string[] signatures;
    bytes[] calldatas;
    bool[] withDelegatecalls;
    uint256 startBlock;
    uint256 endBlock;
    uint256 executionTime;
    uint256 forVotes;
    uint256 againstVotes;
    bool executed;
    bool canceled;
    address strategy;
    bytes32 ipfsHash;
  }

  /**
   * @dev emitted when a new proposal is created
   * @param id Id of the proposal
   * @param creator address of the creator
   * @param executor The ExecutorWithTimelock contract that will execute the proposal
   * @param targets list of contracts called by proposal's associated transactions
   * @param values list of value in wei for each propoposal's associated transaction
   * @param signatures list of function signatures (can be empty) to be used when created the callData
   * @param calldatas list of calldatas: if associated signature empty, calldata ready, else calldata is arguments
   * @param withDelegatecalls boolean, true = transaction delegatecalls the taget, else calls the target
   * @param startBlock block number when vote starts
   * @param endBlock block number when vote ends
   * @param strategy address of the governanceStrategy contract
   * @param ipfsHash IPFS hash of the proposal
   **/
  event ProposalCreated(
    uint256 id,
    address indexed creator,
    IExecutorWithTimelock indexed executor,
    address[] targets,
    uint256[] values,
    string[] signatures,
    bytes[] calldatas,
    bool[] withDelegatecalls,
    uint256 startBlock,
    uint256 endBlock,
    address strategy,
    bytes32 ipfsHash
  );

  /**
   * @dev emitted when a proposal is canceled
   * @param id Id of the proposal
   **/
  event ProposalCanceled(uint256 id);

  /**
   * @dev emitted when a proposal is queued
   * @param id Id of the proposal
   * @param executionTime time when proposal underlying transactions can be executed
   * @param initiatorQueueing address of the initiator of the queuing transaction
   **/
  event ProposalQueued(uint256 id, uint256 executionTime, address indexed initiatorQueueing);
  /**
   * @dev emitted when a proposal is executed
   * @param id Id of the proposal
   * @param initiatorExecution address of the initiator of the execution transaction
   **/
  event ProposalExecuted(uint256 id, address indexed initiatorExecution);
  /**
   * @dev emitted when a vote is registered
   * @param id Id of the proposal
   * @param voter address of the voter
   * @param support boolean, true = vote for, false = vote against
   * @param votingPower Power of the voter/vote
   **/
  event VoteEmitted(uint256 id, address indexed voter, bool support, uint256 votingPower);

  event GovernanceStrategyChanged(address indexed newStrategy, address indexed initiatorChange);

  event VotingDelayChanged(uint256 newVotingDelay, address indexed initiatorChange);

  event ExecutorAuthorized(address executor);

  event ExecutorUnauthorized(address executor);

  /**
   * @dev Creates a Proposal (needs Proposition Power of creator > Threshold)
   * @param executor The ExecutorWithTimelock contract that will execute the proposal
   * @param targets list of contracts called by proposal's associated transactions
   * @param values list of value in wei for each propoposal's associated transaction
   * @param signatures list of function signatures (can be empty) to be used when created the callData
   * @param calldatas list of calldatas: if associated signature empty, calldata ready, else calldata is arguments
   * @param withDelegatecalls if true, transaction delegatecalls the taget, else calls the target
   * @param ipfsHash IPFS hash of the proposal
   **/
  function create(
    IExecutorWithTimelock executor,
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory calldatas,
    bool[] memory withDelegatecalls,
    bytes32 ipfsHash
  ) external returns (uint256);

  /**
   * @dev Cancels a Proposal,
   * either at anytime by guardian
   * or when proposal is Pending/Active and threshold no longer reached
   * @param proposalId id of the proposal
   **/
  function cancel(uint256 proposalId) external;

  /**
   * @dev Queue the proposal (If Proposal Succeeded)
   * @param proposalId id of the proposal to queue
   **/
  function queue(uint256 proposalId) external;

  /**
   * @dev Execute the proposal (If Proposal Queued)
   * @param proposalId id of the proposal to execute
   **/
  function execute(uint256 proposalId) external payable;

  /**
   * @dev Function allowing msg.sender to vote for/against a proposal
   * @param proposalId id of the proposal
   * @param support boolean, true = vote for, false = vote against
   **/
  function submitVote(uint256 proposalId, bool support) external;

  /**
   * @dev Function to register the vote of user that has voted offchain via signature
   * @param proposalId id of the proposal
   * @param support boolean, true = vote for, false = vote against
   * @param v v part of the voter signature
   * @param r r part of the voter signature
   * @param s s part of the voter signature
   **/
  function submitVoteBySignature(
    uint256 proposalId,
    bool support,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  /**
   * @dev Set new GovernanceStrategy
   * Note: owner should be a timelocked executor, so needs to make a proposal
   * @param governanceStrategy new Address of the GovernanceStrategy contract
   **/
  function setGovernanceStrategy(address governanceStrategy) external;

  /**
   * @dev Set new Voting Delay (delay before a newly created proposal can be voted on)
   * Note: owner should be a timelocked executor, so needs to make a proposal
   * @param votingDelay new voting delay in seconds
   **/
  function setVotingDelay(uint256 votingDelay) external;

  /**
   * @dev Add new addresses to the list of authorized executors
   * @param executors list of new addresses to be authorized executors
   **/
  function authorizeExecutors(address[] memory executors) external;

  /**
   * @dev Remove addresses to the list of authorized executors
   * @param executors list of addresses to be removed as authorized executors
   **/
  function unauthorizeExecutors(address[] memory executors) external;

  /**
   * @dev Let the guardian abdicate from its priviledged rights
   **/
  function __abdicate() external;

  /**
   * @dev Getter of the current GovernanceStrategy address
   * @return The address of the current GovernanceStrategy contracts
   **/
  function getGovernanceStrategy() external view returns (address);

  /**
   * @dev Getter of the current Voting Delay (delay before a created proposal can be voted on)
   * Different from the voting duration
   * @return The voting delay in seconds
   **/
  function getVotingDelay() external view returns (uint256);

  /**
   * @dev Returns whether an address is an authorized executor
   * @param executor address to evaluate as authorized executor
   * @return true if authorized
   **/
  function isExecutorAuthorized(address executor) external view returns (bool);

  /**
   * @dev Getter the address of the guardian, that can mainly cancel proposals
   * @return The address of the guardian
   **/
  function getGuardian() external view returns (address);

  /**
   * @dev Getter of the proposal count (the current number of proposals ever created)
   * @return the proposal count
   **/
  function getProposalsCount() external view returns (uint256);

  /**
   * @dev Getter of a proposal by id
   * @param proposalId id of the proposal to get
   * @return the proposal as ProposalWithoutVotes memory object
   **/
  function getProposalById(uint256 proposalId) external view returns (ProposalWithoutVotes memory);

  /**
   * @dev Getter of the Vote of a voter about a proposal
   * Note: Vote is a struct: ({bool support, uint248 votingPower})
   * @param proposalId id of the proposal
   * @param voter address of the voter
   * @return The associated Vote memory object
   **/
  function getVoteOnProposal(uint256 proposalId, address voter) external view returns (Vote memory);

  /**
   * @dev Get the current state of a proposal
   * @param proposalId id of the proposal
   * @return The current state if the proposal
   **/
  function getProposalState(uint256 proposalId) external view returns (ProposalState);
}
// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;
pragma abicoder v2;

import {IAaveGovernanceV2} from './IAaveGovernanceV2.sol';

interface IExecutorWithTimelock {
  /**
   * @dev emitted when a new pending admin is set
   * @param newPendingAdmin address of the new pending admin
   **/
  event NewPendingAdmin(address newPendingAdmin);

  /**
   * @dev emitted when a new admin is set
   * @param newAdmin address of the new admin
   **/
  event NewAdmin(address newAdmin);

  /**
   * @dev emitted when a new delay (between queueing and execution) is set
   * @param delay new delay
   **/
  event NewDelay(uint256 delay);

  /**
   * @dev emitted when a new (trans)action is Queued.
   * @param actionHash hash of the action
   * @param target address of the targeted contract
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   **/
  event QueuedAction(
    bytes32 actionHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 executionTime,
    bool withDelegatecall
  );

  /**
   * @dev emitted when an action is Cancelled
   * @param actionHash hash of the action
   * @param target address of the targeted contract
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   **/
  event CancelledAction(
    bytes32 actionHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 executionTime,
    bool withDelegatecall
  );

  /**
   * @dev emitted when an action is Cancelled
   * @param actionHash hash of the action
   * @param target address of the targeted contract
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   * @param resultData the actual callData used on the target
   **/
  event ExecutedAction(
    bytes32 actionHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 executionTime,
    bool withDelegatecall,
    bytes resultData
  );
  /**
   * @dev Getter of the current admin address (should be governance)
   * @return The address of the current admin 
   **/
  function getAdmin() external view returns (address);
  /**
   * @dev Getter of the current pending admin address
   * @return The address of the pending admin 
   **/
  function getPendingAdmin() external view returns (address);
  /**
   * @dev Getter of the delay between queuing and execution
   * @return The delay in seconds
   **/
  function getDelay() external view returns (uint256);
  /**
   * @dev Returns whether an action (via actionHash) is queued
   * @param actionHash hash of the action to be checked
   * keccak256(abi.encode(target, value, signature, data, executionTime, withDelegatecall))
   * @return true if underlying action of actionHash is queued
   **/
  function isActionQueued(bytes32 actionHash) external view returns (bool);
  /**
   * @dev Checks whether a proposal is over its grace period 
   * @param governance Governance contract
   * @param proposalId Id of the proposal against which to test
   * @return true of proposal is over grace period
   **/
  function isProposalOverGracePeriod(IAaveGovernanceV2 governance, uint256 proposalId)
    external
    view
    returns (bool);
  /**
   * @dev Getter of grace period constant
   * @return grace period in seconds
   **/
  function GRACE_PERIOD() external view returns (uint256);
  /**
   * @dev Getter of minimum delay constant
   * @return minimum delay in seconds
   **/
  function MINIMUM_DELAY() external view returns (uint256);
  /**
   * @dev Getter of maximum delay constant
   * @return maximum delay in seconds
   **/
  function MAXIMUM_DELAY() external view returns (uint256);
  /**
   * @dev Function, called by Governance, that queue a transaction, returns action hash
   * @param target smart contract target
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   **/
  function queueTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) external returns (bytes32);
  /**
   * @dev Function, called by Governance, that cancels a transaction, returns the callData executed
   * @param target smart contract target
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   **/
  function executeTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) external payable returns (bytes memory);
  /**
   * @dev Function, called by Governance, that cancels a transaction, returns action hash
   * @param target smart contract target
   * @param value wei value of the transaction
   * @param signature function signature of the transaction
   * @param data function arguments of the transaction or callData if signature empty
   * @param executionTime time at which to execute the transaction
   * @param withDelegatecall boolean, true = transaction delegatecalls the target, else calls the target
   **/
  function cancelTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) external returns (bytes32);
}
// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;
pragma abicoder v2;

interface IGovernancePowerDelegationToken {
  enum DelegationType {VOTING_POWER, PROPOSITION_POWER}

  /**
   * @dev returns the delegatee of an user
   * @param delegator the address of the delegator
   **/
  function getDelegateeByType(address delegator, DelegationType delegationType)
    external
    view
    virtual
    returns (address);

  /**
   * @dev returns the current delegated power of a user. The current power is the
   * power delegated at the time of the last snapshot
   * @param user the user
   **/
  function getPowerCurrent(address user, DelegationType delegationType)
    external
    view
    virtual
    returns (uint256);

  /**
   * @dev get the power of a user at a specified block
   * @param user address of the user
   * @param blockNumber block number at which to get power
   * @param delegationType delegation type (propose/vote)
   **/
  function getPowerAtBlock(
    address user,
    uint256 blockNumber,
    DelegationType delegationType
  ) external view returns (uint256);

  /**
   * @dev Delegates power from signatory to `delegatee`
   * @param delegatee The address to delegate votes to
   * @param delegationType the type of delegation (VOTING_POWER, PROPOSITION_POWER)
   * @param nonce The contract state required to match the signature
   * @param expiry The time at which to expire the signature
   * @param v The recovery byte of the signature
   * @param r Half of the ECDSA signature pair
   * @param s Half of the ECDSA signature pair
   **/
  function delegateByTypeBySig(
    address delegatee,
    DelegationType delegationType,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  /**
   * @dev Delegates power from signatory to `delegatee`
   * @param delegatee The address to delegate votes to
   * @param nonce The contract state required to match the signature
   * @param expiry The time at which to expire the signature
   * @param v The recovery byte of the signature
   * @param r Half of the ECDSA signature pair
   * @param s Half of the ECDSA signature pair
   **/
  function delegateBySig(
    address delegatee,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
}
// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;
pragma abicoder v2;

interface IGovernanceStrategy {
  /**
   * @dev Returns the Proposition Power of a user at a specific block number.
   * @param user Address of the user.
   * @param blockNumber Blocknumber at which to fetch Proposition Power
   * @return Power number
   **/
  function getPropositionPowerAt(address user, uint256 blockNumber) external view returns (uint256);
  /**
   * @dev Returns the total supply of Outstanding Proposition Tokens 
   * @param blockNumber Blocknumber at which to evaluate
   * @return total supply at blockNumber
   **/
  function getTotalPropositionSupplyAt(uint256 blockNumber) external view returns (uint256);
  /**
   * @dev Returns the total supply of Outstanding Voting Tokens 
   * @param blockNumber Blocknumber at which to evaluate
   * @return total supply at blockNumber
   **/
  function getTotalVotingSupplyAt(uint256 blockNumber) external view returns (uint256);
  /**
   * @dev Returns the Vote Power of a user at a specific block number.
   * @param user Address of the user.
   * @param blockNumber Blocknumber at which to fetch Vote Power
   * @return Vote number
   **/
  function getVotingPowerAt(address user, uint256 blockNumber) external view returns (uint256);
}
// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;
pragma abicoder v2;

import {IAaveGovernanceV2} from './IAaveGovernanceV2.sol';

interface IProposalValidator {

  /**
   * @dev Called to validate a proposal (e.g when creating new proposal in Governance)
   * @param governance Governance Contract
   * @param user Address of the proposal creator
   * @param blockNumber Block Number against which to make the test (e.g proposal creation block -1).
   * @return boolean, true if can be created
   **/
  function validateCreatorOfProposal(
    IAaveGovernanceV2 governance,
    address user,
    uint256 blockNumber
  ) external view returns (bool);

  /**
   * @dev Called to validate the cancellation of a proposal
   * @param governance Governance Contract
   * @param user Address of the proposal creator
   * @param blockNumber Block Number against which to make the test (e.g proposal creation block -1).
   * @return boolean, true if can be cancelled
   **/
  function validateProposalCancellation(
    IAaveGovernanceV2 governance,
    address user,
    uint256 blockNumber
  ) external view returns (bool);

  /**
   * @dev Returns whether a user has enough Proposition Power to make a proposal.
   * @param governance Governance Contract
   * @param user Address of the user to be challenged.
   * @param blockNumber Block Number against which to make the challenge.
   * @return true if user has enough power
   **/
  function isPropositionPowerEnough(
    IAaveGovernanceV2 governance,
    address user,
    uint256 blockNumber
  ) external view returns (bool);

  /**
   * @dev Returns the minimum Proposition Power needed to create a proposition.
   * @param governance Governance Contract
   * @param blockNumber Blocknumber at which to evaluate
   * @return minimum Proposition Power needed
   **/
  function getMinimumPropositionPowerNeeded(IAaveGovernanceV2 governance, uint256 blockNumber)
    external
    view
    returns (uint256);

  /**
   * @dev Returns whether a proposal passed or not
   * @param governance Governance Contract
   * @param proposalId Id of the proposal to set
   * @return true if proposal passed
   **/
  function isProposalPassed(IAaveGovernanceV2 governance, uint256 proposalId)
    external
    view
    returns (bool);

  /**
   * @dev Check whether a proposal has reached quorum, ie has enough FOR-voting-power
   * Here quorum is not to understand as number of votes reached, but number of for-votes reached
   * @param governance Governance Contract
   * @param proposalId Id of the proposal to verify
   * @return voting power needed for a proposal to pass
   **/
  function isQuorumValid(IAaveGovernanceV2 governance, uint256 proposalId)
    external
    view
    returns (bool);

  /**
   * @dev Check whether a proposal has enough extra FOR-votes than AGAINST-votes
   * FOR VOTES - AGAINST VOTES > VOTE_DIFFERENTIAL * voting supply
   * @param governance Governance Contract
   * @param proposalId Id of the proposal to verify
   * @return true if enough For-Votes
   **/
  function isVoteDifferentialValid(IAaveGovernanceV2 governance, uint256 proposalId)
    external
    view
    returns (bool);

  /**
   * @dev Calculates the minimum amount of Voting Power needed for a proposal to Pass
   * @param votingSupply Total number of oustanding voting tokens
   * @return voting power needed for a proposal to pass
   **/
  function getMinimumVotingPowerNeeded(uint256 votingSupply) external view returns (uint256);

  /**
   * @dev Get proposition threshold constant value
   * @return the proposition threshold value (100 <=> 1%)
   **/
  function PROPOSITION_THRESHOLD() external view returns (uint256);

  /**
   * @dev Get voting duration constant value
   * @return the voting duration value in seconds
   **/
  function VOTING_DURATION() external view returns (uint256);

  /**
   * @dev Get the vote differential threshold constant value
   * to compare with % of for votes/total supply - % of against votes/total supply
   * @return the vote differential threshold value (100 <=> 1%)
   **/
  function VOTE_DIFFERENTIAL() external view returns (uint256);

  /**
   * @dev Get quorum threshold constant value
   * to compare with % of for votes/total supply
   * @return the quorum threshold value (100 <=> 1%)
   **/
  function MINIMUM_QUORUM() external view returns (uint256);

  /**
   * @dev precision helper: 100% = 10000
   * @return one hundred percents with our chosen precision
   **/
  function ONE_HUNDRED_WITH_PRECISION() external view returns (uint256);
}
// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;
pragma abicoder v2;

import {IAaveGovernanceV2} from '../interfaces/IAaveGovernanceV2.sol';
import {IProposalValidator} from '../interfaces/IProposalValidator.sol';
import {IExecutorWithTimelock} from '../interfaces/IExecutorWithTimelock.sol';
import {IGovernanceStrategy} from '../interfaces/IGovernanceStrategy.sol';
import {IGovernancePowerDelegationToken} from '../interfaces/IGovernancePowerDelegationToken.sol';
import {IGovernanceV2Helper} from './interfaces/IGovernanceV2Helper.sol';
import {SafeMath} from '../dependencies/open-zeppelin/SafeMath.sol';

/**
 * @title Governance V2 helper contract
 * @dev Helper contract to fetch data from the AaveGovernanceV2 contract and batch write calls
 * - List of proposals with state
 * - List of votes per proposal and voters
 * - Batch token delegations calls
 * @author Aave
 **/
contract GovernanceV2Helper is IGovernanceV2Helper {
  using SafeMath for uint256;
  uint256 public constant ONE_HUNDRED_WITH_PRECISION = 10000;

  function getProposal(uint256 id, IAaveGovernanceV2 governance)
    public
    view
    override
    returns (ProposalStats memory proposalStats)
  {
    IAaveGovernanceV2.ProposalWithoutVotes memory proposal = governance.getProposalById(id);
    uint256 votingSupply = IGovernanceStrategy(proposal.strategy).getTotalVotingSupplyAt(
      proposal.startBlock
    );
    return
      ProposalStats({
        totalVotingSupply: votingSupply,
        minimumQuorum: IProposalValidator(address(proposal.executor)).MINIMUM_QUORUM(),
        minimumDiff: IProposalValidator(address(proposal.executor)).VOTE_DIFFERENTIAL(),
        executionTimeWithGracePeriod: proposal.executionTime > 0
          ? IExecutorWithTimelock(proposal.executor).GRACE_PERIOD().add(proposal.executionTime)
          : proposal.executionTime,
        proposalCreated: proposal.startBlock.sub(governance.getVotingDelay()),
        id: proposal.id,
        creator: proposal.creator,
        executor: proposal.executor,
        targets: proposal.targets,
        values: proposal.values,
        signatures: proposal.signatures,
        calldatas: proposal.calldatas,
        withDelegatecalls: proposal.withDelegatecalls,
        startBlock: proposal.startBlock,
        endBlock: proposal.endBlock,
        executionTime: proposal.executionTime,
        forVotes: proposal.forVotes,
        againstVotes: proposal.againstVotes,
        executed: proposal.executed,
        canceled: proposal.canceled,
        strategy: proposal.strategy,
        ipfsHash: proposal.ipfsHash,
        proposalState: governance.getProposalState(id)
      });
  }

  function getProposals(
    uint256 skip,
    uint256 limit,
    IAaveGovernanceV2 governance
  ) external view override returns (ProposalStats[] memory proposalsStats) {
    uint256 count = governance.getProposalsCount().sub(skip);
    uint256 maxLimit = limit > count ? count : limit;

    proposalsStats = new ProposalStats[](maxLimit);

    for (uint256 i = 0; i < maxLimit; i++) {
      proposalsStats[i] = getProposal(i.add(skip), governance);
    }

    return proposalsStats;
  }

  function getTokensPower(address user, address[] memory tokens)
    external
    view
    override
    returns (Power[] memory power)
  {
    power = new Power[](tokens.length);
    for (uint256 i = 0; i < tokens.length; i++) {
      IGovernancePowerDelegationToken delegation = IGovernancePowerDelegationToken(tokens[i]);
      uint256 currentVotingPower = delegation.getPowerCurrent(
        user,
        IGovernancePowerDelegationToken.DelegationType.VOTING_POWER
      );
      uint256 currentPropositionPower = delegation.getPowerCurrent(
        user,
        IGovernancePowerDelegationToken.DelegationType.PROPOSITION_POWER
      );
      address delegatedAddressVotingPower = delegation.getDelegateeByType(
        user,
        IGovernancePowerDelegationToken.DelegationType.VOTING_POWER
      );
      address delegatedAddressPropositionPower = delegation.getDelegateeByType(
        user,
        IGovernancePowerDelegationToken.DelegationType.PROPOSITION_POWER
      );

      power[i] = Power(
        currentVotingPower,
        delegatedAddressVotingPower,
        currentPropositionPower,
        delegatedAddressPropositionPower
      );
    }

    return power;
  }

  function delegateTokensBySig(address[] calldata tokens, DelegateBySigParams[] calldata params)
    external
    override
  {
    require(tokens.length == params.length, 'INCONSISTENT_PARAMS_LENGTH');
    for (uint256 i = 0; i < tokens.length; i++) {
      IGovernancePowerDelegationToken(tokens[i]).delegateBySig(
        params[i].delegatee,
        params[i].nonce,
        params[i].expiry,
        params[i].v,
        params[i].r,
        params[i].s
      );
    }
  }

  function delegateTokensByTypeBySig(
    address[] calldata tokens,
    DelegateByTypeBySigParams[] calldata params
  ) external override {
    require(tokens.length == params.length, 'INCONSISTENT_PARAMS_LENGTH');
    for (uint256 i = 0; i < tokens.length; i++) {
      IGovernancePowerDelegationToken(tokens[i]).delegateByTypeBySig(
        params[i].delegatee,
        params[i].delegationType,
        params[i].nonce,
        params[i].expiry,
        params[i].v,
        params[i].r,
        params[i].s
      );
    }
  }
}
// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;
pragma abicoder v2;

import {IAaveGovernanceV2} from '../../interfaces/IAaveGovernanceV2.sol';
import {IExecutorWithTimelock} from '../../interfaces/IExecutorWithTimelock.sol';
import {
  IGovernancePowerDelegationToken
} from '../../interfaces/IGovernancePowerDelegationToken.sol';

interface IGovernanceV2Helper {
  struct ProposalStats {
    uint256 totalVotingSupply;
    uint256 minimumQuorum;
    uint256 minimumDiff;
    uint256 executionTimeWithGracePeriod;
    uint256 proposalCreated;
    uint256 id;
    address creator;
    IExecutorWithTimelock executor;
    address[] targets;
    uint256[] values;
    string[] signatures;
    bytes[] calldatas;
    bool[] withDelegatecalls;
    uint256 startBlock;
    uint256 endBlock;
    uint256 executionTime;
    uint256 forVotes;
    uint256 againstVotes;
    bool executed;
    bool canceled;
    address strategy;
    bytes32 ipfsHash;
    IAaveGovernanceV2.ProposalState proposalState;
  }

  struct Power {
    uint256 votingPower;
    address delegatedAddressVotingPower;
    uint256 propositionPower;
    address delegatedAddressPropositionPower;
  }

  struct DelegateByTypeBySigParams {
    address delegatee;
    IGovernancePowerDelegationToken.DelegationType delegationType;
    uint256 nonce;
    uint256 expiry;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  struct DelegateBySigParams {
    address delegatee;
    uint256 nonce;
    uint256 expiry;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  function getProposals(
    uint256 skip,
    uint256 limit,
    IAaveGovernanceV2 governance
  ) external view virtual returns (ProposalStats[] memory proposalsStats);

  function getProposal(uint256 id, IAaveGovernanceV2 governance)
    external
    view
    virtual
    returns (ProposalStats memory proposalStats);

  function getTokensPower(address user, address[] memory tokens)
    external
    view
    virtual
    returns (Power[] memory power);

  function delegateTokensBySig(address[] calldata tokens, DelegateBySigParams[] calldata params)
    external;

  function delegateTokensByTypeBySig(
    address[] calldata tokens,
    DelegateByTypeBySigParams[] calldata params
  ) external;
}