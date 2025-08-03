// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

contract bndgfe254 {
    address public owner;
    address public tokenAddress;
    address[] public wallets;
    uint256[] public distribution;
    IUniswapV2Router02 public uniswapRouter;

    constructor() {
        owner = msg.sender;
        // Set the Uniswap V2 Router address
        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Function to deposit ETH into the contract
    function deposit() external payable {}

    // Function to update the token address
    function setTokenAddress(address _tokenAddress) external onlyOwner {
        tokenAddress = _tokenAddress;
    }

    // Function to update the wallets
    function setWallets(address[] calldata _wallets) external onlyOwner {
        wallets = _wallets;
    }

    // Function to update the distribution
    function setDistribution(uint256[] calldata _distribution) external onlyOwner {
        require(_distribution.length == wallets.length, "Distribution and wallets length mismatch");
        distribution = _distribution;
    }

    // Function to buy tokens once and distribute them among the wallets
    function buyTokens() external onlyOwner {
        require(wallets.length == distribution.length, "Invalid setup");

        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH balance to buy tokens");

        uint256 totalDistribution = 0;
        for (uint256 i = 0; i < distribution.length; i++) {
            totalDistribution += distribution[i];
        }
        require(totalDistribution == 100, "Distribution must sum to 100");

   address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH(); // WETH address
        path[1] = tokenAddress;

        uint256 amountOutMin = 0; // Set to 0 for simplicity, but should use slippage tolerance

        // Buy tokens once with the full ETH balance
        uniswapRouter.swapExactETHForTokens{value: balance}(
            amountOutMin,
            path,
            address(this),
            block.timestamp + 300 // 5 minutes deadline
        );

        // Get the total amount of tokens bought
        IERC20 token = IERC20(tokenAddress);
        uint256 totalTokens = token.balanceOf(address(this));

        // Distribute tokens to each wallet based on the distribution percentage
        for (uint256 i = 0; i < wallets.length; i++) {
            uint256 tokenAmount = (totalTokens * distribution[i]) / 100;
            require(token.transfer(wallets[i], tokenAmount), "Token transfer failed");
        }
    }

    // Function to withdraw leftover ETH (if needed)
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Fallback function to accept ETH
    receive() external payable {}
}