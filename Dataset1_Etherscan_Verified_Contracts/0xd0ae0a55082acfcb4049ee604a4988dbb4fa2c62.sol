// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./oz/interfaces/IERC20.sol";
import "./oz/libraries/SafeERC20.sol";
import "./oz/utils/ReentrancyGuard.sol";
import "./oz/utils/Pausable.sol";
import "./interfaces/IGaugeController.sol";
import "./utils/Owner.sol";

/** @title Warden Covenant */
/// @author Paladin
/*
    Contract to create custom deals for veToken votes on Gauge Controller
*/
contract Covenant is Owner, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Storage

    /** @notice Seconds in a Week */
    uint256 private constant WEEK = 604800;
    /** @notice 1e18 scale */
    uint256 private constant UNIT = 1e18;
    /** @notice Max BPS */
    uint256 private constant MAX_BPS = 10000;

    /** @notice Address of the Curve Gauge Controller */
    address public immutable GAUGE_CONTROLLER;

    address public chest;
    uint256 public feeRatio = 200;

    mapping(address => bool) public allowedCreators;

    uint256 public nextID;
    mapping(uint256 => CovenantParams) public covenants;
    // ID => period => bias
    mapping(uint256 => mapping(uint256 => uint256)) public sumBiases;
    // ID => period => amount
    mapping(uint256 => mapping(uint256 => uint256)) public distributedAmount;
    // ID => period => amount
    mapping(uint256 => mapping(uint256 => uint256)) public claimedAmount;
    // ID => period => bool
    mapping(uint256 => mapping(uint256 => bool)) public distributed;
    // ID => period => bool
    mapping(uint256 => mapping(uint256 => bool)) public clawbacked;
    // ID => amount
    mapping(uint256 => uint256) public withdrawableAmount;
    // ID => listed voters
    mapping(uint256 => address[]) public allowedVoters;
    // voter => ID => bool
    mapping(address => mapping(uint256 => bool)) public isAllowedVoter;

    // voter => token => amount
    mapping(address => mapping(address => uint256)) public accruedAmount;
    // voter => ID -> period => bool
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public accrued;


    // Structs

    struct CovenantParams {
        address gauge;
        address token;
        uint256 targetBias;
        uint256 rewardPerVote;
        address creator;
        uint48 duration;
        uint48 firstPeriod;
    }


    // Events

    event CovenantCreated(uint256 id, address indexed creator, address indexed gauge);

    event UpdatedRewards(uint256 indexed id, uint256 indexed period);
    event WithdrewRewards(uint256 indexed id, uint256 amount);
    event ClawedBackRewards(uint256 indexed id, uint256 period, uint256 amount);

    event Accrued(uint256 indexed id, address indexed voter, uint256 indexed period);
    event Claimed(uint256 indexed id, address indexed voter, uint256 amount);

    event AddedVoter(uint256 indexed id, address indexed voter);
    event RemovedVoter(uint256 indexed id, address indexed voter);

    event SetCreator(address indexed creator, bool allowed);

    event ChestUpdated(address oldChest, address newChest);
    event FeeRatioUpdated(uint256 oldRatio, uint256 newRatio);


    // Errors

    error NotAllowed();
    error AlreadyListed();
    error NotListed();
    error InvalidPeriod();
    error InvalidGauge();
    error IncorrectDuration();
    error NullAmount();
    error NumberExceed48Bits();
    error InvalidParameter();
    error EmptyList();


    // Constructor
    constructor(address _gaugeController, address _chest) {
        if(_gaugeController == address(0) || _chest == address(0)) revert AddressZero();

        GAUGE_CONTROLLER = _gaugeController;
        chest = _chest;
    }


    // View methods

    function getCurrentPeriodEndTimestamp() public view returns(uint256) {
        // timestamp of the end of current voting period
        return ((block.timestamp + WEEK) / WEEK) * WEEK;
    }

    function getVoterList(uint256 id) external view returns(address[] memory){
        return allowedVoters[id];
    }

    function getCovenantPeriods(uint256 id) external view returns(uint256[] memory){
        CovenantParams memory _covenant = covenants[id];
        uint256[] memory periods = new uint256[](_covenant.duration);
        for(uint256 i; i < _covenant.duration;){
            periods[i] = _covenant.firstPeriod + (i * WEEK);

            unchecked{ ++i; }
        }
        return periods;
    }   


    // State-changing methods

    function createCovenant(
        address gauge,
        address rewardToken,
        uint256 firstPeriod,
        uint256 duration,
        uint256 targetBias,
        uint256 totalRewardAmount,
        address[] calldata voters
    ) external nonReentrant whenNotPaused returns(uint256 id) {
        // Check all parameters
        if(!allowedCreators[msg.sender]) revert NotAllowed();
        if(gauge == address(0) || rewardToken == address(0)) revert AddressZero();
        if(IGaugeController(GAUGE_CONTROLLER).gauge_types(gauge) < 0) revert InvalidGauge();
        if(duration == 0) revert IncorrectDuration();
        if(totalRewardAmount == 0 || targetBias == 0 || firstPeriod == 0) revert NullAmount();
        if(voters.length == 0) revert EmptyList();

        firstPeriod = (firstPeriod / WEEK) * WEEK;
        if(firstPeriod < block.timestamp) revert InvalidPeriod();

        IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), totalRewardAmount);

        uint256 feeAmount = (totalRewardAmount * feeRatio) / MAX_BPS;
        totalRewardAmount -= feeAmount;

        IERC20(rewardToken).safeTransfer(chest, feeAmount);

        uint256 rewardPerPeriod = totalRewardAmount / duration;
        uint256 rewardPerVote = (rewardPerPeriod * UNIT) / targetBias;

        id = nextID;
        nextID++;

        covenants[id] = CovenantParams({
            gauge: gauge,
            token: rewardToken,
            targetBias: targetBias,
            rewardPerVote: rewardPerVote,
            creator: msg.sender,
            duration: uint48(duration),
            firstPeriod: uint48(firstPeriod)
        });

        _setVoters(id, voters);

        emit CovenantCreated(id, msg.sender, gauge);
    }

    function updatePeriodRewards(uint256 id, uint256 period) external nonReentrant whenNotPaused {
        _updatePeriodRewards(id, period);
    }

    function updateAllPeriodRewards(uint256 id) external nonReentrant whenNotPaused {
        CovenantParams memory _covenant = covenants[id];
        uint256 lastPeriod = _covenant.firstPeriod + ((_covenant.duration - 1) * WEEK);
        uint256 currentPeriod = getCurrentPeriodEndTimestamp();
        uint256 endUpdatePeriod = lastPeriod < currentPeriod ? lastPeriod : currentPeriod;
        
        uint256 periodIterator = _covenant.firstPeriod;

        while(periodIterator <= endUpdatePeriod){
            _updatePeriodRewards(id, periodIterator);
            periodIterator += WEEK;
        }
    }

    function withdrawUndistributed(uint256 id) external nonReentrant whenNotPaused {
        CovenantParams memory _covenant = covenants[id];
        if(_covenant.creator != msg.sender) revert NotAllowed();

        uint256 lastPeriod = _covenant.firstPeriod + ((_covenant.duration - 1) * WEEK);
        uint256 periodIterator = _covenant.firstPeriod;

        while(periodIterator <= lastPeriod){
            _clawbackRewards(id, periodIterator);
            periodIterator += WEEK;
        }

        uint256 amount = withdrawableAmount[id];
        withdrawableAmount[id] = 0;

        if(amount > 0) {
            IERC20(_covenant.token).safeTransfer(_covenant.creator, amount);
        }

        emit WithdrewRewards(id, amount);
    }

    function accrueVoterRewards(uint256 id, address voter) external nonReentrant whenNotPaused {
        if(!isAllowedVoter[voter][id]) revert NotListed();

        _accrueAllRewards(id, voter);
    }

    function claimRewards(uint256 id, address voter) external nonReentrant whenNotPaused returns(uint256 amount) {
        if(!isAllowedVoter[voter][id]) revert NotListed();

        _accrueAllRewards(id, voter);

        address token = covenants[id].token;

        amount = accruedAmount[voter][token];
        accruedAmount[voter][token] = 0;

        if(amount > 0) {
            IERC20(covenants[id].token).safeTransfer(voter, amount);
        }

        emit Claimed(id, voter, amount);
    }

    function addVoter(uint256 id, address voter) external nonReentrant whenNotPaused {
        if(voter == address(0)) revert AddressZero();
        if(covenants[id].creator != msg.sender) revert NotAllowed();
        if(isAllowedVoter[voter][id]) revert AlreadyListed();

        allowedVoters[id].push(voter);
        isAllowedVoter[voter][id] = true;

        emit AddedVoter(id, voter);
    }

    function removeVoter(uint256 id, address voter) external nonReentrant whenNotPaused {
        if(voter == address(0)) revert AddressZero();
        if(covenants[id].creator != msg.sender) revert NotAllowed();
        if(!isAllowedVoter[voter][id]) revert NotListed();

        address[] memory _list = allowedVoters[id];
        uint256 length = _list.length;
        if(length == 1) revert EmptyList();

        isAllowedVoter[voter][id] = false;

        for(uint256 i; i < length;){
            if(_list[i] == voter){
                if(i != length - 1){
                    allowedVoters[id][i] = _list[length - 1];
                }
                allowedVoters[id].pop();

                emit RemovedVoter(id, voter);

                return;
            }
            unchecked { ++i; }
        }
    }


    // Internal methods

    // Sum of all the voter biases
    function _getGaugeSumBias(uint256 id, address gauge, uint256 period) internal view returns(uint256 gaugeBias) {
        address[] memory _list = allowedVoters[id];
        uint256 length = _list.length;

        for(uint256 i; i < length;){
            (uint256 userBias,) = _getVoterBias(gauge, _list[i], period);

            gaugeBias += userBias;

            unchecked { ++i; }
        }
    }

    function _getVoterBias(
        address gauge,
        address voter,
        uint256 period
    ) internal view returns(uint256 userBias, uint256 lastUserVote) {
        IGaugeController gaugeController = IGaugeController(GAUGE_CONTROLLER);
        lastUserVote = gaugeController.last_user_vote(voter, gauge);
        IGaugeController.VotedSlope memory voteUserSlope = gaugeController.vote_user_slopes(voter, gauge);

        if(lastUserVote >= period) return (0,0);
        if(voteUserSlope.end <= period) return (0,0);
        if(voteUserSlope.slope == 0) return (0,0);

        userBias = voteUserSlope.slope * (voteUserSlope.end - period);
    }

    function _setVoters(uint256 id, address[] calldata voters) internal {
        uint256 length = voters.length;
        for(uint256 i = 0; i < length; i++) {
            if(isAllowedVoter[voters[i]][id]) revert AlreadyListed();

            allowedVoters[id].push(voters[i]);
            isAllowedVoter[voters[i]][id] = true;

            emit AddedVoter(id, voters[i]);
        }
    }

    function _updatePeriodRewards(uint256 id, uint256 period) internal {
        CovenantParams memory _covenant = covenants[id];
        uint256 lastPeriod = _covenant.firstPeriod + ((_covenant.duration - 1) * WEEK);
        if(period < _covenant.firstPeriod || period > lastPeriod) revert InvalidPeriod();
        if(distributed[id][period]) return;
        // We don't want to update rewards if the period is not over yet
        if(block.timestamp < period) return;

        IGaugeController(GAUGE_CONTROLLER).checkpoint_gauge(_covenant.gauge);

        uint256 periodSumBias = _getGaugeSumBias(id, _covenant.gauge, period);
        uint256 maxRewards = (_covenant.rewardPerVote * _covenant.targetBias) / UNIT;

        distributed[id][period] = true;

        if(periodSumBias >= _covenant.targetBias){
            distributedAmount[id][period] = maxRewards;
            sumBiases[id][period] = periodSumBias;
        } else {
            sumBiases[id][period] = periodSumBias;

            uint256 distributeAmount = (_covenant.rewardPerVote * periodSumBias) / UNIT;
            distributedAmount[id][period] = distributeAmount;
            withdrawableAmount[id] += maxRewards - distributeAmount;
        }

        emit UpdatedRewards(id, period);
    }

    function _accrueRewards(uint256 id, address voter, uint256 period) internal {
        if(accrued[voter][id][period]) return;
        // Do not accrue on non-distributed periods
        if(!distributed[id][period]) return;
        // Already clawbacked
        if(clawbacked[id][period]) return;

        uint256 gaugeSumBias = sumBiases[id][period];
        (uint256 voterBias, uint256 lastUserVote) = _getVoterBias(covenants[id].gauge, voter, period);

        accrued[voter][id][period] = true;

        if(gaugeSumBias != 0 && voterBias != 0 && lastUserVote < period) {
            // Get the share of the distributed rewards for this voter
            uint256 reward = (voterBias * distributedAmount[id][period]) / gaugeSumBias;
            accruedAmount[voter][covenants[id].token] += reward;

            claimedAmount[id][period] += reward;

            emit Accrued(id, voter, period);
        }
    }

    function _accrueAllRewards(uint256 id, address voter) internal {
        CovenantParams memory _covenant = covenants[id];
        uint256 lastPeriod = _covenant.firstPeriod + ((_covenant.duration - 1) * WEEK);
        uint256 periodIterator = _covenant.firstPeriod;

        while(periodIterator <= lastPeriod){
            _accrueRewards(id, voter, periodIterator);
            periodIterator += WEEK;
        }
    }

    function _clawbackRewards(uint256 id, uint256 period) internal {
        // Do not clawback on non-distributed periods
        if(!distributed[id][period]) return;
        // Do not clawback during the allowed distribution period
        if(block.timestamp <= period + WEEK) return;
        // Already clawbacked
        if(clawbacked[id][period]) return;

        clawbacked[id][period] = true;

        uint256 unclaimed = distributedAmount[id][period] - claimedAmount[id][period];
        withdrawableAmount[id] += unclaimed;

        emit ClawedBackRewards(id, period, unclaimed);
    }


    // Admin methods

    function setCreator(address creator, bool allowed) external onlyOwner {
        if(creator == address(0)) revert AddressZero();
        
        allowedCreators[creator] = allowed;

        emit SetCreator(creator, allowed);
    }

    function updateChest(address newChest) external onlyOwner {
        if(newChest == address(0)) revert AddressZero();
        address oldChest = chest;
        chest = newChest;

        emit ChestUpdated(oldChest, newChest);
    }

    function updateFeeRatio(uint256 newRatio) external onlyOwner {
        if(newRatio > 500) revert InvalidParameter();
        uint256 oldRatio = feeRatio;
        feeRatio = newRatio;

        emit FeeRatioUpdated(oldRatio, newRatio);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }


    // Maths

    function safe48(uint n) internal pure returns (uint48) {
        if(n > type(uint48).max) revert NumberExceed48Bits();
        return uint48(n);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/**
 * @dev Interface made for the Curve's GaugeController contract
 */
interface IGaugeController {

    struct VotedSlope {
        uint slope;
        uint power;
        uint end;
    }
    
    struct Point {
        uint bias;
        uint slope;
    }
    
    function vote_user_slopes(address, address) external view returns(VotedSlope memory);
    function last_user_vote(address, address) external view returns(uint);
    function points_weight(address, uint256) external view returns(Point memory);
    function checkpoint_gauge(address) external;
    function gauge_types(address _addr) external view returns(int128);
    
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _paused = false;
    }

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
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../oz/utils/Ownable.sol";

/** @title 2-step Ownership  */
/// @author Paladin
/*
    Extends OZ Ownable contract to add 2-step ownership transfer
*/

contract Owner is Ownable {

    address public pendingOwner;

    event NewPendingOwner(address indexed previousPendingOwner, address indexed newPendingOwner);

    error CallerNotPendingOwner();
    error CannotBeOwner();
    error AddressZero();

    function transferOwnership(address newOwner) public override virtual onlyOwner {
        if(newOwner == address(0)) revert AddressZero();
        if(newOwner == owner()) revert CannotBeOwner();
        address oldPendingOwner = pendingOwner;

        pendingOwner = newOwner;

        emit NewPendingOwner(oldPendingOwner, newOwner);
    }

    function acceptOwnership() public virtual {
        if(msg.sender != pendingOwner) revert CallerNotPendingOwner();
        address newOwner = pendingOwner;
        _transferOwnership(pendingOwner);
        pendingOwner = address(0);

        emit NewPendingOwner(newOwner, address(0));
    }

}