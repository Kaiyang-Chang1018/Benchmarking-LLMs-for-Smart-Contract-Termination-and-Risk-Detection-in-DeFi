// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);

}

contract Gaming {
    IERC20 public token;
    IERC20 public usdt;
    IERC20 public usdc;

    address payable public wallet;
    bool public isGamingActive;
    mapping(address => uint256) public usdtContributions;
    mapping(address => uint256) public usdcContributions;

    mapping(address => uint256) public ethContributions;
    mapping(address => uint256) public tokenClaimAmount;

    event TokensPurchasedWithUSDT(address indexed purchaser, uint256 usdtAmount);
    event TokensPurchasedWithETH(address indexed purchaser, uint256 ethAmount);

    constructor(
  
        address _usdt,
         address _usdc,
        address payable _wallet
    ) {
        require(_usdt != address(0), "USDT address cannot be zero");
        require(_usdc != address(0), "USDT address cannot be zero");

        require(_wallet != address(0), "Wallet address cannot be zero");

       
        usdt = IERC20(_usdt);
        usdc = IERC20(_usdc);
        wallet = _wallet;
        isGamingActive = true;
    }

    receive() external payable { }

    function buyTokensWithUSDT(uint256 _usdtAmount) public {
        require(isGamingActive, "Game is not active");
        require(_usdtAmount > 0, "No USDT funds sent");

        usdt.transferFrom(msg.sender, wallet , _usdtAmount);
        usdtContributions[msg.sender] += _usdtAmount;

        emit TokensPurchasedWithUSDT(msg.sender, _usdtAmount);
    }

     function buyTokensWithUSDC(uint256 _usdcAmount) public {
        require(isGamingActive, "Game is not active");
        require(_usdcAmount > 0, "No USDC funds sent");

        usdc.transferFrom(msg.sender, wallet , _usdcAmount);
        usdcContributions[msg.sender] += _usdcAmount;

        emit TokensPurchasedWithUSDT(msg.sender, _usdcAmount);
    }


    function buyTokensWithETH() public payable {
        require(isGamingActive, "Game is not active");
        require(msg.value > 0, "No ETH funds sent");

        ethContributions[msg.sender] += msg.value;
        payable(wallet).transfer(msg.value);

        emit TokensPurchasedWithETH(msg.sender, msg.value);
    }

    function endGames() public {
        require(msg.sender == wallet, "Only the wallet can end the games");
        isGamingActive = false;
    }

    function withdrawUSDT(uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount must be greater than zero");
        require(usdt.balanceOf(address(this)) >= _amount, "Insufficient USDT balance in the contract");
        usdt.transfer(msg.sender, _amount);
    }

      function withdrawUSDC(uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount must be greater than zero");
        require(usdc.balanceOf(address(this)) >= _amount, "Insufficient USDT balance in the contract");
        usdt.transfer(msg.sender, _amount);
    }
    function setTokenClaimAmount(address user, uint256 amount)
        public
        onlyOwner
    {
        tokenClaimAmount[user] = amount;
    }

    function claimTokens() public {
        require(tokenClaimAmount[msg.sender] > 0, "No tokens to claim");

        uint256 amountToClaim = tokenClaimAmount[msg.sender];
        tokenClaimAmount[msg.sender] = 0;
        token.transfer(msg.sender, amountToClaim);
    }

    modifier onlyOwner() {
        require(msg.sender == wallet, "Only owner can call this function");
        _;
    }


}