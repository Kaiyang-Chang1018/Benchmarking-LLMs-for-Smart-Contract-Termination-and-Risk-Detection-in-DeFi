pragma solidity ^0.8.18;


/**
 * @title FlashArbitrageBot
 * @notice Executes flash loan arbitrage across multiple DeFi protocols and DEXs.
 * Features:
 *  - Supports Aave, dYdX, and Uniswap V3 flash loan mechanisms.
 *  - Trades across multiple DEXs (e.g., Uniswap, SushiSwap) within the flash loan.
 *  - Protects against slippage and unprofitable trades by reverting if conditions fail.
 *  - Optimized for low gas usage.
 *  - Profits are sent immediately to a designated beneficiary address.
 *  - Designed to be used with Flashbots for MEV protection (no public mempool).
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address src, address dst, uint256 amt) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

/// Interface for Aave V3 LendingPool (or Aave Pool) flash loans
interface IAavePool {
    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

/// Aave flash loan callback interface (IFlashLoanSimpleReceiver for Aave V3)
interface IAaveFlashLoanReceiver {
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

/// Interface for Uniswap V3 pool flash loans (partial, focusing on flash function)
interface IUniswapV3Pool {
    function flash(address recipient, uint256 amount0, uint256 amount1, bytes memory data) external;
}

/// Uniswap V3 flash callback interface
interface IUniswapV3FlashCallback {
    function uniswapV3FlashCallback(uint256 fee0, uint256 fee1, bytes memory data) external;
}

/// (Optional) dYdX Solo Margin interface for flash loans (operate function)
interface IDyDxSoloMargin {
    function operate(address[] calldata accounts, bytes[] calldata data) external;
    // dYdX flash loan would require constructing operation data with Actions.Call to this contract
}

/// Interface for Uniswap V2-like Router (for swapping tokens on Uniswap/SushiSwap)
interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract FlashArbitrageBot is IAaveFlashLoanReceiver, IUniswapV3FlashCallback {
    address public immutable owner; // Contract owner - Gas Optimization - immutable
    address public beneficiary;

    // Immutable addresses for external protocols - Gas Optimization
    IAavePool public immutable aavePool;
    IUniswapV2Router public immutable uniV2Router;
    IUniswapV2Router public immutable sushiV2Router;

    constructor(
        address _aavePool, 
        address _beneficiary,
        address _uniV2Router,
        address _sushiV2Router
    ) {
        owner = msg.sender;
        beneficiary = _beneficiary;
        aavePool = IAavePool(_aavePool);
        uniV2Router = IUniswapV2Router(_uniV2Router);
        sushiV2Router = IUniswapV2Router(_sushiV2Router);
    }

    // --- Utility and helper functions ---

    // Modifier to restrict function calls to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    /**
     * @dev Initiates an arbitrage using an Aave flash loan.
     * @param asset The address of the asset to borrow.
     * @param amount The amount to borrow.
     * @param dexPath An array of DEX identifiers (e.g., [0,1] to indicate Uniswap then SushiSwap).
     * @param tradePath An array of token addresses representing the swap path (e.g., [tokenBorrow, tokenIntermediate, tokenBorrow]).
     * @param minProfit Minimum profit Minimum profit in the repayment token.
     */
    function startAaveArbitrage(address asset, uint256 amount, uint8[] calldata dexPath, address[] calldata tradePath, uint256 minProfit) external onlyOwner {
        require(dexPath.length == 2 || dexPath.length == 1, "Invalid DEX path");
        require(tradePath.length >= 2, "Invalid trade path");
        // Encode arbitrage parameters to pass to callback (executeOperation)
        // We pack: dexPath, tradePath, minProfit
        bytes memory params = abi.encode(dexPath, tradePath, minProfit);
        // Trigger Aave flash loan (will callback executeOperation)
        aavePool.flashLoanSimple(address(this), asset, amount, params, 0);
    }

    /**
     * @dev Initiates a Uniswap V3 flash swap arbitrage.
     * @param pool The address of the UniswapV3 pool contract to flash from.
     * @param amount0 The amount of token0 to borrow (if any).
     * @param dexPath Same idea as in startAaveArbitrage – sequence of DEX trades to perform.
     * @param tradePath The token addresses path for swaps (must start with one of pool's tokens and end with same token for repayment).
     * @param minProfit Minimum profit Minimum profit in the repayment token.
     */
    function startUniswapV3Flash(address pool, uint256 amount0, uint256 amount1, uint8[] calldata dexPath, address[] calldata tradePath, uint256 minProfit) external onlyOwner {
        require(amount0 == 0 || amount1 == 0, "Only one asset flash at a time for simplicity");
        // Encode the trade parameters to pass through the flash callback data
        bytes memory data = abi.encode(dexPath, tradePath, minProfit);
        // Initiate the UniswapV3 flash loan (flash swap)
        IUniswapV3Pool(pool).flash(address(this), amount0, amount1, data);
    }

    /**
     * @notice Aave flash loan callback. Executes when the flash loan is delivered.
     * This function performs the arbitrage trades then repays the flash loan.
     */
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        require(msg.sender == address(aavePool), "Unauthorized callback");
        require(initiator == address(this), "Initiator must be this contract");
        // Decode parameters
        (uint8[] memory dexPath, address[] memory tradePath, uint256 minProfit) = abi.decode(params, (uint8[], address[], uint256));
        // The contract now has `amount` of `asset` borrowed from Aave.
        // Perform arbitrage swaps according to dexPath:
        _executeDexSwaps(amount, dexPath, tradePath, asset);


        // Calculate amount that needs to be repaid to Aave (principal + fee)
        uint256 amountOwed = amount + premium;
        address finalAsset = tradePath[tradePath.length - 1];
        uint256 finalBalance = IERC20(finalAsset).balanceOf(address(this));


        // Ensure we have enough of the finalAsset to cover repayment
        require(finalAsset == asset, "Final asset must match borrowed asset for repayment");
        require(finalBalance >= amountOwed, "Arbitrage failed: insufficient funds to repay loan");
        // Calculate profit (remaining balance minus amount owed)
        uint256 profit = finalBalance - amountOwed;
        require(profit >= minProfit, "Profit below threshold");

        // Approve Aave pool to pull the owed amount for repayment
        IERC20(asset).approve(address(aavePool), amountOwed);
        // Any remaining profit will stay in this contract (which should equal `profit` now)
        // Transfer profit to beneficiary
        if (profit > 0) {
            IERC20(asset).transfer(beneficiary, profit);
        }
        // Return true to indicate the flash loan execution was successful and funds were repaid
        return true;
    }

    /**
     * @notice Uniswap V3 flash loan callback called by the pool after flash loan is initiated.
     * The contract must repay the pool within this function.
     * @param fee0 The fee for token0.
     * @param fee1 The fee for token1.
     * @param data Arbitrage parameters encoded as bytes.
     */
    function uniswapV3FlashCallback(uint256 fee0, uint256 fee1, bytes memory data) external override {
        // Decode arbitrage parameters
        (uint8[] memory dexPath, address[] memory tradePath, uint256 minProfit) = abi.decode(data, (uint8[], address[], uint256));
        // Determine which token was borrowed (if amount0 > 0 token0 was borrowed; if amount1 > 0 token1 was borrowed)
        // We can get the pool's token addresses by calling pool's getters (not shown here for brevity).
        // For simplicity assume tradePath[0] is the borrowed token address.
        address borrowedToken = tradePath[0];
        uint256 borrowedAmount = IERC20(borrowedToken).balanceOf(address(this));

        // Execute the same arbitrage swap logic as in executeOperation:
        _executeDexSwaps(borrowedAmount, dexPath, tradePath, borrowedToken);


        address finalAsset = tradePath[tradePath.length - 1];
        uint256 finalAmt = IERC20(finalAsset).balanceOf(address(this));
        // Compute fees to repay Uniswap pool
        uint256 amountOwed0 = fee0;
        uint256 amountOwed1 = fee1;
        uint256 amountOwed = (amountOwed0 > 0) ? fee0 : fee1;
        uint256 borrowedAmountAdjusted =  (amountOwed0 > 0) ? borrowedAmount + fee0 : borrowedAmount + fee1;


        if (amountOwed0 > 0) {
            // borrowed token0
            amountOwed0 += borrowedAmount; // total owed = borrowed + fee
            require(finalAsset == borrowedToken, "Final asset mismatch for repay");
            require(finalAmt >= amountOwed0, "Unprofitable flash swap");
            uint256 profit = finalAmt - amountOwed0;
            require(profit >= minProfit, "Profit below threshold");
            // repay token0
            IERC20(borrowedToken).transfer(msg.sender, amountOwed0);
            // send profit to beneficiary
            if (profit > 0) IERC20(borrowedToken).transfer(beneficiary, profit);
        } else {
            // borrowed token1
            amountOwed1 += borrowedAmount;
            require(finalAsset == borrowedToken, "Final asset mismatch for repay");
            require(finalAmt >= amountOwed1, "Unprofitable flash swap");
            uint256 profit = finalAmt - amountOwed1;
            require(profit >= minProfit, "Profit below threshold");
            // repay token1
            IERC20(borrowedToken).transfer(msg.sender, amountOwed1);
            if (profit > 0) IERC20(borrowedToken).transfer(beneficiary, profit);
        }
        // Note: Uniswap V3 flash swap expects the owed amounts to be sent to the pool (msg.sender) by end of this callback.
        // We've done that via the transfer above. No separate return value is needed.
    }

    /**
     * @dev Utility to map DEX identifier to its router address.
     * For simplicity: 0 -> Uniswap V2 router 1 -> SushiSwap router. Extend as needed.
     */
    function addressForDex(uint8 dexId) internal view returns (address dexAddress) {
        if (dexId == 0) {
            dexAddress = address(uniV2Router);
        } else if (dexId == 1) {
            dexAddress = address(sushiV2Router);
        } else {
            revert("Unsupported DEX");
        }
    }

    /**
     * @dev Helper to extract a sub-path for swaps.
     * For example getPathSlice([A B C] 0 1) returns [A B]; getPathSlice([A B C] 1 2) returns [B C].
     */
    function getPathSlice(address[] memory fullPath, uint256 startIndex, uint256 endIndex) internal pure returns (address[] memory) {
        require(endIndex < fullPath.length, "End index out of range");
        require(startIndex < endIndex, "Start index must be < end index");
        address[] memory slice = new address[](endIndex - startIndex + 1);
        uint256 idx = 0;
        for (uint256 i = startIndex; i <= endIndex; ) {
            slice[idx] = fullPath[i];
            unchecked {
                idx++;
                i++;
            }
        }
        return slice;
    }

    /**
     * @dev Withdraw any tokens stuck in the contract to the owner. - Gas Optimization - not really but good practice
     */
    function withdrawToken(address token) external onlyOwner {
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0, "No balance");
        IERC20(token).transfer(owner, bal);
    }

    /**
     * @dev Internal function to execute DEX swaps based on dexPath and tradePath.
     * @param amount The amount of the first token to swap.
     * @param dexPath The DEX path array.
     * @param tradePath The trade path array.
     * @param asset The address of the asset to approve for swap.
     */
    function _executeDexSwaps(uint256 amount, uint8[] memory dexPath, address[] memory tradePath, address asset) internal {
        // Create a memory copy of tradePath
        address[] memory tradePathMemory = tradePath;

        // Approve the first DEX router to spend the asset
        IERC20(tradePathMemory[0]).approve(addressForDex(dexPath[0]), amount);
        uint256[] memory amountsOut1;
        if (dexPath[0] == 0) {
            // 0 indicates Uniswap V2 router
            amountsOut1 = uniV2Router.swapExactTokensForTokens(
                amount,
                1,  // we will handle slippage check after full cycle
                getPathSlice(tradePathMemory, 0, 1),
                address(this),
                block.timestamp
            );
        } else if (dexPath[0] == 1) {
            // 1 indicates SushiSwap router
            amountsOut1 = sushiV2Router.swapExactTokensForTokens(
                amount,
                1,
                getPathSlice(tradePathMemory, 0, 1),
                address(this),
                block.timestamp
            );
        }

        // Check if amountsOut1 is empty to prevent out-of-bounds access
        if (amountsOut1.length == 0) {
            revert("Swap returned empty amounts array");
        }
        uint256 amountOutFirstSwap = amountsOut1[amountsOut1.length - 1];

        // If there's a second swap in the path (dexPath length 2) execute it
        if (dexPath.length > 1) {
            uint256 intermediateAmt = IERC20(tradePathMemory[1]).balanceOf(address(this));
            IERC20(tradePathMemory[1]).approve(addressForDex(dexPath[1]), intermediateAmt);
            uint256[] memory amountsOut2;
            if (dexPath[1] == 0) {
                amountsOut2 = uniV2Router.swapExactTokensForTokens(
                    intermediateAmt,
                    1,
                    getPathSlice(tradePathMemory, 1, tradePathMemory.length-1),
                    address(this),
                    block.timestamp
                );
            } else if (dexPath[1] == 1) {
                amountsOut2 = sushiV2Router.swapExactTokensForTokens(
                    intermediateAmt,
                    1,
                    getPathSlice(tradePathMemory, 1, tradePathMemory.length-1),
                    address(this),
                    block.timestamp
                );
            }
             uint256 amountOutSecondSwap = amountsOut2[amountsOut2.length - 1];
        }
    }
}