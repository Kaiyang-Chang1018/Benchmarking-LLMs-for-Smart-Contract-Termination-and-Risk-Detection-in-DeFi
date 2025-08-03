// SPDX-License-Identifier: Unlicensed

/*
=============================================================================
MCTRUMP TOKEN 🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
=============================================================================
🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
                                              🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
💰 TOKENOMICS:                                🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
- Total Supply: 1,000,000,000 MCTRUMP         🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
- Decimals: 18                                🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
                                              🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
                                              🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
                                              🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
🌐 SOCIALS:                                   🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
Website:     https://www.mctrump.meme         🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
Telegram:    https://t.me/OfficialMcTrump     🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
Twitter:     https://x.com/OfficialMcTrump    🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟���🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟🍟
=============================================================================
*/






pragma solidity ^0.8.14;

//===============================================================
//                          INTERFACES
//===============================================================

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

//===============================================================
//                          LIBRARIES
//===============================================================

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

//===============================================================
//                      ABSTRACT CONTRACTS
//===============================================================

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

//===============================================================
//                      MAIN CONTRACT
//===============================================================

contract MCTRUMP is Context, IERC20, Ownable {
    using SafeMath for uint256;

    //===============================================================
    //                      TOKEN DETAILS
    //===============================================================
    string private constant _name = "MCTRUMP";
    string private constant _symbol = "MCTRUMP";
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1000000000 * 10**18; // 1 billion tokens

    //===============================================================
    //                      MAPPINGS
    //===============================================================
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    //===============================================================
    //                      UNISWAP
    //===============================================================
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    //===============================================================
    //                      TRADING CONTROL
    //===============================================================
    bool public tradingEnabled;
    uint256 public launchTime;
    uint256 public maxTxAmount = _tTotal.mul(2).div(100); // 2% of total supply
    uint256 public maxWalletAmount = _tTotal.mul(2).div(100); // 2% of total supply
    uint256 private _numTokensToSwap = 300000 * 10**18; // 300k tokens minimum for swap

    //===============================================================
    //                      MARKETING
    //===============================================================
    address public marketingWallet;
    bool private inSwap;

    //===============================================================
    //                      TAX MANAGEMENT
    //===============================================================

    // Simplified tax variables
    uint256 public buyTax = 1;     // Default 1% buy tax
    uint256 public sellTax = 5;    // Default 5% sell tax

    function setBuyTax(uint256 newTax) external onlyOwner {
        require(newTax <= 20, "Tax cannot exceed 20%");
        buyTax = newTax;
    }

    function setSellTax(uint256 newTax) external onlyOwner {
        require(newTax <= 20, "Tax cannot exceed 20%");
        sellTax = newTax;
    }

    //===============================================================
    //                      EVENTS
    //===============================================================
    event SwapAndSendMarketing(uint256 tokensSwapped, uint256 ethSent);

    //===============================================================
    //                      MODIFIERS
    //===============================================================
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    //===============================================================
    //                      CONSTRUCTOR 
    //===============================================================
   

    constructor() {
        _balances[_msgSender()] = _tTotal;
        marketingWallet = _msgSender();
        
        // Set router and create pair immediately
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        
        // Create the pair automatically
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    

    //===============================================================
    //                      VIEW FUNCTIONS
    //===============================================================
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    //===============================================================
    //                      TAX CALCULATION
    //===============================================================
    function getCurrentTaxRate(address from, address to) public view returns (uint256) {
        if (!tradingEnabled) {
            return 0;
        }

        // Buy tax (from pair)
        if (from == uniswapV2Pair) {
            return buyTax;
        }
        
        // Sell tax (to pair)
        if (to == uniswapV2Pair) {
            return sellTax;
        }

        return 0; // No tax for wallet transfers
    }

        //===============================================================
    //                      CORE FUNCTIONS
    //===============================================================
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //===============================================================
    //                      TRANSFER LOGIC
    //===============================================================
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");
        require(amount > 0, "Transfer amount zero");
        require(tradingEnabled || sender == owner(), "Trading not enabled");
        
        if (sender != owner() && recipient != owner()) {
            require(amount <= maxTxAmount, "Transfer exceeds max");
        }

        // Max wallet check - exclude pair address and owner
        if (recipient != owner() && recipient != uniswapV2Pair) {
            uint256 recipientBalance = balanceOf(recipient).add(amount);
            require(recipientBalance <= maxWalletAmount, "Exceeds max wallet");
        }

        // Check if we need to swap collected tokens for ETH
        if (
            !inSwap && 
            sender != uniswapV2Pair &&
            balanceOf(address(this)) >= _numTokensToSwap
        ) {
            swapTokensForEth();
        }

        uint256 taxAmount = 0;
        if (!inSwap) {
            uint256 taxRate = getCurrentTaxRate(sender, recipient);
            taxAmount = amount.mul(taxRate).div(100);
        }

        if (taxAmount > 0) {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            _balances[recipient] = _balances[recipient].add(amount.sub(taxAmount));
            emit Transfer(sender, address(this), taxAmount);
            emit Transfer(sender, recipient, amount.sub(taxAmount));
        } else {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    //===============================================================
    //                      SWAP FUNCTIONALITY
    //===============================================================
    function swapTokensForEth() private lockTheSwap {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance == 0) return;
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenBalance);

        uint256 initialETHBalance = address(this).balance;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenBalance,
            0, // Accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        
        if (ethBalance > 0) {
            payable(marketingWallet).transfer(ethBalance);
            emit SwapAndSendMarketing(tokenBalance, ethBalance);
        }
    }

    //===============================================================
    //                      OWNER FUNCTIONS
    //===============================================================
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled");
        tradingEnabled = true;
        launchTime = block.timestamp;
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Cannot be zero address");
        marketingWallet = newWallet;
    }

    function setMaxTxAmount(uint256 percentage) external onlyOwner {
        require(percentage <= 2, "Max 2%");
        maxTxAmount = _tTotal.mul(percentage).div(100);
    }

    function setNumTokensToSwap(uint256 newAmount) external onlyOwner {
        require(newAmount > 0, "Cannot be zero");
        _numTokensToSwap = newAmount;
    }

    function setMaxWalletAmount(uint256 percentage) external onlyOwner {
        require(percentage <= 2, "Max 2%");
        maxWalletAmount = _tTotal.mul(percentage).div(100);
    }

    //===============================================================
    //                      EMERGENCY FUNCTIONS
    //===============================================================
    function rescueETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function rescueTokens(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(this), "Cannot rescue MCTRUMP");
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(owner(), tokenBalance);
    }

    receive() external payable {}
}