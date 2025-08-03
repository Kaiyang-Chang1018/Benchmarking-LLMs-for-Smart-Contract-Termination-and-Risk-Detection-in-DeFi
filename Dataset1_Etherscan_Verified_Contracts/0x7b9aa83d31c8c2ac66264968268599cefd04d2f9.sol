// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

contract Disperse {
    address payable public owner;
    constructor() {
        owner = payable(msg.sender);
    }
    receive() external payable {}
    fallback() external payable {}

    function disperse(address[] memory _users, uint256[] memory _amounts) public payable {
        require(_users.length == _amounts.length, 'Must be same length');
        for (uint256 i = 0; i < _users.length; i++) {
            payable(_users[i]).transfer(_amounts[i]);
        }
    }

    function recoverETH() public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
}