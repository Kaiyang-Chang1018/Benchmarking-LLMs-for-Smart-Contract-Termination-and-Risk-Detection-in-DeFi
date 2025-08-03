// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}


contract Hatercoin {
    using SafeMath for uint256;

    string public constant name = "Hatercoin";
    string public constant symbol = "HATER";
    uint8 public constant decimals = 18;
    uint256 public constant maxSupply = 8000000000 * 10**18; // 8 billion tokens

    address public owner;
    uint256 private totalSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) public allowances;
    bool private locked;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    
    event Burn(address indexed from, uint256 value);

    constructor() {
        owner = address(0); // No owner, contract renounced
        totalSupply = maxSupply; // Set initial total supply to 8 billion tokens
        balances[msg.sender] = maxSupply; // Mint all initial tokens to the contract deployer (you)
        emit Transfer(address(0), msg.sender, maxSupply);
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }

    function transfer(address recipient, uint256 amount)
        external
        nonReentrant
        returns (bool)
    {
        require(
            recipient != address(0),
            "Transfer to the zero address is not allowed"
        );
        require(
            amount <= balances[msg.sender],
            "Insufficient balance for transfer"
        );

        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) external nonReentrant {
        uint256 senderBalance = balances[msg.sender]; // Reuse storage variable
        require(senderBalance >= amount, "Insufficient balance for burning");

        balances[msg.sender] = senderBalance.sub(amount);
        totalSupply = totalSupply.sub(amount);

        emit Transfer(msg.sender, address(0), amount);
        emit Burn(msg.sender, amount);
    }

    

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(amount <= balances[sender], "Insufficient balance");
        require(amount <= allowances[sender][msg.sender], "Allowance exceeded");

        uint256 senderBalance = balances[sender]; // Reuse storage variable
        balances[sender] = senderBalance.sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        allowances[sender][msg.sender] = allowances[sender][msg.sender].sub(
            amount
        );

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function batchTransfer(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external nonReentrant returns (bool) {
        require(recipients.length == amounts.length, "Invalid input length");

        uint256 senderBalance = balances[msg.sender]; // Reuse storage variable
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 amount = amounts[i];

            require(
                recipient != address(0),
                "Transfer to the zero address is not allowed"
            );
            require(
                amount <= senderBalance,
                "Insufficient balance for transfer"
            );

            senderBalance = senderBalance.sub(amount);
            balances[recipient] = balances[recipient].add(amount);

            emit Transfer(msg.sender, recipient, amount);
        }

        balances[msg.sender] = senderBalance; // Update sender balance once after batch transfer
        return true;
    }
}