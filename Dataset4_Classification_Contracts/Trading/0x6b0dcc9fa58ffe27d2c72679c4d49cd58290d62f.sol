/**
 *Submitted for verification at Etherscan.io on 2023-08-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract IDOContract {
    address public owner;
    uint256 public maxAddress;
    uint256 public tokensPerExchange;
    uint256 public ethPerExchange;

    IERC20 public IDOToken;
    bool public isIDOActive = false;
    mapping(address => uint256) public exchangeCount;
    mapping(address => bool) public hasParticipated; // New mapping to track whether an address has participated

    event Exchange(address indexed user, uint256 ethAmount, uint256 aaaAmount);
    event TokenContractUpdated(address indexed newTokenContract);
    event ParametersUpdated(uint256 newmaxAddress, uint256 newTokensPerExchange, uint256 newEthPerExchange);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(address _IDOToken) {
        owner = msg.sender;
        IDOToken = IERC20(_IDOToken);
        maxAddress = 250;
        tokensPerExchange = 4400000 * 10 ** 18;
        ethPerExchange = 0.2 ether;
    }

    function start() external onlyOwner {
        require(!isIDOActive, "IDO is already active");
        isIDOActive = true;
    }

    function pause() external onlyOwner {
        require(isIDOActive, "IDO is not active");
        isIDOActive = false;
    }

    function IDO() external payable {
        require(isIDOActive, "IDO is not active");
        require(exchangeCount[msg.sender] < maxAddress, "Exceeded maximum allowed exchanges");
        require(!hasParticipated[msg.sender], "Address has already participated"); // Check if the address has already participated
        require(msg.value == ethPerExchange, "Incorrect ETH amount");

        exchangeCount[msg.sender]++;
        hasParticipated[msg.sender] = true; // Mark the address as participated
        uint256 aaaAmount = tokensPerExchange;
        require(IDOToken.balanceOf(address(this)) >= aaaAmount, "Insufficient $AAA balance in the contract");

        IDOToken.transfer(msg.sender, aaaAmount);
        emit Exchange(msg.sender, msg.value, aaaAmount);
    }

    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner).transfer(balance);
    }

    function withdrawERC20(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No ERC-20 tokens to withdraw");
        token.transfer(owner, balance);
    }

    // Owner can update the token contract address
    function updateTokenContract(address newTokenContract) external onlyOwner {
        IDOToken = IERC20(newTokenContract);
        emit TokenContractUpdated(newTokenContract);
    }

    // Owner can update the parameters
    function updateParameters(uint256 _maxAddress, uint256 _tokensPerExchange, uint256 _ethPerExchange) external onlyOwner {
        maxAddress = _maxAddress;
        tokensPerExchange = _tokensPerExchange;
        ethPerExchange = _ethPerExchange;
        emit ParametersUpdated(_maxAddress, _tokensPerExchange, _ethPerExchange);
    }
}