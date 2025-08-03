// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BNBToken {
    string public name = "BNB"; // 代币名称
    string public symbol = "BNB"; // 代币符号
    uint8 public decimals = 8; // 小数位数
    uint256 public totalSupply; // 总供应量

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // 初始化代币总量：5,000,000，按小数位数补全实际总量
        totalSupply = 5000000 * 10**decimals;
        // 将全部代币分配给部署合约的账户
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "BNB: Insufficient balance");
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(balances[sender] >= amount, "BNB: Insufficient balance");
        require(allowances[sender][msg.sender] >= amount, "BNB: Transfer amount exceeds allowance");

        allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BNB: Transfer from the zero address");
        require(recipient != address(0), "BNB: Transfer to the zero address");

        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
}