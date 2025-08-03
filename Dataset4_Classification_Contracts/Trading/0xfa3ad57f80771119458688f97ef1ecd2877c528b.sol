// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapRouter {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    
    function WETH() external pure returns (address);
}

interface IERC20 {
    function transfer(address recipient, uint amount) external returns (bool);
}

contract UniswapWrapper {
    IUniswapRouter public uniswapRouter;
    address public owner;
    uint256 public maxSwapAmount;

    // Reentrancy guard
    bool private locked;

    event TokensSwapped(address indexed user, uint256 amountIn, uint256 amountOut);
    event TokensWithdrawn(address indexed token, uint256 amount);

    constructor(address _router) {
        uniswapRouter = IUniswapRouter(_router);
        owner = msg.sender;
        maxSwapAmount = 1 ether; // Alapértelmezett maximális swap mennyiség 1 ether
        locked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    // Wrap ETH and swap for tokens
    function wrapAndSwap(uint amountOutMin, uint256 maxGasPrice) external payable noReentrancy {
        require(msg.value > 0, "Send ETH to wrap");
        require(msg.value <= maxSwapAmount, "Exceeds max swap amount");
        
        // Ellenőrizzük a maximális gázárat
        require(tx.gasprice <= maxGasPrice, "Gas price too high");

        // Default path: WETH to DAI
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH(); // WETH
        path[1] = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI cím (ERC20)

        // Swap ETH for tokens
        uint256[] memory amounts = uniswapRouter.swapExactETHForTokens{value: msg.value}(amountOutMin, path, address(this), block.timestamp);
        
        emit TokensSwapped(msg.sender, msg.value, amounts[amounts.length - 1]);
    }

    // Withdraw tokens from the contract
    function withdrawTokens(address token, uint amount) external onlyOwner {
        require(IERC20(token).transfer(owner, amount), "Transfer failed");
        emit TokensWithdrawn(token, amount);
    }

    // Set a new maximum swap amount
    function setMaxSwapAmount(uint256 _maxSwapAmount) external onlyOwner {
        maxSwapAmount = _maxSwapAmount;
    }

    // Fallback function to receive ETH
    receive() external payable {}
}