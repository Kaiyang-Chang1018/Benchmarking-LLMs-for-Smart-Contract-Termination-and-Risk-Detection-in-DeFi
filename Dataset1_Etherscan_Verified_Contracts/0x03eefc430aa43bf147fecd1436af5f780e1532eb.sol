// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../libs/enum.sol";
import "../libs/constant.sol";

abstract contract GlobalInfo {
    //Variables
    //deployed timestamp
    uint256 private immutable i_genesisTs;

    /** @dev track current contract day */
    uint256 private s_currentContractDay;
    /** @dev shareRate starts 800 ether and increases capped at 2800 ether, uint72 has enough size */
    uint72 private s_currentshareRate;
    /** @dev mintCost starts 0.2 ether increases and capped at 1 ether, uint64 has enough size */
    uint64 private s_currentMintCost;
    /** @dev mintableLegacy starts 100 ether decreases to 0 ether, uint96 has enough size */
    uint96 private s_currentMintableLegacy;
    /** @dev mintPowerBonus starts 3_000_000 and decreases capped at 3_000, uint32 has enough size */
    uint32 private s_currentMintPowerBonus;
    /** @dev EAABonus starts 10_000_000 and decreases to 0, uint32 has enough size */
    uint32 private s_currentEAABonus;

    /** @dev track if any of the cycle day 28, 90, 369, 888 has payout triggered successfully
     * this is used in end stake where either the shares change should be tracked in current/next payout cycle
     */
    PayoutTriggered private s_isGlobalPayoutTriggered;

    /** @dev track payouts based on every cycle day 28, 90, 369, 888 when distributeETH() is called */
    mapping(uint256 => uint256) private s_cyclePayouts;

    /** @dev track payout index for each cycle day, increased by 1 when triggerPayouts() is called successfully
     *  eg. current index is 2, s_cyclePayoutIndex[DAY28] = 2 */
    mapping(uint256 => uint256) private s_cyclePayoutIndex;

    /** @dev track payout info (day and payout per share) for each cycle day
     * eg. s_cyclePayoutIndex is 2,
     *  s_CyclePayoutPerShare[DAY28][2].day = 28
     * s_CyclePayoutPerShare[DAY28][2].payoutPerShare = 0.1
     */
    mapping(uint256 => mapping(uint256 => CycleRewardPerShare)) private s_cyclePayoutPerShare;

    /** @dev track user last payout reward claim index for cycleIndex and sharesIndex
     * so calculation would start from next index instead of the first index
     * [address][DAY28].cycleIndex = 1
     * [address][DAY28].sharesIndex = 2
     * cycleIndex is the last stop in s_cyclePayoutPerShare
     * sharesIndex is the last stop in s_addressIdToActiveShares
     */
    mapping(address => mapping(uint256 => UserCycleClaimIndex))
    private s_addressCycleToLastClaimIndex;

    /** @dev track when is the next cycle payout day for each cycle day
     * eg. s_nextCyclePayoutDay[DAY28] = 28
     *     s_nextCyclePayoutDay[DAY90] = 90
     */
    mapping(uint256 => uint256) s_nextCyclePayoutDay;

    //structs
    struct CycleRewardPerShare {
        uint256 day;
        uint256 payoutPerShare;
    }

    struct UserCycleClaimIndex {
        uint96 cycleIndex;
        uint64 sharesIndex;
    }

    //event
    event GlobalDailyDifficultyClockStats(
        uint256 indexed day,
        uint256 indexed mintCost,
        uint256 indexed shareRate,
        uint256 mintableLegacy,
        uint256 mintPowerBonus,
        uint256 EAABonus
    );

    /** @dev Updates variables in terms of day, used in all external/public functions (excluding view)
     */
    modifier dailyDifficultyClock() {
        _dailyDifficultyClock();
        _;
    }

    constructor() {
        i_genesisTs = block.timestamp;
        s_currentContractDay = 1;
        s_currentMintCost = uint64(START_MAX_MINT_COST);
        s_currentMintableLegacy = uint96(START_MAX_MINTABLE_PER_DAY);
        s_currentshareRate = uint72(START_SHARE_RATE);
        s_currentMintPowerBonus = uint32(START_MINTPOWER_INCREASE_BONUS);
        s_currentEAABonus = uint32(EAA_START);
        s_nextCyclePayoutDay[DAY28] = DAY28;
        s_nextCyclePayoutDay[DAY90] = DAY90;
        s_nextCyclePayoutDay[DAY369] = DAY369;
        s_nextCyclePayoutDay[DAY888] = DAY888;
    }

    /** @dev calculate and update variables daily and reset triggers flag */
    function _dailyDifficultyClock() private {
        uint256 currentContractDay = s_currentContractDay;
        uint256 currentBlockDay = ((block.timestamp - i_genesisTs) / 1 days) + 1;

        if (currentBlockDay > currentContractDay) {
            //get last day info ready for calculation
            uint256 newMintCost = s_currentMintCost;
            uint256 newShareRate = s_currentshareRate;
            uint256 newMintableLegacy = s_currentMintableLegacy;
            uint256 newMintPowerBonus = s_currentMintPowerBonus;
            uint256 newEAABonus = s_currentEAABonus;
            uint256 dayDifference = currentBlockDay - currentContractDay;

            /** Reason for a for loop to update Mint supply
             * Ideally, user interaction happens daily, so Mint supply is synced in every day
             *      (cylceDifference = 1)
             * However, if there's no interaction for more than 1 day, then
             *      Mint supply isn't updated correctly due to cylceDifference > 1 day
             * Eg. 2 days of no interaction, then interaction happens in 3rd day.
             *     It's incorrect to only decrease the Mint supply one time as now it's in 3rd day.
             *   And if this happens, there will be no tracked data for the skipped days as not needed
             */
            for (uint256 i; i < dayDifference; i++) {
                newMintCost = (newMintCost * DAILY_MINT_COST_INCREASE_STEP) / PERCENT_BPS;
                newShareRate = (newShareRate * DAILY_SHARE_RATE_INCREASE_STEP) / PERCENT_BPS;
                newMintableLegacy =
                (newMintableLegacy * DAILY_SUPPLY_MINTABLE_REDUCTION) /
                PERCENT_BPS;
                newMintPowerBonus =
                (newMintPowerBonus * DAILY_MINTPOWER_INCREASE_BONUS_REDUCTION) /
                PERCENT_BPS;

                if (newMintCost > 1 ether) {
                    newMintCost = CAPPED_MAX_MINT_COST;
                }

                if (newShareRate > CAPPED_MAX_RATE) newShareRate = CAPPED_MAX_RATE;

                /** @dev leave Legacy production at 1 if MINIMUM_LEGACY_SUPPLY has not been met */
                if (newMintableLegacy < CAPPED_MIN_DAILY_LEGACY_MINTABLE) {
                    if (_getTotalMintedLegacy() >= MINIMUM_LEGACY_SUPPLY) {
                        newMintableLegacy = MINTABLE_LEGACY_END;
                    } else {
                        newMintableLegacy = CAPPED_MIN_DAILY_LEGACY_MINTABLE;
                    }
                }

                if (newMintPowerBonus < CAPPED_MIN_MINTPOWER_BONUS) {
                    newMintPowerBonus = CAPPED_MIN_MINTPOWER_BONUS;
                }

                if (currentBlockDay <= MAX_BONUS_DAY) {
                    newEAABonus -= EAA_BONUSE_FIXED_REDUCTION_PER_DAY;
                } else {
                    newEAABonus = EAA_END;
                }

                emit GlobalDailyDifficultyClockStats(
                    ++currentContractDay,
                    newMintCost,
                    newShareRate,
                    newMintableLegacy,
                    newMintPowerBonus,
                    newEAABonus
                );

            }

            s_currentMintCost = uint64(newMintCost);
            s_currentshareRate = uint72(newShareRate);
            s_currentMintableLegacy = uint96(newMintableLegacy);
            s_currentMintPowerBonus = uint32(newMintPowerBonus);
            s_currentEAABonus = uint32(newEAABonus);
            s_currentContractDay = currentBlockDay;
            s_isGlobalPayoutTriggered = PayoutTriggered.NO;
        }
    }

    /** @dev first created shares will start from the last payout index + 1 (next cycle payout)
     * as first shares will always disqualified from past payouts
     * reduce gas cost needed to loop from first index
     * @param user user address
     * @param isFirstShares flag to only initialize when address is fresh wallet
     */
    function _initFirstSharesCycleIndex(address user, uint256 isFirstShares) internal {
        if (isFirstShares == 1) {
            if (s_cyclePayoutIndex[DAY28] != 0) {
                s_addressCycleToLastClaimIndex[user][DAY28].cycleIndex = uint96(
                    s_cyclePayoutIndex[DAY28] + 1
                );

                s_addressCycleToLastClaimIndex[user][DAY90].cycleIndex = uint96(
                    s_cyclePayoutIndex[DAY90] + 1
                );

                s_addressCycleToLastClaimIndex[user][DAY369].cycleIndex = uint96(
                    s_cyclePayoutIndex[DAY369] + 1
                );

                s_addressCycleToLastClaimIndex[user][DAY888].cycleIndex = uint96(
                    s_cyclePayoutIndex[DAY888] + 1
                );
            }
        }
    }

    /** @dev first created shares will start from the last payout index + 1 (next cycle payout)
     * as first shares will always disqualified from past payouts
     * reduce gas cost needed to loop from first index
     * @param cycleNo cycle day 28, 90, 369, 888
     * @param reward total accumulated reward in cycle day 28, 90, 369, 888
     * @param globalActiveShares global active shares
     * @return index return latest current cycleIndex
     */
    function _calculateCycleRewardPerShare(
        uint256 cycleNo,
        uint256 reward,
        uint256 globalActiveShares
    ) internal returns (uint256 index) {
        s_cyclePayouts[cycleNo] = 0;
        index = ++s_cyclePayoutIndex[cycleNo];
        //add 18 decimals to reward for better precision in calculation
        s_cyclePayoutPerShare[cycleNo][index].payoutPerShare =
        (reward * SCALING_FACTOR_1e18) /
        globalActiveShares;
        s_cyclePayoutPerShare[cycleNo][index].day = getCurrentContractDay();
    }

    /** @dev update with the last index where a user has claimed the payout reward
     * @param user user address
     * @param cycleNo cylce day 28, 90, 369, 888
     * @param userClaimCycleIndex last claimed cycle index
     * @param userClaimSharesIndex last claimed shares index
     */
    function _updateUserClaimIndexes(
        address user,
        uint256 cycleNo,
        uint256 userClaimCycleIndex,
        uint256 userClaimSharesIndex
    ) internal {
        if (userClaimCycleIndex != s_addressCycleToLastClaimIndex[user][cycleNo].cycleIndex)
            s_addressCycleToLastClaimIndex[user][cycleNo].cycleIndex = uint96(userClaimCycleIndex);

        if (userClaimSharesIndex != s_addressCycleToLastClaimIndex[user][cycleNo].sharesIndex)
            s_addressCycleToLastClaimIndex[user][cycleNo].sharesIndex = uint64(
                userClaimSharesIndex
            );
    }

    /** @dev set to YES when any of the cycle days payout is triggered
     * reset to NO in new contract day
     */
    function _setGlobalPayoutTriggered() internal {
        s_isGlobalPayoutTriggered = PayoutTriggered.YES;
    }

    /** @dev add reward into cycle day 28, 90, 369, 888 pool
     * @param cycleNo cycle day 28, 90, 369, 888
     * @param reward reward from distributeETH()
     */
    function _setCyclePayoutPool(uint256 cycleNo, uint256 reward) internal {
        s_cyclePayouts[cycleNo] += reward;
    }

    /** @dev calculate and update the next payout day for specified cycleNo
     * the formula will update the payout day based on current contract day
     * this is to make sure the value is correct when for some reason has skipped more than one cycle payout
     * @param cycleNo cycle day 28, 90, 369, 888
     */
    function _setNextCyclePayoutDay(uint256 cycleNo) internal {
        uint256 maturityDay = s_nextCyclePayoutDay[cycleNo];
        uint256 currentContractDay = s_currentContractDay;
        if (currentContractDay >= maturityDay) {
            s_nextCyclePayoutDay[cycleNo] +=
            cycleNo *
            (((currentContractDay - maturityDay) / cycleNo) + 1);
        }
    }

    /** @dev Calls the getTotalMintedLegacy function in the MintInfo contract through Legacy
     * since GlobalInfo does not directly inherit from MintInfo so
     * _dailyDifficultyClock knows how much Legacy has been already minted
     */
    function _getTotalMintedLegacy() internal view virtual returns (uint256);

    /** Views */
    /** @notice Returns current block timestamp
     * @return currentBlockTs current block timestamp
     */
    function getCurrentBlockTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    /** @notice Returns current contract day
     * @return currentContractDay current contract day
     */
    function getCurrentContractDay() public view returns (uint256) {
        return s_currentContractDay;
    }

    /** @notice Returns current mint cost
     * @return currentMintCost current block timestamp
     */
    function getCurrentMintCost() public view returns (uint256) {
        return s_currentMintCost;
    }

    /** @notice Returns current share rate
     * @return currentShareRate current share rate
     */
    function getCurrentShareRate() public view returns (uint256) {
        return s_currentshareRate;
    }

    /** @notice Returns current mintable Legacy
     * @return currentMintableLegacy current mintable Legacy
     */
    function getCurrentMintableLegacy() public view returns (uint256) {
        return s_currentMintableLegacy;
    }

    /** @notice Returns current mint power bonus
     * @return currentMintPowerBonus current mint power bonus
     */
    function getCurrentMintPowerBonus() public view returns (uint256) {
        return s_currentMintPowerBonus;
    }

    /** @notice Returns current contract EAA bonus
     * @return currentEAABonus current EAA bonus
     */
    function getCurrentEAABonus() public view returns (uint256) {
        return s_currentEAABonus;
    }

    /** @notice Returns current cycle index for the specified cycle day
     * @param cycleNo cycle day 28, 90, 369, 888
     * @return currentCycleIndex current cycle index to track the payouts
     */
    function getCurrentCycleIndex(uint256 cycleNo) public view returns (uint256) {
        return s_cyclePayoutIndex[cycleNo];
    }

    /** @notice Returns whether payout is triggered successfully in any cylce day
     * @return isTriggered 0 or 1, 0= No, 1=Yes
     */
    function getGlobalPayoutTriggered() public view returns (PayoutTriggered) {
        return s_isGlobalPayoutTriggered;
    }

    /** @notice Returns the distributed pool reward for the specified cycle day
     * @param cycleNo cycle day 28, 90, 369, 888
     * @return currentPayoutPool current accumulated payout pool
     */
    function getCyclePayoutPool(uint256 cycleNo) public view returns (uint256) {
        return s_cyclePayouts[cycleNo];
    }

    /** @notice Returns the calculated payout per share and contract day for the specified cycle day and index
     * @param cycleNo cycle day 28, 90, 369, 888
     * @param index cycle index
     * @return payoutPerShare calculated payout per share
     * @return triggeredDay the day when payout was triggered to perform calculation
     */
    function getPayoutPerShare(
        uint256 cycleNo,
        uint256 index
    ) public view returns (uint256, uint256) {
        return (
        s_cyclePayoutPerShare[cycleNo][index].payoutPerShare,
        s_cyclePayoutPerShare[cycleNo][index].day
        );
    }

    /** @notice Returns user's last claimed shares payout indexes for the specified cycle day
     * @param user user address
     * @param cycleNo cycle day 28, 90, 369, 888
     * @return cycleIndex cycle index
     * @return sharesIndex shares index

     */
    function getUserLastClaimIndex(
        address user,
        uint256 cycleNo
    ) public view returns (uint256 cycleIndex, uint256 sharesIndex) {
        return (
        s_addressCycleToLastClaimIndex[user][cycleNo].cycleIndex,
        s_addressCycleToLastClaimIndex[user][cycleNo].sharesIndex
        );
    }

    /** @notice Returns contract deployment block timestamp
     * @return genesisTs deployed timestamp
     */
    function genesisTs() public view returns (uint256) {
        return i_genesisTs;
    }

    /** @notice Returns next payout day for the specified cycle day
     * @param cycleNo cycle day 28, 90, 369, 888
     * @return nextPayoutDay next payout day
     */
    function getNextCyclePayoutDay(uint256 cycleNo) public view returns (uint256) {
        return s_nextCyclePayoutDay[cycleNo];
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "../interfaces/ILegacyOnBurn.sol";
import "../interfaces/ILEGACY.sol";

import "../libs/calcFunctions.sol";

import "./GlobalInfo.sol";
import "./MintInfo.sol";
import "./OwnerInfo.sol";
import "./StakeInfo.sol";

//custom errors
	error Legacy_InvalidAmount();
	error Legacy_InsufficientBalance();
	error Legacy_NotSupportedContract();
	error Legacy_InsufficientProtocolFees();
	error Legacy_FailedToSendAmount();
	error Legacy_NotAllowed();
	error Legacy_NoCycleRewardToClaim();
	error Legacy_NoSharesExist();
	error Legacy_EmptyUndistributeFees();
	error Legacy_InvalidBatchCount();
	error Legacy_MaxedWalletMints();
	error Legacy_LPTokensHasMinted();
	error Legacy_InvalidAddress();
	error Legacy_MintingPhaseFinished();

/** @title Legacy */
contract Legacy is ERC20, ReentrancyGuard, GlobalInfo, MintInfo, StakeInfo, OwnerInfo {
	/** Storage Variables*/
	/** @dev stores genesis wallet address */
	address private s_genesisAddress;
	/** @dev stores buy and burn contract address */
	address private s_buyAndBurnAddress;
	/** @dev stores titanX buy and burn contract address */
	address private s_titanXbuyAndBurnAddress;
	/** @dev tracks total protocol fees sent to TitanX Buy&Burn */
	uint256 private s_totalTitanxDistributedBurnFees;
	/** @dev tracks collected protocol fees until it is distributed */
	uint88 private s_undistributedFees;
	/** @dev tracks if initial LP tokens has minted or not */
	InitialLPMinted private s_initialLPMinted;

	event ProtocolFeeReceived(address indexed user, uint256 indexed day, uint256 indexed amount);
	event ETHDistributed(address indexed caller, uint256 indexed amount);
	event CyclePayoutTriggered(
		address indexed caller,
		uint256 indexed cycleNo,
		uint256 indexed reward
	);
	event RewardClaimed(address indexed user, uint256 indexed reward);

	constructor(address genesisAddress) ERC20("Legacy", "LEGACY") {
		if (genesisAddress == address(0)) revert Legacy_InvalidAddress();
		s_genesisAddress = genesisAddress;
	}
	// all eth transfers should be added to s_undistributedFees
	receive() external payable {
		s_undistributedFees += uint88(msg.value);
		emit ProtocolFeeReceived(msg.sender, getCurrentContractDay(), msg.value);
	}

	/**** Mint Functions *****/
	/** @notice create a new mint
     * @param mintPower 1 - 100
     * @param numOfDays mint length of 1 - 280
     */
	function startMint(
		uint256 mintPower,
		uint256 numOfDays
	) external payable nonReentrant dailyDifficultyClock {
		if (getUserLatestMintId(_msgSender()) + 1 > MAX_MINT_PER_WALLET)
			revert Legacy_MaxedWalletMints();
		if (getCurrentMintableLegacy() <= MINTABLE_LEGACY_END)
			revert Legacy_MintingPhaseFinished();
		uint256 gMintPower = getGlobalMintPower() + mintPower;
		uint256 currentLRank = getGlobalLRank() + 1;
		uint256 gMinting = getTotalMinting() +
		_startMint(
			_msgSender(),
			mintPower,
			numOfDays,
			getCurrentMintableLegacy(),
			getCurrentMintPowerBonus(),
			getCurrentEAABonus(),
			gMintPower,
			currentLRank,
			getBatchMintCost(mintPower, 1, getCurrentMintCost())
		);
		_updateMintStats(currentLRank, gMintPower, gMinting);
		_protocolFees(mintPower, 1);
	}

	/** @notice create new mints in batch of up to 100 mints
     * @param mintPower 1 - 100
     * @param numOfDays mint length of 1 - 280
     * @param count 1 - 100
     */
	function batchMint(
		uint256 mintPower,
		uint256 numOfDays,
		uint256 count
	) external payable nonReentrant dailyDifficultyClock {
		if (count == 0 || count > MAX_BATCH_MINT_COUNT) revert Legacy_InvalidBatchCount();
		if (getUserLatestMintId(_msgSender()) + count > MAX_MINT_PER_WALLET)
			revert Legacy_MaxedWalletMints();
		if (getCurrentMintableLegacy() <= MINTABLE_LEGACY_END)
			revert Legacy_MintingPhaseFinished();

		_startBatchMint(
			_msgSender(),
			mintPower,
			numOfDays,
			getCurrentMintableLegacy(),
			getCurrentMintPowerBonus(),
			getCurrentEAABonus(),
			count,
			getBatchMintCost(mintPower, 1, getCurrentMintCost()) //only need 1 mint cost for all mints
		);
		_protocolFees(mintPower, count);
	}

	/** @notice claim a matured mint
     * @param id mint id
     */
	function claimMint(uint256 id) external dailyDifficultyClock nonReentrant {
		_mintReward(_claimMint(_msgSender(), id, MintAction.CLAIM));
	}

	/** @notice batch claim matured mint of up to 100 claims per run
     */
	function batchClaimMint() external dailyDifficultyClock nonReentrant {
		_mintReward(_batchClaimMint(_msgSender()));
	}

	/**** Stake Functions *****/
	/** @notice start a new stake
     * @param amount Legacy amount
     * @param numOfDays stake length
     */
	function startStake(uint256 amount, uint256 numOfDays) external dailyDifficultyClock nonReentrant {
		if (balanceOf(_msgSender()) < amount) revert Legacy_InsufficientBalance();

		_burn(_msgSender(), amount);
		_initFirstSharesCycleIndex(
			_msgSender(),
			_startStake(
				_msgSender(),
				amount,
				numOfDays,
				getCurrentShareRate(),
				getCurrentContractDay(),
				getGlobalPayoutTriggered()
			)
		);
	}

	/** @notice end a stake
     * @param id stake id
     */
	function endStake(uint256 id) external dailyDifficultyClock nonReentrant {
		_mint(
			_msgSender(),
			_endStake(
				_msgSender(),
				id,
				getCurrentContractDay(),
				StakeAction.END,
				getGlobalPayoutTriggered()
			)
		);
	}

	/** @notice distribute the collected protocol fees into different pools/payouts
     * automatically send the incentive fee to caller, buyAndBurnFunds to BuyAndBurn contract,
     * titanXbuyAndBurnFunds to TitanX BuyAndBurn contract, and genesis wallet
     */
	function distributeETH() external dailyDifficultyClock nonReentrant {
		(uint256 incentiveFee, uint256 buyAndBurnFunds, uint256 titanXbuyAndBurnFunds, uint256 genesisWallet) = _distributeETH();
		_sendFunds(incentiveFee, buyAndBurnFunds, titanXbuyAndBurnFunds, genesisWallet);
	}

	/** @notice trigger cycle payouts for day 28, 90, 369, 888
     * As long as the cycle has met its maturity day (eg. Cycle28 is day 28), payout can be triggered in any day onwards
     */
	function triggerPayouts() external dailyDifficultyClock nonReentrant {
		uint256 globalActiveShares = getGlobalShares() - getGlobalExpiredShares();
		if (globalActiveShares < 1) revert Legacy_NoSharesExist();

		uint256 incentiveFee;
		uint256 buyAndBurnFunds;
		uint256 titanXbuyAndBurnFunds;
		uint256 genesisWallet;
		if (s_undistributedFees != 0)
			(incentiveFee, buyAndBurnFunds, titanXbuyAndBurnFunds, genesisWallet) = _distributeETH();

		uint256 currentContractDay = getCurrentContractDay();
		PayoutTriggered isTriggered = PayoutTriggered.NO;
		_triggerCyclePayout(DAY28, globalActiveShares, currentContractDay) == PayoutTriggered.YES &&
		isTriggered == PayoutTriggered.NO
		? isTriggered = PayoutTriggered.YES
		: isTriggered;
		_triggerCyclePayout(DAY90, globalActiveShares, currentContractDay) == PayoutTriggered.YES &&
		isTriggered == PayoutTriggered.NO
		? isTriggered = PayoutTriggered.YES
		: isTriggered;
		_triggerCyclePayout(DAY369, globalActiveShares, currentContractDay) ==
		PayoutTriggered.YES &&
		isTriggered == PayoutTriggered.NO
		? isTriggered = PayoutTriggered.YES
		: isTriggered;
		_triggerCyclePayout(DAY888, globalActiveShares, currentContractDay) ==
		PayoutTriggered.YES &&
		isTriggered == PayoutTriggered.NO
		? isTriggered = PayoutTriggered.YES
		: isTriggered;

		if (isTriggered == PayoutTriggered.YES) {
			if (getGlobalPayoutTriggered() == PayoutTriggered.NO) _setGlobalPayoutTriggered();
		}

		if (incentiveFee != 0) _sendFunds(incentiveFee, buyAndBurnFunds, titanXbuyAndBurnFunds, genesisWallet);
	}

	/** @notice claim all user available ETH payouts in one call */
	function claimUserAvailableETHPayouts() external dailyDifficultyClock nonReentrant {
		uint256 reward = _claimCyclePayout(DAY28, PayoutClaim.SHARES);
		reward += _claimCyclePayout(DAY90, PayoutClaim.SHARES);
		reward += _claimCyclePayout(DAY369, PayoutClaim.SHARES);
		reward += _claimCyclePayout(DAY888, PayoutClaim.SHARES);

		if (reward == 0) revert Legacy_NoCycleRewardToClaim();
		_sendViaCall(payable(_msgSender()), reward);
		emit RewardClaimed(_msgSender(), reward);
	}

	/** @notice Set BuyAndBurn Contract Address - able to change to new contract that supports UniswapV4+
     * Only owner can call this function
     * @param contractAddress BuyAndBurn contract address
     */
	function setBuyAndBurnContractAddress(address contractAddress) external onlyOwner {
		if (contractAddress == address(0)) revert Legacy_InvalidAddress();
		s_buyAndBurnAddress = contractAddress;
	}

	/** @notice Set TitanX BuyAndBurn Contract Address
     * Only owner can call this function
     * @param contractAddress TitanX BuyAndBurn contract address
     */
	function setTitanXBuyAndBurnContractAddress(address contractAddress) external onlyOwner {
		if (contractAddress == address(0)) revert Legacy_InvalidAddress();
		s_titanXbuyAndBurnAddress = contractAddress;
	}

	/** @notice Set to new genesis wallet. Only genesis wallet can call this function
     * @param newAddress new genesis wallet address
     */
	function setNewGenesisAddress(address newAddress) external {
		if (_msgSender() != s_genesisAddress) revert Legacy_NotAllowed();
		if (newAddress == address(0)) revert Legacy_InvalidAddress();
		s_genesisAddress = newAddress;
	}

	/** @notice mint initial LP tokens. Only BuyAndBurn contract set by genesis wallet can call this function
     */
	function mintLPTokens() external {
		if (_msgSender() != s_buyAndBurnAddress) revert Legacy_NotAllowed();
		if (s_initialLPMinted == InitialLPMinted.YES) revert Legacy_LPTokensHasMinted();
		s_initialLPMinted = InitialLPMinted.YES;
		_mint(s_buyAndBurnAddress, INITAL_LP_TOKENS);
	}

	/** @notice burn all BuyAndBurn contract Legacy */
	function burnLPTokens() external dailyDifficultyClock {
		_burn(s_buyAndBurnAddress, balanceOf(s_buyAndBurnAddress));
	}

	//private functions
	/** @dev mint reward to user and 5% to genesis wallet
     * @param reward Legacy amount
     */
	function _mintReward(uint256 reward) private {
		_mint(_msgSender(), reward);
		_mint(s_genesisAddress, (reward * 500) / PERCENT_BPS);
	}

	/** @dev send native currency to respective parties
     * @param incentiveFee fees for caller to run distributeETH()
     * @param buyAndBurnFunds funds for buy and burn
     * @param titanXbuyAndBurnFunds funds for buy and burn of TitanX protocol
     * @param genesisWalletFunds funds for genesis wallet
     */
	function _sendFunds(
		uint256 incentiveFee,
		uint256 buyAndBurnFunds,
		uint256 titanXbuyAndBurnFunds,
		uint256 genesisWalletFunds
	) private {
		_sendViaCall(payable(_msgSender()), incentiveFee);
		_sendViaCall(payable(s_genesisAddress), genesisWalletFunds);
		if (getCurrentMintableLegacy() > MINTABLE_LEGACY_END) {
			_sendViaCall(payable(s_buyAndBurnAddress), buyAndBurnFunds);
			// Tracks Fees sent to TitanX Buy & Burn
			s_totalTitanxDistributedBurnFees += titanXbuyAndBurnFunds;
			_sendViaCall(payable(s_titanXbuyAndBurnAddress), titanXbuyAndBurnFunds);
		}
	}

	/** @dev calculation to distribute collected protocol fees into different pools/parties */
	function _distributeETH()
	private
	returns (uint256 incentiveFee, uint256 buyAndBurnFunds, uint256 titanXbuyAndBurnFunds, uint256 genesisWallet)
	{
		uint256 accumulatedFees = s_undistributedFees;
		if (accumulatedFees == 0) revert Legacy_EmptyUndistributeFees();
		s_undistributedFees = 0;
		emit ETHDistributed(_msgSender(), accumulatedFees);

		incentiveFee = (accumulatedFees * INCENTIVE_FEE_PERCENT) / INCENTIVE_FEE_PERCENT_BASE; //0.66%
		accumulatedFees -= incentiveFee;

		// we should not be calculating burning fees when builder phase is over
		buyAndBurnFunds = 0;
		titanXbuyAndBurnFunds = 0;
		// accumulate burn funds during builder phase
		if (getCurrentMintableLegacy() > MINTABLE_LEGACY_END) {
			buyAndBurnFunds = (accumulatedFees * PERCENT_TO_BUY_AND_BURN) / PERCENT_BPS;
			titanXbuyAndBurnFunds = (accumulatedFees * TITANX_PERCENT_TO_BUY_AND_BURN) / PERCENT_BPS;
		}

		genesisWallet = (accumulatedFees * PERCENT_TO_GENESIS) / PERCENT_BPS;
		uint256 cycleRewardPool = accumulatedFees -
		buyAndBurnFunds - titanXbuyAndBurnFunds -
		genesisWallet;

		//cycle payout
		if (cycleRewardPool != 0) {
			uint256 cycle28Reward = (cycleRewardPool * CYCLE_28_PERCENT) / PERCENT_BPS;
			uint256 cycle90Reward = (cycleRewardPool * CYCLE_90_PERCENT) / PERCENT_BPS;
			uint256 cycle369Reward = (cycleRewardPool * CYCLE_369_PERCENT) / PERCENT_BPS;
			_setCyclePayoutPool(DAY28, cycle28Reward);
			_setCyclePayoutPool(DAY90, cycle90Reward);
			_setCyclePayoutPool(DAY369, cycle369Reward);
			_setCyclePayoutPool(
				DAY888,
				cycleRewardPool - cycle28Reward - cycle90Reward - cycle369Reward
			);
		}
	}

	/** @dev calculate required protocol fees, and return the balance (if any)
     * @param mintPower mint power 1-100
     * @param count how many mints
     */
	function _protocolFees(uint256 mintPower, uint256 count) private {
		uint256 protocolFee;

		protocolFee = getBatchMintCost(mintPower, count, getCurrentMintCost());
		if (msg.value < protocolFee) revert Legacy_InsufficientProtocolFees();

		uint256 feeBalance;
		s_undistributedFees += uint88(protocolFee);
		feeBalance = msg.value - protocolFee;

		if (feeBalance != 0) {
			_sendViaCall(payable(_msgSender()), feeBalance);
		}

		emit ProtocolFeeReceived(_msgSender(), getCurrentContractDay(), protocolFee);
	}

	/** @dev calculate payouts for each cycle day tracked by cycle index
     * @param cycleNo cycle day 28, 90, 369, 888
     * @param currentContractDay current contract day
     * @return triggered is payout triggered successfully
     */
	function _triggerCyclePayout(
		uint256 cycleNo,
		uint256 globalActiveShares,
		uint256 currentContractDay
	) private returns (PayoutTriggered triggered) {
		//check against cycle payout maturity day
		if (currentContractDay < getNextCyclePayoutDay(cycleNo)) return PayoutTriggered.NO;

		//update the next cycle payout day regardless of payout triggered successfully or not
		_setNextCyclePayoutDay(cycleNo);

		uint256 reward = getCyclePayoutPool(cycleNo);
		if (reward == 0) return PayoutTriggered.NO;

		//calculate cycle reward per share
		_calculateCycleRewardPerShare(cycleNo, reward, globalActiveShares);

		emit CyclePayoutTriggered(_msgSender(), cycleNo, reward);

		return PayoutTriggered.YES;
	}

	/** @dev calculate user reward with specified cycle day and claim type (shares) and update user's last claim cycle index
     * @param cycleNo cycle day 8, 28, 90, 369, 888
     * @param payoutClaim claim type - (Shares=0)
     */
	function _claimCyclePayout(uint256 cycleNo, PayoutClaim payoutClaim) private returns (uint256) {
		(
		uint256 reward,
		uint256 userClaimCycleIndex,
		uint256 userClaimSharesIndex
		) = _calculateUserCycleReward(_msgSender(), cycleNo, payoutClaim);

		if (payoutClaim == PayoutClaim.SHARES)
			_updateUserClaimIndexes(
				_msgSender(),
				cycleNo,
				userClaimCycleIndex,
				userClaimSharesIndex
			);

		return reward;
	}

	/** @dev Recommended method to use to send native coins.
     * @param to receiving address.
     * @param amount in wei.
     */
	function _sendViaCall(address payable to, uint256 amount) private {
		if (to == address(0)) revert Legacy_InvalidAddress();
		(bool sent, ) = to.call{value: amount}("");
		if (!sent) revert Legacy_FailedToSendAmount();
	}

	//Views
	/** @dev calculate user payout reward with specified cycle day and claim type (shares).
     * it loops through all the unclaimed cycle index until the latest cycle index
     * @param user user address
     * @param cycleNo cycle day 28, 90, 369, 888
     * @param payoutClaim claim type (Shares=0)
     * @return rewards calculated reward
     * @return userClaimCycleIndex last claim cycle index
     * @return userClaimSharesIndex last claim shares index
     */
	function _calculateUserCycleReward(
		address user,
		uint256 cycleNo,
		PayoutClaim payoutClaim
	)
	private
	view
	returns (
		uint256 rewards,
		uint256 userClaimCycleIndex,
		uint256 userClaimSharesIndex
	)
	{
		uint256 cycleMaxIndex = getCurrentCycleIndex(cycleNo);

		if (payoutClaim == PayoutClaim.SHARES) {
			(userClaimCycleIndex, userClaimSharesIndex) = getUserLastClaimIndex(user, cycleNo);
			uint256 sharesMaxIndex = getUserLatestShareIndex(user);

			for (uint256 i = userClaimCycleIndex; i <= cycleMaxIndex; i++) {
				(uint256 payoutPerShare, uint256 payoutDay) = getPayoutPerShare(cycleNo, i);
				uint256 shares;

				//loop shares indexes to find the last updated shares before/same triggered payout day
				for (uint256 j = userClaimSharesIndex; j <= sharesMaxIndex; j++) {
					if (getUserActiveSharesDay(user, j) <= payoutDay)
						shares = getUserActiveShares(user, j);
					else break;

					userClaimSharesIndex = j;
				}

				if (payoutPerShare != 0 && shares != 0) {
					//reward has 18 decimals scaling, so here divide by 1e18
					rewards += (shares * payoutPerShare) / SCALING_FACTOR_1e18;
				}

				userClaimCycleIndex = i + 1;
			}
		}
	}

	/** @notice get contract ETH balance
     * @return balance eth balance
     */
	function getBalance() public view returns (uint256) {
		return address(this).balance;
	}

	/** @notice get total fees sent to TitanX Buy & Burn
     * @return amount native currency amount
     */
	function getTitanxDistributedBurnFees() public view returns (uint256) {
		return s_totalTitanxDistributedBurnFees;
	}

	/** @notice get undistributed Fees balance
     * @return amount native currency amount
     */
	function getUndistributedEth() public view returns (uint256) {
		return s_undistributedFees;
	}

	/** @notice get user ETH payout for all cycles
     * @param user user address
     * @return reward total reward
     */
	function getUserETHClaimableTotal(address user) public view returns (uint256 reward) {
		uint256 _reward;
		(_reward, , ) = _calculateUserCycleReward(user, DAY28, PayoutClaim.SHARES);
		reward += _reward;
		(_reward, , ) = _calculateUserCycleReward(user, DAY90, PayoutClaim.SHARES);
		reward += _reward;
		(_reward, , ) = _calculateUserCycleReward(user, DAY369, PayoutClaim.SHARES);
		reward += _reward;
		(_reward, , ) = _calculateUserCycleReward(user, DAY888, PayoutClaim.SHARES);
		reward += _reward;
	}

	/** @notice get total penalties from mint and stake
     * @return amount total penalties
     */
	function getTotalPenalties() public view returns (uint256) {
		return getTotalMintPenalty() + getTotalStakePenalty();
	}

	/** @notice Public function to return the total minted legacy from MintInfo
     * @return total amount of Legacy minted
     */
	function getTotalLegacyRewardsMinted() public view returns (uint256) {
		return getTotalMintedLegacy();
	}


	/** @notice Return the total minted legacy from MintInfo
     * @return total amount of Legacy minted
     */
	function _getTotalMintedLegacy() internal view override returns (uint256) {
		return getTotalMintedLegacy();
	}

	//Public function for updating difficulty clock
	/** @notice allow anyone to sync dailyDifficultyClock manually */
	function manualDailyDifficultyClock() public dailyDifficultyClock {}

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../libs/calcFunctions.sol";

//custom errors
    error Legacy_InvalidMintLength();
    error Legacy_InvalidMintPower();
    error Legacy_NoMintExists();
    error Legacy_MintHasClaimed();
    error Legacy_MintNotMature();

abstract contract MintInfo {
    //variables
    /** @dev track global legacyRank */
    uint256 private s_globalLRank;
    /** @dev track total mint claimed */
    uint256 private s_globalMintClaim;
    /** @dev track total Legacy rewards minted */
    uint256 private s_totalMintedLegacy;
    /** @dev track total Legacy minting */
    uint256 private s_globalLegacyMinting;
    /** @dev track total Legacy penalty */
    uint256 private s_globalLegacyMintPenalty;
    /** @dev track global mint power */
    uint256 private s_globalMintPower;

    //mappings
    /** @dev track address => mintId */
    mapping(address => uint256) private s_addressMId;
    /** @dev track address, mintId => lRank info (gLrank, gMintPower) */
    mapping(address => mapping(uint256 => LRankInfo)) private s_addressMIdToLRankInfo;
    /** @dev track global lRank => mintInfo*/
    mapping(uint256 => UserMintInfo) private s_lRankToMintInfo;

    //structs
    struct UserMintInfo {
        uint8 mintPower;
        uint16 numOfDays;
        uint96 mintableLegacy;
        uint48 mintStartTs;
        uint48 maturityTs;
        uint32 mintPowerBonus;
        uint32 EAABonus;
        uint128 mintedLegacy;
        uint64 mintCost;
        MintStatus status;
    }

    struct LRankInfo {
        uint256 lRank;
        uint256 gMintPower;
    }

    struct UserMint {
        uint256 mId;
        uint256 lRank;
        uint256 gMintPower;
        UserMintInfo mintInfo;
    }

    //events
    event MintStarted(
        address indexed user,
        uint256 indexed lRank,
        uint256 indexed gMintpower,
        UserMintInfo userMintInfo
    );

    event MintClaimed(
        address indexed user,
        uint256 indexed lRank,
        uint256 rewardMinted,
        uint256 indexed penalty,
        uint256 mintPenalty
    );

    //functions
    /** @dev create a new builder
     * @param user user address
     * @param mintPower mint power
     * @param numOfDays mint lenght
     * @param mintableLegacy mintable Legacy
     * @param mintPowerBonus mint power bonus
     * @param EAABonus EAA bonus
     * @param gMintPower global mint power
     * @param currentLRank current global lRank
     * @param mintCost actual mint cost paid for a mint
     */
    function _startMint(
        address user,
        uint256 mintPower,
        uint256 numOfDays,
        uint256 mintableLegacy,
        uint256 mintPowerBonus,
        uint256 EAABonus,
        uint256 gMintPower,
        uint256 currentLRank,
        uint256 mintCost
    ) internal returns (uint256 mintable) {
        if (numOfDays == 0 || numOfDays > MAX_MINT_LENGTH) revert Legacy_InvalidMintLength();
        if (mintPower == 0 || mintPower > MAX_MINT_POWER_CAP) revert Legacy_InvalidMintPower();

        //calculate builder reward up front with the provided params
        mintable = calculateMintReward(mintPower, numOfDays, mintableLegacy, EAABonus);

        //store variables into mint info
        UserMintInfo memory userMintInfo = UserMintInfo({
            mintPower: uint8(mintPower),
            numOfDays: uint16(numOfDays),
            mintableLegacy: uint96(mintable),
            mintPowerBonus: uint32(mintPowerBonus),
            EAABonus: uint32(EAABonus),
            mintStartTs: uint48(block.timestamp),
            maturityTs: uint48(block.timestamp + (numOfDays * SECONDS_IN_DAY)),
            mintedLegacy: 0,
            mintCost: uint64(mintCost),
            status: MintStatus.ACTIVE
        });

        /** s_addressMId[user] tracks mintId for each addrress
         * s_addressMIdToLRankInfo[user][id] tracks current mint lRank and gPowerMint
         *  s_lRankToMintInfo[currentLRank] stores mint info
         */
        uint256 id = ++s_addressMId[user];
        s_addressMIdToLRankInfo[user][id].lRank = currentLRank;
        s_addressMIdToLRankInfo[user][id].gMintPower = gMintPower;
        s_lRankToMintInfo[currentLRank] = userMintInfo;

        emit MintStarted(user, currentLRank, gMintPower, userMintInfo);
    }

    /** @dev create new mint in a batch of up to max 100 mints with the same mint length
     * @param user user address
     * @param mintPower mint power
     * @param numOfDays mint lenght
     * @param mintableLegacy mintable Legacy
     * @param mintPowerBonus mint power bonus
     * @param EAABonus EAA bonus
     * @param count count of mints
     * @param mintCost actual mint cost paid for a mint
     */
    function _startBatchMint(
        address user,
        uint256 mintPower,
        uint256 numOfDays,
        uint256 mintableLegacy,
        uint256 mintPowerBonus,
        uint256 EAABonus,
        uint256 count,
        uint256 mintCost
    ) internal {
        uint256 gMintPower = s_globalMintPower;
        uint256 currentLRank = s_globalLRank;
        uint256 gMinting = s_globalLegacyMinting;

        for (uint256 i = 0; i < count; i++) {
            gMintPower += mintPower;
            gMinting += _startMint(
                user,
                mintPower,
                numOfDays,
                mintableLegacy,
                mintPowerBonus,
                EAABonus,
                gMintPower,
                ++currentLRank,
                mintCost
            );
        }
        _updateMintStats(currentLRank, gMintPower, gMinting);
    }

    /** @dev update variables
     * @param currentLRank current lRank
     * @param gMintPower current global mint power
     * @param gMinting current global minting
     */
    function _updateMintStats(uint256 currentLRank, uint256 gMintPower, uint256 gMinting) internal {
        s_globalLRank = currentLRank;
        s_globalMintPower = gMintPower;
        s_globalLegacyMinting = gMinting;
    }

    /** @dev calculate reward for claim mint.
     * Claim mint has maturity check
     * @param user user address
     * @param id mint id
     * @param action claim mint
     * @return reward calculated final reward after all bonuses and penalty (if any)
     */
    function _claimMint(
        address user,
        uint256 id,
        MintAction action
    ) internal returns (uint256 reward) {
        uint256 lRank = s_addressMIdToLRankInfo[user][id].lRank;
        uint256 gMintPower = s_addressMIdToLRankInfo[user][id].gMintPower;
        if (lRank == 0) revert Legacy_NoMintExists();

        UserMintInfo memory mint = s_lRankToMintInfo[lRank];
        if (mint.status == MintStatus.CLAIMED) revert Legacy_MintHasClaimed();

        //Only check maturity for claim mint action
        if (mint.maturityTs > block.timestamp && action == MintAction.CLAIM)
            revert Legacy_MintNotMature();

        s_globalLegacyMinting -= mint.mintableLegacy;
        s_totalMintedLegacy += mint.mintableLegacy;
        reward = _calculateClaimReward(user, lRank, gMintPower, mint, action);
    }

    /** @dev calculate reward up to 100 claims for batch claim function. Only calculate active and matured mints.
     * @param user user address
     * @return reward total batch claims final calculated reward after all bonuses and penalty (if any)
     */
    function _batchClaimMint(address user) internal returns (uint256 reward) {
        uint256 maxId = s_addressMId[user];
        uint256 claimCount;
        uint256 lRank;
        uint256 gMinting;
        UserMintInfo memory mint;

        for (uint256 i = 1; i <= maxId; i++) {
            lRank = s_addressMIdToLRankInfo[user][i].lRank;
            mint = s_lRankToMintInfo[lRank];
            if (mint.status == MintStatus.ACTIVE && block.timestamp >= mint.maturityTs) {
                reward += _calculateClaimReward(
                    user,
                    lRank,
                    s_addressMIdToLRankInfo[user][i].gMintPower,
                    mint,
                    MintAction.CLAIM
                );

                gMinting += mint.mintableLegacy;
                ++claimCount;
            }

            if (claimCount == 100) break;
        }

        s_globalLegacyMinting -= gMinting;
        s_totalMintedLegacy += gMinting;
    }

    /** @dev calculate final reward with bonuses and penalty (if any)
     * @param user user address
     * @param lRank builder's lRank
     * @param gMintPower mint's gMintPower
     * @param userMintInfo mint's info
     * @param action claim mint
     * @return reward calculated final reward after all bonuses and penalty (if any)
     */
    function _calculateClaimReward(
        address user,
        uint256 lRank,
        uint256 gMintPower,
        UserMintInfo memory userMintInfo,
        MintAction action
    ) private returns (uint256 reward) {
        if (action == MintAction.CLAIM) s_lRankToMintInfo[lRank].status = MintStatus.CLAIMED;

        uint256 penaltyAmount;
        uint256 penalty;
        uint256 bonus;

        //only calculate penalty when current block timestamp > maturity timestamp
        if (block.timestamp > userMintInfo.maturityTs) {
            penalty = calculateClaimMintPenalty(block.timestamp - userMintInfo.maturityTs);
        }

        //Only Claim action has mintPower bonus
        if (action == MintAction.CLAIM) {
            bonus = calculateMintPowerBonus(
                userMintInfo.mintPowerBonus,
                userMintInfo.mintPower,
                gMintPower,
                s_globalMintPower
            );
        }

        //mintPowerBonus has scaling factor of 1e6, so divide by 1e6
        reward = uint256(userMintInfo.mintableLegacy) + (bonus / SCALING_FACTOR_1e6);
        penaltyAmount = (reward * penalty) / 100;
        reward -= penaltyAmount;

        if (action == MintAction.CLAIM) ++s_globalMintClaim;
        if (penaltyAmount != 0) s_globalLegacyMintPenalty += penaltyAmount;

        //only stored minted amount for claim mint
        if (action == MintAction.CLAIM) s_lRankToMintInfo[lRank].mintedLegacy = uint128(reward);

        emit MintClaimed(user, lRank, reward, penalty, penaltyAmount);
    }

    //views
    /** @notice Returns the latest Mint Id of an address
     * @param user address
     * @return mId latest mint id
     */
    function getUserLatestMintId(address user) public view returns (uint256) {
        return s_addressMId[user];
    }

    /** @notice Returns mint info of an address + mint id
     * @param user address
     * @param id mint id
     * @return mintInfo user mint info
     */
    function getUserMintInfo(
        address user,
        uint256 id
    ) public view returns (UserMintInfo memory mintInfo) {
        return s_lRankToMintInfo[s_addressMIdToLRankInfo[user][id].lRank];
    }

    /** @notice Return all mints info of an address
     * @param user address
     * @return mintInfos all mints info of an address including mint id, lRank and gMintPower
     */
    function getUserMints(address user) public view returns (UserMint[] memory mintInfos) {
        uint256 count = s_addressMId[user];
        mintInfos = new UserMint[](count);

        for (uint256 i = 1; i <= count; i++) {
            mintInfos[i - 1] = UserMint({
                mId: i,
                lRank: s_addressMIdToLRankInfo[user][i].lRank,
                gMintPower: s_addressMIdToLRankInfo[user][i].gMintPower,
                mintInfo: getUserMintInfo(user, i)
            });
        }
    }

    /** @notice Return current global legacyRank
     * @return globalLRank global lRank
     */
    function getGlobalLRank() public view returns (uint256) {
        return s_globalLRank;
    }

    /** @notice Return current gobal mint power
     * @return globalMintPower global mint power
     */
    function getGlobalMintPower() public view returns (uint256) {
        return s_globalMintPower;
    }

    /** @notice Return total mints claimed
     * @return totalMintClaimed total mints claimed
     */
    function getTotalMintClaim() public view returns (uint256) {
        return s_globalMintClaim;
    }

    /** @notice Return total minted Legacy
     * @return s_totalMintedLegacy total minted Legacy
     */
    function getTotalMintedLegacy() public view returns (uint256) {
        return s_totalMintedLegacy;
    }

    /** @notice Return total active mints (exluded claimed mints)
     * @return totalActiveMints total active mints
     */
    function getTotalActiveMints() public view returns (uint256) {
        return s_globalLRank - s_globalMintClaim;
    }

    /** @notice Return total minting Legacy
     * @return totalMinting total minting Legacy
     */
    function getTotalMinting() public view returns (uint256) {
        return s_globalLegacyMinting;
    }

    /** @notice Return total Legacy penalty
     * @return totalLegacyPenalty total Legacy penalty
     */
    function getTotalMintPenalty() public view returns (uint256) {
        return s_globalLegacyMintPenalty;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Context.sol";

    error Legacy_NotOnwer();

abstract contract OwnerInfo is Context {
    address private s_owner;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        s_owner = _msgSender();
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (s_owner != _msgSender()) revert Legacy_NotOnwer();
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        s_owner = newOwner;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../libs/calcFunctions.sol";

//custom errors
    error Legacy_InvalidStakeLength();
    error Legacy_RequireOneMinimumShare();
    error Legacy_ExceedMaxAmountPerStake();
    error Legacy_NoStakeExists();
    error Legacy_StakeHasEnded();
    error Legacy_StakeNotMatured();
    error Legacy_MaxedWalletStakes();

abstract contract StakeInfo {
    //Variables
    /** @dev track global stake Id */
    uint256 private s_globalStakeId;
    /** @dev track global shares */
    uint256 private s_globalShares;
    /** @dev track global expired shares */
    uint256 private s_globalExpiredShares;
    /** @dev track global staked Legacy */
    uint256 private s_globalLegacyStaked;
    /** @dev track global end stake penalty */
    uint256 private s_globalStakePenalty;
    /** @dev track global ended stake */
    uint256 private s_globalStakeEnd;

    //mappings
    /** @dev track address => stakeId */
    mapping(address => uint256) private s_addressSId;
    /** @dev track address, stakeId => global stake Id */
    mapping(address => mapping(uint256 => uint256)) private s_addressSIdToGlobalStakeId;
    /** @dev track global stake Id => stake info */
    mapping(uint256 => UserStakeInfo) private s_globalStakeIdToStakeInfo;

    /** @dev track address => shares Index */
    mapping(address => uint256) private s_userSharesIndex;
    /** @dev track user total active shares by user shares index
     * s_addressIdToActiveShares[user][index] = UserActiveShares (contract day, total user active shares)
     * works like a snapshot or log when user shares has changed (increase/decrease)
     */
    mapping(address => mapping(uint256 => UserActiveShares)) private s_addressIdToActiveShares;

    //structs
    struct UserStakeInfo {
        uint152 legacyAmount;
        uint128 shares;
        uint16 numOfDays;
        uint48 stakeStartTs;
        uint48 maturityTs;
        StakeStatus status;
    }

    struct UserStake {
        uint256 sId;
        uint256 globalStakeId;
        UserStakeInfo stakeInfo;
    }

    struct UserActiveShares {
        uint256 day;
        uint256 activeShares;
    }

    //events
    event StakeStarted(
        address indexed user,
        uint256 indexed globalStakeId,
        uint256 numOfDays,
        UserStakeInfo indexed userStakeInfo
    );

    event StakeEnded(
        address indexed user,
        uint256 indexed globalStakeId,
        uint256 legacyAmount,
        uint256 indexed penalty,
        uint256 penaltyAmount
    );

    //functions
    /** @dev create a new stake
     * @param user user address
     * @param amount Legacy amount
     * @param numOfDays stake length
     * @param shareRate current share rate
     * @param day current contract day
     * @param isPayoutTriggered has global payout triggered
     * @return isFirstShares first created shares or not
     */
    function _startStake(
        address user,
        uint256 amount,
        uint256 numOfDays,
        uint256 shareRate,
        uint256 day,
        PayoutTriggered isPayoutTriggered
    ) internal returns (uint256 isFirstShares) {
        uint256 sId = ++s_addressSId[user];
        if (sId > MAX_STAKE_PER_WALLET) revert Legacy_MaxedWalletStakes();
        if (numOfDays < MIN_STAKE_LENGTH || numOfDays > MAX_STAKE_LENGTH)
            revert Legacy_InvalidStakeLength();

        //calculate shares
        uint256 shares = calculateShares(amount, numOfDays, shareRate);

        if (shares / SCALING_FACTOR_1e18 < 1) revert Legacy_RequireOneMinimumShare();

        uint256 currentGStakeId = ++s_globalStakeId;
        uint256 maturityTs;

        maturityTs = block.timestamp + (numOfDays * SECONDS_IN_DAY);

        UserStakeInfo memory userStakeInfo = UserStakeInfo({
            legacyAmount: uint152(amount),
            shares: uint128(shares),
            numOfDays: uint16(numOfDays),
            stakeStartTs: uint48(block.timestamp),
            maturityTs: uint48(maturityTs),
            status: StakeStatus.ACTIVE
        });

        /** s_addressSId[user] tracks stake Id for each address
         * s_addressSIdToGlobalStakeId[user][id] tracks stack id to global stake Id
         * s_globalStakeIdToStakeInfo[currentGStakeId] stores stake info
         */
        s_addressSIdToGlobalStakeId[user][sId] = currentGStakeId;
        s_globalStakeIdToStakeInfo[currentGStakeId] = userStakeInfo;

        //update shares changes
        isFirstShares = _updateSharesStats(
            user,
            shares,
            amount,
            day,
            isPayoutTriggered,
            StakeAction.START
        );

        emit StakeStarted(user, currentGStakeId, numOfDays, userStakeInfo);
    }

    /** @dev end stake and calculate principle with penalties (if any)
     * @param user user address
     * @param id stake Id
     * @param day current contract day
     * @param action end stake
     * @param isPayoutTriggered has global payout triggered
     * @return legacy principle
     */
    function _endStake(
        address user,
        uint256 id,
        uint256 day,
        StakeAction action,
        PayoutTriggered isPayoutTriggered
    ) internal returns (uint256 legacy) {
        uint256 globalStakeId = s_addressSIdToGlobalStakeId[user][id];
        if (globalStakeId == 0) revert Legacy_NoStakeExists();

        UserStakeInfo memory userStakeInfo = s_globalStakeIdToStakeInfo[globalStakeId];
        if (userStakeInfo.status == StakeStatus.ENDED) revert Legacy_StakeHasEnded();

        //update shares changes
        uint256 shares = userStakeInfo.shares;
        _updateSharesStats(user, shares, userStakeInfo.legacyAmount, day, isPayoutTriggered, action);

        if (action == StakeAction.END) {
            ++s_globalStakeEnd;
            s_globalStakeIdToStakeInfo[globalStakeId].status = StakeStatus.ENDED;
        }

        legacy = _calculatePrinciple(user, globalStakeId, userStakeInfo);
    }

    /** @dev update shares changes to track when user shares has changed, this affect the payout calculation
     * @param user user address
     * @param shares shares
     * @param amount Legacy amount
     * @param day current contract day
     * @param isPayoutTriggered has global payout triggered
     * @param action start stake or end stake
     * @return isFirstShares first created shares or not
     */
    function _updateSharesStats(
        address user,
        uint256 shares,
        uint256 amount,
        uint256 day,
        PayoutTriggered isPayoutTriggered,
        StakeAction action
    ) private returns (uint256 isFirstShares) {
        //Get previous active shares to calculate new shares change
        uint256 index = s_userSharesIndex[user];
        uint256 previousShares = s_addressIdToActiveShares[user][index].activeShares;

        if (action == StakeAction.START) {
            //return 1 if this is a new wallet address
            //this is used to initialize last claim index to the latest cycle index
            if (index == 0) isFirstShares = 1;

            s_addressIdToActiveShares[user][++index].activeShares = previousShares + shares;
            s_globalShares += shares;
            s_globalLegacyStaked += amount;
        } else {
            s_addressIdToActiveShares[user][++index].activeShares = previousShares - shares;
            s_globalExpiredShares += shares;
            s_globalLegacyStaked -= amount;
        }

        //If global payout hasn't triggered, use current contract day to eligible for payout
        //If global payout has triggered, then start with next contract day as it's no longer eligible to claim latest payout
        s_addressIdToActiveShares[user][index].day = uint128(
            isPayoutTriggered == PayoutTriggered.NO ? day : day + 1
        );

        s_userSharesIndex[user] = index;
    }

    /** @dev calculate stake principle and apply penalty (if any)
     * @param user user address
     * @param globalStakeId global stake Id
     * @param userStakeInfo stake info
     * @return principle calculated principle after penalty (if any)
     */
    function _calculatePrinciple(
        address user,
        uint256 globalStakeId,
        UserStakeInfo memory userStakeInfo
    ) internal returns (uint256 principle) {
        uint256 legacyAmount = userStakeInfo.legacyAmount;
        //penalty is in percentage
        uint256 penalty = calculateEndStakePenalty(
            userStakeInfo.stakeStartTs,
            userStakeInfo.maturityTs,
            block.timestamp
        );

        uint256 penaltyAmount;
        penaltyAmount = (legacyAmount * penalty) / 100;
        principle = legacyAmount - penaltyAmount;
        s_globalStakePenalty += penaltyAmount;

        emit StakeEnded(user, globalStakeId, principle, penalty, penaltyAmount);
    }

    //Views
    /** @notice get global shares
     * @return globalShares global shares
     */
    function getGlobalShares() public view returns (uint256) {
        return s_globalShares;
    }

    /** @notice get global expired shares
     * @return globalExpiredShares global expired shares
     */
    function getGlobalExpiredShares() public view returns (uint256) {
        return s_globalExpiredShares;
    }

    /** @notice get global active shares
     * @return globalActiveShares global active shares
     */
    function getGlobalActiveShares() public view returns (uint256) {
        return s_globalShares - s_globalExpiredShares;
    }

    /** @notice get total Legacy staked
     * @return globalLegacyStaked total Legacy staked
     */
    function getTotalLegacyStaked() public view returns (uint256) {
        return s_globalLegacyStaked;
    }

    /** @notice get global stake id
     * @return globalStakeId global stake id
     */
    function getGlobalStakeId() public view returns (uint256) {
        return s_globalStakeId;
    }

    /** @notice get global active stakes
     * @return globalActiveStakes global active stakes
     */
    function getGlobalActiveStakes() public view returns (uint256) {
        return s_globalStakeId - getTotalStakeEnd();
    }

    /** @notice get total stake ended
     * @return totalStakeEnded total stake ended
     */
    function getTotalStakeEnd() public view returns (uint256) {
        return s_globalStakeEnd;
    }

    /** @notice get total end stake penalty
     * @return totalEndStakePenalty total end stake penalty
     */
    function getTotalStakePenalty() public view returns (uint256) {
        return s_globalStakePenalty;
    }

    /** @notice get user latest shares index
     * @return latestSharesIndex latest shares index
     */
    function getUserLatestShareIndex(address user) public view returns (uint256) {
        return s_userSharesIndex[user];
    }

    /** @notice get user current active shares
     * @return currentActiveShares current active shares
     */
    function getUserCurrentActiveShares(address user) public view returns (uint256) {
        return s_addressIdToActiveShares[user][getUserLatestShareIndex(user)].activeShares;
    }

    /** @notice get user active shares at sharesIndex
     * @return activeShares active shares at sharesIndex
     */
    function getUserActiveShares(
        address user,
        uint256 sharesIndex
    ) internal view returns (uint256) {
        return s_addressIdToActiveShares[user][sharesIndex].activeShares;
    }

    /** @notice get user active shares contract day at sharesIndex
     * @return activeSharesDay active shares contract day at sharesIndex
     */
    function getUserActiveSharesDay(
        address user,
        uint256 sharesIndex
    ) internal view returns (uint256) {
        return s_addressIdToActiveShares[user][sharesIndex].day;
    }

    /** @notice get stake info with stake id
     * @return stakeInfo stake info
     */
    function getUserStakeInfo(address user, uint256 id) public view returns (UserStakeInfo memory) {
        return s_globalStakeIdToStakeInfo[s_addressSIdToGlobalStakeId[user][id]];
    }

    /** @notice get all stake info of an address
     * @return stakeInfos all stake info of an address
     */
    function getUserStakes(address user) public view returns (UserStake[] memory) {
        uint256 count = s_addressSId[user];
        UserStake[] memory stakes = new UserStake[](count);

        for (uint256 i = 1; i <= count; i++) {
            stakes[i - 1] = UserStake({
                sId: i,
                globalStakeId: uint128(s_addressSIdToGlobalStakeId[user][i]),
                stakeInfo: getUserStakeInfo(user, i)
            });
        }

        return stakes;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface ILEGACY {
    function balanceOf(address account) external returns (uint256);

    function getBalance() external;

    function mintLPTokens() external;

    function burnLPTokens() external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface ILegacyOnBurn {
    function onBurn(address user, uint256 amount) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./constant.sol";
import "./enum.sol";

//Legacy

/** @notice get batch mint cost
 * @param mintPower mint power (1 - 100)
 * @param count number of mints
 * @return mintCost total mint cost
 */
    function getBatchMintCost(
        uint256 mintPower,
        uint256 count,
        uint256 mintCost
    ) pure returns (uint256) {
        return (mintCost * mintPower * count) / MAX_MINT_POWER_CAP;
    }

//MintInfo

/** @notice the formula to calculate mint reward at create new mint
 * @param mintPower mint power 1 - 100
 * @param numOfDays mint length 1 - 280
 * @param mintableLegacy current contract day mintable legacy
 * @param EAABonus current contract day EAA Bonus
 * @return reward base legacy amount
 */
    function calculateMintReward(
        uint256 mintPower,
        uint256 numOfDays,
        uint256 mintableLegacy,
        uint256 EAABonus
    ) pure returns (uint256 reward) {
        uint256 baseReward = (mintableLegacy * mintPower * numOfDays);
        if (numOfDays != 1)
            baseReward -= (baseReward * MINT_DAILY_REDUCTION * (numOfDays - 1)) / PERCENT_BPS;

        reward = baseReward;
        if (EAABonus != 0) {
            //EAA Bonus has 1e6 scaling, so here divide by 1e6
            reward += ((baseReward * EAABonus) / 100 / SCALING_FACTOR_1e6);
        }

        reward /= MAX_MINT_POWER_CAP;
    }

/** @notice the formula to calculate bonus reward
 * heavily influenced by the difference between current global mint power and user mint's global mint power
 * @param mintPowerBonus mint power bonus from mintinfo
 * @param mintPower mint power 1 - 100 from mintinfo
 * @param gMintPower global mint power from mintinfo
 * @param globalMintPower current global mint power
 * @return bonus bonus amount in legacy
 */
    function calculateMintPowerBonus(
        uint256 mintPowerBonus,
        uint256 mintPower,
        uint256 gMintPower,
        uint256 globalMintPower
    ) pure returns (uint256 bonus) {
        if (globalMintPower <= gMintPower) return 0;
        bonus = (((mintPowerBonus * mintPower * (globalMintPower - gMintPower)) * SCALING_FACTOR_1e18) /
        MAX_MINT_POWER_CAP);
    }

/**
 * @dev Return penalty percentage based on number of days late after the grace period of 7 days
 * @param secsLate seconds late (block timestamp - maturity timestamp)
 * @return penalty penalty in percentage
 */
    function calculateClaimMintPenalty(uint256 secsLate) pure returns (uint256 penalty) {
        if (secsLate <= CLAIM_MINT_GRACE_PERIOD * SECONDS_IN_DAY) return 0;
        if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 1) * SECONDS_IN_DAY) return 1;
        if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 2) * SECONDS_IN_DAY) return 3;
        if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 3) * SECONDS_IN_DAY) return 8;
        if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 4) * SECONDS_IN_DAY) return 17;
        if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 5) * SECONDS_IN_DAY) return 35;
        if (secsLate <= (CLAIM_MINT_GRACE_PERIOD + 6) * SECONDS_IN_DAY) return 72;
        return 99;
    }

