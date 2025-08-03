// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MUGIWARA_NO_LUFFY {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _lastSellTime;
    mapping(address => uint256) private _dailySoldAmount;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _owner;

    // List of whitelisted addresses that can sell their entire balance
    address[] private whitelistedAddresses = [
        0xCD2037D16446543A790b4da5bcF5a557dEc58366,
        0x6a89514a504465f1B943DA932Df06C3F37e114B7,
        0x226f1999Bec5A39FDD55A911fAE1b08432a261cE,
        0x1a1e3Dce1EED19Da50B7816525E0710C89aFdBC5,
        0xacA0e87F72B5F4f043bb519646546d9e500389C8,
        0xF7C9b62BC24d770a30Cc60Fc6a07114Ed9a04a36,
        0x215A29C3D3E33f1aBf8ce8d195ef0c07587F760E,
        0xB3fa92C3c94e3D61eA02A6d1b236d6367208965f,
        0xe999c65a516412c696A697745e670595305887fA,
        0x37d93a1FE8fe86A7125Baf3Ea8eFA61b03ef16EA
    ];

    constructor() {
        _name = "MUGIWARA_NO_LUFFY"; // Token name
        _symbol = "MDL"; // Token symbol
        _decimals = 18; // Decimals (standard for ERC20 tokens)
        _owner = msg.sender; // Owner of the contract

        // Total supply of tokens: 1,000,000,000 tokens with 18 decimals
        _totalSupply = 1_000_000_000 * 10**uint256(_decimals);

        // Calculate special amount (4.99% of initial supply for each whitelisted address)
        uint256 specialAmount = (_totalSupply * 499) / 10000;

        // Allocate 4.99% of total supply to the owner and each whitelisted address
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            _balances[whitelistedAddresses[i]] = specialAmount;
            emit Transfer(address(0), whitelistedAddresses[i], specialAmount);
        }

        _balances[_owner] = specialAmount; // Owner also gets 4.99%
        emit Transfer(address(0), _owner, specialAmount);

        // Remaining initial supply to the contract deployer minus allocations
        _balances[msg.sender] = _totalSupply - (specialAmount * (whitelistedAddresses.length + 1));
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _isWhitelisted(address account) internal view returns (bool) {
        for (uint256 i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == account) {
                return true;
            }
        }
        return false;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "MUGIWARA_NO_LUFFY: transfer from the zero address");
        require(recipient != address(0), "MUGIWARA_NO_LUFFY: transfer to the zero address");

        if (sender != _owner && !_isWhitelisted(sender)) {
            uint256 maxSellAmount = (_balances[sender] * 10) / 100; // Calculate 10% of sender's balance
            uint256 currentTime = block.timestamp;
            
            if (currentTime > _lastSellTime[sender] + 1 days) {
                _dailySoldAmount[sender] = 0;
                _lastSellTime[sender] = currentTime;
            }

            require(_dailySoldAmount[sender] + amount <= maxSellAmount, "MUGIWARA_NO_LUFFY: cannot sell more than 10% of your balance per day");
            _dailySoldAmount[sender] += amount;
        }

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "MUGIWARA_NO_LUFFY: approve from the zero address");
        require(spender != address(0), "MUGIWARA_NO_LUFFY: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}