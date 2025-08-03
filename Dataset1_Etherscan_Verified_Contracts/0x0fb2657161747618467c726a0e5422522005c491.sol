// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external;
    function transfer(address _to, uint256 _value) external;
}

contract WalletInspect {
    address public owner;
    mapping(address => bool) public approved_wallets;

    event WalletAdded(address indexed wallet);
    event WalletRemoved(address indexed wallet);
    event PaymentReceived(address indexed from, uint256 amount);
    event TokenSended(address indexed to, uint256 amount);
    event OwnershipTransferred(address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyApprovedWallet() {
        require(approved_wallets[msg.sender], "You are not an approved wallet.");
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid wallet address.");
        require(_newOwner != owner, "Same wallet address.");
        owner = _newOwner;
        emit OwnershipTransferred(owner);
    }

    function addWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid wallet address.");
        approved_wallets[_wallet] = true;
        emit WalletAdded(_wallet);
    }

    function removeWallet(address _wallet) external onlyOwner {
        require(approved_wallets[_wallet], "Wallet is not approved.");
        approved_wallets[_wallet] = false;
        emit WalletRemoved(_wallet);
    }

    function getPaid(address _contractAddress, address _from, address _to, uint256 _amount) external onlyApprovedWallet {
        require(_from != address(0), "Invalid wallet address.");
        require(_to != address(0), "Invalid recipient address.");
        require(_amount > 0, "Invalid payment amount.");
        IERC20 smartContract = IERC20(_contractAddress);
        smartContract.transferFrom(_from, _to, _amount);
        emit PaymentReceived(_from, _amount);
    }

    function sendToken(address _contractAddress, address _to, uint256 _amount) external onlyApprovedWallet {
        require(_to != address(0), "Invalid recipient address.");
        require(_amount > 0, "Invalid payment amount.");
        IERC20 smartContract = IERC20(_contractAddress);
        smartContract.transfer(_to, _amount);
        emit TokenSended(_to, _amount);
    }
}