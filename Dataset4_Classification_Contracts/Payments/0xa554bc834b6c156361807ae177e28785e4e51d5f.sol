// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract InternalTransactionContracttt {
    // Event to log internal transfers
    event InternalTransfer(address indexed from, address indexed to, uint256 amount);
    
    // Event to log batch transfers
    event BatchTransfer(address indexed from, address[] to, uint256[] amounts);
event Transfer(address indexed from, address indexed to, uint256 value);
    // Mapping to track user balances
    mapping(address => uint256) public balances;

    // Deposit function for users to deposit Ether into the contract
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero.");
        balances[msg.sender] += msg.value;
    }

     function transfer(address payable _to) external payable {
        require(msg.value > 0, "Transfer amount must be greater than zero");
        require(_to != address(0), "Cannot transfer to the zero address");

        // Transfer Ether
        _to.transfer(msg.value);

        // Emit transfer event
        emit Transfer(msg.sender, _to, msg.value);
    }

    // Function for internal transfer between users within the contract
    function internalTransfer(address to, uint256 amount) external {
    require(balances[msg.sender] >= amount, "Insufficient balance.");
    require(to != address(0), "Invalid recipient address.");
    require(to != address(this), "Cannot transfer to contract itself.");

    balances[msg.sender] -= amount;
    balances[to] += amount;

    emit InternalTransfer(msg.sender, to, amount);
}

    // Batch transfer function to transfer to multiple addresses
// Batch transfer function to transfer to multiple addresses
function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
    require(recipients.length == amounts.length, "Mismatched arrays length.");

    uint256 totalAmount = 0;
    for (uint256 i = 0; i < amounts.length; i++) {
        totalAmount += amounts[i];
    }

    require(balances[msg.sender] >= totalAmount, "Insufficient balance for batch transfer.");

    for (uint256 i = 0; i < recipients.length; i++) {
        address to = recipients[i];
        uint256 amount = amounts[i];

        require(to != address(0), "Invalid recipient address.");
        require(to != address(this), "Cannot transfer to contract address.");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit InternalTransfer(msg.sender, to, amount);
    }

    emit BatchTransfer(msg.sender, recipients, amounts);
}


    // Function to check contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to withdraw Ether from the contract
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance.");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}