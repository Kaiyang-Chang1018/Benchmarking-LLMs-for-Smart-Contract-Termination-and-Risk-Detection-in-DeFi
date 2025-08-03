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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
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
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {DistributionManager} from "./DistributionManager.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract AutoYieldFarming is DistributionManager, ERC20 {
    /*
    ╔══════════════════════════════╗
    
    ║           VARIABLES          ║
    
    ╚══════════════════════════════╝
    */
    address public owner;
    IERC20 public rewardToken;
    IERC20 public farmToken;

    uint256 constant EPOCH_DURATION = 30 days;
    uint256 constant WITHDRAW_DURATION = 1 days;

    uint256 public startTime;
    uint256 mockTime;
    uint256 paddingTime;
    uint128 emissionPerSecond;

    mapping(address => uint256) public farmerRewardsToClaim;
    mapping(address => uint256) public userClaimed;

    /*
    ╔══════════════════════════════╗
    
    ║           MODIFIER           ║
    
    ╚══════════════════════════════╝
    */

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /*
    ╔══════════════════════════════╗
    
    ║            EVENTS            ║
    
    ╚══════════════════════════════╝
    */

    event Farm(address indexed user, uint256 amount);

    event Withdraw(address indexed user, uint256 amount);

    event RewardsAccrued(address indexed user, uint256 amount);

    event RewardsClaimed(address indexed user, uint256 amount);

    /*
    ╔══════════════════════════════╗
    
    ║          INITIALIZE          ║
    
    ╚══════════════════════════════╝
    */

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _distributionDuration,
        uint128 _emissionPerSecond,
        address _farmToken,
        address _rewardToken,
        address _owner
    ) ERC20(_name, _symbol) {
        require(address(_farmToken) != address(0), "INVALID ADDRESS");
        require(address(_rewardToken) != address(0), "INVALID ADDRESS");
        owner = _owner;
        rewardToken = IERC20(_rewardToken);
        farmToken = IERC20(_farmToken);
        distributionEnd = block.timestamp + _distributionDuration;
        emissionPerSecond = _emissionPerSecond;
    }

    /*
    ╔══════════════════════════════╗
    
    ║       ADMIN FUNCTIONS        ║
    
    ╚══════════════════════════════╝
    */

    function setOwner(address _owner) external onlyOwner {
        require(_owner != address(0), "INVALID ADDRESS");
        owner = _owner;
    }

    function setRewardToken(IERC20 _rewardToken) external onlyOwner {
        require(address(_rewardToken) != address(0), "INVALID ADDRESS");
        rewardToken = _rewardToken;
    }

    function setFarmToken(IERC20 _farmToken) external onlyOwner {
        require(address(_farmToken) != address(0), "INVALID ADDRESS");
        farmToken = _farmToken;
    }

    function increaseDistribution(
        uint256 distributionDuration
    ) external onlyOwner {
        distributionEnd = distributionEnd + distributionDuration;
    }

    function configureAsset(
        uint128 _InputEmissionPerSecond
    ) external onlyOwner {
        AssetConfigInput memory assetConfigInput = AssetConfigInput({
            emissionPerSecond: _InputEmissionPerSecond,
            totalStaked: totalSupply()
        });
        _configureAsset(assetConfigInput);
    }

    function transferAllRewardToken(
        address _tokenAddress,
        address _receiver
    ) external onlyOwner {
        rewardToken.transfer(
            _receiver,
            IERC20(_tokenAddress).balanceOf(address(this))
        );
    }

    function rescueERC20Tokens(address tokenAddress) external onlyOwner {
        IERC20(tokenAddress).transfer(
            msg.sender,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function startEpoch() external {
        require(msg.sender == address(rewardToken), "Only reward token");
        startTime = block.timestamp - WITHDRAW_DURATION;
        paddingTime = EPOCH_DURATION - (startTime % EPOCH_DURATION);
        mockTime = (startTime + paddingTime) / EPOCH_DURATION;

        AssetConfigInput memory assetConfigInput = AssetConfigInput({
            emissionPerSecond: emissionPerSecond,
            totalStaked: totalSupply()
        });
        _configureAsset(assetConfigInput);
    }

    /*
    ╔══════════════════════════════╗
    
    ║       EXTERNAL FUNCTIONS     ║
    
    ╚══════════════════════════════╝
  */

    /**
     * @dev Withdraws farmed tokens, and stop earning rewards
     * @param _amount Amount to withdraw
     **/
    function farm(uint256 _amount, address _receiver) external {
        require(_amount != 0, "INVALID_ZERO_AMOUNT");

        uint256 balanceOfUser = balanceOf(_receiver);

        uint256 accruedRewards = _updateUserAssetInternal(
            _receiver,
            balanceOfUser,
            totalSupply()
        );
        if (accruedRewards != 0) {
            emit RewardsAccrued(_receiver, accruedRewards);
            farmerRewardsToClaim[_receiver] =
                farmerRewardsToClaim[_receiver] +
                accruedRewards;
        }

        _mint(_receiver, _amount);

        farmToken.transferFrom(msg.sender, address(this), _amount);

        emit Farm(_receiver, _amount);
    }

    /**
     * @dev Withdraws farmed tokens, and stop earning rewards
     * @param _amount Amount to withdraw
     **/
    function withdraw(uint256 _amount) external {
        require(_amount != 0, "INVALID_ZERO_AMOUNT");
        require(isWithdrawable(block.timestamp), "NOT TIME YET");
        address withdrawer = _msgSender();

        uint256 balanceOfWithdrawer = balanceOf(withdrawer);

        uint256 amountToWithdraw = (_amount > balanceOfWithdrawer)
            ? balanceOfWithdrawer
            : _amount;

        _updateCurrentUnclaimedRewards(withdrawer, balanceOfWithdrawer, true);

        _burn(withdrawer, amountToWithdraw);

        farmToken.transfer(withdrawer, amountToWithdraw);

        emit Withdraw(msg.sender, amountToWithdraw);
    }

    /**
     * @dev Claims an `amount` of `REWARD_TOKEN` to the msg.sender
     **/
    function claimRewards() external {
        address claimer = _msgSender();
        uint256 amountToClaim = _updateCurrentUnclaimedRewards(
            claimer,
            balanceOf(claimer),
            false
        );

        farmerRewardsToClaim[claimer] = 0;

        rewardToken.transfer(claimer, amountToClaim);

        userClaimed[msg.sender] += amountToClaim;

        emit RewardsClaimed(claimer, amountToClaim);
    }

    /**
     * @dev Return the total rewards pending to claim by an farmer
     * @param _farmer The farmer address
     * @return The rewards
     */
    function getTotalRewardsBalance(
        address _farmer
    ) external view returns (uint256) {
        UserStakeInput memory userFarmInput = UserStakeInput({
            stakedByUser: balanceOf(_farmer),
            totalStaked: totalSupply()
        });

        return
            farmerRewardsToClaim[_farmer] +
            _getUnclaimedRewards(_farmer, userFarmInput);
    }

    function isWithdrawable(uint256 _timestamp) public view returns (bool) {
        if (
            ((_timestamp + paddingTime) /
                WITHDRAW_DURATION -
                (mockTime * EPOCH_DURATION) /
                WITHDRAW_DURATION) %
                (EPOCH_DURATION / WITHDRAW_DURATION) <
            1
        ) return (true);
        else return (false);
    }

    function timeLeftUntilWithdrawable() external view returns (uint256) {
        uint256 time = startTime;
        while (time < block.timestamp) {
            time = time + EPOCH_DURATION;
        }
        return time;
    }

    /*
    ╔══════════════════════════════╗
    
    ║       INTERNAL FUNCTIONS     ║
    
    ╚══════════════════════════════╝
  */

    /**
     * @dev Updates the user state related with his accrued rewards
     * @param _user Address of the user
     * @param _userBalance The current balance of the user
     * @param _updateStorage Boolean flag used to update or not the farmerRewardsToClaim of the user
     * @return The unclaimed rewards that were added to the total accrued
     **/
    function _updateCurrentUnclaimedRewards(
        address _user,
        uint256 _userBalance,
        bool _updateStorage
    ) internal returns (uint256) {
        uint256 accruedRewards = _updateUserAssetInternal(
            _user,
            _userBalance,
            totalSupply()
        );
        uint256 unclaimedRewards = farmerRewardsToClaim[_user] + accruedRewards;

        if (accruedRewards != 0) {
            if (_updateStorage) {
                farmerRewardsToClaim[_user] = unclaimedRewards;
            }
            emit RewardsAccrued(_user, accruedRewards);
        }

        return unclaimedRewards;
    }

    /**
     * @dev Internal ERC20 _transfer of the tokenized farmed tokens
     * @param from Address to transfer from
     * @param to Address to transfer to
     * @param amount Amount to transfer
     **/
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        uint256 balanceOfFrom = balanceOf(from);
        // Sender
        _updateCurrentUnclaimedRewards(from, balanceOfFrom, true);

        // Recipient
        if (from != to) {
            uint256 balanceOfTo = balanceOf(to);
            _updateCurrentUnclaimedRewards(to, balanceOfTo, true);
        }

        super._transfer(from, to, amount);
    }
}
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./DividendTracker.sol";
import "./AutoYieldFarming.sol";
import "./interfaces/IStaking.sol";

