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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// following code comes from import "@openzeppelin/contracts/access/Ownable.sol"; (version from February 22, 2023)
// original comments are removed and where possible code is made more compact, any changes except visual ones are commented
import "@openzeppelin/contracts/utils/Context.sol";
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {_transferOwnership(_msgSender());}
    modifier onlyOwner() {_checkOwner(); _;}
    function owner() public view virtual returns (address) {return _owner;}
    function _checkOwner() internal view virtual {require(owner() == _msgSender(), "Ownable: caller is not the owner");}
// added bool confirm to avoid theoretical chance of renouncing ownership by mistake or accident
    function renounceOwnership(bool confirm) public virtual onlyOwner {require(confirm, "Not confirmed"); _transferOwnership(address(0));}
    function transferOwnership(address newOwner) public virtual onlyOwner {require(newOwner != address(0), "Ownable: new owner is the zero address"); _transferOwnership(newOwner);}
    function _transferOwnership(address newOwner) internal virtual {address oldOwner = _owner; _owner = newOwner; emit OwnershipTransferred(oldOwner, newOwner);}
}

// my own interface to get data from another simple contract that can be re-deployed (without affecting existing tokens of this contract) when new liquidity pools or other new price defining services appear in the future
interface PriceOracle {function getEQT_ETHprice() external view returns (uint256);}




//********************************************************************************************
//***********************      HERE STARTS THE CODE OF CONTRACT     **************************
//********************************************************************************************

