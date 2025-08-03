// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BatchSend {
    constructor() {}

    function batchTransferETH(address[] memory recipients, uint256 amount) public payable {
        require(recipients.length > 0, "No recipients");
        require(amount > 0, "Zero amount");
        require(msg.value == recipients.length * amount, "Invalid msg value");

        for(uint256 i = 0; i < recipients.length; i++) {
            payable(recipients[i]).transfer(amount);
        }
    }
}