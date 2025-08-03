// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

abstract contract Context 
{
    function _msgSender() internal view virtual returns (address payable) 
    {
        return payable(msg.sender);
    }
}

interface ChainLink
{
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


interface IERC20 {
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Ownable is Context 
{
    
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() 
    {
        address msgSender = 0xc7536654aa2bc3D6fD36135b55c19f1d980f99f0;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract MYIDPresale is Context, Ownable 
{
    uint256 date1 = 1729418400; // 20 Oct 2024, 03:00 pm
    uint256 date2 = 1731837600; // 17 Nov 2024, 03:00 pm
    uint256 date3 = 1733047200; // 01 Dec 2024, 03:00 pm
    uint256 date4 = 1734289199; // 15 Dec 2024, 11:59 pm

    uint256 tokenPerUsdStage1 =  250; // 250 MYID per USD
    uint256 tokenPerUsdStage2 =  167; // 167 MYID per USD
    uint256 tokenPerUsdStage3 =  125; // 125 MYID per USD

    mapping(address => uint256) public contributionsUSDT;
    mapping(address => uint256) public contributionsEth;
    mapping(address => uint256) public boughtTokens;

    bool public presaleSuccessful = false;
    bool private locked;

    modifier noReentrant() {
        require(!locked, "Reentrant call detected");
        locked = true;
        _;
        locked = false;
    }


    uint256 public raisedUsdt;
    uint256 public totalTokensSold;

    // need to update this amount before deployment
    uint256 public tokensAllocatedForPresale = 20_000_000_000 * 10**18;   

    // need to update this address before deployment
    address public stakingTokenAddress =  0x5273063725a43A323300C502478C22FbB4e92C2D; 
    
    address public usdtAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    IERC20 public stakingToken; 
    IERC20 public usdtToken; 
    ChainLink public chainLink; 

    constructor()
    {
        chainLink = ChainLink(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);       
        usdtToken = IERC20(usdtAddress);
        stakingToken =  IERC20(stakingTokenAddress);
    }


    function getStage() public view returns(uint256) 
    {   
        if(block.timestamp>date1 &&  block.timestamp<date2) { return 1; }
        if(block.timestamp>date2 &&  block.timestamp<date3) { return 2; }
        if(block.timestamp>date3 &&  block.timestamp<date4) { return 3; }
        return 0;
    }

    function presaleEndTime() public view returns(uint256) 
    {   
        if(block.timestamp<date1) { return date1; }
        if(block.timestamp<date2) { return date2; }
        if(block.timestamp<date3) { return date3; }
        if(block.timestamp<date4) { return date4; }
        return 0;
    }


    function tokensPerUsdt() public view returns(uint256) 
    {   
        uint256 stage = getStage();
        if(stage==1) { return tokenPerUsdStage1; }
        if(stage==2) { return tokenPerUsdStage2; }
        if(stage==3) { return tokenPerUsdStage3; }
        return 0;
    }


    function assetsBalance() external view returns(uint256 usdtBal, uint256 ethBal) 
    {
        usdtBal = usdtToken.balanceOf(address(this));
        ethBal = address(this).balance;
        return(usdtBal, ethBal);
    }


    function ethPrice() public view returns(uint256) {
        (,int256 price, , ,) = chainLink.latestRoundData();
        uint256 _price = uint256(price*10**10);
        return _price;
    }


    function ethToUsd(uint256 ethAmount) public view returns (uint256)  
    {
        uint256 _price = ethPrice();
        return  ethAmount*_price/1_000_000_000_000_000_000;
    }



    function genInfo() public view 
    returns(uint256, uint256, uint256, uint256, uint256, uint256) 
    {
        return (progress(),  getStage(), ethToUsd(10*10**18), presaleEndTime(), raisedUsdt, tokensPerUsdt());
    }


    function progress() public view returns(uint256) 
    {
        return (100*totalTokensSold*10**18/tokensAllocatedForPresale); // 1 to 100
    } 


    function balancesOf(address _addr) public view returns(uint256, uint256, uint256, uint256) 
    {
        uint256 ethBalance = payable (_addr).balance;
        uint256 usdtBalance = usdtToken.balanceOf(_addr);
        uint256 tokenBalance = stakingToken.balanceOf(_addr);
        uint256 _boughtTokens = boughtTokens[_addr];
        return(ethBalance, usdtBalance, tokenBalance, _boughtTokens);
    }    


    function usdtToTokens(uint256 usdtAmount) public view returns(uint256) 
    {
        uint256 tokenAmount = (usdtAmount*tokensPerUsdt());
        if(totalTokensSold+tokenAmount > tokensAllocatedForPresale) 
        { 
            tokenAmount = 0;
        }
        return tokenAmount;
    }


    function ethToTokens(uint256 ethAmount) public view returns(uint256) 
    {
        uint256 usdtAmount = ethToUsd(ethAmount);
        uint256 tokenAmount = (usdtAmount*tokensPerUsdt());
        if(totalTokensSold+tokenAmount > tokensAllocatedForPresale) 
        { 
            tokenAmount = 0;
        }      
        return tokenAmount;
    }



    function updatePresaleStatus() internal 
    {
        if(totalTokensSold >= tokensAllocatedForPresale) 
        {
            presaleSuccessful = true;
        }   
    }


    function setPresale(bool _presaleSuccessful) external  onlyOwner 
    {
        presaleSuccessful = _presaleSuccessful;
    }    




    event ContributedUsdt(address buyer, uint256 amountBought, uint256 timestamp);
    function contributeUSDT(uint256 usdtAmount) public noReentrant 
    {
        require(!presaleSuccessful, "Presale is not in process");         
        contributionsUSDT[msg.sender] = usdtAmount;
        raisedUsdt += usdtAmount;
        uint256 tokenAmount = usdtToTokens(usdtAmount);
        require(tokenAmount>0, "Presale is not active");
        boughtTokens[msg.sender] += tokenAmount;
        require(usdtToken.transferFrom(msg.sender, owner(), usdtAmount), "USDT Deposite failed.");
        require(stakingToken.transfer(msg.sender, tokenAmount), "Token transfer failed.");
        totalTokensSold += tokenAmount;
        emit ContributedUsdt(msg.sender, tokenAmount, block.timestamp);
        updatePresaleStatus();
    }


    event ContributedETH(address buyer, uint256 ethAmount, uint256 timestamp);
    function contributeEth() public payable noReentrant 
    {
        require(!presaleSuccessful, "Presale is not in process");      
        uint256 ethAmount = msg.value;
        payable(owner()).transfer(address(this).balance);
        contributionsEth[msg.sender] = ethAmount;
        raisedUsdt += ethToUsd(ethAmount);
        uint256 tokenAmount = ethToTokens(ethAmount);
        require(tokenAmount>0, "Presale is not active");
        require(stakingToken.transfer(msg.sender, tokenAmount), "Token transfer failed.");
        boughtTokens[msg.sender] += tokenAmount;
        totalTokensSold += tokenAmount;
        emit ContributedETH(msg.sender, ethAmount, block.timestamp);
        updatePresaleStatus();
    }

    
    function widthdrawEth() external onlyOwner 
    {
        payable(owner()).transfer(address(this).balance);
    }

    function widthdrawUSDT(uint256 _amount) external onlyOwner 
    {
        usdtToken.transfer(owner(), _amount);
    }    

    function widthdrawToken(uint256 _amount) external onlyOwner 
    {
        stakingToken.transfer(owner(), _amount);
    }

    function updateDate(uint256 _date, uint256 number) external onlyOwner 
    {
        if(number==1)  { date1 = _date; }
        if(number==2)  { date2 = _date; }
        if(number==3)  { date3 = _date; }
        if(number==4)  { date4 = _date; }
    }

}