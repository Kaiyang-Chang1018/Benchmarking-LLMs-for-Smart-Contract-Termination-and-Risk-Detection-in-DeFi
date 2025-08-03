// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

pragma abicoder v2;


interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is IERC20 {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


contract KFC4 is ERC20, Ownable {

    uint256 public feeRate;
    bool public transferable;
    mapping(address => bool) public blacklist;
    mapping(address => bool) public dutyFree;
    mapping(address => bool) public pairs;
    mapping(address => bool) public specials;

    event DutyFreeSet(address indexed owner, address indexed account, bool indexed value);
    event PairSet(address indexed owner, address indexed account, bool indexed value);
    event FeeRateSet(address indexed owner, uint256 indexed oldRate, uint256 indexed newRate);
    event BlacklistSet(address indexed owner, address[] accounts);
    event BlacklistRemoved(address indexed owner, address[] accounts);

    constructor() ERC20("KFCCrazythursdayVme50", "KFC4") {
        specials[owner()] = true;

        dutyFree[owner()] = true;
        dutyFree[address(this)] = true;
        dutyFree[address(0xdead)] = true;
        dutyFree[address(0)] = true;

        feeRate = 0.02 ether;

        super._mint(msg.sender, 4000000000000 * 1e18);
    }

    receive() external payable {}

    function _transfer(address from, address to, uint256 amount) internal override {
        require(!blacklist[from], "the sender is on the blacklist");
        require(!blacklist[to], "the receiver is on the blacklist");

        if (!transferable) {
            require(specials[from], "Only special addresses can transfer");
        }

        if (amount > 0 && feeRate > 0) {
            if ((pairs[to] || pairs[from]) && !dutyFree[from] && !dutyFree[to]) {
                uint256 fees = amount * feeRate / 1 ether;
                super._transfer(from, address(this), fees);
                amount -= fees;
            }
        }

        super._transfer(from, to, amount);
    }

    function setTransferable() external onlyOwner {
        transferable = !transferable;
    }

    function setSpecial(address account, bool value) public onlyOwner {
        specials[account] = value;
        dutyFree[account] = value;
    }

    function setFeeRate(uint256 newRate) external onlyOwner {
        emit FeeRateSet(msg.sender, feeRate, newRate);
        feeRate = newRate;
    }

    function setDutyFree(address account) public onlyOwner {
        dutyFree[account] = !dutyFree[account];
        emit DutyFreeSet(msg.sender, account, dutyFree[account]);
    }

    function setPair(address account) external onlyOwner {
        pairs[account] = !pairs[account];
        emit PairSet(msg.sender, account, pairs[account]);
    }

    function setBlacklist(address[] calldata accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blacklist[accounts[i]] = true;
        }
        emit BlacklistSet(msg.sender, accounts);
    }

    function removeBlacklist(address[] calldata accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blacklist[accounts[i]] = false;
        }
        emit BlacklistRemoved(msg.sender, accounts);
    }

    function withdrawToken(address token, address to) external onlyOwner {
        require(token != address(0), "token address cannot be zero address");
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, balance);
    }

    function withdrawEth(address to) external onlyOwner {
        (bool success, ) = to.call{value: address(this).balance}(new bytes(0));
        require(success, "eth transfer failed");
    }
}