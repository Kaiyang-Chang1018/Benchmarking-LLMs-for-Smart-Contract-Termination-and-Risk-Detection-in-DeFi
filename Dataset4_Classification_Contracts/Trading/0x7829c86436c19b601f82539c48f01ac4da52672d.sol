// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

abstract contract HEROABLE {
    function addLiquidityETH(address,uint256,uint256,uint256,address,uint256) external virtual payable {}
    function getPair(address,address) external virtual returns (address) {}
}

contract HERO {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address private _owner;

    bool private _trading;

    address private constant _router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant _factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant _weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event TradingOpened(address indexed pool);

    constructor() {
        _name = "Hero Meme";
        _symbol = "HERO";

        _mint(msg.sender, 712000000000000000000000000);

        _transferOwnership(address(0), msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function trading() public view returns (bool) {
        return _trading;
    }

    function router() public pure returns (address) {
        return _router;
    }

    function factory() public pure returns (address) {
        return _factory;
    }

    function weth() public pure returns (address) {
        return _weth;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function renounceOwnership() external {
        require(msg.sender == _owner);
        _transferOwnership(msg.sender, address(0));
    }

    function _transferOwnership(address previousOwner, address newOwner) private {
        _owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    function openTrading() external payable {
        require(msg.sender == _owner);
        require(!_trading);
        uint256 balance = _balances[msg.sender];
        _transfer(msg.sender, address(this), balance);
        _approve(address(this), _router, balance);
        HEROABLE(_router).addLiquidityETH{value: msg.value}(address(this), balance, balance, msg.value, msg.sender, block.timestamp);
        address pool = HEROABLE(_factory).getPair(address(this), _weth);
        _trading = true;
        emit TradingOpened(pool);
    }

    function transferETH(address payable recipient) external payable {
        recipient.transfer(msg.value);
    }
}