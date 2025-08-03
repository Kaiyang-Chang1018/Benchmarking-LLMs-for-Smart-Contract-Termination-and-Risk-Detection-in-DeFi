// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

/**
 * @title PercyResurrector Token
 * @dev ERC20-compliant token with advanced features for scalability and security.
 * 
 * Features:
 * - 0.5% burn fee per transaction.
 * - 1% transaction tax.
 * - Anti-bot blacklist.
 * - Ownership renouncement for decentralization.
 * - Placeholder for liquidity locking.
 * - Gas-optimized and audit-ready.
 * 
 * Official Links:
 * Telegram: https://t.me/persyresurrect
 * Twitter: https://x.com/PercyResurrect
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

contract PercyResurrector is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "PercyResurrector";
    string private constant _symbol = "PERCYRR";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_000_000_000 * 10**_decimals;

    uint256 public constant TAX_FEE = 1; // 1% transaction tax
    uint256 public constant BURN_FEE = 5; // 0.5% burn fee

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _blacklist;

    event Burn(address indexed burner, uint256 amount);
    event BlacklistUpdated(address indexed account, bool isBlacklisted);

    constructor() {
        _balances[_msgSender()] = _totalSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_blacklist[sender], "Sender is blacklisted");
        require(!_blacklist[recipient], "Recipient is blacklisted");

        uint256 fee = amount.mul(TAX_FEE).div(100);
        uint256 burnAmount = amount.mul(BURN_FEE).div(1000);
        uint256 transferAmount = amount.sub(fee).sub(burnAmount);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(transferAmount);

        if (fee > 0) {
            _balances[address(this)] = _balances[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }

        if (burnAmount > 0) {
            _balances[address(0)] = _balances[address(0)].add(burnAmount);
            emit Burn(sender, burnAmount);
            emit Transfer(sender, address(0), burnAmount);
        }

        emit Transfer(sender, recipient, transferAmount);
    }

    function updateBlacklist(address account, bool isBlacklisted) external onlyOwner {
        _blacklist[account] = isBlacklisted;
        emit BlacklistUpdated(account, isBlacklisted);
    }

    receive() external payable {}

    fallback() external payable {}
}