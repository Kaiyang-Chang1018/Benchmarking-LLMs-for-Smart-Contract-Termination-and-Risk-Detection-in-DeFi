// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.20;

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
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

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

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
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
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error ERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

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
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
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
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
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
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
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
     * `requestedDecrease`.
     *
     * NOTE: Although this function is designed to avoid double spending with {approval},
     * it can still be frontrunned, preventing any attempt of allowance reduction.
     */
    function decreaseAllowance(address spender, uint256 requestedDecrease) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < requestedDecrease) {
            revert ERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
        }
        unchecked {
            _approve(owner, spender, currentAllowance - requestedDecrease);
        }

        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from` (or `to`) is
     * the zero address. All customizations to transfers, mints, and burns should be done by overriding this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, by transferring it to address(0).
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
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
     */
    function _approve(address owner, address spender, uint256 value) internal virtual {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Alternative version of {_approve} with an optional flag that can enable or disable the Approval event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to true
     * using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
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
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.20;

import {ERC20} from "../ERC20.sol";
import {Context} from "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys a `value` amount of tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, deducting from
     * the caller's allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.20;

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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.20;

import {StorageSlot} from "./StorageSlot.sol";

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

pragma solidity ^0.8.20;

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
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
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

pragma solidity ^0.8.20;

import {Math} from "./math/Math.sol";
import {SignedMath} from "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_DIGITS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

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
                    mstore8(ptr, byte(mod(value, 10), _HEX_DIGITS))
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
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
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
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
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
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

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
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
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
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
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
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;

import {MessageHashUtils} from "./MessageHashUtils.sol";
import {ShortStrings, ShortString} from "../ShortStrings.sol";
import {IERC5267} from "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
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
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable
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
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
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
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _name which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _name.toStringWithFallback(_nameFallback);
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _version which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _version.toStringWithFallback(_versionFallback);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Strings} from "../Strings.sol";

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[EIP 191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `hash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32 digest) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(
        address validator,
        bytes memory data
    ) internal pure returns (bytes32 digest) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (EIP-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^0.8.20;

import {ECDSA} from "./ECDSA.sol";
import {IERC1271} from "../../interfaces/IERC1271.sol";

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Safe Wallet (previously Gnosis Safe).
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error, ) = ECDSA.tryRecover(hash, signature);
        return
            (error == ECDSA.RecoverError.NoError && recovered == signer) ||
            isValidERC1271SignatureNow(signer, hash, signature);
    }

    /**
     * @dev Checks if a signature is valid for a given signer and data hash. The signature is validated
     * against the signer smart contract using ERC1271.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeCall(IERC1271.isValidSignature, (hash, signature))
        );
        return (success &&
            result.length >= 32 &&
            abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

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
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
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
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

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

            uint256 twos = denominator & (0 - denominator);
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
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
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
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

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
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {HalfLifeCarbonCreditAuction} from "@/libraries/HalfLifeCarbonCreditAuction.sol";
import {ICarbonCreditAuction} from "@/interfaces/ICarbonCreditAuction.sol";
/**
 * @title CarbonCreditDescendingPriceAuction
 * @notice This contract is a reverse dutch auction for GCC.
 *         - The price has a half life of 1 week
 *         - The max that the price can grow is 2x per 24 hours
 *         - For every sale made, the price increases by the % of the total sold that the sale was
 *             - For example, if 10% of the available GCC is sold, then the price increases by 10%
 *             - If 100% of the available GCC is sold, then the price doubles
 *         - GCC is added to the pool of available GCC linearly over the course of a week
 *         - When new GCC is added, all pending vesting amounts and the new amount are vested over the course of a week
 *         - There is no cap on the amount of GCC that can be purchased in a single transaction
 *         - All GCC donations must be registered by the miner pool contract
 * @author DavidVorick
 * @author 0xSimon(twitter) -  0xSimbo(github)
 */

