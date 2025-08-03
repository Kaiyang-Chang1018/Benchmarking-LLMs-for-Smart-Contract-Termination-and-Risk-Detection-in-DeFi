// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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
/** 
DOPAMINE (DOPA) 
Revanchist dynastic epochal levels of fuck you wealth. Bet more.
Twitter:  https://twitter.com/getdopamine
Website:  https://getdopamine.xyz
**/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Dopamine is ERC20, Ownable {
	uint256 public constant maxSupply = 1_000_000_000_000 * 10 ** 18; // 1t
	uint256 public constant operationalSupply = 750_000_000_000 * 10 ** 18; // 750b 
	uint256 public constant mintAmount = 18_000_000 * 10 ** 18; // 18m
	uint256 public constant maxMintCount = 8;
	uint256 public constant batchMintFee = 5; // in percent
	uint256 public constant tradingFee  = 2; // in percent
	uint256 public seed;
	uint256 public tradingEnabledTime;
	uint256 public constant highTaxDuration = 2 minutes; // anti-bot first 2 mins
	uint256 public constant highTaxRate = 20;
	address payable public marketingWallet;
	bool public tradingEnabled;
	bool public mintingEnabled;
	mapping(address => uint256) public mintCounts;
	mapping(address => bool) private blocklist;
	mapping(address => bool) private isExcludedFromFee;

	constructor() ERC20("Dopamine", "DOPA") {
		isExcludedFromFee[msg.sender] = true;
		marketingWallet = payable(msg.sender);
		_mint((address(this)), maxSupply);
		_transfer(address(this), msg.sender, operationalSupply);
	}

	struct Round {
		address owner; // address of the current round owner
		uint256 countdown; // e.g. 300 = 5 minutes 
		uint256 prizePool; // e.g. 100 * 10 ** 18 = 100 DOPA
		uint256 takeoverCost; // e.g. 100 * 10 ** 18 = 100 DOPA
		uint256 takeoverCostIncrease; // e.g. 5 = 5% increase each takeover
		uint256 lastTakeoverTime; // timestamp of the last takeover
		uint256 sidepot; // e.g. 100 * 10 ** 18 = 100 DOPA
		uint256 sidepotSpinCost; // e.g. 10 * 10 ** 18 = 10 DOPA
	}

	Round public currentRound;

	// Events
	event RoundStarted(
		uint256 countdown,
		uint256 prizePool,
		uint256 takeoverCostIncrease
	);
	event Takeover(address indexed user, uint256 amount);
	event Received(address user, uint amount);
	event PrizePoolClaimed(address indexed claimer, uint256 amount);
	event SidepotSpin(address indexed user, uint256 result);
	event SidepotWin(address indexed user, uint256 amount);

	// Modifiers
	modifier onlyWhenRoundHasEnded() {
		require(
			block.timestamp >= currentRound.lastTakeoverTime + currentRound.countdown,
			"Dopamine: Round not finished"
		);
		_;	
	}

	// Once turned on can never be turned off
	function enableTrading() external onlyOwner {
		tradingEnabled = true;
		tradingEnabledTime = block.timestamp;
	}

	// Once turned on can never be turned off
	function enableMinting() external onlyOwner {
		mintingEnabled = true;
	}

	function setMarketingWallet(address _marketingWallet) external onlyOwner {
		marketingWallet = payable(_marketingWallet);
	}

	function manageBlocklist(address user, bool blockUser) external onlyOwner {
		blocklist[user] = blockUser;
	}

	function manageExcludedFromFee(address user, bool exclude) external onlyOwner {
		isExcludedFromFee[user] = exclude;
	}

	// Game code
	function startNewRound(
		uint256 _countdown,
		uint256 _prizePool,
		uint256 _takeoverCost,
		uint256 _takeoverCostIncrease,
		uint256 _sidepot,
		uint256 _sidepotSpinCost
	) external onlyOwner onlyWhenRoundHasEnded {
		require(
			IERC20(address(this)).transferFrom(msg.sender, address(this), _prizePool + _sidepot),
			"Dopamine: Transfer failed"
		);
		require(_prizePool > 0, "Dopamine: Prize pool must be greater than 0");
		require(_countdown > 0, "Dopamine: Countdown must be greater than 0");
		require(_takeoverCost > 0, "Dopamine: Takeover cost must be greater than 0");
		require(_takeoverCostIncrease > 0 && _takeoverCostIncrease <= 25, "Dopamine: Takeover cost increase must be greater than 0 and less than or equal to 25");
		require(_sidepot > 0, "Dopamine: Sidepot must be greater than 0");
		require(_sidepotSpinCost > 0, "Dopamine: Sidepot spin cost must be greater than 0");

		currentRound = Round(
			address(0),
			_countdown,
			_prizePool,
			_takeoverCost,
			_takeoverCostIncrease,
			block.timestamp,
			_sidepot,
			_sidepotSpinCost
		);
		emit RoundStarted(
			_countdown,
			_prizePool,
			_takeoverCostIncrease
		);
	}

	function claimPrizePool() external onlyWhenRoundHasEnded  {
		require(
			msg.sender == currentRound.owner,
			"Dopamine: Only the winner can claim the prize pool");
		require(
			currentRound.prizePool > 0,
			"Dopamine: Prizepool has already been claimed"
		);
		_transfer(address(this), msg.sender, currentRound.prizePool);
		currentRound.prizePool = 0;
		emit PrizePoolClaimed(msg.sender, currentRound.prizePool);
	}

	function takeover() external {
		require(
			currentRound.takeoverCost > 0,
			"Dopamine: Round has not started"
		);
		require(
			IERC20(address(this)).transferFrom(msg.sender, address(this), currentRound.takeoverCost),
			"Dopamine: Transfer failed"
		);
		require(
			msg.sender != currentRound.owner,
			"Dopamine: You already own this round"
		);

		uint256 addToSidepot = (currentRound.takeoverCost * 40) / 100;
		uint256 burnAmount = (currentRound.takeoverCost * 20) / 100;
		uint256 addToPrizePool = currentRound.takeoverCost - addToSidepot - burnAmount;

		currentRound.owner = msg.sender;
		currentRound.prizePool += addToPrizePool; 
		currentRound.takeoverCost = 
			(currentRound.takeoverCost * (100 + currentRound.takeoverCostIncrease)) / 100;
		currentRound.lastTakeoverTime = block.timestamp;
		currentRound.sidepot += addToSidepot;

		_burn(address(this), burnAmount);	
		emit Takeover(msg.sender, currentRound.takeoverCost);
	}

	function sidepotSpin() external returns (bool) {
		require(
			currentRound.sidepot > 0,
			"Dopamine: Sidepot is empty"
		);
		require(
			IERC20(address(this)).transferFrom(msg.sender, address(this), currentRound.sidepotSpinCost),
			"Dopamine: Transfer failed"
		);
		currentRound.sidepot += currentRound.sidepotSpinCost;
		uint256 roll = sidepotCheck(100, msg.sender);
		if (roll == 42) {
			_transfer(address(this), msg.sender, currentRound.sidepot);
			currentRound.sidepot = 0;
			emit SidepotWin(msg.sender, currentRound.sidepot);
			return true;
		}
		emit SidepotSpin(msg.sender, roll);
		return false;
	}	
	
	function sidepotCheck(uint max, address _a) private returns (uint) {
		seed++;
		return uint(keccak256(abi.encodePacked(blockhash(block.number - 1), _a, seed))) % max;
	}

	function mint() external {
		require(mintingEnabled, "Dopamine: Minting is not enabled");
		require(msg.sender == tx.origin, "Dopamine: Cannot mint from contract");
		require(
			balanceOf(address(this)) - currentRound.prizePool >= mintAmount,
			"Dopamine: Not enough DOPA left to mint"
		);
		require(
			mintCounts[msg.sender] < 8,
			"Dopamine: Max mint count reached"
		);
		mintCounts[msg.sender] += 1;
		_transfer(address(this), msg.sender, mintAmount);
	}

	function batchMint() external {
		require(mintingEnabled, "Dopamine: Minting is not enabled");
		require(msg.sender == tx.origin, "Dopamine: Cannot mint from contract");
		require(
			balanceOf(address(this)) - currentRound.prizePool >= mintAmount * maxMintCount,
			"Dopamine: Not enough DOPA left to mint"
		);
		require(
			mintCounts[msg.sender] < 8,
			"Dopamine: Max mint count reached"
		);
		uint256 totalAmount = mintAmount * (maxMintCount - mintCounts[msg.sender]); // 144m
		uint256 tax = (totalAmount * batchMintFee) / 100; // 7.2m
		uint256 afterTaxAmount = totalAmount - tax; // 136.8m
		mintCounts[msg.sender] = 8;
		_transfer(address(this), msg.sender, afterTaxAmount);
		_transfer(address(this), address(marketingWallet), tax);
	}

	function _transfer(address from, address to, uint256 amount) internal virtual override {
		require(from != address(0), "Dopamine: Transfer from the zero address");
		require(to != address(0), "Dopamine: Transfer to the zero address");
		require(amount > 0, "Dopamine: Transfer amount must be greater than zero");
		if (
			isExcludedFromFee[from] || 
			isExcludedFromFee[to] || 
			tradingEnabled == false || 
			from == address(this) || 
			to == address(this)) {
			super._transfer(from, to, amount);
		} else {
			uint256 tradingFeeRate;
			if (block.timestamp < tradingEnabledTime + highTaxDuration) {
				// protect public from snipers in first few minutes
				tradingFeeRate = highTaxRate;
			} else {
				tradingFeeRate = tradingFee;
			}
			uint256 fee = (amount * tradingFeeRate) / 100;
			uint256 afterFeeAmount = amount - fee;
			super._transfer(from, to, afterFeeAmount);
			super._transfer(from, address(marketingWallet), fee);
		}
	}

	function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
		super._beforeTokenTransfer(from, to, amount);
		if (!tradingEnabled) {
			require(from == owner() || to == owner() || from == address(this) || to == address(this), "Dopamine: Trading is not enabled");
		}
		require(!blocklist[from] && !blocklist[to], "Dopamine: Address is blocklisted");
	}

	function burn(uint256 amount) external {
		_burn(msg.sender, amount);
	}

	fallback() external payable {
		emit Received(msg.sender, msg.value);
	}

	receive() external payable {
		emit Received(msg.sender, msg.value);
	}

	function withdraw() external onlyOwner {
		uint balance = address(this).balance;
		payable(msg.sender).transfer(balance);
	}

}