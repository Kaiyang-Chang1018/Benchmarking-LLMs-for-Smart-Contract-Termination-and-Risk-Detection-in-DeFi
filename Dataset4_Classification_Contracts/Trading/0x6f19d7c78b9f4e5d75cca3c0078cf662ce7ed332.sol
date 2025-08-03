// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.8.3

/*
 *
 * $$$$$$$$\ $$$$$$$$\ $$\   $$\  $$$$$$\   $$$$$$\         $$$$$$\ $$$$$$$$\  $$$$$$\  $$\   $$\ $$$$$$$$\ $$\   $$\  $$$$$$\  $$\   $$\  $$$$$$\  $$$$$$$$\
 * \__$$  __|$$  _____|$$ |  $$ |$$  __$$\ $$  __$$\       $$  __$$\\__$$  __|$$  __$$\ $$ | $$  |$$  _____|$$ |  $$ |$$  __$$\ $$ |  $$ |$$  __$$\ $$  _____|
 *    $$ |   $$ |      \$$\ $$  |$$ /  $$ |$$ /  \__|      $$ /  \__|  $$ |   $$ /  $$ |$$ |$$  / $$ |      $$ |  $$ |$$ /  $$ |$$ |  $$ |$$ /  \__|$$ |
 *    $$ |   $$$$$\     \$$$$  / $$$$$$$$ |\$$$$$$\        \$$$$$$\    $$ |   $$$$$$$$ |$$$$$  /  $$$$$\    $$$$$$$$ |$$ |  $$ |$$ |  $$ |\$$$$$$\  $$$$$\
 *    $$ |   $$  __|    $$  $$<  $$  __$$ | \____$$\        \____$$\   $$ |   $$  __$$ |$$  $$<   $$  __|   $$  __$$ |$$ |  $$ |$$ |  $$ | \____$$\ $$  __|
 *    $$ |   $$ |      $$  /\$$\ $$ |  $$ |$$\   $$ |      $$\   $$ |  $$ |   $$ |  $$ |$$ |\$$\  $$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ |$$\   $$ |$$ |
 *    $$ |   $$$$$$$$\ $$ /  $$ |$$ |  $$ |\$$$$$$  |      \$$$$$$  |  $$ |   $$ |  $$ |$$ | \$$\ $$$$$$$$\ $$ |  $$ | $$$$$$  |\$$$$$$  |\$$$$$$  |$$$$$$$$\
 *    \__|   \________|\__|  \__|\__|  \__| \______/        \______/   \__|   \__|  \__|\__|  \__|\________|\__|  \__| \______/  \______/  \______/ \________|
 *
 */

 /*
  * ______ ___________ _____  __   __  _____ _____ ___   _   __ _____ _   _ _____ _   _ _____ _____
  * | ___ \  ___| ___ \  ___| \ \ / / /  ___|_   _/ _ \ | | / /|  ___| | | |  _  | | | /  ___|  ___|
  * | |_/ / |__ | |_/ / |__    \ V /  \ `--.  | |/ /_\ \| |/ / | |__ | |_| | | | | | | \ `--.| |__
  * |  __/|  __||  __/|  __|   /   \   `--. \ | ||  _  ||    \ |  __||  _  | | | | | | |`--. \  __|
  * | |   | |___| |   | |___  / /^\ \ /\__/ / | || | | || |\  \| |___| | | \ \_/ / |_| /\__/ / |___
  * \_|   \____/\_|   \____/  \/   \/ \____/  \_/\_| |_/\_| \_/\____/\_| |_/\___/ \___/\____/\____/
  */

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


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.8.3

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/Context.sol@v4.8.3

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


// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v4.8.3

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;



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


// File contracts/SteakHouse.sol

pragma solidity ^0.8.2;

