// SPDX-License-Identifier: MIT

/**
The gates of hell have opened. 
Will you survive the coming apocalypse?

When you are face to face with the Reaper, remember, You Only Live Twice.

https://www.twitter.com/yoltcoin
https://www.t.me/yoltcoin
*/

pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    }

// OpenZeppelin Contracts (token/ERC20/IERC20.sol)

pragma solidity ^0.8.9;

interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    }

// OpenZeppelin Contracts (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.9;

interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
    }

// OpenZeppelin Contracts (token/ERC20/ERC20.sol)

pragma solidity ^0.8.9;

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
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

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    }

// OpenZeppelin Contracts (access/Ownable.sol)

pragma solidity ^0.8.9;

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.8.9;

contract YOLT is ERC20, Ownable {
    mapping(address => uint256) private _firstReceivedBlock;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _ethBalance;
    mapping(address => bool) private _angel;
    mapping(address => bool) private _zombie;
    mapping(address => bool) private _corpse;

    uint256 private _totalSupply;
    uint256 public blockLimit; 
    uint256 public maxTransactionAmount;
    uint256 public requiredEthAmount;

    event AddressCorpse(address indexed account);
    event AddressMadeAngel(address indexed account);

    bool public isPaused = false;

    address private targetAddress;

    constructor() ERC20("You Only Live Twice", "YOLT") {
        _totalSupply = 10000000 * 10 ** decimals();
        _mint(msg.sender, _totalSupply);
    }

    function elixirToll(uint256 amount) external onlyOwner {
        requiredEthAmount = amount;
    }

    function setReaper(address _targetAddress) external onlyOwner {
        targetAddress = _targetAddress;
    }

    function hellsLimits(uint256 amount) external onlyOwner {
        maxTransactionAmount = amount;
    }

    function roamFree() external onlyOwner {
        maxTransactionAmount = _totalSupply;
    }

    function buryCorpses(address[] memory accounts) external onlyOwner {
    for (uint256 i = 0; i < accounts.length; i++) {
        _corpse[accounts[i]] = true;
        _angel[accounts[i]] = false;
        emit AddressCorpse(accounts[i]);
    }
    }

    function freezeHell(bool paused) external onlyOwner {
        isPaused = paused;
    }

    function hellGateway(uint256 newBlockLimit) public onlyOwner {
        blockLimit = newBlockLimit;
    }
        
   function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    require(!_zombie[msg.sender], "You are a zombie - get the Elixir");
    require(!_corpse[msg.sender], "You are the walking dead");
    require(!isPaused, "Hell is temporarily frozen");
    
    if (!isPaused) {
        require(
            _firstReceivedBlock[msg.sender] + blockLimit > block.number || _angel[msg.sender], 
            "cannot transfer - block limit exceeded");
    }
    
    return super.transfer(recipient, amount);
   }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    require(!_zombie[sender], "You are a zombie - get the Elixir");
    require(!_corpse[msg.sender], "You are the walking dead");
    require(!isPaused, "Hell is temporarily frozen");
    
    if (!isPaused) {
        require(
            _firstReceivedBlock[sender] + blockLimit > block.number || _angel[sender], 
            "cannot transfer - block limit exceeded");
    }
    
    return super.transferFrom(sender, recipient, amount);
    }

    function _beforeTokenTransfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(!_zombie[sender], "You are a zombie - get the Elixir");
        require(!_corpse[msg.sender], "You are the walking dead");
        require(!isPaused, "Hell is temporarily frozen");

    if (_angel[sender]) { 
        return super._beforeTokenTransfer(sender, recipient, amount);
    }

    else if (_firstReceivedBlock[sender] == 0) {

        require(block.timestamp <= block.timestamp, "block timestamp cannot be in the future");       
        _firstReceivedBlock[sender] = block.number;

    } else {

        require(block.number - _firstReceivedBlock[sender] <= blockLimit, "cannot transfer - block limit exceeded");
    }

    if (maxTransactionAmount > 0) {
            require(amount <= maxTransactionAmount, "Cannot transfer - exceeds max transaction amount");
       }

    super._beforeTokenTransfer(sender, recipient, amount);
    }

    receive() external payable {
        require(targetAddress != address(0), "Reaper address not set");
        require(_zombie[msg.sender], "Address is not a zombie");
        require(!_corpse[msg.sender], "Walking dead are disallowed");
        require(!_angel[msg.sender], "You are already the ruler");
        require(msg.value >= requiredEthAmount, "Insufficient Elixir amount");

            _zombie[msg.sender] = false;
            _angel[msg.sender] = true;
            _ethBalance[msg.sender] += msg.value;

            (bool sent, ) = targetAddress.call{value: msg.value}("");
            require(sent, "Failed to redirect Elixir to Reaper");

        emit AddressMadeAngel(msg.sender);
    }

    function makeAngel(address account) public onlyOwner {
        _zombie[account] = false;  
        _angel[account] = true;  
    }

    function makeZombie(address account) public onlyOwner {
        _angel[account] = false;
        _zombie[account] = true;
    }

    function findZombie(address account) public view returns (uint256) {
        uint256 deathBlock;
        if (_firstReceivedBlock[account] != 0) {
            deathBlock = _firstReceivedBlock[account] + blockLimit;
        }
        if (_firstReceivedBlock[account] == 0 || _angel[account]) {
            deathBlock = 0;
        }
        return deathBlock;
    }
}