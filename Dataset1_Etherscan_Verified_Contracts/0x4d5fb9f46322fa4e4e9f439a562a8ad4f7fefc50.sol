// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract OrangeManSummer {
    mapping(address => uint256) private tokenBalances;
    mapping(address => mapping(address => uint256)) private tokenAllowances;

    string private constant TOKEN_NAME = "Orange Man Summer";
    string private constant TOKEN_SYMBOL = "OMS";
    uint8 private constant TOKEN_DECIMALS = 18;
    uint256 private constant MAX_SUPPLY = 100_000_000_000 * 10**TOKEN_DECIMALS;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor() {
        tokenBalances[msg.sender] = MAX_SUPPLY;
        emit Transfer(address(0), msg.sender, MAX_SUPPLY);
    }

    function name() external pure returns (string memory) {
        return TOKEN_NAME;
    }

    function symbol() external pure returns (string memory) {
        return TOKEN_SYMBOL;
    }

    function decimals() external pure returns (uint8) {
        return TOKEN_DECIMALS;
    }

    function totalSupply() external pure returns (uint256) {
        return MAX_SUPPLY;
    }

    function balanceOf(address account) external view returns (uint256) {
        return tokenBalances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        address sender = msg.sender;
        require(sender != to, "ERC20: cannot transfer to self");
        _transfer(sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return tokenAllowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        address spender = msg.sender;
        require(spender != from, "ERC20: spender cannot be the sender");
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");

        uint256 senderBalance = tokenBalances[from];
        require(senderBalance >= amount, "ERC20: transfer exceeds balance");
        unchecked {
            tokenBalances[from] = senderBalance - amount;
        }
        tokenBalances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");

        tokenAllowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}