// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}



interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function WETH() external pure returns (address);
}


contract AdvancedCryptoBot is Ownable, Pausable {
    IUniswapV2Router02 public uniswapRouter;
    

    uint public slippageTolerance; // Percentage of slippage allowed
    uint public tradeSize; // Percentage of balance to trade
    uint public aggressiveness; // Controls how often trades happen
    uint public stopLossPercentage; // Stop-loss as percentage of price drop
    uint public takeProfitPercentage; // Take-profit as percentage of price increase

    uint public lastTradeTime; // To track when the last trade occurred
    uint public minTradeInterval; // Minimum time interval between trades to control aggressiveness

    event TradeExecuted(address indexed tokenIn, address indexed tokenOut, uint amountIn, uint amountOut);
    event StopLossTriggered(address indexed token, uint price);
    event TakeProfitTriggered(address indexed token, uint price);

    modifier tradeIntervalPassed() {
        require(block.timestamp >= lastTradeTime + minTradeInterval, "Trade interval not passed yet");
        _;
    }

    constructor (
        address _uniswapRouter,
        uint _slippageTolerance,
        uint _tradeSize,
        uint _aggressiveness,
        uint _stopLossPercentage,
        uint _takeProfitPercentage,
        uint _minTradeInterval
    ) public payable Ownable() {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        slippageTolerance = _slippageTolerance;
        tradeSize = _tradeSize;
        aggressiveness = _aggressiveness;
        stopLossPercentage = _stopLossPercentage;
        takeProfitPercentage = _takeProfitPercentage;
        minTradeInterval = _minTradeInterval;
        lastTradeTime = block.timestamp;
    }

    // Control the aggressiveness of the bot by adjusting trade frequency
    function setAggressiveness(uint _aggressiveness) external onlyOwner {
        aggressiveness = _aggressiveness;
        minTradeInterval = aggressiveness * 1 minutes;
    }

    // Set slippage tolerance
    function setSlippageTolerance(uint _slippageTolerance) external onlyOwner {
        slippageTolerance = _slippageTolerance;
    }

    // Set trade size
    function setTradeSize(uint _tradeSize) external onlyOwner {
        tradeSize = _tradeSize;
    }

    // Set stop loss threshold
    function setStopLossPercentage(uint _stopLossPercentage) external onlyOwner {
        stopLossPercentage = _stopLossPercentage;
    }

    // Set take profit threshold
    function setTakeProfitPercentage(uint _takeProfitPercentage) external onlyOwner {
        takeProfitPercentage = _takeProfitPercentage;
    }

    // Function to swap tokens with aggressiveness control
    function swapTokens(address tokenIn, address tokenOut, uint amountIn) internal onlyOwner tradeIntervalPassed whenNotPaused {
        uint balanceIn = IERC20(tokenIn).balanceOf(address(this));
        require(balanceIn >= amountIn, "Insufficient balance to trade");

        uint amountOutMin = getAmountOutMin(tokenIn, tokenOut, amountIn);

        // Approve Uniswap Router to spend tokens
        IERC20(tokenIn).approve(address(uniswapRouter), amountIn);

        // Define the path of the swap (e.g., tokenIn -> WETH -> tokenOut)
        address[] memory path = getPath(tokenIn, tokenOut);

        // Execute the trade
        uint[] memory amounts = uniswapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp);

        emit TradeExecuted(tokenIn, tokenOut, amountIn, amounts[amounts.length - 1]);

        lastTradeTime = block.timestamp; // Update last trade time
    }

    // Function to pause the contract (only by the owner)
    function pause() external onlyOwner {
        _pause();
    }

    // Function to unpause the contract (only by the owner)
    function unpause() external onlyOwner {
        _unpause();
    }

    // Function to calculate the minimum amountOut with slippage tolerance
    function getAmountOutMin(address tokenIn, address tokenOut, uint amountIn) public view returns (uint) {
        uint[] memory amountsOut = uniswapRouter.getAmountsOut(amountIn, getPath(tokenIn, tokenOut));
        uint amountOutMin = amountsOut[amountsOut.length - 1];
        
        uint slippage = (amountOutMin * slippageTolerance) / 100;
        return amountOutMin - slippage;
    }

    // Define the path of the token swap
    function getPath(address tokenIn, address tokenOut) internal view returns (address[] memory path) {
        if (tokenIn == uniswapRouter.WETH()) {
            path = new address[](2) ;
            path[0] = tokenIn;
            path[1] = tokenOut;
        } else if (tokenOut == uniswapRouter.WETH()) {
            path = new address[](2) ;
            path[0] = tokenIn;
            path[1] = tokenOut;
        } else {
            path = new address[](3) ;
            path[0] = tokenIn;
            path[1] = uniswapRouter.WETH();
            path[2] = tokenOut;
        }
    }

    // Risk management: Stop-loss trigger
    function checkStopLoss(address token, uint buyPrice, uint currentPrice, address tokenOut) external onlyOwner {
        uint priceDrop = (buyPrice - currentPrice) * 100 / buyPrice;
        if (priceDrop >= stopLossPercentage) {
            emit StopLossTriggered(token, currentPrice);
            uint amountIn = IERC20(token).balanceOf(address(this));
            require(amountIn > 0, "No tokens to sell");
            swapTokens(token, tokenOut, amountIn);
        }
    }

    // Risk management: Take-profit trigger
    function checkTakeProfit(address token, uint buyPrice, uint currentPrice, address tokenOut) external onlyOwner {
        uint priceIncrease = (currentPrice - buyPrice) * 100 / buyPrice;
        if (priceIncrease >= takeProfitPercentage) {
            emit TakeProfitTriggered(token, currentPrice);
            uint amountIn = IERC20(token).balanceOf(address(this));
            require(amountIn > 0, "No tokens to sell");
            swapTokens(token, tokenOut, amountIn);
        }
    }

    // Function to withdraw ERC20 tokens
    function withdrawERC20(address token, uint amount) external onlyOwner {
        require(IERC20(token).transfer(owner(), amount), "Transfer failed");
    }

    // Function to withdraw ETH
    function withdrawETH(uint amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    // Function to receive ETH
    receive() external payable {}
}