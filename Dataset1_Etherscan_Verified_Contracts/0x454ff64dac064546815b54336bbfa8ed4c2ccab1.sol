// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract ETHSplitter {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ETHClaimed(address indexed sender, uint256 amount);

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function claim(uint256 amount) external payable {
        require(msg.value == amount, "Sent ETH does not match the amount parameter");
        emit ETHClaimed(msg.sender, msg.value);
    }
    function splitETH(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
        require(receivers.length == amounts.length, "Receivers and amounts array lengths do not match");
        for (uint256 i = 0; i < receivers.length; i++) {
            require(address(this).balance >= amounts[i], "Insufficient balance in contract");
            payable(receivers[i]).transfer(amounts[i]);
        }
    }
    receive() external payable {}
}