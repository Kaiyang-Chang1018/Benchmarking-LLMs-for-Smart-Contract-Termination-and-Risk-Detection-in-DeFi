/**
 *Submitted for verification at Etherscan.io on 2025-01-14
*/

// SPDX-License-Identifier: MIT
/*
Telegram: https://t.me/ApePunkEth
X: https://x.com/Ap3Punk
Website: https://ApePunk.space
*/
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

contract ApePunk is IERC20 {
    string public constant name = "APE PUNK";
    string public constant symbol = "APK";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 260_000_000 * 10**decimals;

    // Mappings
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // Max wallet settings
    uint256 public maxWalletPercentage = 3; // 3% max wallet limit
    bool public maxWalletEnabled = true;
    
    // Owner only
    address private _owner;

    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipRenounced(address indexed previousOwner);
    event MaxWalletLimitUpdated(uint256 newPercentage);
    event MaxWalletStatusChanged(bool enabled);

    modifier onlyOwner() {
        require(msg.sender == _owner, "APEPUNK: Not the grand APEPUNK");
        _;
    }

    constructor() {
        _owner = msg.sender;
        _balances[_owner] = totalSupply;
        emit Transfer(address(0), _owner, totalSupply);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0) && recipient != address(0), "APEPUNK: Casting spells into the void");
        require(_balances[sender] >= amount, "APEPUNK: Not enough mana");
        
        // Check max wallet limit only if enabled
        if (maxWalletEnabled && recipient != _owner) {
            uint256 maxWalletAmount = (totalSupply * maxWalletPercentage) / 100;
            require(
                _balances[recipient] + amount <= maxWalletAmount,
                "APEPUNK: Exceeds max wallet limit"
            );
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
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "APEPUNK: Spell power too low");
        _transfer(sender, recipient, amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        return true;
    }

    // Owner functions
    function setMaxWalletPercentage(uint256 newPercentage) external onlyOwner {
        require(newPercentage > 0 && newPercentage <= 100, "APEPUNK: Invalid percentage");
        maxWalletPercentage = newPercentage;
        emit MaxWalletLimitUpdated(newPercentage);
    }

    function toggleMaxWallet(bool enabled) external onlyOwner {
        maxWalletEnabled = enabled;
        emit MaxWalletStatusChanged(enabled);
    }

    // Ownership management
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "APEPUNK: Cannot transfer to the void");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() external onlyOwner {
        address previousOwner = _owner;
        _owner = address(0);
        emit OwnershipRenounced(previousOwner);
    }

    function owner() public view returns (address) {
        return _owner;
    }
}