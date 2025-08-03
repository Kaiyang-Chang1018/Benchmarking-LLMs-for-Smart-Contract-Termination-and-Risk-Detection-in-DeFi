// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Minimal interface of ERC20 token standard
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

// Minimal interface of Uniswap V3 SwapRouter
interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

contract SimpleTradeBot {
    ISwapRouter public immutable uniswapRouter;
    address public owner;

    uint256 public minTradeAmount;
    uint256 public maxTradeAmount;
    uint256 public tradePercent;
    uint256 public slippageTolerance;
    uint256 public profitThreshold;

    mapping(address => bool) public allowedTokens;
    mapping(address => uint256) public tokenBalances;

    struct TradeConfig {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 deadline;
    }

    TradeConfig public currentTrade;

    event TradeExecuted(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut, uint256 profit);
    event TokensWithdrawn(address indexed token, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _uniswapRouter) {
        owner = msg.sender;
        uniswapRouter = ISwapRouter(_uniswapRouter);
        minTradeAmount = 100000; // 0.1 tokens with 6 decimals
        maxTradeAmount = 10000000; // 10 tokens with 6 decimals
        tradePercent = 50;
        slippageTolerance = 50; // 0.5%
        profitThreshold = 10000; // 0.01 tokens with 6 decimals
    }

    function setAllowedToken(address _token, bool _allowed) external onlyOwner {
        allowedTokens[_token] = _allowed;
    }

    function setTradeConfig(TradeConfig memory _config) external onlyOwner {
        currentTrade = _config;
    }

    function executeTrade() external onlyOwner {
        require(allowedTokens[currentTrade.tokenIn] && allowedTokens[currentTrade.tokenOut], "Tokens not allowed");
        require(currentTrade.amountIn >= minTradeAmount && currentTrade.amountIn <= maxTradeAmount, "Invalid trade amount");
        require(block.timestamp <= currentTrade.deadline, "Trade deadline expired");

        uint256 tradeAmount = (IERC20(currentTrade.tokenIn).balanceOf(address(this)) * tradePercent) / 100;
        tradeAmount = tradeAmount > currentTrade.amountIn ? currentTrade.amountIn : tradeAmount;

        IERC20(currentTrade.tokenIn).approve(address(uniswapRouter), tradeAmount);

        uint256 initialBalance = IERC20(currentTrade.tokenOut).balanceOf(address(this));

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: currentTrade.tokenIn,
            tokenOut: currentTrade.tokenOut,
            fee: currentTrade.fee,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: tradeAmount,
            amountOutMinimum: currentTrade.minAmountOut,
            sqrtPriceLimitX96: 0
        });

        uint256 amountOut = uniswapRouter.exactInputSingle(params);

        uint256 finalBalance = IERC20(currentTrade.tokenOut).balanceOf(address(this));
        uint256 profit = finalBalance - initialBalance;

        require(profit >= profitThreshold, "Profit below threshold");

        tokenBalances[currentTrade.tokenIn] -= tradeAmount;
        tokenBalances[currentTrade.tokenOut] += amountOut;

        emit TradeExecuted(currentTrade.tokenIn, currentTrade.tokenOut, tradeAmount, amountOut, profit);
    }

    function withdraw(address _token, uint256 _amount) external onlyOwner {
        require(_amount <= IERC20(_token).balanceOf(address(this)), "Insufficient balance");
        IERC20(_token).transfer(owner, _amount);
        emit TokensWithdrawn(_token, _amount);
    }

    receive() external payable {
        tokenBalances[address(0)] += msg.value;
    }

    fallback() external payable {}
}