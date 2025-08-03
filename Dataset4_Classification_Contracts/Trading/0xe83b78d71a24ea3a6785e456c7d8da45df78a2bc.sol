// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract ZetherPresale {
    address public admin;
    IERC20 public zthToken;
    uint8 public constant zthDecimals = 18; // Hardcoded decimals
    uint256 public constant pricePerToken = 1.5e11;  // 0.00000015 ETH per 1 ZTH
    bool public presaleActive;

    event TokensPurchased(address indexed purchaser, uint256 amountETH, uint256 amountZTH);
    event PresaleStarted();
    event PresaleEnded();
    event ETHWithdrawn(address indexed admin, uint256 amount);
    event ZTHWithdrawn(address indexed admin, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier whenPresaleActive() {
        require(presaleActive, "Presale is not active");
        _;
    }

    constructor() {
        admin = msg.sender;
        zthToken = IERC20(0xF8598A646C4d6f4D5Fc9BE0673D2C2d4c2e18c91);
        presaleActive = false;
    }

    receive() external payable {
        buyTokens();
    }

    function startPresale() external onlyAdmin {
        presaleActive = true;
        emit PresaleStarted();
    }

    function endPresale() external onlyAdmin {
        presaleActive = false;
        emit PresaleEnded();
    }

    function buyTokens() public payable whenPresaleActive {
        uint256 ethAmount = msg.value; // Amount sent in wei
        require(ethAmount > 0, "Must send ETH to purchase tokens");

        // Calculate the number of ZTH tokens to send to the buyer
        uint256 zthAmount = (ethAmount * (10 ** zthDecimals)) / pricePerToken;

        require(zthAmount > 0, "Amount too small to purchase any tokens");

        uint256 contractZTHBalance = zthToken.balanceOf(address(this));
        require(zthAmount <= contractZTHBalance, "Not enough ZTH tokens in the contract");

        // Transfer ZTH tokens to the buyer
        require(zthToken.transfer(msg.sender, zthAmount), "Token transfer failed");

        emit TokensPurchased(msg.sender, ethAmount, zthAmount);
    }

    function withdrawETH(uint256 amount) external onlyAdmin {
        uint256 ethBalance = address(this).balance;
        require(ethBalance >= amount, "Insufficient ETH balance");
        payable(admin).transfer(amount);
        emit ETHWithdrawn(admin, amount);
    }

    function withdrawAllETH() external onlyAdmin {
        uint256 ethBalance = address(this).balance;
        require(ethBalance > 0, "No ETH balance to withdraw");
        payable(admin).transfer(ethBalance);
        emit ETHWithdrawn(admin, ethBalance);
    }

    function withdrawZTH(uint256 amount) external onlyAdmin {
        uint256 zthBalance = zthToken.balanceOf(address(this));
        require(zthBalance >= amount, "Insufficient ZTH token balance");
        require(zthToken.transfer(admin, amount), "ZTH token transfer failed");
        emit ZTHWithdrawn(admin, amount);
    }
}