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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
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
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
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
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT

/**
    Web: https://orygyn.fi/
    Whitepaper: https://orygyn.fi/whitepaper
    X: https://x.com/orygynfi
    TG: http://t.me/orygyncommunity
 */
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IStaking.sol";

interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.2;

library SafeCast {
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(
            value <= uint256(type(int256).max),
            "SafeCast: value doesn't fit in an int256"
        );
        return int256(value);
    }
}

pragma solidity ^0.8.2;

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity ^0.8.2;

contract Staking is ReentrancyGuard, Ownable {
    using SafeCast for uint256;
    using SafeCast for int256;

    uint256 public tokensForSwap;

    mapping(address => uint256) public totalTokensStaked;
    mapping(address => uint256) summedRewardPerShare;
    mapping(address => uint256) cumulativeDistributedRewards;
    uint256 public withdrawalFeePercentage;
    uint256 constant percentageScalingFactor = 100;
    uint256 public lockPeriod;

    uint128 public constant PRIZE_AMPLIFICATION_RATIO = type(uint128).max;
    struct StakeRecord {
        address token;
        uint256 amount;
        uint128 unstakeTime;
    }

    mapping(address => StakeRecord[]) public userStakes;
    mapping(address => mapping(address => int256))
        public userPointsModification;
    mapping(address => mapping(address => uint256)) public userPayoutRewards;
    mapping(address => mapping(address => uint256)) public userDepositedStakes;

    mapping(uint8 => address) public stakeTokens;
    mapping(address => uint256) public rewardPerBlock;
    mapping(address => uint256) public lastDistributionBlock;

    event Deposited(uint256 amount, address depositor);
    event Withdrawn(address depositor, uint256 amount);
 event WithdrawFeeUpdated(uint8 amount);
 event TradingEnabled(bool);

    constructor() {
        lockPeriod =  7 days;
        withdrawalFeePercentage = 2;
    }

    function _stake(
        uint256 _amount,
        address _account,
        address stakeToken
    ) internal {

        userStakes[_account].push(
            StakeRecord({
                token: stakeToken,
                amount: _amount,
                unstakeTime: uint128(block.timestamp + lockPeriod)
            })
        );
        userDepositedStakes[stakeToken][_account] += _amount;
        rewardPointsAdjustment(stakeToken, _account, -int256(_amount));
        totalTokensStaked[stakeToken] += _amount;
        emit Deposited(_amount, _account);
    }

    function _unstake(uint256 id) internal {
        StakeRecord memory userStakeInfo = userStakes[msg.sender][id];
        if (id >= userStakes[msg.sender].length) {
            revert("Invalid Id");
        }
        uint256 unStakeAmount = userStakeInfo.amount;

        userDepositedStakes[userStakeInfo.token][msg.sender] -= unStakeAmount;
        rewardPointsAdjustment(
            userStakeInfo.token,
            msg.sender,
            int256(unStakeAmount)
        );
        totalTokensStaked[userStakeInfo.token] -= unStakeAmount ;
        if (block.timestamp < userStakeInfo.unstakeTime) {
            uint256 unstakeFee = (unStakeAmount * withdrawalFeePercentage) /
                percentageScalingFactor;
        if(unstakeFee > 0) {
            require(IERC20(userStakeInfo.token).transfer(owner(), unstakeFee),"Transfer failed");
            unStakeAmount -= unstakeFee;
            }
        }

        require(IERC20(userStakeInfo.token).transfer(msg.sender, unStakeAmount),"Transfer failed");

        if (id < userStakes[msg.sender].length - 1) {
            userStakes[msg.sender][id] = userStakes[msg.sender][
                userStakes[msg.sender].length - 1
            ];
        }
        userStakes[msg.sender].pop();
        emit Withdrawn(msg.sender, userStakeInfo.amount);
    }

    function setWithdrawFeeRate(uint8 newWithdrawFeeRate) external onlyOwner {
        if (newWithdrawFeeRate > 10) {
            revert("Invalid Fee");
        }
        withdrawalFeePercentage = newWithdrawFeeRate;
        emit WithdrawFeeUpdated(newWithdrawFeeRate);

    }

    function rewardsAvailableForRedemption(address _token, address _account)
        public
        view
        returns (uint256)
    {
        return
            rewardsAccumulationOf(_token, _account) -
            userPayoutRewards[_token][_account];
    }

    function rewardsAcquiredBy(address _token, address account)
        public
        view
        returns (uint256)
    {
        return userPayoutRewards[_token][account];
    }

    function rewardsAccumulationOf(address _token, address _account)
        public
        view
        returns (uint256)
    {
        return
            ((summedRewardPerShare[_token] *
                userDepositedStakes[_token][_account]).toInt256() +
                userPointsModification[_token][_account]).toUint256() /
            PRIZE_AMPLIFICATION_RATIO;
    }

    function updateRewardsInfoForStakers(address _token, uint256 _amountForDistribution)
        internal
    {
        require(totalTokensStaked[_token] != 0, "zero supply");
        if (_amountForDistribution > 0) {
            summedRewardPerShare[_token] =
                summedRewardPerShare[_token] +
                ((_amountForDistribution * PRIZE_AMPLIFICATION_RATIO) /
                    totalTokensStaked[_token]);
        }
    }

    function rewardClaimPreparation(
        address _token,
        address rewardClaimBeneficiary
    ) internal returns (uint256) {
        uint256 redeemableShare = rewardsAvailableForRedemption(
            _token,
            rewardClaimBeneficiary
        );
        if (redeemableShare > 0) {
            userPayoutRewards[_token][rewardClaimBeneficiary] =
                userPayoutRewards[_token][rewardClaimBeneficiary] +
                redeemableShare;
        }
        return redeemableShare;
    }

    function rewardPointsAdjustment(
        address _token,
        address account,
        int256 adjustedShares
    ) internal {
        userPointsModification[_token][account] =
            userPointsModification[_token][account] +
            (adjustedShares * int256(summedRewardPerShare[_token]));
    }

    function getStakeHistory(address user)
        public
        view
        returns (StakeRecord[] memory)
    {
        return userStakes[user];
    }
}

