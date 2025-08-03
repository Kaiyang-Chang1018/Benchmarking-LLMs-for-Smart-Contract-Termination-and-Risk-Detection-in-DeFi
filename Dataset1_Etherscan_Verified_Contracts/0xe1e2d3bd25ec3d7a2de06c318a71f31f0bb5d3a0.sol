// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ISwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint256 amountOut);
}
interface IMaxBuyBackV1 {
    function getUsdcSwaps() external view returns (uint256);
    function getTokensSwap() external view returns (uint256);
}

contract MaxBuyBackV2 {
    ISwapRouter02 public swapRouter02;
    IMaxBuyBackV1 public maxBuyBackV1;
    
    address public usdc;
    address public weth;
    address public buyBackToken;
    address public owner;
    address public finalDestination;
    
    uint256 private totalUSDCSwappedV2;
    uint256 private totalTokensBoughtBackV2;
    uint24 private poolFeeIn;
    uint24 private tokenPoolFeeIn;

    uint256 public usdcAmountToSwap;       // Amount of USDC to swap each time for public function
    uint256 public swapInterval;           // Minimum interval in seconds between public swaps
    uint256 public lastSwapTime;           // Timestamp of the last public swap

    event TokensSwappedV2(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    event SwapSettingsUpdated(uint256 usdcAmountToSwap, uint256 swapInterval);

    constructor(
        address _v1Address,
        address _v3Router,
        address _usdc,
        address _weth,
        address _buyBackToken,
        uint24 _poolFeeIn,
        uint24 _tokenPoolFeeIn,
        address _finalDestination
    ) {
        owner = msg.sender;
        swapRouter02 = ISwapRouter02(_v3Router);
        maxBuyBackV1 = IMaxBuyBackV1(_v1Address);
        usdc = _usdc;
        weth = _weth;
        buyBackToken = _buyBackToken;
        poolFeeIn = _poolFeeIn;
        tokenPoolFeeIn = _tokenPoolFeeIn;
        finalDestination = _finalDestination;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function updateSwapSettings(uint256 _usdcAmountToSwap, uint256 _swapInterval) external onlyOwner {
        usdcAmountToSwap = _usdcAmountToSwap;
        swapInterval = _swapInterval;
        emit SwapSettingsUpdated(usdcAmountToSwap, swapInterval);
    }

    // Public swap function that can be called by anyone, respecting the time interval
    function triggerSwapAndBurn() external {
        require(block.timestamp >= lastSwapTime + swapInterval, "Swap interval not met");
        require(usdcAmountToSwap > 0, "USDC amount to swap not set");

        uint256 wethOut = _swapUSDCToWETH(usdcAmountToSwap);
        uint256 tokenAmount = _swapWETHForBuybackToken(wethOut);

        lastSwapTime = block.timestamp;

        totalUSDCSwappedV2 += usdcAmountToSwap;
        totalTokensBoughtBackV2 += tokenAmount;
    }

    
    function adminSwapAndBurn(uint256 _amountUSDC) external onlyOwner {
        uint256 wethOut = _swapUSDCToWETH(_amountUSDC);
        uint256 tokenAmount = _swapWETHForBuybackToken(wethOut);

        
        totalUSDCSwappedV2 += _amountUSDC;
        totalTokensBoughtBackV2 += tokenAmount;
    }

    function _swapUSDCToWETH(uint256 amount) internal returns (uint256 wethOut) {
        require(IERC20(usdc).balanceOf(address(this)) >= amount, "Insufficient USDC balance");

        IERC20(usdc).approve(address(swapRouter02), amount);

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02.ExactInputSingleParams({
            tokenIn: usdc,
            tokenOut: weth,
            fee: poolFeeIn,
            recipient: address(this),
            amountIn: amount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        wethOut = swapRouter02.exactInputSingle(params);
        IERC20(usdc).approve(address(swapRouter02), 0); 
        return wethOut;
    }

    function _swapWETHForBuybackToken(uint256 wethAmount) internal returns (uint256 tokenAmount) {
        require(IERC20(weth).balanceOf(address(this)) >= wethAmount, "Insufficient WETH balance");

        IERC20(weth).approve(address(swapRouter02), wethAmount);

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02.ExactInputSingleParams({
            tokenIn: weth,
            tokenOut: buyBackToken,
            fee: tokenPoolFeeIn,
            recipient: finalDestination,
            amountIn: wethAmount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        tokenAmount = swapRouter02.exactInputSingle(params);
        IERC20(weth).approve(address(swapRouter02), 0); 

        emit TokensSwappedV2(weth, buyBackToken, wethAmount, tokenAmount);
        return tokenAmount;
    }

    
    function getV1UsdcSwapped() public view returns (uint256) {
        return maxBuyBackV1.getUsdcSwaps();
    }

    function getV1TokensBoughtBack() public view returns (uint256) {
        return maxBuyBackV1.getTokensSwap();
    }

    
    function getV2UsdcSwapped() public view returns (uint256) {
        return totalUSDCSwappedV2;
    }

    function getV2TokensBoughtBack() public view returns (uint256) {
        return totalTokensBoughtBackV2;
    }

    
    function getTotalUsdcSwapped() public view returns (uint256) {
        return getV1UsdcSwapped() + totalUSDCSwappedV2;
    }

    function getTotalTokensBoughtBack() public view returns (uint256) {
        return getV1TokensBoughtBack() + totalTokensBoughtBackV2;
    }

    
    function updateRouter(address _v3Router) external onlyOwner {
        swapRouter02 = ISwapRouter02(_v3Router);
    }

    function updateFinalDestination(address _finalDestination) external onlyOwner {
        finalDestination = _finalDestination;
    }

    function updateBuyBackToken(address _buyBackToken) external onlyOwner {
        buyBackToken = _buyBackToken;
    }
}