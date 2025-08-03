// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory);
}

contract ArbitrageBot {
    address public owner;
    address public profitWallet;
    address public fundingWallet;
    address[] public path;
    address[] public reversePath;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    event ArbitrageExecuted(address indexed tokenA, address indexed tokenB, uint256 profit);
    event WalletUpdated(string walletType, address newWallet);
    event EmergencyWithdrawal(address indexed token, uint256 amount);

    constructor(address _profitWallet, address _fundingWallet) {
        require(_profitWallet != address(0), "Invalid profit wallet address");
        require(_fundingWallet != address(0), "Invalid funding wallet address");
        owner = msg.sender;
        profitWallet = _profitWallet;
        fundingWallet = _fundingWallet;
    }

    // Check if arbitrage is profitable
    function checkArbitrage(
        address tokenA,
        address tokenB,
        uint256 amountIn,
        address routerA,
        address routerB
    ) public returns (bool profitable, uint256 profit) {
        // Initialize path: tokenA -> tokenB
        delete path;
        path.push(tokenA);
        path.push(tokenB);

        uint256[] memory amountsOutA = IUniswapV2Router(routerA).getAmountsOut(amountIn, path);
        uint256 amountOutA = amountsOutA[1];

        // Initialize reversePath: tokenB -> tokenA
        delete reversePath;
        reversePath.push(tokenB);
        reversePath.push(tokenA);

        uint256[] memory amountsOutB = IUniswapV2Router(routerB).getAmountsOut(amountOutA, reversePath);
        uint256 amountOutB = amountsOutB[1];

        if (amountOutB > amountIn) {
            profitable = true;
            profit = amountOutB - amountIn;
        } else {
            profitable = false;
            profit = 0;
        }
    }

    // Execute arbitrage if profitable
    function executeArbitrage(
        address routerA,
        address routerB,
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) external onlyOwner {
        bool profitable;
        (profitable, ) = checkArbitrage(tokenA, tokenB, amountIn, routerA, routerB);
        require(profitable, "No arbitrage opportunity");

        // Approve routerA to spend tokenA
        IERC20(tokenA).approve(routerA, amountIn);

        // Initialize path: tokenA -> tokenB
        delete path;
        path.push(tokenA);
        path.push(tokenB);

        IUniswapV2Router(routerA).swapExactTokensForTokens(
            amountIn,
            (amountIn * 95) / 100, // Slippage protection
            path,
            address(this),
            block.timestamp + 300
        );

        uint256 amountOutA = IERC20(tokenB).balanceOf(address(this));

        // Approve routerB to spend tokenB
        IERC20(tokenB).approve(routerB, amountOutA);

        // Initialize reversePath: tokenB -> tokenA
        delete reversePath;
        reversePath.push(tokenB);
        reversePath.push(tokenA);

        IUniswapV2Router(routerB).swapExactTokensForTokens(
            amountOutA,
            (amountOutA * 95) / 100, // Slippage protection
            reversePath,
            address(this),
            block.timestamp + 300
        );

        uint256 finalBalance = IERC20(tokenA).balanceOf(address(this));
        uint256 profitEarned = finalBalance - amountIn;

        require(profitEarned > 0, "No profit made");
        require(IERC20(tokenA).transfer(profitWallet, profitEarned), "Transfer to profit wallet failed");

        emit ArbitrageExecuted(tokenA, tokenB, profitEarned);
    }

    // Withdraw any ERC-20 tokens
    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner, amount);
        emit EmergencyWithdrawal(token, amount);
    }

    // Withdraw all ETH from the contract
    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Update the profit wallet
    function updateProfitWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Invalid wallet address");
        profitWallet = newWallet;
        emit WalletUpdated("Profit Wallet", newWallet);
    }

    // Update the funding wallet
    function updateFundingWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Invalid wallet address");
        fundingWallet = newWallet;
        emit WalletUpdated("Funding Wallet", newWallet);
    }

    // Allow the contract to receive ETH
    receive() external payable {}
}