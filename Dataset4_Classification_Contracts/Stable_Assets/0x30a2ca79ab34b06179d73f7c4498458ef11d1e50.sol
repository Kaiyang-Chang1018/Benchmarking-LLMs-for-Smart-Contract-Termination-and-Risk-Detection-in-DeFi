// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MiladyDoge is ERC20 {
    address public managerWallet;
    mapping(address => bool) excludedFromTax;

    bool internal supplyMinted = false;
    uint256 MAX_SUPPLY = 18004262537 * 1e18;
    uint256 MAX_TAX_FRACTION = 0.02 * 1e18;
    uint256 public currentTaxFraction;

    event NewManager(address newManager);

    modifier onlyManager() {
        require(msg.sender == managerWallet, "not authorized");
        _;
    }

    constructor(address _managerWallet) ERC20("MiladyDoge", "MD") {
        managerWallet = _managerWallet;
        currentTaxFraction = MAX_TAX_FRACTION;
        excludedFromTax[managerWallet] = true;
    }

    function mintAll() external onlyManager {
        require(!supplyMinted, "already minted");
        _mint(managerWallet, MAX_SUPPLY);
        supplyMinted = true;
    }

    function renounceManagerRole(address newManager) external onlyManager {
        require(newManager != address(0), "can't use the zero adress");
        managerWallet = newManager;
        emit NewManager(newManager);
    }

    function setTaxFraction(uint256 _newTaxFraction) external onlyManager {
        require(_newTaxFraction <= MAX_TAX_FRACTION);
        currentTaxFraction = _newTaxFraction;
    }

    function excludeFromTax(address account) external onlyManager {
        excludedFromTax[account] = true;
    }

    function includeInTax(address account) external onlyManager {
        excludedFromTax[account] = false;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        // Tax Logic
        uint256 amountTo = amount;
        if (!excludedFromTax[from] && !excludedFromTax[to]) {
            uint256 tax = (amount * currentTaxFraction) / 1e18;
            amountTo -= tax;
            _balances[managerWallet] += tax;
        }

        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amountTo;
        }

        emit Transfer(from, to, amount);
    }

    /**

~~~~~~~~^~~~~!!77?JJJYYYYYYYYYY5Y5YYY5YY55Y5555Y555555555555555555555YYYY5Y5Y5555YYYYYYYYYYJJJJ???7!
~~~~~~~~~!!!!777?JJJYYYYYYYYYYYY5Y55YYYYYYYYY5YY5YY5Y555555YYYYYYYYYYYYYYY5Y5YYYYYYYYYJJJJJJJJJ????J
^^^^^^^~~~!!77???JJJJYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYJJJJJ??JJJJJJJJJ?7!
::::::^^~~!777?????JJJJJJYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYJJJJJJ????7?JJJYJJJJ??77?
::...:::^~~!7777!!7777?JJYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYJJJJJJJ?????JJYYYJJJJ???77!
:::::::^^^~~~!!!!!!!!7?JYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYJYJYYJJJJJJJJJJJJYYYYYJJJJ??777?
^^~~~~~~~~~~~~~!!!77JJYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYJJJJYJJJYYYYYYYYYYJJJJJ??7!~
7??????????77777??JYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYJYYYYYYYYYYYJJJJJJ??77?
77?JJJYYJJJJJJJYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYJJJJJJJJJ?77!!
???JJ?JJJYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYJJJJJJJYYYYYYYYYYYYYYYYYYYYYYYJJJJJYYYYJJJJJJJJJJJ???7!7
YYYJJJJ?JYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYJJJJ???JJJYJJJYJJJYYYYYJJJJJJJJJJJJJ?JJJJJYJJJJJJJJ???77!!
YYYYJJYJYYYYYYYYYYYYYYYYYYYYYYYYYYYJJJJJYJJ????JJJJYJJYYYJJ?JYYYYJ?JYJJ?JYJJYYJ?JYJJJJYJJJJJ????77!!
YYYYYYYYYYYYYYYYYYYYYYYYYJJJJYYYJJJ???JJJJ???JJJJJYYJJYYJJJ??YYYYJ?Y5YJ??YYJ?JYJ?JYJJ?JYJ??????777!!
JYYYYYYYYYYJYYYYYYYJJYYJ??JJYYYJJJ?7?JJJJ?7J5YJJJYYYJJYYJJJJ?J5YJ???5YJ??YYJ??JYJJYYJJ?JY????7777!!!
JJJJJJJJJJJJYYYYYJJJJYJ???JYYYJJJ?7?JJJJJ??55YJJJ55JJ!~~JJJJ??YYYJ?!7?J??55YJ?JYJJYYJJ?JYJ7777!!!~~!
JJJJJJJJJJJYYYYYJ???JY???JJYYYJJ???JJJYJJ7?5YYJJ77YY?~^^?YJJJ7?!7JJ!^~J?!7!7J??YJJYYJ??YYY?7!!!!!!~!
JJJJJJJJJJJYYYJJ?77?YY??JJJJYYJJ??JJJYYJ?!~7JJJJ~^~J?^^^~?JJJ??!^~77^~7~^^~77!~!??YYJJJYYY?~~~~~~^^^
????JJJJJJJYYJJJ?77JYY??JJJJYYJJ??JJ??YJ?~77?JJ7~^^~7~^~~~!J?7?!^^^~~^^^^^^^^^^^^~7JYYJJYY!::::.....
?????????JYYJJJ?77?YYY?JJJJJYYJJ??J?~^7Y7^~77!~^^^^^^^^~!!!7!!~^~~~^~~~~~~~~~~^^^~~!Y5J?YY:.......  
?????????JYYJJ?777?YYJJJYJJJJYJJ???~^^^!~^^^^^^^^^~~^~^^^^^^^^^^^^^^Y#BGGGGGGGG57^^!Y5JJY!..........
7777?????JYJJ?7777JYYYJJYYJ?JYYJ??7^^^^^^^~!!7JY5G#P~^^^^^^^^^^^^^^^!?7?JJJJ?7!?7~~~~JJ7^...........
777777777JJJJ?777?YYYYJYYJJ?JYYYJ?!^^~7J5PPP555YJJ?7~^^^^^^^^^^^^^^~^^!Y5PGPPP57~~~~~~:............:
!!!!!!!!7JJJ?7777?YYYYYYJJ??7???JJ7!PGPY?777??!^^^^^^^^^^^^^^^^^^^~~~~~5PYJ5#BP?~~~~~^..............
!!!!!!!!JJJJ?777?YYYYYYJJ?77!~^^~!!~!~^~Y55555?7!~^^^^^^^^^^^^^^^~~~~!#?    J@@B?~~~~^:::...........
!!!!!!!?YJJJ?777JYYYYJJJ?7!!~~^^^^^^^^7PYPB#B#&@&B57^^^^^^^^^^^^~~~~~P@Y^^!5&&&#&Y~~~^::::::::::::::
!!!!!!7YJJJJ?7?JYYJJ????77!~~^^^^^^^^^~JB5~:..^G@@@&Y~^^^^^^^^^^~~!~!#@@@@@@@@##7G5~~~^^^^^^^^^^^^^^
~~~~~~?YJJJJ?7?JJ?77!!~~~~~~~^^^^^^^^~5@5      5@&@@&7^^^^^^^^^^~~~~!&&##@@@@&BB:~!~~~~~~~~~~^^^^~~~
~!!!!!JYJJJ?!!!!~~~~~~~~~~~~~^~~~~~^7B#@&5???Y#@&@@@@Y^^^^^^^^^^~~~~~P7!7P@&?~G7^!~~~~~~~~~~~~~~~~~~
7777!7YYJJ7!~~~~~~~~~~~~~~~^^~~~~~~J#5^#@&&@@@@@BGY7?5^^^^~~^^^^~!~~~!J?7JJ?!Y?^~~~~~!!!!!!!!!!!!!!!
JJJ??JYJJJ?!~~~~~~~~~~~~~~~^^~~~~~~!!^.~#@&&##B5.  ~Y7^^^~~~~~~~~!!~~~~!7JJJP5!~~~~!7!!!~~!!!!!!!!!!
GGGPPPYJJJ???!~~~~~~~~~^^~~^^^~~~~~~^~^:^YGJ~~~~:^55!^^^^^~~~~~~~~~!!~~~~~~!7?!~~~~JYYJ?77??JJJ??JJJ
BBBBBGYJJJ?JYJ?!!~~~~~~~~~~~~~~~~~~~~~^~^:^7!!77?J?~^^^^^^^^~^^^^:^~~!!!!!!!!~~~~~?YYYYYYYYYYYYYYYY5
GGGGGG5JJJ?JYYYYJ?7!!~~~!!~~~~~~~~~~~~^^^~~7JJ7!~^^^^^^^^^^^^^^^^^^~~~~~!!!!~~~~~?JJ5PPGPPPPPPPP5555
PPGGBBPJJJ?JYYYYYYYYJJ?!!!~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^~~~~~~~~!!!~~~~~!!!~~~!?JJ?JPGGGGGGGGGGGGGB
PGGBBB#5JJJJYYYYYYYYYYY?J?7?7!!!~~~~~~~~~~~~~~~~^^~~^^^~~^~!!!!!~~~^~~~~~!!~~!7JYJJJ?JPGGGGGGGGGGGGP
GGBBBB#B5JJJYYYYYYYYYYYJ77Y55YYJJ?7!!~~~~~~~~~~~~~~~~~~~~~~^^^^^^^~~~~~~~~~!?JYYYJJJJ?JGBGGBBBGGGPPG
GGGGGGGGGYJJYYYYYYYYYYYJ77YYYYY555YYYJ?7!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!!7JYYYYYYJ?JJJJJPGGGGP5PPPP5
BGGGGPGGG5JJYYYYYYYYYYYYJJYYYYYYYYYYY555YYJ?7!!~~~~~~~~~~~~~~~~~~~~!!7?JYYYYYYYYJJJJJJJ?5GGP5555PPPG
BBGGGGGGGPJJJYYJJYYYYYYYYYYYYYYYYYYYYYYYYY5GGGGGP?!!!!~~~~~!!!!77??JYYYYYYYYYYYYYJJJJJJJJPGPPPPPPPP5
BBBBBBBBBBYJJJJJJYYYYYYYYYYYYYYYYYYYYY555PGBGGP5P5???7777!!!!!!P555YYYYYYYYYYYYYYJJJJJJJ?YGGG5YPPPPG
GBBBBBBGGG5JJJJJJJJJYYYYYYYYYYYYYY55PGGGPP55Y5~:^?777777777!!!!J:^?5P5YYYYYYYYYYYYJJJJJJJ?JYYJYGGGGG
GGGGGGGPYYJJJJJJJJJJJYYYYY55555PPGBBGPYJYYYYYYY7:!77777777!!!!!!:  .?YY?YJJJYYYYYYYYYYYPP55Y5PBGGGGG
BBBBBBBBPPPPPPGGGGGGBBBGGGB##BBBBB5JYYYJJ555555Y??5YJ??777777??YY.  ^YYJY55??5GPPGPPGGGGBBBBBB#BGGGG
###&&######B#&&&#########BBBBBBGGJ~7JJY5Y5Y555YY55YG##BBBBBBB###G!:^YJY5JJ5Y!!YGPGGPPGGGGBBBBBBBBGGG
###BBBBGGGGGGB#B#BBBBBBBBBBBGGGGJ!~!J55J55J5Y55PP5YJJB#########GJ?JJYY55Y5YJ7~~J555P55PGGGGGGGPPGPPP
GGPPPPP5PPPPPPPGGGGGGGGGPPPPPPPY!!!!?P5YYP555P5P5PGJJJP########J??!?5Y?JYPYJ7~~!5P5555PPPPPPP555555Y
GGGGGGGPGGGBGPPPGGGGGGPPP55Y5P57~!!~7Y5YY55PYYY5Y5PPG5JJB#####Y777JJY?JYYYYJ7~~!5PPPPPPPPGPP555YYY55
GGGGGGGGGBBBBGGGGGGGGGGPP555PG5!~!!~!J5J5YY5Y5YYJ555PGPY?G###J?J5577J?YY?YJJ7~~~?PPPPPPPPGGPPP5555PP
GGGGGGGB#######BBBBGGGPP55PPPGJ~!!!!~?PP?J55Y55JJJJYP5YPPJ5B7755YJ7YYJJ7JYYJ7~~~7PGGGPGGGB#BBGP5PPPG
GGGGGGGPP5YY55PGGGGGGPPPPPGGGP7~!!!!~7JY?P5YYJ?Y5YYYY575GY?~J5YJYYY7J?Y?YJY?!~~~~5GGGGGBGGB#BGPPGGGP
     **/
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
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string internal _name;
    string internal _symbol;

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