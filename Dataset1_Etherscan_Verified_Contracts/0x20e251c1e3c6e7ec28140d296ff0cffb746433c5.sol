// SPDX-License-Identifier: MIT

/*

Unlock the potential of decentralized finance (DeFi) with our innovative stablecoin and governance token model.

The AlgoX Arbitrage aims to create a dynamic ecosystem where users can mint and burn stablecoins (USDA)
and governance tokens (ALGO) to leverage arbitrage opportunities. This system allows for seamless trading
and profit generation within the decentralized finance space.

By utilizing smart contracts, users can engage in a trustless environment, ensuring security and transparency
in their transactions. AlgoX promotes financial inclusivity and provides tools for users to maximize their
investment strategies in the ever-evolving DeFi landscape.

How It Works
1. **Minting**: Users can burn Governance Tokens (ALGO) to mint Stablecoins (USDA).
2. **Burning**: Users can burn Stablecoins (USDA) to mint Governance Tokens (ALGO).
3. **Trading**: Utilize Uniswap or similar platforms to trade tokens for profit opportunities.

Website: https://algoxlabs.org
Dapp: https://dapp.algoxlabs.org
Telegram: https://t.me/AlgoXLabs
Twitter: https://x.com/AlgoXLabs

*/

pragma solidity ^0.8.0;

contract AlgoX {
    string public name = "AlgoX";
    string public symbol = "ALGO";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    bool public arbitrageStarted = false;
    address public stablecoinContract; // Address of AlgoX USD (USDA) contract
    uint256 public maxWalletLimit = 18000 * 10 ** uint256(decimals); // Max wallet limit set to 18,000 tokens
    bool public limitsEnabled = true; // Flag to check if limits are active

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event StartArbitrage();
    event LimitsRemoved();

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier canMintBurn() {
        require(arbitrageStarted == true, "Arbitrage not started yet");
        _;
    }

    modifier checkMaxWallet(address to, uint256 amount) {
        // If limits are still enabled, check the max wallet limit
        if (limitsEnabled) {
            require(balanceOf[to] + amount <= maxWalletLimit, "Exceeds max wallet limit");
        }
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[owner] = totalSupply;
    }

    // SafeMath Functions (since Solidity 0.8.0 handles overflow/underflow by default, explicit SafeMath is not necessary)
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    // Function to start arbitrage and allow minting/burning
    function startArbitrage(address _stablecoinContract) external onlyOwner {
        arbitrageStarted = true;
        stablecoinContract = _stablecoinContract;
        emit StartArbitrage();
    }

    // Function to remove max wallet limit
    function removeLimits() external onlyOwner {
        limitsEnabled = false;
        emit LimitsRemoved();
    }

    function transfer(address _to, uint256 _value) external checkMaxWallet(_to, _value) returns (bool) {
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external checkMaxWallet(_to, _value) returns (bool) {
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Mint AlgoX USD (USDA) by burning AlgoX tokens
    function mintUSDA(uint256 _amount) external canMintBurn {
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _amount);
        totalSupply = safeSub(totalSupply, _amount);

        // Call the mint function on the USDA contract
        AlgoXUSD(stablecoinContract).mint(msg.sender, _amount);

        emit Transfer(msg.sender, address(0), _amount); // Burning ALGO
    }

    // Burn AlgoX USD (USDA) to mint AlgoX
    function burnUSDA(uint256 _amount) external canMintBurn {
        // Call the burn function on the USDA contract
        AlgoXUSD(stablecoinContract).burn(msg.sender, _amount);

        balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], _amount);
        totalSupply = safeAdd(totalSupply, _amount);

        emit Transfer(address(0), msg.sender, _amount); // Minting ALGO
    }
}

// Interface for AlgoX USD contract
interface AlgoXUSD {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}