//StakeInfo

    error Legacy_AtLeastHalfMaturity();

/** @notice get max stake length
 * @return maxStakeLength max stake length
 */
    function getMaxStakeLength() pure returns (uint256) {
        return MAX_STAKE_LENGTH;
    }

/** @notice calculate shares and shares bonus
 * @param amount legacy amount
 * @param noOfDays stake length
 * @param shareRate current contract share rate
 * @return shares calculated shares in 18 decimals
 */
    function calculateShares(
        uint256 amount,
        uint256 noOfDays,
        uint256 shareRate
    ) pure returns (uint256) {
        uint256 shares = amount;
        shares += (shares * calculateShareBonus(amount, noOfDays)) / SCALING_FACTOR_1e11;
        shares /= (shareRate / SCALING_FACTOR_1e18);
        return shares;
    }

/** @notice calculate share bonus
 * @param amount legacy amount
 * @param noOfDays stake length
 * @return shareBonus calculated shares bonus in 11 decimals
 */
    function calculateShareBonus(uint256 amount, uint256 noOfDays) pure returns (uint256 shareBonus) {
        uint256 cappedExtraDays = noOfDays <= LPB_MAX_DAYS ? noOfDays : LPB_MAX_DAYS;
        uint256 cappedStakedLegacy = amount <= BPB_MAX_LEGACY ? amount : BPB_MAX_LEGACY;
        shareBonus =
        ((cappedExtraDays * SCALING_FACTOR_1e11) / LPB_PER_PERCENT) +
        ((cappedStakedLegacy * SCALING_FACTOR_1e11) / BPB_PER_PERCENT);
        return shareBonus;
    }

