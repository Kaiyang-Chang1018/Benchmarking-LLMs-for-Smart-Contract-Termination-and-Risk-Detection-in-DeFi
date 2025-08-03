// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC2612.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Permit.sol";

interface IERC2612 is IERC20Permit {}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.0;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
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
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/cryptography/EIP712.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    /**
     * @dev In previous versions `_PERMIT_TYPEHASH` was declared as `immutable`.
     * However, to ensure consistency with the upgradeable transpiler, we will continue
     * to reserve a slot.
     * @custom:oz-renamed-from _PERMIT_TYPEHASH
     */
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @inheritdoc IERC20Permit
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @inheritdoc IERC20Permit
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
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
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.8;

import "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant _FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(_FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._
 * _Available since v4.9 for `string`, `bytes`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.8;

import "./ECDSA.sol";
import "../ShortStrings.sol";
import "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the `_domainSeparatorV4` function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * _Available since v3.4._
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {EIP-5267}.
     *
     * _Available since v4.9._
     */
    function eip712Domain()
        public
        view
        virtual
        override
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _name.toStringWithFallback(_nameFallback),
            _version.toStringWithFallback(_versionFallback),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./IPool.sol";
import "./ICanReceiveCollateral.sol";

/// @title IActivePool Interface
/// @notice Interface for the ActivePool contract which manages the main collateral pool
interface IActivePool is IPool, ICanReceiveCollateral {
    /// @notice Emitted when the stable debt in the ActivePool is updated
    /// @param _STABLEDebt The new total stable debt amount
    event ActivePoolStableDebtUpdated(uint _STABLEDebt);

    /// @notice Emitted when the collateral balance in the ActivePool is updated
    /// @param _Collateral The new total collateral amount
    event ActivePoolCollateralBalanceUpdated(uint _Collateral);

    /// @notice Sends collateral from the ActivePool to a specified account
    /// @param _account The address of the account to receive the collateral
    /// @param _amount The amount of collateral to send
    function sendCollateral(address _account, uint _amount) external;

