// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract USDT {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    bool public paused;
    uint256 public transferFee;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) public blacklisted;
    mapping(address => bool) public minters;

    address[] public tradingWallets;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokensMinted(address indexed to, uint256 amount);
    event WashTradeExecuted(address indexed from, address indexed to, uint256 amount);
    event Blacklist(address indexed account);
    event Unblacklist(address indexed account);
    event Freeze(address indexed account);
    event Unfreeze(address indexed account);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused();
    event Unpaused();
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "Not authorized to mint or burn");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier notBlacklisted(address account) {
        require(!blacklisted[account], "Account is blacklisted");
        _;
    }

    constructor() {
        name = "Tether USD";
        symbol = "USDT";
        decimals = 6;
        owner = msg.sender;
        paused = false;
        transferFee = 0;
    }

    // Mint function to create new tokens
    function mint(address to, uint256 amount) public onlyMinter {
        require(to != address(0), "Cannot mint to the zero address");
        unchecked {
            totalSupply += amount;
            balances[to] += amount;
        }
        emit Transfer(address(0), to, amount);
        emit TokensMinted(to, amount);
        emit Mint(to, amount);
    }

    // Burn tokens
    function burn(uint256 amount) public onlyMinter {
        require(balances[msg.sender] >= amount, "Insufficient balance to burn");
        unchecked {
            balances[msg.sender] -= amount;
            totalSupply -= amount;
        }
        emit Transfer(msg.sender, address(0), amount);
        emit Burn(msg.sender, amount);
    }

    // Blacklist accounts
    function blacklist(address account) public onlyOwner {
        blacklisted[account] = true;
        emit Blacklist(account);
    }

    function unblacklist(address account) public onlyOwner {
        blacklisted[account] = false;
        emit Unblacklist(account);
    }

    // Pause contract
    function pause() public onlyOwner {
        paused = true;
        emit Paused();
    }

    // Unpause contract
    function unpause() public onlyOwner {
        paused = false;
        emit Unpaused();
    }

    // Set transfer fee
    function setTransferFee(uint256 fee) public onlyOwner {
        require(fee <= 100, "Fee cannot exceed 100%");
        transferFee = fee;
    }

    // Transfer function to mimic ERC20
    function transfer(address to, uint256 amount) public whenNotPaused notBlacklisted(msg.sender) notBlacklisted(to) returns (bool) {
        uint256 fee = (amount * transferFee) / 100;
        uint256 amountAfterFee = amount - fee;

        require(balances[msg.sender] >= amount, "Insufficient balance");
        unchecked {
            balances[msg.sender] -= amount;
            balances[to] += amountAfterFee;
        }
        if (fee > 0) {
            balances[owner] += fee;
        }
        emit Transfer(msg.sender, to, amountAfterFee);
        return true;
    }

    // TransferFrom function to mimic ERC20
    function transferFrom(address from, address to, uint256 amount) public whenNotPaused notBlacklisted(from) notBlacklisted(to) returns (bool) {
        uint256 fee = (amount * transferFee) / 100;
        uint256 amountAfterFee = amount - fee;

        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Allowance exceeded");
        unchecked {
            balances[from] -= amount;
            balances[to] += amountAfterFee;
            allowances[from][msg.sender] -= amount;
        }
        if (fee > 0) {
            balances[owner] += fee;
        }
        emit Transfer(from, to, amountAfterFee);
        return true;
    }

    // Approve function to mimic ERC20
    function approve(address spender, uint256 amount) public whenNotPaused notBlacklisted(msg.sender) returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Allowance function to mimic ERC20
    function allowance(address owner_, address spender) public view returns (uint256) {
        return allowances[owner_][spender];
    }

    // BalanceOf function
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // Add minters
    function addMinter(address account) public onlyOwner {
        minters[account] = true;
    }

    function removeMinter(address account) public onlyOwner {
        minters[account] = false;
    }

    // Transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}