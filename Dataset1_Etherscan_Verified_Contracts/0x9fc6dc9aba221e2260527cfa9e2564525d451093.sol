// SPDX-License-Identifier: MIT

// About EIGHTBET (8BET)
// 8bet is a crypto-based platform that incorporates live wagering games, where users can place bets in real-time, as well as a token-gated wagering game feature. The platform provides an engaging and interactive way for users to participate in betting activities that leverage blockchain technology for security and transparency.

// Links:
// Website: https://8bet.one/
// Telegram: https://t.me/eightbeteth
// Twitter: https://x.com/eightbeteth
// Litepaper: https://8bet.one/litepaper

pragma solidity ^0.8.19;

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract EIGHTBET is IERC20, Ownable {
    
    string private _name = "EIGHTBET";
    string private _symbol = "8BET";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000 * (10 ** decimals());
    uint256 private _creationTimestamp;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isHolder;
    address[] private _holders;

    constructor() {
        _creationTimestamp = block.timestamp;
        _balances[owner()] = _totalSupply;
        _isHolder[owner()] = true;
        _holders.push(owner());
        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        if (!_isHolder[to] && _balances[to] > 0) {
            _isHolder[to] = true;
            _holders.push(to);
        }

        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    // Custom functions

    // Function to get the contract creation timestamp
    function getContractCreationTimestamp() public view returns (uint256) {
        return _creationTimestamp;
    }

    // Function to get a summary of token details
    function getTokenDetails() public view returns (string memory) {
        return string(abi.encodePacked("Name: ", _name, ", Symbol: ", _symbol, ", Decimals: ", _decimals));
    }

    // Function to get the number of unique holders
    function getHolderCount() public view returns (uint256) {
        return _holders.length;
    }

    // Function to get details of the owner address
    function getOwnerAddressDetails() public view returns (address, uint256) {
        return (owner(), _balances[owner()]);
    }

    // Function to check if an address is a token holder
    function isHolder(address account) public view returns (bool) {
        return _isHolder[account];
    }

    // Function to get the top n holders by balance
    function getTopHolders(uint256 n) public view returns (address[] memory) {
        require(n <= _holders.length, "Requested number exceeds total holders");
        address[] memory topHolders = new address[](n);

        // Simple implementation to get the top n holders
        for (uint256 i = 0; i < n; i++) {
            topHolders[i] = _holders[i];
        }

        return topHolders;
    }
}