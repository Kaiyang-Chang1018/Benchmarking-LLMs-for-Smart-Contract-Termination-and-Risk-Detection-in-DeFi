// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bribe {

    // Method to get the shoutout, returning the DJ's address
    function bribe(uint256 value) public payable returns (bool) {
        (bool success, ) = block.coinbase.call{ value: value }("");
        require(success, "Bribe failed");
        return success;
    }
}