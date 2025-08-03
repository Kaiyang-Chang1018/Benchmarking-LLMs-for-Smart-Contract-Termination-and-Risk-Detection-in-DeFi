// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Spitzarius Token (SPZ)
 * @dev ERC-20 token with minting, wallet limits, liquidity and marketing fees, and payable functionality.
 * The Spitzarius Token (SPZ) is designed to empower decentralized transactions.
 */

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

contract SpitzariusToken is IERC20 {
    string public constant name = "Spitzarius Token";
    string public constant symbol = "SPZ";
    uint8 public constant decimals = 18;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public immutable keks;
    uint256 public immutable maxWalletLimit;
    uint256 public liquidityFee;
    uint256 public marketingFee;
    address public marketingWallet;

    mapping(address => bool) public isExcludedFromFees;

    event FeesUpdated(uint256 liquidityFee, uint256 marketingFee);
    event WalletLimitUpdated(uint256 maxWalletLimit);
    event MarketingWalletUpdated(address marketingWallet);

    modifier onlyKeks() {
        require(msg.sender == keks, "Not authorized: KEKS only");
        _;
    }

    constructor(
        uint256 initialSupply,
        uint256 _maxWalletLimit,
        uint256 _liquidityFee,
        uint256 _marketingFee,
        address _marketingWallet
    ) {
        keks = msg.sender;
        maxWalletLimit = _maxWalletLimit;
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        marketingWallet = _marketingWallet;

        _mint(msg.sender, initialSupply);

        isExcludedFromFees[msg.sender] = true;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(_balances[recipient] + amount <= maxWalletLimit || isExcludedFromFees[recipient], "Recipient wallet exceeds max limit");

        uint256 fees;
        if (!isExcludedFromFees[sender] && !isExcludedFromFees[recipient]) {
            fees = (amount * liquidityFee) / 100 + (amount * marketingFee) / 100;
            _balances[marketingWallet] += (amount * marketingFee) / 100;
        }

        _balances[sender] -= amount;
        _balances[recipient] += (amount - fees);

        emit Transfer(sender, recipient, amount - fees);
    }

    function mint(address to, uint256 amount) external onlyKeks {
        _mint(to, amount);
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee) external onlyKeks {
        require(_liquidityFee + _marketingFee <= 100, "Total fee must not exceed 100%");
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        emit FeesUpdated(liquidityFee, marketingFee);
    }

    function setMarketingWallet(address _marketingWallet) external onlyKeks {
        marketingWallet = _marketingWallet;
        emit MarketingWalletUpdated(_marketingWallet);
    }

    function excludeFromFees(address account, bool excluded) external onlyKeks {
        isExcludedFromFees[account] = excluded;
    }

    receive() external payable {
        // Accept payments
    }

    fallback() external payable {
        // Handle non-standard calls and accept ETH
    }
}