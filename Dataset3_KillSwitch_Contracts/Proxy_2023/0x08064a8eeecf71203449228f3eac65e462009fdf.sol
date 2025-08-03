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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

/**
 * @dev Wrappers over Solidity's uintXX/intXX/bool casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }

    /**
     * @dev Cast a boolean (false or true) to a uint256 (0 or 1) with no jump.
     */
    function toUint(bool b) internal pure returns (uint256 u) {
        assembly ("memory-safe") {
            u := iszero(iszero(b))
        }
    }
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

import "../interfaces/ICore.sol";

/**
    @title EpochTracker
    @dev Provides a unified `startTime` and `getEpoch`, used for tracking epochs.
 */
contract EpochTracker {
    uint256 public immutable startTime;
    
    /// @notice Length of an epoch, in seconds
    uint256 public immutable epochLength;

    constructor(address _core) {
        startTime = ICore(_core).startTime();
        epochLength = ICore(_core).epochLength();
    }

    function getEpoch() public view returns (uint256 epoch) {
        return (block.timestamp - startTime) / epochLength;
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

interface IConvexStaking {
    function poolInfo(uint256 _pid) external view returns(
        address lptoken,
        address token,
        address gauge,
        address crvRewards,
        address stash,
        bool shutdown
    );
    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns(bool);
    function depositAll(uint256 _pid, bool _stake) external returns(bool);
    function withdrawAndUnwrap(uint256 amount, bool claim) external returns(bool);
    function withdrawAllAndUnwrap(bool claim) external;
    function getReward() external returns(bool);
    function getReward(address _account, bool _claimExtras) external returns(bool);
    function totalSupply() external view returns (uint256);
    function extraRewardsLength() external view returns (uint256);
    function extraRewards(uint256 _rid) external view returns (address _rewardContract);
    function rewardToken() external view returns (address _rewardToken);
    function token() external view returns (address _token);
    function balanceOf(address account) external view returns (uint256);
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

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    function asset() external view returns (address);

    function convertToAssets(uint256 shares) external view returns (uint256);

    function convertToShares(uint256 assets) external view returns (uint256);

    function maxDeposit(address) external view returns (uint256);

    function maxMint(address) external view returns (uint256);

    function maxRedeem(address owner) external view returns (uint256);

    function maxWithdraw(address owner) external view returns (uint256);

    function previewDeposit(uint256 assets) external view returns (uint256);

    function previewMint(uint256 shares) external view returns (uint256);

    function previewRedeem(uint256 shares) external view returns (uint256);

    function previewWithdraw(uint256 assets) external view returns (uint256);

    function totalAssets() external view returns (uint256);

    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IFeeDeposit {
    function operator() external view returns(address);
    function lastDistributedEpoch() external view returns(uint256);
    function setOperator(address _newAddress) external;
    function distributeFees() external;
    function incrementPairRevenue(uint256 _fees, uint256 _otherFees) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILiquidationHandler {
    function operator() external view returns(address);
    function setOperator(address _newAddress) external;
    function processLiquidationDebt(address _collateral, uint256 _collateralAmount, uint256 _debtAmount) external;
    function processCollateral(address _collateral) external;
    function liquidate(
        address _pair,
        address _borrower
    ) external returns (uint256 _collateralForLiquidator);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IMintable{
    function mint(address _to, uint256 _amount) external;
    function burn(address _from, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IOracle {
    function decimals() external view returns (uint8);

    function getPrices(address _vault) external view returns (uint256 _price);

    function name() external view returns (string memory);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IRateCalculator {
    function name() external view returns (string memory);

    function version() external view returns (uint256, uint256, uint256);

    function getNewRate(
        address _vault,
        uint256 _deltaTime,
        uint256 _previousShares
    ) external view returns (uint64 _newRatePerSec, uint128 _newShares);
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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ISwapper {
    function swap(
        address account,
        uint256 amountIn,
        address[] calldata path,
        address to
    ) external;

    function swapPools(address tokenIn, address tokenOut) external view returns(address swappool, int32 tokenInIndex, int32 tokenOutIndex, uint32 swaptype);
}
// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

struct VaultAccount {
    uint128 amount; // Total amount, analogous to market cap
    uint128 shares; // Total shares, analogous to shares outstanding
}

/// @title VaultAccount Library
/// @author Drake Evans (Frax Finance) github.com/drakeevans, modified from work by @Boring_Crypto github.com/boring_crypto
/// @notice Provides a library for use with the VaultAccount struct, provides convenient math implementations
/// @dev Uses uint128 to save on storage
library VaultAccountingLibrary {
    /// @notice Calculates the shares value in relationship to `amount` and `total`
    /// @dev Given an amount, return the appropriate number of shares
    function toShares(VaultAccount memory total, uint256 amount, bool roundUp) internal pure returns (uint256 shares) {
        if (total.amount == 0) {
            shares = amount;
        } else {
            shares = (amount * total.shares) / total.amount;
            if (roundUp && (shares * total.amount) / total.shares < amount) {
                shares = shares + 1;
            }
        }
    }

    /// @notice Calculates the amount value in relationship to `shares` and `total`
    /// @dev Given a number of shares, returns the appropriate amount
    function toAmount(VaultAccount memory total, uint256 shares, bool roundUp) internal pure returns (uint256 amount) {
        if (total.shares == 0) {
            amount = shares;
        } else {
            amount = (shares * total.amount) / total.shares;
            if (roundUp && total.amount > 0 && (amount * total.shares) / total.amount < shares) {
                amount = amount + 1;
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title ResupplyPair
 * @notice Based on code from Drake Evans and Frax Finance's lending pair contract (https://github.com/FraxFinance/fraxlend), adapted for Resupply Finance
 */

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { ResupplyPairConstants } from "./pair/ResupplyPairConstants.sol";
import { ResupplyPairCore } from "./pair/ResupplyPairCore.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { VaultAccount, VaultAccountingLibrary } from "../libraries/VaultAccount.sol";
import { IRateCalculator } from "../interfaces/IRateCalculator.sol";
import { ISwapper } from "../interfaces/ISwapper.sol";
import { IFeeDeposit } from "../interfaces/IFeeDeposit.sol";
import { IResupplyRegistry } from "../interfaces/IResupplyRegistry.sol";
import { IConvexStaking } from "../interfaces/IConvexStaking.sol";
import { EpochTracker } from "../dependencies/EpochTracker.sol";

contract ResupplyPair is ResupplyPairCore, EpochTracker {
    using VaultAccountingLibrary for VaultAccount;
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    uint256 public lastFeeEpoch;
    address public constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;

    // Staking Info
    address public immutable convexBooster;
    uint256 public convexPid;
    
    error FeesAlreadyDistributed();
    error IncorrectStakeBalance();

    /// @param _core Core contract address
    /// @param _configData config data
    /// @param _immutables immutable data
    /// @param _customConfigData extras
    constructor(
        address _core,
        bytes memory _configData,
        bytes memory _immutables,
        bytes memory _customConfigData
    ) ResupplyPairCore(_core, _configData, _immutables, _customConfigData) EpochTracker(_core) {

        (, address _govToken, address _convexBooster, uint256 _convexpid) = abi.decode(
            _customConfigData,
            (string, address, address, uint256)
        );
        //add gov token rewards
        _insertRewardToken(_govToken);

        //convex info
        if(_convexBooster != address(0)){
            convexBooster = _convexBooster;
            convexPid = _convexpid;
            //approve
            collateral.forceApprove(convexBooster, type(uint256).max);
            //add rewards for curve staking
            _insertRewardToken(CRV);
            _insertRewardToken(CVX);

            emit SetConvexPool(_convexpid);
        }
    }


    // ============================================================================================
    // Functions: Helpers
    // ============================================================================================

    function getConstants()
        external
        pure
        returns (
            uint256 _LTV_PRECISION,
            uint256 _LIQ_PRECISION,
            uint256 _EXCHANGE_PRECISION,
            uint256 _RATE_PRECISION
        )
    {
        _LTV_PRECISION = LTV_PRECISION;
        _LIQ_PRECISION = LIQ_PRECISION;
        _EXCHANGE_PRECISION = EXCHANGE_PRECISION;
        _RATE_PRECISION = RATE_PRECISION;
    }

    /// @notice The ```getUserSnapshot``` function gets user level accounting data
    /// @param _address The user address
    /// @return _borrowShares The user borrow shares
    /// @return _collateralBalance The user collateral balance
    function getUserSnapshot(
        address _address
    ) external returns (uint256 _borrowShares, uint256 _collateralBalance) {
        _collateralBalance = userCollateralBalance(_address);
        _borrowShares = userBorrowShares(_address);
    }

    /// @notice The ```getPairAccounting``` function gets all pair level accounting numbers
    /// @return _claimableFees Total claimable fees
    /// @return _totalBorrowAmount Total borrows
    /// @return _totalBorrowShares Total borrow shares
    /// @return _totalCollateral Total collateral
    function getPairAccounting()
        external
        view
        returns (
            uint256 _claimableFees,
            uint128 _totalBorrowAmount,
            uint128 _totalBorrowShares,
            uint256 _totalCollateral
        )
    {
        VaultAccount memory _totalBorrow;
        (, , _claimableFees, _totalBorrow) = previewAddInterest();
        _totalBorrowAmount = _totalBorrow.amount;
        _totalBorrowShares = _totalBorrow.shares;
        _totalCollateral = totalCollateral();
    }

    /// @notice The ```toBorrowShares``` function converts a given amount of borrow debt into the number of shares
    /// @param _amount Amount of borrow
    /// @param _roundUp Whether to roundup during division
    /// @param _previewInterest Whether to simulate interest accrual
    /// @return _shares The number of shares
    function toBorrowShares(
        uint256 _amount,
        bool _roundUp,
        bool _previewInterest
    ) external view returns (uint256 _shares) {
        if (_previewInterest) {
            (, , , VaultAccount memory _totalBorrow) = previewAddInterest();
            _shares = _totalBorrow.toShares(_amount, _roundUp);
        } else {
            _shares = totalBorrow.toShares(_amount, _roundUp);
        }
    }

    /// @notice The ```toBorrowAmount``` function converts a given amount of borrow debt into the number of shares
    /// @param _shares Shares of borrow
    /// @param _roundUp Whether to roundup during division
    /// @param _previewInterest Whether to simulate interest accrual
    /// @return _amount The amount of asset
    function toBorrowAmount(
        uint256 _shares,
        bool _roundUp,
        bool _previewInterest
    ) external view returns (uint256 _amount) {
        if (_previewInterest) {
            (, , , VaultAccount memory _totalBorrow) = previewAddInterest();
            _amount = _totalBorrow.toAmount(_shares, _roundUp);
        } else {
            _amount = totalBorrow.toAmount(_shares, _roundUp);
        }
    }
    // ============================================================================================
    // Functions: Configuration
    // ============================================================================================


    /// @notice The ```SetOracleInfo``` event is emitted when the oracle info is set
    /// @param oldOracle The old oracle address
    /// @param newOracle The new oracle address
    event SetOracleInfo(
        address oldOracle,
        address newOracle
    );

    /// @notice The ```setOracleInfo``` function sets the oracle data
    /// @param _newOracle The new oracle address
    function setOracle(address _newOracle) external onlyOwner{
        ExchangeRateInfo memory _exchangeRateInfo = exchangeRateInfo;
        emit SetOracleInfo(
            _exchangeRateInfo.oracle,
            _newOracle
        );
        _exchangeRateInfo.oracle = _newOracle;
        exchangeRateInfo = _exchangeRateInfo;
    }

    /// @notice The ```SetMaxLTV``` event is emitted when the max LTV is set
    /// @param oldMaxLTV The old max LTV
    /// @param newMaxLTV The new max LTV
    event SetMaxLTV(uint256 oldMaxLTV, uint256 newMaxLTV);

    /// @notice The ```setMaxLTV``` function sets the max LTV
    /// @param _newMaxLTV The new max LTV
    function setMaxLTV(uint256 _newMaxLTV) external onlyOwner{
        if (_newMaxLTV > LTV_PRECISION) revert InvalidParameter();
        emit SetMaxLTV(maxLTV, _newMaxLTV);
        maxLTV = _newMaxLTV;
    }

 
    /// @notice The ```SetRateCalculator``` event is emitted when the rate contract is set
    /// @param oldRateCalculator The old rate contract
    /// @param newRateCalculator The new rate contract
    event SetRateCalculator(address oldRateCalculator, address newRateCalculator);

    /// @notice The ```setRateCalculator``` function sets the rate contract address
    /// @param _newRateCalculator The new rate contract address
    /// @param _updateInterest Whether to update interest before setting new rate calculator
    function setRateCalculator(address _newRateCalculator, bool _updateInterest) external onlyOwner{
        //should add interest before changing rate calculator
        //however if there is an intrinsic problem with the current rate calculate, need to be able
        //to update without calling addInterest
        if(_updateInterest){
            _addInterest();
        }
        emit SetRateCalculator(address(rateCalculator), _newRateCalculator);
        rateCalculator = IRateCalculator(_newRateCalculator);
    }


    /// @notice The ```SetLiquidationFees``` event is emitted when the liquidation fees are set
    /// @param oldLiquidationFee The old clean liquidation fee
    /// @param newLiquidationFee The new clean liquidation fee
    event SetLiquidationFees(
        uint256 oldLiquidationFee,
        uint256 newLiquidationFee
    );

    /// @notice The ```setLiquidationFees``` function sets the liquidation fees
    /// @param _newLiquidationFee The new clean liquidation fee
    function setLiquidationFees(
        uint256 _newLiquidationFee
    ) external onlyOwner{
        if (_newLiquidationFee > LIQ_PRECISION) revert InvalidParameter();
        emit SetLiquidationFees(
            liquidationFee,
            _newLiquidationFee
        );
        liquidationFee = _newLiquidationFee;
    }

    /// @notice The ```SetMintFees``` event is emitted when the liquidation fees are set
    /// @param oldMintFee The old mint fee
    /// @param newMintFee The new mint fee
    event SetMintFees(
        uint256 oldMintFee,
        uint256 newMintFee
    );

    /// @notice The ```setMintFees``` function sets the mint
    /// @param _newMintFee The new mint fee
    function setMintFees(
        uint256 _newMintFee
    ) external onlyOwner{
        emit SetMintFees(
            mintFee,
            _newMintFee
        );
        mintFee = _newMintFee;
    }

    function setBorrowLimit(uint256 _limit) external onlyOwner{
        _setBorrowLimit(_limit);
    }

    /// @notice The ```SetBorrowLimit``` event is emitted when the borrow limit is set
    /// @param limit The new borrow limit
    event SetBorrowLimit(uint256 limit);

    function _setBorrowLimit(uint256 _limit) internal {
        if(_limit > type(uint128).max){
            revert InvalidParameter();
        }
        borrowLimit = _limit;
        emit SetBorrowLimit(_limit);
    }

    event SetMinimumRedemption(uint256 min);

    function setMinimumRedemption(uint256 _min) external onlyOwner{
        if(_min < 100 * PAIR_DECIMALS ){
            revert InvalidParameter();
        }
        minimumRedemption = _min;
        emit SetMinimumRedemption(_min);
    }

    event SetMinimumLeftover(uint256 min);

    function setMinimumLeftoverDebt(uint256 _min) external onlyOwner{
        minimumLeftoverDebt = _min;
        emit SetMinimumLeftover(_min);
    }

    event SetMinimumBorrowAmount(uint256 min);

    function setMinimumBorrowAmount(uint256 _min) external onlyOwner{
        minimumBorrowAmount = _min;
        emit SetMinimumBorrowAmount(_min);
    }

    event SetProtocolRedemptionFee(uint256 fee);

    /// @notice Sets the redemption fee percentage for this specific pair
    /// @dev The fee is 1e18 precision (1e16 = 1%) and taken from redemptions and sent to the protocol.
    /// @param _fee The new redemption fee percentage. Must be less than or equal to 1e18 (100%)
    function setProtocolRedemptionFee(uint256 _fee) external onlyOwner{
        if(_fee > EXCHANGE_PRECISION) revert InvalidParameter();

        protocolRedemptionFee = _fee;
        emit SetProtocolRedemptionFee(_fee);
    }

    /// @notice The ```WithdrawFees``` event fires when the fees are withdrawn
    /// @param recipient To whom the assets were sent
    /// @param interestFees the amount of interest based fees claimed
    /// @param otherFees the amount of other fees claimed(mint/redemption)
    event WithdrawFees(address recipient, uint256 interestFees, uint256 otherFees);

    /// @notice The ```withdrawFees``` function withdraws fees accumulated
    /// @return _fees the amount of interest based fees claimed
    /// @return _otherFees the amount of other fees claimed(mint/redemption)
    function withdrawFees() external nonReentrant returns (uint256 _fees, uint256 _otherFees) {

        // Accrue interest if necessary
        _addInterest();

        //get deposit contract
        address feeDeposit = IResupplyRegistry(registry).feeDeposit();
        uint256 lastDistributedEpoch = IFeeDeposit(feeDeposit).lastDistributedEpoch();
        uint256 currentEpoch = getEpoch();

        //current epoch must be greater than last claimed epoch
        //current epoch must be equal to the FeeDeposit prev distributed epoch (FeeDeposit must distribute first)
        if(currentEpoch <= lastFeeEpoch || currentEpoch != lastDistributedEpoch){
            revert FeesAlreadyDistributed();
        }

        lastFeeEpoch = currentEpoch;

        //get fees and clear
        _fees = claimableFees;
        _otherFees = claimableOtherFees;
        claimableFees = 0;
        claimableOtherFees = 0;
        //mint new stables to the receiver
        IResupplyRegistry(registry).mint(feeDeposit,_fees+_otherFees);
        //inform deposit contract of this pair's contribution
        IFeeDeposit(feeDeposit).incrementPairRevenue(_fees,_otherFees);
        emit WithdrawFees(feeDeposit, _fees, _otherFees);
    }

    /// @notice The ```SetSwapper``` event fires whenever a swapper is black or whitelisted
    /// @param swapper The swapper address
    /// @param approval The approval
    event SetSwapper(address swapper, bool approval);

    /// @notice The ```setSwapper``` function is called to black or whitelist a given swapper address
    /// @dev
    /// @param _swapper The swapper address
    /// @param _approval The approval
    function setSwapper(address _swapper, bool _approval) external{
        if(msg.sender == owner() || msg.sender == registry){
            swappers[_swapper] = _approval;
            emit SetSwapper(_swapper, _approval);
        }else{
            revert OnlyProtocolOrOwner();
        }
    }

    /// @notice The ```SetConvexPool``` event fires when convex pool id is updated
    /// @param pid the convex pool id
    event SetConvexPool(uint256 pid);

    /// @notice The ```setConvexPool``` function is called update the underlying convex pool
    /// @dev
    /// @param pid the convex pool id
    function setConvexPool(uint256 pid) external onlyOwner{
        _updateConvexPool(pid);
        emit SetConvexPool(pid);
    }

    function _updateConvexPool(uint256 _pid) internal{
        uint256 currentPid = convexPid;
        if(currentPid != _pid){
            //get previous staking
            (,,,address _rewards,,) = IConvexStaking(convexBooster).poolInfo(currentPid);
            //get balance
            uint256 stakedBalance = IConvexStaking(_rewards).balanceOf(address(this));
            
            if(stakedBalance > 0){
                //withdraw
                IConvexStaking(_rewards).withdrawAndUnwrap(stakedBalance,false);
                if(collateral.balanceOf(address(this)) < stakedBalance){
                    revert IncorrectStakeBalance();
                }
            }

            //stake in new pool
            IConvexStaking(convexBooster).deposit(_pid, stakedBalance, true);

            //update pid
            convexPid = _pid;
        }
    }

    function _stakeUnderlying(uint256 _amount) internal override{
        uint256 currentPid = convexPid;
        if(currentPid != 0){
            IConvexStaking(convexBooster).deposit(currentPid, _amount, true);
        }
    }

    function _unstakeUnderlying(uint256 _amount) internal override{
        uint256 currentPid = convexPid;
        if(currentPid != 0){
            (,,,address _rewards,,) = IConvexStaking(convexBooster).poolInfo(currentPid);
            IConvexStaking(_rewards).withdrawAndUnwrap(_amount, false);
        }
    }

    function totalCollateral() public view override returns(uint256 _totalCollateralBalance){
        uint256 currentPid = convexPid;
        if(currentPid != 0){
            //get staking
            (,,,address _rewards,,) = IConvexStaking(convexBooster).poolInfo(currentPid);
            //get balance
            _totalCollateralBalance = IConvexStaking(_rewards).balanceOf(address(this));
        }else{
            _totalCollateralBalance = collateral.balanceOf(address(this));   
        }
    }

    // ============================================================================================
    // Functions: Access Control
    // ============================================================================================

    uint256 previousBorrowLimit;
    /// @notice The ```pause``` function is called to pause all contract functionality
    function pause() external onlyOwner{
        if (borrowLimit > 0) {
            previousBorrowLimit = borrowLimit;
            _setBorrowLimit(0);
        }
    }

    /// @notice The ```unpause``` function is called to unpause all contract functionality
    function unpause() external onlyOwner{
        if (borrowLimit == 0) _setBorrowLimit(previousBorrowLimit);
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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/*
A token-like contract to track write offs via erc20 interfaces to be used
in reward distribution logic

interfaces needed:
- balanceOf
- transfer
- mint

*/
contract WriteOffToken {

    address public immutable owner;
    uint256 public totalSupply;

    constructor(address _owner)
    {
        owner = _owner;
    }

    function name() external pure returns (string memory){
        return "WriteOffToken";
    }

    function symbol() external pure returns (string memory){
        return "WOT";
    }

    function decimals() external pure returns (uint8){
        return 18;
    }

    function mint(uint256 _amount) external{
        if(msg.sender == owner){
            totalSupply += _amount;
        }
    }

    function transfer(address to, uint256 amount) external returns (bool){
        return true;
    }

    function balanceOf(address) external view returns (uint256){
        //just return total supply
        return totalSupply;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title ResupplyPairConstants
 * @notice Based on code from Drake Evans and Frax Finance's pair constants (https://github.com/FraxFinance/fraxlend), adapted for Resupply Finance
 */

abstract contract ResupplyPairConstants {

    // Precision settings
    uint256 public constant LTV_PRECISION = 1e5; // 5 decimals
    uint256 public constant LIQ_PRECISION = 1e5;
    uint256 public constant EXCHANGE_PRECISION = 1e18;
    uint256 public constant RATE_PRECISION = 1e18;
    uint256 public constant SHARE_REFACTOR_PRECISION = 1e12;
    uint256 public constant PAIR_DECIMALS = 1e18;
    error Insolvent(uint256 _borrow, uint256 _collateral, uint256 _exchangeRate);
    error BorrowerSolvent();
    error InsufficientDebtAvailable(uint256 _assets, uint256 _request);
    error SlippageTooHigh(uint256 _minOut, uint256 _actual);
    error BadSwapper();
    error InvalidPath(address _expected, address _actual);
    error InvalidReceiver();
    error InvalidLiquidator();
    error InvalidRedemptionHandler();
    error InvalidParameter();
    error InsufficientDebtToRedeem();
    error MinimumRedemption();
    error InsufficientBorrowAmount();
    error OnlyProtocolOrOwner();
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title ResupplyPairCore
 * @notice Based on code from Drake Evans and Frax Finance's lending pair core contract (https://github.com/FraxFinance/fraxlend), adapted for Resupply Finance
 */

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { ResupplyPairConstants } from "./ResupplyPairConstants.sol";
import { VaultAccount, VaultAccountingLibrary } from "../../libraries/VaultAccount.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IOracle } from "../../interfaces/IOracle.sol";
import { IRateCalculator } from "../../interfaces/IRateCalculator.sol";
import { ISwapper } from "../../interfaces/ISwapper.sol";
import { IResupplyRegistry } from "../../interfaces/IResupplyRegistry.sol";
import { ILiquidationHandler } from "../../interfaces/ILiquidationHandler.sol";
import { RewardDistributorMultiEpoch } from "../RewardDistributorMultiEpoch.sol";
import { WriteOffToken } from "../WriteOffToken.sol";
import { IERC4626 } from "../../interfaces/IERC4626.sol";
import { CoreOwnable } from "../../dependencies/CoreOwnable.sol";
import { IMintable } from "../../interfaces/IMintable.sol";


abstract contract ResupplyPairCore is CoreOwnable, ResupplyPairConstants, RewardDistributorMultiEpoch {
    using VaultAccountingLibrary for VaultAccount;
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    //forked fraxlend at version 3,0,0
    function version() external pure returns (uint256 _major, uint256 _minor, uint256 _patch) {
        _major = 3;
        _minor = 0;
        _patch = 0;
    }

    // ============================================================================================
    // Settings set by constructor()
    // ============================================================================================

    // Asset and collateral contracts
    address public immutable registry;
    IERC20 internal immutable debtToken;
    IERC20 public immutable collateral;
    IERC20 public immutable underlying;

    // LTV Settings
    /// @notice The maximum LTV allowed for this pair
    /// @dev 1e5 precision
    uint256 public maxLTV;

    //max borrow
    uint256 public borrowLimit;

    //Fees
    /// @notice The liquidation fee, given as a % of repayment amount
    /// @dev 1e5 precision
    uint256 public mintFee;
    uint256 public liquidationFee;
    /// @dev 1e18 precision
    uint256 public protocolRedemptionFee;
    uint256 public minimumRedemption = 100 * PAIR_DECIMALS; //minimum amount of debt to redeem
    uint256 public minimumLeftoverDebt = 10000 * PAIR_DECIMALS; //minimum amount of assets left over via redemptions
    uint256 public minimumBorrowAmount = 1000 * PAIR_DECIMALS; //minimum amount of assets to borrow
    

    // Interest Rate Calculator Contract
    IRateCalculator public rateCalculator; // For complex rate calculations

    // Swapper
    mapping(address => bool) public swappers; // approved swapper addresses

    // Metadata
    string public name;
    
    // ============================================================================================
    // Storage
    // ============================================================================================

    /// @notice Stores information about the current interest rate
    CurrentRateInfo public currentRateInfo;

    struct CurrentRateInfo {
        uint64 lastTimestamp;
        uint64 ratePerSec;
        uint128 lastShares;
    }

    /// @notice Stores information about the current exchange rate. Collateral:Asset ratio
    /// @dev Struct packed to save SLOADs. Amount of Collateral Token to buy 1e18 Asset Token
    ExchangeRateInfo public exchangeRateInfo;

    struct ExchangeRateInfo {
        address oracle;
        uint96 lastTimestamp;
        uint256 exchangeRate;
    }

    // Contract Level Accounting
    VaultAccount public totalBorrow; // amount = total borrow amount with interest accrued, shares = total shares outstanding
    uint256 public claimableFees; //amount of interest gained that is claimable as fees
    uint256 public claimableOtherFees; //amount of redemption/mint fees claimable by protocol
    WriteOffToken immutable public redemptionWriteOff; //token to keep track of redemption write offs

    // User Level Accounting
    /// @notice Stores the balance of collateral for each user
    mapping(address => uint256) internal _userCollateralBalance; // amount of collateral each user is backed
    /// @notice Stores the balance of borrow shares for each user
    mapping(address => uint256) internal _userBorrowShares; // represents the shares held by individuals

    

    // ============================================================================================
    // Constructor
    // ============================================================================================

    /// @notice The ```constructor``` function is called on deployment
    /// @param _core Core contract address
    /// @param _configData abi.encode(address _collateral, address _oracle, address _rateCalculator, uint256 _maxLTV, uint256 _borrowLimit, uint256 _liquidationFee, uint256 _mintFee, uint256 _protocolRedemptionFee)
    /// @param _immutables abi.encode(address _registry)
    /// @param _customConfigData abi.encode(address _name, address _govToken, address _underlyingStaking, uint256 _stakingId)
    constructor(
        address _core,
        bytes memory _configData,
        bytes memory _immutables,
        bytes memory _customConfigData
    ) CoreOwnable(_core){
        (address _registry) = abi.decode(
            _immutables,
            (address)
        );
        registry = _registry;
        debtToken = IERC20(IResupplyRegistry(registry).token());
        {
            (
                address _collateral,
                address _oracle,
                address _rateCalculator,
                uint256 _maxLTV,
                uint256 _initialBorrowLimit,
                uint256 _liquidationFee,
                uint256 _mintFee,
                uint256 _protocolRedemptionFee
            ) = abi.decode(
                    _configData,
                    (address, address, address, uint256, uint256, uint256, uint256, uint256)
                );

            // Pair Settings
            collateral = IERC20(_collateral);
            if(IERC20Metadata(_collateral).decimals() != 18){
                revert InvalidParameter();
            }
            underlying = IERC20(IERC4626(_collateral).asset());
            if(IERC20Metadata(address(underlying)).decimals() != 18){
                revert InvalidParameter();
            }
            // approve so this contract can deposit
            underlying.forceApprove(_collateral, type(uint256).max);
            currentRateInfo.lastShares = uint128(IERC4626(_collateral).convertToShares(PAIR_DECIMALS));
            exchangeRateInfo.oracle = _oracle;
            rateCalculator = IRateCalculator(_rateCalculator);
            borrowLimit = _initialBorrowLimit;

            //Liquidation Fee Settings
            liquidationFee = _liquidationFee;
            mintFee = _mintFee;
            protocolRedemptionFee = _protocolRedemptionFee;

            // set maxLTV
            maxLTV = _maxLTV;
        }

        //starting reward types
        redemptionWriteOff = new WriteOffToken(address(this));
        _insertRewardToken(address(redemptionWriteOff));//add redemption token as a reward
        //set the redemption token as non claimable via getReward
        rewards[0].is_non_claimable = true;

        {
            (string memory _name,,,) = abi.decode(
                _customConfigData,
                (string, address, address, uint256)
            );

            // Metadata
            name = _name;

            // Instantiate Interest
            _addInterest();
            // Instantiate Exchange Rate
            _updateExchangeRate();
        }
    }

    // ============================================================================================
    // Helpers
    // ============================================================================================


    //get total collateral, either parked here or staked 
    function totalCollateral() public view virtual returns(uint256 _totalCollateralBalance);

    function userBorrowShares(address _account) public view returns(uint256 borrowShares){
        borrowShares = _userBorrowShares[_account];

        uint256 globalEpoch = currentRewardEpoch;
        uint256 userEpoch = userRewardEpoch[_account];

        if(userEpoch < globalEpoch){
            //need to calculate shares while keeping this as a view function
            for(;;){
                //reduce shares by refactoring amount
                borrowShares /= SHARE_REFACTOR_PRECISION;
                unchecked {
                    userEpoch += 1;
                }
                if(userEpoch == globalEpoch){
                    break;
                }
            }
        }
    }

    //get _userCollateralBalance minus redemption tokens
    function userCollateralBalance(address _account) public nonReentrant returns(uint256 _collateralAmount){
        _syncUserRedemptions(_account);

        _collateralAmount = _userCollateralBalance[_account];

        //since there are some very small dust during distribution there could be a few wei
        //in user collateral that is over total collateral. clamp to total
        uint256 total = totalCollateral();
        _collateralAmount = _collateralAmount > total ? total : _collateralAmount;
    }

    /// @notice The ```totalDebtAvailable``` function returns the total balance of debt tokens in the contract
    /// @return The balance of debt tokens held by contract
    function totalDebtAvailable() external view returns (uint256) {
        (,,, VaultAccount memory _totalBorrow) = previewAddInterest();
        
        return _totalDebtAvailable(_totalBorrow);
    }

    /// @notice The ```_totalDebtAvailable``` function returns the total amount of debt that can be issued on this pair
    /// @param _totalBorrow Total borrowed amount, inclusive of interest
    /// @return The amount of debt that can be issued
    function _totalDebtAvailable(VaultAccount memory _totalBorrow) internal view returns (uint256) {
        uint256 _borrowLimit = borrowLimit;
        uint256 borrowable = _borrowLimit > _totalBorrow.amount ? _borrowLimit - _totalBorrow.amount : 0;

        return borrowable > type(uint128).max ? type(uint128).max : borrowable; 
    }

    function currentUtilization() external view returns (uint256) {
        uint256 _borrowLimit = borrowLimit;
        if(_borrowLimit == 0){
            return PAIR_DECIMALS;
        }
        (,,, VaultAccount memory _totalBorrow) = previewAddInterest();
        return _totalBorrow.amount * PAIR_DECIMALS / _borrowLimit;
    }

    /// @notice The ```_isSolvent``` function determines if a given borrower is solvent given an exchange rate
    /// @param _borrower The borrower address to check
    /// @param _exchangeRate The exchange rate, i.e. the amount of collateral to buy 1e18 asset
    /// @return Whether borrower is solvent
    function _isSolvent(address _borrower, uint256 _exchangeRate) internal view returns (bool) {
        uint256 _maxLTV = maxLTV;
        if (_maxLTV == 0) return true;
        //must look at borrow shares of current epoch so user helper function
        //user borrow shares should be synced before _isSolvent is called
        uint256 _borrowerAmount = totalBorrow.toAmount(_userBorrowShares[_borrower], true);
        if (_borrowerAmount == 0) return true;
        
        //anything that calls _isSolvent will call _syncUserRedemptions beforehand
        uint256 _collateralAmount = _userCollateralBalance[_borrower];
        if (_collateralAmount == 0) return false;

        uint256 _ltv = ((_borrowerAmount * _exchangeRate * LTV_PRECISION) / EXCHANGE_PRECISION) / _collateralAmount;
        return _ltv <= _maxLTV;
    }

    function _isSolventSync(address _borrower, uint256 _exchangeRate) internal returns (bool){
         //checkpoint rewards and sync _userCollateralBalance
        _syncUserRedemptions(_borrower);
        return _isSolvent(_borrower, _exchangeRate);
    }

    // ============================================================================================
    // Modifiers
    // ============================================================================================

    /// @notice Checks for solvency AFTER executing contract code
    /// @param _borrower The borrower whose solvency we will check
    modifier isSolvent(address _borrower) {
        //checkpoint rewards and sync _userCollateralBalance before doing other actions
        _syncUserRedemptions(_borrower);
        _;
        ExchangeRateInfo memory _exchangeRateInfo = exchangeRateInfo;

        if (!_isSolvent(_borrower, _exchangeRateInfo.exchangeRate)) {
            revert Insolvent(
                totalBorrow.toAmount(_userBorrowShares[_borrower], true),
                _userCollateralBalance[_borrower], //_issolvent sync'd so take base _userCollateral
                _exchangeRateInfo.exchangeRate
            );
        }
    }

    // ============================================================================================
    // Reward Implementation
    // ============================================================================================

    function _isRewardManager() internal view override returns(bool){
        return msg.sender == address(core) || msg.sender == IResupplyRegistry(registry).rewardHandler();
    }

    function _fetchIncentives() internal override{
        IResupplyRegistry(registry).claimRewards(address(this));
    }

    function _totalRewardShares() internal view override returns(uint256){
        return totalBorrow.shares;
    }

    function _userRewardShares(address _account) internal view override returns(uint256){
        return _userBorrowShares[_account];
    }

    function _increaseUserRewardEpoch(address _account, uint256 _currentUserEpoch) internal override{
        //convert shares to next epoch shares
        //share refactoring will never be 0
        _userBorrowShares[_account] = _userBorrowShares[_account] / SHARE_REFACTOR_PRECISION;
        //update user reward epoch
        userRewardEpoch[_account] = _currentUserEpoch + 1;
    }

    function earned(address _account) public override returns(EarnedData[] memory claimable){
        EarnedData[] memory earneddata = super.earned(_account);
        uint256 rewardCount = earneddata.length - 1;
        claimable = new EarnedData[](rewardCount);

        //remove index 0 as we dont need to report the write off tokens
        for (uint256 i = 1; i <= rewardCount; ) {
            claimable[i-1].amount = earneddata[i].amount;
            claimable[i-1].token = earneddata[i].token;
            unchecked{ i += 1; }
        }
    }

    function _checkAddToken(address _address) internal view virtual override returns(bool){
        if(_address == address(collateral)) return false;
        if(_address == address(debtToken)) return false;
        return true;
    }

    // ============================================================================================
    // Underlying Staking
    // ============================================================================================

    function _stakeUnderlying(uint256 _amount) internal virtual;

    function _unstakeUnderlying(uint256 _amount) internal virtual;

    // ============================================================================================
    // Functions: Interest Accumulation and Adjustment
    // ============================================================================================

    /// @notice The ```AddInterest``` event is emitted when interest is accrued by borrowers
    /// @param interestEarned The total interest accrued by all borrowers
    /// @param rate The interest rate used to calculate accrued interest
    event AddInterest(uint256 interestEarned, uint256 rate);

    /// @notice The ```UpdateRate``` event is emitted when the interest rate is updated
    /// @param oldRatePerSec The old interest rate (per second)
    /// @param oldShares previous used shares
    /// @param newRatePerSec The new interest rate (per second)
    /// @param newShares new shares
    event UpdateRate(
        uint256 oldRatePerSec,
        uint128 oldShares,
        uint256 newRatePerSec,
        uint128 newShares
    );

    /// @notice The ```addInterest``` function is a public implementation of _addInterest and allows 3rd parties to trigger interest accrual
    /// @param _returnAccounting Whether to return additional accounting data
    /// @return _interestEarned The amount of interest accrued by all borrowers
    /// @return _currentRateInfo The new rate info struct
    /// @return _claimableFees The new total of fees that are claimable
    /// @return _totalBorrow The new total borrow struct
    function addInterest(
        bool _returnAccounting
    )
        external
        nonReentrant
        returns (
            uint256 _interestEarned,
            CurrentRateInfo memory _currentRateInfo,
            uint256 _claimableFees,
            VaultAccount memory _totalBorrow
        )
    {
        (, _interestEarned, _currentRateInfo) = _addInterest();
        if (_returnAccounting) {
            _claimableFees = claimableFees;
            _totalBorrow = totalBorrow;
        }
    }

    /// @notice The ```previewAddInterest``` function
    /// @return _interestEarned The amount of interest accrued by all borrowers
    /// @return _newCurrentRateInfo The new rate info struct
    /// @return _claimableFees The new total of fees that are claimable
    /// @return _totalBorrow The new total borrow struct
    function previewAddInterest()
        public
        view
        returns (
            uint256 _interestEarned,
            CurrentRateInfo memory _newCurrentRateInfo,
            uint256 _claimableFees,
            VaultAccount memory _totalBorrow
        )
    {
        _newCurrentRateInfo = currentRateInfo;
        _newCurrentRateInfo.lastTimestamp = uint64(block.timestamp);

        // Write return values
        InterestCalculationResults memory _results = _calculateInterest(_newCurrentRateInfo);

        if (_results.isInterestUpdated) {
            _interestEarned = _results.interestEarned;

            _newCurrentRateInfo.ratePerSec = _results.newRate;
            _newCurrentRateInfo.lastShares = _results.newShares;

            _claimableFees = claimableFees + uint128(_interestEarned);
            _totalBorrow = _results.totalBorrow;
        } else {
            _claimableFees = claimableFees;
            _totalBorrow = totalBorrow;
        }
    }

    struct InterestCalculationResults {
        bool isInterestUpdated;
        uint64 newRate;
        uint128 newShares;
        uint256 interestEarned;
        VaultAccount totalBorrow;
    }

    /// @notice The ```_calculateInterest``` function calculates the interest to be accrued and the new interest rate info
    /// @param _currentRateInfo The current rate info
    /// @return _results The results of the interest calculation
    function _calculateInterest(
        CurrentRateInfo memory _currentRateInfo
    ) internal view returns (InterestCalculationResults memory _results) {
        // Short circuit if interest already calculated this block
        if (_currentRateInfo.lastTimestamp < block.timestamp) {
            // Indicate that interest is updated and calculated
            _results.isInterestUpdated = true;

            // Write return values and use these to save gas
            _results.totalBorrow = totalBorrow;

            // Time elapsed since last interest update
            uint256 _deltaTime = block.timestamp - _currentRateInfo.lastTimestamp;

            // Request new interest rate and full utilization rate from the rate calculator
            (_results.newRate, _results.newShares) = IRateCalculator(rateCalculator).getNewRate(
                address(collateral),
                _deltaTime,
                _currentRateInfo.lastShares
            );

            // Calculate interest accrued
            _results.interestEarned = (_deltaTime * _results.totalBorrow.amount * _results.newRate) / RATE_PRECISION;

            // Accrue interest (if any) and fees if no overflow
            if (
                _results.interestEarned > 0 &&
                _results.interestEarned + _results.totalBorrow.amount <= type(uint128).max
            ) {
                // Increment totalBorrow by interestEarned
                _results.totalBorrow.amount += uint128(_results.interestEarned);
            }else{
                //reset interest earned
                _results.interestEarned = 0;
            }
        }
    }

    /// @notice The ```_addInterest``` function is invoked prior to every external function and is used to accrue interest and update interest rate
    /// @dev Can only called once per block
    /// @return _isInterestUpdated True if interest was calculated
    /// @return _interestEarned The amount of interest accrued by all borrowers
    /// @return _currentRateInfo The new rate info struct
    function _addInterest()
        internal
        returns (
            bool _isInterestUpdated,
            uint256 _interestEarned,
            CurrentRateInfo memory _currentRateInfo
        )
    {
        // Pull from storage and set default return values
        _currentRateInfo = currentRateInfo;

        // Calc interest
        InterestCalculationResults memory _results = _calculateInterest(_currentRateInfo);

        // Write return values only if interest was updated and calculated
        if (_results.isInterestUpdated) {
            _isInterestUpdated = _results.isInterestUpdated;
            _interestEarned = _results.interestEarned;

            // emit here so that we have access to the old values
            emit UpdateRate(
                _currentRateInfo.ratePerSec,
                _currentRateInfo.lastShares,
                _results.newRate,
                _results.newShares
            );
            emit AddInterest(_interestEarned, _results.newRate);

            // overwrite original values
            _currentRateInfo.ratePerSec = _results.newRate;
            _currentRateInfo.lastShares = _results.newShares;
            _currentRateInfo.lastTimestamp = uint64(block.timestamp);

            // Effects: write to state
            currentRateInfo = _currentRateInfo;
            claimableFees += _interestEarned; //increase claimable fees by interest earned
            totalBorrow = _results.totalBorrow;
        }
    }

    // ============================================================================================
    // Functions: ExchangeRate
    // ============================================================================================

    /// @notice The ```UpdateExchangeRate``` event is emitted when the Collateral:Asset exchange rate is updated
    /// @param exchangeRate The exchange rate
    event UpdateExchangeRate(uint256 exchangeRate);

    /// @notice The ```updateExchangeRate``` function is the external implementation of _updateExchangeRate.
    /// @dev This function is invoked at most once per block as these queries can be expensive
    /// @return _exchangeRate The exchange rate
    function updateExchangeRate()
        external
        nonReentrant
        returns (uint256 _exchangeRate)
    {
        return _updateExchangeRate();
    }

    /// @notice The ```_updateExchangeRate``` function retrieves the latest exchange rate. i.e how much collateral to buy 1e18 asset.
    /// @dev This function is invoked at most once per block as these queries can be expensive
    /// @return _exchangeRate The exchange rate
    function _updateExchangeRate()
        internal
        returns (uint256 _exchangeRate)
    {
        // Pull from storage to save gas and set default return values
        ExchangeRateInfo memory _exchangeRateInfo = exchangeRateInfo;

        // Short circuit if already updated this block
        if (_exchangeRateInfo.lastTimestamp != block.timestamp) {
            // Get the latest exchange rate from the oracle
            _exchangeRate = IOracle(_exchangeRateInfo.oracle).getPrices(address(collateral));
            //convert price of collateral as debt is priced in terms of collateral amount (inverse)
            _exchangeRate = 1e36 / _exchangeRate;


            // Effects: Bookkeeping and write to storage
            _exchangeRateInfo.lastTimestamp = uint96(block.timestamp);
            _exchangeRateInfo.exchangeRate = _exchangeRate;
            exchangeRateInfo = _exchangeRateInfo;
            emit UpdateExchangeRate(_exchangeRate);
        } else {
            // Use default return values if already updated this block
            _exchangeRate = _exchangeRateInfo.exchangeRate;
        }

    }

    // ============================================================================================
    // Functions: Lending
    // ============================================================================================

    // ONLY Protocol can lend

    // ============================================================================================
    // Functions: Borrowing
    // ============================================================================================

    //sync user collateral by removing account of userCollateralBalance based on
    //how many "claimable" redemption tokens are available to the user
    //should be called before anything with userCollateralBalance is used
    function _syncUserRedemptions(address _account) internal{
        //sync rewards first
        _checkpoint(_account);

        //get token count (divide by LTV_PRECISION as precision is padded)
        uint256 rTokens = claimable_reward[address(redemptionWriteOff)][_account] / LTV_PRECISION;
        //reset claimables
        claimable_reward[address(redemptionWriteOff)][_account] = 0;

        //remove from collateral balance the number of rtokens the user has
        uint256 currentUserBalance = _userCollateralBalance[_account];
        _userCollateralBalance[_account] = currentUserBalance >= rTokens ? currentUserBalance - rTokens : 0;
    }

    /// @notice The ```Borrow``` event is emitted when a borrower increases their position
    /// @param _borrower The borrower whose account was debited
    /// @param _receiver The address to which the Asset Tokens were transferred
    /// @param _borrowAmount The amount of Asset Tokens transferred
    /// @param _sharesAdded The number of Borrow Shares the borrower was debited
    /// @param _mintFees The amount of mint fees incurred
    event Borrow(
        address indexed _borrower,
        address indexed _receiver,
        uint256 _borrowAmount,
        uint256 _sharesAdded,
        uint256 _mintFees
    );

    /// @notice The ```_borrow``` function is the internal implementation for borrowing assets
    /// @param _borrowAmount The amount of the Asset Token to borrow
    /// @param _receiver The address to receive the Asset Tokens
    /// @return _sharesAdded The amount of borrow shares the msg.sender will be debited
    function _borrow(uint128 _borrowAmount, address _receiver) internal returns (uint256 _sharesAdded) {
        // Get borrow accounting from storage to save gas
        VaultAccount memory _totalBorrow = totalBorrow;

        if(_borrowAmount < minimumBorrowAmount){
            revert InsufficientBorrowAmount();
        }

        //mint fees
        uint256 debtForMint = (_borrowAmount * (LIQ_PRECISION + mintFee) / LIQ_PRECISION);

        // Check available capital
        uint256 _assetsAvailable = _totalDebtAvailable(_totalBorrow);
        if (_assetsAvailable < debtForMint) {
            revert InsufficientDebtAvailable(_assetsAvailable, debtForMint);
        }
        
        // Calculate the number of shares to add based on the amount to borrow
        _sharesAdded = _totalBorrow.toShares(debtForMint, true);

        //combine current shares and new shares
        uint256 newTotalShares = _totalBorrow.shares + _sharesAdded;

        // Effects: Bookkeeping to add shares & amounts to total Borrow accounting
        _totalBorrow.amount += debtForMint.toUint128();
        _totalBorrow.shares = newTotalShares.toUint128();

        // Effects: write back to storage
        totalBorrow = _totalBorrow;
        _userBorrowShares[msg.sender] += _sharesAdded;

        uint256 otherFees = debtForMint > _borrowAmount ? debtForMint - _borrowAmount : 0;
        if (otherFees > 0) claimableOtherFees += otherFees;

        // Interactions
        IResupplyRegistry(registry).mint(_receiver, _borrowAmount);
        
        emit Borrow(msg.sender, _receiver, _borrowAmount, _sharesAdded, otherFees);
    }

    /// @notice The ```borrow``` function allows a user to open/increase a borrow position
    /// @dev Borrower must call ```ERC20.approve``` on the Collateral Token contract if applicable
    /// @param _borrowAmount The amount to borrow
    /// @param _underlyingAmount The amount of underlying tokens to transfer to Pair
    /// @param _receiver The address which will receive the Asset Tokens
    /// @return _shares The number of borrow Shares the msg.sender will be debited
    function borrow(
        uint256 _borrowAmount,
        uint256 _underlyingAmount,
        address _receiver
    ) external nonReentrant isSolvent(msg.sender) returns (uint256 _shares) {
        if (_receiver == address(0)) revert InvalidReceiver();

        // Accrue interest if necessary
        _addInterest();

        // Update _exchangeRate
        _updateExchangeRate();

        // Only add collateral if necessary
        if (_underlyingAmount > 0) {
            //pull underlying and deposit in vault
            underlying.safeTransferFrom(msg.sender, address(this), _underlyingAmount);
            uint256 collateralShares = IERC4626(address(collateral)).deposit(_underlyingAmount, address(this));
            //add collateral to msg.sender
            _addCollateral(address(this), collateralShares, msg.sender);
        }

        // Effects: Call internal borrow function
        _shares = _borrow(_borrowAmount.toUint128(), _receiver);
    }

    /// @notice The ```AddCollateral``` event is emitted when a borrower adds collateral to their position
    /// @param borrower The borrower account for which the collateral should be credited
    /// @param collateralAmount The amount of Collateral Token to be transferred
    event AddCollateral(address indexed borrower, uint256 collateralAmount);

    /// @notice The ```_addCollateral``` function is an internal implementation for adding collateral to a borrowers position
    /// @param _sender The source of funds for the new collateral
    /// @param _collateralAmount The amount of Collateral Token to be transferred
    /// @param _borrower The borrower account for which the collateral should be credited
    function _addCollateral(address _sender, uint256 _collateralAmount, address _borrower) internal {
        _userCollateralBalance[_borrower] += _collateralAmount;
        if (_sender != address(this)) {
            collateral.safeTransferFrom(_sender, address(this), _collateralAmount);
        }
        //stake underlying
        _stakeUnderlying(_collateralAmount);

        emit AddCollateral(_borrower, _collateralAmount);
    }

    /// @notice The ```addCollateral``` function allows the caller to add Collateral Token to a borrowers position
    /// @dev msg.sender must call ERC20.approve() on the Collateral Token contract prior to invocation
    /// @param _collateralAmount The amount of Collateral Token to be added to borrower's position
    /// @param _borrower The account to be credited
    function addCollateralVault(uint256 _collateralAmount, address _borrower) external nonReentrant {
        if (_borrower == address(0)) revert InvalidReceiver();

        _addInterest();
        _addCollateral(msg.sender, _collateralAmount, _borrower);
    }

    /// @notice Allows depositing in terms of underlying asset, and have it converted to collateral shares to the borrower's position.
    /// @param _amount The amount of the underlying asset to deposit.
    /// @param _borrower The address of the borrower whose collateral balance will be credited.
    function addCollateral(uint256 _amount, address _borrower) external nonReentrant {
        if (_borrower == address(0)) revert InvalidReceiver();

        _addInterest();

        underlying.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 collateralShares = IERC4626(address(collateral)).deposit(_amount, address(this));
        _addCollateral(address(this), collateralShares, _borrower);
    }

    /// @notice The ```RemoveCollateral``` event is emitted when collateral is removed from a borrower's position
    /// @param _collateralAmount The amount of Collateral Token to be transferred
    /// @param _receiver The address to which Collateral Tokens will be transferred
    /// @param _borrower The address of the account in which collateral is being removed
    event RemoveCollateral(
        uint256 _collateralAmount,
        address indexed _receiver,
        address indexed _borrower
    );

    /// @notice The ```_removeCollateral``` function is the internal implementation for removing collateral from a borrower's position
    /// @param _collateralAmount The amount of Collateral Token to remove from the borrower's position
    /// @param _receiver The address to receive the Collateral Token transferred
    /// @param _borrower The borrower whose account will be debited the Collateral amount
    function _removeCollateral(uint256 _collateralAmount, address _receiver, address _borrower) internal {

        // Effects: write to state
        // NOTE: Following line will revert on underflow if _collateralAmount > userCollateralBalance
        _userCollateralBalance[_borrower] -= _collateralAmount;

        //unstake underlying
        //NOTE: following will revert on underflow if total collateral < _collateralAmount
        _unstakeUnderlying(_collateralAmount);

        // Interactions
        if (_receiver != address(this)) {
            collateral.safeTransfer(_receiver, _collateralAmount);
        }
        emit RemoveCollateral(_collateralAmount, _receiver, _borrower);
    }

    /// @notice The ```removeCollateralVault``` function is used to remove collateral from msg.sender's borrow position
    /// @dev msg.sender must be solvent after invocation or transaction will revert
    /// @param _collateralAmount The amount of Collateral Token to transfer
    /// @param _receiver The address to receive the transferred funds
    function removeCollateralVault(
        uint256 _collateralAmount,
        address _receiver
    ) external nonReentrant isSolvent(msg.sender) {
        //note: isSolvent checkpoints msg.sender via _syncUserRedemptions

        if (_receiver == address(0)) revert InvalidReceiver();

        _addInterest();
        // Note: exchange rate is irrelevant when borrower has no debt shares
        if (_userBorrowShares[msg.sender] > 0) {
            _updateExchangeRate();
        }
        _removeCollateral(_collateralAmount, _receiver, msg.sender);
    }

    /// @notice The ```removeCollateral``` function is used to remove collateral from msg.sender's borrow position and redeem it for underlying tokens
    /// @dev msg.sender must be solvent after invocation or transaction will revert
    /// @param _collateralAmount The amount of Collateral Token to redeem
    /// @param _receiver The address to receive the redeemed underlying tokens
    function removeCollateral(
        uint256 _collateralAmount,
        address _receiver
    ) external nonReentrant isSolvent(msg.sender) {
        //note: isSolvent checkpoints msg.sender via _syncUserRedemptions

        if (_receiver == address(0)) revert InvalidReceiver();

        _addInterest();
        // Note: exchange rate is irrelevant when borrower has no debt shares
        if (_userBorrowShares[msg.sender] > 0) {
            _updateExchangeRate();
        }
        _removeCollateral(_collateralAmount, address(this), msg.sender);
        IERC4626(address(collateral)).redeem(_collateralAmount, _receiver, address(this));
    }

    /// @notice The ```Repay``` event is emitted whenever a debt position is repaid
    /// @param payer The address paying for the repayment
    /// @param borrower The borrower whose account will be credited
    /// @param amountToRepay The amount of Asset token to be transferred
    /// @param shares The amount of Borrow Shares which will be debited from the borrower after repayment
    event Repay(address indexed payer, address indexed borrower, uint256 amountToRepay, uint256 shares);

    /// @notice The ```_repay``` function is the internal implementation for repaying a borrow position
    /// @dev The payer must have called ERC20.approve() on the Asset Token contract prior to invocation
    /// @param _totalBorrow An in memory copy of the totalBorrow VaultAccount struct
    /// @param _amountToRepay The amount of Asset Token to transfer
    /// @param _shares The number of Borrow Shares the sender is repaying
    /// @param _payer The address from which funds will be transferred
    /// @param _borrower The borrower account which will be credited
    function _repay(
        VaultAccount memory _totalBorrow,
        uint128 _amountToRepay,
        uint128 _shares,
        address _payer,
        address _borrower
    ) internal {
        //checkpoint rewards for borrower before adjusting borrow shares
        _checkpoint(_borrower);

        // Effects: Bookkeeping
        _totalBorrow.amount -= _amountToRepay;
        _totalBorrow.shares -= _shares;

        // Effects: write user state
        uint256 usershares = _userBorrowShares[_borrower] - _shares;
        _userBorrowShares[_borrower] = usershares;
    
        //check that any remaining user amount is greater than minimumBorrowAmount
        if(usershares > 0 && _totalBorrow.toAmount(usershares, true) < minimumBorrowAmount){
            revert InsufficientBorrowAmount();
        }

        // Effects: write global state
        totalBorrow = _totalBorrow;

        // Interactions
        // burn from non-zero address.  zero address is only supplied during liquidations
        // for liqudations the handler will do the burning
        if (_payer != address(0)) {
            IMintable(address(debtToken)).burn(_payer, _amountToRepay);
        }
        emit Repay(_payer, _borrower, _amountToRepay, _shares);
    }

    /// @notice The ```repay``` function allows the caller to pay down the debt for a given borrower.
    /// @dev Caller must first invoke ```ERC20.approve()``` for the Asset Token contract
    /// @param _shares The number of Borrow Shares which will be repaid by the call
    /// @param _borrower The account for which the debt will be reduced
    /// @return _amountToRepay The amount of Asset Tokens which were burned to repay the Borrow Shares
    function repay(uint256 _shares, address _borrower) external nonReentrant returns (uint256 _amountToRepay) {
        if (_borrower == address(0)) revert InvalidReceiver();

        // Accrue interest if necessary
        _addInterest();

        // Calculate amount to repay based on shares
        VaultAccount memory _totalBorrow = totalBorrow;
        _amountToRepay = _totalBorrow.toAmount(_shares, true);

        // Execute repayment effects
        _repay(_totalBorrow, _amountToRepay.toUint128(), _shares.toUint128(), msg.sender, _borrower);
    }

    // ============================================================================================
    // Functions: Redemptions
    // ============================================================================================
    event Redeemed(
        address indexed _caller,
        uint256 _amount,
        uint256 _collateralFreed,
        uint256 _protocolFee,
        uint256 _debtReduction
    );

    /// @notice Allows redemption of the debt tokens for collateral
    /// @dev Only callable by the registry's redeemer contract
    /// @param _caller The address of the caller
    /// @param _amount The amount of debt tokens to redeem
    /// @param _totalFeePct Total fee to charge, expressed as a percentage of the stablecoin input; to be subdivided between protocol and borrowers.
    /// @param _receiver The address to receive the collateral tokens
    /// @return _collateralToken The address of the collateral token
    /// @return _collateralFreed The amount of collateral tokens returned to receiver
    function redeemCollateral(
        address _caller,
        uint256 _amount,
        uint256 _totalFeePct,
        address _receiver
    ) external nonReentrant returns(address _collateralToken, uint256 _collateralFreed){
        //check sender. must go through the registry's redemptionHandler
        if(msg.sender != IResupplyRegistry(registry).redemptionHandler()) revert InvalidRedemptionHandler();

        if (_receiver == address(0) || _receiver == address(this)) revert InvalidReceiver();

        if(_amount < minimumRedemption){
          revert MinimumRedemption();
        }

        // accrue interest if necessary
        _addInterest();

        //redemption fees
        //assuming 1% redemption fee(0.5% to protocol, 0.5% to borrowers) and a redemption of $100
        // reduce totalBorrow.amount by 99.5$
        // add 0.5$ to protocol earned fees
        // return 99$ of collateral
        // burn $100 of stables
        uint256 valueToRedeem = _amount * (EXCHANGE_PRECISION - _totalFeePct) / EXCHANGE_PRECISION;
        uint256 protocolFee = (_amount - valueToRedeem) * protocolRedemptionFee / EXCHANGE_PRECISION;
        uint256 debtReduction = _amount - protocolFee; // protocol fee portion is not burned

        //check if theres enough debt to write off
        VaultAccount memory _totalBorrow = totalBorrow;
        if(debtReduction > _totalBorrow.amount || _totalBorrow.amount - debtReduction < minimumLeftoverDebt ){
            revert InsufficientDebtToRedeem(); // size of request exceeeds total pair debt
        }

        _totalBorrow.amount -= uint128(debtReduction);

        //if after many redemptions the amount to shares ratio has deteriorated too far, then refactor
        //cast to uint256 to reduce chance of overflow
        if(uint256(_totalBorrow.amount) * SHARE_REFACTOR_PRECISION < _totalBorrow.shares){
            _increaseRewardEpoch(); //will do final checkpoint on previous total supply
            _totalBorrow.shares /= uint128(SHARE_REFACTOR_PRECISION);
        }

        // Effects: write to state
        totalBorrow = _totalBorrow;

        claimableOtherFees += protocolFee; //increase claimable fees

        // Update exchange rate
        uint256 _exchangeRate = _updateExchangeRate();
        //calc collateral units
        _collateralFreed = ((valueToRedeem * _exchangeRate) / EXCHANGE_PRECISION);
        
        _unstakeUnderlying(_collateralFreed);
        _collateralToken = address(collateral);
        IERC20(_collateralToken).safeTransfer(_receiver, _collateralFreed);

        //distribute write off tokens to adjust userCollateralbalances
        //padded with LTV_PRECISION for extra precision
        redemptionWriteOff.mint(_collateralFreed * LTV_PRECISION);

        emit Redeemed(_caller, _amount, _collateralFreed, protocolFee, debtReduction);
    }

    // ============================================================================================
    // Functions: Liquidations
    // ============================================================================================
    /// @notice The ```Liquidate``` event is emitted when a liquidation occurs
    /// @param _borrower The borrower account for which the liquidation occurred
    /// @param _collateralForLiquidator The amount of collateral token transferred to the liquidator
    /// @param _sharesLiquidated The number of borrow shares liquidated
    /// @param _amountLiquidatorToRepay The amount of asset tokens to be repaid by the liquidator
    event Liquidate(
        address indexed _borrower,
        uint256 _collateralForLiquidator,
        uint256 _sharesLiquidated,
        uint256 _amountLiquidatorToRepay
    );

    /// @notice The ```liquidate``` function allows a third party to repay a borrower's debt if they have become insolvent
    /// @dev Caller must invoke ```ERC20.approve``` on the Asset Token contract prior to calling ```Liquidate()```
    /// @param _borrower The account for which the repayment is credited and from whom collateral will be taken
    /// @return _collateralForLiquidator The amount of Collateral Token transferred to the liquidator
    function liquidate(
        address _borrower
    ) external nonReentrant returns (uint256 _collateralForLiquidator) {
        address liquidationHandler = IResupplyRegistry(registry).liquidationHandler();
        if(msg.sender != liquidationHandler) revert InvalidLiquidator();

        if (_borrower == address(0)) revert InvalidReceiver();

        // accrue interest if necessary
        _addInterest();

        // Update exchange rate and use the lower rate for liquidations
        uint256 _exchangeRate = _updateExchangeRate();

        // Check if borrower is solvent, revert if they are
        //_isSolventSync calls _syncUserRedemptions which checkpoints rewards and userCollateral
        if (_isSolventSync(_borrower, _exchangeRate)) {
            revert BorrowerSolvent();
        }

        // Read from state
        VaultAccount memory _totalBorrow = totalBorrow;
        uint256 _collateralBalance = _userCollateralBalance[_borrower];
        uint128 _borrowerShares = _userBorrowShares[_borrower].toUint128();

        // Checks & Calculations
        // Determine the liquidation amount in collateral units (i.e. how much debt liquidator is going to repay)
        uint256 _liquidationAmountInCollateralUnits = ((_totalBorrow.toAmount(_borrowerShares, false) *
            _exchangeRate) / EXCHANGE_PRECISION);

        // add fee for liquidation
        _collateralForLiquidator = (_liquidationAmountInCollateralUnits *
            (LIQ_PRECISION + liquidationFee)) / LIQ_PRECISION;

        // clamp to user collateral balance as we cant take more than that
        _collateralForLiquidator = _collateralForLiquidator > _collateralBalance ? _collateralBalance : _collateralForLiquidator;

        // Calculated here for use during repayment, grouped with other calcs before effects start
        uint128 _amountLiquidatorToRepay = (_totalBorrow.toAmount(_borrowerShares, true)).toUint128();

        emit Liquidate(
                _borrower,
                _collateralForLiquidator,
                _borrowerShares,
                _amountLiquidatorToRepay
            );

        // Effects & Interactions
        // repay using address(0) to skip burning (liquidationHandler will burn from insurance pool)
        _repay(
            _totalBorrow,
            _amountLiquidatorToRepay,
            _borrowerShares,
            address(0),
            _borrower
        );

        // Collateral is removed on behalf of borrower and sent to liquidationHandler
        // NOTE: isSolvent above checkpoints user with _syncUserRedemptions before removing collateral
        _removeCollateral(_collateralForLiquidator, liquidationHandler, _borrower);

        //call liquidation handler to distribute and burn debt
        ILiquidationHandler(liquidationHandler).processLiquidationDebt(address(collateral), _collateralForLiquidator, _amountLiquidatorToRepay);
    }

    // ============================================================================================
    // Functions: Leverage
    // ============================================================================================

    /// @notice The ```LeveragedPosition``` event is emitted when a borrower takes out a new leveraged position
    /// @param _borrower The account for which the debt is debited
    /// @param _swapperAddress The address of the swapper which conforms the FraxSwap interface
    /// @param _borrowAmount The amount of Asset Token to be borrowed to be borrowed
    /// @param _borrowShares The number of Borrow Shares the borrower is credited
    /// @param _initialUnderlyingAmount The amount of initial underlying Tokens supplied by the borrower
    /// @param _amountCollateralOut The amount of Collateral Token which was received for the Asset Tokens
    event LeveragedPosition(
        address indexed _borrower,
        address _swapperAddress,
        uint256 _borrowAmount,
        uint256 _borrowShares,
        uint256 _initialUnderlyingAmount,
        uint256 _amountCollateralOut
    );

    /// @notice The ```leveragedPosition``` function allows a user to enter a leveraged borrow position with minimal upfront Underlying tokens
    /// @dev Caller must invoke ```ERC20.approve()``` on the Underlying Token contract prior to calling function
    /// @param _swapperAddress The address of the whitelisted swapper to use to swap borrowed Asset Tokens for Collateral Tokens
    /// @param _borrowAmount The amount of Asset Tokens borrowed
    /// @param _initialUnderlyingAmount The initial amount of underlying Tokens supplied by the borrower
    /// @param _amountCollateralOutMin The minimum amount of Collateral Tokens to be received in exchange for the borrowed Asset Tokens
    /// @param _path An array containing the addresses of ERC20 tokens to swap.  Adheres to UniV2 style path params.
    /// @return _totalCollateralBalance The total amount of Collateral Tokens added to a users account (initial + swap)
    function leveragedPosition(
        address _swapperAddress,
        uint256 _borrowAmount,
        uint256 _initialUnderlyingAmount,
        uint256 _amountCollateralOutMin,
        address[] memory _path
    ) external nonReentrant isSolvent(msg.sender) returns (uint256 _totalCollateralBalance) {
        // Accrue interest if necessary
        _addInterest();

        // Update exchange rate
        _updateExchangeRate();

        IERC20 _debtToken = debtToken;
        IERC20 _collateral = collateral;

        if (!swappers[_swapperAddress]) {
            revert BadSwapper();
        }
        if (_path[0] != address(_debtToken)) {
            revert InvalidPath(address(_debtToken), _path[0]);
        }
        if (_path[_path.length - 1] != address(_collateral)) {
            revert InvalidPath(address(_collateral), _path[_path.length - 1]);
        }

        // Add initial underlying
        if (_initialUnderlyingAmount > 0) {
            underlying.safeTransferFrom(msg.sender, address(this), _initialUnderlyingAmount);
            uint256 collateralShares = IERC4626(address(collateral)).deposit(_initialUnderlyingAmount, address(this));
            _addCollateral(address(this), collateralShares, msg.sender);
            _totalCollateralBalance = collateralShares;
        }

        // Debit borrowers account
        // setting recipient to _swapperAddress allows us to skip a transfer (debt still goes to msg.sender)
        uint256 _borrowShares = _borrow(_borrowAmount.toUint128(), _swapperAddress);

        // Even though swappers are trusted, we verify the balance before and after swap
        uint256 _initialCollateralBalance = _collateral.balanceOf(address(this));
        ISwapper(_swapperAddress).swap(
            msg.sender,
            _borrowAmount,
            _path,
            address(this)
        );
        uint256 _finalCollateralBalance = _collateral.balanceOf(address(this));

        // Note: VIOLATES CHECKS-EFFECTS-INTERACTION pattern, make sure function is NONREENTRANT
        // Effects: bookkeeping & write to state
        uint256 _amountCollateralOut = _finalCollateralBalance - _initialCollateralBalance;
        if (_amountCollateralOut < _amountCollateralOutMin) {
            revert SlippageTooHigh(_amountCollateralOutMin, _amountCollateralOut);
        }

        // address(this) as _sender means no transfer occurs as the pair has already received the collateral during swap
        _addCollateral(address(this), _amountCollateralOut, msg.sender);

        _totalCollateralBalance += _amountCollateralOut;
        emit LeveragedPosition(
            msg.sender,
            _swapperAddress,
            _borrowAmount,
            _borrowShares,
            _initialUnderlyingAmount,
            _amountCollateralOut
        );
    }

    /// @notice The ```RepayWithCollateral``` event is emitted whenever ```repayWithCollateral()``` is invoked
    /// @param _borrower The borrower account for which the repayment is taking place
    /// @param _swapperAddress The address of the whitelisted swapper to use for token swaps
    /// @param _collateralToSwap The amount of Collateral Token to swap and use for repayment
    /// @param _amountAssetOut The amount of Asset Token which was repaid
    /// @param _sharesRepaid The number of Borrow Shares which were repaid
    event RepayWithCollateral(
        address indexed _borrower,
        address _swapperAddress,
        uint256 _collateralToSwap,
        uint256 _amountAssetOut,
        uint256 _sharesRepaid
    );

    /// @notice The ```repayWithCollateral``` function allows a borrower to repay their debt using existing collateral in contract
    /// @param _swapperAddress The address of the whitelisted swapper to use for token swaps
    /// @param _collateralToSwap The amount of Collateral Tokens to swap for Asset Tokens
    /// @param _amountOutMin The minimum amount of Asset Tokens to receive during the swap
    /// @param _path An array containing the addresses of ERC20 tokens to swap.  Adheres to UniV2 style path params.
    /// @return _amountOut The amount of Asset Tokens received for the Collateral Tokens, the amount the borrowers account was credited
    function repayWithCollateral(
        address _swapperAddress,
        uint256 _collateralToSwap,
        uint256 _amountOutMin,
        address[] calldata _path
    ) external nonReentrant isSolvent(msg.sender) returns (uint256 _amountOut) {
        // Accrue interest if necessary
        _addInterest();

        // Update exchange rate
        _updateExchangeRate();

        IERC20 _debtToken = debtToken;
        IERC20 _collateral = collateral;
        VaultAccount memory _totalBorrow = totalBorrow;

        if (!swappers[_swapperAddress]) {
            revert BadSwapper();
        }
        if (_path[0] != address(_collateral)) {
            revert InvalidPath(address(_collateral), _path[0]);
        }
        if (_path[_path.length - 1] != address(_debtToken)) {
            revert InvalidPath(address(_debtToken), _path[_path.length - 1]);
        }
        //in case of a full redemption/shutdown via protocol,
        //all user debt should be 0 and thus swapping to repay is unnecessary.
        //toShares below will also return an incorrect value.
        //in case of a full redemption, users can use the normal repayAsset with 0 cost
        //or just withdraw collateral via removeCollateral
        if(_totalBorrow.amount == 0){
            revert InsufficientBorrowAmount();
        }

        // Effects: bookkeeping & write to state
        // Debit users collateral balance and sends directly to the swapper
        // NOTE: isSolvent checkpoints msg.sender with _syncUserRedemptions
        _removeCollateral(_collateralToSwap, _swapperAddress, msg.sender);

        // Even though swappers are trusted, we verify the balance before and after swap
        uint256 _initialBalance = _debtToken.balanceOf(address(this));
        ISwapper(_swapperAddress).swap(
            msg.sender,
            _collateralToSwap,
            _path,
            address(this)
        );

        // Note: VIOLATES CHECKS-EFFECTS-INTERACTION pattern, make sure function is NONREENTRANT
        // Effects: bookkeeping
        _amountOut = _debtToken.balanceOf(address(this)) - _initialBalance;
        if (_amountOut < _amountOutMin) {
            revert SlippageTooHigh(_amountOutMin, _amountOut);
        }

        
        uint256 _sharesToRepay = _totalBorrow.toShares(_amountOut, false);

        //check if over user borrow shares or will revert
        uint256 currentUserBorrowShares = _userBorrowShares[msg.sender];
        if(_sharesToRepay > currentUserBorrowShares){
            //clamp
            _sharesToRepay = currentUserBorrowShares;

            //readjust token amount since shares changed
            _amountOut = _totalBorrow.toAmount(_sharesToRepay, true);
        }
        

        // Effects: write to state
        _repay(_totalBorrow, _amountOut.toUint128(), _sharesToRepay.toUint128(), address(this), msg.sender);

        //check for leftover stables that didnt go toward repaying debt
        uint256 leftover = debtToken.balanceOf(address(this)) - _initialBalance;
        if(leftover > 0){
            //send change back to user
            debtToken.transfer(msg.sender, leftover);
        }

        emit RepayWithCollateral(msg.sender, _swapperAddress, _collateralToSwap, _amountOut, _sharesToRepay);
    }
}