// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

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
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

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
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
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
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
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
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
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
     * Does not emit an {Approval} event.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Burnable.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Permit.sol)

pragma solidity ^0.8.20;

import {IERC20Permit} from "./IERC20Permit.sol";
import {ERC20} from "../ERC20.sol";
import {ECDSA} from "../../../utils/cryptography/ECDSA.sol";
import {EIP712} from "../../../utils/cryptography/EIP712.sol";
import {Nonces} from "../../../utils/Nonces.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712, Nonces {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Permit deadline has expired.
     */
    error ERC2612ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

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
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    function nonces(address owner) public view virtual override(IERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    /**
     * @inheritdoc IERC20Permit
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

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
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Nonces.sol)
pragma solidity ^0.8.20;

/**
 * @dev Provides tracking nonces for addresses. Nonces will only increment.
 */
abstract contract Nonces {
    /**
     * @dev The nonce used for an `account` is not the expected current nonce.
     */
    error InvalidAccountNonce(address account, uint256 currentNonce);

    mapping(address account => uint256) private _nonces;

    /**
     * @dev Returns the next unused nonce for an address.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner];
    }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address owner) internal virtual returns (uint256) {
        // For each account, the nonce has an initial value of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here.
            return _nonces[owner]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address owner, uint256 nonce) internal virtual {
        uint256 current = _useNonce(owner);
        if (nonce != current) {
            revert InvalidAccountNonce(owner, current);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ShortStrings.sol)

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
    bytes32 private constant FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

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
            return ShortString.wrap(FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using
     * {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;

import {Math} from "./math/Math.sol";
import {SignedMath} from "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

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
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
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
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

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
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/EIP712.sol)

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

    bytes32 private constant TYPE_HASH =
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
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MessageHashUtils.sol)

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
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
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
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
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
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

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
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

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
pragma solidity 0.8.24;

import { EditQueueInteractor } from "./EditQueueInteractor.sol";

contract Timelock is EditQueueInteractor {
    // Timelock constructor
    constructor(address _owner) EditQueueInteractor(_owner) {}

    // ////////////////////
    // ⏰ timelock logic
    // this timelock is used for all sensitive actions in the contract and is expected to change very rately, it is thus hard capped at a change lock of 14 days.
    // ////////////////////

    // Timelock events
    event TimelockDurationCommitted(uint256 newTimelock);

    // Timelock errors
    error TimelockDurationZero();

    // Timelock tracking variables
    uint256 public sensitiveActionTimelock = 2 days; // The timelock applied on sensitive actions within the TaofuOFT contract stack
    uint256 public timelockEditDelay = 14 days; // The timelock on the editing of the sensitiveActionTimelock, this is an immutable delay

    /**
     * @dev Queue an edit for the timelock duration
     * @param _newTimelock The new timelock duration in seconds
     */
    function queueTimelockDurationEdit(uint256 _newTimelock) external onlyOwner {
        if (_newTimelock == 0) revert TimelockDurationZero();
        // require(_newTimelock > 0, "Timelock = 0");
        registerQueuedEdit(block.timestamp + timelockEditDelay, address(0), false, _newTimelock, "", "timelockDuration");
    }

    /**
     * @dev Commit the queued timelock edit
     */
    function commitQueuedTimelockEdit() external onlyOwner {
        // Get the indexes of the committable edits
        uint256[] memory committableEditIndexes = getCommittableEditIndexes("timelockDuration");

        // Loop through the committable edits in reverse order to prevent invalid indexes due to the removal of previous edits
        for (uint256 i = committableEditIndexes.length; i > 0; i--) {
            // Decrement i to get the correct index, the reason not to do this in the `for` statement is to prevent an underflow
            uint256 index = i - 1;

            // Get the matching queue edit
            (, , , uint256 newTimelock, , ) = getQueuedEdit(committableEditIndexes[index]);

            // Apply the new timelock
            sensitiveActionTimelock = newTimelock;

            // Remove this queued entry from the array in the EditQueue
            removeEditFromQueue(committableEditIndexes[index]);

            emit TimelockDurationCommitted(newTimelock);
        }
    }

    // ////////////////////
    // ⏰ end timelock logic
    // ////////////////////
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Timelock } from "./0_Timelock.sol";

contract CommunityCommittee is Timelock {
    // Community committee constructor
    constructor(address _owner) Timelock(_owner) {}

    // ////////////////////
    // 👯 Community committee logic
    // ////////////////////

    // Community committee errors
    error NotCommitteeMember();

    // Community committee tracker
    mapping(address => bool) public isCommunityCommitteeMember;
    address[] public communityCommittee;

    // Community committee modifier
    modifier onlyCommunityCommittee() {
        if (!isCommunityCommitteeMember[msg.sender]) revert NotCommitteeMember();
        _;
    }

    /**
     * @dev Queue a change to the community committee
     * @param _member the address of the member
     * @param _isMember whether to set the address as a member or to remove it
     */
    function queueCommunityCommitteeStatusChange(address _member, bool _isMember) external onlyOwner {
        // Create edit queue item
        registerQueuedEdit(block.timestamp + sensitiveActionTimelock, _member, _isMember, 0, "", "communityCommitteeStatus");
    }

    /**
     * @dev Commit all community committee changes that are past their timelock
     */
    function commitCommunityCommitteeStatusChanges() external onlyOwner {
        // Get all committable index items
        uint256[] memory committableEditIndexes = getCommittableEditIndexes("communityCommitteeStatus");

        // Loop through the committable edits in reverse order to prevent invalid indexes due to the removal of previous edits
        for (uint256 i = committableEditIndexes.length; i > 0; i--) {
            // Decrement i to get the correct index, the reason not to do this in the `for` statement is to prevent an underflow
            uint256 index = i - 1;

            // Get the address payload and bool payload
            (, address addressPayload, bool boolPayload, , , ) = getQueuedEdit(committableEditIndexes[index]);

            // Applying the committee status change
            isCommunityCommitteeMember[addressPayload] = boolPayload;

            // Remove the processed edit from the queue
            removeEditFromQueue(committableEditIndexes[index]);

            // If this was an addition, add the member to communityCommittee if it is not already in there
            if (boolPayload) {
                bool isMember = false;
                for (uint256 j; j < communityCommittee.length; j++) {
                    if (communityCommittee[j] == addressPayload) {
                        isMember = true;
                        break;
                    }
                }
                if (!isMember) {
                    communityCommittee.push(addressPayload);
                }
            }

            // If this was a removal, remove the member from communityCommittee if it is in there
            if (!boolPayload) {
                // If this was a removal, remove the member from communityCommittee if it is in there
                for (uint256 j; j < communityCommittee.length; j++) {
                    if (communityCommittee[j] == addressPayload) {
                        communityCommittee[j] = communityCommittee[communityCommittee.length - 1];
                        communityCommittee.pop();
                        break;
                    }
                }
            }
        }
    }

    // ////////////////////
    // 👯 End community committee logic
    // ////////////////////
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { CommunityCommittee } from "./1_CommunityCommittee.sol";

contract PausingCommittee is CommunityCommittee {
    // Pausing committee constructur
    constructor(address _owner) CommunityCommittee(_owner) {}

    // ////////////////////
    // 🙋‍♀️ Pausing committee logic
    // ////////////////////

    // Pause committee errors
    error NotPauser();
    error NotUnpauser();

    // Pause committee tracker, 0 = none, 1 = pauser, 2 = unpauser, 3 = pauser and unpauser
    mapping(address => uint8) public hasPausingPrivileges;
    address[] public pauseCommittee;

    // Pause committee modifier
    modifier onlyPausers() {
        if (hasPausingPrivileges[msg.sender] == 0 || hasPausingPrivileges[msg.sender] == 2) revert NotPauser();
        _;
        // require(hasPausingPrivileges[msg.sender] == 1 || hasPausingPrivileges[msg.sender] == 3, "!pauser");
        // _;
    }
    modifier onlyUnpausers() {
        if (hasPausingPrivileges[msg.sender] == 0 || hasPausingPrivileges[msg.sender] == 1) revert NotUnpauser();
        _;
        // require(hasPausingPrivileges[msg.sender] == 2 || hasPausingPrivileges[msg.sender] == 3, "!unpauser");
        // _;
    }

    /**
     * @dev Queue a change to the pause committee
     * @param _member the address of the member
     * @param _permissions whether to remove (NONE), make pauser (PAUSER), or make unpauser (UNPAUSER)
     */
    function queuePauseCommitteeStatusChange(address _member, uint8 _permissions) external onlyCommunityCommittee {
        // Check that the _permissions is within the allowed range
        require(_permissions >= 0 && _permissions <= 3, "Invalid permissions");

        // Queue edit
        registerQueuedEdit(block.timestamp + sensitiveActionTimelock, _member, false, uint256(_permissions), "", "pauseCommitteeStatus");
    }

    /**
     * @dev Commit all pause committee changes that are past their timelock
     */
    function commitPauseCommitteeStatusChanges() external onlyCommunityCommittee {
        // Get all committable index items
        uint256[] memory committableEditIndexes = getCommittableEditIndexes("pauseCommitteeStatus");

        // Loop through the committable edits in reverse order to prevent invalid indexes due to the removal of previous edits
        for (uint256 i = committableEditIndexes.length; i > 0; i--) {
            // Decrement i to get the correct index, the reason not to do this in the `for` statement is to prevent an underflow
            uint256 index = i - 1;

            // Get the address payload and uint payload
            (, address addressPayload, , uint256 uintPayload, , ) = getQueuedEdit(committableEditIndexes[index]);

            // Applying the committee status change
            hasPausingPrivileges[addressPayload] = uint8(uintPayload);

            // If this change set the address to isMember false, remove the address from the pauseCommittee array
            if (uint8(uintPayload) == 0) {
                for (uint _index; _index < pauseCommittee.length; _index++) {
                    if (pauseCommittee[_index] == addressPayload) {
                        pauseCommittee[_index] = pauseCommittee[pauseCommittee.length - 1];
                        pauseCommittee.pop();
                        break;
                    }
                }
            }

            // If this was an addition, add the member to pauseCommittee if it is not already in there
            if (uint8(uintPayload) != 0) {
                bool isMember = false;
                for (uint256 j; j < pauseCommittee.length; j++) {
                    if (pauseCommittee[j] == addressPayload) {
                        isMember = true;
                        break;
                    }
                }
                if (!isMember) pauseCommittee.push(addressPayload);
            }

            // Remove the processed edit from the queue
            removeEditFromQueue(committableEditIndexes[index]);
        }
    }

    // ////////////////////
    // 🙋‍♀️ End pausing committee logic
    // ////////////////////

    // ////////////////////
    // ⏯️ minting (un)pause logic
    // ////////////////////

    // Minting pause errors
    error NoQueuedUnpause();
    error NoTimelockPassed();

    // Minting pause events
    event UnpauseQueue(uint256 timelock);

    // Minting enabled flag, this is used in the minting queue item delivery
    bool public mintingEnabled = true;

    // Unpause logic events
    event MintingEnabled(bool _status);

    /**
     * @dev Function to pause minting, this is instant
     */
    function pauseMinting() external onlyPausers {
        mintingEnabled = false;
        emit MintingEnabled(false);
    }

    // Unpausing timelock trackers
    uint256 public unpauseTimelock;

    /**
     * @dev Function to queue a minting pause, this is timelocked
     */
    function queueUnpauseMinting() external onlyUnpausers {
        unpauseTimelock = block.timestamp + sensitiveActionTimelock;
        emit UnpauseQueue(unpauseTimelock);
    }

    /**
     * @dev Function that commits the queued unpause but only after timelock
     */
    function commitUnpauseMinting() external onlyUnpausers {
        if (unpauseTimelock == 0) revert NoQueuedUnpause();
        if (block.timestamp < unpauseTimelock) revert NoTimelockPassed();
        // require(unpauseTimelock != 0, "!queued unpause");
        // require(block.timestamp > unpauseTimelock, "!timelock passed");
        mintingEnabled = true;
        unpauseTimelock = 0;
        emit MintingEnabled(true);
    }

    // ////////////////////
    // ⏯️ minting (un)pause logic
    // ////////////////////
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// import ERC20Burnable from OpenZeppelin
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

import { PausingCommittee } from "./2_PausingCommittee.sol";

contract MintingLogic is ERC20, ERC20Burnable, ERC20Permit, PausingCommittee {
    // Minting logic constructor
    constructor(string memory _name, string memory _symbol, address _owner) ERC20(_name, _symbol) ERC20Permit(_name) PausingCommittee(_owner) {}

    /**
     * *********************
     * 🐣 Minting logic section
     * *********************
     *
     * The minting process is as follows:
     *  1) authorised party deposits Tao at the custory partner,
     *  2) the Taofu oracle creates a minting request (RFQ)
     *  3) an approved minting administrator (oracle) approves the minting request upon receiving the expected TAO, this creates a minting queue item
     *  4) the minting queue item is delivered after a delay (delivery means minting the tokens to the address specified in the minting queue item)
     */

    // Minting related events
    event MintingQueueItemDelivered(address _recipient, uint256 _amount);
    event MintingDelayEdited(uint256 new_delay);
    event MintingQueueItemCreated(uint256 _uid, address _recipient, uint256 _amount);

    ///////////////////////////////////////////
    // 💡 Start minting status tracking
    // note: a minting status tracks a uid all the way from request to minting
    ///////////////////////////////////////////

    // Status event
    enum MintingStatus {
        Undefined,
        Pending,
        Queued,
        Minting,
        Rejected,
        Vetoed
    }
    event MintingStatusEdited(uint256 _uid, MintingStatus _status);

    // Minting status mapping
    mapping(uint256 => MintingStatus) public mintingStatus;

    /**
     * @dev Edit the minting status of a minting request.
     * @param _uid The unique identifier of the minting request.
     * @param _status The new status of the minting request, 0 = pending, 1 = queued, 2 = minting, 3 = rejected, 4 = vetoed
     * @notice This function is only called by the contract itself
     */
    function editMintingStatus(uint256 _uid, MintingStatus _status) internal {
        mintingStatus[_uid] = _status;
        emit MintingStatusEdited(_uid, _status);
    }

    ///////////////////////////////////////////
    //  💡 End minting status tracking
    ///////////////////////////////////////////

    ///////////////////////////////////////////
    //  🔐 Start minting permission modifiers
    ///////////////////////////////////////////

    // Permissioning events
    event MintingRequestCreatorAdded(address _creator);
    event MintingRequestCreatorRemoved(address _creator);
    event MintingAdministratorAdded(address _administrator);
    event MintingAdministratorRemoved(address _administrator);

    // Minting permission mappings
    mapping(address => bool) public isMintingRequestCreator;
    mapping(address => bool) public isMintingAdministrator;

    // Minting permission errors
    error IsNotRequestCreator();
    error IsNotAdministrator();

    modifier onlyMintingRequestCreator() {
        if (!isMintingRequestCreator[msg.sender]) revert IsNotRequestCreator();
        _;
        // require(isMintingRequestCreator[msg.sender], "!request creator");
        // _;
    }
    modifier onlyMintingAdministrators() {
        if (!isMintingAdministrator[msg.sender]) revert IsNotAdministrator();
        _;
        // require(isMintingAdministrator[msg.sender], "!administrator");
        // _;
    }

    /**
     * @dev Adds a new minting request creator.
     * @param _creator The address of the creator.
     * @notice This function is only called by the Taofu team.
     */
    function addMintingRequestCreator(address _creator) external onlyOwner {
        isMintingRequestCreator[_creator] = true;
        emit MintingRequestCreatorAdded(_creator);
    }

    /**
     * @dev Removes a minting request creator.
     * @param _creator The address of the creator.
     * @notice This function is only called by the Taofu team.
     */
    function removeMintingRequestCreator(address _creator) external onlyOwner {
        isMintingRequestCreator[_creator] = false;
        emit MintingRequestCreatorRemoved(_creator);
    }

    /**
     * @dev Adds a new minting administrator.
     * @param _administrator The address of the administrator.
     * @notice This function is only called by the Taofu team.
     */
    function addMintingAdministrator(address _administrator) external onlyOwner {
        isMintingAdministrator[_administrator] = true;
        emit MintingAdministratorAdded(_administrator);
    }

    /**
     * @dev Removes a minting administrator.
     * @param _administrator The address of the administrator.
     * @notice This function is only called by the Taofu team.
     */
    function removeMintingAdministrator(address _administrator) external onlyOwner {
        isMintingAdministrator[_administrator] = false;
        emit MintingAdministratorRemoved(_administrator);
    }

    //////////////////////////////////////
    // 🔐 End minting permission modifiers
    //////////////////////////////////////

    ////////////////////////////////////
    // 🙏 Start minting request section
    ////////////////////////////////////

    // Minting request related events
    event MintingRequestCreated(address _creator, uint256 _amount, uint256 _price, uint256 _uid);
    event MintingRequestApproved(address _creator, uint256 _amount, uint256 _price, uint256 _uid);

    // Create minting request struct
    struct MintingRequest {
        uint256 uid; // unique identifier of the minting request
        address requester; // requestor address
        uint256 amount; // minting amount
        uint256 price; // relavitve price of Taofu in Tao
    }

    // Minting request errors
    error AmountNotPositive();
    error MintingRequestNotUnique();
    error MintingRequestNotFound();

    // Create minting request variable
    MintingRequest[] public mintingRequests;

    /**
     * @dev Creates a new minting request.
     * @param _uid The unique identifier of the minting request.
     * @param _amount The amount of staked Tao to be emitted.
     * @param _price The relative price of Taofu in Tao. This value is only used for informational event emissions and does not influence minting logic
     * @param _requester The address of the requester.
     * @notice This function is only called by the minting request creators.
     */
    function createMintingRequest(uint256 _uid, uint256 _amount, uint256 _price, address _requester) external onlyMintingRequestCreator {
        // Check that amount is positive
        if (_amount <= 0) revert AmountNotPositive();
        // require(_amount > 0, "Amount !positive");

        // Require the _uid to have not been used before
        if (mintingStatus[_uid] != MintingStatus.Undefined) revert MintingRequestNotUnique();
        // require(mintingStatus[_uid] == MintingStatus.Undefined, "!unique");

        // Add the minting request
        mintingRequests.push(MintingRequest(_uid, _requester, _amount, _price));
        emit MintingRequestCreated(_requester, _amount, _price, _uid);

        // Register the status of the minting request
        editMintingStatus(_uid, MintingStatus.Pending);
    }

    /**
     * @dev Approves a minting request.
     * @param _uid The unique identifier of the minting request.
     * @notice This function is only called by the minting administrators.
     */
    function approveMintingRequest(uint256 _uid) external onlyMintingAdministrators {
        // Find the minting request
        uint256 i;
        while (mintingRequests[i].uid != _uid) {
            i++;

            // If i is bigger than array length, throw error
            if (i >= mintingRequests.length) revert MintingRequestNotFound();
            // require(i < mintingRequests.length, "!found");
        }

        // Create a minting queue item from the minting request
        createMintingQueueItem(_uid, mintingRequests[i].requester, mintingRequests[i].amount);
        emit MintingRequestApproved(mintingRequests[i].requester, mintingRequests[i].amount, mintingRequests[i].price, mintingRequests[i].uid);

        // Remove the request from the array
        mintingRequests[i] = mintingRequests[mintingRequests.length - 1];
        mintingRequests.pop();
    }

    /**
     * @dev Rejects a minting request.
     * @param _uid The unique identifier of the minting request.
     * @notice This function is only called by the minting administrators.
     */
    function rejectMintingRequest(uint256 _uid) external onlyMintingAdministrators {
        // Find the minting request
        uint256 i;
        while (mintingRequests[i].uid != _uid) {
            i++;

            // If i is bigger than array length, throw error
            if (i >= mintingRequests.length) revert MintingRequestNotFound();
            // require(i < mintingRequests.length, "!found");
        }

        // Register the status of the minting request
        editMintingStatus(_uid, MintingStatus.Rejected);

        // Remove the request from the array
        mintingRequests[i] = mintingRequests[mintingRequests.length - 1];
        mintingRequests.pop();
    }

    ////////////////////////////////////
    // 🙏 End minting request section
    ////////////////////////////////////

    ////////////////////////////////////
    // 💰 Start minting queue section
    ////////////////////////////////////

    // Create minting delay variable
    uint256 public mintingDelay = 1 days;

    // Create minting queue item struct
    struct MintingQueueItem {
        uint256 uid; // unique identifier of the minting request
        address recipient; // recipient address
        uint256 amount; // minting amount
        uint256 delivery_time; // minting delivery time, this is a safety delay
    }

    // Minting queue errors
    error MintingDisabled();

    // Create minting queue variable
    MintingQueueItem[] public mintingQueue;

    /**
     * @dev Edit the minting delay, owner only
     * @param _mintingDelay The new minting delay in seconds
     */
    function queueEditMintingDelay(uint256 _mintingDelay) external onlyOwner {
        registerQueuedEdit(block.timestamp + sensitiveActionTimelock, address(0), false, _mintingDelay, "", "mintingDelay");
    }

    /**
     * @dev Commit the queued minting delay edit if it passed the timelock
     */
    function commitQueuedEditMintingDelay() external onlyOwner {
        // Get committable edit indexes
        uint256[] memory committableEditIndexes = getCommittableEditIndexes("mintingDelay");

        // Loop through the committable edits in reverse order to prevent invalid indexes due to the removal of previous edits
        for (uint256 i = committableEditIndexes.length; i > 0; i--) {
            // Decrement i to get the correct index, the reason not to do this in the `for` statement is to prevent an underflow
            uint256 index = i - 1;

            // Get the uint payload
            (, , , uint256 newMintingDelay, , ) = getQueuedEdit(committableEditIndexes[index]);
            mintingDelay = newMintingDelay;
            removeEditFromQueue(committableEditIndexes[index]);

            // Emit the event
            emit MintingDelayEdited(newMintingDelay);
        }
    }

    /**
     * @dev Creates a new minting queue item.
     * @param _uid The unique identifier of the minting request.
     * @param _recipient The address of the recipient.
     * @param _amount The amount to be minted, in wei.
     * @notice This function is only called by the Taofu team after Tao has been deposited at the custory partner.
     */
    function createMintingQueueItem(uint256 _uid, address _recipient, uint256 _amount) internal onlyMintingAdministrators {
        // Check that amount is positive
        if (_amount <= 0) revert AmountNotPositive();
        // require(_amount > 0, "!positive");

        // Add the minting queue item
        uint256 _delivery_time = block.timestamp + mintingDelay;
        mintingQueue.push(MintingQueueItem(_uid, _recipient, _amount, _delivery_time));
        emit MintingQueueItemCreated(_uid, _recipient, _amount);

        // Register the status of the minting request
        editMintingStatus(_uid, MintingStatus.Queued);
    }

    /**
     * @dev Delivers minting queue items that have passed their delivery time, up to a maximum specified amount.
     * @param _max_amount_to_process The maximum number of items to process in this call. Useful for gas control and if array is too large to process in one go because of gas limits.
     * @notice Anyone can call this function, but we assume it is mostly called by the Taofu team. The reason to keep this open is that we will potentially have the minting process done by a third party custodian while we want to be able to trigger the minting requests that qualify for minting
     */
    function deliverMintingQueueItems(uint256 _max_amount_to_process) external {
        // If minting is disabled, do nothing
        if (!mintingEnabled) revert MintingDisabled();
        // require(mintingEnabled, "!enabled");

        uint256 i;
        uint256 processed; // Counter for the number of items processed

        while (i < mintingQueue.length && processed < _max_amount_to_process) {
            // If delivery time has not passed, skip to the next item.
            if (mintingQueue[i].delivery_time > block.timestamp) {
                i++;
                continue;
            }

            // Mint the tokens for the current item.
            _mint(mintingQueue[i].recipient, mintingQueue[i].amount);
            emit MintingQueueItemDelivered(mintingQueue[i].recipient, mintingQueue[i].amount);

            // Register the status of the minting request
            editMintingStatus(mintingQueue[i].uid, MintingStatus.Minting);

            // Remove the item from the queue efficiently.
            mintingQueue[i] = mintingQueue[mintingQueue.length - 1];
            mintingQueue.pop();

            // Increment the processed counter since an item has been successfully processed.
            processed++;

            // No need to increment `i` since we need to check the new item that has been moved to this position.
        }
    }

    /**
     * @dev Returns all minting queue items.
     * @notice Solidity creates getter functions for indexes, but not entire arrays, this function is a convenience function to read the minting queue items.
     * @return An array of minting queue items.
     */
    function readMintingQueueItems() external view returns (MintingQueueItem[] memory) {
        return mintingQueue;
    }

    /**
     * @dev Caclculate the amount of to-be-minted taofu tokens based on the mintingqueueitens
     * @return The total amount of to-be-minted taofu tokens
     */
    function calculateTotalMintingQueueAmount() external view returns (uint256) {
        uint256 total;
        MintingQueueItem[] memory _mintingQueue = mintingQueue;
        for (uint256 i; i < _mintingQueue.length; i++) {
            total += _mintingQueue[i].amount;
        }
        return total;
    }

    ////////////////////////////////////
    // 💰 End minting queue section
    ////////////////////////////////////
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { MintingLogic } from "./3_MintingLogic.sol";

contract VetoCommittee is MintingLogic {
    // Veto committee constructor with OFT constructor parameters
    constructor(string memory _name, string memory _symbol, address _owner) MintingLogic(_name, _symbol, _owner) {}

    /**
     * *********************
     * 🚨 Escape hatch section
     * *********************
     *
     * During the minting delay, any of the veto participants can cancel any minting queue item.
     * This is an escape hatch security feature, veto participants have no other special powers.
     */

    // Escape hatch related events
    event VetoParticipantAdded(address _participant);
    event VetoParticipantRemoved(address _participant);
    event VetoPerformed(address _recipient, uint256 _amount);
    event NuclearVetoPerformed(uint256 _amount);

    // Escape hatch errors
    error NotVetoParticipant();
    error MintingQueueItemNotFound();

    // Declaration of the mapping to track veto participants
    mapping(address => bool) public isVetoParticipant;

    // Create a modifier that allows only veto participants to call the function
    modifier onlyVetoParticipants() {
        if (!isVetoParticipant[msg.sender]) revert NotVetoParticipant();
        _;
        // require(isVetoParticipant[msg.sender], "!veto participant");
        // _;
    }

    /**
     * @dev Adds a new veto participant.
     * @param _participant The address of the participant.
     * @notice This function is only called by the Taofu team.
     */
    function addVetoParticipant(address _participant) external onlyOwner {
        isVetoParticipant[_participant] = true;
        emit VetoParticipantAdded(_participant);
    }

    /**
     * @dev Removes a veto participant.
     * @param _participant The address of the participant.
     * @notice This function is only called by the Taofu team.
     */
    function removeVetoParticipant(address _participant) external onlyOwner {
        isVetoParticipant[_participant] = false;
        emit VetoParticipantRemoved(_participant);
    }

    /**
     * @dev Veto a minting queue item by index
     * @param _index The index of the minting queue item.
     * @notice This function can be called by any of the veto participants. It vetoes the minting queue item.
     */
    function vetoMintingQueueItem(uint256 _index) external onlyVetoParticipants {
        if (_index >= mintingQueue.length) revert MintingQueueItemNotFound();
        // require(_index < mintingQueue.length, "!exist");

        // Emit event of veto
        emit VetoPerformed(mintingQueue[_index].recipient, mintingQueue[_index].amount);

        // Register the status of the minting request
        editMintingStatus(mintingQueue[_index].uid, MintingStatus.Vetoed);

        // Replace the item at _index with the last item in the array
        mintingQueue[_index] = mintingQueue[mintingQueue.length - 1];

        // Remove the last element
        mintingQueue.pop();
    }

    /**
     * @dev Veto a minting queue item by recipient
     * @param _recipient The address of the recipient.
     * @notice This function can be called by any of the veto participants. It vetoes the minting queue item.
     */
    function vetoMintingQueueItemByRecipient(address _recipient) external onlyVetoParticipants {
        // Track index of the next item to be kept/protected from deletion
        uint256 index_of_next_keeper;
        MintingQueueItem[] memory _mintingQueue = mintingQueue;

        // Loop over items, find keepers, mark vetos for replacement
        for (uint256 i = 0; i < _mintingQueue.length; i++) {
            // If this should be vetoed, do not protect it
            if (_mintingQueue[i].recipient == _recipient) {
                emit VetoPerformed(_mintingQueue[i].recipient, _mintingQueue[i].amount);

                // Register the status of the minting request
                editMintingStatus(_mintingQueue[i].uid, MintingStatus.Vetoed);

                continue;
            }

            // Protect keepers from deletions by shifting them to the lowest available voto slot
            if (index_of_next_keeper != i) {
                mintingQueue[index_of_next_keeper] = mintingQueue[i];
            }

            // Increment the index of the last vetoed item
            index_of_next_keeper++;
        }

        // After filtering, truncate the array to remove the vetoed items.
        while (mintingQueue.length > index_of_next_keeper) {
            mintingQueue.pop(); // Remove the last item, decreasing the array's length.
        }
    }

    /**
     * @dev Veto all minting queue items, this is a nuclear option intented for very severe cases only
     * @param _cheap_mode If true, the function will not emit veto events for each item but only an aggregated event, this should only be used if for some reason gas fees are prohibitively high for the veto participant. It reduces the east of tracking veto entries for off-chain applications relying on events.
     * @notice This function can be called by any of the veto participants. It vetoes the minting queue item.
     */
    function vetoAllMintingQueueItems(bool _cheap_mode) external onlyVetoParticipants {
        // Emit veto events for each item
        if (!_cheap_mode) {
            MintingQueueItem[] memory _mintingQueue = mintingQueue;
            for (uint256 i = 0; i < _mintingQueue.length; i++) {
                emit VetoPerformed(_mintingQueue[i].recipient, _mintingQueue[i].amount);
                // Register the status of the minting request
                editMintingStatus(_mintingQueue[i].uid, MintingStatus.Vetoed);
            }
        }

        // In cheap mode, only emit the nuclear veto event
        if (_cheap_mode) {
            emit NuclearVetoPerformed(mintingQueue.length);
        }

        // Set the minting queue array to an empty array
        delete mintingQueue;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Import the interface
import "./IEditQueue.sol";

// Import Ownable from OpenZeppelin
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract EditQueueInteractor is Ownable {
    // Address of the EditQueue contract
    IEditQueue public editQueue;

    // EditQueueInteractor constructor
    constructor(address _owner) Ownable(_owner) {}

    /**
     * @dev Function to set the address of the EditQueue contract
     * @param _edit_queue_address the address of the EditQueue contract
     */
    function setEditQueue(address _edit_queue_address) external onlyOwner {
        require(address(editQueue) == address(0), "Already set");
        editQueue = IEditQueue(_edit_queue_address);
    }

    /**
     * @dev Register a queued edit in the EditQueue contract
     * @param _timelock the timestamp at which the timelock opens
     * @param _addressPayload the address payload
     * @param _boolPayload the bool payload
     * @param _uintPayload the uint payload
     * @param _stringPayload the string payload
     * @param _editType the type of the edit
     */
    function registerQueuedEdit(
        uint256 _timelock,
        address _addressPayload,
        bool _boolPayload,
        uint256 _uintPayload,
        string memory _stringPayload,
        string memory _editType
    ) internal {
        // Call the registerQueuedEdit function of the EditQueue contract
        editQueue.registerQueuedEdit(_timelock, _addressPayload, _boolPayload, _uintPayload, _stringPayload, _editType);
    }

    /**
     * @dev Get the edit indexes of a specific type where the timelock has expired
     * @param _editType the type of the edit
     * @return an array of indexes
     */
    function getCommittableEditIndexes(string memory _editType) public view returns (uint256[] memory) {
        // Call the getCommittableEditIndexes function of the EditQueue contract
        return editQueue.getCommittableEditIndexes(_editType);
    }

    /**
     * @dev Remove an edit from the queue by index
     * @param _index the index of the edit
     */
    function removeEditFromQueue(uint256 _index) internal {
        // Call the removeEditFromQueue function of the EditQueue contract
        editQueue.removeEditFromQueue(_index);
    }

    /**
     * @dev Get details of a queued edit by index
     * @param _index the index of the queued edit
     * @return timelock the timestamp of the edit's timelock
     * @return addressPayload the address payload of the edit
     * @return boolPayload the boolean payload of the edit
     * @return uintPayload the uint payload of the edit
     * @return stringPayload the string payload of the edit
     * @return editType the type of the edit
     */
    function getQueuedEdit(
        uint256 _index
    )
        public
        view
        returns (uint256 timelock, address addressPayload, bool boolPayload, uint256 uintPayload, string memory stringPayload, string memory editType)
    {
        // Call the queuedEdits getter function of the EditQueue contract
        return editQueue.queuedEdits(_index);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Define an interface for the EditQueue contract
interface IEditQueue {
    // Edit queue item struct
    struct QueuedEdit {
        uint256 timelock; // timestamp used for timelocking
        address addressPayload; // optional, depending on the use case
        bool boolPayload; // optional, depending on the use case
        uint256 uintPayload; // optional, depending on the use case
        string stringPayload; // optional, depending on the use case
        string editType; // optional, depending on the use case
    }

    // Edit queue events
    event EditQueued(QueuedEdit edit);
    event EditCommitted(QueuedEdit edit);

    // Function to register a queued edit
    function registerQueuedEdit(
        uint256 _timelock,
        address _addressPayload,
        bool _boolPayload,
        uint256 _uintPayload,
        string calldata _stringPayload,
        string calldata _editType
    ) external;

    // Function to get the edit indexes of a specific type where the timelock has expired
    function getCommittableEditIndexes(string calldata _editType) external view returns (uint256[] memory);

    // Function to remove an edit from the queue by index
    function removeEditFromQueue(uint256 _index) external;

    // Getter for the queuedEdits array
    function queuedEdits(
        uint256 index
    )
        external
        view
        returns (
            uint256 timelock,
            address addressPayload,
            bool boolPayload,
            uint256 uintPayload,
            string memory stringPayload,
            string memory editType
        );
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Import cascading inheritance chain
import { VetoCommittee } from "./4_VetoCommittee.sol";

// @title: Taofu token contract
// @dev: Taofu is a LayerZero omninichain token (OFT) that wraps staked Tao tokens
// @dev: ERC-20 docs at OpenZeppelin: https://docs.openzeppelin.com/contracts/5.x/erc20
// @dev: OFT docs at LayerZero: https://docs.layerzero.network/contracts/oft
contract sTAO is VetoCommittee {
    /**
     * @dev Taofu token constructor
     * @param _name The name of the token
     * @param _symbol The symbol of the token
     * @param _owner The owner of the token after the deployment is complete (this is not the deployment key)
     */
    constructor(string memory _name, string memory _symbol, address _owner) VetoCommittee(_name, _symbol, _owner) {}
}