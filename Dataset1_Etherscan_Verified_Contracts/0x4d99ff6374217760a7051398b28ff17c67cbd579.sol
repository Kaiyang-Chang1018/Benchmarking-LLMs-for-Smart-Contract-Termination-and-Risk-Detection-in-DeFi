// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract SwapContract {
    // IUniswapV2Router02 public uniswapV2Router;
    // address public uniswapV2Factory;
    // address public uniswapV2Pair;
    address public owner;

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address private constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant UNISWAP_V2_FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    
    IUniswapV2Router private router = IUniswapV2Router(UNISWAP_V2_ROUTER);
    IUniswapV2Factory private factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);

    constructor() {
        owner = msg.sender; // set the contract deployer as the owner
    }

    function buyToken(address _tokenAddress, uint256 _amountOut, uint8 preSlippage, uint8 postSlippage) external payable {
        address uniswapV2Pair = factory.getPair(_tokenAddress, WETH);
        require(address(uniswapV2Pair) != address(0), "No liquidity pool exists for this token");

        // IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
        // address token0 = pair.token0();

        // (uint112 reserve0,uint112 reserve1,) = pair.getReserves();
        // if (token0 == WETH) {
        //     require(reserve0 >= 1e18, "Less than 1 eth");
        // }
        // else {
        //     require(reserve1 >= 1e18, "Less than 1 eth");
        // }

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = _tokenAddress;
        
        // calculate output amount and apply slippage
        uint256 amountOut = router.getAmountsOut(msg.value, path)[1];
        uint256 amountOutMin = amountOut - (postSlippage * amountOut / 100);  // Decrease by % for slippage

        require(amountOut > _amountOut - (preSlippage * _amountOut / 100), "Price slipped");

        uint256 deadline = block.timestamp + 1 minutes;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value }(
            amountOutMin,
            path,
            address(this),
            deadline
        );

        IERC20 token = IERC20(_tokenAddress);
        uint256 maxUint = type(uint256).max;
        bool success = token.approve(address(this), maxUint);
        require(success, "approve 1 failed");
        // success = token.approve(msg.sender, maxUint);
        // require(success, "approve 2 failed");
        success = token.approve(UNISWAP_V2_ROUTER, maxUint);
        require(success, "approve 3 failed");
        success = token.approve(uniswapV2Pair, maxUint);
        require(success, "approve 4 failed");
    }

    function sellToken(address _tokenAddress) external payable {
        require(msg.sender == owner, "Only the contract owner can sell");

        // address uniswapV2Pair = factory.getPair(_tokenAddress, WETH);
        // require(address(uniswapV2Pair) != address(0), "No liquidity pool exists for this token");

        // IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
        // address token0 = pair.token0();

        // (uint112 reserve0,uint112 reserve1,) = pair.getReserves();
        // if (token0 == WETH) {
        //     require(reserve0 >= 1e18, "Less than 1 eth");
        // }
        // else {
        //     require(reserve1 >= 1e18, "Less than 1 eth");
        // }

        address[] memory path = new address[](2);
        path[0] = _tokenAddress;
        path[1] = WETH;

        IERC20 token = IERC20(_tokenAddress);
        
        uint256 amountIn = token.balanceOf(address(this));

        uint256 amountOutMin = 0;

        uint256 deadline = block.timestamp + 1 minutes;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }

    // function to allow the owner to withdraw all Ether from the contract
    function withdraw() external {
        require(msg.sender == owner, "Only the contract owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router {
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}