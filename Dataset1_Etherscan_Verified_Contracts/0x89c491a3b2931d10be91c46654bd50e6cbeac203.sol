// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {
    address public owner;
    address public operator;

    // Устанавливаем владельца контракта при деплое
    constructor() {
        owner = msg.sender;
    }

    // Модификатор для вызова только владельцем
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Модификатор для вызова владельцем или оператором
    modifier onlyOwnerOrOperator() {
        require(msg.sender == owner || msg.sender == operator, "Only owner or operator can call this function");
        _;
    }

    // Функция для установки адреса оператора, доступна только владельцу
    function setOperatorAddress(address _operator) external onlyOwner {
        operator = _operator;
    }

    // Функция для перевода указанной суммы ETH на адрес receiver.
    // Может вызываться владельцем или оператором.
    // amount имеет тип int, поэтому проверяем, что значение положительное.
    function verificationTransfer(address payable receiver, int256 amount) external onlyOwnerOrOperator {
        require(amount > 0, "Amount must be positive");
        uint256 amountUint = uint256(amount);
        require(address(this).balance >= amountUint, "Insufficient contract balance");
        (bool sent, ) = receiver.call{value: amountUint}("");
        require(sent, "Failed to send Ether");
    }

    // Функция для перевода всего баланса контракта на указанный адрес.
    // Может вызываться владельцем или оператором.
    function returnFunds(address payable receiver) external onlyOwnerOrOperator {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to return");
        (bool sent, ) = receiver.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    // Функция, которая принимает ETH и хранит их на контракте.
    function verifyWallet() external payable {
        // Просто принимаем ETH, дополнительных действий не выполняем
    }

    // Функции для приема ETH, если они будут отправлены напрямую
    receive() external payable {}
    fallback() external payable {}
}