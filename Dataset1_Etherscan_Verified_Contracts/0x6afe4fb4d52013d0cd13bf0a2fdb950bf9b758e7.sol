// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ERC20 Implementation (added directly here)
abstract contract ERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8 ) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < value) {
            revert("Allowance exceeded");
        }
        _approve(owner, spender, currentAllowance - value);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Add the mint function to be accessible
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}

// Ownable Implementation (added directly here)
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }

    // Function to prevent ownership renouncement
    function renounceOwnership() public view onlyOwner {
        revert("Ownership renouncement is disabled");
    }
}

// ReentrancyGuard Implementation (added directly here)
abstract contract ReentrancyGuard {
    uint256 private _status;

    constructor() {
        _status = 1;
    }

    modifier nonReentrant() {
        require(_status != 2, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }
}

// CovfefeToken Contract (main contract)
contract CovfefeToken is ERC20, Ownable, ReentrancyGuard {
    uint256 private constant _totalSupply = 10000000000 * 10 ** 18; // 10 billion tokens
    address private _taxWallet;
    uint256 private constant _taxFee = 150; // 1.5% tax fee (150 basis points)
    uint256 private constant _feeDenominator = 10000;

    event TaxWalletChanged(address indexed previousWallet, address indexed newWallet);

    constructor(address taxWallet) ERC20("COVFEFE TOKEN", "COVFEFE") Ownable() {
        require(taxWallet != address(0), "Invalid tax wallet address");
        _taxWallet = taxWallet;
        _mint(msg.sender, _totalSupply); // Mint the tokens to the contract creator (msg.sender)
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 taxAmount = (amount * _taxFee) / _feeDenominator;
        uint256 transferAmount = amount - taxAmount;

        _transfer(msg.sender, _taxWallet, taxAmount); // Send tax to taxWallet
        _transfer(msg.sender, recipient, transferAmount); // Send the remaining amount to the recipient
        return true;
    }

    function setTaxWallet(address newTaxWallet) external onlyOwner {
        require(newTaxWallet != address(0), "Invalid tax wallet address");
        emit TaxWalletChanged(_taxWallet, newTaxWallet);
        _taxWallet = newTaxWallet;
    }
}