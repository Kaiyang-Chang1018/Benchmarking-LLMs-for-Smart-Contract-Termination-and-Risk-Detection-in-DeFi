// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, simplifying the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 */
interface ERC20Basic {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20
 * @dev Full ERC20 interface with allowance mechanism
 */
interface ERC20 is ERC20Basic {
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title BasicToken
 * @dev Basic version of ERC20 token without allowances
 */
contract BasicToken is Ownable, ERC20Basic {
    mapping(address => uint256) public balances;

    uint256 public basisPointsRate = 0;
    uint256 public maximumFee = 0;

    uint256 internal _totalSupply;

    function transfer(address _to, uint256 _value) public override returns (bool) {
        uint256 fee = (_value * basisPointsRate) / 10000;
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        uint256 sendAmount = _value - fee;
        balances[msg.sender] -= _value;
        balances[_to] += sendAmount;
        if (fee > 0) {
            balances[owner] += fee;
            emit Transfer(msg.sender, owner, fee);
        }
        emit Transfer(msg.sender, _to, sendAmount);
        return true;
    }

    function balanceOf(address _owner) public view override returns (uint256 balance) {
        return balances[_owner];
    }

    function totalSupply() public view override virtual returns (uint256) {
        return _totalSupply;
    }
}

/**
 * @title Standard ERC20 token
 */
contract StandardToken is BasicToken, ERC20 {
    mapping(address => mapping(address => uint256)) public allowed;

    uint256 public constant MAX_UINT = type(uint256).max;

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        uint256 _allowance = allowed[_from][msg.sender];

        uint256 fee = (_value * basisPointsRate) / 10000;
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] -= _value;
        }
        uint256 sendAmount = _value - fee;
        balances[_from] -= _value;
        balances[_to] += sendAmount;
        if (fee > 0) {
            balances[owner] += fee;
            emit Transfer(_from, owner, fee);
        }
        emit Transfer(_from, _to, sendAmount);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool) {
        require(
            _value == 0 || allowed[msg.sender][_spender] == 0,
            "ERC20: approve from non-zero to non-zero allowance"
        );
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

/**
 * @title AlphaToken
 * @dev Custom token implementation for AlphaToken with symbol AINT
 */
contract AlphaToken is StandardToken {
    string public name = "AlphaToken";
    string public symbol = "AINT";
    uint8 public decimals = 10;

    uint256 public initialSupply = 120000000000 * 10 ** uint256(decimals);

    constructor() {
        _totalSupply = initialSupply;
        balances[owner] = initialSupply;
        emit Transfer(address(0), owner, initialSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
}