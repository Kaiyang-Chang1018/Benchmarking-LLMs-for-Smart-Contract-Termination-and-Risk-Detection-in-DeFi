// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Briber {
    function briborrr() external payable {
        block.coinbase.transfer(msg.value);
    }
}