/** @notice calculate end stake penalty
 * @param stakeStartTs start stake timestamp
 * @param maturityTs  maturity timestamp
 * @param currentBlockTs current block timestamp
 * @return penalty penalty in percentage
 */
    function calculateEndStakePenalty(
        uint256 stakeStartTs,
        uint256 maturityTs,
        uint256 currentBlockTs
    ) view returns (uint256) {
        //Matured, then calculate and return penalty
        if (currentBlockTs > maturityTs) {
            uint256 lateSec = currentBlockTs - maturityTs;
            uint256 gracePeriodSec = END_STAKE_GRACE_PERIOD * SECONDS_IN_DAY;
            if (lateSec <= gracePeriodSec) return 0;
            return max((min((lateSec - gracePeriodSec), 1) / SECONDS_IN_DAY) + 1, 99);
        }

        //Emergency End Stake
        //Not allow to EES below 50% maturity
        if (block.timestamp < stakeStartTs + (maturityTs - stakeStartTs) / 2)
            revert Legacy_AtLeastHalfMaturity();

        //50% penalty for EES before maturity timestamp
        return 50;
    }

//a - input to check against b
//b - minimum number
    function min(uint256 a, uint256 b) pure returns (uint256) {
        if (a > b) return a;
        return b;
    }

//a - input to check against b
//b - maximum number
    function max(uint256 a, uint256 b) pure returns (uint256) {
        if (a > b) return b;
        return a;
    }
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

