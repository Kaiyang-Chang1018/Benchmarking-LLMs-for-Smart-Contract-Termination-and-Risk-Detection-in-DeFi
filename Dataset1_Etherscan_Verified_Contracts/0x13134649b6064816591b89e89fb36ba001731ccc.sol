// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/*
 * @title ContractName
 * @dev ContractDescription
 * @custom:dev-run-script scripts/deploy_with_web3.ts
 */

contract Iriecoin {

    string public constant name = "Iriecoin";
    string public constant symbol = "IRE";
    uint8 public constant decimals = 9;  

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Buy(address indexed buyer, uint tokens, uint ethValue);
    event Sell(address indexed seller, uint tokens, uint ethValue);

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    uint256 public constant totalSupply = 21 * 10**6 * 10**uint(decimals); // Total supply set to 21 million tokens
    uint256 public constant miningSupply = 20 * 10**6 * 10**uint(decimals); // 20 million tokens designated for mining
    uint256 public constant initialSupply = 1 * 10**6 * 10**uint(decimals); // 1 million tokens sent to the token creator
    
    uint256 public constant usdtPerIRE = 100000000; // 1 IRE equals 65000 USDT

    constructor() {
        balances[msg.sender] = miningSupply; // Initial balance for mining
        balances[msg.sender] = initialSupply; // Send 1 million tokens to the token creator
    }  

    function gettotalSupply() public pure returns (uint256) {
        return totalSupply;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);
    
        balances[owner] -= numTokens;
        allowed[owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    
    // Function to buy tokens directly from the contract with 0% liquidity fee
    function buyTokens() public payable {
        require(msg.value > 0); // Ensure the buyer sends some ether
        uint tokensToBuy = msg.value * usdtPerIRE; // Calculate tokens based on exchange rate
        balances[msg.sender] += tokensToBuy;
        emit Transfer(address(0), msg.sender, tokensToBuy);
        emit Buy(msg.sender, tokensToBuy, msg.value);
    }
    
    // Function to sell tokens directly to the contract with 0% liquidity fee
    function sellTokens(uint tokensToSell) public {
        require(tokensToSell > 0); // Ensure the seller is selling some tokens
        require(balances[msg.sender] >= tokensToSell); // Ensure the seller has enough tokens to sell
        uint ethToTransfer = tokensToSell / usdtPerIRE; // Calculate ETH based on exchange rate
        balances[msg.sender] -= tokensToSell;
        payable(msg.sender).transfer(ethToTransfer);
        emit Transfer(msg.sender, address(0), tokensToSell);
        emit Sell(msg.sender, tokensToSell, ethToTransfer);
    }
}