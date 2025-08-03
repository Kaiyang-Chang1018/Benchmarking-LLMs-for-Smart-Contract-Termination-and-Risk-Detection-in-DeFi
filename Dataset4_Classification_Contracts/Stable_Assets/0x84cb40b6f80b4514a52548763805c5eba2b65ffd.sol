// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GatotKacaTokenUSDT is IERC20 {
    string public constant name = "USDT";
    string public constant symbol = "USDT";
    uint8 public constant decimals = 6;
    uint256 private _totalSupply;

    address private _owner;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }

    constructor(uint256 initialSupply) {
        _owner = msg.sender;
        _totalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Allowance exceeded");

        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function mint(uint256 amount) external onlyOwner {
        _totalSupply += amount * 10 ** uint256(decimals);
        _balances[_owner] += amount * 10 ** uint256(decimals);
        emit Transfer(address(0), _owner, amount * 10 ** uint256(decimals));
    }

    function burn(uint256 amount) external onlyOwner {
        require(_balances[_owner] >= amount * 10 ** uint256(decimals), "Insufficient balance");
        _totalSupply -= amount * 10 ** uint256(decimals);
        _balances[_owner] -= amount * 10 ** uint256(decimals);
        emit Transfer(_owner, address(0), amount * 10 ** uint256(decimals));
    }

    function swap(address tokenAddress, uint256 amount) external {
        IERC20 otherToken = IERC20(tokenAddress);

        // Transfer GatotKacaTokenUSDT from the sender to the contract
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        require(_allowances[msg.sender][address(this)] >= amount, "Allowance exceeded");

        _balances[msg.sender] -= amount;
        _balances[address(this)] += amount;
        _allowances[msg.sender][address(this)] -= amount;
        emit Transfer(msg.sender, address(this), amount);

        // Transfer the other token from the contract to the sender
        require(otherToken.transfer(msg.sender, amount), "Transfer of other token failed");
    }

    function withdraw(address tokenAddress, address to, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);

        // Transfer the specified amount of the token to the specified address
        require(token.transfer(to, amount), "Withdraw failed");
    }
}