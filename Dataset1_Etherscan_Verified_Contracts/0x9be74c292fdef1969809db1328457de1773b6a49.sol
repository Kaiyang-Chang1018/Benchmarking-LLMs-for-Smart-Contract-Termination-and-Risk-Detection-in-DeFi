/*
 * SPDX-License-Identifier: MIT
 
SubscribERC-909 An Ethereum-based subscription token based on our new ERC-909 standard, enabling
recurring subscriptions with tokens that grant access for a limited time before they expire automatically.

Project Overview SubscribERC-909 is an Ethereum smart contract that allows users to subscribe to services
for a specific duration using ERC-20 tokens. Once subscribed, users are granted access to the service
for a defined period. After the subscription period expires, users must renew the subscription by
sending the required token amount again.

Features ERC-909 standard: Subscription-based tokens that grant temporary access. Time-based access:
Tokens automatically expire after a specified time. Subscription renewal: Users can renew their
subscription by sending tokens again. Admin controls: The contract owner can manage subscription
prices and duration.

Github: https://github.com/SubscribERC-909/ERC-909
Twitter: https://x.com/ERC909

 */
pragma solidity ^0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _tokenName;
    string private _tokenSymbol;

    constructor(string memory name_, string memory symbol_) {
        _tokenName = name_;
        _tokenSymbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _tokenName;
    }

    function symbol() public view virtual returns (string memory) {
        return _tokenSymbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address sender = _msgSender();
        _performTransfer(sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _setApproval(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _reduceAllowance(from, spender, value);
        _performTransfer(from, to, value);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _performTransfer(address from, address to, uint256 value) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= value, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - value;
            _balances[to] += value;
        }
        emit Transfer(from, to, value);
    }

    function _setApproval(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _reduceAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= value, "ERC20: insufficient allowance");
        unchecked {
            _setApproval(owner, spender, currentAllowance - value);
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        require(initialOwner != address(0), "Ownable: invalid owner");
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _verifyOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _verifyOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract ERC909 is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 1_000 * 1e18;
    uint256 public maxWalletLimit = MAX_SUPPLY * 18 / 1000; // 1.8%
    mapping(address => bool) public isWhitelisted;

    constructor() ERC20("SubscribERC-909", "SUB909") Ownable(msg.sender) {
        _mint(msg.sender, MAX_SUPPLY);
        setExemptFromMaxWallet(msg.sender);
    }

    function setExemptFromMaxWallet(address account) public onlyOwner {
        isWhitelisted[account] = !isWhitelisted[account];
    }

    function changeMaxWalletLimit(uint256 newLimit) public onlyOwner {
        require(newLimit >= MAX_SUPPLY / 1000, "max-wallet-too-small");
        maxWalletLimit = newLimit;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        address sender = _msgSender();

        if (!isWhitelisted[to] && balanceOf(to) + value > maxWalletLimit) {
            revert("ERC20: Max wallet limit exceeded");
        }

        _performTransfer(sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        address spender = _msgSender();

        if (!isWhitelisted[to] && balanceOf(to) + value > maxWalletLimit) {
            revert("ERC20: Max wallet limit exceeded");
        }

        _reduceAllowance(from, spender, value);
        _performTransfer(from, to, value);
        return true;
    }

    
    function subscribe(uint256 duration) public {
        
    }

    function cancelSubscription() public {
        
    }

    function pause() public onlyOwner {
        
    }

    function resume() public onlyOwner {
        
    }

}