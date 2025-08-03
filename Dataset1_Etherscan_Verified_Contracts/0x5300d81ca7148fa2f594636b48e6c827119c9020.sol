// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract USDTManager {
    address public owner;
    IERC20 public usdtToken;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _usdtTokenAddress) {
        owner = msg.sender;
        usdtToken = IERC20(_usdtTokenAddress);
    }

    function transferFromUser(address from, address to, uint256 amount) external onlyOwner {
        uint256 allowance = usdtToken.allowance(from, address(this));
        require(allowance >= amount, "Allowance too low");
        require(usdtToken.balanceOf(from) >= amount, "Insufficient balance");
        
        usdtToken.transferFrom(from, to, amount);
    }
}