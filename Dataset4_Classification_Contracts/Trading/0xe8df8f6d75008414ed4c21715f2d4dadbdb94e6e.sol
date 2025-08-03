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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

//        _   _____ ____
//  _ __ | | |_   _/ ___|
// | '_ \| |   | || |
// | |_) | |___| || |___
// | .__/|_____|_| \____|
// |_|
//
// t.me/pulselitecoin
// x.com/pulselitecoin

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./lib/PulseBitcoinMineable.sol";

contract PulseLitecoin is ERC20, ReentrancyGuard, PulseBitcoinMineable {
  uint256 private constant SCALE_FACTOR = 4;

  constructor() ERC20("PulseLitecoin", "pLTC") {}

  function decimals() public view virtual override returns (uint8) {
    return 12;
  }

  // @notice Start your miner
  // @param bitoshis The amount in ASIC to mine with
  function minerStart(uint256 bitoshis) external nonReentrant {
    ASIC.transferFrom(msg.sender, address(this), bitoshis);

    _minerStart(bitoshis);
  }

  // @notice End your miner
  // @param minerIndex The index of the miner on the pLTC contract
  // @param minerOwnerIndex The index of the miner on the minerOwner
  // @param minerId The minerId for the miner to end. Duh.
  // @param minerOwner The owner of the miner to end. Also Duh.
  function minerEnd(int256 minerIndex, uint256 minerOwnerIndex, uint256 minerId, address minerOwner) external nonReentrant {

    MinerCache memory miner = _minerEnd(minerIndex, minerOwnerIndex, minerId, minerOwner);

    uint256 servedDays = _currentDay() - miner.day;
    uint256 pltcMined = miner.pSatoshisMined * SCALE_FACTOR;

    // Any time after you end the miner, you can still mint pLTC.
    // If servedDays > _daysForPenalty(), The miner will lose all plsb and half asic as per the PulseBitcoin mining contract.
    // Added for pLTC, the miner loses half of the pLTC yield to the caller
    if (servedDays > _daysForPenalty()) {

      _mint(minerOwner, pltcMined / 2);
      _mint(msg.sender, pltcMined / 2);

      ASIC.transfer(minerOwner, miner.bitoshisReturned / 2);
      ASIC.transfer(msg.sender, miner.bitoshisReturned / 2);

    } else {

      _mint(minerOwner, pltcMined);

      ASIC.transfer(minerOwner, miner.bitoshisReturned);
      pBTC.transfer(minerOwner, miner.pSatoshisMined);

    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//        ____ _____ ____ __  __ _                  _     _
//  _ __ | __ )_   _/ ___|  \/  (_)_ __   ___  __ _| |__ | | ___
// | '_ \|  _ \ | || |   | |\/| | | '_ \ / _ \/ _` | '_ \| |/ _ \
// | |_) | |_) || || |___| |  | | | | | |  __/ (_| | |_) | |  __/
// | .__/|____/ |_| \____|_|  |_|_|_| |_|\___|\__,_|_.__/|_|\___|
// |_|
//
// This contract allows any contract that inherits it to mine PulseBitcoin.
// Supports recovering miners that are ended on the PulseBitcoin contract directly.

abstract contract Asic {
  event Transfer(address indexed from, address indexed to, uint256 value);

  function approve(address spender, uint256 amount) public virtual returns (bool);
  function balanceOf(address account) public view virtual returns (uint256);
  function transfer(address to, uint256 amount) public virtual returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) public virtual returns(bool);
}

abstract contract PulseBitcoin {
  uint256 public miningRate;
  uint256 public miningFee;
  uint256 public totalpSatoshisMined;
  uint256 public previousHalvingThresold;
  uint256 public currentHalvingThreshold;
  uint256 public numOfHalvings;
  uint256 public atmMultiplier;

  struct MinerStore {
    uint128 bitoshisMiner;
    uint128 bitoshisReturned;
    uint96 pSatoshisMined;
    uint96 bitoshisBurned;
    uint40 minerId;
    uint24 day;
  }

  mapping(address => MinerStore[]) public minerList;

  event Transfer(address indexed from, address indexed to, uint256 value);

  function minerCount(address minerAddress) public virtual view returns (uint256);
  function minerStart(uint256 bitoshisMiner) public virtual;
  function minerEnd(uint256 minerIndex, uint256 minerId, address minerAddr) public virtual;
  function currentDay() public virtual view returns (uint256);

  function approve(address spender, uint256 amount) public virtual returns (bool);
  function balanceOf(address account) public view virtual returns (uint256);
  function transfer(address to, uint256 amount) public virtual returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) public virtual returns(bool);
}

abstract contract PulseBitcoinMineable {
  PulseBitcoin public immutable pBTC;
  Asic public immutable ASIC;

  struct MinerStore {
    uint128 bitoshisMiner;
    uint128 bitoshisReturned;
    uint96 pSatoshisMined;
    uint96 bitoshisBurned;
    uint40 minerId;
    uint24 day;
  }

  struct MinerCache {
    uint256 bitoshisMiner;
    uint256 bitoshisReturned;
    uint256 pSatoshisMined;
    uint256 bitoshisBurned;
    uint256 minerId;
    uint256 day;
  }

  mapping(address => MinerStore[]) public minerList;

  error UnknownMiner(MinerStore[] minerList, MinerCache miner);
  error InvalidMinerId(uint256 minerId);
  error InvalidMinerIndex(uint256 minerIndex);
  error CannotEndMinerEarly(uint256 servedDays, uint256 requiredDays);

  constructor() {
    pBTC = PulseBitcoin(address(0x5EE84583f67D5EcEa5420dBb42b462896E7f8D06));
    ASIC = Asic(address(0x347a96a5BD06D2E15199b032F46fB724d6c73047));

    // Approve the pBTC contract to spend our ASIC so this contract can mine.
    ASIC.approve(address(pBTC), type(uint256).max);
  }

  // @remark -1 Is magic. It makes your function call less efficient!
  //  a minerIndex of -1 triggers the _minerEnd function to run _minerIndexSearch to find the minerIndex
  //  (which could loop quite a lot!)
  //  If you can call this function with the minerIndex, do that. 
  //  Otherwise, pass -1 & it'll do it. Just cost more. 
  //  Could potentially run into out of gas errors.

  // @notice Start the PLSB Miner.
  // @dev We store this miner as {msg.sender -> MinerCache instance}
  //   On the PLSB contract, our miners are stored as {pLTCContract -> MinerCache instance}
  //   We're duping this as {msg.sender -> MinerCache instance} so we can look it up later.
  //   See @remark -1 for details.
  function _minerStart(
    uint256 bitoshis
  ) internal returns (
    MinerCache memory
  ) {

    pBTC.minerStart(bitoshis);

    MinerCache memory miner = _minerAt(_lastMinerIndex());
    _minerAdd(minerList[msg.sender], miner);

    return miner;

  }

  // @notice End the PLSB miner
  // @param minerIndex The index of the pLTC contract miner's address on the PLSB contract
  //  This would be the miner's specific index on pLTC address. If you DON'T KNOW, specify -1. See @remark on -1
  // @param minerOwnerIndex The index of the miner's address using the pBTCMineable's address.
  //  This is the miner's ACTUAL miner. Like "who's mining"? The index above is just for saving unnessecary gas. 
  // @param minerId collected from the PLSB contract
  // @param minerOwner The owner of the miner
  // @return miner a instance of MinerCache
  function _minerEnd(
    int minerIndex,
    uint256 minerOwnerIndex,
    uint256 minerId,
    address minerOwner
  ) internal returns (
    MinerCache memory
  ) {
    
    MinerCache memory miner = _minerLoad(minerOwnerIndex, minerOwner);

    // Do we have the correct miner?
    if(miner.minerId != minerId) {
      revert InvalidMinerId(minerId);
    }

    // Try to find the miner index (This is what -1 triggers)
    if(minerIndex < 0) {
      minerIndex = _minerIndexSearch(miner);
    }

    // The miner index still wasn't found. Must've been ended already?
    if(minerIndex < 0) {

      // Make sure the miner is old enough. 
      // pBTC.minerEnd does this for us with it's minerEnd function.
      uint256 servedDays = _currentDay() - miner.day;
      if (servedDays < _miningDuration()) {
        revert CannotEndMinerEarly(servedDays, _miningDuration());
      }

    } else {

      // End the miner as per usual
      pBTC.minerEnd(uint256(minerIndex), minerId, address(this));

    }

    _minerRemove(minerList[minerOwner], miner);

    return miner;

  }

  function _minerAt(uint256 index) internal view returns (MinerCache memory) {
    (
      uint128 bitoshisMiner,
      uint128 bitoshisReturned,
      uint96 pSatoshisMined,
      uint96 bitoshisBurned,
      uint40 minerId,
      uint24 day
    ) = pBTC.minerList(address(this), index);

    return MinerCache({
      minerId: minerId,
      bitoshisMiner: bitoshisMiner,
      pSatoshisMined: pSatoshisMined,
      bitoshisBurned: bitoshisBurned,
      bitoshisReturned: bitoshisReturned,
      day: day
    });
  }

  function _minerLoad(
    uint256 minerIndex,
    address minerOwner
  ) internal view returns (
    MinerCache memory miner
  ) {
    MinerStore storage _miner = minerList[minerOwner][minerIndex];

    return MinerCache({
      minerId: _miner.minerId,
      bitoshisMiner: _miner.bitoshisMiner,
      pSatoshisMined: _miner.pSatoshisMined,
      bitoshisBurned: _miner.bitoshisBurned,
      bitoshisReturned: _miner.bitoshisReturned,
      day: _miner.day
    });
  }

  function _minerAdd(
    MinerStore[] storage minerListRef,
    MinerCache memory miner
  ) internal {
    minerListRef.push(MinerStore(
      uint128(miner.bitoshisMiner),
      uint128(miner.bitoshisReturned),
      uint96(miner.pSatoshisMined),
      uint96(miner.bitoshisBurned),
      uint40(miner.minerId),
      uint24(miner.day)
    ));
  }

  function _minerRemove(
    MinerStore[] storage minerListRef,
    MinerCache memory miner
  ) internal {
    uint256 minerListLength = minerListRef.length;

    for(uint256 i=0; i < minerListLength;) {
      if(minerListRef[i].minerId == miner.minerId) {

        uint256 lastIndex = minerListLength - 1;

        if(i != lastIndex) {
          minerListRef[i] = minerListRef[lastIndex];
        }

        minerListRef.pop();

        break;

      }

      unchecked {
        i++;
      }
    }

    // Did it remove anything?
    if(minerListRef.length == minerListLength) {
      revert UnknownMiner(minerListRef, miner);
    }
  }

  // @notice Find the minerIndex of a miner. 
  // @dev Only accessible by passing -1 as the minerIndex.
  function _minerIndexSearch(
    MinerCache memory miner
  ) internal view returns (int) {
    uint256 minerListLength = pBTC.minerCount(address(this));
    int foundMinerIndex = -1;

    for(uint256 i=0; i < minerListLength;) {
      if(_minerAt(i).minerId == miner.minerId) {
        foundMinerIndex = int(i);

        break;
      }

      unchecked {
        i++;
      }
    }

    return foundMinerIndex;
  }

  function minerCount(address minerAddress) external view returns (uint256) {
    return minerList[minerAddress].length;
  }

  function _miningDuration() internal pure returns (uint256) {
    return 30;
  }

  function _withdrawGracePeriod() internal pure returns (uint256) {
    return 30;
  }

  function _daysForPenalty() internal pure returns (uint256) {
    return _miningDuration() + _withdrawGracePeriod();
  }

  function _lastMinerIndex() internal view returns (uint256) {
    return pBTC.minerCount(address(this)) - 1;
  }

  function _currentDay() internal view returns (uint256) {
    return pBTC.currentDay();
  }
}