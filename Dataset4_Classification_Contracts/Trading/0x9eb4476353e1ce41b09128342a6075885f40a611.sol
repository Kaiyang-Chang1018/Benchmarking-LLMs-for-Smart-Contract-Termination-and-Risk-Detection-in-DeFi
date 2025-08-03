pragma solidity 0.8.26;

// SPDX-License-Identifier: MIT

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract TokenBridge is Ownable {
    IERC20 public token1; // V1 token
    IERC20 public token2; // V2 token

    IDexRouter public immutable dexRouter;

    mapping (address => uint256) public snapshot;
    mapping (address => uint256) public tokensBridged;
    
    bool public isInitialized = false;
    bool public finalized = false;

    address public liquidityWalletForV2;
    
    
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    
    uint256 private _status;
        
    // pay close attention here and make sure all values are CORRECT
    
    constructor(address _originalToken, address _newToken) {
        _status = _NOT_ENTERED;
        
        // Token V1
        token1 = IERC20(_originalToken);
        
        
        // Token V2
        token2 = IERC20(_newToken);
        
        // change to token owner or liquidity holder (usually the project owner, not the developer) before launch
        liquidityWalletForV2 = address(0x9e7131bc44B773b6eBa76fef158147bD43D7561c);  // UPDATE
    

        address _v2Router;

        // @dev assumes WETH pair
        if(block.chainid == 1){
            _v2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        } else if(block.chainid == 5){
            _v2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        } else if(block.chainid == 97){
            _v2Router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        } else if(block.chainid == 42161){
            _v2Router = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
        } else if(block.chainid == 8453){
            _v2Router = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
        } else if(block.chainid == 11155111){
            _v2Router = 0xa3D89E5B9C7a863BF4535F349Bc5619ABe72fb09;
        } else {
            revert("Chain not configured");
        }

        dexRouter = IDexRouter(_v2Router);

        token1.approve(address(dexRouter), type(uint256).max);
    }
    
    receive() external payable {
    }
    
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    
    function tradeInTokens(uint256 amountOutMin) external nonReentrant {
        uint256 amountToSend;
        require(isInitialized, "Trading bridge is not active");
        require(!finalized, "Bridging tokens is not allowed after bridge is complete");
        uint256 snapshotAmount = snapshot[msg.sender];
        require(snapshotAmount > 0, "Not in snapshot.");
        
        uint256 tokensToBridge = eligibleTokensToBridge(msg.sender);
        
        if(tokensToBridge == 0){
            revert("No tokens to bridge");
        }

        require(token1.allowance(msg.sender, address(this)) >= tokensToBridge, "Approval must be done before transfer");
        token1.transferFrom(msg.sender, address(this), tokensToBridge); // tokens are sent directly to this contract for sale
        
        tokensBridged[msg.sender] += tokensToBridge;
        
        amountToSend = tokensToBridge; // leave alone if supply is identical
        
        require(token2.balanceOf(address(this)) >= amountToSend, "Not enough V2 tokens to send");
        token2.transfer(msg.sender, amountToSend);

        swapTokensForETH(tokensToBridge, amountOutMin);
    }

    function eligibleTokensToBridge(address user) public view returns (uint256){
        uint256 tokensToBridge = token1.balanceOf(msg.sender);
        uint256 snapshotAmount = snapshot[user];
        uint256 tokensBridgedAmount = tokensBridged[user];
        
        if(tokensBridgedAmount >= snapshotAmount){
            return 0;
        }

        if(tokensToBridge >= snapshotAmount - tokensBridged[user]){
            tokensToBridge = snapshotAmount - tokensBridged[user];
        }

        return tokensToBridge;
    }

    function swapTokensForETH(uint256 tokenAmt, uint256 amountOutMin) private {

        address[] memory path = new address[](2);
        path[0] = address(token1);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmt,
            amountOutMin,
            path,
            address(liquidityWalletForV2),
            block.timestamp
        );
    }

    function getAmountOut(uint256 tokenIn) external view returns (uint256){
        address[] memory path = new address[](2);
        path[0] = address(token1);
        path[1] = dexRouter.WETH();

        uint256[] memory amountOut = dexRouter.getAmountsOut(tokenIn, path);
        return amountOut[1] * 9 / 10;
    }

    
    function initialize(bool _initialize) external onlyOwner {
        isInitialized = _initialize;
    }

    function addSnapshot(address[] calldata wallets, uint256[] calldata amounts) external onlyOwner {
        for(uint256 i = 0; i < wallets.length; i++){
            snapshot[wallets[i]] = amounts[i];
        }
    }
    
    function emergencyToken2Withdraw() external onlyOwner {
        token2.transfer(address(msg.sender),token2.balanceOf(address(this)));
    }
    
    // use in case the sell won't work.
    function emergencyToken1Withdraw() external onlyOwner {
        token1.transfer(address(msg.sender),token1.balanceOf(address(this)));
    }

    function emergencyUpdateToken1(address token) external onlyOwner {
        token1 = IERC20(token);
    }

    function emergencyToken2Withdraw(address token) external onlyOwner {
        token2 = IERC20(token);
    }

    function updateLiquidityWallet(address liquidityWallet) external onlyOwner {
        require(liquidityWallet != address(0), "Zero Address");
        liquidityWalletForV2 = liquidityWallet;
    }
}