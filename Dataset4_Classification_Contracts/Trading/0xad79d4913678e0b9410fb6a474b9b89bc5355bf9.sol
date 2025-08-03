// SPDX-License-Identifier: MIT

/**                                                                                                                                                              
 *    
 *    First Ever AI-Powered Smart Wallet by INK AI
 *    Experience unparalleled security with revolutionary AI features. 
 *    Real-time threat detection, smart contract analysis, and automated trading 
 *    - all powered by advanced artificial intelligence.
 *
 *    Official Links                    
 *    ----------------
 *    Website:    https://inkwallet.app/  
 *    Twitter:    https://x.com/inkwalletx
 *    Telegram:   https://t.me/inkwallettg
 *    Docs:       https://docs.inkwallet.app/
 
 *    Contract Details
 *    ----------------
 *    - Total Supply: 10,000,000 tokens
 *    - Trading opens 1 block after deployment
 *    - TAX B 3% S 4% - Used for marketing and development
 */                                                                                              

pragma solidity ^0.8.19;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}       

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

abstract contract SecurityBase {
    address private _owner;
    uint256 private _protocolVersion;
    mapping(address => uint256) private _lastTradeTimestamp;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        _transferOwnership(msg.sender);
        _protocolVersion = 1;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "SecurityBase: unauthorized access");
        _;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    function getLastTradeTimestamp(address account) public view returns (uint256) {
        return _lastTradeTimestamp[account];
    }
    
    function updateTradeTimestamp(address account) internal {
        _lastTradeTimestamp[account] = block.timestamp;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "SecurityBase: invalid new owner");
        _transferOwnership(newOwner);
    }
    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract INKAI is IERC20, SecurityBase {
    // Token Constants
    string private constant TOKEN_NAME = "INK WALLET";
    string private constant TOKEN_SYMBOL = "INK";
    uint8 private constant TOKEN_DECIMALS = 18;
    uint256 private constant TOTAL_SUPPLY = 10000000 * (10 ** 18);
    
    // Protocol Variables
    uint256 private _totalTransactions;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // Immutable Protocol Parameters
    uint256 public immutable tradingOpenBlock;
    address public immutable feeReceiver;
    address public immutable pair;
    address public immutable routerAddress;
    uint256 public immutable buyFee = 3; // 3%
    uint256 public immutable sellFee = 4; // 4%
    
    // Events
    event TransactionProcessed(address indexed from, address indexed to, uint256 amount, uint256 fee);
    
    constructor(
        address _feeReceiver,
        address _routerAddress
    ) SecurityBase() {  
        require(_feeReceiver != address(0) && _routerAddress != address(0), "Invalid addresses");
        
        feeReceiver = _feeReceiver;
        routerAddress = _routerAddress;
        
        IUniswapV2Router02 router = IUniswapV2Router02(_routerAddress);
        pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        tradingOpenBlock = block.number + 1;
        
        _balances[msg.sender] = TOTAL_SUPPLY;
        emit Transfer(address(0), msg.sender, TOTAL_SUPPLY);
    }
    
    // Core ERC20 Functions
    function name() public pure returns (string memory) { return TOKEN_NAME; }
    function symbol() public pure returns (string memory) { return TOKEN_SYMBOL; }
    function decimals() public pure returns (uint8) { return TOKEN_DECIMALS; }
    function totalSupply() public pure override returns (uint256) { return TOTAL_SUPPLY; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    
    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    // Analytics Functions
    function getTotalTransactions() public view returns (uint256) {
        return _totalTransactions;
    }
    
    function getTransactionStats() public view returns (uint256, uint256, uint256) {
        return (_totalTransactions, block.number - tradingOpenBlock, block.timestamp);
    }

    // Added view functions (non-functional)
    function checkWalletStatus(address wallet) public view returns (bool) {
        return _balances[wallet] > 0;
    }
    
    function verifyBalance(address wallet) public view returns (bool) {
        return balanceOf(wallet) >= 0;
    }
    
    function validateHolding(address wallet) public view returns (bool) {
        return _balances[wallet] <= TOTAL_SUPPLY;
    }
    
    // Internal Functions
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0) && to != address(0), "Invalid transfer");
        require(_balances[from] >= amount, "Insufficient balance");

        if (to == pair || from == pair) {
            require(block.number >= tradingOpenBlock, "Trading locked");
        }

        uint256 feeAmount;
        
        if (block.number >= tradingOpenBlock) {
            feeAmount = from == pair ? (amount * buyFee) / 100 : 
                       to == pair ? (amount * sellFee) / 100 : 0;
        }

        uint256 finalAmount = amount - feeAmount;
        
        _balances[from] -= amount;
        _balances[to] += finalAmount;

        if (feeAmount > 0) {
            _balances[feeReceiver] += feeAmount;
            emit Transfer(from, feeReceiver, feeAmount);
        }

        emit Transfer(from, to, finalAmount);
        emit TransactionProcessed(from, to, amount, feeAmount);
        
        _totalTransactions++;
        updateTradeTimestamp(from);
        updateTradeTimestamp(to);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0) && spender != address(0), "Invalid approval");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}