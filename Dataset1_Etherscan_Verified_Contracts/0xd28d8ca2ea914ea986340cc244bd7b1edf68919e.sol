/**
 *Submitted for verification at Etherscan.io on 2024-01-22
*/

pragma solidity 0.8.20;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IMAGA {
    function manualSwap() external;
}

interface IUniswapV2Router02 {
    function swapExactTokensForETH(
        uint256 amountIn, 
        uint256 amountOutMin, 
        address[] calldata path, 
        address to, 
        uint256 deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function WETH() external pure returns (address);
}

contract MAGASwap {
    address private owner;
    IUniswapV2Router02 private uniswapRouter;
    address private magaTokenAddress;
    address private wethAddress;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _uniswapRouter, address _magaToken) {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        magaTokenAddress = _magaToken;
        wethAddress = uniswapRouter.WETH();
    }

    function run(uint256 magaAmount) external onlyOwner {
        require(IERC20(magaTokenAddress).balanceOf(address(this)) >= magaAmount, "Insufficient MAGA");

        // Approve Uniswap Router to spend MAGA
        IERC20(magaTokenAddress).approve(address(uniswapRouter), magaAmount);

        // Sell MAGA for ETH
        address[] memory path = new address[](2);
        path[0] = magaTokenAddress;
        path[1] = wethAddress;
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            magaAmount, 
            0, 
            path, 
            address(this), 
            block.timestamp + 300
        );

        // Call manualSwap on the MAGA contract
        IMAGA(magaTokenAddress).manualSwap();

        // Buy back MAGA with all ETH in this contract
        uint256 ethBalance = address(this).balance;
        path[0] = wethAddress;
        path[1] = magaTokenAddress;
        uniswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: ethBalance }(
            magaAmount, 
            path, 
            address(this), 
            block.timestamp + 300
        );
    }

    // Function to receive ETH when swapping
    receive() external payable {}

    // Withdraw function for owner to remove tokens or ETH
    function withdrawToken(address tokenAddress) external onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(owner, balance);
    }

    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}