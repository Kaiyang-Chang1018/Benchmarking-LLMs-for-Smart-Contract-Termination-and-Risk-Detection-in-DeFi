//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.26;

contract Rounders {
    function payThatManHisMoney(uint256 timestamp, address recipient) external payable {
        require(block.timestamp == timestamp);
        selfdestruct(payable(recipient));
    }
}