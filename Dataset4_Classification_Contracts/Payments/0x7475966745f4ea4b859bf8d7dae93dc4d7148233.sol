// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract EthTransfer {
    function send_some_eth_to(address payable _recipient) payable public {
        _recipient.transfer(msg.value);
    }
}