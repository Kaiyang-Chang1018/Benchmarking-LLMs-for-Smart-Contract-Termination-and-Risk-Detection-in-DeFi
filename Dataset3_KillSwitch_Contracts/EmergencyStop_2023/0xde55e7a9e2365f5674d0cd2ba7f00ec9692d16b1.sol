// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20_USDT {
    function transferFrom(address from, address to, uint value) external;
}

contract Presale {

    address public tokenAddress;
    address public usdtAddress;
    address public admin;
    address public operator;
    bool public isOpen;
    uint256 public startTimestamp;
    uint256 public endTimestamp;
    uint256 public stageEndTimeStamp;
    uint256 public timeUnit;
    uint256 public tokensPerUsdt;
    
    constructor() {

        tokenAddress = 0x898C66702D4B60C0F7B83bBf6E1De900e8CbD0A0;
        usdtAddress  = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        admin        =  0xe9c831280D96dBFa20B8c01E5C49993BBbb74a0e; 
        operator     = msg.sender;
        tokensPerUsdt = 1000; // 0.001 USDT
        timeUnit = 7 days;
    }

    event StartedPresale(uint256 startTimestamp);
    event UpdatedEndTime(uint256 endTimestamp);
    event UpdatedStage(uint256 tokensPerUsdt, uint256 stageEndTimeStamp);
    event UpdateAdmin(address newAdmin);

    function contribute(uint256 usdtAmount) external {
        uint256 _allowance = IERC20(usdtAddress).allowance(msg.sender, address(this));
        require(_allowance >= usdtAmount, "No enough allowance available");
        require(usdtAmount > 0, "Contribution amount must be greater than 0");
        require(isOpen, "Not opened");
        require(block.timestamp <= endTimestamp, "Presale Time is over");
        IERC20_USDT(usdtAddress).transferFrom(msg.sender, admin, usdtAmount);
        uint256 tokensAmount = tokensPerUsdt*usdtAmount*(10**12);
        IERC20(tokenAddress).transfer(msg.sender, tokensAmount);
    }

    function getState(address user) public view returns(uint256, uint256, uint256, uint256) {
        uint256 usdtBal = IERC20(usdtAddress).balanceOf(user);
        uint256 tokenBal = IERC20(tokenAddress).balanceOf(user);
        uint256 stage = getStage();
        return(usdtBal, tokenBal, stage, endTimestamp);
    }

    function startPresale() external {
        require(msg.sender==operator, "Only operator is Authorize");
        require(!isOpen, "already opened");
        isOpen = true;
        uint256 _periodInSeconds = 60 days;
        startTimestamp = block.timestamp;
        endTimestamp = block.timestamp+(_periodInSeconds);
        stageEndTimeStamp = block.timestamp+timeUnit;
        emit StartedPresale(block.timestamp);
    }

    function getStage() public view returns(uint256) {
        uint256 span = block.timestamp-startTimestamp;
        uint fac = span/(timeUnit);
        if(fac>8) { fac = 8; }
        return fac;
    }

    function updateStage(uint256 _tokensPerUsdt, uint256 _stageEndTimeStamp) external {
        require(msg.sender == operator, "Only operator is Authorize");
        tokensPerUsdt = _tokensPerUsdt;
        stageEndTimeStamp = _stageEndTimeStamp;
        emit UpdatedStage(tokensPerUsdt, stageEndTimeStamp);
    }

    function updateEndTime(uint256 _endTimestamp) external {
        require(msg.sender == operator, "Only operator is Authorize");
        require(block.timestamp <= _endTimestamp, "wrong timestamp");
        endTimestamp = _endTimestamp;
        emit UpdatedEndTime(endTimestamp);   
    }

    function pause() external {
        require(msg.sender == operator, "Only operator is Authorize");
        isOpen = !isOpen;
    }

    function getRestTokens(address to) external {
        require(msg.sender == operator, "Only operator is Authorize");
        require(block.timestamp > endTimestamp, "Not ended");
        IERC20(tokenAddress).transfer(to, IERC20(tokenAddress).balanceOf(address(this)));
    }

    function updateAdminAddress(address _admin) external {
        require(msg.sender == operator, "Only operator is Authorize");
        require(admin != _admin, "Same address");
        admin = _admin;
        emit UpdateAdmin(admin);
    }
}