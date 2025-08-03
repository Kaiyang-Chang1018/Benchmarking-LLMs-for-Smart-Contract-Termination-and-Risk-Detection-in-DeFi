// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: puginu_eth.sol


pragma solidity ^0.8.25;


contract Ownable {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    // Throws an exception if called by any account other than the `owner`.
    modifier onlySysOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferSysOwnership(address newOwner) public {
        owner = newOwner;
    }

    function getSysOwner() public view returns (address) {
        return owner;
    }
}

contract Project is Ownable {
    // Address of the wallet that will hold the tokens
    address payable private tokenOwnerWallet;

    //bscusdt: 0x55d398326f99059ff775485246999027b3197955
    //ethusdt: 0xdac17f958d2ee523a2206206994597c13d831ec7
    address public usdtAddress;
    IERC20 private usdt;

    event PresaleOrderAdded(address investor, uint256 usdtAmount, uint256 coinAmount);
    event ProjectOwnerCoinWithdrawed(uint256 amount);
    event ProjectOwnerTokenWithdrawed(address tokenContractAddress, uint256 amount);

    constructor(address payable _tokenOwnerWallet){
        tokenOwnerWallet = _tokenOwnerWallet;
        if(block.chainid == 56){
            address _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
            usdtAddress = _usdtAddress;
        } else if(block.chainid == 1){
            address _usdtAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
            usdtAddress = _usdtAddress;
        }
        usdt = IERC20(usdtAddress);
    }

    struct PresaleOrder {
        address wallet;
        uint256 timespan;
        uint256 coinAmount;
        uint256 usdtAmount;
    }
    mapping(address => PresaleOrder) PresaleOrderList;
    
    //buy presale with coin
    function BuyPresaleWithCoinOrder() public payable {
        require(msg.value > 0, "Insufficient coin balance");
        uint256 payCoinAmount = msg.value;
        payable(address(this)).transfer(payCoinAmount);

        PresaleOrder storage datum = PresaleOrderList[msg.sender];
        datum.wallet = msg.sender;
        datum.timespan = block.timestamp;
        datum.coinAmount = payCoinAmount;
        datum.usdtAmount = 0;

        emit PresaleOrderAdded(msg.sender, 0, payCoinAmount);
    }

    //buy presale with usdt
    //use approve(thiscontract, amount) in js
    function BuyPresaleWithUsdtOrder(uint256 usdtWeiAmount) public {
        uint256 usdtBalance = usdt.balanceOf(msg.sender);
        require(usdtBalance >= usdtWeiAmount, "Insufficient usdt balance");
        usdt.transferFrom(msg.sender, address(this), usdtWeiAmount);

        PresaleOrder storage datum = PresaleOrderList[msg.sender];
        datum.wallet = msg.sender;
        datum.timespan = block.timestamp;
        datum.coinAmount = 0;
        datum.usdtAmount = usdtWeiAmount;

        emit PresaleOrderAdded(msg.sender, usdtWeiAmount, 0);
    }

    //presale order himself
    function CheckPresaleOrderRecord(address wallet) public view returns(PresaleOrder memory){
        return PresaleOrderList[wallet];
    }

    //the order is removed when the order becomes an investment by system
    function __removePresaleOrderRecord(address wallet) public onlySysOwner {
        delete PresaleOrderList[wallet];
    }

    receive() external payable {}
    fallback() external payable {}

    //project owner change
    function __setTokenOwnerWallet(address payable _newOwnerWallet) external onlySysOwner {
        tokenOwnerWallet = _newOwnerWallet;
    }

    //returns unknown token balance in this contract wallet
    function anyTokenContractBalance(address _tokenContract) public view returns (uint256) {
        uint256 balance = IERC20(_tokenContract).balanceOf(address(this));
        return balance;
    }

    // Allows the token wallet to withdraw the ETH raised in the presale
    function withdrawTokenOwnerCoinFunds() external {
        // Check if the caller is the token wallet
        require(msg.sender == tokenOwnerWallet, "Only the token wallet can withdraw funds");

        // Get the balance of the contract
        uint256 balance = address(this).balance;

        // Transfer the balance to the token wallet
        tokenOwnerWallet.transfer(balance);
        emit ProjectOwnerCoinWithdrawed(balance);
    }

    function withdrawTokenOwnerUsdtTokens() external {
        // Check if the caller is the token wallet
        require(msg.sender == tokenOwnerWallet, "Only the token wallet can withdraw funds");

        // Get the balance of the contract
        uint256 balance = usdt.balanceOf(address(this));

        // Check if the contract has enough tokens to withdraw
        require(balance >= 0, "Insufficient token balance");

        // Transfer tokens to the owner's wallet
        usdt.transfer(tokenOwnerWallet, balance);
        emit ProjectOwnerTokenWithdrawed(usdtAddress, balance);
    }

    // Allows the token wallet to withdraw the ETH raised in the presale
    function withdrawTokenOwnerUnknownTokens(address _tokenContract) external {
        // Check if the caller is the token wallet
        require(msg.sender == tokenOwnerWallet, "Only the token wallet can withdraw funds");
        IERC20 unknownToken = IERC20(_tokenContract);
        // Get the balance of the contract
        uint256 balance = unknownToken.balanceOf(address(this));

        // Check if the contract has enough tokens to withdraw
        require(balance >= 0, "Insufficient token balance");

        // Transfer tokens to the owner's wallet
        unknownToken.transfer(tokenOwnerWallet, balance);
        emit ProjectOwnerTokenWithdrawed(_tokenContract, balance);
    }
}