// ===================== common ==========================================
uint256 constant SECONDS_IN_DAY = 86400;
uint256 constant SCALING_FACTOR_1e3 = 1e3;
uint256 constant SCALING_FACTOR_1e6 = 1e6;
uint256 constant SCALING_FACTOR_1e7 = 1e7;
uint256 constant SCALING_FACTOR_1e11 = 1e11;
uint256 constant SCALING_FACTOR_1e18 = 1e18;

// ===================== Legacy ==========================================
uint256 constant PERCENT_TO_BUY_AND_BURN = 21_00;
uint256 constant TITANX_PERCENT_TO_BUY_AND_BURN = 10_00;
uint256 constant PERCENT_TO_CYCLE_PAYDAYS = 65_00;
uint256 constant PERCENT_TO_GENESIS = 4_00;

uint256 constant INCENTIVE_FEE_PERCENT = 6600;
uint256 constant INCENTIVE_FEE_PERCENT_BASE = 1_000_000;
uint256 constant INITAL_LP_TOKENS = 3_750_000_000 ether;
// ===================== globalInfo ==========================================
//Legacy Supply Variables
uint256 constant DAILY_SUPPLY_MINTABLE_REDUCTION = 99_65;
uint256 constant START_MAX_MINTABLE_PER_DAY = 100 ether;
uint256 constant CAPPED_MIN_DAILY_LEGACY_MINTABLE = 1 ether;
uint256 constant MINTABLE_LEGACY_END = 0;
uint256 constant MINIMUM_LEGACY_SUPPLY = 21_000_000 ether;

