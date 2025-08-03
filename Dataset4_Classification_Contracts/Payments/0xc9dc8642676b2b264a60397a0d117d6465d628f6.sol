// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Splitter {
    address payable public address1;
    address payable public address2;
    address payable public address3;

    uint public share1;
    uint public share2;
    uint public share3;

    address public owner;

    constructor(address payable _address1, address payable _address2, address payable _address3, uint _share1, uint _share2, uint _share3) {
        require(_share1 + _share2 + _share3 == 100, "Total share must be 100%");
        
        owner = msg.sender;
        address1 = _address1;
        address2 = _address2;
        address3 = _address3;
        share1 = _share1;
        share2 = _share2;
        share3 = _share3;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function setAddresses(address payable _address1, address payable _address2, address payable _address3) public onlyOwner {
        address1 = _address1;
        address2 = _address2;
        address3 = _address3;
    }

    function setShares(uint _share1, uint _share2, uint _share3) public onlyOwner {
        require(_share1 + _share2 + _share3 == 100, "Total share must be 100%");
        share1 = _share1;
        share2 = _share2;
        share3 = _share3;
    }

    receive() external payable {
        uint balance = msg.value;
        address1.transfer(balance * share1 / 100);
        address2.transfer(balance * share2 / 100);
        address3.transfer(balance * share3 / 100);
    }
}