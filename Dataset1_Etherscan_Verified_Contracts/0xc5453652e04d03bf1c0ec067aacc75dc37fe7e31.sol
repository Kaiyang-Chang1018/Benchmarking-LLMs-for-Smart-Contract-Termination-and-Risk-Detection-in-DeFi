// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner_, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner_, address indexed spender, uint256 value);
}

contract PEPEPIZZAKING is IERC20 {
    string public constant name = "PEPE PIZZA KING";
    string public constant symbol = "PEPKING";
    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 420_000_000 * 10**decimals; // 420 milionů tokenů (meme číslo)

    // Poplatky (0.3%)
    uint256 public constant TRANSACTION_FEE = 3;
    
    // Limity
    bool public limitsEnabled = true;
    uint256 public maxWalletSize;
    uint256 public maxTransferSize;
    uint256 public minTransactionAmount;

    // Mapování
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public blacklist;
    mapping(address => bool) public whitelist;
    
    // Owner a fee recipient
    address private _owner;
    address public immutable feeRecipient;

    // Events
    event LimitsDisabled();
    event BlacklistAdded(address indexed account);
    event BlacklistRemoved(address indexed account);
    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    constructor(address initialFeeRecipient) {
        require(initialFeeRecipient != address(0), "Zero address");
        
        _owner = msg.sender;
        feeRecipient = initialFeeRecipient;

        // Nastavení výchozích limitů
        maxWalletSize = totalSupply / 100;     // 1% z total supply
        maxTransferSize = totalSupply / 100;    // 1% z total supply
        minTransactionAmount = totalSupply / 1000; // 0.1% z total supply

        // Přidělení total supply ownerovi
        _balances[_owner] = totalSupply;
        emit Transfer(address(0), _owner, totalSupply);

        // Přidání ownera na whitelist
        whitelist[_owner] = true;
        emit WhitelistAdded(_owner);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0) && recipient != address(0), "Zero address");
        require(_balances[sender] >= amount, "Insufficient balance");
        require(!blacklist[sender] && !blacklist[recipient], "Blacklisted");

        // Kontrola limitů pokud nejsou na whitelistu
        if (limitsEnabled && !whitelist[sender] && !whitelist[recipient]) {
            require(amount >= minTransactionAmount, "Below min amount");
            require(amount <= maxTransferSize, "Exceeds max transfer");
            require(_balances[recipient] + amount <= maxWalletSize, "Exceeds wallet size");
        }

        // Výpočet poplatku
        uint256 fee = 0;
        if (!whitelist[sender] && !whitelist[recipient]) {
            fee = (amount * TRANSACTION_FEE) / 1000;
        }

        // Převod
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + (amount - fee);
        
        if (fee > 0) {
            _balances[feeRecipient] += fee;
            emit Transfer(sender, feeRecipient, fee);
        }

        emit Transfer(sender, recipient, amount - fee);
    }

    // ERC20 funkce
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(!blacklist[msg.sender] && !blacklist[spender], "Blacklisted");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "Insufficient allowance");
        _transfer(sender, recipient, amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        return true;
    }

    // Owner funkce
    function addToBlacklist(address account) external onlyOwner {
        require(account != address(0), "Zero address");
        blacklist[account] = true;
        emit BlacklistAdded(account);
    }

    function removeFromBlacklist(address account) external onlyOwner {
        require(account != address(0), "Zero address");
        blacklist[account] = false;
        emit BlacklistRemoved(account);
    }

    function addToWhitelist(address account) external onlyOwner {
        require(account != address(0), "Zero address");
        whitelist[account] = true;
        emit WhitelistAdded(account);
    }

    function removeFromWhitelist(address account) external onlyOwner {
        require(account != address(0), "Zero address");
        require(account != _owner, "Cannot remove owner");
        whitelist[account] = false;
        emit WhitelistRemoved(account);
    }

    function disableLimits() external onlyOwner {
        require(limitsEnabled, "Already disabled");
        limitsEnabled = false;
        maxWalletSize = totalSupply;
        maxTransferSize = totalSupply;
        minTransactionAmount = 0;
        emit LimitsDisabled();
    }

    function setTransferLimits(
        uint256 newMaxWallet,
        uint256 newMaxTransfer,
        uint256 newMinTransaction
    ) external onlyOwner {
        require(limitsEnabled, "Limits disabled");
        require(newMaxWallet <= totalSupply, "Max wallet too high");
        require(newMaxTransfer <= totalSupply, "Max transfer too high");
        require(newMinTransaction <= newMaxTransfer, "Min higher than max");
        
        maxWalletSize = newMaxWallet;
        maxTransferSize = newMaxTransfer;
        minTransactionAmount = newMinTransaction;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        whitelist[_owner] = false;
        whitelist[newOwner] = true;
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }
}