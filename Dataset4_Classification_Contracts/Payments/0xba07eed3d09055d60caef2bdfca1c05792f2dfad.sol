pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Withdrawable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Receive ETH
    receive() external payable {}

    // Withdraw ETH to owner
    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Withdraw ERC20 tokens to owner
    function withdrawTokens(address token) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        erc20.transfer(owner, balance);
    }

    // Change ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}