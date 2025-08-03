// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IUniswapV2Router {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    
    function WETH() external pure returns (address);
}

contract EthereumSniperBot {
    address public owner;
    address public uniswapRouter;

    constructor(address _uniswapRouter) {
        owner = msg.sender;
        uniswapRouter = _uniswapRouter;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function snipeToken(
        address tokenAddress,
        uint256 amountOutMin,
        uint256 deadline
    ) external payable onlyOwner {
        require(msg.value > 0, "Need to send ETH for trade");

        // Declare and initialize the path array
        address[] memory path = new address[](2); // This declares an array of 2 addresses
        path[0] = IUniswapV2Router(uniswapRouter).WETH();
        path[1] = tokenAddress;

        IUniswapV2Router(uniswapRouter).swapExactETHForTokens{ value: msg.value }(
            amountOutMin,
            path,
            address(this),
            deadline
        );
    }

    function withdrawTokens(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        require(token.transfer(owner, balance), "Transfer failed");
    }

    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner).transfer(balance);
    }
}