/*
 *
 * $$$$$$$$\ $$$$$$$$\ $$\   $$\  $$$$$$\   $$$$$$\         $$$$$$\ $$$$$$$$\  $$$$$$\  $$\   $$\ $$$$$$$$\ $$\   $$\  $$$$$$\  $$\   $$\  $$$$$$\  $$$$$$$$\
 * \__$$  __|$$  _____|$$ |  $$ |$$  __$$\ $$  __$$\       $$  __$$\\__$$  __|$$  __$$\ $$ | $$  |$$  _____|$$ |  $$ |$$  __$$\ $$ |  $$ |$$  __$$\ $$  _____|
 *    $$ |   $$ |      \$$\ $$  |$$ /  $$ |$$ /  \__|      $$ /  \__|  $$ |   $$ /  $$ |$$ |$$  / $$ |      $$ |  $$ |$$ /  $$ |$$ |  $$ |$$ /  \__|$$ |
 *    $$ |   $$$$$\     \$$$$  / $$$$$$$$ |\$$$$$$\        \$$$$$$\    $$ |   $$$$$$$$ |$$$$$  /  $$$$$\    $$$$$$$$ |$$ |  $$ |$$ |  $$ |\$$$$$$\  $$$$$\
 *    $$ |   $$  __|    $$  $$<  $$  __$$ | \____$$\        \____$$\   $$ |   $$  __$$ |$$  $$<   $$  __|   $$  __$$ |$$ |  $$ |$$ |  $$ | \____$$\ $$  __|
 *    $$ |   $$ |      $$  /\$$\ $$ |  $$ |$$\   $$ |      $$\   $$ |  $$ |   $$ |  $$ |$$ |\$$\  $$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ |$$\   $$ |$$ |
 *    $$ |   $$$$$$$$\ $$ /  $$ |$$ |  $$ |\$$$$$$  |      \$$$$$$  |  $$ |   $$ |  $$ |$$ | \$$\ $$$$$$$$\ $$ |  $$ | $$$$$$  |\$$$$$$  |\$$$$$$  |$$$$$$$$\
 *    \__|   \________|\__|  \__|\__|  \__| \______/        \______/   \__|   \__|  \__|\__|  \__|\________|\__|  \__| \______/  \______/  \______/ \________|
 *
 */

