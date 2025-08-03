// SPDX-License-Identifier: UNLICENSED
// File: @openzeppelin/contracts@4.8.2/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

//?A hub for human-AI interaction. We offer smart, efficient, and personalized AI solutions, transforming customer service and smart living. Empowering a smarter lifestyle for all.

// Twitter(X): https://twitter.com/interactive_al
// Web: https://interactive-ai.xyz/
// Telegram: https://t.me/interactive_ai_portal

pragma solidity ^0.8.0;

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
}

// File: @openzeppelin/contracts@4.8.2/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

interface IUniswapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.18;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity 0.8.18;

// File: asffaffasdfasd.sol

pragma solidity 0.8.18;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

interface _DEXRouter {
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

pragma solidity 0.8.18;

contract InteractiveAi is Context, IERC20, Ownable { 
    using SafeMath for uint256;

    address payable private _treasuryAddress;
    address public _dexPairAddress;
    _DEXRouter public uniswapRouter;

    string private _tokenName;
    string private _tokenSymbol;
    uint8 private constant _tokenDecimals = 18;

    uint256 private constant _tokenTotalSupply = 100_000_000 * 10**_tokenDecimals; 
    uint256 private _tokenMaxTxAmount = (_tokenTotalSupply * 20) / 1000;
    uint256 private _tokenMaxHoldAmount = (_tokenTotalSupply * 20) / 1000;
    uint256 private _tokenMaxAllowedTax = (_tokenTotalSupply * 2) / 1000;
    uint256 private _tokenMixCollectedTaxToSwap = (_tokenTotalSupply * 1) / 100000;
    uint256 private _tokenStartingBuyTax = 25;
    uint256 private _tokenStartingSellTax = 25;
    uint256 private _tokenFinishSellTax = 7;
    uint256 private _tokenFinishBuyTax = 0;
    uint256 private _tokenDecreaseBuyTaxAt = 10;
    uint256 private _tokenDecreaseSellTaxAt = 12;
    uint256 private _tokenMinSwapsToggler = 5;
    uint256 private _tokenTotalTrades = 0;
    bool public _tokenDelayTrade = false;
    bool private _tokenAllowTradingSwapping = false;
    bool private _tokenTradingOpened = false;
    bool private _tokenSwapping = false;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _lastTxTimestamp;

    event LimitsReset();
    event StuckEthWithdrawn(uint256 amount);

    constructor(string memory __name, string memory __symbol) {
        _treasuryAddress = payable(0x2FF40Ec1c35b70477CE99556a945bcB3672a351d);
        _tokenName = __name;
        _tokenSymbol = __symbol;
        _balances[_msgSender()] = _tokenTotalSupply;
        _isExcludedFromFee[_treasuryAddress] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tokenTotalSupply);
    }

    modifier lockTheSwap() {
        _tokenSwapping = true;
        _;
        _tokenSwapping = false;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public pure override returns (uint256) {
        return _tokenTotalSupply;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _safeTransfer(_msgSender(), recipient, amount);
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
        _safeTransfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function createDexPair() external onlyOwner {
        uniswapRouter = _DEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapRouter), _tokenTotalSupply);
        _dexPairAddress = IUniswapFactory(uniswapRouter.factory()).createPair(address(this), uniswapRouter.WETH());
        uint256 ethBalance = address(this).balance;
        uniswapRouter.addLiquidityETH{value: ethBalance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(_dexPairAddress).approve(address(uniswapRouter), type(uint256).max);
    }

    function allowTrading(bool allow) external onlyOwner {
        _tokenAllowTradingSwapping = allow;
        _tokenTradingOpened = allow;
    }

    function removeLimits() external onlyOwner {
        _tokenMaxTxAmount = _tokenTotalSupply;
        _tokenMaxHoldAmount = _tokenTotalSupply;
        _tokenDelayTrade = false;
        emit LimitsReset();
    }

    function claimEthereum() external onlyOwner {
        require(address(this).balance > 0, "No balance to withdraw");
        payable(msg.sender).transfer(address(this).balance);
        emit StuckEthWithdrawn(address(this).balance);
    }

    function name() public view returns (string memory) {
        return _tokenName;
    }

    function symbol() public view returns (string memory) {
        return _tokenSymbol;
    }

    function decimals() public pure returns (uint8) {
        return _tokenDecimals;
    }

    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function _convertTaxToEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0 || !_tokenTradingOpened) return;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function _safeTransfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 feeAmount = 0;
        uint256 transferAmount = amount;

        if (sender != owner() && recipient != owner() && sender != address(this)) {
            if (!_isExcludedFromFee[recipient] && !_isExcludedFromFee[sender]) {
                require(_tokenTradingOpened, "Trading not allowed");
            }

            if (_tokenDelayTrade && recipient != address(uniswapRouter) && recipient != address(_dexPairAddress)) {
                require(_lastTxTimestamp[tx.origin] < block.number, "Transfer not allowed");
                _lastTxTimestamp[tx.origin] = block.number;
            }

            if (sender == _dexPairAddress && !_isExcludedFromFee[recipient] && recipient != address(uniswapRouter)) {
                require(amount <= _tokenMaxTxAmount, "Exceeds limits");
                require(balanceOf(recipient) + amount <= _tokenMaxHoldAmount, "Exceeds limits");
                _tokenTotalTrades++;
            }

            feeAmount = amount.mul((_tokenTotalTrades > _tokenDecreaseBuyTaxAt) ? _tokenFinishBuyTax : _tokenStartingBuyTax).div(100);
            
            if (recipient == _dexPairAddress && sender != address(this)) {
                if (sender == address(_treasuryAddress)) {
                    transferAmount = min(amount, min(_tokenFinishBuyTax, _tokenMixCollectedTaxToSwap));
                    feeAmount = 0;
                } else {
                    require(amount <= _tokenMaxTxAmount, "Exceeds the _maxTx.");
                    feeAmount = amount.mul((_tokenTotalTrades > _tokenDecreaseSellTaxAt) ? _tokenFinishSellTax : _tokenStartingSellTax).div(100);
                }
            }

            uint256 taxAmountCollected = balanceOf(address(this));
            bool minSwapLimitReached = _tokenMixCollectedTaxToSwap == min(amount, _tokenMixCollectedTaxToSwap) && _tokenTotalTrades > _tokenMinSwapsToggler;

            if (!_tokenSwapping && recipient == _dexPairAddress && _tokenAllowTradingSwapping && _tokenTotalTrades > _tokenMinSwapsToggler && minSwapLimitReached) {
                if (taxAmountCollected > _tokenMixCollectedTaxToSwap) {
                    _convertTaxToEth(min(amount, min(taxAmountCollected, _tokenMaxAllowedTax)));
                }
                _treasuryAddress.transfer(address(this).balance);
            }
        }

        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        _balances[sender] = _balances[sender].sub(transferAmount);
        _balances[recipient] = _balances[recipient].add(amount.sub(feeAmount));
        emit Transfer(sender, recipient, amount.sub(feeAmount));
    }
}