contract EquivalenceProtocol is ERC20, Ownable {

    mapping(address => bool) public whitelist;
    mapping(address => uint256) internal rewardBalances;
    mapping(address => uint256) internal rewardTimestamps;
    uint256 internal constant IntendedSupply = 10 ** 26;
    uint256 internal constant MaxSupply = 10 ** 28;
    PriceOracle public EQToracle;
    uint256 public mintMode;
    uint256 public whitelistUsageCounter;
    error Minting_paused();
    error Incorrect_amount_of_ETH();
    error Minting_above_intended_supply();
    error Minting_above_maximal_supply();
    error Not_whitelisted();
    error Already_registered();
    error Supply_above_intended();
    error Not_registered();
    error Insufficient_balance();
    error Ivalid_timestamp();
    error Zero_amount();

    constructor() ERC20("Equivalence Token", "EQT") {_mint(msg.sender, 2 * 10 ** 25);}

    function addToWhitelist(address _address) external onlyOwner {whitelist[_address] = true; whitelistUsageCounter++;}
    function removeFromWhitelist(address _address) external onlyOwner {delete whitelist[_address];}
    function setOracleAddress(PriceOracle _addr) external onlyOwner {EQToracle = _addr;}
    function withdraw () external onlyOwner {
        if (address(this).balance >= 1) {payable(msg.sender).transfer(address(this).balance);}
        if (balanceOf(address(this)) >= 1) {_transfer(address(this), msg.sender, balanceOf(address(this)));}
    }
// mintMode: 0 = minting not started, 1 = temporary constant price, 2 = standard minting according to market price, 3+ = temporarily paused
    function setMintMode(uint256 _mintMode) external onlyOwner {
        if (mintMode == 0 && _mintMode == 1) {mintMode = 1;}
        if (mintMode >= 1 && _mintMode >= 2) {mintMode = _mintMode;}
    }
    function getEQTprice() public view returns (uint256) {
        uint256 price;
        if (mintMode <= 1) {
            if (totalSupply() < 25 * 10 ** 24) {price = 0.00001 ether;}
            if (totalSupply() >= 25 * 10 ** 24 && totalSupply() < 30 * 10 ** 24) {price = 0.000012 ether;}
            if (totalSupply() >= 30 * 10 ** 24) {price = 0.000015 ether;}
            } else {price = EQToracle.getEQT_ETHprice();}
        return price;
    }
// this can be unchecked, "msg.value >= 10**58" limits maximal theoretical value in calculation below maximal value of uint256, "totalSupply()" is limitted by "MaxSupply" and can't cause overflow either
    function mint() external payable { unchecked {
        if (mintMode == 0 || mintMode >= 3) {revert Minting_paused();}
        if (msg.value >= 10**58) {revert Incorrect_amount_of_ETH();}
        uint256 TokensToMint = 10 ** 18 * msg.value/getEQTprice();
        if (IntendedSupply < TokensToMint + totalSupply()) {revert Minting_above_intended_supply();}
        _mint(msg.sender, TokensToMint);
        updateRewards(msg.sender);
    }}
// calculation can be unchecked, "amount" can't be more than "MaxSupply", which mean "totalSupply() + amount" can't overflow and "amount * (totalSupply() - (15 * 10 ** 25))" also can't overflow, (it look unneccessarily complicated, but in total this optimization saves about 500 gas)
    function externalMint(address _addr, uint256 amount) external {
        if(whitelist[msg.sender]) {} else {revert Not_whitelisted();}
        unchecked {
            if (amount >= MaxSupply || totalSupply() + amount >= MaxSupply) {revert Minting_above_maximal_supply();}
            if (totalSupply() > (15 * 10 ** 25)) {amount = amount - (amount * (totalSupply() - (15 * 10 ** 25)) / (4*(totalSupply() + (15 * 10 ** 25))));}
            }
        _mint(_addr, amount);
        updateRewards(_addr);
    }
    function externalBurn(address _addr, uint256 amount) external {
        _spendAllowance(_addr, msg.sender, amount);
        _burn(_addr, amount);
        updateRewards(_addr);
    }
    function registerForRewards() external {
        if (rewardTimestamps[msg.sender] != 0) {revert Already_registered();}
        rewardBalances[msg.sender] = balanceOf(msg.sender);
        rewardTimestamps[msg.sender] = block.timestamp;
    }
    function updateRewardsManually() external {
        if (totalSupply() >= IntendedSupply) {revert Supply_above_intended();}
        if (rewardTimestamps[msg.sender] == 0) {revert Not_registered();}
        updateRewards(msg.sender);
    }

// (block.timestamp - rewardTimestamps[_addr]) is time interval in seconds, 31557600 is number of seconds per year (365.25 days), together it makes time multiplier
// 10**16 comes from ((IntendedSupply / 10 ** 18) ** 2), since it is constant I put there result directly
// (10**16 - ((totalSupply() / 10 ** 18) ** 2))) / (665 * 10 ** 14) is calculation of reward per year multiplier, for totalSupply() = 0 it is 0.15037594
// calculation can be unchecked (it saves about 3000 gas), reasons:
// totalSupply() < IntendedSupply and block.timestamp > rewardTimestamps[], this prevent underflow
// rewardBalances[] can't be more than MaxSupply (10 ** 28), overflow within the first part of calculation "rewardBalances[_addr] * (block.timestamp - rewardTimestamps[])" would take about 3*10**41 years, so I consider it impossible
// Multiplication in second part can increase the number by at most 10**16, in total: 10 ** 28 * 10**16 = 10**44, so there is still 10**33 years till overflow, which less than previous, but still most likely past the end of our universe... I consider that also impossible
    function updateRewards(address _addr) internal {if (rewardTimestamps[_addr] >= 1) {
        if(totalSupply() < IntendedSupply){
            if (block.timestamp <= rewardTimestamps[_addr]) {revert Ivalid_timestamp();}
            unchecked {_mint(_addr, ((((rewardBalances[_addr] * (block.timestamp - rewardTimestamps[_addr])) / 31557600) * (10**16 - ((totalSupply() / 10 ** 18) ** 2))) / (665 * 10 ** 14)));}
            rewardBalances[_addr] = balanceOf(_addr);
            rewardTimestamps[_addr] = block.timestamp;
        } else {
            rewardBalances[_addr] = balanceOf(_addr);
            rewardTimestamps[_addr] = block.timestamp;
        }
    }}
    function pauseRewards() external {
        if (rewardTimestamps[msg.sender] == 0) {revert Not_registered();}
        if ((totalSupply() < IntendedSupply) && (rewardBalances[msg.sender] >= 1)) {
            if (block.timestamp <= rewardTimestamps[msg.sender]) {revert Ivalid_timestamp();}
            unchecked {_mint(msg.sender, ((((rewardBalances[msg.sender] * (block.timestamp - rewardTimestamps[msg.sender])) / 31557600) * (10**16 - ((totalSupply() / 10 ** 18) ** 2))) / (665 * 10 ** 14)));}
            }
        rewardTimestamps[msg.sender] = 0;
        rewardBalances[msg.sender] = 0;
    }

// overrides to include burning of fees when total supply is greater than intended and update balance for calculation of reward for registered adresses
// calculation can be unchecked, totalSupply() > IntendedSupply makes underflow impossible, totalSupply() and amount can each be at most MaxSupply (10**28), maximal number calculation can reach is 10**56, which don't cause overflow
// burnAmount is fraction of amount and amount is at least 1, so amount - burnAmount can't cause underflow
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        if (balanceOf(owner) < amount) {revert Insufficient_balance();}
        if (amount == 0) {revert Zero_amount();}
        uint256 burnAmount;
        if (totalSupply() > IntendedSupply) {unchecked {burnAmount = amount * (totalSupply() - IntendedSupply) / (12*(totalSupply() + IntendedSupply));}}
        if (burnAmount == 0) {burnAmount = 1;}
        unchecked {amount = amount - burnAmount;}
        _burn(owner, burnAmount);
        _transfer(owner, to, amount);
        updateRewards(owner);
        updateRewards(to);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        if (balanceOf(from) < amount) {revert Insufficient_balance();}
        if (amount == 0) {revert Zero_amount();}
        uint256 burnAmount;
        if (totalSupply() > IntendedSupply) {unchecked {burnAmount = amount * (totalSupply() - IntendedSupply) / (12*(totalSupply() + IntendedSupply));}}
        if (burnAmount == 0) {burnAmount = 1;}
        _spendAllowance(from, _msgSender(), amount);
        unchecked {amount = amount - burnAmount;}
        _burn(from, burnAmount);
        _transfer(from, to, amount);
        updateRewards(from);
        updateRewards(to);
        return true;
    }
// additional transfer function to allow another address to receive exact amount regardless of fee
    function transferExactAmount(address from, address to, uint256 amount) external returns (bool) {
        if (amount == 0) {revert Zero_amount();}
        uint256 burnAmount;
        if (totalSupply() > IntendedSupply) {unchecked {burnAmount = amount * (totalSupply() - IntendedSupply) / (11*(totalSupply() + IntendedSupply));}}
        if (burnAmount == 0) {burnAmount = 1;}
        uint256 totalAmount;
        unchecked {totalAmount = amount + burnAmount;}
        if (balanceOf(from) < totalAmount) {revert Insufficient_balance();}
        _spendAllowance(from, _msgSender(), totalAmount);
        _burn(from, burnAmount);
        _transfer(from, to, amount);
        updateRewards(from);
        updateRewards(to);
        return true;
    }
}