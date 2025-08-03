// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    BLUE SHIBA INU Token (BLUE)
    Telegram: https://t.me/Blueshibaainu
*/

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address to,
        uint deadline
    ) external;
}

contract BLUE_SHIBA_INU {
    string public constant name = "BLUE SHIBA INU";
    string public constant symbol = "BLUE";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    address public immutable owner;
    address public feeRecipient;
    address public uniswapPair;

    uint256 public buyTax;
    uint256 public sellTax;
    uint256 public maxTransactionAmount;
    uint256 public maxWalletLimit;
    uint256 public autoSwapThreshold;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private taxExempted;

    IUniswapV2Router02 private immutable uniswapRouter;
    bool public tradingLive = false;

    event TokenTransfer(address indexed sender, address indexed receiver, uint256 amount);
    event TokenApproval(address indexed owner, address indexed spender, uint256 amount);
    event TradingActivated();

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied: Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        feeRecipient = msg.sender;
        totalSupply = 1_000_000_000 * (10 ** decimals);
        buyTax = 5;
        sellTax = 5;
        maxTransactionAmount = totalSupply / 100;
        maxWalletLimit = totalSupply / 50;
        autoSwapThreshold = totalSupply / 1000;

        balanceOf[msg.sender] = totalSupply;
        taxExempted[msg.sender] = true;
        taxExempted[address(this)] = true;

        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        emit TokenTransfer(address(0), msg.sender, totalSupply);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit TokenApproval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _handleTransfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        _handleTransfer(from, to, amount);
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function _handleTransfer(address from, address to, uint256 amount) internal {
        require(tradingLive || taxExempted[from], "Trading is not yet live");
        require(from != address(0) && to != address(0), "Invalid address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!taxExempted[from] && !taxExempted[to]) {
            require(amount <= maxTransactionAmount, "Transaction exceeds limit");
            require(balanceOf[to] + amount <= maxWalletLimit, "Wallet exceeds limit");
        }

        uint256 feeAmount = 0;

        if (!taxExempted[from] && !taxExempted[to]) {
            if (to == uniswapPair) {
                feeAmount = (amount * sellTax) / 100;
            } else if (from == uniswapPair) {
                feeAmount = (amount * buyTax) / 100;
            }
        }

        uint256 transferAmount = amount - feeAmount;
        balanceOf[from] -= amount;
        balanceOf[to] += transferAmount;

        if (feeAmount > 0) {
            balanceOf[address(this)] += feeAmount;
            emit TokenTransfer(from, address(this), feeAmount);
        }

        emit TokenTransfer(from, to, transferAmount);

        if (balanceOf[address(this)] >= autoSwapThreshold) {
            _convertFeesToETH();
        }
    }

    function _convertFeesToETH() private {
        uint256 contractTokenBalance = balanceOf[address(this)];
        if (contractTokenBalance == 0) return;

        approve(address(uniswapRouter), contractTokenBalance);
        
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            feeRecipient,
            block.timestamp
        );
    }

    function activateTrading() external onlyOwner {
        require(!tradingLive, "Trading already activated");
        uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        tradingLive = true;
        emit TradingActivated();
    }

    function modifyTaxRates(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        require(newBuyTax <= 5 && newSellTax <= 5, "Tax rates too high");
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }

    function liftLimits() external onlyOwner {
        maxTransactionAmount = totalSupply;
        maxWalletLimit = totalSupply;
    }

    function exemptFromTax(address account, bool status) external onlyOwner {
        taxExempted[account] = status;
    }

    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}