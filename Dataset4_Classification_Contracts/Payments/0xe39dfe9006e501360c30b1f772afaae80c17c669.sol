// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
      * @dev The Ownable constructor sets the original `owner` of the contract to the sender
      * account.
      */
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
      * @dev Throws if called by any account other than the owner.
      */
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface ERC20Basic {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface ERC20 is ERC20Basic {
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is Ownable, ERC20Basic, ERC20 {
    mapping (address => mapping (address => uint256)) public allowed;
    mapping (address => uint256) public balances;

    uint256 public _totalSupply;

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) virtual public override onlyPayloadSize(3 * 32) returns (bool) {
        require( _to != address(this) );
        uint256 _allowance = allowed[_from][msg.sender];
        
        if (_allowance < type(uint256).max) {
            allowed[_from][msg.sender] = _allowance - _value;
        }

        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) virtual public override onlyPayloadSize(2 * 32) returns (bool) {
        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)), "ERC20: approve from non-zero to non-zero allowance");

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) virtual public view override returns (uint256 remaining) {
    /**
    * @dev Function to check the amount of tokens than an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.    
    */

        return allowed[_owner][_spender];
    }

    /**
    * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint256 size) {
        require(msg.data.length >= size + 4, "BasicToken: payload size is too small");
        _;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public virtual onlyPayloadSize(2 * 32) returns (bool) {
        require( _to != address(this) );

        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) virtual public view returns (uint256) {
        return balances[_owner];
    }

    function totalSupply() virtual public view returns (uint256) {
        return _totalSupply;
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

contract BlackList is Ownable {
    mapping (address => bool) public isBlackListed;

    event AddedBlackList(address indexed _user);
    event RemovedBlackList(address indexed _user);

    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    function addBlackList(address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList(address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }
}

interface UpgradedStandardToken {
    function transferByLegacy(address from, address to, uint256 value) external;
    function transferFromByLegacy(address sender, address from, address to, uint256 value) external;
    function approveByLegacy(address from, address spender, uint256 value) external;
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

contract IPv6Token is Pausable, StandardToken, BlackList {
    string public name;
    string public symbol;
    uint256 public decimals;
    address public upgradedAddress;
    bool public deprecated;

    // total tokens limit * decimals and + 1 - XXXXXXXX - XXXXXXX (reserved)
    uint256 public constant _totalLimit =  278167850713087000001;

    event Issue(uint256 amount);
    event Redeem(uint256 amount);
    event Deprecate(address indexed newAddress);

    constructor(uint256 _initialSupply, string memory _name, string memory _symbol, uint256 _decimals) {
        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[owner] = _initialSupply;
        deprecated = false;
    }

    function transfer(address _to, uint256 _value) override public whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender], "IPv6Token: sender is blacklisted");
        if (deprecated) {
            UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
        } else {
            return super.transfer(_to, _value);
        }
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override whenNotPaused returns (bool) {
        require(!isBlackListed[_from], "IPv6Token: sender is blacklisted");
        if (deprecated) {
            UpgradedStandardToken(upgradedAddress).transferFromByLegacy(msg.sender, _from, _to, _value);
        } else {
            return super.transferFrom(_from, _to, _value);
        }
        return true;
    }

     function balanceOf(address who) override public view returns (uint256) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).balanceOf(who);
        } else {
            return super.balanceOf(who);
        }
    }

    function approve(address _spender, uint256 _value) public override onlyPayloadSize(2 * 32) returns (bool) {
        if (deprecated) {
            UpgradedStandardToken(upgradedAddress).approveByLegacy(msg.sender, _spender, _value);
        } else {
            super.approve(_spender, _value);
        }
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).allowance(_owner, _spender);
        } else {
            return super.allowance(_owner, _spender);
        }
    }

    function deprecate(address _upgradedAddress) public onlyOwner {
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        emit Deprecate(_upgradedAddress);
    }

    function totalSupply() override public view returns (uint256) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).totalSupply();
        } else {
            return _totalSupply;
        }
    }

    function issue(uint256 amount) public onlyOwner {
        require(_totalSupply + amount > _totalSupply, "IPv6Token: overflow detected");
        require(balances[owner] + amount > balances[owner], "IPv6Token: overflow detected");
        require(_totalSupply + amount < _totalLimit, "IPv6Token: Resource limit reached");

        balances[owner] = balances[owner] + amount;
        _totalSupply = _totalSupply + amount;
        emit Issue(amount);
    }

    function redeem(uint256 amount) public onlyOwner {
        require(_totalSupply >= amount, "IPv6Token: insufficient supply");
        require(balances[owner] >= amount, "IPv6Token: insufficient balance");

        balances[owner] = balances[owner] - amount;
        _totalSupply = _totalSupply - amount;
        emit Redeem(amount);
    }
}