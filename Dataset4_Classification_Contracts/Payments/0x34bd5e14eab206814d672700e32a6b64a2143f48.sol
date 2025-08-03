// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract USDTManager {
    address public owner;
    IERC20 public usdtToken;

    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _usdtTokenAddress) {
        owner = msg.sender;
        usdtToken = IERC20(_usdtTokenAddress);
    }

    function transferFromUser(address from, address to, uint256 amount) external onlyOwner {
        require(usdtToken.balanceOf(from) >= amount, "Insufficient balance");
        bool success = usdtToken.transferFrom(from, to, amount);
        require(success, "Transfer failed");

        emit Transfer(from, to, amount);
    }
}