contract CarbonCreditDescendingPriceAuction is ICarbonCreditAuction {
    /* -------------------------------------------------------------------------- */
    /*                                   errors                                   */
    /* -------------------------------------------------------------------------- */
    error CallerNotGCC();
    error UserPriceNotHighEnough();
    error NotEnoughGCCForSale();
    error CannotBuyZeroUnits();

    /* -------------------------------------------------------------------------- */
    /*                                  constants                                 */
    /* -------------------------------------------------------------------------- */

    /// @dev The precision (magnifier) used for calculations
    uint256 private constant PRECISION = 1e8;
    /// @dev The number of seconds in a day
    uint256 private constant ONE_DAY = uint256(1 days);
    /// @dev The number of seconds in a week
    uint256 private constant ONE_WEEK = uint256(7 days);
    /**
     * @notice the amount of GCC sold within a single unit (0.000000000001 GCC)
     * @dev This is equal to 1e-12 GCC
     */
    uint256 public constant SALE_UNIT = 1e6;

    /* -------------------------------------------------------------------------- */
    /*                                 immutables                                 */
    /* -------------------------------------------------------------------------- */

    /// @notice The GLOW token
    IERC20 public immutable GLOW;
    /// @notice The GCC token
    IERC20 public immutable GCC;

    /* -------------------------------------------------------------------------- */
    /*                                 state vars                                */
    /* -------------------------------------------------------------------------- */
    /**
     * @dev a variable to keep track of the total amount of GCC that has been fully vested
     *         - it's not accurate and should only be used in conjunction with
     *             - {totalAmountReceived} to calculate the total supply
     *             - as shown in {totalSupply}
     */
    uint256 internal _pesudoTotalAmountFullyAvailableForSale;

    /// @notice The total amount of GLOW received from the miner pool
    uint256 public totalAmountReceived;

    /// @notice The total number of units of GCC sold
    uint256 public totalUnitsSold;

    /// @notice The price of GCC 24 hours ago
    ///         - this price is not accurate if there have been no sales in the last 24 hours
    ///         - it should not be relied on for accurate calculations
    uint256 public pseudoPrice24HoursAgo;

    /// @dev The price of GCC per sale unit
    /// @dev this price is not the actual price, and should be used in conjunction with {getPricePerUnit}
    uint256 internal pricePerSaleUnit;

    /// @notice The timestamps
    Timestamps public timestamps;

    /* -------------------------------------------------------------------------- */
    /*                                   structs                                  */
    /* -------------------------------------------------------------------------- */
    /**
     * @dev A struct to keep track of the timestamps all in a single slot
     * @param lastSaleTimestamp the timestamp of the last sale
     * @param lastReceivedTimestamp the timestamp of the last time GCC was received from the miner pool
     * @param lastPriceChangeTimestamp the timestamp of the last time the price changed
     */
    struct Timestamps {
        uint64 lastSaleTimestamp;
        uint64 lastReceivedTimestamp;
        uint64 lastPriceChangeTimestamp;
        uint64 firstReceivedTimestamp;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 constructor                                */
    /* -------------------------------------------------------------------------- */
    /**
     * @param glow the GLOW token
     * @param gcc the GCC token
     * @param startingPrice the starting price of 1 unit of GCC
     */
    constructor(IERC20 glow, IERC20 gcc, uint256 startingPrice) payable {
        GLOW = glow;
        GCC = gcc;
        pricePerSaleUnit = startingPrice;
        pseudoPrice24HoursAgo = startingPrice;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 buy gcc                                    */
    /* -------------------------------------------------------------------------- */

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function buyGCC(uint256 unitsToBuy, uint256 maxPricePerUnit) external {
        if (unitsToBuy == 0) {
            _revert(CannotBuyZeroUnits.selector);
        }
        Timestamps memory _timestamps = timestamps;
        uint256 _lastPriceChangeTimestamp = _timestamps.lastPriceChangeTimestamp;
        uint256 _pseudoPrice24HoursAgo = pseudoPrice24HoursAgo;
        uint256 price = getPricePerUnit();
        if (price > maxPricePerUnit) {
            _revert(UserPriceNotHighEnough.selector);
        }
        uint256 gccPurchasing = unitsToBuy * SALE_UNIT;
        uint256 glowToTransfer = unitsToBuy * price;

        uint256 totalSaleUnitsAvailable = totalSaleUnits();
        uint256 saleUnitsLeftForSale = totalSaleUnitsAvailable - totalUnitsSold;

        if (saleUnitsLeftForSale < unitsToBuy) {
            _revert(NotEnoughGCCForSale.selector);
        }

        uint256 newPrice = price + (price * (unitsToBuy * PRECISION / saleUnitsLeftForSale) / PRECISION);

        //The new price can never grow more than 100% in 24 hours
        if (newPrice * PRECISION / _pseudoPrice24HoursAgo > 2 * PRECISION) {
            newPrice = _pseudoPrice24HoursAgo * 2;
        }
        //If it's been more than a day since the last sale, then update the price
        //To the price in the current tx
        //Also update the last price change timestamp
        if (block.timestamp - _lastPriceChangeTimestamp > ONE_DAY) {
            pseudoPrice24HoursAgo = price;
            _lastPriceChangeTimestamp = block.timestamp;
        }

        //
        pricePerSaleUnit = newPrice;

        totalUnitsSold += unitsToBuy;
        timestamps = Timestamps({
            lastSaleTimestamp: uint64(block.timestamp),
            lastReceivedTimestamp: _timestamps.lastReceivedTimestamp,
            lastPriceChangeTimestamp: uint64(_lastPriceChangeTimestamp),
            firstReceivedTimestamp: _timestamps.firstReceivedTimestamp
        });
        GLOW.transferFrom(msg.sender, address(this), glowToTransfer);
        GCC.transfer(msg.sender, gccPurchasing);
    }

    /* -------------------------------------------------------------------------- */
    /*                                 receive gcc                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function receiveGCC(uint256 amount) external {
        if (msg.sender != address(GCC)) {
            _revert(CallerNotGCC.selector);
        }
        Timestamps memory _timestamps = timestamps;
        _pesudoTotalAmountFullyAvailableForSale = totalSupply();
        timestamps = Timestamps({
            lastSaleTimestamp: _timestamps.lastSaleTimestamp,
            lastReceivedTimestamp: uint64(block.timestamp),
            lastPriceChangeTimestamp: _timestamps.lastPriceChangeTimestamp,
            firstReceivedTimestamp: _timestamps.firstReceivedTimestamp == 0
                ? uint64(block.timestamp)
                : _timestamps.firstReceivedTimestamp
        });
        totalAmountReceived += amount;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 view functions                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function getPricePerUnit() public view returns (uint256) {
        Timestamps memory _timestamps = timestamps;
        uint256 _lastSaleTimestamp = _timestamps.lastSaleTimestamp;
        uint256 firstReceivedTimestamp = _timestamps.firstReceivedTimestamp;
        if (firstReceivedTimestamp == 0) {
            return pricePerSaleUnit;
        }
        if (_lastSaleTimestamp == 0) {
            _lastSaleTimestamp = firstReceivedTimestamp;
        }
        uint256 _pricePerSaleUnit = pricePerSaleUnit;
        return
            HalfLifeCarbonCreditAuction.calculateHalfLifeValue(_pricePerSaleUnit, block.timestamp - _lastSaleTimestamp);
    }

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function totalSupply() public view returns (uint256) {
        Timestamps memory _timestamps = timestamps;
        uint256 _lastReceivedTimestamp = _timestamps.lastReceivedTimestamp;
        uint256 _totalAmountReceived = totalAmountReceived;
        uint256 amountThatNeedsToVest = _totalAmountReceived - _pesudoTotalAmountFullyAvailableForSale;
        uint256 timeDiff = _min(ONE_WEEK, block.timestamp - _lastReceivedTimestamp);
        return (_pesudoTotalAmountFullyAvailableForSale + amountThatNeedsToVest * timeDiff / ONE_WEEK);
    }

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function unitsForSale() external view returns (uint256) {
        return totalSaleUnits() - totalUnitsSold;
    }

    /**
     * @inheritdoc ICarbonCreditAuction
     */
    function totalSaleUnits() public view returns (uint256) {
        return totalSupply() / (SALE_UNIT);
    }

    /* -------------------------------------------------------------------------- */
    /*                                     utils                                  */
    /* -------------------------------------------------------------------------- */
    /**
     * @param a the first number
     * @param b the second number
     * @return smaller - the smaller of the two numbers
     */
    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? b : a;
    }

    /**
     * @notice More efficiently reverts with a bytes4 selector
     * @param selector The selector to revert with
     */
    function _revert(bytes4 selector) private pure {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            mstore(0x0, selector)
            revert(0x0, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IGCC} from "@/interfaces/IGCC.sol";
import {ICarbonCreditAuction} from "@/interfaces/ICarbonCreditAuction.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {IGovernance} from "@/interfaces/IGovernance.sol";
import {CarbonCreditDescendingPriceAuction} from "@/CarbonCreditDescendingPriceAuction.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapRouterV2} from "@/interfaces/IUniswapRouterV2.sol";
import {ImpactCatalyst} from "@/ImpactCatalyst.sol";
import {IERC20Permit} from "@/interfaces/IERC20Permit.sol";
import {UniswapV2Library} from "@/libraries/UniswapV2Library.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title GCC (Glow Carbon Credit)
 * @author DavidVorick
 * @author 0xSimon(twitter) - 0xSimbo(github)
 * @notice This contract is the ERC20 token for Glow Carbon Credits (GCC).
 *         - 1 GCC or (1e18 wei of GCC) represents 1 metric ton of CO2 offsets
 *         - GCC is minted by the Glow protocol as farms produce clean solar
 *         - GCC can be committed for nominations and permanent impact power
 *         - Nominations are used to vote on proposals in governance and are in 12 decimals
 *         - Impact power is an on-chain record of the sum of total impact power earned by a user
 *         - It currently has no use, but can be used to integrate with other protocols
 *         - Once GCC is committed, it can't be uncommitted
 *         - GCC is sold in the carbon credit auction
 *          - The amount of nominations earned is equal to the sqrt(amountGCCAddedToUniV2LP * amountUSDCAddedToUniV2LP)
 *              - earned from a swap in the commitGCC or commitUSDC functions in the `impactCatalyst`
 *              - When committing USDC, the amount of nominations earned is equal to the amount of USDC committed
 */

contract GCC is ERC20, ERC20Burnable, IGCC, EIP712 {
    /* -------------------------------------------------------------------------- */
    /*                                  constants                                 */
    /* -------------------------------------------------------------------------- */
    /// @notice The EIP712 typehash for the CommitPermit struct used by the permit
    bytes32 public constant COMMIT_PERMIT_TYPEHASH = keccak256(
        "CommitPermit(address owner,address spender,address rewardAddress,address referralAddress,uint256 amount,uint256 nonce,uint256 deadline)"
    );

    /// @notice The maximum shift for a bucketId
    uint256 private constant _BITS_IN_UINT = 256;

    /* -------------------------------------------------------------------------- */
    /*                                  immutables                                */
    /* -------------------------------------------------------------------------- */
    /// @notice The address of the CarbonCreditAuction contract
    ICarbonCreditAuction public immutable CARBON_CREDIT_AUCTION;

    /// @notice The address of the GCAAndMinerPool contract
    address public immutable GCA_AND_MINER_POOL_CONTRACT;

    /// @notice the address of the governance contract
    IGovernance public immutable GOVERNANCE;

    /// @notice the address of the GLOW token
    address public immutable GLOW;

    /// @notice the address of the ImpactCatalyst contract
    /// @dev the impact catalyst is responsible for handling the commitments of GCC and USDC
    ImpactCatalyst public immutable IMPACT_CATALYST;

    /// @notice The Uniswap router
    /// @dev used to swap USDC for GCC and vice versa
    IUniswapRouterV2 public immutable UNISWAP_ROUTER;

    /// @notice The address of the USDC token
    address public immutable USDC;

    /* -------------------------------------------------------------------------- */
    /*                                   mappings                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice The bitmap of minted buckets
     * @dev key 0 contains the first 256 buckets, key 1 contains the next 256 buckets, etc.
     */
    mapping(uint256 => uint256) private _mintedBucketsBitmap;

    /**
     * @notice The total impact power earned by a user from their USDC or GCC commitments
     */
    mapping(address => uint256) public totalImpactPowerEarned;

    /**
     * @notice The allowances for committing GCC
     * @dev similar to ERC20
     */
    mapping(address => mapping(address => uint256)) private _commitGCCAllowances;

    /**
     * @notice The next commit nonce for a user
     */
    mapping(address => uint256) public nextCommitNonce;

    /* -------------------------------------------------------------------------- */
    /*                                 constructor                                */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice GCC constructor
     * @param _gcaAndMinerPoolContract The address of the GCAAndMinerPool contract
     * @param _governance The address of the governance contract
     * @param _glowToken The address of the GLOW token
     * @param _usdc The address of the USDC token
     * @param _uniswapRouter The address of the Uniswap V2 router
     */
    constructor(
        address _gcaAndMinerPoolContract,
        address _governance,
        address _glowToken,
        address _usdc,
        address _uniswapRouter
    ) payable ERC20("Glow Carbon Certificate", "GCC-BETA") EIP712("Glow Carbon Certificate", "1") {
        // Set the immutable variables
        USDC = _usdc;
        GCA_AND_MINER_POOL_CONTRACT = _gcaAndMinerPoolContract;
        UNISWAP_ROUTER = IUniswapRouterV2(_uniswapRouter);
        GOVERNANCE = IGovernance(_governance);
        GLOW = _glowToken;
        //Create the carbon credit auction directly in the constructor
        CarbonCreditDescendingPriceAuction cccAuction = new CarbonCreditDescendingPriceAuction({
            glow: IERC20(_glowToken),
            gcc: IERC20(address(this)),
            startingPrice: 1e5 // Carbon Credit Auction sells increments of 1e6 GCC,
                // Setting the price to 1e5 per unit means that 1 GCC = .1 GLOW
        });

        CARBON_CREDIT_AUCTION = ICarbonCreditAuction(address(cccAuction));
        //Create the impact catalyst
        address factory = UNISWAP_ROUTER.factory();
        address pair = getPair(factory, _usdc);
        //Mint 1 to set the LP with USDC
        //Note: On Guarded Launch the LP is set with USDG
        if (block.chainid == 1) {
            _mint(tx.origin, 1.1 ether);
        }
        //The impact catalyst is responsible for handling the commitments of GCC and USDC
        IMPACT_CATALYST = new ImpactCatalyst(_usdc, _uniswapRouter, factory, pair);
    }

    /* -------------------------------------------------------------------------- */
    /*                                   minting                                  */
    /* -------------------------------------------------------------------------- */
    /**
     * @inheritdoc IGCC
     */
    function mintToCarbonCreditAuction(uint256 bucketId, uint256 amount) external {
        if (msg.sender != GCA_AND_MINER_POOL_CONTRACT) _revert(IGCC.CallerNotGCAContract.selector);
        _setBucketMinted(bucketId);
        if (amount > 0) {
            CARBON_CREDIT_AUCTION.receiveGCC(amount);
            _mint(address(CARBON_CREDIT_AUCTION), amount);
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                                   commits                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @inheritdoc IGCC
     */
    function commitGCC(uint256 amount, address rewardAddress, address referralAddress, uint256 minImpactPower)
        public
        returns (uint256 usdcEffect, uint256 impactPower)
    {
        //Transfer GCC from the msg.sender to the impact catalyst
        _transfer(msg.sender, address(IMPACT_CATALYST), amount);
        //get back the amount of USDC that was used in the LP and the impact power earned
        (usdcEffect, impactPower) = IMPACT_CATALYST.commitGCC(amount, minImpactPower);
        //handle the commitment
        _handleCommitment(msg.sender, rewardAddress, amount, usdcEffect, impactPower, referralAddress);
    }

    /**
     * @inheritdoc IGCC
     */
    function commitGCC(uint256 amount, address rewardAddress, uint256 minImpactPower)
        external
        returns (uint256, uint256)
    {
        //Same as above, but with no referrer
        return (commitGCC(amount, rewardAddress, address(0), minImpactPower));
    }

    /**
     * @inheritdoc IGCC
     */
    function commitGCCFor(
        address from,
        address rewardAddress,
        uint256 amount,
        address referralAddress,
        uint256 minImpactPower
    ) public returns (uint256 usdcEffect, uint256 impactPower) {
        //Transfer GCC `from` to the impact catalyst
        transferFrom(from, address(IMPACT_CATALYST), amount);
        //If the msg.sender is not `from`, then check and decrease the allowance
        if (msg.sender != from) {
            _decreaseCommitAllowance(from, msg.sender, amount, false);
        }
        //get back the amount of USDC that was used in the LP and the impact power earned
        (usdcEffect, impactPower) = IMPACT_CATALYST.commitGCC(amount, minImpactPower);
        //handle the commitment
        _handleCommitment(from, rewardAddress, amount, usdcEffect, impactPower, referralAddress);
    }

    /**
     * @inheritdoc IGCC
     */
    function commitGCCFor(address from, address rewardAddress, uint256 amount, uint256 minImpactPower)
        public
        returns (uint256, uint256)
    {
        //Same as above, but with no referrer
        return (commitGCCFor(from, rewardAddress, amount, address(0), minImpactPower));
    }

    /**
     * @inheritdoc IGCC
     */
    function commitGCCForAuthorized(
        address from,
        address rewardAddress,
        uint256 amount,
        uint256 deadline,
        bytes calldata signature,
        address referralAddress,
        uint256 minImpactPower
    ) public returns (uint256, uint256) {
        //Check the deadline
        if (block.timestamp > deadline) {
            _revert(IGCC.CommitPermitSignatureExpired.selector);
        }

        //Load the next nonce
        uint256 _nextCommitNonce = nextCommitNonce[from]++;
        //Construct the message to be signed
        bytes32 message = _constructCommitPermitDigest(
            from, msg.sender, rewardAddress, referralAddress, amount, _nextCommitNonce, deadline
        );
        //Check the signature
        if (!_checkCommitPermitSignature(from, message, signature)) {
            _revert(IGCC.CommitSignatureInvalid.selector);
        }
        //Increase the allowance for the msg.sender on the `from` account
        _increaseCommitAllowance(from, msg.sender, amount, false);
        uint256 transferAllowance = allowance(from, msg.sender);
        if (transferAllowance < amount) {
            _approve(from, msg.sender, amount, false);
        }
        //Commit the GCC
        return (commitGCCFor(from, rewardAddress, amount, referralAddress, minImpactPower));
    }

    /**
     * @inheritdoc IGCC
     */
    function commitGCCForAuthorized(
        address from,
        address rewardAddress,
        uint256 amount,
        uint256 deadline,
        bytes calldata signature,
        uint256 minImpactPower
    ) external returns (uint256 usdcEffect, uint256 impactPower) {
        //Same as above, but with no referrer
        return (commitGCCForAuthorized(from, rewardAddress, amount, deadline, signature, address(0), minImpactPower));
    }

    /**
     * @inheritdoc IGCC
     */
    function commitUSDC(uint256 amount, address rewardAddress, address referralAddress, uint256 minImpactPower)
        public
        returns (uint256 impactPower)
    {
        //Read in the balance of the impact catalyst before the transfer
        uint256 impactCatalystBalBefore = IERC20(USDC).balanceOf(address(IMPACT_CATALYST));
        //Transfer USDC from the msg.sender to the impact catalyst
        IERC20(USDC).transferFrom(msg.sender, address(IMPACT_CATALYST), amount);
        //Read in the balance of the impact catalyst after the transfer
        uint256 impactCatalystBalAfter = IERC20(USDC).balanceOf(address(IMPACT_CATALYST));
        //Calculate the actual amount of USDC available from the transfer (in case of fees since USDC is upgradable)
        uint256 usdcUsing = impactCatalystBalAfter - impactCatalystBalBefore;
        //get back the impaoct power earned
        impactPower = IMPACT_CATALYST.commitUSDC(usdcUsing, minImpactPower);
        //handle the commitment
        _handleUSDCcommitment(msg.sender, rewardAddress, amount, impactPower, referralAddress);
    }

    /**
     * @inheritdoc IGCC
     */
    function commitUSDC(uint256 amount, address rewardAddress, uint256 minImpactPower) external returns (uint256) {
        //Same as above, but with no referrer
        return (commitUSDC(amount, rewardAddress, address(0), minImpactPower));
    }

    /**
     * @inheritdoc IGCC
     */
    function commitUSDCSignature(
        uint256 amount,
        address rewardAddress,
        address referralAddress,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 minImpactPower
    ) external returns (uint256 impactPower) {
        // Execute the transfer with a signed authorization
        IERC20Permit paymentToken = IERC20Permit(USDC);
        uint256 allowance = paymentToken.allowance(msg.sender, address(this));
        //Check allowance to avoid front-running issues
        if (allowance < amount) {
            paymentToken.permit(msg.sender, address(this), amount, deadline, v, r, s);
        }
        return (commitUSDC(amount, rewardAddress, referralAddress, minImpactPower));
    }

    /* -------------------------------------------------------------------------- */
    /*                        commit allowance  & allowances                      */
    /* -------------------------------------------------------------------------- */
    /// @inheritdoc IGCC
    function setAllowances(address spender, uint256 transferAllowance, uint256 committingAllowance) external {
        _approve(msg.sender, spender, transferAllowance);
        _commitGCCAllowances[msg.sender][spender] = committingAllowance;
        emit IGCC.CommitGCCAllowance(msg.sender, spender, committingAllowance);
    }

    /// @inheritdoc IGCC
    function increaseAllowances(address spender, uint256 addedValue) public {
        _approve(msg.sender, spender, allowance(msg.sender, spender) + addedValue);
        _increaseCommitAllowance(msg.sender, spender, addedValue, true);
    }

    /// @inheritdoc IGCC
    function decreaseAllowances(address spender, uint256 requestedDecrease) public {
        uint256 currentAllowance = allowance(msg.sender, spender);
        if (currentAllowance < requestedDecrease) {
            revert ERC20.ERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
        }
        unchecked {
            _approve(msg.sender, spender, currentAllowance - requestedDecrease);
        }
        _decreaseCommitAllowance(msg.sender, spender, requestedDecrease, true);
    }

    /**
     * @inheritdoc IGCC
     */
    function increaseCommitAllowance(address spender, uint256 amount) external override {
        _increaseCommitAllowance(msg.sender, spender, amount, true);
    }

    /**
     * @inheritdoc IGCC
     */
    function decreaseCommitAllowance(address spender, uint256 amount) external override {
        _decreaseCommitAllowance(msg.sender, spender, amount, true);
    }

    /* -------------------------------------------------------------------------- */
    /*                              view functions                              */
    /* -------------------------------------------------------------------------- */

    /**
     * @inheritdoc IGCC
     */
    function commitAllowance(address account, address spender) public view override returns (uint256) {
        return _commitGCCAllowances[account][spender];
    }

    /**
     * @inheritdoc IGCC
     */
    function isBucketMinted(uint256 bucketId) external view returns (bool) {
        (uint256 key, uint256 shift) = _getKeyAndShiftFromBucketId(bucketId);
        return _mintedBucketsBitmap[key] & (1 << shift) != 0;
    }

    /**
     * @notice Returns the domain separator used in the permit signature
     * @dev Should be deterministic
     * @return result The domain separator
     */
    function domainSeparatorV4() public view returns (bytes32) {
        return _domainSeparatorV4();
    }

    /* -------------------------------------------------------------------------- */
    /*                              private functions                              */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice sets the bucket as minted
     * @param bucketId the id of the bucket to set as minted
     * @dev reverts if the bucket has already been minted
     */
    function _setBucketMinted(uint256 bucketId) private {
        (uint256 key, uint256 shift) = _getKeyAndShiftFromBucketId(bucketId);
        //Can't overflow because _BITS_IN_UINT is 256
        uint256 bitmap = _mintedBucketsBitmap[key];
        if (bitmap & (1 << shift) != 0) _revert(IGCC.BucketAlreadyMinted.selector);
        _mintedBucketsBitmap[key] = bitmap | (1 << shift);
    }

    /**
     * @notice handles the storage writes and event emissions relating to committing gcc.
     * @param from the address of the account committing the credits
     * @param rewardAddress the address to receive the benefits of committing
     * @param usdcEffect - the amount of USDC added into the uniswap v2 lp position
     * @param gccCommitted the amount of GCC committed
     * @param impactPower the effect of committing on the USDC balance
     * @param referralAddress the address of the referrer (zero for no referrer)
     */
    function _handleCommitment(
        address from,
        address rewardAddress,
        uint256 gccCommitted,
        uint256 usdcEffect,
        uint256 impactPower,
        address referralAddress
    ) private {
        if (from == referralAddress) _revert(IGCC.CannotReferSelf.selector);
        //committing USDC calls syncProposals in governance to ensure that the proposals are up to date
        //This design is meant to ensure that the proposals are as up to date as possible
        GOVERNANCE.syncProposals();
        //Increase the total impact power earned by the reward address
        totalImpactPowerEarned[rewardAddress] += impactPower;
        //Grant the nominations to the reward address
        GOVERNANCE.grantNominations(rewardAddress, impactPower);
        //Emit a GCCCommitted event
        emit IGCC.GCCCommitted(from, rewardAddress, gccCommitted, usdcEffect, impactPower, referralAddress);
    }

    /**
     * @notice handles the storage writes and event emissions relating to committing USDC
     * @dev should only be used internally and by function that require a transfer of {amount} to address(this)
     * @param from the address of the account committing the credits
     * @param rewardAddress the address to receive the benefits of committing
     * @param amount the amount of USDC TO commit
     * @param referralAddress the address of the referrer (zero for no referrer)
     */
    function _handleUSDCcommitment(
        address from,
        address rewardAddress,
        uint256 amount,
        uint256 impactPower,
        address referralAddress
    ) private {
        if (from == referralAddress) _revert(IGCC.CannotReferSelf.selector);
        //committing USDC calls syncProposals in governance to ensure that the proposals are up to date
        //This design is meant to ensure that the proposals are as up to date as possible
        GOVERNANCE.syncProposals();
        //Increase the total impact power earned by the reward address
        totalImpactPowerEarned[rewardAddress] += impactPower;
        //Grant the nominations to the reward address
        GOVERNANCE.grantNominations(rewardAddress, impactPower);
        //Emit a USDCCommitted event
        emit IGCC.USDCCommitted(from, rewardAddress, amount, impactPower, referralAddress);
    }

    /**
     * @dev internal function to increase the committing allowance
     * @param from the address of the account to increase the allowance from
     * @param spender the address of the spender to increase the allowance for
     * @param amount the amount to increase the allowance by
     * @param emitEvent whether or not to emit the event
     */
    function _increaseCommitAllowance(address from, address spender, uint256 amount, bool emitEvent) private {
        if (amount == 0) {
            _revert(IGCC.MustIncreaseCommitAllowanceByAtLeastOne.selector);
        }
        uint256 currentAllowance = _commitGCCAllowances[from][spender];
        uint256 newAllowance;
        unchecked {
            newAllowance = currentAllowance + amount;
        }
        //If there was an overflow, then we set the new allowance to type(uint).max
        //Since that is where the allowance will be capped anyway
        if (newAllowance <= currentAllowance) {
            newAllowance = type(uint256).max;
        }
        _commitGCCAllowances[from][spender] = newAllowance;
        if (emitEvent) {
            emit IGCC.CommitGCCAllowance(from, spender, newAllowance);
        }
    }

    /**
     * @dev internal function to decrease the committing allowance
     * @param from the address of the account to decrease the allowance from
     * @param spender the address of the spender to decrease the allowance for
     * @param amount the amount to decrease the allowance by
     * @param emitEvent whether or not to emit the event
     * @dev underflow auto-reverts due to built in safemath
     */
    function _decreaseCommitAllowance(address from, address spender, uint256 amount, bool emitEvent) private {
        uint256 currentAllowance = _commitGCCAllowances[from][spender];

        uint256 newAllowance = currentAllowance - amount;
        _commitGCCAllowances[from][spender] = newAllowance;
        if (emitEvent) {
            emit IGCC.CommitGCCAllowance(from, spender, newAllowance);
        }
    }

    //-------------  PRIVATE UTILS  --------------------//
    /**
     * @notice Returns the key and shift for a bucketId
     * @return key The key for the bucketId
     * @return shift The shift for the bucketId
     * @dev cant overflow because _BITS_IN_UINT is 256
     * @dev no division by zero because _BITS_IN_UINT is 256
     */
    function _getKeyAndShiftFromBucketId(uint256 bucketId) private pure returns (uint256 key, uint256 shift) {
        key = bucketId / _BITS_IN_UINT;
        shift = bucketId % _BITS_IN_UINT;
    }

    /**
     * @dev Constructs a committing permit EIP712 message hash to be signed
     * @param owner The owner of the funds
     * @param spender The spender
     * @param rewardAddress - the address to receive the benefits of committing
     * @param referralAddress - the address of the referrer
     * @param amount The amount of funds
     * @param nonce The next nonce
     * @param deadline The deadline for the signature to be valid
     * @return digest The EIP712 digest
     */
    function _constructCommitPermitDigest(
        address owner,
        address spender,
        address rewardAddress,
        address referralAddress,
        uint256 amount,
        uint256 nonce,
        uint256 deadline
    ) private view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    COMMIT_PERMIT_TYPEHASH, owner, spender, rewardAddress, referralAddress, amount, nonce, deadline
                )
            )
        );
    }

    /**
     * @dev Checks if the signature provided is valid for the provided data, hash.
     * @param signer The address of the signer.
     * @param message The EIP-712 digest.
     * @param signature The signature, in bytes.
     * @return bool indicating if the signature was valid (true) or not (false).
     * @dev accounts for EIP-1271 magic values as well
     */
    function _checkCommitPermitSignature(address signer, bytes32 message, bytes memory signature)
        private
        view
        returns (bool)
    {
        return SignatureChecker.isValidSignatureNow(signer, message, signature);
    }

    /**
     * @notice Returns the univ2 pair for a given factory and token
     * @param factory The address of the univ2 factory
     * @param _usdc The address of the USDC token
     * @return pair The address of the univ2 pair of the factory and token with this contract
     */
    function getPair(address factory, address _usdc) internal view virtual returns (address) {
        return UniswapV2Library.pairFor(factory, _usdc, address(this));
    }
    /**
     * @notice More efficiently reverts with a bytes4 selector
     * @param selector The selector to revert with
     */

    function _revert(bytes4 selector) internal pure {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            mstore(0x0, selector)
            revert(0x0, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {GCC} from "@/GCC.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IVetoCouncil} from "@/interfaces/IVetoCouncil.sol";
import {UniswapV2Library} from "@/libraries/UniswapV2Library.sol";

/**
 * @title GCCGuardedLaunch
 * @notice This contract is used to guard the launch of the GCC token
 *               - GLOW Protocol's guarded launch is meant to protect the protocol from
 *                 malicious actors and to give the community time to audit the code
 *               - During the guarded launch, transfers are restricted to EOA's and allowlisted contracts
 *               - The veto council also has the ability to permanently freeze transfers in case of an emergency
 *                   - Post guarded-launch, Guarded Launch tokens will be airdropped 1:1 to GCC holders
 */
contract GCCGuardedLaunch is GCC {
    error ErrIsContract();
    error ErrNotVetoCouncilMember();
    error ErrPermanentlyFrozen();

    /* -------------------------------------------------------------------------- */
    /*                                  immutables                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice The address of the USDG contract
     */
    address public immutable VETO_COUNCIL_ADDRESS;

    /* -------------------------------------------------------------------------- */
    /*                                 state vars                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice true if transfers are permanently frozen
     */
    bool public permanentlyFreezeTransfers;

    /**
     * @notice address -> isAllowListedContract
     */
    mapping(address => bool) public allowlistedContracts;

    /* -------------------------------------------------------------------------- */
    /*                                   events                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Emitted when the contract is permanently frozen
     */
    event PermanentFreeze();

    /* -------------------------------------------------------------------------- */
    /*                                 constructor                                */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice GCC constructor
     * @param _gcaAndMinerPoolContract The address of the GCAAndMinerPool contract
     * @param _governance The address of the governance contract
     * @param _glowToken The address of the GLOW token
     * @param _usdg The address of the USDG token
     * @param _vetoCouncilAddress The address of the veto council contract
     * @param _uniswapRouter The address of the Uniswap V2 router
     * @param _uniswapFactory The address of the Uniswap V2 factory
     */
    constructor(
        address _gcaAndMinerPoolContract,
        address _governance,
        address _glowToken,
        address _usdg,
        address _vetoCouncilAddress,
        address _uniswapRouter,
        address _uniswapFactory
    ) payable GCC(_gcaAndMinerPoolContract, _governance, _glowToken, _usdg, _uniswapRouter) {
        VETO_COUNCIL_ADDRESS = _vetoCouncilAddress;
        allowlistedContracts[address(this)] = true;
        allowlistedContracts[getPair(_uniswapFactory, _usdg)] = true;
    }

    /* -------------------------------------------------------------------------- */
    /*                                  veto council                              */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice Freezes transfers permanently
     * @dev only veto council members can call this function
     * @dev after this function is called, all transfers are permanently frozen
     */
    function freezeContract() external {
        if (!IVetoCouncil(VETO_COUNCIL_ADDRESS).isCouncilMember(msg.sender)) {
            revert ErrNotVetoCouncilMember();
        }
        permanentlyFreezeTransfers = true;
        emit PermanentFreeze();
    }

    /* -------------------------------------------------------------------------- */
    /*                               one time setters                             */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice Allowlist contracts that are created after the contract is deployed
     * @dev this includes [CarbonCreditAuction, ImpactCatalyst]
     */
    function allowlistPostConstructionContracts() external {
        allowlistedContracts[address(CARBON_CREDIT_AUCTION)] = true;
        allowlistedContracts[address(IMPACT_CATALYST)] = true;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 erc20 override                              */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev override transfers to make sure that only EOA's and allowlisted contracts can send or receive USDG
     * @param from the address to send USDG from
     * @param to the address to send USDG to
     * @param value the amount of USDG to send
     */
    function _update(address from, address to, uint256 value) internal override(ERC20) {
        if (permanentlyFreezeTransfers) {
            revert ErrPermanentlyFrozen();
        }
        if (!_isZeroAddress(from)) {
            _revertIfNotAllowlistedContract(from);
            _revertIfNotAllowlistedContract(to);
        }
        super._update(from, to, value);
    }

    /* -------------------------------------------------------------------------- */
    /*                                  utils                              */
    /* -------------------------------------------------------------------------- */
    /**
     * @dev reverts if the address is a contract and not allowlisted
     */
    function _revertIfNotAllowlistedContract(address _address) internal view {
        if (_isContract(_address)) {
            if (!allowlistedContracts[_address]) {
                revert ErrIsContract();
            }
        }
    }

    /**
     * @dev returns true if the address is a contract
     * @param _address the address to check
     * @return isContract - true if the address is a contract
     */
    function _isContract(address _address) internal view returns (bool isContract) {
        assembly {
            isContract := gt(extcodesize(_address), 0)
        }
    }

    /**
     * @notice More efficient address(0) check
     */
    function _isZeroAddress(address _address) internal pure returns (bool isZero) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            isZero := iszero(_address)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IUniswapRouterV2} from "@/interfaces/IUniswapRouterV2.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Pair} from "@/interfaces/IUniswapV2Pair.sol";
import {UniswapV2Library} from "@/libraries/UniswapV2Library.sol";
/**
 * @title ImpactCatalyst
 * @notice A contract for managing the GCC and USDC commitment
 *         A commitment is when a user `donates` their GCC or USDC to the GCC-USDC pool
 *         to increase the liquidity of the pool and earn nominations
 *         For each commit, `amount` of GCC or USDC is swapped for the other token
 *         for the optimal amount such that the return amount of the other token
 *         is exactly enough to add liquidity to the GCC-USDC pool without any leftover of either token
 *         (precision errors may have small dust)
 *         - Nominations are granted as (sqrt(amountGCCUsedInLiquidityPosition * amountUSDCUsedInLiquidityPosition))
 *                 - or as the amount of liquidity tokens created from adding liquidity to the GCC-USDC pool
 *         - This is done to battle the quadratic nature of K in the UniswapV2Pair contract and standardize nominations
 * @dev only the GCC contract can call this contract since GCC is the only contract that is allowed to grant nominations
 * - having the catalyst calls be open would lead to commitment that would not earn any impact points / rewards / nominations
 */

contract ImpactCatalyst {
    /* -------------------------------------------------------------------------- */
    /*                                   errors                                   */
    /* -------------------------------------------------------------------------- */
    error CallerNotGCC();
    error PrecisionLossLeadToUnderflow();
    error NotEnoughImpactPowerFromCommitment();

    /* -------------------------------------------------------------------------- */
    /*                                  constants                                 */
    /* -------------------------------------------------------------------------- */
    /// @dev the magnification of GCC to use in {findOptimalAmountToSwap} to reduce precision loss
    /// @dev GCC is in 18 decimals, so we can make it 1e18 to reduce precision loss
    uint256 private constant GCC_MAGNIFICATION = 1e18;

    /// @dev the magnification of USDC to use in {findOptimalAmountToSwap} to reduce precision loss
    /// @dev USDC is in 6 decimals, so we can make it 1e24 to reduce precision loss
    uint256 private constant USDC_MAGNIFICATION = 1e24;

    /* -------------------------------------------------------------------------- */
    /*                                 immutables                                 */
    /* -------------------------------------------------------------------------- */

    /// @notice the GCC token
    address public immutable GCC;

    /// @notice the USDC token
    address public immutable USDC;

    /// @notice the uniswap router
    IUniswapRouterV2 public immutable UNISWAP_ROUTER;

    /// @notice the uniswap factory
    address public immutable UNISWAP_V2_FACTORY;

    /// @notice the uniswap pair of GCC and USDC
    address public immutable UNISWAP_V2_PAIR;

    /* -------------------------------------------------------------------------- */
    /*                                 constructor                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @param _usdc - the address of the USDC token
     * @param router - the address of the uniswap router
     * @param factory - the address of the uniswap factory
     * @param pair - the address of the uniswap pair of GCC and USDC
     */
    constructor(address _usdc, address router, address factory, address pair) payable {
        GCC = msg.sender;
        USDC = _usdc;
        UNISWAP_ROUTER = IUniswapRouterV2(router);
        UNISWAP_V2_FACTORY = factory;
        UNISWAP_V2_PAIR = pair;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 gcc commits                                */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice entry point for GCC to commit GCC
     * @dev the commit process is as follows:
     *         1. GCC is swapped for USDC
     *         2. GCC and USDC are added to the GCC-USDC pool
     *         3. The user receives impact points and nominations (handled in GCC contract)
     *     - The point is to commit the GCC while adding liquidity to increase incentives for farms
     * @param amount the amount of GCC to commit
     * @param minImpactPower the minimum amount of impact power expected to be earned from the commitment
     * @return usdcEffect - the amount of USDC used in the LP Position
     * @return nominations - the amount of nominations to earn sqrt(amountGCCUsedInLiquidityPosition * amountUSDCUsedInLiquidityPosition)
     *                        - we do this to battle the quadratic nature of K in the UniswapV2Pair contract and standardize nominations
     */
    function commitGCC(uint256 amount, uint256 minImpactPower)
        external
        returns (uint256 usdcEffect, uint256 nominations)
    {
        // Commitments can only be made through the GCC contract
        if (msg.sender != GCC) {
            _revert(CallerNotGCC.selector);
        }
        // Find the reserves of GCC and USDC in the GCC-USDC pool
        (uint256 reserveA, uint256 reserveB,) = IUniswapV2Pair(UNISWAP_V2_PAIR).getReserves();
        //Find the reserve of GCC and USDC in the GCC-USDC pool
        uint256 reserveGCC = GCC < USDC ? reserveA : reserveB;

        // Find the optimal amount of GCC to swap for USDC
        // This ensures that the return amount of USDC after the swap
        // Should be exactly enough to add liquidity to the GCC-USDC pool with the remainder of `amount` of GCC left over
        uint256 amountToSwap =
            findOptimalAmountToSwap(amount * GCC_MAGNIFICATION, reserveGCC * GCC_MAGNIFICATION) / GCC_MAGNIFICATION;

        //Approve the GCC token to be spent by the router
        IERC20(GCC).approve(address(UNISWAP_ROUTER), amount);
        //Create the path for the swap
        address[] memory path = new address[](2);
        path[0] = GCC;
        path[1] = USDC;
        //Swap the GCC for USDC

        // If impact power = sqrt(amountGCCUsedInLiquidityPosition * amountUSDCUsedInLiquidityPosition)
        // square both sides, and we get impact power ^ 2 = amountGCCUsedInLiquidityPosition * amountUSDCUsedInLiquidityPosition
        // so we can find the minimum amount of USDC expected from the swap by doing
        // minimumUSDCExpected = (minImpactPower * minImpactPower) / (amount - amountToSwap)
        // since amount - amountToSwap is the expected amount of GCC used in the liquidity position
        uint256 minimumUSDCExpected = (minImpactPower * minImpactPower) / (amount - amountToSwap);
        uint256[] memory amounts = UNISWAP_ROUTER.swapExactTokensForTokens({
            amountIn: amountToSwap,
            // we allow for a 1% slippage based on the minimum impact power,
            // due to potential rounding errors in the findOptimalAmountToSwap function
            amountOutMin: minimumUSDCExpected * 99 / 100,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });

        //Find how much USDC was received from the swap
        uint256 amountUSDCReceived = amounts[1];
        //Approve the USDC token to be spent by the router
        IERC20(USDC).approve(address(UNISWAP_ROUTER), amountUSDCReceived);
        uint256 amountToAddInLiquidity = amount - amounts[0];

        // Add liquidity to the GCC-USDC pool
        // Note: There could be a tax due to USDC Upgrades, and there could also be ERC777 type upgrades,
        // When glow relaunches after the guarded launch, this will be accounted for
        (uint256 actualAmountGCCUsedInLP, uint256 actualAmountUSDCUsedInLP,) = UNISWAP_ROUTER.addLiquidity({
            tokenA: GCC,
            tokenB: USDC,
            amountADesired: amountToAddInLiquidity,
            amountBDesired: amountUSDCReceived,
            // we allow for a 1% slippage due to potential rounding errors
            // This seems high, but it's simply a precaution to prevent the transaction from reverting
            // The bulk of the calculation happens in the logic above
            amountAMin: amountToAddInLiquidity * 99 / 100,
            amountBMin: amountUSDCReceived * 99 / 100,
            to: address(this),
            deadline: block.timestamp
        });

        uint256 actualImpactPowerEarned = sqrt(actualAmountGCCUsedInLP * actualAmountUSDCUsedInLP);
        usdcEffect = actualAmountUSDCUsedInLP;
        if (actualImpactPowerEarned < minImpactPower) {
            _revert(NotEnoughImpactPowerFromCommitment.selector);
        }

        // Set usdcEffect to the amount of USDC used in the liquidity position
        // set the nominations to sqrt(amountGCCUsedInLiquidityPosition * amountUSDCUsedInLiquidityPosition)
        nominations = actualImpactPowerEarned;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 usdc commits                               */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice entry point for GCC to commit USDC
     * @dev the commit process is as follows:
     *         1. USDC is swapped for GCC
     *         2. GCC and USDC are added to the GCC-USDC pool
     *         3. The user receives impact points and nominations (handled in GCC contract)
     * @param amount the amount of USDC to commit
     * @param minImpactPower the minimum amount of impact power expected to be earned from the commitment
     * @return nominations - the amount of nominations to earn sqrt(amountGCCUsedInLiquidityPosition * amountUSDCUsedInLiquidityPosition)
     *                        - we do this to battle the quadratic nature of K in the UniswapV2Pair contract and standardize nominations
     */
    function commitUSDC(uint256 amount, uint256 minImpactPower) external returns (uint256 nominations) {
        // Commitments can only be made through the GCC contract
        if (msg.sender != GCC) {
            _revert(CallerNotGCC.selector);
        }
        // Find the reserves of GCC and USDC in the GCC-USDC pool
        (uint256 reserveA, uint256 reserveB,) = IUniswapV2Pair(UNISWAP_V2_PAIR).getReserves();
        // Find the reserve of GCC and USDC in the GCC-USDC pool
        uint256 reserveUSDC = USDC < GCC ? reserveA : reserveB;
        // Find the optimal amount of USDC to swap for GCC
        // This ensures that the the return amount of GCC after the swap
        // Should be exactly enough to add liquidity to the GCC-USDC pool with the remainder of `amount`  USDC left over
        uint256 optimalSwapAmount =
            findOptimalAmountToSwap(amount * USDC_MAGNIFICATION, reserveUSDC * USDC_MAGNIFICATION) / USDC_MAGNIFICATION;

        //Approve the USDC token to be spent by the router
        IERC20(USDC).approve(address(UNISWAP_ROUTER), amount);
        //Create the path for the swap
        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = GCC;

        // If impact power = sqrt(amountGCCUsedInLiquidityPosition * amountUSDCUsedInLiquidityPosition)
        // square both sides, and we get impact power ^ 2 = amountGCCUsedInLiquidityPosition * amountUSDCUsedInLiquidityPosition
        // so we can find the minimum amount of GCC expected from the swap by doing
        // minimumGCCExpected = (minImpactPower * minImpactPower) / (amount - optimalSwapAmount)
        // since amount - optimalSwapAmount is the expected amount of USDC used in the liquidity position
        uint256 minimumGCCExpected = (minImpactPower * minImpactPower) / (amount - optimalSwapAmount);

        // Swap the USDC for GCC
        uint256[] memory amounts = UNISWAP_ROUTER.swapExactTokensForTokens({
            amountIn: optimalSwapAmount,
            // we allow for a 1% slippage based on the minimum impact power,
            // due to potential rounding errors in the findOptimalAmountToSwap function
            amountOutMin: minimumGCCExpected * 99 / 100,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });
        // Approve the GCC token to be spent by the router
        IERC20(GCC).approve(address(UNISWAP_ROUTER), amounts[1]);

        uint256 amountToAddInLiquidity = amount - amounts[0];

        // Add liquidity to the GCC-USDC pool
        // Note: There could be a tax due to USDC Upgrades, and there could also be ERC777 type upgrades,
        // When glow relaunches after the guarded launch, this will be accounted for
        (uint256 actualAmountUSDCUsedInLP, uint256 actualAmountGCCUsedInLP,) = UNISWAP_ROUTER.addLiquidity({
            tokenA: USDC,
            tokenB: GCC,
            amountADesired: amountToAddInLiquidity,
            amountBDesired: amounts[1],
            // we allow for a 1% slippage due to potential rounding errors
            // This seems high, but it's simply a precaution to prevent the transaction from reverting
            // The bulk of the calculation happens in the logic above
            amountAMin: amountToAddInLiquidity * 99 / 100,
            amountBMin: amounts[1] * 99 / 100,
            to: address(this),
            deadline: block.timestamp
        });

        uint256 actualImpactPowerEarned = sqrt(actualAmountGCCUsedInLP * actualAmountUSDCUsedInLP);
        if (actualImpactPowerEarned < minImpactPower) {
            _revert(NotEnoughImpactPowerFromCommitment.selector);
        }

        nominations = actualImpactPowerEarned;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 view functions                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice a helper function to estimate the impact power expected from a GCC commit
     * @dev there may be a slight difference between the actual impact power earned and the estimated impact power
     *     - A max .5% divergence should be accounted for when using this function
     * @param amount the amount of GCC to commit
     * @return expectedImpactPower - the amount of impact power expected to be earned from the commitment
     */
    function estimateUSDCCommitImpactPower(uint256 amount) external view returns (uint256 expectedImpactPower) {
        uint256 expectedImpactPower = _estimateUSDCCommitImpactPower(amount);
        return expectedImpactPower;
    }

    /**
     * @notice a helper function to estimate the impact power expected from a USDC commit
     * @dev there may be a slight difference between the actual impact power earned and the estimated impact power
     *     - A max .5% divergence should be accounted for when using this function
     * @param amount the amount of USDC to commit
     * @return expectedImpactPower - the amount of impact power expected to be earned from the commitment
     */
    function estimateGCCCommitImpactPower(uint256 amount) external view returns (uint256 expectedImpactPower) {
        uint256 expectedImpactPower = _estimateGCCCommitImpactPower(amount);
        return expectedImpactPower;
    }

    /**
     * @notice helper function to find the optimal amount of tokens to swap
     * @param amountTocommit the amount of tokens to commit
     * @param totalReservesOfToken the total reserves of the token to commit
     * @return optimalAmount - the optimal amount of tokens to swap
     */
    function findOptimalAmountToSwap(uint256 amountTocommit, uint256 totalReservesOfToken)
        public
        view
        returns (uint256)
    {
        uint256 a = sqrt(totalReservesOfToken) + 1; //adjust for div round down errors
        uint256 b = sqrt(3988000 * amountTocommit + 3988009 * totalReservesOfToken);
        uint256 c = 1997 * totalReservesOfToken;
        uint256 d = 1994;
        if (c > a * b) _revert(PrecisionLossLeadToUnderflow.selector); // prevent underflow
        uint256 res = ((a * b) - c) / d;
        return res;
    }

    /* -------------------------------------------------------------------------- */
    /*                               internal view funcs                          */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice returns {optimalSwapAmount, amountToAddInLiquidity, impactPowerExpected} for an USDC commit
     * @param amount the amount of USDC to commit
     * @dev there may be a slight difference between the actual impact power earned and the estimated impact power
     *     - A max .5% divergence should be accounted for when using this function
     * @return impactPowerExpected - the amount of impact power expected to be earned from the commitment
     */
    function _estimateUSDCCommitImpactPower(uint256 amount) internal view returns (uint256 impactPowerExpected) {
        // Get the reserves of GCC and USDC in the GCC-USDC pool
        (uint256 reserveA, uint256 reserveB,) = IUniswapV2Pair(UNISWAP_V2_PAIR).getReserves();
        // Get GCC Reserve
        uint256 reserveGCC = GCC < USDC ? reserveA : reserveB;
        // Get USDC Reserve
        uint256 reserveUSDC = USDC < GCC ? reserveA : reserveB;

        // Calculate the optimal amount of USDC to swap for GCC
        uint256 optimalSwapAmount =
            findOptimalAmountToSwap(amount * USDC_MAGNIFICATION, reserveUSDC * USDC_MAGNIFICATION) / USDC_MAGNIFICATION;

        // Since we commit USDC, we want to simulate how much GCC we would get from the swap
        // This is also the same amount of GCC that will be used to add liquidity to the GCC-USDC pool
        uint256 gccEstimate = UniswapV2Library.getAmountOut(optimalSwapAmount, reserveUSDC, reserveGCC);

        // This is the amount of USDC to add in the LP, which is the amount-optimalSwapAmount
        // This number represents the balance of USDC after the swap
        uint256 amountUSDCToAddInLiquidity = amount - optimalSwapAmount;

        // The new reserves of GCC and USDC after the swap
        // We add the optimalSwapAmount to USDC, since we used it to swap for GCC
        // and, we subtract the gccEstimate from GCC, since it was used when we swapped our USDC
        uint256 reserveUSDC_afterSwap = reserveUSDC + optimalSwapAmount;
        uint256 reserveGCC_afterSwap = reserveGCC - gccEstimate;

        uint256 amountGCCOptimal =
            UniswapV2Library.quote(amountUSDCToAddInLiquidity, reserveUSDC_afterSwap, reserveGCC_afterSwap);

        if (amountGCCOptimal <= gccEstimate) {
            return sqrt(amountGCCOptimal * amountUSDCToAddInLiquidity);
        } else {
            uint256 amountUSDCOptimal = UniswapV2Library.quote(gccEstimate, reserveGCC_afterSwap, reserveUSDC_afterSwap);
            return sqrt(gccEstimate * amountUSDCOptimal);
        }
    }

    /**
     * @notice returns {optimalSwapAmount, amountToAddInLiquidity, impactPowerExpected} for a GCC commit
     * @param amount the amount of GCC to commit
     * @dev there may be a slight difference between the actual impact power earned and the estimated impact power
     *     - A max .5% divergence should be accounted for when using this function
     * @return impactPowerExpected - the amount of impact power expected to be earned from the commitment
     */
    function _estimateGCCCommitImpactPower(uint256 amount) internal view returns (uint256 impactPowerExpected) {
        //Get the reserves of GCC and USDC in the GCC-USDC pool
        (uint256 reserveA, uint256 reserveB,) = IUniswapV2Pair(UNISWAP_V2_PAIR).getReserves();

        // Get GCC Reserve
        uint256 reserveGCC = GCC < USDC ? reserveA : reserveB;
        // Get USDC Reserve
        uint256 reserveUSDC = USDC < GCC ? reserveA : reserveB;

        // Calculate the optimal amount of GCC to swap for USDC
        uint256 optimalSwapAmount =
            findOptimalAmountToSwap(amount * GCC_MAGNIFICATION, reserveGCC * GCC_MAGNIFICATION) / GCC_MAGNIFICATION;

        // Since we commit GCC, we want to simulate how much USDC we would get from the swap
        uint256 usdcEstimate = UniswapV2Library.getAmountOut(optimalSwapAmount, reserveGCC, reserveUSDC);

        //This is the amount of GCC to add in the LP, which is the amount-optimalSwapAmount
        uint256 amountGCCToAddInLiquidity = amount - optimalSwapAmount;

        // The new reserves of GCC and USDC after the swap
        // We add the optimalSwapAmount to GCC reserves, since we used it to swap for USDC
        // and, we subtract the usdcEstimate from USDC reserves, since it was used when we swapped our GCC
        uint256 reserveGCC_afterSwap = reserveGCC + optimalSwapAmount;
        uint256 reserveUSDC_afterSwap = reserveUSDC - usdcEstimate;

        uint256 amountUSDCOptimal =
            UniswapV2Library.quote(amountGCCToAddInLiquidity, reserveGCC_afterSwap, reserveUSDC_afterSwap);

        if (amountUSDCOptimal <= usdcEstimate) {
            impactPowerExpected = sqrt(amountGCCToAddInLiquidity * amountUSDCOptimal);
            return impactPowerExpected;
        } else {
            uint256 amountGCCOptimal = UniswapV2Library.quote(usdcEstimate, reserveUSDC_afterSwap, reserveGCC_afterSwap);
            impactPowerExpected = sqrt(usdcEstimate * amountGCCOptimal);
            return impactPowerExpected;
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                                    utils                                   */
    /* -------------------------------------------------------------------------- */
    /// @dev forked from solady library
    /// @param x - the number to calculate the square root of
    /// @return z - the square root of x
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let y := x // We start y at x, which will help us make our initial estimate.

            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // We check y >= 2^(k + 8) but shift right by k bits
            // each branch to ensure that if x >= 256, then y >= 256.
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }

            // Goal was to get z*z*y within a small factor of x. More iterations could
            // get y in a tighter range. Currently, we will have y in [256, 256*2^16).
            // We ensured y >= 256 so that the relative difference between y and y+1 is small.
            // That's not possible if x < 256 but we can just verify those cases exhaustively.

            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8), and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of sqrt(x), or about 20bps.

            // For s in the range [1/256, 256], the estimate f(s) = (181/1024) * (s+1) is in the range
            // (1/2.84 * sqrt(s), 2.84 * sqrt(s)), with largest error when s = 1 and when s = 256 or 1/256.

            // Since y is in [256, 256*2^16), let a = y/65536, so that a is in [1/256, 256). Then we can estimate
            // sqrt(y) using sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2^18.

            // There is no overflow risk here since y < 2^136 after the first branch above.
            z := shr(18, mul(z, add(y, 65536))) // A mul() is saved from starting z at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    /**
     * @notice returns the minimum of two numbers
     * @param a - the first number
     * @param b - the second number
     * @return the minimum of a and b
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @notice More efficiently reverts with a bytes4 selector
     * @param selector The selector to revert with
     */

    function _revert(bytes4 selector) private pure {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            mstore(0x0, selector)
            revert(0x0, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICarbonCreditAuction {
    /* -------------------------------------------------------------------------- */
    /*                                   state-changing                           */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice receives GCC from the miner pool
     * @param amount the amount of GCC to receive
     * @dev this function can only be called by the miner pool contract
     */
    function receiveGCC(uint256 amount) external;
    /**
     * @notice purchases {unitsToBuy} units of GCC at a maximum price of {maxPricePerUnit} GLOW per unit
     * @param unitsToBuy the number of units to buy
     * @param maxPricePerUnit the maximum price per unit that the user is willing to pay
     */
    function buyGCC(uint256 unitsToBuy, uint256 maxPricePerUnit) external;

    /* -------------------------------------------------------------------------- */
    /*                                 view functions                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice returns the price per unit of GCC
     */
    function getPricePerUnit() external view returns (uint256);

    /**
     * @notice returns the total supply of GCC available for sale in WEI
     * @dev this is not to be confused with the total units of GCC available for sale
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice returns the number of units of GCC available for sale
     */
    function unitsForSale() external view returns (uint256);

    /**
     * @notice returns the cumulative total number of units of GCC that have been sold or are available for sale
     */
    function totalSaleUnits() external view returns (uint256);
}
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Permit is IERC20 {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGCC is IERC20 {
    /* -------------------------------------------------------------------------- */
    /*                                   errors                                  */
    /* -------------------------------------------------------------------------- */
    error CallerNotGCAContract();
    error BucketAlreadyMinted();
    error CommitPermitSignatureExpired();
    error CommitSignatureInvalid();
    error CommitAllowanceUnderflow();
    error MustIncreaseCommitAllowanceByAtLeastOne();
    error CannotReferSelf();
    /* -------------------------------------------------------------------------- */
    /*                                   structs                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @param lastUpdatedTimestamp - the last timestamp a user earned or used nominations
     * @ param amount - the amount of nominations a user has
     */
    struct Nominations {
        uint64 lastUpdatedTimestamp;
        uint192 amount;
    }

    /* -------------------------------------------------------------------------- */
    /*                                   events                                  */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice is emitted when a user commits credits
     * @param account the account that committed credits
     * @param rewardAddress the address that earned the credits and nominations
     * @param gccAmount the amount of credits committed
     * @param usdcEffect the amount of USDC effect
     * @param impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     * @param referralAddress the address that referred the account
     *             - zero address if no referral
     */
    event GCCCommitted(
        address indexed account,
        address indexed rewardAddress,
        uint256 gccAmount,
        uint256 usdcEffect,
        uint256 impactPower,
        address referralAddress
    );

    /**
     * @notice is emitted when a user commits USDC
     * @param account the account that commit the USDC
     * @param rewardAddress the address that earns nominations
     * @param amount the amount of USDC commit
     * @param impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     * @param referralAddress the address that referred the account
     *             - zero address if no referral
     */
    event USDCCommitted(
        address indexed account,
        address indexed rewardAddress,
        uint256 amount,
        uint256 impactPower,
        address referralAddress
    );

    /**
     * @notice is emitted when a user approves a spender to commit credits on their behalf
     * @param account the account that approved a spender
     * @param spender the address of the spender
     * @param value -  new total allowance
     */
    event CommitGCCAllowance(address indexed account, address indexed spender, uint256 value);

    /* -------------------------------------------------------------------------- */
    /*                                   commits                                  */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice allows a user to commit credits
     * @param amount the amount of credits to commit
     * @param rewardAddress the address to commit the credits to
     *     -   Rewards Address earns:
     *     -       1.  Carbon Neutrality
     *     -       2.  Nominations
     * @param minImpactPower - the minimum amount of impact power to receive from the commitment
     * @return usdcEffect the amount of USDC used in the LP position
     * @return impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     */
    function commitGCC(uint256 amount, address rewardAddress, uint256 minImpactPower)
        external
        returns (uint256 usdcEffect, uint256 impactPower);

    /**
     * @notice allows a user to commit credits
     * @param amount the amount of credits to commit
     * @param rewardAddress the address to commit the credits to
     *     -   Rewards Address earns:
     *     -       1.  Carbon Neutrality
     *     -       2.  Nominations
     * @param referralAddress the address that referred the account
     * @param minImpactPower - the minimum amount of impact power to receive from the commitment
     *
     * @return usdcEffect the amount of USDC used in the LP position
     * @return impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     */
    function commitGCC(uint256 amount, address rewardAddress, address referralAddress, uint256 minImpactPower)
        external
        returns (uint256 usdcEffect, uint256 impactPower);

    /**
     * @notice the entry point for an approved entity to commit credits on behalf of a user
     * @param from the address of the user to commit credits from
     * @param rewardAddress the address of the reward address to commit credits to
     *         - Carbon Neutrality
     *         - Nominations
     * @param amount the amount of credits to commit
     * @param minImpactPower - the minimum amount of impact power to receive from the commitment
     *
     * @return usdcEffect the amount of USDC used in the LP position
     * @return impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     */
    function commitGCCFor(address from, address rewardAddress, uint256 amount, uint256 minImpactPower)
        external
        returns (uint256, uint256);

    /**
     * @notice the entry point for an approved entity to commit credits on behalf of a user
     * @param from the address of the user to commit credits from
     * @param rewardAddress the address of the reward address to commit credits to
     *         - Carbon Neutrality
     *         - Nominations
     * @param amount the amount of credits to commit
     * @param referralAddress - the address that referred the account
     * @param usdcEffect the amount of USDC used in the LP position
     * @param minImpactPower - the minimum amount of impact power to receive from the commitment
     *
     * @param impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     */
    function commitGCCFor(
        address from,
        address rewardAddress,
        uint256 amount,
        address referralAddress,
        uint256 minImpactPower
    ) external returns (uint256 usdcEffect, uint256 impactPower);

    /**
     * @notice the entry point for an approved entity to commit credits on behalf of a user using EIP712 signatures
     * @param from the address of the user to commit credits from
     * @param rewardAddress the address of the reward address to commit credits to
     *         - Carbon Neutrality
     *         - Nominations
     * @param amount the amount of credits to commit
     * @param deadline the deadline for the signature
     * @param signature - the signature
     * @param minImpactPower - the minimum amount of impact power to receive from the commitment
     *
     * @return usdcEffect the amount of USDC used in the LP position
     * @return impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     */
    function commitGCCForAuthorized(
        address from,
        address rewardAddress,
        uint256 amount,
        uint256 deadline,
        bytes calldata signature,
        uint256 minImpactPower
    ) external returns (uint256 usdcEffect, uint256 impactPower);

    /**
     * @notice the entry point for an approved entity to commit credits on behalf of a user using EIP712 signatures
     * @param from the address of the user to commit credits from
     * @param rewardAddress the address of the reward address to commit credits to
     *         - Carbon Neutrality
     *         - Nominations
     * @param amount the amount of credits to commit
     * @param deadline the deadline for the signature
     * @param signature - the signature
     * @param referralAddress - the address that referred the account
     * @param minImpactPower - the minimum amount of impact power to receive from the commitment
     *
     * @return usdcEffect the amount of USDC used in the LP position
     * @return impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     */
    function commitGCCForAuthorized(
        address from,
        address rewardAddress,
        uint256 amount,
        uint256 deadline,
        bytes calldata signature,
        address referralAddress,
        uint256 minImpactPower
    ) external returns (uint256 usdcEffect, uint256 impactPower);

    /**
     * @notice Allows a user to commit USDC
     * @param amount the amount of USDC to commit
     * @param rewardAddress the address to commit the USDC to
     * @param referralAddress the address that referred the account
     * @param minImpactPower - the minimum amount of impact power to receive from the commitment
     *
     * @return impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     */
    function commitUSDC(uint256 amount, address rewardAddress, address referralAddress, uint256 minImpactPower)
        external
        returns (uint256 impactPower);

    /**
     * @notice Allows a user to commit USDC
     * @param amount the amount of USDC to commit
     * @param rewardAddress the address to commit the USDC to
     * @param minImpactPower - the minimum amount of impact power to receive from the commitment
     *
     * @return impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     */
    function commitUSDC(uint256 amount, address rewardAddress, uint256 minImpactPower)
        external
        returns (uint256 impactPower);

    /**
     * @notice Allows a user to commit USDC using permit
     * @param amount the amount of USDC to commit
     * @param rewardAddress the address to commit the USDC to
     * @param referralAddress the address that referred the account
     * @param deadline the deadline for the signature
     * @param v the v value of the signature for permit
     * @param r the r value of the signature for permit
     * @param s the s value of the signature for permit
     * @param minImpactPower - the minimum amount of impact power to receive from the commitment
     *
     * @return impactPower - sqrt(amount gcc used in lp * amountc usdc used in lp) aka nominations granted
     */
    function commitUSDCSignature(
        uint256 amount,
        address rewardAddress,
        address referralAddress,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 minImpactPower
    ) external returns (uint256 impactPower);

    /* -------------------------------------------------------------------------- */
    /*                                   minting                                  */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice allows gca contract to mint GCC to the carbon credit auction
     * @dev must callback to the carbon credit auction contract so it can organize itself
     * @dev a bucket can only be minted from once
     * @param bucketId the id of the bucket to mint from
     * @param amount the amount of GCC to mint
     */
    function mintToCarbonCreditAuction(uint256 bucketId, uint256 amount) external;

    /* -------------------------------------------------------------------------- */
    /*                                   view functions                                  */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice returns a boolean indicating if the bucket has been minted
     * @return if the bucket has been minted
     */
    function isBucketMinted(uint256 bucketId) external view returns (bool);

    /**
     * @notice direct setter to set transfer allowance and committing allowance in one transaction for a {spender}
     * @param spender the address of the spender to set the allowances for
     * @param transferAllowance the amount of transfer allowance to set
     * @param committingAllowance the amount of committing allowance to set
     */
    function setAllowances(address spender, uint256 transferAllowance, uint256 committingAllowance) external;

    /**
     * @notice approves a spender to commit credits on behalf of the caller
     * @param spender the address of the spender
     * @param amount the amount of credits to approve
     */
    function increaseCommitAllowance(address spender, uint256 amount) external;

    /**
     * @notice decreases a spender's allowance to commit credits on behalf of the caller
     * @param spender the address of the spender
     * @param amount the amount of credits to decrease the allowance by
     */
    function decreaseCommitAllowance(address spender, uint256 amount) external;

    /**
     * @notice allows a user to increase the erc20 and committing allowance of a spender in one transaction
     * @param spender the address of the spender
     * @param addedValue the amount of credits to increase the allowance by
     */
    function increaseAllowances(address spender, uint256 addedValue) external;

    /**
     * @notice allows a user to decrease the erc20 and committing allowance of a spender in one transaction
     * @param spender the address of the spender
     * @param requestedDecrease the amount of credits to decrease the allowance by
     */
    function decreaseAllowances(address spender, uint256 requestedDecrease) external;

    /**
     * @notice returns the committing allowance for a user
     * @param account the address of the account to check
     * @param spender the address of the spender to check
     * @return the committing allowance
     */
    function commitAllowance(address account, address spender) external view returns (uint256);

    /**
     * @notice returns the next nonce to be used when committing credits
     *         - only applies when the user is using EIP712 signatures similar to Permit
     * @param account the address of the account to check
     */
    function nextCommitNonce(address account) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGovernance {
    /* -------------------------------------------------------------------------- */
    /*                                   errors                                   */
    /* -------------------------------------------------------------------------- */
    error ProposalHasNotExpired(uint256 proposalId);
    error ProposalExpired();
    error InsufficientNominations();
    error GCAContractAlreadySet();
    error CallerNotGCA();
    error CallerNotGCC();
    error CallerNotVetoCouncilMember();
    error ZeroAddressNotAllowed();
    error ContractsAlreadySet();
    error NominationCostGreaterThanAllowance();
    error ProposalDoesNotExist();
    error WeekNotStarted();
    error WeekNotFinalized();
    error InsufficientRatifyOrRejectVotes();
    error RatifyOrRejectPeriodEnded();
    error RatifyOrRejectPeriodNotEnded();
    error MostPopularProposalNotSelected();
    error ProposalAlreadyVetoed();
    error AlreadyEndorsedWeek();
    error OnlyGCAElectionsCanBeEndorsed();
    error MaxGCAEndorsementsReached();
    error VetoCouncilElectionsCannotBeVetoed();
    error GCACouncilElectionsCannotBeVetoed();
    error ProposalsMustBeExecutedSynchonously();
    error ProposalNotInitialized();
    error RFCPeriodNotEnded();
    error ProposalAlreadyExecuted();
    error ProposalIdDoesNotMatchMostPopularProposal();
    error ProposalNotMostPopular();
    error VetoCouncilProposalCreationOldMemberCannotEqualNewMember();
    error MaximumNumberOfGCAS();
    error InvalidSpendNominationsOnProposalSignature();

    error MaxSlashesInGCAElection();
    error SpendNominationsOnProposalSignatureExpired();
    error ProposalIsVetoed();
    error VetoMemberCannotBeNullAddress();
    error WeekMustHaveEndedToAcceptRatifyOrRejectVotes();

    /* -------------------------------------------------------------------------- */
    /*                                    enums                                   */
    /* -------------------------------------------------------------------------- */
    enum ProposalType {
        NONE, //default value for unset proposals
        VETO_COUNCIL_ELECTION_OR_SLASH,
        GCA_COUNCIL_ELECTION_OR_SLASH,
        GRANTS_PROPOSAL,
        CHANGE_GCA_REQUIREMENTS,
        REQUEST_FOR_COMMENT
    }

    enum ProposalStatus {
        NONE,
        EXECUTED_WITH_ERROR,
        EXECUTED_SUCCESSFULLY,
        VETOED
    }

    /* -------------------------------------------------------------------------- */
    /*                                   structs                                  */
    /* -------------------------------------------------------------------------- */
    /**
     * @param proposalType the type of the proposal
     * @param expirationTimestamp the timestamp at which the proposal expires
     * @param data the data of the proposal
     */
    struct Proposal {
        ProposalType proposalType;
        uint64 expirationTimestamp;
        uint184 votes;
        bytes data;
    }

    /* -------------------------------------------------------------------------- */
    /*                                   events                                   */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice Emitted when a Veto Council Election or Slash proposal is created
     * @param proposalId the id of the proposal
     * @param proposer the address of the proposer
     * @param oldAgent the address of the old agent
     * @param newAgent the address of the new agent
     * @param slashOldAgent whether or not to slash the old agent
     * @param nominationsUsed the amount of nominations used
     */
    event VetoCouncilElectionOrSlash(
        uint256 indexed proposalId,
        address indexed proposer,
        address oldAgent,
        address newAgent,
        bool slashOldAgent,
        uint256 nominationsUsed
    );

    /**
     * @notice Emitted when a GCA Council Election or Slash proposal is created
     * @param proposalId the id of the proposal
     * @param proposer the address of the proposer
     * @param agentsToSlash the addresses of the agents to slash
     * @param newGCAs the addresses of the new GCAs
     * @param proposalCreationTimestamp the timestamp at which the proposal was created
     *         -   This is necessary due to the proposalHashes logic in GCA
     * @param nominationsUsed the amount of nominations used
     */
    event GCACouncilElectionOrSlashCreation(
        uint256 indexed proposalId,
        address indexed proposer,
        address[] agentsToSlash,
        address[] newGCAs,
        uint256 proposalCreationTimestamp,
        uint256 nominationsUsed
    );

    /**
     * @notice emitted when a grants proposal is created
     * @param proposalId the id of the proposal
     * @param proposer the address of the proposer
     * @param recipient the address of the recipient
     * @param amount the amount of tokens to send
     * @param hash the hash of the proposal contents
     * @param nominationsUsed the amount of nominations used
     */
    event GrantsProposalCreation(
        uint256 indexed proposalId,
        address indexed proposer,
        address recipient,
        uint256 amount,
        bytes32 hash,
        uint256 nominationsUsed
    );

    /**
     * @notice emitted when a proposal to change the GCA requirements is created
     * @param proposalId the id of the proposal
     * @param proposer the address of the proposer
     * @param requirementsHash the hash of the requirements
     * @param nominationsUsed the amount of nominations used
     */
    event ChangeGCARequirementsProposalCreation(
        uint256 indexed proposalId, address indexed proposer, bytes32 requirementsHash, uint256 nominationsUsed
    );

    /**
     * @notice emitted when a request for comment is created
     * @param proposalId the id of the proposal
     * @param proposer the address of the proposer
     * @param rfcHash the hash of the requirements string
     * @param nominationsUsed the amount of nominations used
     */
    event RFCProposalCreation(
        uint256 indexed proposalId, address indexed proposer, bytes32 rfcHash, uint256 nominationsUsed
    );

    /**
     * @notice emitted when a long glow staker casts a ratify vote on a proposal
     * @param proposalId the id of the proposal
     * @param voter the address of the voter
     * @param numVotes the number of ratify votes
     */
    event RatifyCast(uint256 indexed proposalId, address indexed voter, uint256 numVotes);

    /**
     * @notice emitted when a long glow staker casts a reject vote on a proposal
     * @param proposalId the id of the proposal
     * @param voter the address of the voter
     * @param numVotes the number of reject votes
     */
    event RejectCast(uint256 indexed proposalId, address indexed voter, uint256 numVotes);

    /**
     * @notice emitted when nominations are used on a proposal
     * @param proposalId the id of the proposal
     * @param spender the address of the spender
     * @param amount the amount of nominations used
     */
    event NominationsUsedOnProposal(uint256 indexed proposalId, address indexed spender, uint256 amount);

    /**
     * @notice emitted when a proposal is set as the most popular proposal at a week
     * @param weekId - the weekId in which the proposal was selected as the most popular proposal
     * @param proposalId - the id of the proposal that was selected as the most popular proposal
     */
    event MostPopularProposalSet(uint256 indexed weekId, uint256 indexed proposalId);

    /**
     * @notice emitted when a proposal is ratified
     * @param weekId - the weekId in which the proposal to be vetoed was selected as the most popular proposal
     * @param vetoer - the address of the veto council member who vetoed the proposal
     * @param proposalId - the id of the proposal that was vetoed
     */
    event ProposalVetoed(uint256 indexed weekId, address indexed vetoer, uint256 proposalId);

    /**
     * @notice emitted when an rfc proposal is executed succesfully.
     * - RFC Proposals don't change the state of the system, so rather than performing state changes
     *         - we emit an event to alert that the proposal was executed succesfully
     *         - and that the rfc requires attention
     * @param proposalId - the id of the proposal from which the rfc was created
     * @param requirementsHash - the hash of the requirements string
     */
    event RFCProposalExecuted(uint256 indexed proposalId, bytes32 requirementsHash);

    /**
     * @notice emitted when a proposal is executed  for the week
     * @param week - the week for which the proposal was the most popular proposal
     * @param proposalId - the id of the proposal that was executed
     * @param proposalType - the type of the proposal that was executed
     * @param success - whether or not the proposal was executed succesfully
     */
    event ProposalExecution(uint256 indexed week, uint256 proposalId, ProposalType proposalType, bool success);

    /**
     * @notice Allows the GCC contract to grant nominations to {to} when they retire GCC
     * @param to the address to grant nominations to
     * @param amount the amount of nominations to grant
     */
    function grantNominations(address to, uint256 amount) external;

    /**
     * @notice Executes a most popular proposal at a given week
     * @dev a proposal that has not been ratified or rejected can be executed
     *         - but should never make any changes to the system (exceptions are detailed in the implementation)
     * @dev proposals that have met their requirements to perform state changes are executed as well
     * @dev no execution of any proposal should ever revert as this will freeze the governance contract
     * @param weekId the weekId that containst the 'mostPopularProposal' at that week
     * @dev proposals must be executed synchronously to ensure that the state of the system is consistent
     */
    function executeProposalAtWeek(uint256 weekId) external;

    /**
     * @notice syncs all proposals that must be synced
     */
    function syncProposals() external;

    /**
     * @notice allows a veto council member to endorse a gca election
     * @param weekId the weekId of the gca election to endorse
     */
    function endorseGCAProposal(uint256 weekId) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IUniswapRouterV2 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function factory() external view returns (address);
}
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVetoCouncil {
    /* -------------------------------------------------------------------------- */
    /*                                   errors                                    */
    /* -------------------------------------------------------------------------- */
    error CallerNotGovernance();
    error NoRewards();
    error ZeroAddressInConstructor();
    error MaxCouncilMembersExceeded();

    /* -------------------------------------------------------------------------- */
    /*                                   events                                    */
    /* -------------------------------------------------------------------------- */

    /**
     * @param oldMember The address of the member to be slashed or removed
     * @param newMember The address of the new member (0 = no new member)
     * @param slashOldMember Whether to slash the member or not
     */
    event VetoCouncilSeatsEdited(address indexed oldMember, address indexed newMember, bool slashOldMember);

    /**
     * @dev emitted when a council member is paid out
     * @param account The address of the council member
     * @param amountNow The amount paid out now
     * @param amountToBeVested The amount to be vested
     */
    event CouncilMemberPayout(address indexed account, uint256 amountNow, uint256 amountToBeVested);
    /* -------------------------------------------------------------------------- */
    /*                                 state-changing                             */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice Add or remove a council member
     * @param oldMember The address of the member to be slashed or removed
     * @param newMember The address of the new member (0 = no new member)
     * @param slashOldMember Whether to slash the member or not
     * @return - true if the council member was added or removed, false if nothing was done
     *                 - the function should return false if the new member is already a council member
     *                 - if the old member is not a council member, the function should return false
     *                 - if the old member is a council member and the new member is the same as the old member, the function should return false
     *                 - by adding a new member there would be more than 7 council members, the function should return false
     */

    function addAndRemoveCouncilMember(address oldMember, address newMember, bool slashOldMember)
        external
        returns (bool);

    /**
     * @notice Payout the council member
     * @param member The address of the council member
     * @param nonce The payout nonce to claim from
     * @param sync Whether to sync the vesting schedule or not
     * @param members The addresses of the council members that were active at `nonce`
     */
    function claimPayout(address member, uint256 nonce, bool sync, address[] memory members) external;

    /* -------------------------------------------------------------------------- */
    /*                                   view                                    */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice returns true if the member is a council member
     * @param member The address of the member to be checked
     * @return - true if the member is a council member
     */
    function isCouncilMember(address member) external view returns (bool);
}
// SPDX-License-Identifier: BSD-4-Clause
/*
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
pragma solidity ^0.8.0;

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
library ABDKMath64x64 {
    /*
    * Minimum value signed 64.64-bit fixed point number may have. 
    */
    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

    /*
    * Maximum value signed 64.64-bit fixed point number may have. 
    */
    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * Convert signed 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromInt(int256 x) internal pure returns (int128) {
        unchecked {
            require(x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
            return int128(x << 64);
        }
    }

    /**
     * Convert signed 64.64 fixed point number into signed 64-bit integer number
     * rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64-bit integer number
     */
    function toInt(int128 x) internal pure returns (int64) {
        unchecked {
            return int64(x >> 64);
        }
    }

    /**
     * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromUInt(uint256 x) internal pure returns (int128) {
        unchecked {
            require(x <= 0x7FFFFFFFFFFFFFFF);
            return int128(int256(x << 64));
        }
    }

    /**
     * Convert signed 64.64 fixed point number into unsigned 64-bit integer
     * number rounding down.  Revert on underflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return unsigned 64-bit integer number
     */
    function toUInt(int128 x) internal pure returns (uint64) {
        unchecked {
            require(x >= 0);
            return uint64(uint128(x >> 64));
        }
    }

    /**
     * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
     * number rounding down.  Revert on overflow.
     *
     * @param x signed 128.128-bin fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function from128x128(int256 x) internal pure returns (int128) {
        unchecked {
            int256 result = x >> 64;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Convert signed 64.64 fixed point number into signed 128.128 fixed point
     * number.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 128.128 fixed point number
     */
    function to128x128(int128 x) internal pure returns (int256) {
        unchecked {
            return int256(x) << 64;
        }
    }

    /**
     * Calculate x + y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function add(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) + y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x - y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sub(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) - y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x * y rounding down.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function mul(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) * y >> 64;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
     * number and y is signed 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y signed 256-bit integer number
     * @return signed 256-bit integer number
     */
    function muli(int128 x, int256 y) internal pure returns (int256) {
        unchecked {
            if (x == MIN_64x64) {
                require(
                    y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                        && y <= 0x1000000000000000000000000000000000000000000000000
                );
                return -y << 63;
            } else {
                bool negativeResult = false;
                if (x < 0) {
                    x = -x;
                    negativeResult = true;
                }
                if (y < 0) {
                    y = -y; // We rely on overflow behavior here
                    negativeResult = !negativeResult;
                }
                uint256 absoluteResult = mulu(x, uint256(y));
                if (negativeResult) {
                    require(absoluteResult <= 0x8000000000000000000000000000000000000000000000000000000000000000);
                    return -int256(absoluteResult); // We rely on overflow behavior here
                } else {
                    require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                    return int256(absoluteResult);
                }
            }
        }
    }

    /**
     * Calculate x * y rounding down, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y unsigned 256-bit integer number
     * @return unsigned 256-bit integer number
     */
    function mulu(int128 x, uint256 y) internal pure returns (uint256) {
        unchecked {
            if (y == 0) return 0;

            require(x >= 0);

            uint256 lo = (uint256(int256(x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
            uint256 hi = uint256(int256(x)) * (y >> 128);

            require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            hi <<= 64;

            require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
            return hi + lo;
        }
    }

    /**
     * Calculate x / y rounding towards zero.  Revert on overflow or when y is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function div(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            require(y != 0);
            int256 result = (int256(x) << 64) / y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are signed 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x signed 256-bit integer number
     * @param y signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divi(int256 x, int256 y) internal pure returns (int128) {
        unchecked {
            require(y != 0);

            bool negativeResult = false;
            if (x < 0) {
                x = -x; // We rely on overflow behavior here
                negativeResult = true;
            }
            if (y < 0) {
                y = -y; // We rely on overflow behavior here
                negativeResult = !negativeResult;
            }
            uint128 absoluteResult = divuu(uint256(x), uint256(y));
            if (negativeResult) {
                require(absoluteResult <= 0x80000000000000000000000000000000);
                return -int128(absoluteResult); // We rely on overflow behavior here
            } else {
                require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int128(absoluteResult); // We rely on overflow behavior here
            }
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divu(uint256 x, uint256 y) internal pure returns (int128) {
        unchecked {
            require(y != 0);
            uint128 result = divuu(x, y);
            require(result <= uint128(MAX_64x64));
            return int128(result);
        }
    }

    /**
     * Calculate -x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function neg(int128 x) internal pure returns (int128) {
        unchecked {
            require(x != MIN_64x64);
            return -x;
        }
    }

    /**
     * Calculate |x|.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function abs(int128 x) internal pure returns (int128) {
        unchecked {
            require(x != MIN_64x64);
            return x < 0 ? -x : x;
        }
    }

    /**
     * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function inv(int128 x) internal pure returns (int128) {
        unchecked {
            require(x != 0);
            int256 result = int256(0x100000000000000000000000000000000) / x;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function avg(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            return int128((int256(x) + int256(y)) >> 1);
        }
    }

    /**
     * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
     * Revert on overflow or in case x * y is negative.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function gavg(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 m = int256(x) * int256(y);
            require(m >= 0);
            require(m < 0x4000000000000000000000000000000000000000000000000000000000000000);
            return int128(sqrtu(uint256(m)));
        }
    }

    /**
     * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y uint256 value
     * @return signed 64.64-bit fixed point number
     */
    function pow(int128 x, uint256 y) internal pure returns (int128) {
        unchecked {
            bool negative = x < 0 && y & 1 == 1;

            uint256 absX = uint128(x < 0 ? -x : x);
            uint256 absResult;
            absResult = 0x100000000000000000000000000000000;

            if (absX <= 0x10000000000000000) {
                absX <<= 63;
                while (y != 0) {
                    if (y & 0x1 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    if (y & 0x2 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    if (y & 0x4 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    if (y & 0x8 != 0) {
                        absResult = absResult * absX >> 127;
                    }
                    absX = absX * absX >> 127;

                    y >>= 4;
                }

                absResult >>= 64;
            } else {
                uint256 absXShift = 63;
                if (absX < 0x1000000000000000000000000) {
                    absX <<= 32;
                    absXShift -= 32;
                }
                if (absX < 0x10000000000000000000000000000) {
                    absX <<= 16;
                    absXShift -= 16;
                }
                if (absX < 0x1000000000000000000000000000000) {
                    absX <<= 8;
                    absXShift -= 8;
                }
                if (absX < 0x10000000000000000000000000000000) {
                    absX <<= 4;
                    absXShift -= 4;
                }
                if (absX < 0x40000000000000000000000000000000) {
                    absX <<= 2;
                    absXShift -= 2;
                }
                if (absX < 0x80000000000000000000000000000000) {
                    absX <<= 1;
                    absXShift -= 1;
                }

                uint256 resultShift = 0;
                while (y != 0) {
                    require(absXShift < 64);

                    if (y & 0x1 != 0) {
                        absResult = absResult * absX >> 127;
                        resultShift += absXShift;
                        if (absResult > 0x100000000000000000000000000000000) {
                            absResult >>= 1;
                            resultShift += 1;
                        }
                    }
                    absX = absX * absX >> 127;
                    absXShift <<= 1;
                    if (absX >= 0x100000000000000000000000000000000) {
                        absX >>= 1;
                        absXShift += 1;
                    }

                    y >>= 1;
                }

                require(resultShift < 64);
                absResult >>= 64 - resultShift;
            }
            int256 result = negative ? -int256(absResult) : int256(absResult);
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate sqrt (x) rounding down.  Revert if x < 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sqrt(int128 x) internal pure returns (int128) {
        unchecked {
            require(x >= 0);
            return int128(sqrtu(uint256(int256(x)) << 64));
        }
    }

    /**
     * Calculate binary logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function log_2(int128 x) internal pure returns (int128) {
        unchecked {
            require(x > 0);

            int256 msb = 0;
            int256 xc = x;
            if (xc >= 0x10000000000000000) {
                xc >>= 64;
                msb += 64;
            }
            if (xc >= 0x100000000) {
                xc >>= 32;
                msb += 32;
            }
            if (xc >= 0x10000) {
                xc >>= 16;
                msb += 16;
            }
            if (xc >= 0x100) {
                xc >>= 8;
                msb += 8;
            }
            if (xc >= 0x10) {
                xc >>= 4;
                msb += 4;
            }
            if (xc >= 0x4) {
                xc >>= 2;
                msb += 2;
            }
            if (xc >= 0x2) msb += 1; // No need to shift xc anymore

            int256 result = msb - 64 << 64;
            uint256 ux = uint256(int256(x)) << uint256(127 - msb);
            for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
                ux *= ux;
                uint256 b = ux >> 255;
                ux >>= 127 + b;
                result += bit * int256(b);
            }

            return int128(result);
        }
    }

    /**
     * Calculate natural logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function ln(int128 x) internal pure returns (int128) {
        unchecked {
            require(x > 0);

            return int128(int256(uint256(int256(log_2(x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
        }
    }

    /**
     * Calculate binary exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp_2(int128 x) internal pure returns (int128) {
        unchecked {
            require(x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            uint256 result = 0x80000000000000000000000000000000;

            if (x & 0x8000000000000000 > 0) {
                result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
            }
            if (x & 0x4000000000000000 > 0) {
                result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
            }
            if (x & 0x2000000000000000 > 0) {
                result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
            }
            if (x & 0x1000000000000000 > 0) {
                result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
            }
            if (x & 0x800000000000000 > 0) {
                result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
            }
            if (x & 0x400000000000000 > 0) {
                result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
            }
            if (x & 0x200000000000000 > 0) {
                result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
            }
            if (x & 0x100000000000000 > 0) {
                result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
            }
            if (x & 0x80000000000000 > 0) {
                result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
            }
            if (x & 0x40000000000000 > 0) {
                result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
            }
            if (x & 0x20000000000000 > 0) {
                result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
            }
            if (x & 0x10000000000000 > 0) {
                result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
            }
            if (x & 0x8000000000000 > 0) {
                result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
            }
            if (x & 0x4000000000000 > 0) {
                result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
            }
            if (x & 0x2000000000000 > 0) {
                result = result * 0x1000162E525EE054754457D5995292026 >> 128;
            }
            if (x & 0x1000000000000 > 0) {
                result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
            }
            if (x & 0x800000000000 > 0) {
                result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
            }
            if (x & 0x400000000000 > 0) {
                result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
            }
            if (x & 0x200000000000 > 0) {
                result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
            }
            if (x & 0x100000000000 > 0) {
                result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
            }
            if (x & 0x80000000000 > 0) {
                result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
            }
            if (x & 0x40000000000 > 0) {
                result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
            }
            if (x & 0x20000000000 > 0) {
                result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
            }
            if (x & 0x10000000000 > 0) {
                result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
            }
            if (x & 0x8000000000 > 0) {
                result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
            }
            if (x & 0x4000000000 > 0) {
                result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
            }
            if (x & 0x2000000000 > 0) {
                result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
            }
            if (x & 0x1000000000 > 0) {
                result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
            }
            if (x & 0x800000000 > 0) {
                result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
            }
            if (x & 0x400000000 > 0) {
                result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
            }
            if (x & 0x200000000 > 0) {
                result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
            }
            if (x & 0x100000000 > 0) {
                result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
            }
            if (x & 0x80000000 > 0) {
                result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
            }
            if (x & 0x40000000 > 0) {
                result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
            }
            if (x & 0x20000000 > 0) {
                result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
            }
            if (x & 0x10000000 > 0) {
                result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
            }
            if (x & 0x8000000 > 0) {
                result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
            }
            if (x & 0x4000000 > 0) {
                result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
            }
            if (x & 0x2000000 > 0) {
                result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
            }
            if (x & 0x1000000 > 0) {
                result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
            }
            if (x & 0x800000 > 0) {
                result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
            }
            if (x & 0x400000 > 0) {
                result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
            }
            if (x & 0x200000 > 0) {
                result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
            }
            if (x & 0x100000 > 0) {
                result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
            }
            if (x & 0x80000 > 0) {
                result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
            }
            if (x & 0x40000 > 0) {
                result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
            }
            if (x & 0x20000 > 0) {
                result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
            }
            if (x & 0x10000 > 0) {
                result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
            }
            if (x & 0x8000 > 0) {
                result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
            }
            if (x & 0x4000 > 0) {
                result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
            }
            if (x & 0x2000 > 0) {
                result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
            }
            if (x & 0x1000 > 0) {
                result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
            }
            if (x & 0x800 > 0) {
                result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
            }
            if (x & 0x400 > 0) {
                result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
            }
            if (x & 0x200 > 0) {
                result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
            }
            if (x & 0x100 > 0) {
                result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
            }
            if (x & 0x80 > 0) {
                result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
            }
            if (x & 0x40 > 0) {
                result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
            }
            if (x & 0x20 > 0) {
                result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
            }
            if (x & 0x10 > 0) {
                result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
            }
            if (x & 0x8 > 0) {
                result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
            }
            if (x & 0x4 > 0) {
                result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
            }
            if (x & 0x2 > 0) {
                result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
            }
            if (x & 0x1 > 0) {
                result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;
            }

            result >>= uint256(int256(63 - (x >> 64)));
            require(result <= uint256(int256(MAX_64x64)));

            return int128(int256(result));
        }
    }

    /**
     * Calculate natural exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp(int128 x) internal pure returns (int128) {
        unchecked {
            require(x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            return exp_2(int128(int256(x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return unsigned 64.64-bit fixed point number
     */
    function divuu(uint256 x, uint256 y) private pure returns (uint128) {
        unchecked {
            require(y != 0);

            uint256 result;

            if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
                result = (x << 64) / y;
            } else {
                uint256 msb = 192;
                uint256 xc = x >> 192;
                if (xc >= 0x100000000) {
                    xc >>= 32;
                    msb += 32;
                }
                if (xc >= 0x10000) {
                    xc >>= 16;
                    msb += 16;
                }
                if (xc >= 0x100) {
                    xc >>= 8;
                    msb += 8;
                }
                if (xc >= 0x10) {
                    xc >>= 4;
                    msb += 4;
                }
                if (xc >= 0x4) {
                    xc >>= 2;
                    msb += 2;
                }
                if (xc >= 0x2) msb += 1; // No need to shift xc anymore

                result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
                require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

                uint256 hi = result * (y >> 128);
                uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

                uint256 xh = x >> 192;
                uint256 xl = x << 64;

                if (xl < lo) xh -= 1;
                xl -= lo; // We rely on overflow behavior here
                lo = hi << 128;
                if (xl < lo) xh -= 1;
                xl -= lo; // We rely on overflow behavior here

                result += xh == hi >> 128 ? xl / y : 1;
            }

            require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return uint128(result);
        }
    }

    /**
     * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
     * number.
     *
     * @param x unsigned 256-bit integer number
     * @return unsigned 128-bit integer number
     */
    function sqrtu(uint256 x) private pure returns (uint128) {
        unchecked {
            if (x == 0) {
                return 0;
            } else {
                uint256 xx = x;
                uint256 r = 1;
                if (xx >= 0x100000000000000000000000000000000) {
                    xx >>= 128;
                    r <<= 64;
                }
                if (xx >= 0x10000000000000000) {
                    xx >>= 64;
                    r <<= 32;
                }
                if (xx >= 0x100000000) {
                    xx >>= 32;
                    r <<= 16;
                }
                if (xx >= 0x10000) {
                    xx >>= 16;
                    r <<= 8;
                }
                if (xx >= 0x100) {
                    xx >>= 8;
                    r <<= 4;
                }
                if (xx >= 0x10) {
                    xx >>= 4;
                    r <<= 2;
                }
                if (xx >= 0x4) r <<= 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1; // Seven iterations should be enough
                uint256 r1 = x / r;
                return uint128(r < r1 ? r : r1);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ABDKMath64x64} from "@/libraries/ABDKMath64x64.sol";

library HalfLifeCarbonCreditAuction {
    /**
     * @dev the halving period in seconds (7 days)
     * @dev the price of the carbon credit auction decays with a half-life or 7 days
     *         - the price will shrink exponentially every 7 days unless there are purchases
     */
    uint256 constant HALVING_PERIOD = uint256(7 days);

    /**
     * @notice calculates the value remaining after a given amount of time has elapsed
     *         - using a half-life of 52 weeks
     * @param initialValue the initial value
     * @param elapsedSeconds the number of seconds that have elapsed
     * @return value - the value remaining given a half-life of 52 weeks
     */
    function calculateHalfLifeValue(uint256 initialValue, uint256 elapsedSeconds) public pure returns (uint256) {
        if (elapsedSeconds == 0) {
            return initialValue;
        }
        // Convert the half-life from months to seconds
        uint256 halfLifeSeconds = HALVING_PERIOD;

        // Calculate the ratio of elapsed time to half-life in fixed point format
        int128 tOverT =
            ABDKMath64x64.div(ABDKMath64x64.fromUInt(elapsedSeconds), ABDKMath64x64.fromUInt(halfLifeSeconds));

        // Calculate (1/2)^(t/T) using the fact that e^(ln(0.5)*t/T) = (0.5)^(t/T)
        int128 halfPowerTOverT =
            ABDKMath64x64.exp(ABDKMath64x64.mul(ABDKMath64x64.ln(ABDKMath64x64.divu(1, 2)), tOverT));

        // Calculate the final amount
        uint256 finalValue = ABDKMath64x64.mulu(halfPowerTOverT, initialValue);

        return finalValue;
    }
}
pragma solidity ^0.8.19;

import {IUniswapV2Pair} from "@/interfaces/IUniswapV2Pair.sol";

library UniswapV2Library {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB)
        internal
        view
        returns (uint256 reserveA, uint256 reserveB)
    {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        amountB = amountA * (reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn * (997);
        uint256 numerator = amountInWithFee * (reserveOut);
        uint256 denominator = reserveIn * (1000) + (amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserx   ves, returns a required input amount of the other asset
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn * (amountOut) * (1000);
        uint256 denominator = reserveOut - (amountOut) * (997);
        amountIn = (numerator / denominator) + (1);
    }

    // // performs chained getAmountOut calculations on any number of pairs
    // function getAmountsOut(address factory, uint256 amountIn, address[] memory path)
    //     internal
    //     view
    //     returns (uint256[] memory amounts)
    // {
    //     require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
    //     amounts = new uint[](path.length);
    //     amounts[0] = amountIn;
    //     for (uint256 i; i < path.length - 1; i++) {
    //         (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
    //         amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
    //     }
    // }

    // // performs chained getAmountIn calculations on any number of pairs
    // function getAmountsIn(address factory, uint256 amountOut, address[] memory path)
    //     internal
    //     view
    //     returns (uint256[] memory amounts)
    // {
    //     require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
    //     amounts = new uint[](path.length);
    //     amounts[amounts.length - 1] = amountOut;
    //     for (uint256 i = path.length - 1; i > 0; i--) {
    //         (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
    //         amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
    //     }
    // }
}