    /// @notice Sets the addresses of connected contracts and components
    /// @param _positionControllerAddress Address of the PositionController contract
    /// @param _positionManagerAddress Address of the PositionManager contract
    /// @param _backstopPoolAddress Address of the BackstopPool contract
    /// @param _defaultPoolAddress Address of the DefaultPool contract
    /// @param _collateralAssetAddress Address of the collateral asset token
    function setAddresses(
        address _positionControllerAddress,
        address _positionManagerAddress,
        address _backstopPoolAddress,
        address _defaultPoolAddress,
        address _collateralAssetAddress
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

// Common interface for the contracts which need internal collateral counters to be updated.
interface ICanReceiveCollateral {
    function receiveCollateral(address asset, uint amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./IActivePool.sol";
import "./ICollateralSurplusPool.sol";
import "./IDefaultPool.sol";
import "./IPriceFeed.sol";
import "./ISortedPositions.sol";
import "./IPositionManager.sol";

/// @title ICollateralController Interface
/// @notice Interface for the CollateralController contract which manages multiple collateral types and their settings
interface ICollateralController {
    /// @notice Emitted when the redemption cooldown requirement is changed
    /// @param newRedemptionCooldownRequirement The new cooldown period for redemptions
    event RedemptionCooldownRequirementChanged(uint newRedemptionCooldownRequirement);

    /// @notice Gets the address of the guardian
    /// @return The address of the guardian
    function getGuardian() external view returns (address);

    /// @notice Structure to hold redemption settings for a collateral type
    struct RedemptionSettings {
        uint256 redemptionCooldownPeriod;
        uint256 redemptionGracePeriod;
        uint256 maxRedemptionPoints;
        uint256 availableRedemptionPoints;
        uint256 redemptionRegenerationRate;
        uint256 lastRedemptionRegenerationTimestamp;
    }

    /// @notice Structure to hold loan settings for a collateral type
    struct LoanSettings {
        uint256 loanCooldownPeriod;
        uint256 loanGracePeriod;
        uint256 maxLoanPoints;
        uint256 availableLoanPoints;
        uint256 loanRegenerationRate;
        uint256 lastLoanRegenerationTimestamp;
    }

    /// @notice Enum to represent the base rate type
    enum BaseRateType {
        Global,
        Local
    }

    /// @notice Structure to hold fee settings for a collateral type
    struct FeeSettings {
        uint256 redemptionsTimeoutFeePct;
        uint256 maxRedemptionsFeePct;
        uint256 minRedemptionsFeePct;
        uint256 minBorrowingFeePct;
        uint256 maxBorrowingFeePct;
        BaseRateType baseRateType;
    }

    /// @notice Structure to hold all settings for a collateral type
    struct Settings {
        uint256 debtCap;
        uint256 decommissionedOn;
        uint256 MCR;
        uint256 CCR;
        RedemptionSettings redemptionSettings;
        LoanSettings loanSettings;
        FeeSettings feeSettings;
    }

    /// @notice Structure to represent a collateral type and its associated contracts
    struct Collateral {
        uint8 version;
        IActivePool activePool;
        ICollateralSurplusPool collateralSurplusPool;
        IDefaultPool defaultPool;
        IERC20Metadata asset;
        IPriceFeed priceFeed;
        ISortedPositions sortedPositions;
        IPositionManager positionManager;
        bool sunset;
    }

    /// @notice Structure to represent a collateral type with its settings and associated contracts
    struct CollateralWithSettings {
        string name;
        string symbol;
        uint8 decimals;
        uint8 version;
        Settings settings;
        IActivePool activePool;
        ICollateralSurplusPool collateralSurplusPool;
        IDefaultPool defaultPool;
        IERC20Metadata asset;
        IPriceFeed priceFeed;
        ISortedPositions sortedPositions;
        IPositionManager positionManager;
        bool sunset;
        uint256 availableRedemptionPoints;
        uint256 availableLoanPoints;
    }

    /// @notice Adds support for a new collateral type
    /// @param collateralAddress Address of the collateral token
    /// @param positionManagerAddress Address of the PositionManager contract
    /// @param sortedPositionsAddress Address of the SortedPositions contract
    /// @param activePoolAddress Address of the ActivePool contract
    /// @param priceFeedAddress Address of the PriceFeed contract
    /// @param defaultPoolAddress Address of the DefaultPool contract
    /// @param collateralSurplusPoolAddress Address of the CollateralSurplusPool contract
    function supportCollateral(
        address collateralAddress,
        address positionManagerAddress,
        address sortedPositionsAddress,
        address activePoolAddress,
        address priceFeedAddress,
        address defaultPoolAddress,
        address collateralSurplusPoolAddress
    ) external;

    /// @notice Gets all active collateral types
    /// @return An array of Collateral structs representing active collateral types
    function getActiveCollaterals() external view returns (Collateral[] memory);

    /// @notice Gets the unique addresses of all active collateral tokens
    /// @return An array of addresses representing active collateral token addresses
    function getUniqueActiveCollateralAddresses() external view returns (address[] memory);

    /// @notice Gets the debt cap for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return debtCap The debt cap for the specified collateral type
    function getDebtCap(address asset, uint8 version) external view returns (uint debtCap);

    /// @notice Gets the Critical Collateral Ratio (CCR) for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The CCR for the specified collateral type
    function getCCR(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the Minimum Collateral Ratio (MCR) for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The MCR for the specified collateral type
    function getMCR(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the minimum borrowing fee percentage for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The minimum borrowing fee percentage for the specified collateral type
    function getMinBorrowingFeePct(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the maximum borrowing fee percentage for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The maximum borrowing fee percentage for the specified collateral type
    function getMaxBorrowingFeePct(address asset, uint8 version) external view returns (uint);

    /// @notice Gets the minimum redemption fee percentage for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return The minimum redemption fee percentage for the specified collateral type
    function getMinRedemptionsFeePct(address asset, uint8 version) external view returns (uint);

    /// @notice Requires that the commissioning period has passed for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    function requireAfterCommissioningPeriod(address asset, uint8 version) external view;

    /// @notice Requires that a specific collateral type is active
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    function requireIsActive(address asset, uint8 version) external view;

    /// @notice Gets the Collateral struct for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return A Collateral struct representing the specified collateral type
    function getCollateralInstance(address asset, uint8 version) external view returns (ICollateralController.Collateral memory);

    /// @notice Gets the Settings struct for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return A Settings struct representing the settings for the specified collateral type
    function getSettings(address asset, uint8 version) external view returns (ICollateralController.Settings memory);

    /// @notice Gets the total collateral amount for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return assetColl The total collateral amount for the specified collateral type
    function getAssetColl(address asset, uint8 version) external view returns (uint assetColl);

    /// @notice Gets the total debt amount for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return assetDebt The total debt amount for the specified collateral type
    function getAssetDebt(address asset, uint8 version) external view returns (uint assetDebt);

    /// @notice Gets the version of a specific PositionManager
    /// @param positionManager Address of the PositionManager contract
    /// @return version The version of the specified PositionManager
    function getVersion(address positionManager) external view returns (uint8 version);

    /// @notice Checks if a specific collateral type is in Recovery Mode
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param price Current price of the collateral
    /// @return A boolean indicating whether the collateral type is in Recovery Mode
    function checkRecoveryMode(address asset, uint8 version, uint price) external returns (bool);

    /// @notice Requires that there are no undercollateralized positions across all collateral types
    function requireNoUnderCollateralizedPositions() external;

    /// @notice Checks if a given address is a valid PositionManager
    /// @param positionManager Address to check
    /// @return A boolean indicating whether the address is a valid PositionManager
    function validPositionManager(address positionManager) external view returns (bool);

    /// @notice Checks if a specific collateral type is decommissioned
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return A boolean indicating whether the collateral type is decommissioned
    function isDecommissioned(address asset, uint8 version) external view returns (bool);

    /// @notice Checks if a specific PositionManager is decommissioned and its sunset period has elapsed
    /// @param pm Address of the PositionManager
    /// @param collateral Address of the collateral token
    /// @return A boolean indicating whether the PositionManager is decommissioned and its sunset period has elapsed
    function decommissionedAndSunsetPositionManager(address pm, address collateral) external view returns (bool);

    /// @notice Gets the base rate type (Global or Local)
    /// @return The base rate type
    function getBaseRateType() external view returns (BaseRateType);

    /// @notice Gets the timestamp of the last fee operation
    /// @return The timestamp of the last fee operation
    function getLastFeeOperationTime() external view returns (uint);

    /// @notice Gets the current base rate
    /// @return The current base rate
    function getBaseRate() external view returns (uint);

    /// @notice Decays the base rate from borrowing
    function decayBaseRateFromBorrowing() external;

    /// @notice Updates the timestamp of the last fee operation
    function updateLastFeeOpTime() external;

    /// @notice Calculates the number of minutes passed since the last fee operation
    /// @return The number of minutes passed since the last fee operation
    function minutesPassedSinceLastFeeOp() external view returns (uint);

    /// @notice Calculates the decayed base rate
    /// @return The decayed base rate
    function calcDecayedBaseRate() external view returns (uint);

    /// @notice Updates the base rate from redemption
    /// @param _CollateralDrawn Amount of collateral drawn
    /// @param _price Current price of the collateral
    /// @param _totalStableSupply Total supply of stable tokens
    /// @return The updated base rate
    function updateBaseRateFromRedemption(uint _CollateralDrawn, uint _price, uint _totalStableSupply) external returns (uint);

    /// @notice Regenerates and consumes redemption points
    /// @param amount Amount of redemption points to consume
    /// @return utilizationPCT The utilization percentage after consumption
    /// @return loadIncrease The increase in load after consumption
    function regenerateAndConsumeRedemptionPoints(uint amount) external returns (uint utilizationPCT, uint loadIncrease);

    /// @notice Gets the redemption cooldown requirement for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return escrowDuration The duration of the escrow period
    /// @return gracePeriod The grace period for redemptions
    /// @return redemptionsTimeoutFeePct The fee percentage for redemption timeouts
    function getRedemptionCooldownRequirement(address asset, uint8 version) external returns (uint escrowDuration,uint gracePeriod,uint redemptionsTimeoutFeePct);

    /// @notice Calculates the redemption points at a specific timestamp for a collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param targetTimestamp The timestamp to calculate the redemption points for
    /// @return workingRedemptionPoints The redemption points at the specified timestamp
    function redemptionPointsAt(address asset, uint8 version, uint targetTimestamp) external view returns (uint workingRedemptionPoints);

    /// @notice Regenerates and consumes loan points
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param amount Amount of loan points to consume
    /// @return utilizationPCT The utilization percentage after consumption
    /// @return loadIncrease The increase in load after consumption
    function regenerateAndConsumeLoanPoints(address asset, uint8 version, uint amount) external returns (uint utilizationPCT, uint loadIncrease);

    /// @notice Gets the loan cooldown requirement for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @return escrowDuration The duration of the escrow period
    /// @return gracePeriod The grace period for loans
    function getLoanCooldownRequirement(address asset, uint8 version) external view returns (uint escrowDuration, uint gracePeriod);

    /// @notice Calculates the loan points at a specific timestamp for a collateral type
    /// @param asset Address of the collateral token
    /// @param version Version of the collateral type
    /// @param targetTimestamp The timestamp to calculate the loan points for
    /// @return workingLoanPoints The loan points at the specified timestamp
    function loanPointsAt(address asset, uint8 version, uint targetTimestamp) external view returns (uint workingLoanPoints);

    /// @notice Calculates the borrowing rate for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param baseRate The base rate to use in the calculation
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The calculated borrowing rate
    function calcBorrowingRate(address asset, uint baseRate, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Calculates the redemption rate for a specific collateral type
    /// @param asset Address of the collateral token
    /// @param baseRate The base rate to use in the calculation
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The calculated redemption rate
    function calcRedemptionRate(address asset, uint baseRate, uint suggestedAdditiveFeePCT) external view returns (uint);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./ICanReceiveCollateral.sol";

/// @title ICollateralSurplusPool Interface
/// @notice Interface for the CollateralSurplusPool contract which manages surplus collateral
interface ICollateralSurplusPool is ICanReceiveCollateral {
    /// @notice Emitted when a user's collateral balance is updated
    /// @param _account The address of the account
    /// @param _newBalance The new balance of the account
    event CollBalanceUpdated(address indexed _account, uint _newBalance);

    /// @notice Emitted when collateral is sent to an account
    /// @param _to The address receiving the collateral
    /// @param _amount The amount of collateral sent
    event CollateralSent(address _to, uint _amount);

    /// @notice Sets the addresses of connected contracts
    /// @param _positionControllerAddress Address of the PositionController contract
    /// @param _positionManagerAddress Address of the PositionManager contract
    /// @param _activePoolAddress Address of the ActivePool contract
    /// @param _collateralAssetAddress Address of the collateral asset token
    function setAddresses(address _positionControllerAddress, address _positionManagerAddress, address _activePoolAddress, address _collateralAssetAddress) external;

    /// @notice Gets the total amount of collateral in the pool
    /// @return The total amount of collateral
    function getCollateral() external view returns (uint);

    /// @notice Gets the amount of claimable collateral for a specific account
    /// @param _account The address of the account
    /// @return The amount of claimable collateral for the account
    function getUserCollateral(address _account) external view returns (uint);

    /// @notice Accounts for surplus collateral for a specific account
    /// @param _account The address of the account
    /// @param _amount The amount of surplus collateral to account for
    function accountSurplus(address _account, uint _amount) external;

    /// @notice Allows an account to claim their surplus collateral
    /// @param _account The address of the account claiming the collateral
    function claimColl(address _account) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "./IPool.sol";
import "./ICanReceiveCollateral.sol";

/// @title IDefaultPool Interface
/// @notice Interface for the DefaultPool contract which manages defaulted debt and collateral
interface IDefaultPool is IPool, ICanReceiveCollateral {
    /// @notice Emitted when the STABLE debt in the DefaultPool is updated
    /// @param _STABLEDebt The new total STABLE debt amount
    event DefaultPoolSTABLEDebtUpdated(uint _STABLEDebt);

    /// @notice Emitted when the collateral balance in the DefaultPool is updated
    /// @param _Collateral The new total collateral amount
    event DefaultPoolCollateralBalanceUpdated(uint _Collateral);

    /// @notice Sends collateral from the DefaultPool to the ActivePool
    /// @param _amount The amount of collateral to send
    function sendCollateralToActivePool(uint _amount) external;

    /// @notice Sets the addresses of connected contracts
    /// @param _positionManagerAddress Address of the PositionManager contract
    /// @param _activePoolAddress Address of the ActivePool contract
    /// @param _collateralAssetAddress Address of the collateral asset token
    function setAddresses(address _positionManagerAddress, address _activePoolAddress, address _collateralAssetAddress) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPool Interface
/// @notice Interface for Pool contracts that manage collateral and stable debt
interface IPool {
    /// @notice Emitted when collateral is sent from the pool
    /// @param _to The address receiving the collateral
    /// @param _amount The amount of collateral sent
    event CollateralSent(address _to, uint _amount);

    /// @notice Gets the total amount of collateral in the pool
    /// @return The total amount of collateral
    function getCollateral() external view returns (uint);

    /// @notice Gets the total amount of stable debt in the pool
    /// @return The total amount of stable debt
    function getStableDebt() external view returns (uint);

    /// @notice Increases the stable debt in the pool
    /// @param _amount The amount to increase the debt by
    function increaseStableDebt(uint _amount) external;

    /// @notice Decreases the stable debt in the pool
    /// @param _amount The amount to decrease the debt by
    function decreaseStableDebt(uint _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPositionManager Interface
/// @notice Interface for the PositionManager contract which manages individual positions
interface IPositionManager {
    /// @notice Emitted when a redemption occurs
    /// @param _attemptedStableAmount The amount of stable tokens attempted to redeem
    /// @param _actualStableAmount The actual amount of stable tokens redeemed
    /// @param _CollateralSent The amount of collateral sent to the redeemer
    /// @param _CollateralFee The fee paid in collateral for the redemption
    event Redemption(uint _attemptedStableAmount, uint _actualStableAmount, uint _CollateralSent, uint _CollateralFee);

    /// @notice Emitted when total stakes are updated
    /// @param _newTotalStakes The new total stakes value
    event TotalStakesUpdated(uint _newTotalStakes);

    /// @notice Emitted when system snapshots are updated
    /// @param _totalStakesSnapshot The new total stakes snapshot
    /// @param _totalCollateralSnapshot The new total collateral snapshot
    event SystemSnapshotsUpdated(uint _totalStakesSnapshot, uint _totalCollateralSnapshot);

    /// @notice Emitted when L terms are updated
    /// @param _L_Collateral The new L_Collateral value
    /// @param _L_STABLE The new L_STABLE value
    event LTermsUpdated(uint _L_Collateral, uint _L_STABLE);

    /// @notice Emitted when position snapshots are updated
    /// @param _L_Collateral The new L_Collateral value for the position
    /// @param _L_STABLEDebt The new L_STABLEDebt value for the position
    event PositionSnapshotsUpdated(uint _L_Collateral, uint _L_STABLEDebt);

    /// @notice Emitted when a position's index is updated
    /// @param _borrower The address of the position owner
    /// @param _newIndex The new index value
    event PositionIndexUpdated(address _borrower, uint _newIndex);

    /// @notice Get the total count of position owners
    /// @return The number of position owners
    function getPositionOwnersCount() external view returns (uint);

    /// @notice Get a position owner's address by index
    /// @param _index The index in the position owners array
    /// @return The address of the position owner
    function getPositionFromPositionOwnersArray(uint _index) external view returns (address);

    /// @notice Get the nominal ICR (Individual Collateral Ratio) of a position
    /// @param _borrower The address of the position owner
    /// @return The nominal ICR of the position
    function getNominalICR(address _borrower) external view returns (uint);

    /// @notice Get the current ICR of a position
    /// @param _borrower The address of the position owner
    /// @param _price The current price of the collateral
    /// @return The current ICR of the position
    function getCurrentICR(address _borrower, uint _price) external view returns (uint);

    /// @notice Liquidate a single position
    /// @param _borrower The address of the position owner to liquidate
    function liquidate(address _borrower) external;

    /// @notice Liquidate multiple positions
    /// @param _n The number of positions to attempt to liquidate
    function liquidatePositions(uint _n) external;

    /// @notice Batch liquidate a specific set of positions
    /// @param _positionArray An array of position owner addresses to liquidate
    function batchLiquidatePositions(address[] calldata _positionArray) external;

    /// @notice Queue a redemption request
    /// @param _stableAmount The amount of stable tokens to queue for redemption
    function queueRedemption(uint _stableAmount) external;

    /// @notice Redeem collateral for stable tokens
    /// @param _stableAmount The amount of stable tokens to redeem
    /// @param _firstRedemptionHint The address of the first position to consider for redemption
    /// @param _upperPartialRedemptionHint The address of the position just above the partial redemption
    /// @param _lowerPartialRedemptionHint The address of the position just below the partial redemption
    /// @param _partialRedemptionHintNICR The nominal ICR of the partial redemption hint
    /// @param _maxIterations The maximum number of iterations to perform in the redemption algorithm
    /// @param _maxFee The maximum acceptable fee percentage for the redemption
    function redeemCollateral(
        uint _stableAmount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        uint _maxFee
    ) external;

    /// @notice Update the stake and total stakes for a position
    /// @param _borrower The address of the position owner
    /// @return The new stake value
    function updateStakeAndTotalStakes(address _borrower) external returns (uint);

    /// @notice Update the reward snapshots for a position
    /// @param _borrower The address of the position owner
    function updatePositionRewardSnapshots(address _borrower) external;

    /// @notice Add a position owner to the array of position owners
    /// @param _borrower The address of the position owner
    /// @return index The index of the new position owner in the array
    function addPositionOwnerToArray(address _borrower) external returns (uint index);

    /// @notice Apply pending rewards to a position
    /// @param _borrower The address of the position owner
    function applyPendingRewards(address _borrower) external;

    /// @notice Get the pending collateral reward for a position
    /// @param _borrower The address of the position owner
    /// @return The amount of pending collateral reward
    function getPendingCollateralReward(address _borrower) external view returns (uint);

    /// @notice Get the pending stable debt reward for a position
    /// @param _borrower The address of the position owner
    /// @return The amount of pending stable debt reward
    function getPendingStableDebtReward(address _borrower) external view returns (uint);

    /// @notice Check if a position has pending rewards
    /// @param _borrower The address of the position owner
    /// @return True if the position has pending rewards, false otherwise
    function hasPendingRewards(address _borrower) external view returns (bool);

    /// @notice Get the entire debt and collateral for a position, including pending rewards
    /// @param _borrower The address of the position owner
    /// @return debt The total debt of the position
    /// @return coll The total collateral of the position
    /// @return pendingStableDebtReward The pending stable debt reward
    /// @return pendingCollateralReward The pending collateral reward
    function getEntireDebtAndColl(address _borrower)
    external view returns (uint debt, uint coll, uint pendingStableDebtReward, uint pendingCollateralReward);

    /// @notice Close a position
    /// @param _borrower The address of the position owner
    function closePosition(address _borrower) external;

    /// @notice Remove the stake for a position
    /// @param _borrower The address of the position owner
    function removeStake(address _borrower) external;

    /// @notice Get the current redemption rate
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The current redemption rate
    function getRedemptionRate(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the redemption rate with decay
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The redemption rate with decay applied
    function getRedemptionRateWithDecay(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the redemption fee with decay
    /// @param _CollateralDrawn The amount of collateral drawn
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The redemption fee with decay applied
    function getRedemptionFeeWithDecay(uint _CollateralDrawn, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the current borrowing rate
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The current borrowing rate
    function getBorrowingRate(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the borrowing rate with decay
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The borrowing rate with decay applied
    function getBorrowingRateWithDecay(uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the borrowing fee
    /// @param stableDebt The amount of stable debt
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The borrowing fee
    function getBorrowingFee(uint stableDebt, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Get the borrowing fee with decay
    /// @param _stableDebt The amount of stable debt
    /// @param suggestedAdditiveFeePCT The suggested additive fee percentage
    /// @return The borrowing fee with decay applied
    function getBorrowingFeeWithDecay(uint _stableDebt, uint suggestedAdditiveFeePCT) external view returns (uint);

    /// @notice Decay the base rate from borrowing
    function decayBaseRateFromBorrowing() external;

    /// @notice Get the status of a position
    /// @param _borrower The address of the position owner
    /// @return The status of the position
    function getPositionStatus(address _borrower) external view returns (uint);

    /// @notice Get the stake of a position
    /// @param _borrower The address of the position owner
    /// @return The stake of the position
    function getPositionStake(address _borrower) external view returns (uint);

    /// @notice Get the debt of a position
    /// @param _borrower The address of the position owner
    /// @return The debt of the position
    function getPositionDebt(address _borrower) external view returns (uint);

    /// @notice Get the collateral of a position
    /// @param _borrower The address of the position owner
    /// @return The collateral of the position
    function getPositionColl(address _borrower) external view returns (uint);

    /// @notice Set the status of a position
    /// @param _borrower The address of the position owner
    /// @param num The new status value
    function setPositionStatus(address _borrower, uint num) external;

    /// @notice Increase the collateral of a position
    /// @param _borrower The address of the position owner
    /// @param _collIncrease The amount of collateral to increase
    /// @return The new collateral amount
    function increasePositionColl(address _borrower, uint _collIncrease) external returns (uint);

    /// @notice Decrease the collateral of a position
    /// @param _borrower The address of the position owner
    /// @param _collDecrease The amount of collateral to decrease
    /// @return The new collateral amount
    function decreasePositionColl(address _borrower, uint _collDecrease) external returns (uint);

    /// @notice Increase the debt of a position
    /// @param _borrower The address of the position owner
    /// @param _debtIncrease The amount of debt to increase
    /// @return The new debt amount
    function increasePositionDebt(address _borrower, uint _debtIncrease) external returns (uint);

    /// @notice Decrease the debt of a position
    /// @param _borrower The address of the position owner
    /// @param _debtDecrease The amount of debt to decrease
    /// @return The new debt amount
    function decreasePositionDebt(address _borrower, uint _debtDecrease) external returns (uint);

    /// @notice Get the entire debt of the system
    /// @return total The total debt in the system
    function getEntireDebt() external view returns (uint total);

    /// @notice Get the entire collateral in the system
    /// @return total The total collateral in the system
    function getEntireCollateral() external view returns (uint total);

    /// @notice Get the Total Collateral Ratio (TCR) of the system
    /// @param _price The current price of the collateral
    /// @return TCR The Total Collateral Ratio
    function getTCR(uint _price) external view returns(uint TCR);

    /// @notice Check if the system is in Recovery Mode
    /// @param _price The current price of the collateral
    /// @return True if the system is in Recovery Mode, false otherwise
    function checkRecoveryMode(uint _price) external returns(bool);

    /// @notice Check if the position manager is in sunset mode
    /// @return True if the position manager is in sunset mode, false otherwise
    function isSunset() external returns(bool);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title IPriceFeed Interface
/// @notice Interface for price feed contracts that provide various price-related functionalities
interface IPriceFeed {
    /// @notice Enum to represent the current operational mode of the oracle
    enum OracleMode {AUTOMATED, FALLBACK}

    /// @notice Struct to hold detailed price information
    struct PriceDetails {
        uint lowestPrice;
        uint highestPrice;
        uint weightedAveragePrice;
        uint spotPrice;
        uint shortTwapPrice;
        uint longTwapPrice;
        uint suggestedAdditiveFeePCT;
        OracleMode currentMode;
    }

    /// @notice Fetches the current price details
    /// @param utilizationPCT The current utilization percentage
    /// @return A PriceDetails struct containing various price metrics
    function fetchPrice(uint utilizationPCT) external view returns (PriceDetails memory);

    /// @notice Fetches the weighted average price, used during liquidations
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The weighted average price
    function fetchWeightedAveragePrice(bool testLiquidity, bool testDeviation) external returns (uint price);

    /// @notice Fetches the lowest price, used when exiting escrow or testing for under-collateralized positions
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The lowest price
    function fetchLowestPrice(bool testLiquidity, bool testDeviation) external returns (uint price);

    /// @notice Fetches the lowest price with a fee suggestion, used when issuing new debt
    /// @param loadIncrease The increase in load
    /// @param originationOrRedemptionLoadPCT The origination or redemption load percentage
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The lowest price
    /// @return suggestedAdditiveFeePCT The suggested additive fee percentage
    function fetchLowestPriceWithFeeSuggestion(
        uint loadIncrease,
        uint originationOrRedemptionLoadPCT,
        bool testLiquidity,
        bool testDeviation
    ) external returns (uint price, uint suggestedAdditiveFeePCT);

    /// @notice Fetches the highest price with a fee suggestion, used during redemptions
    /// @param loadIncrease The increase in load
    /// @param originationOrRedemptionLoadPCT The origination or redemption load percentage
    /// @param testLiquidity Whether to test for liquidity
    /// @param testDeviation Whether to test for price deviation
    /// @return price The highest price
    /// @return suggestedAdditiveFeePCT The suggested additive fee percentage
    function fetchHighestPriceWithFeeSuggestion(
        uint loadIncrease,
        uint originationOrRedemptionLoadPCT,
        bool testLiquidity,
        bool testDeviation
    ) external returns (uint price, uint suggestedAdditiveFeePCT);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title ISortedPositions Interface
/// @notice Interface for a sorted list of positions, ordered by their Individual Collateral Ratio (ICR)
interface ISortedPositions {
    /// @notice Emitted when the PositionManager address is changed
    /// @param _positionManagerAddress The new address of the PositionManager
    event PositionManagerAddressChanged(address _positionManagerAddress);

    /// @notice Emitted when the PositionController address is changed
    /// @param _positionControllerAddress The new address of the PositionController
    event PositionControllerAddressChanged(address _positionControllerAddress);

    /// @notice Emitted when a new node (position) is added to the list
    /// @param _id The address of the new position
    /// @param _NICR The Nominal Individual Collateral Ratio of the new position
    event NodeAdded(address _id, uint _NICR);

    /// @notice Emitted when a node (position) is removed from the list
    /// @param _id The address of the removed position
    event NodeRemoved(address _id);

    /// @notice Sets the parameters for the sorted list
    /// @param _size The maximum size of the list
    /// @param _positionManagerAddress The address of the PositionManager contract
    /// @param _positionControllerAddress The address of the PositionController contract
    function setParams(uint256 _size, address _positionManagerAddress, address _positionControllerAddress) external;

    /// @notice Inserts a new node (position) into the list
    /// @param _id The address of the new position
    /// @param _ICR The Individual Collateral Ratio of the new position
    /// @param _prevId The address of the previous node in the insertion position
    /// @param _nextId The address of the next node in the insertion position
    function insert(address _id, uint256 _ICR, address _prevId, address _nextId) external;

    /// @notice Removes a node (position) from the list
    /// @param _id The address of the position to remove
    function remove(address _id) external;

    /// @notice Re-inserts a node (position) into the list with a new ICR
    /// @param _id The address of the position to re-insert
    /// @param _newICR The new Individual Collateral Ratio of the position
    /// @param _prevId The address of the previous node in the new insertion position
    /// @param _nextId The address of the next node in the new insertion position
    function reInsert(address _id, uint256 _newICR, address _prevId, address _nextId) external;

    /// @notice Checks if a position is in the list
    /// @param _id The address of the position to check
    /// @return bool True if the position is in the list, false otherwise
    function contains(address _id) external view returns (bool);

    /// @notice Checks if the list is full
    /// @return bool True if the list is full, false otherwise
    function isFull() external view returns (bool);

    /// @notice Checks if the list is empty
    /// @return bool True if the list is empty, false otherwise
    function isEmpty() external view returns (bool);

    /// @notice Gets the current size of the list
    /// @return uint256 The current number of positions in the list
    function getSize() external view returns (uint256);

    /// @notice Gets the maximum size of the list
    /// @return uint256 The maximum number of positions the list can hold
    function getMaxSize() external view returns (uint256);

    /// @notice Gets the first position in the list (highest ICR)
    /// @return address The address of the first position
    function getFirst() external view returns (address);

    /// @notice Gets the last position in the list (lowest ICR)
    /// @return address The address of the last position
    function getLast() external view returns (address);

    /// @notice Gets the next position in the list after a given position
    /// @param _id The address of the current position
    /// @return address The address of the next position
    function getNext(address _id) external view returns (address);

    /// @notice Gets the previous position in the list before a given position
    /// @param _id The address of the current position
    /// @return address The address of the previous position
    function getPrev(address _id) external view returns (address);

    /// @notice Checks if a given insertion position is valid for a new ICR
    /// @param _ICR The ICR of the position to insert
    /// @param _prevId The address of the proposed previous node
    /// @param _nextId The address of the proposed next node
    /// @return bool True if the insertion position is valid, false otherwise
    function validInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (bool);

    /// @notice Finds the correct insertion position for a given ICR
    /// @param _ICR The ICR of the position to insert
    /// @param _prevId A hint for the previous node
    /// @param _nextId A hint for the next node
    /// @return address The address of the previous node for insertion
    /// @return address The address of the next node for insertion
    function findInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (address, address);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC2612.sol";

/// @title IStable Interface
/// @notice Interface for the Stable token contract, extending ERC20 and ERC2612 functionality
interface IStable is IERC20, IERC2612 {
    /// @notice Mints new tokens to a specified account
    /// @param _account The address to receive the minted tokens
    /// @param _amount The amount of tokens to mint
    function mint(address _account, uint256 _amount) external;

    /// @notice Burns tokens from a specified account
    /// @param _account The address from which to burn tokens
    /// @param _amount The amount of tokens to burn
    function burn(address _account, uint256 _amount) external;

    /// @notice Transfers tokens from a sender to a pool
    /// @param _sender The address sending the tokens
    /// @param poolAddress The address of the pool receiving the tokens
    /// @param _amount The amount of tokens to transfer
    function sendToPool(address _sender, address poolAddress, uint256 _amount) external;

    /// @notice Transfers tokens for redemption escrow
    /// @param from The address sending the tokens
    /// @param to The address receiving the tokens (likely a position manager)
    /// @param amount The amount of tokens to transfer
    function transferForRedemptionEscrow(address from, address to, uint amount) external;

    /// @notice Returns tokens from a pool to a user
    /// @param poolAddress The address of the pool sending the tokens
    /// @param user The address of the user receiving the tokens
    /// @param _amount The amount of tokens to return
    function returnFromPool(address poolAddress, address user, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../interfaces/ICollateralController.sol";
import "../interfaces/IStable.sol";

/**
 * @title USDx Stable
 * @dev Implementation of a stablecoin token with additional security features and controlled minting/burning.
 * This contract extends ERC20Permit for gasless approvals and includes ReentrancyGuard for security.
 */
contract Stable is IStable, ERC20Permit {
    // Immutable addresses for key components of the system
    address public immutable backstopPoolAddress;
    address public immutable positionControllerAddress;
    ICollateralController public immutable collateralController;

    /**
     * @dev Constructor to set up the Stable token
     * @param _collateralController Address of the CollateralController contract
     * @param _backstopPoolAddress Address of the BackstopPool contract
     * @param _positionControllerAddress Address of the PositionController contract
     */
    constructor(
        address _collateralController,
        address _backstopPoolAddress,
        address _positionControllerAddress
    ) ERC20("USDx", "USDx") ERC20Permit("USDx") {
        collateralController = ICollateralController(_collateralController);
        backstopPoolAddress = _backstopPoolAddress;
        positionControllerAddress = _positionControllerAddress;
    }

    // Modifiers for access control

    modifier onlyPositionController() {
        require(msg.sender == positionControllerAddress, "Stable: Caller is not PositionController");
        _;
    }

    modifier onlyBackstopPool() {
        require(msg.sender == backstopPoolAddress, "Stable: Caller is not the BackstopPool");
        _;
    }

    modifier onlyPositionManagerOrBackstopPool() {
        require(
            collateralController.validPositionManager(msg.sender) || msg.sender == backstopPoolAddress,
            "Stable: Caller is neither PositionManager nor BackstopPool"
        );
        _;
    }

    modifier onlyPositionManager() {
        require(
            collateralController.validPositionManager(msg.sender),
            "Stable: Caller is not a valid PositionManager"
        );
        _;
    }

    /**
     * @dev Mints new tokens. Can only be called by the PositionController.
     * @param _account Address to receive the minted tokens
     * @param _amount Amount of tokens to mint
     */
    function mint(address _account, uint256 _amount) external onlyPositionController {
        _mint(_account, _amount);
    }

    /**
     * @dev Burns tokens. Can be called by PositionController, PositionManager, or BackstopPool.
     * @param _account Address from which to burn tokens
     * @param _amount Amount of tokens to burn
     */
    function burn(address _account, uint256 _amount) external {
        require(
            msg.sender == positionControllerAddress ||
            collateralController.validPositionManager(msg.sender) ||
            msg.sender == backstopPoolAddress,
            "Stable: Caller is neither PositionController nor PositionManager nor BackstopPool"
        );
        _burn(_account, _amount);
    }

    /**
     * @dev Transfers tokens for redemption escrow. Can only be called by a PositionManager.
     * @param _sender Address sending the tokens
     * @param _positionManager Address of the PositionManager (recipient)
     * @param _amount Amount of tokens to transfer
     */
    function transferForRedemptionEscrow(address _sender, address _positionManager, uint256 _amount) external override onlyPositionManager {
        _transfer(_sender, _positionManager, _amount);
    }

    /**
     * @dev Sends tokens to a pool. Can only be called by the BackstopPool.
     * @param _sender Address sending the tokens
     * @param _poolAddress Address of the pool (recipient)
     * @param _amount Amount of tokens to send
     */
    function sendToPool(address _sender, address _poolAddress, uint256 _amount) external onlyBackstopPool {
        _transfer(_sender, _poolAddress, _amount);
    }

    /**
     * @dev Returns tokens from a pool. Can be called by PositionManager or BackstopPool.
     * @param _poolAddress Address of the pool sending the tokens
     * @param _receiver Address receiving the tokens
     * @param _amount Amount of tokens to return
     */
    function returnFromPool(address _poolAddress, address _receiver, uint256 _amount) external onlyPositionManagerOrBackstopPool {
        _transfer(_poolAddress, _receiver, _amount);
    }

    /**
     * @dev Overrides the standard ERC20 transfer function with additional checks and updates
     * @param recipient Address receiving the tokens
     * @param amount Amount of tokens to transfer
     * @return success Boolean indicating whether the transfer was successful
     */
    function transfer(address recipient, uint256 amount) public override(IERC20, ERC20) returns (bool) {
        _requireValidRecipient(recipient);
        return super.transfer(recipient, amount);
    }

    /**
     * @dev Overrides the standard ERC20 transferFrom function with additional checks and updates
     * @param sender Address sending the tokens
     * @param recipient Address receiving the tokens
     * @param amount Amount of tokens to transfer
     * @return success Boolean indicating whether the transfer was successful
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override(IERC20, ERC20) returns (bool) {
        _requireValidRecipient(recipient);
        return super.transferFrom(sender, recipient, amount);
    }

    /**
     * @dev Internal function to check if a recipient is valid for token transfers
     * @param _recipient Address of the recipient
     */
    function _requireValidRecipient(address _recipient) internal view {
        require(
            _recipient != address(0) &&
            _recipient != address(this),
            "Stable: Cannot transfer tokens directly to the Stable token contract or the zero address"
        );
        require(
            _recipient != backstopPoolAddress &&
            _recipient != positionControllerAddress,
            "Stable: Cannot transfer tokens directly to the BackstopPool or PositionController"
        );
    }
}