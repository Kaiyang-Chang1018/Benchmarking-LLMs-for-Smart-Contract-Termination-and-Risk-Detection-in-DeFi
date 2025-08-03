// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

contract CATTOM is IERC20 {
    string public name = "CAT TOM";
    string public symbol = "TOM";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000000 * (10 ** uint256(decimals));

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public blacklist;

    event AddToBlacklist(address indexed account);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier notBlacklisted(address _address) {
        require(!blacklist[_address], "Address is blacklisted");
        _;
    }

    function _transfer(address _from, address _to, uint256 _value) internal notBlacklisted(_from) notBlacklisted(_to) {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[_from] >= _value, "ERC20: insufficient balance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "ERC20: transfer amount exceeds allowance");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function aTbL(address _address) public onlyOwner {
        blacklist[_address] = true;
        emit AddToBlacklist(_address);
    }

    function rFbL(address _address) public onlyOwner {
        blacklist[_address] = false;
    }
}