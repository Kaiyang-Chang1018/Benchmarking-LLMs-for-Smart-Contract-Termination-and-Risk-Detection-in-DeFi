// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract ERC20Splitter {
    IERC20 public token;
    address public recipient1;
    address public recipient2;
    uint256 public percentage; // percentage for recipient1 (in basis points, e.g., 5000 for 50%)

    constructor(address _token, address _recipient1, address _recipient2, uint256 _percentage) {
        require(_percentage <= 10000, "Percentage must be <= 10000");
        token = IERC20(_token);
        recipient1 = _recipient1;
        recipient2 = _recipient2;
        percentage = _percentage;
    }

    function transfer() public {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No balance to transfer");

        uint256 amount1 = (balance * percentage) / 10000;
        uint256 amount2 = balance - amount1;

        require(token.transfer(recipient1, amount1), "Transfer to recipient1 failed");
        require(token.transfer(recipient2, amount2), "Transfer to recipient2 failed");
    }
}