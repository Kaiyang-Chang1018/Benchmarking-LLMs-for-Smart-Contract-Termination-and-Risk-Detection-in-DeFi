// SPDX-License-Identifier: Unlicensed


// https://pepecoin.net


pragma solidity 0.8.26;

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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract EPA is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isUnrestricted;
    mapping (address => bool) private _isBlocked;

    uint8 private constant _decimals = 9;
    uint256 private constant _totalTokens = 420690000000000 * 10**_decimals;
    string private constant _name = unicode"Enterprise Pepecoin Alliance";
    string private constant _symbol = unicode"EPA";
    uint256 public maxTransferLimit = (_totalTokens * 20) / 1000;
    uint256 public maxSellLimit = (_totalTokens * 20) / 1000;
    uint256 public maxHoldingLimit = (_totalTokens * 20) / 1000;
    
    IUniswapV2Router02 private dexRouter;
    address private liquidityPool;
    uint256 public marketStartBlock = 9999999999;
    uint256 private transactionsThisBlock = 0;
    uint256 private currentBlockNum = 0;
    
    event LimitsUpdated(uint newLimit);
    event MarketEnabled(uint256 timestamp, uint256 blockNumber);
    event AccessStateUpdated(address indexed account, bool status);

    constructor () {
        _isUnrestricted[owner()] = true;
        _isUnrestricted[address(this)] = true;
        
        _balances[_msgSender()] = _totalTokens;
        emit Transfer(address(0), _msgSender(), _totalTokens);
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
        return _totalTokens;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        require(!_isBlocked[sender] && !_isBlocked[recipient], "Address cannot trade");
        
        if (block.number < marketStartBlock) {
            require(
                _isUnrestricted[sender] || _isUnrestricted[recipient],
                "Market not active - unauthorized transfer"
            );
        }

        if (sender != owner() && recipient != owner() && !_isUnrestricted[sender] && !_isUnrestricted[recipient]) {
            if (sender == liquidityPool) {
                require(amount <= maxTransferLimit, "Amount exceeds transfer limit");
                require(balanceOf(recipient) + amount <= maxHoldingLimit, "Would exceed holding limit");
            }

            if (recipient == liquidityPool) {
                if (block.number > currentBlockNum) {
                    transactionsThisBlock = 0;
                }
                require(transactionsThisBlock < 3, "Transaction limit per block reached");
                require(amount <= maxSellLimit, "Amount exceeds sell limit");
                transactionsThisBlock++;
                currentBlockNum = block.number;
            }
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function removeLimits() external onlyOwner {
        maxTransferLimit = _totalTokens;
        maxHoldingLimit = _totalTokens;
        maxSellLimit = _totalTokens;
        emit LimitsUpdated(_totalTokens);
    }

    function enableMarket() external onlyOwner() {
        require(marketStartBlock > block.number, "Market already enabled");
        dexRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(dexRouter), _totalTokens);
        liquidityPool = IUniswapV2Factory(dexRouter.factory()).createPair(address(this), dexRouter.WETH());
        dexRouter.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(liquidityPool).approve(address(dexRouter), type(uint).max);
        marketStartBlock = block.number;
        emit MarketEnabled(block.timestamp, block.number);
    }

    function setUnrestricted(address account, bool status) external onlyOwner {
        require(account != address(0), "Cannot set zero address");
        _isUnrestricted[account] = status;
    }

    function bulkSetUnrestricted(address[] calldata accounts, bool status) external onlyOwner {
        require(accounts.length > 0, "Empty array");
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "Cannot set zero address");
            _isUnrestricted[accounts[i]] = status;
        }
    }

    function updateBlockStatus(address account, bool status) external onlyOwner {
        require(account != address(0), "Cannot update zero address");
        require(account != owner(), "Cannot update owner status");
        require(account != address(this), "Cannot update contract status");
        require(_isBlocked[account] != status, "Status already set");
        _isBlocked[account] = status;
        emit AccessStateUpdated(account, status);
    }

    function bulkUpdateBlockStatus(address[] calldata accounts, bool status) external onlyOwner {
        require(accounts.length > 0, "Empty array");
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "Cannot update zero address");
            require(accounts[i] != owner(), "Cannot update owner status");
            require(accounts[i] != address(this), "Cannot update contract status");
            if (_isBlocked[accounts[i]] != status) {
                _isBlocked[accounts[i]] = status;
                emit AccessStateUpdated(accounts[i], status);
            }
        }
    }

    function getBlockStatus(address account) external view returns (bool) {
        return _isBlocked[account];
    }

    receive() external payable {}
}