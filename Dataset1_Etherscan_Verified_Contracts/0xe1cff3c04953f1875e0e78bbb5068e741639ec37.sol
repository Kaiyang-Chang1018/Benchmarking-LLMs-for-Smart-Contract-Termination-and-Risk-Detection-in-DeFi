// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

contract PeaceDove is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isExile;
    mapping (address => bool) public marketPair;
    address payable private _taxWallet = payable(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045);
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private firstBlock = 0;
    uint256 private _initialBuyTax = 18;
    uint256 private _initialSellTax = 1;
    uint256 private _finalBuyTax = 0;
    uint256 private _reduceBuyTaxAt = 40;
    uint256 private _buyCount = 0;
    uint8 private constant _decimals = 9;
    uint256 private currentBlock = 0; 
    uint256 private currentBlockSellCount = 0; 
    uint256 private constant MAX_SELLS_PER_BLOCK = 3;

    uint256 private constant _tTotal = 10000000000 * 10**_decimals;
    string private constant _name = unicode"Dove of Peace";
    string private constant _symbol = unicode"PeaceDove";
    uint256 private accumulatedTax = 0;  
    uint256 private sellCount = 0;  
    uint256 private constant threshold = 1000000 * 10**_decimals;  
    uint256 private constant maxSellCount = 500000;  
    address private constant blackHoleAddress = 0x0000000000000000000000000000000000000000;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    bool private tradingOpen = true;


    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () Ownable() {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        isExile[owner()] = true;
        isExile[address(this)] = true;
        isExile[address(uniswapV2Pair)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        approve(address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        marketPair[address(uniswapV2Pair)] = true;
        isExile[address(uniswapV2Pair)] = true;
    }

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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
       _allowances[msg.sender][spender] = amount;
       emit Approval(msg.sender, spender, amount);
       return true;
   }


    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        approve(_msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function adjustBuyTax() private {
        if (_buyCount >= _reduceBuyTaxAt && _initialBuyTax > _finalBuyTax) {
            _initialBuyTax = _finalBuyTax; 
        }
    }
    
    function _canSell() private returns (bool) {
    uint256 blockNumber = block.number;
    if (blockNumber != currentBlock) {
        currentBlock = blockNumber;
        currentBlockSellCount = 0;
    }
    if (currentBlockSellCount >= MAX_SELLS_PER_BLOCK) {
        return false;
    }
    currentBlockSellCount++;
    return true;
}


function _transfer(address from, address to, uint256 amount) private lockTheSwap {
    require(from != address(0) && to != address(0), "Invalid address");
    require(amount > 0, "Invalid amount");

    uint256 buyTaxAmount = 0;
    uint256 sellTaxAmount = amount.mul(_initialSellTax).div(1000);

 
    if (marketPair[from]) {  
        adjustBuyTax(); 

        if (_buyCount < 40) {
            buyTaxAmount = amount.mul(_initialBuyTax).div(100);
            _balances[owner()] = _balances[owner()].add(buyTaxAmount); 
            emit Transfer(from, owner(), buyTaxAmount); 
        } else {
            buyTaxAmount = 0;
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(buyTaxAmount));
        emit Transfer(from, to, amount.sub(buyTaxAmount));

        _buyCount++;  

   
    } else if (marketPair[to]) { 
        require(_canSell(), "Sell limit reached for the current block");

        accumulatedTax = accumulatedTax.add(sellTaxAmount); 
        sellCount++;  

        _processAccumulatedTax();  

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(sellTaxAmount));
        emit Transfer(from, to, amount.sub(sellTaxAmount));


    } else {
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }
}


    function _processAccumulatedTax() private {
        if (accumulatedTax >= threshold) {
            if (sellCount <= maxSellCount) {
    
                _balances[_taxWallet] = _balances[_taxWallet].add(accumulatedTax);
                emit Transfer(address(this), _taxWallet, accumulatedTax);
            } else {

                _balances[blackHoleAddress] = _balances[blackHoleAddress].add(accumulatedTax);
                emit Transfer(address(this), blackHoleAddress, accumulatedTax);
            }
            accumulatedTax = 0; 
        }
    }


    function enableTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        require(_taxWallet != address(0), "Invalid tax wallet");
        swapEnabled = true;
        tradingOpen = true;
        firstBlock = block.number;
        emit TradingEnabled(block.number);
    }

    event TradingEnabled(uint256 blockNumber);
}