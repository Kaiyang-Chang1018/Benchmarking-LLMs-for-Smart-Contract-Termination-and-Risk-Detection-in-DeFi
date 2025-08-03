// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces for Uniswap V3
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

    function refundETH() external payable;
}

interface IUniswapV3Factory {
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);
}

interface IQuoter {
    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external view returns (uint256 amountOut);
}

interface IWETH9 {
    function deposit() external payable;

    function withdraw(uint256) external;

    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

// Interface for ERC-20 tokens
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);
}

// Ownable contract from OpenZeppelin
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// Main Contract
contract AdvancedSandwichAttack is Ownable {
    ISwapRouter public immutable swapRouter;
    IUniswapV3Factory public immutable factory;
    IQuoter public immutable quoter;
    address public immutable WETH9;

    uint24 public poolFee;
    uint256 public gasPriceLimit;

    event SandwichAttackExecuted(uint256 profit, uint256 gasUsed);

    constructor(
        address _swapRouter,
        address _factory,
        address _quoter,
        address _WETH9,
        uint24 _poolFee,
        uint256 _gasPriceLimit
    ) {
        swapRouter = ISwapRouter(_swapRouter);
        factory = IUniswapV3Factory(_factory);
        quoter = IQuoter(_quoter);
        WETH9 = _WETH9;
        poolFee = _poolFee;
        gasPriceLimit = _gasPriceLimit;
    }

    receive() external payable {}

    modifier withinGasPriceLimit() {
        require(tx.gasprice <= gasPriceLimit, "Gas price exceeds limit");
        _;
    }

    function executeSandwich(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 slippageTolerance // Slippage tolerance in basis points (e.g., 50 = 0.5%)
    ) external onlyOwner withinGasPriceLimit {
        uint256 amountOutMinFrontRun;
        uint256 amountOutMinBackRun;
        uint256 amountOutFrontRun;
        uint256 amountOutBackRun;

        (amountOutMinFrontRun, amountOutMinBackRun) = calculateSlippageAdjustedAmounts(
            tokenIn,
            tokenOut,
            amountIn,
            slippageTolerance
        );

        // Step 1: Execute the front-run swap
        amountOutFrontRun = swap(tokenIn, tokenOut, amountIn, amountOutMinFrontRun);

        // Step 2: Execute the back-run swap (reverse)
        amountOutBackRun = swap(tokenOut, tokenIn, amountOutFrontRun, amountOutMinBackRun);

        // Calculate profit
        uint256 profit = amountOutBackRun - amountIn;
        emit SandwichAttackExecuted(profit, tx.gasprice);

        // Optional: Transfer profit to owner
        IERC20(tokenIn).transfer(owner(), profit);
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) internal returns (uint256 amountOut) {
        IERC20(tokenIn).approve(address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        amountOut = swapRouter.exactInputSingle(params);
    }

    function calculateSlippageAdjustedAmounts(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 slippageTolerance
    ) public view returns (uint256 amountOutMinFrontRun, uint256 amountOutMinBackRun) {
        // Simulate the front-run swap and get the quote
        uint256 amountOutQuotedFrontRun = quoter.quoteExactInputSingle(
            tokenIn,
            tokenOut,
            poolFee,
            amountIn,
            0
        );

        // Simulate the back-run swap and get the quote
        uint256 amountOutQuotedBackRun = quoter.quoteExactInputSingle(
            tokenOut,
            tokenIn,
            poolFee,
            amountOutQuotedFrontRun,
            0
        );

        // Calculate the minimum amounts out with slippage tolerance applied
        amountOutMinFrontRun = amountOutQuotedFrontRun * (10000 - slippageTolerance) / 10000;
        amountOutMinBackRun = amountOutQuotedBackRun * (10000 - slippageTolerance) / 10000;
    }

    function withdrawFunds(address token) external onlyOwner {
        if (token == WETH9) {
            IWETH9(WETH9).withdraw(IWETH9(WETH9).balanceOf(address(this)));
            payable(owner()).transfer(address(this).balance);
        } else {
            IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
        }
    }

    function withdrawETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setPoolFee(uint24 _poolFee) external onlyOwner {
        poolFee = _poolFee;
    }

    function setGasPriceLimit(uint256 _gasPriceLimit) external onlyOwner {
        gasPriceLimit = _gasPriceLimit;
    }

    
}