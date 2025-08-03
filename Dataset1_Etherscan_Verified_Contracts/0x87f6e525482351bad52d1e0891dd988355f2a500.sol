// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IPool {
    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

contract FlashLoanArbitrage is ReentrancyGuard {
    address public owner;
    address public immutable POOL_ADDRESS;
    address public uniswapRouter;
    address public sushiswapRouter;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    // Tracking variables
    uint256 private executionCount = 0;
    uint256 private totalProfit = 0;
    
    // Circuit breaker flag
    bool public isPaused = false;

    // Events for debugging and monitoring
    event DebugString(string label, string message);
    event DebugUint(string label, uint256 value);
    event DebugAddress(string label, address addr);
    event DebugArray(string label, uint256[] values);
    event FlashLoanStarted(address indexed asset, uint amount);
    event FlashLoanExecuted(address indexed asset, uint amount, uint premium);
    event ArbitrageExecuted(
        address tokenAddress,
        uint256 flashLoanAmount,
        uint256 profit,
        string buyDex,
        string sellDex
    );
    event ProfitWithdrawn(address recipient, uint256 amount);
    event ErrorOccurred(string errorType, string reason);

    constructor(address _pool, address _uniswap, address _sushiswap) {
        owner = msg.sender;
        POOL_ADDRESS = _pool;
        uniswapRouter = _uniswap;
        sushiswapRouter = _sushiswap;
    }

    // Modifier to restrict functions to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Function to set emergency pause
    function setPaused(bool _isPaused) external onlyOwner {
        isPaused = _isPaused;
        emit DebugString("Pause Status", _isPaused ? "Paused" : "Unpaused");
    }

    receive() external payable {}

    function executeFlashLoan(address asset, uint256 amount) external onlyOwner {
        require(!isPaused, "Contract is paused");
        require(amount > 0, "Amount must be greater than 0");

        // Track execution count
        executionCount++;
        
        address[] memory assets = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        uint256[] memory modes = new uint256[](1);
        assets[0] = asset;
        amounts[0] = amount;
        modes[0] = 0;

        emit FlashLoanStarted(asset, amount);
        bytes memory params = abi.encode(asset);

        try IPool(POOL_ADDRESS).flashLoan(
            address(this),
            assets,
            amounts,
            modes,
            address(this),
            params,
            0
        ) {
            emit DebugString("FlashLoan", "Success");
        } catch Error(string memory reason) {
            emit DebugString("FlashLoan Error", reason);
            emit ErrorOccurred("Flash loan failed", reason);
            revert(string(abi.encodePacked("FlashLoan failed: ", reason)));
        } catch {
            emit DebugString("FlashLoan Error", "Unknown error");
            emit ErrorOccurred("Low-level flash loan error", "Unknown error");
            revert("FlashLoan failed: Unknown error");
        }
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external nonReentrant returns (bool) {
        require(msg.sender == POOL_ADDRESS, "Caller must be Pool");
        require(initiator == address(this), "Bad initiator");

        emit DebugString("Executing Operation", "Start");
        emit DebugAddress("Asset", asset);
        emit DebugUint("Amount", amount);
        emit DebugUint("Premium", premium);

        // Execute arbitrage
        _executeArbitrage(asset, amount, premium);

        // Ensure we have enough to repay
        uint256 tokenBalance = IERC20(asset).balanceOf(address(this));
        uint256 totalRepay = amount + premium;
        require(tokenBalance >= totalRepay, "Not enough tokens to repay the loan");
        
        // Approve repayment
        IERC20(asset).approve(POOL_ADDRESS, totalRepay);
        emit DebugUint("Total Repayment", totalRepay);
        
        emit FlashLoanExecuted(asset, amount, premium);
        return true;
    }

    // Separated to avoid stack too deep errors
    function _executeArbitrage(address asset, uint256 amount, uint256 premium) internal {
        // Check prices on both DEXes to determine optimal path
        (uint256 uniswapPrice, uint256 sushiswapPrice) = checkPrices(asset, amount);
        emit DebugUint("Uniswap Price", uniswapPrice);
        emit DebugUint("Sushiswap Price", sushiswapPrice);
        
        if (uniswapPrice > sushiswapPrice) {
            _executeSushiToUniArbitrage(asset, amount, premium, uniswapPrice, sushiswapPrice);
        } else {
            _executeUniToSushiArbitrage(asset, amount, premium, uniswapPrice, sushiswapPrice);
        }
    }

    // Arbitrage from Sushiswap to Uniswap
    function _executeSushiToUniArbitrage(
        address asset, 
        uint256 amount, 
        uint256 premium,
        uint256 uniswapPrice, 
        uint256 sushiswapPrice
    ) internal {
        string memory buyDex = "Sushiswap";
        string memory sellDex = "Uniswap";
        
        // Calculate minimum amounts with slippage protection (2%)
        uint256 minOutput = calculateMinimumAmountOut(sushiswapPrice, 98);
        
        // Execute swaps with slippage protection
        IERC20(asset).approve(sushiswapRouter, amount);
        
        // Path: asset -> WETH
        address[] memory path = new address[](2);
        path[0] = asset;
        path[1] = WETH;
        
        uint[] memory sushiOut;
        
        try IUniswapV2Router(sushiswapRouter).swapExactTokensForTokens(
            amount,
            minOutput,
            path,
            address(this),
            block.timestamp + 20 minutes
        ) returns (uint[] memory amounts) {
            sushiOut = amounts;
            emit DebugArray("Sushiswap Output", sushiOut);
            
            // Execute second part of arbitrage
            _executeSecondSwap(
                asset,
                amount,
                premium,
                sushiOut[1],  // WETH amount
                uniswapRouter, // Sell on Uniswap
                buyDex,
                sellDex
            );
        } catch Error(string memory reason) {
            emit ErrorOccurred("Sushiswap execution error", reason);
            emit DebugString("Sushiswap Error", reason);
        } catch {
            emit ErrorOccurred("Sushiswap low-level error", "Unknown error");
            emit DebugString("Sushiswap Error", "Failed to execute swap");
        }
    }

    // Arbitrage from Uniswap to Sushiswap
    function _executeUniToSushiArbitrage(
        address asset, 
        uint256 amount, 
        uint256 premium,
        uint256 uniswapPrice, 
        uint256 sushiswapPrice
    ) internal {
        string memory buyDex = "Uniswap";
        string memory sellDex = "Sushiswap";
        
        // Calculate minimum amounts with slippage protection (2%)
        uint256 minOutput = calculateMinimumAmountOut(uniswapPrice, 98);
        
        // Path: asset -> WETH
        address[] memory path = new address[](2);
        path[0] = asset;
        path[1] = WETH;
        
        IERC20(asset).approve(uniswapRouter, amount);
        
        uint[] memory uniOut;
        
        try IUniswapV2Router(uniswapRouter).swapExactTokensForTokens(
            amount,
            minOutput,
            path,
            address(this),
            block.timestamp + 20 minutes
        ) returns (uint[] memory amounts) {
            uniOut = amounts;
            emit DebugArray("Uniswap Output", uniOut);
            
            // Execute second part of arbitrage
            _executeSecondSwap(
                asset,
                amount,
                premium,
                uniOut[1],  // WETH amount
                sushiswapRouter, // Sell on Sushiswap
                buyDex,
                sellDex
            );
        } catch Error(string memory reason) {
            emit ErrorOccurred("Uniswap execution error", reason);
            emit DebugString("Uniswap Error", reason);
        } catch {
            emit ErrorOccurred("Uniswap low-level error", "Unknown error");
            emit DebugString("Uniswap Error", "Failed to execute swap");
        }
    }

    // Second swap for arbitrage
    function _executeSecondSwap(
        address asset,
        uint256 amount,
        uint256 premium,
        uint256 wethAmount,
        address router,
        string memory buyDex,
        string memory sellDex
    ) internal {
        // Path: WETH -> asset
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = asset;
        
        // Calculate minimum amounts with slippage protection (2%)
        uint256 minTokenOutput = calculateMinimumAmountOut(amount + premium, 98);
        
        IERC20(WETH).approve(router, wethAmount);
        
        try IUniswapV2Router(router).swapExactTokensForTokens(
            wethAmount,
            minTokenOutput,
            path,
            address(this),
            block.timestamp + 20 minutes
        ) returns (uint[] memory amounts) {
            emit DebugArray("Second Swap Output", amounts);
            
            // Calculate profit
            uint256 finalTokenAmount = amounts[1];
            uint256 totalRepay = amount + premium;
            
            if (finalTokenAmount > totalRepay) {
                uint256 profit = finalTokenAmount - totalRepay;
                totalProfit += profit;
                emit ArbitrageExecuted(asset, amount, profit, buyDex, sellDex);
            }
        } catch Error(string memory reason) {
            emit ErrorOccurred("Second swap execution error", reason);
            emit DebugString("Second Swap Error", reason);
        } catch {
            emit ErrorOccurred("Second swap low-level error", "Unknown error");
            emit DebugString("Second Swap Error", "Failed to execute swap");
        }
    }

    /**
     * @dev Check prices on both DEXes
     */
    function checkPrices(address tokenAddress, uint256 amount) internal view returns (uint256, uint256) {
        // Create path
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = WETH;
        
        // Get price on Uniswap
        uint256 uniswapPrice;
        try IUniswapV2Router(uniswapRouter).getAmountsOut(amount, path) returns (uint256[] memory amounts) {
            uniswapPrice = amounts[1];
        } catch {
            uniswapPrice = 0;
        }
        
        // Get price on Sushiswap
        uint256 sushiswapPrice;
        try IUniswapV2Router(sushiswapRouter).getAmountsOut(amount, path) returns (uint256[] memory amounts) {
            sushiswapPrice = amounts[1];
        } catch {
            sushiswapPrice = 0;
        }
        
        return (uniswapPrice, sushiswapPrice);
    }
    
    /**
     * @dev Calculate minimum amount out with given percentage of desired amount
     */
    function calculateMinimumAmountOut(uint256 amount, uint256 percentage) internal pure returns (uint256) {
        return amount * percentage / 100;
    }
    
    /**
     * @dev Test function for simple swaps
     */
    function testSwap(
        address tokenAddress,
        uint256 amountIn,
        address routerAddress
    ) external onlyOwner returns (uint256) {
        // Approve router to spend tokens
        IERC20(tokenAddress).approve(routerAddress, amountIn);
        
        // Prepare swap path
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = WETH; // WETH address
        
        // Get minimum amount out with 2% slippage
        uint256[] memory amountsOut = IUniswapV2Router(routerAddress).getAmountsOut(amountIn, path);
        uint256 minAmountOut = amountsOut[1] * 98 / 100; // 2% slippage
        
        // Execute swap with deadline 20 minutes in the future
        uint256[] memory amounts = IUniswapV2Router(routerAddress).swapExactTokensForTokens(
            amountIn,
            minAmountOut,
            path,
            address(this),
            block.timestamp + 20 minutes
        );
        
        return amounts[1]; // Return amount of WETH received
    }
    
    /**
     * @dev Allow owner to withdraw profits
     */
    function withdrawProfit(address token, address recipient) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "No balance to withdraw");
        
        IERC20(token).transfer(recipient, balance);
        emit ProfitWithdrawn(recipient, balance);
    }
    
    /**
     * @dev Allow owner to withdraw ETH
     */
    function withdrawETH(address payable recipient, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient ETH balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH transfer failed");
    }
    
    /**
     * @dev Reset owner in case of emergency
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
}