// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

// Website: https://humanornot.one/ 
// Community: https://t.me/humanornottgbot 
// Documentation: https://whitepaper.humanornot.one/ 
// Twitter: https://x.com/humanornotx

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract HUMANorNOT is IERC20, Ownable {
    string private _name = "HUMANorNOT";
    string private _symbol = "BOT";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000000 * (10 ** decimals());

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public buyFeePercent = 3;  // 3% buy fee
    uint256 public sellFeePercent = 3; // 3% sell fee
    address public feeWallet;

    mapping(address => bool) public isExcludedFromFee;

    constructor(address _feeWallet) {
        require(_feeWallet != address(0), "Fee wallet address cannot be zero");
        feeWallet = _feeWallet;
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);

        // Exclude owner and contract from fee
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address sender = msg.sender;
        _transfer(sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function setBuyFeePercent(uint256 feePercent) external onlyOwner {
        require(feePercent <= 10, "Fee too high");
        buyFeePercent = feePercent;
    }

    function setSellFeePercent(uint256 feePercent) external onlyOwner {
        require(feePercent <= 10, "Fee too high");
        sellFeePercent = feePercent;
    }

    function setFeeWallet(address _feeWallet) external onlyOwner {
        require(_feeWallet != address(0), "Fee wallet address cannot be zero");
        feeWallet = _feeWallet;
    }

    function excludeFromFee(address account, bool excluded) external onlyOwner {
        isExcludedFromFee[account] = excluded;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 feePercent = (to == address(this)) ? sellFeePercent : (from == address(this)) ? buyFeePercent : 0;

        if (feePercent > 0 && !isExcludedFromFee[from] && !isExcludedFromFee[to]) {
            uint256 feeAmount = (amount * feePercent) / 100;
            uint256 transferAmount = amount - feeAmount;
            _balances[from] -= amount;
            _balances[to] += transferAmount;
            _balances[feeWallet] += feeAmount;
            emit Transfer(from, to, transferAmount);
            emit Transfer(from, feeWallet, feeAmount);
        } else {
            _balances[from] -= amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}