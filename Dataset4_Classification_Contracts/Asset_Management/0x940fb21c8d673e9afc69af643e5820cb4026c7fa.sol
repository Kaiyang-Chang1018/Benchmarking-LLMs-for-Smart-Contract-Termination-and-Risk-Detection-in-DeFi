// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/*    
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│       _______         ______                      _                     │
│      |__   __|       |  ____|                    (_)                    │
│         | | __ ___  _| |__ __ _ _ __ _ __ ___     _ _ __   __ _         │
│         | |/ _` \ \/ /  __/ _` | '__| '_ ` _ \   | | '_ \ / _` |        │
│         | | (_| |>  <| | | (_| | |  | | | | | |  | | | | | (_| |        │
│         |_|\__,_/_/\_\_|  \__,_|_|  |_| |_| |_|(_)_|_| |_|\__, |        │
│                                                            __/ |        │
│                                                           |___/         │
│                                                                         │
│                               taxfarm.ing                               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
*/

import {IERC20} from "./utils/IERC20.sol";

contract TokenStaking {

    IERC20 public taxFarmingToken;


    uint public totalStaked; // total token staked
    uint public totalRewards; // total rewards received by the contract

    uint private accumulatedRewardsPerToken = 1; // act as a price entry for new staker, the delta between this variable entry and exit is the effective rewards per token
    uint private constant DECIMALS = 1e12; // floor precision protection decimals

    struct Stake {
        uint tokensStaked;
        uint accumulatedRewardsPerToken;
    }

    mapping (address => Stake) public stakersInfos;
    mapping (address => uint) public lastTx; // last tx block of stakers, used to avoid reentrancy and flashloans attacks

    event TokenStaked(address indexed user, uint amount, uint accumulatedRewardsPerToken);
    event TokenUnstaked(address indexed user, uint amount, uint accumulatedRewardsPerToken);

    constructor(address _taxFarmingToken) {

        taxFarmingToken = IERC20(_taxFarmingToken);
    }

    // prevent user to use any function again in this block
    modifier blockUser(address user) {
        require(lastTx[user] != block.number, "User blocked");
        lastTx[user] = block.number;
        _;
    }

    function stake(uint amount) external blockUser(msg.sender) {
        if (amount == 0) return;

        address user = msg.sender;
        if (stakersInfos[user].tokensStaked == 0) stakersInfos[user].accumulatedRewardsPerToken = accumulatedRewardsPerToken;
        else _claim(user);
        
        taxFarmingToken.transferFrom(user, address(this), amount);

        totalStaked += amount;
        stakersInfos[user].tokensStaked += amount;

        emit TokenStaked(user, amount, accumulatedRewardsPerToken);
    }

    function unstake(uint amount) external blockUser(msg.sender) {
        address user = msg.sender;

        if (amount == 0 || stakersInfos[user].tokensStaked == 0) return;
        _claim(user);

        require(stakersInfos[user].tokensStaked >= amount, "Not enough staked tokens");
        stakersInfos[user].tokensStaked -= amount;
        totalStaked -= amount;
            
        taxFarmingToken.transfer(user, amount);

        emit TokenUnstaked(user, amount, accumulatedRewardsPerToken);
    }

    function claim() external blockUser(msg.sender) {
        _claim(msg.sender);
    }

    function _claim(address user) private {
        uint rewards = getUserRewards(user);

        stakersInfos[user].accumulatedRewardsPerToken = accumulatedRewardsPerToken;

        if (rewards == 0) return;
        (bool success, ) = payable(user).call{value: rewards}("");
        require(success, "Unable to claim rewards");
    }

    function getUserRewards(address user) public view returns (uint) {
        uint rewardsPerToken = accumulatedRewardsPerToken - stakersInfos[user].accumulatedRewardsPerToken;
        uint rewards = (rewardsPerToken * stakersInfos[user].tokensStaked) / DECIMALS;
        return rewards;
    }

    receive() payable external {
        require(totalStaked != 0, "No stakers");

        uint rewardsPerToken = (msg.value * DECIMALS) / totalStaked;
        accumulatedRewardsPerToken += rewardsPerToken;

        totalRewards += msg.value;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function burn(uint256 value) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}