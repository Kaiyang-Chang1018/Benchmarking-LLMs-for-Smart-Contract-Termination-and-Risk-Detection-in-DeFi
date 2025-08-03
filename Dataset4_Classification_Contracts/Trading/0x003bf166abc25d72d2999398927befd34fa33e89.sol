// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenSwap {
    address public owner;

    IERC20 public tokenIn;
    IERC20 public tokenOut;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setTokenIn(address _tokenIn) external onlyOwner {
        require(_tokenIn != address(0), "Invalid address for tokenIn");
        tokenIn = IERC20(_tokenIn);
    }

    function setTokenOut(address _tokenOut) external onlyOwner {
        require(_tokenOut != address(0), "Invalid address for tokenOut");
        tokenOut = IERC20(_tokenOut);
    }

    function swap(uint256 amount) external {
        require(address(tokenIn) != address(0), "tokenIn not set");
        require(address(tokenOut) != address(0), "tokenOut not set");
        require(amount > 0, "Amount must be greater than 0");

        bool successIn = tokenIn.transferFrom(msg.sender, address(this), amount);
        require(successIn, "Failed to transfer tokenIn");

        bool successOut = tokenOut.transfer(msg.sender, amount);
        require(successOut, "Failed to transfer tokenOut");
    }

    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function withdrawTokenIn(uint256 amount) external onlyOwner {
        require(address(tokenIn) != address(0), "tokenIn not set");
        bool success = tokenIn.transfer(owner, amount);
        require(success, "Failed to withdraw tokenIn");
    }

    function withdrawTokenOut(uint256 amount) external onlyOwner {
        require(address(tokenOut) != address(0), "tokenOut not set");
        bool success = tokenOut.transfer(owner, amount);
        require(success, "Failed to withdraw tokenOut");
    }

    function withdrawAllTokenIn() external onlyOwner {
        require(address(tokenIn) != address(0), "tokenIn not set");
        uint256 balance = tokenIn.balanceOf(address(this));
        require(balance > 0, "No tokenIn balance");
        bool success = tokenIn.transfer(owner, balance);
        require(success, "Failed to withdraw all tokenIn");
    }

    function withdrawAllTokenOut() external onlyOwner {
        require(address(tokenOut) != address(0), "tokenOut not set");
        uint256 balance = tokenOut.balanceOf(address(this));
        require(balance > 0, "No tokenOut balance");
        bool success = tokenOut.transfer(owner, balance);
        require(success, "Failed to withdraw all tokenOut");
    }

    receive() external payable {}
}