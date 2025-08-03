// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
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
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract NAILS is Context, IERC20, IERC20Metadata, IERC20Errors, Ownable {
    string private constant _name = "Nails Tech";
    string private constant _symbol = "NAILS";
    uint8 private constant _decimals = 18;
    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public immutable uniswapV2Pair;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    address public treasuryWallet = 0xeFcc9b8aEd029b09C12D8CD35178b14C33A2e6f5;
    uint256 public constant maxTxAmount = 50000000 * 10 ** _decimals;
    bool public maxTxAmountStatus = false;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _tFeeTotal;
    uint256 private _rTotal = (type(uint256).max - (type(uint256).max % _tTotal));
    uint256 private _reflectionFee = 0;
    uint256 private _treasuryFee = 0;
    uint256 private _previousReflectionFee = _reflectionFee;
    uint256 private _previousTreasuryFee = _treasuryFee;
    address[] private _excluded;

    struct BuyFee {
        uint8 reflectionFee;
        uint8 treasuryFee;
    }

    struct SellFee {
        uint8 reflectionFee;
        uint8 treasuryFee;
    }

    BuyFee public buyFee;
    SellFee public sellFee;

    event MaxTxAmountStatusChanged(bool newStatus);
    event ExcludedFromFee(address indexed account);
    event IncludedInFee(address indexed account);
    event ExcludedFromReward(address indexed account);
    event IncludedInReward(address indexed account);
    event TreasuryWalletUpdated(address indexed newWallet);
    event AirdropReflections(address indexed sender, uint256 amount);
    event ReflectionsDistributed(uint256 amount);

    constructor() Ownable(msg.sender) {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        excludeFromReward(uniswapV2Pair);
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[treasuryWallet] = true;

        buyFee.reflectionFee = sellFee.reflectionFee = 2;
        buyFee.treasuryFee = sellFee.treasuryFee = 1;

        _rOwned[msg.sender] = _rTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() external pure returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external pure returns (uint256) {
        return _tTotal;
    }
    
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        if (_isExcluded[account]) {
            return _tOwned[account];
        }
        return _tokenFromReflection(_rOwned[account]);
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) external returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) private {
        _approve(owner, spender, value, true);
    }

    /**private
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) private {
        if (owner == address(0)) { revert ERC20InvalidApprover(address(0)); }
        if (spender == address(0)) { revert ERC20InvalidSpender(address(0)); }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) private {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "NAILS: transfer from zero address");
        require(to != address(0), "NAILS: transfer to zero address");
        require(amount > 0, "NAILS: Transfer amount must be greater than zero");

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && maxTxAmountStatus) {
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        removeAllFee();

        if (takeFee) {
            if (sender == uniswapV2Pair) { setBuy(); }
            if (recipient == uniswapV2Pair) { setSell(); }
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) {
            restoreAllFee();
        }
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTreasury) = _getValues(tAmount);
        _tOwned[sender] -= tAmount;
        _rOwned[sender] -= rAmount;

        _rOwned[recipient] += rTransferAmount;

        _takeTreasury(sender, tTreasury);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTreasury) = _getValues(tAmount);
        _rOwned[sender] -= rAmount;

        _tOwned[recipient] += tTransferAmount;
        _rOwned[recipient] += rTransferAmount;

        _takeTreasury(sender, tTreasury);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTreasury) = _getValues(tAmount);
        _rOwned[sender] -= rAmount;
        _rOwned[recipient] += rTransferAmount;

        _takeTreasury(sender, tTreasury);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTreasury) = _getValues(tAmount);
        _tOwned[sender] -= tAmount;
        _rOwned[sender] -= rAmount;

        _tOwned[recipient] += tTransferAmount;
        _rOwned[recipient] += rTransferAmount;

        _takeTreasury(sender, tTreasury);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function removeAllFee() private {
        if (_reflectionFee == 0 && _treasuryFee == 0) return;

        _previousReflectionFee = _reflectionFee;
        _previousTreasuryFee = _treasuryFee;

        _reflectionFee = _treasuryFee = 0;
    }

    function setBuy() private {
        _reflectionFee = buyFee.reflectionFee;
        _treasuryFee = buyFee.treasuryFee;
    }

    function setSell() private {
        _reflectionFee = sellFee.reflectionFee;
        _treasuryFee = sellFee.treasuryFee;
    }

    function restoreAllFee() private {
        _reflectionFee = _previousReflectionFee;
        _treasuryFee = _previousTreasuryFee;
    }

    function _takeTreasury(address sender, uint256 tTreasury) private {
        uint256 currentRate = _getRate();
        uint256 rTreasury = tTreasury * currentRate;
        _rOwned[treasuryWallet] += rTreasury;
        if (_isExcluded[treasuryWallet]) _tOwned[treasuryWallet] += tTreasury;
        if (tTreasury > 0) {
            emit Transfer(sender, treasuryWallet, tTreasury);
        }
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal -= rFee;
        _tFeeTotal += tFee;
        emit ReflectionsDistributed(tFee);
    }

    function totalReflectionsDistributed() external view returns (uint256) {
        return _tFeeTotal;
    }

    function _tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "NAILS: Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "NAILS: Account is already excluded from reward");
        if (_rOwned[account] > 0) {
            _tOwned[account] = _tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
        emit ExcludedFromReward(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "NAILS: Account is already included in reward");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                emit IncludedInReward(account);
                break;
            }
        }
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedInFee(account);
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function changeTreasuryWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "NAILS: new wallet is zero address");
        treasuryWallet = newWallet;
        emit TreasuryWalletUpdated(newWallet);
    }

    function changeMaxTxAmountStatus(bool flag) external onlyOwner {
        maxTxAmountStatus = flag;
        emit MaxTxAmountStatusChanged(flag);
    }

    function airdropReflections(uint256 amount) external {
        address sender = _msgSender();
        require(!_isExcluded[sender], "NAILS: Excluded address cannot call this function");
        (uint256 rAmount, , , , , ) = _getValues(amount);
        _rOwned[sender] -= rAmount;
        _rTotal -= rAmount;
        _tFeeTotal += amount;
        emit AirdropReflections(sender, amount);
    }

    function _getValues(uint256 tAmount)private view returns (uint256, uint256, uint256, uint256, uint256, uint256)
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTreasury) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTreasury, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTreasury);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTreasury, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rTreasury = tTreasury * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rTreasury;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = _calculateReflectionFee(tAmount);
        uint256 tTreasury = _calculateTreasuryFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tTreasury;
        return (tTransferAmount, tFee, tTreasury);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _calculateReflectionFee(uint256 amount) private view returns (uint256) {
        return (amount * _reflectionFee) / 100;
    }

    function _calculateTreasuryFee(uint256 amount) private view returns (uint256) {
        return (amount * _treasuryFee) / 100;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) {
                return (_rTotal, _tTotal);
            }
            rSupply -= _rOwned[_excluded[i]];
            tSupply -= _tOwned[_excluded[i]];
        }
        if (rSupply < (_rTotal / _tTotal)) {
            return (_rTotal, _tTotal);
        }
        return (rSupply, tSupply);
    }
}