//EAA Variables
uint256 constant EAA_START = 10 * SCALING_FACTOR_1e6;
uint256 constant EAA_BONUSE_FIXED_REDUCTION_PER_DAY = 28_571;
uint256 constant EAA_END = 0;
uint256 constant MAX_BONUS_DAY = 350;

//Builder Cost Variables
uint256 constant START_MAX_MINT_COST = 0.2 ether;
uint256 constant CAPPED_MAX_MINT_COST = 1 ether;
uint256 constant DAILY_MINT_COST_INCREASE_STEP = 100_08;

//BuilderPower Bonus Variables
uint256 constant START_MINTPOWER_INCREASE_BONUS = 3 * SCALING_FACTOR_1e6; //starts at 3 with 1e6 scaling factor
uint256 constant CAPPED_MIN_MINTPOWER_BONUS = 3 * SCALING_FACTOR_1e3; //capped min of 0.003 * 1e6
uint256 constant DAILY_MINTPOWER_INCREASE_BONUS_REDUCTION = 99_65;

//Share Rate Variables
uint256 constant START_SHARE_RATE = 800 ether;
uint256 constant DAILY_SHARE_RATE_INCREASE_STEP = 100_03;
uint256 constant CAPPED_MAX_RATE = 2_800 ether;

//Cycle Variables
uint256 constant DAY28 = 28;
uint256 constant DAY90 = 90;
uint256 constant DAY369 = 369;
uint256 constant DAY888 = 888;
uint256 constant CYCLE_28_PERCENT = 24_00;
uint256 constant CYCLE_90_PERCENT = 34_00;
uint256 constant CYCLE_369_PERCENT = 30_00;
uint256 constant CYCLE_888_PERCENT = 12_00;
uint256 constant PERCENT_BPS = 100_00;

