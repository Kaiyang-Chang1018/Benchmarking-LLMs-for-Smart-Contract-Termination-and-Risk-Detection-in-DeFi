// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router02 {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Aouki {
    address public owner;
    IUniswapV2Router02 public uniswapRouter;
    bool public isActive;

    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    event TokensSniped(address token, uint amountETH, uint amountTokens);
    event TokensSold(address token, uint amountTokens, uint amountETH);
    event StatusChanged(bool isActive);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier isActiveSniping() {
        require(isActive, "Sniping is not active");
        _;
    }

    constructor() {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router02(UNISWAP_V2_ROUTER);
    }


    function startSniping() external onlyOwner {
        isActive = true;
        emit StatusChanged(true);
    }


    function stopSniping() external onlyOwner {
        isActive = false;
        emit StatusChanged(false);
    }


    function snipeToken(address token, uint amountOutMin, uint deadline) external payable onlyOwner isActiveSniping {
        require(msg.value > 0, "Must send ETH to snipe");

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = token;

        uniswapRouter.swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            address(this),
            deadline
        );

        emit TokensSniped(token, msg.value, amountOutMin);
    }


    function sellToken(address token, uint amountOutMin, uint deadline) external onlyOwner {
        uint tokenBalance = IERC20(token).balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to sell");

        IERC20(token).approve(UNISWAP_V2_ROUTER, tokenBalance);

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = WETH;

        uniswapRouter.swapExactTokensForETH(
            tokenBalance,
            amountOutMin,
            path,
            address(this),
            deadline
        );

        emit TokensSold(token, tokenBalance, amountOutMin);
    }

    // Fonction de retrait des tokens ou de l'ETH
    function withdrawTokens(address token) external onlyOwner {
        IERC20(token).transfer(owner, IERC20(token).balanceOf(address(this)));
    }

    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}