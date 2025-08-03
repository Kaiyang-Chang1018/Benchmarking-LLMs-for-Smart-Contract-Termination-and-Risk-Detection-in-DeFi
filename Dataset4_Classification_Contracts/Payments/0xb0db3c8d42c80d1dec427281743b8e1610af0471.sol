// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Etherpepes {
  
    error NotEnoughEther();
    error NotDeployer();

    address public projectCreator = msg.sender;

    event ethscriptions_protocol_CreateEthscription(
        address indexed initialOwner,
        string contentURI
    );

    function ethscribe(string memory dataURI) public payable {
       
        if (msg.sender != address(projectCreator) && msg.value < 0.0012 ether) {
            revert NotEnoughEther();
        }

        emit ethscriptions_protocol_CreateEthscription(msg.sender, string(abi.encodePacked(dataURI)));
    }

    function withdraw(uint256 amount, address to) public {
        if (msg.sender != projectCreator) {
            revert NotDeployer();
        }

        payable(to).transfer(amount == 0 ? address(this).balance : amount);
    }
}