contract AutoYieldProtocol is ERC20, Ownable {
    IUniswapRouter public router;
    address public pair;
    address public projectDevelopmentWallet;
    DividendTracker public dividendTracker;
    AutoYieldFarming public autoYieldFarming;

    bool private swapping;
    bool public claimEnabled;
    bool public tradingEnabled;

    uint256 public swapTokensAtAmount;
    uint256 public antiBotAmount;
    uint256 public antiBotEndBlock;

    struct Taxes {
        uint256 projectDevelopment;
        uint256 holder;
        uint256 farming;
    }

    Taxes public buyTaxes = Taxes(1, 1, 0);
    Taxes public sellTaxes = Taxes(1, 1, 3);

    uint256 public totalBuyTax = 2;
    uint256 public totalSellTax = 5;

    mapping(address => bool) public isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => mapping(uint256 => bool)) public isTransferred;

    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor(
        address _projectDevelopmentWallet,
        address _routerAddress
    ) ERC20("Auto Yield Protocol", "AYP") {
        dividendTracker = new DividendTracker();
        setProjectDevelopmentWallet(_projectDevelopmentWallet);

        IUniswapRouter _router = IUniswapRouter(_routerAddress);

        _approve(address(this), _routerAddress, type(uint256).max);

        address _pair = IFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );

        router = _router;
        pair = _pair;
        setSwapTokensAtAmount(60_000);

        AutoYieldFarming _autoYieldFarming = new AutoYieldFarming(
            "AYP-ETH rLP",
            "AYP-ETH rLP",
            150 days,
            uint128(231481481481481000),
            _pair,
            address(this),
            _projectDevelopmentWallet
        );

        autoYieldFarming = _autoYieldFarming;

        antiBotAmount = 280_000 * (10 ** 18);

        IERC20(_pair).approve(address(_autoYieldFarming), type(uint256).max);

        _setAutomatedMarketMakerPair(_pair, true);

        dividendTracker.updateLP_Token(_pair);

        dividendTracker.excludeFromDividends(address(dividendTracker), true);
        dividendTracker.excludeFromDividends(address(_autoYieldFarming), true);
        dividendTracker.excludeFromDividends(address(this), true);
        dividendTracker.excludeFromDividends(owner(), true);
        dividendTracker.excludeFromDividends(address(0xdead), true);
        dividendTracker.excludeFromDividends(address(_router), true);

        excludeFromFees(owner(), true);
        excludeFromFees(_projectDevelopmentWallet, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(_autoYieldFarming), true);

        _mint(owner(), 7_000_000 * (10 ** 18)); // 70%
        _mint(address(_autoYieldFarming), 3_000_000 * (10 ** 18)); // 30%
    }

    receive() external payable {}

    function updateDividendTracker(address newAddress) public onlyOwner {
        DividendTracker newDividendTracker = DividendTracker(
            payable(newAddress)
        );
        newDividendTracker.excludeFromDividends(
            address(newDividendTracker),
            true
        );
        newDividendTracker.excludeFromDividends(address(this), true);
        newDividendTracker.excludeFromDividends(owner(), true);
        newDividendTracker.excludeFromDividends(address(router), true);
        dividendTracker = newDividendTracker;
    }

    /// @notice Manual claim the dividends
    function claim() external {
        require(claimEnabled, "Claim not enabled");
        dividendTracker.processAccount(payable(msg.sender));
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount * 10 ** 18;
    }

    /// @notice Withdraw tokens sent by mistake.
    /// @param tokenAddress The address of the token to withdraw
    function rescueERC20Tokens(address tokenAddress) external onlyOwner {
        IERC20(tokenAddress).transfer(
            owner(),
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function forceSend() external onlyOwner {
        uint256 ETHbalance = address(this).balance;
        (bool success, ) = payable(projectDevelopmentWallet).call{
            value: ETHbalance
        }("");
        require(success);
    }

    function trackerRescueERC20Tokens(address tokenAddress) external {
        require(msg.sender == projectDevelopmentWallet, "Only Admin");
        dividendTracker.trackerRescueERC20Tokens(msg.sender, tokenAddress);
    }

    function trackerRescueETH() external {
        require(msg.sender == projectDevelopmentWallet, "Only Admin");
        dividendTracker.trackerRescueETH(msg.sender);
    }

    function updateRouter(address newRouter) external onlyOwner {
        router = IUniswapRouter(newRouter);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeFromDividends(
        address account,
        bool value
    ) public onlyOwner {
        dividendTracker.excludeFromDividends(account, value);
    }

    function setProjectDevelopmentWallet(address newWallet) public onlyOwner {
        projectDevelopmentWallet = newWallet;
    }

    function activateTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled");
        tradingEnabled = true;
        claimEnabled = true;
        autoYieldFarming.startEpoch();
        antiBotEndBlock = block.number + 2;
    }

    function setClaimEnabled(bool state) external onlyOwner {
        claimEnabled = state;
    }

    function setLP_Token(address _lpToken) external onlyOwner {
        dividendTracker.updateLP_Token(_lpToken);
    }

    function setAutomatedMarketMakerPair(
        address newPair,
        bool value
    ) external onlyOwner {
        _setAutomatedMarketMakerPair(newPair, value);
    }

    function _setAutomatedMarketMakerPair(address newPair, bool value) private {
        require(
            automatedMarketMakerPairs[newPair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[newPair] = value;

        if (value) {
            dividendTracker.excludeFromDividends(newPair, true);
        }

        emit SetAutomatedMarketMakerPair(newPair, value);
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(
        address account
    ) public view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(
        address account
    ) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function getAccountInfo(
        address account
    ) external view returns (address, uint256, uint256, uint256, uint256) {
        return dividendTracker.getAccount(account);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (!isExcludedFromFees[from] && !isExcludedFromFees[to] && !swapping) {
            require(tradingEnabled, "Trading not active");
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (tx.origin == from || tx.origin == to) {
            require(!isTransferred[tx.origin][block.number], "Bot!");
            isTransferred[tx.origin][block.number] = true;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !swapping &&
            automatedMarketMakerPairs[to] &&
            !isExcludedFromFees[from] &&
            !isExcludedFromFees[to]
        ) {
            swapping = true;

            swapAndLiquify(swapTokensAtAmount);

            swapping = false;
        }

        bool takeFee = !swapping;

        // If any account belongs to _isExcludedFromFee account then remove the fee
        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (!automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from])
            takeFee = false;

        if (takeFee) {
            uint256 feeAmt;
            uint256 farming;
            bool isSell;
            if (automatedMarketMakerPairs[to]) {
                feeAmt = (amount * totalSellTax) / 100;
                farming = (feeAmt * sellTaxes.farming) / totalSellTax;
                isSell = true;
            } else if (automatedMarketMakerPairs[from]) {
                feeAmt = (amount * totalBuyTax) / 100;
            }

            if (
                antiBotEndBlock > block.number &&
                amount > antiBotAmount &&
                to != address(this) &&
                automatedMarketMakerPairs[from]
            ) {
                feeAmt = (amount * 80) / 100;
            }

            amount = amount - feeAmt;

            super._transfer(from, address(this), feeAmt);

            if (isSell && !swapping) {
                swapping = true;
                swapAndFarm(farming, from);
                swapping = false;
            }
        }
        super._transfer(from, to, amount);

        try dividendTracker.setBalance(from, balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(to, balanceOf(to)) {} catch {}
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 toSwapForHolder = (tokens * buyTaxes.holder) / totalBuyTax;

        uint256 toSwapForProjectDevelopment = tokens - toSwapForHolder;

        swapTokensForETH(toSwapForHolder / 2);

        uint256 currentbalance = address(this).balance;

        if (currentbalance > 0) {
            addLiquidity(toSwapForHolder / 2, currentbalance);
        }

        swapTokensForETH(toSwapForProjectDevelopment);

        uint256 projectDevelopmentAmt = address(this).balance;

        if (projectDevelopmentAmt > 0) {
            payable(projectDevelopmentWallet).transfer(projectDevelopmentAmt);
        }

        uint256 lpBalance = IERC20(pair).balanceOf(address(this));

        //Send LP to dividends
        uint256 dividends = lpBalance;

        if (dividends > 0) {
            bool success = IERC20(pair).transfer(
                address(dividendTracker),
                dividends
            );
            if (success) {
                dividendTracker.distributeLPDividends(dividends);
                emit SendDividends(tokens, dividends);
            }
        }
    }

    function swapAndFarm(uint256 tokens, address swaper) private {
        swapTokensForETH(tokens / 2);
        uint256 currentbalance = address(this).balance;
        if (currentbalance > 0) {
            addLiquidity(tokens / 2, currentbalance);
        }

        uint256 lpBalance = IERC20(pair).balanceOf(address(this));
        autoYieldFarming.farm(lpBalance, swaper);
    }

    function manualLiquidityDistribution(uint256 amount) public onlyOwner {
        bool success = IERC20(pair).transferFrom(
            msg.sender,
            address(dividendTracker),
            amount
        );
        if (success) {
            dividendTracker.distributeLPDividends(amount);
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        // Make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // Add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            address(this),
            block.timestamp
        );
    }
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract DistributionManager {
    struct AssetData {
        uint128 emissionPerSecond;
        uint128 lastUpdateTimestamp;
        uint256 index;
        mapping(address => uint256) users;
    }

    struct AssetConfigInput {
        uint128 emissionPerSecond;
        uint256 totalStaked;
    }

    struct UserStakeInput {
        uint256 stakedByUser;
        uint256 totalStaked;
    }

    /*
    ╔══════════════════════════════╗
    
    ║           VARIABLES          ║
    
    ╚══════════════════════════════╝
    */

    uint256 public distributionEnd;

    uint8 public constant PRECISION = 18;

    AssetData public assetData;

    /*
    ╔══════════════════════════════╗
    
    ║            EVENTS            ║
    
    ╚══════════════════════════════╝
    */

    event AssetConfigUpdated(uint128 emission);
    event AssetIndexUpdated(uint256 index);
    event UserIndexUpdated(address indexed user, uint256 index);

    /*
    ╔══════════════════════════════╗
    
    ║       EXTERNAL FUNCTIONS     ║
    
    ╚══════════════════════════════╝
    */

    /**
     * @param _user Address of the user
     * @return The user index
     **/
    function getUserAssetData(address _user) external view returns (uint256) {
        return assetData.users[_user];
    }

    /*
    ╔══════════════════════════════╗
    
    ║       INTERNAL FUNCTIONS     ║
    
    ╚══════════════════════════════╝
  */

    /**
     * @dev Configures the distribution of rewards for a asset
     * @param _assetConfigInput The configurations to apply
     **/
    function _configureAsset(
        AssetConfigInput memory _assetConfigInput
    ) internal {
        _updateAssetStateInternal(assetData, _assetConfigInput.totalStaked);

        assetData.emissionPerSecond = _assetConfigInput.emissionPerSecond;

        emit AssetConfigUpdated(_assetConfigInput.emissionPerSecond);
    }

    /**
     * @dev Updates the state of distribution, mainly rewards index and timestamp
     * @param _assetConfig Storage pointer to the distribution's config
     * @param _totalStaked Current total of staked asset for a distribution
     * @return The new distribution index
     **/
    function _updateAssetStateInternal(
        AssetData storage _assetConfig,
        uint256 _totalStaked
    ) internal returns (uint256) {
        uint256 oldIndex = _assetConfig.index;
        uint128 lastUpdateTimestamp = _assetConfig.lastUpdateTimestamp;

        if (block.timestamp == lastUpdateTimestamp) {
            return oldIndex;
        }

        uint256 newIndex = _getAssetIndex(
            oldIndex,
            _assetConfig.emissionPerSecond,
            lastUpdateTimestamp,
            _totalStaked
        );

        if (newIndex != oldIndex) {
            _assetConfig.index = newIndex;
            emit AssetIndexUpdated(newIndex);
        }

        _assetConfig.lastUpdateTimestamp = uint128(block.timestamp);

        return newIndex;
    }

    /**
     * @dev Updates the state of an user in a distribution
     * @param _user The user's address
     * @param _stakedByUser Amount of tokens staked by the user in the distribution at the moment
     * @param _totalStaked Total tokens staked in the distribution
     * @return The accrued rewards for the user until the moment
     **/
    function _updateUserAssetInternal(
        address _user,
        uint256 _stakedByUser,
        uint256 _totalStaked
    ) internal returns (uint256) {
        uint256 userIndex = assetData.users[_user];
        uint256 accruedRewards = 0;

        uint256 newIndex = _updateAssetStateInternal(assetData, _totalStaked);

        if (userIndex != newIndex) {
            if (_stakedByUser != 0) {
                accruedRewards = _getRewards(
                    _stakedByUser,
                    newIndex,
                    userIndex
                );
            }

            assetData.users[_user] = newIndex;
            emit UserIndexUpdated(_user, newIndex);
        }

        return accruedRewards;
    }

    /**
     * @dev Used by "frontend" stake contracts to update the data of an user when claiming rewards from there
     * @param _user The address of the user
     * @param _stakes Struct of the user data
     * @return The accrued rewards for the user until the moment
     **/
    function _claimRewards(
        address _user,
        UserStakeInput memory _stakes
    ) internal returns (uint256) {
        uint256 accruedRewards = 0;

        accruedRewards =
            accruedRewards +
            _updateUserAssetInternal(
                _user,
                _stakes.stakedByUser,
                _stakes.totalStaked
            );

        return accruedRewards;
    }

    /**
     * @dev Return the accrued rewards for an user
     * @param _user The address of the user
     * @param _stakes Struct of the user data
     * @return The accrued rewards for the user until the moment
     **/
    function _getUnclaimedRewards(
        address _user,
        UserStakeInput memory _stakes
    ) internal view returns (uint256) {
        uint256 accruedRewards = 0;

        AssetData storage assetConfig = assetData;

        uint256 assetIndex = _getAssetIndex(
            assetConfig.index,
            assetConfig.emissionPerSecond,
            assetConfig.lastUpdateTimestamp,
            _stakes.totalStaked
        );

        accruedRewards =
            accruedRewards +
            _getRewards(
                _stakes.stakedByUser,
                assetIndex,
                assetConfig.users[_user]
            );

        return accruedRewards;
    }

    /**
     * @dev Internal function for the calculation of user's rewards on a distribution
     * @param _principalUserBalance Amount staked by the user on a distribution
     * @param _reserveIndex Current index of the distribution
     * @param _userIndex Index stored for the user, representation his staking moment
     * @return The rewards
     **/
    function _getRewards(
        uint256 _principalUserBalance,
        uint256 _reserveIndex,
        uint256 _userIndex
    ) internal pure returns (uint256) {
        return
            (_principalUserBalance * (_reserveIndex - _userIndex)) /
            (10 ** uint256(PRECISION));
    }

    /**
     * @dev Calculates the next value of an specific distribution index, with validations
     * @param currentIndex Current index of the distribution
     * @param emissionPerSecond Representing the total rewards distributed per second per asset unit, on the distribution
     * @param lastUpdateTimestamp Last moment this distribution was updated
     * @param totalBalance of tokens considered for the distribution
     * @return The new index.
     **/
    function _getAssetIndex(
        uint256 currentIndex,
        uint256 emissionPerSecond,
        uint256 lastUpdateTimestamp,
        uint256 totalBalance
    ) internal view returns (uint256) {
        if (
            emissionPerSecond == 0 ||
            totalBalance == 0 ||
            lastUpdateTimestamp == block.timestamp ||
            lastUpdateTimestamp >= distributionEnd
        ) {
            return currentIndex;
        }

        uint256 currentTimestamp = block.timestamp > distributionEnd
            ? distributionEnd
            : block.timestamp;
        uint256 timeDelta = currentTimestamp - lastUpdateTimestamp;
        return
            (emissionPerSecond * (timeDelta) * (10 ** uint256(PRECISION))) /
            (totalBalance) +
            (currentIndex);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./SafeMath.sol";
import "./interfaces/IDividendPayingToken.sol";

interface IPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);
}

interface IFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IUniswapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract DividendPayingToken is ERC20, DividendPayingTokenInterface, Ownable {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    address public LP_Token;

    // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
    // For more discussion about choosing the value of `magnitude`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 internal constant magnitude = 2 ** 128;

    uint256 internal magnifiedDividendPerShare;

    // About dividendCorrection:
    // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
    // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
    //   `dividendOf(_user)` should not be changed,
    //   but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
    // To keep the `dividendOf(_user)` unchanged, we add a correction term:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
    //   where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
    //   `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
    // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public totalDividendsDistributed;
    uint256 public totalDividendsWithdrawn;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}

    function distributeLPDividends(uint256 amount) public onlyOwner {
        require(totalSupply() > 0);

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (amount).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amount);

            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function _withdrawDividendOfUser(
        address payable user
    ) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(
                _withdrawableDividend
            );
            totalDividendsWithdrawn += _withdrawableDividend;
            emit DividendWithdrawn(user, _withdrawableDividend);
            bool success = IERC20(LP_Token).transfer(
                user,
                _withdrawableDividend
            );

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(
                    _withdrawableDividend
                );
                totalDividendsWithdrawn -= _withdrawableDividend;
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner) public view override returns (uint256) {
        return withdrawableDividendOf(_owner);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(
        address _owner
    ) public view override returns (uint256) {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(
        address _owner
    ) public view override returns (uint256) {
        return withdrawnDividends[_owner];
    }

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / magnitude
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(
        address _owner
    ) public view override returns (uint256) {
        return
            magnifiedDividendPerShare
                .mul(balanceOf(_owner))
                .toInt256Safe()
                .add(magnifiedDividendCorrections[_owner])
                .toUint256Safe() / magnitude;
    }

    /// @dev Internal function that transfer tokens from one address to another.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param value The amount to be transferred.
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        int256 _magCorrection = magnifiedDividendPerShare
            .mul(value)
            .toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from]
            .add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(
            _magCorrection
        );
    }

    /// @dev Internal function that mints tokens to an account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].sub((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    /// @dev Internal function that burns an amount of the token of a given account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].add((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./DividendPayingToken.sol";

contract DividendTracker is Ownable, DividendPayingToken {
    struct AccountInfo {
        address account;
        uint256 withdrawableDividends;
        uint256 totalDividends;
        uint256 lastClaimTime;
    }

    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint256) public lastClaimTimes;

    event ExcludeFromDividends(address indexed account, bool value);
    event Claim(address indexed account, uint256 amount);

    constructor() DividendPayingToken("Dividend_Tracker", "Dividend_Tracker") {}

    function trackerRescueERC20Tokens(
        address recipient,
        address tokenAddress
    ) external onlyOwner {
        IERC20(tokenAddress).transfer(
            recipient,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function trackerRescueETH(address recipient) external onlyOwner {
        payable(recipient).transfer(address(this).balance);
    }

    function updateLP_Token(address _lpToken) external onlyOwner {
        LP_Token = _lpToken;
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "Dividend_Tracker: Transfer not allowed");
    }

    function excludeFromDividends(
        address account,
        bool value
    ) external onlyOwner {
        require(excludedFromDividends[account] != value);
        excludedFromDividends[account] = value;
        if (value == true) {
            _setBalance(account, 0);
        } else {
            _setBalance(account, balanceOf(account));
        }
        emit ExcludeFromDividends(account, value);
    }

    function getAccount(
        address account
    ) public view returns (address, uint256, uint256, uint256, uint256) {
        AccountInfo memory info;
        info.account = account;
        info.withdrawableDividends = withdrawableDividendOf(account);
        info.totalDividends = accumulativeDividendOf(account);
        info.lastClaimTime = lastClaimTimes[account];
        return (
            info.account,
            info.withdrawableDividends,
            info.totalDividends,
            info.lastClaimTime,
            totalDividendsWithdrawn
        );
    }

    function setBalance(
        address account,
        uint256 newBalance
    ) external onlyOwner {
        if (excludedFromDividends[account]) {
            return;
        }
        _setBalance(account, newBalance);
    }

    function processAccount(
        address payable account
    ) external onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount);
            return true;
        }
        return false;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

library SafeMath {
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface DividendPayingTokenInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner) external view returns (uint256);

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
    ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
    function withdrawDividend() external;

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(
        address _owner
    ) external view returns (uint256);

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(
        address _owner
    ) external view returns (uint256);

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(
        address _owner
    ) external view returns (uint256);

    /// @dev This event MUST emit when ether is distributed to token holders.
    /// @param from The address which sends ether to this contract.
    /// @param weiAmount The amount of distributed ether in wei.
    event DividendsDistributed(address indexed from, uint256 weiAmount);

    /// @dev This event MUST emit when an address withdraws their dividend.
    /// @param to The address which withdraws ether from this contract.
    /// @param weiAmount The amount of withdrawn ether in wei.
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}
pragma solidity ^0.8.0;

interface IStaking {
    function updateReward(uint256 _amount) external;

    function init(address _rewardToken, address _stakingToken) external;
}