contract SteakHouse is ERC20 {
    enum Doneness {
        RARE,
        MEDIUMRARE,
        MEDIUM,
        MEDIUMWELLDONE,
        WELLDONE
    }

    struct Steak {
        uint timestamp;
        uint amount;
        Doneness doneness;
        bool yummy;
    }

    struct PepeSteak {
        uint timestamp;
        uint amount;
        uint yourFrogs;
        uint lastestVisit;
        bool returned;
    }

    address public beefTokenAddress =
        0xcaa7709A7365f981e4996F907F8ADb482e75ACB8;
    address public pepeTokenAddress =
        0x6982508145454Ce325dDbE47a25d4ec3d2311933;
    uint public steakRatio;

    uint public remainedSteak;
    uint public remainedPepeSteak;

    uint public pepeStakingPeriod = 1 days;
    uint public pepeSteakCliff = 2 weeks;
    uint public pepeSteakVesting = 4 weeks;

    mapping(address => uint32) steakCount;
    mapping(address => mapping(uint32 => Steak)) steaks;
    mapping(address => PepeSteak) pepesteaks;

    constructor() ERC20("Steak in Texas Stakehouse", "STEAK") {}

    modifier nonZeroCheck(uint n) {
        require(n > 0, "ZERO MEANS NOTHING");
        _;
    }

    function letsGrill(
        uint amount,
        Doneness doneness
    ) external nonZeroCheck(amount) {
        ERC20(beefTokenAddress).transferFrom(msg.sender, address(this), amount);

        uint newyummysteaks = _moreGrills(amount, doneness);
        require(
            newyummysteaks - amount <= remainedSteak,
            "Steak is out of stock. Please wait for the next Stakehouse!"
        );
        remainedSteak -= (newyummysteaks - amount);
        Steak storage steak = steaks[msg.sender][steakCount[msg.sender]];
        steak.timestamp = block.timestamp;
        steak.amount = amount;
        steak.doneness = doneness;
        steakCount[msg.sender] += 1;
    }

    function yummyyummyyummy(uint32 steaknum) external {
        Steak storage steak = steaks[msg.sender][steaknum];
        require(!steak.yummy, "You already ate them up!");
        uint grilledAt = _grilledWhen(steak.timestamp, steak.doneness);
        require(grilledAt < block.timestamp, "The steak is not grilled yet!");
        require(block.timestamp < grilledAt + 1 days, "Overcooked :P");
        steak.yummy = true;
        _mint(msg.sender, _moreGrills(steak.amount, steak.doneness));
    }

    function howIsItGoing(
        address customer,
        uint32 steaknum
    ) external view returns (Steak memory steak) {
        steak = steaks[customer][steaknum];
    }

    function howManyTimesDidYouGrill(
        address customer
    ) external view returns (uint) {
        return steakCount[customer];
    }

    function _grilledWhen(
        uint timestamp,
        Doneness doneness
    ) internal pure returns (uint) {
        if (doneness == Doneness.RARE) return timestamp;
        if (doneness == Doneness.MEDIUMRARE) return timestamp + 1 days;
        if (doneness == Doneness.MEDIUM) return timestamp + 3 days;
        if (doneness == Doneness.MEDIUMWELLDONE) return timestamp + 5 days;
        return timestamp + 7 days;
    }

    function _moreGrills(
        uint amount,
        Doneness doneness
    ) internal pure returns (uint) {
        if (doneness == Doneness.RARE) return amount;
        if (doneness == Doneness.MEDIUMRARE) return (amount * 10030) / 1e4;
        if (doneness == Doneness.MEDIUM) return (amount * 10115) / 1e4;
        if (doneness == Doneness.MEDIUMWELLDONE) return (amount * 10225) / 1e4;
        return (amount * 10350) / 1e4;
    }

    function provideMoreSteaks(uint amount) external nonZeroCheck(amount) {
        ERC20(beefTokenAddress).transferFrom(msg.sender, address(this), amount);
        remainedSteak += amount;
    }

    function magicChangingSteakIntoBeef(
        uint amount
    ) external nonZeroCheck(amount) {
        _burn(msg.sender, amount);
        ERC20(beefTokenAddress).transfer(msg.sender, amount);
    }

    /*
     * ______ ___________ _____  __   __  _____ _____ ___   _   __ _____ _   _ _____ _   _ _____ _____
     * | ___ \  ___| ___ \  ___| \ \ / / /  ___|_   _/ _ \ | | / /|  ___| | | |  _  | | | /  ___|  ___|
     * | |_/ / |__ | |_/ / |__    \ V /  \ `--.  | |/ /_\ \| |/ / | |__ | |_| | | | | | | \ `--.| |__
     * |  __/|  __||  __/|  __|   /   \   `--. \ | ||  _  ||    \ |  __||  _  | | | | | | |`--. \  __|
     * | |   | |___| |   | |___  / /^\ \ /\__/ / | || | | || |\  \| |___| | | \ \_/ / |_| /\__/ / |___
     * \_|   \____/\_|   \____/  \/   \/ \____/  \_/\_| |_/\_| \_/\____/\_| |_/\___/ \___/\____/\____/
     */

    function letsGrillFrog(uint amount) external nonZeroCheck(amount) {
        require(
            pepeTokenAddress != address(0) && steakRatio != 0,
            "Wait for minutes plz :D"
        );
        ERC20(pepeTokenAddress).transferFrom(msg.sender, address(this), amount);
        PepeSteak storage steak = pepesteaks[msg.sender];
        require(steak.amount == 0, "You can taste frog steak only once.");
        steak.timestamp = block.timestamp;
        steak.yourFrogs = amount;
        steak.amount = amount * steakRatio;
        steak.lastestVisit = steak.timestamp + pepeSteakCliff;
        require(
            remainedPepeSteak >= steak.amount,
            "Pepe steak is out of stock ;P"
        );
        remainedPepeSteak -= steak.amount;
    }

    function takeYourFrogBack() external {
        PepeSteak storage steak = pepesteaks[msg.sender];
        require(
            steak.timestamp + pepeStakingPeriod < block.timestamp,
            "Still grilling your frog..."
        );
        require(!steak.returned, "Already took your frog back");
        steak.returned = true;
        ERC20(pepeTokenAddress).transfer(msg.sender, steak.yourFrogs);
    }

    function tasteNewTypeOfSteakYummy() external {
        PepeSteak storage steak = pepesteaks[msg.sender];
        require(
            steak.timestamp + pepeSteakCliff < block.timestamp,
            "Your steak is not ready!"
        );
        uint amount = (steak.amount *
            ((
                (block.timestamp >
                    steak.timestamp + pepeSteakCliff + pepeSteakVesting)
                    ? steak.timestamp + pepeSteakCliff + pepeSteakVesting
                    : block.timestamp
            ) - steak.lastestVisit)) / pepeSteakVesting;
        steak.lastestVisit = block.timestamp;
        _mint(msg.sender, amount);
    }

    function howIsYourFrogGoing(
        address customer
    ) external view returns (PepeSteak memory steak) {
        steak = pepesteaks[customer];
    }

    function provideMorePepeSteaks(uint amount) external nonZeroCheck(amount) {
        ERC20(beefTokenAddress).transferFrom(msg.sender, address(this), amount);
        remainedPepeSteak += amount;
    }

    function findANewFriend(
        address tokenAddress,
        uint newRatio,
        uint stakingPeriod,
        uint steakCliff,
        uint steakVesting
    ) external {
        require(msg.sender == 0xC54a1581309bB22eF1366A4Cd5E34C20b84D67B1);
        pepeTokenAddress = tokenAddress;
        steakRatio = newRatio;
        pepeStakingPeriod = stakingPeriod;
        pepeSteakCliff = steakCliff;
        pepeSteakVesting = steakVesting;
    }
}