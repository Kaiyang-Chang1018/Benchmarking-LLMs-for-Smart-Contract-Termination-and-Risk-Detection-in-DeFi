// AI is dev 
// Dev not exist , 100% Ai token launched on v3.
// fully automated deployed by Ai sys.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Suppress state mutability warnings
// pragma solidity ^0.8.0 pragma solidity ^0.8.0;




// ERC-20 interface
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

// ERC-20 implementation
contract ERC20 is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
        _balances[msg.sender] = totalSupply_; // Assign all tokens to contract deployer
        emit Transfer(address(0), msg.sender, totalSupply_);
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

// Ownable contract
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }
}

// Uniswap V3 Factory Interface
interface IUniswapV3Factory {
    function createPool(address tokenA, address tokenB, uint24 fee) external returns (address pool);
}

// Uniswap V3 Pool Interface
interface IUniswapV3Pool {
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);
}

// Uniswap V3 Swap Router Interface
interface ISwapRouter {
    function exactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        address recipient,
        uint256 deadline,
        uint256 amountIn,
        uint256 amountOutMinimum,
        uint160 sqrtPriceLimitX96
    ) external payable returns (uint256 amountOut);
}

// Main Contract: Custom Token with Uniswap V3 Liquidity Management
contract AiCustomDev is ERC20, Ownable {
    IUniswapV3Factory public immutable uniswapFactory;
    ISwapRouter public immutable swapRouter;

    uint256 public maxTransactionAmounts;
    uint256 public maxWalletBalance;

    mapping(address => uint256) private walletBalances;

    event PoolCreated(address pool, address token0, address token1, uint24 fee);
    event LiquidityAdded(address liquidityProvider, uint256 tokenAmount, uint256 tokenBAmount);

    constructor(
        address _uniswapFactory,
        address _swapRouter,
        uint256 _maxTransactionAmount,
        uint256 _maxWalletBalance
    ) ERC20("Bullish", "Bullish", 18, 1_000_000_000 * 10**18) {  // Mint 1 billion tokens to deployer
        uniswapFactory = IUniswapV3Factory(_uniswapFactory);
        swapRouter = ISwapRouter(_swapRouter);
        maxTransactionAmounts = _maxTransactionAmount;
        maxWalletBalance = _maxWalletBalance;
    }

    // Create Uniswap V3 Pool
    function createPool(address tokenB, uint24 fee) external onlyOwner returns (address pool) {
        require(tokenB != address(this), "Tokens must be different");
        pool = uniswapFactory.createPool(address(this), tokenB, fee);
        emit PoolCreated(pool, address(this), tokenB, fee);
    }

    // Add Liquidity to Uniswap V3 Pool
    function addLiquidity(
        address pool,
        address tokenB,
        uint256 amountTokenA,
        uint256 amountTokenB
    ) external {
        require(amountTokenA <= maxTransactionAmounts, "Exceeds max transaction limit");
        require(walletBalances[msg.sender] + amountTokenA <= maxWalletBalance, "Exceeds max wallet balance");

        // Transfer tokens to contract
        _transfer(msg.sender, address(this), amountTokenA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountTokenB);

        // Track the wallet balance
        walletBalances[msg.sender] += amountTokenA;

        // Approve Uniswap Pool to spend tokens
        _approve(address(this), pool, amountTokenA);
        IERC20(tokenB).approve(pool, amountTokenB);

        // Add liquidity to Uniswap V3 pool (using wide ticks)
        IUniswapV3Pool(pool).mint(
            msg.sender, 
            -887272, 
            887272, 
            uint128(amountTokenA), 
            abi.encode(amountTokenB)
        );

        emit LiquidityAdded(msg.sender, amountTokenA, amountTokenB);
    }

    // Set Maximum Transaction Limit
    function setMaxTransactionAmount(uint256 _maxTransactionAmount) external onlyOwner {
        maxTransactionAmounts = _maxTransactionAmount;
    }

    // Set Maximum Wallet Balance
    function setMaxWalletBalance(uint256 _maxWalletBalance) external onlyOwner {
        maxWalletBalance = _maxWalletBalance;
    }

    // Add Wallet Balance Check to Transfers
    function _beforeTokenTransfer(address, address to, uint256 amount) internal {
        if (to != address(0)) {  // If not burning tokens
            require(balanceOf(to) + amount <= maxWalletBalance, "Recipient balance exceeds max wallet limit");
        }
    }
}