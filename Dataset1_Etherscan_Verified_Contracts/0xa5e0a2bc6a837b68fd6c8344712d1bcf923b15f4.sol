// SPDX-License-Identifier: MIT

/*
   ___ _____ _____ ___ ___   _      _   ___ ___ 
  / _ \_   _|_   _| __| _ \ | |    /_\ | _ ) __|
 | (_) || |   | | | _||   / | |__ / _ \| _ \__ \
  \___/ |_|   |_| |___|_|_\ |____/_/ \_\___/___/                          

Otter Labs (OTTER) - Otter Labs gamifies token staking to reward loyalty, reduce volatility, and strengthen ecosystems. By making holding fun and profitable, we've cracked the code on sustainable tokenomics – where patience pays and communities thrive.

Website: https://otterlabs.lol/
Telegram: https://t.me/otterlabstg
Twitter: https://x.com/otterlabs_
*/

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

contract otterlabs is IERC20, Ownable {
    
    string private _name = "Otter Labs";
    string private _symbol = "OTTER";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 100000000 * (10 ** decimals());
    uint256 private _creationTimestamp;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor () {
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
        _creationTimestamp = block.timestamp;
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

    // Added unique read functions below

    /**
     * @dev Returns the contract creation timestamp
     */
    function getCreationTime() public view returns (uint256) {
        return _creationTimestamp;
    }

    /**
     * @dev Returns the age of the token contract in days
     */
    function getTokenAge() public view returns (uint256) {
        return (block.timestamp - _creationTimestamp) / 1 days;
    }

    /**
     * @dev Returns the token version (can be updated in future implementations)
     */
    function getTokenVersion() public pure returns (string memory) {
        return "1.0.0";
    }

    /**
     * @dev Returns the contract address as bytes32
     */
    function getContractIdentifier() public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), _creationTimestamp));
    }

    /**
     * @dev Returns the balance percentage of an account relative to total supply
     * @param account The address to check
     */
    function getHolderPercentage(address account) public view returns (uint256) {
        return (_balances[account] * 10000) / _totalSupply;  // Returns basis points (1/100 of a percent)
    }

    /**
     * @dev Returns theoretical market capitalization at a given token price
     * @param pricePerToken The price of one token in wei
     */
    function getTheoreticalMarketCap(uint256 pricePerToken) public view returns (uint256) {
        return _totalSupply * pricePerToken / (10 ** decimals());
    }

    /**
     * @dev Returns unique token fingerprint (a hash of several token properties)
     */
    function getTokenFingerprint() public view returns (bytes32) {
        return keccak256(abi.encodePacked(_name, _symbol, _totalSupply, _creationTimestamp));
    }
    
    /**
     * @dev Returns the token description
     */
    function getTokenDescription() public pure returns (string memory) {
        return "Revolutionizing DeFi with gamified yield farming ecosystems that empower communities and developers to create sustainable staking incentives and advanced liquidity locking mechanisms.";
    }
    
    /**
     * @dev Returns the project website
     */
    function getProjectWebsite() public pure returns (string memory) {
        return "https://otterlabs.lol/";
    }
    
    /**
     * @dev Returns social media links
     */
    function getSocialMediaLinks() public pure returns (string memory, string memory) {
        return ("https://t.me/otterlabstg", "https://x.com/otterlabs_");
    }

    /**
     * @dev Returns circulating supply (total supply minus contract balance)
     */
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - _balances[address(this)];
    }
}