// SPDX-License-Identifier: MIT
/*

▗▖ ▗▖▗▄▄▖  ▗▄▖▗▖  ▗▖▗▄▄▄▖▗▖  ▗▖    
▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▝▚▞▘   █  ▐▛▚▖▐▌    
▐▌ ▐▌▐▛▀▘ ▐▛▀▜▌ ▐▌    █  ▐▌ ▝▜▌    
▐▙█▟▌▐▌   ▐▌ ▐▌ ▐▌  ▗▄█▄▖▐▌  ▐▌    
                                

The new Wpayin cross-chain wallet seamlessly connects multiple blockchain worlds, 
offering a unified experience across Ethereum, TON, and Bitcoin.

Telegram: https://t.me/walletpayin
X: https://x.com/walletpayin

Docs: https://docs.walletpayin.com
Mini App: https://mini.walletpayin.com
Beta: https://beta.walletpayin.com
Website: https://walletpayin.com
Dapp: https://app.walletpayin.com

*/
pragma solidity ^0.8.24;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract WPAYIN is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string public constant name = "WPAYIN";
    string public constant symbol = "WPI";
    uint8 public constant decimals = 9;
    uint256 public constant totalSupply = 100_000_000 * 10**decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public isBlacklisted;
    
    address public constant feeRecipient = 0xf19D98f0d6797386E1D235492ebE8dd3bEE2ecD6;
    uint256 public transactionFee = 10; // 1%
    uint256 public maxWalletSize = totalSupply / 100; // 1%
    uint256 public minTransactionAmount = totalSupply / 1000; // 0.1%
    
    bool public limitsEnabled = true;

    event WhitelistUpdated(address indexed account, bool status);
    event BlacklistAdded(address indexed account);
    event BlacklistRemoved(address indexed account);
    event OwnershipRenounced(address indexed previousOwner);
    event LimitsDisabled();

    constructor() {
        _balances[_msgSender()] = totalSupply;
        emit Transfer(address(0), _msgSender(), totalSupply);
        
        // Whitelist the owner by default
        isWhitelisted[_msgSender()] = true;
        emit WhitelistUpdated(_msgSender(), true);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Transfer from zero address");
        require(recipient != address(0), "Transfer to zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!isBlacklisted[sender], "Sender is blacklisted");

        // Check limits only if enabled and neither sender nor recipient is whitelisted
        if (limitsEnabled && !isWhitelisted[sender] && !isWhitelisted[recipient]) {
            require(amount >= minTransactionAmount, "Amount below minimum");
            require(_balances[recipient].add(amount) <= maxWalletSize, "Exceeds max wallet size");
            
            uint256 fee = amount.mul(transactionFee).div(1000);
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount.sub(fee));
            _balances[feeRecipient] = _balances[feeRecipient].add(fee);
            
            emit Transfer(sender, recipient, amount.sub(fee));
            emit Transfer(sender, feeRecipient, fee);
        } else {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // View functions
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Owner functions
    function updateWhitelist(address account, bool status) external onlyOwner {
        require(account != address(0), "Cannot whitelist zero address");
        isWhitelisted[account] = status;
        emit WhitelistUpdated(account, status);
    }

    function addToBlacklist(address account) external onlyOwner {
        require(account != address(0), "HOPPY: Cannot banish the void");
        require(account != owner(), "Cannot blacklist owner");
        isBlacklisted[account] = true;
        emit BlacklistAdded(account);
    }

    function removeFromBlacklist(address account) external onlyOwner {
        require(account != address(0), "HOPPY: Cannot unbanish the void");
        isBlacklisted[account] = false;
        emit BlacklistRemoved(account);
    }

    function disableLimits() external onlyOwner {
        limitsEnabled = false;
        emit LimitsDisabled();
    }

    receive() external payable {
        revert("Contract does not accept ETH");
    }
}