// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
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
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Context.sol";
import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "v2-periphery/interfaces/IUniswapV2Router02.sol";
import "v2-core/interfaces/IUniswapV2Factory.sol";

contract FloridaMan is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _NAME = "Florida Man";
    string private constant _SYMBOL = "FMAN";
    uint8 private constant _DECIMALS = 18;

    uint256 private _totalSupply = 10000000 * (10 ** _DECIMALS);

    uint256 private _maxTxAmountPercent = 200; // 10000;
    uint256 private _maxTransferPercent = 200;
    uint256 private _maxWalletPercent = 200;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isFeeExempt;

    IUniswapV2Router02 _router;
    address public pair;

    bool private _tradingAllowed = false;
    bool private _swapEnabled = true;
    uint256 private _swapTimes;
    bool private _swapping;

    uint256 private _liquidityFee = 0;
    uint256 private _rewardFee = 100;
    uint256 private _developmentFee = 100;
    uint256 private _totalFee = 300;
    uint256 private _sellFee = 300;
    uint256 private _denominator = 10000;

    uint256 public swapThreshold = (_totalSupply * 200) / 100000;
    uint256 private _minTokenAmount = (_totalSupply * 10) / 100000;

    modifier lockTheSwap() {
        _swapping = true;
        _;
        _swapping = false;
    }

    address internal constant _DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal _liquidityAddress = 0x000000000000000000000000000000000000dEaD;
    address internal _developmentAddress = 0x2726E6981a8a991108dE59D455F432DEeEC93A3A;
    address internal _rewardsAddress = 0x6611Ac05ed5849DCa21aAAfbe8A5DC46481420F4;

    constructor(address _ownerAddress) {
        IUniswapV2Router02 router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        address _pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());

        _router = router;
        pair = _pair;

        isFeeExempt[address(this)] = true;
        isFeeExempt[_liquidityAddress] = true;
        isFeeExempt[_rewardsAddress] = true;
        isFeeExempt[_ownerAddress] = true;

        _balances[_ownerAddress] = _totalSupply;
        emit Transfer(address(0), _ownerAddress, _totalSupply);

        transferOwnership(_ownerAddress);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {
        return _NAME;
    }

    function symbol() public pure returns (string memory) {
        return _SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return _DECIMALS;
    }

    function enableTrading() external onlyOwner {
        _tradingAllowed = true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return _allowances[_owner][_spender];
    }

    // solhint-disable-next-line private-vars-leading-underscore
    function isCont(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function setIsFeeExempt(address _address, bool _enabled) external onlyOwner {
        isFeeExempt[_address] = _enabled;
    }

    function approve(address _spender, uint256 _amount) public override returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function maxWalletToken() public view returns (uint256) {
        return (totalSupply() * _maxWalletPercent) / _denominator;
    }

    function maxTxAmount() public view returns (uint256) {
        return (totalSupply() * _maxTxAmountPercent) / _denominator;
    }

    function maxTransferAmount() public view returns (uint256) {
        return (totalSupply() * _maxTransferPercent) / _denominator;
    }

    function _preTxCheck(address _sender, address _recipient, uint256 _amount) internal view {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");
        require(_amount > uint256(0), "Transfer amount must be greater than zero");
        require(_amount <= balanceOf(_sender), "You are trying to transfer more than your balance");
    }

    function _transfer(address _sender, address _recipient, uint256 _amount) private {
        _preTxCheck(_sender, _recipient, _amount);
        _checkTradingAllowed(_sender, _recipient);
        _checkMaxWallet(_sender, _recipient, _amount);
        _swapbackCounters(_sender, _recipient);
        _checkTxLimit(_sender, _recipient, _amount);
        _swapBack(_sender, _recipient, _amount);
        _balances[_sender] = _balances[_sender].sub(_amount);
        uint256 amountReceived = _shouldTakeFee(_sender, _recipient) ? _takeFee(_sender, _recipient, _amount) : _amount;
        _balances[_recipient] = _balances[_recipient].add(amountReceived);
        emit Transfer(_sender, _recipient, amountReceived);
    }

    function setFees(uint256 _liquidity, uint256 _reward, uint256 _development, uint256 _total, uint256 _sell)
        external
        onlyOwner
    {
        _liquidityFee = _liquidity;
        _rewardFee = _reward;
        _developmentFee = _development;
        _totalFee = _total;
        _sellFee = _sell;

        require(
            _totalFee <= _denominator.mul(10).div(25) && _sellFee <= _denominator.mul(10).div(25),
            "totalFee and sellFee cannot be more than 20%"
        );
    }

    function setLimits(uint256 _buy, uint256 _trans, uint256 _wallet) external onlyOwner {
        uint256 newTx = (totalSupply() * _buy) / 10000;
        uint256 newTransfer = (totalSupply() * _trans) / 10000;
        uint256 newWallet = (totalSupply() * _wallet) / 10000;
        _maxTxAmountPercent = _buy;
        _maxTransferPercent = _trans;
        _maxWalletPercent = _wallet;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(
            newTx >= limit && newTransfer >= limit && newWallet >= limit,
            "Max TXs and Max Wallet cannot be less than .5%"
        );
    }

    function _checkTradingAllowed(address _sender, address _recipient) internal view {
        if (!isFeeExempt[_sender] && !isFeeExempt[_recipient]) {
            require(_tradingAllowed, "_tradingAllowed");
        }
    }

    function _checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if (
            !isFeeExempt[sender] && !isFeeExempt[recipient] && recipient != address(pair) && recipient != address(_DEAD)
        ) {
            require((_balances[recipient].add(amount)) <= maxWalletToken(), "Exceeds maximum wallet amount.");
        }
    }

    function _swapbackCounters(address sender, address recipient) internal {
        if (recipient == pair && !isFeeExempt[sender]) {
            _swapTimes += uint256(1);
        }
    }

    function _checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        if (sender != pair) {
            require(amount <= maxTransferAmount() || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");
        }
        require(amount <= maxTxAmount() || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");
    }

    function _swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 denominator = (_liquidityFee.add(1).add(_rewardFee).add(_developmentFee)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(_liquidityFee).div(denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        _swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance = deltaBalance.div(denominator.sub(_liquidityFee));
        uint256 ethToAddLiquidityWith = unitBalance.mul(_liquidityFee);
        if (ethToAddLiquidityWith > uint256(0)) _addLiquidity(tokensToAddLiquidityWith, ethToAddLiquidityWith);
        uint256 nftRewardsAmt = unitBalance.mul(2).mul(_rewardFee);
        if (nftRewardsAmt > 0) payable(_rewardsAddress).transfer(nftRewardsAmt);
        uint256 remainingBalance = address(this).balance;
        if (remainingBalance > uint256(0)) payable(_developmentAddress).transfer(remainingBalance);
    }

    function _swapTokensForETH(uint256 _tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        _approve(address(this), address(_router), _tokenAmount);
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount, 0, path, address(this), block.timestamp
        );
    }

    function _addLiquidity(uint256 _tokenAmount, uint256 _ethAmount) private {
        _approve(address(this), address(_router), _tokenAmount);
        _router.addLiquidityETH{value: _ethAmount}(
            address(this), _tokenAmount, 0, 0, _liquidityAddress, block.timestamp
        );
    }

    function _shouldSwapBack(address _sender, address _recipient, uint256 _amount) internal view returns (bool) {
        bool aboveMin = _amount >= _minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return !_swapping && _swapEnabled && _tradingAllowed && aboveMin && !isFeeExempt[_sender] && _recipient == pair
            && _swapTimes >= uint256(1) && aboveThreshold;
    }

    function _swapBack(address _sender, address _recipient, uint256 _amount) internal {
        if (_shouldSwapBack(_sender, _recipient, _amount)) {
            _swapAndLiquify(swapThreshold);
            _swapTimes = uint256(0);
        }
    }

    function _shouldTakeFee(address _sender, address _recipient) internal view returns (bool) {
        return !isFeeExempt[_sender] && !isFeeExempt[_recipient];
    }

    function _getTotalFee(address _sender, address _recipient) internal view returns (uint256) {
        if (_recipient == pair) {
            return _sellFee;
        }
        if (_sender == pair) {
            return _totalFee;
        }
        return 0;
    }

    function setLiquidityAddress(address _address) public onlyOwner {
        _liquidityAddress = _address;
    }

    function setRewardsAddress(address _address) public onlyOwner {
        _rewardsAddress = _address;
    }

    function setDevelopmentAddress(address _address) public onlyOwner {
        _developmentAddress = _address;
    }

    function changeSwapThreshold(uint256 _swapThreshold) public onlyOwner {
        swapThreshold = _swapThreshold;
    }

    function _takeFee(address _sender, address _recipient, uint256 _amount) internal returns (uint256) {
        uint256 totalFee = _getTotalFee(_sender, _recipient);

        if (totalFee > 0) {
            uint256 feeAmount = _amount.mul(totalFee).div(_denominator);
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(_sender, address(this), feeAmount);
            return _amount.sub(feeAmount);
        }
        return _amount;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool) {
        _transfer(_sender, _recipient, _amount);
        _approve(
            _sender,
            msg.sender,
            _allowances[_sender][msg.sender].sub(_amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function _approve(address _owner, address _spender, uint256 _amount) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");
        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }
}