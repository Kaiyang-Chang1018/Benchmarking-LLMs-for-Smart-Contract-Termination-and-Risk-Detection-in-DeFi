// SPDX-License-Identifier: MIT

/**
  TG: https://t.me/tuxonlinux
  X: https://x.com/tuxonlinux
  Website: https://www.linuxpenguin.meme/
*/

pragma solidity ^0.8.7;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
}

contract Ownable {
    address public owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

interface ERC20 {

    function balanceOf(address who) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    function allowance(address owner, address spender) external view returns (uint);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);

    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC20Token is ERC20 {
    using SafeMath for uint256;

    uint256 public txFee;
    uint256 public burnFee;
    address public FeeAddress;
    uint256 public totalSupply;
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => mapping (address => uint256)) internal allowed;
    mapping(address => bool) public  tokenBlacklist;
    event Blacklist(address indexed blackListed, bool value);
    bool public paused;
    mapping(address => uint256) balances;


    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(!tokenBlacklist[sender], "StandardToken: sender is blacklisted");
        require(recipient != address(0), "StandardToken: transfer to the zero address");
        require(amount <= balances[sender], "StandardToken: transfer amount exceeds balance");
        if((!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]) ){
            require(!paused, "not start");
        }

        balances[sender] = balances[sender].sub(amount);
        uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ?
                                        amount : takeFee(sender, amount);


        balances[recipient] = balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        return amount;
    }

    function transfer(address _to, uint256 _value) public virtual override returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view virtual override returns (uint256 balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual override returns (bool) {
        _transfer(_from,_to,_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        return true;
    }

    function approve(address _spender, uint256 _value) public virtual override returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view virtual override returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue) public virtual returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public virtual returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract LinuxPenguin is ERC20Token,Ownable {
    string public name = "Linux Penguin";
    string public symbol = "TUX";
    uint public decimals = 9;

    event Mint(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);

    constructor()  {
        totalSupply = 1_000_000_000 * 10**decimals;
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0), owner, totalSupply);
    }

    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender], "Burn amount exceeds balance");
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
    }
    
    function pause(bool _pause) onlyOwner public {
        paused = _pause;
    }

    function blackListAddresses(address[] memory listAddresses,  bool isBlackListed) public onlyOwner {
        for(uint i = 0 ; i < listAddresses.length ; i++){
            tokenBlacklist[listAddresses[i]] = isBlackListed;
        }
    }

}