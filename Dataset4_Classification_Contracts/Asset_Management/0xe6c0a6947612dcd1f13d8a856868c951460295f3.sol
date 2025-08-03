/**
 *Submitted for verification at Etherscan.io on 2024-09-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        require(initialOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(initialOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
}

contract Dogism is ERC20, Ownable {
    using SafeMath for uint256;

    bool public antiWhale = true;
    bool public tradingEnabled = false; // New flag to control trading and max tx increase
    uint256 private _tTotal = 10000 * 10 ** decimals(); // 1 trillion
    uint256 public maxTransactionAmount = (_tTotal * 15) / 10000; // Start at 0.15% of total supply
    uint256 public increasePercentMultuplier = 150; // 0.1% increase multiplier * 1.5%
    uint256 public lastUpdateTime;

    uint constant MAX_GENS_START = 1000;
    uint public constant GEN_MIN = 1;
    uint public constant gen_max = MAX_GENS_START;
    uint public gen = MAX_GENS_START;
    uint public constant max_breed = 1000;
    mapping(address owner => uint) public counts;
    uint public breed_total_count;
    uint breed_id;

    uint background_Color;
    uint body_Color;
    uint facial_Hair;
    uint facial_Hair_color;
    uint shirt1;
    uint shirt1_color;
    uint nose;
    uint nose_Color;
    uint mouth;
    uint eyes;
    uint eye_Color;
    uint hat;
    uint hat_Color;
    uint accessoires;

    constructor(string memory name, string memory symbol) payable ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, _tTotal);
        lastUpdateTime = block.timestamp;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Check if trading is enabled
        require(tradingEnabled || from == owner(), "Trading is not enabled yet");

        if (tradingEnabled && antiWhale && tx.origin != owner()) {
            // Anti-whale check only if trading is enabled
            _updateMaxTransactionAuto();
            require(amount <= maxTransactionAmount, "Transaction exceeds the max allowed amount");
        }

        super._transfer(from, to, amount);
    }

    // Internal function to update the max transaction amount every 10 seconds
    function _updateMaxTransactionAuto() internal {
        if (tradingEnabled && block.timestamp >= lastUpdateTime + 10 seconds) {
            uint256 intervalsElapsed = (block.timestamp - lastUpdateTime) / 10 seconds;
            for (uint256 i = 0; i < intervalsElapsed; i++) {
                maxTransactionAmount = maxTransactionAmount.add((maxTransactionAmount * increasePercentMultuplier) / 10000);
            }
            lastUpdateTime = block.timestamp;
        }
    }

    // Toggle the anti-whale mechanism
    function toggleLimits() public onlyOwner {
        antiWhale = !antiWhale;
    }

    // Manually set the max transaction limit (in units of tokens with decimals considered)
    function setMaxTransactionManual(uint256 _max) public onlyOwner {
        maxTransactionAmount = _max * 10 ** decimals();
    }

    // Enable trading and allow max transaction updates to start
    function enableTrading() public onlyOwner {
        tradingEnabled = true;
        lastUpdateTime = block.timestamp; // Reset the last update time when trading starts
    }

    function setBackground(uint _value) public onlyOwner {
        background_Color = _value;
    }

    function updateBodyColor(uint _value) public onlyOwner{
        body_Color = _value;
    }

    function updateFacialHair(uint _value) public onlyOwner{
        facial_Hair = _value;
    }

    function updateFacialHairColor(uint _value) public onlyOwner{
        facial_Hair_color = _value;
    }

    function updateShirt1(uint _value) public onlyOwner{
        shirt1 = _value;
    }

    function updateShirtColor1(uint _value) public onlyOwner{
        shirt1_color = _value;
    }

    function updateNose(uint _value) public onlyOwner{
        nose = _value;
    }

    function updateNoseColor(uint _value) public onlyOwner{
        nose_Color = _value;
    }

    function updateMouth(uint _value) public onlyOwner{
        mouth = _value;
    }

    function updateMouthColor(uint _value) public onlyOwner{
        mouth = _value;
    }

    function updateEyes(uint _value) public onlyOwner{
        eyes = _value;
    }

    function updateEyeColor(uint _value) public onlyOwner{
        eye_Color = _value;
    }

    function updateHat(uint _value) public onlyOwner{
        hat = _value;
    }

    function updateHatColor(uint _value) public onlyOwner{
        hat_Color = _value;
    }

    function updateAccessoires(uint _value) public onlyOwner{
        accessoires = _value;
    }

    receive() external payable {}
}