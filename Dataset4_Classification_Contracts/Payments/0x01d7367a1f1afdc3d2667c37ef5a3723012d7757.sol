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

contract FROGZ is IERC20 {
    string public constant name = "Frog Sorcerer";
    string public constant symbol = "FROGZ";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 69_420_000_000 * 10**decimals; // 69.42B tokens (combining two meme numbers)

    // Limits state
    bool public limitsEnabled = true;
    uint256 public maxWalletSize;
    uint256 public maxTransferSize;
    uint256 public minTransactionAmount;

    // Mappings
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public blacklist;
    mapping(address => bool) public whitelist;
    
    // Owner
    address private _owner;

    // Events
    event BlacklistAdded(address indexed account);
    event BlacklistRemoved(address indexed account);
    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipRenounced(address indexed previousOwner);
    event LimitsDisabled();
    event LimitsUpdated(uint256 maxWallet, uint256 maxTransfer, uint256 minTransaction);

    modifier onlyOwner() {
        require(msg.sender == _owner, "WIZARD: Not the grand wizard");
        _;
    }

    constructor() {
        _owner = msg.sender;

        // Set default limits
        maxWalletSize = totalSupply / 100;     // 1% of total supply
        maxTransferSize = totalSupply / 100;    // 1% of total supply
        minTransactionAmount = totalSupply / 1000; // 0.1% of total supply

        // Initial supply to owner
        _balances[_owner] = totalSupply;
        emit Transfer(address(0), _owner, totalSupply);

        // Add owner to whitelist
        whitelist[_owner] = true;
        emit WhitelistAdded(_owner);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0) && recipient != address(0), "WIZARD: Casting spells into the void");
        require(_balances[sender] >= amount, "WIZARD: Not enough mana");
        require(!blacklist[sender] && !blacklist[recipient], "WIZARD: Dark magic detected");

        // Check limits if enabled and not whitelisted
        if (limitsEnabled && !whitelist[sender] && !whitelist[recipient]) {
            require(amount >= minTransactionAmount, "WIZARD: Spell too weak");
            require(amount <= maxTransferSize, "WIZARD: Spell too powerful");
            require(_balances[recipient] + amount <= maxWalletSize, "WIZARD: Mana capacity exceeded");
        }

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        
        emit Transfer(sender, recipient, amount);
    }

    // ERC20 functions
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
        require(!blacklist[msg.sender] && !blacklist[spender], "WIZARD: Dark magic detected");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "WIZARD: Spell power too low");
        _transfer(sender, recipient, amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        return true;
    }

    // Owner functions
    function addToBlacklist(address account) external onlyOwner {
        require(account != address(0), "WIZARD: Cannot banish the void");
        blacklist[account] = true;
        emit BlacklistAdded(account);
    }

    function removeFromBlacklist(address account) external onlyOwner {
        require(account != address(0), "WIZARD: Cannot unbanish the void");
        blacklist[account] = false;
        emit BlacklistRemoved(account);
    }

    function addToWhitelist(address account) external onlyOwner {
        require(account != address(0), "WIZARD: Cannot bless the void");
        whitelist[account] = true;
        emit WhitelistAdded(account);
    }

    function removeFromWhitelist(address account) external onlyOwner {
        require(account != address(0), "WIZARD: Cannot unbless the void");
        require(account != _owner, "WIZARD: Grand wizard cannot be unblessed");
        whitelist[account] = false;
        emit WhitelistRemoved(account);
    }

    // Limit management functions
    function disableLimits() external onlyOwner {
        require(limitsEnabled, "WIZARD: Limits already disabled");
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
        require(limitsEnabled, "WIZARD: Limits are disabled");
        require(newMaxWallet <= totalSupply, "WIZARD: Max wallet exceeds total supply");
        require(newMaxTransfer <= totalSupply, "WIZARD: Max transfer exceeds total supply");
        require(newMinTransaction <= newMaxTransfer, "WIZARD: Min transfer exceeds max transfer");
        
        maxWalletSize = newMaxWallet;
        maxTransferSize = newMaxTransfer;
        minTransactionAmount = newMinTransaction;
        
        emit LimitsUpdated(newMaxWallet, newMaxTransfer, newMinTransaction);
    }

    // Ownership management
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "WIZARD: Cannot transfer to the void");
        whitelist[_owner] = false;
        whitelist[newOwner] = true;
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() external onlyOwner {
        address previousOwner = _owner;
        whitelist[_owner] = false;
        _owner = address(0);
        emit OwnershipRenounced(previousOwner);
    }

    function owner() public view returns (address) {
        return _owner;
    }
}