// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract GROWLSALE {
    IERC20 public memecoin;
    IERC20 public usdt;
    address public owner;
    uint256 public price; // Price in USDT (1 USDT = 1 * 10^6)
    uint256 public maxSpendAmount = 500 * 10**6; // $500 in USDT (assuming USDT has 6 decimals)
    mapping(address => uint256) public userSpendAmount;

    event TokensPurchased(address buyer, uint256 amountSpent, uint256 amountBought);
    event TokensDeposited(address owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(IERC20 _memecoin, IERC20 _usdt, uint256 _price) {
        memecoin = _memecoin;
        usdt = _usdt;
        owner = msg.sender;
        price = _price; // Price per memecoin in USDT (e.g., 0.01 USDT per memecoin)
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function setMaxSpendAmount(uint256 _maxSpendAmount) external onlyOwner {
        maxSpendAmount = _maxSpendAmount;
    }

    function buyMemecoins(uint256 usdtAmount) external {
        require(usdtAmount > 0, "Amount should be greater than zero");
        require(userSpendAmount[msg.sender] + usdtAmount <= maxSpendAmount, "Exceeds maximum spend limit");

        uint256 memecoinsToBuy = (usdtAmount * 10**18) / (price); // USDT has 6 decimals, token has 18 decimals

        require(memecoin.balanceOf(address(this)) >= memecoinsToBuy, "Not enough memecoins in the reserve");

        // Transfer USDT from the buyer to the contract
        require(usdt.transferFrom(msg.sender, address(this), usdtAmount), "USDT transfer failed");

        // Update the user's spend amount
        userSpendAmount[msg.sender] += usdtAmount;

        // Transfer memecoins from the contract to the buyer
        require(memecoin.transfer(msg.sender, memecoinsToBuy), "Memecoin transfer failed");

        emit TokensPurchased(msg.sender, usdtAmount, memecoinsToBuy);
    }

    function depositGrowlcoins(uint256 amount) external onlyOwner {
        require(memecoin.transferFrom(msg.sender, address(this), amount), "Memecoin transfer failed");
        emit TokensDeposited(msg.sender, amount);
    }

    function withdrawUSDT(uint256 amount) external onlyOwner {
        require(usdt.balanceOf(address(this)) >= amount, "Not enough USDT in the reserve");
        usdt.transfer(owner, amount);
    }

    function withdrawGrowlcoins(uint256 amount) external onlyOwner {
        require(memecoin.balanceOf(address(this)) >= amount, "Not enough memecoins in the reserve");
        memecoin.transfer(owner, amount);
    }

    // Fallback function to reject any ETH sent directly to the contract
    fallback() external payable {
        revert("Do not send ETH directly to this contract");
    }

    receive() external payable {
        revert("Do not send ETH directly to this contract");
    }
}