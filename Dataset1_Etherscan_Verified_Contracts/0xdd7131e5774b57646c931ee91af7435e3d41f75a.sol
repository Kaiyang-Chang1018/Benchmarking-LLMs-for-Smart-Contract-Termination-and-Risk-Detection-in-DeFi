// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/Platty/presale.sol


pragma solidity ^0.8.26;



interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PlattyPreSale is Ownable(msg.sender) {
    IERC20 public Platty;
    address public constant burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public tokenRatePerEth = 9500000000; // xxx * (10 ** decimals) Platty per eth
    uint256 public minETHLimit = 0.001 ether;
    uint256 public maxETHLimit = 3 ether;

    uint256 public hardCap = 35 ether;
    uint256 public totalRaisedETH;
    uint256 public totalTokenSold;

    uint256 public startTime;
    uint256 public endTime;
    bool public contractPaused;
    bool public liquidityAdded;

    mapping(address => uint256) public userInvestments;

    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 private uniswapRouter;

    event TokensPurchased(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);
    event LiquidityAdded(uint256 ethAmount, uint256 tokenAmount);
    event TokensBurned(uint256 amount);
    event PresaleTokenUpdated(address indexed newToken);
    event MinEthLimitUpdated(uint256 newMinLimit);
    event MaxEthLimitUpdated(uint256 newMaxLimit);
    event PresaleStartTimeUpdated(uint256 newStartTime);
    event PresaleEndTimeUpdated(uint256 newEndTime);
    event ContractPaused(bool isPaused);
    event UnnecessaryTokensRecovered(address indexed token, address indexed to, uint256 amount);

    constructor(address tokenAddress, uint256 _startTime, uint256 _endTime) {
        require(_startTime > block.timestamp, "Start time must be in the future");
        require(_endTime > _startTime, "End time must be after start time");
        require(tokenAddress != address(0), "Invalid token address");

        Platty = IERC20(tokenAddress);
        startTime = _startTime;
        endTime = _endTime;
        uniswapRouter = IUniswapV2Router02(UNISWAP_V2_ROUTER);
    }

    modifier checkIfPaused() {
        require(!contractPaused, "Contract is paused");
        _;
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable checkIfPaused {
        require(block.timestamp >= startTime, "Sale has not started");
        require(block.timestamp <= endTime, "Sale has ended");
        require(totalRaisedETH + msg.value <= hardCap, "HardCap exceeded");
        require(
            userInvestments[msg.sender] + msg.value >= minETHLimit &&
            userInvestments[msg.sender] + msg.value <= maxETHLimit,
            "Invalid ETH amount"
        );

        uint256 tokenAmount = getTokensPerEth(msg.value);
        require(
            Platty.transfer(msg.sender, tokenAmount),
            "Insufficient tokens in contract"
        );

        userInvestments[msg.sender] += msg.value;
        totalRaisedETH += msg.value;
        totalTokenSold += tokenAmount;

        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    function addPlattyLiquidity() external onlyOwner {
        require(block.timestamp > endTime, "Sale is still active");
        require(!liquidityAdded, "Liquidity already added");

        uint256 ethAmount = address(this).balance;
        uint256 tokenAmount = ethAmount * tokenRatePerEth * 95 / 100;

        IERC20(Platty).approve(address(uniswapRouter), tokenAmount);

        uniswapRouter.addLiquidityETH{ value: ethAmount }(
            address(Platty),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );

        liquidityAdded = true;

        uint256 remainingTokens = Platty.balanceOf(address(this));
        Platty.transfer(burnAddress, remainingTokens);

        emit LiquidityAdded(ethAmount, tokenAmount);
        emit TokensBurned(remainingTokens);
    }

    function togglePause() external onlyOwner {
        contractPaused = !contractPaused;
        emit ContractPaused(contractPaused);
    }

    function setPresaleToken(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "Invalid token address");
        Platty = IERC20(tokenAddress);
        emit PresaleTokenUpdated(tokenAddress);
    }

    function setMinEthLimit(uint256 amount) external onlyOwner {
        minETHLimit = amount;
        emit MinEthLimitUpdated(amount);
    }

    function setMaxEthLimit(uint256 amount) external onlyOwner {
        maxETHLimit = amount;
        emit MaxEthLimitUpdated(amount);
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        require(_startTime > block.timestamp, "Start time must be in the future");
        startTime = _startTime;
        emit PresaleStartTimeUpdated(_startTime);
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        require(_endTime > startTime, "End time must be after start time");
        endTime = _endTime;
        emit PresaleEndTimeUpdated(_endTime);
    }

    function getUnnecessaryTokens(address token, address to) external onlyOwner {
        require(token != address(Platty), "Cannot withdraw Platty tokens");
        require(to != address(0), "Invalid address");

        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, balance);

        emit UnnecessaryTokensRecovered(token, to, balance);
    }

    function getUserRemainingAllocation(address account) external view returns (uint256) {
        return maxETHLimit - userInvestments[account];
    }

    function getTokensPerEth(uint256 amount) internal view returns (uint256) {
        return amount * tokenRatePerEth / (10 ** (18 - Platty.decimals()));
    }
}