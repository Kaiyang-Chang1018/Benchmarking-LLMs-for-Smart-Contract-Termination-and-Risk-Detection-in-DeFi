// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Utility/owner.sol";

interface IBV3 {
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Bv3Distribution is Owner {
    IBV3 public bv3Token;
    uint256 public totalDistributed;

    // New mapping to store claims
    mapping(address => uint256) public claims;

    function setBV3TokenAddress(address _bv3TokenAddress) external onlyOwner {
        bv3Token = IBV3(_bv3TokenAddress);
    }

    //UTILIZE THIS FUNCTION HERE TO GET YOUR BV3
    function claim() external {
        uint256 amount = claims[msg.sender];
        require(amount > 0, "No tokens to claim");

        claims[msg.sender] = 0;
        require(bv3Token.transfer(msg.sender, amount), "Token transfer failed");
        totalDistributed += amount;
    }

    function distributeTokens(address recipient, uint256 amount) external onlyOwner returns (bool) {
        claims[recipient] += amount;
        return true;
    }

    function distributeTokens(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner returns (bool) {
        require(recipients.length == amounts.length, "Recipients and amounts length mismatch");

        for (uint i = 0; i < recipients.length; i++) {
            claims[recipients[i]] += amounts[i];
        }

        return true;
    }

    // ... other existing functions ...
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Owner {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(isOwner(), "You are not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }


    function getOwner() public view returns (address) {
        return _owner;
    }

}