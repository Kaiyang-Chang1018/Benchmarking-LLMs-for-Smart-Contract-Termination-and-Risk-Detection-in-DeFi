// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Begin IERC20Minimal.sol
interface IERC20Minimal {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// End IERC20Minimal.sol

// Begin IUniswapV3Pool.sol
interface IUniswapV3Pool {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    function fee() external view returns (uint24);
}

// End IUniswapV3Pool.sol

// Begin IUniswapV3Factory.sol
interface IUniswapV3Factory {
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);
}

// End IUniswapV3Factory.sol

// Begin ISwapRouter.sol
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

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);
}

// End ISwapRouter.sol

// Begin TransferHelper.sol
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal.approve.selector, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal.transfer.selector, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal.transferFrom.selector, from, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }
}

// End TransferHelper.sol

// Begin MEV_SandwichBot.sol
contract MEV_SandwichBot {
    address public owner;
    ISwapRouter public swapRouter;
    IUniswapV3Factory public factory;
    address public liquidityPool;
    bool public isActive;

    uint24 public constant poolFee = 10000;

    event SandwichAttackExecuted(uint256 profit, uint256 gasUsed);

    constructor(address _swapRouter, address _factory, address _liquidityPool) {
        owner = msg.sender;
        swapRouter = ISwapRouter(_swapRouter);
        factory = IUniswapV3Factory(_factory);
        liquidityPool = _liquidityPool;
        isActive = false;  // Initialize as inactive
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyWhenActive() {
        require(isActive, "Contract is not active");
        _;
    }

    function start() external onlyOwner {
        isActive = true;
    }

    function stop() external onlyOwner {
        isActive = false;
    }

    function executeSandwich(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMinFrontRun,
        uint256 amountOutMinBackRun,
        uint256 maxGasPrice
    ) external onlyOwner onlyWhenActive {
        // Validate that the provided pool matches the tokens and fee tier
        address poolAddress = factory.getPool(tokenIn, tokenOut, poolFee);
        require(poolAddress == liquidityPool, "Invalid pool address");

        // Get current gas price
        uint256 gasPrice = tx.gasprice;
        require(gasPrice <= maxGasPrice, "Gas price exceeds limit");

        // Front-run the victim's trade
        uint256 amountOut1 = swapExactInputSingle(tokenIn, tokenOut, amountIn, amountOutMinFrontRun);

        // Ensure the front-run trade is profitable
        require(amountOut1 > amountOutMinFrontRun, "Front-run trade not profitable");

        // Here, you should have off-chain logic that waits for the victim's transaction to be mined
        // You would use an off-chain bot to monitor the mempool and ensure the correct timing

        // Back-run the victim's trade
        uint256 amountOut2 = swapExactInputSingle(tokenOut, tokenIn, amountOut1, amountOutMinBackRun);

        // Ensure the back-run trade is profitable
        require(amountOut2 > amountIn, "Back-run trade not profitable");

        // Calculate profit
        uint256 profit = amountOut2 - amountIn;

        // Emit an event to track the attack
        emit SandwichAttackExecuted(profit, gasPrice);
    }

    function swapExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) internal returns (uint256 amountOut) {
        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,  // Ensure it uses the 1% fee tier
                recipient: address(this),
                deadline: block.timestamp + 15,
                amountIn: amountIn,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }

    function withdrawFunds(address token) external onlyOwner {
        uint256 balance = IERC20Minimal(token).balanceOf(address(this));
        TransferHelper.safeTransfer(token, owner, balance);
    }

    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}

// End MEV_SandwichBot.sol