// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC165} from "./IERC165.sol";

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
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
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
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
 * @dev Standard ERC-1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-1155 tokens.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/ERC20.sol)

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
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC1363} from "../../../interfaces/IERC1363.sol";
import {Address} from "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Address.sol)

pragma solidity ^0.8.20;

import {Errors} from "./Errors.sol";

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {Errors.FailedCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors.FailedCall();
        }
    }
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

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
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ICore} from "../interfaces/ICore.sol";

/**
    @title Core Ownable
    @author Prisma Finance (with edits by Resupply Finance)
    @notice Contracts inheriting `CoreOwnable` have the same owner as `Core`.
            The ownership cannot be independently modified or renounced.
 */
contract CoreOwnable {
    ICore public immutable core;

    constructor(address _core) {
        core = ICore(_core);
    }

    modifier onlyOwner() {
        require(msg.sender == address(core), "!core");
        _;
    }

    function owner() public view returns (address) {
        return address(core);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IAuthHook {
    function preHook(address operator, address target, bytes calldata data) external returns (bool);
    function postHook(bytes memory result, address operator, address target, bytes calldata data) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IAuthHook } from './IAuthHook.sol';

interface ICore {
    struct OperatorAuth {
        bool authorized;
        IAuthHook hook;
    }

    event VoterSet(address indexed newVoter);
    event OperatorExecuted(address indexed caller, address indexed target, bytes data);
    event OperatorSet(address indexed caller, address indexed target, bool authorized, bytes4 selector, IAuthHook authHook);

    function execute(address target, bytes calldata data) external returns (bytes memory);
    function epochLength() external view returns (uint256);
    function startTime() external view returns (uint256);
    function voter() external view returns (address);
    function ownershipTransferDeadline() external view returns (uint256);
    function pendingOwner() external view returns (address);
    function setOperatorPermissions(
        address caller,
        address target,
        bytes4 selector,
        bool authorized,
        IAuthHook authHook
    ) external;
    function setVoter(address newVoter) external;
    function operatorPermissions(address caller, address target, bytes4 selector) external view returns (bool authorized, IAuthHook hook);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IMintable{
    function mint(address _to, uint256 _amount) external;
    function burn(address _from, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IResupplyRegistry {
    event AddPair(address pairAddress);
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SetDeployer(address deployer, bool _bool);

    function acceptOwnership() external;

    function addPair(address _pairAddress) external;

    function registeredPairs(uint256) external view returns (address);

    function pairsByName(string memory) external view returns (address);

    function defaultSwappersLength() external view returns (uint256);
    function registeredPairsLength() external view returns (uint256);

    function getAllPairAddresses() external view returns (address[] memory _deployedPairsArray);
    
    function getAllDefaultSwappers() external view returns (address[] memory _defaultSwappers);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    function claimFees(address _pair) external;
    function claimRewards(address _pair) external;
    function claimInsuranceRewards() external;
    function withdrawTo(address _asset, uint256 _amount, address _to) external;
    function mint( address receiver, uint256 amount) external;
    function burn( address target, uint256 amount) external;
    function liquidationHandler() external view returns(address);
    function feeDeposit() external view returns(address);
    function redemptionHandler() external view returns(address);
    function rewardHandler() external view returns(address);
    function insurancePool() external view returns(address);
    function setRewardClaimer(address _newAddress) external;
    function setRedemptionHandler(address _newAddress) external;
    function setFeeDeposit(address _newAddress) external;
    function setLiquidationHandler(address _newAddress) external;
    function setInsurancePool(address _newAddress) external;
    function setStaker(address _newAddress) external;
    function setTreasury(address _newAddress) external;
    function staker() external view returns(address);
    function token() external view returns(address);
    function treasury() external view returns(address);
    function govToken() external view returns(address);
    function l2manager() external view returns(address);
    function setRewardHandler(address _newAddress) external;
    function setVestManager(address _newAddress) external;
    function setDefaultSwappers(address[] memory _swappers) external;
    function collateralId(address _collateral) external view returns(uint256);
}
// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { SafeERC20 as OZSafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// solhint-disable avoid-low-level-calls
// solhint-disable max-line-length

/// @title SafeERC20 provides helper functions for safe transfers as well as safe metadata access
/// @author Library originally written by @Boring_Crypto github.com/boring_crypto, modified by Drake Evans (Frax Finance) github.com/drakeevans
/// @dev original: https://github.com/boringcrypto/BoringSolidity/blob/fed25c5d43cb7ce20764cd0b838e21a02ea162e9/contracts/libraries/BoringERC20.sol
library SafeERC20 {
    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()

    function returnDataToString(bytes memory data) internal pure returns (string memory) {
        if (data.length >= 64) {
            return abi.decode(data, (string));
        } else if (data.length == 32) {
            uint8 i = 0;
            while (i < 32 && data[i] != 0) {
                i++;
            }
            bytes memory bytesArray = new bytes(i);
            for (i = 0; i < 32 && data[i] != 0; i++) {
                bytesArray[i] = data[i];
            }
            return string(bytesArray);
        } else {
            return "???";
        }
    }

    /// @notice Provides a safe ERC20.symbol version which returns '???' as fallback string.
    /// @param token The address of the ERC-20 token contract.
    /// @return (string) Token symbol.
    function safeSymbol(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_SYMBOL));
        return success ? returnDataToString(data) : "???";
    }

    /// @notice Provides a safe ERC20.name version which returns '???' as fallback string.
    /// @param token The address of the ERC-20 token contract.
    /// @return (string) Token name.
    function safeName(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_NAME));
        return success ? returnDataToString(data) : "???";
    }

    /// @notice Provides a safe ERC20.decimals version which returns '18' as fallback value.
    /// @param token The address of the ERC-20 token contract.
    /// @return (uint8) Token decimals.
    function safeDecimals(IERC20 token) internal view returns (uint8) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_DECIMALS));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        OZSafeERC20.safeTransfer(token, to, value);
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        OZSafeERC20.safeTransferFrom(token, from, to, value);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "../libraries/SafeERC20.sol";
import { IMintable } from "../interfaces/IMintable.sol";
import { RewardDistributorMultiEpoch } from "./RewardDistributorMultiEpoch.sol";
import { IResupplyRegistry } from "../interfaces/IResupplyRegistry.sol";
import { CoreOwnable } from '../dependencies/CoreOwnable.sol';

