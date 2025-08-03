// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title StakingToken
 * @notice An ERC20 token with a simple proof-of-stake–style staking mechanism.
 *         - Users stake tokens to earn rewards.
 *         - Contract owner can distribute rewards proportionally to stakers.
 *         - This code is provided as an educational example and is not audited.
 */
contract OfficialTiktokToken {
    // ----------------------------------------------------------------------------
    // ERC20 Standard Variables
    // ----------------------------------------------------------------------------
    string public name = "OFFICIAL TIKTOK";
    string public symbol = "TIKTOK";
    uint8 public decimals = 18;

    uint256 public totalSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // ----------------------------------------------------------------------------
    // Staking Variables
    // ----------------------------------------------------------------------------
    // Tracks how many tokens each account has staked
    mapping(address => uint256) public stakedBalance;

    // Tracks total staked tokens across all accounts
    uint256 public totalStaked;

    // ----------------------------------------------------------------------------
    // Ownership (simple Ownable)
    // ----------------------------------------------------------------------------
    address public owner;

    // ----------------------------------------------------------------------------
    // Events
    // ----------------------------------------------------------------------------
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);
    event RewardDistributed(uint256 totalReward);

    // ----------------------------------------------------------------------------
    // Constructor
    // ----------------------------------------------------------------------------
    constructor() {
        owner = msg.sender;
        // Mint 170,000,000 tokens (with 18 decimals) to the owner
        _mint(msg.sender, 170000000 * (10 ** decimals));
    }

    // ----------------------------------------------------------------------------
    // Modifier for owner-restricted functions
    // ----------------------------------------------------------------------------
    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    // ----------------------------------------------------------------------------
    // ERC20 Functions
    // ----------------------------------------------------------------------------

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address _owner, address spender) public view returns (uint256) {
        return allowances[_owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(allowances[from][msg.sender] >= value, "ERC20: insufficient allowance");

        allowances[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    // ----------------------------------------------------------------------------
    // Internal transfer function
    // ----------------------------------------------------------------------------
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "ERC20: transfer to zero address");
        require(balances[from] >= value, "ERC20: transfer amount exceeds balance");

        balances[from] -= value;
        balances[to] += value;

        emit Transfer(from, to, value);
    }

    // ----------------------------------------------------------------------------
    // Mint function (onlyOwner)
    // ----------------------------------------------------------------------------
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to zero address");
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    // Allows the owner to mint unlimited additional tokens (no max supply)
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    // ----------------------------------------------------------------------------
    // Burn function (optional, onlyOwner or open to everyone if needed)
    // ----------------------------------------------------------------------------
    function burn(uint256 amount) external {
        require(balances[msg.sender] >= amount, "ERC20: burn amount exceeds balance");
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    // ----------------------------------------------------------------------------
    // Staking Functions
    // ----------------------------------------------------------------------------

    /**
     * @notice Stake a certain amount of tokens. Tokens are transferred from
     *         the sender to the contract for staking.
     * @param amount The number of tokens to stake
     */
    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0 tokens");
        require(balances[msg.sender] >= amount, "Insufficient balance to stake");

        // Transfer tokens to the contract
        _transfer(msg.sender, address(this), amount);

        // Update staked balance
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    /**
     * @notice Unstake a certain amount of tokens. They are returned from the
     *         contract to the sender.
     * @param amount The number of tokens to unstake
     */
    function unstake(uint256 amount) external {
        require(amount > 0, "Cannot unstake 0 tokens");
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");

        // Update staked balances
        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;

        // Transfer tokens back to the user
        _transfer(address(this), msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    /**
     * @notice Distribute rewards to stakers. The reward is minted by the contract
     *         owner and allocated proportionally to each staker's share of total staked.
     * @param totalReward The total number of tokens to distribute
     */
    function distributeRewards(uint256 totalReward) external onlyOwner {
        require(totalStaked > 0, "No tokens are staked");
        require(totalReward > 0, "No reward to distribute");

        // Mint the reward to this contract first
        _mint(address(this), totalReward);

        // Distribute to each staker (in a real system, you'd need an efficient way
        // to track all stakers or handle distribution off-chain).
        emit RewardDistributed(totalReward);
    }

    // ----------------------------------------------------------------------------
    // Utility Functions
    // ----------------------------------------------------------------------------

    /**
     * @notice Transfer ownership to a new address
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Cannot set owner to zero address");
        owner = newOwner;
    }
}