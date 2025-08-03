// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: contracts/CashVest.sol


pragma solidity ^0.8.20;


contract Vesting {
    IERC20 public token;
    address public owner;

    enum VestingScheduleType { Presale1, Presale2 }

    struct VestingSchedule {
        uint256 totalAmount;
        uint256 claimedAmount;
        uint256 startTime;
        uint256 duration;
    }

    // Mapping from beneficiary to vesting schedule type to VestingSchedule
    mapping(address => mapping(VestingScheduleType => VestingSchedule)) public vestingSchedules;

    event TokensClaimed(address indexed user, uint256 amount, VestingScheduleType vestingType);

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function addVestingSchedules(
        address[] calldata _beneficiaries,
        uint256[] calldata _amounts,
        uint256[] calldata _startTimes,
        uint256[] calldata _durations,
        VestingScheduleType[] calldata _vestingTypes
    ) external onlyOwner {
        require(_beneficiaries.length == _amounts.length, "Array length mismatch");
        require(_beneficiaries.length == _startTimes.length, "Array length mismatch");
        require(_beneficiaries.length == _durations.length, "Array length mismatch");
        require(_beneficiaries.length == _vestingTypes.length, "Array length mismatch");

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            address beneficiary = _beneficiaries[i];
            uint256 totalAmount = _amounts[i];
            uint256 startTime = _startTimes[i];
            uint256 duration = _durations[i];
            VestingScheduleType vestingType = _vestingTypes[i];

            require(vestingSchedules[beneficiary][vestingType].totalAmount == 0, "Vesting schedule already exists for this type");

            vestingSchedules[beneficiary][vestingType] = VestingSchedule({
                totalAmount: totalAmount,
                claimedAmount: 0,
                startTime: startTime,
                duration: duration
            });
        }
    }

    function claim(VestingScheduleType vestingType) external {
        VestingSchedule storage schedule = vestingSchedules[msg.sender][vestingType];
        require(schedule.totalAmount > 0, "No vesting schedule for this type");
        uint256 currentTime = block.timestamp;
        require(currentTime >= schedule.startTime, "Vesting period has not started yet");

        uint256 vestedAmount = _vestedAmount(schedule);
        uint256 claimableAmount = vestedAmount - schedule.claimedAmount;
        require(claimableAmount > 0, "No tokens available for claim");

        schedule.claimedAmount = vestedAmount;
        token.transfer(msg.sender, claimableAmount);

        emit TokensClaimed(msg.sender, claimableAmount, vestingType);
    }

    function _vestedAmount(VestingSchedule memory schedule) internal view returns (uint256) {
        uint256 currentTime = block.timestamp;
        if (currentTime >= schedule.startTime + schedule.duration) {
            return schedule.totalAmount;
        } else {
            return (schedule.totalAmount * (currentTime - schedule.startTime)) / schedule.duration;
        }
    }
}