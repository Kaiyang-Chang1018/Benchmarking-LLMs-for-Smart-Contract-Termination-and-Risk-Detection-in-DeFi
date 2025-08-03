// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract FeeDistributor {
    address public immutable owner;
    address public protocolWallet;
    address public lpStakingContract;
    address public bonziStakingContract;
    AggregatorV3Interface internal priceFeed;
    
    uint256 public threshold = 100; // $100 in USDC, modifiable
    
    // Shares in basis points (100 = 1%, 10000 = 100%)
    uint256 public protocolShare = 5790;  // 57.9% (11/19)
    uint256 public lpShare = 2632;        // 26.3% (5/19)
    uint256 public bonziShare = 1578;     // 15.8% (3/19)

    bool private locked;
    
    event FeesDistributed(uint256 amount);
    event SharesUpdated(uint256 protocol, uint256 lp, uint256 bonzi);
    event WalletsUpdated(address protocol, address lp, address bonzi);
    event ThresholdUpdated(uint256 newThreshold);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }
    
    constructor(
        address _priceFeed,    
        address _protocol,         
        address _lpStaking,    
        address _bonziStaking  
    ) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
        protocolWallet = _protocol;
        lpStakingContract = _lpStaking;
        bonziStakingContract = _bonziStaking;
    }

    function getEthUsdcPrice() internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price/100); 
    }

    function usdcToEth(uint256 usdcAmount) public view returns (uint256) {
        uint256 ethUsdcPrice = getEthUsdcPrice();
        return (usdcAmount * 1e6*1e18 / ethUsdcPrice); 
    }

    receive() external payable nonReentrant {
        uint256 thresholdInEth = usdcToEth(threshold);
        if (address(this).balance >= thresholdInEth) {
            _distributeFees();
        }
    }

    function setThreshold(uint256 _newThreshold) external onlyOwner {
        threshold = _newThreshold;
        emit ThresholdUpdated(_newThreshold);
    }

    function updateShares(
        uint256 _protocolShare, 
        uint256 _lpShare, 
        uint256 _bonziShare
    ) external onlyOwner {
        require(_protocolShare + _lpShare + _bonziShare == 10000, "Shares must total 100%");
        
        protocolShare = _protocolShare;
        lpShare = _lpShare;
        bonziShare = _bonziShare;
        
        emit SharesUpdated(_protocolShare, _lpShare, _bonziShare);
    }

    function setProtocolWallet(address _new) external onlyOwner {
        require(_new != address(0), "Invalid address");
        protocolWallet = _new;
        emit WalletsUpdated(protocolWallet, lpStakingContract, bonziStakingContract);
    }

    function setLpStaking(address _new) external onlyOwner {
        lpStakingContract = _new; // Can be zero address to disable
        emit WalletsUpdated(protocolWallet, lpStakingContract, bonziStakingContract);
    }

    function setBonziStaking(address _new) external onlyOwner {
        bonziStakingContract = _new; // Can be zero address to disable
        emit WalletsUpdated(protocolWallet, lpStakingContract, bonziStakingContract);
    }

    function updateWallets(
        address _protocol,
        address _lpStaking,
        address _bonziStaking
    ) external onlyOwner {
        require(_protocol != address(0), "Invalid address");
        
        protocolWallet = _protocol;
        lpStakingContract = _lpStaking;
        bonziStakingContract = _bonziStaking;
        
        emit WalletsUpdated(_protocol, _lpStaking, _bonziStaking);
    }

    function manualDistribute() external onlyOwner nonReentrant {
        _distributeFees();
    }

    function _distributeFees() private {
        uint256 totalBalance = address(this).balance;
        require(totalBalance > 0, "No fees to distribute");

        // Calculate amounts
        uint256 protocolAmount = (totalBalance * protocolShare) / 10000;
        uint256 lpAmount = (totalBalance * lpShare) / 10000;
        uint256 bonziAmount = totalBalance - protocolAmount - lpAmount;

        // Send shares (only if share > 0 and address is set)
        if (protocolAmount > 0 && protocolWallet != address(0)) {
            (bool protocolSent,) = payable(protocolWallet).call{value: protocolAmount}("");
            require(protocolSent, "Failed to send to protocol");
        }
        
        if (lpAmount > 0 && lpStakingContract != address(0)) {
            (bool lpSent,) = payable(lpStakingContract).call{value: lpAmount}("");
            require(lpSent, "Failed to send to LP staking");
        }
        
        if (bonziAmount > 0 && bonziStakingContract != address(0)) {
            (bool bonziSent,) = payable(bonziStakingContract).call{value: bonziAmount}("");
            require(bonziSent, "Failed to send to BONZI staking");
        }

        emit FeesDistributed(totalBalance);
    }

    // View functions
    function getShares() external view returns (uint256, uint256, uint256) {
        return (protocolShare, lpShare, bonziShare);
    }

    function getWallets() external view returns (address, address, address) {
        return (protocolWallet, lpStakingContract, bonziStakingContract);
    }

    function getCurrentBalance() external view returns (uint256) {
        return address(this).balance;
    }
}