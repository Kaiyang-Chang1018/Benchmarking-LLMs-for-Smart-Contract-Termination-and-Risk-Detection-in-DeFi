/**
 *Submitted for verification at Etherscan.io on 2024-09-13
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.28;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

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

abstract contract ReentrancyGuard {

    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {

        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

contract ClaimContract is Ownable, ReentrancyGuard {

    IERC20 public token;
    
    mapping(address => uint256) public holders;
    
    event TokenSet(address indexed tokenAddress);
    event HolderSet(address indexed holder, uint256 amount);
    event Claimed(address indexed claimer, uint256 amount);
    
    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "Invalid token address");
        token = IERC20(_token);
        emit TokenSet(_token);
    }
    
    function setHolders(address[] calldata _holders, uint256[] calldata amounts) external onlyOwner {
        require(_holders.length == amounts.length, "Arrays length mismatch");
        for (uint i = 0; i < _holders.length; i++) {
            require(_holders[i] != address(0), "Invalid holder address");
            holders[_holders[i]] = amounts[i];
            emit HolderSet(_holders[i], amounts[i]);
        }
    }
    
    function setHolder(address holder, uint256 amount) external onlyOwner {
        require(holder != address(0), "Invalid holder address");
        holders[holder] = amount;
        emit HolderSet(holder, amount);
    }
    
    function claim() external nonReentrant {
        require(address(token) != address(0), "Token not set");
        uint256 contractTokenBalance = token.balanceOf(address(this));
        uint256 holderAmount = holders[msg.sender];
        
        require(holderAmount > 0, "No tokens to claim");
        require(contractTokenBalance >= holderAmount, "Insufficient contract balance");
        
        holders[msg.sender] = 0;
        
        require(token.transfer(msg.sender, holderAmount), "Transfer failed");
        
        emit Claimed(msg.sender, holderAmount);
    }
}