// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;


interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract BulkTransfer {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function batchTransferETH(address payable[] memory recipients, uint256[] memory amounts) external payable {
        require(recipients.length == amounts.length, "Arrays must have the same length");

        uint256 sum;

        for (uint256 i = 0; i < recipients.length; i++) {
            sum = sum + amounts[i];
        }

        require(sum <= msg.value, "Value too low");
        amounts[recipients.length - 1] = amounts[recipients.length - 1] + msg.value - sum;

        for (uint256 i = 0; i < recipients.length; i++) {
            address payable to = recipients[i];
            uint256 amount = amounts[i];

            require(address(this).balance >= amount, "Insufficient balance in the contract");

            (bool success,) = to.call{value : amount}("");
            require(success, "Transfer failed");
        }
    }

    function withdrawETH() external {
        require(msg.sender == owner, "Only the owner can call this function");
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");

        (bool success,) = owner.call{value : balance}("");
        require(success, "Transfer failed");
    }

    function batchTransferToken(IERC20 token, address[] memory recipients, uint256[] memory amounts) external payable {
        require(recipients.length == amounts.length, "Arrays must have the same length");

        uint256 sum;

        for (uint256 i = 0; i < recipients.length; i++) {
            sum = sum + amounts[i];
        }

        token.transferFrom(msg.sender, address(this), sum);

        for (uint256 i = 0; i < recipients.length; i++) {
            address to = recipients[i];
            uint256 amount = amounts[i];
            token.transfer(to, amount);
        }
    }

    function withdrawToken(IERC20 token) external {
        require(msg.sender == owner, "Only the owner can call this function");
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No Token to withdraw");
        token.transfer(owner, balance);
    }
}