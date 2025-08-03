// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract GasEfficientMultiSender {
    IERC20 public immutable token;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
    }

    function multiSend(address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "Length mismatch");

        uint256 length = recipients.length;
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < length; ) {
            totalAmount += amounts[i];
            unchecked { ++i; } // Use unchecked to save gas on increments
        }

        // Use transferFrom for automatic deposit of the total amount
        require(token.transferFrom(msg.sender, address(this), totalAmount), "Deposit failed");

        for (uint256 i = 0; i < length; ) {
            require(token.transfer(recipients[i], amounts[i]), "Transfer failed");
            unchecked { ++i; } // Use unchecked to save gas on increments
        }
    }
}