contract Yang is ERC20, Ownable, IStaking, Staking {
    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public  immutable routerCA;

    bool private swapping;

    address public devWallet;

    uint256 public  maxTxAmount;
    uint256 public swapTokensAtAmount;
    uint256 public  maxWallet;

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;

    uint256 public buyDevFee = 2;
    uint256 public sellDevFee = 2;
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 1e18;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedMaxTransactionAmount;

    mapping(address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() ERC20("Yang - Orygyn Finance", "YANG") {
        routerCA = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerCA);

        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        uint256 initialSupply = 400_000_000 * 1e18;

        maxTxAmount = 8_000_000 * 1e18; // 2% max txn of intial supply
        maxWallet = 8_000_000 * 1e18; // 2% max wallet of intial supply
        swapTokensAtAmount = (initialSupply * 2) / 1000; // 0.2% swap wallet
        devWallet = address(0x722eFe2eCe7d36Ef00fb8af866A47E0449770172);

        buyDevFee = 21;
        sellDevFee = 21;

        // exclude from payang fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);

        _mint(msg.sender, initialSupply);
    }

    receive() external payable {}

    function startTrading() external onlyOwner {
        require(!tradingActive, "Trading Live Already");
        tradingActive = true;
        swapEnabled = true;
        emit TradingEnabled(true);
    }

    // remove limits after token is stable
    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        return true;
    }

    function excludeFromMaxTransaction(address updAds, bool isEx)
        public
        onlyOwner
    {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    // only use to disable contract sales if absolutely necessary (emergency use only)
    function updateSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
    }

    function updateBuyFees(uint256 _devFee) external onlyOwner {
        buyDevFee = _devFee;
        require(buyDevFee <= 2,"Invalid tax");
    }

    function updateSellFees(uint256 _devFee) external onlyOwner {
        sellDevFee = _devFee;
        require(sellDevFee <= 2,"Invalid tax");
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0xdead) &&
                !swapping
            ) {
                if (!tradingActive) {
                    require(
                        _isExcludedFromFees[from] || _isExcludedFromFees[to],
                        "Trading is not active."
                    );
                }

                //when buy
                if (
                    automatedMarketMakerPairs[from] &&
                    !_isExcludedMaxTransactionAmount[to]
                ) {
                    require(
                        amount <= maxTxAmount,
                        "Buy transfer amount exceeds the maxTransactionAmount."
                    );
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
                //when sell
                else if (
                    automatedMarketMakerPairs[to] &&
                    !_isExcludedMaxTransactionAmount[from]
                ) {
                    require(
                        amount <= maxTxAmount,
                        "Sell transfer amount exceeds the maxTransactionAmount."
                    );
                } else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            from != owner() &&
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to] &&
            automatedMarketMakerPairs[to]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }
        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on sell
            if (automatedMarketMakerPairs[to] && sellDevFee > 0) {
                fees = (amount * sellDevFee)/100;
                tokensForSwap += fees;
            }
            // on buy
            else if (automatedMarketMakerPairs[from] && buyDevFee > 0) {
                fees = (amount * buyDevFee)/100;
                tokensForSwap += fees;
            }
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function stake(uint8 _tokenId, uint256 _amount) external nonReentrant {
        require(_tokenId < 2, "Invalid token");
        address stakeToken = stakeTokens[_tokenId];
        IERC20(stakeToken).transferFrom(msg.sender, address(this), _amount);
        _stake(_amount, msg.sender, stakeToken);
        address _token = stakeTokens[_tokenId];
        disperseRewards(_token);
    }
    
    function unstake(uint256 id) external nonReentrant {
        _unstake(id);
    }

    function claim(uint8 _tokenId) public {
        require(_tokenId < 2, "Invalid token");
        address _token = stakeTokens[_tokenId];
        disperseRewards(_token);
        uint256 reward = rewardClaimPreparation(_token, msg.sender);

        if (reward > 1) {
            mintRewards(msg.sender, reward);
            cumulativeDistributedRewards[_token] += reward;
        }
    }

    function compounding(
        uint256 _amount,
        address _account,
        uint8 _tokenId
    ) external {
        require(msg.sender == stakeTokens[0], "Not allowed");
        address stakeToken = stakeTokens[_tokenId];
        _stake(_amount, _account, stakeToken);
    }

    function disperseRewards(address _token) public {
        uint256 totalBlocks = block.number - lastDistributionBlock[_token];
        uint256 rewardPool = totalBlocks * rewardPerBlock[_token];
        if(totalSupply() + rewardPool <= MAX_SUPPLY){
        updateRewardsInfoForStakers(_token, rewardPool);
        }
    }

    function compoundRewards(uint8 _tokenId) public {
        require(_tokenId < 2, "Invalid token");
        address _token = stakeTokens[_tokenId];
        disperseRewards(_token);
        uint256 reward = rewardClaimPreparation(_token, msg.sender);

        if (reward > 1) {
            mintRewards(stakeTokens[0], reward);
            cumulativeDistributedRewards[_token] += reward;
            IStaking(stakeTokens[0]).compounding(reward, msg.sender, _tokenId);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            devWallet,
            block.timestamp
        );
    }


    function swapBack() private {
        uint256 totalTokensToSwap = tokensForSwap;

        if (totalTokensToSwap == 0) {
            return;
        }

        if (totalTokensToSwap > swapTokensAtAmount * 10) {
            totalTokensToSwap = swapTokensAtAmount * 10;
        }

        swapTokensForEth(totalTokensToSwap);

        tokensForSwap -= totalTokensToSwap;
    }

    function burn(uint256 amount) external {
        require(amount > 0,"Zero amount");
        _burn(msg.sender, amount);
    }


    function setConfig(address oneToken, address twoLP, uint256 tokenRPB, uint256 lpRPB)
        external
        onlyOwner
    {
        stakeTokens[0] = oneToken;
        stakeTokens[1] = twoLP;

        lastDistributionBlock[oneToken] = block.number;
        lastDistributionBlock[twoLP] = block.number;

        rewardPerBlock[oneToken] = tokenRPB;
        rewardPerBlock[twoLP] = lpRPB;

        _approve(address(this), oneToken, type(uint256).max);
    }

    function mintRewards(address _receiver, uint256 _amount) private {
            require(totalSupply() + _amount <= MAX_SUPPLY, "Max supply reached");
            super._mint(_receiver, _amount);
    }
        function withdrawAllEther() external {
    uint256 balance = address(this).balance;
    if(balance > 0){
        (bool success, ) = devWallet.call{value: balance}("");
        require(success, "Transfer failed");
    }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IStaking {
    function stake(uint8 tokenId, uint256 amount) external;
    function unstake(uint256 id) external;
    function compounding(uint256 _amount, address _account,uint8 stakeToken) external;


}