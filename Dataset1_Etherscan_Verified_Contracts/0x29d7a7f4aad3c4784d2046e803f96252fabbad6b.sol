// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MultiCaller {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    /// @notice Allows the contract owner to make multiple calls to the same target address with different data
    /// @param target The address of the contract to call
    /// @param data An array of calldata for the function calls
    function multiCall(address target, bytes[] memory data) public onlyOwner {
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, ) = target.call(data[i]);
            require(success, "Call failed");
        }
    }

    /// @notice Allows the contract owner to withdraw the full balance of any ERC20 token
    /// @param token The address of the ERC20 token
    function withdrawToken(address token) public onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "No token balance to withdraw");
        bool success = IERC20(token).transfer(owner, balance);
        require(success, "Token transfer failed");
    }

    /// @notice Allows the contract owner to withdraw Ether from the contract
    /// @param to The recipient address
    /// @param amount The amount of Ether to withdraw
    function withdrawEther(address payable to, uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        to.transfer(amount);
    }

    /// @notice Fallback function to receive Ether
    receive() external payable {}
}