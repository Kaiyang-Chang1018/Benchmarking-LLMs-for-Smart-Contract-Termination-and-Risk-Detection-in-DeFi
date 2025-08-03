// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;


contract OlympixPresale {
   using SafeMath for uint256;

    address payable public owner;
    Token private token;
    uint256 public _weiRaised = 0;

    uint256 transactionCount;

    event TokensPurchased(address purchaser, uint256 value, uint256 amount, uint256 timestamp);

    struct TokensPurchasedStruct {
        address purchaser;
        uint256 value;
        uint256 amount;
        uint256 timestamp;
    }

    TokensPurchasedStruct[] transactions;

    constructor(Token _tokenAddress, uint256 funds) {
        token = _tokenAddress;
        owner = payable(msg.sender);
        fundContract(funds*(10**18));
    }


    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function fundContract(uint256 funds) internal {
        token.claimReferralTokens(funds);
    }

    function totalSupplyOfToken() public view returns (uint256) {
        return token.totalSupply();
    }



    //Pre-Sale 
    function buyTokens(uint256 tokens) public payable {
        address payable beneficiary = payable(msg.sender);
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
        _weiRaised = _weiRaised.add(weiAmount);
        token.transfer(beneficiary, tokens);

        transactionCount += 1; 
        transactions.push(TokensPurchasedStruct(beneficiary, weiAmount, tokens, block.timestamp));

        emit TokensPurchased(beneficiary, weiAmount, tokens, block.timestamp);
    }


    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Invalid address");
        require(weiAmount != 0, "Insufficient bid");
        this; 
    }

    
     function withdraw() external onlyOwner{
         require(address(this).balance > 0, 'zero_balance');
        owner.transfer(address(this).balance);  
    }


    function getAllTransactions() public view returns (TokensPurchasedStruct[] memory) {
        return transactions;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }
    

    function amountInETHReceived() public view returns (uint256) {
        return address(this).balance;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "only_owner_access");
        _;
    }

}






/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface Token {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function claimReferralTokens (uint256 weiAmount) external;
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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