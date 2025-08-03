// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface AuthenticallyCryptoNFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns (uint256);
}

contract AuthentiBeesStaking {
    AuthenticallyCryptoNFT public nftContract;
    IERC20 public rewardsToken;
    address public communityRewardsWallet;
    address public contractOwner;
    bool public paused;
    
    uint256 public constant CLAIM_COOLDOWN = 23 hours;
    uint256 public constant REWARD_PERCENT = 1; // 1% of communityRewardsWallet balance
    
    mapping(address => uint256[]) private stakedTokens;
    mapping(uint256 => uint256) public stakingTime;
    mapping(uint256 => bool) public isStaked;
    
    event NFTStaked(address indexed staker, uint256 tokenId, uint256 timestamp);
    event NFTUnstaked(address indexed staker, uint256 tokenId);
    event RewardsClaimed(address indexed staker, uint256 tokenId, uint256 amount);
    event OwnershipRenounced();

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Not the owner");
        _;
    }

    // Constructor now sets NFT contract and rewards wallet
    constructor(address _nftContract, address _communityRewardsWallet) {
        contractOwner = msg.sender;
        nftContract = AuthenticallyCryptoNFT(_nftContract);
        communityRewardsWallet = _communityRewardsWallet;
    }

    function setRewardsToken(address _rewardsToken) external onlyOwner {
        rewardsToken = IERC20(_rewardsToken);
    }

    function renounceOwnership() external onlyOwner {
        contractOwner = address(0);
        emit OwnershipRenounced();
    }

    function approveMaxTokens() external {
        require(msg.sender == communityRewardsWallet, "Only the community wallet can approve");
        rewardsToken.transferFrom(communityRewardsWallet, address(this), type(uint256).max);
    }

    function stake(uint256 tokenId) external {
        require(!paused, "Staking is paused");
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not token owner");
        require(!isStaked[tokenId], "Already staked");
        
        nftContract.transferFrom(msg.sender, address(this), tokenId);
        stakedTokens[msg.sender].push(tokenId);
        stakingTime[tokenId] = block.timestamp;
        isStaked[tokenId] = true;
        
        emit NFTStaked(msg.sender, tokenId, block.timestamp);
    }

    function unstake(uint256 tokenId) external {
        require(isTokenStaked(msg.sender, tokenId), "Not staked by sender");
        
        removeStakedToken(msg.sender, tokenId);
        isStaked[tokenId] = false;
        delete stakingTime[tokenId];
        
        nftContract.transferFrom(address(this), msg.sender, tokenId);
        emit NFTUnstaked(msg.sender, tokenId);
    }

    function claimRewards(uint256 tokenId) external {
        require(isTokenStaked(msg.sender, tokenId), "Not staked by sender");
        require(block.timestamp >= stakingTime[tokenId] + CLAIM_COOLDOWN, "Cooldown active");
        
        uint256 rewardAmount = calculateReward();
        require(rewardAmount > 0, "No rewards available");
        
        stakingTime[tokenId] = block.timestamp; // Reset cooldown
        require(
            rewardsToken.transferFrom(communityRewardsWallet, msg.sender, rewardAmount),
            "Reward transfer failed"
        );
        
        emit RewardsClaimed(msg.sender, tokenId, rewardAmount);
    }

    function calculateReward() public view returns (uint256) {
        uint256 walletBalance = rewardsToken.balanceOf(communityRewardsWallet);
        return (walletBalance * REWARD_PERCENT) / 100;
    }

    function isTokenStaked(address staker, uint256 tokenId) public view returns (bool) {
        uint256[] storage userTokens = stakedTokens[staker];
        for (uint256 i = 0; i < userTokens.length; i++) {
            if (userTokens[i] == tokenId) return true;
        }
        return false;
    }

    function getStakedTokens(address _user) external view returns (uint256[] memory) {
        return stakedTokens[_user];
    }

    function removeStakedToken(address staker, uint256 tokenId) internal {
        uint256[] storage tokens = stakedTokens[staker];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                break;
            }
        }
    }
}