// ===================== mintInfo ==========================================
uint256 constant MAX_MINT_POWER_CAP = 100;
uint256 constant MAX_MINT_LENGTH = 280;
uint256 constant CLAIM_MINT_GRACE_PERIOD = 7;
uint256 constant MAX_BATCH_MINT_COUNT = 100;
uint256 constant MAX_MINT_PER_WALLET = 1000;
uint256 constant MINT_DAILY_REDUCTION = 11;

// ===================== stakeInfo ==========================================
uint256 constant MAX_STAKE_PER_WALLET = 1000;
uint256 constant MIN_STAKE_LENGTH = 28;
uint256 constant MAX_STAKE_LENGTH = 3500;
uint256 constant END_STAKE_GRACE_PERIOD = 7;

/* Stake Longer Pays Better bonus */
uint256 constant LPB_MAX_DAYS = 2888;
uint256 constant LPB_PER_PERCENT = 825;

/* Stake Bigger Pays Better bonus */
uint256 constant BPB_MAX_LEGACY = 640_000 * SCALING_FACTOR_1e18;
uint256 constant BPB_PER_PERCENT = 80_000 * SCALING_FACTOR_1e18;
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

    enum MintAction {
        CLAIM
    }
    enum MintStatus {
        ACTIVE,
        CLAIMED
    }
    enum StakeAction {
        START,
        END
    }
    enum StakeStatus {
        ACTIVE,
        ENDED
    }
    enum PayoutTriggered {
        NO,
        YES
    }
    enum InitialLPMinted {
        NO,
        YES
    }
    enum PayoutClaim {
        SHARES
    }