contract InsurancePool is RewardDistributorMultiEpoch, CoreOwnable{
    using SafeERC20 for IERC20;

    address immutable public asset;
    address immutable public registry;
    
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    uint256 constant public SHARE_REFACTOR_PRECISION = 1e12;

    uint256 public minimumHeldAssets = 10_000 * 1e18;

    uint256 public withdrawTime = 7 days;
    uint256 public withdrawTimeLimit = 1 days;
    mapping(address => uint256) public withdrawQueue;

    address public immutable emissionsReceiver;
    uint256 public constant MAX_WITHDRAW_DELAY = 14 days;

    //events
    event Deposit(
        address indexed sender,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 shares,
        uint256 assets
    );

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Cooldown(address indexed account, uint256 amount, uint256 end);
    event ExitCancel(address indexed account);
    event WithdrawTimersUpdated(uint256 withdrawTime, uint256 withdrawWindow);
    event MinimumHeldAssetsUpdated(uint256 minimumAssets);

    constructor(address _core, address _registry, address _asset, address[] memory _rewards, address _emissionsReceiver) CoreOwnable(_core){
        asset = _asset;
        registry = _registry;
        emissionsReceiver = _emissionsReceiver;
        //initialize rewards list with passed in reward tokens
        //NOTE: slot 0 should be emission based extra reward
        for(uint256 i = 0; i < _rewards.length;){
            _insertRewardToken(_rewards[i]);
            unchecked { i += 1; }
        }
        

        //mint unbacked shares to this address
        //deployment should send the outstanding amount
        _mint(address(this), 1e18);
    }

    function name() external pure returns (string memory){
        return "Resupply Insurance Pool";
    }

    function symbol() external pure returns (string memory){
        return "reIP";
    }

    function decimals() external pure returns (uint8){
        return 18;
    }

    /// @notice set unlock length and withdraw window
    /// @param _withdrawLength time to unlock
    /// @param _withdrawWindow time to withdraw after unlock
    function setWithdrawTimers(uint256 _withdrawLength, uint256 _withdrawWindow) external onlyOwner{
        require(_withdrawLength <= MAX_WITHDRAW_DELAY, "too high");
        withdrawTime = _withdrawLength;
        withdrawTimeLimit = _withdrawWindow;
        emit WithdrawTimersUpdated(_withdrawLength, _withdrawWindow);
    }

    /// @notice set a minimum amount of assets that must be kept from being burned
    /// @param _minimum the amount of assets to protect from burn
    function setMinimumHeldAssets(uint256 _minimum) external onlyOwner{
        require(_minimum >= 1e18, "too low");
        minimumHeldAssets = _minimum;
        emit MinimumHeldAssetsUpdated(_minimum);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// @notice balance of a given account
    /// @param _account the user account
    function balanceOf(address _account) public view returns (uint256 userBalance) {
        userBalance = _balances[_account];

        uint256 globalEpoch = currentRewardEpoch;
        uint256 userEpoch = userRewardEpoch[_account];

        if(userEpoch < globalEpoch){
            //need to calculate balance while keeping this as a view function
            for(;;){
                //reduce shares by refactoring amount
                userBalance /= SHARE_REFACTOR_PRECISION;
                unchecked {
                    userEpoch += 1;
                }
                if(userEpoch == globalEpoch){
                    break;
                }
            }
        }
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    // ============================================================================================
    // Reward Implementation
    // ============================================================================================

    function _isRewardManager() internal view override returns(bool){
        return msg.sender == address(core)
        || msg.sender == IResupplyRegistry(registry).rewardHandler();
    }

    function _fetchIncentives() internal override{
        IResupplyRegistry(registry).claimInsuranceRewards();
    }

    function _totalRewardShares() internal view override returns(uint256){
        return _totalSupply;
    }

    function _userRewardShares(address _account) internal view override returns(uint256){
        return _balances[_account];
    }

    function _increaseUserRewardEpoch(address _account, uint256 _currentUserEpoch) internal override{
        //convert shares to next epoch shares
        //share refactoring will never be 0
        _balances[_account] = _balances[_account] / SHARE_REFACTOR_PRECISION;
        //update user reward epoch
        userRewardEpoch[_account] = _currentUserEpoch + 1;
    }

    function _checkAddToken(address _address) internal view override returns(bool){
        if(_address == asset) return false;
        return true;
    }

    //we cant limit reward types since collaterals could be sent as rewards
    //however reward lists growing too large is undesirable
    //governance should act if too many are added
    function maxRewards() public pure override returns(uint256){
        return type(uint256).max;
    }

    function maxBurnableAssets() public view returns(uint256){
        uint256 minimumHeld = minimumHeldAssets;
        uint256 _totalAssets = totalAssets();
        return _totalAssets > minimumHeld ? _totalAssets - minimumHeld : 0;
    }

    /// @notice burn underlying, liquidationHandler will send rewards in exchange
    /// @param _amount the amount to burn
    function burnAssets(uint256 _amount) external {
        require(msg.sender == IResupplyRegistry(registry).liquidationHandler(), "!liq handler");
        require(_amount <= maxBurnableAssets(), "!minimumAssets");

        IMintable(asset).burn(address(this), _amount);

        //if after many burns the amount to shares ratio has deteriorated too far, then refactor
        uint256 tsupply = _totalSupply;
        if(totalAssets() * SHARE_REFACTOR_PRECISION < tsupply){
            _increaseRewardEpoch(); //will do final checkpoint on previous total supply
            tsupply /= SHARE_REFACTOR_PRECISION;
            _totalSupply = tsupply;
        }
    }

    /// @notice deposit assets into the insurance pool
    /// @param _assets the amount of tokens to deposit
    /// @param _receiver the receiving address
    /// @return shares amount of shares minted
    function deposit(uint256 _assets, address _receiver) external nonReentrant returns (uint256 shares){
        //can not deposit if in withdraw queue, call cancel first
        require(withdrawQueue[_receiver] == 0,"withdraw queued");

        //checkpoint rewards before balance change
        _checkpoint(_receiver);
         if (_assets > 0) {
            shares = previewDeposit(_assets);
            if(shares > 0){
                _mint(_receiver, shares);
                IERC20(asset).safeTransferFrom(msg.sender, address(this), _assets);
                emit Deposit(msg.sender, _receiver, _assets, shares);
            }
        }
    }

    /// @notice mint shares
    /// @param _shares the amount of shares to mint
    /// @param _receiver the receving address
    /// @return assets amount of assets minted
    function mint(uint256 _shares, address _receiver) external nonReentrant returns (uint256 assets){
        //can not deposit if in withdraw queue, call cancel first
        require(withdrawQueue[_receiver] == 0,"withdraw queued");

        //checkpoint rewards before balance change
        _checkpoint(_receiver);
        if (_shares > 0) {
            assets = previewMint(_shares);
            if(assets > 0){
                _mint(_receiver, _shares);
                IERC20(asset).safeTransferFrom(msg.sender, address(this), assets);
                emit Deposit(msg.sender, _receiver, assets, _shares);
            }
        }
    }

    /// @notice start unlock timing for msg.sender
    function exit() external{
        //clear any previous withdraw queue and restart
        _clearWithdrawQueueGuarded(msg.sender);
        
        //claim all rewards now because reward0 will be excluded during
        //the withdraw sequence
        //will error if already in withdraw process
        getReward(msg.sender);

        //set withdraw time
        uint256 exitTime = block.timestamp + withdrawTime;
        withdrawQueue[msg.sender] = exitTime;

        emit Cooldown(msg.sender, balanceOf(msg.sender), exitTime);
    }

    /// @notice cancel exit timer for msg.sender
    function cancelExit() external{
        //canceling will remove claimable emissions
        //but will redistribute those claimable back into the pool
        //thus a portion will go back to msg.sender in accordance with its weight
        _clearWithdrawQueueGuarded(msg.sender);
        emit ExitCancel(msg.sender);
    }

    function _clearWithdrawQueueGuarded(address _account) internal nonReentrant{
        _clearWithdrawQueue(_account);
    }

    function _clearWithdrawQueue(address _account) internal {
        if(withdrawQueue[_account] != 0){
            //checkpoint rewards
            _checkpoint(_account);
            //get reward 0 info
            RewardType storage reward = rewards[0];
            address rewardToken = reward.reward_token;
            //note how much is claimable
            uint256 reward0 = claimable_reward[rewardToken][_account];
            //reset claimable
            claimable_reward[rewardToken][_account] = 0;
            //redistribute back to pool
            reward.reward_remaining -= reward0;

            withdrawQueue[_account] = 0; //flag as not waiting for withdraw
        }
    }

    function _checkWithdrawReady(address _account) internal view{
        uint256 exitTime = withdrawQueue[_account];
        require(exitTime > 0 && block.timestamp >= exitTime, "!withdraw time");
        require(block.timestamp <= exitTime + withdrawTimeLimit, "withdraw time over");
    }

    /// @notice burn shares and withdraw underlying assets
    /// @param _shares number of shares to redeem
    /// @param _receiver address to send underlying to
    /// @param _owner the account to redeem from (must equal msg.sender)
    /// @return assets amount of asset tokens received
    function redeem(uint256 _shares, address _receiver, address _owner) external nonReentrant returns (uint256 assets){
        require(msg.sender == _owner);

        _checkWithdrawReady(msg.sender);
        if (_shares > 0) {
            //clear queue will also checkpoint rewards
            _clearWithdrawQueue(msg.sender);
            
            assets = previewRedeem(_shares);
            require(assets != 0, "ZERO_ASSETS");
            _burn(msg.sender, _shares);
            IERC20(asset).safeTransfer(_receiver, assets);
            emit Withdraw(msg.sender, _receiver, msg.sender, _shares, assets);
        }
    }

    /// @notice withdraw underlying assets
    /// @param _amount amount of underlying assets to withdraw
    /// @param _receiver the receiving address
    /// @param _owner the account to redeem from (must equal msg.sender)
    /// @return shares amount of shares burned
    function withdraw(uint256 _amount, address _receiver, address _owner) external nonReentrant returns(uint256 shares){
        require(msg.sender == _owner);

        _checkWithdrawReady(msg.sender);
        if (_amount > 0) {
            //clear queue will also checkpoint rewards
            _clearWithdrawQueue(msg.sender);

            shares = previewWithdraw(_amount);
            _burn(msg.sender, shares);
            IERC20(asset).safeTransfer(_receiver, _amount);
            emit Withdraw(msg.sender, _receiver, msg.sender, shares, _amount);
        }
    }

    /// @notice get rewards for the given account
    /// @param _account the account to claim rewards for
    function getReward(address _account) public override{
        require(withdrawQueue[_account] == 0, "claim while queued");
        super.getReward(_account);
    }

    /// @notice get rewards for the given account
    /// @param _account the account to claim rewards for
    /// @param _forwardTo the address to send claimed rewards to
    function getReward(address _account, address _forwardTo) public override{
        require(withdrawQueue[_account] == 0, "claim while queued");
        super.getReward(_account,_forwardTo);
    }

    /// @notice check what rewards are claimable
    /// @param _account the account to query
    /// @dev not a view function
    function earned(address _account) public override returns(EarnedData[] memory claimable) {
        claimable = super.earned(_account);
        if(withdrawQueue[_account] > 0){
            claimable[0].amount = 0;
        }
    }

    function totalAssets() public view returns(uint256 assets){
        assets = IERC20(asset).balanceOf(address(this));
    }

    function convertToShares(uint256 _assets) public view returns (uint256 shares){
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            shares = _assets;
        } else {
            shares = _assets * _totalSupply / totalAssets();
        }
    }

    function convertToAssets(uint256 _shares) public view returns (uint256 assets){
        uint256 _totalSupply = totalSupply();
        if(_totalSupply > 0){
            assets = totalAssets() * _shares / _totalSupply;
        } else{
            assets = _shares;
        }
    }

    function convertToSharesRoundUp(uint256 _assets) internal view returns (uint256 shares){
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            shares = _assets;
        } else {
            uint256 _totalAssets = totalAssets();
            shares = _assets * _totalSupply / _totalAssets;
            if ( shares * _totalAssets / _totalSupply < _assets) {
                shares = shares + 1;
            }
        }
    }

    function convertToAssetsRoundUp(uint256 _shares) internal view returns (uint256 assets){
        uint256 _totalSupply = totalSupply();
        if(_totalSupply > 0){
            uint256 _totalAssets = totalAssets();
            assets = _totalAssets * _shares / _totalSupply;
            if ( assets * _totalSupply / _totalAssets < _shares) {
                assets = assets + 1;
            }
        }else{
            assets = _shares;
        }
    }

    function maxDeposit(address /*_receiver*/) external pure returns (uint256){
        return type(uint256).max;
    }
    function maxMint(address /*_receiver*/) external pure returns (uint256){
        return type(uint256).max;
    }
    function previewDeposit(uint256 _amount) public view returns (uint256){
        return convertToShares(_amount);
    }
    function previewMint(uint256 _shares) public view returns (uint256){
        return convertToAssetsRoundUp(_shares); //round up
    }
    function maxWithdraw(address _owner) external view returns (uint256){
        return convertToAssets(balanceOf(_owner));
    }
    function previewWithdraw(uint256 _amount) public view returns (uint256){
        return convertToSharesRoundUp(_amount); //round up
    }
    function maxRedeem(address _owner) external view returns (uint256){
        return balanceOf(_owner);
    }
    function previewRedeem(uint256 _shares) public view returns (uint256){
        return convertToAssets(_shares);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


//abstract reward handling to attach to another contract
//supports an epoch system for supply changes
abstract contract RewardDistributorMultiEpoch is ReentrancyGuard{
    using SafeERC20 for IERC20;

    struct EarnedData {
        address token;
        uint256 amount;
    }

    struct RewardType {
        address reward_token;
        bool is_non_claimable; //a bit unothrodox setting but need to block claims on our redemption tokens as they will be processed differently
        uint256 reward_remaining;
    }

    //rewards
    RewardType[] public rewards;
    uint256 public currentRewardEpoch;
    mapping(address => uint256) public userRewardEpoch; //account -> epoch
    mapping(uint256 => mapping(address => uint256)) public global_reward_integral; //epoch -> token -> integral
    mapping(uint256 => mapping(address => mapping(address => uint256))) public reward_integral_for;// epoch -> token -> account -> integral
    mapping(address => mapping(address => uint256)) public claimable_reward;//token -> account -> claimable
    mapping(address => uint256) public rewardMap;
    mapping(address => address) public rewardRedirect;
    
    uint256 constant private PRECISION = 1e22;

    //events
    event RewardPaid(address indexed _user, address indexed _rewardToken, address indexed _receiver, uint256 _rewardAmount);
    event RewardAdded(address indexed _rewardToken);
    event RewardInvalidated(address indexed _rewardToken);
    event RewardRedirected(address indexed _account, address _forward);
    event NewEpoch(uint256 indexed _epoch);

    constructor() {

    }

    modifier onlyRewardManager() {
        require(_isRewardManager(), "!rewardManager");
        _;
    }

/////////
//  Abstract functions
////////

    function _isRewardManager() internal view virtual returns(bool);

    function _fetchIncentives() internal virtual;

    function _totalRewardShares() internal view virtual returns(uint256);

    function _userRewardShares(address _account) internal view virtual returns(uint256);

    function _increaseUserRewardEpoch(address _account, uint256 _currentUserEpoch) internal virtual;

    function _checkAddToken(address _address) internal view virtual returns(bool);
//////////

    function maxRewards() public pure virtual returns(uint256){
        return 15;
    }

    //register an extra reward token to be handled
    function addExtraReward(address _token) external onlyRewardManager nonReentrant{
        //add to reward list
        _insertRewardToken(_token);
    }

    //insert a new reward, ignore if already registered or invalid
    function _insertRewardToken(address _token) internal{
        if(_token == address(this) || _token == address(0) || !_checkAddToken(_token)){
            //dont allow reward tracking of the staking token or invalid address
            return;
        }

        //add to reward list if new
        if(rewardMap[_token] == 0){
            //check reward count for new additions
            require(rewards.length < maxRewards(), "max rewards");

            //set token
            RewardType storage r = rewards.push();
            r.reward_token = _token;
            
            //set map index after push (mapped value is +1 of real index)
            rewardMap[_token] = rewards.length;

            emit RewardAdded(_token);
            //workaround: transfer 0 to self so that earned() reports correctly
            //with new tokens
            if(_token.code.length > 0){
                IERC20(_token).safeTransfer(address(this), 0);
            }else{
                //non contract address added? invalidate
                _invalidateReward(_token);
            }
        }else{
            //get previous used index of given token
            //this ensures that reviving can only be done on the previous used slot
            uint256 index = rewardMap[_token];
            //index is rewardMap minus one
            RewardType storage reward = rewards[index-1];
            //check if it was invalidated
            if(reward.reward_token == address(0)){
                //revive
                reward.reward_token = _token;
                emit RewardAdded(_token);
            }
        }
    }

    //allow invalidating a reward if the token causes trouble in calcRewardIntegral
    function invalidateReward(address _token) external onlyRewardManager nonReentrant{
        _invalidateReward(_token);
    }

    function _invalidateReward(address _token) internal{
        uint256 index = rewardMap[_token];
        if(index > 0){
            //index is registered rewards minus one
            RewardType storage reward = rewards[index-1];
            require(reward.reward_token == _token, "!mismatch");
            //set reward token address to 0, integral calc will now skip
            reward.reward_token = address(0);
            emit RewardInvalidated(_token);
        }
    }

    //get reward count
    function rewardLength() external view returns(uint256) {
        return rewards.length;
    }

    //calculate and record an account's earnings of the given reward.  if _claimTo is given it will also claim.
    function _calcRewardIntegral(uint256 _epoch, uint256 _currentEpoch, uint256 _index, address _account, address _claimTo) internal{
        RewardType storage reward = rewards[_index];
        address rewardToken = reward.reward_token;
        //skip invalidated rewards
        //if a reward token starts throwing an error, calcRewardIntegral needs a way to exit
        if(rewardToken == address(0)){
           return;
        }

        //get difference in balance and remaining rewards
        //getReward is unguarded so we use reward_remaining to keep track of how much was actually claimed since last checkpoint
        uint256 bal = IERC20(rewardToken).balanceOf(address(this));
        uint256 remainingRewards = reward.reward_remaining;
        
        //update the global integral but only for the current epoch
        if (_epoch == _currentEpoch && _totalRewardShares() > 0 && bal > remainingRewards) {
            uint256 rewardPerToken = ((bal - remainingRewards) * PRECISION / _totalRewardShares());
            if(rewardPerToken > 0){
                //increase integral
                global_reward_integral[_epoch][rewardToken] += rewardPerToken;
            }else{
                //set balance as current reward_remaining to let dust grow
                bal = remainingRewards;
            }
        }

        uint256 reward_global = global_reward_integral[_epoch][rewardToken];

        if(_account != address(0)){
            //update user integrals
            uint userI = reward_integral_for[_epoch][rewardToken][_account];
            if(_claimTo != address(0) || userI < reward_global){
                //_claimTo address non-zero means its a claim 
                // only allow claims if current epoch and if the reward allows it
                if(_epoch == _currentEpoch && _claimTo != address(0) && !reward.is_non_claimable){
                    uint256 receiveable = claimable_reward[rewardToken][_account] + (_userRewardShares(_account) * (reward_global - userI) / PRECISION);
                    if(receiveable > 0){
                        claimable_reward[rewardToken][_account] = 0;
                        IERC20(rewardToken).safeTransfer(_claimTo, receiveable);
                        emit RewardPaid(_account, rewardToken, _claimTo, receiveable);
                        //remove what was claimed from balance
                        bal -= receiveable;
                    }
                }else{
                    claimable_reward[rewardToken][_account] = claimable_reward[rewardToken][_account] + ( _userRewardShares(_account) * (reward_global - userI) / PRECISION);
                }
                reward_integral_for[_epoch][rewardToken][_account] = reward_global;
            }
        }


        //update remaining reward so that next claim can properly calculate the balance change
        //claims and tracking new rewards should only happen on current epoch
        if(_epoch == _currentEpoch && bal != remainingRewards){
            reward.reward_remaining = bal;
        }
    }

    function _increaseRewardEpoch() internal{
        //final checkpoint for this epoch
        _checkpoint(address(0), address(0), type(uint256).max);

        //move epoch up
        uint256 newEpoch = currentRewardEpoch + 1;
        currentRewardEpoch = newEpoch;

        emit NewEpoch(newEpoch);
    }

    //checkpoint without claiming
    function _checkpoint(address _account) internal {
        //checkpoint without claiming by passing address(0)
        //default to max as most operations such as deposit/withdraw etc needs to fully sync beforehand
        _checkpoint(_account, address(0), type(uint256).max);
    }

    //checkpoint with claim
    function _checkpoint(address _account, address _claimTo, uint256 _maxloops) internal {
        //claim rewards first
        _fetchIncentives();

        uint256 globalEpoch = currentRewardEpoch;
        uint256 rewardCount = rewards.length;

        for (uint256 loops = 0; loops < _maxloops;) {
            uint256 userEpoch = globalEpoch;

            if(_account != address(0)){
                //take user epoch
                userEpoch = userRewardEpoch[_account];

                //if no shares then jump to current epoch
                if(userEpoch != globalEpoch && _userRewardShares(_account) == 0){
                    userEpoch = globalEpoch;
                    userRewardEpoch[_account] = userEpoch;
                }
            }
            
            //calc reward integrals
            for(uint256 i = 0; i < rewardCount;){
                _calcRewardIntegral(userEpoch, globalEpoch, i,_account,_claimTo);
                unchecked { i += 1; }
            }
            if(userEpoch < globalEpoch){
                _increaseUserRewardEpoch(_account, userEpoch);
            }else{
                return;
            }
            unchecked { loops += 1; }
        }
    }

    //manually checkpoint a user account
    function user_checkpoint(address _account, uint256 _epochloops) external nonReentrant returns(bool) {
        _checkpoint(_account, address(0), _epochloops);
        return true;
    }

    //get earned token info
    //change ABI to view to use this off chain
    function earned(address _account) public nonReentrant virtual returns(EarnedData[] memory claimable) {
        
        //because this is a state mutative function
        //we can simplify the earned() logic of all rewards (internal and external)
        //and allow this contract to be agnostic to outside reward contract design
        //by just claiming everything and updating state via _checkpoint()
        _checkpoint(_account);
        uint256 rewardCount = rewards.length;
        claimable = new EarnedData[](rewardCount);

        for (uint256 i = 0; i < rewardCount;) {
            RewardType storage reward = rewards[i];

            //skip invalidated and non claimable rewards
            if(reward.reward_token == address(0) || reward.is_non_claimable){
                unchecked{ i += 1; }
                continue;
            }
    
            claimable[i].amount = claimable_reward[reward.reward_token][_account];
            claimable[i].token = reward.reward_token;

            unchecked{ i += 1; }
        }
        return claimable;
    }

    //set any claimed rewards to automatically go to a different address
    //set address to zero to disable
    function setRewardRedirect(address _to) external nonReentrant{
        rewardRedirect[msg.sender] = _to;
        emit RewardRedirected(msg.sender, _to);
    }

    //claim reward for given account (unguarded)
    function getReward(address _account) public virtual nonReentrant {
        //check if there is a redirect address
        address redirect = rewardRedirect[_account];
        if(redirect != address(0)){
            _checkpoint(_account, redirect, type(uint256).max);
        }else{
            //claim directly in checkpoint logic to save a bit of gas
            _checkpoint(_account, _account, type(uint256).max);
        }
    }

    //claim reward for given account and forward (guarded)
    function getReward(address _account, address _forwardTo) public virtual nonReentrant{
        //in order to forward, must be called by the account itself
        require(msg.sender == _account, "!self");
        require(_forwardTo != address(0), "fwd address cannot be 0");
        //use _forwardTo address instead of _account
        _checkpoint(_account, _forwardTo, type(uint256).max);
    }
}