// Why hodl when you can cry with Sad Cat? ?? 
// Sad Cat Coin is all about bringing some humor (and tears) to the ETH network. 
// Join us and let's turn those sad vibes into something legendary!

// Telegram: https://t.me/coinSadcat
// Twitter: https://x.com/coinsadcat
// Website: https://sadcat.cloud

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract SADCAT {
    string public name = "SAD CAT";
    string public symbol = "SADCAT";
    uint256 public totalSupply = 88888888888888888888888888888;
    uint8 public decimals = 18;
    
    address public owner;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0x000000000000000000000000000000000000dEaD));
        owner = address(0x000000000000000000000000000000000000dEaD);
    }
}