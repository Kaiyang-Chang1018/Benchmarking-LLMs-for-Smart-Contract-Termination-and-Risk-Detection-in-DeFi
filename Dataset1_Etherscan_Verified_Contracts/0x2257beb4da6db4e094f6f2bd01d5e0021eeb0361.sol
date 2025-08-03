// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.26;

/*
             _______
         ,-'``       ``'-.
      ,-'                 '-.
    ,'                       `.
  ,'                           `.
 /                               \
|                                 |
|                O                |
|                                 |
 \                               /
  `.                           ,'
    `.                       ,'
      `-.                 ,-'
         `'-.._______..-'`

 ____  ____  ____  ____  ____  __ _   ___  ____       
(  _ \(  _ \(  __)/ ___)(  __)(  ( \ / __)(  __)      
 ) __/ )   / ) _) \___ \ ) _) /    /( (__  ) _)       
(__)  (__\_)(____)(____/(____)\_)__) \___)(____)      
 ____  ____   __  ____  __    ___  __   __            
(  _ \(  _ \ /  \(_  _)/  \  / __)/  \ (  )           
 ) __/ )   /(  O ) )( (  O )( (__(  O )/ (_/\         
(__)  (__\_) \__/ (__) \__/  \___)\__/ \____/  

*/

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract PresenceProtocol {
    int256 public latitude;
    int256 public longitude;
    address public owner;
    event LocationUpdate(int256 latitude, int256 longitude, uint256 time);

    error NotOwner(address caller, address expected);

    // sets owner to the provided address
    constructor(address _owner) {
        owner = _owner;
    }

    // owner can withdraw Ether
    function withdrawEther() public {
        if (msg.sender != owner) revert NotOwner(msg.sender, owner);
        payable(owner).transfer(address(this).balance);
    }

    // owner can withdraw ERC-20 tokens
    function withdrawERC20(address tokenAddress, uint256 amount) public {
        if (msg.sender != owner) revert NotOwner(msg.sender, owner);
        IERC20(tokenAddress).transfer(owner, amount);
    }

    // to support receiving ETH by default
    receive() external payable {}
    fallback() external payable {}

    // owner can set new owner if needed
    function setOwner(address newOwner) external {
        if (msg.sender != owner) revert NotOwner(msg.sender, owner);
        owner = newOwner;
    }

    // owner can set the location
    function setLocation(int256 _latitude, int256 _longitude) external {
        if (msg.sender != owner) revert NotOwner(msg.sender, owner);
        latitude = _latitude;
        longitude = _longitude;
        emit LocationUpdate(_latitude, _longitude, block.timestamp);
    }
}