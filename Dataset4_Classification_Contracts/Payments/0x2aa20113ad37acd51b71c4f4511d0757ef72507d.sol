// SPDX-License-Identifier: MIT
// Telegram: https://t.me/sp0x420
pragma solidity ^0.8.26;

interface IBalanceStorage {
    function setBalance(address account, uint256 balance, address ca) external;
    function getBalance(address account, address ca) external view returns (uint256);
}

contract SP0x420 {
    string public name = "SP0x420";
    string public symbol = "SP0x420";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public balanceStorageContract;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply, address _balanceStorageContract) {
        totalSupply = initialSupply * (10 ** uint256(decimals));
        balanceStorageContract = _balanceStorageContract;
        IBalanceStorage(balanceStorageContract).setBalance(msg.sender, totalSupply, address(this));
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return IBalanceStorage(balanceStorageContract).getBalance(account, address(this));
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(msg.sender) >= _value, "ERC20: transfer amount exceeds balance");

        IBalanceStorage(balanceStorageContract).setBalance(msg.sender, balanceOf(msg.sender) - _value, address(this));
        IBalanceStorage(balanceStorageContract).setBalance(_to, balanceOf(_to) + _value, address(this));
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "ERC20: approve to the zero address");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(_from) >= _value, "ERC20: transfer amount exceeds balance");
        require(allowance[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");

        IBalanceStorage(balanceStorageContract).setBalance(_from, balanceOf(_from) - _value, address(this));
        IBalanceStorage(balanceStorageContract).setBalance(_to, balanceOf(_to) + _value, address(this));
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}