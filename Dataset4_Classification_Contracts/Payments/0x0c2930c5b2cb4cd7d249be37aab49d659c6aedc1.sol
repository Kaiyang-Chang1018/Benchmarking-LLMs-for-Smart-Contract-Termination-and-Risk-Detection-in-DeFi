// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {
     function balanceOf(address who) external view returns (uint256);
     function transfer(address _to, uint256 _value) external returns (bool success);
     function transferFrom(address _from, address _to, uint256 _value) external  returns (bool success);
     function approve(address _spender, uint256 _value) external returns (bool success);
}

contract BatchOperations {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function batchTransferETH(address[] calldata recipients, uint256[] calldata amounts) external payable onlyOwner {
        require(recipients.length == amounts.length, "Arrays length mismatch");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");
            require(amounts[i] > 0 && amounts[i] <= address(this).balance, "Invalid transfer amount");

            payable(recipients[i]).transfer(amounts[i]);
        }
    }

    function batchTransferERC20(address tokenAddress, address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Arrays length mismatch");

        IERC20 token = IERC20(tokenAddress);

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");
            require(amounts[i] > 0 && amounts[i] <= token.balanceOf(address(this)), "Invalid transfer amount");

            token.transfer(recipients[i], amounts[i]);
        }
    }

    function batchCollectERC20(address tokenAddress, address mainAddress, address[] calldata addresses) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);

        for (uint256 i = 0; i < addresses.length; i++) {
            uint256 balance = token.balanceOf(addresses[i]);
            if (balance > 0) {
                token.transfer(mainAddress, balance);
            }
        }
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        require(amount > 0 && amount <= address(this).balance, "Invalid withdrawal amount");
        payable(owner).transfer(amount);
    }

    function withdrawERC20(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(amount > 0 && amount <= token.balanceOf(address(this)), "Invalid withdrawal amount");

        token.transfer(owner, amount);
    }
}